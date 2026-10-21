# Handoff 022 — Slice 21 (fidelity rework, Site 08 Mount Malarayat)
Date: 2026-10-22 · Previous: 021-handoff.md. Run unattended (user asleep); decisions mine.

## Status
Slice 21 built, verified, committed (`feat(slice-21)`). **Not signed off by the user.** Open sites: 01 to 08 (all reworked sites are open for the user's verdict).
References: photos already on disk; no new photo; no credits change.

## Environment
Studio id `68aceec4-73fa-4e06-8b5c-4e4b73538e37`, Edit mode. Backups: `slice-17.rbxl` exists; **`slice-18` to `slice-21` PENDING** (I cannot save the place); the work since Slice 17 lives only in the open Studio session and in git.

## What changed
Files: `builders/site08.luau`, `tests/site08_check.luau` (new, 29 checks), `briefs/site08.md` ("Revision 1 (Slice 21)").
Hashes (Studio = disk): site08 builder **25395/510/218266307**; site08_check **8101/182/2883594454**.
Built: bright terracotta roof, `WindowTrim` x24, `StoneCourse` x4, 12 carts (third row on the left), 34-high 8-tier pines, 18-high palms with 8 fronds, fixed-size leisure board text.
Gotcha found: a cart row on the right of the forecourt blocks walking lane c ("forecourt to pool") in sites_check; moved it to the left.

## Verification (Edit mode, real output)
Red first: `site08_check` 16 passed / 13 failed on the old model.
```
site08 29/0 · site07 34/0 · site04 41/0 · site03 74/0 · sites_check 256/0 · qa 42/0 · routes 11/0 · site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0
unit 127/127   BuildCheck: 01 16/0 1639 | 02 15/0 1104 | 03 15/0 375 | 04 14/0 663 | 05 15/0 472 | 06 15/0 687 | 07 14/0 682 | 08 14/0 657 | 09 15/0 400
checkWorld parts=6699   cells 1793270
```
Screenshots: the clubhouse before and after; not looked at: pines, pool, island green close up. `world_check` not re-run (no terrain code ran).

## Not done
No play test; no terrain change; the roof is still stacked tiers (not a smooth hip).

## Pending on the user
Save the missing backups; verdicts; credits identity; Ship (Slice 23).
