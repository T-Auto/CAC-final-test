"""
适配器模块 - 提供不同LLM提供商的统一接口
"""
from typing import Dict, Any, Optional
from .base import BaseLLMAdaptor, DEFAULT_PARAMS
from .openai import OpenAIAdaptor
from .anthropic import AnthropicAdaptor
from .doubao import DoubaoAdaptor


# 适配器注册表
ADAPTOR_REGISTRY = {
    "openai": OpenAIAdaptor,
    "anthropic": AnthropicAdaptor,
    "doubao": DoubaoAdaptor,
}


def create_adaptor(
    provider: str,
    api_key: str,
    base_url: str,
    model_name: str,
    params: Optional[Dict[str, Any]] = None
) -> BaseLLMAdaptor:
    """
    创建适配器实例
    
    Args:
        provider: 提供商名称
        api_key: API密钥
        base_url: API基础URL
        model_name: 模型名称
        params: 模型参数配置（temperature, max_tokens, top_p, timeout 等）
        
    Returns:
        BaseLLMAdaptor: 适配器实例
        
    Raises:
        ValueError: 当提供商不支持时
    """
    if provider not in ADAPTOR_REGISTRY:
        raise ValueError(f"Unsupported provider: {provider}. Available providers: {list(ADAPTOR_REGISTRY.keys())}")
    
    adaptor_class = ADAPTOR_REGISTRY[provider]
    return adaptor_class(api_key=api_key, base_url=base_url, model_name=model_name, params=params)


__all__ = [
    "BaseLLMAdaptor",
    "OpenAIAdaptor",
    "AnthropicAdaptor",
    "DoubaoAdaptor",
    "ADAPTOR_REGISTRY",
    "DEFAULT_PARAMS",
    "create_adaptor",
]
