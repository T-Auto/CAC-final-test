# DeepSeek Math-V2 解答

We need to find the smallest positive integer $k$ such that

$$z = \frac{\sin 20^\circ}{\cos 25^\circ} + \frac{\sin 25^\circ}{\cos 20^\circ}\, i$$

raised to the $k$-th power is a real number.

---

## Step 1: Compute the argument of z

Let $a = \dfrac{\sin 20^\circ}{\cos 25^\circ}$, $b = \dfrac{\sin 25^\circ}{\cos 20^\circ}$. So $z = a + bi$.

Both $a > 0$ and $b > 0$, so $z$ lies in the first quadrant. Its argument $\theta$ satisfies:

$$\tan\theta = \frac{b}{a} = \frac{\frac{\sin 25^\circ}{\cos 20^\circ}}{\frac{\sin 20^\circ}{\cos 25^\circ}} = \frac{\sin 25^\circ \cos 25^\circ}{\sin 20^\circ \cos 20^\circ}$$

---

## Step 2: Simplify using double-angle formula

Using $\sin\alpha\cos\alpha = \frac{1}{2}\sin 2\alpha$:

$$\tan\theta = \frac{\frac{1}{2}\sin 50^\circ}{\frac{1}{2}\sin 40^\circ} = \frac{\sin 50^\circ}{\sin 40^\circ}$$

Since $\sin 40^\circ = \cos 50^\circ$ (complementary angles):

$$\tan\theta = \frac{\sin 50^\circ}{\cos 50^\circ} = \tan 50^\circ$$

Because $\theta$ is in the first quadrant, we obtain:

$$\theta = 50^\circ = \frac{5\pi}{18}$$

---

## Step 3: Condition for z^k to be real

$z^k$ is real exactly when its argument is an integer multiple of $\pi$:

$$k\theta \equiv 0 \pmod{\pi}$$

This means:

$$k \cdot \frac{5\pi}{18} = m\pi \quad \text{for some integer } m$$

Cancelling $\pi$:

$$\frac{5k}{18} = m$$

So $5k = 18m$. Since $\gcd(5, 18) = 1$, we need $18 \mid k$.

---

## Step 4: Find the minimum k

The smallest positive integer $k$ occurs when $k = 18$.

**Verification:** When $k = 18$:
- $k\theta = 18 \times 50^\circ = 900^\circ = 2 \times 360^\circ + 180^\circ$
- $\cos 180^\circ = -1$, $\sin 180^\circ = 0$
- So $z^{18}$ is a negative real number ✓

---

## Answer

$$\boxed{18}$$

---

## 验证状态

✅ **答案验证结果：正确**

解题过程完整，包含：
1. 正确计算复数的辐角为 $50^\circ$
2. 熟练运用三角恒等变换（二倍角公式、互余关系）
3. 正确分析复数幂次为实数的条件
4. 整除性分析严谨，最终答案 $18$ 正确
