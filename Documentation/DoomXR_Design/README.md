# DoomXR — Game Design

The design vision for DoomXR's roguelite-arcade layer: a VR looter-shooter built on
native GZDoom/DoomXR, where you still play *Doom* but every kill feeds a stack of
interlocking systems — score chains, gold economy, crits, a difficulty director, loot
imprints — and **90 physical VR gestures** are the skilled input that drives all of it.

> **Status:** design synthesis, 2026-07-04. This captures a working vision, not shipped
> code. Numbers are deliberately left as "the user's balance call" — this documents
> *structure*, not tuning. Some referenced systems exist today (SDF combo, kill-reward
> bits, crits, the native Hardpoint holster); others are proposed seams.

> **Provenance note:** several mechanics here were understood by studying prototype
> systems in a `notforclaude` reference tree (HackFraud). Those are **inspiration only** —
> this document describes DoomXR's *own* native design, not a port. Where a proven
> pattern exists, it's named as a pattern, not lifted.

## Read in this order

1. [Core loop](01_core-loop.md) — the whole game on one page.
2. [Classes & loadout](02_classes-and-loadout.md) — Vanilla+, dual-weapon classes, the universal art kit.
3. [The gesture system](03_gesture-system.md) — 90 gestures as a gold-bought build tree.
4. [Scoring & the combo chain](04_scoring-combo.md) — the SDF damage-chain and the gold economy.
5. [Crits & locational damage](05_crits-locational.md) — the precision layer gestures plug into.
6. [The difficulty director (DDA)](06_difficulty-director-dda.md) — normalized time-to-kill, adaptive set-pieces.
7. [Economy & the shop](07_economy-shop.md) — gold, the SDF worldspace shop, what it sells.
8. [Encounter spikes](08_encounter-spikes.md) — captains, elites, curse tokens.
9. [Engine seams](09_engine-seams.md) — the native hooks this design needs (exists vs. proposed).
10. [Open questions](10_open-questions.md) — every unresolved fork, in one place.

## The gesture catalog (companion)

The raw 90-gesture catalog lives next door in
[`../DoomXR_Gesture_Ideas/`](../DoomXR_Gesture_Ideas/) — browse it via
`gesture-catalog.html` (searchable, filterable) or the per-category `.md` files.
This design set explains *how those gestures fit the game*; the catalog is the
idea inventory itself.

## The one-sentence pitch

You pick a dual-weapon fighting style, you still play Doom, and everything you do
with your hands — how you kill, reload, finish, traverse, dodge — feeds a chain-score,
a gold economy, a crit layer, and a difficulty director that escalates to meet your
skill and hands you a bullet-time stage to show off on.
