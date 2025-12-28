"""Provider 基类"""
from abc import ABC, abstractmethod
from typing import Optional

from ..config import ModelConfig


DEFAULT_PARAMS = {
    "temperature": 0.7,
    "max_tokens": 4096,
    "timeout": 300,
}


class BaseProvider(ABC):
    """LLM Provider 抽象基类"""

    def __init__(self, config: ModelConfig):
        self.config = config

    def get_param(self, key: str, override=None):
        """获取参数，优先级: override > config.params > DEFAULT_PARAMS"""
        if override is not None:
            return override
        return self.config.params.get(key, DEFAULT_PARAMS.get(key))

    @abstractmethod
    def chat(self, prompt: str) -> str:
        """发送请求，返回响应文本"""
        pass

    def supports_tool_calling(self) -> bool:
        """是否支持 tool calling，子类可覆盖"""
        return False

    def chat_with_tool(self, prompt: str, tool_schema: dict) -> dict:
        """强制使用 tool 调用，返回解析后的参数 dict。不支持时抛出 NotImplementedError"""
        raise NotImplementedError(f"{self.__class__.__name__} 不支持 tool calling")

    def get_model_name(self) -> str:
        """用于输出文件命名"""
        return self.config.name
