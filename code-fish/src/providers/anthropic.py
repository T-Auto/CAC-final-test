"""Anthropic Provider"""
import json
import requests

from .base import BaseProvider


class AnthropicProvider(BaseProvider):
    """Anthropic/Claude API Provider"""

    def chat(self, prompt: str) -> str:
        headers = {
            "Content-Type": "application/json",
            "x-api-key": self.config.api_key,
            "anthropic-version": "2023-06-01",
        }

        messages = [{"role": "user", "content": prompt}]

        data = {
            "model": self.config.model_id,
            "messages": messages,
            "max_tokens": self.get_param("max_tokens"),
            "temperature": self.get_param("temperature"),
        }

        # 可选参数
        for param in ["top_p", "top_k", "stop_sequences"]:
            value = self.config.params.get(param)
            if value is not None:
                data[param] = value

        # 移除stream参数（当前不支持流式响应）
        data.pop("stream", None)

        url = f"{self.config.base_url.rstrip('/')}/v1/messages"
        timeout = self.get_param("timeout")
        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()

        result = response.json()
        
        # 解析 Anthropic/MiniMax 标准格式
        thinking_content = ""
        text_content = ""
        
        for item in result["content"]:
            if isinstance(item, dict):
                item_type = item.get("type", "")
                if item_type == "thinking":
                    # thinking 块的内容在 "thinking" 键中
                    thinking_content = item.get("thinking", "")
                elif item_type == "text":
                    text_content = item.get("text", "")
        
        # 组合输出：thinking 包裹在 <thinking> 标签中
        if thinking_content:
            return f"<thinking>\n{thinking_content}\n</thinking>\n\n{text_content}"
        return text_content
