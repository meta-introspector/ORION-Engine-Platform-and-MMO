# Build report: Monolithic Zoo Lean repositories (Matthew Chenoweth Wright / @enuminous)

Checked on 2026-09-26 against the public GitHub repositories. Both are MIT-licensed. No Zoo
files are copied into this project; the only file here is a patch.

## 1. `enuminous/Monolithic-Zoo-Lean4` (46 animals, commit `94e0a9e`)

The repository's own `BUILD_STATUS.md` says it has never been compiled. It has now been built
with Lean, both on its pinned toolchain `v4.19.0` and on `v4.28.0`:

| Step | Result as published | Result with the one-line fix below |
|---|---|---|
| `lake build` | **fails** at `Falcon.lean:20` (`failed to synthesize Decidable (Missed hazard a delay)`) | builds, all 46 animals plus `Core` and `Registry` |
| `lake exe zoo46` | not reachable | prints the 46-animal roster |
| `lake exe regression` | not reachable | **All 90 upstream-generated fixtures passed.** |
| `lake env lean ProofAudit.lean` | not reachable | all 98 theorems checked. None uses `sorry`; only Lean's standard axioms (`propext`, `Classical.choice`, `Quot.sound`) appear, and 53 use no axioms at all |
| `python3 verify.py` | **fails**: `MANIFEST_SHA256.txt` lists a `.gitignore` that is not in the published repository | — (the manifest also needs regenerating after the Falcon fix) |

The only other diagnostic is one unused-variable warning in `Moth.lean`.

**The fix** (`falcon-decidable.patch`): `Missed` is a `def` returning a `Prop`, so Lean cannot
find a `Decidable` instance for `decide (Missed …)`. Adding one line after the definition fixes it:

```lean
instance (hazard alarm delay : Int) : Decidable (Missed hazard alarm delay) :=
  inferInstanceAs (Decidable (hazard ≤ alarm+delay))
```

**A note for the author.** Most of the 98 theorems are contract checks, such as "an accepted
repair has its rollback flag set" or "a veto blocks support". Their proofs unfold a definition
in one step. They are correct and useful as guard rails. Properties that exercise the kernels
further, such as bounds on scores, monotonicity, and behaviour of the rank aggregation under
ties, would strengthen the Zoo. `FORMALIZATION_NOTES.md` already lists these as next steps.

## 2. `enuminous/Monolithic_Zoo_Run` (TURTLE survivor tranche)

As published, `lake build` fails for two independent reasons:
1. `lakefile.toml` declares only `Monolithic102` as a root, so its imports (`SurvivorTypes`,
   `Exponent`, …) are not found. Fix: list all eight modules under `roots`.
2. The proofs use Mathlib tactics and lemmas (`ring`, `norm_num`, `pow_mul`), but the package
   does not depend on Mathlib. Fix: add a Mathlib `[[require]]` and `import Mathlib`.

With both fixes, every theorem in the tranche checks with no errors or warnings. This was tested
by compiling all eight files, in import order, against Mathlib on Lean `v4.28.0`.
