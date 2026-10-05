module

public import Mathlib

/-!
# Round Nine, fifth pass: your notes on the cross-platform reply (*ORION R9💎*, version 826)

* **Sales split for finished items.** The person who finished the item gets 90% of the sale, the
  base creator's schematic gets 3%, and the other 7% is divided by weight among tagged
  contributors (rounded down). Proved: the three parts never pay out more than the sale
  (`sales_split_le_total`), and a contributor with more weight is never paid less
  (`contrib_share_monotone`). Taking the locked 3% tax first and splitting the rest still never
  pays out more than the gross sale (`taxed_split_le_gross`).
* **Child-safety rooms.** A minor may share a room with someone who needs supervision (anyone
  other than their own verified guardian for an under-13; an adult who is not their guardian for a
  13–17 player) only while one of that minor's verified guardians is in the room.
  Proved: checking only when people join is not enough. If the guardian leaves, a teacher and
  child can be left alone together (`naive_leave_breaks_safety`). With the "close the bubble"
  rule (when someone leaves, every minor who is no longer protected is moved out), every room stays
  safe over any sequence of joins and leaves (`room_run_safe`). In a safe room an adult who is not
  the child's guardian is never alone with the child (`no_private_adult_minor`), and an under-13 is
  never alone with another player who is not their guardian (`no_private_under13`).
* **50% vote weight for players from other platforms.** Half weight on its own does not stop them
  outvoting the engaged players: 1 engaged yes, 2 engaged no and 3 outside yes passes
  (`half_weight_can_override`). Outside voters can only override if their yes votes are more than
  twice the engaged margin (`half_weight_override_needs`). With the engaged-majority lock, the
  result always matches the engaged majority whenever the engaged players aren't tied
  (`locked_never_overrides`).
* **Parental controls.** With a daily cap per platform, total time never exceeds the sum of the
  caps (`total_time_le_caps`), and a platform the parent locks gets no time at all
  (`locked_platform_no_time`).
* **Biometric firewall at each graduation.** An account's tier only rises by passing a check, so
  the tier is never higher than the number of checks passed (`tier_le_passed_checks`) and a run
  with no passed check never moves an account up (`no_check_no_graduation`).
* **Damaged structures.** While a structure takes damage, half its income goes to the DEVPOOL and
  the owner keeps the rest, with nothing lost or created (`damaged_split_conserves`).
-/

@[expose] public section

namespace RoundNineFifth

/-! ## 1. Sales split: 90% finisher, 3% base schematic, 7% contributors by weight -/

/-- The finisher's 90% (rounded down). -/
def finisherShare (sale : ℕ) : ℕ := sale * 90 / 100

/-- The base creator's schematic 3% (rounded down). -/
def baseShare (sale : ℕ) : ℕ := sale * 3 / 100

/-- The contributors' 7% pot (rounded down). -/
def contribPot (sale : ℕ) : ℕ := sale * 7 / 100

/-- One contributor's payout: their weight's share of the 7% pot, rounded down. -/
def contribShare (sale w totalW : ℕ) : ℕ := contribPot sale * w / totalW

/-- What all contributors in `s` (with weights `w`) are paid together. -/
def contribTotal {ι : Type*} (s : Finset ι) (w : ι → ℕ) (sale : ℕ) : ℕ :=
  ∑ i ∈ s, contribShare sale (w i) (∑ j ∈ s, w j)

lemma contribTotal_le_pot {ι : Type*} (s : Finset ι) (w : ι → ℕ) (sale : ℕ) :
    contribTotal s w sale ≤ contribPot sale := by
  unfold contribTotal contribShare
  set W := ∑ j ∈ s, w j
  rcases Nat.eq_zero_or_pos W with hW | hW
  · simp [hW]
  · have h1 : ∑ i ∈ s, contribPot sale * w i / W ≤ (∑ i ∈ s, contribPot sale * w i) / W := by
      rw [Nat.le_div_iff_mul_le hW, Finset.sum_mul]
      exact Finset.sum_le_sum fun i _ => Nat.div_mul_le_self _ _
    calc ∑ i ∈ s, contribPot sale * w i / W ≤ (∑ i ∈ s, contribPot sale * w i) / W := h1
      _ = contribPot sale * W / W := by rw [← Finset.mul_sum]
      _ = contribPot sale := Nat.mul_div_cancel _ hW

/-- The three parts of the split never pay out more than the sale. -/
theorem sales_split_le_total {ι : Type*} (s : Finset ι) (w : ι → ℕ) (sale : ℕ) :
    finisherShare sale + baseShare sale + contribTotal s w sale ≤ sale := by
  have h := contribTotal_le_pot s w sale
  unfold finisherShare baseShare contribPot at *
  omega

/-- A contributor with more weight is never paid less. -/
theorem contrib_share_monotone (sale totalW : ℕ) {w₁ w₂ : ℕ} (h : w₁ ≤ w₂) :
    contribShare sale w₁ totalW ≤ contribShare sale w₂ totalW :=
  Nat.div_le_div_right (Nat.mul_le_mul_left _ h)

/-- The locked 3% tax (rounded down). -/
def tax (gross : ℕ) : ℕ := gross * 3 / 100

/-- Taking the 3% tax first and splitting what is left never pays out more than the gross sale. -/
theorem taxed_split_le_gross {ι : Type*} (s : Finset ι) (w : ι → ℕ) (gross : ℕ) :
    tax gross + (finisherShare (gross - tax gross) + baseShare (gross - tax gross) +
      contribTotal s w (gross - tax gross)) ≤ gross := by
  have h := sales_split_le_total s w (gross - tax gross)
  have ht : tax gross ≤ gross := by unfold tax; omega
  omega

/-! ## 2. Child-safety rooms -/

/-- Age tiers. -/
inductive Tier
  | under13
  | teen
  | adult
  deriving DecidableEq

variable {P : Type*} [DecidableEq P] (tier : P → Tier) (guardian : P → P → Prop)
  [DecidableRel guardian]

/-- `m` is a minor. -/
def IsMinor (m : P) : Prop := tier m ≠ Tier.adult

/-- `x` being in a room with minor `m` requires one of `m`'s verified guardians to be present:
anyone other than `m` and `m`'s guardians, for an under-13; an adult who is not `m`'s guardian,
for a 13–17 player. -/
def NeedsGuardian (m x : P) : Prop :=
  x ≠ m ∧ ¬ guardian x m ∧
    (tier m = Tier.under13 ∨ (tier m = Tier.teen ∧ tier x = Tier.adult))

instance (m x : P) : Decidable (NeedsGuardian tier guardian m x) := by
  unfold NeedsGuardian; infer_instance

/-- `m` is in room `r` without the protection it needs. -/
def Unprotected (r : Finset P) (m : P) : Prop :=
  (∃ x ∈ r, NeedsGuardian tier guardian m x) ∧ ¬ ∃ g ∈ r, guardian g m

instance (r : Finset P) (m : P) : Decidable (Unprotected tier guardian r m) := by
  unfold Unprotected; infer_instance

/-- A room is safe when no one in it is unprotected. -/
def Safe (r : Finset P) : Prop := ∀ m ∈ r, ¬ Unprotected tier guardian r m

instance (r : Finset P) : Decidable (Safe tier guardian r) := by
  unfold Safe; infer_instance

/-- Guardians are verified adults. -/
def GuardiansAdult : Prop := ∀ g m, guardian g m → tier g = Tier.adult

/-- The "close the bubble" rule: move every unprotected person out of the room. -/
def closeBubble (r : Finset P) : Finset P := r.filter fun m => ¬ Unprotected tier guardian r m

/-- Leaving: `p` leaves, then the bubble is closed for anyone left unprotected. -/
def safeLeave (p : P) (r : Finset P) : Finset P := closeBubble tier guardian (r.erase p)

/-- Joining: allowed only if the room is still safe afterwards. -/
def gatedJoin (p : P) (r : Finset P) : Finset P :=
  if Safe tier guardian (insert p r) then insert p r else r

/-- Room events. -/
inductive Event (P : Type*)
  | join (p : P)
  | leave (p : P)

/-- Apply one event with the gated join and the close-the-bubble leave. -/
def step (r : Finset P) : Event P → Finset P
  | .join p => gatedJoin tier guardian p r
  | .leave p => safeLeave tier guardian p r

variable {tier guardian}

/-- Only minors can be unprotected and guardians are adults, so closing the bubble never removes
a guardian, and the room left behind is always safe. -/
theorem closeBubble_safe (hg : GuardiansAdult tier guardian)
    (r : Finset P) : Safe tier guardian (closeBubble tier guardian r) := by
  intro m hm ⟨⟨x, hx, hnx⟩, hng⟩
  simp only [closeBubble, Finset.mem_filter] at hm hx
  obtain ⟨hmr, hmu⟩ := hm
  apply hmu
  refine ⟨⟨x, hx.1, hnx⟩, ?_⟩
  rintro ⟨g, hgr, hgm⟩
  apply hng
  refine ⟨g, ?_, hgm⟩
  simp only [closeBubble, Finset.mem_filter]
  refine ⟨hgr, ?_⟩
  rintro ⟨⟨y, _, hy⟩, _⟩
  have hga : tier g = Tier.adult := hg g m hgm
  rcases hy.2.2 with h | ⟨h, _⟩ <;> simp [hga] at h

theorem safeLeave_safe (hg : GuardiansAdult tier guardian) (p : P)
    (r : Finset P) : Safe tier guardian (safeLeave tier guardian p r) :=
  closeBubble_safe hg _

theorem gatedJoin_safe {p : P} {r : Finset P} (hr : Safe tier guardian r) :
    Safe tier guardian (gatedJoin tier guardian p r) := by
  unfold gatedJoin; split_ifs with h
  · exact h
  · exact hr

/-- Over any sequence of joins and leaves, starting from a safe room, every room stays safe. -/
theorem room_run_safe (hg : GuardiansAdult tier guardian)
    (evs : List (Event P)) {r : Finset P} (hr : Safe tier guardian r) :
    Safe tier guardian (evs.foldl (step tier guardian) r) := by
  induction evs generalizing r with
  | nil => exact hr
  | cons e evs ih =>
    apply ih
    cases e with
    | join p => exact gatedJoin_safe hr
    | leave p => exact safeLeave_safe hg p r

omit [DecidableRel guardian] in
/-- In a safe room, an adult who is not the child's guardian is never alone with the child. -/
theorem no_private_adult_minor {a m : P} (ha : tier a = Tier.adult) (hm : IsMinor tier m)
    (hnot : ¬ guardian a m) (hgm : ¬ guardian m m) (hs : Safe tier guardian {a, m}) : False := by
  have ham : a ≠ m := by rintro rfl; exact hm ha
  apply hs m (by simp)
  refine ⟨⟨a, by simp, ham, hnot, ?_⟩, ?_⟩
  · unfold IsMinor at hm
    cases h : tier m with
    | under13 => exact Or.inl rfl
    | teen => exact Or.inr ⟨rfl, ha⟩
    | adult => exact absurd h hm
  · rintro ⟨g, hg, hgm'⟩
    simp only [Finset.mem_insert, Finset.mem_singleton] at hg
    rcases hg with rfl | rfl
    · exact hnot hgm'
    · exact hgm hgm'

omit [DecidableRel guardian] in
/-- In a safe room, an under-13 is never alone with another player who is not their guardian. -/
theorem no_private_under13 {x m : P} (hm : tier m = Tier.under13) (hxm : x ≠ m)
    (hnot : ¬ guardian x m) (hgm : ¬ guardian m m) (hs : Safe tier guardian {x, m}) : False := by
  apply hs m (by simp)
  refine ⟨⟨x, by simp, hxm, hnot, Or.inl hm⟩, ?_⟩
  rintro ⟨g, hg, hgm'⟩
  simp only [Finset.mem_insert, Finset.mem_singleton] at hg
  rcases hg with rfl | rfl
  · exact hnot hgm'
  · exact hgm hgm'

/-! ### Checking only at join time is not enough

People: `0` a child (under 13), `1` the child's guardian, `2` a teacher (adult). -/

/-- Tiers in the example. -/
def exTier : Fin 3 → Tier
  | 0 => Tier.under13
  | 1 => Tier.adult
  | 2 => Tier.adult

/-- In the example, only `1` is anyone's guardian, and only of `0`. -/
def exGuardian (g m : Fin 3) : Prop := g = 1 ∧ m = 0

instance : DecidableRel exGuardian := fun g m => by unfold exGuardian; infer_instance

/-- With the guardian present the room is safe; if the guardian just leaves (no bubble closing),
the teacher and child are left alone and the room is unsafe. -/
theorem naive_leave_breaks_safety :
    Safe exTier exGuardian {0, 1, 2} ∧ ¬ Safe exTier exGuardian (({0, 1, 2} : Finset (Fin 3)).erase 1) := by
  decide

/-- With the close-the-bubble rule, the child is moved out when the guardian leaves. -/
theorem safe_leave_moves_child_out : safeLeave exTier exGuardian 1 {0, 1, 2} = {2} := by
  decide

/-! ## 3. 50% vote weight for players from other platforms -/

/-- Weighted vote, counting engaged votes twice and outside votes once (that is, outside votes
at 50% weight): it passes if weighted yes beats weighted no. -/
def halfWeightPasses (eYes eNo oYes oNo : ℕ) : Prop := 2 * eYes + oYes > 2 * eNo + oNo

/-- Half weight alone can override the engaged players: 1 engaged yes, 2 engaged no, 3 outside
yes. -/
theorem half_weight_can_override : (1 : ℕ) < 2 ∧ halfWeightPasses 1 2 3 0 := by
  unfold halfWeightPasses; decide

/-- Outside voters can only override an engaged "no" majority if their yes votes are more than
twice the engaged margin. -/
theorem half_weight_override_needs {eYes eNo oYes oNo : ℕ} (hmaj : eYes < eNo)
    (hpass : halfWeightPasses eYes eNo oYes oNo) : oYes > 2 * (eNo - eYes) := by
  unfold halfWeightPasses at hpass; omega

/-- Engaged-majority lock: if the engaged players aren't tied, their majority decides; outside
half-weight votes only break ties. -/
def lockedPasses (eYes eNo oYes oNo : ℕ) : Prop :=
  if eYes = eNo then oYes > oNo else eYes > eNo

/-- With the lock, the result always matches the engaged majority when they aren't tied. -/
theorem locked_never_overrides {eYes eNo : ℕ} (oYes oNo : ℕ) (h : eYes ≠ eNo) :
    lockedPasses eYes eNo oYes oNo ↔ eYes > eNo := by
  unfold lockedPasses; simp [h]

/-! ## 4. Parental controls -/

/-- Total time today across platforms. -/
def totalTime {ι : Type*} (s : Finset ι) (used : ι → ℕ) : ℕ := ∑ p ∈ s, used p

/-- With a daily cap per platform, total time never exceeds the sum of the caps. -/
theorem total_time_le_caps {ι : Type*} (s : Finset ι) (used cap : ι → ℕ)
    (h : ∀ p ∈ s, used p ≤ cap p) : totalTime s used ≤ ∑ p ∈ s, cap p :=
  Finset.sum_le_sum h

/-- A platform the parent locks (cap 0) gets no time at all. -/
theorem locked_platform_no_time {ι : Type*} (used cap : ι → ℕ) (p : ι) (h : used p ≤ cap p)
    (hlock : cap p = 0) : used p = 0 := by omega

/-! ## 5. Biometric firewall at each graduation (0 = under 13, 1 = 13–17, 2 = adult) -/

/-- One graduation attempt: the tier rises by one only if the check is passed. -/
def attempt (t : ℕ) (passed : Bool) : ℕ := if passed then min (t + 1) 2 else t

/-- Run a sequence of attempts. -/
def runAttempts (t : ℕ) (checks : List Bool) : ℕ := checks.foldl attempt t

/-- The tier never rises by more than the number of checks passed. -/
theorem tier_le_passed_checks (t : ℕ) (checks : List Bool) :
    runAttempts t checks ≤ t + checks.count true := by
  induction checks generalizing t with
  | nil => simp [runAttempts]
  | cons c cs ih =>
    simp only [runAttempts, List.foldl_cons] at ih ⊢
    have := ih (attempt t c)
    cases c <;> simp [attempt] at this ⊢ <;> omega

/-- A run with no passed check never moves an account up. -/
theorem no_check_no_graduation (t : ℕ) (checks : List Bool) (h : true ∉ checks) :
    runAttempts t checks = t := by
  induction checks generalizing t with
  | nil => rfl
  | cons c cs ih =>
    simp only [List.mem_cons, not_or] at h
    have hc : c = false := by cases c <;> simp_all
    subst hc
    simp only [runAttempts, List.foldl_cons, attempt] at ih ⊢
    simpa using ih t h.2

/-! ## 6. Damaged structures -/

/-- While a structure takes damage, the DEVPOOL gets half its income (rounded down). -/
def devpoolCut (income : ℕ) : ℕ := income / 2

/-- Nothing is lost or created: owner's part plus DEVPOOL's part is the whole income, and the
DEVPOOL never gets more than the owner. -/
theorem damaged_split_conserves (income : ℕ) :
    devpoolCut income + (income - devpoolCut income) = income ∧
      devpoolCut income ≤ income - devpoolCut income := by
  unfold devpoolCut; omega

end RoundNineFifth
