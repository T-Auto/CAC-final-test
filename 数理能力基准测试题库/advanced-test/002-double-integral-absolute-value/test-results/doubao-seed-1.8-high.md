要计算二重积分 \( I = \iint_{D} \left| x^2 + y^2 - x - y \right| dx dy \)（其中 \( D: x^2 + y^2 \le 1 \)），步骤如下：


### **步骤1：处理绝对值，拆分积分区域**
首先对被积函数中的表达式配方：
\[
x^2 + y^2 - x - y = \left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 - \frac{1}{2}
\]
绝对值的零点为圆 \( C: \left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 = \frac{1}{2} \)，其圆心为 \( \left(\frac{1}{2}, \frac{1}{2}\right) \)，半径 \( r = \frac{\sqrt{2}}{2} \)。

圆 \( C \) 与 \( D \)（单位圆 \( x^2 + y^2 \le 1 \)）的交点满足：
\[
\begin{cases}
\left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 = \frac{1}{2} \\
x^2 + y^2 = 1
\end{cases}
\]
代入化简得 \( x + y = 1 \)，解得交点为 \( (0,1) \) 和 \( (1,0) \)。

因此，\( D \) 被圆 \( C \) 分为两部分：
- \( D_1 \)：\( D \cap \left\{ \left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 \le \frac{1}{2} \right\} \)，此时 \( x^2 + y^2 - x - y \le 0 \)，绝对值可拆为 \( x + y - x^2 - y^2 \)。
- \( D_2 \)：\( D \cap \left\{ \left(x - \frac{1}{2}\right)^2 + \left(y - \frac{1}{2}\right)^2 \ge \frac{1}{2} \right\} \)，此时 \( x^2 + y^2 - x - y \ge 0 \)，绝对值可拆为 \( x^2 + y^2 - x - y \)。

于是积分拆分为：
\[
I = \iint_{D_1} (x + y - x^2 - y^2) dxdy + \iint_{D_2} (x^2 + y^2 - x - y) dxdy
\]


### **步骤2：计算 \( \iint_{D_1} (x + y - x^2 - y^2) dxdy \)（记为 \( I_1 \)）**
通过平移坐标系简化计算：令 \( u = x - \frac{1}{2} \)，\( v = y - \frac{1}{2} \)，则：
- 被积函数变为 \( \frac{1}{2} - u^2 - v^2 \)（配方化简可得）。
- \( D_1 \) 变为 \( u^2 + v^2 \le \frac{1}{2} \) 且 \( (u + \frac{1}{2})^2 + (v + \frac{1}{2})^2 \le 1 \)（即原区域 \( D \) 平移后的形式）。

利用极坐标计算 \( \iint_{u^2 + v^2 \le \frac{1}{2}} \left( \frac{1}{2} - u^2 - v^2 \right) dudv \)：
\[
\int_0^{2\pi} d\theta \int_0^{\frac{\sqrt{2}}{2}} \left( \frac{1}{2} - \rho^2 \right) \rho d\rho = 2\pi \cdot \left[ \frac{\rho^2}{4} - \frac{\rho^4}{4} \right]_0^{\frac{\sqrt{2}}{2}} = \frac{\pi}{8}
\]

再计算 \( u^2 + v^2 \le \frac{1}{2} \) 但不在 \( (u + \frac{1}{2})^2 + (v + \frac{1}{2})^2 \le 1 \) 内的部分积分（记为 \( J \)），通过极坐标和变量替换可得：
\[
J = \frac{3\pi}{16} - \frac{1}{2}
\]

因此：
\[
I_1 = \frac{\pi}{8} - J = \frac{\pi}{8} - \left( \frac{3\pi}{16} - \frac{1}{2} \right) = -\frac{\pi}{16} + \frac{1}{2}
\]


### **步骤3：利用区域对称性计算 \( \iint_D (x^2 + y^2 - x - y) dxdy \)**
由于 \( D \) 关于原点对称，\( x \) 和 \( y \) 是奇函数，故 \( \iint_D (x + y) dxdy = 0 \)。

计算 \( \iint_D (x^2 + y^2) dxdy \)（极坐标）：
\[
\int_0^{2\pi} d\theta \int_0^1 \rho^2 \cdot \rho d\rho = 2\pi \cdot \left[ \frac{\rho^4}{4} \right]_0^1 = \frac{\pi}{2}
\]

因此：
\[
\iint_D (x^2 + y^2 - x - y) dxdy = \frac{\pi}{2} - 0 = \frac{\pi}{2}
\]


### **步骤4：联立求解 \( I \)**
注意到 \( \iint_D (x^2 + y^2 - x - y) dxdy = \iint_{D_1} (x^2 + y^2 - x - y) dxdy + \iint_{D_2} (x^2 + y^2 - x - y) dxdy \)，而 \( \iint_{D_1} (x^2 + y^2 - x - y) dxdy = -I_1 \)，因此：
\[
\frac{\pi}{2} = -I_1 + \iint_{D_2} (x^2 + y^2 - x - y) dxdy
\]
即 \( \iint_{D_2} (x^2 + y^2 - x - y) dxdy = \frac{\pi}{2} + I_1 \)。

最终：
\[
I = I_1 + \left( \frac{\pi}{2} + I_1 \right) = 2I_1 + \frac{\pi}{2}
\]

代入 \( I_1 = -\frac{\pi}{16} + \frac{1}{2} \)：
\[
I = 2\left( -\frac{\pi}{16} + \frac{1}{2} \right) + \frac{\pi}{2} = -\frac{\pi}{8} + 1 + \frac{\pi}{2} = 1 + \frac{3\pi}{8}
\]


### **最终结果**
\[
\boxed{I = 1 + \frac{3\pi}{8}}
\]