# DeepSeek Math-V2 解答

点集 $\Gamma$ 的方程为 $y^{2}=2x+2|x|$。

- 当 $x<0$ 时，$|x|=-x$，则 $y^{2}=2x+2(-x)=0$，故 $y=0$。
- 当 $x\ge 0$ 时，$|x|=x$，则 $y^{2}=2x+2x=4x$，即 $y^{2}=4x$。

因此 $\Gamma = A\cup B$，其中
- $A=\{(x,0)\mid x\le 0\}$（负半轴及原点）
- $B=\{(x,y)\mid y^{2}=4x,\;x\ge 0\}$（抛物线）

## 分类讨论

设 $P(x_{1},y_{1}),Q(x_{2},y_{2})\in\Gamma$，$M$ 为 $PQ$ 的中点，且 $\overrightarrow{OP}\cdot\overrightarrow{OQ}=-2$。

### 情况Ⅰ：$P,Q$ 都在 $A$ 上

则 $y_{1}=y_{2}=0$，于是 $\overrightarrow{OP}\cdot\overrightarrow{OQ}=x_{1}x_{2}=-2$。

但 $x_{1},x_{2}\le 0$，乘积 $x_{1}x_{2}\ge 0$，矛盾。故不可能。

### 情况Ⅱ：$P,Q$ 都在 $B$ 上

令 $P\bigl(\frac{y_{1}^{2}}{4},y_{1}\bigr),\; Q\bigl(\frac{y_{2}^{2}}{4},y_{2}\bigr)$。则

$$M\Bigl(\frac{y_{1}^{2}+y_{2}^{2}}{8},\frac{y_{1}+y_{2}}{2}\Bigr)$$

因为 $M\in\Gamma$，若 $M\in A$，则 $Y=0\Rightarrow y_{1}+y_{2}=0$。此时 $X=\frac{y_{1}^{2}}{4}>0$（若 $y_{1}\neq0$），但点 $(X,0)$ 属于 $\Gamma$ 当且仅当 $X\le 0$，矛盾。

因此 $M\in B$，即 $Y^{2}=4X$。代入得

$$\frac{(y_{1}+y_{2})^{2}}{4}=\frac{y_{1}^{2}+y_{2}^{2}}{2}$$

化简得 $(y_{1}-y_{2})^{2}=0$，即 $y_{1}=y_{2}$。于是 $P=Q$，与互异矛盾。故情况Ⅱ也不可能。

### 情况Ⅲ：一个点在 $A$ 上，另一个点在 $B$ 上

不妨设 $P\in A,\;Q\in B$。记 $P=(a,0),\;a\le 0$；$Q=\bigl(\frac{c^{2}}{4},c\bigr),\;c\neq0$。

由 $\overrightarrow{OP}\cdot\overrightarrow{OQ}=-2$ 得

$$a\cdot\frac{c^{2}}{4}=-2\quad\Longrightarrow\quad a=-\frac{8}{c^{2}} \tag{1}$$

$M$ 为 $PQ$ 的中点：

$$M\Bigl(\frac{a+\frac{c^{2}}{4}}{2},\frac{c}{2}\Bigr)$$

因为 $c\neq0$，故 $Y=\frac{c}{2}\neq0$，所以 $M$ 必在 $B$ 上，即 $Y^{2}=4X$。

$$\frac{c^{2}}{4}=4\cdot\frac{a+\frac{c^{2}}{4}}{2}=2\bigl(a+\frac{c^{2}}{4}\bigr)$$

化简得 $a=-\frac{c^{2}}{8}$ ...(2)

联立 (1)(2)：

$$-\frac{c^{2}}{8}=-\frac{8}{c^{2}} \;\Longrightarrow\; c^{4}=64 \;\Longrightarrow\; c^{2}=8$$

代入得 $a=-1$。于是

$$P=(-1,0),\qquad Q=\bigl(2,\pm2\sqrt{2}\bigr)$$

$$M=\Bigl(\frac{-1+2}{2},\frac{0\pm2\sqrt{2}}{2}\Bigr)=\Bigl(\frac{1}{2},\pm\sqrt{2}\Bigr)$$

## 验证

- $M$ 满足 $\Gamma$：$(\sqrt{2})^{2}=2$，$2\cdot\frac{1}{2}+2\cdot\frac{1}{2}=2$ ✓
- $P,Q,M$ 互异 ✓
- $\overrightarrow{OP}\cdot\overrightarrow{OQ}=(-1)\times2+0\times(\pm2\sqrt{2})=-2$ ✓

## Answer

$$\boxed{M = \left(\frac{1}{2}, \sqrt{2}\right) \text{ 或 } M = \left(\frac{1}{2}, -\sqrt{2}\right)}$$
