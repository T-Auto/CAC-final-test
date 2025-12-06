# 逆欧拉函数算法问题

**题目编号**：math-advanced-014

**分类**：数理 > 高级

**难度**：高级

## 题目描述

设 phi(n) 为欧拉函数（Euler's totient function），定义为不超过 n 且与 n 互素的正整数个数。对于给定的整数 m，定义其逆欧拉函数为：

phi_inv(m) =
  - 最小的正整数 n 使得 phi(n) = m（如果存在）
  - -1（如果不存在满足 phi(n) = m 的正整数 n）

现给定 k = 10000 个正整数 m_1, m_2, ..., m_k，其中：

m_i = i          当 i 为奇数时
m_i = i / 2      当 i 为偶数时

计算这 k 个数的逆欧拉函数值的总和：

S = sum(phi_inv(m_i)) for i = 1 to k

需要给出：
1. 完整的算法设计思路，包括预处理优化策略
2. 时间复杂度和空间复杂度分析
3. 最终计算结果 S mod (10^9 + 7)
4. 对于一般情况（k 更大时）的优化建议

## 核心概念

### 欧拉函数 phi(n)
- 定义：小于等于 n 且与 n 互质的正整数个数
- 积性性质：若 gcd(a,b) = 1，则 phi(ab) = phi(a)phi(b)
- 计算公式：若 n = product p_i^{a_i}，则 phi(n) = product p_i^{a_i-1}(p_i - 1)

### 逆欧拉函数 phi_inv(m)
- 给定 m，找出满足 phi(n) = m 的最小正整数 n
- 不是所有 m 都有解（如 phi_inv(14) = -1）
- 可能有多个 n 满足条件，需取最小值

### 线性筛法
- 用于在 O(N) 时间内预处理 1..N 的所有欧拉函数值
- 基于欧拉函数积性性质的高效算法

## 算法思路

### 预处理阶段

1. 使用线性筛法计算 n = 1..20000 的所有 phi(n) 值
2. 建立逆映射数组 phi_inv，其中 phi_inv[m] = 最小的 n 满足 phi(n) = m
3. 如果没有 n 满足 phi(n) = m，则 phi_inv[m] = -1

### 查询阶段

1. 对于每个查询 m_i，直接查表得到 phi_inv(m_i)
2. 将所有结果累加，最后取模 (10^9 + 7)

### 优化策略

1. 预处理范围确定：理论上最小的 n 满足 phi(n) = m 通常不超过 2m
2. 去重处理：序列中重复值较多，可以先统计不同查询
3. 离线处理：收集所有查询后一次性计算最小必要映射

## 复杂度分析

- 预处理：时间复杂度 O(N)，空间复杂度 O(N)，N ≈ 20000
- 查询：时间复杂度 O(k)，k = 10000，每次查询 O(1)
- 总复杂度：O(N + k)，线性效率

## 边界情况

1. 无解情况：如 phi_inv(14) = -1，phi_inv(26) = -1
2. 多个解：取最小的 n，如 phi_inv(8) = 15（虽然 phi(16) = 8，但 15 < 16）
3. 大范围查询：当 m 较大时，可能需要更大的预处理范围

## 实现示例（Python）

```python
MOD = 10**9 + 7

def compute_phi(n):
    """使用线性筛计算欧拉函数表"""
    phi = list(range(n + 1))
    primes = []
    is_composite = [False] * (n + 1)

    for i in range(2, n + 1):
        if not is_composite[i]:
            primes.append(i)
            phi[i] = i - 1
        for p in primes:
            if i * p > n:
                break
            is_composite[i * p] = True
            if i % p == 0:
                phi[i * p] = phi[i] * p
                break
            else:
                phi[i * p] = phi[i] * (p - 1)

    return phi

def build_inverse_phi(max_n):
    """构建逆欧拉函数表"""
    phi = compute_phi(max_n)
    max_m = max(phi)
    inverse_phi = [-1] * (max_m + 1)

    for n in range(1, max_n + 1):
        m = phi[n]
        if m <= max_m and inverse_phi[m] == -1:
            inverse_phi[m] = n

    return inverse_phi

def solve(k=10000):
    """计算 S mod (10^9 + 7)"""
    # 预处理范围
    max_n = 20000  # 2 * max(m_i)
    inverse_phi = build_inverse_phi(max_n)

    # 计算总和
    total = 0
    seen = set()  # 去重

    for i in range(1, k + 1):
        m = i if i % 2 == 1 else i // 2
        if m not in seen:
            seen.add(m)
            n = inverse_phi[m] if m < len(inverse_phi) else -1
            if n != -1:
                total = (total + n) % MOD

    return total

# 执行计算
result = solve()
print(f"S mod (10^9 + 7) = {result}")
```

## 大规模优化

当 k 增大到 10^6 或更大时：

1. **按需预处理**：只预处理到实际需要的最大 m 值
2. **并行预处理**：使用多线程加速线性筛
3. **压缩存储**：使用 array 模块或 numpy 数组减少内存
4. **查询优化**：对查询排序后批量处理，提高缓存命中率

## 教学价值

本题综合考查：
- 数论函数的理解与应用
- 算法设计能力（预处理+查询）
- 复杂度分析能力
- 大规模数据优化思维

适合作为：
- 高级算法课程的练习题
- 算法竞赛中数论部分的难题
- 考察数学建模与算法实现能力的面试题

## 测试用例

验证几个关键点：
- m = 1 -> n = 1 (phi(1) = 1)
- m = 2 -> n = 3 (phi(3) = 2)
- m = 8 -> n = 15 (phi(15) = 8)
- m = 12 -> n = 13 (phi(13) = 12)
- m = 14 -> n = -1 (无解)
