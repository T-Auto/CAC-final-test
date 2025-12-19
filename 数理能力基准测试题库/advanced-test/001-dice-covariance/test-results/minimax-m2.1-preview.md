<thinking>
We need to compute expectation and variance of X and Y, where X is the outcome of first die (uniform 1-6). Y is the maximum of the two dice outcomes (first die X, second die Z, say). So Y = max(X, Z), where Z is independent uniform {1,...,6}.

We need E[X], Var(X), E[Y], Var(Y), and Cov(X,Y).

Let's compute.

First, X ~ Uniform(1..6). E[X] = (1+2+3+4+5+6)/6 = 21/6 = 3.5. Var(X) = E[X^2] - (E[X])^2. E[X^2] = (1^2+2^2+...+6^2)/6 = (1+4+9+16+25+36)/6 = 91/6 ≈ 15.1667. So Var(X) = 91/6 - (3.5)^2 = 91/6 - 12.25 = 91/6 - 73.5/6 = (91 - 73.5)/6 = 17.5/6 = 35/12 ≈ 2.9167.

Now Y = max(X, Z). We need distribution of Y. Since X and Z independent uniform 1..6.

We can compute P(Y = k) = P(max(X,Z) = k) = P(X ≤ k, Z ≤ k) - P(X ≤ k-1, Z ≤ k-1) = [P(X ≤ k) P(Z ≤ k)] - [P(X ≤ k-1) P(Z ≤ k-1)] = (k/6)^2 - ((k-1)/6)^2.

Because X and Z independent and each uniform.

Thus P(Y = k) = (k^2 - (k-1)^2)/36 = (2k-1)/36, for k = 1,...,6.

Check sum: sum_{k=1}^6 (2k-1)/36 = (2*21 - 6)/36 = (42 - 6)/36 = 36/36 = 1.

Now E[Y] = sum_{k=1}^6 k * P(Y=k) = sum_{k=1}^6 k * (2k-1)/36 = (1/36) sum_{k=1}^6 (2k^2 - k).

Compute sum_{k=1}^6 2k^2 = 2 * sum k^2 = 2 * 91 = 182. sum_{k=1}^6 k = 21. So sum (2k^2 - k) = 182 - 21 = 161. So E[Y] = 161/36 ≈ 4.4722.

Alternatively, we can compute using known formula for maximum of two independent discrete uniform variables. Indeed E[max] = (n+1)*(2n+1)/(3n) for n=6? Let's verify: For n uniform {1,...,n}, E[max] = (n+1)*(2n+1)/(3n). For n=6, (7*13)/(18) = 91/18 ≈ 5.0556? That seems too high. Wait that's for continuous uniform [0,1]? Let's not rely.

But we can compute exactly as above: 161/36 ≈ 4.4722.

Now Var(Y) = E[Y^2] - (E[Y])^2.

Compute E[Y^2] = sum_{k=1}^6 k^2 * P(Y=k) = sum k^2 * (2k-1)/36 = (1/36) sum (2k^3 - k^2).

Compute sum_{k=1}^6 k^3 = (6*7/2)^2 = (21)^2 = 441. sum k^2 = 91.

Thus sum (2k^3 - k^2) = 2*441 - 91 = 882 - 91 = 791.

Thus E[Y^2] = 791/36 ≈ 21.9722.

Now Var(Y) = 791/36 - (161/36)^2 = (791/36) - (25921/1296). Convert to common denominator: 1296 = 36^2. So 791/36 = (791*36)/1296 = 28476/1296. Then subtract 25921/1296 = (28476 - 25921)/1296 = 2555/1296.

Thus Var(Y) = 2555/1296 ≈ 1.9725.

Simplify? 2555 and 1296 have gcd? 2555 = 5 * 511 = 5 * 7 * 73? Let's factor: 511 = 7*73. So 2555 = 5*7*73 = 2555. 1296 = 2^4 * 3^4 = 16 * 81 = 1296. No common factor >1. So fraction is simplest.

Thus Var(Y) = 2555/1296.

Now Cov(X,Y) = E[XY] - E[X]E[Y].

We need E[XY] = E[ X * max(X,Z) ].

We can compute using law of total expectation conditioning on X = x.

Given X = x, Y = max(x,Z). So XY = x * max(x,Z). So we can compute E[XY | X = x] = x * E[max(x,Z) | X=x] = x * E[max(x,Z)], where Z independent uniform 1..6.

Thus E[XY] = E[ X * E[max(X,Z) | X] ] = E[ X * g(X) ] where g(x) = E[max(x,Z)].

Compute g(x) = sum_{z=1}^6 max(x,z) * (1/6). For each x from 1 to 6.

Alternatively, we can compute directly: g(x) = (1/6) * sum_{z=1}^6 max(x,z) = (1/6) * [ sum_{z=1}^{x} x + sum_{z=x+1}^{6} z ].

Simplify: sum_{z=1}^{x} x = x * x = x^2. sum_{z=x+1}^{6} z = sum_{z=1}^{6} z - sum_{z=1}^{x} z = 21 - x(x+1)/2.

Thus g(x) = (1/6) * [ x^2 + 21 - x(x+1)/2 ] = (1/6) * [ x^2 + 21 - (x^2 + x)/2 ] = (1/6) * [ x^2 + 21 - (x^2)/2 - x/2 ] = (1/6) * [ (x^2 - (x^2)/2) + 21 - x/2 ] = (1/6) * [ (x^2)/2 + 21 - x/2 ] = (1/6) * [ (x^2 - x)/2 + 21 ] = (1/6) * [ (x(x-1))/2 + 21 ].

Simplify: g(x) = (1/6) * [ (x(x-1))/2 + 21 ] = (1/12) * [ x(x-1) + 42 ] = (x(x-1) + 42) / 12.

Check for x=1: g(1) = (1*0 + 42)/12 = 42/12 = 3.5. Indeed max(1,Z) average is 3.5? Let's compute: Z uniform 1-6, max(1,Z) = Z because Z >=1 always. So average of Z is 3.5. Good.

x=2: g(2) = (2*1 + 42)/12 = (2+42)/12 = 44/12 = 11/3 ≈ 3.6667. Let's check manually: For Z=1, max=2; Z=2..6, max=Z. So sum = 2 + (2+3+4+5+6) = 2 + 20 = 22. Average = 22/6 = 3.6667. Good.

x=3: g(3) = (3*2 + 42)/12 = (6+42)/12 = 48/12 = 4. So average max = 4. Indeed: Z=1,2 => max=3; Z=3..6 => Z. Sum = 3+3 + (3+4+5+6) = 6 + 18 = 24. Average = 24/6 = 4. Good.

x=4: g(4) = (4*3 + 42)/12 = (12+42)/12 = 54/12 = 4.5. Check: Z=1..3 => max=4; Z=4..6 => Z. Sum = 4*3 + (4+5+6) = 12 + 15 = 27. Average = 27/6 = 4.5.

x=5: g(5) = (5*4 + 42)/12 = (20+42)/12 = 62/12 = 31/6 ≈ 5.1667. Check: Z=1..4 => max=5; Z=5..6 => Z. Sum = 5*4 + (5+6) = 20 + 11 = 31. Average = 31/6 ≈ 5.1667.

x=6: g(6) = (6*5 + 42)/12 = (30+42)/12 = 72/12 = 6. Indeed max(6,Z) always 6.

Thus g(x) works.

Now E[XY] = E[ X * g(X) ] = sum_{x=1}^6 x * g(x) * P(X=x). Since X uniform, P(X=x) = 1/6.

Thus E[XY] = (1/6) * sum_{x=1}^6 x * g(x). Compute sum.

Compute x * g(x) for each x.

x=1: 1 * (42/12) = 42/12 = 3.5 = 7/2.

x=2: 2 * (44/12) = 88/12 = 22/3 ≈ 7.3333.

x=3: 3 * (48/12) = 144/12 = 12.

x=4: 4 * (54/12) = 216/12 = 18.

x=5: 5 * (62/12) = 310/12 = 155/6 ≈ 25.8333.

x=6: 6 * (72/12) = 432/12 = 36.

Now sum them: Let's express in common denominator 12 maybe.

Compute each as rational:

x=1: 42/12 = 42/12.

x=2: 88/12.

x=3: 144/12.

x=4: 216/12.

x=5: 310/12.

x=6: 432/12.

Sum numerator: 42 + 88 + 144 + 216 + 310 + 432 = let's sum: 42+88=130; +144=274; +216=490; +310=800; +432=1232.

Thus sum = 1232/12 = 308/3 ≈ 102.6667? Wait 1232/12 = 102.6667? Let's compute: 12*102 = 1224, remainder 8, so 102 + 8/12 = 102 + 2/3 = 308/3 = 102.6667. Yes.

Thus sum_{x} x*g(x) = 1232/12 = 308/3.

Now E[XY] = (1/6) * (308/3) = 308 / 18 = simplify: divide by 2 => 154/9 ≈ 17.1111.

Thus E[XY] = 154/9.

Now compute Cov = E[XY] - E[X]E[Y] = 154/9 - (3.5)*(161/36). Compute 3.5 = 7/2. So E[X]E[Y] = (7/2)*(161/36) = (7*161)/(72) = 1127/72? Let's compute: 7*161 = 1127. So 1127/72.

Now convert 154/9 to denominator 72: multiply numerator and denominator by 8: 154*8 = 1232; denominator 9*8 = 72. So 154/9 = 1232/72.

Thus Cov = 1232/72 - 1127/72 = 105/72 = simplify: divide by 3 => 35/24.

Thus Cov(X,Y) = 35/24 ≈ 1.45833.

Check if positive: Yes, as expected.

Now we have E[X] = 7/2 = 3.5, Var(X) = 35/12 ≈ 2.9167.

E[Y] = 161/36 ≈ 4.4722, Var(Y) = 2555/1296 ≈ 1.9725.

Cov = 35/24 ≈ 1.45833.

Thus answer.

We can also compute correlation if needed: Corr = Cov / sqrt(Var(X)Var(Y)) = (35/24) / sqrt((35/12)*(2555/1296)). Compute maybe.

Compute sqrt: (35/12)*(2555/1296) = (35*2555)/(12*1296) = (89425)/(15552) ≈ 5.75? Let's compute precisely: 35*2555 = 89425. 12*1296 = 15552. So product = 89425/15552. sqrt = sqrt(89425)/sqrt(15552). sqrt(89425) ≈ 299.041? Actually 299^2 = 89401, 300^2 = 90000, so sqrt ≈ 299.04. sqrt(15552) = sqrt(15552) = sqrt(2^? * 3^? etc). 15552 = 2^? * 3^? Let's factor: 15552 = 2^5 * 3^5? Let's compute: 2^5 = 32, 3^5 = 243, product = 7776. That's half. Actually 2^5*3^5 = 7776. Multiply by 2 => 15552 = 2^6 * 3^5 = 64 * 243 = 15552. So sqrt = 2^3 * 3^(5/2) = 8 * 3^(2.5) = 8 * 3^2 * sqrt(3) = 8 * 9 * sqrt(3) = 72 sqrt(3). So sqrt product = sqrt(89425) / (72 sqrt(3)). So correlation = (35/24) * (72 sqrt(3) / sqrt(89425)) = (35*72 sqrt(3)) / (24 sqrt(89425)) = (35*3 sqrt(3)) / (sqrt(89425)) = (105 sqrt(3)) / sqrt(89425). Compute sqrt(89425) = sqrt(5*17885) = not nice. Let's approximate: sqrt(89425) ≈ 299.04. So correlation ≈ 105 * 1.732 / 299.04 = (181.86) / 299.04 ≈ 0.608. So correlation ~0.61.

But not needed.

Now we can present answer.

We can also compute E[Y] using formula: E[Y] = (n+1)*(2n+1)/(3n) for n=6 yields (7*13)/(18) = 91/18 ≈ 5.0556, which is wrong. Actually that formula is for continuous uniform [0,1] maybe? Let's verify known results: For two i.i.d. discrete uniform {1,...,n}, the expected maximum is (n+1)*(2n+1)/(3n). Let's test for n=1: expected max = 1, formula gives (2*3)/(3) = 2? Not correct. So maybe that formula is for continuous uniform [0,1] with two i.i.d. Uniform(0,1): E[max] = 2/3. Not relevant.

Thus we trust our direct computation.

Now we can present the answer in Chinese.

We should present steps: compute distribution of Y, compute E[Y], Var(Y), then compute Cov.

We can also compute Cov by using law of total covariance: Cov(X,Y) = Cov(X, max(X,Z)) = E[X max(X,Z)] - E[X]E[max(X,Z)].

We already computed.

We can also compute directly using formula: Cov(X,Y) = sum_{x} sum_{y} (x - E[X])(y - E[Y]) P(X=x, Y=y). But easier as above.

Thus final answer:

E[X] = 7/2, Var(X) = 35/12.

E[Y] = 161/36, Var(Y) = 2555/1296.

Cov(X,Y) = 35/24.

Alternatively, numeric approximations.

We can also present results as fractions and decimals.

Thus answer.

Now we need to produce final answer in Chinese, with proper formatting.

Will include steps.

Potentially also compute correlation coefficient if desired.

But answer requested: (1) 求 X, Y 的数学期望与方差 (2) 求 Cov(X, Y). So we provide those.

Thus final answer.

Now produce final answer.
</thinking>

**设**  
\(X\) 为第一颗骰子的点数，\(Z\) 为第二颗骰子的点数，且 \(X,Z\) 独立且均匀分布于 \(\{1,2,3,4,5,6\}\)。  
\(Y=\max (X,Z)\)。

---

## 1. 期望与方差

### (1) 第一个骰子 \(X\)

\[
E[X]=\frac{1+2+3+4+5+6}{6}= \frac{21}{6}= \frac{7}{2}=3.5 .
\]

\[
E[X^{2}]=\frac{1^{2}+2^{2}+3^{2}+4^{2}+5^{2}+6^{2}}{6}= \frac{91}{6},
\qquad 
\operatorname{Var}(X)=E[X^{2}]-(E[X])^{2}
 =\frac{91}{6}-\Big(\frac{7}{2}\Big)^{2}
 =\frac{35}{12}\approx 2.9167 .
\]

---

### (2) 最大值 \(Y\)

先求 \(Y\) 的分布：

\[
\begin{aligned}
P(Y=k)&=P(\max (X,Z)=k)\\
      &=P(X\le k,Z\le k)-P(X\le k-1,Z\le k-1)\\
      &=\Big(\frac{k}{6}\Big)^{2}-\Big(\frac{k-1}{6}\Big)^{2}
      =\frac{2k-1}{36},\qquad k=1,\dots ,6 .
\end{aligned}
\]

（显然 \(\sum_{k=1}^{6}P(Y=k)=1\)。）

**期望**

\[
\begin{aligned}
E[Y]&=\sum_{k=1}^{6}k\,P(Y=k)
     =\frac1{36}\sum_{k=1}^{6}k(2k-1)\\
    &=\frac1{36}\sum_{k=1}^{6}(2k^{2}-k)
     =\frac{161}{36}\approx 4.4722 .
\end{aligned}
\]

**二阶矩**

\[
\begin{aligned}
E[Y^{2}]&=\sum_{k=1}^{6}k^{2}P(Y=k)
        =\frac1{36}\sum_{k=1}^{6}k^{2}(2k-1)\\
       &=\frac1{36}\sum_{k=1}^{6}(2k^{3}-k^{2})
        =\frac{791}{36}\approx 21.9722 .
\end{aligned}
\]

**方差**

\[
\operatorname{Var}(Y)=E[Y^{2}]-(E[Y])^{2}
   =\frac{791}{36}-\Big(\frac{161}{36}\Big)^{2}
   =\frac{2555}{1296}\approx 1.9725 .
\]

---

## 2. 协方差 \(\operatorname{Cov}(X,Y)\)

\[
\operatorname{Cov}(X,Y)=E[XY]-E[X]E[Y].
\]

先算 \(E[XY]\)。对已知的 \(X=x\)（\(x=1,\dots ,6\)），

\[
Y=\max (x,Z),\qquad 
E[XY\mid X=x]=x\,E[\max (x,Z)] .
\]

记  

\[
g(x)=E[\max (x,Z)]
    =\frac1{6}\sum_{z=1}^{6}\max (x,z)
    =\frac{x^{2}+21-\frac{x(x+1)}{2}}{6}
    =\frac{x(x-1)+42}{12}.
\]

于是  

\[
E[XY]=\sum_{x=1}^{6}x\,g(x)P(X=x)
     =\frac1{6}\sum_{x=1}^{6}x\,g(x).
\]

计算每一项（已化简为分母 12）：

\[
\begin{array}{c|c|c}
x & g(x) & x\,g(x) \\ \hline
1 & \dfrac{42}{12}=3.5 & \dfrac{42}{12}\\
2 & \dfrac{44}{12}= \dfrac{11}{3} & \dfrac{88}{12}\\
3 & \dfrac{48}{12}=4 & \dfrac{144}{12}\\
4 & \dfrac{54}{12}=4.5 & \dfrac{216}{12}\\
5 & \dfrac{62}{12}= \dfrac{31}{6} & \dfrac{310}{12}\\
6 & \dfrac{72}{12}=6 & \dfrac{432}{12}
\end{array}
\]

\[
\sum_{x=1}^{6}x\,g(x)=\frac{42+88+144+216+310+432}{12}
                     =\frac{1232}{12}
                     =\frac{308}{3}.
\]

故  

\[
E[XY]=\frac1{6}\cdot\frac{308}{3}= \frac{308}{18}= \frac{154}{9}
      \approx 17.1111 .
\]

现在  

\[
E[X]E[Y]=\frac{7}{2}\cdot\frac{161}{36}
        =\frac{1127}{72}.
\]

把 \(E[XY]\) 换成同一分母：

\[
\frac{154}{9}= \frac{1232}{72}.
\]

于是  

\[
\operatorname{Cov}(X,Y)=\frac{1232}{72}-\frac{1127}{72}
                       =\frac{105}{72}
                       =\frac{35}{24}
                       \approx 1.4583 .
\]

---

## 结果汇总

| 随机变量 | 期望 \(E[\cdot]\) | 方差 \(\operatorname{Var}(\cdot)\) |
|----------|-------------------|-----------------------------------|
| \(X\)    | \(\displaystyle \frac{7}{2}=3.5\) | \(\displaystyle \frac{35}{12}\approx 2.9167\) |
| \(Y\)    | \(\displaystyle \frac{161}{36}\approx 4.4722\) | \(\displaystyle \frac{2555}{1296}\approx 1.9725\) |

\[
\boxed{\operatorname{Cov}(X,Y)=\frac{35}{24}\approx 1.4583 } .
\]

（若需相关系数：\(\rho_{X,Y}= \frac{\operatorname{Cov}(X,Y)}{\sqrt{\operatorname{Var}(X)\operatorname{Var}(Y)}}\approx 0.61\)。）