# ORION Round 4: fourth update

I read the whole current *ORION Round 4* page. It now has **six photo dividers**. Your new notes
are all in the block between photo 5 and photo 6, written into my last reply. I found no new
notes above photo 5. All of those notes had already been handled in earlier updates.

The rules I could prove are in `RequestProject/RoundFour/RulingsFour.lean`. The whole project
builds with no `sorry` and only Lean's standard axioms.

---

## 1. Your notes, one by one

### 1.1 Phoenix: all elements at once, and switching mid-battle (👍)
> *Phoenix Dragon builds are able to have all learned and active elements at one time* /
> *an exceptional addition to allow the Phoenix dragon special skills*

**Confirmed and proved.**
- A phoenix can switch elements in combat. For a phoenix, combat changes nothing
  (`phoenix_switch_in_combat`).
- A phoenix can have every learned element active at once, in combat or not
  (`phoenix_all_learned_active`).
- Every other dragon still can't switch in combat and keeps at most one active element (from the
  last update, unchanged).

### 1.2 "Gaining an element during combat" (🤷‍♀️, now answered)
Your answer made my question clear. I had treated "gaining an element" as one step. You described
two:
1. **The orb levels up.** This can happen anywhere, even mid-fight. The element becomes
   *pending*: earned, but not yet usable.
2. **Lock-in.** The dragon goes to a safe space and meditates (or balances its KRION energy some
   other way) to lock the element into its build. Only then can it be used.

**Proved:**
- A pending element is never active, so it can't be used (`pending_not_active`).
- Nothing that happens in combat adds a usable element (`combat_no_new_element`).
- Levelling an orb in combat still works, but only makes the element pending
  (`levelOrb_in_combat`).
- Meditating outside a safe zone or during combat does nothing (`lockIn_needs_safe_zone`).
  Meditating in a safe zone locks the element in (`lockIn_in_safe_zone`).
- The element rules still hold after any mix of play (`runL_valid`).

Note the contrast: **switching** between elements a dragon already has doesn't need a safe zone.
**Locking in** a new one does. I modelled lock-in as safe-zone meditation only. If "some other
way of managing KRION balance" should also work outside safe zones, tell me what it is and I'll
add it.

This replaces last update's "gaining is never blocked" result, which is now marked *Refined* in
`RulingsThree.lean`.

### 1.3 Council votes: every seat votes, any no triggers reassessment
> *Councils are made up of AI members. Each one must give a yay or nay… All nay votes require full
> council reassessment… to make sure that at the end of the assessment it still remains of 4/5
> majority to pass.*

**Modelled and proved.**
- **No abstentions.** A vote is a yes or no from *every* seat, so the "seated member doesn't
  vote" question can't come up.
- **A unanimous first round passes** straight away (`unanimous_passes`).
- **Any no sends the motion to one full reassessment**, and the reassessment round decides it
  (`nay_needs_reassessment`).
- **Passing always means 4/5 approval in the round that counts**: either a unanimous first round,
  or a reassessment round with at most one no in five (`pass_has_four_fifths`).
- Examples in a five-seat council: one no, then still one no after reassessment → **passes**
  (`reassessment_can_pass`). One no, then two noes after reassessment → **fails**
  (`reassessment_can_fail`).

Two small things to confirm:
- I allowed **one** reassessment round. If a no in the reassessment should trigger another one,
  tell me.
- The reassessment round decides on its own. A seat that changed from yes to no counts as a no.

### 1.4 Royalties after a hard reset (🔥 no)
**Proved.** After a hard reset, royalties from that user's records go to nobody
(`hardReset_no_royalty`). Other users' royalties are unchanged (`hardReset_others_royalty`). This
fits with the hard-reset rules from last time: the content stays public, the public sees
"anonymous", and admins and the development team still see the real user.

### 1.5 Lessons: at the player's level, and quests must be fair
> *lessons should be offered at the players level and be reasonably able to use… it should not
> require more than what the player can reasonably obtain before reaching the end of the quest*

This **changes** my last model, where lessons sat just *above* the player's reach. Now:
- **Lessons are offered at the player's level.** Every lesson offered is usable at the player's
  current skill (`lessonsAt`, `lessonAt_usable`).
- **Quests must be fair.** A quest is a list of stages. Each stage needs some skill, and its
  lessons teach some skill. A quest is *fair* if no stage asks for more than the player's
  starting skill plus what the earlier stages taught.
- **Proved:** fair quests are exactly the ones a player can complete by taking the lessons along
  the way (`fair_iff_completable`). A stronger player can complete anything a weaker one can
  (`completable_mono`). No stage ever needs more than starting skill plus everything the quest
  teaches (`fair_stage_le_total`). That last result is your "not more than the player can
  reasonably obtain before the end of the quest".

The old "just past reach" lesson results are kept in `RulingsThree.lean` and marked *Superseded*.
"Skill and abilities, not levels" is noted. In the model, "skill" is a single number standing for
whatever the stage measures.

### 1.6 Element strength (🧠 intuition)
> *a dragon should be twice as powerful as a non-Dragon player elemental skill, and a 10%
> differentiation between non-phoenix dragons abilities*

The 2× part is clear: a dragon's elemental skill is twice a non-dragon player's (`dragonPower`).
"10% differentiation" can mean two things, and they give different results:
- **Reading A, a band:** every non-phoenix dragon is within 10% of 2×, i.e. between 1.8× and 2.2×.
- **Reading B, a spread:** the strongest non-phoenix dragon is at most 10% stronger than the
  weakest.

**They are not the same.** Under reading A, one dragon at 1.8× and another at 2.2× are both
allowed, but the second is about 22% stronger than the first (`band_allows_wider_gap`).

**Suggestion:** put the weakest non-phoenix dragon at exactly 2× and the strongest at 2.2×. That
satisfies both readings at once (`anchored_satisfies_both`) and keeps every dragon at least twice
a non-dragon player. Under reading A alone, a dragon can drop to 1.8× (`band_at_least`).

Still open here: where does the **phoenix** sit on this scale?

### 1.7 Archetype pairing (🍝🧠)
Recorded as **confirmed, pending Matthew's review**. HIVE → Kronos, PULSE → Orion,
SHEPHERD → KRION stands unless Matthew (builder of the Zoo) objects or suggests another way to fit
them together. No proof changes.

### 1.8 Landing-page names (🍝👍 brainstorm)
Your idea: the Bedrock becomes **the Garden** (social community page), and the global project
platform becomes **the Elder's Garden**.

⚠ One clash: "the Elder's Garden" is already a location in the lore codex. Last time the two
names could both stay because they sat at different levels. If the top-tier platform takes that
name, the platform and the lore place would share it. That could work on purpose, since the
platform would be the "real" Elder's Garden. Otherwise, one of them needs a new name.

You asked for a grander word for the elder space. Some options, with the real meaning of each:
- **Paradise / Pairidaeza.** "Paradise" comes, by way of Greek *paradeisos*, from an Old Iranian
  word for a walled garden or enclosure. A walled garden for the elders fits a top tier.
- **The Hanging Gardens.** The Hanging Gardens of Babylon tie in with the Babel and cuneiform
  themes in your source material.
- **Eden.** The first garden, which fits your "In the Beginning" writing.
- **Elysium / the Elysian Fields.** In Greek myth, the resting place of heroes.
- **The Hesperides.** In Greek myth, the far-western garden of the golden apples.
- **Arcadia.** An idealised harmonious land.
- **The Arboretum** or **the Grove.** Quieter, and closer to "garden".

One idea that keeps the ORION language: **the Garden** (community) → **the Ascent** (education) →
**Orion's Gate**, with the top tier described as "the Elder's Garden beyond Orion's Gate". The
names are your call. Nothing here needs proving.

### 1.9 Acknowledged (👍 / 💎)
- Council sizes (5 personal / 10 public), hard-reset anonymity, and admin visibility: confirmed.
- The 13-layer comparison is waiting until you can share the 13-layer and Tri-Sphere documents.
- Rounding is still the team's call.
- Ryan's ZIP files still haven't been shared.

---

## 2. Still open
1. Should a no vote in the reassessment round trigger another reassessment, or is one final
   round enough?
2. Element strength: reading A (band) or reading B (spread), and where does the phoenix sit?
3. Is safe-zone meditation the only way to lock in an element, or is there another KRION-balance
   method that works elsewhere?
4. The Elder's Garden: share the lore name on purpose, or rename one of them?
5. Archetype pairing: waiting on Matthew.
6. The 13-layer and Tri-Sphere documents, rounding, and Ryan's ZIPs: as before.
