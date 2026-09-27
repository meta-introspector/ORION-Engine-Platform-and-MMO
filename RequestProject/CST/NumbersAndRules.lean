module

public import Mathlib
public import RequestProject.Hub.TrinityDigitalRoots

/-!
# Cosmic Sandbox Theory, Volumes I–IV: numbers, ciphers and community rules

Checks of the numerical claims and the rule-like proposals in the Volume I–IV pages. See
`CST_COMPILED_EDITION.md` for the plain-language write-up.

1. **3-1-3 cycle.** `(−3)+(−2)+(−1)+0+1+2+3 = 0`, but any symmetric labelling sums to zero,
   including a six-day week with no rest day (`symmetric_sum_zero`, `no_rest_day_also_zero`):
   the zero total comes from the labels, not from Day 4.
2. **The ×6 ("Sumerian / Tesla") cipher.** Every value `6n` has digital root 3, 6 or 9, cycling
   6, 3, 9 with `n mod 3` (`times_six_digitalRoot`). The same is true of every multiple of 3, so it
   says nothing about English (`times_six_any_alphabet`). Table values `G = 42`, `X = 144` and the
   Pythagorean 1–9 table are correct (`cipher_table_values`, `pythagorean_table`).
3. **Counting claims** (`count_claims`): `26+26+10 = 62 = 12+20+30`, `60/3 = 20`, `4³ = 64`,
   `25³ = 15625`, `1+1+2+4 = 8`, `5·12 = 60`, `12·12 = 144`, `0.1 Hz = 6 breaths/min`.
4. **The Blind Mapping Test is needed.** Every whole number from 4 to 45 — every common alphabet
   size — is "a Platonic-solid count, plus possibly a second one, plus 0–3 axes"
   (`every_alphabet_size_fits`), so such fits carry no evidence unless the rule is fixed first.
5. **FRB 180916.** The "≈16-day" prediction `144/9 = 16` passes a 5% falsifier but fails the
   literature error bound `16.35 ± 0.18` days that the same page cites (`frb_sixteen`); a second
   formula `120/7` also passes the 5% test (`frb_two_formulas`).
6. **Octaves and primes.** `2ⁿ` is prime only for `n = 1` (`two_pow_prime_iff`), and the
   upgraded 1:5:1 geometry contains the non-prime 1 (`one_not_prime`).
7. **Rules.** The 80% rolling supermajority with a human veto (`Vote.*`), the Sanctuary City
   combat-flag rule (`Sanctuary.*`), the neurotechnology Exit System (`Exit.*`), a
   consensus-only stopping rule that may never stop (`consensus_only_never_stops`), and the
   ECHOSpiral no-duplication rule (`NoDup.*`).
-/

@[expose] public section

namespace CSTNumbers

open TrinityDigitalRoots CubyNumerics

/-! ## 1. The 3-1-3 cycle -/

/-- The week labelled `−3, −2, −1, 0, 1, 2, 3` sums to zero. -/
theorem three_one_three_sum : (-3 : ℤ) + -2 + -1 + 0 + 1 + 2 + 3 = 0 := by norm_num

/-- Any symmetric labelling `−n, …, n` sums to zero, whatever `n` is. -/
theorem symmetric_sum_zero (n : ℕ) :
    ∑ k ∈ Finset.Icc (-(n : ℤ)) n, k = 0 := by
  induction n with
  | zero => simp
  | succ m ih =>
    have h1 : Finset.Icc (-((m + 1 : ℕ) : ℤ)) ((m + 1 : ℕ) : ℤ) =
        insert (-((m : ℤ) + 1)) (insert ((m : ℤ) + 1) (Finset.Icc (-(m : ℤ)) m)) := by
      ext x; simp only [Finset.mem_Icc, Finset.mem_insert]; push_cast; omega
    rw [h1, Finset.sum_insert (by simp; omega), Finset.sum_insert (by simp), ih]
    ring

/-- A six-day week with **no** rest day, labelled `−3, −2, −1, 1, 2, 3`, also sums to zero. -/
theorem no_rest_day_also_zero : (-3 : ℤ) + -2 + -1 + 1 + 2 + 3 = 0 := by norm_num

/-! ## 2. Ciphers -/

/-- **The ×6 cipher.** For every letter number `n ≥ 1`, `6n` has digital root 6, 3 or 9
according as `n ≡ 1, 2, 0 (mod 3)`. -/
theorem times_six_digitalRoot (n : ℕ) (hn : 0 < n) :
    digitalRoot (6 * n) = if n % 3 = 1 then 6 else if n % 3 = 2 then 3 else 9 := by
  rw [digitalRoot_pos (by omega)]
  split_ifs <;> omega

/-- The {3,6,9} property holds for **every** positive multiple of 3, so any list of numbers
multiplied by 6 (any alphabet, any word list) has it. -/
theorem times_six_any_alphabet (n : ℕ) (hn : 0 < n) : Trinity (digitalRoot (6 * n)) :=
  (trinity_iff_three_dvd (by omega)).2 ⟨2 * n, by ring⟩

/-- Values in the ×6 table: `G` (7th letter) `= 42`, `X` (24th) `= 144`, `Z` (26th) `= 156`. -/
theorem cipher_table_values : 6 * 7 = 42 ∧ 6 * 24 = 144 ∧ 6 * 26 = 156 := by norm_num

/-- The Pythagorean table: letter `n` (A = 1, …, Z = 26) goes to `1 + (n − 1) mod 9`.
Row 9 holds only I and R; every other row holds three letters. -/
theorem pythagorean_table :
    (List.range 26).map (fun i => 1 + i % 9) =
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 7, 8] := by
  decide

/-! ## 3. Counting claims -/

theorem count_claims :
    26 + 26 + 10 = 62 ∧ 12 + 20 + 30 = 62 ∧ 12 * 5 / 3 = 20 ∧ 4 ^ 3 = 64 ∧
      25 ^ 3 = 15625 ∧ 1 + 1 + 2 + 4 = 8 ∧ 5 * 12 = 60 ∧ 12 * 12 = 144 ∧
      (1 / 10 : ℚ) * 60 = 6 := by
  norm_num

/-! ## 4. The Blind Mapping Test -/

/-- Vertex, edge and face counts of the five Platonic solids. -/
def platonicCounts : List ℕ := [4, 6, 8, 12, 20, 30]

/-- "A Platonic count, plus possibly a second Platonic count, plus 0–3 axes or poles." -/
def fitsPlatonic (n : ℕ) : Bool :=
  platonicCounts.any fun a => (0 :: platonicCounts).any fun b =>
    [0, 1, 2, 3].any fun c => a + b + c == n

/-- Every number from 4 to 45 fits, so fitting an alphabet size (Greek 24, Hebrew 22,
Latin 26, Arabic 28, Russian 33, …) is no evidence by itself. -/
theorem every_alphabet_size_fits : ∀ n ∈ Finset.Icc 4 45, fitsPlatonic n = true := by
  decide

/-! ## 5. FRB 180916 -/

/-- `144/9 = 16` is within 5% of 16.35 days, but outside the published error bar ±0.18 days. -/
theorem frb_sixteen :
    (144 / 9 : ℚ) = 16 ∧ |(16 : ℚ) - 1635 / 100| ≤ 5 / 100 * (1635 / 100) ∧
      (18 / 100 : ℚ) < |(16 : ℚ) - 1635 / 100| := by
  norm_num [abs_of_neg]

/-- A different framework ratio, `120/7`, also passes the 5% test, so that test cannot tell
formulas apart. -/
theorem frb_two_formulas : |(120 / 7 : ℚ) - 1635 / 100| ≤ 5 / 100 * (1635 / 100) := by
  norm_num [abs_of_pos]

/-! ## 6. Octaves and primes -/

theorem two_pow_prime_iff (n : ℕ) : (2 ^ n).Prime ↔ n = 1 := by
  constructor
  · intro h
    rcases n with _ | _ | n
    · exact absurd h Nat.not_prime_one
    · rfl
    · exfalso
      have h2 : 2 ∣ 2 ^ (n + 2) := dvd_pow_self 2 (by omega)
      rcases (Nat.dvd_prime h).1 h2 with h' | h'
      · omega
      · have : 2 ^ 2 ≤ 2 ^ (n + 2) := Nat.pow_le_pow_right (by norm_num) (by omega)
        omega
  · rintro rfl; norm_num

theorem one_not_prime : ¬ Nat.Prime 1 := Nat.not_prime_one

/-! ## 7. Rules -/

namespace Vote

/-- The Universal Toroidal Constitution rule: a measure passes when at least 80% of the votes
cast are in favour and no human veto has been lodged. -/
def passes (yes total : ℕ) (veto : Bool) : Bool := decide (4 * total ≤ 5 * yes) && !veto

/-- A human veto always blocks. -/
theorem veto_blocks (yes total : ℕ) : passes yes total true = false := by simp [passes]

/-- Unanimity is not required: exactly 80% in favour passes. -/
theorem eighty_percent_passes (k : ℕ) : passes (4 * k) (5 * k) false = true := by
  simp [passes]; omega

/-- More than 20% against blocks the measure. -/
theorem blocking_minority {yes total : ℕ} (hle : yes ≤ total) (h : total < 5 * (total - yes)) :
    passes yes total false = false := by
  simp [passes]; omega

/-- Winning over an extra voter never turns a pass into a fail. -/
theorem monotone {yes total : ℕ} {veto : Bool} (h : passes yes total veto = true) :
    passes (yes + 1) total veto = true := by
  simp only [passes, Bool.and_eq_true, decide_eq_true_eq] at h ⊢
  exact ⟨by omega, h.2⟩

end Vote

namespace Sanctuary

/-- A player with the time at which their combat flag expires. -/
structure Player where
  id : ℕ
  flagUntil : ℕ

/-- The city: the current time and who is inside. -/
structure City where
  now : ℕ
  inside : List Player

/-- Invariant: nobody inside the city has an active combat flag. -/
def Safe (c : City) : Prop := ∀ p ∈ c.inside, p.flagUntil ≤ c.now

/-- Entry is allowed only once the player's flag has expired (the auto-eject field). -/
def enter (c : City) (p : Player) : City :=
  if p.flagUntil ≤ c.now then { c with inside := p :: c.inside } else c

/-- Flagging player `i` for combat until time `t` ejects them if they are inside. -/
def flag (c : City) (i t : ℕ) : City :=
  if c.now < t then { c with inside := c.inside.filter (fun p => p.id != i) } else c

/-- Time passes. -/
def tick (c : City) : City := { c with now := c.now + 1 }

theorem enter_safe {c : City} (h : Safe c) (p : Player) : Safe (enter c p) := by
  unfold enter; split_ifs with hp
  · intro q hq; rcases List.mem_cons.1 hq with rfl | hq
    · exact hp
    · exact h q hq
  · exact h

theorem flag_safe {c : City} (h : Safe c) (i t : ℕ) : Safe (flag c i t) := by
  unfold flag; split_ifs
  · intro q hq; exact h q (List.mem_of_mem_filter hq)
  · exact h

theorem tick_safe {c : City} (h : Safe c) : Safe (tick c) := fun p hp => by
  have := h p hp; simp [tick]; omega

/-- A flagged player cannot enter before the flag expires. -/
theorem flagged_cannot_enter (c : City) (p : Player) (h : c.now < p.flagUntil) :
    enter c p = c := by
  simp [enter, Nat.not_le.2 h]

/-- Once the cooldown has passed, the player gets in. -/
theorem cooled_down_enters (c : City) (p : Player) (h : p.flagUntil ≤ c.now) :
    p ∈ (enter c p).inside := by
  simp [enter, h]

end Sanctuary

namespace Exit

/-- Connection state of a neural interface. -/
inductive Link | connected | disconnected
  deriving DecidableEq, Repr

/-- Software status: working, crashed, or actively trying to keep the user connected. -/
inductive Software | ok | crashed | lockingIn
  deriving DecidableEq, Repr

/-- Inputs: the hard-wired kill switch, a software reconnect request, and the user's consent. -/
inductive Input | killSwitch | reconnect (userConsents : Bool) | softwareTick
  deriving DecidableEq, Repr

/-- The kill switch acts on the hardware link directly and ignores the software state.
Reconnection needs the user's consent. -/
def step (_sw : Software) : Link → Input → Link
  | _, .killSwitch => .disconnected
  | .disconnected, .reconnect true => .connected
  | l, _ => l

/-- **Software independence.** The kill switch disconnects from every state, whatever the
software is doing (working, crashed, or trying to lock the user in). -/
theorem kill_switch_always (sw : Software) (l : Link) : step sw l .killSwitch = .disconnected :=
  by cases l <;> rfl

/-- **No forced reconnection.** Without the user's consent a disconnected user stays
disconnected, whatever the software does. -/
theorem no_forced_reconnect (sw : Software) (i : Input) (h : i ≠ .reconnect true) :
    step sw .disconnected i = .disconnected := by
  cases i with
  | killSwitch => rfl
  | reconnect b => cases b; rfl; exact absurd rfl h
  | softwareTick => rfl

end Exit

/-- A stopping rule that ends only when every node agrees. If one node never agrees, the loop
never stops, however many rounds are allowed: this is why a bounded round limit with hand-off to
the human is needed. -/
def consensusLoop (agree : ℕ → Fin 5 → Bool) : ℕ → Option ℕ
  | 0 => none
  | k + 1 =>
    match consensusLoop agree k with
    | some r => some r
    | none => if (List.finRange 5).all (agree k) then some k else none

theorem consensus_only_never_stops (agree : ℕ → Fin 5 → Bool) (j : Fin 5)
    (hj : ∀ r, agree r j = false) (fuel : ℕ) : consensusLoop agree fuel = none := by
  induction fuel with
  | zero => rfl
  | succ k ih =>
    simp only [consensusLoop, ih]
    have : (List.finRange 5).all (agree k) = false := by
      rw [List.all_eq_false]; exact ⟨j, List.mem_finRange j, by simp [hj]⟩
    simp [this]

namespace NoDup

/-- ECHOSpiral agent outputs: a delta (a new correction or upgrade) or a clean/pass signal. -/
inductive Output (α : Type*)
  | delta (a : α)
  | pass

/-- Apply an agent output to the holotape: a delta is added only if it is new; a pass changes
nothing. -/
def apply {α : Type*} [DecidableEq α] (tape : List α) : Output α → List α
  | .delta a => if a ∈ tape then tape else tape ++ [a]
  | .pass => tape

/-- **No duplication.** Starting from a duplicate-free holotape, any sequence of agent outputs
leaves it duplicate-free. -/
theorem nodup_preserved {α : Type*} [DecidableEq α] (outs : List (Output α)) (tape : List α)
    (h : tape.Nodup) : (outs.foldl apply tape).Nodup := by
  induction outs generalizing tape with
  | nil => exact h
  | cons o os ih =>
    apply ih
    cases o with
    | pass => exact h
    | delta a =>
      simp only [apply]
      split_ifs with ha
      · exact h
      · exact List.nodup_append.2 ⟨h, List.nodup_singleton a, by simp; intro x hx hxa; exact ha (hxa ▸ hx)⟩

/-- Nothing already on the holotape is ever removed (only-add rule). -/
theorem apply_extends {α : Type*} [DecidableEq α] (tape : List α) (o : Output α) :
    tape <+: apply tape o := by
  cases o with
  | pass => exact List.prefix_refl _
  | delta a => simp only [apply]; split_ifs
               · exact List.prefix_refl _
               · exact List.prefix_append _ _

end NoDup

/-- The four cardinal corners each combine two elements, and each element appears in exactly two
corners (North = Wind+Earth, East = Earth+Water, South = Water+Fire, West = Fire+Wind). -/
theorem cardinal_corners_balanced :
    let corners : List (String × String) :=
      [("Wind", "Earth"), ("Earth", "Water"), ("Water", "Fire"), ("Fire", "Wind")]
    ∀ e ∈ ["Wind", "Earth", "Water", "Fire"],
      (corners.filter fun c => c.1 == e || c.2 == e).length = 2 := by
  decide

end CSTNumbers
