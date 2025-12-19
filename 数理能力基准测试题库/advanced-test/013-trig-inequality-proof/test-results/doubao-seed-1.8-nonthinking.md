### 证明过程：

#### 步骤1：去分母简化不等式
原不等式为：
$$\frac{1}{|\sin m\alpha|} + \frac{1}{|\sin n\alpha|} > \frac{1}{m \cdot |\sin m\alpha \cdot \sin n\alpha| + |\sin mn\alpha|}$$

由于分母均为正数，两边同时乘以正数 $|\sin m\alpha|\cdot|\sin n\alpha|\cdot\left(m|\sin m\alpha\sin n\alpha| + |\sin mn\alpha|\right)$，等价于证明：
$$\left(|\sin n\alpha| + |\sin m\alpha|\right)\cdot\left(m|\sin m\alpha\sin n\alpha| + |\sin mn\alpha|\right) > |\sin m\alpha|\cdot|\sin n\alpha|$$

#### 步骤2：放缩左侧第一项
注意到 $|\sin n\alpha| + |\sin m\alpha| \geq 2\sqrt{|\sin m\alpha|\cdot|\sin n\alpha|}$（均值不等式），我们先证明更强的结论：
$$2\sqrt{|\sin m\alpha|\cdot|\sin n\alpha|}\cdot\left(m|\sin m\alpha\sin n\alpha| + |\sin mn\alpha|\right) > |\sin m\alpha|\cdot|\sin n\alpha|$$

令 $x = \sqrt{|\sin m\alpha|\cdot|\sin n\alpha|}>0$，则只需证明：
$$2\left(mx^4 + x^2|\sin mn\alpha|\right) > x^4$$
即：
$$(2m-1)x^4 + 2x^2|\sin mn\alpha| >0$$

#### 步骤3：利用三角恒等式放缩$|\sin mn\alpha|$
利用积化和差与数学归纳法可证：$|\sin mn\alpha| \leq mn|\sin \alpha|$，同时注意到：
$$|\sin m\alpha| \leq m|\sin\alpha|,\quad |\sin n\alpha|\leq n|\sin\alpha|$$
因此 $x^2 = |\sin m\alpha\sin n\alpha|\leq mn|\sin\alpha|^2$，且：
$$|\sin mn\alpha|\geq \left||\sin m\alpha|^n - |\cos m\alpha|^n\right|\cdot|\sin m\alpha|^{n(n-1)/2} >0$$
由于题目条件 $\sin m\alpha\sin n\alpha\neq0$，故 $|\sin mn\alpha|>0$，$x>0$。

#### 步骤4：分情况讨论
1.  当 $m\geq1$时，$2m-1\geq1>0$，此时：
    $$(2m-1)x^4 + 2x^2|\sin mn\alpha| \geq x^4 >0$$
    显然成立。

2.  当 $m=1$时，原不等式退化为：
    $$\frac{1}{|\sin \alpha|} + \frac{1}{|\sin n\alpha|} > \frac{1}{|\sin \alpha\sin n\alpha| + |\sin n\alpha|} = \frac{1}{|\sin n\alpha|(|\sin\alpha|+1)}$$
    由于 $\frac{1}{|\sin\alpha|} >0$，且 $\frac{1}{|\sin n\alpha|} > \frac{1}{|\sin n\alpha|(|\sin\alpha|+1)}$，显然成立。

#### 步骤5：回溯原不等式
由于我们证明了更强的结论，原不等式自然成立。

### 最终结论
综上：
$$\frac{1}{|\sin m\alpha|} + \frac{1}{|\sin n\alpha|} > \frac{1}{m \cdot |\sin m\alpha \cdot \sin n\alpha| + |\sin mn\alpha|}$$
证毕。