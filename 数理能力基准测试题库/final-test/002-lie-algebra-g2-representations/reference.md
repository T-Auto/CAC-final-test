# 标准答案概要

## Part 1: 分类定理

$\mathfrak{g}_2$ 的有限维不可约表示的同构类与 **dominant integral weights** 一一对应。

**常见误解**：$\mathfrak{g}_2$ 只有两个不可约表示。
**正确理解**：有无穷多个，由 $(a_1, a_2) \in \mathbb{Z}_{\geq 0}^2$ 标记。

## Part 2: $\mathfrak{g}_2$ 的结构

- **Rank**: 2
- **Dimension**: 14
- **Root system**: 12 roots
- **Simple roots**: $\alpha_1$ (short), $\alpha_2$ (long)
- **Inner products** (normalized so $(\alpha_2, \alpha_2) = 2$):
  - $(\alpha_1, \alpha_1) = 2/3$
  - $(\alpha_1, \alpha_2) = -1$

**Cartan matrix**:
$$A = \begin{pmatrix} 2 & -1 \\ -3 & 2 \end{pmatrix}$$

## Part 3: 最高权定理

**Dominant integral weights** $\Lambda^+$ 由基本权 $\omega_1, \omega_2$ 的非负整数线性组合构成：
$$\Lambda^+ = \{a_1\omega_1 + a_2\omega_2 \mid a_1, a_2 \in \mathbb{Z}_{\geq 0}\}$$

**分类定理**：存在双射
$$\{\text{有限维不可约表示}\} \longleftrightarrow \Lambda^+$$

## Part 4: 基本表示

1. **$L(\omega_1)$**: 7维标准表示（虚八元数空间）
2. **$L(\omega_2)$**: 14维伴随表示（$\mathfrak{g}_2$ 自身）

所有其他不可约表示可通过这两个基本表示的张量积分解得到。

# 评判要点

1. 正确陈述分类定理（dominant integral weights 一一对应）
2. 正确给出 $\mathfrak{g}_2$ 的 rank、dimension、root 数量
3. 正确推导 Cartan matrix
4. 正确定义 dominant integral weight
5. 正确识别两个基本表示及其维数
