"""交互式菜单模块 - 生成运行参数"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Optional, Tuple

from rich.console import Console
from rich.panel import Panel
from rich.prompt import Confirm, IntPrompt, Prompt
from rich.table import Table


@dataclass
class InteractiveArgs:
    mode: str  # test/judge/all
    scope: str  # math/base-test
    range: Optional[str]
    target: Optional[str]
    concurrency: int
    force: bool
    dry_run: bool

    def to_argv(self) -> list[str]:
        argv = ["--mode", self.mode, "--scope", self.scope, "--concurrency", str(self.concurrency)]
        if self.range:
            argv.extend(["--range", self.range])
        if self.target:
            argv.extend(["--target", self.target])
        if self.force:
            argv.append("--force")
        if self.dry_run:
            argv.append("--dry-run")
        return argv


class InteractiveMenu:
    MODES = [("test", "仅测试"), ("judge", "仅评分"), ("all", "测试+评分")]
    CATEGORIES = [
        ("math", "数理能力"),
        ("code", "代码能力"),
        ("logic", "自然语言与逻辑"),
        ("comp", "综合能力"),
        ("hallucination", "幻觉控制"),
    ]
    DIFFICULTIES = [
        ("base-test", "基础"),
        ("advanced-test", "进阶"),
        ("final-test", "终极"),
        ("final-test+", "终极+"),
    ]

    def __init__(self, console: Optional[Console] = None):
        self.console = console or Console(emoji=False)

    def run(self) -> Optional[InteractiveArgs]:
        try:
            while True:
                mode = self._select_mode()
                if mode is None:
                    return None

                while True:
                    category = self._select_category()
                    if category is None:
                        break

                    while True:
                        difficulty = self._select_difficulty()
                        if difficulty is None:
                            break

                        scope = category if difficulty == "all" else f"{category}/{difficulty}"
                        range_str = self._input_range()
                        concurrency, force, target = self._input_advanced(mode)

                        args = InteractiveArgs(
                            mode=mode,
                            scope=scope,
                            range=range_str,
                            target=target,
                            concurrency=concurrency,
                            force=force,
                            dry_run=False,
                        )

                        action = self._confirm(args)
                        if action is None:
                            continue

                        args.dry_run = action == "dry-run"
                        return args
        except (KeyboardInterrupt, EOFError):
            return None

    def _select_mode(self) -> Optional[str]:
        idx = self._show_menu("选择运行模式", self.MODES, allow_back=False)
        if idx is None:
            return None
        return self.MODES[idx][0]

    def _select_category(self) -> Optional[str]:
        idx = self._show_menu("选择题库类别", self.CATEGORIES, allow_back=True)
        if idx is None:
            return None
        return self.CATEGORIES[idx][0]

    def _select_difficulty(self) -> Optional[str]:
        options = [("all", "全部"), *self.DIFFICULTIES]
        idx = self._show_menu("选择难度", options, allow_back=True)
        if idx is None:
            return None
        return options[idx][0]

    def _input_range(self) -> Optional[str]:
        while True:
            value = Prompt.ask("题号范围(如 001-005 或 003，回车跳过)", default="", show_default=False).strip()
            if not value:
                return None
            if self._is_valid_range(value):
                return value
            self.console.print("[red]格式不合法：请输入 001-005 或 003[/]")

    def _input_advanced(self, mode: str) -> Tuple[int, bool, Optional[str]]:
        while True:
            concurrency = IntPrompt.ask("并发数", default=1)
            if concurrency >= 1:
                break
            self.console.print("[red]并发数必须 >= 1[/]")

        force = Confirm.ask("是否强制重测(忽略已有结果)？", default=False)

        target: Optional[str] = None
        if mode in ("judge", "all"):
            value = Prompt.ask("target 模型名(回车默认：使用 test-model)", default="", show_default=False).strip()
            if value:
                target = value

        return concurrency, force, target

    def _confirm(self, args: InteractiveArgs) -> Optional[str]:
        summary = Table(show_header=False, box=None, padding=(0, 1))
        summary.add_column("k", style="cyan", no_wrap=True)
        summary.add_column("v", style="green")
        summary.add_row("mode", args.mode)
        summary.add_row("scope", args.scope)
        summary.add_row("range", args.range or "-")
        summary.add_row("concurrency", str(args.concurrency))
        summary.add_row("force", "是" if args.force else "否")
        if args.mode in ("judge", "all"):
            summary.add_row("target", args.target or "(默认: test-model)")

        self.console.print()
        self.console.print(Panel.fit(summary, title="确认参数", border_style="cyan"))

        if Confirm.ask("确认开始运行？", default=True):
            return "run"
        if Confirm.ask("改为 dry-run 仅预览？", default=False):
            return "dry-run"
        return None

    def _show_menu(self, title: str, options: list[tuple[str, str]], allow_back: bool) -> Optional[int]:
        self.console.print()
        self.console.print(Panel.fit(f"[bold cyan]{title}[/]", border_style="cyan"))

        table = Table(show_header=True, header_style="bold cyan")
        table.add_column("编号", justify="right", style="yellow", no_wrap=True)
        table.add_column("选项", style="green")
        table.add_column("说明", style="dim")

        if allow_back:
            table.add_row("0", "返回上一步", "回到上一层菜单")
        else:
            table.add_row("0", "退出", "结束交互")

        for idx, (value, desc) in enumerate(options, start=1):
            table.add_row(str(idx), value, desc)
        self.console.print(table)

        max_choice = len(options)
        while True:
            choice = IntPrompt.ask("请输入编号", default=0)
            if choice == 0:
                return None
            if 1 <= choice <= max_choice:
                return choice - 1
            self.console.print(f"[red]无效选择: {choice}（有效范围: 0-{max_choice}）[/]")

    @staticmethod
    def _is_valid_range(value: str) -> bool:
        if re.fullmatch(r"\d+", value):
            return True
        match = re.fullmatch(r"(\d+)-(\d+)", value)
        if not match:
            return False
        start = int(match.group(1))
        end = int(match.group(2))
        return start <= end
