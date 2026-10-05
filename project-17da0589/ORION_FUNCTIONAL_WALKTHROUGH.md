# How the ORION Engine is supposed to function: a plain-words walkthrough

Written for Round 9 (2026-10-04) because you asked: "how is this supposed to function, without blowing my brain up
with coding". It contains no code. It's built only from your rulings so far (see `GAMEPLAY_MECHANICS_SUMMARY.md`) and
the ORION's Gate mockup on R9 Live. Anything marked *(suggestion)* is my idea, not a ruling.

---

## 1. The big picture in one paragraph

ORION is **one account** that opens **one connected world** with several doors:
- **ORION's Gate** is the front door;
- behind it are **The Playground** (social), **The Orion Chronicles** (the game), **The Ascent** (learning),
  **projects** (taking things into the real world) and **Elder's Garden** (the family tree and celebrations);
- **POLY** runs through the game as capture → train → utilize.

The layers form a loop: Engine → Playground → Chronicles → Ascent → projects → Elder's Garden → back to the Engine. You
can walk in through any door, and every layer is at most five steps from any other (proved in Round 8).

Underneath everything sit two things you never see but always rely on:
- **the official rulebook** (the Loom archive, with your 💎 locks);
- **the change rule** (creator → DEV team → Galactic council → human).

---

## 2. ORION's Gate: the front door

**What it's for:** the first page anyone sees. It explains ORION in one glance, and sends each visitor to the right
door.

**What's on it** (from your mockup):
- the **ORION's Gate** title, with the two forces either side: **Kronos** (kinetic, red) and **Orion** (harmonic, blue);
- two big buttons: **Enter Playground** and **View Chronicles**;
- a **live engine status** bar: core stability, kinetic flow, harmonic sync, "online";
- four **portal cards**: Playground, Orion Chronicles, Ascent, Elder's Garden. Each has a one-line description and a
  live status;
- **Docs**, **Join Now**, and a **recruitment ticker** (pilots, kinetic engineers, harmonic technicians wanted).

**What a visitor does:**
1. Reads the one-line pitch.
2. Either clicks a portal to look around as a guest, or clicks **Join Now** to make an account.
3. After joining, ORION's Gate becomes their **home dashboard**: their level, their skyboxes, any council votes or
   notifications waiting (for example "someone proposed a change to your design", from the Round 9 rule), and
   shortcuts back into whichever layer they were last in. *(suggestion)*

**Fix before going live:**
- the Elder's Garden card should say ancestral tree and celebrations, not "grow stabilizers";
- replace the placeholder numbers ("© 4027", "v3.1.9", "1.2k users", "47 new entries");
- decide whether POLY and projects get their own cards (R8 Q6).

---

## 3. The Playground (social layer: "the swarm")

**What it's for:** where people meet, post, team up and share what they've made. Your socials (X, YouTube, TikTok,
Instagram, GitHub, Discord) feed into it.

**What a visitor does:** posts, follows, joins groups and guilds, and shares schematics, stories and art. Concept art
from the gallery can live here too.

**How it connects:** the swarm "feeds up". Ideas and teams formed here go into the game, into learning, and into
projects.

---

## 4. The Orion Chronicles (the MMO: "the proofs")

**What it's for:** the game itself.
- **Character:** species (chosen once), body, archetype, skin. A skin's look is cosmetic; crafted bioengineered skins
  can add enhancements.
- **Skill orbs:** level to 100 (gold-lock). Gold orbs slot into the 64-node matrix. Meditating in a safe zone with the
  full matrix makes you a level-65 dragon rider.
- **Dragons:** a 144-node dragon matrix. Elements are fire, water, earth, air and ether. Ordinary dragons choose their
  path and learn one element at a time. The phoenix runs several elements at 110% → 100%.
- **Never stuck:** quests, a quest generator and search, and levelling just by interacting.
- **Skyboxes:** owners set who can come in. Aggro and PvP rules apply.
- **Economy:** 3% tax, player-favouring rounding, royalties, arena pools.

**What a player does:** create a character, train orbs, quest, build, trade, battle, and eventually earn a dragon.

---

## 5. POLY (capture → train → utilize)

**What it's for:** catching game creatures, training them, and putting them to work. That includes competing in the
**Polygon Arena**. DeepSeek is effectively POLY's headmaster; how far its decision-making reaches is question G6.

*(suggestion)* Skill orbs can power POLY pods, giving the creature inside that skill line while the orb is in the pod.

---

## 6. The Ascent (education)

**What it's for:** learning that moves players forward, in the game and in real life. The owl "AI tutor" in the new
Chronicles art is a good picture of it: guided lessons just past your current skill (Round 4 rule), plus educational
quests.

---

## 7. Projects (taking it into the real world)

**What it's for:** turning good ideas from the game and the community into real projects.
- A project goes to a **council**: 4/5 consensus, three strikes, a 7-day cool-off.
- It also needs **the humans' choice**, and the humans can always say no.
- Anything attached to a submitted project becomes public record. Private chats stay private.

---

## 8. Elder's Garden (ancestral tree and celebrations: the capstone)

**What it's for:** each user's **family tree and celebration board**.
- Public accomplishments, storylines and family relations are viewable.
- Bubbles branch **outward** to friends and family, and **inward** through a user's own accomplishments and
  publications.
- Published stories pass the **story gate**: real stories cite a source, and every genre's record stays consistent.

**How it connects:** the tree "feeds back down" into the Engine. Celebrated work and family links become part of the
world's shared history.

---

## 9. What sits underneath everything

1. **One account everywhere.** The same identity, level, credits and reputation in every layer.
2. **The official rulebook (Loom archive).**
   - Every locked ruling is written down once. Pages, devs and AI helpers all check against it, so stale pages can't
     spread old rules (the old 2% tax, for example).
   - 💎 entries change only with your signature.
3. **The change rule (Round 9).**
   - Changing someone's design needs that creator's yes if they're active. Otherwise it needs the whole DEV team's
     agreement.
   - Then the Galactic council, then a human.
4. **Credit that follows the work.** Royalties, RD pool shares and contributor lineage (Marek included) all point back
   to whoever made the thing.
5. **Signed official releases.**
   - Official servers only run builds signed with your key.
   - An altered copy can't pretend to be ORION.

---

## 10. A sensible order to build in *(suggestion)*

1. **ORION's Gate as a simple website:**
   - the pitch, the portal cards (linking to "coming soon" pages where needed), Docs, and a sign-up list;
   - this can go up now, with no game code.
2. **The Docs page:** a public version of `GAMEPLAY_MECHANICS_SUMMARY.md` and the locked names.
3. **The Playground:** start with a Discord or community hub linked from the Gate, then fold in your socials. This is
   also where feedback will start coming in.
4. **Accounts:** one sign-in that later carries into every layer.
5. **Elder's Garden profile pages:** a public profile with accomplishments and links, before the full family tree.
6. **The Orion Chronicles:** prototype the core loop first (character, orbs, meditation, one skybox) before dragons
   and POLY.
7. **The Ascent and projects:** lessons and the council flow, once there are players to use them.

**About feedback:** visitors respond best when a page gives them **one clear thing to do**: "join the list", "vote on
the next feature", "share your concept art". Putting one such ask on the Gate and on each social post usually gets
more replies than a general invitation.
