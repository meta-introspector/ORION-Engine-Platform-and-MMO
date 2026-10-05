module

public import Mathlib
public import RequestProject.RoundThree.Rulings

/-!
# Round Three clarifications: node discount, lock tiers, demolition tiers, aggro timer

Exact statements of the designer's answers given after `Rulings.lean`.

* **Node discount.** A one-time, flat 50 % discount: every additional orb levelled in a node
  slot costs half the base cost (not half of the previous one). The discount belongs to the
  grid being trained. On the character grid it comes from the node's character lock
  (currently called "Gold Lock"). After symbiosis with the dragon it is off for a node until
  that node's first skill earns the dragon lock (currently "Black Hole lock") on the dragon
  matrix.
* **Character lock at 64.** The character can progress to 64 and no further until a dragon is
  unlocked. The character lock becomes available at 64, and character
  locks carry over into the dragon's symbiosis slot.
* **Demolition tiers.** Practice gives no resources. Scheduled (sanctioned) gives resources.
  Unscheduled (forced) gives resources and aggroes the local group.
* **Aggro timer.** Aggro from a destructive demolition lasts 10 minutes (600 s). Healing buffs
  and ORION-aligned debuffs let the timer run down. Any kinetic action (registered as
  intentionally Kronos-aligned, for example an attack) resets it to the full 10 minutes.
* **PvE-only mid-encounter.** Switching to PvE-only during an encounter is recorded and takes
  effect automatically when the encounter ends.
* **Gifts.** A gift with no applicable weight is rejected. A gift's points can never exceed
  the resources put into its schematic.
-/

@[expose] public section
namespace RoundThreeClarifications

open RoundThreeRulings

/-! ## The node discount: flat, once, and tied to the grid being trained -/

/-- The grid being trained: the character's own grid, or the dragon's matrix after
symbiosis. -/
inductive Grid
  | character
  | dragon
  deriving DecidableEq

/-- Number of nodes on each grid. -/
def gridSize : Grid → ℕ
  | .character => 64
  | .dragon => 144

/-- The locks a node holds. `charLocked` is earned on the character grid (currently called
"Gold Lock"); `dragonLocked` is earned when the node's first skill is locked on the dragon
matrix (currently called "Black Hole lock"). -/
structure NodeState where
  charLocked : Bool
  dragonLocked : Bool
  deriving DecidableEq

/-- The discount is on for a node exactly when that node holds the lock of the grid being
trained. -/
def discountActive : Grid → NodeState → Bool
  | .character, n => n.charLocked
  | .dragon, n => n.dragonLocked

/-- Cost of the orb with index `k` (`k = 0` is the first) levelled in a node with base cost
`c`. With the discount on, every additional orb costs `c / 2`: a single 50 % discount, not a
compounding one. -/
def orbCost (c : ℕ) (disc : Bool) (k : ℕ) : ℕ :=
  if disc = true ∧ 0 < k then c / 2 else c

/-- Total cost of levelling `n` orbs in one node. -/
def nodeCost (c : ℕ) (disc : Bool) (n : ℕ) : ℕ :=
  ((List.range n).map (orbCost c disc)).sum

/-- **Flat, not compounding.** With the discount, every additional orb costs exactly half the
base cost, however many came before it. -/
theorem orbCost_flat (c k : ℕ) (hk : 0 < k) : orbCost c true k = c / 2 := by
  simp [orbCost, hk]

/-- Total cost with the discount: the first orb at full price, every further one at half. -/
theorem nodeCost_discounted (c n : ℕ) :
    nodeCost c true (n + 1) = c + n * (c / 2) := by
  induction n with
  | zero => simp [nodeCost, orbCost]
  | succ n ih =>
    simp only [nodeCost] at *
    rw [List.range_succ, List.map_append, List.sum_append, ih]
    simp [orbCost]
    ring

/-- Without the discount every orb is at full price. -/
theorem nodeCost_full (c n : ℕ) : nodeCost c false n = n * c := by
  have : orbCost c false = fun _ => c := by funext k; simp [orbCost]
  simp [nodeCost, this]

/-- Symbiosis with the dragon, for one node: the character lock carries over into the
symbiosis slot, and the dragon lock starts unearned. -/
def bondNode (n : NodeState) : NodeState := { n with dragonLocked := false }

/-- Earn the dragon lock on a node (its first skill locked on the dragon matrix). -/
def dragonLock (n : NodeState) : NodeState := { n with dragonLocked := true }

/-- **The discount does not carry over.** Right after symbiosis the discount is off on every
node of the dragon matrix, even on nodes that were character-locked, and the character lock
itself is kept. -/
theorem bond_discount_off (n : NodeState) :
    discountActive .dragon (bondNode n) = false ∧ (bondNode n).charLocked = n.charLocked :=
  ⟨rfl, rfl⟩

/-- **Earned again the same way.** On the dragon matrix the discount is on exactly when the
node holds the dragon lock, and earning it switches the discount back on. -/
theorem dragon_discount_iff (n : NodeState) :
    (discountActive .dragon n = true ↔ n.dragonLocked = true) ∧
      discountActive .dragon (dragonLock n) = true :=
  ⟨Iff.rfl, rfl⟩

/-- After symbiosis, additional orbs in a node cost full price until the dragon lock is
earned, and half price afterwards. -/
theorem bond_then_lock_costs (c : ℕ) (n : NodeState) (k : ℕ) (hk : 0 < k) :
    orbCost c (discountActive .dragon (bondNode n)) k = c ∧
      orbCost c (discountActive .dragon (dragonLock (bondNode n))) k = c / 2 := by
  simp [orbCost, discountActive, bondNode, dragonLock, hk]

/-! ## The character lock is available at 64 -/

/-- How far the character can progress: 64 without a dragon, 144 with one. -/
def progressCap (hasDragon : Bool) : ℕ := if hasDragon then gridSize .dragon else gridSize .character

/-- One step of progress, stopped at the cap. -/
def advance (hasDragon : Bool) (p : ℕ) : ℕ := min (p + 1) (progressCap hasDragon)

/-- The character lock can be activated once progress reaches 64. -/
def charLockAvailable (p : ℕ) : Bool := decide (64 ≤ p)

/-- Without a dragon, progress never passes 64. -/
theorem advance_le_64 (p : ℕ) : advance false p ≤ 64 := by
  simp [advance, progressCap, gridSize]

theorem advance_iterate (k : ℕ) (hk : k ≤ 64) : (advance false)^[k] 0 = k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [Function.iterate_succ_apply', ih (by omega)]
    simp [advance, progressCap, gridSize]
    omega

/-- **Available at 64.** Without a dragon, 64 steps of progress from the start reach 64,
and the character lock is then available. Before 64 it is not. -/
theorem charLock_at_64 :
    (advance false)^[64] 0 = 64 ∧ charLockAvailable 64 = true ∧
      ∀ p < 64, charLockAvailable p = false := by
  refine ⟨advance_iterate 64 le_rfl, by decide, fun p hp => by simp [charLockAvailable]; omega⟩

/-! ## Demolition: three tiers -/

/-- **Three tiers.** Practice gives no resources; scheduled (sanctioned) and unscheduled
(forced) demolitions both give the resource yield. All three give the same skill progress.
Only the forced one aggroes the local group (see `RoundThreeRulings.forced_demolition_aggro`
and the timer below). -/
theorem demolition_tiers (rate yield effort : ℕ) :
    (demolitionReward rate yield effort .practice).2 = 0 ∧
      (demolitionReward rate yield effort .sanctioned).2 = yield ∧
      (demolitionReward rate yield effort .forced).2 = yield ∧
      (demolitionReward rate yield effort .forced).1 =
        (demolitionReward rate yield effort .practice).1 :=
  ⟨rfl, rfl, rfl, rfl⟩

/-! ## The aggro timer -/

/-- Length of demolition aggro, in seconds: 10 minutes. -/
def aggroWindow : ℕ := 600

/-- What a player does in one second. -/
inductive Action
  | idle
  | heal
  | orionDebuff
  | kinetic
  deriving DecidableEq

/-- Kinetic actions (such as attacks) are registered as intentionally Kronos-aligned. -/
def Action.isKinetic : Action → Bool
  | .kinetic => true
  | _ => false

/-- One second of the aggro timer, holding the seconds of aggro left (`0` = not aggroed).
A kinetic action while aggroed resets the timer to 10 minutes; anything else lets it count
down. A player who is not aggroed does not become aggroed by a kinetic action. -/
def stepAggro (r : ℕ) (a : Action) : ℕ :=
  if r = 0 then 0 else if a.isKinetic then aggroWindow else r - 1

/-- Run the timer over a sequence of seconds. -/
def runAggro (r : ℕ) (as : List Action) : ℕ := as.foldl stepAggro r

/-- A forced demolition starts the crew's aggro timer at 10 minutes. -/
def aggroOnForce : ℕ := aggroWindow

/-- **Attacking resets the timer.** While aggroed, a kinetic action sets the timer back to the
full 10 minutes. -/
theorem kinetic_resets (r : ℕ) (hr : 0 < r) : stepAggro r .kinetic = aggroWindow := by
  simp [stepAggro, Action.isKinetic, Nat.pos_iff_ne_zero.mp hr]

/-- Healing buffs and ORION-aligned debuffs do not reset the timer; it keeps counting down. -/
theorem heal_debuff_count_down (r : ℕ) :
    stepAggro r .heal = r - 1 ∧ stepAggro r .orionDebuff = r - 1 := by
  constructor <;> (unfold stepAggro; split_ifs <;> simp_all [Action.isKinetic])

theorem runAggro_nonkinetic (r : ℕ) (as : List Action) (h : ∀ a ∈ as, a.isKinetic = false) :
    runAggro r as = r - as.length := by
  induction as generalizing r with
  | nil => simp [runAggro]
  | cons a as ih =>
    have ha := h a (by simp)
    have : stepAggro r a = r - 1 := by
      unfold stepAggro; split_ifs <;> simp_all
    simp only [runAggro, List.foldl_cons] at *
    rw [this, ih _ (fun b hb => h b (by simp [hb]))]
    simp only [List.length_cons]
    omega

/-- **How aggro ends.** Ten minutes with no kinetic action (only healing buffs, ORION-aligned
debuffs, or nothing) ends the aggro from a forced demolition. -/
theorem aggro_ends (as : List Action) (h : ∀ a ∈ as, a.isKinetic = false)
    (hlen : aggroWindow ≤ as.length) : runAggro aggroOnForce as = 0 := by
  rw [runAggro_nonkinetic _ _ h, aggroOnForce]
  omega

theorem runAggro_pos (r : ℕ) (as : List Action) (hr : 0 < r) (hr' : r ≤ aggroWindow)
    (hlen : as.length < r) :
    0 < runAggro r as := by
  induction as generalizing r with
  | nil => simpa [runAggro] using hr
  | cons a as ih =>
    simp only [runAggro, List.foldl_cons, List.length_cons] at *
    apply ih <;> (unfold stepAggro; split_ifs <;> simp only [aggroWindow] at * <;> omega)

/-- **Aggro lasts the full 10 minutes.** Within 10 minutes of the forced demolition, or of the
last kinetic action while aggroed, the player is still aggroed, whatever else they do. -/
theorem aggro_lasts (as : List Action) (hlen : as.length < aggroWindow) :
    0 < runAggro aggroOnForce as ∧
      ∀ r, 0 < r → 0 < runAggro r (.kinetic :: as) := by
  refine ⟨runAggro_pos _ _ (by decide) le_rfl hlen, fun r hr => ?_⟩
  simp only [runAggro, List.foldl_cons]
  rw [kinetic_resets r hr]
  exact runAggro_pos _ _ (by decide) le_rfl hlen

/-- A player who is not aggroed never becomes aggroed through their own actions. -/
theorem no_aggro_stays (as : List Action) : runAggro 0 as = 0 := by
  induction as with
  | nil => rfl
  | cons a as ih => simpa [runAggro, stepAggro] using ih

/-! ## Switching to PvE-only mid-encounter -/

variable {S : Type}

/-- A player together with a switch change they asked for during an encounter. -/
structure Toggle (S : Type) where
  f : Fighter S
  pending : Option Bool

/-- Ask to set the PvP switch. During an encounter the request is recorded; otherwise it takes
effect at once. -/
def requestPvp (t : Toggle S) (b : Bool) : Toggle S :=
  if t.f.inEncounter then { t with pending := some b } else ⟨{ t.f with pvpOpen := b }, none⟩

/-- End the encounter: a recorded request takes effect automatically. -/
def endEncounter (t : Toggle S) : Toggle S :=
  ⟨{ t.f with inEncounter := false, pvpOpen := t.pending.getD t.f.pvpOpen }, none⟩

/-- A request made mid-encounter does not change the switch during the encounter. -/
theorem request_midEncounter_unchanged (t : Toggle S) (b : Bool) (h : t.f.inEncounter = true) :
    (requestPvp t b).f = t.f := by
  simp [requestPvp, h]

/-- **Automatic switch at the end.** When the encounter ends, the switch is set to the last
value asked for during it. -/
theorem request_applies_at_end (t : Toggle S) (b b' : Bool) (h : t.f.inEncounter = true) :
    (endEncounter (requestPvp t b)).f.pvpOpen = b ∧
      (endEncounter (requestPvp (requestPvp t b) b')).f.pvpOpen = b' := by
  simp [endEncounter, requestPvp, h]

/-- Outside an encounter the switch changes at once. -/
theorem request_outside_immediate (t : Toggle S) (b : Bool) (h : t.f.inEncounter = false) :
    (requestPvp t b).f.pvpOpen = b := by
  simp [requestPvp, h]

/-- **Safe once it ends.** A player who asks for PvE-only mid-encounter and has not aggroed
their skybox cannot be attacked by anyone once the encounter ends. -/
theorem pve_request_safe_after (t : Toggle S) (a : Fighter S) (h : t.f.inEncounter = true)
    (hna : ¬ t.f.aggroHere) : ¬ mayAttack a (endEncounter (requestPvp t false)).f := by
  apply pvp_off_safe
  · simp [endEncounter, requestPvp, h]
  · simpa [endEncounter, requestPvp, h, Fighter.aggroHere] using hna

/-! ## Gifts: weight required, value capped by resources -/

variable {K P : Type} [DecidableEq K] [DecidableEq P]

/-- Give a gift, rejecting any gift with no applicable weight (worth no points). -/
def giveWeighted (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) : Option (List (Gift K) × List (Gift K) × List (P × P) × Bool) :=
  if 0 < g.points then giveGift sender receiver g inv avail given else none

/-- **Empty gifts are rejected.** -/
theorem empty_gift_rejected (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) (h : g.points = 0) :
    giveWeighted sender receiver g inv avail given = none := by
  simp [giveWeighted, h]

/-- Every gift that reaches the receiver has weight: if all their available gifts had weight
before, they all do after. -/
theorem giveWeighted_all_weighted (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) (r) (hr : giveWeighted sender receiver g inv avail given = some r)
    (havail : ∀ x ∈ avail, 0 < x.points) : ∀ x ∈ r.2.1, 0 < x.points := by
  unfold giveWeighted giveGift at hr
  split_ifs at hr with hp
  cases hr
  intro x hx
  rcases List.mem_cons.mp hx with rfl | hx
  · exact hp
  · exact havail x hx

omit [DecidableEq K] in
/-- **No points from nothing.** If every gift is worth no more than the resources put into its
schematic, then the points from unused gifts never exceed those resources, and any gift that
can be given at all had resources put into it. -/
theorem gift_points_from_resources (b : GiftBox K) (resources : Gift K → ℕ)
    (hc : ∀ g, g.points ≤ resources g) :
    (b.unused.map Gift.points).sum ≤ (b.unused.map resources).sum ∧
      ∀ g : Gift K, 0 < g.points → 0 < resources g :=
  ⟨endEncounter_le_effort b resources hc, fun g hg => lt_of_lt_of_le hg (hc g)⟩

end RoundThreeClarifications
