# ORION Round 9, fifth pass

Page read: **ORION R9💎** (page version 826, 2026-10-04). It was called "ORION R9 Live" last time. Text copy:
`orion/r9e/PAGE_TRANSCRIPT.md`. New proofs: `RequestProject/RoundNine/FifthPassNine.lean`. The whole project builds
with no `sorry` and only Lean's standard axioms. "Proved" means the rules as written have these results; there is no
game code yet.

**Spaghetti check:** there is new spaghetti, so nothing was skipped. It's written into the cross-platform reply
(the one pasted on the page in R9d), plus thumbs-ups and notes on my R9c reply. My R9d reply is pasted on the page with
no notes under it, so nothing from R9d changes. I have no questions this time. Where your meaning was unclear, I wrote
down my best reading marked "Assumed".

**Round status:** the page title now ends in 💎, which is how you marked R8 when you closed it. I read this as R9
closing. A new page for the next round works the same way as before.

## What's new on the page

- Your notes on every point of the cross-platform reply: the four platforms, credit for shared links, contributor
  tags and a sales split, damaged and abandoned structures, the economy, parental controls, child safety, voting
  weight, level names, the Adult Penalty and the biometric firewall.
- Thumbs-ups on my R9c results, plus a note on skyboxes inside solar boxes and a request to keep every shared link.
- One new concept image (Orion Chronicles, Batch 1, Kronos 7/10, mechanical lair).
- My R9d reply, pasted with no notes.

## 1. Confirmed (👍), now locked

- Construction site: an idea goes to the DEVs only if it isn't already in the wiki; no idea reaches the DEVs twice;
  every submitted idea ends up in the wiki; the first submitter keeps the credit.
- Nested stars: the nearest star wins.
- Ad bubbles: one per downloadable app mentioned during the build; every build-playlist song gets an honourable
  mention. "Gemini rock, deep sea" = Gemini, Grok, DeepSeek.
- Ryan's Choir Architecture v1.2 and Bounded Receipt Runner v0.1 results.
- "13 levels" should get two different names (ideas in §9).

## 2. The platforms: one global web platform, four houses

Recorded: ORION is one **global web platform** that houses **four platforms** (the MMO, education, the socials and
Elder's Garden), plus the **Orion engine landing page**. Everything can be reached on the ordinary web. Each platform
also has an instance inside the MMO, and each has access points to the others' pages.

Recorded: release in **small pieces**. Live demos go out as things come together, for example "an Orion project
mini-game available at live load". The project doesn't have to launch all at once.

## 3. Credit and the sales split

Recorded:

- **Shared links count a little.** A DEV member who shares public web links, rather than ideas or code, still gets a
  small contribution boost. It's much less than for writing the underlying code, because the AI council can find
  information that's already public on its own.
- **Community claims are hands-on only.** You get a community claim only for a project you actually worked on and
  changed. Everyone mutates projects in their own way unless they're working as a group.
- **Contributor tags.** A player can tag others as idea generators or spaghetti brains: "🌀Joe" marks Joe as a
  contributor to an idea. If Joe can show he contributed more than he was credited for, the council adjusts his
  share.
  - Assumed: the adjustment comes out of the claimant's locked stash, as your note says. It doesn't come from the pot.
- **Sales split for finished items:** the person who finished the item gets **90%**, the base creator's schematic
  gets **3%**, and the other **7%** is divided by weight among the tagged contributors.

Proved (`RoundNineFifth`, section 1):

- The three parts **never pay out more than the sale**, however many contributors there are and however their
  weights are set (`sales_split_le_total`). Rounding down can leave a few coins over.
  - Assumed: those leftover coins go to the DEVPOOL, like other leftovers.
- A contributor with **more weight is never paid less** (`contrib_share_monotone`). So a link-sharer, given a small
  weight, always gets less than a code-writer with a large weight.
- **With the locked 3% tax**, taking the tax first and splitting the rest 90/3/7 still never pays out more than the
  gross sale (`taxed_split_le_gross`).
  - Assumed: the tax comes off first and the split is of what's left. If you meant the 3% to the base schematic *is*
    the tax, say so and I'll redo it.

## 4. Damaged and abandoned structures

Recorded:

- While a structure is taking damage, **50% of its income goes straight to the DEVPOOL**. This speeds up decay and
  moves money away from spaces nobody uses.
- A public space nobody maintains stays open for others to adventure in until it decays.
- Once every structure has decayed off a planet's surface, **another player can claim it as their skybox**, even if
  it belonged to someone else. The previous owner's things are packed up and put in their own storage. The two
  planets can share the same base build ("planet Bob" and "planet Alpha"), and planet Bob then morphs towards its own
  owner's character.

Proved: the 50% split **loses and creates nothing**. The owner's part plus the DEVPOOL's part is always the whole
income, and the DEVPOOL never gets more than the owner (`damaged_split_conserves`).

## 5. The economy, Bubble Bucks and QX

Recorded as **deferred to the economics people**:

- how the in-game economy connects to real money;
- whether Bubble Bucks and QX exist outside the game;
- the limits on converting points between platforms.

Nothing in the game's rules depends on these yet. The point-conversion warning from the cross-platform reply still
stands for whoever takes it on. If conversion rates around a loop multiply to more than 1, holdings grow every lap.

## 6. Parental controls

Recorded:

- Parental controls are **completely open-ended**. A parent can set daily time per platform (for example one hour each
  on education, the socials, the MMO and Elder's Garden).
- They can lock the MMO entirely and leave only education.
- They can block specific educational tracks, and build their own custom track.
- The time gate counts **every** platform. Your 🌪️ confirms that study on the education platform should count.
- Wish list: Montessori-level educators reviewing the education side.

Proved (section 4):

- With a daily cap per platform, a child's **total time never exceeds the sum of the caps** (`total_time_le_caps`).
- A platform the parent **locks gets no time at all** (`locked_platform_no_time`).

## 7. Child safety: no adult alone with a child 💎🔥🐲

Your ruling is recorded as **locked** (💎), and as the strictest rule in the project:

- **No one-to-one access to a child** except by that child's verified guardian.
- **Under 13:** no other player at all, not even another under-13, unless a verified guardian is there. Rules for
  13–17 can be less strict and are still to be worked out.
- **Educators:** never a private conversation with a student. Teachers use classrooms, public message boards and
  tiered-access boards, and contact goes through a **parent portal**.
- **Any adult contacting a minor** must do it in a publicly accountable way that the guardian can see. Either the
  guardian is present in a community bubble, or it's a bubble group chat that everyone attached to the bubble can
  read.
- If you're the only adult in a conversation, you can't invite the child in, and the child can't join you.
- **Logs:** if the parent isn't actively in the room, the full transcript goes to them afterwards.
  - Per your note, a moment-by-moment biometric replay is **too much**.
  - Without a parent available, the most anyone else can do is message the child on a public board the parent is part
    of.

How I modelled it:

- A minor may share a room with someone who "needs a guardian" only while one of **that minor's** verified guardians
  is in the room.
- For an under-13, everyone who isn't their guardian needs a guardian. For a 13–17 player, every adult who isn't
  their guardian does.
- Assumed for now: two 13–17 players may share a room on their own. That's the part you said could be less strict.

Proved (section 2):

- **Checking only when people join is not enough.** A child, their guardian and a teacher are safely in a room. If
  the guardian simply leaves, the teacher and the child are left alone together (`naive_leave_breaks_safety`). Any
  real system has to handle **leaving** as carefully as joining.
- The fix is the **"close the bubble" rule**: when someone leaves, every minor who is no longer protected is moved out
  at once. In the example, the child goes and the teacher stays (`safe_leave_moves_child_out`). With this rule, and a
  join that is refused whenever it would make the room unsafe, **every room stays safe over any sequence of joins
  and leaves** (`room_run_safe`). The proof uses one fact: guardians are verified adults.
- In a safe room, **an adult who is not the child's guardian is never alone with the child**
  (`no_private_adult_minor`). This covers teachers and admins of the child's community room too.
- In a safe room, **an under-13 is never alone with any other player who isn't their guardian**
  (`no_private_under13`).

## 8. Voting weight for players from other platforms

You suggested about **50% vote weight** for people who don't use the platform a vote affects. The aim is that their
ideas count but never outweigh the people it affects. Changes still go through the council and the DEV team.

**50% alone doesn't guarantee that.** Proved (section 3):

- With 1 engaged player voting yes, 2 voting no, and 3 outside players voting yes, the vote passes at half weight,
  against the engaged majority (`half_weight_can_override`).
- More precisely, outsiders can override the engaged players only when their yes votes are **more than twice the
  engaged margin** (`half_weight_override_needs`). So it's rare in big votes but easy in small ones.

**Assumed fix (approve or change):** keep 50% weight, plus an **engaged-majority lock**. If the engaged players
aren't tied, their majority decides. Outside votes are counted and shown, and they break ties. Proved: with the lock,
**the result always matches the engaged majority** whenever the engaged players aren't tied
(`locked_never_overrides`).

Also recorded: all platforms can interact like one big game. Each platform has its own rewards and skill levels, and
players earn **titles of notoriety per platform**.

## 9. "13 levels": two names (brainstorm only)

The personal 13 on the community and education side, and the project 13 in the Gauntlet, need different names. Some
ideas:

| Personal levels (you) | Project levels (the build) |
|---|---|
| Rings (Ring 1 … Ring 13) | Trials |
| Ascents | Gates |
| Orbits | Stages of the Gauntlet |
| Constellations | Forge levels |
| Harmonics | Proofs |

One possible pair is **Rings** for people and **Trials** for projects. "LVL 6 · TRIAL" on your Gauntlet mockup
already leans that way.

## 10. The "Adult Penalty"

It isn't the child-safety rule. The term came from the pasted cross-platform reply, which said it was in a "Master
GDD". It isn't in anything you've shared with me, so I can't tell you what it was meant to be. Since you don't
recognise it, I've recorded it as **not an ORION rule**, and the question is closed.

## 11. The biometric firewall

Recorded:

- **Project-wide, part of the core programming:** one firewall covering all four platforms and the Orion engine
  landing page.
- One account is tied to **one human**.
- A biometric check is needed to **move up a tier**: graduating from under-13 to 13–17, graduating into the adult
  world, and trying to communicate with a child.

Proved (section 5):

- An account's tier **never rises by more than the number of checks it has passed** (`tier_le_passed_checks`).
- An account that passes **no check never moves up at all** (`no_check_no_graduation`).

## 12. Skyboxes inside solar boxes

Recorded:

- A player's skybox inside a dragon's solar box is **its own solar system**, the player's personal property and
  **internal universe**.
- The dragon still governs the orbiting bodies in its universe, the **external universe** or "governing ring".
- The two only interact **through the dragon filter**.
- "🌀🪩 One sinks in, one spreads out" is recorded as the motto for internal versus external universes.

## 13. Ryan's WN-E3 protocol, in plain words (your 🤷‍♀️)

Ryan's tool checks a "receipt" that says, in effect, "I ran this exact package and every check passed". Part of the
receipt is a fingerprint of the package, which changes if even one byte changes.

The gap: the tool accepted a receipt where the **fingerprint didn't match** the real package but **every check was
still marked as passed**. That's like a lab report saying "all tests passed" for a sample whose label doesn't match the
patient. The report should be thrown out, and the tool didn't do that. The small fix makes it reject such receipts.

Nothing for you to decide. It's something to pass on to Ryan.

## 14. Every shared link is now kept

Done: **`ORION_LINK_ARCHIVE.md`** lists every link shared on the ORION pages and in your original request, 86 in all.
Each entry names the project file where it was first saved, and the page copies keep the text around each link. To
rebuild it, run `python3 review/make_link_archive.py`.

- Links I couldn't open are still listed, with a note on why (sign-in or app needed).
- Six Notion pages that used to open with the link **no longer open without access**: ORION R7💎, ORION Engine SoB
  R6, the CONCEPT GALLERY, ORION R6 LIVE, ORION Round 4 and ORION R5 Ryan's Links.
  - If that's on purpose, nothing to do.
  - If not, their sharing setting has changed.
  - Text copies of ORION R7💎, SoB R6, R6 and R5 Ryan's Links are saved in `orion/` from earlier rounds. I don't
    have full copies of the Concept Gallery or ORION Round 4.

## 15. The new concept image

"ORION CHRONICLES · BATCH 1 | KRONOS 7/10 · INTERIOR · MECHANICAL LAIR | THREAT LEVEL: EXTREME | OBJECTIVE:
NEUTRALIZE ENTITY". It shows a suited player with a circuit shield, a mechanical dragon companion with drones, a giant
mechanical boss, and glowing star-of-David asset tiles.

- It fits the rulings: the suit's nodes are labelled N-01 to N-64, matching the 64-slot grid. There's a dragon
  companion and a Kronos meter.
- **One labelling slip:** two different asset tiles are both labelled "VERIFIED ASSET #1194". If asset numbers are
  meant to be unique (one global ID per piece of work, which is what stops double credit), the second tile needs a
  different number.
- Other on-screen text (small and partly garbled, as usual for AI art): "UNVERIFIED ASSET #0781 / #0234, CONTAINMENT
  LOCKED", "MULTISENSORY TELEMETRY · ACTIVE SCAN CLASS-9 THREAT · WEAKPOINT: CHEST CORE JOINT · RANGE 21.8m", "92%
  SHIELDS ONLINE".

## Also updated

`ORION_RUNNING_ROSTER.md` (marked [R9e]), `ORION_MASTER_INDEX.md`, `GAMEPLAY_MECHANICS_SUMMARY.md` and
`CODE_MANIFEST.md`.
