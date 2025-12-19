"""Anthropic Provider"""
import json
import sys
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

        url = f"{self.config.base_url.rstrip('/')}/v1/messages"
        timeout = self.get_param("timeout")
        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()

        result = response.json()
        
        # 调试：打印完整响应结构
        print(f"[DEBUG] MiniMax response keys: {result.keys()}", file=sys.stderr)
        if "content" in result:
            print(f"[DEBUG] content type: {type(result['content'])}, value: {result['content']}", file=sys.stderr)
        
        return result["content"][0]["text"]
