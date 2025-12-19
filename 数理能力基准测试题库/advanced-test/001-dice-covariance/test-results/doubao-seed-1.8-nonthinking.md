### **问题(1)：计算X,Y的数学期望与方差**
#### 1. 随机变量X的分布、期望与方差
X是第一颗骰子的点数，服从1到6的均匀分布：
$$P(X=k)=\frac{1}{6}, \quad k=1,2,3,4,5,6$$

**期望**：
$$E(X)=\frac{1+2+3+4+5+6}{6}=\frac{21}{6}=3.5$$

**方差**：
$$Var(X)=E(X^2)-[E(X)]^2=\frac{1^2+2^2+3^2+4^2+5^2+6^2}{6} - 3.5^2=\frac{91}{6}-\frac{49}{4}=\frac{35}{12}\approx2.9167$$

---
#### 2. 随机变量Y的分布、期望与方差
Y是两颗骰子点数的最大值，Y的可能取值为1到6，计算每个取值的概率：
1.  $P(Y=1)$：两颗骰子都为1，$P=\frac{1}{36}$
 2. $P(Y=2)$：至少一颗为2且不超过2，$P=\frac{2\times2-1}{36}=\frac{3}{36}$
3.  $P(Y=3)$：至少一颗为3且不超过3，$P=\frac{2\times3-1}{36}=\frac{5}{36}$
4.  $P(Y=4)$：$\frac{2\times4-1}{36}=\frac{7}{36}$
5.  $P(Y=5)$：$\frac{2\times5-1}{36}=\frac{9}{36}$
 6. $P(Y=6)$：$\frac{2\times6-1}{36}=\frac{11}{36}$

**期望**：
$$E(Y)=1\times\frac{1}{36} +2\times\frac{3}{36}+3\times\frac{5}{36}+4\times\frac{7}{36}+5\times\frac{9}{36}+6\times\frac{11}{36}=\frac{161}{36}\approx4.4722$$

**方差**：
$$E(Y^2)=1^2\times\frac{1}{36} +2^2\times\frac{3}{36}+3^2\times\frac{5}{36}+4^2\times\frac{7}{36}+5^2\times\frac{9}{36}+6^2\times\frac{11}{36}=\frac{791}{36}$$
$$Var(Y)=\frac{791}{36}-\left(\frac{161}{36}\right)^2=\frac{2555}{1296}\approx1.9715$$

---
### **问题(2)：计算协方差Cov(X,Y)**
根据协方差定义：$Cov(X,Y)=E(XY)-E(X)E(Y)$
1.  **计算$E(XY)$**
    对每个X=k，Y≥k时Y的条件期望：
    $$E(XY)=\sum_{k=1}^6 k\times E(Y|X=k)\times\frac{1}{6}$$
    - 当X=k时，Y的条件分布为max(k, X2)
        - $E(Y|X=k)=k\times\frac{k}{6} + \sum_{m=k+1}^6 m\times\frac{1}{6}=\frac{k^2 + (k+1+k+2+...+6)}{6}=\frac{k^2+\frac{(6+k)(7-k)}{2}}{6}$

    代入计算得：
    $$E(XY)=\frac{1}{6}\left(1\times\frac{161}{36} +2\times\frac{156}{36}+3\times\frac{145}{36}+4\times\frac{128}{36}+5\times\frac{105}{36}+6\times\frac{76}{36}\right)=\frac{105}{12}=8.75$$

 2. 协方差：
$$Cov(X,Y)=8.75 -3.5\times\frac{161}{36}=\frac{35}{24}\approx1.4583$$

---
### 最终答案
1.  $E(X)=3.5, Var(X)=\frac{35}{12}$；$E(Y)=\frac{161}{36}, Var(Y)=\frac{2555}{1296}$
 2. $Cov(X,Y)=\frac{35}{24}$
 