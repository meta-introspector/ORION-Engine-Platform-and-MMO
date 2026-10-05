"""
Round Four review: corrected H4 / Penrose engine (replaces the simple-root choice and the
rhombus corner order in the zip-archive scripts).  Standard library only.

    python3 review/h4_penrose_fixed.py

What it checks (all exact, in Q(sqrt5), except the angle sums):
  * the 120 unit icosians are distinct and have norm 1;
  * the corrected simple roots have the H4 Coxeter Gram matrix;
  * the reflection orbit of a root closes at exactly 120 points (the scripts' orbits never
    closed and stopped at the 20 000-point cap);
  * the orbit of a generic vector has exactly 14 400 points = |W(H4)|;
  * pentagrid rhombi listed in the corrected corner order have interior angles summing to
    2*pi (a real quadrilateral), while the scripts' order gives pi (a bow-tie); pi is
    exactly the "kappa = 3.1416" the original script printed.

The Lean file RequestProject/RoundFour/H4.lean proves the Gram matrix and the closure of
the 120 points under the corrected reflections; this script adds the 14 400 count, which is
checked here by running it but not proved in Lean.
"""
from fractions import Fraction as F
from itertools import permutations
import math


# ---------- exact arithmetic in Q(sqrt5): (a, b) = a + b*sqrt5 ----------
def add(x, y): return (x[0] + y[0], x[1] + y[1])
def neg(x): return (-x[0], -x[1])
def mul(x, y): return (x[0] * y[0] + 5 * x[1] * y[1], x[0] * y[1] + x[1] * y[0])


ZERO, ONE, TWO, HALF = (F(0), F(0)), (F(1), F(0)), (F(2), F(0)), (F(1, 2), F(0))
PHI = (F(1, 2), F(1, 2))     # (1 + sqrt5)/2
IPHI = (F(-1, 2), F(1, 2))   # 1/phi = (sqrt5 - 1)/2


def dot(u, v):
    s = ZERO
    for a, b in zip(u, v):
        s = add(s, mul(a, b))
    return s


def reflect_unit(v, n):
    """Reflection in the hyperplane orthogonal to the unit vector n."""
    c = mul(TWO, dot(v, n))
    return tuple(add(a, neg(mul(c, b))) for a, b in zip(v, n))


def icosians():
    pts = set()
    for s in range(16):
        pts.add(tuple(HALF if (s >> k) & 1 else neg(HALF) for k in range(4)))
    for i in range(4):
        for sg in (ONE, neg(ONE)):
            v = [ZERO] * 4
            v[i] = sg
            pts.add(tuple(v))
    even = [p for p in permutations(range(4))
            if sum(p[i] > p[j] for i in range(4) for j in range(i + 1, 4)) % 2 == 0]
    hp, hi = mul(HALF, PHI), mul(HALF, IPHI)
    for s in range(8):
        base = [hp if s & 1 else neg(hp), HALF if s & 2 else neg(HALF),
                hi if s & 4 else neg(hi), ZERO]
        for p in even:
            pts.add(tuple(base[p[k]] for k in range(4)))
    return pts


# Corrected simple roots (Coxeter diagram  a1 --5-- a2 --- a3 --- a4).
SIMPLE = [
    (neg(ONE), ZERO, ZERO, ZERO),
    (mul(HALF, PHI), neg(HALF), mul(HALF, IPHI), ZERO),
    (ZERO, mul(HALF, PHI), neg(mul(HALF, IPHI)), neg(HALF)),
    (ZERO, ZERO, ZERO, ONE),
]


def orbit(seed, cap=50_000):
    seen, stack = {seed}, [seed]
    while stack:
        v = stack.pop()
        for n in SIMPLE:
            w = reflect_unit(v, n)
            if w not in seen:
                seen.add(w)
                stack.append(w)
                if len(seen) > cap:
                    return seen, False
    return seen, True


# ---------- pentagrid rhombus corners ----------
DIRS = [(math.cos(2 * math.pi * k / 5), math.sin(2 * math.pi * k / 5)) for k in range(5)]


def vertex(idx):
    return (sum(n * DIRS[k][0] for k, n in enumerate(idx)),
            sum(n * DIRS[k][1] for k, n in enumerate(idx)))


def interior_angle_sum(verts):
    """Sum over corners of (pi - turning angle), the quantity the scripts' kappa adds up."""
    total = 0.0
    for i in range(4):
        a, b, c = verts[i - 1], verts[i], verts[(i + 1) % 4]
        u = (b[0] - a[0], b[1] - a[1])
        v = (c[0] - b[0], c[1] - b[1])
        cos = (u[0] * v[0] + u[1] * v[1]) / (math.hypot(*u) * math.hypot(*v))
        total += math.pi - math.acos(max(-1.0, min(1.0, cos)))
    return total


def rhombus(n, k, m, corrected):
    c0 = list(n)
    c1 = list(n); c1[k] -= 1
    c2 = list(n); c2[m] -= 1
    c3 = list(n); c3[k] -= 1; c3[m] -= 1
    order = [c0, c1, c3, c2] if corrected else [c0, c1, c2, c3]   # script used the latter
    return [vertex(c) for c in order]


if __name__ == "__main__":
    P = icosians()
    assert len(P) == 120 and all(dot(p, p) == ONE for p in P)
    print("icosians: 120 distinct unit vectors")

    half_phi = mul(HALF, PHI)
    for i in range(4):
        for j in range(4):
            want = ONE if i == j else (neg(half_phi) if {i, j} == {0, 1}
                                       else neg(HALF) if abs(i - j) == 1 else ZERO)
            assert dot(SIMPLE[i], SIMPLE[j]) == want
    print("corrected simple roots: H4 Gram matrix")

    o, closed = orbit(SIMPLE[0])
    assert closed and len(o) == 120 and o == P
    print("orbit of a root: closes at 120 = the 600-cell")

    generic = ((F(1), F(0)), (F(2, 7), F(1, 3)), (F(5, 11), F(0)), (F(1, 13), F(2, 9)))
    o, closed = orbit(generic)
    assert closed and len(o) == 14400
    print("orbit of a generic vector: 14400 = |W(H4)|")

    n = [0, 1, -1, 2, 0]
    for k in range(5):
        for m in range(k + 1, 5):
            assert abs(interior_angle_sum(rhombus(n, k, m, True)) - 2 * math.pi) < 1e-9
            assert abs(interior_angle_sum(rhombus(n, k, m, False)) - math.pi) < 1e-9
    print("rhombus angle sum: corrected order = 2*pi (a real quadrilateral);"
          " script's order = pi (a bow-tie), which is the 3.1416 the script printed")
    print("ALL CHECKS PASSED")
