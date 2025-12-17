"""测试执行器"""
from __future__ import annotations

import threading
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, List, Optional

from .config import RetryConfig
from .providers import BaseProvider
from .scope import Question


@dataclass(frozen=True)
class TestItemResult:
    index: int
    question_id: str
    question_path: Path
    status: str
    output_file: Optional[Path] = None
    elapsed_s: Optional[float] = None
    attempts: Optional[int] = None
    error: Optional[str] = None


@dataclass(frozen=True)
class TestRunSummary:
    model_name: str
    total: int
    done: int
    skipped: int
    failed: int
    items: List[TestItemResult]


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

    def run(
        self,
        questions: List[Question],
        concurrency: int = 1,
        log_fn: Optional[Callable[[str], None]] = None,
    ) -> TestRunSummary:
        if concurrency < 1:
            raise ValueError("concurrency 必须 >= 1")

        total = len(questions)
        items_by_index: dict[int, TestItemResult] = {}
        to_run: list[tuple[int, Question, Path]] = []

        log_lock = threading.Lock()

        def log(message: str):
            if log_fn is None:
                return
            with log_lock:
                log_fn(message)

        for i, question in enumerate(questions, 1):
            output_file = question.path / "test-results" / f"{self.model_name}.md"

            if self.incremental and output_file.exists():
                items_by_index[i] = TestItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    status="skipped",
                    output_file=output_file,
                )
                log(f"[{i}/{total}] SKIP {question.id} (已有结果)")
                continue

            to_run.append((i, question, output_file))

        def run_one(i: int, question: Question, output_file: Path) -> TestItemResult:
            started = time.monotonic()
            log(f"[{i}/{total}] TEST {question.id}")

            attempts: Optional[int] = None
            try:
                prompt = (question.path / "prompt.md").read_text(encoding="utf-8")
                response, attempts = self._request_with_retry(
                    prompt,
                    context=f"[{i}/{total}] {question.id}",
                    log=log,
                )
                self._write_result(question.path, response)
                elapsed = time.monotonic() - started
                log(f"[{i}/{total}] DONE {question.id} ({elapsed:.2f}s)")
                return TestItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    status="done",
                    output_file=output_file,
                    elapsed_s=elapsed,
                    attempts=attempts,
                )
            except Exception as e:
                elapsed = time.monotonic() - started
                error = f"{type(e).__name__}: {e}"
                log(f"[{i}/{total}] FAIL {question.id}: {error}")
                return TestItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    status="failed",
                    output_file=output_file,
                    elapsed_s=elapsed,
                    attempts=attempts,
                    error=error,
                )

        if concurrency == 1:
            for i, question, output_file in to_run:
                items_by_index[i] = run_one(i, question, output_file)
        else:
            with ThreadPoolExecutor(max_workers=concurrency) as executor:
                futures = [
                    executor.submit(run_one, i, question, output_file)
                    for i, question, output_file in to_run
                ]
                for future in as_completed(futures):
                    result = future.result()
                    items_by_index[result.index] = result

        items = [items_by_index[i] for i in sorted(items_by_index)]
        done = sum(1 for item in items if item.status == "done")
        skipped = sum(1 for item in items if item.status == "skipped")
        failed = sum(1 for item in items if item.status == "failed")

        return TestRunSummary(
            model_name=self.model_name,
            total=total,
            done=done,
            skipped=skipped,
            failed=failed,
            items=items,
        )

    def _request_with_retry(
        self,
        prompt: str,
        context: str,
        log: Callable[[str], None],
    ) -> tuple[str, int]:
        max_attempts = self.retry_config.max_attempts
        delay = self.retry_config.delay
        last_error = None

        for attempt in range(1, max_attempts + 1):
            try:
                return self.provider.chat(prompt), attempt
            except Exception as e:
                last_error = e
                if attempt < max_attempts:
                    log(f"{context} RETRY {attempt}/{max_attempts}: {type(e).__name__}: {e}")
                    time.sleep(delay)

        raise RuntimeError(f"请求失败 ({max_attempts} 次尝试): {last_error}")

    def _write_result(self, question_path: Path, response: str):
        """写入测试结果"""
        output_dir = question_path / "test-results"
        output_dir.mkdir(exist_ok=True)

        output_file = output_dir / f"{self.model_name}.md"
        output_file.write_text(response, encoding="utf-8")
