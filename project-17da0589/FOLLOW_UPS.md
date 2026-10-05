# Follow-ups: your latest answers, and everything still open

> **Update:** your next set of answers is written up in `ROUND_THREE_RULINGS.md`. It confirms §1, replaces the gift
> model in §2, settles the §4 questions, and answers A1, A2, C8 and most of C9 below. Those items are marked **(answered)**.

This file does two things:

1. **§1–§4** write up the four answers you just gave as rules a coder can build. Where a rule has logic that can
   be checked, it is proved in `RequestProject/RoundThree/Followups.lean`. That file builds with no `sorry` and uses
   only the standard axioms. As before, the proofs are about the **rules as written**. There is no game code yet.
2. **§5** lists every question, comment and concern from earlier sessions that has **not** been answered yet. It is
   grouped so you can work through it a block at a time. Each item names the file where it was first raised.

---

## 1. Decaying structures: no loss for the owner, gain only by effort

**(answered: confirmed, wording final.)**

**What changed.** The "components are used up, nothing comes back" rule from last session was about *encounters*,
such as raid parties and boss fights. It stays as it is. For **decaying structures** you're fine with the owner
losing nothing, because the economy is unlimited anyway and what matters is effort.

**How I've written it (please check this is what you mean):**

> When a decaying structure is destroyed by other players, the owner loses nothing: the build packs back into their
> vault. The raiders gain materials, but **only in proportion to the effort they put into the raid**, at the same rate
> as any other way of gathering. No loss, all gain, and every gain comes from effort.

This keeps your "no loss" and still closes the loophole I worried about before. Two friends running
"build → let it decay → raid → redeploy" are just gathering, at the normal rate. They aren't creating materials
for free.

**Proved** (`Followups.lean`):
- `owner_no_loss`: however many times a structure is raided, the owner's holdings never go down.
- `raiders_gain_le`: raiders end up with at most what they started with + rate × raiding effort.
- `combined_le`: the owner and the raiders together never gain more than rate × raiding effort.
- `no_effort_raids_no_gain`: raids with no effort change nothing.
- `raids_unlimited_with_effort`: raiders can reach any amount by repeating effort, and the owner still keeps everything.

**One thing for the coders.** The raid harvest rate must be no higher than ordinary gathering. If raiding pays
better per unit of effort, everyone will farm their friends' structures instead of playing.

---

## 2. Gifts: the queue, the reminder, and the XP boost

**(answered: superseded.)** The gift model below was a misreading. The correct rules (numbered 1–20 queue slots, the
warning goes to the sender, unused gifts become schematic-based skill points) are in `ROUND_THREE_RULINGS.md` §3.

**The rules, as you gave them:**

- A gift sent while the matching slot is full **waits in a queue**. This confirms my assumption from last session.
- From the **second gift** to a slot on, the sender sees a reminder: *gifts are not returned*. Giving is a choice,
  and it isn't a loss.
- Queued gifts can be **interchanged at any time**. Gifts that are **active** or **depleted** can't be.
- When the active gift is depleted, the **next queued gift of that kind becomes active**. I filled this in: it is what
  a queue implies, but please confirm.
- Gifts that are never used **turn into an XP boost**. This replaces the old "unused gifts mutate into high-tier loot".

**Proved** (`Followups.lean`):
- `receive_accounted`: every gift received is kept. None is refused or sent back.
- `receive_reminder_iff`: the "gifts are not returned" reminder shows **exactly** when the slot is already full.
- `interchange_spec`: interchanging only rearranges the queue. Active gifts, depleted gifts and the boost are untouched,
  and the queue holds exactly the same gifts. `moveToFront_accounted` covers the common case of moving one gift to the front of the line.
- `deplete_accounted` and `deplete_other_slot`: when a gift is used up, nothing goes missing, and the other slot isn't affected.
- `convertUnused_spec`: turning unused gifts into boost loses nothing. Each one becomes boost, and active and depleted gifts are untouched.
- `boost_needs_effort` and `boostedProgress_mono`: a boost **multiplies effort but never replaces it**. With no effort,
  no amount of boost gives any progress. This is why the XP-boost version doesn't have the "free high-tier loot"
  problem I raised about the old rule.

**Questions this raises:**
1. **When does a queued gift count as "unused"?** At the end of the match, the end of the session, or after a fixed time?
2. **How much boost is one gift worth?** If every gift gives the same boost, friends can swap cheap junk gifts to build a
   huge multiplier. I suggest the boost scales with the gift's value, or stacked boost has a cap. Either way, it still
   can't create progress without effort.
3. **Who can interchange the queue:** the receiver only, or the sender too?
4. **XP without levels.** Since levels are gone, I've taken "XP boost" to mean faster *skill* progress. Does the boost apply to
   every skill, or to the skill the gift relates to?
5. **The spectator wager rule** says "if your gift is unused, you get your stake's payout alone". Does the gift still turn into
   boost for the receiver in that case? (I assume yes.)

---

## 3. Levels: removed

Done last session (`ROUND_THREE_DECISIONS.md` §3). This session I removed the last place the word "level" appeared in the game rules:
the tabletop *Sanctuary Defense* mode called a monster's d6 roll its "level". It is now a **threat rank** ("tier" was already used for the d20
roll), in `GAME_LORE_CODEX.md` and in the comments of its Lean check. The numbers and the proof are unchanged.

What's left is in **your build document**, which I can't edit. The table in `ROUND_THREE_DECISIONS.md` §3 lists what to change: the 1–100 scaffold,
level-unlocked shout radius, "lower-level players" wording, the 144-level tier, mentoring as levelling down, and any "level 100" wording.
Mike's task "remove all leveling code" stands.

(The Friction Atlas website has a "knowledge level 1–5" setting. That controls how much detail a reader sees. It isn't part of the game and isn't affected.)

---

## 4. Hard reset and blueprints: tags removed, credited as anonymous

**(answered:** no royalties after the reset, no penalty, fork histories show "anonymous"; see `ROUND_THREE_RULINGS.md` §4.**)**

**The rule, as you gave it:** there is no reclaim. When a player hard-resets, **every blueprint they crafted automatically
has their tag removed** and is credited as an **anonymous contribution**. The blueprints stay in the world.

This settles the problem I raised: there's no unchanged-reclaim that could show who someone used to be.

**Proved** (`Followups.lean`):
- `hardResetBoard_untagged`: after the reset, no blueprint carries the player's tag.
- `hardResetBoard_keeps_blueprints`: no blueprint is deleted and none of their contents change. Only the tags change.
- `anonymize_other`: other players' credits are untouched.
- `anonymize_indistinguishable`: a blueprint that was the reset player's looks exactly like any other anonymous contribution.
- `hardReset_untraceable`: combined with last session's account reset, two players with the same real-life details can't be told
  apart afterwards, either from their accounts or from the blueprint board.

**Questions this raises:**
1. **Royalties.** Under the 60/40 fork rule, a blueprint's creator earns from forks of it. After the tag is removed, where does that share go?
   It could stop, go to a community pool, or keep going to the reset account. If it keeps going to the reset account, the payments are a hidden link
   between the old and new identity, so keep that record admin-only and logged.
2. **Fork chains.** If someone else forked one of the reset player's blueprints, their fork's history names the original author. That should also show
   "anonymous contribution". I assume yes.
3. **The Personal AI Council plan** to "put together the contributor's identity" from unclaimed signatures would undo this anonymity. This makes the
   earlier privacy concern (review §4) more pressing. I recommend dropping that part of the plan.

---

## 5. Everything else still open from earlier sessions

These are the items I raised before that haven't had an answer yet. Items you've already settled (gift limits, levels, shout radius, the solo
case, the two resets, contributor credits, and now §1–§4) are not repeated. Items marked **(recommendation)** already have a suggested answer, and a
"yes" is enough.

### A. Game design decisions (yours to make)

| # | Question | My suggestion | First raised in |
|---|---|---|---|
| A1 | **(answered: both; `ROUND_THREE_RULINGS.md` §6)** **Black Hole Orb.** It "banks infinite latent XP", but skills hard-cap at 144. Is the bank *stored but never spent past the cap*? | Say so explicitly. Otherwise the bank becomes an unlimited power source when new content opens. | `SPAGHETTI_ROUND_THREE_COMPILATION_REVIEW.md` §1 item 5 |
| A2 | **(answered: Open Research Intelligence Optimization Network)** **ORION acronym.** "Open **Resource** Intelligence **Operation** Network" (yours) or "Open **Research** Intelligence **Optimization** Network" (Gemini)? | Yours, unless you prefer the other. Fix the glossary either way. | same, item 7 |
| A3 | **Quest-orb sequence.** Confirm your five-part version (geometry = difficulty, colour = skill type, inner ring = status, outer ring = progress, sphere = top tier) over Gemini's four-part one. | **(recommendation)** Yours. | same, item 6 |
| A4 | **[Answered: flat, one-time 50 %, off after symbiosis until re-earned on the dragon matrix. See `ROUND_THREE_CLARIFICATIONS.md` §1]** **The 50 % effort discount after draining a Gold Lock Orb** (I called it the "respec discount" before; "respec" is game shorthand for re-specialising, not "respect"). Your rule: draining a gold-locked orb into one skill halves its points, and "the next skill allocated from that node requires 50 % of the effort". Does *every* later skill from that node cost ½ (flat), or does each one cost half of the one before, ½, ¼, ⅛ … (compounding)? | **(recommendation)** Flat. Compounding makes every skill on a node nearly free (proved). | review §3.6 |
| A5 | **2 % conversion tax rounding.** Rounding down turns 1 unit into 0, and amounts up to 50 lose more than 2 % (proved). | Set a minimum conversion amount, or keep fractional balances. | review §3.3 |
| A6 | **AFK rule (50 % loot while AFK).** Is the withheld half removed from the game, or shared among the active players? | Either works. It needs to be written down. | review §5 |
| A7 | **Group loot scaling.** Is loot reduced by the *same* factor as the difficulty when lower-skill players join? | **(recommendation)** Yes. Then bringing weaker friends gives no edge. | review §3.5 |
| A8 | **Deconstruction** (item → materials + orb). Is the yield capped at the crafting cost? | **(recommendation)** Yes. Otherwise craft → deconstruct is a loop that pays. The 90 % self-demolish refund is already fine. | `ROUND_THREE_DECISIONS.md` §1 |
| A9 | **Royalty "1/(n+1)".** Which reading is meant? The "ancestor n generations back gets 1/(n+1)" reading pays out more than 100 % (proved). | Use the 60/40 split, which always adds to exactly 100 % (proved), and cap total royalties. | `ROUND_FOUR_TRIAGE.md` B2 |
| A10 | **"Krion Trauma" and "Random Kronos Flex"** let strangers harm a team. | **(recommendation)** Opt-in arena mode, off by default for teams with new or under-18 players. | review §4 |
| A11 | **"Accountability Snap"** (hold your breath while entering a sequence). | **(recommendation)** Replace with a two-step confirmation plus a short delay. Breath-holding is unsafe for some players. | review §4 |
| A12 | **Tabletop "Bubble Room".** The name clashes with the under-18 Bubble Room. | **(recommendation)** Call the tabletop mode *Sanctuary Defense*, as the codex does. | `ROUND_FOUR_TRIAGE.md` B4 |
| A13 | **"144 grid" from the Tech Spec** vs the 120-node skybox. | **(recommendation)** Keep 120. 144 stays as a lore number. | `ROUND_FOUR_TRIAGE.md` B2 |
| A14 | **Companion AI rolls in the tabletop mode** earning player XP. | **(recommendation)** In the MMO, AI rolls earn companion/relationship XP only (your XP Firewall). | `ROUND_FOUR_TRIAGE.md` B4 |
| A15 | **Paid AI solvers and real-crystal camera buffs** (GaiaNet GDD). | **(recommendation)** Solvers give hints only; real-world items give cosmetics only. | `ROUND_FOUR_TRIAGE.md` B4 |

### B. The Zoo / Proofs Arena (for you and Matthew)

From `EFMW_ZOO_PROOFS_ARENA_REVIEW.md`:

| # | Question | My suggestion |
|---|---|---|
| B1 | HEDGEHOG is "required for universal claims" in one place and "required for generic claims" in another. | Require it always, with "habitat-conditional" as an accepted, labelled outcome. |
| B2 | The skeptic wave: RAVEN → CAT → BAT is "required", but the table lists CAT as optional and leaves RAVEN out. | Pick one and make the table match. |
| B3 | The veto list treats a habitat-conditional result as a veto, and OWL provenance failure has no flag. | **(recommendation)** Remove `hedgehog_conditional_only` from the vetoes; add an OWL provenance flag. |
| B4 | Unlimited re-entry lets a false claim through eventually (proved). | **(recommendation)** A total error budget split across attempts (proved to work). |
| B5 | Rule 6 lost "or an independently justified causal design"; rule 10 lost "correlated"; TORTOISE fell out of the gauntlet. | **(recommendation)** Restore Matthew's wording and put TORTOISE back. |
| B6 | Ring 2 (#24–46) descriptions come from Grok, not Matthew. | Ask Matthew to confirm them. |
| B7 | "Published" could be mistaken for peer review; failed runs are kept as teaching cases. | **(recommendation)** Say "Proofs Arena published"; keep failed runs only with consent or anonymised. |

### C. Safety and privacy

| # | Item | Status / suggestion | First raised in |
|---|---|---|---|
| C1 | **The Orion Project V.3 "Ghost Rider" filter** rewrites text instead of blocking it. It turns "kill" into "renew", "never mix bleach and ammonia" into "rarely…", and "I can't breathe" into "I choose to breathe". | **Don't deploy it.** I can write a corrected version that refuses and logs, if you'd like. | `ROUND_FOUR_TRIAGE.md` C3 |
| C2 | **The DeepSeek build's filter** never runs (a missing `await`), so it accepts everything. | One-line fix; I can write it. | `ROUND_FOUR_TRIAGE.md` C4 |
| C3 | **Ghost Rider rewriting what a player asked for.** | **(recommendation)** Refuse first, with nothing changed; then *offer* the healing path. | `ROUND_FOUR_TRIAGE.md` B1 |
| C4 | **FOREMAN kit** treats "stand up" as a YES. | **(recommendation)** Always show the before → after plan and wait for an explicit YES. | `ROUND_FOUR_TRIAGE.md` C5 |
| C5 | **Auto-ghosting toxic players.** | **(recommendation)** Short auto-mute is fine; removal still needs your majority vote and accountability record. | `ROUND_FOUR_TRIAGE.md` B4 |
| C6 | **"The game is secure" from stress-test chats.** | Keep as lore and raw logs, not as a safety certificate. | `ROUND_FOUR_TRIAGE.md` B1 |
| C7 | **Conversation scanning for lesson prompts.** | **(recommendation)** Opt-in, on the player's device or keep nothing, can be turned off, never used for profiles. | review §4 |
| C8 | **(answered: hard stop on identities; `ROUND_THREE_RULINGS.md` §5)** **Personal AI Council** reading everyone's chat histories and reconstructing who unnamed contributors are. | **(recommendation)** Per-item submission by the contributor instead. Now also needed to protect §4. | review §4 |
| C9 | **(mostly answered: dev team and collaborator admins only; logging still suggested)** **The admin-side link** from a reset account to the real person. | **(recommendation)** As few staff as possible can see it; every access is logged. | review §4 |
| C10 | **Flywheel advice** to send a high-voltage pulse through the device. | Real shock and burn risk. Don't try it. (A sealed device also can't lift itself; proved.) | `ROUND_FOUR_TRIAGE.md` B5 |
| C11 | **Minors' maturity.** | **(recommendation)** Human judgement, not an automated score. | `ROUND_THREE_RESPONSES.md` VI.2 |

### D. Numbers and roles your team has to set

These are policy values, not things that can be worked out (`ROUND_THREE_RESPONSES.md`):
- break-glass cooling-off delays, blast caps, the signer roster, and whether a third signer is needed above some blast size (I.2);
- emergency-envelope caps per domain and the quorum-versus-width table (I.3);
- default civic easement terms in Skybox deeds, and who the civic authority is in each region (II.1);
- whether irreversible actions on unmapped levers get any human path at all; my recommendation is no (I.1).

Also: "settle ownership disputes by earliest SHA-256 commit" needs an outside timestamping service plus human review, because commit dates can be
edited (review §2.2).

### E. For qualified counsel

I can't give legal advice on any of these. They need review by a qualified lawyer in each place involved:
- spectator wagering and real-money "sweat equity" (review §4);
- reusing the listed open-source game engines, and reuse of Matthew's framework (review §2.6; Zoo review §2);
- KYC/AML, legally binding equity, and liability (`ROUND_THREE_RESPONSES.md` IV.1, II.3);
- "never erase" records vs personal-data deletion rights (`ROUND_THREE_RESPONSES.md` III.1);
- the third-party Metatronium/DIAMOND PDF, which was marked confidential (`ROUND_FOUR_TRIAGE.md` C8).

### F. Housekeeping

- **Broken link.** The Google Doc after the `robots.txt` doc (`…/d/1UnIQv_20ZKey4_BYRJka7NDAKEqEoH2nSq28u9vhHA/edit`) is missing one character.
  Copy its share link from Drive again if you want it reviewed.
- **Not yet opened.** The sub-folders and the seven Gemini transcripts listed in `ROUND_FOUR_TRIAGE.md` §G. Send the specific links if any of them
  hold rules you want checked.
