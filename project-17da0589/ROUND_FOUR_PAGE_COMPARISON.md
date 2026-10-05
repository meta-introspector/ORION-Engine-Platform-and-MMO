# Round Four page: current state compared with what I've already processed

**Source:** the *ORION Round 4* Notion page as it stands now (read in full: 755 blocks, 4 photos).
**New Lean file:** `RequestProject/RoundFour/RulingsTwo.lean`. The whole project builds with no `sorry` and only
Lean's standard axioms. Three earlier results are marked *Superseded* in `RoundFour/Rulings.lean` (nothing deleted).

---

## 0. Using your photo dividers

Yes, I noticed, and it helps. The four photos divide the page into five blocks:

| Block | Between | What it holds | Status |
|---|---|---|---|
| 1 | top → photo 1 | Ryan's Formal Kernel v0.2 and v0.3, Round Three Game Rules v1 (the v0.3 boundary is pasted twice, which does no harm) | processed earlier |
| 2 | photo 1 → photo 2 | Grok's comparison, my Round Three report with your notes, Ryan's K22 ledger, Game Rules v2/v3 | processed earlier |
| 3 | photo 2 → photo 3 | my manifest reply, your D1–D8 answers | processed in the rulings update |
| 4 | photo 3 → photo 4 | **"UPDATED ARI"**: your new 🍝🧠 notes written into that report, the "garden" question, Ryan's link and "master tip" | **new: processed in this file** |
| 5 | after photo 4 | my last transmission (team roster / X review) | no notes from you yet; you're working through it |

Nothing above photo 3 has changed in a way that affects the rules. Block 4 is the only part with new decisions in it.

One thing from block 1 answers a question in my last transmission: **"W0 / O0" are Ryan's labels.** His Formal
Kernel v0.2 boundary reads "Authority: O0 / WITHHELD · Witness: W0 · Independent reproductions: 0 · Production:
PROHIBITED". So W0 means no independent witness has reproduced it, and O0 means no operational authority has been
granted. The status note's numbers (35 proof obligations, 10,904 reference checks) don't appear anywhere on the page.
v0.2 had about 20 Lean obligations and v0.3 had 32 theorem sources and 47 tests. So that note is probably a later
Ryan build, likely the v0.4 "event admission" step he named as next. Grant-path resolution fits that step. Please
confirm.

---

## 1. Your new notes, one by one

### 1.1 Phoenix hatching (your note on D8): formalized
> "hatches unlit but with the fire flame ability … they wouldn't stay aflame unless the player activated the flame
> ability after that"

- **A phoenix hatches unlit, with fire already gained**, at no cost (`phoenix_hatches_unlit_with_fire`).
- **One action lights it** (`phoenix_lights_up`). The flare in the hatching animation is visual only; it doesn't
  change the state.
- This replaces my earlier "hatches with fire active". **It also brings Ryan's code back into line:** his phoenix
  hatches unlit too. The one thing he'd need to add is that the fire ability is already learned at hatching.

### 1.2 Phoenix elements: chosen, not all on at once. Formalized
> "they don't all activate at once. They CAN — phoenix build can choose which and how many are active at once.
> Certain elements v encounter."

- **Gaining an element never switches it on**, for any dragon.
- **A phoenix picks its active set**: any combination of the elements it has gained, from none to all five
  (`phoenix_select`, `phoenix_any_selection`). Example: a five-element phoenix running only water and air
  (`phoenix_partial_choice`), or all five when the player selects them (`five_element_phoenix_by_choice`).
- **Every other dragon still has at most one element active**, however it plays (`other_at_most_one_active'`).
- **The rule holds after any sequence** of gains, activations, deactivations and selections (`run'_valid`).
- **Unchanged:** fire is open to every dragon (`fire_open_to_all'`), and a phoenix pays half price (the earlier
  `phoenix_half_rate` / `phoenix_spends_no_more` still apply).
- **Superseded, still in the file:** `phoenix_hatches_with_fire`, `phoenix_all_active`, `five_element_phoenix`.
- "Certain elements v encounter" (some elements suit some encounters better) is recorded as design. It isn't
  formalized because it needs an element-versus-encounter table.

### 1.3 How much agreement is consensus? **4/5.** Formalized, with one consequence to check
- The council publishes when at least four fifths of the votes are approvals (`council`).
- **A council of \(n\) can absorb exactly \(\lfloor n/5 \rfloor\) rejections** (`council_iff_rejections`,
  `council_iff_rejections_div`).
- **⚠ Small councils:** with **four or fewer votes**, one rejection blocks (`small_council_needs_all`). Three out of
  four is 75%, which is short of 80% (`four_one_rejection`). So the single veto you removed comes back automatically
  for any council smaller than five. Five votes absorb one rejection (`five_one_rejection`) but not two
  (`five_two_rejections`).
- **Question:** is that intended? If not, two easy fixes: a minimum council size of 5, or "4/5, rounded down in
  favour of publishing".

### 1.4 What a non-phoenix gets from an element: recorded
> "Limited and minimized, visual effects and less effective skills/abilities — Dragon builds should always have
> massive benefits to standard player skills and abilities."

Recorded as design: phoenix gets the full element; any other dragon gets visuals and a weaker version; any dragon
build gives a large boost to the player's standard skills. **Not formalized yet** because there are no numbers.
If you give a ratio (e.g. "a non-phoenix gets half the effect" and "a dragon at least doubles a standard skill"),
I can prove the ordering phoenix > other dragon > no dragon holds for every skill.

### 1.5 Aggro follow-ups: confirmed, plus monster timer formalized
- **(a) First player's aggro:** "Player aggro is linked specifically to the player." This matches what is already
  proved: nobody's actions change anyone else's timer unless they themselves engage kinetically (`effect_no_grief`,
  `RoundThreeCuration.stays_inactive`). No change.
- **(b) Monsters use the same 10-minute timer** (`monster_window_same`). You asked for anyone who sees a problem to
  say so. I see none in the rules as proved.

### 1.6 Private conversations and the public record (your note on D6): formalized
> "You can have private conversations, but if you want to include them in your build, moving forward with the
> council, it has to be submitted and made public."

- **Anything attached to a council submission becomes public record** (`submit_publishes_attachments`). So every
  item in a build that goes forward is public (`council_build_all_public`).
- **Anything not attached keeps its visibility** (`submit_keeps_unattached`). Private conversations stay private
  unless the player chooses to attach them.
- **This settles the Chronicle question (Q4)**: the permanent log can hold governance events and council submissions,
  since those are public anyway. Unattached private items never go into it.
- **One clash to settle: hard reset vs public record.** The proved hard-reset rule says a reset player's blueprints
  lose their tags and are credited as anonymous. If a submitted project is permanent public record, does a hard reset
  remove the **name** on it? The suggestion that keeps both rules: the **content** stays public, the **author
  field** becomes "anonymous".
- **Admin access to private communications on the live server:** recorded as stated. Players should be told plainly
  that the admin team can see these, especially since the game has under-18 players. What the team must disclose is
  a question for someone qualified in privacy rules; I can't advise on that.

### 1.7 Kronos / Orion / KRION vs HIVE / PULSE / SHEPHERD: your pattern match, checked
You asked me to check your reading **HIVE → Kronos, PULSE → Orion, SHEPHERD → KRION**. Here is what each term means
in the project:

| Term | Meaning in the project | Source |
|---|---|---|
| **HIVE** | *Hierarchical Interaction and Variance Engine*; in the Proofs Arena **discovery** wave | `Zoo/Arena.lean` |
| **PULSE** | *Predictive Uncertainty and Longitudinal Safety Evaluation*; **domain-safety** wave | `Zoo/Arena.lean` |
| **SHEPHERD** | *Systemic Hazard Evaluation through Persistent History, Error, Recursion and Drift*; **domain-safety** wave | `Zoo/Arena.lean` |
| **Kronos** | the kinetic / active mode (kinetic skills pull aggro) | Round Three rules |
| **Orion** | the perceptive / receptive mode (Orion-aligned effects are safe while aggroed) | Round Three rules |
| **Krion** | the meter between the two ("renamable Krion labels"); drifts from Kronos toward Orion | lore codex, glossary |

My assessment:
- **PULSE → Orion: strong.** Prediction, uncertainty and long-term watching are perceiving, not acting.
- **SHEPHERD → KRION: good.** A shepherd watches (history, drift) *and* steps in (hazard, error). That straddles both
  ends, which is what the Krion meter is.
- **HIVE → Kronos: plausible, the weakest of the three.** "Interaction" and "Engine" are active words, and HIVE sits
  in the discovery wave (active probing) while PULSE and SHEPHERD are both safety. But HIVE is about *coordinating
  many*, which is collective rather than kinetic.
- So the pairing **does tie together**. It is one-to-one and covers all three builds (`pairing_bijective`). I've
  recorded it as a **proposal**, not a ruling.
- **Question this raises:** if HIVE means Kronos, does a HIVE dragon lean towards aggro-pulling (kinetic) play, and a
  PULSE dragon towards safe (Orion) play? The glossary says Kronos/Orion are "processing modes, not moral teams", so
  this would be about playstyle only.

### 1.8 Renaming the social-community "bedrock" to "the Garden": thoughts
- I like it. It fits the growth language already used across the project (Mycelial Gardens, the Elder's Garden).
- **Name clash to avoid:** `GAME_LORE_CODEX.md` §8 already has **"The Elder's Garden (GaiaNet hub)"**, whose lore is
  "the universe is a garden behind an old house". Either make the Elder's Garden *one place inside* the Garden, or
  rename one of them.
- **I couldn't find "bedrock" in the project files.** The closest is the "Social hub", listed as not yet formalized.
  Tell me which document uses "bedrock" and I'll rename it consistently. No proofs depend on the name.

### 1.9 Ryan's link and "master tip"
- The link is a shared ChatGPT conversation titled **"Portfolio overview"**. Its content matches the text you pasted:
  a general workflow for running an **investment** research portfolio (evidence → claims → portfolio decisions,
  cadence, calibration).
- **It doesn't answer any of the open questions** (consensus, elements, aggro, archetypes, lessons). It's advice on
  method.
- **What is useful for ORION:** its *claim ledger* (every claim with its confidence, evidence for and against, and
  what would falsify it) is close to how the Proofs Arena and Ryan's own evidence labels (W0/O0) already work.
- **One caution:** "paste everything into one chat and ask for a refined synthesis" loses track of where each claim
  came from. Ryan's own kernels do the opposite: hash-pinned files and no silent promotion. For the build itself,
  stick with files and hashes.

---

## 2. Still open (short answers welcome)

1. **Small councils** (§1.3): is it OK that councils of fewer than five need every vote?
2. **Element strengths** (§1.4): what ratios for non-phoenix elements and the dragon boost?
3. **Hard reset vs public record** (§1.6): content stays and name goes, or something else?
4. **HIVE / PULSE / SHEPHERD pairing** (§1.7): confirm, and say whether it affects playstyle or aggro.
5. **"Bedrock"** (§1.8): which document uses it, and should the Elder's Garden sit inside the Garden?
6. **Lessons vs the menu rule** (Q6 / D3): still unanswered: a separate Lessons list, or greyed-out menu entries
   linked to lessons?
7. **Rounding** (D1): still the team's call. Ryan rounds costs up and the proofs round them down.

**Not checked:** Ryan's ZIP files still aren't on the page or in this project.
