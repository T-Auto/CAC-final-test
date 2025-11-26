"""
题目加载器 - 支持新的标准化题目格式
从题库目录扫描并加载 meta.yaml + prompt.md + reference.md 格式的题目
"""
import os
import yaml
from typing import Dict, Any, List, Optional
from src import logger as L


def load_question_banks_config(config_path: str = "data/question_banks.yaml") -> Dict[str, Any]:
    """
    加载题库配置文件
    
    Args:
        config_path: 配置文件路径
        
    Returns:
        Dict[str, Any]: 题库配置
    """
    with open(config_path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def scan_question_dir(question_path: str) -> Optional[Dict[str, Any]]:
    """
    扫描单个题目目录，加载题目信息
    
    Args:
        question_path: 题目目录路径
        
    Returns:
        Optional[Dict[str, Any]]: 题目信息，如果目录不符合格式则返回 None
    """
    meta_path = os.path.join(question_path, "meta.yaml")
    prompt_path = os.path.join(question_path, "prompt.md")
    reference_path = os.path.join(question_path, "reference.md")
    
    # 检查必需文件是否存在
    if not os.path.exists(meta_path):
        return None
    if not os.path.exists(prompt_path):
        L.warning(f"题目缺少 prompt.md: {question_path}")
        return None
    if not os.path.exists(reference_path):
        L.warning(f"题目缺少 reference.md: {question_path}")
        return None
    
    try:
        # 加载 meta.yaml
        with open(meta_path, 'r', encoding='utf-8') as f:
            meta = yaml.safe_load(f)
        
        # 加载 prompt.md
        with open(prompt_path, 'r', encoding='utf-8') as f:
            prompt = f.read().strip()
        
        # 加载 reference.md
        with open(reference_path, 'r', encoding='utf-8') as f:
            reference = f.read().strip()
        
        # 构建题目信息
        question = {
            "id": meta.get("id", os.path.basename(question_path)),
            "brief": meta.get("brief", ""),
            "category": meta.get("category", ""),
            "difficulty": meta.get("difficulty", ""),
            "scoring_std": meta.get("scoring_std", {"max_score": 10, "indicators": []}),
            "prompt": prompt,
            "reference": reference,
            "path": question_path,  # 保存路径用于后续写入测试结果
        }
        
        return question
        
    except Exception as e:
        L.error(f"加载题目失败 [{question_path}]: {e}")
        return None


def scan_difficulty_dir(bank_path: str, difficulty: str) -> List[Dict[str, Any]]:
    """
    扫描某个难度目录下的所有题目
    
    Args:
        bank_path: 题库路径
        difficulty: 难度级别 (base, advanced, final, final+)
        
    Returns:
        List[Dict[str, Any]]: 题目列表
    """
    # 处理 final+ 目录名
    dir_name = f"{difficulty}-test"
    difficulty_path = os.path.join(bank_path, dir_name)
    
    if not os.path.exists(difficulty_path):
        return []
    
    questions = []
    
    # 遍历难度目录下的所有子目录
    for item in sorted(os.listdir(difficulty_path)):
        item_path = os.path.join(difficulty_path, item)
        
        if not os.path.isdir(item_path):
            continue
        
        # 跳过隐藏目录
        if item.startswith('.'):
            continue
        
        question = scan_question_dir(item_path)
        if question:
            questions.append(question)
    
    return questions


def scan_comprehensive_dir(bank_path: str) -> List[Dict[str, Any]]:
    """
    扫描综合能力测评目录（没有难度分级）
    
    Args:
        bank_path: 题库路径
        
    Returns:
        List[Dict[str, Any]]: 题目列表
    """
    if not os.path.exists(bank_path):
        return []
    
    questions = []
    
    # 综合能力测评直接在根目录下有题目目录
    for item in sorted(os.listdir(bank_path)):
        item_path = os.path.join(bank_path, item)
        
        if not os.path.isdir(item_path):
            continue
        
        # 跳过隐藏目录和难度目录
        if item.startswith('.') or item.endswith('-test'):
            continue
        
        question = scan_question_dir(item_path)
        if question:
            questions.append(question)
    
    return questions


def load_questions_from_banks(
    config_path: str = "data/question_banks.yaml",
    categories: Optional[List[str]] = None,
    difficulties: Optional[List[str]] = None
) -> List[Dict[str, Any]]:
    """
    从题库配置加载所有题目
    
    Args:
        config_path: 题库配置文件路径
        categories: 要加载的类别列表，None 表示全部
        difficulties: 要加载的难度列表，None 表示全部
        
    Returns:
        List[Dict[str, Any]]: 题目列表
    """
    config = load_question_banks_config(config_path)
    banks = config.get("banks", [])
    difficulty_levels = config.get("difficulty_levels", ["base", "advanced", "final", "final+"])
    
    # 过滤难度
    if difficulties:
        difficulty_levels = [d for d in difficulty_levels if d in difficulties]
    
    all_questions = []
    
    for bank in banks:
        bank_path = bank["path"]
        bank_category = bank["category"]
        bank_name = bank.get("name", bank_category)
        
        # 过滤类别
        if categories and bank_category not in categories:
            continue
        
        L.info(f"扫描题库: {bank_name} ({bank_path})")
        
        # 综合能力测评特殊处理
        if bank_category == "comprehensive":
            questions = scan_comprehensive_dir(bank_path)
            all_questions.extend(questions)
            L.info(f"  找到 {len(questions)} 道题目")
        else:
            # 按难度扫描
            for difficulty in difficulty_levels:
                questions = scan_difficulty_dir(bank_path, difficulty)
                all_questions.extend(questions)
                if questions:
                    L.info(f"  {difficulty}: {len(questions)} 道题目")
    
    L.info(f"共加载 {len(all_questions)} 道题目")
    return all_questions


def validate_questions(questions: List[Dict[str, Any]], indicators_data: List[Dict[str, Any]]) -> bool:
    """
    验证题目的评分指标是否都已定义
    
    Args:
        questions: 题目列表
        indicators_data: indicators 数据列表
        
    Returns:
        bool: 验证是否通过
    """
    # 构建所有可用的 indicator 集合
    all_indicators = set()
    for category in indicators_data:
        category_indicators = category.get("indicators", {})
        all_indicators.update(category_indicators.keys())
    
    L.info(f"已加载 {len(all_indicators)} 个可用评分指标")
    
    # 检查每个题目的 indicators
    has_error = False
    for question in questions:
        question_id = question["id"]
        scoring_std = question.get("scoring_std", {})
        indicators = scoring_std.get("indicators", [])
        
        if not isinstance(indicators, list):
            L.error(f"题目 [{question_id}] 的 indicators 不是数组类型")
            has_error = True
            continue
        
        for indicator in indicators:
            if indicator not in all_indicators:
                L.error(f"题目 [{question_id}] 使用了未定义的 indicator: {indicator}")
                has_error = True
    
    return not has_error
