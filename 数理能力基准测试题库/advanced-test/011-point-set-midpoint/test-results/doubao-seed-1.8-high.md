### 步骤1：化简点集$\Gamma$

根据绝对值的定义，分情况讨论：
- 当$x \geq 0$时，$|x|=x$，因此$y^2 = 2x + 2x = 4x$，即$\Gamma$的这部分是开口向右的抛物线$y^2 = 4x$（$x \geq 0$）。
- 当$x < 0$时，$|x|=-x$，因此$y^2 = 2x - 2x = 0$，即$y=0$（$x < 0$），这是$x$轴的负半轴（不含原点）。

综上，$\Gamma$由两部分组成：
1.  抛物线$C: y^2 = 4x$（$x \geq 0$）；
2.  射线$L: y=0$（$x < 0$）。


### 步骤2：分析$P, Q, M$的位置关系

已知$M, P, Q$是$\Gamma$中三个不同的点，且$M$是$PQ$的中点，$\overrightarrow{OP} \cdot \overrightarrow{OQ} = -2$。我们分情况讨论$P, Q$的位置：

#### 情况1：$P, Q$均在射线$L$上（$x < 0, y=0$）
设$P(x_1, 0)$，$Q(x_2, 0)$（$x_1 < 0, x_2 < 0$），则$\overrightarrow{OP} \cdot \overrightarrow{OQ} = x_1x_2$。由于$x_1, x_2 < 0$，故$x_1x_2 > 0$，与$\overrightarrow{OP} \cdot \overrightarrow{OQ} = -2$矛盾，排除此情况。

#### 情况2：$P, Q$均在抛物线$C$上（$x \geq 0, y^2=4x$）
设$P(x_1, y_1)$，$Q(x_2, y_2)$，则$y_1^2 = 4x_1$，$y_2^2 = 4x_2$。
$M$是$PQ$的中点，故$M\left( \frac{x_1+x_2}{2}, \frac{y_1+y_2}{2} \right)$。由于$x_1, x_2 \geq 0$，$\frac{x_1+x_2}{2} \geq 0$，因此$M$在抛物线$C$上，满足：
$$\left( \frac{y_1+y_2}{2} \right)^2 = 4 \cdot \frac{x_1+x_2}{2}$$
展开得：
$$\frac{(y_1+y_2)^2}{4} = 2(x_1+x_2) \implies y_1^2 + 2y_1y_2 + y_2^2 = 8(x_1+x_2)$$
代入$y_1^2=4x_1$，$y_2^2=4x_2$，化简得：
$$4(x_1+x_2) + 2y_1y_2 = 8(x_1+x_2) \implies y_1y_2 = 2(x_1+x_2)$$

结合$\overrightarrow{OP} \cdot \overrightarrow{OQ} = x_1x_2 + y_1y_2 = -2$，且$x_1 = \frac{y_1^2}{4}$，$x_2 = \frac{y_2^2}{4}$，故$x_1x_2 = \frac{(y_1y_2)^2}{16}$。设$t = y_1y_2$，则：
$$\frac{t^2}{16} + t = -2 \implies t^2 + 16t + 32 = 0$$
解得$t = -8 \pm 4\sqrt{2}$，均为负数。但$y_1y_2 = 2(x_1+x_2)$，而$x_1+x_2 \geq 0$，故$t \geq 0$，矛盾。因此此情况无解。

#### 情况3：$P$在射线$L$上，$Q$在抛物线$C$上（对称地，$Q$在$L$上，$P$在$C$上结果一致）
设$P(x_1, 0)$（$x_1 < 0$），$Q(x_2, y_2)$（$x_2 \geq 0, y_2^2=4x_2, y_2 \neq 0$）。
$M$是$PQ$的中点，故$M\left( \frac{x_1+x_2}{2}, \frac{y_2}{2} \right)$，且$M \in \Gamma$，分两种子情况：

- **子情况3.1：$M$在射线$L$上**：则$\frac{y_2}{2} = 0 \implies y_2=0$，此时$Q(x_2, 0)$，代入抛物线得$x_2=0$（即$Q(0,0)$），$\overrightarrow{OP} \cdot \overrightarrow{OQ} = 0 \neq -2$，矛盾，排除。

- **子情况3.2：$M$在抛物线$C$上**：则$\left( \frac{y_2}{2} \right)^2 = 4 \cdot \frac{x_1+x_2}{2}$，即$\frac{y_2^2}{4} = 2(x_1+x_2)$。由于$y_2^2=4x_2$，代入得：
  $$\frac{4x_2}{4} = 2(x_1+x_2) \implies x_2 = 2x_1 + 2x_2 \implies x_2 = -2x_1$$

  结合$\overrightarrow{OP} \cdot \overrightarrow{OQ} = x_1x_2 + 0 \cdot y_2 = x_1x_2 = -2$，将$x_2=-2x_1$代入得：
  $$x_1 \cdot (-2x_1) = -2 \implies -2x_1^2 = -2 \implies x_1^2=1$$
  由于$x_1 < 0$，故$x_1=-1$，从而$x_2=-2 \times (-1)=2$。

  代入$y_2^2=4x_2=8$，得$y_2 = \pm 2\sqrt{2}$，因此$M$的坐标为：
  $$\left( \frac{-1+2}{2}, \frac{\pm 2\sqrt{2}}{2} \right) = \left( \frac{1}{2}, \pm \sqrt{2} \right)$$

  验证：$M\left( \frac{1}{2}, \pm \sqrt{2} \right)$满足抛物线方程$(\pm \sqrt{2})^2 = 4 \times \frac{1}{2} = 2$，且$M, P, Q$为不同点，符合条件。


### 最终结论
点$M$的坐标为$\left( \frac{1}{2}, \sqrt{2} \right)$和$\left( \frac{1}{2}, -\sqrt{2} \right)$。

$\boxed{\left( \dfrac{1}{2}, \sqrt{2} \right)}$ 和 $\boxed{\left( \dfrac{1}{2}, -\sqrt{2} \right)}$