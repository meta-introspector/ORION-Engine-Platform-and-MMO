# ORION R7 💎, fourth pass: reply

I re-read the R7 page. It is now titled **"ORION R7 💎"**. I also read everything new on it:

- my third-pass reply, which you pasted in;
- two new images on the R7 page (plus a new book-cover crest on the ToC X-Summary page);
- the line **"POLY = Path of the Living Ylem"** and the line "The matriarch whale dragon has spoken";
- the two shared chats. The first one links a page I hadn't seen, **ToC X-Summary**, so I read that too.

I re-checked the state-of-build page (ORION SoB R6), the ORION (Summary) page and the concept gallery. **None of the three has changed.** The gallery still has 49 images.

- **Text copies:**
  - `orion/r7d/PAGE_TRANSCRIPT.md` (the R7 page, including the tax table);
  - `orion/r7d/TOC_X_SUMMARY_TRANSCRIPT.md`;
  - `orion/r7d/SHARED_CHATS_TRANSCRIPT.md` (both chats).
- **New proofs:** `RequestProject/RoundSeven/FourthPassSeven.lean`. The whole project builds with no `sorry` and only Lean's standard axioms.
- **Other updates:**
  - the running roster (`ORION_RUNNING_ROSTER.md`), with changes marked **[R7d]**;
  - the Master Index (`ORION_MASTER_INDEX.md`);
  - `CODE_MANIFEST.md`, regenerated.

**What I couldn't find:** you haven't answered Q1–Q6 from the third pass yet, so I've carried them forward unchanged (§7). The 💎 in the title might mean R7 is closed and R8 comes next. I've asked about that (Q7).

---

## 1. POLY = Path of the Living Ylem

I've recorded it in the glossary as **"POLY — Path of the Living Ylem: the capture → train → utilize loop"**. The letters work: **P**ath **O**f the **L**iving **Y**lem gives P-O-L-Y, skipping "the".

Your naming rule says every name suggestion has to be routed for approval, *your own included* (proved in Round 7). You wrote this one on the page yourself, but without a 💎. So it's in the index as **adopted by you, not yet 💎-locked**. Q8 asks whether to lock it.

The chat also says "Poly comes from poly-something". The expansion doesn't contain a "poly-" word, so you may want a one-line note on where the name comes from (Q8).

## 2. The ToC X-Summary page, checked against the rules already proved

This is a player-facing description of The Orion Chronicles, and it fits the empty "The Orion Chronicles Summary" heading at the top of the R7 page. Q9 asks whether that's what the heading is for.

I checked each of its gameplay claims against rules you've already ruled on:

| ToC X-Summary says | Already ruled / proved? | Where |
|---|---|---|
| New abilities stay pending until you meditate in a safe zone | ✔ Matches. Locked skill changes only through safe-zone meditation | Round 5, `locked_only_by_meditation` |
| Aggro belongs to whoever creates it; one player's aggro never changes another's timer; leaving the skybox clears it | ✔ Matches | Round 3, `RoundThree/Curation.lean` (`leave_clears` and the group-aggro theorems) |
| Quests never need a skill you had no way to get earlier | ✔ Matches. A fair quest is exactly a completable one | Round 4, `fair_iff_completable` |
| Epic training quests stay locked until you reach the skill level | ✔ Matches | Round 5, `epic_locked_until_entry` |
| You can't craft your way past the skybox; you need a quest, the escape feature, or a key | ✔ Matches in substance. One small wording difference: Round 3 has **two** routes (an escape earned through the quest, or a key), but the page reads like **three** | Round 3, `passesGate` |
| Species is your underlying identity; acquired traits add to it but never replace it | ✔ Matches. Species is chosen once | Round 3, `species_forever`; **new** `trait_keeps_species` |
| **Skin is cosmetic** and never changes abilities | **New, proved this pass** (§3.1) | `skinBlind_iff_factors` |
| **"There are endless opportunities at all skill levels, so no one is ever truly stuck"** | **New, proved under one condition** (§3.2) | `never_stuck`, `stuck_if_finite` |

**Missing from the page** (suggestion, not a ruling). It doesn't mention any of these:

- skill orbs (0–100, gold-lock at 100);
- player level = gold-locked nodes (out of 64);
- the 144-node dragon matrix;
- the KRION meter challenge;
- the phoenix;
- the economy (2% sale royalty, arena tax);
- ORION's Gate and Elder's Garden.

Once Q1–Q3 are answered, a short "Progression at a glance" section covering the orbs, level and dragon matrix would make it complete for players.

## 3. New proofs (`RequestProject/RoundSeven/FourthPassSeven.lean`)

### 3.1 Skins are cosmetic, and how a dev can check it

Model: a character has a species, body, archetype, skin and a list of acquired traits. An **ability formula** is "skin-blind" if swapping the skin never changes its result.

**Proved** (`skinBlind_iff_factors`): a formula is skin-blind **exactly when** it can be written using only species, body, archetype and traits. For the devs, this means the test is "swap the skin and check that nothing changes". If that test passes, skin really isn't an input anywhere.

The only assumption is that at least one skin exists, i.e. there's a default skin.

### 3.2 "No one is ever truly stuck": true, but only if quests keep coming

This uses the Round 4 quest model: each stage needs some skill and teaches some skill.

- **Proved** (`never_stuck`): suppose there are **infinitely many** quests a skill-0 beginner can complete. Then at **every** skill level, however many quests a player has already finished, there's still an unfinished quest they can complete.
- **Proved** (`stuck_if_finite`): if there are only **finitely many** beginner-completable quests, a skill-0 player who finishes them all has nothing left to complete.

So the promise needs a catalogue that keeps growing: player-created and developer-created training content (both listed on the page), or regenerating quests. A fixed hand-made list isn't enough. **Suggestion:** say this on the page, e.g. "player- and dev-created quests keep the supply endless".

### 3.3 Elder's Garden story gate (your idea from the second chat; **proposal**)

Your idea: when someone writes a story for their profile in the Elder's Garden family tree, they must choose **"real story" or "lore"**, and it's run through the proofs before it can be published.

The model:

- each story has a genre and a list of facts;
- a story is published only if Ryan's Loom contract check accepts it **together with everything already published in the same genre**;
- real and lore are kept apart, so lore about a character never clashes with a real family story.

Proved:

- **A refused story changes nothing** (`publish_refused`).
- **Each genre's published record is always consistent.** This holds whatever is submitted, in whatever order (`run_canon_satisfiable`). It follows from the fact proved in R7b that the Loom check accepts exactly the consistent sets.
- **Publishing a lore story never changes the real record**, and the other way round (`lore_leaves_real`, `publish_other_genre`).
- **Important limit: consistency isn't truth** (`gate_cannot_certify_truth`). Whatever the real world is like, some "real" story passes the gate and is still false. The proofs can catch a story that contradicts what's already published. They can't confirm that a real family story actually happened.

  If "real" stories need to be trustworthy, they need something else: a witness or family sign-off, a source, or at least a visible label like "real (self-declared)". Q11 asks which.

## 4. Things that conflict or need a ruling

1. **Elder's Garden now has two meanings.** In R7c you ruled that Elder's Garden is the placeholder title for the ORION Engine **landing page** (walkthrough, tutorial, account creation), and that ORION's Gate is the **community projects page**. In the second chat, Elder's Garden is the **ancestral tree / Raspberry Fields** with family stories, a final ceremony and public profiles. Those could be one place (the landing page grows into the family tree) or two. Q10.
2. **The ORION (Summary) page is still out of date, and it's spreading.** It still lists Elder's Garden as the global community and projects page and leaves out ORION's Gate. The first chat's assistant read that page and repeated the old meaning back to you. Updating the Summary page to the settled names would stop other assistants and teammates picking up the old version. (It's in the roster's "Broke" table.)
3. **Order of the loop.** In the chat you describe social → **MMO** → **education** → global projects. The ORION (Summary) page and the chat's reply describe Playground → **The Ascent** → **The Orion Chronicles** → projects, which puts education before the MMO. Both pages agree that you can enter at any layer. Q12 asks which order is the intended default path.
4. **"13-level gauntlet."** This is new to me. It isn't on any ORION page I've read. The Proofs Arena gauntlet I reviewed earlier is a different thing (a sequence of Zoo checks). Q13 asks what the 13 levels are, and whether this is the same as the council's route to publication.
5. **The chats' reading of your framework is their own interpretation.** The first chat's table maps Council ideas (Ghost Rider Protocol, the Layer A/B/C/D discipline, "144 = 000") onto game features. Those links are its interpretation, and the ToC X-Summary page doesn't say them. I haven't added them to the glossary. If you want any of them as official lore, tell me which ones (Q14).

## 5. Images

- **The Orion Chronicles battle scene** (R7 page). Dragon riders fight alongside a huge horned whale-dragon in a storm, with "THE ORION CHRONICLES" in the corner. The spelling matches the locked name. There's a faint second logo just above the title that reads like "ORION" plus a glyph. If that's leftover from an earlier draft, you may want to remove it before using this as a title card.
- **Astronaut and cosmic whale in a bubble** (R7 page). No text.
- **Book-cover crest** (ToC X-Summary, top of the page). A blue dragon wrapped around the Earth, in a gold jewelled frame, titled "THE ORION CHRONICLES". The spelling matches the locked name. The image at the bottom of that page is the crest I noted in R7b.

These notes are only what I can see in the images. They aren't proved results.

## 6. Status of earlier items

- **Settled or confirmed:** everything listed in R7c (skill orbs, tax table, names, Master Index). The tax table on the page matches the Lean results.
- **Needs your permission:** the phoenix focus-cost proposal (Q4/Q5) is still pending. The Round 5 "+10%" rule stays in force until you approve it.
- **Still open:** the RD pool questions (R7b Q2–Q5), whether to seed the Loom archive (R7b Q8), and the older items listed in the roster.

## 7. All questions this pass

Carried forward from R7c, unanswered:

1. **Q1.** Full dragon matrix: does a new orb replace an existing one?
2. **Q2.** Do the 64 character orbs fill 64 of the 144 dragon nodes? Does the auto-adjust start when you get a dragon, or only once all 144 are filled?
3. **Q3.** Is the KRION meter challenge once per orb, or once per matrix?
4. **Q4 (permission).** Should the focus cost replace the Round 5 phoenix +10% rule? If so, which d (5% suggested)?
5. **Q5.** Can ordinary dragons run two elements at a focus cost?
6. **Q6.** Should the tax be locked at 2%, 3% or 5%? Same rate for the sale royalty?

New:

7. **Q7.** Does "ORION R7 💎" mean Round 7 is closed? Should the next answers go on a new R8 page?
8. **Q8.** Should **POLY = Path of the Living Ylem** be 💎-locked? Do you want a one-line note on the "poly-" origin?
9. **Q9.** Is ToC X-Summary the page for the empty "The Orion Chronicles Summary" heading on the R7 page?
10. **Q10.** Elder's Garden: is it the landing page, the ancestral tree / Raspberry Fields, or both (the landing page grows into the tree)?
11. **Q11.** Story gate: adopt the real/lore gate in §3.3? For "real" stories, which of these should apply: a witness or family sign-off, a cited source, or a visible "self-declared" label?
12. **Q12.** Which is the default path: social → MMO → education → projects, or social → education → MMO → projects?
13. **Q13.** What are the 13 levels of the council gauntlet, and where should they be written down?
14. **Q14.** Should any of the chat's mappings (Ghost Rider, Layer A/B/C/D, 144 = 000) become official lore, or stay as commentary?
