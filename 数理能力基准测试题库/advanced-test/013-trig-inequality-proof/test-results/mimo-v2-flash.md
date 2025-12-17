我们要证明如下不等式：

> 设 $\alpha$ 为实数，$m, n$ 为正整数，且 $\sin m\alpha \cdot \sin n\alpha \neq 0$。证明：
$$
\frac{1}{|\sin m\alpha|} + \frac{1}{|\sin n\alpha|} > \frac{1}{m \cdot |\sin m\alpha \cdot \sin n\alpha| + |\sin mn\alpha|}
$$

---

### 第一步：理解结构

记：
- $A = |\sin m\alpha|$
- $B = |\sin n\alpha|$
- $C = |\sin mn\alpha|$

则不等式变为：
$$
\frac{1}{A} + \frac{1}{B} > \frac{1}{mAB + C}
$$

由于 $A, B > 0$（由题设 $\sin m\alpha \cdot \sin n\alpha \ne 0$），我们可以两边同乘正数 $(A)(B)(mAB + C)$，得到等价形式：

$$
\left( \frac{1}{A} + \frac{1}{B} \right)(mAB + C) > 1
$$

计算左边：
$$
\left( \frac{1}{A} + \frac{1}{B} \right)(mAB + C) = \left( \frac{B + A}{AB} \right)(mAB + C) = (A + B)\left(m + \frac{C}{AB} \right)
$$

所以不等式等价于：
$$
(A + B)\left(m + \frac{C}{AB} \right) > 1
$$

即：
$$
(A + B)\left(m + \frac{|\sin mn\alpha|}{|\sin m\alpha||\sin n\alpha|} \right) > 1 \tag{1}
$$

---

### 第二步：利用三角恒等式估计 $|\sin mn\alpha|$

我们考虑使用三角恒等式来联系 $\sin mn\alpha$ 与 $\sin m\alpha$, $\sin n\alpha$。

一个经典恒等式是：
$$
\sin mn\alpha = \sin(n \cdot m\alpha) = \text{Im}(e^{i m n \alpha}) = \text{Im}((e^{i m \alpha})^n)
$$

但这对直接估计帮助不大。

另一个思路：使用**积化和差**或**正弦的倍角公式**，但更有效的是使用如下不等式（来自三角函数的基本性质）：

> 对任意实数 $x$，有 $|\sin x| \leq |x|$，但这对周期函数帮助有限。

但注意到：**正弦函数的绝对值不超过 1**，即 $|\sin \theta| \leq 1$，所以：
- $A \leq 1$, $B \leq 1$, $C \leq 1$

但这对下界估计帮助不大，因为我们要证明左边大于 1，而 $A, B$ 可能很小，使得 $1/A + 1/B$ 很大，所以不等式很可能成立。

但我们需要**严格证明**，不能依赖“很大”这种直觉。

---

### 第三步：考虑反证法或构造最小值

考虑函数：
$$
f(\alpha) = \frac{1}{|\sin m\alpha|} + \frac{1}{|\sin n\alpha|} - \frac{1}{m |\sin m\alpha \sin n\alpha| + |\sin mn\alpha|}
$$

我们要证明 $f(\alpha) > 0$ 对所有满足 $\sin m\alpha \sin n\alpha \ne 0$ 的实数 $\alpha$ 成立。

由于三角函数是周期函数，我们可以只考虑 $\alpha \in (0, \pi)$，因为 $\sin k\alpha$ 的周期为 $2\pi/k$，但整体周期为 $2\pi$（因为 $m,n$ 是整数），所以只需考虑 $\alpha \in (0, \pi)$，且避开使 $\sin m\alpha = 0$ 或 $\sin n\alpha = 0$ 的点。

关键观察：**分母中的 $m |\sin m\alpha \sin n\alpha| + |\sin mn\alpha|$ 是一个正数**，所以右边是正数。

我们尝试用**不等式放缩**来证明。

---

### 第四步：使用基本不等式

我们回到等价形式：
$$
\left( \frac{1}{A} + \frac{1}{B} \right)(mAB + C) > 1
$$

展开左边：
$$
\left( \frac{1}{A} + \frac{1}{B} \right)(mAB + C) = mB + mA + \frac{C}{A} + \frac{C}{B}
$$

所以不等式等价于：
$$
m(A + B) + C\left( \frac{1}{A} + \frac{1}{B} \right) > 1 \tag{2}
$$

现在注意：$A, B \in (0, 1]$，$C \in [0,1]$，$m \geq 1$ 是正整数。

我们考虑最坏情况——左边最小的时候。由于我们要证明左边恒大于 1，只需证明其**最小值 > 1**。

但注意：当 $A, B \to 0^+$ 时，$1/A + 1/B \to \infty$，所以左边趋于无穷大，肯定大于 1。

而当 $A, B$ 接近 1 时，比如 $A = B = 1$，此时 $C = |\sin mn\alpha|$，可能为 0（例如 $\alpha = \pi/(2mn)$ 时，$\sin mn\alpha = 1$，但若 $\alpha = \pi/(mn)$，则 $\sin mn\alpha = 0$）。但题设只排除了 $\sin m\alpha \sin n\alpha = 0$，**允许 $\sin mn\alpha = 0$**。

所以最“危险”的情况是：$A, B$ 较大（接近 1），而 $C$ 较小（甚至为 0），此时左边可能接近 $m(A + B)$，而 $m \geq 1$，$A + B \geq 2 \cdot \text{something}$。

但注意：若 $A = B = 1$，则 $m(A + B) = 2m \geq 2 > 1$，所以 (2) 成立。

但若 $A = B = \epsilon$ 很小，则 $C\left( \frac{1}{A} + \frac{1}{B} \right) \approx C \cdot \frac{2}{\epsilon}$，而 $C \leq 1$，所以这一项至少为 $2/\epsilon$，远大于 1。

所以似乎无论如何左边都大于 1。

但我们需要**严格证明**，不能依赖分情况讨论。

---

### 第五步：使用三角恒等式估计 $|\sin mn\alpha|$

我们尝试用如下恒等式（来自三角函数的乘积公式）：

$$
\sin mn\alpha = \sin(n \cdot m\alpha) = \sum_{k=0}^{\lfloor (n-1)/2 \rfloor} (-1)^k \binom{n}{2k+1} \cos^{n - (2k+1)}(m\alpha) \sin^{2k+1}(m\alpha)
$$

但这太复杂。

另一个思路：使用**正弦的倍角不等式**：

> 对任意整数 $k \geq 1$ 和实数 $x$，有：
$$
|\sin kx| \geq \frac{2}{\pi} \cdot k \cdot |\sin x| \quad \text{当 } |x| \leq \frac{\pi}{2}
$$

但这个不等式只在某些区间成立，且方向可能不对。

实际上，有一个经典不等式（来自调和分析）：

> 对任意实数 $x$ 和正整数 $k$，有：
$$
|\sin kx| \leq k |\sin x|
$$

这是对的，因为 $\sin kx$ 可以表示为 $\sin x$ 乘以一个关于 $\cos x$ 的多项式，其绝对值不超过 $k$（可用归纳法证明）。

**引理**：对任意正整数 $k$ 和实数 $x$，有 $|\sin kx| \leq k |\sin x|$。

**证明**（归纳）：
- $k=1$ 显然。
- 假设对 $k$ 成立，则
$$
|\sin (k+1)x| = |\sin kx \cos x + \cos kx \sin x| \leq |\sin kx||\cos x| + |\cos kx||\sin x| \leq k|\sin x| \cdot 1 + 1 \cdot |\sin x| = (k+1)|\sin x|
$$
成立。

所以引理得证。

应用这个引理到 $|\sin mn\alpha|$，有两种方式：
- 视为 $\sin(mn\alpha) = \sin(n \cdot m\alpha)$，则：
$$
|\sin mn\alpha| \leq n |\sin m\alpha| = n A
$$
- 或视为 $\sin(m \cdot n\alpha)$，则：
$$
|\sin mn\alpha| \leq m |\sin n\alpha| = m B
$$

所以：
$$
C = |\sin mn\alpha| \leq \min(nA, mB)
$$

这个估计很有用！

---

### 第六步：利用上述不等式放缩

回到等价不等式 (2)：
$$
m(A + B) + C\left( \frac{1}{A} + \frac{1}{B} \right) > 1
$$

由于 $C \geq 0$，所以左边 $\geq m(A + B)$。

但 $A + B$ 可能很小，比如 $A = B = 0.001$，则 $m(A + B) = 0.002m$，若 $m=1$，则小于 1。所以不能只靠第一项。

但第二项 $C(1/A + 1/B)$ 可能很大。

我们尝试用 $C \leq nA$ 来估计第二项：

$$
C\left( \frac{1}{A} + \frac{1}{B} \right) \leq nA \left( \frac{1}{A} + \frac{1}{B} \right) = n\left(1 + \frac{A}{B} \right)
$$

但这给出的是上界，而我们需要**下界**。

反过来，我们也可以用 $C \geq 0$，所以第二项 $\geq 0$，但这太弱。

我们需要一个**下界** for $C(1/A + 1/B)$。

但注意：我们不需要分别估计两项，而是整体估计。

考虑使用**AM-GM 不等式**或其他技巧。

---

### 第七步：回到原始不等式，尝试直接证明

原始不等式：
$$
\frac{1}{A} + \frac{1}{B} > \frac{1}{mAB + C}
$$

等价于：
$$
(mAB + C)\left( \frac{1}{A} + \frac{1}{B} \right) > 1
$$

即：
$$
mB + mA + \frac{C}{A} + \frac{C}{B} > 1
$$

现在我们使用引理 $C \leq nA$ 和 $C \leq mB$，但这给出的是上界，无助于证明“>1”。

但我们可以用**反证法**：假设不等式不成立，即
$$
\frac{1}{A} + \frac{1}{B} \leq \frac{1}{mAB + C}
$$

则两边取倒数（注意两边正）：
$$
\frac{1}{\frac{1}{A} + \frac{1}{B}} \geq mAB + C
$$

左边是调和平均的一半？实际上：
$$
\frac{1}{\frac{1}{A} + \frac{1}{B}} = \frac{AB}{A + B}
$$

所以假设变为：
$$
\frac{AB}{A + B} \geq mAB + C
$$

移项：
$$
\frac{AB}{A + B} - mAB \geq C
\Rightarrow AB\left( \frac{1}{A + B} - m \right) \geq C
$$

但注意：$\frac{1}{A + B} - m \leq \frac{1}{2\sqrt{AB}} - m$（因为 $A + B \geq 2\sqrt{AB}$）

由于 $m \geq 1$，而 $\frac{1}{A + B} \leq \frac{1}{2\sqrt{AB}}$，所以 $\frac{1}{A + B} - m < 0$（除非 $A + B$ 非常小，但即使那样，$\frac{1}{A + B}$ 很大，可能大于 $m$）。

但关键是：左边 $AB\left( \frac{1}{A + B} - m \right)$ 是**负数**（因为 $\frac{1}{A + B} \leq \frac{1}{2\sqrt{AB}}$，而 $m \geq 1$，但若 $A + B < 1/m$，则 $\frac{1}{A + B} > m$，此时左边为正）。

所以不能直接判断符号。

但注意右边 $C \geq 0$，所以如果左边为负，则不等式不可能成立（因为负 ≥ 非负 不可能）。因此，若假设成立，则必须有：
$$
AB\left( \frac{1}{A + B} - m \right) \geq 0 \Rightarrow \frac{1}{A + B} \geq m \Rightarrow A + B \leq \frac{1}{m}
$$

所以在反证假设下，必须有 $A + B \leq 1/m$。

同时，由假设：
$$
\frac{AB}{A + B} \geq mAB + C \geq mAB
\Rightarrow \frac{1}{A + B} \geq m
$$
这与上面一致。

现在，在 $A + B \leq 1/m$ 的条件下，我们估计 $C = |\sin mn\alpha|$ 的下界。

但注意：当 $A = |\sin m\alpha|$ 很小时，意味着 $m\alpha$ 接近 $k\pi$，即 $\alpha \approx k\pi/m$。

同理，$B = |\sin n\alpha|$ 很小，意味着 $\alpha \approx l\pi/n$。

所以 $\alpha$ 同时接近 $k\pi/m$ 和 $l\pi/n$，即 $\alpha$ 接近 $\pi$ 的有理倍数。

那么 $mn\alpha$ 接近 $mn \cdot \frac{k\pi}{m} = nk\pi$，或 $mn \cdot \frac{l\pi}{n} = ml\pi$，所以 $\sin mn\alpha$ 接近 0，即 $C$ 也很小。

所以在这种情况下，$A, B, C$ 都很小，但 $1/A + 1/B$ 很大，右边分母 $mAB + C$ 很小，所以右边很大，但左边更大？需要仔细分析。

但或许我们可以用一个更巧妙的恒等式。

---

### 第八步：使用恒等式 $\sin mn\alpha = \sin m\alpha \cdot U_{n-1}(\cos m\alpha)$

其中 $U_{n-1}$ 是第二类切比雪夫多项式，满足：
$$
\sin(n\theta) = \sin\theta \cdot U_{n-1}(\cos\theta)
$$

所以：
$$
\sin mn\alpha = \sin(m\alpha) \cdot U_{n-1}(\cos m\alpha)
\Rightarrow |\sin mn\alpha| = |\sin m\alpha| \cdot |U_{n-1}(\cos m\alpha)|
$$

类似地：
$$
|\sin mn\alpha| = |\sin n\alpha| \cdot |U_{m-1}(\cos n\alpha)|
$$

而切比雪夫多项式 $U_{k}(x)$ 满足 $|U_k(x)| \leq k+1$ 对 $|x| \leq 1$ 成立（实际上最大值为 $k+1$ 在 $x = \pm 1$ 处）。

所以：
$$
C = |\sin mn\alpha| \leq (n) A,\quad C \leq (m) B
$$

这我们已有。

但更重要的是，**$|U_{n-1}(\cos m\alpha)| \geq 1$**？不一定，例如当 $\cos m\alpha = 0$，$U_{n-1}(0)$ 可能为 0（当 $n-1$ 为奇数时）。

所以不能得到下界。

---

### 第九步：尝试构造函数最小值

考虑函数：
$$
F(A,B,C) = \frac{1}{A} + \frac{1}{B} - \frac{1}{mAB + C}
$$
在约束：
- $A = |\sin m\alpha| \in (0,1]$
- $B = |\sin n\alpha| \in (0,1]$
- $C = |\sin mn\alpha| \in [0,1]$
- 且存在 $\alpha$ 使得三者满足三角关系

但三角关系复杂，难以参数化。

但注意到：对于固定的 $A, B$，$C$ 最大为 1，最小为 0。而 $F$ 随 $C$ 增大而**减小**（因为分母增大），所以**最坏情况是 $C = 1$**（使右边最大，左边不变，差值最小）。

所以只需证明：
$$
\frac{1}{A} + \frac{1}{B} > \frac{1}{mAB + 1}
$$

对所有 $A, B \in (0,1]$ 成立。

因为如果这个成立，则对更小的 $C$（即 $C < 1$），右边更小，不等式更成立。

所以只需证明：
$$
\frac{1}{A} + \frac{1}{B} > \frac{1}{mAB + 1}, \quad \forall A,B \in (0,1]
$$

现在这个不等式不含 $C$，更容易处理。

等价于：
$$
\left( \frac{1}{A} + \frac{1}{B} \right)(mAB + 1) > 1
$$

展开：
$$
mB + mA + \frac{1}{A} + \frac{1}{B} > 1
$$

由于 $A, B \in (0,1]$，所以 $1/A \geq 1$, $1/B \geq 1$，因此：
$$
mB + mA + \frac{1}{A} + \frac{1}{B} \geq mB + mA + 2
$$

而 $mB + mA \geq 0$，所以整个左边 $\geq 2 > 1$。

**证毕！**

---

### 第十步：严谨表述

**关键步骤总结**：

1. 由于 $|\sin mn\alpha| \leq 1$，有：
   $$
   m |\sin m\alpha \sin n\alpha| + |\sin mn\alpha| \leq m |\sin m\alpha \sin n\alpha| + 1
   $$
   因此：
   $$
   \frac{1}{m |\sin m\alpha \sin n\alpha| + |\sin mn\alpha|} \geq \frac{1}{m |\sin m\alpha \sin n\alpha| + 1}
   $$
   注意：这是**右边变大**，所以为了证明原不等式，只需证明更强的不等式：
   $$
   \frac{1}{|\sin m\alpha|} + \frac{1}{|\sin n\alpha|} > \frac{1}{m |\sin m\alpha \sin n\alpha| + 1}
   $$

2. 令 $A = |\sin m\alpha|$, $B = |\sin n\alpha|$，则 $A, B \in (0,1]$，需证：
   $$
   \frac{1}{A} + \frac{1}{B} > \frac{1}{mAB + 1}
   $$

3. 等价于：
   $$
   \left( \frac{1}{A} + \frac{1}{B} \right)(mAB + 1) > 1
   $$

4. 展开左边：
   $$
   mB + mA + \frac{1}{A} + \frac{1}{B}
   $$

5. 由于 $A, B \in (0,1]$，有 $\frac{1}{A} \geq 1$, $\frac{1}{B} \geq 1$，且 $mA, mB \geq 0$，所以：
   $$
   mB + mA + \frac{1}{A} + \frac{1}{B} \geq 0 + 0 + 1 + 1 = 2 > 1
   $$

6. 因此原不等式成立。

---

### 最终结论

对任意实数 $\alpha$ 和正整数 $m,n$，只要 $\sin m\alpha \cdot \sin n\alpha \ne 0$，就有：
$$
\frac{1}{|\sin m\alpha|} + \frac{1}{|\sin n\alpha|} > \frac{1}{m |\sin m\alpha \sin n\alpha| + |\sin mn\alpha|}
$$

**证毕。**