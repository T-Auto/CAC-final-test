# DeepSeek Math-V2 解答

We need to find the number of elements in the union of A and B, where $A = \{1,2,3,...,100\}$ (so $|A| = 100$). $B = \{a^2 + 2^a \mid a \in A\}$. So B is the set of values of the function $f(a) = a^2 + 2^a$ for a from 1 to 100 inclusive.

We need to compute $|A \cup B|$. That is the total distinct numbers that are either in A (i.e., integers from 1 to 100) or are equal to $a^2 + 2^a$ for some $a$ in $A$.

Since A is a set of integers 1..100, and B likely contains numbers that are larger than 100 (since $a^2$ grows and $2^a$ grows fast). But there might be some overlap: some values of $a^2 + 2^a$ might be $\leq 100$ and also be integers in A. If any such values exist, they would be counted in both sets, but we need the union size $= |A| + |B| - |A \cap B|$.

So we need to compute $|B|$ (the number of distinct values among $f(a)$ for $a=1..100$) and the intersection size (how many of those values are $\leq 100$ and also in A).

---

## Analysis of f(a) = a² + 2^a

We can approach by analyzing $f(a) = a^2 + 2^a$. For $a \geq 1$, $2^a$ grows quickly. Let's compute small a values to see which $f(a)$ are $\leq 100$.

Compute:

- $a=1$: $f=1^2+2^1=1+2=3$
- $a=2$: $4+4=8$
- $a=3$: $9+8=17$
- $a=4$: $16+16=32$
- $a=5$: $25+32=57$
- $a=6$: $36+64=100$
- $a=7$: $49+128=177 > 100$
- $a=8$: $64+256=320 > 100$
- $a=9$: $81+512=593 > 100$
- $a=10$: $100+1024=1124 > 100$

From $a=7$ onward, $f(a) > 100$. So $f(6)=100$, which is in $A$ (since $A$ includes 100). Also $f(5)=57$, $f(4)=32$, $f(3)=17$, $f(2)=8$, $f(1)=3$. All these are $\leq 100$ and are in $A$.

So $A \cap B$ includes $\{3,8,17,32,57,100\}$.

Only $a=1..6$ produce $f(a) \leq 100$. So the intersection consists of those six values.

---

## Computing |B|

Now we need to compute $|B|$, the number of distinct values among $f(a)$ for $a=1..100$. Since $f$ is strictly increasing for $a \geq 1$:

$$f(a+1)-f(a) = ((a+1)^2 - a^2) + (2^{a+1} - 2^a) = (2a+1) + 2^a$$

Since $2^a$ is positive and grows, the difference is positive for all $a \geq 1$. Indeed $(2a+1)+2^a > 0$. So $f$ is strictly increasing over integers.

Therefore all $f(a)$ are distinct. So $|B| = 100$ (since a runs over 100 distinct values, and f is injective).

---

## Final Calculation

Thus:
- $|A| = 100$
- $|B| = 100$
- $|A \cap B| = 6$ (the values $\{3, 8, 17, 32, 57, 100\}$)

$$|A \cup B| = |A| + |B| - |A \cap B| = 100 + 100 - 6 = 194$$

---

## Answer

$$\boxed{194}$$

---

## 验证状态

✅ **答案验证结果：正确**

解题过程完整，包含：
1. 正确分析了函数 $f(a) = a^2 + 2^a$ 的单调性
2. 准确计算了所有 $f(a) \leq 100$ 的情况
3. 正确应用容斥原理计算并集元素个数
4. 最终答案 194 正确
