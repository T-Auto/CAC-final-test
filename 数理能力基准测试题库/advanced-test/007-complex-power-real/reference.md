# 标准答案

$18$

# 解题过程

设 $z = \dfrac{\sin 20^\circ}{\cos 25^\circ} + \dfrac{\sin 25^\circ}{\cos 20^\circ} i$，实部虚部均为正，$z$ 在第一象限。

**第一步：计算辐角**

$$\tan\theta = \dfrac{\dfrac{\sin 25^\circ}{\cos 20^\circ}}{\dfrac{\sin 20^\circ}{\cos 25^\circ}} = \dfrac{\sin 25^\circ \cos 25^\circ}{\sin 20^\circ \cos 20^\circ}$$

利用 $\sin\alpha\cos\alpha = \dfrac{1}{2}\sin 2\alpha$：

$$\tan\theta = \dfrac{\frac{1}{2}\sin 50^\circ}{\frac{1}{2}\sin 40^\circ} = \dfrac{\sin 50^\circ}{\sin 40^\circ}$$

由 $\sin 40^\circ = \cos 50^\circ$：

$$\tan\theta = \dfrac{\sin 50^\circ}{\cos 50^\circ} = \tan 50^\circ$$

故 $\theta = 50^\circ = \dfrac{5\pi}{18}$

**第二步：确定 k 的条件**

$z^k \in \mathbb{R}$ 当且仅当 $k\theta \equiv 0 \pmod{\pi}$

即 $k \cdot \dfrac{5\pi}{18} = m\pi$（$m$ 为整数）

化简得 $\dfrac{5k}{18} = m$，即 $5k = 18m$

由 $\gcd(5, 18) = 1$，需 $18 \mid k$

**第三步：求最小值**

最小正整数 $k = 18$

# 评判要点

1. **答案正确性 (40%)**
   - 答案必须为 $18$

2. **解题过程完整性 (40%)**
   - 正确计算复数的辐角
   - 正确应用三角恒等变换
   - 正确分析整除条件

3. **方法深度 (20%)**
   - 理解复数幂次为实数的几何意义
   - 三角变换技巧熟练
   - 数论分析严谨
