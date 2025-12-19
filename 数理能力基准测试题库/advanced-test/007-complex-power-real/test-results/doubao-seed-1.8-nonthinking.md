### 步骤1：将复数转化为三角形式
设复数 $z = \frac{\sin20^\circ}{\cos25^\circ} + \frac{\sin25^\circ}{\cos20^\circ}i = a + bi$，其中：
$a = \frac{\sin20^\circ}{\cos25^\circ}, \quad b = \frac{\sin25^\circ}{\cos20^\circ}$

1.  **计算模长 $|z|$**
    $$
    \begin{align*}
    |z|^2 &= \frac{\sin^220^\circ}{\cos^225^\circ} + \frac{\sin^225^\circ}{\cos^220^\circ} \\
    &=\frac{\sin^220^\circ\cos^220^\circ + \sin^225^\circ\cos^225^\circ}{\cos^225^\circ\cos^220^\circ}\\
    &=\frac{\frac{1}{4}\sin^240^\circ + \frac{1}{4}\sin^250^\circ}{\cos^225^\circ\cos^220^\circ} \\
    &=\frac{\frac{1}{4}(\sin^240^\circ + \cos^240^\circ)}{\cos^225^\circ\cos^220^\circ} = \frac{1}{4\cos^225^\circ\cos^220^\circ}
    \end{align*}
    $$
    $$|z| = \frac{1}{2\cos25^\circ\cos20^\circ}$$

2.  **计算辐角 $\theta$**
    $$
    \begin{align*}
    \sin\theta &= \frac{b}{|z|} = 2\sin25^\circ\cos25^\circ = \sin50^\circ\\
    \cos\theta &= \frac{a}{|z|} =2\sin20^\circ\cos20^\circ = \sin40^\circ=\cos50^\circ
    \end{align*}
    $$
    故 $\theta = 50^\circ$，$z = |z|(\cos50^\circ + i\sin50^\circ)$

### 步骤2：利用棣莫弗定理计算$z^k$
根据棣莫弗定理：
$$z^k = |z|^k(\cos50k^\circ + i\sin50k^\circ)$$
若$z^k \in \mathbb{R}$，则虚部为0，即$\sin50k^\circ =0$。

### 步骤3：求最小正整数$k$
$\sin50k^\circ =0$等价于$50k^\circ =180^\circ\cdot n, n\in \mathbb{Z}$，即
$$k = \frac{18n}{5}$$
当$n=5$时，$k$取最小正整数$18$。

**答案：$\boxed{18}$**