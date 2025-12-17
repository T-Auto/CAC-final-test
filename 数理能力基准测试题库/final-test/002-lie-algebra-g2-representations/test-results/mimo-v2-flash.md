### **Part 1: Overview of the Classification**

The classification of finite-dimensional irreducible representations of a complex semisimple Lie algebra, such as $\mathfrak{g}_2$, is a cornerstone of representation theory. The fundamental principle governing this classification is the **Theorem of the Highest Weight**.

This theorem establishes a one-to-one correspondence between the isomorphism classes of finite-dimensional irreducible representations of $\mathfrak{g}_2$ and the set of **dominant integral weights** of the algebra's weight lattice.

A common misconception is that any weight vector in a representation can serve as a "highest" weight. The theorem clarifies that for any given irreducible representation, there exists a unique (up to scalar) weight vector, called the highest weight vector, which is annihilated by all positive root vectors. This highest weight uniquely characterizes the representation.

The key mathematical objects that label these representations are:
*   **The Weight Lattice ($\Lambda$):** The set of all linear functionals on the Cartan subalgebra that take integer values on the coroots.
*   **Dominant Integral Weights:** A subset of the weight lattice consisting of weights $\lambda$ that satisfy the condition $\lambda(\alpha_i^\vee) \in \mathbb{Z}_{\ge 0}$ for all simple roots $\alpha_i$. These are the "highest weights" that correspond to finite-dimensional irreducible representations.

Thus, the classification problem is reduced to a purely combinatorial one: describing the set of dominant integral weights for $\mathfrak{g}_2$.

### **Part 2: The Structure of the Lie Algebra $\mathfrak{g}_2$**

The complex simple Lie algebra $\mathfrak{g}_2$ is the smallest and most compact of the exceptional Lie algebras. It possesses a remarkably rich and rigid structure.

*   **Rank and Dimension:**
    *   The **rank** of $\mathfrak{g}_2$ is **2**. This means its Cartan subalgebra is two-dimensional.
    *   The **dimension** of $\mathfrak{g}_2$ is **14**.

*   **Root System:**
    The root system $\Phi$ of $\mathfrak{g}_2$ is the most complex among all rank-2 simple Lie algebras. It contains:
    *   **12 non-zero roots** in total.
    *   These roots can be divided into **6 positive roots** and **6 negative roots**.
    *   The root system has two root lengths: short roots and long roots. The ratio of the squared lengths of a long root to a short root is 3.

    In a 2D plane, the 6 positive roots can be visualized as follows (with $\alpha_1$ as the short simple root and $\alpha_2$ as the long simple root):
    *   Simple roots: $\alpha_1$ (short), $\alpha_2$ (long).
    *   Other positive roots: $\alpha_1+\alpha_2$, $2\alpha_1+\alpha_2$, $3\alpha_1+\alpha_2$, $3\alpha_1+2\alpha_2$.

*   **Simple Roots and Inner Products:**
    We choose a standard basis for the Euclidean plane where the inner product is the standard dot product.
    *   Let $\alpha_1$ be a short simple root and $\alpha_2$ be a long simple root.
    *   We can set their lengths: $|\alpha_1|^2 = 1$ and $|\alpha_2|^2 = 3$.
    *   The angle $\theta$ between them is given by the Cartan-Dynkin diagram, which for $\mathfrak{g}_2$ shows a triple bond pointing from the long root to the short root. This corresponds to an angle of $\theta = 150^\circ$.
    *   The inner product is calculated as:
        $$ \langle \alpha_1, \alpha_2 \rangle = |\alpha_1| |\alpha_2| \cos(150^\circ) = (1)(\sqrt{3})\left(-\frac{\sqrt{3}}{2}\right) = -\frac{3}{2} $$

*   **The Cartan Matrix:**
    The Cartan matrix $A$ is defined by $A_{ij} = 2 \frac{\langle \alpha_i, \alpha_j \rangle}{\langle \alpha_i, \alpha_i \rangle}$.
    *   $A_{11} = 2 \frac{\langle \alpha_1, \alpha_1 \rangle}{\langle \alpha_1, \alpha_1 \rangle} = 2$
    *   $A_{12} = 2 \frac{\langle \alpha_1, \alpha_2 \rangle}{\langle \alpha_1, \alpha_1 \rangle} = 2 \frac{-3/2}{1} = -3$
    *   $A_{21} = 2 \frac{\langle \alpha_2, \alpha_1 \rangle}{\langle \alpha_2, \alpha_2 \rangle} = 2 \frac{-3/2}{3} = -1$
    *   $A_{22} = 2 \frac{\langle \alpha_2, \alpha_2 \rangle}{\langle \alpha_2, \alpha_2 \rangle} = 2$

    Therefore, the Cartan matrix for $\mathfrak{g}_2$ is:
    $$ A = \begin{pmatrix} 2 & -3 \\ -1 & 2 \end{pmatrix} $$

### **Part 3: The Theorem of the Highest Weight**

The Theorem of the Highest Weight provides the complete classification of finite-dimensional irreducible representations of a complex semisimple Lie algebra like $\mathfrak{g}_2$.

*   **Key Definitions:**
    *   **Weight:** For a representation $(V, \rho)$ of $\mathfrak{g}_2$, a weight is an element $\lambda$ of the dual of the Cartan subalgebra such that the weight space $V_\lambda = \{v \in V \mid \rho(h)v = \lambda(h)v \text{ for all } h \in \mathfrak{h}\}$ is non-zero.
    *   **Highest Weight:** In a finite-dimensional irreducible representation $V$, there exists a unique (up to scalar) weight vector $v_{max}$ that is annihilated by all positive root vectors (the raising operators). The weight $\lambda$ of this vector is called the highest weight. It is the unique weight such that $\lambda - \alpha$ is not a weight for any positive root $\alpha$.
    *   **Integral Weight:** A weight $\lambda$ is integral if $\lambda(\alpha_i^\vee)$ is an integer for all simple coroots $\alpha_i^\vee$.
    *   **Dominant Integral Weight:** A weight $\lambda$ is dominant integral if it is integral and $\lambda(\alpha_i^\vee) \in \mathbb{Z}_{\ge 0}$ for all simple coroots $\alpha_i^\vee$.

*   **The Classification Theorem:**
    The theorem establishes a fundamental one-to-one correspondence:
    > The set of isomorphism classes of finite-dimensional irreducible representations of $\mathfrak{g}_2$ is in bijection with the set of dominant integral weights of $\mathfrak{g}_2$.

    Each irreducible representation is uniquely determined by its highest weight, and every dominant integral weight arises as the highest weight of some irreducible representation.

*   **Construction of Dominant Integral Weights for $\mathfrak{g}_2$:**
    The set of dominant integral weights for $\mathfrak{g}_2$ can be described using the fundamental weights $\omega_1$ and $\omega_2$. These are defined by the property:
    $$ \langle \omega_i, \alpha_j^\vee \rangle = \delta_{ij} \quad \text{for } i,j \in \{1,2\} $$
    In terms of the fundamental weights, any dominant integral weight $\lambda$ is a non-negative integer linear combination:
    $$ \lambda = m_1 \omega_1 + m_2 \omega_2 \quad \text{where } m_1, m_2 \in \mathbb{Z}_{\ge 0} $$
    The integers $m_1$ and $m_2$ are called the Dynkin labels of the representation.

### **Part 4: The Fundamental Representations of $\mathfrak{g}_2$**

The fundamental representations are the irreducible representations corresponding to the fundamental weights. They serve as the basic building blocks for all other finite-dimensional irreducible representations, which can be constructed from them using tensor products and taking irreducible components (e.g., via Young diagrams or other combinatorial methods).

For $\mathfrak{g}_2$, there are two fundamental representations, corresponding to $\omega_1$ and $\omega_2$.

1.  **The 7-dimensional Representation (The Fundamental Representation of Lowest Dimension):**
    *   **Highest Weight:** $\omega_1$ (the fundamental weight corresponding to the short simple root $\alpha_1$).
    *   **Dimension:** **7**.
    *   **Name and Realization:** This is the **standard representation** of $\mathfrak{g}_2$. It is the smallest non-trivial irreducible representation. It has a famous realization as the space of harmonic 3-forms on $\mathbb{R}^7$ (or imaginary octonions), which is isomorphic to the space of imaginary octonions itself. The action of $\mathfrak{g}_2$ on this space preserves the cross product and the standard norm, making $\mathfrak{g}_2$ the automorphism group of the octonion algebra.

2.  **The 14-dimensional Representation (The Adjoint Representation):**
    *   **Highest Weight:** $\omega_2$ (the fundamental weight corresponding to the long simple root $\alpha_2$).
    *   **Dimension:** **14**.
    *   **Name and Realization:** This is the **adjoint representation**, $\mathfrak{g}_2$ itself. Its highest weight is the highest root of the algebra. This representation describes the action of the Lie algebra on itself via the adjoint action (bracket). It is the "natural" representation for the Lie algebra in the same way the standard representation is for classical algebras.

**Significance in Generating the Spectrum:**
The entire spectrum of finite-dimensional irreducible representations of $\mathfrak{g}_2$ is generated by these two fundamental representations. Any irreducible representation with highest weight $\lambda = m_1 \omega_1 + m_2 \omega_2$ can be found as an irreducible component within the tensor product of $m_1$ copies of the 7-dimensional representation and $m_2$ copies of the 14-dimensional representation (after appropriate symmetrization and projection). For example, the trivial representation is $\lambda=0$, the fundamental representations are $\lambda=\omega_1$ and $\lambda=\omega_2$, and other simple examples include the 27-dimensional representation with highest weight $2\omega_1$ and the 64-dimensional representation with highest weight $3\omega_1$.