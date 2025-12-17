"""Anthropic Provider"""
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
        return result["content"][0]["text"]
