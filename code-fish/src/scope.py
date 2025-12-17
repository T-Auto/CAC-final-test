"""Scope 解析器 - 解析测试范围"""
import re
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional, Tuple

import yaml


@dataclass
class Question:
    """题目信息"""
    path: Path
    id: str
    number: int


CATEGORY_MAP = {
    "math": "数理能力基准测试题库",
    "code": "代码能力基准测试题库",
    "logic": "自然语言与逻辑能力基准测试题库",
    "comp": "综合能力测评",
    "comprehensive": "综合能力测评",
}


class ScopeResolver:
    """解析 scope 并返回匹配的题目列表"""

    def __init__(self, banks_config_path: str = "data/question_banks.yaml"):
        self.banks_config_path = Path(banks_config_path).resolve()
        self.banks_config = self._load_banks_config()
        self.base_dir = self.banks_config_path.parent.parent  # code-fish 目录

    def _load_banks_config(self) -> dict:
        with open(self.banks_config_path, "r", encoding="utf-8") as f:
            return yaml.safe_load(f)

    def resolve(
        self, scope_str: str, range_str: Optional[str] = None
    ) -> List[Question]:
        """
        解析 scope 字符串

        Args:
            scope_str: "math", "math/base-test", "math/base"
            range_str: "001-005" 或 "003"

        Returns:
            匹配的题目列表
        """
        parts = scope_str.strip("/").split("/")
        category = parts[0]
        difficulty = parts[1] if len(parts) > 1 else None

        # 解析 range
        range_start, range_end = self._parse_range(range_str)

        # 获取题库目录
        bank_path = self._get_bank_path(category)
        if bank_path is None:
            raise ValueError(f"未知的题库类别: {category}")

        # 扫描题目
        questions = self._scan_questions(bank_path, difficulty, range_start, range_end)
        return sorted(questions, key=lambda q: (q.path.parent.name, q.number))

    def _parse_range(self, range_str: Optional[str]) -> Tuple[Optional[int], Optional[int]]:
        """解析 "001-005" 或 "003" 格式"""
        if not range_str:
            return None, None
        if "-" in range_str:
            start, end = range_str.split("-", 1)
            return int(start), int(end)
        num = int(range_str)
        return num, num

    def _get_bank_path(self, category: str) -> Optional[Path]:
        """根据 category 获取题库路径"""
        # 先尝试 CATEGORY_MAP
        if category in CATEGORY_MAP:
            dir_name = CATEGORY_MAP[category]
            return (self.base_dir.parent / dir_name).resolve()

        # 再尝试从配置文件查找
        for bank in self.banks_config.get("banks", []):
            if bank.get("category") == category:
                return (self.base_dir / bank["path"]).resolve()

        return None

    def _scan_questions(
        self,
        bank_path: Path,
        difficulty: Optional[str],
        range_start: Optional[int],
        range_end: Optional[int],
    ) -> List[Question]:
        """扫描匹配的题目"""
        questions = []

        def is_in_range(number: int) -> bool:
            if range_start is not None and number < range_start:
                return False
            if range_end is not None and number > range_end:
                return False
            return True

        def scan_difficulty_dir(difficulty_dir: Path):
            if not difficulty_dir.exists():
                return

            for item in difficulty_dir.iterdir():
                if not item.is_dir():
                    continue
                if not (item / "prompt.md").exists():
                    continue
                match = re.match(r"^(\d+)", item.name)
                if not match:
                    continue
                number = int(match.group(1))
                if not is_in_range(number):
                    continue
                questions.append(Question(path=item, id=item.name, number=number))

        if difficulty:
            scan_difficulty_dir(bank_path / self._normalize_difficulty(difficulty))
            return questions

        for diff_dir in ["base-test", "advanced-test", "final-test", "final-test+"]:
            scan_difficulty_dir(bank_path / diff_dir)

        return questions

    def _normalize_difficulty(self, difficulty: str) -> str:
        """标准化难度名称"""
        # 移除 -test 后缀（如果有），然后添加
        difficulty = difficulty.rstrip("/")
        if difficulty in {"base-test", "advanced-test", "final-test", "final-test+"}:
            return difficulty
        if difficulty.endswith("-test"):
            return difficulty
        if difficulty == "final+":
            return "final-test+"
        return f"{difficulty}-test"
