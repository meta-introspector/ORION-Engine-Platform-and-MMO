# Formal review of the TGS:ATE documents

Nine linked documents were read: the ORION Engine Architecture (plus its three sub-pages),
the Watermelon Equation V2.0, the Ghost Rider Protocol V2.0, the 13 Levels of Geometric
Integration, The 4th Space, and the Google Doc "The Tri-Sphere Architecture".
Most of this material is conceptual, philosophical or metaphorical and has no statement that
can be checked mathematically. The parts that can be checked are formalized here.

## `RequestProject/EvidenceWeight.lean`: the `W(e)` rubric (Operation Snake and Scale)

`W(e) = S_t × R_m × C_i × (1 − D_r)`, using the exact tier values from the page. Proved:

* **Anti-volume safeguard holds:** for low-rigor evidence (`R_m = 0.1`), `C_i = 1` and `W(e)`
  does not depend on the number of sources `n`.
* **Cap holds:** `1 ≤ C_i ≤ 1.5`. `C_i` is monotone in `n`, and for high-rigor evidence
  `C_i = 1.5` exactly when `n ≥ 5`.
* **Range:** for `0 ≤ D_r ≤ 1`, `0 ≤ W(e) ≤ 1.5`, and the value `1.5` is attained
  (primary source, cryptographic proof, `n = 5`, `D_r = 0`). So the "Reliability_Score" is
  **not** confined to `[0, 1]`. If it is meant to be a normalised score, it needs dividing by 1.5.
* **Ceilings:** low-rigor evidence never exceeds `0.1`. Evidence from unverified sources never
  exceeds `0.15`. Uncontested primary evidence with a cryptographic proof is always `≥ 1`.
* `W(e) = 0` exactly when `D_r = 1`. `W(e)` never increases as `D_r` increases.

Two points about the specification that were not formalized:
* `D_r` is defined as "conflicting evidence weight / supporting evidence weight", and those
  weights are themselves values of `W`. That makes the definition circular unless an order of
  evaluation or a fixed-point rule is given.
* The ratio is undefined when the supporting weight is 0. The page does not say what happens then.

## `RequestProject/NumericClaims.lean`: explicit arithmetic and geometry

* Correct as arithmetic: 1+4+4 = 9 (the digit sum of 144), 144/4 = 36, `36 = 12J ⇔ J = 3`,
  3+6 = 9, 1.5+1.5 = 3, 12×12 = 144. Bekenstein–Hawking `kA/(4 l_P²)` equals 36 **only**
  in units where k = l_P = 1 with A = 144. The choice of A = 144 and divisor 4 is an input
  to the framework, not something derived.
* Read literally as numbers, `144 = 000` and `144 < 000` are false. Of the five
  "filter-state" symbols, only `<>` and `>` hold numerically. The documents use them as labels.
* "144 degrees is the angle of perfection in the grid lattice": 144° is the interior angle of a
  regular **decagon**. The dodecahedron's faces are pentagons (108°). 144° is also not the
  dodecahedron's dihedral angle: `cos 144° = −(1+√5)/4 ≠ −1/√5`.
* Dodecahedron counts: 12 faces, 30 edges, 20 vertices, V − E + F = 2.
* The 13 levels form a linear chain in which Level 13 is the only terminal state.
