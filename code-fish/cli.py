#!/usr/bin/env python3
"""
Examples:
    python cli.py --scope math
    python cli.py --scope math/base-test --range 001-005
    python cli.py --config config.yaml --scope code
    python cli.py --scope math --force
    python cli.py --scope math/advanced --dry-run

Providers:
    openai      OpenAI/DeepSeek/Qwen 等（自动补 `/chat/completions`）
    anthropic   Claude（`/v1/messages`）
    gemini      Google Gemini（`/v1beta/...:generateContent`）
    custom      完整 URL（如 Ollama Cloud）
"""
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
        help="测试范围: math, code, logic, comp 或 math/base-test",
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

    # 1. 加载配置
    try:
        config = load_config(args.config)
    except FileNotFoundError:
        print(f"错误: 配置文件不存在: {args.config}")
        sys.exit(1)
    except ValueError as e:
        print(f"错误: 配置无效: {e}")
        sys.exit(1)

    print(f"模型: {config.model.name} ({config.model.provider})")

    # 2. 解析 scope
    resolver = ScopeResolver(config.question_banks)
    try:
        questions = resolver.resolve(args.scope, args.range)
    except ValueError as e:
        print(f"错误: {e}")
        sys.exit(1)

    if not questions:
        print("未找到匹配的题目")
        sys.exit(0)

    print(f"找到 {len(questions)} 道题目")

    # 3. dry-run 模式
    if args.dry_run:
        print("\n将测试以下题目:")
        for q in questions:
            print(f"  - {q.path.relative_to(resolver.base_dir.parent)}")
        return

    # 4. 创建 provider
    provider = create_provider(config.model)

    # 5. 执行测试
    runner = TestRunner(
        provider=provider,
        retry_config=config.retry,
        incremental=not args.force,
    )

    print(f"\n开始测试...")
    runner.run(questions)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
