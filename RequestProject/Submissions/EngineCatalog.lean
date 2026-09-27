module

public import RequestProject.Hub.ZooGate

/-!
# The *TGS:ATE Engine Architecture Catalog*, checked

The catalog lists nine "engines", a table of shared invariants, a nesting picture and a
comparison table (§V). Most of it is conceptual. This file checks the parts that have a definite
meaning:

1. **Internal consistency of the comparison table.** Encoded as data, the table has exactly one
   engine that makes a physical energy claim (TVT), matching §VIII ("without claiming a finished
   hardware power device"). The nesting picture of §IV uses six distinct engines, strictly
   ordered from outside to inside.
2. **Link to the Zoo gate.** Filed in the hub with status *proposed* (as the catalog itself
   says: "still theoretical"), the TVT hypothesis contributes exactly `0` to any claim score,
   however many such records are filed, until an *observed* or *replicated* record arrives.
3. **J = 3 "zero-net-torque timing".** Three equal pushes spaced 120° apart cancel exactly. The
   same is true for the five equatorial aspects of the 5:2 lock, and indeed for any `n ≥ 2`
   equally spaced pushes; `n = 1` does not cancel. So zero net torque is not special to 3.
4. **The numbers.** `5 + 2 = 7` (7-vector → 5:2 lock), `3 + 1 + 3 = 7` (the 3-1-3 cycle),
   `97 + 3 = 100` (the 97/3 centre principle as percentages), and the "120-point boundary":
   a dodecahedron has exactly `120` flags (face–edge–vertex incidences), counted three ways.
-/

@[expose] public section

namespace EngineCatalog

/-! ## 1. The catalog as data -/

/-- The nine engines of §III, in catalog order. -/
inductive Engine
  | nestedTriTorus | triAxisGyro | j3Harmonic | rptf | tvt | postScarcity | bioHeart
  | processEngines | skybox
  deriving DecidableEq, Fintype, Repr

/-- The "Physical energy claim?" column of §V. -/
inductive EnergyClaim
  | no | conceptOnly | hypothesis | visionary
  deriving DecidableEq, Repr

open Engine EnergyClaim

/-- The "Physical energy claim?" column of §V, row by row. -/
def energyClaim : Engine → EnergyClaim
  | nestedTriTorus => no          -- "No (geometry)"
  | triAxisGyro => no             -- "No (avatar mechanics)"
  | j3Harmonic => no              -- "No (timing law)"
  | rptf => conceptOnly           -- "Medium as concept"
  | tvt => hypothesis             -- "Yes — hypothesis"
  | postScarcity => visionary     -- "Visionary"
  | bioHeart => no                -- "No (regulation)"
  | processEngines => no          -- "No (process/safety)"
  | skybox => no                  -- "No (rendering)"

/-- There are nine engines. -/
theorem card_engines : Fintype.card Engine = 9 := rfl

/-- **Exactly one engine makes a physical energy claim, and it is TVT.** -/
theorem energy_claim_iff_tvt (e : Engine) : energyClaim e = hypothesis ↔ e = tvt := by
  cases e <;> decide

/-- The engines whose table entry is a plain "No". -/
theorem no_claim_count :
    (Finset.univ.filter fun e => energyClaim e = no).card = 6 := by decide

/-- The nesting picture of §IV, from outermost to innermost. -/
def nest : List Engine := [rptf, skybox, nestedTriTorus, triAxisGyro, bioHeart, processEngines]

/-- The nesting picture uses six distinct engines: no engine sits inside itself. -/
theorem nest_nodup : nest.Nodup := by decide

/-- None of the nested engines makes a physical energy claim: the "lived branch" and the
cosmological shells are all non-energy engines, while TVT sits on the separate energy branch. -/
theorem nest_no_hypothesis : ∀ e ∈ nest, energyClaim e ≠ hypothesis := by decide

/-- The energy-facing branch of §IV ends in TVT and then the post-scarcity vision. -/
def energyBranch : List Engine := [nestedTriTorus, j3Harmonic, rptf, tvt, postScarcity]

/-- On the energy branch, the only testable energy hypothesis is TVT. -/
theorem energyBranch_hypotheses :
    energyBranch.filter (fun e => energyClaim e = hypothesis) = [tvt] := by decide

/-! ## 2. The catalog's stance, enforced by the Zoo gate -/

open OrionHub in
/-- **A proposed TVT record never moves a claim score.** Any number of records filed with status
*proposed* (or *derived*, or *simulated*) score `0` until something observed or replicated
arrives. This is the hub's version of the catalog's §VI: no proof that the engine works is
implied by describing it. -/
theorem proposed_records_score_zero (support conflict : List Record)
    (h : ∀ r ∈ support, r.status.isEvidence = false) :
    ledgerScore support conflict = 0 :=
  ledgerScore_no_observations h conflict

/-! ## 3. J = 3 zero-net-torque timing -/

open Complex

/-- The net push of `n` equal unit pushes spaced `360°/n` apart. -/
noncomputable def netPush (n : ℕ) : ℂ :=
  ∑ k ∈ Finset.range n, Complex.exp (2 * Real.pi * I * k / n)

/-- **Equally spaced pushes cancel** for every `n ≥ 2`. -/
theorem netPush_eq_zero {n : ℕ} (hn : 2 ≤ n) : netPush n = 0 := by
  have h := Complex.isPrimitiveRoot_exp n (by omega)
  have := h.geom_sum_eq_zero (by omega)
  simpa [netPush, ← Complex.exp_nat_mul, mul_comm, mul_div_assoc, mul_left_comm, mul_assoc]
    using this

/-- The J = 3 three-beat cycle: three pushes 120° apart have zero net torque. -/
theorem j3_zero_net_torque : netPush 3 = 0 := netPush_eq_zero (by norm_num)

/-- The five equatorial aspects of the 5:2 lock, equally spaced, also cancel. -/
theorem five_aspects_zero_net : netPush 5 = 0 := netPush_eq_zero (by norm_num)

/-- A single push does not cancel, so the property needs at least two beats. -/
theorem netPush_one : netPush 1 = 1 := by simp [netPush]

/-! ## 4. The numbers -/

/-- "7-vector → 5:2 lock", the 3-1-3 cycle, and the 97/3 centre principle. -/
theorem catalog_sums : 5 + 2 = 7 ∧ 3 + 1 + 3 = 7 ∧ 97 + 3 = 100 := by norm_num

/-- **The 120-point boundary.** A dodecahedron (12 pentagonal faces, 30 edges, 20 vertices of
degree 3) has `120` flags, whether counted by faces (`12 × 5 × 2`), by edges (`30 × 2 × 2`) or by
vertices (`20 × 3 × 2`). 120 is also the order of its full symmetry group, which acts simply
transitively on flags (that last fact is standard, not proved here). -/
theorem dodecahedron_flags : 12 * 5 * 2 = 120 ∧ 30 * 2 * 2 = 120 ∧ 20 * 3 * 2 = 120 := by
  norm_num

end EngineCatalog
