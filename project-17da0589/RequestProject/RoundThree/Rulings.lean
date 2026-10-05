module

public import Mathlib
public import RequestProject.RoundThree.Followups

/-!
# Round Three rulings: demolition limits, PvP and aggro, the gift queue, and the rest

Exact statements of the designer's answers given after `Followups.lean`.

* **Demolition.** A structure can be set as a deconstruction zone at most once per month
  (a window of `W` days). Demolishing it again inside that window is possible only by
  force, and forcing it aggroes the whole local group (the skybox) against the demolishers.
  A structure can also be set up as a *practice demolition*: skill progress only, no
  resources.
* **PvP and aggro.** Players toggle whether they are open to PvP. The switch cannot be
  flipped during an encounter, and there is no cool-off timer otherwise. A player who has
  aggroed a skybox is a target for every asset and every player in that skybox, whatever
  their switch says.
* **Gifts.** Gifts are crafted or owned items, handed over from the sender's inventory.
  A second gift from the same sender to the same player in the same encounter shows the
  warning "gifted items are not returned". The receiver has between 1 and 20 numbered queue
  slots, depending on skill; an occupied slot cannot take a second gift. The queue tries
  slot 1 first, then 2, and so on. Gifts still unused when the encounter ends become excess
  skill points towards loot rewards, in the skill named by the gift's schematic. Only the
  player edits their own queue; a group queue is edited by the leader or an admin they
  assign.
* **Reset blueprints.** No royalties after the tags are removed, and fork histories show
  "anonymous" too.
* **AI Council.** Developer-secure information (such as real-world identities) is open only
  to the assigned developer team and collaborator admins. Human approval does not change
  this. AI Council engagement with the build needs a developer on the team.
* **Black Hole Orb and the 144 cap.** Both hold. Skills cap at 144; the dragon's Black Hole
  Orb can be activated in game, the player's 64 Gold Lock Orb once the character reaches 64.
-/

@[expose] public section
namespace RoundThreeRulings

/-! ## Demolition: once per month, forcing it aggroes the local group -/

/-- Result of asking for a structure to be set as a deconstruction zone. -/
inductive ZoneRequest
  | sanctioned
  | forced
  deriving DecidableEq

/-- Ask, at day `now`, to set a structure as a deconstruction zone, when its last
sanctioned zone was at day `last` (if ever). Inside the `W`-day window the request can only
go ahead by force. -/
def requestZone (W now : ℕ) (last : Option ℕ) : ZoneRequest :=
  match last with
  | none => .sanctioned
  | some t => if now < t + W then .forced else .sanctioned

/-- A request is forced exactly when it falls inside the window after the last sanctioned
zone. -/
theorem requestZone_forced_iff (W now : ℕ) (last : Option ℕ) :
    requestZone W now last = .forced ↔ ∃ t, last = some t ∧ now < t + W := by
  cases last with
  | none => simp [requestZone]
  | some t =>
    simp only [requestZone, Option.some.injEq, exists_eq_left']
    split_ifs with h <;> simp [h]

/-- The days on which a sequence of requests was sanctioned. Forced demolitions do not
reset the monthly clock. -/
def sanctionedDays (W : ℕ) : Option ℕ → List ℕ → List ℕ
  | _, [] => []
  | last, t :: ts =>
    if requestZone W t last = .sanctioned then t :: sanctionedDays W (some t) ts
    else sanctionedDays W last ts

theorem sanctionedDays_chain (W l : ℕ) (ts : List ℕ) :
    List.IsChain (fun a b => a + W ≤ b) (l :: sanctionedDays W (some l) ts) := by
  induction ts generalizing l with
  | nil => simp [sanctionedDays]
  | cons t ts ih =>
    by_cases h : t < l + W
    · have : requestZone W t (some l) = .forced := by simp [requestZone, h]
      simp only [sanctionedDays, this, reduceCtorEq, if_false]
      exact ih l
    · have : requestZone W t (some l) = .sanctioned := by simp [requestZone, h]
      simp only [sanctionedDays, this, if_true]
      exact List.IsChain.cons_cons (by omega) (ih t)

/-- **Once per month.** Any two sanctioned deconstruction zones on the same structure, in
order, are at least `W` days apart, however the requests are timed. -/
theorem sanctioned_spaced (W : ℕ) (ts : List ℕ) :
    List.IsChain (fun a b => a + W ≤ b) (sanctionedDays W none ts) := by
  induction ts with
  | nil => simp [sanctionedDays]
  | cons t ts ih =>
    simp only [sanctionedDays, requestZone, if_true]
    exact sanctionedDays_chain W t ts

theorem chain_bound (W T : ℕ) :
    ∀ (a : ℕ) (s : List ℕ), List.IsChain (fun a b => a + W ≤ b) (a :: s) →
      (∀ x ∈ s, x < T) → a < T → a + s.length * W < T
  | a, [], _, _, ha => by simpa using ha
  | a, b :: s, hc, hs, _ => by
    rw [List.isChain_cons_cons] at hc
    have := chain_bound W T b s hc.2 (fun x hx => hs x (by simp [hx])) (hs b (by simp))
    simp only [List.length_cons]
    nlinarith [hc.1]

/-- **Not an infinite resource stream.** If every request is made before day `T`, then the
number `k` of sanctioned deconstruction zones satisfies `k × W < T + W`: about one per
month, and no more. -/
theorem sanctioned_count_bound (W T : ℕ) (hW : 0 < W) (ts : List ℕ) (hT : ∀ t ∈ ts, t < T) :
    (sanctionedDays W none ts).length * W < T + W := by
  have hsub : ∀ (last : Option ℕ) (ts : List ℕ), ∀ x ∈ sanctionedDays W last ts, x ∈ ts := by
    intro last ts
    induction ts generalizing last with
    | nil => simp [sanctionedDays]
    | cons t ts ih =>
      intro x hx
      simp only [sanctionedDays] at hx
      split_ifs at hx
      · rcases List.mem_cons.mp hx with rfl | hx
        · simp
        · exact List.mem_cons_of_mem _ (ih _ x hx)
      · exact List.mem_cons_of_mem _ (ih _ x hx)
  have hc := sanctioned_spaced W ts
  rcases hs : sanctionedDays W none ts with _ | ⟨a, s⟩
  · simpa using Nat.lt_add_left T hW
  · rw [hs] at hc
    have hall : ∀ x ∈ a :: s, x < T := fun x hx => hT x (hsub none ts x (hs ▸ hx))
    have := chain_bound W T a s hc (fun x hx => hall x (by simp [hx])) (hall a (by simp))
    simp only [List.length_cons]
    nlinarith

/-- How a structure is demolished. -/
inductive DemolitionMode
  | sanctioned
  | forced
  | practice
  deriving DecidableEq

/-- What a demolition pays: (skill progress, resources). Every mode pays skill progress
for the effort put in; a practice demolition pays no resources, like a training hologram.
`yield` is the resource yield of a real demolition. -/
def demolitionReward (rate yield effort : ℕ) : DemolitionMode → ℕ × ℕ
  | .practice => (rate * effort, 0)
  | _ => (rate * effort, yield)

/-- A practice demolition gives no resources, and the same skill progress as a real one. -/
theorem practice_no_resources (rate yield effort : ℕ) :
    (demolitionReward rate yield effort .practice).2 = 0 ∧
      (demolitionReward rate yield effort .practice).1 =
        (demolitionReward rate yield effort .sanctioned).1 :=
  ⟨rfl, rfl⟩

/-! ## PvP and aggro -/

/-- A player, for the purposes of who may attack whom: the skybox they are in, their PvP
switch, whether they are in an encounter, and the skybox they have aggroed (if any). -/
structure Fighter (S : Type) where
  skybox : S
  pvpOpen : Bool
  inEncounter : Bool
  aggroed : Option S

variable {S : Type}

/-- `t` has aggroed the skybox they are standing in. -/
def Fighter.aggroHere (t : Fighter S) : Prop := t.aggroed = some t.skybox

/-- Every asset in a skybox targets a player who has aggroed that skybox. -/
def assetTargets (assetBox : S) (t : Fighter S) : Prop :=
  t.aggroed = some assetBox ∧ t.skybox = assetBox

/-- Player `a` may attack player `t` if `t` has aggroed the skybox they are both in, or if
both have their PvP switch open. -/
def mayAttack (a t : Fighter S) : Prop :=
  (t.aggroHere ∧ a.skybox = t.skybox) ∨ (a.pvpOpen = true ∧ t.pvpOpen = true)

/-- Set the PvP switch. Refused (`none`) during an encounter; otherwise it takes effect
at once. There is no timer anywhere in the state, so there is no cool-off. -/
def setPvp (p : Fighter S) (b : Bool) : Option (Fighter S) :=
  if p.inEncounter then none else some { p with pvpOpen := b }

/-- The switch cannot be flipped in the middle of an encounter.

*Superseded:* a mid-encounter change is now recorded and applied automatically when the
encounter ends; see `RoundThreeClarifications.request_applies_at_end`. -/
theorem setPvp_refused_in_encounter (p : Fighter S) (b : Bool) (h : p.inEncounter = true) :
    setPvp p b = none := by
  simp [setPvp, h]

/-- **No cool-off.** Outside an encounter the switch can be flipped, and flipped back,
straight away. -/
theorem setPvp_no_cooldown (p : Fighter S) (h : p.inEncounter = false) (b b' : Bool) :
    ∃ q q', setPvp p b = some q ∧ setPvp q b' = some q' ∧ q'.pvpOpen = b' := by
  refine ⟨{ p with pvpOpen := b }, { p with pvpOpen := b' }, ?_, ?_, rfl⟩ <;>
    simp [setPvp, h]

/-- **Done with fighting.** Once a player who has not aggroed their skybox has turned PvP
off, nobody can attack them. -/
theorem pvp_off_safe (a t : Fighter S) (hoff : t.pvpOpen = false) (hna : ¬ t.aggroHere) :
    ¬ mayAttack a t := by
  simp [mayAttack, hoff, hna]

/-- **Aggro overrides the switch.** A player who has aggroed a skybox can be attacked by
every player in it and is targeted by every asset in it, whatever either switch says. -/
theorem aggro_overrides (a t : Fighter S) (h : t.aggroHere) (hs : a.skybox = t.skybox) :
    mayAttack a t ∧ assetTargets t.skybox t :=
  ⟨Or.inl ⟨h, hs⟩, h, rfl⟩

/-- Turning PvP off does not lift aggro. -/
theorem pvp_off_keeps_aggro (a t q : Fighter S) (h : t.aggroHere) (hs : a.skybox = t.skybox)
    (hq : setPvp t false = some q) : mayAttack a q := by
  unfold setPvp at hq
  split_ifs at hq
  cases hq
  exact Or.inl ⟨h, hs⟩

/-- A forced demolition in skybox `s` aggroes the local group against the crew that forced
it: each crew member is marked as having aggroed `s`. -/
def forceDemolition (s : S) (crew : List (Fighter S)) : List (Fighter S) :=
  crew.map fun f => { f with aggroed := some s }

/-- After a forced demolition, any player in that skybox may attack any crew member still
there, and every asset in it targets them. -/
theorem forced_demolition_aggro (s : S) (crew : List (Fighter S)) (a : Fighter S)
    (ha : a.skybox = s) : ∀ t ∈ forceDemolition s crew, t.skybox = s →
      mayAttack a t ∧ assetTargets s t := by
  intro t ht hts
  simp only [forceDemolition, List.mem_map] at ht
  obtain ⟨f, -, rfl⟩ := ht
  refine ⟨Or.inl ⟨?_, ?_⟩, rfl, hts⟩
  · simp only [Fighter.aggroHere]; rw [hts]
  · simp only at hts; rw [ha, hts]

/-! ## Gifts -/

/-- A gift item. Its schematic fixes the skill `skill` that an unused gift's points go to
and how many points `points` it is worth. -/
structure Gift (K : Type) where
  id : ℕ
  skill : K
  points : ℕ
  deriving DecidableEq

variable {K P : Type} [DecidableEq K] [DecidableEq P]

/-- Number of queue slots: between 1 and 20, where `u` is what micromanagement skill has
unlocked. -/
def queueSlots (u : ℕ) : ℕ := max 1 (min 20 u)

theorem queueSlots_bounds (u : ℕ) : 1 ≤ queueSlots u ∧ queueSlots u ≤ 20 := by
  unfold queueSlots; omega

/-- A sender gives a gift they own to a receiver during an encounter. `given` records the
(sender, receiver) pairs that have already happened this encounter. The result is the
sender's new inventory, the receiver's new available gifts, the updated record, and the
warning flag "gifted items are not returned". A sender cannot give what they do not own. -/
def giveGift (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) : Option (List (Gift K) × List (Gift K) × List (P × P) × Bool) :=
  if g ∈ inv then
    some (inv.erase g, g :: avail, (sender, receiver) :: given, decide ((sender, receiver) ∈ given))
  else none

/-- The warning shows exactly when this sender has already given this receiver a gift in
this encounter. -/
theorem giveGift_warning_iff (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) (r) (hr : giveGift sender receiver g inv avail given = some r) :
    r.2.2.2 = true ↔ (sender, receiver) ∈ given := by
  unfold giveGift at hr
  split_ifs at hr
  cases hr
  simp

/-- Only items the sender owns can be given. -/
theorem giveGift_needs_owned (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) (h : g ∉ inv) : giveGift sender receiver g inv avail given = none := by
  simp [giveGift, h]

/-- Giving moves exactly one item from the sender to the receiver. -/
theorem giveGift_conserves (sender receiver : P) (g : Gift K) (inv avail : List (Gift K))
    (given : List (P × P)) (r) (hr : giveGift sender receiver g inv avail given = some r) :
    r.1.length + r.2.1.length = inv.length + avail.length ∧ g ∈ r.2.1 := by
  unfold giveGift at hr
  split_ifs at hr with hg
  cases hr
  have := List.length_erase_of_mem hg
  have := List.length_pos_of_mem hg
  simp only [List.length_cons, List.mem_cons, true_or, and_true]
  omega

/-- The receiver's gifts: those available (not queued) and the numbered queue slots
`1, …, n`, where `n = queueSlots unlocked`. -/
structure GiftBox (K : Type) where
  unlocked : ℕ
  avail : List (Gift K)
  queue : ℕ → Option (Gift K)

/-- Slot numbers that exist: `1, …, queueSlots unlocked`. -/
def GiftBox.slotNums (b : GiftBox K) : List ℕ := List.range' 1 (queueSlots b.unlocked)

/-- Put an available gift into slot `i`. Refused (`none`) if the slot does not exist, is
already occupied, or the gift is not available. To change an occupied slot, the player
first takes its gift out (`unslot`). -/
def slotGift (b : GiftBox K) (i : ℕ) (g : Gift K) : Option (GiftBox K) :=
  if i ∈ b.slotNums ∧ b.queue i = none ∧ g ∈ b.avail then
    some { b with avail := b.avail.erase g, queue := Function.update b.queue i (some g) }
  else none

/-- An occupied slot cannot take a second gift. -/
theorem slotGift_occupied (b : GiftBox K) (i : ℕ) (g g' : Gift K) (h : b.queue i = some g') :
    slotGift b i g = none := by
  simp [slotGift, h]

/-- Take the gift out of slot `i`, back to the available gifts (manual re-slotting). -/
def unslot (b : GiftBox K) (i : ℕ) : GiftBox K :=
  match b.queue i with
  | none => b
  | some g => { b with avail := g :: b.avail, queue := Function.update b.queue i none }

/-- The slot the queue activates: the lowest-numbered slot whose gift is not blocked
(`ready g`). -/
def nextSlot (b : GiftBox K) (ready : Gift K → Bool) : Option ℕ :=
  b.slotNums.find? fun i => match b.queue i with
    | some g => ready g
    | none => false

/-- The test the queue applies to slot `i`. -/
def slotReady (b : GiftBox K) (ready : Gift K → Bool) (i : ℕ) : Prop :=
  ∃ g, b.queue i = some g ∧ ready g = true

omit [DecidableEq K] in
theorem slotReady_iff (b : GiftBox K) (ready : Gift K → Bool) (i : ℕ) :
    slotReady b ready i ↔ (match b.queue i with | some g => ready g | none => false) = true := by
  unfold slotReady
  cases b.queue i <;> simp

omit [DecidableEq K] in
theorem find?_range'_min (q : ℕ → Bool) :
    ∀ (n st i : ℕ), (List.range' st n).find? q = some i → ∀ j, st ≤ j → j < i → q j = false
  | 0, st, i, h => by simp at h
  | n + 1, st, i, h => by
    intro j hj hji
    rw [List.range'_succ, List.find?_cons] at h
    by_cases hq : q st
    · rw [hq] at h; cases h; omega
    · rw [Bool.not_eq_true] at hq
      rw [hq] at h
      rcases Nat.eq_or_lt_of_le hj with rfl | hlt
      · exact hq
      · exact find?_range'_min q n (st + 1) i h j hlt hji

omit [DecidableEq K] in
/-- **Slot 1 first, then 2, then 3, ….** If the queue activates slot `i`, that slot's gift
is ready, and every lower-numbered slot was empty or blocked. -/
theorem nextSlot_spec (b : GiftBox K) (ready : Gift K → Bool) (i : ℕ)
    (h : nextSlot b ready = some i) :
    1 ≤ i ∧ i ≤ queueSlots b.unlocked ∧ slotReady b ready i ∧
      ∀ j, 1 ≤ j → j < i → ¬ slotReady b ready j := by
  unfold nextSlot at h
  have hmem := List.mem_of_find?_eq_some h
  have hi := List.find?_some h
  simp only [GiftBox.slotNums, List.mem_range'_1] at hmem
  refine ⟨by omega, by omega, (slotReady_iff b ready i).2 hi, ?_⟩
  intro j hj hji hr
  have := find?_range'_min _ _ 1 i h j hj hji
  rw [(slotReady_iff b ready j).1 hr] at this
  exact Bool.noConfusion this

omit [DecidableEq K] in
/-- If any existing slot holds a ready gift, the queue activates something. -/
theorem nextSlot_isSome (b : GiftBox K) (ready : Gift K → Bool) (i : ℕ)
    (hi : 1 ≤ i ∧ i ≤ queueSlots b.unlocked) (hr : slotReady b ready i) :
    (nextSlot b ready).isSome := by
  unfold nextSlot
  rw [List.find?_isSome]
  exact ⟨i, by simp [GiftBox.slotNums]; omega, (slotReady_iff b ready i).1 hr⟩

/-- The gifts still unused: the available ones and those in existing queue slots. -/
def GiftBox.unused (b : GiftBox K) : List (Gift K) :=
  b.avail ++ b.slotNums.filterMap b.queue

/-- Points an unused gift adds to skill `k` when the encounter ends. -/
def pointsFor (k : K) (g : Gift K) : ℕ := if g.skill = k then g.points else 0

/-- **End of encounter.** Every unused gift becomes excess skill points towards loot
rewards, in the skill its schematic names: skill `k` receives this many points. -/
def endEncounterPoints (b : GiftBox K) (k : K) : ℕ := (b.unused.map (pointsFor k)).sum

/-- Each unused gift is converted once, into its schematic's skill only: summed over any
list of skills that contains every schematic skill once, the points are exactly the total
schematic value of the unused gifts. -/
theorem endEncounter_total (b : GiftBox K) (ks : List K) (hnd : ks.Nodup)
    (hall : ∀ g ∈ b.unused, g.skill ∈ ks) :
    (ks.map (endEncounterPoints b)).sum = (b.unused.map Gift.points).sum := by
  unfold endEncounterPoints
  generalize b.unused = l at hall
  induction l with
  | nil => simp
  | cons g rest ih =>
    simp only [List.map_cons, List.sum_cons]
    have : (ks.map (pointsFor · g)).sum = g.points := by
      have hk := hall g (by simp)
      obtain ⟨l1, l2, rfl⟩ := List.append_of_mem hk
      have hnd' := hnd
      rw [List.nodup_append] at hnd'
      have h1 : ∀ x ∈ l1, x ≠ g.skill := fun x hx he =>
        hnd'.2.2 x hx g.skill (by simp) he
      have h2 : ∀ x ∈ l2, x ≠ g.skill := fun x hx he =>
        (List.nodup_cons.mp hnd'.2.1).1 (he ▸ hx)
      simp only [List.map_append, List.map_cons, List.sum_append, List.sum_cons, pointsFor]
      rw [List.sum_eq_zero (by
          intro y hy; obtain ⟨x, hx, rfl⟩ := List.mem_map.mp hy
          simp [Ne.symm (h1 x hx)]),
        List.sum_eq_zero (by
          intro y hy; obtain ⟨x, hx, rfl⟩ := List.mem_map.mp hy
          simp [Ne.symm (h2 x hx)])]
      simp
    rw [List.sum_map_add, this, ih (fun g' hg' => hall g' (by simp [hg']))]

omit [DecidableEq K] in
/-- **Gift points still trace back to effort.** If no schematic is worth more points than
the effort it takes to craft (`cost`), the points from unused gifts are at most the crafting
effort that went into them. -/
theorem endEncounter_le_effort (b : GiftBox K) (cost : Gift K → ℕ)
    (hc : ∀ g, g.points ≤ cost g) :
    (b.unused.map Gift.points).sum ≤ (b.unused.map cost).sum :=
  List.sum_le_sum (by simpa using fun g _ => hc g)

/-- Who is acting on a queue. -/
inductive Actor (P : Type)
  | player (p : P)
  | nonPlayer

/-- Whose queue it is: a player's own, or a group's (with its leader and the admin the
leader has assigned, if any). -/
inductive QueueOwner (P : Type)
  | own (p : P)
  | group (leader : P) (admin : Option P)

/-- Who may swap gifts in a queue. -/
def maySwap : Actor P → QueueOwner P → Prop
  | .player a, .own p => a = p
  | .player a, .group leader admin => a = leader ∨ admin = some a
  | .nonPlayer, _ => False

omit [DecidableEq P] in
/-- Only the player edits their own queue; only the leader (or the admin they assigned)
edits the group queue; nothing other than a player edits any queue. -/
theorem maySwap_spec (a p leader : P) (admin : Option P) (o : QueueOwner P) :
    (maySwap (.player a) (.own p) ↔ a = p) ∧
      (maySwap (.player a) (.group leader admin) ↔ a = leader ∨ admin = some a) ∧
      ¬ maySwap .nonPlayer o :=
  ⟨Iff.rfl, Iff.rfl, id⟩

/-! ## Reset blueprints: no royalties, fork histories anonymous -/

open RoundThreeFollowups

/-- Who receives royalties from a blueprint: its tagged author, and nobody for an
anonymous contribution. -/
def royaltyTo {B : Type} (b : Blueprint P B) : Option P := b.author

/-- After a hard reset, none of the board's royalties go to the reset player. -/
theorem reset_no_royalty {B : Type} (p : P) (board : List (Blueprint P B)) :
    ∀ b ∈ hardResetBoard p board, royaltyTo b ≠ some p :=
  hardResetBoard_untagged p board

/-- Anonymise a fork's history (the list of authors it was forked from). -/
def anonymizeHistory (p : P) (h : List (Option P)) : List (Option P) :=
  h.map fun a => if a = some p then none else a

/-- After the reset, the player appears in no fork history; every other entry is kept. -/
theorem anonymizeHistory_spec (p : P) (h : List (Option P)) :
    some p ∉ anonymizeHistory p h ∧ (anonymizeHistory p h).length = h.length ∧
      ∀ q, q ≠ p → (some q ∈ anonymizeHistory p h ↔ some q ∈ h) := by
  refine ⟨?_, by simp [anonymizeHistory], ?_⟩
  · simp only [anonymizeHistory, List.mem_map, not_exists, not_and]
    intro a _ he
    by_cases ha : a = some p
    · rw [if_pos ha] at he; exact absurd he (by simp)
    · rw [if_neg ha] at he; exact ha he
  · intro q hq
    simp only [anonymizeHistory, List.mem_map]
    constructor
    · rintro ⟨a, ha, he⟩
      by_cases h1 : a = some p
      · rw [if_pos h1] at he; exact absurd he (by simp)
      · rw [if_neg h1] at he; exact he ▸ ha
    · intro hq'
      exact ⟨some q, hq', by simp [hq]⟩

/-! ## AI Council: no access to developer-secure information -/

/-- Who asks for developer-secure information. -/
inductive Requester (P : Type)
  | human (p : P)
  | aiCouncil

/-- Access to developer-secure information (such as real-world identities): only humans on
the assigned developer team or collaborator admins. The `humanApproval` flag is accepted and
deliberately ignored: approval does not open access. -/
def secureAccess (devTeam collabAdmins : List P) (r : Requester P) (_humanApproval : Bool) :
    Prop :=
  match r with
  | .human p => p ∈ devTeam ∨ p ∈ collabAdmins
  | .aiCouncil => False

omit [DecidableEq P] in
/-- **Absolute hard stop.** The AI Council never has access, with or without human
approval, and approval never changes anyone's access. -/
theorem aiCouncil_hard_stop (devTeam collabAdmins : List P) (approval : Bool) :
    ¬ secureAccess devTeam collabAdmins .aiCouncil approval ∧
      ∀ r, (secureAccess devTeam collabAdmins r true ↔
        secureAccess devTeam collabAdmins r false) :=
  ⟨id, fun _ => Iff.rfl⟩

/-- AI Council engagement with the build is allowed only when a developer is on the
team for it. -/
def councilMayEngage (devTeam session : List P) : Prop := ∃ p ∈ session, p ∈ devTeam

omit [DecidableEq P] in
theorem councilMayEngage_needs_dev (devTeam : List P) : ¬ councilMayEngage devTeam [] := by
  simp [councilMayEngage]

/-! ## Black Hole Orb and the 144 cap: both -/

/-- Skills cap at 144. -/
def skillCap : ℕ := 144

/-- When an orb can be activated: during ordinary play, or once the character has reached 64
(all 64 character nodes). -/
inductive Phase
  | inGame
  | at64
  deriving DecidableEq

/-- The two orbs: the player's 64 Gold Lock Orb and the dragon's Black Hole Orb. -/
inductive Orb
  | goldLock
  | blackHole
  deriving DecidableEq

/-- The Gold Lock Orb activates once the character reaches 64; the Black Hole Orb in game (and
at 64). -/
def canActivate : Orb → Phase → Bool
  | .goldLock, p => p == .at64
  | .blackHole, _ => true

/-- Activate the Black Hole bank into a skill: as much of `amount` as the bank holds and the
cap allows moves into the skill; the rest stays banked. Returns (skill, bank). -/
def activateBank (skill bank amount : ℕ) : ℕ × ℕ :=
  let m := min amount (min bank (skillCap - skill))
  (skill + m, bank - m)

/-- **Both hold.** Activating the bank never takes a skill past 144, and nothing is lost:
skill plus bank is unchanged. -/
theorem activateBank_spec (skill bank amount : ℕ) (h : skill ≤ skillCap) :
    (activateBank skill bank amount).1 ≤ skillCap ∧
      (activateBank skill bank amount).1 + (activateBank skill bank amount).2 = skill + bank := by
  simp only [activateBank]
  omega

/-- The Gold Lock Orb cannot be activated before the character reaches 64; the Black Hole Orb
can. (The platform grows organically and has no final stage; "64" is the character's cap before
a dragon, see `RoundThreeClarifications.charLock_at_64`.) -/
theorem orb_phases : canActivate .goldLock .inGame = false ∧
    canActivate .goldLock .at64 = true ∧ canActivate .blackHole .inGame = true := by
  decide

end RoundThreeRulings
