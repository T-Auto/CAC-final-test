"""
评判模块 - 使用评判模型对答案进行打分
"""
import yaml
import os
import re
from typing import Dict, Any, List
from src.adaptors import create_adaptor, BaseLLMAdaptor
from src import logger as L
import time
from src.md2str import md_to_string


def load_prompt_template(template_path: str) -> str:
    """
    加载提示词模板
    
    Args:
        template_path: 模板文件路径
        
    Returns:
        str: 模板内容
    """
    with open(template_path, 'r', encoding='utf-8') as f:
        return f.read()


def build_judge_prompt(
    question: Dict[str, Any],
    model_answer: str,
    prompt_template: str,
    indicators_map: Dict[str, Dict[str, str]]
) -> str:
    """
    构建评判提示词
    
    Args:
        question: 题目信息
        model_answer: 模型答案
        prompt_template: 提示词模板
        indicators_map: indicators 映射表 {indicator_name: description}
        
    Returns:
        str: 构建好的提示词
    """
    # 获取评分标准
    scoring_std = question["scoring_std"]
    max_score = scoring_std["max_score"]
    indicators = scoring_std["indicators"]  # 现在是数组
    
    # 格式化评分指标（从 indicators_map 获取描述）
    indicators_text_list = []
    for indicator_name in indicators:
        description = indicators_map.get(indicator_name, f"[未定义指标: {indicator_name}]")
        indicators_text_list.append(f"  - **{indicator_name}**: {description}")
    indicators_text = "\n".join(indicators_text_list)
    
    # 构建评分字段列表（YAML，不包含 final_score）
    score_fields_list = [f"  {name}: <{name}得分>" for name in indicators]
    score_fields = "\n".join(score_fields_list)
    
    # 读取题目与标准答案 Markdown
    qid = question["id"]
    base_dir = os.path.join("data", "questions", qid)
    question_md_path = os.path.join(base_dir, "question.md")
    std_answer_md_path = os.path.join(base_dir, "answer.md")
    try:
        question_text = md_to_string(question_md_path)
        std_answer_text = md_to_string(std_answer_md_path)
    except Exception as e:
        raise Exception(f"读取评判所需Markdown失败 [{qid}]: {e}")
    
    # 替换模板变量
    prompt = prompt_template.replace("{question}", question_text)
    prompt = prompt.replace("{std_answer}", std_answer_text)
    prompt = prompt.replace("{model_answer}", model_answer)
    prompt = prompt.replace("{max_score}", str(max_score))
    prompt = prompt.replace("{indicators}", indicators_text)
    prompt = prompt.replace("{score_fields}", score_fields)
    
    return prompt


def parse_judgment_response(response: str, indicators: List[str] = None) -> Dict[str, Any]:
    """
    解析评判响应，提取YAML格式的评分结果，并自动计算 final_score
    
    Args:
        response: 模型响应
        indicators: 评分指标列表，用于计算 final_score
        
    Returns:
        Dict[str, Any]: 解析后的评分结果（包含自动计算的 final_score）
    """
    # 提取 YAML 文本（优先代码块）
    yaml_match = re.search(r'```(?:yaml|yml)?\s*([\s\S]*?)\s*```', response, re.DOTALL)
    yaml_text = yaml_match.group(1) if yaml_match else response

    def try_load_yaml(text: str) -> Dict[str, Any]:
        return yaml.safe_load(text)

    def sanitize_unknown_backslashes(text: str) -> str:
        # 将不被 YAML 双引号支持的反斜杠转义加倍，避免 \m、\g 等触发解析错误
        return re.sub(r'\\(?![0abtnvfre"\\/N_LPuxU])', r'\\\\', text)

    # 第一次尝试
    try:
        content = try_load_yaml(yaml_text)
    except yaml.YAMLError as e:
        # 失败后，对未知转义进行加倍，再次尝试
        fixed_text = sanitize_unknown_backslashes(yaml_text)
        try:
            content = try_load_yaml(fixed_text)
        except yaml.YAMLError as e2:
            L.error(f"YAML解析失败: {str(e2)}")
            return {
                "feedback": response,
                "scores": {
                    "final_score": 0.0
                }
            }

    if not isinstance(content, dict):
        # 内容不是映射，回退为原文
        return {
            "feedback": response,
            "scores": {
                "final_score": 0.0
            }
        }

    # 确保基本结构存在
    if "scores" not in content or not isinstance(content["scores"], dict):
        content["scores"] = {}

    # 计算 final_score（所有 indicators 的平均分）
    if indicators:
        scores = content["scores"]
        indicator_scores = []
        
        for indicator in indicators:
            if indicator in scores:
                try:
                    score_value = float(scores[indicator])
                    indicator_scores.append(score_value)
                except (ValueError, TypeError):
                    L.warning(f"指标 {indicator} 的分数无法转换为数字: {scores[indicator]}")
        
        if indicator_scores:
            final_score = round(sum(indicator_scores) / len(indicator_scores), 2)
            content["scores"]["final_score"] = final_score
            L.debug(f"自动计算 final_score: {indicator_scores} -> {final_score}")
        else:
            L.warning("没有找到有效的指标分数，final_score 设为 0.0")
            content["scores"]["final_score"] = 0.0

    return content


def judge_answer(
    adaptor: BaseLLMAdaptor,
    question: Dict[str, Any],
    model_answer: str,
    prompt_template: str,
    retry_config: Dict[str, Any],
    timestamp: str,
    indicators_map: Dict[str, str]
) -> Dict[str, Any]:
    """
    评判答案
    
    Args:
        adaptor: 评判模型适配器
        question: 题目信息
        model_answer: 模型答案
        prompt_template: 提示词模板
        retry_config: 重试配置
        timestamp: str
        indicators_map: indicators 映射表 {indicator_name: description}
        
    Returns:
        Dict[str, Any]: 评判结果
    """
    # 构建提示词
    prompt = build_judge_prompt(question, model_answer, prompt_template, indicators_map)
    save_input(timestamp, adaptor.model_name, question["id"], prompt)
    
    # 获取该题目的 indicators 列表
    indicators = question.get("scoring_std", {}).get("indicators", [])
    
    # 重试机制
    max_attempts = retry_config.get("max_attempts", 3)
    delay = retry_config.get("delay", 10.0)
    
    last_error = None
    for attempt in range(1, max_attempts + 1):
        try:
            L.info(f"评判答案 (尝试 {attempt}/{max_attempts}): {question['id']}")
            response = adaptor.chat(prompt)
            
            # 解析响应（传递 indicators 用于计算 final_score）
            judgment = parse_judgment_response(response, indicators)
            L.info(f"成功获取评判结果: {question['id']}")
            return judgment
            
        except Exception as e:
            last_error = e
            L.warning(f"评判失败 (尝试 {attempt}/{max_attempts}): {str(e)}")
            if attempt < max_attempts:
                L.info(f"等待 {delay} 秒后重试...")
                time.sleep(delay)
    
    # 所有重试都失败
    error_msg = f"评判失败，已重试 {max_attempts} 次: {str(last_error)}"
    L.error(error_msg)
    return {
        "feedback": f"[ERROR] {error_msg}",
        "scores": {
            "final_score": 0.0
        }
    }

def save_input(
    timestamp: str,
    model_name: str,
    question_id: str,
    prompt: str,
    output_dir: str = "results/raw/input-judge"
):
    os.makedirs(output_dir, exist_ok=True)

    # 清理模型名称
    safe_model_name = model_name.replace("/", "_").replace("\\", "_").replace(":", "_")

    filename = f"{timestamp}_judgment_{safe_model_name}_{question_id}.yaml"
    filepath = os.path.join(output_dir, filename)

    data = {
        "model_name": model_name,
        "question_id": question_id,
        "prompt": prompt
    }

    with open(filepath, 'w', encoding='utf-8') as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)

    L.debug(f"已保存发送给模型的prompt: {filepath}")

def save_raw_judgment(
    timestamp: str,
    model_name: str,
    question_id: str,
    std_answer: str,
    model_answer: str,
    judgment: Dict[str, Any],
    output_dir: str = "results/raw/judge"
):
    """
    保存原始评判结果到YAML文件
    
    Args:
        timestamp: 时间戳
        model_name: 被测模型名称
        question_id: 题目ID
        std_answer: 标准答案
        model_answer: 模型答案
        judgment: 评判结果
        output_dir: 输出目录
    """
    os.makedirs(output_dir, exist_ok=True)
    
    # 清理模型名称
    safe_model_name = model_name.replace("/", "_").replace("\\", "_").replace(":", "_")
    
    filename = f"{timestamp}_judgment_{safe_model_name}_{question_id}.yaml"
    filepath = os.path.join(output_dir, filename)
    
    data = {
        "model_name": model_name,
        "question_id": question_id,
        "std_answer": std_answer,
        "model_answer": model_answer,
        "feedback": judgment.get("feedback", ""),
        "scores": judgment.get("scores", {})
    }
    
    with open(filepath, 'w', encoding='utf-8') as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)
    
    L.debug(f"已保存原始评判: {filepath}")


def load_indicators() -> Dict[str, str]:
    """
    加载 indicators.yaml 并构建映射表
    
    Returns:
        Dict[str, str]: {indicator_name: description}
    """
    with open("data/indicators.yaml", 'r', encoding='utf-8') as f:
        indicators_data = yaml.safe_load(f)
    
    # 构建扁平化的映射表
    indicators_map = {}
    for category in indicators_data:
        category_indicators = category.get("indicators", {})
        indicators_map.update(category_indicators)
    
    return indicators_map


def process_judgments(
    judge_config: Dict[str, Any],
    questions: List[Dict[str, Any]],
    all_answers: Dict[str, Dict[str, str]],
    retry_config: Dict[str, Any],
    timestamp: str
) -> Dict[str, Dict[str, Any]]:
    """
    处理所有评判
    
    Args:
        judge_config: 评判模型配置
        questions: 题目列表
        all_answers: 所有模型的答案 {model_name: {question_id: answer}}
        retry_config: 重试配置
        timestamp: 时间戳
        
    Returns:
        Dict[str, Dict[str, Any]]: 评判结果 {model_name: {question_id: judgment}}
    """
    # 加载 indicators 映射表
    indicators_map = load_indicators()
    L.info(f"已加载 {len(indicators_map)} 个评分指标")
    
    # 加载提示词模板
    prompt_template = load_prompt_template("prompts/judge.md")
    
    # 创建评判模型适配器（支持 params 配置）
    judge_adaptor = create_adaptor(
        provider=judge_config["provider"],
        api_key=judge_config["api_key"],
        base_url=judge_config["base_url"],
        model_name=judge_config["model_name"],
        params=judge_config.get("params")
    )
    
    if not judge_adaptor.validate_config():
        raise Exception("评判模型配置无效")
    
    L.info(f"使用评判模型: {judge_config['model_name']}")
    
    # 存储所有评判结果
    all_judgments = {}
    
    # 创建题目映射
    questions_map = {q["id"]: q for q in questions}
    
    # 遍历所有被测模型
    for model_name, answers in all_answers.items():
        L.info(f"开始评判模型 {model_name} 的答案")
        
        model_judgments = {}
        
        # 遍历该模型的所有答案
        for question_id, answer in answers.items():
            question = questions_map.get(question_id)
            if not question:
                L.warning(f"找不到题目: {question_id}")
                continue
            
            try:
                # 评判答案
                judgment = judge_answer(
                    judge_adaptor,
                    question,
                    answer,
                    prompt_template,
                    retry_config,
                    timestamp,
                    indicators_map
                )
                
                # 保存原始评判
                # 读取标准答案 Markdown 以便保存
                std_answer_text = ""
                try:
                    std_answer_text = md_to_string(os.path.join("data", "questions", question_id, "answer.md"))
                except Exception as e:
                    L.warning(f"读取标准答案失败 [{question_id}]: {e}")
                save_raw_judgment(
                    timestamp,
                    model_name,
                    question_id,
                    std_answer_text,
                    answer,
                    judgment
                )
                
                # 存储到内存
                model_judgments[question_id] = judgment
                
            except Exception as e:
                L.error(f"评判答案失败 [{model_name}][{question_id}]: {str(e)}")
                model_judgments[question_id] = {
                    "feedback": f"[ERROR] {str(e)}",
                    "scores": {"final_score": 0.0}
                }
        
        all_judgments[model_name] = model_judgments
        L.info(f"完成评判模型 {model_name} ({len(model_judgments)}/{len(answers)} 题)")
    
    return all_judgments
