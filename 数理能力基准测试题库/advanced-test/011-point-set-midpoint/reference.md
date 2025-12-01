# 标准答案

$M = \left(\dfrac{1}{2}, \sqrt{2}\right)$ 或 $M = \left(\dfrac{1}{2}, -\sqrt{2}\right)$

# 解题过程

**第一步：化简点集 $\Gamma$**

当 $x < 0$ 时，$|x| = -x$，则 $y^2 = 2x + 2(-x) = 0$，故 $y = 0$

当 $x \ge 0$ 时，$|x| = x$，则 $y^2 = 2x + 2x = 4x$

因此 $\Gamma = A \cup B$，其中：
- $A = \{(x, 0) \mid x \le 0\}$（负半轴及原点）
- $B = \{(x, y) \mid y^2 = 4x, x \ge 0\}$（抛物线）

**第二步：分类讨论**

设 $P(x_1, y_1), Q(x_2, y_2) \in \Gamma$，$M$ 为 $PQ$ 中点

**情况一：$P, Q$ 都在 $A$ 上**

则 $y_1 = y_2 = 0$，$\overrightarrow{OP} \cdot \overrightarrow{OQ} = x_1 x_2 = -2$

但 $x_1, x_2 \le 0$，故 $x_1 x_2 \ge 0$，矛盾。不可能。

**情况二：$P, Q$ 都在 $B$ 上**

设 $P(\frac{y_1^2}{4}, y_1), Q(\frac{y_2^2}{4}, y_2)$

$M$ 在 $\Gamma$ 上要求 $Y^2 = 4X$，代入化简得 $(y_1 - y_2)^2 = 0$

故 $y_1 = y_2$，则 $P = Q$，与三点互异矛盾。不可能。

**情况三：一点在 $A$，一点在 $B$**

设 $P = (a, 0), a \le 0$；$Q = (\frac{c^2}{4}, c), c \neq 0$

由 $\overrightarrow{OP} \cdot \overrightarrow{OQ} = -2$：$a \cdot \frac{c^2}{4} = -2 \Rightarrow a = -\frac{8}{c^2}$ ...(1)

$M = \left(\frac{a + \frac{c^2}{4}}{2}, \frac{c}{2}\right)$，由 $M \in B$：$Y^2 = 4X$

代入得 $a = -\frac{c^2}{8}$ ...(2)

联立 (1)(2)：$-\frac{c^2}{8} = -\frac{8}{c^2} \Rightarrow c^4 = 64 \Rightarrow c^2 = 8$

故 $a = -1$，$P = (-1, 0)$，$Q = (2, \pm 2\sqrt{2})$

$M = \left(\frac{1}{2}, \pm\sqrt{2}\right)$

**第三步：验证**

$M(\frac{1}{2}, \sqrt{2})$：$y^2 = 2$，$2x + 2|x| = 2$，满足 $\Gamma$

# 评判要点

1. **答案正确性 (40%)**
   - 答案必须为 $(\frac{1}{2}, \sqrt{2})$ 或 $(\frac{1}{2}, -\sqrt{2})$

2. **解题过程完整性 (40%)**
   - 正确化简点集
   - 完整的分类讨论
   - 正确求解方程

3. **方法深度 (20%)**
   - 分类讨论逻辑清晰
   - 验证过程完整
