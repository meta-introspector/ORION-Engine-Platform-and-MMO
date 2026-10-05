module

public import Mathlib

/-!
# An independent replay of the *Civ One* rule book (Mike DuPont's submission)

The page `civone.jmikedupont2.workers.dev/civone` publishes the rules of a small
civilisation game as JavaScript, described there as a transcription of a Lean rule book.
This file re-transcribes **the JavaScript published on the page** into Lean, independently
of the author's own Lean sources (which are not public), and re-checks the page's claims
against it. Within the ORION build this is an assisting tool: a small, fully checked
rule-book pattern for ORION's game layer.

Re-confirmed here, against the published JavaScript:
* the advisor lights the beacon on turn 25 and not before (`advisor_wins_turn_25`);
* a game with no study order is never won (`no_study_no_beacon`);
* a city planted on tile 0 can never build a library or a beacon (`no_beacon_in_the_west`);
* tile 2 is the only site whose land includes a river, a forest and a hill (`homeTile_unique`);
* knowledge is never unlearned while within its cap of 30, and a beacon is never lost
  (`know_le_step`, `beacon_step`). The cap condition is needed: `study` clamps to 30.

New observations:
* **The advisor is far from optimal.** An explicit 17-turn game lights the beacon
  (`fast_game_wins`), eight turns sooner than the advisor. It never farms and never grows.
  **17 is the exact minimum**: no game of 16 or fewer orders wins (`min_turns_17`).
* **Food has no bite for a one-person city.** At population 1 the upkeep rule never removes
  anyone (`upkeep_pop_one`), so the fastest game ignores food entirely and ends with an empty
  granary (`fast_game_final`). If starvation is meant to matter, the rules need a penalty at
  population 1.
-/

@[expose] public section

namespace CivOneReplay

inductive Terrain | plain | river | forest | hill
  deriving DecidableEq, Repr

inductive Job | farm | chop | mine
  deriving DecidableEq, Repr

inductive Bldg | granary | workshop | library | beacon
  deriving DecidableEq, Repr

inductive Order
  | settle (tile : ℕ)
  | work (job : Job) (tile : ℕ)
  | study
  | grow
  | build (b : Bldg)
  deriving DecidableEq, Repr

structure St where
  turn : ℕ
  home : Option ℕ
  pop : ℕ
  food : ℕ
  wood : ℕ
  ore : ℕ
  know : ℕ
  granary : Bool
  workshop : Bool
  library : Bool
  beacon : Bool
  deriving DecidableEq, Repr

def worldSize : ℕ := 6
def resCap : ℕ := 40
def knowCap : ℕ := 30
def maxPop : ℕ := 4
def growCost : ℕ := 6

def terrainAt : ℕ → Terrain
  | 0 => .plain | 1 => .river | 2 => .forest | 3 => .hill | 4 => .forest | 5 => .plain
  | _ => .plain

def yield : Terrain → Job → ℕ
  | .plain, .farm => 2 | .plain, .chop => 1 | .plain, .mine => 0
  | .river, .farm => 3 | .river, .chop => 1 | .river, .mine => 0
  | .forest, .farm => 1 | .forest, .chop => 3 | .forest, .mine => 1
  | .hill, .farm => 1 | .hill, .chop => 1 | .hill, .mine => 3

/-- Building cost as (timber, ore, knowledge). Knowledge is a threshold and is not spent. -/
def cost : Bldg → ℕ × ℕ × ℕ
  | .granary => (4, 0, 0) | .workshop => (3, 2, 0) | .library => (5, 5, 2) | .beacon => (8, 6, 8)

def START : St :=
  { turn := 0, home := none, pop := 1, food := 3, wood := 0, ore := 0, know := 0,
    granary := false, workshop := false, library := false, beacon := false }

def clampRes (x : ℕ) : ℕ := min x resCap

def owns (st : St) (i : ℕ) : Bool :=
  match st.home with
  | none => false
  | some h => decide (i < worldSize ∧ (i = h ∨ i + 1 = h ∨ h + 1 = i))

def has (st : St) : Bldg → Bool
  | .granary => st.granary | .workshop => st.workshop
  | .library => st.library | .beacon => st.beacon

def canBuild (st : St) (b : Bldg) : Bool :=
  !has st b && decide ((cost b).1 ≤ st.wood) && decide ((cost b).2.1 ≤ st.ore) &&
    decide ((cost b).2.2 ≤ st.know) && (b != .beacon || st.library)

def setBuilt (st : St) : Bldg → St
  | .granary => { st with granary := true } | .workshop => { st with workshop := true }
  | .library => { st with library := true } | .beacon => { st with beacon := true }

/-- The order itself, before the city eats (JavaScript `act`). -/
def act (st : St) : Order → St
  | .settle _ => st
  | .work j t =>
    if !owns st t then st else
    let base := yield (terrainAt t) j * st.pop
    match j with
    | .farm => { st with food := clampRes (st.food + base + (if st.granary then 1 else 0)) }
    | .chop => { st with wood := clampRes (st.wood + base) }
    | .mine => { st with ore := clampRes (st.ore + base + (if st.workshop then 1 else 0)) }
  | .study => { st with know := min knowCap (st.know + 1 + (if st.library then 1 else 0)) }
  | .grow =>
    if growCost ≤ st.food ∧ st.pop < maxPop then
      { st with food := st.food - growCost, pop := st.pop + 1 } else st
  | .build b =>
    if canBuild st b then
      setBuilt { st with wood := st.wood - (cost b).1, ore := st.ore - (cost b).2.1 } b
    else st

/-- The city eats one food a head; the last inhabitant never leaves (JavaScript `upkeep`). -/
def upkeep (st : St) : St :=
  if st.pop ≤ st.food then { st with food := st.food - st.pop }
  else { st with food := 0, pop := max 1 (st.pop - 1) }

/-- One whole turn (JavaScript `step`). -/
def step (st : St) (o : Order) : St :=
  match st.home with
  | none =>
    let st' := match o with
      | .settle t => if t < worldSize then { st with home := some t } else st
      | _ => st
    { st' with turn := st.turn + 1 }
  | some _ => { upkeep (act st o) with turn := st.turn + 1 }

def run (st : St) (os : List Order) : St := os.foldl step st

/-- The reference strategy (JavaScript `advisor`). -/
def advisor (st : St) : Order :=
  if st.home = none then .settle 2
  else if canBuild st .beacon then .build .beacon
  else if st.food < st.pop + 3 then .work .farm 1
  else if canBuild st .library then .build .library
  else if !st.library then
    if st.wood < 5 then .work .chop 2
    else if st.ore < 5 then .work .mine 3
    else .study
  else if st.know < 8 then .study
  else if st.wood < 8 then .work .chop 2
  else if st.ore < 6 then .work .mine 3
  else .work .farm 1

/-- Play the advisor for `n` turns. -/
def advisorRun : ℕ → St
  | 0 => START
  | n + 1 => let s := advisorRun n; step s (advisor s)

/-! ## The page's claims, re-checked against the published JavaScript -/

/-- The advisor lights the beacon on turn 25, and not on any earlier turn. -/
theorem advisor_wins_turn_25 :
    (advisorRun 25).beacon = true ∧ ∀ n < 25, (advisorRun n).beacon = false := by
  refine ⟨by decide +kernel, ?_⟩
  intro n hn
  interval_cases n <;> decide +kernel

lemma upkeep_fields (st : St) :
    (upkeep st).know = st.know ∧ (upkeep st).beacon = st.beacon ∧
      (upkeep st).library = st.library ∧ (upkeep st).workshop = st.workshop ∧
      (upkeep st).ore = st.ore ∧ (upkeep st).home = st.home := by
  unfold upkeep; split <;> simp

lemma step_home_none {st : St} (h : st.home = none) (o : Order) :
    (step st o).know = st.know ∧ (step st o).beacon = st.beacon := by
  rcases st with ⟨turn, home, pop, food, wood, ore, know, g, w, l, b⟩
  simp only at h; subst h
  cases o <;> simp [step]
  split <;> simp

lemma step_home_some {st : St} {h : ℕ} (hh : st.home = some h) (o : Order) :
    step st o = { upkeep (act st o) with turn := st.turn + 1 } := by
  simp [step, hh]

lemma act_know_of_ne_study (st : St) (o : Order) (ho : o ≠ .study) :
    (act st o).know = st.know := by
  cases o with
  | settle t => rfl
  | work j t =>
    simp only [act]
    split
    · rfl
    · cases j <;> rfl
  | study => exact absurd rfl ho
  | grow => simp only [act]; split <;> rfl
  | build b =>
    simp only [act]
    split
    · cases b <;> rfl
    · rfl

lemma act_know_ge {st : St} (hk : st.know ≤ knowCap) (o : Order) :
    st.know ≤ (act st o).know := by
  by_cases ho : o = .study
  · subst ho
    simp only [act, knowCap]
    simp only [knowCap] at hk
    cases st.library <;> simp <;> omega
  · rw [act_know_of_ne_study st o ho]

lemma act_beacon (st : St) (o : Order) (h : (act st o).beacon = true) :
    st.beacon = true ∨ (o = .build .beacon ∧ canBuild st .beacon = true) := by
  cases o with
  | settle t => left; exact h
  | work j t =>
    left
    simp only [act] at h
    split at h
    · exact h
    · cases j <;> exact h
  | study => left; exact h
  | grow => left; simp only [act] at h; split at h <;> exact h
  | build b =>
    simp only [act] at h
    split at h
    · rename_i hc
      cases b
      · left; exact h
      · left; exact h
      · left; exact h
      · right; exact ⟨rfl, hc⟩
    · left; exact h

/-- Knowledge never goes down, as long as it is within its cap of 30 (which holds in every
reachable position). Without that condition the claim fails: `study` clamps to 30. -/
theorem know_le_step {st : St} (hk : st.know ≤ knowCap) (o : Order) :
    st.know ≤ (step st o).know := by
  rcases hh : st.home with _ | h
  · rw [(step_home_none hh o).1]
  · rw [step_home_some hh o]
    simp only [(upkeep_fields _).1]
    exact act_know_ge hk o

/-- A built beacon is never lost. -/
theorem beacon_step {st : St} (h : st.beacon = true) (o : Order) :
    (step st o).beacon = true := by
  rcases hh : st.home with _ | hm
  · rw [(step_home_none hh o).2, h]
  · rw [step_home_some hh o]
    simp only [(upkeep_fields _).2.1]
    cases o with
    | settle t => exact h
    | work j t =>
      simp only [act]
      split
      · exact h
      · cases j <;> exact h
    | study => exact h
    | grow => simp only [act]; split <;> exact h
    | build b =>
      simp only [act]
      split
      · cases b <;> simp [setBuilt, h]
      · exact h

/-- Only a study order raises knowledge. -/
theorem know_step_of_not_study (st : St) (o : Order) (ho : o ≠ .study) :
    (step st o).know = st.know := by
  rcases hh : st.home with _ | h
  · rw [(step_home_none hh o).1]
  · rw [step_home_some hh o]
    simp only [(upkeep_fields _).1]
    exact act_know_of_ne_study st o ho

/-- Lighting the beacon requires 8 knowledge at the moment it is built. -/
theorem beacon_needs_know {st : St} (h0 : st.beacon = false) (o : Order)
    (h1 : (step st o).beacon = true) : 8 ≤ st.know := by
  rcases hh : st.home with _ | h
  · rw [(step_home_none hh o).2, h0] at h1; exact absurd h1 (by simp)
  · rw [step_home_some hh o] at h1
    simp only [(upkeep_fields _).2.1] at h1
    rcases act_beacon st o h1 with h2 | ⟨-, hc⟩
    · rw [h0] at h2; exact absurd h2 (by simp)
    · simp [canBuild, cost] at hc; omega

/-- **A game with no study order is never won**, whoever gives the orders. -/
theorem no_study_no_beacon (os : List Order) (hos : Order.study ∉ os) :
    (run START os).beacon = false := by
  suffices ∀ st : St, st.know = 0 → st.beacon = false →
      ∀ os : List Order, Order.study ∉ os → (run st os).beacon = false from
    this START rfl rfl os hos
  intro st hk hb os hos
  induction os generalizing st with
  | nil => exact hb
  | cons o os ih =>
    simp only [List.mem_cons, not_or] at hos
    have hk' : (step st o).know = 0 := by rw [know_step_of_not_study st o (Ne.symm hos.1), hk]
    have hb' : (step st o).beacon = false := by
      cases hc : (step st o).beacon
      · rfl
      · have := beacon_needs_know hb o hc
        omega
    exact ih (step st o) hk' hb' hos.2

/-- The invariant of a city planted on the westernmost tile. -/
def WestStuck (st : St) : Prop :=
  st.home = some 0 ∧ st.ore = 0 ∧ st.workshop = false ∧ st.library = false ∧ st.beacon = false

theorem westStuck_step {st : St} (h : WestStuck st) (o : Order) : WestStuck (step st o) := by
  obtain ⟨hh, ho, hw, hl, hb⟩ := h
  rw [step_home_some hh o]
  obtain ⟨-, e1, e2, e3, e4, e5⟩ := upkeep_fields (act st o)
  simp only [WestStuck, e1, e2, e3, e4, e5]
  cases o with
  | settle t => exact ⟨hh, ho, hw, hl, hb⟩
  | work j t =>
    simp only [act]
    split
    · exact ⟨hh, ho, hw, hl, hb⟩
    · rename_i hown
      have ht : t = 0 ∨ t = 1 := by
        simp [owns, hh, worldSize] at hown; omega
      cases j <;> simp [hh, ho, hw, hl, hb]
      rcases ht with rfl | rfl <;> simp [terrainAt, yield, clampRes]
  | study => exact ⟨hh, ho, hw, hl, hb⟩
  | grow => simp only [act]; split <;> exact ⟨hh, ho, hw, hl, hb⟩
  | build b =>
    simp only [act]
    split
    · rename_i hc
      cases b <;> simp [canBuild, cost, has, ho, hl, hw, hb] at hc
      simp [setBuilt, hh, ho, hw, hl, hb]
    · exact ⟨hh, ho, hw, hl, hb⟩

/-- **No beacon in the west.** Once a city stands on tile 0 with no ore, no workshop and no
library (as it does right after being planted there), no sequence of orders ever builds a
library or a beacon. -/
theorem no_beacon_in_the_west {st : St} (h : WestStuck st) (os : List Order) :
    (run st os).library = false ∧ (run st os).beacon = false := by
  induction os generalizing st with
  | nil => exact ⟨h.2.2.2.1, h.2.2.2.2⟩
  | cons o os ih => exact ih (westStuck_step h o)

/-- Planting on tile 0 as the first order gives exactly that situation. -/
theorem settle_west_stuck : WestStuck (step START (.settle 0)) := by
  refine ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- **Tile 2 is the only site** whose land includes a river, a forest and a hill. -/
theorem homeTile_unique (h : ℕ) (hh : h < worldSize) :
    ((∃ i < worldSize, (i = h ∨ i + 1 = h ∨ h + 1 = i) ∧ terrainAt i = .river) ∧
      (∃ i < worldSize, (i = h ∨ i + 1 = h ∨ h + 1 = i) ∧ terrainAt i = .forest) ∧
      (∃ i < worldSize, (i = h ∨ i + 1 = h ∨ h + 1 = i) ∧ terrainAt i = .hill)) ↔ h = 2 := by
  simp only [worldSize] at hh ⊢
  interval_cases h <;> decide

/-! ## New observations -/

/-- The last inhabitant never leaves: upkeep never removes anyone from a one-person city. -/
theorem upkeep_pop_one (st : St) (h : st.pop = 1) : (upkeep st).pop = 1 := by
  unfold upkeep; split <;> simp [h]

/-- A 17-order game found by exhaustive breadth-first search over the published rules. -/
def fastGame : List Order :=
  [.settle 2, .work .chop 1, .work .chop 2, .work .chop 2, .work .chop 2, .work .chop 2,
   .work .mine 3, .work .mine 3, .work .mine 3, .work .mine 3, .study, .study,
   .build .library, .study, .study, .study, .build .beacon]

theorem fastGame_length : fastGame.length = 17 := rfl

/-- **The beacon can be lit on turn 17**, eight turns before the advisor manages it. -/
theorem fast_game_wins :
    (run START fastGame).beacon = true ∧ (run START fastGame).turn = 17 := by
  decide +kernel

/-- The fast game never grows the city, never farms, and ends with no food at all. -/
theorem fast_game_final :
    (run START fastGame).pop = 1 ∧ (run START fastGame).food = 0 ∧
      Order.grow ∉ fastGame ∧ ∀ t, Order.work .farm t ∉ fastGame := by
  refine ⟨by decide +kernel, by decide +kernel, by decide, ?_⟩
  intro t
  simp [fastGame]

/-!
## Optimality: 17 turns is the minimum

Under the rules published on the Civ One page (as transcribed in `CivOneReplay`), **no sequence
of 16 or fewer orders lights the beacon.** Together with `fast_game_wins` this shows that 17 is
the exact minimum, against 25 for the page's advisor.

The proof enumerates every position reachable in exactly 16 turns. Orders naming a tile beyond
the map are first reduced to a single representative (`norm`), since they all act alike.
Positions are sorted and adjacent duplicates removed, which never drops a reachable position
(`mem_dedupAdj`). The final check that none of these positions has a beacon is run as compiled
code (`native_decide`).
-/


/-- Every order with its tile reduced to `0 … 6` (tile 6 stands for any tile off the map). -/
def orderList : List Order :=
  (List.range 7).map Order.settle ++
  ([Job.farm, Job.chop, Job.mine].flatMap fun j => (List.range 7).map (Order.work j)) ++
  [.study, .grow, .build .granary, .build .workshop, .build .library, .build .beacon]

def norm : Order → Order
  | .settle t => .settle (min t 6)
  | .work j t => .work j (min t 6)
  | o => o

theorem norm_mem (o : Order) : norm o ∈ orderList := by
  cases o with
  | settle t =>
    simp only [norm, orderList, List.mem_append, List.mem_map, List.mem_range]
    left; left; exact ⟨min t 6, by omega, rfl⟩
  | work j t =>
    simp only [norm, orderList, List.mem_append, List.mem_flatMap, List.mem_map, List.mem_range]
    left; right
    exact ⟨j, by cases j <;> simp, min t 6, by omega, rfl⟩
  | study => simp [norm, orderList]
  | grow => simp [norm, orderList]
  | build b => cases b <;> simp [norm, orderList]

lemma owns_off_map (st : St) {t : ℕ} (ht : 6 ≤ t) : owns st t = false := by
  unfold owns; split
  · rfl
  · simp [worldSize]; omega

lemma act_work_off_map (st : St) (j : Job) {t : ℕ} (ht : 6 ≤ t) :
    act st (.work j t) = act st (.work j 6) := by
  simp [act, owns_off_map st ht, owns_off_map st (le_refl 6)]

theorem step_norm (st : St) (o : Order) : step st (norm o) = step st o := by
  cases o with
  | settle t =>
    simp only [norm]
    by_cases ht : t < 6
    · rw [Nat.min_eq_left ht.le]
    · have h6 : min t 6 = 6 := by omega
      rw [h6]
      unfold step
      split
      · simp [worldSize]; split <;> simp_all
      · simp [act]
  | work j t =>
    simp only [norm]
    by_cases ht : t < 6
    · rw [Nat.min_eq_left ht.le]
    · have h6 : min t 6 = 6 := by omega
      rw [h6]
      unfold step
      split
      · rfl
      · rw [act_work_off_map st j (by omega : 6 ≤ t)]
  | study => rfl
  | grow => rfl
  | build b => rfl

theorem run_norm (st : St) (os : List Order) : run st (os.map norm) = run st os := by
  induction os generalizing st with
  | nil => rfl
  | cons o os ih => simp only [run, List.map_cons, List.foldl_cons] at ih ⊢; rw [step_norm, ih]

/-- Numeric key used only to bring equal positions next to each other. -/
def key (s : St) : ℕ :=
  let h := match s.home with | none => 0 | some t => t + 1
  let bits := (if s.granary then 1 else 0) + (if s.workshop then 2 else 0) +
    (if s.library then 4 else 0) + (if s.beacon then 8 else 0)
  ((((((h * 8 + s.pop) * 64 + s.food) * 64 + s.wood) * 64 + s.ore) * 64 + s.know) * 16 + bits)

/-- Remove adjacent duplicates (tail-recursive; the result comes out reversed). -/
def dedupAdj (acc : List St) : List St → List St
  | [] => acc
  | a :: l =>
    match acc with
    | b :: _ => if a = b then dedupAdj acc l else dedupAdj (a :: acc) l
    | [] => dedupAdj [a] l

theorem mem_dedupAdj {x : St} : ∀ {acc l : List St}, x ∈ acc ∨ x ∈ l → x ∈ dedupAdj acc l
  | acc, [], h => by simpa [dedupAdj] using h
  | acc, a :: l, h => by
    simp only [dedupAdj]
    split
    · rename_i b t
      split
      · rename_i hab
        apply mem_dedupAdj
        rcases h with h | h
        · exact Or.inl h
        · rcases List.mem_cons.1 h with rfl | h
          · left; rw [hab]; exact List.mem_cons_self
          · exact Or.inr h
      · apply mem_dedupAdj
        rcases h with h | h
        · exact Or.inl (List.mem_cons_of_mem _ h)
        · rcases List.mem_cons.1 h with rfl | h
          · exact Or.inl List.mem_cons_self
          · exact Or.inr h
    · apply mem_dedupAdj
      rcases h with h | h
      · simp at h
      · rcases List.mem_cons.1 h with rfl | h
        · exact Or.inl List.mem_cons_self
        · exact Or.inr h

/-- All positions reachable in one more turn, without adjacent duplicates. -/
def next (R : List St) : List St :=
  dedupAdj [] ((R.flatMap fun s => orderList.map (step s)).mergeSort fun a b => key a ≤ key b)

theorem mem_next {R : List St} {s : St} (hs : s ∈ R) {o : Order} (ho : o ∈ orderList) :
    step s o ∈ next R := by
  apply mem_dedupAdj
  right
  rw [List.mem_mergeSort, List.mem_flatMap]
  exact ⟨s, hs, List.mem_map.2 ⟨o, ho, rfl⟩⟩

/-- Positions reachable in exactly `n` turns (possibly with repetitions). -/
def reach : ℕ → List St
  | 0 => [START]
  | n + 1 => next (reach n)

theorem run_mem_reach (os : List Order) (hos : ∀ o ∈ os, o ∈ orderList) :
    run START os ∈ reach os.length := by
  induction os using List.reverseRecOn with
  | nil => simp [run, reach]
  | append_singleton os o ih =>
    simp only [List.mem_append, List.mem_singleton] at hos
    have h1 := ih (fun x hx => hos x (Or.inl hx))
    simp only [run, List.foldl_append, List.foldl_cons, List.foldl_nil, List.length_append,
      List.length_singleton, reach] at h1 ⊢
    exact mem_next h1 (hos o (Or.inr rfl))

/-- The exhaustive check: no position reachable in exactly 16 turns has a beacon. -/
theorem reach16_no_beacon : ∀ s ∈ reach 16, s.beacon = false := by
  native_decide

theorem run_beacon_mono (st : St) (os : List Order) (h : st.beacon = true) :
    (run st os).beacon = true := by
  induction os generalizing st with
  | nil => exact h
  | cons o os ih => exact ih (step st o) (beacon_step h o)

/-- **No game of 16 or fewer turns lights the beacon.** -/
theorem no_win_within_16 (os : List Order) (hlen : os.length ≤ 16) :
    (run START os).beacon = false := by
  cases hb : (run START os).beacon
  · rfl
  · exfalso
    let pad : List Order := List.replicate (16 - os.length) .study
    have hlong : (os ++ pad).length = 16 := by simp [pad]; omega
    have hwin : (run START (os ++ pad)).beacon = true := by
      simp only [run, List.foldl_append] at hb ⊢
      exact run_beacon_mono _ pad hb
    rw [← run_norm] at hwin
    have hmem := run_mem_reach ((os ++ pad).map norm) (by
      intro o ho
      obtain ⟨o', -, rfl⟩ := List.mem_map.1 ho
      exact norm_mem o')
    rw [List.length_map, hlong] at hmem
    rw [reach16_no_beacon _ hmem] at hwin
    exact absurd hwin (by simp)

/-- **17 turns is the exact minimum** for lighting the beacon. -/
theorem min_turns_17 :
    (∃ os : List Order, os.length = 17 ∧ (run START os).beacon = true) ∧
      ∀ os : List Order, (run START os).beacon = true → 17 ≤ os.length := by
  refine ⟨⟨fastGame, fastGame_length, fast_game_wins.1⟩, fun os h => ?_⟩
  by_contra hlt
  rw [no_win_within_16 os (by omega)] at h
  exact absurd h (by simp)

end CivOneReplay
