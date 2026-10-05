module

public import Mathlib
public import RequestProject.RoundThree.Decisions

/-!
# Round Three follow-ups: the designer's answers to the remaining questions

Exact statements of four answers the designer gave after `Decisions.lean`.

* **Decaying structures (not boss fights).** When a decaying structure is destroyed by
  others, the owner loses nothing (the build packs into their vault) and the raiders gain
  materials. The economy is unlimited, but every gain is paid for with effort: "no loss,
  all gain", with effort as the only source of gain.
* **Gift queue.** Extra gifts wait in a queue. Queued gifts can be interchanged (reordered)
  at any time; active and depleted gifts cannot. Gifts are never returned to the sender
  (the second gift to a slot shows that reminder). When a slot's gift is depleted, the next
  queued gift of that kind becomes active. Gifts that are never used turn into an XP boost.
* **No levels.** Already in `Decisions.lean`; an XP boost here is a boost to *skill*
  progress, since there are no levels.
* **Hard reset and blueprints.** Every blueprint crafted by a player who hard-resets has the
  player's tag removed and is credited as an anonymous contribution. The blueprint itself
  stays in the world unchanged.
-/

@[expose] public section
namespace RoundThreeFollowups

open RoundThreeDecisions

/-! ## Decaying structures: the owner loses nothing, raiders gain only by effort -/

/-- One decay raid on a structure: the raiders put in `effort` and harvest `harvest`
materials. The owner's build packs back into their vault, so the owner's holdings are
unchanged. -/
structure DecayRaid where
  harvest : ℕ
  effort : ℕ

/-- Holdings of (owner, raiders) after one raid. The owner keeps everything; the raiders
add their harvest. -/
def DecayRaid.apply (r : DecayRaid) (h : ℕ × ℕ) : ℕ × ℕ := (h.1, h.2 + r.harvest)

/-- Holdings after a sequence of raids. -/
def runRaids (h : ℕ × ℕ) : List DecayRaid → ℕ × ℕ
  | [] => h
  | r :: rest => runRaids (r.apply h) rest

/-- Total raiding effort. -/
def raidEffort (l : List DecayRaid) : ℕ := (l.map DecayRaid.effort).sum

/-- **No loss.** However many times a structure is raided, the owner's holdings never go
down. -/
theorem owner_no_loss (h : ℕ × ℕ) (l : List DecayRaid) : (runRaids h l).1 = h.1 := by
  induction l generalizing h with
  | nil => rfl
  | cons r rest ih => simp [runRaids, ih, DecayRaid.apply]

/-- **All gain is paid for by effort.** If raiders harvest at most `rate` per unit of
raiding effort (the same `rate` as any other way of gathering), then after any number of
raids the raiders hold at most their starting amount plus `rate × total raiding effort`. -/
theorem raiders_gain_le (rate : ℕ) (h : ℕ × ℕ) (l : List DecayRaid)
    (hRate : ∀ r ∈ l, r.harvest ≤ rate * r.effort) :
    (runRaids h l).2 ≤ h.2 + rate * raidEffort l := by
  induction l generalizing h with
  | nil => simp [runRaids]
  | cons r rest ih =>
    have h1 := hRate r (by simp)
    have h2 := ih (r.apply h) (fun s hs => hRate s (by simp [hs]))
    simp only [runRaids, raidEffort, List.map_cons, List.sum_cons, DecayRaid.apply] at h2 ⊢
    rw [Nat.mul_add]
    omega

/-- **Owner and raiders together: no free materials.** Combined holdings never exceed the
starting total plus `rate × total raiding effort`. A friendly "build, decay, raid" loop is
therefore just another way of gathering, at the ordinary rate. -/
theorem combined_le (rate : ℕ) (h : ℕ × ℕ) (l : List DecayRaid)
    (hRate : ∀ r ∈ l, r.harvest ≤ rate * r.effort) :
    (runRaids h l).1 + (runRaids h l).2 ≤ h.1 + h.2 + rate * raidEffort l := by
  have := raiders_gain_le rate h l hRate
  rw [owner_no_loss]
  omega

/-- Raids with no effort harvest nothing. -/
theorem no_effort_raids_no_gain (rate : ℕ) (h : ℕ × ℕ) (l : List DecayRaid)
    (hRate : ∀ r ∈ l, r.harvest ≤ rate * r.effort) (h0 : raidEffort l = 0) :
    runRaids h l = h := by
  have h2 := raiders_gain_le rate h l hRate
  have h3 : h.2 ≤ (runRaids h l).2 := by
    clear hRate h0 h2
    induction l generalizing h with
    | nil => simp [runRaids]
    | cons r rest ih =>
      have := ih (r.apply h)
      simp only [runRaids, DecayRaid.apply] at this ⊢
      omega
  have h1 := owner_no_loss h l
  rw [h0, Nat.mul_zero, Nat.add_zero] at h2
  exact Prod.ext h1 (le_antisymm h2 h3)

/-- **Unlimited, by repeating effort.** Raiding with one unit of effort at a time and
harvesting `rate` each time reaches any amount, while the owner keeps everything. -/
theorem raids_unlimited_with_effort (rate B : ℕ) (h : ℕ × ℕ) (hr : 0 < rate) :
    ∃ n, B < (runRaids h (List.replicate n ⟨rate, 1⟩)).2 ∧
      (runRaids h (List.replicate n ⟨rate, 1⟩)).1 = h.1 := by
  have key : ∀ n h', (runRaids h' (List.replicate n ⟨rate, 1⟩)).2 = h'.2 + n * rate := by
    intro n
    induction n with
    | zero => intro h'; simp [runRaids]
    | succ n ih =>
      intro h'
      simp only [List.replicate_succ, runRaids, ih, DecayRaid.apply]
      ring
  refine ⟨B + 1, ?_, owner_no_loss _ _⟩
  rw [key]
  nlinarith

/-! ## The gift queue

Superseded: the designer corrected this reading of the gift rules. The current gift rules
(numbered queue slots 1–20, the sender's warning, schematic-based points) are in
`RequestProject/RoundThree/Rulings.lean`. The results below are kept for the record. -/

variable {G : Type}

/-- The full gift state of one receiving player: the two active slots and the queue (as in
`Decisions.lean`), the gifts that have been depleted (used up), and the XP boost built up
from gifts that were never used. -/
structure GiftState (G : Type) where
  slots : GiftSlots G
  depleted : List (GiftKind × G)
  boost : ℕ

/-- Every gift the player has ever received is in exactly one place: active, queued,
depleted, or converted into one unit of XP boost. -/
def GiftState.accounted (s : GiftState G) : ℕ := s.slots.total + s.depleted.length + s.boost

/-- Receiving a gift (`sendGift` from `Decisions.lean`); the Boolean is the reminder
"gifts are not returned", shown when the matching slot is already full (that is, from the
second gift to that slot on). The gift is never sent back. -/
def receive (s : GiftState G) (k : GiftKind) (g : G) : GiftState G × Bool :=
  let r := sendGift s.slots k g
  ({ s with slots := r.1 }, r.2)

/-- Receiving a gift adds exactly one to the gifts held; nothing is refused or returned. -/
theorem receive_accounted (s : GiftState G) (k : GiftKind) (g : G) :
    (receive s k g).1.accounted = s.accounted + 1 := by
  simp only [receive, GiftState.accounted, sendGift_total]
  omega

/-- The reminder that gifts are not returned appears exactly when the matching slot is
already full. -/
theorem receive_reminder_iff (s : GiftState G) (k : GiftKind) (g : G) :
    (receive s k g).2 = true ↔
      (match k with
        | .player => s.slots.playerGift.isSome
        | .teamMember => s.slots.teamGift.isSome) = true :=
  sendGift_warns_iff s.slots k g

/-- **Interchanging queued gifts.** The queue may be replaced by any rearrangement of
itself. Active and depleted gifts are not in the queue, so they cannot be interchanged. -/
def interchange (s : GiftState G) (q : List (GiftKind × G)) (_h : q.Perm s.slots.waiting) :
    GiftState G :=
  { s with slots := { s.slots with waiting := q } }

/-- Interchanging leaves the active gifts, the depleted gifts and the boost untouched, and
keeps exactly the same queued gifts. -/
theorem interchange_spec (s : GiftState G) (q : List (GiftKind × G))
    (h : q.Perm s.slots.waiting) :
    (interchange s q h).slots.playerGift = s.slots.playerGift ∧
      (interchange s q h).slots.teamGift = s.slots.teamGift ∧
      (interchange s q h).depleted = s.depleted ∧
      (interchange s q h).boost = s.boost ∧
      (interchange s q h).slots.waiting.Perm s.slots.waiting ∧
      (interchange s q h).accounted = s.accounted := by
  refine ⟨rfl, rfl, rfl, rfl, h, ?_⟩
  simp [interchange, GiftState.accounted, GiftSlots.total, GiftSlots.activeCount, h.length_eq]

/-- A common interchange: move the queued gift at position `i` to the front of the queue. -/
def moveToFront (s : GiftState G) (i : ℕ) (hi : i < s.slots.waiting.length) : GiftState G :=
  interchange s (s.slots.waiting[i] :: s.slots.waiting.eraseIdx i)
    (List.getElem_cons_eraseIdx_perm hi)

/-- Moving a gift to the front is an interchange: nothing is lost or created. -/
theorem moveToFront_accounted (s : GiftState G) (i : ℕ) (hi : i < s.slots.waiting.length) :
    (moveToFront s i hi).accounted = s.accounted :=
  (interchange_spec s _ _).2.2.2.2.2

/-- Remove the first queued gift of kind `k`, returning it. -/
def takeNext (k : GiftKind) : List (GiftKind × G) → Option G × List (GiftKind × G)
  | [] => (none, [])
  | (k', g) :: rest =>
    if k' = k then (some g, rest)
    else
      let r := takeNext k rest
      (r.1, (k', g) :: r.2)

/-- `takeNext` removes at most one gift from the queue, and only when it returns one. -/
theorem takeNext_length (k : GiftKind) (l : List (GiftKind × G)) :
    (takeNext k l).2.length + (if (takeNext k l).1.isSome then 1 else 0) = l.length := by
  induction l with
  | nil => simp [takeNext]
  | cons a rest ih =>
    obtain ⟨k', g⟩ := a
    by_cases hk : k' = k
    · simp [takeNext, hk]
    · simp only [takeNext, hk, if_false, List.length_cons]
      omega

/-- **Depleting the active gift of kind `k`.** The active gift moves to the depleted list,
and the next queued gift of that kind (if any) becomes active. -/
def deplete (s : GiftState G) (k : GiftKind) : GiftState G :=
  match k with
  | .player =>
    match s.slots.playerGift with
    | none => s
    | some g =>
      let r := takeNext .player s.slots.waiting
      { slots := { s.slots with playerGift := r.1, waiting := r.2 },
        depleted := s.depleted ++ [(.player, g)], boost := s.boost }
  | .teamMember =>
    match s.slots.teamGift with
    | none => s
    | some g =>
      let r := takeNext .teamMember s.slots.waiting
      { slots := { s.slots with teamGift := r.1, waiting := r.2 },
        depleted := s.depleted ++ [(.teamMember, g)], boost := s.boost }

/-- Depleting a gift loses nothing: every gift is still accounted for. -/
theorem deplete_accounted (s : GiftState G) (k : GiftKind) :
    (deplete s k).accounted = s.accounted := by
  have h1 := takeNext_length GiftKind.player s.slots.waiting
  have h2 := takeNext_length GiftKind.teamMember s.slots.waiting
  cases k <;> rcases hp : s.slots.playerGift <;> rcases ht : s.slots.teamGift <;>
    simp only [deplete, hp, ht] <;>
    simp only [GiftState.accounted, GiftSlots.total, GiftSlots.activeCount, hp, ht,
      List.length_append, List.length_singleton, Option.isSome_some, Option.isSome_none,
      if_true] at h1 h2 ⊢ <;>
    split_ifs at h1 h2 ⊢ <;> simp_all <;> omega

/-- Depleting the active gift of one kind leaves the other slot alone. -/
theorem deplete_other_slot (s : GiftState G) :
    (deplete s .player).slots.teamGift = s.slots.teamGift ∧
      (deplete s .teamMember).slots.playerGift = s.slots.playerGift := by
  constructor
  · rcases hp : s.slots.playerGift <;> simp [deplete, hp]
  · rcases ht : s.slots.teamGift <;> simp [deplete, ht]

/-- **Unused gifts turn into XP boost.** Each gift still in the queue when it expires
becomes one unit of boost. Active and depleted gifts are not affected. -/
def convertUnused (s : GiftState G) : GiftState G :=
  { slots := { s.slots with waiting := [] }, depleted := s.depleted,
    boost := s.boost + s.slots.waiting.length }

/-- Converting unused gifts is not a loss: each one becomes boost, so the total is kept,
and the active and depleted gifts are untouched. -/
theorem convertUnused_spec (s : GiftState G) :
    (convertUnused s).accounted = s.accounted ∧
      (convertUnused s).slots.playerGift = s.slots.playerGift ∧
      (convertUnused s).slots.teamGift = s.slots.teamGift ∧
      (convertUnused s).depleted = s.depleted ∧
      (convertUnused s).boost = s.boost + s.slots.waiting.length := by
  refine ⟨?_, rfl, rfl, rfl, rfl⟩
  simp [convertUnused, GiftState.accounted, GiftSlots.total, GiftSlots.activeCount]
  omega

/-- Skill progress earned for `effort` with `boost` units of XP boost, at a base `rate`
per unit of effort, where each boost unit adds `perBoost` to the rate. There are no
levels: this is progress in a skill. -/
def boostedProgress (rate perBoost boost effort : ℕ) : ℕ :=
  (rate + perBoost * boost) * effort

/-- **A boost multiplies effort; it never replaces it.** With no effort, no amount of
boost gives any progress. -/
theorem boost_needs_effort (rate perBoost boost : ℕ) :
    boostedProgress rate perBoost boost 0 = 0 := by
  simp [boostedProgress]

/-- A boost never lowers progress, and more effort always gives at least as much. -/
theorem boostedProgress_mono (rate perBoost b b' e e' : ℕ) (hb : b ≤ b') (he : e ≤ e') :
    boostedProgress rate perBoost b e ≤ boostedProgress rate perBoost b' e' := by
  unfold boostedProgress
  gcongr

/-! ## Hard reset: the player's blueprints become anonymous contributions -/

/-- A blueprint on the public board: its author tag (`none` = anonymous contribution) and
its content. -/
structure Blueprint (P B : Type) where
  author : Option P
  body : B
  deriving DecidableEq

variable {P B : Type} [DecidableEq P]

/-- Remove player `p`'s tag from one blueprint. -/
def anonymize (p : P) (b : Blueprint P B) : Blueprint P B :=
  if b.author = some p then { b with author := none } else b

/-- **What a hard reset does to the blueprint board**: every blueprint crafted by `p` has
the tag removed and becomes an anonymous contribution. -/
def hardResetBoard (p : P) (board : List (Blueprint P B)) : List (Blueprint P B) :=
  board.map (anonymize p)

/-- After the reset, no blueprint on the board is tagged with the reset player. -/
theorem hardResetBoard_untagged (p : P) (board : List (Blueprint P B)) :
    ∀ b ∈ hardResetBoard p board, b.author ≠ some p := by
  intro b hb
  simp only [hardResetBoard, List.mem_map] at hb
  obtain ⟨b₀, -, rfl⟩ := hb
  unfold anonymize
  split_ifs with h
  · simp
  · exact h

/-- No blueprint is deleted and no content changes: the blueprints stay in the world,
only the tags change. -/
theorem hardResetBoard_keeps_blueprints (p : P) (board : List (Blueprint P B)) :
    (hardResetBoard p board).length = board.length ∧
      (hardResetBoard p board).map Blueprint.body = board.map Blueprint.body := by
  refine ⟨by simp [hardResetBoard], ?_⟩
  simp only [hardResetBoard, List.map_map]
  congr 1
  funext b
  simp only [Function.comp, anonymize]
  split_ifs <;> rfl

/-- Other players' credits are untouched. -/
theorem anonymize_other (p : P) (b : Blueprint P B) (h : b.author ≠ some p) :
    anonymize p b = b := by
  simp [anonymize, h]

/-- **The reset cannot be traced through blueprints.** After the reset, a blueprint that
was `p`'s looks exactly the same as an anonymous contribution with the same content. -/
theorem anonymize_indistinguishable (p : P) (body : B) :
    anonymize p (⟨some p, body⟩ : Blueprint P B) = anonymize p ⟨none, body⟩ := by
  simp [anonymize]

/-- Together with the account hard reset of `Decisions.lean`: two players with the same
real-life metadata, one of whom crafted a blueprint and one of whom found the same
blueprint already anonymous, cannot be told apart afterwards, either by account or by
board. -/
theorem hardReset_untraceable {Meta Char : Type} (a a' : Account Meta Char) (p : P)
    (hm : a.realLife = a'.realLife) (body : B) (rest : List (Blueprint P B)) :
    hardReset a = hardReset a' ∧
      hardResetBoard p (⟨some p, body⟩ :: rest) = hardResetBoard p (⟨none, body⟩ :: rest) := by
  refine ⟨hardReset_forgets a a' hm, ?_⟩
  simp [hardResetBoard, anonymize]

end RoundThreeFollowups
