"""
Anthropic API 适配器
"""
import json
import requests
from typing import Dict, Any
from .base import BaseLLMAdaptor


class AnthropicAdaptor(BaseLLMAdaptor):
    """Anthropic API适配器"""
    
    def get_provider_name(self) -> str:
        return "anthropic"
    
    def chat(self, prompt: str, **kwargs) -> str:
        """
        调用Anthropic API
        
        Args:
            prompt: 提示词
            **kwargs: 其他参数
            
        Returns:
            str: 模型响应
        """
        # 准备请求头
        headers = {
            "Content-Type": "application/json",
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01"
        }
        
        # 准备请求体
        data = {
            "model": self.model_name,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "max_tokens": kwargs.get("max_tokens", 4096),
            "temperature": kwargs.get("temperature", 0.7)
        }
        
        # 发送请求
        url = f"{self.base_url.rstrip('/')}/messages"
        response = requests.post(url, headers=headers, json=data, timeout=900)
        response.raise_for_status()
        
        # 解析响应
        result = response.json()
        return result["content"][0]["text"]
