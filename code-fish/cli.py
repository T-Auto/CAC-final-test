#!/usr/bin/env python3
"""
Examples:
    python cli.py --scope math
    python cli.py --scope math/base-test --range 001-005
    python cli.py --scope hallucination
    python cli.py --config config.yaml --scope code
    python cli.py --mode judge --scope math --target mimo-v2-flash -j 4
    python cli.py --mode all --scope math -j 4
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
from typing import Optional

# 添加 src 到路径
sys.path.insert(0, str(Path(__file__).parent))

from src.config import load_config
from src.scope import ScopeResolver
from src.runner import TestRunner
from src.judge import JudgeRunner
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

    log(f"test-model: {config.test_model.name} ({config.test_model.provider})")
    if config.judge_model is not None:
        log(f"judge-model: {config.judge_model.name} ({config.judge_model.provider})")

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
            print(json.dumps({"ok": False, "error": error}, ensure_ascii=False))
            return 1
        log(f"错误: {error}")
        return 1

    target_model = args.target or config.test_model.name
    test_summary = None
    judge_summary = None

    # 5. 执行 test 模式
    if args.mode in ("test", "all"):
        provider = create_provider(config.test_model)
        runner = TestRunner(
            provider=provider,
            retry_config=config.retry,
            incremental=not args.force,
        )
        log(f"\n开始测试... (并发: {args.concurrency})")
        test_summary = runner.run(questions, concurrency=args.concurrency, log_fn=log)
        log(f"\n测试完成: {test_summary.done} | 跳过: {test_summary.skipped} | 失败: {test_summary.failed} | 总计: {test_summary.total}")

    # 6. 执行 judge 模式
    if args.mode in ("judge", "all"):
        judge_provider = create_provider(config.judge_model)
        judge_runner = JudgeRunner(
            provider=judge_provider,
            retry_config=config.retry,
            incremental=not args.force,
        )
        log(f"\n开始评分... (目标: {target_model}, 并发: {args.concurrency})")
        judge_summary = judge_runner.judge(questions, target_model=target_model, concurrency=args.concurrency, log_fn=log)
        avg_str = f"{judge_summary.avg_score:.2f}" if judge_summary.avg_score is not None else "N/A"
        log(f"\n评分完成: {judge_summary.done} | 跳过: {judge_summary.skipped} | 失败: {judge_summary.failed} | 无答案: {judge_summary.no_answer} | 平均分: {avg_str}")

    # 7. JSON 输出
    if args.json:
        result = {
            "ok": True,
            "mode": args.mode,
            "scope": args.scope,
            "range": args.range,
            "concurrency": args.concurrency,
            "incremental": not args.force,
            "test_model": {
                "name": config.test_model.name,
                "provider": config.test_model.provider,
                "base_url": config.test_model.base_url,
                "model_id": config.test_model.model_id,
            },
        }
        if config.judge_model is not None:
            result["judge_model"] = {
                "name": config.judge_model.name,
                "provider": config.judge_model.provider,
                "base_url": config.judge_model.base_url,
                "model_id": config.judge_model.model_id,
            }

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
            result["ok"] = result["ok"] and judge_summary.failed == 0
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

        print(json.dumps(result, ensure_ascii=False))

    # 8. 返回码
    failed = 0
    if test_summary:
        failed += test_summary.failed
    if judge_summary:
        failed += judge_summary.failed
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
