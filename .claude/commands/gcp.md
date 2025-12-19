---
description: Git add, commit, push with CONTRIBUTING.md compliant message
argument-hint: [可选指令]
allowed-tools: Bash(git *:*)
---

# Git Commit & Push with Conventional Commits

你需要帮助用户完成一次符合项目 CONTRIBUTING.md 规范的 Git 提交和推送。

## 执行步骤

### 1. 分析变更（必须）

首先运行以下命令分析当前变更：

```bash
git status
git diff --staged
git diff
```

仔细分析输出以理解：
- 被修改、新增或删除的文件
- 更改的性质（新功能、bug 修复、重构等）
- 是否有破坏性更改

### 2. 确定 Commit 类型

根据分析结果，从以下类型中选择最合适的：

| Emoji | 类型 | 说明 |
|-------|------|------|
| 🎉 | `init` | 初始化 |
| ✨ | `feat` | 添加新功能 |
| 🐛 | `fix` | 修复 bug |
| 📝 | `docs` | 对文档进行修改 |
| ♻️ | `refactor` | 代码重构 |
| ⚡ | `perf` | 提高性能的代码修改 |
| 🎨 | `style` | 代码风格修改 |
| ✅ | `test` | 测试用例添加及修改 |
| 🔨 | `build` | 影响构建系统或外部依赖 |
| 🔨 | `chore` | 其它不涉及源码以及测试的修改 |
| ⬆️ | `deps` | 依赖项修改 |
| 🧑‍💻 | `dx` | 优化开发体验 |
| 👷 | `ci` | CI 配置文件和脚本更改 |

### 3. 编写 Commit Message

遵循以下格式和规则：

**格式：**
```
[emoji] [类型][(可选范围)]: [描述]

[可选正文]
```

**规则：**
- 主题行不超过 50 个字符
- 使用中文、祈使句和现在式
- 主题行结尾不加句号
- 描述应该能够完成句子："如果应用，这个提交将 [你的描述]"
- 如有破坏性更改，在类型后加感叹号（如 `feat!:`）

**示例：**
- `✨ feat: 添加用户登录功能`
- `🐛 fix(auth): 修复登录页面验证码显示问题`
- `📝 docs: 更新题目编写规范说明`
- `♻️ refactor(tests): 重构题目文件为目录结构`

### 4. 执行 Git 操作

按以下顺序执行：

1. **Add**：添加所有变更文件到暂存区
   ```bash
   git add .
   ```

2. **Commit**：使用生成的 message 创建提交
   ```bash
   git commit -m "你生成的 commit message"
   ```

3. **Push**：推送到远程仓库
   ```bash
   git push
   ```

### 5. 输出确认

完成后输出：
- 使用的 commit message
- 推送的分支名称
- 提交的 SHA 值

## 特殊情况处理

- 如果没有变更，提示用户无需提交
- 如果有未暂存的文件，询问用户是否全部添加
- 如果推送失败（如需要 pull），给出明确的下一步建议
- 如果变更涉及多个不相关的功能，建议分多次提交

## 参数说明

如果用户提供了参数（通过 `$ARGUMENTS`），将其作为额外指令执行。

例如：
- `/gcp 把改动拆成代码和测试两次提交` → 分析变更后拆分成两次独立提交
- `/gcp 只提交 src/ 下的文件` → 只 add 和 commit src/ 目录
