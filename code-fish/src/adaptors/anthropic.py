"""
Anthropic API 适配器
"""
import requests
from typing import Dict, Any, Optional, List
from .base import BaseLLMAdaptor


class AnthropicAdaptor(BaseLLMAdaptor):
    """Anthropic API适配器"""
    
    def get_provider_name(self) -> str:
        return "anthropic"
    
    def chat(self, prompt: str, system_prompt: Optional[str] = None, **kwargs) -> str:
        """
        调用Anthropic API
        
        Args:
            prompt: 用户提示词
            system_prompt: 系统提示词（可选）
            **kwargs: 其他参数，可覆盖配置文件中的参数
            
        Returns:
            str: 模型响应
        """
        # 准备请求头
        headers = {
            "Content-Type": "application/json",
            "x-api-key": self.api_key,
            "anthropic-version": "2023-06-01"
        }
        
        # 构建 messages
        messages: List[Dict[str, str]] = [{"role": "user", "content": prompt}]
        
        # 准备请求体
        data: Dict[str, Any] = {
            "model": self.model_name,
            "messages": messages,
            "max_tokens": self.get_param("max_tokens", kwargs.get("max_tokens")),
            "temperature": self.get_param("temperature", kwargs.get("temperature")),
        }
        
        # Anthropic 的 system prompt 是顶层字段
        if system_prompt:
            data["system"] = system_prompt
        
        # 可选参数
        optional_params = ["top_p", "top_k", "stop_sequences"]
        for param in optional_params:
            value = self.get_param(param, kwargs.get(param))
            if value is not None:
                data[param] = value
        
        # 发送请求
        url = f"{self.base_url.rstrip('/')}/messages"
        timeout = self.get_param("timeout", kwargs.get("timeout"))
        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()
        
        # 解析响应
        result = response.json()
        return result["content"][0]["text"]
