# CLI Beautify - Development Plan

## Overview
将 CLI 输出从纯 print 日志升级为结构化事件驱动架构，支持 rich 进度条、彩色状态和汇总表格，同时保持 `--json` 模式兼容。

## Task Breakdown

### Task 1: Event/Reporter 接口与基础设施
- **ID**: task-1
- **Description**: 定义 `Event` 数据类（类型: start/skip/done/fail/retry/no_answer）和 `Reporter` 协议；实现 `PlainReporter`（纯文本降级）；创建 Console 工厂函数检测 TTY
- **File Scope**: `code-fish/src/reporting.py`（新建）, `code-fish/cac.py`（导入并初始化）
- **Dependencies**: None
- **Test Command**: `python -m py_compile code-fish/src/reporting.py code-fish/cac.py`
- **Test Focus**:
  - Event 数据类字段完整性
  - PlainReporter.on_event() 输出格式正确
  - Console 工厂在 TTY/非 TTY 环境返回正确配置

### Task 2: TestRunner 结构化事件改造
- **ID**: task-2
- **Description**: 将 `runner.py` 的 `log_fn(str)` 回调改为 `reporter.on_event(Event)`；移除字符串拼接，改用 Event 对象传递状态
- **File Scope**: `code-fish/src/runner.py`
- **Dependencies**: task-1
- **Test Command**: `python -m py_compile code-fish/src/runner.py && python -c "from src.runner import TestRunner; print('OK')"`
- **Test Focus**:
  - SKIP/TEST/DONE/FAIL/RETRY 事件正确触发
  - 事件携带 index/total/question_id/elapsed_s 等字段
  - 并发场景下事件顺序不影响正确性

### Task 3: JudgeRunner 结构化事件改造
- **ID**: task-3
- **Description**: 同 Task 2，覆盖 `judge.py` 的 NO_ANSWER/SKIP/JUDGE/DONE/FAIL/RETRY 事件
- **File Scope**: `code-fish/src/judge.py`
- **Dependencies**: task-1
- **Test Command**: `python -m py_compile code-fish/src/judge.py && python -c "from src.judge import JudgeRunner; print('OK')"`
- **Test Focus**:
  - NO_ANSWER 事件在缺少测试结果时触发
  - JUDGE 事件在开始评分时触发
  - 评分结果（score/max_score）正确传入 DONE 事件

### Task 4: RichReporter 实现与 CLI 集成
- **ID**: task-4
- **Description**: 实现 `RichReporter`：Live 进度条 + 最近事件滚动日志 + 最终汇总 Table；样式规范：INFO 淡青、SKIP 灰、DONE 绿、RETRY 黄、FAIL/NO_ANSWER 红；CLI 根据 TTY 自动选择 Reporter
- **File Scope**: `code-fish/src/reporting.py`, `code-fish/cac.py`
- **Dependencies**: task-1, task-2, task-3
- **Test Command**: `cd code-fish && python cac.py --scope math/base-test --dry-run`
- **Test Focus**:
  - TTY 环境显示进度条和彩色输出
  - 非 TTY 环境降级为 PlainReporter
  - `--json` 模式下 RichReporter 不输出到 stdout
  - 最终汇总表格包含 done/skipped/failed 统计

### Task 5: Help 美化与 UI 细节
- **ID**: task-5
- **Description**: 使用 rich Panel/Table 重新排版 argparse help 输出；统一 CLI 启动 banner 样式
- **File Scope**: `code-fish/cac.py`
- **Dependencies**: task-4
- **Test Command**: `cd code-fish && python cac.py --help`
- **Test Focus**:
  - help 输出使用 Panel 包裹
  - 参数分组清晰（必选/可选/模式）
  - 示例命令高亮显示

## Acceptance Criteria
- [ ] Event/Reporter 协议定义完整，支持 6 种事件类型
- [ ] TestRunner 和 JudgeRunner 完全迁移到事件驱动
- [ ] TTY 环境显示 rich 进度条和彩色状态
- [ ] 非 TTY 环境自动降级为纯文本输出
- [ ] `--json` 模式 stdout 仅输出 JSON，日志走 stderr
- [ ] 最终汇总以 Table 形式展示统计数据
- [ ] help 输出美观且信息完整
- [ ] 所有模块通过语法检查
- [ ] 代码覆盖率 >= 90%

## Technical Notes
- rich 已在 `requirements.txt`，无需新增依赖
- 并发场景下 Reporter 需线程安全（rich Console 内置锁）
- `--json` 模式：RichReporter 应将 Console 指向 stderr 或完全禁用
- 保持向后兼容：现有 JSON 输出结构不变

## Parallel Execution Strategy
```
task-1 ──┬──> task-2 ──┐
         │             │
         └──> task-3 ──┼──> task-4 ──> task-5
```
- task-2 和 task-3 可并行执行（均仅依赖 task-1）
- task-4 需等待 task-2、task-3 完成
- task-5 依赖 task-4 的 CLI 集成

## UI Task Notes (needs_ui=true)
由于本功能直接面向终端用户，需特别关注：
1. 颜色对比度：确保在浅色/深色终端均可读
2. 进度条宽度：自适应终端宽度，窄终端降级为简化显示
3. 无障碍：纯文本降级模式保留完整信息
4. 响应性：长时间任务需显示已用时间和预估剩余时间
