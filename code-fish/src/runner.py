"""测试执行器"""
import time
from pathlib import Path
from typing import List

from .config import RetryConfig
from .providers import BaseProvider
from .scope import Question


class TestRunner:
    """执行测试并保存结果"""

    def __init__(
        self,
        provider: BaseProvider,
        retry_config: RetryConfig,
        incremental: bool = True,
    ):
        self.provider = provider
        self.retry_config = retry_config
        self.incremental = incremental
        self.model_name = provider.get_model_name()

    def run(self, questions: List[Question]) -> dict:
        """
        执行测试

        Args:
            questions: 题目列表

        Returns:
            {question_id: response} 字典
        """
        results = {}
        total = len(questions)
        skipped = 0
        failed = 0

        for i, question in enumerate(questions, 1):
            output_file = question.path / "test-results" / f"{self.model_name}.md"

            # 增量检测
            if self.incremental and output_file.exists():
                print(f"[{i}/{total}] SKIP {question.id} (已有结果)")
                skipped += 1
                continue

            # 加载 prompt
            prompt_file = question.path / "prompt.md"
            prompt = prompt_file.read_text(encoding="utf-8")

            # 执行请求
            print(f"[{i}/{total}] TEST {question.id}")
            try:
                response = self._request_with_retry(prompt, question.id)
                results[question.id] = response

                # 立即写入结果
                self._write_result(question.path, response)
                print(f"[{i}/{total}] DONE {question.id}")
            except Exception as e:
                print(f"[{i}/{total}] FAIL {question.id}: {e}")
                failed += 1

        # 统计
        tested = total - skipped - failed
        print(f"\n完成: {tested} | 跳过: {skipped} | 失败: {failed} | 总计: {total}")

        return results

    def _request_with_retry(self, prompt: str, question_id: str) -> str:
        """带重试的请求"""
        max_attempts = self.retry_config.max_attempts
        delay = self.retry_config.delay
        last_error = None

        for attempt in range(1, max_attempts + 1):
            try:
                return self.provider.chat(prompt)
            except Exception as e:
                last_error = e
                if attempt < max_attempts:
                    print(f"  重试 {attempt}/{max_attempts}: {e}")
                    time.sleep(delay)

        raise RuntimeError(f"请求失败 ({max_attempts} 次尝试): {last_error}")

    def _write_result(self, question_path: Path, response: str):
        """写入测试结果"""
        output_dir = question_path / "test-results"
        output_dir.mkdir(exist_ok=True)

        output_file = output_dir / f"{self.model_name}.md"
        output_file.write_text(response, encoding="utf-8")
