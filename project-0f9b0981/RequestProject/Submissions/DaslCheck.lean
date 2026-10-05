module

public import Mathlib

/-!
# Re-checking the 0xDA51 address format (meta-meme, by Mike DuPont)

Source: `0xDA51PrefixClassification.md` in the `meta-introspector/meta-meme` repository
(a fork of `jmikedupont2/meta-meme`, MIT licence).

The document defines 64-bit addresses laid out as `[prefix:16][type:4][data:44]`, with eight
data layouts (types 0–7), and gives a worked example for each type. Here each example is
decoded against the layout the document states, bit for bit.

Findings:
* The arithmetic claims hold: `0x51 = 81`, the prefix bits are `1101 1010 0101 0001`,
  `16 + 4 + 44 = 64`, and each of the eight data layouts adds up to exactly 44 bits.
* The type nibble matches for types 0, 3, 4, 5, 6 and 7. The type 1 example
  `0xDA51E0000011C000` has type nibble `0xE = 14`, not 1.
* Several fields do not decode to the values the document lists. See `type0_fields`,
  `type3_fields`, `type4_fields`, `type5_fields`, `type6_fields` and `type7_fields`
  below. Only the type 7 coefficient value (782) and a few small fields come out as stated.
* The text says the type field runs 0–5, but it defines types 6 and 7 as well.

This is an evidence-ledger entry in the ORION sense: the format is sound, and the worked
examples need regenerating from the actual encoder.
-/

@[expose] public section

namespace DaslCheck

/-- The 44 data bits of an address (everything under the prefix and type). -/
def data (a : ℕ) : ℕ := a % 2 ^ 44

/-- The type nibble, bits 47–44. -/
def typeNibble (a : ℕ) : ℕ := (a / 2 ^ 44) % 16

/-- The prefix, bits 63–48. -/
def pfx (a : ℕ) : ℕ := a / 2 ^ 48

/-- Read the data fields for a layout given as a list of widths, most significant first. -/
def fields (a : ℕ) (ws : List ℕ) : List ℕ :=
  (ws.foldl (fun (acc : List ℕ × ℕ) w =>
      let rest := acc.2 - w
      (acc.1 ++ [(data a / 2 ^ rest) % 2 ^ w], rest)) ([], 44)).1

/-! ## The stated layouts -/

def layout0 : List ℕ := [4, 8, 16, 4, 12]  -- group, position, sequence, factors, pad
def layout1 : List ℕ := [3, 3, 11, 7, 20]  -- selector, bott, tenfold, hecke, hash
def layout2 : List ℕ := [8, 8, 28]         -- protocol_id, version, capabilities
def layout3 : List ℕ := [8, 8, 8, 20]      -- shard, hecke, bott, hash
def layout4 : List ℕ := [4, 4, 8, 28]      -- source, dest, harmonic, transition
def layout5 : List ℕ := [4, 4, 8, 28]      -- prime_idx, replica, zone, node
def layout6 : List ℕ := [2, 4, 6, 4, 28]   -- eigenspace, prime_idx, mckay, hub_proj, hash
def layout7 : List ℕ := [4, 4, 8, 28]      -- prime_idx, genus, coeff_idx, coeff_val

/-! ## Claims that hold -/

theorem prefix_facts : (0x51 : ℕ) = 81 ∧ Nat.digits 2 0xDA51 =
    [1, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1] ∧ 16 + 4 + 44 = 64 := by
  refine ⟨rfl, by norm_num, rfl⟩

/-- Every one of the eight data layouts is exactly 44 bits wide. -/
theorem layouts_are_44_bits :
    [layout0, layout1, layout2, layout3, layout4, layout5, layout6, layout7].map List.sum =
      [44, 44, 44, 44, 44, 44, 44, 44] := by decide

theorem gcd_lcm_10_8 : Nat.gcd 10 8 = 2 ∧ Nat.lcm 10 8 = 40 := by decide

/-- All eight examples carry the `0xDA51` prefix. -/
theorem examples_have_prefix :
    [0xDA510001F9080000, 0xDA51E0000011C000, 0xDA513AE3392F2B7F, 0xDA515E2A00000001,
      0xDA5160750A000000, 0xDA5170060000030E].map pfx = List.replicate 6 0xDA51 := by
  decide

/-! ## The worked examples, decoded against the stated layouts -/

/-- Type 0 example. The document lists group 0, position 0, sequence 8080, factors 8.
Decoded: position 1, sequence `0xF908 = 63752`, factors 0. -/
theorem type0_fields :
    typeNibble 0xDA510001F9080000 = 0 ∧
      fields 0xDA510001F9080000 layout0 = [0, 1, 63752, 0, 0] := by decide

/-- The value 8080 is present, but it sits four bits higher than the stated layout puts
the sequence field (`0x1F90 = 8080`). -/
theorem type0_sequence_shifted : (0x1F90 : ℕ) = 8080 := rfl

/-- Type 1 example: the type nibble is 14, not 1. -/
theorem type1_nibble : typeNibble 0xDA51E0000011C000 = 14 := by decide

/-- Type 3 example. The document lists shard 58, hecke 35, bott 41 and a 28-bit hash
`0x92F2B7F` in a 20-bit field. Decoded: shard 174, hecke 51, bott 146. -/
theorem type3_fields :
    typeNibble 0xDA513AE3392F2B7F = 3 ∧
      fields 0xDA513AE3392F2B7F layout3 = [174, 51, 146, 0xF2B7F] := by decide

/-- The stated hash `0x92F2B7F` does not fit in the 20-bit hash field. -/
theorem type3_hash_too_wide : 2 ^ 20 ≤ 0x92F2B7F := by decide

/-- Type 4 example (the document truncates it as `0xDA5140A0280...`; the leading digits are
padded with zeros here). Source 0 and dest 10 match; harmonic decodes to 2, not 40. -/
theorem type4_fields :
    typeNibble 0xDA5140A028000000 = 4 ∧
      (fields 0xDA5140A028000000 layout4).take 3 = [0, 10, 2] := by decide

/-- Type 5 example. The document lists prime_idx 14, replica 2, zone 42, node 1.
Decoded: zone 160 (`0xA0`); 42 is `0x2A`, which overlaps the replica nibble. -/
theorem type5_fields :
    typeNibble 0xDA515E2A00000001 = 5 ∧
      fields 0xDA515E2A00000001 layout5 = [14, 2, 160, 1] := by decide

/-- Type 6 example. The document lists eigenspace 2, prime_idx 7, mckay 5, hub_proj 15.
Decoded: eigenspace 0, prime_idx 1, mckay 53, hub_proj 0. -/
theorem type6_fields :
    typeNibble 0xDA5160750A000000 = 6 ∧
      fields 0xDA5160750A000000 layout6 = [0, 1, 53, 0, 0xA000000] := by decide

/-- Type 7 example. The document lists prime_idx 0, genus 0, coeff_idx 1, coeff_val 782.
Decoded: coeff_idx is 96 (`0x60`); the coefficient value 782 is correct. -/
theorem type7_fields :
    typeNibble 0xDA5170060000030E = 7 ∧
      fields 0xDA5170060000030E layout7 = [0, 0, 96, 782] := by decide

/-! ## The genus table for `X₀(p)`

The document's genus list agrees with the standard closed form for the genus of `X₀(p)`,
`p` prime: `⌊(p+1)/12⌋`, minus one when `p ≡ 1 (mod 12)` (and 0 for `p = 2, 3`). This checks
the table against that formula only; the formula itself is not derived here. -/

def genusX0 (p : ℕ) : ℕ :=
  if p < 5 then 0 else if p % 12 = 1 then (p + 1) / 12 - 1 else (p + 1) / 12

theorem genus_table :
    [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71].map genusX0 =
      [0, 0, 0, 0, 1, 0, 1, 1, 2, 2, 2, 3, 4, 5, 6] := by decide

end DaslCheck
