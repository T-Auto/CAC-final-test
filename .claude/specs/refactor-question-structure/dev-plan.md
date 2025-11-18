# 题目文件结构重构开发计划

## 功能概述

将所有符合 `0XX-*.md` 的题目文件重构为以题号命名的目录，内容迁移至 `README.md` 并为 `test-results` 预置 `.gitkeep`。

## 任务列表

### T1：路径发现与冲突检测

**任务描述**：列出所有 `0XX-*.md` 文件；检查同名目录是否已存在

**涉及文件/目录**：项目根及所有子目录

**依赖**：无

**测试命令**：
```bash
# 验证发现的文件数量和路径
find . -type f -name "0*-*.md" | wc -l
# 检查是否有冲突的目录
for file in $(find . -type f -name "0*-*.md"); do
  dirname=$(dirname "$file")
  basename=$(basename "$file" .md)
  if [ -d "$dirname/$basename" ]; then
    echo "冲突: $dirname/$basename 已存在"
  fi
done
```

**测试重点**：
- 清单包含所有 12+ 个已知题目文件
- 准确检测同名目录冲突
- 输出清晰的冲突报告

---

### T2：内容迁移与目录重构

**任务描述**：为每个文件创建 `<题号名>/README.md` 并搬移原内容

**涉及文件/目录**：所有匹配的题目文件所在目录

**依赖**：T1（确认无冲突或处理策略）

**测试命令**：
```bash
# 验证迁移后的文件内容一致性
for file in $(find . -type f -name "0*-*.md"); do
  dirname=$(dirname "$file")
  basename=$(basename "$file" .md)
  new_file="$dirname/$basename/README.md"
  if [ -f "$new_file" ]; then
    diff "$file" "$new_file" || echo "内容不一致: $file"
  fi
done
```

**测试重点**：
- 每个源文件内容与新 `README.md` 完全一致
- 保持原始编码与 front matter 不变
- 原 `.md` 文件已删除或移动

---

### T3：test-results 预置

**任务描述**：在每个新目录下创建 `test-results/.gitkeep`

**涉及文件/目录**：T2 生成的所有题目目录

**依赖**：T2

**测试命令**：
```bash
# 验证每个题目目录下都有 test-results/.gitkeep
for dir in $(find . -type d -name "0*-*" | grep -E "(base-test|advanced-test|final-test)"); do
  if [ ! -f "$dir/test-results/.gitkeep" ]; then
    echo "缺少 .gitkeep: $dir"
  fi
done
```

**测试重点**：
- 每个题目目录下存在 `test-results/.gitkeep`
- `.gitkeep` 文件可读且为空文件
- 目录结构符合预期

---

### T4：收尾校验

**任务描述**：核对重构后的目录树与规格一致，确认未触及引用

**涉及文件/目录**：全项目

**依赖**：T2, T3

**测试命令**：
```bash
# 检查目录结构
tree -L 3 代码能力基准测试题库/ 数理能力基准测试题库/ 自然语言与逻辑能力基准测试题库/
# 验证没有残留的 0XX-*.md 文件
find . -type f -name "0*-*.md" | grep -E "(base-test|advanced-test|final-test)"
# 检查 git diff 仅包含结构变更
git status --short
```

**测试重点**：
- 目录命名与要求一致
- 没有残留的原始 `.md` 文件
- Git diff 仅包含结构变更与 `.gitkeep`
- 未修改其他引用文件

---

## 验收标准

1. ✅ 所有 `0XX-*.md` 文件已转换为目录结构
2. ✅ 每个目录包含 `README.md`（原内容）和 `test-results/.gitkeep`
3. ✅ 文件内容与原始文件完全一致
4. ✅ 没有路径引用被自动修改
5. ✅ 没有同名目录冲突

## 覆盖率要求

≥90%（此项目为文件迁移，覆盖率指：成功迁移的文件数 / 总文件数）

## 执行策略

1. 先执行 T1 检测冲突
2. 如无冲突，创建迁移脚本批量执行 T2 和 T3
3. 最后执行 T4 验证

## 注意事项

- 若遇到已有同名目录，需先确认处理策略（覆盖/跳过/合并）
- 保持原文件的编码格式和换行符
- Windows 路径长度限制需注意
