"""
CAC 评测系统主程序
支持新的标准化题目格式（meta.yaml + prompt.md + reference.md）
"""
import os
import yaml
from datetime import datetime
from typing import Dict, Any, List

from src import logger as L
from src.ask import process_questions
from src.judge import process_judgments
from src.question_loader import load_questions_from_banks, validate_questions


def load_yaml_config(filepath: str) -> Dict[str, Any]:
    """加载YAML配置文件"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def load_yaml_data(filepath: str) -> List[Dict[str, Any]]:
    """加载YAML数据文件（列表）"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def save_final_results(
    timestamp: str,
    test_models: List[str],
    judge_model: str,
    questions: List[Dict[str, Any]],
    all_answers: Dict[str, Dict[str, str]],
    all_judgments: Dict[str, Dict[str, Any]],
    output_dir: str = "results"
):
    """保存最终结果"""
    os.makedirs(output_dir, exist_ok=True)
    questions_map = {q["id"]: q for q in questions}
    
    results = {}
    
    for model_name in test_models:
        if model_name not in all_answers:
            continue
        
        answers = all_answers[model_name]
        judgments = all_judgments.get(model_name, {})
        model_results = {}
        
        for question_id, answer in answers.items():
            question = questions_map.get(question_id)
            if not question:
                continue
            
            judgment = judgments.get(question_id, {})
            
            result_item = {
                "question_id": question_id,
                "question_brief": question.get("brief", ""),
                "category": question.get("category", ""),
                "difficulty": question.get("difficulty", ""),
                "model_answer": answer,
                "judgment": judgment.get("feedback", ""),
                "score": {
                    "max_score": question["scoring_std"]["max_score"],
                    **judgment.get("scores", {})
                }
            }
            
            model_results[question_id] = result_item
        
        results[model_name] = model_results
    
    final_output = {
        "timestamp": timestamp,
        "test_models": test_models,
        "judge_model": judge_model,
        "total_questions": len(questions),
        "results": results
    }
    
    filename = f"{timestamp}.yaml"
    filepath = os.path.join(output_dir, filename)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        yaml.safe_dump(final_output, f, allow_unicode=True, sort_keys=False)
    
    L.info(f"最终结果已保存: {filepath}")


def main():
    """主函数"""
    try:
        L.ENABLE_FILE = True
        L.reload_config()
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

        # 1. 加载配置文件
        test_config_path = "providers/test.yaml"
        judge_config_path = "providers/judge.yaml"
        
        if not os.path.exists(test_config_path):
            L.error(f"配置文件不存在: {test_config_path}")
            L.error("请复制 test.yaml.example 为 test.yaml 并填写配置")
            return
        
        if not os.path.exists(judge_config_path):
            L.error(f"配置文件不存在: {judge_config_path}")
            L.error("请复制 judge.yaml.example 为 judge.yaml 并填写配置")
            return
        
        test_config = load_yaml_config(test_config_path)
        judge_config_full = load_yaml_config(judge_config_path)
        
        test_models = test_config["test"]
        retry_config = test_config.get("retry", {"max_attempts": 3, "delay": 10.0})
        judge_config = judge_config_full["judge"]
        judge_retry_config = judge_config_full.get("retry", {"max_attempts": 3, "delay": 10.0})
        
        L.info(f"被测模型: {[m['model_name'] for m in test_models]}")
        L.info(f"评判模型: {judge_config['model_name']}")
        
        # 2. 加载题目（新格式：从题库目录扫描）
        L.info("=" * 60)
        L.info("加载题目")
        L.info("=" * 60)
        
        questions = load_questions_from_banks()
        
        if not questions:
            L.error("没有找到任何题目！请检查题库目录和 meta.yaml 文件")
            return
        
        # 3. 验证评分指标
        L.info("=" * 60)
        L.info("验证评分指标")
        L.info("=" * 60)
        
        indicators_data = load_yaml_data("data/indicators.yaml")
        if not validate_questions(questions, indicators_data):
            L.error("程序终止：indicators 验证失败")
            return
        
        L.info("✓ 所有题目验证通过")

        # 4. 向被测模型提问
        L.info("=" * 60)
        L.info("阶段 1: 向被测模型提问")
        L.info("=" * 60)
        
        all_answers = process_questions(
            test_models=test_models,
            questions=questions,
            retry_config=retry_config,
            timestamp=timestamp
        )
        
        L.info(f"收集到 {len(all_answers)} 个模型的答案")
        
        # 5. 评判答案
        L.info("=" * 60)
        L.info("阶段 2: 评判答案")
        L.info("=" * 60)
        
        all_judgments = process_judgments(
            judge_config=judge_config,
            questions=questions,
            all_answers=all_answers,
            retry_config=judge_retry_config,
            timestamp=timestamp
        )
        
        L.info(f"完成 {len(all_judgments)} 个模型的评判")
        
        # 6. 保存最终结果
        test_model_names = [m["model_name"] for m in test_models]
        
        save_final_results(
            timestamp=timestamp,
            test_models=test_model_names,
            judge_model=judge_config["model_name"],
            questions=questions,
            all_answers=all_answers,
            all_judgments=all_judgments
        )
        
        # 7. 输出统计信息
        L.info("=" * 60)
        L.info("评测完成 - 统计信息")
        L.info("=" * 60)
        
        for model_name in test_model_names:
            if model_name not in all_judgments:
                continue
            
            judgments = all_judgments[model_name]
            total_score = 0
            count = 0
            
            for judgment in judgments.values():
                scores = judgment.get("scores", {})
                final_score = scores.get("final_score", 0)
                total_score += final_score
                count += 1
            
            if count > 0:
                avg_score = total_score / count
                L.info(f"{model_name}: 平均分 = {avg_score:.2f} ({count} 题)")
        
    except Exception as e:
        L.exception(f"程序运行出错: {str(e)}")
        raise


if __name__ == "__main__":
    main()
