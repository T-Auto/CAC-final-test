#!/usr/bin/env python3
"""
Examples:
    python cli.py --scope math
    python cli.py --scope math/base-test --range 001-005
    python cli.py --scope hallucination
    python cli.py --config config.yaml --scope code
    python cli.py --scope logic -j 8
    python cli.py --scope logic -j 8 --json > report.json
    python cli.py --scope math --force
    python cli.py --scope math/advanced --dry-run

Providers:
    openai      OpenAI/DeepSeek/Qwen 等（自动补 `/chat/completions`）
    anthropic   Claude（`/v1/messages`）
    gemini      Google Gemini（`/v1beta/...:generateContent`）
    custom      完整 URL（如 Ollama Cloud）
"""
import json
import argparse
import sys
from pathlib import Path

# 添加 src 到路径
sys.path.insert(0, str(Path(__file__).parent))

from src.config import load_config
from src.scope import ScopeResolver
from src.runner import TestRunner
from src.providers import create_provider


def main(argv=None) -> int:
    if argv is None:
        argv = sys.argv[1:]

    parser = argparse.ArgumentParser(
        description="CAC Benchmark Test Runner",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
        add_help=False,
    )

    parser.add_argument(
        "-h",
        "--help",
        action="help",
        default=argparse.SUPPRESS,
        help="显示帮助信息并退出",
    )

    parser.add_argument(
        "--scope",
        "-s",
        required=True,
        help="测试范围: math, code, logic, comp, hallucination 或 math/base-test",
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
        print("错误: --concurrency/-j 必须 >= 1", file=sys.stderr)
        return 1

    log_stream = sys.stderr if args.json else sys.stdout

    def log(message: str = ""):
        print(message, file=log_stream)

    # 1. 加载配置
    try:
        config = load_config(args.config)
    except FileNotFoundError:
        error = f"配置文件不存在: {args.config}"
        if args.json:
            print(json.dumps({"ok": False, "error": error}, ensure_ascii=False))
            return 1
        log(f"错误: {error}")
        return 1
    except ValueError as e:
        error = f"配置无效: {e}"
        if args.json:
            print(json.dumps({"ok": False, "error": error}, ensure_ascii=False))
            return 1
        log(f"错误: {error}")
        return 1

    log(f"模型: {config.model.name} ({config.model.provider})")

    # 2. 解析 scope
    resolver = ScopeResolver(config.question_banks)
    try:
        questions = resolver.resolve(args.scope, args.range)
    except ValueError as e:
        if args.json:
            print(json.dumps({"ok": False, "error": str(e)}, ensure_ascii=False))
            return 1
        log(f"错误: {e}")
        return 1

    if not questions:
        if args.json:
            print(json.dumps({"ok": True, "total": 0, "items": []}, ensure_ascii=False))
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

            print(
                json.dumps(
                    {
                        "ok": True,
                        "dry_run": True,
                        "total": len(questions),
                        "items": [{"id": q.id, "path": rel(q.path)} for q in questions],
                    },
                    ensure_ascii=False,
                )
            )
            return 0

        log("\n将测试以下题目:")
        for q in questions:
            log(f"  - {q.path.relative_to(resolver.base_dir.parent)}")
        return 0

    # 4. 创建 provider
    provider = create_provider(config.model)

    # 5. 执行测试
    runner = TestRunner(
        provider=provider,
        retry_config=config.retry,
        incremental=not args.force,
    )

    log(f"\n开始测试... (并发: {args.concurrency})")
    summary = runner.run(questions, concurrency=args.concurrency, log_fn=log)

    log(
        f"\n完成: {summary.done} | 跳过: {summary.skipped} | 失败: {summary.failed} | 总计: {summary.total}"
    )

    repo_root = resolver.base_dir.parent

    def rel(path: Optional[Path]) -> Optional[str]:
        if path is None:
            return None
        try:
            return str(path.relative_to(repo_root))
        except ValueError:
            return str(path)

    if args.json:
        print(
            json.dumps(
                {
                    "ok": summary.failed == 0,
                    "model": {
                        "name": config.model.name,
                        "provider": config.model.provider,
                        "base_url": config.model.base_url,
                        "model_id": config.model.model_id,
                    },
                    "scope": args.scope,
                    "range": args.range,
                    "concurrency": args.concurrency,
                    "incremental": not args.force,
                    "total": summary.total,
                    "done": summary.done,
                    "skipped": summary.skipped,
                    "failed": summary.failed,
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
                        for item in summary.items
                    ],
                },
                ensure_ascii=False,
            )
        )

    return 0 if summary.failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
