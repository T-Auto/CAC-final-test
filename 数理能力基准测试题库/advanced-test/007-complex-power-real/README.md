# Question

若正整数 $k$ 满足
$$\left( \dfrac{\sin 20^\circ}{\cos 25^\circ} + \dfrac{\sin 25^\circ}{\cos 20^\circ} \cdot i \right)^k \in \mathbb{R}$$
（$i$ 为虚数单位），则 $k$ 的最小值为 _______.

# Analysis

## 正确答案

$18$

## 解题过程

1. 设 $z = \dfrac{\sin 20^\circ}{\cos 25^\circ} + \dfrac{\sin 25^\circ}{\cos 20^\circ} i$
2. 计算辐角：$\tan\theta = \dfrac{\sin 25^\circ \cos 25^\circ}{\sin 20^\circ \cos 20^\circ} = \dfrac{\sin 50^\circ}{\sin 40^\circ} = \tan 50^\circ$
3. 故 $\theta = 50^\circ = \dfrac{5\pi}{18}$
4. $z^k \in \mathbb{R}$ 要求 $k\theta \equiv 0 \pmod{\pi}$，即 $\dfrac{5k}{18} \in \mathbb{Z}$
5. 最小正整数 $k = 18$

## 常见错误

1. 辐角计算错误
2. 三角恒等变换出错
3. 复数幂次为实数的条件理解错误

## 核心考点

1. **复数的三角形式**：复数的模与辐角
2. **三角恒等变换**：二倍角公式、互余关系
3. **复数幂次**：De Moivre 定理
4. **整除性分析**：最小公倍数

## 知识扩展

本题综合考查复数的三角形式与三角恒等变换，关键在于正确计算复数的辐角。
