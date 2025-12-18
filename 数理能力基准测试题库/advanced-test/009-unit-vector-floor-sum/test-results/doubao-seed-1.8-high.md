### 解题过程


#### 步骤1：分析点积与取整函数的性质
设三个单位向量 $\vec{a}, \vec{b}, \vec{c}$，对于任意两个单位向量的点积 $\vec{u} \cdot \vec{v} = \cos\theta \in [-1, 1]$（$\theta$ 为两向量夹角）。取整函数 $\lfloor x \rfloor$ 对 $x \in [-1, 1]$ 的可能取值为：
- 当 $x \in [-1, 0)$ 时，$\lfloor x \rfloor = -1$；
- 当 $x \in [0, 1)$ 时，$\lfloor x \rfloor = 0$；
- 当 $x = 1$ 时，$\lfloor x \rfloor = 1$。

设 $x = \vec{a} \cdot \vec{c}$，$y = \vec{b} \cdot \vec{c}$，题目条件为 $\vec{a} \cdot \vec{b} = \lfloor x \rfloor + \lfloor y \rfloor$。由于 $\lfloor x \rfloor$ 和 $\lfloor y \rfloor$ 均为整数，记 $m = \lfloor x \rfloor$，$n = \lfloor y \rfloor$，则 $m + n$ 的可能取值为 $-2, -1, 0, 1, 2$。但 $\vec{a} \cdot \vec{b} \in [-1, 1]$，故 $m + n \in \{-1, 0, 1\}$。


#### 步骤2：排除不可能的情况
- **情况 $m + n = 1$**：此时 $\vec{a} \cdot \vec{b} = 1$，说明 $\vec{a} = \vec{b}$（单位向量点积为1时同向）。此时 $x = \vec{a} \cdot \vec{c} = \vec{b} \cdot \vec{c} = y$，故 $\lfloor x \rfloor + \lfloor x \rfloor = 2\lfloor x \rfloor = 1$，$\lfloor x \rfloor = 0.5$（非整数，矛盾），因此该情况不存在。
- **情况 $m + n = -2$**：此时 $\vec{a} \cdot \vec{b} = -2$，但 $\vec{a} \cdot \vec{b} \geq -1$，不可能，排除。
- **情况 $m + n = 2$**：此时 $\vec{a} \cdot \vec{b} = 2$，但 $\vec{a} \cdot \vec{b} \leq 1$，不可能，排除。

因此仅需考虑 $m + n = -1$ 和 $m + n = 0$ 两种情况。


### 情况A：$m + n = -1$（即 $\vec{a} \cdot \vec{b} = -1$）
$\vec{a} \cdot \vec{b} = -1$ 说明 $\vec{a} = -\vec{b}$（单位向量点积为-1时反向）。此时 $y = \vec{b} \cdot \vec{c} = -\vec{a} \cdot \vec{c} = -x$，条件变为：
$$\lfloor x \rfloor + \lfloor -x \rfloor = -1.$$
当 $x \in (-1, 0) \cup (0, 1)$ 时，$\lfloor x \rfloor + \lfloor -x \rfloor = -1$（例如 $x \in (0,1)$ 时，$\lfloor x \rfloor = 0$，$\lfloor -x \rfloor = -1$，和为-1）。此时 $\vec{a} + \vec{b} = \vec{0}$，故：
$$|\vec{a} + \vec{b} + \vec{c}| = |\vec{0} + \vec{c}| = |\vec{c}| = 1,$$
因为 $\vec{c}$ 是单位向量，模长恒为1。


### 情况B：$m + n = 0$（即 $\vec{a} \cdot \vec{b} = 0$）
$\vec{a} \cdot \vec{b} = 0$ 说明 $\vec{a}$ 与 $\vec{b}$ 垂直（正交单位向量）。此时 $m + n = 0$ 的可能组合为：
1.  $\lfloor x \rfloor = 1, \lfloor y \rfloor = -1$：$\lfloor x \rfloor = 1$ 意味着 $x = 1$（因 $x \leq 1$），即 $\vec{c} = \vec{a}$，此时 $y = \vec{b} \cdot \vec{c} = \vec{b} \cdot \vec{a} = 0$，$\lfloor y \rfloor = 0 \neq -1$，矛盾，排除。
2.  $\lfloor x \rfloor = -1, \lfloor y \rfloor = 1$：同理，$\lfloor y \rfloor = 1$ 意味着 $\vec{c} = \vec{b}$，此时 $x = \vec{a} \cdot \vec{c} = 0$，$\lfloor x \rfloor = 0 \neq -1$，矛盾，排除。
3.  $\lfloor x \rfloor = 0, \lfloor y \rfloor = 0$：即 $x = \vec{a} \cdot \vec{c} \in [0, 1)$，$y = \vec{b} \cdot \vec{c} \in [0, 1)$。

由于 $\vec{a}, \vec{b}$ 是平面正交单位向量，$\vec{c}$ 可表示为 $\vec{c} = x\vec{a} + y\vec{b}$，且 $|\vec{c}| = 1$，故 $x^2 + y^2 = 1$（单位向量模长平方为1）。此时：
$$|\vec{a} + \vec{b} + \vec{c}|^2 = (\vec{a} + \vec{b} + \vec{c}) \cdot (\vec{a} + \vec{b} + \vec{c}) = |\vec{a}|^2 + |\vec{b}|^2 + |\vec{c}|^2 + 2\vec{a} \cdot \vec{b} + 2\vec{a} \cdot \vec{c} + 2\vec{b} \cdot \vec{c}.$$
代入 $|\vec{a}| = |\vec{b}| = |\vec{c}| = 1$，$\vec{a} \cdot \vec{b} = 0$，得：
$$|\vec{a} + \vec{b} + \vec{c}|^2 = 3 + 2(x + y).$$

#### 求 $x + y$ 的范围
由 $x^2 + y^2 = 1$ 且 $x \in [0, 1), y \in [0, 1)$，利用三角代换 $x = \cos\theta, y = \sin\theta$（$\theta \in (0, \frac{\pi}{2})$，排除 $\theta = 0$ 和 $\theta = \frac{\pi}{2}$，因 $x=1$ 或 $y=1$ 时 $\lfloor x \rfloor=1$ 或 $\lfloor y \rfloor=1$，不符合条件），则：
$$x + y = \cos\theta + \sin\theta = \sqrt{2}\sin\left(\theta + \frac{\pi}{4}\right).$$
$\theta \in (0, \frac{\pi}{2})$ 时，$\theta + \frac{\pi}{4} \in (\frac{\pi}{4}, \frac{3\pi}{4})$，故 $\sin\left(\theta + \frac{\pi}{4}\right) \in (\frac{\sqrt{2}}{2}, 1]$，因此：
$$x + y \in (1, \sqrt{2}].$$

代入模长公式得：
$$|\vec{a} + \vec{b} + \vec{c}|^2 \in (3 + 2 \cdot 1, 3 + 2\sqrt{2}] = (5, (1+\sqrt{2})^2],$$
即：
$$|\vec{a} + \vec{b} + \vec{c}| \in (\sqrt{5}, 1+\sqrt{2}].$$


### 最终取值范围
综合两种情况，$|\vec{a} + \vec{b} + \vec{c}|$ 的取值范围为 $\{1\} \cup (\sqrt{5}, 1+\sqrt{2}]$。


**答案：$\boxed{\{1\} \cup (\sqrt{5}, 1+\sqrt{2}]}$**（或等价表示为 $\boxed{[1,1] \cup (\sqrt{5}, 1+\sqrt{2}]}$）。