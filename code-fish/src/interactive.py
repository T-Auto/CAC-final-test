"""交互式菜单模块 - 生成运行参数"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Optional, Tuple

from rich import box
from rich.align import Align
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Confirm, IntPrompt, Prompt
from rich.table import Table
from rich.text import Text


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
        self._print_banner()

    def _print_banner(self):
        banner_text = Text("CAC BENCHMARK", style="bold cyan")
        subtitle = Text("LLM Capability Assessment CLI", style="dim white")
        
        self.console.print()
        self.console.print(Panel(
            Align.center(Text.assemble(banner_text, "\n", subtitle)),
            box=box.ROUNDED,
            border_style="blue",
            padding=(0, 2)
        ))

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
        idx = self._show_menu("Select Mode", self.MODES, allow_back=False)
        if idx is None:
            return None
        return self.MODES[idx][0]

    def _select_category(self) -> Optional[str]:
        idx = self._show_menu("Select Category", self.CATEGORIES, allow_back=True)
        if idx is None:
            return None
        return self.CATEGORIES[idx][0]

    def _select_difficulty(self) -> Optional[str]:
        options = [("all", "全部"), *self.DIFFICULTIES]
        idx = self._show_menu("Select Difficulty", options, allow_back=True)
        if idx is None:
            return None
        return options[idx][0]

    def _input_range(self) -> Optional[str]:
        self.console.print()
        while True:
            value = Prompt.ask("  [cyan]Range[/] [dim](e.g. 001-005, 003, Enter to skip)[/]", default="", show_default=False).strip()
            if not value:
                return None
            if self._is_valid_range(value):
                return value
            self.console.print("  [red]Format error: use 001-005 or 003[/]")

    def _input_advanced(self, mode: str) -> Tuple[int, bool, Optional[str]]:
        self.console.print()
        while True:
            concurrency = IntPrompt.ask("  [cyan]Concurrency[/]", default=1)
            if concurrency >= 1:
                break
            self.console.print("  [red]Concurrency must be >= 1[/]")

        force = Confirm.ask("  [cyan]Force Retry[/] [dim](Ignore existing results)[/]", default=False)

        target: Optional[str] = None
        if mode in ("judge", "all"):
            value = Prompt.ask("  [cyan]Target Model[/] [dim](Enter to use test-model)[/]", default="", show_default=False).strip()
            if value:
                target = value

        return concurrency, force, target

    def _confirm(self, args: InteractiveArgs) -> Optional[str]:
        summary = Table(show_header=False, box=None, padding=(0, 2))
        summary.add_column("k", style="cyan bold", justify="right")
        summary.add_column("v", style="white")
        summary.add_row("Mode", args.mode)
        summary.add_row("Scope", args.scope)
        summary.add_row("Range", args.range or "-")
        summary.add_row("Concurrency", str(args.concurrency))
        summary.add_row("Force", "Yes" if args.force else "No")
        if args.mode in ("judge", "all"):
            summary.add_row("Target", args.target or "(Default: test-model)")

        self.console.print()
        self.console.print(Panel(
            Align.center(summary),
            title="[bold]Configuration Review[/]",
            border_style="green",
            box=box.ROUNDED,
            expand=False,
            padding=(0, 2)
        ))

        self.console.print()
        if Confirm.ask("  [bold green]Ready to start?[/]", default=True):
            return "run"
        if Confirm.ask("  [yellow]Dry-run only?[/]", default=False):
            return "dry-run"
        return None

    def _show_menu(self, title: str, options: list[tuple[str, str]], allow_back: bool) -> Optional[int]:
        table = Table(show_header=True, header_style="bold cyan", box=box.SIMPLE, expand=True, show_edge=False, pad_edge=False)
        table.add_column("#", justify="right", style="yellow", no_wrap=True, width=4)
        table.add_column("Option", style="bold white")
        table.add_column("Description", style="dim")

        if allow_back:
            table.add_row("0", "Back", "Return to previous menu")
        else:
            table.add_row("0", "Exit", "Exit application")

        for idx, (value, desc) in enumerate(options, start=1):
            table.add_row(str(idx), value, desc)

        self.console.print()
        self.console.print(Panel(
            table,
            title=f"[bold cyan]{title}[/]",
            border_style="blue",
            box=box.ROUNDED,
            expand=False,
            padding=(0, 1)
        ))

        max_choice = len(options)
        while True:
            choice = IntPrompt.ask("  [cyan]Select[/]", default=0)
            if choice == 0:
                return None
            if 1 <= choice <= max_choice:
                return choice - 1
            self.console.print(f"  [red]Invalid choice: {choice} (Valid: 0-{max_choice})[/]")

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
