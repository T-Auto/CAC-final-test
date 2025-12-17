"""Provider 注册与工厂"""
from ..config import ModelConfig
from .base import BaseProvider
from .openai import OpenAIProvider
from .anthropic import AnthropicProvider
from .gemini import GeminiProvider


PROVIDER_REGISTRY = {
    "openai": OpenAIProvider,
    "anthropic": AnthropicProvider,
    "gemini": GeminiProvider,
    "custom": OpenAIProvider,  # custom 使用 OpenAI 格式
}


def create_provider(config: ModelConfig) -> BaseProvider:
    """根据配置创建 Provider 实例"""
    provider_type = config.provider.lower()
    if provider_type not in PROVIDER_REGISTRY:
        raise ValueError(f"不支持的 provider: {config.provider}")

    provider_class = PROVIDER_REGISTRY[provider_type]
    return provider_class(config)


__all__ = [
    "BaseProvider",
    "OpenAIProvider",
    "AnthropicProvider",
    "GeminiProvider",
    "create_provider",
    "PROVIDER_REGISTRY",
]
