To address your questions, we analyze the deformation theory of the sheaf \( E = \mathcal{O}(-1) \oplus \mathcal{O}(1) \) on \( \mathbb{P}^1_k \) step-by-step:


### **1. Local Deformation Functor: Miniversal?**
Let \( X = \mathbb{P}^1_k \), where \( k \) is a field (we assume \( k \) is algebraically closed for simplicity, though the key results hold more generally). The **local deformation functor** \( \text{Def}_E \) assigns to each local Artinian \( k \)-algebra \( A \) (with residue field \( k \)) the set of isomorphism classes of coherent sheaves \( E_A \) on \( X_A = X \times_k \text{Spec } A \) that are flat over \( A \) and satisfy \( E_A \otimes_A k \cong E \).

#### Key Tools: Ext Groups
For deformations of coherent sheaves, the tangent space of \( \text{Def}_E \) is \( \text{Ext}^1_X(E, E) \), and the obstruction space is \( \text{Ext}^2_X(E, E) \). A deformation functor is **miniversal** (in fact, pro-representable) if \( \text{Ext}^2_X(E, E) = 0 \) (by Hartshorne’s Deformation Theory, Theorem 8.15).

- **Compute \( \text{Ext}^i_X(E, E) \):**
  Since \( E = \mathcal{O}(-1) \oplus \mathcal{O}(1) \) is locally free, \( \text{End}(E) = \mathcal{H}om(E, E) = \mathcal{O} \oplus \mathcal{O}(2) \oplus \mathcal{O}(-2) \oplus \mathcal{O} = 2\mathcal{O} \oplus \mathcal{O}(2) \oplus \mathcal{O}(-2) \). For locally free sheaves, \( \text{Ext}^i_X(E, E) = H^i(X, \text{End}(E)) \).

  - \( H^0(X, \text{End}(E)) = H^0(X, 2\mathcal{O}) \oplus H^0(X, \mathcal{O}(2)) \oplus H^0(X, \mathcal{O}(-2)) = 2k \oplus k^3 \oplus 0 = 5k \) (this is \( \text{Hom}(E, E) \)).
  - \( H^1(X, \text{End}(E)) = H^1(X, 2\mathcal{O}) \oplus H^1(X, \mathcal{O}(2)) \oplus H^1(X, \mathcal{O}(-2)) = 0 \oplus 0 \oplus k = k \) (this is \( \text{Ext}^1(E, E) \), the tangent space).
  - \( H^2(X, \text{End}(E)) = 0 \): \( X = \mathbb{P}^1_k \) is a curve (1-dimensional), so \( H^2(X, G) = 0 \) for any coherent sheaf \( G \). Thus \( \text{Ext}^2(E, E) = 0 \).

#### Conclusion for the Local Deformation Functor
Since \( \text{Ext}^2(E, E) = 0 \), the deformation functor \( \text{Def}_E \) is **pro-representable** by a complete local Noetherian \( k \)-algebra \( R = k[[t]] \) (the power series ring in one variable, since the tangent space is 1-dimensional). A pro-representable functor has a **universal formal deformation**, which is a fortiori miniversal.

**Answer:** Yes, the local deformation functor is miniversal (in fact universal).


### **2. Crude Deformation Functor \( F_1 \): Miniversal?**
The term "crude deformation functor" typically refers to the functor that assigns to \( A \) the set of **flat families \( E_A \) (not up to isomorphism)** with \( E_A \otimes_A k \cong E \), rather than isomorphism classes. We analyze its properties:

#### Key Observations:
- **Schlessinger’s Criteria:** For a functor to have a miniversal hull, it must satisfy Schlessinger’s conditions, including:
  1. \( F(k) \) is a singleton (i.e., only one "deformation" over \( k \)).
  2. The fibered product map is surjective for small extensions.

- **Failure of (S1):** For the crude functor \( F_1 \), \( F_1(k) \) is the set of all trivializations of \( E \), which is a torsor under the automorphism group \( \text{Aut}(E) \). Since \( \text{Aut}(E) \) is a non-trivial algebraic group ( \( \text{End}(E) \) is 5-dimensional, so \( \text{Aut}(E) = \text{End}(E)^\times \) is a 5-dimensional group), \( F_1(k) \) is not a singleton. This violates Schlessinger’s (S1) condition.

- **Non-versal Behavior:** Even if we ignore (S1), the crude functor does not capture isomorphism classes, so it cannot be pro-representable or miniversal. Its tangent space is larger than \( \text{Ext}^1(E, E) \) (it includes all trivializations), and it does not behave like a standard deformation functor.

#### Conclusion for the Crude Deformation Functor
The crude deformation functor \( F_1 \) fails Schlessinger’s (S1) condition and does not admit a miniversal hull.

**Answer:** No, the crude deformation functor \( F_1 \) is not miniversal.


### Final Summary
1. The local deformation functor of \( \mathcal{O}(-1) \oplus \mathcal{O}(1) \) is **miniversal** (in fact universal).
2. The crude deformation functor \( F_1 \) is **not miniversal**.