"""OpenAI Provider (含 custom 模式)"""
import json
import sys
import time

import requests

from .base import BaseProvider


class OpenAIProvider(BaseProvider):
    """OpenAI API Provider，也支持 custom 模式"""

    def supports_tool_calling(self) -> bool:
        """openai provider 支持 tool calling，custom 模式不支持"""
        return (self.config.provider or "").lower() != "custom"

    def chat_with_tool(self, prompt: str, tool_schema: dict) -> dict:
        """使用 function calling 强制输出结构化数据"""
        if not self.supports_tool_calling():
            raise NotImplementedError("custom provider 不支持 tool calling")

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.config.api_key}",
        }

        messages = [{"role": "user", "content": prompt}]
        tool_def = {"type": "function", "function": tool_schema}

        data = {
            "model": self.config.model_id,
            "messages": messages,
            "tools": [tool_def],
            "tool_choice": {"type": "function", "function": {"name": tool_schema["name"]}},
            "temperature": self.get_param("temperature"),
            "max_tokens": self.get_param("max_tokens"),
        }

        base_url = self.config.base_url.rstrip("/")
        url = base_url if base_url.endswith("/chat/completions") else f"{base_url}/chat/completions"
        timeout = self.get_param("timeout")

        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()

        result = response.json()
        tool_call = result["choices"][0]["message"]["tool_calls"][0]
        return json.loads(tool_call["function"]["arguments"])

    def chat(self, prompt: str) -> str:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.config.api_key}",
        }

        messages = [{"role": "user", "content": prompt}]
        stream = self.config.params.get("stream", False)

        # 透传所有 params，兼容各厂商参数 (reasoning_effort, enable_thinking 等)
        data = {
            "model": self.config.model_id,
            "messages": messages,
            "stream": stream,
            **self.config.params,
        }

        provider = (self.config.provider or "").lower()

        # URL: custom 模式不拼接，openai 模式拼接 /chat/completions
        if provider == "custom":
            url = self.config.base_url
        else:
            base_url = self.config.base_url.rstrip("/")
            url = base_url if base_url.endswith("/chat/completions") else f"{base_url}/chat/completions"

        timeout = self.get_param("timeout")

        if stream:
            return self._stream_chat(url, headers, data, timeout)

        response = requests.post(url, headers=headers, json=data, timeout=timeout)
        response.raise_for_status()
        return response.json()["choices"][0]["message"]["content"]

    def _stream_chat(self, url: str, headers: dict, data: dict, timeout: int) -> str:
        """流式请求，显示实时进度（仅 TTY 环境）"""
        start = time.time()
        ttft = None
        chunks = 0
        content = []
        is_tty = sys.stderr.isatty()

        with requests.post(url, headers=headers, json=data, timeout=timeout, stream=True) as resp:
            resp.raise_for_status()
            for line in resp.iter_lines():
                if not line:
                    continue
                line = line.decode("utf-8")
                if not line.startswith("data: "):
                    continue
                payload = line[6:]
                if payload == "[DONE]":
                    break
                try:
                    chunk = json.loads(payload)
                    delta = chunk.get("choices", [{}])[0].get("delta", {})
                    text = delta.get("content", "")
                    if text:
                        if ttft is None:
                            ttft = time.time() - start
                        chunks += 1
                        content.append(text)
                        if is_tty:
                            elapsed = time.time() - start
                            sys.stderr.write(f"\r  ⏳ TTFT: {ttft:.2f}s | {elapsed:.1f}s | ~{chunks} chunks")
                            sys.stderr.flush()
                except json.JSONDecodeError:
                    continue

        if is_tty:
            sys.stderr.write("\r" + " " * 60 + "\r")
            sys.stderr.flush()
        return "".join(content)
