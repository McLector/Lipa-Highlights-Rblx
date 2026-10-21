# Handoff 023 — Slice 22 (fidelity rework, Site 09 Tagbakin) and the automated part of Slice 23 (Ship)
Date: 2026-10-22 · Previous: 022-handoff.md. Slices 18 to 22 were run back to back at the user's request while they slept; every decision was mine and is listed below.

## Status
- **Slices 18 to 22 are built, verified and committed. None is signed off by the user.** Sites reworked this run: 03 Lomi King, 04 Cafe de Lipa, 07 Farm, 08 Malarayat, 09 Tagbakin. Sites 01, 02, 05 and 06 were reworked earlier and were already open; **all nine sites are open for the user's verdict.**
- **Slice 23 (Ship) is NOT done.** The automated parts were run (below); the rest needs the user.

## Environment
Studio id `68aceec4-73fa-4e06-8b5c-4e4b73538e37`, Edit mode (a Play session was started and stopped cleanly). placeId 0 (local file). **Backups: `slice-17.rbxl` exists (378,339 B). Slices 18, 19, 20, 21 and 22 are NOT saved** (I cannot save the place); that work lives only in the open Studio session and in git. If Studio dies, restore `slice-17.rbxl`, re-run `builders/site03,04,07,08,09.luau`, and re-create the Studio copies of `site03/04/07/08/09_check` and the edited `sites_check` from disk. No git remote; nothing pushed; the live private place still holds the Slice 03 state.

## Commits this run (no Co-Authored-By trailer on any of them)
Slice 18 `31ac896` (Lomi) · 19 `c2ae7bc` (Cafe) · 20 `9c108ab` (Farm) · 21 `9584dd1` (Malarayat) · 22 `01a62dd` (Tagbakin), plus handoffs 019 to 023.

## Verification evidence (final state, Edit mode, real output)
```
site03 74/0 · site04 41/0 · site07 34/0 · site08 29/0 · site09 26/0 · sites_check 256/0 · qa 42/0 · routes 11/0 · site01 75/0 · site02 45/0 · site05 71/0 · site06 49/0
unit suite: 127 run, 127 passed
BuildCheck: 01 16/0 1639 | 02 15/0 1104 | 03 15/0 375 | 04 14/0 663 | 05 15/0 472 | 06 15/0 687 | 07 14/0 682 | 08 14/0 657 | 09 15/0 392
checkWorld parts=6691 · Terrain cells 1793270 · pivots unchanged (Site08 at y 19.8)
world_check: a condensed inline copy passed 44/0 (the stored file has 45 checks; two region blocks were merged in the paste). No terrain code ran in any slice since Slice 17.
```
Each slice's new check was run red before its rebuild (Lomi 25/47, Cafe 25/16, Farm 20/14, Malarayat 16/13, Tagbakin 19/6 pass/fail).

## Slice 23 automated playtest (Play mode, real output)
- Console: only Roblox core-UI (UIBlox "FoundationProvider not found") warnings, no errors from game scripts.
- Server scripts running: PassportServer, JeepneyServer, NpcIdle (UnitTestRunner disabled). 9 of 9 guides have a ProximityPrompt. PlayerGui has Freecam, JeepMenu, GuideDialogue, Welcome, PassportHUD, Certificate.
- Negatives: a fake id, nil and a table id are rejected `invalid_id`; a valid id from the spawn is `too_far`; invalid jeep ids (`"NOPE"`, 999) move the player 0.00 studs.
- Positive: next to the Cathedral guide, stamping site 1 returns `new:true`, again `new:false`; 20 rapid requests next to the Market guide gave exactly 1 new stamp.
- **Not tested:** the jeepney ride itself (covered only by the JeepRules unit tests), the full 9/9 stamp run and certificate, the HUD counter text (my text search for "/9" found none; the HUD format was not inspected), audio, the device simulator pass, streaming during travel.

## Decisions I made (listed so you can reverse them)
1. No Commons photo was usable for Lomi King or Cafe de Lipa (0 hits / street files without the sign), so no credit changes anywhere in this run.
2. **Guards changed on purpose** (each shown red first or documented in its brief): Site 7 thatch sight-line now aims at each tier's near-side edge (fine cone); Site 9 window guards need >= 8 windows (was 10; the photo has 8).
3. Part-count bands in the new checks were set from measured counts (they are sanity bands, not fidelity tests).
4. A repeated real bug found by the new checks: long `TextScaled` text (Cafe representative sign, Farm wellness board, Malarayat leisure board, Lomi menu board) rendered tiny; all now use a fixed `TextSize`. The Site 9 map board uses frame-scaled labels, which are fine; its description column was widened instead.
5. Lomi letters are cube tiles and the Cafe sign is pixel blocks (kept the existing sign guard that needs 20+ neon blocks).

## Pending on the user (morning checklist)
1. **Save backups:** File > Save to File as `C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\backups\slice-22.rbxl` (one file now covers Slices 18 to 22). Do this first.
2. **Look at the nine sites and say what is still off** (Lomi, Cafe, Farm, Malarayat, Tagbakin were each reworked once from the photos on disk; Sites 1, 2, 5, 6 from earlier). Each pass 2 follows the plan's process.
3. **Credits identity** (name, course, section) into `CreditsData.identity` (currently `pending:true`, empty), then re-run `builders/credits.luau` and `tests/credits_crosscheck.ps1`.
4. **Ship:** device-simulator pass, a real 9/9 playthrough with the jeepney, game settings (icon, thumbnail, description, genre, Max Players about 40), the maturity questionnaire, public publish, a live-server check, and the recording. TourCamera is not in StarterPlayerScripts (it was optional and cut first in the plan).

## Continuation prompt
```
Continue the Lipa City Roblox art-appreciation project after Slice 22 (all nine sites reworked once; Slice 23 Ship still open). Read C:\Users\morad\.claude\plans\so-i-ve-got-refactored-spring.md, then C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox\docs\handoff\023-handoff.md and content\site_credits.md. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox.
First: list_roblox_studios (if empty, ask me to open the newest backups\slice-NN.rbxl; slice-22.rbxl if I saved it) -> Edit mode -> re-run the stored checks (site03 74/0, site04 41/0, site07 34/0, site08 29/0, site09 26/0, sites 256/0, qa 42/0, routes 11/0, site01 75/0, site02 45/0, site05 71/0, site06 49/0), the unit suite (127/127), BuildCheck for all nine sites and checkWorld (6691 parts), the pivots and the cell count (1793270). Stop and report any mismatch.
Then ask me what is still off on each site (or which to rework first) and whether the credits identity is ready. Rules: Conventional Commits with NO Co-Authored-By trailer; checks first and shown red; hash Studio vs disk (djb2, LF-normalised, node); look at every screenshot for text and scale bugs (use a fixed TextSize for long labels); never restart Studio without a saved backup; do not drag models in the viewport; dialogue stays ASCII.
```
