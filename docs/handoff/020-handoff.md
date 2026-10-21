# Handoff 020 — Slice 19 (fidelity rework, Site 04 Cafe de Lipa)
Date: 2026-10-22 · Previous: 019-handoff.md. Slices 19 to 22 were run back to back at the user's request (they were asleep); decisions were made by me.

## Status
Slice 19 built, verified, committed (`c2ae7bc`). **Not signed off by the user.** Open sites: 01 plaza, 02 Market, 03 Lomi, 04 Cafe, 05 Carmel, 06 Outlets.
Reference: only the Tibig/STAR night photo (the two unconfirmed-branch photos stay excluded). Commons has no Cafe de Lipa file (0 hits). No credits change.

## Environment
Studio id `68aceec4-73fa-4e06-8b5c-4e4b73538e37`, Edit mode. Backups: `slice-17.rbxl` exists; **`slice-18.rbxl` and `slice-19.rbxl` PENDING** (I cannot save the place). The Slice 18 and 19 state lives only in the open Studio session and in git. No git remote.

## What changed
Git: `c2ae7bc`. Files: `builders/site04.luau`, `tests/site04_check.luau` (new, 41 checks), `briefs/site04.md` ("Revision 1 (Slice 19)").
Hashes (djb2, LF-normalised; bytes/newlines/hash), Studio = disk: builder **22521/472/70893896**. `site04_check` Studio = disk after the threshold edit (">= 60 neon blocks"); disk before the edit was 11925/244/4080465770.
Built: 5 x 9 bold pixel "cafedelipa" (71 neon blocks) centred on a band that now runs y 13..22; 3 columns; pale `NeighbourBay` + `NeighbourWindow` + 2 `NeighbourSpot`; slat chairs (`ChairSlat`, `ChairPost`); 38 `TileGrout`; 11 `BarPlank`; fixed-size `RepresentativeSign` text.

## Verification (Edit mode, real output)
Red first: `site04_check` 25 passed / 16 failed on the old model (including the real bug: `RepresentativeSign` TextScaled on a 32-char line).
```
site04_check 41/0 · site03_check 74/0 · sites_check 256/0 · qa 42/0 · routes 11/0 · site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0
unit 127/127   BuildCheck: 01 16/0 1639 | 02 15/0 1104 | 03 15/0 375 | 04 14/0 663 | 05 15/0 472 | 06 15/0 687 | 07 14/0 619 | 08 14/0 530 | 09 15/0 400
checkWorld parts=6509   cells 1793270   pivots unchanged (Site04 at 272,0,-160)
```
Screenshot: one front oblique, compared with the night photo; no text or scale bug. Not looked at: interior close-up, rear.
`world_check` not re-run this slice (no terrain code ran; cell count unchanged).

## Not done
No play test; the interior is representative; sign is pixel blocks (not rounded glass tubes); no night lighting (ClockTime stays 15.5).

## Pending on the user
Save `backups\slice-18.rbxl` and `backups\slice-19.rbxl` (or one later file); verdicts on the open sites; credits identity; Ship (Slice 23).
