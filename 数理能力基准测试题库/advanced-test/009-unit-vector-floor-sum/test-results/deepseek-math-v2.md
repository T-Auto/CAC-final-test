# DeepSeek Math-V2 解答

We need to find the range of $|\vec{a}+\vec{b}+\vec{c}|$ given that $\vec{a}, \vec{b}, \vec{c}$ are unit vectors in the plane satisfying:

$$\vec{a} \cdot \vec{b} = \lfloor \vec{a} \cdot \vec{c} \rfloor + \lfloor \vec{b} \cdot \vec{c} \rfloor$$

## Step 1: Analyze the constraint

Let $\vec{a} \cdot \vec{b} = \cos\theta$. Since the RHS is an integer and $\cos\theta \in [-1, 1]$, we have:

$$\cos\theta \in \{-1, 0, 1\}$$

## Step 2: Case $\cos\theta = 1$ (i.e., $\vec{a} = \vec{b}$)

The condition becomes $2\lfloor \vec{a} \cdot \vec{c} \rfloor = 1$, which requires $\lfloor \vec{a} \cdot \vec{c} \rfloor = 0.5$.

This is impossible since floor function returns integers. **No solution.**

## Step 3: Case $\cos\theta = -1$ (i.e., $\vec{b} = -\vec{a}$)

The condition becomes $\lfloor \cos\varphi \rfloor + \lfloor -\cos\varphi \rfloor = -1$.

This holds when $\cos\varphi \in (-1, 0) \cup (0, 1)$.

Then $\vec{a} + \vec{b} = \vec{0}$, so:

$$|\vec{a} + \vec{b} + \vec{c}| = |\vec{c}| = 1$$

## Step 4: Case $\cos\theta = 0$ (i.e., $\vec{a} \perp \vec{b}$)

Set $\vec{a} = (1, 0)$, $\vec{b} = (0, 1)$, $\vec{c} = (\cos\alpha, \sin\alpha)$.

The condition becomes:

$$\lfloor \cos\alpha \rfloor + \lfloor \sin\alpha \rfloor = 0$$

This requires both $\lfloor \cos\alpha \rfloor = 0$ and $\lfloor \sin\alpha \rfloor = 0$, i.e., $\cos\alpha, \sin\alpha \in [0, 1)$.

This gives $\alpha \in (0, \frac{\pi}{2})$ (excluding endpoints).

## Step 5: Compute the magnitude

$$|\vec{a} + \vec{b} + \vec{c}|^2 = |(\!1\!+\!\cos\alpha, 1\!+\!\sin\alpha)|^2 = 3 + 2(\cos\alpha + \sin\alpha)$$

Let $t = \cos\alpha + \sin\alpha = \sqrt{2}\sin(\alpha + \frac{\pi}{4})$.

For $\alpha \in (0, \frac{\pi}{2})$:
- As $\alpha \to 0^+$ or $\alpha \to \frac{\pi}{2}^-$: $t \to 1$
- At $\alpha = \frac{\pi}{4}$: $t = \sqrt{2}$

So $t \in (1, \sqrt{2}]$, giving:

$$|\vec{a} + \vec{b} + \vec{c}|^2 \in (5, 3 + 2\sqrt{2}]$$

$$|\vec{a} + \vec{b} + \vec{c}| \in (\sqrt{5}, \sqrt{3 + 2\sqrt{2}}] = (\sqrt{5}, 1 + \sqrt{2}]$$

(Note: $(1+\sqrt{2})^2 = 3 + 2\sqrt{2}$)

## Answer

$$\boxed{\{1\} \cup (\sqrt{5}, 1+\sqrt{2}]}$$
