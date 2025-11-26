# 编号规则

## 编号格式

- 必须是三位数字：`001`, `002`, `003`, ...
- 从 001 开始
- 连续递增（不跳号）

| 编号 | 有效性 |
|------|--------|
| `001` | ✅ |
| `002` | ✅ |
| `010` | ✅ |
| `100` | ✅ |
| `1` | ❌ 不足三位 |
| `01` | ❌ 不足三位 |
| `0001` | ❌ 超过三位 |

## 查找下一个编号

在创建新题目前，需要确定该难度级别下的下一个可用编号。

### 步骤

1. 进入目标题库的目标难度目录
2. 列出所有现有题目目录
3. 找到最大编号
4. 新编号 = 最大编号 + 1

### 命令示例

```bash
# 查看数理题库 base-test 下的题目
ls 数理能力基准测试题库/base-test/

# 查看代码题库 advanced-test 下的题目
ls 代码能力基准测试题库/advanced-test/

# 查看逻辑题库 final-test 下的题目
ls 自然语言与逻辑能力基准测试题库/final-test/
```

### 输出示例

```
001-chicken-rabbit-cage/
002-cubic-function-roots/
```

下一个编号应该是 `003`。

## 目录命名规范

格式：`NNN-problem-name`

- `NNN`：三位数字编号
- `problem-name`：问题名称
  - 使用小写英文字母
  - 单词间用连字符 `-` 分隔
  - 简洁但有描述性
  - 不使用中文

### 好的命名示例

- `001-chicken-rabbit-cage`
- `002-dice-covariance`
- `003-water-jug-problem`
- `001-simple-calculator`
- `002-implement-trie-data-structure`

### 不好的命名示例

- `001-鸡兔同笼` ❌ 使用了中文
- `001_chicken_rabbit` ❌ 使用了下划线
- `1-chicken-rabbit` ❌ 编号不足三位
- `001-ChickenRabbit` ❌ 使用了大写字母
- `001-a-very-long-problem-name-that-is-too-descriptive` ❌ 名称过长

## 各题库路径

| 类别 | 路径 |
|------|------|
| 代码能力 | `代码能力基准测试题库/{difficulty}-test/` |
| 数理能力 | `数理能力基准测试题库/{difficulty}-test/` |
| 逻辑能力 | `自然语言与逻辑能力基准测试题库/{difficulty}-test/` |
| 综合能力 | `综合能力测评/` |

其中 `{difficulty}` 可以是：`base`, `advanced`, `final`, `final+`

## id 命名规则

格式：`{category}-{difficulty}-{number}`

| category | difficulty | 示例 |
|----------|------------|------|
| math | base, adv, final, final+ | `math-base-001` |
| code | base, adv, final, final+ | `code-adv-002` |
| logic | base, adv, final, final+ | `logic-final-001` |
| comp | (无) | `comp-001` |

## 测试结果文件命名

位置：`test-results/` 目录下

格式：`{model-name}.md`
- 使用小写字母、数字和连字符
- 示例：`claude-3.5-sonnet.md`, `gpt-4o.md`, `deepseek-v3.md`

## 注意事项

1. **创建前务必检查**：每次创建新题目前，都要实际查看目录确认当前最大编号
2. **不要跳号**：如果当前最大是 002，下一个必须是 003
3. **综合能力测评特殊**：综合能力测评不使用编号，直接用问题名称作为目录名
