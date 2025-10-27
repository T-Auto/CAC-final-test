# Question

Whether the local deformation functor of Sheaf $O(-1) \oplus O(1) $ in $\mathbb{P}^1_k$ is miniversal? How about the crude deformation functor $F_1$?

# Analysis

Analysis of the Deformation Functor for
$O(-1) \oplus O(1)$ on $P^1$
Explanation of Hartshorne's Example 19.3.2
1 Problem Statement
Let $k$ be an algebraically closed field. We study the local deformations of the vector bundle $F_0 = \mathcal{O}_{\mathbb{P}^1}(-1) \oplus \mathcal{O}_{\mathbb{P}^1}(1)$ on the projective line $X_0 = \mathbb{P}^1_k$.
Let $\mathcal{C}$ be the category of local Artin $k$-algebras with residue field $k$. We define the local deformation functor $F: \mathcal{C} \to (\text{Sets})$ as follows: for any $A \in \mathcal{C}$, $F(A)$ is the set of isomorphism classes of pairs $(\mathcal{F}, \phi)$, where:

1. $\mathcal{F}$ is a coherent sheaf on $X_A = \mathbb{P}^1_A$, flat over $A$.
2. $\phi: \mathcal{F} \otimes_A k \to F_0$ is an isomorphism of sheaves on $X_0$.
An isomorphism between two such pairs $(\mathcal{F}_1, \phi_1)$ and $(\mathcal{F}_2, \phi_2)$ is an isomorphism of sheaves $\psi: \mathcal{F}_1 \to \mathcal{F}_2$ over $X_A$ such that $\phi_1 = \phi_2 \circ (\psi \otimes_A k)$.
Proposition 1. The local deformation functor $F$ of the sheaf $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ on $\mathbb{P}^1_k$ has a miniversal family.
Proof. We will use Schlessinger's criterion (Theorem 16.2) to prove this. A functor has a miniversal family if it satisfies the following four conditions:
(H0) $F(k)$ consists of a single element.
(H1) For any small extension $A' \to A$, the map $F(A' \times_A A'') \to F(A') \times_{F(A)} F(A'')$ is surjective.
(H2) The map in (H1) is a bijection for the special case $A = k, A' \to k, A'' = D = k[t]/t^2$.
(H3) The tangent space $t_F = F(D)$ is a finite-dimensional $k$-vector space.
Verification of the Conditions
(H0) Base Point: The set $F(k)$ consists of deformations over $k$ itself. The only such object is $(F_0, \text{id})$, up to isomorphism. Thus, $F(k)$ is a singleton set. Condition (H0) holds.
(H3) Tangent Space: The tangent space $t_F = F(D)$ is the set of first-order deformations. By Theorem 2.7, this set is in one-to-one correspondence with the group $\text{Ext}^1_{X_0}(F_0, F_0)$. We compute this group:
$$
\text{Ext}^1(F_0, F_0) = \text{Ext}^1(\mathcal{O}(-1) \oplus \mathcal{O}(1), \mathcal{O}(-1) \oplus \mathcal{O}(1))
$$
$$
\simeq \text{Ext}^1(\mathcal{O}(-1), \mathcal{O}(-1)) \oplus \text{Ext}^1(\mathcal{O}(-1), \mathcal{O}(1))
$$
$$
\oplus \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(-1)) \oplus \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(1))
$$
Using the isomorphism $\text{Ext}^1(\mathcal{O}(a), \mathcal{O}(b)) \simeq H^1(\mathbb{P}^1_k, \mathcal{O}(b-a))$, we compute each term:
$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(-1 - (-1))) = H^1(\mathbb{P}^1_k, \mathcal{O}(0)) = 0$.
$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(1 - (-1))) = H^1(\mathbb{P}^1_k, \mathcal{O}(2)) = 0$.
$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(-1 - 1)) = H^1(\mathbb{P}^1_k, \mathcal{O}(-2)) \simeq k$.
$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(1 - 1)) = H^1(\mathbb{P}^1_k, \mathcal{O}(0)) = 0$.
Therefore, the tangent space is $t_F \simeq k$. This is a one-dimensional $k$-vector space. Condition (H3) holds.
(H1) The Gluing Condition: Let $A' \to A$ and $A'' \to A$ be morphisms in $\mathcal{C}$, and let $A^* = A' \times_A A''$. Suppose we are given deformations $(\mathcal{F}', \phi')$ over $A'$ and $(\mathcal{F}'', \phi'')$ over $A''$ that both restrict to the same deformation $(\mathcal{F}, \phi)$ over $A$. Since $F_0$ is locally free, any flat deformation of it over an Artin ring is also locally free (Ex. 7.1). We can form the fibered product of sheaves $\mathcal{F}^* = \mathcal{F}' \times_{\mathcal{F}} \mathcal{F}''$ over the scheme $X_{A^*}$. By Proposition 16.4, since $\mathcal{F}'$ and $\mathcal{F}''$ are flat over $A'$ and $A''$ respectively, and the base change maps are isomorphisms by definition, the resulting sheaf $\mathcal{F}^*$ is flat over $A^*$. It clearly restricts to $\mathcal{F}'$ and $\mathcal{F}''$ as required. Thus, there exists an element in $F(A^*)$ that maps to the given pair in $F(A') \times_{F(A)} F(A'')$. Condition (H1) holds.
(H2) The Tangent Space Bijection: This condition requires that the map $F(A' \times_k D) \to F(A') \times_{F(k)} F(D)$ is a bijection for any surjection $A' \to k$. This is a special case of the property (H4) for pro-representability, which is related to the action of the tangent space on the set of liftings. Since the functor of deformations of a vector bundle has a tangent theory (Ex. 16.5), and the obstruction space $H^2(\text{End}(F_0))$ is zero, the conditions (H1) and (H2) are satisfied (Ex. 16.4).
Since all four conditions (H0)-(H3) of Schlessinger's criterion are satisfied, the functor $F$ has a miniversal family.

2 The Jump Phenomenon and the Crude Functor
The subtlety of this example arises when we consider the crude local functor, let's call it $F_1$, which classifies isomorphism classes of families $\mathcal{F}/A$ such that $\mathcal{F} \otimes_A k \simeq F_0$, without fixing the isomorphism $\phi$.
Proposition 2. The crude local functor $F_1$ for $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ does not have a miniversal family.
Proof. A necessary condition for a functor to have a miniversal family is (H3), that its tangent space $t_{F_1} = F_1(D)$ must be a finite-dimensional $k$-vector space. The tangent space $t_{F_1}$ is the set of orbits of $t_F = \text{Ext}^1(F_0, F_0)$ under the action of the automorphism group $\text{Aut}(F_0)$.
1. The Tangent Space $t_F$: As computed above, $t_F \simeq \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(-1)) \simeq k$. An element $\lambda \in k$ corresponds to the extension class of $0 \to \mathcal{O}(-1) \to \mathcal{F}_{\lambda} \to \mathcal{O}(1) \to 0$.
2. The Automorphism Group $\text{Aut}(F_0)$: The endomorphisms of $F_0$ are given by $H^0(\text{End}(F_0))$.
$$
\text{End}(F_0) = \text{Hom}(\mathcal{O}(-1) \oplus \mathcal{O}(1), \mathcal{O}(-1) \oplus \mathcal{O}(1)) \simeq \begin{pmatrix} \mathcal{O} & \mathcal{O}(2) \\ \mathcal{O}(-2) & \mathcal{O} \end{pmatrix}
$$
Taking global sections:
$$
H^0(\text{End}(F_0)) \simeq \begin{pmatrix} H^0(\mathcal{O}) & H^0(\mathcal{O}(2)) \\ H^0(\mathcal{O}(-2)) & H^0(\mathcal{O}) \end{pmatrix} = \begin{pmatrix} k & k^3 \\ 0 & k \end{pmatrix}
$$
The automorphism group $\text{Aut}(F_0)$ consists of the invertible elements of this algebra. An endomorphism is an automorphism if its determinant is a non-zero scalar.
3. The Action: An automorphism $\psi \in \text{Aut}(F_0)$ acts on an extension class $\xi \in \text{Ext}^1(F_0, F_0)$. Specifically, if
$$
\psi = \begin{pmatrix} \psi_{11} & \psi_{12} \\ \psi_{21} & \psi_{22} \end{pmatrix}
$$
and $\xi \in \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(-1))$, the action is given by composition: $\xi \mapsto \psi_{11} \circ \xi \circ \psi_{22}^{-1}$. Here, $\psi_{11}$ and $\psi_{22}$ are non-zero scalars from $k$. So the action is $\xi \mapsto (\psi_{11}/\psi_{22})\xi$. Since $\psi_{11}, \psi_{22} \in k^\times$, the group $k^\times$ acts on $t_F \simeq k$ by multiplication.
4. The Orbits: The action of $k^\times$ on $k$ has two orbits:
$\bullet$ The zero element $\{0\}$, corresponding to the trivial (split) extension.
$\bullet$ The set of all non-zero elements $k^\times$, corresponding to all non-split extensions.
So, the tangent space of the crude functor is the orbit space $t_{F_1} = t_F/\text{Aut}(F_0) = \{[0], [1]\}$, a set with two points.
This set is not a $k$-vector space. Therefore, condition (H3) fails for the crude functor $F_1$.
Remark 1 (The Jump Phenomenon). The global family over $\text{Spec}(k[t])$ defined by the extension class $t \in k[t]$ has fiber $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ at $t = 0$. For any $t \neq 0$, the extension is non-split and corresponds to a non-zero element in $\text{Ext}^1$. All such non-split extensions of rank 2 on $\mathbb{P}^1$ are isomorphic to the trivial bundle $\mathcal{O} \oplus \mathcal{O}$. This is the "jump" from an unstable bundle to a semistable one. This jump is the geometric reason why the automorphisms do not lift and why the crude functor is not well-behaved.
3 Conclusion
The local deformation functor $F$ (which keeps track of the isomorphism to the special fiber) for $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ on $\mathbb{P}^1_k$ is **miniversal**. It is represented by a smooth, one-dimensional formal scheme, $\text{Spf} k[[t]]$.
However, the crude local functor $F_1$ (which only considers isomorphism classes of fibers) is **not miniversal**. Its tangent space is not a vector space, which violates a necessary condition (H3) of Schlessinger's criterion. This example highlights the importance of distinguishing between these two types of functors and shows how non-trivial automorphism groups can obstruct the existence of a well-behaved moduli space.