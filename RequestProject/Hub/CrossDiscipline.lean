module

public import Mathlib

/-!
# Cross-discipline pattern matching

The hub stores concepts from many disciplines. Each concept carries a finite set of
*pattern tags* (for example `feedback-loop`, `phase-transition`, `power-law`, `symmetry`),
which an AI assistant proposes and human reviewers confirm. Two concepts are compared by the
Jaccard similarity of their tags, and the hub suggests a *bridge* between two concepts when
they come from **different** disciplines and their similarity reaches a threshold `θ`.

What is proved here is what makes the suggestions trustworthy and explainable:
* similarity is symmetric and lies in `[0, 1]`; it is `1` exactly for identical nonempty tag
  sets and `0` exactly for tag sets with nothing in common;
* the bridge list contains exactly the cross-discipline pairs above the threshold, and is
  symmetric;
* for any positive threshold, every suggested bridge is backed by at least one concrete
  shared tag, which can be shown to the user as the reason for the suggestion.
-/

@[expose] public section

namespace OrionHub

variable {T : Type*} [DecidableEq T]

/-- Jaccard similarity `|A ∩ B| / |A ∪ B|` of two tag sets (`0` if both are empty). -/
def jaccard (A B : Finset T) : ℚ :=
  if A ∪ B = ∅ then 0 else ((A ∩ B).card : ℚ) / (A ∪ B).card

theorem jaccard_comm (A B : Finset T) : jaccard A B = jaccard B A := by
  simp [jaccard, Finset.union_comm, Finset.inter_comm]

theorem jaccard_nonneg (A B : Finset T) : 0 ≤ jaccard A B := by
  unfold jaccard; split_ifs <;> positivity

theorem jaccard_le_one (A B : Finset T) : jaccard A B ≤ 1 := by
  unfold jaccard
  split_ifs with h
  · norm_num
  · have hpos : (0 : ℚ) < (A ∪ B).card := by
      exact_mod_cast Finset.card_pos.2 (Finset.nonempty_iff_ne_empty.2 h)
    rw [div_le_one hpos]
    exact_mod_cast Finset.card_le_card Finset.inter_subset_union

/-- Similarity is `0` exactly when the two concepts share no tag. -/
theorem jaccard_eq_zero_iff (A B : Finset T) : jaccard A B = 0 ↔ Disjoint A B := by
  unfold jaccard
  split_ifs with h
  · simp only [true_iff]
    rw [Finset.union_eq_empty] at h
    simp [h.1]
  · have hne : ((A ∪ B).card : ℚ) ≠ 0 := by
      exact_mod_cast (Finset.card_pos.2 (Finset.nonempty_iff_ne_empty.2 h)).ne'
    rw [div_eq_zero_iff, or_iff_left hne, Nat.cast_eq_zero, Finset.card_eq_zero,
      Finset.disjoint_iff_inter_eq_empty]

/-- Similarity is `1` exactly when the two tag sets are equal and nonempty. -/
theorem jaccard_eq_one_iff (A B : Finset T) : jaccard A B = 1 ↔ A = B ∧ A.Nonempty := by
  unfold jaccard
  split_ifs with h
  · rw [Finset.union_eq_empty] at h
    simp [h.1]
  · have hpos : (0 : ℚ) < (A ∪ B).card := by
      exact_mod_cast Finset.card_pos.2 (Finset.nonempty_iff_ne_empty.2 h)
    rw [div_eq_one_iff_eq hpos.ne', Nat.cast_inj]
    constructor
    · intro hc
      have hEq : A ∩ B = A ∪ B :=
        Finset.eq_of_subset_of_card_le Finset.inter_subset_union hc.ge
      have hAB : A = B := by
        apply le_antisymm
        · calc A ≤ A ∪ B := Finset.subset_union_left
            _ = A ∩ B := hEq.symm
            _ ≤ B := Finset.inter_subset_right
        · calc B ≤ A ∪ B := Finset.subset_union_right
            _ = A ∩ B := hEq.symm
            _ ≤ A := Finset.inter_subset_left
      subst hAB
      refine ⟨rfl, ?_⟩
      rw [Finset.union_self] at h
      exact Finset.nonempty_iff_ne_empty.2 h
    · rintro ⟨rfl, -⟩
      simp

/-- A nonempty tag set is perfectly similar to itself. -/
theorem jaccard_self {A : Finset T} (hA : A.Nonempty) : jaccard A A = 1 :=
  (jaccard_eq_one_iff A A).2 ⟨rfl, hA⟩

variable {ι D : Type*} [DecidableEq D]

/-- Suggested cross-discipline bridges among the concepts `s`: ordered pairs of concepts from
different disciplines whose tag similarity is at least `θ`. -/
def bridges (s : Finset ι) (disc : ι → D) (tags : ι → Finset T) (θ : ℚ) : Finset (ι × ι) :=
  (s ×ˢ s).filter fun p => disc p.1 ≠ disc p.2 ∧ θ ≤ jaccard (tags p.1) (tags p.2)

/-- **Soundness and completeness of bridge suggestions.** A pair is suggested exactly when both
concepts are in the hub, they come from different disciplines, and they reach the threshold. -/
theorem mem_bridges {s : Finset ι} {disc : ι → D} {tags : ι → Finset T} {θ : ℚ} {a b : ι} :
    (a, b) ∈ bridges s disc tags θ ↔
      a ∈ s ∧ b ∈ s ∧ disc a ≠ disc b ∧ θ ≤ jaccard (tags a) (tags b) := by
  simp [bridges, and_assoc]

/-- Bridges are symmetric: if `a` is linked to `b`, then `b` is linked to `a`. -/
theorem bridges_symm {s : Finset ι} {disc : ι → D} {tags : ι → Finset T} {θ : ℚ} {a b : ι} :
    (a, b) ∈ bridges s disc tags θ ↔ (b, a) ∈ bridges s disc tags θ := by
  rw [mem_bridges, mem_bridges, jaccard_comm (tags a), ne_comm]
  tauto

/-- No concept is ever bridged to itself, nor to another concept of its own discipline. -/
theorem bridges_cross {s : Finset ι} {disc : ι → D} {tags : ι → Finset T} {θ : ℚ} {a b : ι}
    (h : (a, b) ∈ bridges s disc tags θ) : disc a ≠ disc b :=
  (mem_bridges.1 h).2.2.1

/-- **Explainability.** For any positive threshold, every suggested bridge is backed by a
concrete shared pattern tag. -/
theorem bridges_shared_tag {s : Finset ι} {disc : ι → D} {tags : ι → Finset T} {θ : ℚ}
    (hθ : 0 < θ) {a b : ι} (h : (a, b) ∈ bridges s disc tags θ) :
    ∃ t, t ∈ tags a ∧ t ∈ tags b := by
  have hj := (mem_bridges.1 h).2.2.2
  by_contra hno
  push_neg at hno
  have hd : Disjoint (tags a) (tags b) := Finset.disjoint_left.2 hno
  rw [(jaccard_eq_zero_iff _ _).2 hd] at hj
  linarith

/-- Raising the threshold can only remove suggestions. -/
theorem bridges_antitone {s : Finset ι} {disc : ι → D} {tags : ι → Finset T} {θ θ' : ℚ}
    (hθ : θ ≤ θ') : bridges s disc tags θ' ⊆ bridges s disc tags θ := by
  intro p hp
  rcases p with ⟨a, b⟩
  rw [mem_bridges] at hp ⊢
  exact ⟨hp.1, hp.2.1, hp.2.2.1, hθ.trans hp.2.2.2⟩

end OrionHub
