# Question

这道题目看起来远比想象的难


设圆域 $D: x^2+y^2 \le 1$, 求二重积分

$$
I = \iint_{D} \left| x^2 + y^2 - x - y \right| dx dy
$$


# Analysis

## 正确答案

$$I = 1 + \frac{3}{8}\pi \approx 2.178$$


## 解题过程

### 步骤1：分析绝对值内的函数零点

设 $f(x,y) = x^2 + y^2 - x - y$

令 $f(x,y) = 0$，配方得：

$$x^2 - x + y^2 - y = 0$$

$$\left(x - \frac{1}{2}\right)^2 - \frac{1}{4} + \left(y - \frac{1}{2}\right)^2 - \frac{1}{4} = 0$$

$$\left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 = \frac{1}{2}$$

这是圆心在 $C\left(\frac{1}{2}, \frac{1}{2}\right)$，半径为 $r_0 = \frac{\sqrt{2}}{2}$ 的圆。

### 步骤2：判断区域划分

积分区域 $D$ 是单位圆 $x^2 + y^2 \le 1$

圆心 $C$ 到原点距离：$|OC| = \sqrt{\left(\frac{1}{2}\right)^2 + \left(\frac{1}{2}\right)^2} = \frac{\sqrt{2}}{2}$

因为 $|OC| = \frac{\sqrt{2}}{2} = r_0 < 1$，所以小圆完全在单位圆内部。

**区域划分**：
- $D_1$: $f(x,y) < 0$ 的区域（小圆内部）
- $D_2$: $f(x,y) > 0$ 的区域（单位圆内、小圆外部）

因此：
$$I = -\iint_{D_1} (x^2+y^2-x-y) \, dxdy + \iint_{D_2} (x^2+y^2-x-y) \, dxdy$$

$$= -2\iint_{D_1} (x^2+y^2-x-y) \, dxdy + \iint_D (x^2+y^2-x-y) \, dxdy$$

### 步骤3：使用极坐标变换

令 $x = \rho\cos\theta, y = \rho\sin\theta$，$dxdy = \rho \, d\rho d\theta$

$$f(\rho,\theta) = \rho^2 - \rho(\cos\theta + \sin\theta)$$

令 $f(\rho,\theta) = 0$，得分界曲线：

$$\rho = \cos\theta + \sin\theta$$

该曲线在 $\theta \in \left[-\frac{\pi}{4}, \frac{3\pi}{4}\right]$ 时非负（在单位圆内）。

### 步骤4：分区域积分

$$I = -2\int_{-\frac{\pi}{4}}^{0} d\theta \int_0^{\cos\theta+\sin\theta} (\rho^2 - \rho(\cos\theta+\sin\theta))\rho \, d\rho$$

$$-2\int_0^{\frac{\pi}{2}} d\theta \int_0^1 (\rho^2 - \rho(\cos\theta+\sin\theta))\rho \, d\rho$$

$$-2\int_{\frac{\pi}{2}}^{\frac{3\pi}{4}} d\theta \int_0^{\cos\theta+\sin\theta} (\rho^2 - \rho(\cos\theta+\sin\theta))\rho \, d\rho + \int_0^{2\pi} d\theta \int_0^1 \rho^3 \, d\rho$$

### 步骤5：计算具体积分

对于 $\int_0^{\cos\theta+\sin\theta} (\rho^3 - \rho^2(\cos\theta+\sin\theta)) d\rho$：

$$= \frac{\rho^4}{4}\Big|_0^{\cos\theta+\sin\theta} - \frac{(\cos\theta+\sin\theta)\rho^3}{3}\Big|_0^{\cos\theta+\sin\theta}$$

$$= \frac{(\cos\theta+\sin\theta)^4}{4} - \frac{(\cos\theta+\sin\theta)^4}{3} = -\frac{(\cos\theta+\sin\theta)^4}{12}$$

对于 $\int_0^1 (\rho^3 - \rho^2(\cos\theta+\sin\theta)) d\rho$：

$$= \frac{1}{4} - \frac{\cos\theta+\sin\theta}{3}$$

综合计算：

$$I = \frac{1}{6}\int_{-\frac{\pi}{4}}^0 (\cos\theta+\sin\theta)^4 d\theta - \frac{\pi}{4} + \frac{4}{3} + \frac{1}{6}\int_{\frac{\pi}{2}}^{\frac{3\pi}{4}} (\cos\theta+\sin\theta)^4 d\theta + \frac{\pi}{2}$$

令 $t = \theta + \frac{\pi}{4}$，则 $\cos\theta+\sin\theta = \sqrt{2}\sin t$

$$= \frac{2}{3}\int_0^{\frac{\pi}{4}} \sin^4 t \, dt + \frac{2}{3}\int_{\frac{3\pi}{4}}^{\pi} \sin^4 t \, dt + \frac{\pi}{4} + \frac{4}{3}$$

$$= \frac{\pi}{16} - \frac{1}{6} + \frac{\pi}{16} - \frac{1}{6} + \frac{\pi}{4} + \frac{4}{3} = 1 + \frac{3}{8}\pi$$


## 常见错误

**错误1：忽略绝对值**
- 直接对 $x^2+y^2-x-y$ 积分而不考虑正负
- 必须先确定函数的正负区域

**错误2：区域划分错误**
- 没有正确找出分界曲线 $(x-1/2)^2+(y-1/2)^2=1/2$
- 没有判断分界曲线与积分区域的位置关系

**错误3：极坐标转换错误**
- 忘记 Jacobian 行列式 $r$
- 积分形式应为 $\iint f(r,\theta) \cdot r \, dr d\theta$

**错误4：积分限设置错误**
- 未正确确定 $\theta$ 的范围和对应的 $r$ 的范围
- 分界曲线 $r = \cos\theta + \sin\theta$ 只在部分 $\theta$ 值有意义

**错误5：计算疏漏**
- $(\cos\theta+\sin\theta)^4$ 的积分计算复杂，容易出错
- 需要利用三角恒等式化简


## 核心考点

1. **绝对值函数的处理**：通过分析零点确定正负区域
2. **二重积分区域划分**：将积分区域按被积函数正负分割
3. **极坐标变换**：选择合适的坐标系简化计算
4. **配方法**：识别圆的标准方程
5. **几何直观**：判断两圆的位置关系
6. **三角函数恒等变换**：$\cos\theta+\sin\theta = \sqrt{2}\sin(\theta+\pi/4)$
7. **分段积分技巧**：正确设置积分上下限


## 知识扩展

**一般形式的绝对值二重积分**：

$$I = \iint_D |f(x,y)| \, dxdy$$

**求解步骤**：
1. 找零点曲线 $f(x,y) = 0$
2. 判断曲线与区域 $D$ 的关系
3. 将 $D$ 分为 $D_+ = \{(x,y) \in D : f(x,y) \ge 0\}$ 和 $D_- = \{(x,y) \in D : f(x,y) < 0\}$
4. $I = \iint_{D_+} f \, dxdy - \iint_{D_-} f \, dxdy$

**极坐标适用条件**：
- 积分区域是圆、扇形、圆环等
- 被积函数含有 $x^2+y^2$ 形式
- 边界曲线用极坐标表示更简单

**常用三角恒等式**：
- $\cos\theta + \sin\theta = \sqrt{2}\sin(\theta + \pi/4) = \sqrt{2}\cos(\theta - \pi/4)$
- $\cos\theta - \sin\theta = \sqrt{2}\cos(\theta + \pi/4)$
- $(\cos\theta + \sin\theta)^2 = 1 + 2\sin\theta\cos\theta = 1 + \sin(2\theta)$
- $(\cos\theta + \sin\theta)^4 = [1 + \sin(2\theta)]^2$

**二重积分的对称性**：
- 若 $D$ 关于 $y$ 轴对称，$f(x,y)$ 关于 $x$ 为奇函数，则 $\iint_D f \, dxdy = 0$
- 若 $D$ 关于原点对称，利用对称性可简化计算

**数值验证方法**：
- 使用数值积分（如 Simpson 法则）验证解析结果
- 利用软件（Mathematica, MATLAB 等）验证
