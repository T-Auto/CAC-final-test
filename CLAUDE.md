# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Commands

```bash
# Validate question format (runs automatically on pre-commit)
python scripts/validate_questions.py

# Run benchmark tests
cd code-fish
python cli.py --scope math              # Test all math questions
python cli.py --scope math/base-test    # Test math base level
python cli.py --scope logic --dry-run   # Preview questions to test

# Enable git hooks (validates commit messages and question formats)
git config core.hooksPath .githooks
```

## Environment Setup

```bash
# Root level (for validation scripts)
pip install pyyaml

# Evaluation system
cd code-fish
pip install -r requirements.txt

# Configure model (copy example and add API key)
cp config.yaml.example config.yaml
# Edit config.yaml with your API key
```

## Project Architecture

LLM/Agent benchmark suite with CLI-driven test runner.

### Evaluation System (`code-fish/`)
- `cli.py`: CLI entry point with rich help, scope/range/force options
- `src/config.py`: Config loading with `${ENV_VAR}` support
- `src/scope.py`: Resolves `math/base-test` to question paths
- `src/runner.py`: Executes tests with retry and incremental mode
- `src/judge.py`: Executes scoring with LLM-as-judge
- `src/reporting.py`: Event-driven output (PlainReporter/RichReporter)
- `src/providers/`: LLM providers (OpenAI, Anthropic, Gemini, Custom)

### Configuration
```yaml
# config.yaml
model:
  name: gpt-4o                  # Output filename
  provider: openai              # gemini | anthropic | openai | custom
  api_key: ${OPENAI_API_KEY}    # Environment variable
  base_url: https://api.openai.com/v1
  model_id: gpt-4o
  params:
    temperature: 0.3
    max_tokens: 8192
```

### Provider Types
| Provider | URL Handling | Use Case |
|----------|-------------|----------|
| `openai` | Auto-append `/chat/completions` | OpenAI/DeepSeek/Qwen |
| `anthropic` | `/v1/messages` | Claude |
| `gemini` | `/v1beta/models/{model}:generateContent` | Google Gemini |
| `custom` | Use URL as-is | Ollama Cloud etc. |

### Question Bank Structure
```
{Category}/                     # 代码/数理/自然语言与逻辑能力基准测试题库
└── {Difficulty}/               # base-test, advanced-test, final-test, final-test+
    └── NNN-problem-name/       # e.g., 001-chicken-rabbit-cage
        ├── meta.yaml           # ID, difficulty, scoring indicators
        ├── prompt.md           # Exact prompt for tested model
        ├── reference.md        # Answer/criteria for judge model
        ├── README.md           # Human documentation
        └── test-results/       # Output: {model-name}.md
```

### Scoring Indicator Categories
| Category | Indicators |
|----------|------------|
| code | `ans_correct`, `code_quality`, `efficiency`, `robustness` |
| theory | `completeness`, `accuracy`, `clarity`, `depth` |
| design | `ans_correct`, `example_quality`, `completeness`, `practicality` |
| easy | `correct_max_1` |

## Creating Questions

Use the `question-creator` skill (`.claude/skills/question-creator/`) for guided question creation.

**ID format**: `{category}-{difficulty}-{number}` (e.g., `math-base-001`, `code-final-003`)
- Categories: `math`, `code`, `logic`, `comp`
- Difficulties: `base`, `advanced`, `final`, `final+`

**Required files**: `meta.yaml`, `prompt.md`, `reference.md`

## Adding LLM Providers

1. Create file in `code-fish/src/providers/` inheriting `BaseProvider`
2. Implement `chat(prompt: str) -> str`
3. Register in `src/providers/__init__.py` PROVIDER_REGISTRY

## Commit Messages

Follow Conventional Commits with Chinese + emoji: `[emoji][type](scope): description`

Common types: `✨ feat`, `🐛 fix`, `📝 docs`, `♻️ refactor`, `✅ test`, `🧹 chore`, `🛠️ ci`
