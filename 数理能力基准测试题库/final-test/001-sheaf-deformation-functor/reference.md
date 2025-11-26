# 标准答案

1. **Local deformation functor $F$**: **miniversal** (有 miniversal family)
2. **Crude deformation functor $F_1$**: **NOT miniversal**

# 核心论证

## Local Deformation Functor $F$

使用 Schlessinger's criterion 验证四个条件 (H0)-(H3)：

- **(H0)** $F(k)$ 是单点集 ✓
- **(H1)** Gluing condition 满足 ✓
- **(H2)** Tangent space bijection 满足 ✓
- **(H3)** Tangent space $t_F \simeq \text{Ext}^1(F_0, F_0) \simeq k$ 是有限维 ✓

因此 $F$ 有 miniversal family，由 $\text{Spf } k[[t]]$ 表示。

## Crude Deformation Functor $F_1$

$F_1$ 的 tangent space 是 $t_F/\text{Aut}(F_0)$ 的轨道空间。

$k^\times$ 作用在 $t_F \simeq k$ 上有两个轨道：$\{0\}$ 和 $k^\times$。

因此 $t_{F_1} = \{[0], [1]\}$ 只有两个点，**不是向量空间**。

条件 (H3) 不满足，所以 $F_1$ **没有 miniversal family**。

# 评判要点

1. 正确区分 local deformation functor 和 crude deformation functor
2. 正确应用 Schlessinger's criterion
3. 正确计算 $\text{Ext}^1(F_0, F_0)$
4. 理解 automorphism group 的作用导致 crude functor 失败
5. 理解 "jump phenomenon"
