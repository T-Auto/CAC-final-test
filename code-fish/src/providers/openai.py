"""OpenAI Provider (含 custom 模式)"""
import requests

from .base import BaseProvider


class OpenAIProvider(BaseProvider):
    """OpenAI API Provider，也支持 custom 模式"""

    def chat(self, prompt: str) -> str:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.config.api_key}",
        }

        messages = [{"role": "user", "content": prompt}]

        data = {
            "model": self.config.model_id,
            "messages": messages,
            "temperature": self.get_param("temperature"),
            "max_tokens": self.get_param("max_tokens"),
        }

        # 可选参数
        for param in ["top_p", "presence_penalty", "frequency_penalty", "stop"]:
            value = self.config.params.get(param)
            if value is not None:
                data[param] = value

        provider = (self.config.provider or "").lower()

        # URL: custom 模式不拼接，openai 模式拼接 /chat/completions
        if provider == "custom":
            url = self.config.base_url
        else:
            base_url = self.config.base_url.rstrip("/")
            if base_url.endswith("/chat/completions"):
                url = base_url
            else:
                url = f"{base_url}/chat/completions"

        timeout = self.get_param("timeout")
        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()

        result = response.json()
        return result["choices"][0]["message"]["content"]
