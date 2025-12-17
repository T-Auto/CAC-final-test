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
    test_model: ModelConfig
    judge_model: Optional[ModelConfig]
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


def _parse_model(data: dict, section: str) -> ModelConfig:
    try:
        return ModelConfig(
            name=data["name"],
            provider=data["provider"],
            api_key=data["api_key"],
            base_url=data["base_url"],
            model_id=data.get("model_id", data["name"]),
            params=data.get("params", {}),
        )
    except KeyError as e:
        raise ValueError(f"{section} 缺少字段: {e.args[0]}") from e


def load_config(config_path: str) -> Config:
    """加载配置文件"""
    path = Path(config_path)
    if not path.exists():
        raise FileNotFoundError(f"配置文件不存在: {config_path}")

    with open(path, "r", encoding="utf-8") as f:
        raw = yaml.safe_load(f)

    if raw is None:
        raw = {}
    if not isinstance(raw, dict):
        raise ValueError("配置格式无效: 顶层必须是 YAML map/object")

    # 解析 test-model（必选）
    test_model_data = raw.get("test-model") or raw.get("model")
    if test_model_data is None:
        raise ValueError("配置缺少 test-model")
    if not isinstance(test_model_data, dict):
        raise ValueError("test-model 必须是对象")
    test_model = _parse_model(expand_env_vars_recursive(test_model_data), "test-model")

    # 解析 judge-model（可选）
    judge_model_data = raw.get("judge-model")
    if judge_model_data is None:
        judge_model = None
    else:
        if not isinstance(judge_model_data, dict):
            raise ValueError("judge-model 必须是对象")
        judge_model = _parse_model(expand_env_vars_recursive(judge_model_data), "judge-model")

    # 解析 retry
    retry_data = raw.get("retry", {})
    if retry_data is None:
        retry_data = {}
    if not isinstance(retry_data, dict):
        raise ValueError("retry 必须是对象")
    retry_data = expand_env_vars_recursive(retry_data)
    retry = RetryConfig(
        max_attempts=retry_data.get("max_attempts", 3),
        delay=retry_data.get("delay", 10.0),
    )

    question_banks = expand_env_vars(raw.get("question_banks", "data/question_banks.yaml"))

    return Config(test_model=test_model, judge_model=judge_model, retry=retry, question_banks=question_banks)
