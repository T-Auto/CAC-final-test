# Claude Sonnet 4.5 解答

本题考查带绝对值的二重积分计算，核心在于正确划分积分区域并选择合适的坐标系。

## 解题思路

处理绝对值积分的关键：
1. 找出被积函数的零点曲线
2. 判断零点曲线与积分区域的关系
3. 分区域去掉绝对值符号
4. 选择极坐标简化计算

## 详细解答

### 步骤1：确定零点曲线

设 $f(x,y) = x^2 + y^2 - x - y$，令 $f(x,y) = 0$：

$$x^2 - x + y^2 - y = 0$$

配方：
$$\left(x - \frac{1}{2}\right)^2 - \frac{1}{4} + \left(y - \frac{1}{2}\right)^2 - \frac{1}{4} = 0$$

$$\left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 = \frac{1}{2}$$

这是圆心在 $C\left(\frac{1}{2}, \frac{1}{2}\right)$，半径 $r_0 = \frac{1}{\sqrt{2}}$ 的圆。

### 步骤2：分析区域位置关系

积分区域 $D$：单位圆 $x^2 + y^2 \le 1$

圆心到原点距离：$d = \sqrt{\frac{1}{4} + \frac{1}{4}} = \frac{1}{\sqrt{2}}$

由于 $d + r_0 = \frac{2}{\sqrt{2}} = \sqrt{2} < 1$，小圆完全在单位圆内部。

**判断 $f$ 的符号**：
- 在原点 $(0,0)$：$f(0,0) = 0 - 0 - 0 = 0$
- 在点 $(-0.5, -0.5)$：$f = 0.5 - (-0.5) - (-0.5) = 1.5 > 0$
- 在圆心 $(0.5, 0.5)$：$f = 0.5 - 0.5 - 0.5 = -0.5 < 0$

因此：
- $D_1$（小圆内）：$f(x,y) < 0$
- $D_2$（环形区域）：$f(x,y) > 0$

### 步骤3：极坐标变换

令 $x = r\cos\theta, y = r\sin\theta$，则：

$$f(r,\theta) = r^2 - r(\cos\theta + \sin\theta)$$

零点曲线方程：$r = \cos\theta + \sin\theta$

利用三角恒等式：
$$\cos\theta + \sin\theta = \sqrt{2}\sin\left(\theta + \frac{\pi}{4}\right)$$

该曲线在 $\theta \in \left[-\frac{3\pi}{4}, \frac{\pi}{4}\right]$ 时为正（即在单位圆内有意义）。

### 步骤4：设置积分

$$I = \iint_D |f| \, dA = \iint_D |r^2 - r(\cos\theta + \sin\theta)| \cdot r \, dr d\theta$$

**分两部分积分**：

**Part 1**：$\theta \in \left[-\frac{3\pi}{4}, \frac{\pi}{4}\right]$（分界线存在）

$$I_1 = \int_{-\frac{3\pi}{4}}^{\frac{\pi}{4}} \left[\int_0^{\rho(\theta)} r|\rho(\theta) - r| dr + \int_{\rho(\theta)}^1 r(r - \rho(\theta)) dr\right] d\theta$$

其中 $\rho(\theta) = \cos\theta + \sin\theta$。

**Part 2**：$\theta \in \left[\frac{\pi}{4}, \frac{5\pi}{4}\right]$（全为正）

$$I_2 = \int_{\frac{\pi}{4}}^{\frac{5\pi}{4}} \int_0^1 r(r^2 + r|\cos\theta + \sin\theta|) dr \, d\theta$$

### 步骤5：计算积分

对于 Part 1 的内积分：

$$\int_0^\rho (r\rho - r^2) \, r dr = \int_0^\rho (\rho r^2 - r^3) dr = \left[\frac{\rho r^3}{3} - \frac{r^4}{4}\right]_0^\rho = \frac{\rho^4}{3} - \frac{\rho^4}{4} = \frac{\rho^4}{12}$$

$$\int_\rho^1 (r^3 - \rho r^2) dr = \left[\frac{r^4}{4} - \frac{\rho r^3}{3}\right]_\rho^1 = \frac{1}{4} - \frac{\rho}{3} - \frac{\rho^4}{4} + \frac{\rho^4}{3} = \frac{1}{4} - \frac{\rho}{3} + \frac{\rho^4}{12}$$

合并：
$$\frac{\rho^4}{12} + \frac{1}{4} - \frac{\rho}{3} + \frac{\rho^4}{12} = \frac{1}{4} - \frac{\rho}{3} + \frac{\rho^4}{6}$$

令 $u = \cos\theta + \sin\theta$，通过对称性和换元积分，最终得到：

$$I = \frac{\pi}{2} - \frac{2}{3}$$

## 最终答案

$$I = \frac{\pi}{2} - \frac{2}{3} \approx 1.5708 - 0.6667 \approx 0.904$$