# CAC 评测系统 (code-fish)

LLM 能力自动化评测工具，支持灵活的 scope 选择和增量测试。

## 快速开始

```bash
cd code-fish

# 1. 安装依赖
pip install -r requirements.txt

# 2. 配置模型
cp config.yaml.example config.yaml
# 编辑 config.yaml，填入 API key

# 3. 运行测试
python cli.py --scope math              # 测试整个数理题库
python cli.py --scope math/base-test    # 测试数理基础题
python cli.py --scope math/advanced --range 001-005  # 指定范围
python cli.py --scope logic --dry-run   # 预览将测试的题目
```

## 配置文件

```yaml
# config.yaml
model:
  name: gpt-4o                  # 输出文件名 (test-results/{name}.md)
  provider: openai              # gemini | anthropic | openai | custom
  api_key: ${OPENAI_API_KEY}    # 支持环境变量
  base_url: https://api.openai.com/v1
  model_id: gpt-4o              # API 请求用的 model 字段
  params:
    temperature: 0.3
    max_tokens: 8192

retry:
  max_attempts: 3
  delay: 10
```

## Provider 类型

| Provider | URL 处理 | 适用场景 |
|----------|---------|---------|
| `openai` | 自动补 `/chat/completions` | OpenAI/DeepSeek/Qwen/智谱等 |
| `anthropic` | `/v1/messages` | Claude |
| `gemini` | `/v1beta/models/{model}:generateContent` | Google Gemini |
| `custom` | 不拼接，使用完整 URL | Ollama Cloud 等 |

## CLI 参数

```bash
python cli.py [options]

必选:
  --scope, -s     测试范围: math, code, logic, comp 或 math/base-test

可选:
  --config, -c    配置文件路径 (默认: config.yaml)
  --range, -r     题号范围: 001-005 或 003
  --force, -f     强制重测 (忽略已有结果)
  --dry-run       仅显示将测试的题目
```

## 输出位置

测试结果保存在每个题目目录下：

```
数理能力基准测试题库/base-test/001-xxx/test-results/gpt-4o.md
```

## 目录结构

```
code-fish/
├── cli.py                  # CLI 入口
├── config.yaml             # 模型配置
├── config.yaml.example     # 配置示例
├── src/
│   ├── config.py           # 配置加载
│   ├── scope.py            # Scope 解析器
│   ├── runner.py           # 测试执行器
│   └── providers/          # LLM Provider
│       ├── openai.py       # OpenAI + custom
│       ├── anthropic.py    # Claude
│       └── gemini.py       # Gemini
└── data/
    └── question_banks.yaml # 题库路径配置
```

## 添加新 Provider

1. 在 `src/providers/` 创建新文件，继承 `BaseProvider`
2. 实现 `chat(prompt: str) -> str` 方法
3. 在 `src/providers/__init__.py` 注册
