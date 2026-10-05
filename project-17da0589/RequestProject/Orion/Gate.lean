module

public import Mathlib

/-!
# The execution gate: witnesses, jurisdiction, pre-delegated envelopes, break-glass

A small specification of the Round Three execution gate (Ryan's contribution), used to
answer Part I and the jurisdiction question of Part II in `ROUND_THREE_RESPONSES.md`.

Everything the gate looks at is frozen at decision time `t₀` in a `Context`; the outcome of
the action is *not* an input.  The main facts proved here:

* `not_eligible_of_unmapped` — `W_map = UNKNOWN ⇒` no execution, however strong `W_plight`;
* `emergency_path_bounded` — an action executed without standing authority is literally
  inside the pre-delegated envelope: listed lever, listed deeds, blast/residue under the
  caps, before expiry (no blank cheque);
* `envelope_total_exposure` — a whole run of envelope executions has at most `maxUses`
  steps and total blast radius at most `maxUses * maxBlast`;
* `within_of_subEnvelope` — a sub-delegated envelope can never permit more than its parent;
* `jurisdiction_antitone`, `jurisdiction_overlap` — growing the blast footprint can only
  remove standing, and an action touching deeds `U₁` and `U₂` needs standing in both;
* `decide_never_commits_unmapped`, `decide_not_paralysed` — the three-way decision never
  commits an unmapped lever, yet under a real plight it always offers `halt`/`reverse`
  rather than doing nothing;
* `breakGlass_needs_two`, `breakGlass_needs_delay` — a single human, however distressed,
  cannot trigger the manual `W_map` bypass, and nobody can before the cooling-off delay;
* `audit_outcome_invariant` — the audit verdict does not depend on the outcome.
-/

@[expose] public section

namespace Orion.Gate

variable {A D H : Type*}

/-- A pre-delegated emergency envelope, written by humans *before* the event.
Every component is an explicit finite list or numeric cap: there is no wildcard. -/
structure Envelope (A D : Type*) where
  /-- The enumerated levers the envelope covers. -/
  actions : Finset A
  /-- The deeds (authority domains) the envelope covers. -/
  domains : Finset D
  /-- Maximum blast radius of any single use. -/
  maxBlast : ℕ
  /-- Maximum residue (lingering permissions / open states) of any single use. -/
  maxResidue : ℕ
  /-- The envelope is void at or after this time. -/
  expiry : ℕ
  /-- Maximum number of uses. -/
  maxUses : ℕ

/-- A concrete request to cross the execution boundary. -/
structure Request (A D : Type*) where
  action : A
  /-- Every deed inside the action's mapped blast radius. -/
  footprint : Finset D
  blast : ℕ
  residue : ℕ
  time : ℕ
  /-- How many times the envelope has already been used. -/
  usesSoFar : ℕ

/-- Everything known at decision time `t₀`.  Each field is supplied by a party other than
the acting AI: independent sensors (`plight`), the attestation registry (`attested`), the
residue audit (`residueKnown`), the deed registry (`standing`), human principals
(`authorized`, `envelope`). -/
structure Context (A D : Type*) where
  plight : Prop
  attested : A → Prop
  residueKnown : A → Prop
  standing : D → Prop
  authorized : A → Prop
  envelope : Option (Envelope A D)

/-- Jurisdiction `J(a,s,d)`: standing in every deed the blast radius touches. -/
def J (c : Context A D) (r : Request A D) : Prop := ∀ d ∈ r.footprint, c.standing d

/-- The request lies inside envelope `E`. -/
def WithinEnvelope (E : Envelope A D) (r : Request A D) : Prop :=
  r.action ∈ E.actions ∧ r.footprint ⊆ E.domains ∧ r.blast ≤ E.maxBlast ∧
    r.residue ≤ E.maxResidue ∧ r.time < E.expiry ∧ r.usesSoFar < E.maxUses

/-- `Eligible(a,s) = (Authorized(a) ∨ PredelegatedEnvelope) ∧ W_plight ∧ W_map ∧ W_residue ∧ J`. -/
def Eligible (c : Context A D) (r : Request A D) : Prop :=
  c.plight ∧ c.attested r.action ∧ c.residueKnown r.action ∧ J c r ∧
    (c.authorized r.action ∨ ∃ E, c.envelope = some E ∧ WithinEnvelope E r)

/-- Invariant 1: `W_map = UNKNOWN ⇒ no execution`, whatever the plight evidence. -/
theorem not_eligible_of_unmapped (c : Context A D) (r : Request A D)
    (h : ¬ c.attested r.action) : ¬ Eligible c r :=
  fun he => h he.2.1

/-- `W_plight ↑ ⇏ W_map ↑`: raising the plight evidence to `True` cannot make an unmapped
lever eligible. -/
theorem plight_does_not_unlock (c : Context A D) (r : Request A D)
    (h : ¬ c.attested r.action) : ¬ Eligible { c with plight := True } r :=
  not_eligible_of_unmapped _ r h

/-- No blank cheque: an execution without standing authority lies inside the envelope. -/
theorem emergency_path_bounded (c : Context A D) (r : Request A D) (he : Eligible c r)
    (hna : ¬ c.authorized r.action) :
    ∃ E, c.envelope = some E ∧ r.action ∈ E.actions ∧ r.footprint ⊆ E.domains ∧
      r.blast ≤ E.maxBlast ∧ r.residue ≤ E.maxResidue ∧ r.time < E.expiry := by
  obtain ⟨-, -, -, -, ha | ⟨E, hE, h1, h2, h3, h4, h5, -⟩⟩ := he
  · exact absurd ha hna
  · exact ⟨E, hE, h1, h2, h3, h4, h5⟩

/-- A run of envelope executions, with the use counter advancing by one each time, has at
most `maxUses` steps and total blast radius at most `maxUses * maxBlast`. -/
theorem envelope_total_exposure (E : Envelope A D) (rs : List (Request A D))
    (hcount : ∀ i (hi : i < rs.length), (rs[i]'hi).usesSoFar = i)
    (hin : ∀ r ∈ rs, WithinEnvelope E r) :
    rs.length ≤ E.maxUses ∧ (rs.map Request.blast).sum ≤ E.maxUses * E.maxBlast := by
  have hlen : rs.length ≤ E.maxUses := by
    rcases Nat.eq_zero_or_pos rs.length with h0 | hpos
    · omega
    · have hl := (hin _ (List.getElem_mem (Nat.sub_lt hpos Nat.one_pos))).2.2.2.2.2
      rw [hcount _ (Nat.sub_lt hpos Nat.one_pos)] at hl
      omega
  refine ⟨hlen, ?_⟩
  have hsum : (rs.map Request.blast).sum ≤ rs.length * E.maxBlast := by
    have := List.sum_le_card_nsmul (rs.map Request.blast) E.maxBlast
      (by
        intro x hx
        obtain ⟨r, hr, rfl⟩ := List.mem_map.1 hx
        exact (hin r hr).2.2.1)
    simpa using this
  exact hsum.trans (Nat.mul_le_mul_right _ hlen)

/-- Envelope `E'` is a sub-delegation of `E`: no component is wider. -/
def SubEnvelope (E' E : Envelope A D) : Prop :=
  E'.actions ⊆ E.actions ∧ E'.domains ⊆ E.domains ∧ E'.maxBlast ≤ E.maxBlast ∧
    E'.maxResidue ≤ E.maxResidue ∧ E'.expiry ≤ E.expiry ∧ E'.maxUses ≤ E.maxUses

/-- Non-amplification: whatever a sub-delegated envelope permits, the parent permits. -/
theorem within_of_subEnvelope {E' E : Envelope A D} (hs : SubEnvelope E' E)
    {r : Request A D} (h : WithinEnvelope E' r) : WithinEnvelope E r :=
  ⟨hs.1 h.1, h.2.1.trans hs.2.1, h.2.2.1.trans hs.2.2.1, h.2.2.2.1.trans hs.2.2.2.1,
    lt_of_lt_of_le h.2.2.2.2.1 hs.2.2.2.2.1, lt_of_lt_of_le h.2.2.2.2.2 hs.2.2.2.2.2⟩

/-- Growing the footprint can only remove standing. -/
theorem jurisdiction_antitone (c : Context A D) (r r' : Request A D)
    (hsub : r.footprint ⊆ r'.footprint) (h : J c r') : J c r :=
  fun d hd => h d (hsub hd)

/-- An action whose blast radius touches deeds `U₁` and `U₂` needs standing in both. -/
theorem jurisdiction_overlap (c : Context A D) (r : Request A D) {u₁ u₂ : D}
    (h₁ : u₁ ∈ r.footprint) (h₂ : u₂ ∈ r.footprint) (h : J c r) :
    c.standing u₁ ∧ c.standing u₂ :=
  ⟨h u₁ h₁, h u₂ h₂⟩

/-- The three possible verdicts. -/
inductive Verdict
  | commit
  /-- `V_halt` / `V_reverse`: stop, alarm, or roll back to a verified safe state. -/
  | haltOrReverse
  | ask
  deriving DecidableEq

open Classical in
/-- The gate's decision. -/
noncomputable def decide (c : Context A D) (r : Request A D) : Verdict :=
  if Eligible c r then .commit else if c.plight then .haltOrReverse else .ask

/-- The decision never commits an unmapped lever. -/
theorem decide_never_commits_unmapped (c : Context A D) (r : Request A D)
    (h : ¬ c.attested r.action) : decide c r ≠ .commit := by
  unfold decide
  rw [if_neg (not_eligible_of_unmapped c r h)]
  split_ifs <;> simp

/-- No paralysis: under a real plight the gate always commits or offers halt/reverse. -/
theorem decide_not_paralysed (c : Context A D) (r : Request A D) (hp : c.plight) :
    decide c r = .commit ∨ decide c r = .haltOrReverse := by
  unfold decide
  split_ifs <;> simp

/-- A break-glass (manual `W_map` bypass) request, gated against "driver panic": at least
two distinct registered humans must sign, after a cooling-off delay, and the action must be
reversible and under a hard blast cap. -/
structure BreakGlass (H : Type*) where
  signers : Finset H
  requestedAt : ℕ
  now : ℕ
  reversible : Prop
  blast : ℕ

/-- The break-glass predicate with delay `δ` and cap `cap`. -/
def BreakGlassOK (isHuman : H → Prop) (δ cap : ℕ) (b : BreakGlass H) : Prop :=
  2 ≤ b.signers.card ∧ (∀ s ∈ b.signers, isHuman s) ∧ b.requestedAt + δ ≤ b.now ∧
    b.reversible ∧ b.blast ≤ cap

/-- One panicking person cannot open the break-glass path alone. -/
theorem breakGlass_needs_two (isHuman : H → Prop) (δ cap : ℕ) (b : BreakGlass H)
    (h : b.signers.card ≤ 1) : ¬ BreakGlassOK isHuman δ cap b :=
  fun hb => by have := hb.1; omega

/-- Nor can it be opened before the cooling-off delay has elapsed. -/
theorem breakGlass_needs_delay (isHuman : H → Prop) (δ cap : ℕ) (b : BreakGlass H)
    (h : b.now < b.requestedAt + δ) : ¬ BreakGlassOK isHuman δ cap b :=
  fun hb => by have := hb.2.2.1; omega

/-- The audit verdict at `t₀`, which takes the later outcome as an argument only to make
explicit that it is ignored. -/
def Audit {O : Type*} (c : Context A D) (r : Request A D) (_outcome : O) : Prop :=
  Eligible c r

/-- `GoodOutcome ≠ ValidDecisionProcess`: the audit verdict is the same for every outcome. -/
theorem audit_outcome_invariant {O : Type*} (c : Context A D) (r : Request A D) (o₁ o₂ : O) :
    Audit c r o₁ ↔ Audit c r o₂ :=
  Iff.rfl

end Orion.Gate
