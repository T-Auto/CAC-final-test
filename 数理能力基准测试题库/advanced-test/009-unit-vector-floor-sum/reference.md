# 标准答案

$\{1\} \cup (\sqrt{5}, 1+\sqrt{2}]$

# 解题过程

**第一步：分析约束条件**

设 $\vec{a} \cdot \vec{b} = \cos\theta$，$\vec{a} \cdot \vec{c} = \cos\varphi$，$\vec{b} \cdot \vec{c} = \cos\psi$

由于 $\lfloor \vec{a} \cdot \vec{c} \rfloor + \lfloor \vec{b} \cdot \vec{c} \rfloor$ 为整数，而 $\cos\theta \in [-1, 1]$

故 $\cos\theta \in \{-1, 0, 1\}$，即 $\theta \in \{0, \frac{\pi}{2}, \pi\}$

**第二步：排除 $\theta = 0$**

若 $\theta = 0$，则 $\vec{a} = \vec{b}$，$\cos\theta = 1$

需 $\lfloor \cos\varphi \rfloor + \lfloor \cos\varphi \rfloor = 1$，即 $2\lfloor \cos\varphi \rfloor = 1$

这要求 $\lfloor \cos\varphi \rfloor = 0.5$，矛盾。故 $\theta = 0$ 无解。

**第三步：情形一 $\theta = \pi$**

此时 $\vec{b} = -\vec{a}$，$\cos\theta = -1$

需 $\lfloor \cos\varphi \rfloor + \lfloor -\cos\varphi \rfloor = -1$

当 $\cos\varphi \in (-1, 0) \cup (0, 1)$ 时成立

此时 $\vec{a} + \vec{b} = \vec{0}$，故 $|\vec{a} + \vec{b} + \vec{c}| = |\vec{c}| = 1$

**第四步：情形二 $\theta = \frac{\pi}{2}$**

设 $\vec{a} = (1, 0)$，$\vec{b} = (0, 1)$，$\vec{c} = (\cos\alpha, \sin\alpha)$

条件变为 $\lfloor \cos\alpha \rfloor + \lfloor \sin\alpha \rfloor = 0$

需 $\cos\alpha \in [0, 1)$ 且 $\sin\alpha \in [0, 1)$，即 $\alpha \in (0, \frac{\pi}{2})$

计算：
$$|\vec{a} + \vec{b} + \vec{c}|^2 = 3 + 2(\cos\alpha + \sin\alpha)$$

设 $t = \cos\alpha + \sin\alpha = \sqrt{2}\sin(\alpha + \frac{\pi}{4})$

当 $\alpha \in (0, \frac{\pi}{2})$ 时，$t \in (1, \sqrt{2}]$

故 $|\vec{a} + \vec{b} + \vec{c}|^2 \in (5, 3 + 2\sqrt{2}]$

即 $|\vec{a} + \vec{b} + \vec{c}| \in (\sqrt{5}, \sqrt{3 + 2\sqrt{2}}] = (\sqrt{5}, 1 + \sqrt{2}]$

**第五步：综合结论**

$|\vec{a} + \vec{b} + \vec{c}|$ 的取值范围为 $\{1\} \cup (\sqrt{5}, 1+\sqrt{2}]$

# 评判要点

1. **答案正确性 (40%)**
   - 答案必须为 $\{1\} \cup (\sqrt{5}, 1+\sqrt{2}]$

2. **解题过程完整性 (40%)**
   - 正确分析 $\cos\theta$ 必须为整数
   - 完整的分类讨论
   - 正确求解各情形下的取值范围

3. **方法深度 (20%)**
   - 取整函数性质运用正确
   - 向量模计算严谨
   - 参数范围分析准确
