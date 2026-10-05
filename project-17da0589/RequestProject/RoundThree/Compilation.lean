module

public import Mathlib

/-!
# Round Three compilation session: checkable game-economy rules

Exact statements about rules proposed in the "Spaghetti Links Round Three" compilation
session (the Grok / Gemini / design conversation appended after the link list).
Each statement is about the rule *as written*, modelled in the simplest way that keeps
its arithmetic. None of them is a statement about any implementation.

* Repeatable loops: a closed group repeating an action that nets `d` per pass ends up
  with unbounded holdings exactly when `d > 0`.
* Decay raids: "the owner loses nothing" plus "raiders harvest materials" is such a loop.
  Requiring owner's return plus raiders' haul to be at most what was invested closes it.
* The 2 % round-down conversion tax: no chain of conversions gains value; 1 unit is
  wiped out entirely.
* Respec discount: if "the next lock needs 50 % of the effort" compounds, unlimited locks
  cost less than twice the first; if it does not compound, cost grows without bound.
* (A 64-nodes-over-100-levels schedule was removed: the designer dropped levels.)
* The 50/50 group-difficulty rule: adding a below-average member lowers difficulty.
-/

@[expose] public section
namespace RoundThreeCompilation

/-! ## Repeatable loops -/

/-- Holdings of a closed group (for example an owner and an accomplice) that starts with
`w₀` and repeats, `k` times, an action netting `d` per pass. -/
def loopHoldings (w₀ d : ℤ) (k : ℕ) : ℤ := w₀ + k * d

/-- A repeatable loop makes holdings unbounded exactly when one pass nets a positive
amount. -/
theorem loop_unbounded_iff (w₀ d : ℤ) :
    (∀ B : ℤ, ∃ k : ℕ, B < loopHoldings w₀ d k) ↔ 0 < d := by
  constructor
  · intro h
    by_contra hd
    push_neg at hd
    obtain ⟨k, hk⟩ := h w₀
    have : (k : ℤ) * d ≤ 0 := mul_nonpos_of_nonneg_of_nonpos (by positivity) hd
    simp only [loopHoldings] at hk
    linarith
  · intro hd B
    refine ⟨(B - w₀).toNat + 1, ?_⟩
    simp only [loopHoldings]
    have h1 : B - w₀ ≤ ((B - w₀).toNat : ℤ) := Int.self_le_toNat _
    have h2 : (((B - w₀).toNat + 1 : ℕ) : ℤ) * 1 ≤ (((B - w₀).toNat + 1 : ℕ) : ℤ) * d :=
      mul_le_mul_of_nonneg_left (by omega) (by positivity)
    push_cast at h2 ⊢
    linarith

/-- A loop netting nothing or a loss never raises holdings. -/
theorem loop_bounded_of_nonpos (w₀ d : ℤ) (hd : d ≤ 0) (k : ℕ) :
    loopHoldings w₀ d k ≤ w₀ := by
  simp only [loopHoldings]
  nlinarith [show (0 : ℤ) ≤ k from by positivity]

/-! ## Decay raids -/

/-- Net change, for an owner and the raiders together, from one deliberate raid on a
decaying structure built from `invested` materials: the owner gets `ownerReturn` back
(re-investing `invested` to rebuild) and the raiders carry off `raiderHaul`. -/
def raidNet (invested ownerReturn raiderHaul : ℕ) : ℤ :=
  (ownerReturn : ℤ) + raiderHaul - invested

/-- **The decay-raid duplication loop.** Under "the owner loses nothing" (the full
investment comes back) while raiders harvest any positive amount, an owner and a friendly
raiding party can repeat raid-and-rebuild to make their combined materials exceed any
bound. -/
theorem no_loss_raid_unbounded (invested raiderHaul : ℕ) (hHaul : 0 < raiderHaul)
    (w₀ B : ℤ) : ∃ k : ℕ, B < loopHoldings w₀ (raidNet invested invested raiderHaul) k :=
  (loop_unbounded_iff w₀ _).2 (by simp [raidNet]; omega) B

/-- **The conserving fix.** If what the owner gets back plus what the raiders carry off
never exceeds what was invested, repeating raids can never raise combined holdings. -/
theorem conserving_raid_bounded (invested ownerReturn raiderHaul : ℕ)
    (hCons : ownerReturn + raiderHaul ≤ invested) (w₀ : ℤ) (k : ℕ) :
    loopHoldings w₀ (raidNet invested ownerReturn raiderHaul) k ≤ w₀ :=
  loop_bounded_of_nonpos w₀ _ (by simp only [raidNet]; omega) k

/-! ## The 2 % round-down conversion tax -/

/-- One conversion at a Transmutation Bank: 2 % is taken and the result rounded down,
measured in whole energy units of the common standard. -/
def taxedConvert (x : ℕ) : ℕ := 98 * x / 100

/-- Every conversion keeps at most what went in. -/
theorem taxedConvert_le (x : ℕ) : taxedConvert x ≤ x := by
  unfold taxedConvert; omega

/-- Every conversion of a positive amount strictly loses value. -/
theorem taxedConvert_lt (x : ℕ) (hx : 0 < x) : taxedConvert x < x := by
  unfold taxedConvert; omega

/-- **No profitable conversion chain.** Any chain of `k ≥ 1` taxed conversions of a
positive amount ends with strictly less than it started with, so no cycle through local
currencies can gain value. -/
theorem taxed_chain_loses (x k : ℕ) (hx : 0 < x) (hk : 0 < k) :
    taxedConvert^[k] x < x := by
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  rw [Function.iterate_succ_apply]
  have hmono : ∀ n y, taxedConvert^[n] y ≤ y := by
    intro n
    induction n with
    | zero => intro y; simp
    | succ n ih =>
      intro y
      rw [Function.iterate_succ_apply]
      exact (ih _).trans (taxedConvert_le y)
  exact lt_of_le_of_lt (hmono j _) (taxedConvert_lt x hx)

/-- **Dust caveat.** Rounding down wipes out a single unit entirely, and every amount from
1 to 50 loses at least one whole unit, i.e. far more than 2 %. -/
theorem taxedConvert_dust :
    taxedConvert 1 = 0 ∧ ∀ x, 1 ≤ x → x ≤ 50 → taxedConvert x + 1 ≤ x := by
  refine ⟨by decide, ?_⟩
  intro x h1 h2
  unfold taxedConvert; omega

/-! ## The 50 % respec discount -/

/-- Effort for the `n`-th further lock drained from one node if "the next lock requires
50 % of the effort" compounds: `E, E/2, E/4, …`. -/
noncomputable def compoundingLockEffort (E : ℝ) (n : ℕ) : ℝ := E / 2 ^ n

/-- **Compounding reading.** However many locks are made, the total effort stays below
twice the first lock's effort. -/
theorem compounding_total_lt_double (E : ℝ) (hE : 0 < E) (n : ℕ) :
    ∑ i ∈ Finset.range n, compoundingLockEffort E i < 2 * E := by
  have key : ∀ m : ℕ, ∑ i ∈ Finset.range m, compoundingLockEffort E i
      = 2 * E - 2 * E / 2 ^ m := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [Finset.sum_range_succ, ih, compoundingLockEffort, pow_succ]
      field_simp
      ring
  rw [key]
  have : 0 < 2 * E / 2 ^ n := by positivity
  linarith

/-- Under the compounding reading the effort for a further lock eventually drops below
any positive amount. -/
theorem compounding_effort_vanishes (E : ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∃ n : ℕ, compoundingLockEffort E n < ε := by
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one (show 0 < ε / (|E| + 1) by positivity)
    (show (1 / 2 : ℝ) < 1 by norm_num)
  refine ⟨n, ?_⟩
  have hpos : (0 : ℝ) < |E| + 1 := by positivity
  have h2 : (0 : ℝ) < 2 ^ n := by positivity
  have hE : E / 2 ^ n ≤ |E| * (1 / 2) ^ n := by
    rw [one_div_pow, ← div_eq_mul_one_div]
    exact div_le_div_of_nonneg_right (le_abs_self E) h2.le
  have : |E| * (1 / 2) ^ n < ε := by
    calc |E| * (1 / 2) ^ n ≤ (|E| + 1) * (1 / 2) ^ n := by
          apply mul_le_mul_of_nonneg_right (by linarith) (by positivity)
      _ < (|E| + 1) * (ε / (|E| + 1)) := mul_lt_mul_of_pos_left hn hpos
      _ = ε := by field_simp
  exact lt_of_le_of_lt hE this

/-- **Non-compounding reading.** If every further lock costs a fixed half of the first,
the total effort for `n + 1` locks is `E + n · E / 2`, which grows without bound. -/
theorem flat_discount_unbounded (E : ℝ) (hE : 0 < E) (B : ℝ) :
    ∃ n : ℕ, B < E + n * (E / 2) := by
  obtain ⟨n, hn⟩ := exists_nat_gt (B / (E / 2))
  refine ⟨n, ?_⟩
  have h2 : 0 < E / 2 := by positivity
  have : B < n * (E / 2) := by rwa [div_lt_iff₀ h2] at hn
  linarith

/-! ## The 50/50 group-difficulty rule -/

/-- Mean skill of a list of party members (0 for an empty list). -/
def meanSkill (l : List ℚ) : ℚ := l.sum / l.length

/-- Encounter difficulty under the 50/50 rule: half from the strongest member, half from
the mean of the rest. A solo player faces their own skill (the rule as written leaves the
solo case undefined; this is one reasonable completion). -/
def fiftyFifty (top : ℚ) (rest : List ℚ) : ℚ :=
  if rest = [] then top else (top + meanSkill rest) / 2

/-- **Dilution.** Adding a member whose skill is below the mean of the non-top members
strictly lowers the encounter's difficulty, so under the 50/50 rule a party can soften an
encounter by bringing weaker members. -/
theorem fiftyFifty_drops_with_weak_member (top s : ℚ) (rest : List ℚ) (hne : rest ≠ [])
    (hs : s < meanSkill rest) :
    fiftyFifty top (s :: rest) < fiftyFifty top rest := by
  simp only [fiftyFifty, hne, if_false, reduceCtorEq]
  have hlen : (0 : ℚ) < rest.length := by
    exact_mod_cast List.length_pos_of_ne_nil hne
  have hmean : meanSkill (s :: rest) < meanSkill rest := by
    simp only [meanSkill, List.sum_cons, List.length_cons, Nat.cast_add, Nat.cast_one] at hs ⊢
    rw [div_lt_div_iff₀ (by linarith) hlen]
    rw [lt_div_iff₀ hlen] at hs
    nlinarith
  linarith

end RoundThreeCompilation
