#!/usr/bin/env python3
"""CAC Benchmark Test Runner - LLM/Agent 能力评测工具"""
import json
import argparse
import sys
from pathlib import Path
from types import SimpleNamespace
from typing import Optional

# 添加 src 到路径
sys.path.insert(0, str(Path(__file__).parent))

from src.config import load_config
from src.scope import ScopeResolver
from src.runner import TestRunner
from src.judge import JudgeRunner
from src.providers import create_provider
from src.reporting import Phase, create_reporter, is_tty


def print_rich_help():
    """使用 rich 打印美化的帮助信息"""
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.text import Text

    console = Console(emoji=False)

    # 标题
    console.print()
    console.print(Panel.fit(
        "[bold cyan]CAC Benchmark Test Runner[/]\n[dim]LLM/Agent 能力评测工具[/]",
        border_style="cyan"
    ))

    # 用法
    console.print("\n[bold]用法:[/]")
    console.print("  python cli.py [OPTIONS] --scope <SCOPE>", style="green")

    # 必选参数
    console.print("\n[bold]必选参数:[/]")
    args_table = Table(show_header=False, box=None, padding=(0, 2))
    args_table.add_column("参数", style="cyan")
    args_table.add_column("说明")
    args_table.add_row("-s, --scope", "测试范围: math, code, logic, comp, hallucination 或 math/base-test")
    console.print(args_table)

    # 可选参数
    console.print("\n[bold]可选参数:[/]")
    opts_table = Table(show_header=False, box=None, padding=(0, 2))
    opts_table.add_column("参数", style="cyan")
    opts_table.add_column("说明")
    opts_table.add_row("-m, --mode", "运行模式: test(默认), judge, all")
    opts_table.add_row("-c, --config", "配置文件路径 (默认: config.yaml)")
    opts_table.add_row("-r, --range", "题号范围: 001-005 或 003")
    opts_table.add_row("-t, --target", "judge 模式: 被评分的模型名")
    opts_table.add_row("-j, --concurrency", "并发数 (默认: 1)")
    opts_table.add_row("-f, --force", "强制重新测试 (忽略已有结果)")
    opts_table.add_row("--dry-run", "仅显示将要测试的题目")
    opts_table.add_row("--json", "输出 JSON 汇总到 stdout")
    opts_table.add_row("-h, --help", "显示帮助信息")
    console.print(opts_table)

    # Provider 说明
    console.print("\n[bold]Providers:[/]")
    prov_table = Table(show_header=False, box=None, padding=(0, 2))
    prov_table.add_column("类型", style="yellow")
    prov_table.add_column("说明")
    prov_table.add_row("openai", "OpenAI/DeepSeek/Qwen (自动补 /chat/completions)")
    prov_table.add_row("anthropic", "Claude (/v1/messages)")
    prov_table.add_row("gemini", "Google Gemini (/v1beta/...:generateContent)")
    prov_table.add_row("custom", "完整 URL (如 Ollama Cloud)")
    console.print(prov_table)

    # 示例
    console.print("\n[bold]示例:[/]")
    examples = [
        ("python cli.py --scope math", "测试所有数学题"),
        ("python cli.py --scope math/base-test --range 001-005", "测试指定范围"),
        ("python cli.py --mode all --scope logic -j 4", "测试+评分，4并发"),
        ("python cli.py --scope math --dry-run", "预览将测试的题目"),
    ]
    for cmd, desc in examples:
        console.print(f"  [green]{cmd}[/]")
        console.print(f"    [dim]{desc}[/]")

    console.print()


def make_json_base(args, config) -> dict:
    judge_model = None
    if getattr(config, "judge_model", None) is not None:
        judge_model = {
            "name": config.judge_model.name,
            "provider": config.judge_model.provider,
        }

    return {
        "ok": True,
        "mode": args.mode,
        "scope": args.scope,
        "range": args.range,
        "concurrency": args.concurrency,
        "incremental": not args.force,
        "test_model": {
            "name": config.test_model.name,
            "provider": config.test_model.provider,
        },
        "judge_model": judge_model,
        "error": None,
        "dry_run": bool(getattr(args, "dry_run", False)),
        "total": 0,
        "items": [],
        "test": None,
        "judge": None,
    }


def _make_stub_config():
    return SimpleNamespace(
        test_model=SimpleNamespace(
            name=None,
            provider=None,
        ),
        judge_model=None,
    )


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv[1:]

    # 无参数时进入交互模式
    if not argv:
        if is_tty():
            from src.interactive import InteractiveMenu

            menu = InteractiveMenu()
            result = menu.run()
            if result is None:
                return 0  # 用户退出
            argv = result.to_argv()
        else:
            print_rich_help()
            return 0

    # 保留原有的 -h/--help 处理
    if "-h" in argv or "--help" in argv:
        if is_tty():
            print_rich_help()
        else:
            # 非 TTY 环境使用简单帮助
            print(__doc__)
        return 0

    parser = argparse.ArgumentParser(
        description="CAC Benchmark Test Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        add_help=False,
    )

    parser.add_argument(
        "--mode",
        "-m",
        choices=["test", "judge", "all"],
        default="test",
        help="运行模式: test(默认), judge, all",
    )

    parser.add_argument(
        "--scope",
        "-s",
        required=True,
        help="测试范围: math, code, logic, comp, hallucination 或 math/base-test",
    )

    parser.add_argument(
        "--target",
        "-t",
        help="judge 模式: 被评分的模型名 (默认=test-model.name)",
    )

    parser.add_argument(
        "--concurrency",
        "-j",
        type=int,
        default=1,
        help="并发数 (default: 1)",
    )

    parser.add_argument(
        "--json",
        action="store_true",
        help="输出 JSON 汇总到 stdout（日志输出到 stderr）",
    )

    parser.add_argument(
        "--config",
        "-c",
        default="config.yaml",
        help="配置文件路径 (default: config.yaml)",
    )

    parser.add_argument(
        "--range",
        "-r",
        help="题号范围: 001-005 或 003",
    )

    parser.add_argument(
        "--force",
        "-f",
        action="store_true",
        help="强制重新测试 (忽略已有结果)",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="仅显示将要测试的题目，不执行",
    )

    if not argv:
        parser.print_help(sys.stdout)
        return 0

    args = parser.parse_args(argv)

    if args.concurrency < 1:
        error = "--concurrency/-j 必须 >= 1"
        if args.json:
            result = make_json_base(args, _make_stub_config())
            result["ok"] = False
            result["error"] = error
            print(json.dumps(result, ensure_ascii=False))
            return 1
        print(f"错误: {error}", file=sys.stderr)
        return 1

    log_stream = sys.stderr if args.json else sys.stdout
    use_rich = not args.json  # JSON 模式禁用 rich
    reporter = create_reporter(stream=log_stream, use_rich=use_rich)

    def log(message: str = ""):
        print(message, file=log_stream)

    def emit_json(payload: dict) -> None:
        print(json.dumps(payload, ensure_ascii=False))

    def json_error(error: str, cfg=None) -> int:
        cfg = cfg or _make_stub_config()
        result = make_json_base(args, cfg)
        result["ok"] = False
        result["error"] = error
        emit_json(result)
        return 1

    # 1. 加载配置
    try:
        config = load_config(args.config)
    except FileNotFoundError:
        error = f"配置文件不存在: {args.config}"
        if args.json:
            return json_error(error)
        log(f"错误: {error}")
        return 1
    except ValueError as e:
        error = f"配置无效: {e}"
        if args.json:
            return json_error(error)
        log(f"错误: {error}")
        return 1

    log(f"test-model: {config.test_model.name} ({config.test_model.provider})")
    if config.judge_model is not None:
        log(f"judge-model: {config.judge_model.name} ({config.judge_model.provider})")

    # 2. 解析 scope
    resolver = ScopeResolver(config.question_banks)
    try:
        questions = resolver.resolve(args.scope, args.range)
    except ValueError as e:
        if args.json:
            return json_error(str(e), cfg=config)
        log(f"错误: {e}")
        return 1

    if not questions:
        if args.json:
            result = make_json_base(args, config)
            result["total"] = 0
            result["items"] = []
            emit_json(result)
            return 0
        log("未找到匹配的题目")
        return 0

    log(f"找到 {len(questions)} 道题目")

    # 3. dry-run 模式
    if args.dry_run:
        if args.json:
            repo_root = resolver.base_dir.parent

            def rel(path: Path) -> str:
                try:
                    return str(path.relative_to(repo_root))
                except ValueError:
                    return str(path)

            result = make_json_base(args, config)
            result["dry_run"] = True
            result["total"] = len(questions)
            result["items"] = [{"id": q.id, "path": rel(q.path)} for q in questions]
            emit_json(result)
            return 0

        log("\n将测试以下题目:")
        for q in questions:
            log(f"  - {q.path.relative_to(resolver.base_dir.parent)}")
        return 0

    repo_root = resolver.base_dir.parent

    def rel(path: Optional[Path]) -> Optional[str]:
        if path is None:
            return None
        try:
            return str(path.relative_to(repo_root))
        except ValueError:
            return str(path)

    # 4. 模式分发
    if args.mode in ("judge", "all") and config.judge_model is None:
        error = "judge/all 模式需要配置 judge-model"
        if args.json:
            return json_error(error, cfg=config)
        log(f"错误: {error}")
        return 1

    target_model = args.target or config.test_model.name
    test_summary = None
    judge_summary = None

    def safe_reporter_call(method: str, *call_args) -> None:
        fn = getattr(reporter, method, None)
        if fn is None:
            return
        try:
            fn(*call_args)
        except Exception as exc:
            log(f"reporter.{method} 异常: {exc}")

    # 5. 执行 test 模式
    if args.mode in ("test", "all"):
        provider = create_provider(config.test_model)
        runner = TestRunner(
            provider=provider,
            retry_config=config.retry,
            incremental=not args.force,
        )
        safe_reporter_call("on_phase_start", Phase.TEST, len(questions), config.test_model.name)
        test_summary = runner.run(questions, concurrency=args.concurrency, reporter=reporter)
        safe_reporter_call("on_phase_end", Phase.TEST, test_summary.done, test_summary.skipped, test_summary.failed)

    # 6. 执行 judge 模式
    if args.mode in ("judge", "all"):
        judge_provider = create_provider(config.judge_model)
        judge_runner = JudgeRunner(
            provider=judge_provider,
            retry_config=config.retry,
            incremental=not args.force,
        )
        safe_reporter_call("on_phase_start", Phase.JUDGE, len(questions), target_model)
        judge_summary = judge_runner.judge(questions, target_model=target_model, concurrency=args.concurrency, reporter=reporter)
        safe_reporter_call(
            "on_phase_end",
            Phase.JUDGE,
            judge_summary.done,
            judge_summary.skipped,
            judge_summary.failed,
            judge_summary.no_answer,
            judge_summary.avg_score,
        )

    # 7. JSON 输出
    if args.json:
        result = make_json_base(args, config)
        result["total"] = len(questions)

        if test_summary:
            result["ok"] = result["ok"] and test_summary.failed == 0
            result["test"] = {
                "model": config.test_model.name,
                "total": test_summary.total,
                "done": test_summary.done,
                "skipped": test_summary.skipped,
                "failed": test_summary.failed,
                "items": [
                    {
                        "index": item.index,
                        "id": item.question_id,
                        "path": rel(item.question_path),
                        "status": item.status,
                        "output_file": rel(item.output_file),
                        "elapsed_s": item.elapsed_s,
                        "attempts": item.attempts,
                        "error": item.error,
                    }
                    for item in test_summary.items
                ],
            }

        if judge_summary:
            result["ok"] = result["ok"] and judge_summary.failed == 0 and judge_summary.no_answer == 0
            result["judge"] = {
                "judge_model": judge_summary.judge_name,
                "target_model": judge_summary.target_model,
                "total": judge_summary.total,
                "done": judge_summary.done,
                "skipped": judge_summary.skipped,
                "failed": judge_summary.failed,
                "no_answer": judge_summary.no_answer,
                "avg_score": judge_summary.avg_score,
                "items": [
                    {
                        "index": item.index,
                        "id": item.question_id,
                        "path": rel(item.question_path),
                        "status": item.status,
                        "score": item.total_score,
                        "max_score": item.max_score,
                        "output_file": rel(item.output_file),
                        "elapsed_s": item.elapsed_s,
                        "attempts": item.attempts,
                        "error": item.error,
                    }
                    for item in judge_summary.items
                ],
            }

        emit_json(result)

    # 8. 返回码
    failed = 0
    if test_summary:
        failed += test_summary.failed
    if judge_summary:
        failed += judge_summary.failed + judge_summary.no_answer
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
