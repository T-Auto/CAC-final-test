# 仓库维护规范 v2.0

> **❗在push和提交pr之前务必阅读此文档**

## 文件组织规范

总体逻辑如下：
```text
# 子目录需要遵循两层次分类
CAC-final-test/
├── 代码能力基准测试题库/
│   ├── advanced-test/
│   ├── base-test/
│   ├── final-test/
│   └── final-test+/
├── 数理能力基准测试题库/
│   ├── advanced-test/
│   ├── base-test/
│   ├── final-test/
│   └── final-test+/
├── 自然语言与逻辑能力基准测试题库/
│   ├── advanced-test/
│   ├── base-test/
│   ├── final-test/
│   └── final-test+/
├── 综合能力测评/
├── README.md  # 简介
└── CONTRIBUTING.md # 仓库维护手册
```

对于具体分类题库，这里以 `自然语言与逻辑能力基准测试题库/base-test/` 为例子：
```text
# 题目以目录形式组织，遵循时间顺序编号
base-test/
├── 001-age-multiple-reasoning/
│   ├── README.md
│   └── test-results/
├── 002-clock-interval-trap/
│   ├── README.md
│   └── test-results/
├── 003-direction-reasoning/
│   ├── README.md
│   └── test-results/
└── .gitkeep
```

**目录命名规则：**
- `NNN-problem-name/`：三位数字编号 + 连字符 + 问题描述（小写英文，单词间用连字符分隔）
- 每个题目目录必须包含 `README.md` 文件（题目内容）
- 每个题目目录必须包含 `test-results/` 子目录（存放该题目的测试结果）

## 测试结果存放规范

为保证测试结果可追溯且与题目一一对应，测试结果文件存放在对应题目目录下的 `test-results/` 子目录中。

**目录结构示例：**
```text
自然语言与逻辑能力基准测试题库/base-test/
├── 001-age-multiple-reasoning/
│   ├── README.md
│   └── test-results/
│       ├── claude-3.5-sonnet.md
│       ├── gpt-4o.md
│       └── deepseek.md
├── 002-clock-interval-trap/
│   ├── README.md
│   └── test-results/
│       ├── claude-3.5-sonnet.md
│       └── gpt-4o.md
```

**命名规则：**
- 测试结果文件名：`模型名.md`
- 模型名仅使用小写字母、数字和连字符
- 每个模型的测试结果独立存放在一个文件中

**完整对应示例：**
```text
# 题目目录
自然语言与逻辑能力基准测试题库/base-test/001-age-multiple-reasoning/
├── README.md  # 题目内容
└── test-results/
    ├── claude-3.5-sonnet.md  # Claude 3.5 Sonnet 的测试结果
    └── gpt-4o.md             # GPT-4o 的测试结果
```


## Commit Message 规范

本项目遵循 Conventional Commits 规范，这是一种轻量级的 commit message 约定，用于创建明确的提交历史记录。所有提交信息应使用中文的流畅语言和 emoji。

### 提交前的分析步骤

在编写 commit message 之前，请仔细分析 git diff 以理解所做的更改：
- 识别被修改、新增或删除的文件
- 确定更改的性质（例如：错误修复、新功能、重构等）
- 检查是否有破坏性更改

### Commit 类型

| 图标 | 类型 | 说明 |
|------|------|------|
| 🎉 | `init` | 初始化 |
| 🚀 | `release` | 发布新版本 |
| 🎨 | `style` | 代码风格修改（不影响代码运行的变动） |
| ✨ | `feat` | 添加新功能 |
| 🐛 | `fix` | 修复 bug |
| 📝 | `docs` | 对文档进行修改 |
| ♻️ | `refactor` | 代码重构（既不是新增功能，也不是修改 bug 的代码变动） |
| ⚡ | `perf` | 提高性能的代码修改 |
| 🧑‍💻 | `dx` | 优化开发体验 |
| 🔨 | `workflow` | 工作流变动 |
| 🏷️ | `types` | 类型声明修改 |
| 🚧 | `wip` | 工作正在进行中 |
| ✅ | `test` | 测试用例添加及修改 |
| 🔨 | `build` | 影响构建系统或外部依赖关系的更改 |
| 👷 | `ci` | 更改 CI 配置文件和脚本 |
| ❓ | `chore` | 其它不涉及源码以及测试的修改 |
| ⬆️ | `deps` | 依赖项修改 |
| 🔖 | `release` | 发布新版本 |

### 编写步骤

1. **确定适当的提交类型**：根据上表选择最符合更改性质的类型

2. **标记破坏性更改**：如果提交引入了破坏性更改，在类型/范围后面加上感叹号（例如：`feat!:`）

3. **编写主题行**：提供一个简短的、祈使语气的更改描述

4. **添加正文（可选）**：在需要时添加更详细的更改说明，解释更改的动机并与先前的行为进行对比

5. **添加页脚（可选）**：如果有破坏性更改，请在提交正文的末尾描述它们，以"破坏性更改："开头

### 格式规范

```
[emoji][类型][可选范围]: [描述]

[可选正文]

[可选页脚]
```

**必须遵守的规则：**
- 主题行不应超过 50 个字符
- 正文应在 72 个字符处换行
- 在主题行中使用祈使句和现在式
- 主题行结尾不要加句号
- 用空白行将主题与正文分开
- 使用正文解释做了什么和为什么，而不是如何做
- 一个好的 commit message 应该能够完成句子："如果应用，这个提交将 [你的主题行]"

### 格式示例

**简单提交：**
```
🎨 style: 统一代码缩进风格

✨ feat: 添加用户登录功能

🐛 fix: 修复登录页面验证码显示问题

📝 docs: 更新 API 文档说明
```

**包含正文的提交：**
```
✨ feat(auth): 添加 OAuth2 认证支持

实现了基于 OAuth2 协议的第三方登录功能，支持 GitHub 和 Google 账号登录。
用户现在可以使用社交账号快速注册和登录系统。

- 集成 OAuth2 客户端库
- 添加第三方账号绑定逻辑
- 更新用户数据模型
```

**破坏性更改：**
```
✨ feat(api)!: 重构 API 端点结构

将所有 API 端点从 /api/v1 迁移到 /api/v2，并统一了响应格式。

破坏性更改：
- 所有 v1 API 端点将在下个版本中废弃
- 响应格式从 {data, error} 改为 {success, data, message}
- 需要更新客户端代码以适配新的 API 结构
```

## 题目编写规范

### 题目目录结构

每个题目目录必须包含以下文件：

```
NNN-problem-name/
├── README.md       # 给人看的完整文档（题目背景、解析、考点等）
├── meta.yaml       # 给程序看的元数据（id、评分指标等）
├── prompt.md       # 发给被测模型的 prompt
├── reference.md    # 标准答案/评判依据
└── test-results/   # 测试结果目录
```

### 各文件职责说明

| 文件 | 给谁看 | 内容说明 |
|------|--------|----------|
| `README.md` | 人类 | 完整的题目文档：背景、题目、解析、常见错误、考点扩展 |
| `meta.yaml` | 程序 | 元数据：id、简介、难度、评分指标 |
| `prompt.md` | 被测模型 | 纯净的 prompt，就是发给模型的内容 |
| `reference.md` | 评判模型 | 标准答案或评判依据 |
| `test-results/` | 人类 | 各模型的测试结果 |

### 目录命名规则

- `NNN`：三位数字编号，从 001 开始递增
- `problem-name`：题目的简短英文描述
  - 使用小写字母
  - 单词之间用连字符 `-` 分隔
  - 避免使用特殊字符（除了 `-`）
  - 保持简洁但有描述性

**示例：**
- ✅ `001-binary-search/`
- ✅ `002-matrix-multiplication/`
- ✅ `001-age-multiple-reasoning/`
- ❌ `1-problem/` （编号不足三位）
- ❌ `001_problem_name/` （使用了下划线）
- ❌ `001-Problem-Name/` （使用了大写字母）

### meta.yaml 格式规范

```yaml
id: math-base-001              # 唯一标识，格式：{类别}-{难度}-{编号}
brief: 鸡兔同笼经典问题         # 简短描述
category: math                 # 类别：math | code | logic | comprehensive
difficulty: base               # 难度：base | advanced | final | final+
scoring_std:
  max_score: 10                # 满分
  indicators:                  # 评分指标（引用 indicators.yaml 中定义的指标）
    - accuracy
    - completeness
    - clarity
```

**id 命名规则：**
- 数理题：`math-{difficulty}-{number}`
- 代码题：`code-{difficulty}-{number}`
- 逻辑题：`logic-{difficulty}-{number}`
- 综合题：`comp-{number}`

**可用的评分指标（定义在 `code-fish/data/indicators.yaml`）：**

| 类别 | 指标 | 说明 |
|------|------|------|
| code | `ans_correct` | 答案正确性 - 代码能否正确运行并得到预期结果 |
| code | `code_quality` | 代码质量 - 代码风格、注释、可读性 |
| code | `efficiency` | 运行效率 - 算法时间和空间复杂度 |
| code | `robustness` | 鲁棒性 - 异常处理和边界情况考虑 |
| theory | `completeness` | 回答完整性 - 是否涵盖问题的所有方面 |
| theory | `accuracy` | 准确性 - 概念和信息是否准确无误 |
| theory | `clarity` | 表达清晰度 - 逻辑是否清晰、表述是否易懂 |
| theory | `depth` | 深度 - 回答是否有深度和见解 |

### prompt.md 格式规范

`prompt.md` 是发给被测模型的**纯净 prompt**，应该：
- 只包含题目内容，不包含元数据
- 清晰明确，无歧义
- 可以直接复制粘贴发给模型

**数理题示例：**
```markdown
鸡兔同笼，共35只头，94只脚，问鸡兔各多少？

请给出完整的解题过程和最终答案。
```

**代码题示例：**
```markdown
创建一个简单的计算器网页应用，要求：
1. 支持基本四则运算（加、减、乘、除）
2. 包含数字0-9按钮、小数点、运算符按钮和等号
...

仅返回完整的HTML代码，不包含markdown格式标记。
```

### reference.md 格式规范

`reference.md` 是给评判模型参考的**标准答案或评判依据**。

**数理题格式：**
```markdown
# 标准答案

**鸡23只，兔12只**

# 解题过程

## 方法一：二元一次方程组
...

# 评判要点

1. 答案必须正确
2. 解题过程需要有逻辑推导
3. 最好有验证步骤
```

**代码题格式：**
```markdown
# 考察能力

- HTML结构设计与语义化
- CSS布局与样式设计
- JavaScript基础编程
...

# 测试要点

## 基础功能
- [ ] 数字输入正常显示
- [ ] 四则运算计算正确
...

## 边界情况
- [ ] 除以零的处理
...

# 评判标准

1. **功能正确性 (40%)**：四则运算结果正确
2. **代码质量 (30%)**：代码结构清晰
3. **边界处理 (20%)**：正确处理边界情况
4. **UI设计 (10%)**：界面美观
```

### README.md 内容建议

`README.md` 是给人类阅读的完整文档，建议包含：

**数理/逻辑题库格式：**
```markdown
# Question

[题目描述]

# Analysis

## 正确答案
[答案]

## 解题过程
[详细解题步骤，可包含多种解法]

## 常见错误
[列举常见错误及原因]

## 核心考点
[考察的知识点]

## 知识扩展
[相关知识扩展，可选]
```

**代码题库格式：**
```markdown
# [题目名称]

## 测试 Prompts
[发给模型的完整 prompt]

## 考察能力
[考察的技能点]

## 测试要点
[功能测试、边界测试等检查项]

## 分析与答案
[参考实现、复杂度分析等]
```

### 综合能力测评命名规则

综合能力测评目录使用描述性英文名称：
```
综合能力测评/
├── Weather Cards Simple Frontend Skills Test/
│   ├── prompt.md
│   ├── meta.yaml
│   ├── reference.md
│   └── [模型输出文件]
└── Stealth Fighter RCS Simulation.../
```

### 重要说明

- **新题目必须**包含 `meta.yaml`、`prompt.md`、`reference.md` 三个文件
- **已有题目**会逐步迁移到新格式
- `README.md` 保持原有内容，作为人类可读的完整文档
- 评分指标必须在 `code-fish/data/indicators.yaml` 中定义
