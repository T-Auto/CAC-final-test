# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Commands

```bash
# Validate question format (runs automatically on pre-commit)
python scripts/validate_questions.py

# Run benchmark evaluation
cd code-fish && python main.py

# Enable git hooks (validates commit messages and question formats)
git config core.hooksPath .githooks
```

## Environment Setup

```bash
# Root level (for validation scripts)
pip install pyyaml

# Evaluation system
cd code-fish
python -m venv .venv
.venv\Scripts\Activate.ps1  # Windows PowerShell
pip install -r requirements.txt

# Configure models (copy examples and add API keys)
cp providers/test.yaml.example providers/test.yaml
cp providers/judge.yaml.example providers/judge.yaml
```

## Project Architecture

LLM/Agent benchmark suite with automated evaluation. Two-phase flow:
1. **Ask**: Send prompts to tested models, collect responses
2. **Judge**: Use judge model (e.g., Claude) to score responses against reference answers

### Evaluation System (`code-fish/`)
- `main.py`: Orchestrates test → judge pipeline
- `src/ask.py`: Sends prompts to tested models with retry logic
- `src/judge.py`: Builds judge prompts, parses scoring YAML, calculates final_score
- `src/question_loader.py`: Scans question banks, loads meta.yaml/prompt.md/reference.md
- `src/adaptors/`: LLM API adapters (OpenAI, Anthropic, Doubao) inheriting `BaseLLMAdaptor`

### Configuration Files
- `providers/test.yaml`: Tested models (copy from `.example`)
- `providers/judge.yaml`: Judge model config
- `data/question_banks.yaml`: Question bank paths (math, code, logic, comprehensive)
- `data/indicators.yaml`: Scoring indicator definitions

### Question Bank Structure
```
{Category}/                     # 代码/数理/自然语言与逻辑能力基准测试题库
└── {Difficulty}/               # base-test, advanced-test, final-test, final-test+
    └── NNN-problem-name/       # e.g., 001-chicken-rabbit-cage
        ├── meta.yaml           # ID, difficulty, scoring indicators
        ├── prompt.md           # Exact prompt for tested model
        ├── reference.md        # Answer/criteria for judge model
        ├── README.md           # Human documentation
        └── test-results/       # Historical results (model-name.md)
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

1. Create adapter in `code-fish/src/adaptors/` inheriting `BaseLLMAdaptor`
2. Implement `chat(prompt, system_prompt=None, **kwargs) -> str`
3. Register in `src/adaptors/__init__.py` ADAPTOR_REGISTRY

## Commit Messages

Follow Conventional Commits with Chinese + emoji: `[emoji][type](scope): description`

Common types: `✨ feat`, `🐛 fix`, `📝 docs`, `♻️ refactor`, `✅ test`, `🧹 chore`, `🛠️ ci`
