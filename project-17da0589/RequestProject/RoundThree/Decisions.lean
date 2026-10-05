module

public import Mathlib

/-!
# Round Three decisions: the rules as settled by the designer

Exact statements of the rules the designer settled after the Round Three compilation
review. Each is modelled in the simplest way that keeps its logic. None of them is a
statement about game code (there is none yet).

* **Gifts.** Each player has one active *player* gift slot and one active *team-member*
  gift slot. Sending a gift is never refused; sending one while the matching slot is
  already filled raises a warning and the gift waits instead of becoming active.
* **Expended components.** Components spent in an encounter are used up. Nothing is
  returned automatically. Any increase in holdings has to be paid for with effort, so an
  unlimited amount can be reached only with unlimited effort.
* **No levels.** A character is an archetype (chosen at the load screen) plus skills.
  Encounters scale to the skills of the people in them; for a solo player that is their
  own skills, and lowering them by hand never improves the reward-to-difficulty ratio.
* **Two different resets.** The account *hard reset* returns the account to exactly the
  state of a first-time player with the same real-life metadata. The optional
  *character reset* is a different function that touches one character only.
* **Contributor credits.** Every contribution is credited at launch: by name if the
  contributor has set up a profile, otherwise as an anonymous contributor until they ask
  for a correction.
-/

@[expose] public section
namespace RoundThreeDecisions

/-! ## Gifts: one active player gift and one active team-member gift per player -/

/-- Which slot a gift is aimed at: the player's own gift, or a gift for one of their team
members. -/
inductive GiftKind
  | player
  | teamMember
  deriving DecidableEq, Repr

/-- The gift state of one player: what is active in each slot, and the gifts that arrived
while a slot was full (they wait; they are not thrown away). -/
structure GiftSlots (G : Type) where
  playerGift : Option G
  teamGift : Option G
  waiting : List (GiftKind × G)

variable {G : Type}

/-- The empty gift state. -/
def GiftSlots.empty : GiftSlots G := ⟨none, none, []⟩

/-- Number of active gifts on a player. -/
def GiftSlots.activeCount (s : GiftSlots G) : ℕ :=
  (if s.playerGift.isSome then 1 else 0) + (if s.teamGift.isSome then 1 else 0)

/-- Total number of gifts the player holds, active or waiting. -/
def GiftSlots.total (s : GiftSlots G) : ℕ := s.activeCount + s.waiting.length

/-- Send a gift. Returns the new state and whether a warning is shown. Nothing is ever
refused: if the matching slot is free the gift becomes active with no warning; if it is
full, the gift waits and the warning is raised. -/
def sendGift (s : GiftSlots G) (k : GiftKind) (g : G) : GiftSlots G × Bool :=
  match k with
  | .player =>
    match s.playerGift with
    | none => ({ s with playerGift := some g }, false)
    | some _ => ({ s with waiting := s.waiting ++ [(k, g)] }, true)
  | .teamMember =>
    match s.teamGift with
    | none => ({ s with teamGift := some g }, false)
    | some _ => ({ s with waiting := s.waiting ++ [(k, g)] }, true)

/-- A player never has more than two active gifts: at most one player gift and at most one
team-member gift. -/
theorem activeCount_le_two (s : GiftSlots G) : s.activeCount ≤ 2 := by
  unfold GiftSlots.activeCount; split_ifs <;> omega

/-- **Gifts are never refused.** Every gift sent is kept: the total held goes up by
exactly one. -/
theorem sendGift_total (s : GiftSlots G) (k : GiftKind) (g : G) :
    (sendGift s k g).1.total = s.total + 1 := by
  cases k <;> rcases hp : s.playerGift <;> rcases ht : s.teamGift <;>
    simp [sendGift, GiftSlots.total, GiftSlots.activeCount, hp, ht] <;> omega

/-- **The warning fires exactly when the matching slot is already filled.** -/
theorem sendGift_warns_iff (s : GiftSlots G) (k : GiftKind) (g : G) :
    (sendGift s k g).2 = true ↔
      (match k with
        | .player => s.playerGift.isSome
        | .teamMember => s.teamGift.isSome) = true := by
  cases k <;> rcases hp : s.playerGift <;> rcases ht : s.teamGift <;>
    simp [sendGift, hp, ht]

/-- A gift sent with no warning is active right away in its slot. -/
theorem sendGift_no_warning_active (s : GiftSlots G) (k : GiftKind) (g : G)
    (h : (sendGift s k g).2 = false) :
    (match k with
      | .player => (sendGift s k g).1.playerGift
      | .teamMember => (sendGift s k g).1.teamGift) = some g := by
  cases k <;> rcases hp : s.playerGift <;> rcases ht : s.teamGift <;>
    simp [sendGift, hp, ht] at h ⊢

/-- A gift sent with a warning never displaces the active one. -/
theorem sendGift_warning_keeps_active (s : GiftSlots G) (k : GiftKind) (g : G)
    (h : (sendGift s k g).2 = true) :
    (sendGift s k g).1.playerGift = s.playerGift ∧
      (sendGift s k g).1.teamGift = s.teamGift := by
  cases k <;> rcases hp : s.playerGift <;> rcases ht : s.teamGift <;>
    simp_all [sendGift]

/-- In a party of `n` players, at most `2 n` gifts are active at once. -/
theorem party_active_le (party : List (GiftSlots G)) :
    (party.map GiftSlots.activeCount).sum ≤ 2 * party.length := by
  induction party with
  | nil => simp
  | cons s rest ih =>
    simp only [List.map_cons, List.sum_cons, List.length_cons]
    have := activeCount_le_two s
    omega

/-! ## Expended components are used up; every gain costs effort -/

/-- One encounter (or any action) for a group: `spent` components are used up, and
`earned` new components are gained. The rule is that what is spent is gone (nothing goes
back to the aggressor automatically) and that anything gained is paid for by effort:
`earned ≤ rate * effort`. -/
structure Step where
  spent : ℕ
  earned : ℕ
  effort : ℕ

/-- Holdings after one step. Holdings cannot go below zero, so a step can only spend what
is there. -/
def Step.apply (st : Step) (w : ℕ) : ℕ := w - st.spent + st.earned

/-- Holdings after a sequence of steps. -/
def runSteps (w : ℕ) : List Step → ℕ
  | [] => w
  | st :: rest => runSteps (st.apply w) rest

/-- Total effort put into a sequence of steps. -/
def totalEffort (l : List Step) : ℕ := (l.map Step.effort).sum

/-- **Every gain costs effort.** If each step earns at most `rate` per unit of effort,
holdings after any sequence of steps are at most the starting holdings plus
`rate × total effort`. In particular, spending components never refunds them. -/
theorem runSteps_le (rate w : ℕ) (l : List Step)
    (hEarn : ∀ st ∈ l, st.earned ≤ rate * st.effort) :
    runSteps w l ≤ w + rate * totalEffort l := by
  induction l generalizing w with
  | nil => simp [runSteps, totalEffort]
  | cons st rest ih =>
    simp only [runSteps, totalEffort, List.map_cons, List.sum_cons] at *
    have h1 := hEarn st (by simp)
    have h2 := ih (st.apply w) (fun s hs => hEarn s (by simp [hs]))
    simp only [Step.apply] at h2 ⊢
    rw [Nat.mul_add]
    have : w - st.spent ≤ w := Nat.sub_le _ _
    omega

/-- **No quick fix to unlimited anything.** With zero effort, no sequence of encounters
ever raises a group's holdings. -/
theorem no_effort_no_gain (rate w : ℕ) (l : List Step)
    (hEarn : ∀ st ∈ l, st.earned ≤ rate * st.effort) (h0 : totalEffort l = 0) :
    runSteps w l ≤ w := by
  simpa [h0] using runSteps_le rate w l hEarn

/-- **Unlimited is allowed, but always takes effort.** To reach holdings above `B`
starting from `w`, at least `(B - w) / rate` effort is needed (rounded up): precisely,
`rate × effort` must exceed `B - w`. -/
theorem effort_needed (rate w B : ℕ) (l : List Step) (hwB : w ≤ B)
    (hEarn : ∀ st ∈ l, st.earned ≤ rate * st.effort) (hB : B < runSteps w l) :
    B - w < rate * totalEffort l := by
  have := runSteps_le rate w l hEarn
  omega

/-- The repeatable step "spend nothing, put in one unit of effort, earn `rate`" shows
that unlimited amounts *are* reachable, by repeating effort. -/
theorem unlimited_with_effort (rate w B : ℕ) (hr : 0 < rate) :
    ∃ n : ℕ, B < runSteps w (List.replicate n ⟨0, rate, 1⟩) := by
  have key : ∀ n w', runSteps w' (List.replicate n ⟨0, rate, 1⟩) = w' + n * rate := by
    intro n
    induction n with
    | zero => intro w'; simp [runSteps]
    | succ n ih =>
      intro w'
      simp only [List.replicate_succ, runSteps, ih, Step.apply]
      ring_nf
      omega
  refine ⟨B + 1, ?_⟩
  rw [key]
  nlinarith

/-- **The rejected rule.** If an encounter spends `c > 0` components and they are then
handed back automatically to the aggressor, with no effort, the encounter never costs
anything; with any positive side gain (for example a defender's haul) repeating it gives
unbounded holdings for no effort. This is the loop the consumption rule removes. -/
theorem auto_return_unbounded (c gain w B : ℕ) (hg : 0 < gain) :
    ∃ n : ℕ, B < runSteps w (List.replicate n ⟨c, c + gain, 0⟩) := by
  have key : ∀ n w', c ≤ w' →
      runSteps w' (List.replicate n ⟨c, c + gain, 0⟩) = w' + n * gain := by
    intro n
    induction n with
    | zero => intro w' _; simp [runSteps]
    | succ n ih =>
      intro w' hw
      simp only [List.replicate_succ, runSteps, Step.apply]
      rw [ih _ (by omega)]
      ring_nf
      omega
  refine ⟨B + 1, ?_⟩
  by_cases hw : c ≤ w
  · rw [key _ _ hw]; nlinarith
  · -- start by spending what is there; afterwards the loop runs as above
    simp only [List.replicate_succ, runSteps, Step.apply]
    rw [key _ _ (by omega)]
    nlinarith

/-! ## No levels: archetype plus skills, encounters scale to skills -/

/-- A character with no level number: an archetype picked at the load screen and a skill
profile. Everything that used to be gated by level is gated by skill. -/
structure Character (Arch : Type) where
  archetype : Arch
  skill : ℚ

/-- Encounter difficulty for a party, from skills only: the mean skill of the party (an
encounter scales to the experience and abilities of the people in it). For one player
this is just their own skill. -/
def partyDifficulty (skills : List ℚ) : ℚ := skills.sum / skills.length

/-- A solo player faces exactly their own skill. -/
theorem solo_difficulty (s : ℚ) : partyDifficulty [s] = s := by
  simp [partyDifficulty]

/-- Rewards scale with the difficulty the encounter was set to, at a fixed rate. -/
def reward (rate difficulty : ℚ) : ℚ := rate * difficulty

/-- **Lowering yourself by hand gives no edge.** A solo encounter scales to the skill the
player brings, so the reward per unit of difficulty is the same fixed `rate` whatever
skill they bring, and bringing a lower skill `s' ≤ s` only lowers the reward. -/
theorem manual_lowering_no_benefit (rate s s' : ℚ) (hs' : 0 < s') (hle : s' ≤ s)
    (hrate : 0 ≤ rate) :
    reward rate (partyDifficulty [s']) / partyDifficulty [s'] = rate ∧
      reward rate (partyDifficulty [s]) / partyDifficulty [s] = rate ∧
      reward rate (partyDifficulty [s']) ≤ reward rate (partyDifficulty [s]) := by
  simp only [solo_difficulty, reward]
  have hs : 0 < s := lt_of_lt_of_le hs' hle
  refine ⟨by field_simp, by field_simp, mul_le_mul_of_nonneg_left hle hrate⟩

/-- Mentoring: a mentor's effective skill in an encounter is capped at the mentee's. -/
def mentoredSkill (mentor mentee : ℚ) : ℚ := min mentor mentee

/-- With mentoring, a mentor never raises the encounter above what the mentee faces
alone: a mentor-and-mentee pair faces at most the mentee's own skill level. -/
theorem mentoring_matches_mentee (mentor mentee : ℚ) :
    partyDifficulty [mentoredSkill mentor mentee, mentee] ≤ partyDifficulty [mentee] := by
  simp only [partyDifficulty, mentoredSkill]
  norm_num
  have := min_le_right mentor mentee
  linarith

/-! ## Two different resets -/

/-- An account: the real-life metadata (kept by the account hard reset) and the game
state of each character slot. -/
structure Account (Meta Char : Type) where
  realLife : Meta
  characters : List Char

variable {Meta Char : Type}

/-- The account a first-time player has when they first log in. -/
def firstLogin (m : Meta) : Account Meta Char := ⟨m, []⟩

/-- **Account hard reset**: everything but the real-life metadata is removed. -/
def hardReset (a : Account Meta Char) : Account Meta Char := firstLogin a.realLife

/-- **Optional character reset**: character `i` is replaced by a fresh character; the rest
of the account is untouched. -/
def characterReset (fresh : Char) (i : ℕ) (a : Account Meta Char) : Account Meta Char :=
  { a with characters := a.characters.set i fresh }

/-- After a hard reset the account is exactly a first-time account. -/
theorem hardReset_is_first_login (a : Account Meta Char) :
    hardReset a = firstLogin a.realLife := rfl

/-- Two accounts with the same real-life metadata are identical after a hard reset,
whatever they did before: nothing from the earlier game state survives. -/
theorem hardReset_forgets (a b : Account Meta Char) (h : a.realLife = b.realLife) :
    hardReset a = hardReset b := by
  simp [hardReset, h]

/-- A hard reset keeps the real-life metadata. -/
theorem hardReset_keeps_realLife (a : Account Meta Char) :
    (hardReset a).realLife = a.realLife := rfl

/-- Doing a hard reset twice is the same as once. -/
theorem hardReset_idem (a : Account Meta Char) : hardReset (hardReset a) = hardReset a := rfl

/-- The character reset leaves every other character untouched. -/
theorem characterReset_keeps_others (fresh : Char) (i j : ℕ) (hij : i ≠ j)
    (a : Account Meta Char) :
    (characterReset fresh i a).characters[j]? = a.characters[j]? := by
  simp [characterReset, hij]

/-- **The two resets are different functions**: on an account with two characters, the
character reset keeps a character, while the hard reset keeps none. -/
theorem resets_differ (fresh c₀ c₁ : Char) (m : Meta) :
    (characterReset fresh 0 (⟨m, [c₀, c₁]⟩ : Account Meta Char)).characters.length = 2 ∧
      (hardReset (⟨m, [c₀, c₁]⟩ : Account Meta Char)).characters.length = 0 := by
  simp [characterReset, hardReset, firstLogin]

/-! ## Contributor credits at launch -/

/-- How a contribution is credited on the opening summary and the game board. -/
inductive Credit (Name : Type)
  | named (n : Name)
  | anonymous
  deriving DecidableEq

variable {Contributor Name : Type}

/-- The credit for one contributor: their profile name if they set one up, otherwise
"anonymous contributor". -/
def creditFor (profile : Contributor → Option Name) (c : Contributor) : Credit Name :=
  match profile c with
  | some n => .named n
  | none => .anonymous

/-- The credits list: one entry per contribution, in order. -/
def creditList (profile : Contributor → Option Name) (contributions : List Contributor) :
    List (Credit Name) :=
  contributions.map (creditFor profile)

/-- **Nobody is left off.** Every contribution gets exactly one entry. -/
theorem creditList_length (profile : Contributor → Option Name) (l : List Contributor) :
    (creditList profile l).length = l.length := by
  simp [creditList]

/-- A contributor is shown as anonymous exactly when they have no profile. -/
theorem anonymous_iff_no_profile (profile : Contributor → Option Name) (c : Contributor) :
    creditFor profile c = .anonymous ↔ profile c = none := by
  unfold creditFor
  cases profile c <;> simp

/-- Applying a correction: contributor `c` now has the name `n`. -/
def correct [DecidableEq Contributor] (profile : Contributor → Option Name)
    (c : Contributor) (n : Name) : Contributor → Option Name :=
  fun d => if d = c then some n else profile d

/-- After a correction the contributor is credited by name, and nobody else's credit
changes. -/
theorem correction_effect [DecidableEq Contributor] (profile : Contributor → Option Name)
    (c : Contributor) (n : Name) :
    creditFor (correct profile c n) c = .named n ∧
      ∀ d, d ≠ c → creditFor (correct profile c n) d = creditFor profile d := by
  refine ⟨by simp [creditFor, correct], fun d hd => by simp [creditFor, correct, hd]⟩

end RoundThreeDecisions
