# DeepSeek Math-V2 解答

We need to find the maximum value of $f(x)$ given that $f$ is defined on $\mathbb{R}$, and $g(x) = (x-1)f(x)$ is odd, $h(x) = f(x) + x$ is even.

## Step 1: Use the even function condition

Given $h(x) = f(x) + x$ is even, we have $h(-x) = h(x)$:

$$f(-x) + (-x) = f(x) + x$$

$$f(-x) - x = f(x) + x$$

$$f(-x) = f(x) + 2x \quad \text{...(2)}$$

## Step 2: Use the odd function condition

Given $g(x) = (x-1)f(x)$ is odd, we have $g(-x) = -g(x)$:

$$(-x - 1)f(-x) = -(x-1)f(x)$$

Compute left side: $(-x - 1)f(-x) = -(x+1)f(-x)$

So we have:

$$-(x+1)f(-x) = -(x-1)f(x)$$

Multiply both sides by $-1$:

$$(x+1)f(-x) = (x-1)f(x) \quad \text{...(1')}$$

## Step 3: Solve for f(x)

Substitute $f(-x)$ from (2) into (1'):

$$(x+1)(f(x) + 2x) = (x-1)f(x)$$

Expand:

$$(x+1)f(x) + 2x(x+1) = (x-1)f(x)$$

Bring terms with $f(x)$ to one side:

$$(x+1)f(x) - (x-1)f(x) + 2x(x+1) = 0$$

$$[(x+1) - (x-1)]f(x) + 2x(x+1) = 0$$

$$(x + 1 - x + 1)f(x) + 2x(x+1) = 0$$

$$2f(x) + 2x(x+1) = 0$$

Divide by 2:

$$f(x) + x(x+1) = 0$$

$$f(x) = -x(x+1) = -x^2 - x$$

## Step 4: Verify the solution

**Check $h(x) = f(x) + x$ is even:**

$$h(x) = -x^2 - x + x = -x^2$$

Since $-x^2$ is even (because $(-x)^2 = x^2$), $h(x)$ is even. ✓

**Check $g(x) = (x-1)f(x)$ is odd:**

$$g(x) = (x-1)(-x^2 - x) = -(x-1)(x^2 + x) = -(x-1)x(x+1) = -x(x-1)(x+1)$$

$$g(-x) = -(-x)(-x-1)(-x+1) = -(-x)(-(x+1))(-(x-1))$$

Simplify: $-(-x) = x$, and $(-(x+1))(-(x-1)) = (x+1)(x-1)$

$$g(-x) = x(x+1)(x-1) = x(x-1)(x+1)$$

And $-g(x) = -(-x(x-1)(x+1)) = x(x-1)(x+1)$

So $g(-x) = -g(x)$. ✓

## Step 5: Find the maximum value

$f(x) = -x^2 - x$ is a quadratic with leading coefficient $-1$ (negative), so it opens downward and has a maximum at its vertex.

Vertex at $x = -\dfrac{b}{2a}$ for $f(x) = ax^2 + bx + c$:

Here $a = -1$, $b = -1$, $c = 0$.

$$x = -\dfrac{-1}{2 \times (-1)} = \dfrac{1}{-2} = -\dfrac{1}{2}$$

Maximum value:

$$f\left(-\dfrac{1}{2}\right) = -\left(-\dfrac{1}{2}\right)^2 - \left(-\dfrac{1}{2}\right) = -\dfrac{1}{4} + \dfrac{1}{2} = \dfrac{1}{4}$$

## Answer

$$\boxed{\dfrac{1}{4}}$$
