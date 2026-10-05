# Round Four page, third update: your notes on my last two replies

**Source:** the *ORION Round 4* Notion page as it stands now (771 blocks, **5 photos**). Photo 5 is new and
marks the end of what you've worked through.
**New Lean file:** `RequestProject/RoundFour/RulingsThree.lean`. The whole project builds with no `sorry` and only
Lean's standard axioms.

## 0. Where the new material is

| Block | Between | What it holds | Status |
|---|---|---|---|
| 1–4 | top → photo 4 | Ryan's kernels and game rules, earlier replies, D1–D8, "UPDATED ARI" notes | processed earlier; nothing new here |
| 5 | photo 4 → photo 5 | my team-roster / X reply and my page-comparison reply, **now carrying your 🍝🧠 and 👍 notes** | **new: processed here** |
| 6 | after photo 5 | "Ari:" (empty, waiting for this reply) | — |

No block above photo 4 was edited since my last read.

---

## 1. Your notes, one by one

### 1.1 Element switching for non-phoenix dragons: formalized
> "other players can toggle between their elements … they don't even have to go to a safe zone. They just cannot
> be actively in combat to switch between their elements."

- **In combat, switching does nothing** (`combat_freezes_switch`). Switching means turning an element on or off, or
  choosing the active set.
- **Out of combat, switching works anywhere** (`switch_out_of_combat`), and being in a safe zone makes no difference
  (`safe_zone_irrelevant`).
- **Gaining a new element isn't blocked**, even in combat (`gain_in_combat`). Tell me if gaining should also be
  out-of-combat only.
- **The one-active-element rule still holds** after any mix of in-combat and out-of-combat play (`runC_valid`,
  `other_at_most_one_activeC`).
- **Reading to confirm:** your note says "other players", so I left the **phoenix free to switch during combat**.
  If a phoenix should also have to be out of combat, that's a one-line change.

### 1.2 Council sizes: formalized, and the small-council worry is gone
> "Councils require five at the personal level and 10 at the public level so there is no four seat council."

- **No single veto anywhere** (`no_single_veto`). Every allowed council absorbs at least one rejection.
- **A public council absorbs two** (`public_absorbs_two`). In a council of exactly ten, two rejections pass and three
  don't (`ten_two_three`).
- **Councils of four or fewer aren't allowed** (`small_council_not_allowed`), so the veto I flagged can't happen.
- **One gap: abstentions.** These results count *votes cast*. If one of the five seated members doesn't vote, only
  four votes are cast, and then that vote needs all four. Either require all seats to vote, or treat the minimum
  as a quorum of votes cast. Which do you want?

### 1.3 Hard reset and the public record: formalized
> "a hard reset removes all public records and translates them to anonymous contribution. The only time the actual
> real world user is attached to anything after a hard reset is at the development team and administrative levels."

- **Public view shows "anonymous"** for every record by a user who has done a hard reset (`hardReset_public_anonymous`).
- **The content stays public.** A reset changes no record's visibility (`hardReset_keeps_visibility`).
- **The development team and administrators still see the real user** (`hardReset_admin_sees_user`).
- **Nobody else's records change** (`hardReset_others_unchanged`).
- **One knock-on question:** royalties. `RoundFour/Attribution.lean` checks the blueprint royalty split. After a hard
  reset, does the anonymized contribution keep earning royalties for the player (paid quietly at the admin level),
  or does its share stop?

### 1.4 Lessons vs the menu rule: you had answered it, and it's now formalized
You asked me to check whether you'd already answered this, and you had. Your earlier note (block 2) asks for
"extended opportunities" for players who are actively working toward something. These start at the player's
current level, include things they can't finish yet, and work like a guided tutorial: "lessons and tests and then
advancement". You also gave D2/D3 a 👍 as intended design. I should have closed this item then. Read together,
the two notes say:

- **Lessons are a separate list beside the menu**: options not yet within reach, at most a set number of levels
  (`stretch`) above the player's skill.
- **The menu rule is untouched.** A lesson is never on the menu (`lesson_not_on_menu`).
- **Lessons start at the player's level:** each one is above the player's skill and within `stretch` of it
  (`lesson_near_level`).
- **Finishing the lesson opens the menu entry.** Once the player's skill reaches it, the option is on the menu
  (`lesson_then_menu`).

The only thing left for you is the size of `stretch`: one level ahead, or more?

### 1.5 Archetype pairing: confirmed
Your 👍 confirms HIVE → Kronos, PULSE → Orion, SHEPHERD → KRION. It's recorded as a ruling (`confirmedPairing`,
one-to-one: `confirmedPairing_bijective`).

### 1.6 "Bedrock" and the platform names: recorded
| Name | What it is |
|---|---|
| **The Orion Engine** | the entire project build |
| **Bedrock** (proposed rename: **the Garden**) | the platform's social community page |
| **The Ascent** | the education hub |
| **The Orion Chronicles** | the MMO |
| **Orion's Gate** | the global project, the highest-tier platform |

With this, "the Garden" is the social layer of the whole Orion Engine, while **the Elder's Garden** (lore codex §8)
is one hub inside the Chronicles MMO. Those are different levels, so both names can stay. One small suggestion:
call the codex hub by its full name, "the Elder's Garden", and the platform "the Garden", so they don't get mixed
up in UI text.

The Ascent and the "lessons" track (1.4) look like the same idea at two levels: lessons inside the game, the Ascent
as the education hub outside it. A lesson finished in the Ascent could count toward the same in-game skill. Tell
me if that's intended.

### 1.7 Monsters, Dr. Logvinovich, Nader, Watts, effect on ORION: 👍 noted
No change needed.

### 1.8 The 13-layer universal architecture vs the Tri-Sphere vs Dr. Logvinovich's torus/hourglass
**I don't have the 13-layer document.** It isn't in the project files or on the Round 4 page. I also can't reach
the Google Docs or the tgsate.com pages from here any more: both now ask for a Google sign-in, which is probably
the same access problem you're having.

What I do have is my notes on **the Tri-Sphere Architecture** from the first round (`FRICTION_EXAMINATION.md`):
the five filter states, Driver / Engine / Vehicle / Copilot, and the Impedance Spectrum of Vehicles. I also have
what's public about **IT³**: the invariant torus, the Perez Hourglass, and the three published critiques. That's
enough to set out **how** the comparison should be judged, so it's ready when you can share the 13-layer document:

1. **Internal consistency.** Do the parts fit without contradiction? IT³ already has two documented defects: the
   metric changes signature near the poles (Nader point 1), and the claimed octahedral symmetry fails (Nader
   point 2; its mechanism is proved in `TeamReview/IT3Checks.lean`). I'd check the 13 layers and three spheres
   the same way. One tension inside the Tri-Sphere is already on record: "frictionless" State 4 against
   "frictionless existence is unsustainable". `FRICTION_EXAMINATION.md` resolves it by reading State 4 as
   *matched* friction.
2. **Testability.** Does each framework state a prediction that could come out wrong? The Tri-Sphere has one: the
   ≥ 30 % theta/alpha coherence threshold. That counts in its favour. Watts's critique shows that IT³'s "100 %
   matches" come from a floor function, which produces integers from any data, so they aren't tests.
3. **Fit for ORION.** Which structure maps cleanly onto the build? Three spheres line up naturally with three
   things the project already has three of: the three builds (Kronos / Orion / KRION) and the three archetype
   upgrades. That's a design fit, not physical evidence.

**What I can't do:** decide which picture of the universe is "superior" as physics. Neither the 13-layer/Tri-Sphere
framework nor IT³ has been checked against independent measurements, and by the corpus's own No-Transfer rule,
correct arithmetic doesn't carry over into evidence for the physical claims. The fair way to persuade Dr.
Logvinovich is points 1 and 2: show where each framework is internally consistent and where it makes a
prediction he could check. **Please share the 13-layer document (and the Tri-Sphere doc again) once you have Google
access**, uploaded to the project or pasted onto the Notion page, and I'll do the full side-by-side.

---

## 2. Still open (short)
1. Can a phoenix switch elements during combat? (1.1) Is gaining an element allowed in combat? (1.1)
2. Council abstentions: must every seat vote, or is 5 / 10 a quorum of votes cast? (1.2)
3. Do anonymized contributions keep earning royalties after a hard reset? (1.3)
4. How far ahead do lessons reach (`stretch`)? (1.4)
5. The 13-layer document, for the comparison. (1.8)
6. From before: what a non-phoenix dragon gets from an element (you said "limited and minimized … visual effects
   and less effective skills"; I'd need a number or ratio to formalize it), and rounding (the team's call).
7. Ryan's ZIP files still haven't been shared, so nothing is checked against his code.
