"""
字节跳动豆包（Doubao）API 适配器
"""
import requests
from typing import Dict, Any, Optional, List
from .base import BaseLLMAdaptor


class DoubaoAdaptor(BaseLLMAdaptor):
    """豆包API适配器（使用OpenAI兼容格式）"""
    
    def get_provider_name(self) -> str:
        return "doubao"
    
    def chat(self, prompt: str, system_prompt: Optional[str] = None, **kwargs) -> str:
        """
        调用豆包API
        
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
            "Authorization": f"Bearer {self.api_key}"
        }
        
        # 构建 messages（豆包使用 OpenAI 兼容格式）
        messages: List[Dict[str, str]] = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})
        
        # 准备请求体
        data: Dict[str, Any] = {
            "model": self.model_name,
            "messages": messages,
            "temperature": self.get_param("temperature", kwargs.get("temperature")),
            "max_tokens": self.get_param("max_tokens", kwargs.get("max_tokens")),
        }
        
        # 可选参数
        optional_params = ["top_p", "presence_penalty", "frequency_penalty", "stop"]
        for param in optional_params:
            value = self.get_param(param, kwargs.get(param))
            if value is not None:
                data[param] = value
        
        # 发送请求（豆包的 base_url 已经是完整路径）
        url = f"{self.base_url.rstrip('/')}"
        timeout = self.get_param("timeout", kwargs.get("timeout"))
        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()
        
        # 解析响应
        result = response.json()
        return result["choices"][0]["message"]["content"]
