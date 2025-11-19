"""
适配器基类 - 定义所有LLM提供商需要实现的接口
"""
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional


class BaseLLMAdaptor(ABC):
    """LLM适配器抽象基类"""
    
    def __init__(self, api_key: str, base_url: str, model_name: str):
        """
        初始化适配器
        
        Args:
            api_key: API密钥
            base_url: API基础URL
            model_name: 模型名称
        """
        self.api_key = api_key
        self.base_url = base_url
        self.model_name = model_name
    
    @abstractmethod
    def chat(self, prompt: str, **kwargs) -> str:
        """
        发送聊天请求并获取响应
        
        Args:
            prompt: 提示词
            **kwargs: 其他参数（如temperature, max_tokens等）
            
        Returns:
            str: 模型的响应文本
            
        Raises:
            Exception: 当API调用失败时
        """
        pass
    
    @abstractmethod
    def get_provider_name(self) -> str:
        """
        获取提供商名称
        
        Returns:
            str: 提供商名称（如 "openai", "anthropic" 等）
        """
        pass
    
    def validate_config(self) -> bool:
        """
        验证配置是否有效
        
        Returns:
            bool: 配置是否有效
        """
        if not self.api_key:
            return False
        if not self.base_url:
            return False
        if not self.model_name:
            return False
        return True
