# WARP.md

此文件为 WARP (warp.dev) 在此仓库中工作时提供指导。

## 项目概述

这是一个 AI 模型性能竞技场项目 (AI-Arena),用于测试和比较不同自然语言模型在复杂任务上的表现。

## 代码架构

### 目录结构
- **根目录**: 包含项目说明文件 (README.md)
- **Stealth Fighter RCS Simulation and Genetic Algorithm Optimization/**: 主要测试用例目录
  - `Prompt.md`: 测试任务的原始提示词
  - 各个模型的子目录 (如 `Claude-3.7/`, `Gemini-2.5-pro/`, `GPT-4o/` 等): 存放不同 AI 模型生成的 MATLAB 代码实现

### 技术栈
- **语言**: MATLAB
- **应用领域**: 物理学仿真、机器学习、遗传算法优化

## 测试用例结构

### 测试一:物理学仿真/机器学习综合命题
**任务**: 创建隐身战斗机 RCS (雷达反射截面) 仿真和遗传算法优化程序

**要求**:
1. 使用数学函数对隐身战斗机进行建模
2. 仿真计算各个方向的 RCS
3. 使用遗传算法优化隐身战斗机设计以减少 RCS
4. 三维建模可视化
5. 结论可视化作图

**评分等级**: A (最高) - D (最低)
- A级: Gemini-2.5pro
- B级: Claude-3.7, GPT-o3, DeepSeek-v3-0324
- C级: Gemini-2.5-flash(thinking), GPT-4o
- D级: DeepSeek-R1, GPT-o4-mini

## 查看测试结果

### 查看特定模型的实现
```powershell
# 列出所有模型的实现
Get-ChildItem "X:\Toys\CAC-final-test\Stealth Fighter RCS Simulation and Genetic Algorithm Optimization" -Directory

# 查看特定模型的文件
Get-ChildItem "X:\Toys\CAC-final-test\Stealth Fighter RCS Simulation and Genetic Algorithm Optimization\Claude-3.7" -Recurse
```

### 运行 MATLAB 代码
```powershell
# 需要先打开 MATLAB
matlab -r "cd 'X:\Toys\CAC-final-test\Stealth Fighter RCS Simulation and Genetic Algorithm Optimization\Claude-3.7'; main"
```

## 代码实现要点

### 典型实现模式
各个模型的 MATLAB 实现通常包括:
1. **几何建模函数**: 创建参数化的飞机模型
2. **RCS 计算函数**: 使用简化物理光学模型或面元法计算雷达截面
3. **可视化函数**: 3D 模型展示和 RCS 方向图
4. **遗传算法优化**: 使用 MATLAB Global Optimization Toolbox 优化设计参数

### 关键 MATLAB 依赖
- MATLAB R2016b+ (推荐)
- Global Optimization Toolbox (遗传算法)
- 基础绘图功能 (surf, patch, plot3 等)

## 添加新的测试用例

在根目录或创建新的测试子目录时,应遵循以下结构:
1. 创建测试目录 (以测试名称命名)
2. 添加 `Prompt.md` 包含测试提示词
3. 为每个测试模型创建子目录
4. 在 README.md 中更新评分结果

## Windows 环境特殊说明

此项目在 Windows 环境下运行,文件路径使用反斜杠。在编写 MATLAB 代码时注意路径兼容性。
