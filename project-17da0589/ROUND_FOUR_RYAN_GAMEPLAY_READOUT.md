# Round Four: Ryan's second drop, read for gameplay

**Source:** the Notion page *ORION Round 4*. "Ryan's second drop" means everything below the heading **RYAN** near the
bottom: the K22 Lean ledger, *Round Three Game Rules v2* and *Round Three Game Rules v3*. "The last batch" means
everything above it on the same page: Ryan's *Formal Kernel v0.2 / v0.3*, *Game Rules v1*, Grok's comparison, my Round
Three report, and **your own notes and answers written into that report**.

**How decisions are handled here.** Where two sources disagree, I describe the options and what each one changes. I
haven't chosen for you. Section 4 lists every open decision. Until you rule, the Lean proofs keep the reading they
already had. The one exception is rounding, where you've already given a ruling (§2.1).

**What I could and couldn't check.** I could read the Notion page. I couldn't get Ryan's ZIP files: the download links
aren't on the page, and they've never been shared with this project. So I compared what his messages *say* his code
does. I haven't run his tests or checked his SHA-256 hashes.

---

## 0. The short version

1. **Rounding is a direct conflict.** You wrote "we definitely want the rounding to work in favor of the player". For
   a cost, that means rounding **down**. For a payout, it means rounding **up**. Ryan's v1 does the opposite: costs
   round up and payouts round down. His v2 and v3 go further and treat "half-cost rounds down" as a *bug* that the
   test suite must catch (v2 mutant #1). His frozen v3 conformance corpus has this built in. → **Decision D1.**
2. **Player-favourable rounding opens a hole in the 2 % conversion tax.** Any conversion of 49 or less pays no tax, so
   splitting a big conversion into small pieces avoids the tax completely. I proved this in Lean, along with a simple
   fix. → part of **D1**.
3. **Your notes add design content that neither Ryan's code nor my proofs cover yet:**
   - Kronos / Orion / KRION archetype builds alongside HIVE / PULSE / SHEPHERD (**D2**);
   - a classroom-style "lessons and tests" track, which collides with the rule that menus show only what you can do
     now (**D3**);
   - phoenix dragons gaining water, earth, air and ether (toroidal flux) flares (**D4**);
   - "accidentally casting a negative effect that raises Kronos" counts as joining a fight, and the mob turns on that
     player (**D5**).
4. **Ryan and I disagree on whether non-phoenix dragons can catch fire.** In my proofs, only a phoenix catches fire.
   Ryan's v2 deliberately removed that restriction, saying your text doesn't establish it. You decide. → **D4**.
5. **Everything else in v2 and v3 agrees with the proved Round Three rules**: 43 species, archetypes not counted as
   species, menus, skybox gate, monthly reset, demolition bonus, per-player aggro, lock names.
6. **The K22 ledger** (Golay code and Steiner system mathematics) **doesn't touch gameplay.** Two safety notes from
   it are in §1.1.
7. **From the last batch**, two pieces of Ryan's kernel affect gameplay if they're applied to the game. His
   append-only Chronicle conflicts with hard-reset anonymity (**D6**). His "scoped negative evidence" conflicts with
   the Proofs Arena's "one veto blocks publication" rule (**D7**).

---

## 1. What Ryan's second drop contains

### 1.1 K22 Lean Proof-Status Ledger (no gameplay effect)

This is a report from a separate AI-run session on Ryan's own K22/MOG mathematics project. It covers the Golay code,
the "MOG" recognition rule and the Steiner system S(5,8,24). It reports that his recognition rule accepts exactly the
4096 Golay codewords, checked on Lean 4.19. It also reports that only 3 of his 9 original files build under Lean
4.8.0, and that 5 of his 22 open `sorry` lemmas are false as stated.

None of this affects game rules. Two points are worth passing on:
- **False lemmas behind `sorry`.** If any later file relies on one of those 5 false lemmas, its result is unsound.
  They should be retired or restated before anything is built on them, as the ledger itself recommends.
- **The "THOR" authority theorem doesn't use its governance hypothesis.** So that theorem says nothing about
  governance. Please read it as a safety-stack finding: it shouldn't be cited as evidence that authority changes are
  governed.

I haven't seen these files, so I'm repeating the ledger's claims and haven't verified them.

### 1.2 Round Three Game Rules v2 (54/54 tests, according to Ryan)

This is a Python reference version of the Round Three rules. It adds shared test fixtures
(`conformance_vectors.json`), a species registry fixed at 43, per-player aggro timers, exhaustive small-case checks,
six deliberately broken versions ("mutants") that the tests must catch, and a hash manifest.

It also makes one deliberate correction to v1: it no longer forbids non-phoenix dragons from burning (§2.4).

### 1.3 Round Three Game Rules v3 (65/65 tests, 22 frozen cases, according to Ryan)

This version freezes one shared test set, `ROUND-THREE-CONFORMANCE-v3`. It generates Lean fixture source from those
cases and adds a contract for connecting real game code later. Ryan labels the parts that aren't done yet: **"Lean
correspondence compilation: NOT RUN"** and **"Production game implementation: NOT CONNECTED."** His proposed next step
is to plug the fixtures into `RequestProject/RoundThree/Curation.lean` and build them here.

That's a sensible step, but it needs his ZIP. It should also wait until D1, D4 and D5 are settled, because the
frozen corpus would otherwise lock in rules you're still changing (§5).

---

## 2. Rule-by-rule comparison

Key: ✅ same in both · ⚠️ conflict or gap · 🆕 new content from your notes that nobody has built yet.

| Rule | My Round Three proofs | Ryan v1 → v2 → v3 | Your latest word (Notion) | Status |
|---|---|---|---|---|
| Menus show only what the player can do | `menu_within_reach`, `menu_complete`, `menu_mono` | same in all three | You want an extra lessons-and-tests track for skills you can't do yet | ⚠️ **D3** |
| 43 species incl. `DRAGON` and `PHOENIX`; `HIVE`/`PULSE`/`SHEPHERD` aren't species | `roster_split` | same (v2 registry enforces exactly 43) | — | ✅ |
| Any species can take an archetype upgrade | allowed | same | "Stick with any species" | ✅ |
| Kronos / Orion / KRION archetype builds | not modelled | not modelled | You want them in addition to animal + dragon + archetype | 🆕 **D2** |
| Generic `DRAGON` build instead of an animal, so no animal morph | already allowed: `DRAGON` is one of the 43 species | same | You asked for it | ✅ (please confirm this is what you meant) |
| Skin never affects abilities; species never changes | `skin_never_matters`, `species_forever` | same | — | ✅ |
| Phoenix hatches unlit, can ignite, can be put out | `phoenix_fire` | same | Phoenix "starts off as a fire dragon", then gains other elements | ⚠️ / 🆕 **D4** |
| Can **non**-phoenix dragons catch fire? | **No** (`ignite_other`) | v1 no; **v2 and v3 leave it open** | — | ⚠️ **D4** |
| Skybox gate: quest escape or key; crafting and rockets don't work | `crafting_alone_blocked`, `quest_or_key` | same | — | ✅ |
| Monthly reset drains unwon developer pools; player pools untouched; energy conserved | `monthlyReset_spec` | same | — | ✅ |
| Forced demolition pays yield + bonus | `forced_pays_more` | same | — | ✅ |
| Aggro is per player; leaving the skybox clears it; nobody can grief the group | `no_grief`, `stays_inactive`, `leave_clears` | same | — | ✅ |
| Joining a fight aggroes only the joiner | `join_fight` (trigger: a kinetic skill) | same (trigger: a Kronos cast) | Yes, and an accidental **negative effect that raises Kronos** also counts, and "the mob will aggro on them" | ⚠️ **D5** |
| Rounding | both directions defined, not yet chosen | **costs up, payouts down**; round-down costs treated as a bug | **"in favor of the player"**: costs down, payouts up | ⚠️ **D1** |
| Lock names | "Gold Lock" / "Black Hole lock" | same | "Keep them" | ✅ |

### 2.1 Rounding: what your ruling means, and what I proved

I recorded your answer as the current rule, in the new file `RequestProject/RoundFour/PlayerRounding.lean`. It builds
with no `sorry` and only Lean's standard axioms.
- Costs round **down** and payouts round **up**. A player never pays more than the exact amount and never receives
  less (`playerCost_le_exact`, `exact_le_playerPayout`). The two directions differ by at most one unit
  (`playerCost_le_playerPayout`).
- At half price, an orb costing 7 costs 3 (`half_cost_eq_halfDown`). Draining a gold-locked orb into one skill halves
  its points. That's a payout, so 7 points become 4 (`half_payout_eq_halfUp`).
- **Tax hole.** If the 2 % conversion tax is also rounded in the player's favour:
  - every conversion of 49 or less pays no tax (`small_conversion_untaxed`);
  - from 50 up, a single conversion does pay (`large_conversion_taxed`);
  - splitting a conversion never costs more than doing it in one go (`split_never_costs_more`);
  - **every** amount can be split into pieces that pay no tax at all (`exists_untaxed_split`).
- **Fix.** Charge the tax on each player's running total, so the tax due is the tax on everything converted so far
  minus what has already been paid. Then splitting changes nothing (`runningTax_split_invariant`).
- **No currency from nothing.** Even with player-favourable rounding, no chain of conversions leaves a player with
  more than they started with (`playerKeep_never_gains`).

**Earlier, in my Round Three file, you said you'd "round up" the half cost.** Your newest answer ("in favor of the
player") points the other way for costs. I've gone with the newest answer, but please confirm (D1).

---

## 3. Gameplay points from the last batch

### 3.1 Your four answers were already in the document

My last report still listed rounding, lock names, joining a fight and archetypes as "still needed", but you had
already answered all four in the Notion page. I'm sorry for asking again. They're now recorded:
- **Lock names:** kept. Nothing changes.
- **Any species can take an archetype:** this was already how the proofs work.
- **Joining a fight:** "yes". Your extra detail is in D5.
- **Rounding:** in the player's favour. See §2.1 and D1.

### 3.2 Your notes written into my Round Three report

All four are new design content. None of them is in Ryan's code or my proofs yet:
1. **Guided lessons** for skills you can't yet complete, structured like a classroom: lessons, then tests, then
   advancement. → D3.
2. **Kronos, KRION and Orion builds** as archetypes "in addition to animal + dragon + archetype", plus a generic
   dragon overlay so a player avoids an animal morph. → D2.
3. **Phoenix elements:** the phoenix starts as fire and gains water, earth, air and ether (toroidal flux) flares
   through organic interaction with the elements. → D4.
4. **Accidental Kronos-raising effects pull aggro.** → D5.

### 3.3 Where Ryan's Formal Kernel (v0.2 / v0.3) meets gameplay

The kernel is about governance. Its rules are that passing a check isn't the same as being given authority, that
learning doesn't grant permissions, that an AI can't approve its own successor, and that the Chronicle is an
append-only history. Most of that belongs with the safety stack, not the game. It touches gameplay in four places:
- **Chronicle vs hard reset (D6).** Ryan's K7 says failures are kept forever, and replaying the Chronicle rebuilds the
  full state. Your hard-reset rule says the account becomes exactly a new account and the player's blueprints become
  untraceable. If player actions are written to an append-only Chronicle, a hard reset can't erase them, and the
  replay could identify the player again.
- **Scoped negative evidence vs the Proofs Arena veto (D7).** Ryan's K6/K9 says a claim still stands if at least one
  support path avoids every failed piece of evidence. The Arena's TURTLE rule (`veto_dominates`) says one veto blocks
  publication, whatever else comes in. Both are sensible, but for different things. The Arena has to say which one
  applies.
- **"Learning ≠ authority" fits your classroom idea.** Passing lessons and tests could unlock skill progress but
  never permissions, such as AI Council access, admin rights or running real-world actions. I'd suggest writing that
  into D3 whichever option you pick.
- **"Proposer ≠ evaluator"** carries over naturally to the game. Whoever submits a claim to the Proofs Arena
  shouldn't be one of its judges, and an AI copilot that "improves" shouldn't promote itself.

Grok asked whether Ryan's species, archetype and skybox lists match your locked text. They do, as the table in §2
shows, apart from the items marked ⚠️ and 🆕.

---

## 4. Decisions for you

You decide each of these. My recommendations are marked as recommendations, and the proofs aren't changed until you
answer.

> **Update:** your answers to D1–D8 are recorded in `ROUND_FOUR_RULINGS_UPDATE.md`. D1, D4, D5 and D7 are now
> formalized in `RequestProject/RoundFour/Rulings.lean`. The options below are kept for reference.

**D1. Rounding direction**
- (a) **Your ruling as written:** costs round down, payouts round up. Ryan flips v1–v3, removes mutant #1 (or turns
  it around) and regenerates the frozen corpus. You also choose a tax fix: (i) tax the running total
  (*recommendation*, proved to close the hole); (ii) a minimum tax of 1 on every conversion; (iii) accept tax-free
  small conversions.
- (b) **Ryan's version:** costs round up and payouts round down. Nothing in his code changes, and there's no tax
  hole, but this overrides your "in favor of the player".

**D2. How Kronos / Orion / KRION fit with HIVE / PULSE / SHEPHERD.** The word "archetype" now covers three different
things: the character's base archetype chosen at the load screen, the dragon upgrades HIVE / PULSE / SHEPHERD, and
the Kronos / Orion / KRION builds. Pick one:
- (a) **Two layers.** Kronos / Orion / KRION is the character's (and dragon's) alignment build; HIVE / PULSE /
  SHEPHERD is the dragon's role upgrade. Any combination is allowed (3 × 3 = 9).
- (b) **Paired one-to-one.** Each of HIVE / PULSE / SHEPHERD belongs to exactly one of Kronos / Orion / KRION. If so,
  please say which goes with which.
- (c) **Replace.** Kronos / Orion / KRION take over and HIVE / PULSE / SHEPHERD become flavour only.

*Recommendation:* whichever you choose, give each layer its own name (for example "alignment" and "role") so coders
don't confuse them.

**D3. Lessons for skills you can't yet do, vs "menus show only what you can do"**
- (a) **Separate Lessons track** (*recommendation*). Crafting and curating menus keep the proved rule. A separate,
  clearly labelled "Lessons" list offers guided practice that starts at the player's current skill and ends with a
  test that advances the skill. Nothing on it is presented as doable right now.
- (b) **Relax the menu rule.** Menus also show a few greyed-out options just above the player's reach, each linked to
  a lesson. The current proof `menu_within_reach` would be replaced with a weaker version.

Also, your note says "leveling". Since levels are gone, I read that as skill progress. Please confirm.

**D4. Phoenix and elements**
1. Does a phoenix still **hatch unlit**, with "starts as a fire dragon" meaning fire is its starting element? Or does
   it hatch burning?
2. Can **non-phoenix** dragons catch fire? I currently say no; Ryan's v2 leaves it open.
3. Can **only** the phoenix gain water / earth / air / ether flares, or can every species?
4. What does "organic interaction with the elements" mean in play? For example: time spent in an element zone, a
   number of exposures, or a skill line for each element.
5. Do elements **change abilities**? (Skin never does; body and archetype do.) And is ether / toroidal flux a fifth
   element with its own source in the world?

**D5. Aggro from "negative effects that raise Kronos"**
1. Which effects count? Earlier you said **ORION-aligned debuffs** are safe while aggroed. Is every debuff now labelled
   either "raises Kronos" (pulls aggro) or "Orion-aligned" (safe)?
2. When the mob "aggros on" the new player, does the first player's aggro **end**, keep **running down**, or stay
   **shared**? The proofs currently say the first player's timer is untouched.
3. Is aggro from mobs (PvE monsters) the same 10-minute timer as aggro from forced demolition, or a separate system?
   (The proofs currently cover only aggro started by demolition.)

**D6. Ryan's append-only Chronicle vs hard-reset anonymity**
- (a) The Chronicle covers governance and AI-authority events only, never player identity or gameplay history
  (*recommendation*).
- (b) The Chronicle records gameplay under pseudonyms, and a hard reset cuts the link from pseudonym to account.
- (c) The Chronicle is complete. Then the hard-reset promise has to be reworded.

**D7. Proofs Arena: one veto blocks, or scoped?**
- (a) Keep TURTLE as it is: any veto blocks publication.
- (b) Use Ryan's scoped rule: a claim survives if one support path avoids every vetoed piece of evidence.
- (c) Both: scoped for evidence-quality failures, global for safety and fraud vetoes.

**D8. Timing of Ryan's frozen v3 corpus.** Should he hold the "frozen" label until D1, D4 and D5 are settled?
*Recommendation:* yes. Otherwise the shared fixtures lock in rules you've changed.

---

## 5. Other comments and concerns

- **Nothing is connected to a real game yet.** Ryan says so ("NOT CONNECTED"), and I've said the same about my
  proofs. Passing tests and proofs show that the *rules as written* behave as intended, not that a game does.
- **Integrating v3 here is welcome**, but I need the ZIP. Without it I can't build his Lean fixtures in this project,
  and nothing about them should be described as machine-checked yet.
- **Forced-demolition farming.** Forced demolitions pay a bonus and have no monthly limit. With payouts now rounding
  up, the bonus is still the main control. The rounding change is at most 1 unit per payout, so it's minor, but it
  adds up if forcing is repeated.
- **"Frozen corpus" vs "your decisions".** Both Ryan and I are working from your rulings. Whenever a ruling changes,
  his fixtures and my proofs both need updating. One shared list of rulings, dated, would stop the two drifting apart.

---

## 6. What changed in the project this session

- **New:** `RequestProject/RoundFour/PlayerRounding.lean`. It states your player-favourable rounding ruling and proves
  the results in §2.1. It builds with the rest of the project, with no `sorry` and only Lean's standard axioms.
- **Updated:** `ROUND_THREE_CLARIFICATIONS.md`, new §9. It records your four answers and points to this file for
  what's still open.
- No existing proof was changed, so every earlier result still stands.
