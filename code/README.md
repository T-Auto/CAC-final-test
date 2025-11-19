# CAC 评测系统

一个用于自动化评测大语言模型（LLM）能力的 Python 程序。

## 快速开始

### 1. 环境准备

```bash
# 创建虚拟环境
python -m venv .venv

# 激活虚拟环境
.\.venv\Scripts\Activate.ps1

# 安装依赖
pip install -r requirements.txt
```

### 2. 配置

#### 2.1 配置模型提供商

复制配置示例文件：

将 `providers/test.yaml.example` 复制为 `providers/test.yaml`，并填写被测模型的 API 信息：

```yaml
test:
  - 
    provider: openai
    api_key: sk-xxx
    base_url: https://api.xxx.com/v1
    model_name: gpt-4o-mini
  -
    provider: openai
    api_key: sk-xxx
    base_url: https://api.xxx.com/v1
    model_name: deepseek-v3
    
retry:
  max_attempts: 3
  delay: 10.0
```

将 `providers/judge.yaml.example` 复制为 `providers/judge.yaml`，并填写评判模型的 API 信息：

```yaml
judge:
  provider: anthropic
  api_key: sk-xxx
  base_url: https://api.xxx.com/v1
  model_name: claude-4-5-sonnet
```

添加新的 LLM 提供商的流程：

1. 在 `src/adaptors/` 下创建新的适配器文件（如 `new_provider.py`）
2. 继承 `BaseLLMAdaptor` 类并实现必要的方法
3. 在 `src/adaptors/__init__.py` 中注册新适配器
4. 在配置文件中使用新提供商


#### 2.2 配置题库信息

1. 在 `data\indicators.yaml` 中配置评分指标信息，格式为：

```yaml
- category_id: code
  indicators:
    ans_correct: "答案正确性 - 代码能否正确运行并得到预期结果"
    code_quality: "代码质量 - 代码风格、注释、可读性"
    efficiency: "运行效率 - 算法时间和空间复杂度"
    robustness: "鲁棒性 - 异常处理和边界情况考虑"
- category_id: theory
  indicators:
    completeness: "回答完整性 - 是否涵盖问题的所有方面"
    accuracy: "准确性 - 概念和信息是否准确无误"
    clarity: "表达清晰度 - 逻辑是否清晰、表述是否易懂"
    depth: "深度 - 回答是否有深度和见解"
# ...
```

2. 在 `data\questions.yaml` 中配置题目元数据（不再保存题干与标准答案文本），格式为：

```yaml
- id: "题目id，使用英文、数字、短横杠、下划线"
  question_brief: "题目简介"
  scoring_std:
    max_score: 10  # 满分
    indicators:    # 本题使用的评分指标
      - "correct_max_1"
      - "code_quality"
# ...
```

3. 将题目的原始 Markdown 文件放置于以下路径（以题目 id 为目录名）：

```
data/questions/<id>/question.md   # 题目正文（Markdown）
data/questions/<id>/answer.md     # 标准答案（Markdown）
```

程序会在运行时自动读取上述 Markdown，并用于构建提问/评判的 prompt。

#### 2.3 配置基础prompt（可选）

在 `prompts/question.md` 中配置提问模板的提示词，在 `prompts/judge.md` 中配置评判模板的提示词。

注意：**占位符不要修改**

### 3. 运行评测

```bash
python ./main.py
```

### 查看结果

评测完成后，结果保存在 `results/` 目录：

- `results/YYYYMMDD_HHMMSS.yaml` - 汇总结果（YAML）
- `results/raw/test/` - 模型原始答案
- `results/raw/judge/` - 评判详细结果（YAML）

日志文件保存在 `logs/` 目录。
