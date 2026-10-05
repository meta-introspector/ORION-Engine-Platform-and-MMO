module

public import RequestProject.Hub.Reliability

/-!
# Thirteen-level learner progression (the MMO / education layer)

The *13 Levels of Geometric Integration* describe a linear path ending at Level 13. The hub
reuses that path as its progression system: a learner's experience (XP) is the total
reliability score of the contributions they have had verified, and their level is

  `level = min 13 (1 + ⌊XP / k⌋)`

for a step size `k > 0` (XP needed per level).

Proved here:
* levels always lie between 1 and 13, Level 13 is reachable, and level never goes down as
  XP grows;
* **no skipping:** with `k ≥ 1`, a single verified contribution (worth at most 1 XP, because
  claim scores lie in `[0, 1]`) raises a learner by at most one level, so the path through
  the levels is followed in order;
* resubmitting evidence already on file earns nothing, so progress cannot be farmed by
  repetition.
-/

@[expose] public section

namespace OrionHub

/-- Level reached with `xp` experience, with `k` XP needed per level. -/
def levelOf (k xp : ℚ) : ℕ := min 13 (1 + ⌊xp / k⌋₊)

theorem one_le_levelOf (k xp : ℚ) : 1 ≤ levelOf k xp := by
  unfold levelOf; omega

theorem levelOf_le_13 (k xp : ℚ) : levelOf k xp ≤ 13 := by
  unfold levelOf; omega

/-- Level never decreases as experience grows. -/
theorem levelOf_mono {k : ℚ} (hk : 0 < k) {x y : ℚ} (hxy : x ≤ y) :
    levelOf k x ≤ levelOf k y := by
  unfold levelOf
  have : ⌊x / k⌋₊ ≤ ⌊y / k⌋₊ := Nat.floor_le_floor (div_le_div_of_nonneg_right hxy hk.le)
  omega

/-- Level 13 is reached with `12 k` experience. -/
theorem levelOf_twelve_mul {k : ℚ} (hk : 0 < k) : levelOf k (12 * k) = 13 := by
  unfold levelOf
  rw [mul_div_assoc, div_self hk.ne', mul_one]
  norm_num

/-- **No skipping.** If each level costs at least `1` XP, gaining at most `1` XP raises the
level by at most one. -/
theorem levelOf_add_le {k : ℚ} (hk : 1 ≤ k) {xp δ : ℚ} (hxp : 0 ≤ xp) (hδ1 : δ ≤ 1) : levelOf k (xp + δ) ≤ levelOf k xp + 1 := by
  unfold levelOf
  have hk0 : 0 < k := by linarith
  have h1 : (xp + δ) / k ≤ xp / k + 1 := by
    rw [add_div]
    have : δ / k ≤ 1 := (div_le_one hk0).2 (by linarith)
    linarith
  have h2 : ⌊(xp + δ) / k⌋₊ ≤ ⌊xp / k⌋₊ + 1 := by
    calc ⌊(xp + δ) / k⌋₊ ≤ ⌊xp / k + 1⌋₊ := Nat.floor_le_floor h1
      _ = ⌊xp / k⌋₊ + 1 := Nat.floor_add_one (div_nonneg hxp hk0.le)
  omega

/-- Experience earned from a list of verified contributions (each a claim, given by its
supporting and conflicting evidence): the sum of the claim scores of the *distinct*
contributions, so a repeated submission counts once. -/
def experience (contribs : List (List Evidence × List Evidence)) : ℚ :=
  (contribs.dedup.map fun c => claimScore c.1 c.2).sum

/-- **Anti-farming.** Submitting a contribution that is already on file earns no experience. -/
theorem experience_cons_of_mem {c : List Evidence × List Evidence}
    {contribs : List (List Evidence × List Evidence)} (h : c ∈ contribs) :
    experience (c :: contribs) = experience contribs := by
  simp [experience, List.dedup_cons_of_mem h]

lemma experience_cons_le (c : List Evidence × List Evidence)
    (contribs : List (List Evidence × List Evidence)) :
    experience contribs ≤ experience (c :: contribs) ∧
      experience (c :: contribs) ≤ experience contribs + 1 := by
  by_cases h : c ∈ contribs
  · rw [experience_cons_of_mem h]; constructor <;> linarith
  · have e : experience (c :: contribs) = experience contribs + claimScore c.1 c.2 := by
      simp [experience, List.dedup_cons_of_notMem h, add_comm]
    rw [e]
    have := claimScore_mem_Icc c.1 c.2
    constructor <;> linarith

theorem experience_nonneg (contribs : List (List Evidence × List Evidence)) :
    0 ≤ experience contribs := by
  unfold experience
  apply List.sum_nonneg
  intro x hx
  obtain ⟨c, -, rfl⟩ := List.mem_map.1 hx
  exact (claimScore_mem_Icc _ _).1

/-- **No skipping, for real contributions.** With `k ≥ 1`, one more verified contribution
raises a learner's level by at most one. -/
theorem levelOf_experience_cons {k : ℚ} (hk : 1 ≤ k) (c : List Evidence × List Evidence)
    (contribs : List (List Evidence × List Evidence)) :
    levelOf k (experience (c :: contribs)) ≤ levelOf k (experience contribs) + 1 := by
  obtain ⟨h1, h2⟩ := experience_cons_le c contribs
  have e : experience (c :: contribs) =
      experience contribs + (experience (c :: contribs) - experience contribs) := by ring
  rw [e]
  exact levelOf_add_le hk (experience_nonneg _) (by linarith)

/-- Gaining a contribution never lowers a learner's level. -/
theorem levelOf_experience_cons_ge {k : ℚ} (hk : 0 < k) (c : List Evidence × List Evidence)
    (contribs : List (List Evidence × List Evidence)) :
    levelOf k (experience contribs) ≤ levelOf k (experience (c :: contribs)) := by
  exact levelOf_mono hk (experience_cons_le c contribs).1

end OrionHub
