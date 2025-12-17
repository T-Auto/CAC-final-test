我们要求的是在单位圆盘 $ D: x^2 + y^2 \leq 1 $ 上的二重积分：

$$
I = \iint_{D} \left| x^2 + y^2 - x - y \right| \, dx\,dy.
$$

---

### 第一步：观察被积函数结构

注意到：
$$
x^2 + y^2 - x - y = (x^2 - x) + (y^2 - y) = \left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 - \frac{1}{2}.
$$

所以被积函数为：
$$
\left| \left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 - \frac{1}{2} \right|.
$$

这提示我们：**绝对值的零点**（即符号变化的边界）是圆：
$$
\left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 = \frac{1}{2}.
$$

记这个圆为 $ C $，其圆心为 $ \left(\frac{1}{2}, \frac{1}{2}\right) $，半径为 $ r = \frac{1}{\sqrt{2}} \approx 0.7071 $。

而积分区域 $ D $ 是单位圆盘：$ x^2 + y^2 \leq 1 $，圆心在原点，半径为 1。

因此，被积函数在 $ D $ 内部会改变符号，分界线就是圆 $ C $ 与 $ D $ 的交集。

---

### 第二步：确定符号区域

定义函数：
$$
f(x, y) = x^2 + y^2 - x - y.
$$

- 在圆 $ C $ 内部（即 $ (x - \frac{1}{2})^2 + (y - \frac{1}{2})^2 < \frac{1}{2} $），有 $ f(x, y) < 0 $；
- 在圆 $ C $ 外部（但在 $ D $ 内），有 $ f(x, y) > 0 $。

因此，积分可以拆分为两部分：

$$
I = \iint_{D \cap \{f < 0\}} (-f) \, dx\,dy + \iint_{D \cap \{f \ge 0\}} f \, dx\,dy.
$$

等价于：
$$
I = \iint_D |f| \, dx\,dy = \iint_D f \, dx\,dy - 2 \iint_{D \cap \{f < 0\}} f \, dx\,dy.
$$

但更直接的方法是使用**极坐标变换**，因为区域 $ D $ 是单位圆盘，极坐标非常合适。

---

### 第三步：转换为极坐标

令：
$$
x = r\cos\theta,\quad y = r\sin\theta,\quad 0 \le r \le 1,\ 0 \le \theta < 2\pi.
$$

则：
$$
x^2 + y^2 = r^2,\quad x + y = r(\cos\theta + \sin\theta).
$$

所以：
$$
f(x, y) = r^2 - r(\cos\theta + \sin\theta).
$$

被积函数变为：
$$
|f| = |r^2 - r(\cos\theta + \sin\theta)| = r\,|r - (\cos\theta + \sin\theta)|.
$$

面积元素：$ dx\,dy = r\,dr\,d\theta $，所以整个积分变为：

$$
I = \int_0^{2\pi} \int_0^1 r\,|r - (\cos\theta + \sin\theta)| \cdot r \, dr\,d\theta = \int_0^{2\pi} \int_0^1 r^2 |r - (\cos\theta + \sin\theta)| \, dr\,d\theta.
$$

---

### 第四步：对 $ r $ 积分（分段）

对于固定的 $ \theta $，令 $ a = \cos\theta + \sin\theta $。注意 $ a \in [-\sqrt{2}, \sqrt{2}] $。

我们要计算：
$$
\int_0^1 r^2 |r - a| \, dr.
$$

根据 $ a $ 与区间 $ [0,1] $ 的关系，分情况讨论：

#### 情况 1：$ a \le 0 $

此时对所有 $ r \in [0,1] $，有 $ r - a \ge r \ge 0 $，所以 $ |r - a| = r - a $。

积分：
$$
\int_0^1 r^2 (r - a) \, dr = \int_0^1 (r^3 - a r^2) \, dr = \left[\frac{r^4}{4} - a \cdot \frac{r^3}{3}\right]_0^1 = \frac{1}{4} - \frac{a}{3}.
$$

#### 情况 2：$ a \ge 1 $

此时对所有 $ r \in [0,1] $，有 $ r - a \le 0 $，所以 $ |r - a| = a - r $。

积分：
$$
\int_0^1 r^2 (a - r) \, dr = \int_0^1 (a r^2 - r^3) \, dr = a \cdot \frac{1}{3} - \frac{1}{4} = \frac{a}{3} - \frac{1}{4}.
$$

#### 情况 3：$ 0 < a < 1 $

此时在 $ r \in [0, a] $，有 $ r - a \le 0 $，所以 $ |r - a| = a - r $；  
在 $ r \in [a, 1] $，有 $ r - a \ge 0 $，所以 $ |r - a| = r - a $。

因此积分拆为两部分：

$$
\int_0^a r^2 (a - r) \, dr + \int_a^1 r^2 (r - a) \, dr.
$$

分别计算：

- 第一部分：
$$
\int_0^a (a r^2 - r^3) \, dr = a \cdot \frac{a^3}{3} - \frac{a^4}{4} = \frac{a^4}{3} - \frac{a^4}{4} = \frac{a^4}{12}.
$$

- 第二部分：
$$
\int_a^1 (r^3 - a r^2) \, dr = \left[\frac{r^4}{4} - a \cdot \frac{r^3}{3}\right]_a^1 = \left(\frac{1}{4} - \frac{a}{3}\right) - \left(\frac{a^4}{4} - \frac{a^4}{3}\right) = \frac{1}{4} - \frac{a}{3} - \left(\frac{a^4}{4} - \frac{a^4}{3}\right).
$$

注意：
$$
\frac{a^4}{4} - \frac{a^4}{3} = a^4\left(\frac{1}{4} - \frac{1}{3}\right) = -\frac{a^4}{12}.
$$

所以第二部分为：
$$
\frac{1}{4} - \frac{a}{3} + \frac{a^4}{12}.
$$

加上第一部分 $ \frac{a^4}{12} $，总和为：
$$
\frac{1}{4} - \frac{a}{3} + \frac{a^4}{6}.
$$

综上，对于 $ a \in (0,1) $，积分值为：
$$
\frac{1}{4} - \frac{a}{3} + \frac{a^4}{6}.
$$

---

### 第五步：对 $ \theta $ 积分

现在我们有：

- 当 $ a = \cos\theta + \sin\theta \le 0 $，积分值为 $ \frac{1}{4} - \frac{a}{3} $；
- 当 $ a \ge 1 $，积分值为 $ \frac{a}{3} - \frac{1}{4} $；
- 当 $ 0 < a < 1 $，积分值为 $ \frac{1}{4} - \frac{a}{3} + \frac{a^4}{6} $。

注意：由于 $ a = \cos\theta + \sin\theta = \sqrt{2} \sin(\theta + \pi/4) $，其取值范围为 $ [-\sqrt{2}, \sqrt{2}] $，且关于 $ \theta $ 对称。

我们可以利用对称性简化积分。

---

### 第六步：利用对称性简化

令 $ \phi = \theta + \pi/4 $，则 $ a = \sqrt{2} \sin\phi $，且 $ d\theta = d\phi $，积分区间仍为 $ 0 \le \phi < 2\pi $。

于是：
$$
I = \int_0^{2\pi} F(a(\theta)) \, d\theta = \int_0^{2\pi} F(\sqrt{2} \sin\phi) \, d\phi,
$$
其中 $ F(a) = \int_0^1 r^2 |r - a| \, dr $，如上分段定义。

由于 $ \sin\phi $ 是周期为 $ 2\pi $ 的奇函数，且 $ F(a) $ 是关于 $ a $ 的**偶函数吗**？我们来验证：

- $ F(-a) = \int_0^1 r^2 |r + a| \, dr $，而 $ F(a) = \int_0^1 r^2 |r - a| \, dr $，两者不相等，所以不是偶函数。

但我们可以利用 $ \sin\phi $ 的对称性，将积分区间分为四段，或者更简单地，直接在 $ \theta \in [0, 2\pi] $ 上数值积分？但题目要求解析解，所以继续分析。

更好的方法是回到**原始表达式**，考虑使用**平移坐标**或**几何方法**。

---

### 第七步：换一种思路 —— 利用对称性和积分公式

我们回到原始表达式：

$$
I = \iint_D |x^2 + y^2 - x - y| \, dx\,dy.
$$

令 $ u = x - \frac{1}{2}, v = y - \frac{1}{2} $，即平移坐标系到点 $ (\frac{1}{2}, \frac{1}{2}) $。

则：
$$
x = u + \frac{1}{2},\quad y = v + \frac{1}{2},\quad x^2 + y^2 = u^2 + v^2 + u + v + \frac{1}{2}.
$$

所以：
$$
x^2 + y^2 - x - y = (u^2 + v^2 + u + v + \frac{1}{2}) - (u + \frac{1}{2}) - (v + \frac{1}{2}) = u^2 + v^2 - \frac{1}{2}.
$$

因此被积函数变为：
$$
|u^2 + v^2 - \frac{1}{2}|.
$$

而积分区域 $ D $ 变为：
$$
(x)^2 + (y)^2 \le 1 \Rightarrow (u + \frac{1}{2})^2 + (v + \frac{1}{2})^2 \le 1.
$$

即：
$$
(u + \tfrac{1}{2})^2 + (v + \tfrac{1}{2})^2 \le 1.
$$

这是一个以 $ (-\frac{1}{2}, -\frac{1}{2}) $ 为圆心、半径为 1 的圆盘，记作 $ D' $。

所以现在的问题转化为：

$$
I = \iint_{D'} |u^2 + v^2 - \tfrac{1}{2}| \, du\,dv.
$$

这看起来更简洁了！现在被积函数只依赖于 $ \rho = \sqrt{u^2 + v^2} $，即径向对称，但积分区域 $ D' $ 不是以原点为中心的圆，而是偏移的圆。

不过，我们可以考虑**以原点为中心的极坐标**，然后对每个角度 $ \theta $，确定径向积分的上下限。

令 $ u = r\cos\theta, v = r\sin\theta $，则被积函数为 $ |r^2 - \frac{1}{2}| $，而区域 $ D' $ 的边界为：

$$
(r\cos\theta + \tfrac{1}{2})^2 + (r\sin\theta + \tfrac{1}{2})^2 \le 1.
$$

展开：
$$
r^2\cos^2\theta + r\cos\theta + \tfrac{1}{4} + r^2\sin^2\theta + r\sin\theta + \tfrac{1}{4} \le 1,
$$
$$
r^2 + r(\cos\theta + \sin\theta) + \tfrac{1}{2} \le 1,
$$
$$
r^2 + r(\cos\theta + \sin\theta) \le \tfrac{1}{2}.
$$

即：
$$
r^2 + a r - \tfrac{1}{2} \le 0,\quad a = \cos\theta + \sin\theta.
$$

解这个不等式，求出 $ r $ 的范围（非负部分）。

二次方程 $ r^2 + a r - \frac{1}{2} = 0 $ 的正根为：

$$
r = \frac{-a + \sqrt{a^2 + 2}}{2} \quad (\text{因为 } \sqrt{a^2 + 2} > |a|).
$$

所以对于每个 $ \theta $，$ r \in [0, R(\theta)] $，其中：

$$
R(\theta) = \frac{-a + \sqrt{a^2 + 2}}{2},\quad a = \cos\theta + \sin\theta.
$$

于是积分变为：

$$
I = \int_0^{2\pi} \int_0^{R(\theta)} |r^2 - \tfrac{1}{2}| \cdot r \, dr\,d\theta.
$$

注意这里面积元素是 $ r\,dr\,d\theta $，因为是在 $ (u,v) $ 平面用极坐标。

现在对每个 $ \theta $，内层积分：

$$
\int_0^{R} |r^2 - \tfrac{1}{2}| r \, dr.
$$

令 $ s = r^2 $，则 $ ds = 2r\,dr \Rightarrow r\,dr = ds/2 $，积分变为：

$$
\frac{1}{2} \int_0^{R^2} |s - \tfrac{1}{2}| \, ds.
$$

这是一个标准积分：

- 若 $ R^2 \le \frac{1}{2} $，则 $ |s - \frac{1}{2}| = \frac{1}{2} - s $，积分值为：
  $$
  \frac{1}{2} \int_0^{R^2} \left(\frac{1}{2} - s\right) ds = \frac{1}{2} \left( \frac{1}{2} R^2 - \frac{R^4}{2} \right) = \frac{R^2}{4} - \frac{R^4}{4}.
  $$

- 若 $ R^2 \ge \frac{1}{2} $，则拆为两段：
  $$
  \frac{1}{2} \left[ \int_0^{1/2} \left(\frac{1}{2} - s\right) ds + \int_{1/2}^{R^2} (s - \frac{1}{2}) ds \right].
  $$

计算：
- 第一部分：$ \int_0^{1/2} (\frac{1}{2} - s) ds = \frac{1}{8} $；
- 第二部分：$ \int_{1/2}^{R^2} (s - \frac{1}{2}) ds = \frac{1}{2}(R^2 - \frac{1}{2})^2 $。

所以总和为：
$$
\frac{1}{2} \left( \frac{1}{8} + \frac{1}{2}(R^2 - \frac{1}{2})^2 \right) = \frac{1}{16} + \frac{1}{4}(R^2 - \frac{1}{2})^2.
$$

综上，内层积分结果为：

$$
G(R) = 
\begin{cases}
\displaystyle \frac{R^2}{4} - \frac{R^4}{4}, & R^2 \le \frac{1}{2}, \\
\displaystyle \frac{1}{16} + \frac{1}{4}(R^2 - \frac{1}{2})^2, & R^2 \ge \frac{1}{2}.
\end{cases}
$$

现在我们需要确定对于哪些 $ \theta $，有 $ R(\theta)^2 \le \frac{1}{2} $。

回忆：
$$
R(\theta) = \frac{-a + \sqrt{a^2 + 2}}{2},\quad a = \cos\theta + \sin\theta.
$$

计算 $ R^2 $：

令 $ t = a $，则：
$$
R = \frac{-t + \sqrt{t^2 + 2}}{2} \Rightarrow R^2 = \frac{t^2 - 2t\sqrt{t^2 + 2} + (t^2 + 2)}{4} = \frac{2t^2 + 2 - 2t\sqrt{t^2 + 2}}{4} = \frac{t^2 + 1 - t\sqrt{t^2 + 2}}{2}.
$$

我们想知道何时 $ R^2 \le \frac{1}{2} $，即：

$$
\frac{t^2 + 1 - t\sqrt{t^2 + 2}}{2} \le \frac{1}{2} \Rightarrow t^2 + 1 - t\sqrt{t^2 + 2} \le 1 \Rightarrow t^2 \le t\sqrt{t^2 + 2}.
$$

若 $ t \ge 0 $，两边除以 $ t $（注意 $ t=0 $ 时等式成立）：

$$
t \le \sqrt{t^2 + 2} \quad \text{恒成立}.
$$

所以当 $ t \ge 0 $，不等式成立，即 $ R^2 \le \frac{1}{2} $？

但等一下，我们来验证一个具体值：

- 若 $ t = \sqrt{2} $（最大值），则：
  $$
  R = \frac{-\sqrt{2} + \sqrt{2 + 2}}{2} = \frac{-\sqrt{2} + 2}{2} \approx \frac{-1.414 + 2}{2} = 0.293.
  $$
  $ R^2 \approx 0.086 < 0.5 $，确实小于。

- 若 $ t = 0 $，则 $ R = \frac{0 + \sqrt{2}}{2} = \frac{\sqrt{2}}{2} \approx 0.707 $，$ R^2 = 0.5 $，等于。

- 若 $ t = -\sqrt{2} $，则：
  $$
  R = \frac{\sqrt{2} + \sqrt{2 + 2}}{2} = \frac{\sqrt{2} + 2}{2} \approx \frac{1.414 + 2}{2} = 1.707,
  $$
  $ R^2 \approx 2.915 > 0.5 $。

所以结论是：

- 当 $ a = \cos\theta + \sin\theta \ge 0 $，有 $ R^2 \le \frac{1}{2} $；
- 当 $ a < 0 $，有 $ R^2 > \frac{1}{2} $。

验证边界：$ a = 0 \Rightarrow R^2 = 0.5 $，正确。

因此，分界线是 $ \cos\theta + \sin\theta = 0 \Rightarrow \sin(\theta + \pi/4) = 0 \Rightarrow \theta + \pi/4 = 0, \pi, 2\pi,... \Rightarrow \theta = -\pi/4, 3\pi/4 $ 等。

所以在 $ \theta \in [-\pi/4, 3\pi/4] $（即长度为 $ \pi $）的区间内，$ a \ge 0 $；其余区间 $ a < 0 $。

由于积分周期为 $ 2\pi $，我们可以取：

- 区间 I：$ \theta \in [-\pi/4, 3\pi/4] $，长度 $ \pi $，$ a \ge 0 $，用第一种表达式；
- 区间 II：$ \theta \in [3\pi/4, 7\pi/4] $，长度 $ \pi $，$ a < 0 $，用第二种表达式。

利用周期性，我们可以将积分写为：

$$
I = \int_{-\pi/4}^{3\pi/4} G_1(R(\theta)) \, d\theta + \int_{3\pi/4}^{7\pi/4} G_2(R(\theta)) \, d\theta,
$$

其中：

- $ G_1(R) = \frac{R^2}{4} - \frac{R^4}{4} $,
- $ G_2(R) = \frac{1}{16} + \frac{1}{4}(R^2 - \frac{1}{2})^2 $.

但注意：在区间 II（$ a < 0 $），我们有 $ R^2 > 1/2 $，所以用 $ G_2 $。

现在我们尝试用变量替换简化。

---

### 第八步：回到原始极坐标方法（更简单）

回顾之前在原始极坐标下的表达式：

$$
I = \int_0^{2\pi} \int_0^1 r^2 |r - a| \, dr\,d\theta,\quad a = \cos\theta + \sin\theta.
$$

我们已经对 $ r $ 积分得到了分段表达式。现在我们直接对 $ \theta $ 积分。

由于 $ a = \sqrt{2} \sin(\theta + \pi/4) $，令 $ \phi = \theta + \pi/4 $，则 $ d\theta = d\phi $，积分区间 $ \phi \in [0, 2\pi] $，且 $ a = \sqrt{2} \sin\phi $。

于是：

$$
I = \int_0^{2\pi} H(a(\phi)) \, d\phi,
$$

其中：

- 若 $ a \le 0 $（即 $ \sin\phi \le 0 $，即 $ \phi \in [\pi, 2\pi] $），则 $ H(a) = \frac{1}{4} - \frac{a}{3} $；
- 若 $ a \ge 1 $（即 $ \sqrt{2} \sin\phi \ge 1 \Rightarrow \sin\phi \ge 1/\sqrt{2} \approx 0.7071 $，即 $ \phi \in [\pi/4, 3\pi/4] $），则 $ H(a) = \frac{a}{3} - \frac{1}{4} $；
- 若 $ 0 < a < 1 $（即 $ \sin\phi \in (0, 1/\sqrt{2}) $，即 $ \phi \in (0, \pi/4) \cup (3\pi/4, \pi) $），则 $ H(a) = \frac{1}{4} - \frac{a}{3} + \frac{a^4}{6} $。

现在我们将积分拆成几段：

1. $ \phi \in [0, \pi/4] $: $ a \in (0,1) $, use $ H_2 = \frac{1}{4} - \frac{a}{3} + \frac{a^4}{6} $.
2. $ \phi \in [\pi/4, 3\pi/4] $: $ a \in [1, \sqrt{2}] $, use $ H_1 = \frac{a}{3} - \frac{1}{4} $.
3. $ \phi \in [3\pi/4, \pi] $: $ a \in (0,1) $, use $ H_2 $.
4. $ \phi \in [\pi, 2\pi] $: $ a \le 0 $, use $ H_0 = \frac{1}{4} - \frac{a}{3} $.

注意函数关于 $ \phi = \pi $ 对称？我们检查：

- $ a(\phi) = \sqrt{2} \sin\phi $,
- $ a(2\pi - \phi) = \sqrt{2} \sin(2\pi - \phi) = -\sqrt{2} \sin\phi = -a(\phi) $.

而 $ H(a) $ 不是偶函数，但我们可以利用对称性将区间 $ [\pi, 2\pi] $ 映射到 $ [0, \pi] $。

令 $ \psi = \phi - \pi $，则 $ \phi \in [\pi, 2\pi] \Rightarrow \psi \in [0, \pi] $，且 $ a = \sqrt{2} \sin(\psi + \pi) = -\sqrt{2} \sin\psi = -a' $，其中 $ a' = \sqrt{2} \sin\psi \in [0, \sqrt{2}] $。

所以：

$$
\int_{\pi}^{2\pi} \left( \frac{1}{4} - \frac{a}{3} \right) d\phi = \int_0^{\pi} \left( \frac{1}{4} + \frac{a'}{3} \right) d\psi.
$$

而前半部分 $ \phi \in [0, \pi] $ 的积分是：

$$
\int_0^{\pi/4} H_2(a) d\phi + \int_{\pi/4}^{3\pi/4} H_1(a) d\phi + \int_{3\pi/4}^{\pi} H_2(a) d\phi.
$$

所以总积分：

$$
I = \int_0^{\pi} H_2(a) d\phi + \int_{\pi/4}^{3\pi/4} [H_1(a) - H_2(a)] d\phi + \int_0^{\pi} \left( \frac{1}{4} + \frac{a}{3} \right) d\phi,
$$

其中在第二项中，$ H_2 $ 只在 $ [0,\pi/4] \cup [3\pi/4,\pi] $ 有定义，但为了方便，我们可以写成：

$$
I = \int_0^{\pi} \left( \frac{1}{4} + \frac{a}{3} \right) d\phi + \int_0^{\pi/4} [H_2(a) - (\frac{1}{4} + \frac{a}{3})] d\phi + \int_{3\pi/4}^{\pi} [H_2(a) - (\frac{1}{4} + \frac{a}{3})] d\phi + \int_{\pi/4}^{3\pi/4} [H_1(a) - (\frac{1}{4} + \frac{a}{3})] d\phi.
$$

但这太复杂了。

---

### 第九步：直接计算积分（利用对称性和已知积分）

回到原始极坐标表达式：

$$
I = \int_0^{2\pi} \int_0^1 r^2 |r - a| \, dr\,d\theta,\quad a = \cos\theta + \sin\theta.
$$

我们交换积分顺序，先对 $ \theta $ 积分？不太容易。

但注意到：我们可以将积分写成：

$$
I = \int_0^1 r^2 \left( \int_0^{2\pi} |r - (\cos\theta + \sin\theta)| \, d\theta \right) dr.
$$

令 $ J(r) = \int_0^{2\pi} |r - (\cos\theta + \sin\theta)| \, d\theta $。

由于 $ \cos\theta + \sin\theta = \sqrt{2} \sin(\theta + \pi/4) $，所以：

$$
J(r) = \int_0^{2\pi} |r - \sqrt{2} \sin\phi| \, d\phi,\quad \phi = \theta + \pi/4.
$$

这是一个标准积分。对于常数 $ r $，计算：

$$
\int_0^{2\pi} |r - \sqrt{2} \sin\phi| \, d\phi.
$$

由于 $ \sin\phi $ 是周期函数，且绝对值，我们可以利用对称性：

$$
J(r) = 2 \int_0^{\pi} |r - \sqrt{2} \sin\phi| \, d\phi = 4 \int_0^{\pi/2} |r - \sqrt{2} \sin\phi| \, d\phi.
$$

现在分情况：

- 若 $ r \ge \sqrt{2} $，则 $ r - \sqrt{2} \sin\phi \ge 0 $，所以：
  $$
  J(r) = 4 \int_0^{\pi/2} (r - \sqrt{2} \sin\phi) d\phi = 4 \left( r \cdot \frac{\pi}{2} - \sqrt{2} \cdot 1 \right) = 2\pi r - 4\sqrt{2}.
  $$

- 若 $ r \le 0 $，则 $ r - \sqrt{2} \sin\phi \le 0 $，所以：
  $$
  J(r) = 4 \int_0^{\pi/2} (\sqrt{2} \sin\phi - r) d\phi = 4 \left( \sqrt{2} \cdot 1 - r \cdot \frac{\pi}{2} \right) = 4\sqrt{2} - 2\pi r.
  $$

- 若 $ 0 < r < \sqrt{2} $，则存在 $ \phi_0 \in (0, \pi/2) $ 使得 $ \sqrt{2} \sin\phi_0 = r \Rightarrow \sin\phi_0 = r/\sqrt{2} $。

于是：
$$
J(r) = 4 \left[ \int_0^{\phi_0} (\sqrt{2} \sin\phi - r) d\phi + \int_{\phi_0}^{\pi/2} (r - \sqrt{2} \sin\phi) d\phi \right].
$$

计算：

- 第一部分：$ \int_0^{\phi_0} \sqrt{2} \sin\phi d\phi = \sqrt{2}(1 - \cos\phi_0) $,
- 第二部分：$ \int_{\phi_0}^{\pi/2} \sqrt{2} \sin\phi d\phi = \sqrt{2} \cos\phi_0 $.

所以：

$$
J(r) = 4 \left[ \sqrt{2}(1 - \cos\phi_0) - r\phi_0 + r(\pi/2 - \phi_0) - \sqrt{2} \cos\phi_0 \right] = 4 \left[ \sqrt{2} - 2\sqrt{2} \cos\phi_0 + r(\pi/2 - 2\phi_0) \right].
$$

但 $ \cos\phi_0 = \sqrt{1 - \sin^2\phi_0} = \sqrt{1 - r^2/2} $.

所以：

$$
J(r) = 4\sqrt{2} - 8\sqrt{2} \sqrt{1 - r^2/2} + 2r(\pi - 4\phi_0).
$$

而 $ \phi_0 = \arcsin(r/\sqrt{2}) $.

因此：

$$
J(r) = 4\sqrt{2} - 8\sqrt{2} \sqrt{1 - r^2/2} + 2r(\pi - 4\arcsin(r/\sqrt{2})).
$$

现在，$ I = \int_0^1 r^2 J(r) dr $.

这看起来仍然复杂，但或许可以积分。

不过，我们注意到 $ r \in [0,1] \subset [0, \sqrt{2}] $，所以只需考虑 $ 0 \le r \le 1 < \sqrt{2} $，即 always in the case $ 0 < r < \sqrt{2} $.

所以：

$$
I = \int_0^1 r^2 \left[ 4\sqrt{2} - 8\sqrt{2} \sqrt{1 - r^2/2} + 2r(\pi - 4\arcsin(r/\sqrt{2})) \right] dr.
$$

拆成三部分：

1. $ I_1 = 4\sqrt{2} \int_0^1 r^2 dr = 4\sqrt{2} \cdot \frac{1}{3} = \frac{4\sqrt{2}}{3} $.

2. $ I_2 = -8\sqrt{2} \int_0^1 r^2 \sqrt{1 - r^2/2} \, dr $.

3. $ I_3 = 2 \int_0^1 r^3 (\pi - 4\arcsin(r/\sqrt{2})) dr = 2\pi \int_0^1 r^3 dr - 8 \int_0^1 r^3 \arcsin(r/\sqrt{2}) dr = \frac{2\pi}{4} - 8 \int_0^1 r^3 \arcsin(r/\sqrt{2}) dr = \frac{\pi}{2} - 8 \int_0^1 r^3 \arcsin(r/\sqrt{2}) dr $.

现在计算 $ I_2 $ 和 the arcsin integral.

---

#### 计算 $ I_2 $

Let $ u = r^2/2 \Rightarrow r = \sqrt{2u}, dr = \frac{\sqrt{2}}{2\sqrt{u}}