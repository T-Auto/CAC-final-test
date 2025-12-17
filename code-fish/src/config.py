"""配置加载模块 - 支持环境变量替换"""
import os
import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

import yaml


@dataclass
class ModelConfig:
    """模型配置"""
    name: str
    provider: str
    api_key: str
    base_url: str
    model_id: str
    params: dict = field(default_factory=dict)


@dataclass
class RetryConfig:
    """重试配置"""
    max_attempts: int = 3
    delay: float = 10.0


@dataclass
class Config:
    """完整配置"""
    model: ModelConfig
    retry: RetryConfig
    question_banks: str = "data/question_banks.yaml"


def expand_env_vars(value: str) -> str:
    """展开环境变量 ${VAR} 或 $VAR"""
    if not isinstance(value, str):
        return value

    pattern = r'\$\{([^}]+)\}|\$([A-Za-z_][A-Za-z0-9_]*)'

    def replace(match):
        var_name = match.group(1) or match.group(2)
        env_value = os.environ.get(var_name)
        if env_value is None:
            raise ValueError(f"环境变量未设置: {var_name}")
        return env_value

    return re.sub(pattern, replace, value)


def expand_env_vars_recursive(obj):
    """递归展开字典/列表中的环境变量"""
    if isinstance(obj, str):
        return expand_env_vars(obj)
    elif isinstance(obj, dict):
        return {k: expand_env_vars_recursive(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [expand_env_vars_recursive(item) for item in obj]
    return obj


def load_config(config_path: str) -> Config:
    """加载配置文件"""
    path = Path(config_path)
    if not path.exists():
        raise FileNotFoundError(f"配置文件不存在: {config_path}")

    with open(path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f)

    # 展开环境变量
    data = expand_env_vars_recursive(raw)

    # 解析 model
    model_data = data.get("model", {})
    model = ModelConfig(
        name=model_data["name"],
        provider=model_data["provider"],
        api_key=model_data["api_key"],
        base_url=model_data["base_url"],
        model_id=model_data.get("model_id", model_data["name"]),
        params=model_data.get("params", {}),
    )

    # 解析 retry
    retry_data = data.get("retry", {})
    retry = RetryConfig(
        max_attempts=retry_data.get("max_attempts", 3),
        delay=retry_data.get("delay", 10.0),
    )

    # 题库路径
    question_banks = data.get("question_banks", "data/question_banks.yaml")

    return Config(model=model, retry=retry, question_banks=question_banks)
