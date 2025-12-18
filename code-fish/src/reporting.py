from __future__ import annotations

import sys
import threading
import traceback
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import TYPE_CHECKING, Optional, Protocol, TextIO

if TYPE_CHECKING:
    from rich.progress import TaskID


def _write_internal_error(message: str) -> None:
    try:
        sys.stderr.write(f"{message}\n")
        sys.stderr.flush()
    except Exception:
        pass


def _reporter_exception(where: str, exc: BaseException) -> None:
    try:
        detail = "".join(traceback.format_exception(type(exc), exc, exc.__traceback__))
    except Exception:
        detail = f"{exc}"

    _write_internal_error(f"[reporting] {where} crashed")
    _write_internal_error(detail.rstrip("\n"))


class EventType(Enum):
    START = "start"
    SKIP = "skip"
    DONE = "done"
    FAIL = "fail"
    RETRY = "retry"
    NO_ANSWER = "no_answer"


class Phase(Enum):
    TEST = "test"
    JUDGE = "judge"


@dataclass
class Event:
    phase: Phase
    event_type: EventType
    index: int
    total: int
    question_id: str
    elapsed_s: Optional[float] = None
    attempt: Optional[int] = None
    max_attempts: Optional[int] = None
    error: Optional[str] = None
    score: Optional[float] = None
    max_score: Optional[float] = None
    output_file: Optional[Path] = None


class Reporter(Protocol):
    def on_event(self, event: Event) -> None: ...

    def on_phase_start(self, phase: Phase, total: int, model_name: str) -> None: ...

    def on_phase_end(
        self,
        phase: Phase,
        done: int,
        skipped: int,
        failed: int,
        no_answer: int = 0,
        avg_score: Optional[float] = None,
    ) -> None: ...


STYLES = {
    EventType.START: "cyan",
    EventType.SKIP: "dim",
    EventType.DONE: "green",
    EventType.RETRY: "yellow",
    EventType.FAIL: "red",
    EventType.NO_ANSWER: "red",
}


def create_console(file=None, force_terminal: Optional[bool] = None) -> "Console":
    """创建 rich Console，自动检测 TTY"""
    from rich.console import Console

    return Console(file=file, force_terminal=force_terminal, emoji=False)


def is_tty(file=None) -> bool:
    """检测是否为 TTY 环境"""
    f = file or sys.stdout
    return hasattr(f, "isatty") and f.isatty()


class PlainReporter:
    def __init__(self, stream: Optional[TextIO] = None):
        self._stream = stream or sys.stdout
        self._lock = threading.Lock()

    def on_event(self, event: Event) -> None:
        try:
            message = self._format_event(event)
            if message is None:
                return
            self._write_line(message)
        except Exception as exc:
            _reporter_exception("PlainReporter.on_event", exc)

    def on_phase_start(self, phase: Phase, total: int, model_name: str) -> None:
        try:
            if phase == Phase.TEST:
                self._write_line("\n开始测试...")
                return
            self._write_line("\n开始评分...")
        except Exception as exc:
            _reporter_exception("PlainReporter.on_phase_start", exc)

    def on_phase_end(
        self,
        phase: Phase,
        done: int,
        skipped: int,
        failed: int,
        no_answer: int = 0,
        avg_score: Optional[float] = None,
    ) -> None:
        try:
            if phase == Phase.TEST:
                total = done + skipped + failed
                self._write_line(
                    f"\n测试完成: {done} | 跳过: {skipped} | 失败: {failed} | 总计: {total}"
                )
                return

            avg_str = f"{avg_score:.2f}" if avg_score is not None else "N/A"
            self._write_line(
                f"\n评分完成: {done} | 跳过: {skipped} | 失败: {failed} | 无答案: {no_answer} | 平均分: {avg_str}"
            )
        except Exception as exc:
            _reporter_exception("PlainReporter.on_phase_end", exc)

    def _write_line(self, message: str) -> None:
        with self._lock:
            self._stream.write(f"{message}\n")
            try:
                self._stream.flush()
            except Exception:
                pass

    def _format_event(self, event: Event) -> Optional[str]:
        prefix = f"[{event.index}/{event.total}]"

        if event.event_type == EventType.RETRY:
            attempt = event.attempt or 0
            max_attempts = event.max_attempts or 0
            error = event.error or ""
            return f"{prefix} {event.question_id} RETRY {attempt}/{max_attempts}: {error}"

        if event.event_type == EventType.START:
            action = "TEST" if event.phase == Phase.TEST else "JUDGE"
            return f"{prefix} {action} {event.question_id}"

        if event.event_type == EventType.SKIP:
            reason = "已有结果" if event.phase == Phase.TEST else "已有评分"
            return f"{prefix} SKIP {event.question_id} ({reason})"

        if event.event_type == EventType.NO_ANSWER:
            error = event.error or ""
            return f"{prefix} NO_ANSWER {event.question_id} ({error})"

        if event.event_type == EventType.DONE:
            elapsed = None
            if event.elapsed_s is not None:
                elapsed = f"{event.elapsed_s:.2f}s"

            if event.phase == Phase.JUDGE and event.score is not None and event.max_score is not None:
                score_part = f"{event.score}/{event.max_score}"
                if elapsed is not None:
                    return f"{prefix} DONE {event.question_id} ({score_part}, {elapsed})"
                return f"{prefix} DONE {event.question_id} ({score_part})"

            if elapsed is not None:
                return f"{prefix} DONE {event.question_id} ({elapsed})"
            return f"{prefix} DONE {event.question_id}"

        if event.event_type == EventType.FAIL:
            error = event.error or ""
            return f"{prefix} FAIL {event.question_id}: {error}"

        return None


class RichReporter:
    """Rich 美化输出 Reporter"""

    def __init__(self, stream: Optional[TextIO] = None):
        from rich.console import Console

        self._stream = stream or sys.stderr
        self._console = Console(file=self._stream, emoji=False)
        self._lock = threading.Lock()
        self._progress: Optional[Progress] = None
        self._task_id: Optional[TaskID] = None
        self._phase: Optional[Phase] = None
        self._total = 0
        self._completed = 0

    def on_event(self, event: Event) -> None:
        try:
            style = STYLES.get(event.event_type, "")
            message = self._format_event(event)
            if message is None:
                return

            with self._lock:
                if event.event_type in (
                    EventType.DONE,
                    EventType.SKIP,
                    EventType.FAIL,
                    EventType.NO_ANSWER,
                ):
                    self._completed += 1
                    if self._progress and self._task_id is not None:
                        self._progress.update(self._task_id, completed=self._completed)

                self._console.print(message, style=style)
        except Exception as exc:
            _reporter_exception("RichReporter.on_event", exc)

    def on_phase_start(self, phase: Phase, total: int, model_name: str) -> None:
        try:
            from rich.progress import (
                BarColumn,
                Progress,
                SpinnerColumn,
                TaskProgressColumn,
                TextColumn,
                TimeElapsedColumn,
            )
            from rich.panel import Panel

            self._phase = phase
            self._total = total
            self._completed = 0

            phase_name = "测试" if phase == Phase.TEST else "评分"
            title = f"{phase_name} - {model_name}"

            self._console.print()
            self._console.print(
                Panel(f"[bold cyan]{title}[/] | 共 {total} 题", expand=False)
            )

            self._progress = Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                BarColumn(),
                TaskProgressColumn(),
                TimeElapsedColumn(),
                console=self._console,
                transient=False,
            )
            self._progress.start()
            self._task_id = self._progress.add_task(f"[cyan]{phase_name}中...", total=total)
        except Exception as exc:
            _reporter_exception("RichReporter.on_phase_start", exc)

    def on_phase_end(
        self,
        phase: Phase,
        done: int,
        skipped: int,
        failed: int,
        no_answer: int = 0,
        avg_score: Optional[float] = None,
    ) -> None:
        try:
            from rich.table import Table

            if self._progress:
                self._progress.stop()
                self._progress = None

            table = Table(show_header=False, box=None)
            table.add_column("指标", style="bold")
            table.add_column("值", justify="right")

            table.add_row("完成", f"[green]{done}[/]")
            table.add_row("跳过", f"[dim]{skipped}[/]")
            table.add_row("失败", f"[red]{failed}[/]" if failed > 0 else "0")

            if phase == Phase.JUDGE:
                table.add_row("无答案", f"[red]{no_answer}[/]" if no_answer > 0 else "0")
                avg_str = f"{avg_score:.2f}" if avg_score is not None else "N/A"
                table.add_row("平均分", f"[bold]{avg_str}[/]")

            total = done + skipped + failed + no_answer
            table.add_row("总计", f"[bold]{total}[/]")

            self._console.print()
            self._console.print(table)
        except Exception as exc:
            _reporter_exception("RichReporter.on_phase_end", exc)

    def _format_event(self, event: Event) -> Optional[str]:
        prefix = f"[{event.index}/{event.total}]"
        tag = event.event_type.value.upper()

        if event.event_type == EventType.RETRY:
            attempt = event.attempt or 0
            max_attempts = event.max_attempts or 0
            return f"{prefix} {tag} {event.question_id} ({attempt}/{max_attempts})"

        if event.event_type == EventType.START:
            action = "TEST" if event.phase == Phase.TEST else "JUDGE"
            return f"{prefix} {action} {event.question_id}"

        if event.event_type == EventType.SKIP:
            return f"{prefix} {tag} {event.question_id}"

        if event.event_type == EventType.NO_ANSWER:
            error = (event.error or "").strip()
            if error:
                return f"{prefix} {tag} {event.question_id}: {error}"
            return f"{prefix} {tag} {event.question_id}"

        if event.event_type == EventType.DONE:
            parts = [prefix, tag, event.question_id]
            if (
                event.phase == Phase.JUDGE
                and event.score is not None
                and event.max_score is not None
            ):
                parts.append(f"({event.score}/{event.max_score})")
            if event.elapsed_s is not None:
                parts.append(f"{event.elapsed_s:.1f}s")
            return " ".join(parts)

        if event.event_type == EventType.FAIL:
            error = (event.error or "").strip()
            if error:
                return f"{prefix} {tag} {event.question_id}: {error}"
            return f"{prefix} {tag} {event.question_id}"

        return None


def create_reporter(stream: Optional[TextIO] = None, use_rich: bool = True) -> Reporter:
    """创建 Reporter，TTY 环境使用 RichReporter，否则使用 PlainReporter"""
    actual_stream = stream if stream is not None else sys.stderr
    if use_rich and is_tty(actual_stream):
        return RichReporter(actual_stream)
    return PlainReporter(actual_stream)
