# CAC-final-test

Benchmark for Evaluating the Performance of Natural Language Models and Agents / 自然语言模型 & Agent性能评测基准

## 项目简介

本项目将包含：

- 一个全面的大模型与Agent能力测试题库

- 一个能自动化完成模型能力打分的python后端程序，以及未来可能的前端界面





## LLM能力基准测试

### 数理能力基准测试

- 一系列分层次的数学/物理题目，测定AI的基础数理能力。基础题目用于区分给本地部署小模型打分，Final-test题目用于评测顶级模型。

### 代码能力基准测试

- 测试AI在 C / C++ / Python / java / golong / rust 后端的能力表现

- 测试AI的前端审美能力，只展示，不评分

### 自然语言与逻辑能力基准测试

- 一系列日常对话理解/逻辑推理，如弱智吧题目或者悬疑推理问题
- 语言能力与文风，只展示，不评分



题目将分为四个级别：

**base-test**：面向3B~30B的，本地部署/边缘计算的小模型，较为简单且生活中常用的问题

**advanced-test**：8B/30B/70B模型几乎无法完成，但是可以被500B以上的DeepSeek、GPT、Gemini等巨参数模型完成的问题

**final-test**：以Goolge-AI-studio最大思考上限的Gemini-2.5-pro的“偶尔可以答对，但需要多次刷新”为难度基准的问题

**final-test+**：包括Gemini-Deepthink与GPT-5-pro在内的当前所有顶级AI都无法解决，但人类可以解决的问题



## LLM日用体验测试

### 幻觉&谄媚表现

- 测评幻觉
- ......





## Agent相关测试

由于这部分暂时无法自动化完成，在当前阶段，我们先专注于LLM基准能力测试的编写





## Q&A

**Q：为什么没有llm自带文科能力测试或者知识储量基准测试？**

A：随着Agent与上网搜索能力的普及，如果你有解决此类问题的需求，与其向一个“知识更丰富”的模型提问，不如使用可以灵活上网搜索的Agent来解决此类问题

**Q：题库泄露导致模型怎么办？**

A：那真是我们的荣幸。不过，本项目仍然会把题目分为公开题库和私有题库两部分，如果一个模型在公开题库和私有题库的表现差距过大，我们会指出“刷分”现象的存在





## 投稿需求

- 需要一个问题和一个标准答案，并说明这道题目主要考察LLM的哪一项能力
- 为自动化评测需求，我们需要一个裁判LLM对照标准答案判断回答问题的模型的对错。不可以是**证明题**，不可以是**没有标准答案的发散性问题**，那样很难被判断“对错”



### 例：(final-test难度，Gemini正确作答率约30%)

**Question**:
Whether the local deformation functor of Sheaf $O(-1) \oplus O(1)$ in $\mathbb{P}^1_k$ is miniversal? How about the crude deformation functor $F_1$?

**Analysis**

>**1 Problem Statement**
>
>Let $k$ be an algebraically closed field. We study the local deformations of the vector bundle $F_0 = \mathcal{O}_{\mathbb{P}^1}(-1) \oplus \mathcal{O}_{\mathbb{P}^1}(1)$ on the projective line $X_0 = \mathbb{P}^1_k$.
>Let $\mathcal{C}$ be the category of local Artin $k$-algebras with residue field $k$. We define the local deformation functor $F: \mathcal{C} \to (\text{Sets})$ as follows: for any $A \in \mathcal{C}$, $F(A)$ is the set of isomorphism classes of pairs $(\mathcal{F}, \phi)$, where:
>
>1. $\mathcal{F}$ is a coherent sheaf on $X_A = \mathbb{P}^1_A$, flat over $A$.
>2. $\phi: \mathcal{F} \otimes_A k \to F_0$ is an isomorphism of sheaves on $X_0$.
>   An isomorphism between two such pairs $(\mathcal{F}_1, \phi_1)$ and $(\mathcal{F}_2, \phi_2)$ is an isomorphism of sheaves $\psi: \mathcal{F}_1 \to \mathcal{F}_2$ over $X_A$ such that $\phi_1 = \phi_2 \circ (\psi \otimes_A k)$.
>   Proposition 1. The local deformation functor $F$ of the sheaf $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ on $\mathbb{P}^1_k$ has a miniversal family.
>   Proof. We will use Schlessinger's criterion (Theorem 16.2) to prove this. A functor has a miniversal family if it satisfies the following four conditions:
>   (H0) $F(k)$ consists of a single element.
>   (H1) For any small extension $A' \to A$, the map $F(A' \times_A A'') \to F(A') \times_{F(A)} F(A'')$ is surjective.
>   (H2) The map in (H1) is a bijection for the special case $A = k, A' \to k, A'' = D = k[t]/t^2$.
>   (H3) The tangent space $t_F = F(D)$ is a finite-dimensional $k$-vector space.
>   Verification of the Conditions
>   (H0) Base Point: The set $F(k)$ consists of deformations over $k$ itself. The only such object is $(F_0, \text{id})$, up to isomorphism. Thus, $F(k)$ is a singleton set. Condition (H0) holds.
>   (H3) Tangent Space: The tangent space $t_F = F(D)$ is the set of first-order deformations. By Theorem 2.7, this set is in one-to-one correspondence with the group $\text{Ext}^1_{X_0}(F_0, F_0)$. We compute this group:
>
>$$
>\text{Ext}^1(F_0, F_0) = \text{Ext}^1(\mathcal{O}(-1) \oplus \mathcal{O}(1), \mathcal{O}(-1) \oplus \mathcal{O}(1))
>$$
>
>$$
>\simeq \text{Ext}^1(\mathcal{O}(-1), \mathcal{O}(-1)) \oplus \text{Ext}^1(\mathcal{O}(-1), \mathcal{O}(1))
>$$
>
>$$
>\oplus \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(-1)) \oplus \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(1))
>$$
>
>Using the isomorphism $\text{Ext}^1(\mathcal{O}(a), \mathcal{O}(b)) \simeq H^1(\mathbb{P}^1_k, \mathcal{O}(b-a))$, we compute each term:
>$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(-1 - (-1))) = H^1(\mathbb{P}^1_k, \mathcal{O}(0)) = 0$.
>$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(1 - (-1))) = H^1(\mathbb{P}^1_k, \mathcal{O}(2)) = 0$.
>$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(-1 - 1)) = H^1(\mathbb{P}^1_k, \mathcal{O}(-2)) \simeq k$.
>$\bullet H^1(\mathbb{P}^1_k, \mathcal{O}(1 - 1)) = H^1(\mathbb{P}^1_k, \mathcal{O}(0)) = 0$.
>Therefore, the tangent space is $t_F \simeq k$. This is a one-dimensional $k$-vector space. Condition (H3) holds.
>(H1) The Gluing Condition: Let $A' \to A$ and $A'' \to A$ be morphisms in $\mathcal{C}$, and let $A^* = A' \times_A A''$. Suppose we are given deformations $(\mathcal{F}', \phi')$ over $A'$ and $(\mathcal{F}'', \phi'')$ over $A''$ that both restrict to the same deformation $(\mathcal{F}, \phi)$ over $A$. Since $F_0$ is locally free, any flat deformation of it over an Artin ring is also locally free (Ex. 7.1). We can form the fibered product of sheaves $\mathcal{F}^* = \mathcal{F}' \times_{\mathcal{F}} \mathcal{F}''$ over the scheme $X_{A^*}$. By Proposition 16.4, since $\mathcal{F}'$ and $\mathcal{F}''$ are flat over $A'$ and $A''$ respectively, and the base change maps are isomorphisms by definition, the resulting sheaf $\mathcal{F}^*$ is flat over $A^*$. It clearly restricts to $\mathcal{F}'$ and $\mathcal{F}''$ as required. Thus, there exists an element in $F(A^*)$ that maps to the given pair in $F(A') \times_{F(A)} F(A'')$. Condition (H1) holds.
>(H2) The Tangent Space Bijection: This condition requires that the map $F(A' \times_k D) \to F(A') \times_{F(k)} F(D)$ is a bijection for any surjection $A' \to k$. This is a special case of the property (H4) for pro-representability, which is related to the action of the tangent space on the set of liftings. Since the functor of deformations of a vector bundle has a tangent theory (Ex. 16.5), and the obstruction space $H^2(\text{End}(F_0))$ is zero, the conditions (H1) and (H2) are satisfied (Ex. 16.4).
>Since all four conditions (H0)-(H3) of Schlessinger's criterion are satisfied, the functor $F$ has a miniversal family.
>
>**2 The Jump Phenomenon and the Crude Functor**
>The subtlety of this example arises when we consider the crude local functor, let's call it $F_1$, which classifies isomorphism classes of families $\mathcal{F}/A$ such that $\mathcal{F} \otimes_A k \simeq F_0$, without fixing the isomorphism $\phi$.
>Proposition 2. The crude local functor $F_1$ for $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ does not have a miniversal family.
>Proof. A necessary condition for a functor to have a miniversal family is (H3), that its tangent space $t_{F_1} = F_1(D)$ must be a finite-dimensional $k$-vector space. The tangent space $t_{F_1}$ is the set of orbits of $t_F = \text{Ext}^1(F_0, F_0)$ under the action of the automorphism group $\text{Aut}(F_0)$.
>
>1. The Tangent Space $t_F$: As computed above, $t_F \simeq \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(-1)) \simeq k$. An element $\lambda \in k$ corresponds to the extension class of $0 \to \mathcal{O}(-1) \to \mathcal{F}_{\lambda} \to \mathcal{O}(1) \to 0$.
>2. The Automorphism Group $\text{Aut}(F_0)$: The endomorphisms of $F_0$ are given by $H^0(\text{End}(F_0))$.
>
>$$
>\text{End}(F_0) = \text{Hom}(\mathcal{O}(-1) \oplus \mathcal{O}(1), \mathcal{O}(-1) \oplus \mathcal{O}(1)) \simeq \begin{pmatrix} \mathcal{O} & \mathcal{O}(2) \\ \mathcal{O}(-2) & \mathcal{O} \end{pmatrix}
>$$
>
>Taking global sections:
>$$
>H^0(\text{End}(F_0)) \simeq \begin{pmatrix} H^0(\mathcal{O}) & H^0(\mathcal{O}(2)) \\ H^0(\mathcal{O}(-2)) & H^0(\mathcal{O}) \end{pmatrix} = \begin{pmatrix} k & k^3 \\ 0 & k \end{pmatrix}
>$$
>The automorphism group $\text{Aut}(F_0)$ consists of the invertible elements of this algebra. An endomorphism is an automorphism if its determinant is a non-zero scalar.
>
>3. The Action: An automorphism $\psi \in \text{Aut}(F_0)$ acts on an extension class $\xi \in \text{Ext}^1(F_0, F_0)$. Specifically, if
>
>$$
>\psi = \begin{pmatrix} \psi_{11} & \psi_{12} \\ \psi_{21} & \psi_{22} \end{pmatrix}
>$$
>
>and $\xi \in \text{Ext}^1(\mathcal{O}(1), \mathcal{O}(-1))$, the action is given by composition: $\xi \mapsto \psi_{11} \circ \xi \circ \psi_{22}^{-1}$. Here, $\psi_{11}$ and $\psi_{22}$ are non-zero scalars from $k$. So the action is $\xi \mapsto (\psi_{11}/\psi_{22})\xi$. Since $\psi_{11}, \psi_{22} \in k^\times$, the group $k^\times$ acts on $t_F \simeq k$ by multiplication.
>
>4. The Orbits: The action of $k^\times$ on $k$ has two orbits:
>   $\bullet$ The zero element $\{0\}$, corresponding to the trivial (split) extension.
>   $\bullet$ The set of all non-zero elements $k^\times$, corresponding to all non-split extensions.
>   So, the tangent space of the crude functor is the orbit space $t_{F_1} = t_F/\text{Aut}(F_0) = \{[0], [1]\}$, a set with two points.
>   This set is not a $k$-vector space. Therefore, condition (H3) fails for the crude functor $F_1$.
>   Remark 1 (The Jump Phenomenon). The global family over $\text{Spec}(k[t])$ defined by the extension class $t \in k[t]$ has fiber $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ at $t = 0$. For any $t \neq 0$, the extension is non-split and corresponds to a non-zero element in $\text{Ext}^1$. All such non-split extensions of rank 2 on $\mathbb{P}^1$ are isomorphic to the trivial bundle $\mathcal{O} \oplus \mathcal{O}$. This is the "jump" from an unstable bundle to a semistable one. This jump is the geometric reason why the automorphisms do not lift and why the crude functor is not well-behaved.
>   3 Conclusion
>   The local deformation functor $F$ (which keeps track of the isomorphism to the special fiber) for $F_0 = \mathcal{O}(-1) \oplus \mathcal{O}(1)$ on $\mathbb{P}^1_k$ is miniversal. It is represented by a smooth, one-dimensional formal scheme, $\text{Spf} k[[t]]$.
>   However, the crude local functor $F_1$ (which only considers isomorphism classes of fibers) is not miniversal. Its tangent space is not a vector space, which violates a necessary condition (H3) of Schlessinger's criterion. This example highlights the importance of distinguishing between these two types of functors and shows how non-trivial automorphism groups can obstruct the existence of a well-behaved moduli space.







