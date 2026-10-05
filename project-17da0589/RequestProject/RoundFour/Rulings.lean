module

public import Mathlib
public import RequestProject.RoundFour.PlayerRounding

/-!
# Round Four rulings: tax splitting, phoenix elements, aggro triggers, council consensus

The designer's answers to decisions D1, D4, D5 and D7 (written into the *ORION Round 4* page)
are stated here as rules, with their consequences proved.

* **D1, the tax-splitting loophole is accepted.** Rounding stays in the player's favour, and
  splitting a conversion to avoid the 2 % tax is allowed: "the real world time is the cost". The
  proofs here measure that cost. Avoiding all tax on an amount `T` takes at least `T / 49`
  conversions (`untaxed_split_needs_many`). The most tax that can be avoided on `T` is the
  one-shot tax, which is at most 2 % of `T` (`avoidable_tax_le`).
* **D4, phoenix and elements.** There are five elements: fire, water, earth, air and ether.
  A phoenix hatches with fire already active (`phoenix_hatches_with_fire`). Any dragon can
  learn fire (`fire_open_to_all`). A phoenix gains each element at a 50 % exchange rate
  (`phoenix_half_rate`, `phoenix_spends_no_more`). A phoenix has every element it has gained
  active at once, while other dragons have at most one active at a time (`Elemental.Valid`,
  preserved by every step: `run_valid`). So a phoenix can become a five-element dragon
  (`five_element_phoenix`), and no other dragon can ever have two elements active
  (`other_at_most_one_active`).
* **D5, what pulls aggro.** Environmental effects and direct-encounter effects pull aggro onto
  the player who causes them, for the full 10-minute window (`pulling_effect_aggroes_caster`).
  Other effects never start aggro (`other_effect_no_new_aggro`), and nobody else's timer is
  touched (`effect_no_grief`).
* **D7, council consensus instead of one veto.** A claim is published when the council reaches
  consensus: approvals reach a fixed fraction `num / den` of the votes cast. Unless the council
  requires unanimity, one rejection no longer blocks publication (`one_rejection_not_blocking`).
  With unanimity the old one-veto rule comes back (`unanimity_is_veto`). Moving a project from
  the virtual space into the real world needs the council's consensus **and** the humans' choice
  (`release_needs_both`). The humans can always decline (`humans_can_decline`).
-/

@[expose] public section

namespace RoundFourRulings

open RoundFourRounding

/-! ## D1: splitting around the conversion tax is allowed, and costs conversions -/

/-- A conversion is tax-free exactly when it is at most 49. -/
theorem playerTax_eq_zero_iff (x : ℕ) : playerTax x = 0 ↔ x ≤ 49 := by
  unfold playerTax playerCost; omega

/-- **Dodging the tax takes time.** If every piece of a split pays no tax, there are at least
`T / 49` pieces, where `T` is the total. -/
theorem untaxed_split_needs_many (l : List ℕ) (h : ∀ x ∈ l, playerTax x = 0) :
    l.sum ≤ 49 * l.length := by
  induction l with
  | nil => simp
  | cons x l ih =>
    have hx := (playerTax_eq_zero_iff x).1 (h x (by simp))
    have := ih (fun y hy => h y (by simp [hy]))
    simp only [List.sum_cons, List.length_cons]
    omega

/-- **The most the tax can be dodged by.** Splitting can save at most the one-shot tax on the
total, and that is at most 2 % of the total. -/
theorem avoidable_tax_le (l : List ℕ) :
    playerTax l.sum - (l.map playerTax).sum ≤ playerTax l.sum ∧
      100 * playerTax l.sum ≤ 2 * l.sum := by
  refine ⟨Nat.sub_le _ _, ?_⟩
  unfold playerTax playerCost
  have := Nat.div_mul_le_self (l.sum * 2) 100
  omega

/-! ## D4: phoenix and the five elements -/

/-- The five elements. -/
inductive Element
  | fire
  | water
  | earth
  | air
  | ether
  deriving DecidableEq, Fintype, Repr

/-- A dragon's elemental state: whether it is a phoenix, the elements it has gained, the
elements currently active, and what it has spent gaining them. -/
structure Elemental where
  phoenix : Bool
  acquired : Finset Element
  active : Finset Element
  spent : ℕ

/-- A new hatchling. A phoenix hatches with fire gained and active, at no cost; any other
dragon hatches with no element. -/
def hatch (phoenix : Bool) : Elemental :=
  if phoenix then ⟨true, {.fire}, {.fire}, 0⟩ else ⟨false, ∅, ∅, 0⟩

/-- The price of gaining an element whose standard price is `base`. A phoenix pays half,
rounded down (in the player's favour, as in `RoundFourRounding.playerCost`). -/
def gainCost (phoenix : Bool) (base : ℕ) : ℕ :=
  if phoenix then playerCost base 1 2 else base

/-- Gain element `e` at standard price `base`. A phoenix's new element is active straight away;
any other dragon keeps its current alignment until it chooses to switch. -/
def Elemental.gain (d : Elemental) (e : Element) (base : ℕ) : Elemental :=
  { d with
    acquired := insert e d.acquired
    active := if d.phoenix then insert e d.acquired else d.active
    spent := d.spent + gainCost d.phoenix base }

/-- Align with element `e`. A non-phoenix dragon that has gained `e` makes it its one active
element. A phoenix already has all its elements active, so nothing changes. -/
def Elemental.align (d : Elemental) (e : Element) : Elemental :=
  if d.phoenix then d else if e ∈ d.acquired then { d with active := {e} } else d

/-- One step of elemental play. -/
inductive ElemStep
  | gain (e : Element) (base : ℕ)
  | align (e : Element)

/-- Apply one step. -/
def Elemental.step (d : Elemental) : ElemStep → Elemental
  | .gain e base => d.gain e base
  | .align e => d.align e

/-- Apply a sequence of steps. -/
def Elemental.run (d : Elemental) (l : List ElemStep) : Elemental := l.foldl Elemental.step d

/-- The designer's rule: a phoenix has every element it has gained active; any other dragon has
only gained elements active, and at most one of them. -/
def Elemental.Valid (d : Elemental) : Prop :=
  (d.phoenix = true → d.active = d.acquired) ∧
    (d.phoenix = false → d.active ⊆ d.acquired ∧ d.active.card ≤ 1)

theorem hatch_valid (p : Bool) : (hatch p).Valid := by
  cases p <;> simp [hatch, Elemental.Valid]

theorem step_valid (d : Elemental) (s : ElemStep) (h : d.Valid) : (d.step s).Valid := by
  obtain ⟨hp, hn⟩ := h
  cases s with
  | gain e base =>
    cases hph : d.phoenix
    · obtain ⟨hs, hc⟩ := hn hph
      refine ⟨fun h => by simp [Elemental.step, Elemental.gain, hph] at h, fun _ => ?_⟩
      simp only [Elemental.step, Elemental.gain, hph, Bool.false_eq_true, if_false]
      exact ⟨hs.trans (Finset.subset_insert _ _), hc⟩
    · refine ⟨fun _ => ?_, fun h => by simp [Elemental.step, Elemental.gain, hph] at h⟩
      simp [Elemental.step, Elemental.gain, hph]
  | align e =>
    cases hph : d.phoenix
    · obtain ⟨hs, hc⟩ := hn hph
      by_cases he : e ∈ d.acquired
      · refine ⟨fun h => by simp [Elemental.step, Elemental.align, hph, he] at h, fun _ => ?_⟩
        simp [Elemental.step, Elemental.align, hph, he]
      · refine ⟨fun h => by simp [Elemental.step, Elemental.align, hph, he] at h, fun _ => ?_⟩
        simp only [Elemental.step, Elemental.align, hph, he, Bool.false_eq_true, if_false]
        exact ⟨hs, hc⟩
    · simp only [Elemental.step, Elemental.align, hph, if_true]
      exact ⟨hp, hn⟩

/-- **The rule always holds.** Starting from any valid state, every sequence of gains and
alignments keeps the rule. -/
theorem run_valid (d : Elemental) (l : List ElemStep) (h : d.Valid) : (d.run l).Valid := by
  induction l generalizing d with
  | nil => exact h
  | cons s l ih => exact ih _ (step_valid d s h)

/-- **A phoenix hatches with fire.**
*Superseded* by `RoundFourRulingsTwo.phoenix_hatches_unlit_with_fire`
(second Round Four ruling: a phoenix hatches unlit, with the fire ability gained but not active).
-/
theorem phoenix_hatches_with_fire : Element.fire ∈ (hatch true).active := by
  simp [hatch]

/-- **Fire is open to every dragon.** A non-phoenix dragon that gains fire and aligns with it
has fire active. -/
theorem fire_open_to_all (base : ℕ) :
    Element.fire ∈ (((hatch false).gain .fire base).align .fire).active := by
  simp [hatch, Elemental.gain, Elemental.align]

/-- **Half rate for the phoenix.** A phoenix pays at most half the standard price (rounded
down), never more than another dragon, and strictly less whenever the price isn't zero. -/
theorem phoenix_half_rate (base : ℕ) :
    2 * gainCost true base ≤ base ∧ gainCost true base ≤ gainCost false base ∧
      (0 < base → gainCost true base < gainCost false base) := by
  simp only [gainCost, playerCost, if_true, Bool.false_eq_true, if_false]
  omega

/-- Gaining elements never changes whether a dragon is a phoenix. -/
theorem run_phoenix (d : Elemental) (l : List ElemStep) : (d.run l).phoenix = d.phoenix := by
  induction l generalizing d with
  | nil => rfl
  | cons s l ih =>
    simp only [Elemental.run, List.foldl_cons] at ih ⊢
    rw [ih]
    cases s with
    | gain e base => rfl
    | align e => simp only [Elemental.step, Elemental.align]; split_ifs <;> rfl

/-- Total spent gaining a list of elements, each `(element, standard price)`. -/
def gainAll (d : Elemental) (l : List (Element × ℕ)) : Elemental :=
  l.foldl (fun d p => d.gain p.1 p.2) d

theorem gainAll_spent (d : Elemental) (l : List (Element × ℕ)) :
    (gainAll d l).spent = d.spent + (l.map fun p => gainCost d.phoenix p.2).sum := by
  induction l generalizing d with
  | nil => simp [gainAll]
  | cons p l ih =>
    simp only [gainAll, List.foldl_cons, List.map_cons, List.sum_cons] at ih ⊢
    rw [ih]
    simp only [Elemental.gain]
    ring

/-- **A phoenix never spends more.** Gaining the same elements at the same standard prices,
a phoenix spends at most what any other dragon spends, and at most half of it. -/
theorem phoenix_spends_no_more (l : List (Element × ℕ)) :
    2 * (gainAll (hatch true) l).spent ≤ (gainAll (hatch false) l).spent := by
  rw [gainAll_spent, gainAll_spent]
  simp only [hatch, if_true, Bool.false_eq_true, if_false, zero_add]
  induction l with
  | nil => simp
  | cons p l ih =>
    simp only [List.map_cons, List.sum_cons]
    have := (phoenix_half_rate p.2).1
    have h2 : gainCost false p.2 = p.2 := rfl
    omega

/-- **Five-element phoenix.** A phoenix that gains water, earth, air and ether has all five
elements active at once.
*Superseded* by `RoundFourRulingsTwo.five_element_phoenix_by_choice`
(second Round Four ruling: all five are active only when the player selects them).
-/
theorem five_element_phoenix (a b c d : ℕ) :
    let p := ((((hatch true).gain .water a).gain .earth b).gain .air c).gain .ether d
    p.active = Finset.univ ∧ p.active.card = 5 := by
  have h : (((((hatch true).gain .water a).gain .earth b).gain .air c).gain .ether d).active =
      Finset.univ := by
    simp only [hatch, Elemental.gain, if_true]; decide
  exact ⟨h, by rw [h]; rfl⟩

/-- **Other dragons align with one element at a time.** However a non-phoenix dragon plays,
it never has more than one element active. -/
theorem other_at_most_one_active (l : List ElemStep) :
    ((hatch false).run l).active.card ≤ 1 := by
  have hv := run_valid _ l (hatch_valid false)
  have hp : ((hatch false).run l).phoenix = false := by rw [run_phoenix]; rfl
  exact (hv.2 hp).2

/-- **A phoenix has everything it has gained active.**
*Superseded* by `RoundFourRulingsTwo.phoenix_any_selection`
(second Round Four ruling: a phoenix chooses which and how many gained elements are active).
-/
theorem phoenix_all_active (l : List ElemStep) :
    ((hatch true).run l).active = ((hatch true).run l).acquired := by
  have hv := run_valid _ l (hatch_valid true)
  have hp : ((hatch true).run l).phoenix = true := by rw [run_phoenix]; rfl
  exact hv.1 hp

/-! ## D5: environmental and direct-encounter effects pull aggro -/

/-- Kinds of effect a player can cause. -/
inductive EffectKind
  | environmental
  | directEncounter
  | other
  deriving DecidableEq, Repr

/-- The designer's rule: environmental and direct-encounter effects pull aggro. -/
def EffectKind.pullsAggro : EffectKind → Bool
  | .environmental => true
  | .directEncounter => true
  | .other => false

/-- Player `i` causes an effect of kind `k`. If it pulls aggro, `i` is aggroed for the full
window (`RoundThreeClarifications.aggroWindow`, 10 minutes). Nobody else's timer changes. -/
def effectStep {ι : Type} [DecidableEq ι] (timers : ι → ℕ) (i : ι) (k : EffectKind) : ι → ℕ :=
  if k.pullsAggro then Function.update timers i RoundThreeClarifications.aggroWindow else timers

/-- **Pulling effects aggro the one who causes them**, for the full 10 minutes. -/
theorem pulling_effect_aggroes_caster {ι : Type} [DecidableEq ι] (timers : ι → ℕ) (i : ι)
    (k : EffectKind) (hk : k = .environmental ∨ k = .directEncounter) :
    effectStep timers i k i = 600 := by
  rcases hk with rfl | rfl <;> simp [effectStep, EffectKind.pullsAggro,
    RoundThreeClarifications.aggroWindow]

/-- **Other effects start no aggro.** -/
theorem other_effect_no_new_aggro {ι : Type} [DecidableEq ι] (timers : ι → ℕ) (i : ι) :
    effectStep timers i .other = timers := by
  simp [effectStep, EffectKind.pullsAggro]

/-- **No griefing.** An effect caused by `i` never changes anyone else's timer. -/
theorem effect_no_grief {ι : Type} [DecidableEq ι] (timers : ι → ℕ) (i j : ι) (hij : j ≠ i)
    (k : EffectKind) : effectStep timers i k j = timers j := by
  unfold effectStep; split_ifs <;> simp [Function.update_of_ne hij]

/-! ## D7: council consensus decides publication; humans decide real-world release -/

/-- The council reaches consensus when approvals (`true` votes) make up at least the fraction
`num / den` of all votes cast. -/
def consensus (num den : ℕ) (votes : List Bool) : Bool :=
  decide (num * votes.length ≤ den * votes.count true)

/-- A project leaves the virtual space for the real world only with the council's consensus
and the humans' choice to bring it out. -/
def releaseToReal (num den : ℕ) (votes : List Bool) (humansChoose : Bool) : Bool :=
  consensus num den votes && humansChoose

/-- **One rejection no longer blocks.** Whenever the threshold is short of unanimity
(`num < den`), a council with one rejection and enough approvals reaches consensus. -/
theorem one_rejection_not_blocking (num den : ℕ) (h : num < den) :
    consensus num den (false :: List.replicate num true) = true := by
  simp only [consensus, List.length_cons, List.length_replicate, List.count_cons,
    List.count_replicate, decide_eq_true_eq]
  simp
  nlinarith

/-- **Unanimity brings the veto back.** If the council requires every vote (`num = den > 0`),
a single rejection blocks consensus. -/
theorem unanimity_is_veto (den : ℕ) (hd : 0 < den) (votes : List Bool) (h : false ∈ votes) :
    consensus den den votes = false := by
  have hlt : votes.count true < votes.length := by
    rw [← List.count_add_count_not votes true]
    have : 0 < votes.count (!true) := List.count_pos_iff.mpr (by simpa using h)
    omega
  simp only [consensus, decide_eq_false_iff_not, not_le]
  exact Nat.mul_lt_mul_of_pos_left hlt hd

/-- **Approvals only help.** Adding an approval never breaks consensus, as long as the
threshold is at most unanimity. -/
theorem approval_keeps_consensus (num den : ℕ) (hnd : num ≤ den) (votes : List Bool)
    (h : consensus num den votes = true) : consensus num den (true :: votes) = true := by
  simp only [consensus, decide_eq_true_eq, List.length_cons, List.count_cons_self] at h ⊢
  nlinarith

/-- **Real-world release needs both.** -/
theorem release_needs_both (num den : ℕ) (votes : List Bool) (hc : Bool) :
    releaseToReal num den votes hc = true ↔ consensus num den votes = true ∧ hc = true := by
  simp [releaseToReal]

/-- **The humans can always decline.** -/
theorem humans_can_decline (num den : ℕ) (votes : List Bool) :
    releaseToReal num den votes false = false := by
  simp [releaseToReal]

end RoundFourRulings
