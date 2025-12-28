"""评分执行器"""
from __future__ import annotations

import json
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Literal, Optional

import yaml

from .config import RetryConfig
from .providers import BaseProvider
from .reporting import Event, EventType, Phase, Reporter
from .scope import Question


@dataclass(frozen=True)
class JudgeItemResult:
    index: int
    question_id: str
    question_path: Path
    target_model: str
    status: Literal["done", "skipped", "failed", "no_answer"]
    total_score: Optional[float] = None
    max_score: Optional[float] = None
    dimensions: Optional[dict] = None
    feedback: Optional[str] = None
    output_file: Optional[Path] = None
    elapsed_s: Optional[float] = None
    attempts: Optional[int] = None
    error: Optional[str] = None


@dataclass(frozen=True)
class JudgeSummary:
    judge_name: str
    target_model: str
    total: int
    done: int
    skipped: int
    failed: int
    no_answer: int
    avg_score: Optional[float]
    items: List[JudgeItemResult]


JUDGE_PROMPT_TEMPLATE = """你是专业评审员。请根据以下信息评分：

## 原题目
{prompt}

## 参考答案/评分标准
{reference}

## 被测模型的回答
{answer}

## 评分维度（满分 {max_score} 分）
{indicators_list}

请调用 submit_score 工具提交评分结果。"""


# 旧版 prompt（用于不支持 tool calling 的 provider）
JUDGE_PROMPT_TEMPLATE_LEGACY = """你是专业评审员。请根据以下信息评分：

## 原题目
{prompt}

## 参考答案/评分标准
{reference}

## 被测模型的回答
{answer}

## 评分维度（满分 {max_score} 分）
{indicators_list}

请严格按照以下 JSON 格式输出（不要输出其他内容）：
```json
{{
  "total_score": <总分>,
  "dimensions": {{
    "<维度名>": {{"score": <得分>, "comment": "<简短评价>"}},
    ...
  }},
  "feedback": "<总体评价>"
}}
```"""


def _build_judge_tool_schema(max_score: float, indicators: list) -> dict:
    """构建评分工具的 JSON Schema"""
    dimension_properties = {}
    for ind in indicators:
        dimension_properties[ind] = {
            "type": "object",
            "properties": {
                "score": {"type": "number", "description": f"{ind} 维度得分"},
                "comment": {"type": "string", "description": f"{ind} 维度评价"},
            },
            "required": ["score", "comment"],
        }

    return {
        "name": "submit_score",
        "description": f"提交评分结果，满分 {max_score} 分",
        "parameters": {
            "type": "object",
            "properties": {
                "total_score": {
                    "type": "number",
                    "description": f"总分（0-{max_score}）",
                },
                "dimensions": {
                    "type": "object",
                    "description": "各维度评分",
                    "properties": dimension_properties,
                    "required": indicators,
                },
                "feedback": {
                    "type": "string",
                    "description": "总体评价",
                },
            },
            "required": ["total_score", "dimensions", "feedback"],
        },
    }


class JudgeRunner:
    """执行评分"""

    def __init__(
        self,
        provider: BaseProvider,
        retry_config: RetryConfig,
        incremental: bool = True,
    ):
        self.provider = provider
        self.retry_config = retry_config
        self.incremental = incremental
        self.judge_name = provider.get_model_name()

    def judge(
        self,
        questions: List[Question],
        target_model: str,
        concurrency: int = 1,
        reporter: Optional[Reporter] = None,
    ) -> JudgeSummary:
        if concurrency < 1:
            raise ValueError("concurrency 必须 >= 1")

        total = len(questions)
        items_by_index: dict[int, JudgeItemResult] = {}
        to_judge: list[tuple[int, Question, Path, Path]] = []

        for i, question in enumerate(questions, 1):
            answer_file = question.path / "test-results" / f"{target_model}.md"
            output_file = question.path / "test-results" / f"{target_model}.judge.yaml"

            # 检查是否有测试结果
            if not answer_file.exists():
                error = f"缺少测试结果: {answer_file.name}"
                items_by_index[i] = JudgeItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    target_model=target_model,
                    status="no_answer",
                    error=error,
                )
                if reporter is not None:
                    reporter.on_event(Event(
                        phase=Phase.JUDGE,
                        event_type=EventType.NO_ANSWER,
                        index=i,
                        total=total,
                        question_id=question.id,
                        error=error,
                    ))
                continue

            # 增量模式：跳过已评分的
            if self.incremental and output_file.exists():
                items_by_index[i] = JudgeItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    target_model=target_model,
                    status="skipped",
                    output_file=output_file,
                )
                if reporter is not None:
                    reporter.on_event(Event(
                        phase=Phase.JUDGE,
                        event_type=EventType.SKIP,
                        index=i,
                        total=total,
                        question_id=question.id,
                        output_file=output_file,
                    ))
                continue

            to_judge.append((i, question, answer_file, output_file))

        def judge_one(i: int, question: Question, answer_file: Path, output_file: Path) -> JudgeItemResult:
            started = time.monotonic()
            attempts: Optional[int] = None
            try:
                if reporter is not None:
                    reporter.on_event(Event(
                        phase=Phase.JUDGE,
                        event_type=EventType.START,
                        index=i,
                        total=total,
                        question_id=question.id,
                    ))

                # 读取题目、参考答案、被测回答
                prompt = (question.path / "prompt.md").read_text(encoding="utf-8")
                reference = (question.path / "reference.md").read_text(encoding="utf-8")
                answer = answer_file.read_text(encoding="utf-8")

                # 读取 meta.yaml 获取评分维度
                meta = self._load_meta(question.path)
                scoring_std = meta.get("scoring_std", {})
                indicators = scoring_std.get("indicators", ["accuracy"])
                max_score = scoring_std.get("max_score", 10)
                if not isinstance(indicators, list):
                    raise ValueError(f"meta.yaml scoring_std.indicators 必须是列表: {type(indicators).__name__}")

                # 检查是否支持 tool calling
                use_tool = self.provider.supports_tool_calling()
                
                # 构造评分 prompt 和 tool schema
                judge_prompt = self._build_judge_prompt(prompt, reference, answer, indicators, max_score, use_tool=use_tool)
                tool_schema = _build_judge_tool_schema(max_score, indicators) if use_tool else None

                # 调用评分模型
                result, attempts = self._request_with_retry(
                    judge_prompt,
                    tool_schema=tool_schema,
                    index=i,
                    total=total,
                    question_id=question.id,
                    reporter=reporter,
                )

                # 解析评分结果（tool calling 已返回 dict，无需再解析）
                total_score_raw = result.get("total_score")
                if total_score_raw is None:
                    raise ValueError("评分输出缺少 total_score")
                try:
                    total_score = float(total_score_raw)
                except (TypeError, ValueError) as e:
                    raise ValueError(f"评分输出 total_score 非数字: {total_score_raw!r}") from e

                try:
                    max_score_num = float(max_score)
                except (TypeError, ValueError) as e:
                    raise ValueError(f"meta.yaml scoring_std.max_score 非数字: {max_score!r}") from e

                if total_score < 0 or total_score > max_score_num + 1e-6:
                    raise ValueError(f"评分输出 total_score 越界: {total_score}/{max_score_num}")

                dimensions = result.get("dimensions", {})
                if dimensions is None:
                    dimensions = {}
                if not isinstance(dimensions, dict):
                    raise ValueError(f"评分输出 dimensions 必须是对象: {type(dimensions).__name__}")

                feedback = result.get("feedback", "")
                if feedback is None:
                    feedback = ""
                if not isinstance(feedback, str):
                    feedback = str(feedback)

                # 写入结果
                self._write_result(
                    output_file=output_file,
                    question_id=question.id,
                    target_model=target_model,
                    total_score=total_score,
                    max_score=max_score_num,
                    indicators=indicators,
                    dimensions=dimensions,
                    feedback=feedback,
                )

                elapsed = time.monotonic() - started
                if reporter is not None:
                    reporter.on_event(Event(
                        phase=Phase.JUDGE,
                        event_type=EventType.DONE,
                        index=i,
                        total=total,
                        question_id=question.id,
                        elapsed_s=elapsed,
                        attempt=attempts,
                        score=total_score,
                        max_score=max_score_num,
                    ))

                return JudgeItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    target_model=target_model,
                    status="done",
                    total_score=total_score,
                    max_score=max_score_num,
                    dimensions=dimensions,
                    feedback=feedback,
                    output_file=output_file,
                    elapsed_s=elapsed,
                    attempts=attempts,
                )
            except Exception as e:
                elapsed = time.monotonic() - started
                error = f"{type(e).__name__}: {e}"
                if reporter is not None:
                    reporter.on_event(Event(
                        phase=Phase.JUDGE,
                        event_type=EventType.FAIL,
                        index=i,
                        total=total,
                        question_id=question.id,
                        elapsed_s=elapsed,
                        attempt=attempts,
                        error=error,
                    ))
                return JudgeItemResult(
                    index=i,
                    question_id=question.id,
                    question_path=question.path,
                    target_model=target_model,
                    status="failed",
                    elapsed_s=elapsed,
                    attempts=attempts,
                    error=error,
                )

        # 执行评分
        if concurrency == 1:
            for i, question, answer_file, output_file in to_judge:
                items_by_index[i] = judge_one(i, question, answer_file, output_file)
        else:
            with ThreadPoolExecutor(max_workers=concurrency) as executor:
                futures = [
                    executor.submit(judge_one, i, question, answer_file, output_file)
                    for i, question, answer_file, output_file in to_judge
                ]
                for future in as_completed(futures):
                    result = future.result()
                    items_by_index[result.index] = result

        # 汇总
        items = [items_by_index[i] for i in sorted(items_by_index)]
        done = sum(1 for item in items if item.status == "done")
        skipped = sum(1 for item in items if item.status == "skipped")
        failed = sum(1 for item in items if item.status == "failed")
        no_answer = sum(1 for item in items if item.status == "no_answer")

        # 计算平均分
        scored_items = [item for item in items if item.status == "done" and item.total_score is not None]
        avg_score = None
        if scored_items:
            avg_score = sum(item.total_score for item in scored_items) / len(scored_items)

        return JudgeSummary(
            judge_name=self.judge_name,
            target_model=target_model,
            total=total,
            done=done,
            skipped=skipped,
            failed=failed,
            no_answer=no_answer,
            avg_score=avg_score,
            items=items,
        )

    def _load_meta(self, question_path: Path) -> dict:
        meta_file = question_path / "meta.yaml"
        if not meta_file.exists():
            return {}
        with open(meta_file, "r", encoding="utf-8") as f:
            meta = yaml.safe_load(f) or {}
            if not isinstance(meta, dict):
                return {}
            return meta

    def _build_judge_prompt(self, prompt: str, reference: str, answer: str, indicators: list, max_score: int, use_tool: bool = True) -> str:
        indicators_list = "\n".join(f"- {ind}" for ind in indicators)
        template = JUDGE_PROMPT_TEMPLATE if use_tool else JUDGE_PROMPT_TEMPLATE_LEGACY
        return template.format(
            prompt=prompt,
            reference=reference,
            answer=answer,
            max_score=max_score,
            indicators_list=indicators_list,
        )

    def _parse_judge_response(self, response: str) -> dict:
        """解析评分模型的 JSON 响应（仅用于 legacy 模式）"""
        # 尝试提取 JSON 块
        if "```json" in response:
            start = response.find("```json") + 7
            end = response.find("```", start)
            if end > start:
                response = response[start:end].strip()
        elif "```" in response:
            start = response.find("```") + 3
            end = response.find("```", start)
            if end > start:
                response = response[start:end].strip()

        return json.loads(response)

    def _request_with_retry(
        self,
        prompt: str,
        tool_schema: Optional[dict],
        index: int,
        total: int,
        question_id: str,
        reporter: Optional[Reporter],
    ) -> tuple[dict, int]:
        """
        带重试的请求。
        - 如果 tool_schema 不为 None 且 provider 支持 tool calling，使用 chat_with_tool
        - 否则使用 chat + JSON 解析
        返回 (解析后的 dict, 尝试次数)
        """
        max_attempts = self.retry_config.max_attempts
        delay = self.retry_config.delay
        last_error = None

        use_tool = tool_schema is not None and self.provider.supports_tool_calling()

        for attempt in range(1, max_attempts + 1):
            try:
                if use_tool:
                    # 使用 tool calling，直接返回 dict
                    result = self.provider.chat_with_tool(prompt, tool_schema)
                else:
                    # 使用传统方式，需要解析 JSON
                    response = self.provider.chat(prompt)
                    result = self._parse_judge_response(response)
                return result, attempt
            except Exception as e:
                last_error = e
                if attempt < max_attempts:
                    if reporter is not None:
                        reporter.on_event(Event(
                            phase=Phase.JUDGE,
                            event_type=EventType.RETRY,
                            index=index,
                            total=total,
                            question_id=question_id,
                            attempt=attempt,
                            max_attempts=max_attempts,
                            error=f"{type(e).__name__}: {e}",
                        ))
                    time.sleep(delay)

        raise RuntimeError(f"请求失败 ({max_attempts} 次尝试): {last_error}")

    def _write_result(
        self,
        output_file: Path,
        question_id: str,
        target_model: str,
        total_score: float,
        max_score: float,
        indicators: list,
        dimensions: dict,
        feedback: str,
    ):
        output_file.parent.mkdir(exist_ok=True)

        result = {
            "judge_model": self.judge_name,
            "target_model": target_model,
            "question_id": question_id,
            "judged_at": datetime.now(timezone.utc).isoformat(),
            "total_score": total_score,
            "max_score": max_score,
            "indicators": indicators,
            "dimensions": dimensions,
            "feedback": feedback,
        }

        with open(output_file, "w", encoding="utf-8") as f:
            yaml.dump(result, f, allow_unicode=True, default_flow_style=False, sort_keys=False)
