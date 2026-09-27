module

public import Mathlib

/-!
# An independent re-check of the FRONTIER ledger (Mike DuPont's submission)

The page `nixwars-v3.jmikedupont2.workers.dev/frontier` says "every number on this page is a
Lean 4 theorem" and embeds its numbers as exact fractions in a JSON block. The author's Lean
sources are not public, so this file re-derives the published numbers from the page's own
inputs, independently, and checks that they agree exactly. Within the ORION build this is an
assisting tool: a pattern for publishing an economy or a ledger whose every figure can be
checked.

All checks pass:
* the ship hull's squared edge lengths (`cobra_edge_lengths`);
* the 3-4-5 rotation is a true rotation (`yaw345_unit`);
* all five projected screen points, using the camera described on the page (`screen_points`);
* the cost ledger: the total is the sum of its three parts, the amortised part at each lifetime
  is `$250B × 10⁶ / lifetime tokens`, and the energy per token (`ledger_*`);
* the three-leg route: energy, fuel left, profit at the list price, and the equivalent coin,
  which is under 400 sats as the page states (`route_*`).
-/

@[expose] public section

namespace FrontierCheck

/-! ## Geometry -/

def verts : List (ℚ × ℚ × ℚ) := [(0, 0, 3), (-2, 0, -2), (2, 0, -2), (0, 1, -1), (0, -1, -1)]
def edges : List (ℕ × ℕ) := [(0,1), (0,2), (1,2), (0,3), (1,3), (2,3), (0,4), (1,4), (2,4)]

def dist2 (p q : ℚ × ℚ × ℚ) : ℚ := (p.1 - q.1)^2 + (p.2.1 - q.2.1)^2 + (p.2.2 - q.2.2)^2

def vert (i : ℕ) : ℚ × ℚ × ℚ := verts.getD i (0, 0, 0)

/-- The published squared edge lengths are correct. -/
theorem cobra_edge_lengths :
    edges.map (fun e => dist2 (vert e.1) (vert e.2)) = [29, 29, 16, 17, 6, 6, 17, 6, 6] := by
  simp [edges, vert, verts, dist2]; norm_num

/-- The 3-4-5 yaw is a genuine rotation: `c² + s² = 1`. -/
theorem yaw345_unit : (4 / 5 : ℚ) ^ 2 + (3 / 5) ^ 2 = 1 := by norm_num

/-- Rotate about the vertical axis by `(c, s)`, as in the page's engine (`aboutY`). -/
def aboutY (c s : ℚ) (p : ℚ × ℚ × ℚ) : ℚ × ℚ × ℚ :=
  (c * p.1 + s * p.2.2, p.2.1, c * p.2.2 - s * p.1)

/-- Camera one metre up and twenty back, 960×540 viewport, focal length 600. -/
def project (p : ℚ × ℚ × ℚ) : ℚ × ℚ :=
  let q := aboutY (4 / 5) (3 / 5) p
  let X := q.1 - 0
  let Y := q.2.1 - 1
  let Z := q.2.2 - (-20)
  (480 + 600 * X / Z, 270 - 600 * Y / Z)

/-- All five published screen points are reproduced exactly. -/
theorem screen_points :
    verts.map project =
      [(7395/14, 4155/14), (2760/7, 14730/49), (21240/43, 13110/43), (1845/4, 270),
        (1845/4, 665/2)] := by
  simp [verts, project, aboutY]; norm_num

/-! ## The cost ledger -/

def electricityUSD : ℚ := 28 / 375
def depreciationUSD : ℚ := 625 / 657
/-- Amortised programme cost per 10⁶-token result, for a given lifetime token count. -/
def amortizedUSD (lifetimeTokens : ℚ) : ℚ := 250 * 10 ^ 9 * 10 ^ 6 / lifetimeTokens
def ledgerTotal (lifetimeTokens : ℚ) : ℚ :=
  electricityUSD + depreciationUSD + amortizedUSD lifetimeTokens

theorem ledger_amortized_base : amortizedUSD (2 * 10 ^ 14) = 1250 := by
  norm_num [amortizedUSD]

/-- The three published totals are exactly electricity + depreciation + amortisation at
lifetimes of `2×10¹⁴`, `10¹⁶` and `10¹⁷` tokens. -/
theorem ledger_totals :
    ledgerTotal (2 * 10 ^ 14) = 102740507 / 82125 ∧
      ledgerTotal (10 ^ 16) = 2137382 / 82125 ∧
      ledgerTotal (10 ^ 17) = 579139 / 164250 := by
  refine ⟨?_, ?_, ?_⟩ <;> norm_num [ledgerTotal, electricityUSD, depreciationUSD, amortizedUSD]

/-- Loaded cost per token and energy per token. -/
theorem ledger_per_token :
    ledgerTotal (2 * 10 ^ 14) / 10 ^ 6 = 102740507 / 82125000000 ∧
      (3360000 : ℚ) / 10 ^ 6 = 84 / 25 := by
  constructor <;> norm_num [ledgerTotal, electricityUSD, depreciationUSD, amortizedUSD]

/-! ## The three-leg route -/

theorem route_energy_fuel :
    3 * (3360000 : ℚ) = 10080000 ∧ (100000000 : ℚ) - 10080000 = 89920000 := by norm_num

/-- Profit of three 10⁶-token results sold at the list price of `$1/500` per token. -/
theorem route_profit :
    3 * 10 ^ 6 * ((1 : ℚ) / 500 - 102740507 / 82125000000) = 61509493 / 27375 := by norm_num

/-- The coin the same energy would have mined, and its value in sats. -/
theorem route_coins :
    (10080000 : ℚ) / (7888486930795764 / 3125) = 875000000 / 219124636966549 ∧
      (875000000 / 219124636966549 : ℚ) * 10 ^ 8 = 87500000000000000 / 219124636966549 := by
  constructor <;> norm_num

/-- The page's "under 400 sats" claim holds. (The value is about 399.3.) -/
theorem route_coins_under_400_sats :
    (87500000000000000 / 219124636966549 : ℚ) < 400 ∧
      399 < (87500000000000000 / 219124636966549 : ℚ) := by
  constructor <;> norm_num

end FrontierCheck
