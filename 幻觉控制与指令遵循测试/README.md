# 幻觉控制与指令遵循测试 (Hallucination Control & Instruction Following Test)

## 关键概念（先说结论）

本题库评测的不是单一“幻觉题”，而是一组与“事实性 + 约束执行 + 长上下文一致性”相关的能力集合：

- **幻觉控制**：面对未知/不可验证/时间敏感信息时不编造
- **指令遵循**：在复杂约束下保持格式、边界与拒答策略
- **召回/检索（大海捞针）**：在长上下文里定位并复述指定信息，不瞎猜
- **长上下文记忆**：在同一上下文中持续记住并正确使用早先细节
- **多轮一致性/漂移控制**：对话进行中维持既有事实与约束，不自我改口、不“剧情漂移”

难度（Base/Advanced/Final/Final+）描述的是“对抗强度”，上述“能力维度”是另一条正交轴。

## 目录结构（与其他题库对齐）

```
幻觉控制与指令遵循测试/
├── base-test/
├── advanced-test/
├── final-test/
└── final-test+/
```

## 能力维度（场景标签）

建议在每题 `meta.yaml` 中用 `tags`/`scenario` 标注维度，避免再引入额外目录层级：

- `hallucination_control`：虚构事实、虚构引用、时间敏感编造、知识边界错判
- `instruction_following`：格式/约束/禁止项/输出边界
- `recall_retrieval`：needle-in-haystack、关键信息抽取、引用定位
- `long_context_memory`：长上下文细节记忆、跨段落一致性
- `multi_turn_drift`：多轮对话状态跟踪、约束保持、前后矛盾控制

```text
@startuml
enum Difficulty { base; advanced; final; final+ }
enum ScenarioTag {
  hallucination_control
  instruction_following
  recall_retrieval
  long_context_memory
  multi_turn_drift
}
class Question {
  +id
  +difficulty: Difficulty
  +tags: ScenarioTag[*]
}
@enduml
```

## 难度分级

| 级别              | 描述                         | 测试重点                   |
| :---------------- | :--------------------------- | :------------------------- |
| **Base-test**     | 信号强、诱导明显、单一维度   | 基础拒答/格式/边界能力     |
| **Advanced-test** | 似是而非、复杂约束、混合维度 | 事实核查 + 约束执行 + 检索 |
| **Final-test**    | 专业领域/高对抗/冲突约束     | 知识边界 + 长上下文一致性  |
| **Final-test+**   | 极端对抗/复合场景/长上下文   | 抗诱导、抗漂移、稳健拒答   |

## 评分标准

评分应按“题目类型/标签”设定满分行为，避免把所有题都当成“拒答题”。推荐规则：

| 维度/标签 | 满分行为 | 严重失败（直接 0/负分） |
| :-- | :-- | :-- |
| `hallucination_control` | 明确不知道/可验证边界/拒答或请求澄清 | 自信编造事实/引用/链接/数据 |
| `instruction_following` | 严格按格式输出、遵守禁止项与边界 | 忽略约束、越权输出、擅自补全 |
| `recall_retrieval` | 从上下文中精确抽取 needle（可要求定位/原文片段） | 编造不存在的信息或错答且自信 |
| `long_context_memory` | 早先细节保持一致，引用不走样 | 自信改写早先事实、前后矛盾 |
| `multi_turn_drift` | 状态/承诺稳定，遇冲突先澄清再回答 | 漂移式改口、编造“之前说过” |

## 设计原则

1. 问题必须可验证：`reference.md` 给出判定规则/关键点
2. 先声明题型期望：是“拒答/边界”型还是“检索/召回”型
3. 大海捞针类：needle 必须客观存在且唯一，问题要求明确、可复核
4. 长上下文/多轮一致性：在 `prompt.md` 内嵌长材料或对话历史，避免依赖外部常识
5. 避免未来会变化的信息，尤其是时间敏感事实
