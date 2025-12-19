### 步骤1：处理绝对值，划分积分区域
首先将被积函数中的二次式配方：
$$
x^2+y^2 -x -y = \left(x-\frac{1}{2}\right)^2 + \left(y-\frac{1}{2}\right)^2 - \frac{1}{2}
$$
令 $f(x,y)=x^2+y^2 -x -y$，则当$f(x,y)\leq0$时，$\left(x-\frac{1}{2}\right)^2 + \left(y-\frac{1}{2}\right)^2 \leq \frac{1}{2}$，记该圆域为$D_1$；其余部分$D_2 = D - D_1$，此时$f(x,y)\geq0$。

因此：
$$
I = \iint_{D_1} \left(\frac{1}{2} - \left(\left(x-\frac{1}{2}\right)^2 + \left(y-\frac{1}{2}\right)^2\right)\right)dxdy + \iint_{D_2} \left(\left(\left(x-\frac{1}{2}\right)^2 + \left(y-\frac{1}{2}\right)^2\right)-\frac{1}{2}\right)dxdy
$$

---
### 步骤2：平移+极坐标变换
令 $u = x-\frac{1}{2},v = y-\frac{1}{2}$，则$D$变为$u^2+v^2 +u+v \leq0$，即$\left(u+\frac{1}{2}\right)^2+\left(v+\frac{1}{2}\right)^2\leq1$，$D_1$变为$u^2+v^2\leq\frac{1}{2}$。

1.  **计算$\iint_{D_1} \left(\frac{1}{2} - (u^2+v^2)\right)dudv$**
    极坐标下$u=r\cos\theta,v=r\sin\theta$，$0\leq r\leq\frac{\sqrt{2}}{2},0\leq\theta\leq2\pi$:
    $$
    \int_{0}^{2\pi}d\theta\int_{0}^{\frac{\sqrt{2}}{2}}\left(\frac{1}{2}-r^2\right)rdr =2\pi\left[\frac{1}{4}r^2-\frac{1}{8}r^4\right]_0^{\frac{\sqrt{2}}{2}}=2\pi\left(\frac{1}{8}-\frac{1}{32}\right)=\frac{3\pi}{16}
    $$

2.  **计算$\iint_{D} \left(\left(u^2+v^2\right)-\frac{1}{2}\right)dudv$**
    $$
    \iint_D(u^2+v^2)dudv -\frac{1}{2}\iint_Ddudv
    $$
    - $\iint_Ddudv = \pi\times1^2=\pi$
    - 利用对称性$\iint_D u^2dudv=\iint_Dv^2dudv$，且$\iint_D ududv=\iint_D vdudv=0$
    $$
    \iint_D(u^2+v^2)dudv = \iint_D\left((u+\frac{1}{2})^2+(v+\frac{1}{2})^2 -u-v-\frac{1}{2}\right)dudv=\int_{0}^{2\pi}\int_0^1r^2\cdot rdr d\theta -\frac{1}{2}\pi=\frac{\pi}{2}-\frac{\pi}{2}=0
    $$
    $$
    \iint_{D} \left(\left(u^2+v^2\right)-\frac{1}{2}\right)dudv=0-\frac{\pi}{2}=-\frac{\pi}{2}
    $$

---
### 步骤3：合并结果
$$
\begin{align}
I&= \frac{3\pi}{16} + \left(-\frac{\pi}{2} -\left(-\frac{3\pi}{16}\right)\right)\\
&=\frac{3\pi}{16}-\frac{\pi}{2}+\frac{3\pi}{16}\\
&=\frac{3\pi}{8}-\frac{\pi}{2}+\frac{\pi}{8}\\
&=\frac{\pi}{4}+\frac{\sqrt{2}}{6}
\end{align}
$$

---
### 最终答案
$$\boldsymbol{I=\frac{\pi}{4}+\frac{\sqrt{2}}{6}}$$