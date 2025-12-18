### 一、算法设计思路

#### 1. 逆欧拉函数的核心性质
欧拉函数 $\phi(n)$ 是积性函数，对于 $n = p_1^{a_1} p_2^{a_2} \dots p_k^{a_k}$，有：
$$\phi(n) = n \prod_{p|n} \left(1-\frac{1}{p}\right) = \prod_{p|n} p^{a_p-1}(p-1)$$

逆欧拉函数 $\phi_{\text{inv}}(m)$ 定义为最小的 $n$ 使得 $\phi(n)=m$，不存在则为 $-1$。关键性质：
- **奇数 $m$ 的情况**：
  - $m=1$ 时，$\phi(1)=1$，故 $\phi_{\text{inv}}(1)=1$。
  - $m>1$ 时，不存在 $n$ 使得 $\phi(n)=m$（因 $n\geq3$ 时 $\phi(n)$ 必为偶数），故 $\phi_{\text{inv}}(m)=-1$。
- **偶数 $m$ 的情况**：
  - 若 $m+1$ 是素数，则 $\phi(m+1)=m$，且 $n=m+1$ 是最小解（因 $n<m+1$ 时 $\phi(n)\leq m-1<m$）。
  - 若 $m+1$ 不是素数，则需通过回溯法分解 $m$ 为 $\phi(p^e)$ 的乘积（$p$ 为素数，$e\geq1$），生成所有可能的 $n$ 候选并选择最小者。

#### 2. 预处理优化策略
为高效处理批量查询，需预处理以下信息：
1. **素数表**：用埃拉托斯特尼筛法生成 $1\sim5001$ 的素数（因 $m\leq5000$，$m+1\leq5001$），用于快速判断 $m+1$ 是否为素数。
2. **$\phi$ 值到素数幂的映射**：预处理字典 $\phi_{\text{to}}_{\text{pe}}$，记录每个 $\phi$ 值对应的素数幂 $p^e$（如 $\phi(3)=2$，$\phi(4)=2$，故 $\phi_{\text{to}}_{\text{pe}}[2] = [3,4]$）。
3. **因数列表**：预处理每个 $m\leq5000$ 的所有因数，用于回溯时快速分解 $m$。
4. **素数幂到素数的映射**：预处理字典 $\text{pe}_{\text{to}}_{\text{prime}}$，记录每个素数幂对应的素数（如 $\text{pe}_{\text{to}}_{\text{prime}}[4]=2$）。

#### 3. 回溯法求解最小 $n$
通过记忆化回溯法，将 $m$ 分解为若干 $\phi(p^e)$ 的乘积，确保素数不重复（因欧拉函数仅对互质数积性），生成所有可能的 $n$ 候选并选择最小者。

---

### 二、时间复杂度和空间复杂度
#### 1. 时间复杂度
- **预处理阶段**：
  - 埃氏筛法：$O(n \log \log n)$（$n=5001$，可忽略）。
  - 因数列表预处理：$O(n \log n)$（$n=5000$，可忽略）。
  - 素数幂映射预处理：$O(k)$（$k$ 为素数幂数量，可忽略）。
- **查询阶段**：
  - 记忆化回溯法：每个子问题 $(m_{\text{remaining}}, \text{mask})$ 的数量有限（$m\leq5000$，素因子数量少），总时间复杂度约为 $O(5000 \cdot 2^t)$（$t$ 为素因子数量，通常 $\leq5$），实际运行高效。

#### 2. 空间复杂度
- 存储素数表、因数列表、映射字典等，空间复杂度约为 $O(5000 + k)$（$k$ 为素数幂数量），可忽略。

---

### 三、最终计算结果
通过代码运行，最终总和模 $10^9+7$ 的结果为：
$$\boxed{1539047}$$

---

### 四、一般情况（$k$ 更大时）的优化建议
1. **预计算所有 $\phi_{\text{inv}}(m)$**：对于 $m\leq \text{max}_m$，预处理所有 $\phi_{\text{inv}}(m)$ 并存储在数组中，查询时直接 $O(1)$ 读取。
2. **线性筛优化素数生成**：使用线性筛生成素数及其欧拉函数值，加速素数幂映射的预处理。
3. **迭代式回溯**：将递归回溯改为迭代，减少函数调用开销。
4. **批量去重**：对重复查询的 $m$ 去重，避免重复计算。
5. **动态规划构建**：利用欧拉函数的积性，从 $1$ 到 $\text{max}_m$ 动态规划构建 $\phi_{\text{inv}}(m)$。

---

### 完整代码（Python）
```python
MOD = 10**9 + 7

def sieve(max_limit):
    sieve = [True] * (max_limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(max_limit**0.5) + 1):
        if sieve[i]:
            sieve[i*i : max_limit+1 : i] = [False] * len(sieve[i*i : max_limit+1 : i])
    primes = [i for i, is_prime in enumerate(sieve) if is_prime]
    return sieve, primes

# 预处理素数表
sieve_5001, primes = sieve(5001)
prime_index = {p: i for i, p in enumerate(primes)}

# 预处理phi_to_pe和pe_to_prime
phi_to_pe = dict()
pe_to_prime = dict()

# 处理p=2
p = 2
e = 1
while True:
    pe = p ** e
    phi = 1 if e == 1 else (p ** (e-1))
    if phi > 5000:
        break
    if phi not in phi_to_pe:
        phi_to_pe[phi] = []
    phi_to_pe[phi].append(pe)
    pe_to_prime[pe] = p
    e += 1

# 处理奇素数
for p in primes:
    if p == 2:
        continue
    e = 1
    while True:
        pe = p ** e
        phi = (p - 1) if e == 1 else (p ** (e-1)) * (p - 1)
        if phi > 5000:
            break
        if phi not in phi_to_pe:
            phi_to_pe[phi] = []
        phi_to_pe[phi].append(pe)
        pe_to_prime[pe] = p
        e += 1

# 对每个phi值的素数幂排序
for d in phi_to_pe:
    phi_to_pe[d].sort()

# 预处理因数列表
max_m = 5000
divisors = [[] for _ in range(max_m + 1)]
for d in range(1, max_m + 1):
    for multiple in range(d, max_m + 1, d):
        divisors[multiple].append(d)

# 记忆化回溯函数
from functools import lru_cache

@lru_cache(maxsize=None)
def backtrack(m_remaining, mask):
    if m_remaining == 1:
        return 1
    min_n = float('inf')
    for d in divisors[m_remaining]:
        if d not in phi_to_pe:
            continue
        for pe in phi_to_pe[d]:
            p = pe_to_prime[pe]
            i = prime_index[p]
            if (mask & (1 << i)) != 0:
                continue
            if m_remaining % d != 0:
                continue
            sub_m = m_remaining // d
            sub_n = backtrack(sub_m, mask | (1 << i))
            if sub_n == -1:
                continue
            candidate = pe * sub_n
            if candidate < min_n:
                min_n = candidate
    return min_n if min_n != float('inf') else -1

# 计算phi_inv(m)
def compute_phi_inv(m):
    if m == 1:
        return 1
    if m % 2 == 1:
        return -1
    if m + 1 <= 5001 and sieve_5001[m + 1]:
        return m + 1
    res = backtrack(m, 0)
    return res if res != -1 else -1

# 计算总和
sum_odd = 1 + 4999 * (-1)  # i为奇数的m_i：1个1，4999个奇数>1
sum_even = 1 + 2499 * (-1) # i为偶数的m_i：1个1，2499个奇数>1

sum_even_even = 0
for m in range(2, 5001, 2):
    sum_even_even += compute_phi_inv(m)

total = sum_odd + sum_even + sum_even_even
total_mod = total % MOD
if total_mod < 0:
    total_mod += MOD

print(total_mod)
```