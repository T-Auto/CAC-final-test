"""测试执行器"""
from __future__ import annotations

import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path
from typing import List, Literal, Optional

from .config import RetryConfig
from .providers import BaseProvider
from .reporting import Event, EventType, Phase, Reporter
from .scope import Question


class RetryExhaustedError(RuntimeError):
    def __init__(self, max_attempts: int, last_error: Exception):
        self.attempts = max_attempts
        super().__init__(f"请求失败 ({max_attempts} 次尝试): {last_error}")


@dataclass(frozen=True)
class TestItemResult:
    index: int
    question_id: str
    question_path: Path
    status: Literal["done", "skipped", "failed"]
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
        reporter: Optional[Reporter] = None,
    ) -> TestRunSummary:
        if concurrency < 1:
            raise ValueError("concurrency 必须 >= 1")

        total = len(questions)
        items_by_index: dict[int, TestItemResult] = {}
        to_run: list[tuple[int, Question, Path]] = []

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
                if reporter is not None:
                    reporter.on_event(
                        Event(
                            phase=Phase.TEST,
                            event_type=EventType.SKIP,
                            index=i,
                            total=total,
                            question_id=question.id,
                            output_file=output_file,
                        )
                    )
                continue

            to_run.append((i, question, output_file))

        def run_one(i: int, question: Question, output_file: Path) -> TestItemResult:
            started = time.monotonic()
            attempts: Optional[int] = None
            try:
                if reporter is not None:
                    reporter.on_event(
                        Event(
                            phase=Phase.TEST,
                            event_type=EventType.START,
                            index=i,
                            total=total,
                            question_id=question.id,
                        )
                    )
                prompt = (question.path / "prompt.md").read_text(encoding="utf-8")
                response, attempts = self._request_with_retry(
                    prompt,
                    index=i,
                    total=total,
                    question_id=question.id,
                    reporter=reporter,
                )
                self._write_result(question.path, response)
                elapsed = time.monotonic() - started
                if reporter is not None:
                    reporter.on_event(
                        Event(
                            phase=Phase.TEST,
                            event_type=EventType.DONE,
                            index=i,
                            total=total,
                            question_id=question.id,
                            elapsed_s=elapsed,
                            attempt=attempts,
                        )
                )
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
                if isinstance(e, RetryExhaustedError) and attempts is None:
                    attempts = e.attempts
                error = f"{type(e).__name__}: {e}"
                if reporter is not None:
                    reporter.on_event(
                        Event(
                            phase=Phase.TEST,
                            event_type=EventType.FAIL,
                            index=i,
                            total=total,
                            question_id=question.id,
                            elapsed_s=elapsed,
                            attempt=attempts,
                            error=error,
                        )
                    )
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
        index: int,
        total: int,
        question_id: str,
        reporter: Optional[Reporter],
    ) -> tuple[str, int]:
        max_attempts = self.retry_config.max_attempts
        delay = self.retry_config.delay
        last_error: Optional[Exception] = None

        for attempt in range(1, max_attempts + 1):
            try:
                return self.provider.chat(prompt), attempt
            except Exception as e:
                last_error = e
                if attempt < max_attempts:
                    if reporter is not None:
                        reporter.on_event(
                            Event(
                                phase=Phase.TEST,
                                event_type=EventType.RETRY,
                                index=index,
                                total=total,
                                question_id=question_id,
                                attempt=attempt,
                                max_attempts=max_attempts,
                                error=f"{type(e).__name__}: {e}",
                            )
                        )
                    time.sleep(delay)

        raise RetryExhaustedError(max_attempts=max_attempts, last_error=last_error or RuntimeError("unknown error"))

    def _write_result(self, question_path: Path, response: str):
        """写入测试结果"""
        output_dir = question_path / "test-results"
        output_dir.mkdir(exist_ok=True)

        output_file = output_dir / f"{self.model_name}.md"
        output_file.write_text(response, encoding="utf-8")
