"""Google Gemini Provider"""
import requests

from .base import BaseProvider


class GeminiProvider(BaseProvider):
    """Google Gemini API Provider"""

    def supports_tool_calling(self) -> bool:
        """Gemini 支持 function calling"""
        return True

    def chat_with_tool(self, prompt: str, tool_schema: dict) -> dict:
        """使用 function calling 强制输出结构化数据"""
        params = {"key": self.config.api_key}
        headers = {"Content-Type": "application/json"}

        # 转换为 Gemini function declaration 格式
        gemini_func = {
            "name": tool_schema["name"],
            "description": tool_schema.get("description", ""),
            "parameters": tool_schema["parameters"],
        }

        data = {
            "contents": [{"parts": [{"text": prompt}]}],
            "tools": [{"functionDeclarations": [gemini_func]}],
            "toolConfig": {
                "functionCallingConfig": {
                    "mode": "ANY",
                    "allowedFunctionNames": [tool_schema["name"]],
                }
            },
            "generationConfig": {
                "temperature": self.get_param("temperature"),
                "maxOutputTokens": self.get_param("max_tokens"),
            },
        }

        url = f"{self.config.base_url.rstrip('/')}/v1beta/models/{self.config.model_id}:generateContent"
        timeout = self.get_param("timeout")
        response = requests.post(
            url, headers=headers, json=data, params=params, timeout=timeout
        )
        response.raise_for_status()

        result = response.json()
        
        # 从 candidates 中提取 functionCall
        parts = result["candidates"][0]["content"]["parts"]
        for part in parts:
            if "functionCall" in part:
                return part["functionCall"]["args"]

        raise ValueError("Gemini 响应中未找到 functionCall")

    def chat(self, prompt: str) -> str:
        # Gemini API key 通过 query param 传递
        params = {"key": self.config.api_key}

        headers = {"Content-Type": "application/json"}

        data = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "temperature": self.get_param("temperature"),
                "maxOutputTokens": self.get_param("max_tokens"),
            },
        }

        # 可选参数
        if "top_p" in self.config.params:
            data["generationConfig"]["topP"] = self.config.params["top_p"]
        if "top_k" in self.config.params:
            data["generationConfig"]["topK"] = self.config.params["top_k"]

        url = f"{self.config.base_url.rstrip('/')}/v1beta/models/{self.config.model_id}:generateContent"
        timeout = self.get_param("timeout")
        response = requests.post(
            url, headers=headers, json=data, params=params, timeout=timeout
        )
        response.raise_for_status()

        result = response.json()
        return result["candidates"][0]["content"]["parts"][0]["text"]
