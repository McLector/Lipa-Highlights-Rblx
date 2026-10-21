# Handoff 021 — Slice 20 (fidelity rework, Site 07 The Farm at San Benito)
Date: 2026-10-22 · Previous: 020-handoff.md. Run unattended (user asleep); decisions mine.

## Status
Slice 20 built, verified, committed (see `git log`, `feat(slice-20)`). **Not signed off by the user.** Open sites: 01, 02, 03, 04, 05, 06, 07.
References: `Farm_Villa_Pool_Front.jpg` and `Farm_Big_Lagoon_and_Pavilion.jpg` (already on disk). No new photo; no credits change.

## Environment
Studio id `68aceec4-73fa-4e06-8b5c-4e4b73538e37`, Edit mode. Backups: `slice-17.rbxl` exists; **`slice-18`, `slice-19`, `slice-20` PENDING** (I cannot save the place). Everything since Slice 17 lives only in the open Studio session and in git.

## What changed
Files: `builders/site07.luau`, `tests/site07_check.luau` (new, 34 checks), `tests/sites_check.luau` (one guard changed), `briefs/site07.md` ("Revision 1 (Slice 20)").
Hashes (Studio = disk): site07 builder **21316/438/2621608000**; site07_check **8373/184/3350120268**; sites_check **46369/762/2509028971**.
**Guard changed on purpose:** the Site 7 thatch sight-line now aims at each tier's near-side edge (an axis-centre ray cannot see the upper tiers of a fine cone from a low eye). Still needs 80% of tiers visible; 12/12 pass.
Built: darker pool water, `CopingJoint` x12, 12-tier thatch + finial, 19 palms 16/18/20 tall with 8 fronds of 9.5, `WingPost` x6, fixed-size wellness board text (it was TextScaled on 213 characters).

## Verification (Edit mode, real output)
Red first: `site07_check` 20 passed / 14 failed on the old model.
```
site07_check 34/0 · site03 74/0 · site04 41/0 · sites_check 256/0 · qa 42/0 · routes 11/0 · site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0
unit 127/127   BuildCheck: 01 16/0 1639 | 02 15/0 1104 | 03 15/0 375 | 04 14/0 663 | 05 15/0 472 | 06 15/0 687 | 07 14/0 682 | 08 14/0 530 | 09 15/0 400
checkWorld parts=6572   cells 1793270   pivots unchanged
```
Screenshots: the original villa and pavilion shots (before) and one pavilion shot (after). Not looked at: the villa after the change, the path, the wellness board close up.

## Not done
No play test; no villa-front close-up after the change; no terrain change. `world_check` not re-run (no terrain code ran; cell count unchanged).

## Pending on the user
Save the missing backups; verdicts; credits identity; Ship (Slice 23).
