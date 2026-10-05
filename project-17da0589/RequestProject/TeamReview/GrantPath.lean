module

public import Mathlib

/-!
# Grant-path resolution rejects missing parents and cycles

The status note pasted into this round ends with "the next useful slice is proving that
grant-path resolution rejects missing parents and cycles". The code that note refers to was not
received (only the note's text came through), so this file is an **independent model** of that
slice, written from the note alone. It is meant as a reference statement that the team's own
implementation can be compared with, not as a check of that implementation.

**Model.** A registry maps each grant id to
* `none`: no such grant (missing),
* `some none`: a root grant (no parent),
* `some (some p)`: a grant whose parent is `p`.

`resolve reg fuel g` walks from `g` up through the parents, keeping the ids already visited, and
returns the path `[g, parent, grandparent, …, root]`. It fails (`none`) if it meets a missing id,
revisits an id, or runs out of fuel.

**Results.**
* `resolve_rejects_missing`: if any ancestor of `g` (or `g` itself) is missing, resolution fails,
  for every fuel.
* `resolve_rejects_cycle`: if the parent chain of `g` runs into a cycle, resolution fails, for
  every fuel.
* `resolve_sound`: any path that is returned starts at `g`, follows real parent links, ends at a
  root, and never repeats an id.
* `resolve_complete`: conversely, every such path is found when the fuel is at least its length.
* `resolve_eq_some_iff`: the two together, so resolution succeeds exactly on well-formed paths.
-/

@[expose] public section

namespace TeamReview.GrantPath

/-- A grant registry: `none` = missing, `some none` = root, `some (some p)` = parent `p`. -/
abbrev Registry := ℕ → Option (Option ℕ)

/-- Resolve the authenticated path of grant `g`, starting with the ids in `visited` already seen. -/
def resolve (reg : Registry) : ℕ → ℕ → List ℕ → Option (List ℕ)
  | fuel, g, visited =>
    if g ∈ visited then none
    else
      match reg g with
      | none => none
      | some none => some [g]
      | some (some p) =>
        match fuel with
        | 0 => none
        | n + 1 => (resolve reg n p (g :: visited)).map (g :: ·)

/-- `Reaches reg g h`: following parent links from `g` leads to `h` (in zero or more steps). -/
inductive Reaches (reg : Registry) : ℕ → ℕ → Prop
  | refl (g : ℕ) : Reaches reg g g
  | step {g p h : ℕ} : reg g = some (some p) → Reaches reg p h → Reaches reg g h

/-- `h` lies on a cycle of parent links. -/
def OnCycle (reg : Registry) (h : ℕ) : Prop :=
  ∃ p, reg h = some (some p) ∧ Reaches reg p h

/-- A well-formed path: consecutive entries are real child → parent links, ending at a root. -/
inductive ValidPath (reg : Registry) : List ℕ → Prop
  | root {g : ℕ} : reg g = some none → ValidPath reg [g]
  | link {g p : ℕ} {rest : List ℕ} :
      reg g = some (some p) → ValidPath reg (p :: rest) → ValidPath reg (g :: p :: rest)

/-! ## Missing parents -/

/-- **Missing parents are rejected.** If `g` or any of its ancestors is missing from the registry,
resolution fails, whatever the fuel. -/
theorem resolve_rejects_missing {reg : Registry} {g h : ℕ} (hreach : Reaches reg g h)
    (hmissing : reg h = none) (fuel : ℕ) (visited : List ℕ) :
    resolve reg fuel g visited = none := by
  induction hreach generalizing fuel visited with
  | refl g =>
    unfold resolve
    split_ifs <;> simp [hmissing]
  | step hlink _ ih =>
    unfold resolve
    split_ifs
    · rfl
    · rw [hlink]
      cases fuel with
      | zero => rfl
      | succ n => simp [ih hmissing]

/-! ## Cycles -/

/-- Parent chains are linear: two ids reachable from `g` are reachable one from the other. -/
lemma reaches_linear {reg : Registry} {g x h : ℕ} (hx : Reaches reg g x) (hh : Reaches reg g h) :
    Reaches reg x h ∨ Reaches reg h x := by
  induction hx generalizing h with
  | refl g => exact Or.inl hh
  | step hlink hpx ih =>
    cases hh with
    | refl => exact Or.inr (Reaches.step hlink hpx)
    | step hlink' hp'h =>
      rw [hlink] at hlink'
      cases hlink'
      exact ih hp'h

lemma reaches_trans {reg : Registry} {a b c : ℕ} (hab : Reaches reg a b) (hbc : Reaches reg b c) :
    Reaches reg a c := by
  induction hab with
  | refl => exact hbc
  | step hlink _ ih => exact Reaches.step hlink (ih hbc)

/-- The parent of a point on a cycle is again on the cycle. -/
lemma onCycle_parent {reg : Registry} {g p : ℕ} (hlink : reg g = some (some p))
    (hpg : Reaches reg p g) : OnCycle reg p := by
  cases hpg with
  | refl => exact ⟨_, hlink, Reaches.refl _⟩
  | step hlink' hq => exact ⟨_, hlink', reaches_trans hq (Reaches.step hlink (Reaches.refl p))⟩

/-- Everything reachable from a point on a cycle has a parent. -/
lemma has_parent_of_cycle {reg : Registry} {h x : ℕ} (hx : Reaches reg h x) (hc : OnCycle reg h) :
    ∃ p, reg x = some (some p) := by
  induction hx with
  | refl h => obtain ⟨p, hp, _⟩ := hc; exact ⟨p, hp⟩
  | step hlink hpx ih =>
    obtain ⟨q, hq, hqh⟩ := hc
    rw [hlink] at hq
    cases hq
    exact ih (onCycle_parent hlink hqh)

/-- If every id reachable from `g` has a parent, resolution never reaches a root, so it fails. -/
lemma resolve_none_of_all_have_parents {reg : Registry} :
    ∀ (fuel g : ℕ) (visited : List ℕ),
      (∀ x, Reaches reg g x → ∃ p, reg x = some (some p)) → resolve reg fuel g visited = none := by
  intro fuel
  induction fuel with
  | zero =>
    intro g visited hall
    obtain ⟨p, hp⟩ := hall g (Reaches.refl g)
    unfold resolve
    split_ifs <;> simp [hp]
  | succ n ih =>
    intro g visited hall
    obtain ⟨p, hp⟩ := hall g (Reaches.refl g)
    unfold resolve
    split_ifs
    · rfl
    · rw [hp]
      simp only [Option.map_eq_none_iff]
      exact ih p _ fun x hx => hall x (Reaches.step hp hx)

/-- **Cycles are rejected.** If the parent chain of `g` runs into a cycle, resolution fails,
whatever the fuel. -/
theorem resolve_rejects_cycle {reg : Registry} {g h : ℕ} (hreach : Reaches reg g h)
    (hcycle : OnCycle reg h) (fuel : ℕ) (visited : List ℕ) :
    resolve reg fuel g visited = none := by
  apply resolve_none_of_all_have_parents
  intro x hx
  rcases reaches_linear hx hreach with hxh | hhx
  · cases hxh with
    | refl => obtain ⟨p, hp, _⟩ := hcycle; exact ⟨p, hp⟩
    | step hlink _ => exact ⟨_, hlink⟩
  · exact has_parent_of_cycle hhx hcycle

/-- A self-parented grant is the simplest cycle, and is rejected. -/
example (reg : Registry) (g : ℕ) (hself : reg g = some (some g)) (fuel : ℕ) :
    resolve reg fuel g [] = none :=
  resolve_rejects_cycle (Reaches.refl g) ⟨g, hself, Reaches.refl g⟩ fuel []

/-! ## Soundness and completeness -/

/-- **Soundness.** A returned path starts at `g`, follows real parent links to a root, repeats no
id, and avoids the ids already visited. -/
theorem resolve_sound {reg : Registry} :
    ∀ (fuel g : ℕ) (visited path : List ℕ), resolve reg fuel g visited = some path →
      ValidPath reg path ∧ path.head? = some g ∧ path.Nodup ∧ ∀ x ∈ path, x ∉ visited := by
  intro fuel
  induction fuel with
  | zero =>
    intro g visited path hres
    unfold resolve at hres
    split_ifs at hres with hv
    rcases hg : reg g with _ | _ | p <;> rw [hg] at hres <;> simp at hres
    subst hres
    exact ⟨ValidPath.root hg, rfl, List.nodup_singleton g, by simpa using hv⟩
  | succ n ih =>
    intro g visited path hres
    unfold resolve at hres
    split_ifs at hres with hv
    rcases hg : reg g with _ | _ | p <;> rw [hg] at hres
    · simp at hres
    · simp only [Option.some.injEq] at hres
      subst hres
      exact ⟨ValidPath.root hg, rfl, List.nodup_singleton g, by simpa using hv⟩
    · simp only [Option.map_eq_some_iff] at hres
      obtain ⟨tail, htail, rfl⟩ := hres
      obtain ⟨hvalid, hhead, hnodup, hfresh⟩ := ih p (g :: visited) tail htail
      cases tail with
      | nil => simp at hhead
      | cons q rest =>
        simp only [List.head?_cons, Option.some.injEq] at hhead
        subst hhead
        refine ⟨ValidPath.link hg hvalid, rfl, ?_, ?_⟩
        · refine List.nodup_cons.mpr ⟨fun hmem => ?_, hnodup⟩
          exact hfresh g hmem (List.mem_cons_self)
        · intro x hx
          rcases List.mem_cons.mp hx with rfl | hx
          · exact hv
          · exact fun hxv => hfresh x hx (List.mem_cons_of_mem g hxv)

/-- **Completeness.** Every well-formed, repetition-free path that avoids `visited` is found,
given fuel at least its length. -/
theorem resolve_complete {reg : Registry} :
    ∀ (path : List ℕ) (g fuel : ℕ) (visited : List ℕ),
      ValidPath reg path → path.head? = some g → path.Nodup → (∀ x ∈ path, x ∉ visited) →
        path.length ≤ fuel + 1 → resolve reg fuel g visited = some path := by
  intro path
  induction path with
  | nil => intro g fuel visited hv; cases hv
  | cons a rest ih =>
    intro g fuel visited hvalid hhead hnodup hfresh hlen
    simp only [List.head?_cons, Option.some.injEq] at hhead
    subst hhead
    have hav : a ∉ visited := hfresh a List.mem_cons_self
    cases hvalid with
    | root hroot =>
      unfold resolve
      simp [hav, hroot]
    | @link _ p rest' hlink hvrest =>
      cases fuel with
      | zero => simp at hlen
      | succ n =>
        have hrec : resolve reg n p (a :: visited) = some (p :: rest') := by
          apply ih p n (a :: visited) hvrest rfl (List.nodup_cons.mp hnodup).2
          · intro x hx hxv
            rcases List.mem_cons.mp hxv with rfl | hxv
            · exact (List.nodup_cons.mp hnodup).1 hx
            · exact hfresh x (List.mem_cons_of_mem _ hx) hxv
          · simp at hlen ⊢; omega
        unfold resolve
        simp [hav, hlink, hrec]

/-- Resolution from scratch succeeds with enough fuel exactly on well-formed paths. -/
theorem resolve_eq_some_iff {reg : Registry} (g fuel : ℕ) (path : List ℕ)
    (hfuel : path.length ≤ fuel + 1) :
    resolve reg fuel g [] = some path ↔ ValidPath reg path ∧ path.head? = some g ∧ path.Nodup := by
  constructor
  · intro h
    obtain ⟨h1, h2, h3, _⟩ := resolve_sound fuel g [] path h
    exact ⟨h1, h2, h3⟩
  · rintro ⟨h1, h2, h3⟩
    exact resolve_complete path g fuel [] h1 h2 h3 (by simp) hfuel

end TeamReview.GrantPath

end
