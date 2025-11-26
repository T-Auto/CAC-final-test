"""
提问模块 - 向被测模型发起提问并收集答案
支持新的标准化题目格式（prompt 直接从题目对象获取）
"""
import yaml
import os
import time
from typing import Dict, Any, List
from src.adaptors import create_adaptor, BaseLLMAdaptor
from src import logger as L


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


def ask_question(
    adaptor: BaseLLMAdaptor,
    question: Dict[str, Any],
    prompt_template: str,
    retry_config: Dict[str, Any],
    timestamp: str,
) -> str:
    """
    向模型提问
    
    Args:
        adaptor: LLM适配器
        question: 题目信息（包含 prompt 字段）
        prompt_template: 提示词模板
        retry_config: 重试配置
        timestamp: 时间戳
        
    Returns:
        str: 模型的答案
    """
    question_id = question["id"]
    
    # 新格式：直接从 question 对象获取 prompt
    if "prompt" in question:
        question_text = question["prompt"]
    else:
        # 兼容旧格式：从文件读取
        from src.md2str import md_to_string
        question_md_path = os.path.join("data", "questions", question_id, "question.md")
        try:
            question_text = md_to_string(question_md_path)
        except Exception as e:
            raise Exception(f"读取题目失败 [{question_id}]: {e}")
    
    prompt = prompt_template.replace("{question}", question_text)
    save_input(timestamp, adaptor.model_name, question_id, prompt)

    # 重试机制
    max_attempts = retry_config.get("max_attempts", 3)
    delay = retry_config.get("delay", 10.0)
    
    last_error = None
    for attempt in range(1, max_attempts + 1):
        try:
            L.info(f"向模型 {adaptor.model_name} 提问 (尝试 {attempt}/{max_attempts}): {question_id}")
            answer = adaptor.chat(prompt)
            L.info(f"成功获取答案: {question_id}")
            return answer
        except Exception as e:
            last_error = e
            L.warning(f"提问失败 (尝试 {attempt}/{max_attempts}): {str(e)}")
            if attempt < max_attempts:
                L.info(f"等待 {delay} 秒后重试...")
                time.sleep(delay)
    
    error_msg = f"提问失败，已重试 {max_attempts} 次: {str(last_error)}"
    L.error(error_msg)
    raise Exception(error_msg)


def save_input(
    timestamp: str,
    model_name: str,
    question_id: str,
    prompt: str,
    output_dir: str = "results/raw/input_test"
):
    """保存发送给模型的prompt"""
    os.makedirs(output_dir, exist_ok=True)
    safe_model_name = model_name.replace("/", "_").replace("\\", "_").replace(":", "_")
    safe_question_id = question_id.replace("/", "_").replace("\\", "_")

    filename = f"{timestamp}_output_{safe_model_name}_{safe_question_id}.yaml"
    filepath = os.path.join(output_dir, filename)

    data = {
        "model_name": model_name,
        "question_id": question_id,
        "prompt": prompt
    }

    with open(filepath, 'w', encoding='utf-8') as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)

    L.debug(f"已保存发送给模型的prompt: {filepath}")


def save_raw_answer(
    timestamp: str,
    model_name: str,
    question_id: str,
    answer: str,
    output_dir: str = "results/raw/test"
):
    """保存原始答案到YAML文件"""
    os.makedirs(output_dir, exist_ok=True)
    safe_model_name = model_name.replace("/", "_").replace("\\", "_").replace(":", "_")
    safe_question_id = question_id.replace("/", "_").replace("\\", "_")
    
    filename = f"{timestamp}_output_{safe_model_name}_{safe_question_id}.yaml"
    filepath = os.path.join(output_dir, filename)
    
    data = {
        "model_name": model_name,
        "question_id": question_id,
        "answer": answer
    }
    
    with open(filepath, 'w', encoding='utf-8') as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)
    
    L.debug(f"已保存原始答案: {filepath}")


def process_questions(
    test_models: List[Dict[str, Any]],
    questions: List[Dict[str, Any]],
    retry_config: Dict[str, Any],
    timestamp: str
) -> Dict[str, Dict[str, str]]:
    """
    处理所有题目，收集所有模型的答案
    
    Args:
        test_models: 被测模型配置列表
        questions: 题目列表
        retry_config: 重试配置
        timestamp: 时间戳
        
    Returns:
        Dict[str, Dict[str, str]]: 模型答案字典 {model_name: {question_id: answer}}
    """
    # 加载提示词模板
    prompt_template = load_prompt_template("prompts/question.md")
    
    all_answers = {}
    
    for model_config in test_models:
        model_name = model_config["model_name"]
        L.info(f"开始测试模型: {model_name}")
        
        try:
            adaptor = create_adaptor(
                provider=model_config["provider"],
                api_key=model_config["api_key"],
                base_url=model_config["base_url"],
                model_name=model_name,
                params=model_config.get("params")
            )
            
            if not adaptor.validate_config():
                L.error(f"模型配置无效: {model_name}")
                continue
            
            model_answers = {}
            
            for question in questions:
                question_id = question["id"]
                
                try:
                    answer = ask_question(adaptor, question, prompt_template, retry_config, timestamp)
                    save_raw_answer(timestamp, model_name, question_id, answer)
                    model_answers[question_id] = answer
                    
                except Exception as e:
                    L.error(f"处理题目失败 [{model_name}][{question_id}]: {str(e)}")
                    model_answers[question_id] = f"[ERROR] {str(e)}"
            
            all_answers[model_name] = model_answers
            L.info(f"完成测试模型: {model_name} ({len(model_answers)}/{len(questions)} 题)")
            
        except Exception as e:
            L.error(f"创建适配器失败 [{model_name}]: {str(e)}")
            continue
    
    return all_answers
