# Handoff 051: R6a (band traffic, poles, wires, cap raise) is BUILT and committed; R6b (12 crowd figures) is planned and NOT started
Previous: 050-handoff.md (then 049 to 036 for the environment and rules). This file only records what changed after 050.
Baseline now: `run_all` reads **ok=true, 89 rows, 0 mismatches**; HEAD is the commit that adds this file, on top of `22765ce`.

## Owner decisions and approvals since 050 (2026-10-30)
- Saved `slice-36-wip19.rbxl` on request (before R6a). On the wip18 hash mismatch (below): "do what u think is better in this".
- R6a look: "Commit as built (Recommended)" with the two honest DIFFs shown (south band denser than the blueprint; poles and wires are the owner's request, not drawn).
- `e8edef6` (the 050 EXPECTED edit, roads_check 278, cells 1796830): **"Yes, confirmed"**. The open note in 050 is closed.
- EXPECTED for R6a (site02_check 167, build 02 parts 2322, worldParts 10414): asked twice. First answer "do whats best"; second, verbatim: "lets put the best interest of the overall plan in place, if this is something thats truly necessary then go if not and wont affect much of the work then we may skip as we are in hurry on this project". **My reading: a conditional OK.** I judged it necessary because `run_all` is the README's session-start gate and would stay red on exactly those three rows; the commit body says so and calls it an interpretation, not a plain yes. Correct me if that was not meant (then revert `22765ce` and `run_all` goes red on exactly those three rows).

## What changed (hashes: bytes / newlines / djb2, disk equals Studio)
- `builders/site02_bands.luau` 7940/138/3370195152 (new, LF): owns the Folder `BandTraffic`; north band (z -5..31) and south band (z 277..325, x -530..-228), each 6 `BandJeepney` (z -1.5 / 321.5), 4 `BandTricycle` (z 8.5 / 314.5), 6 `BandMotorbike`, 6 `UtilityPole` + `PoleArm` + `PoleLamp` (z 14.5 / 308.5, x -250..-500 step 50), 10 `PoleWire` (50 long, y 22.2..22.4). 240 parts. Vehicles are Models, direct children, recipe copied from `site02_traffic`.
- `builders/site02.luau` 15315/293/676246645: `SITE_CAP` 2100 to 2550, `MODULES` row `site02_bands` (budget 250), `TREE` row `BandTraffic`, header.
- `tests/site02_check.luau` 105746/1534/3864647300: new group `bands` (16 new checks, 17 with the shared one), `CAP.total` 2550, own-part guard 2200 (the only two existing assertions touched, both caps).
- `tests/run_all.luau` 20002/117/2360878440: `site02_check` 167, `build 02` { 15, 2322 }, `worldParts` 10414, each with a reason.
- `briefs/site02.md` (R6a entry with MATCH/DIFF), `docs/shot-kit.md` (CRLF, two Market rows).

## Evidence (run by me)
- **Red first:** `bands` 1 passed / 16 failed (agent run, my re-run identical), committed `afa0bd0`. Build: one Sonnet agent each for tests (108k tokens) and builder (110k); neither used git or screenshots.
- **Green:** `bands` 17/0, `general` 34/0, `yard` 31/0 (my runs); hall 46/0, sheds 17/0, block 27/0 (builder agent). Coordinator twice identical: builtParts 2261, rigParts 128, keptParts 61, parts 2322, `BandTraffic` 240.
- **`run_all`:** after the build, exactly three mismatches (site02_check 167 vs 151, build 02 parts 2322 vs 2082, worldParts 10414 vs 10174); after `22765ce`, ok=true, 89 rows; negative control `override = { site02_check = 151 }` goes red on exactly `site02_check passed: got 167, expected 151`.
- **Ground:** terrain columns in both bands read Grass 1.00 / Concrete 0.50 like under SJ3 and PV5 (accepted yard vehicles) and a downward ray hits y 0.00: vehicles at y0 0 follow precedent.
- **`routes_check`** 16/0 in Edit and in Play. **Market walk 429.63** in Edit and in Play, and the SAME 429.63 with `BandTraffic` removed and restored (so R6a does not change it). Method, so the next session compares like with like: PathfindingService, `AgentRadius 2, AgentHeight 5, AgentCanJump true`, from `workspace.SpawnLocation.Position + (0,3,0)` to `Site02_Market.Guide:GetPivot().Position`, 110 waypoints, cap 506. 050 recorded 426.44; **the cause of the 3.2 difference is not established** (not R6a; possibly different endpoints in that session).
- **Shots** (each view twice with a wait; none blank), in `scratch\site02\shots\`: `r6a_1_north_band_take1.jpg` / `take2`, `r6a_2_south_band_take1.jpg` / `take2`. Camera rows are in shot-kit. Pair them with `scratch\site02\crops\iso_northyard.png`, `iso_shedsA.png` (both BP1 crops) and `bp2_iso_whole.png`.

## Line-up table
| Element | Result |
|---|---|
| North band kerb jeepneys | MATCH with BP1 `iso_northyard` (about six in a row along the kerb) |
| South band kerb vehicles | DIFF: BP1 `iso_shedsA` draws two spaced jeepneys; ours has 6 jeepneys, 4 tricycles, 6 motorbikes (counts approved in 050) |
| Utility poles and wires | DIFF: the blueprints draw only thin posts, no utility poles or wires; the owner asked for them. Wires are straight, no sag |
| Motorbikes | DIFF: not drawn in either blueprint (owner request) |
| Street name, lane lines | DIFF: none (text needs approval) |

## Review notes (things I corrected during this stretch)
- I first called the south band a MATCH and named `iso_shedsA` as BP2 and before opening it; it is a BP1 crop and shows only two jeepneys. Fixed in the brief and shot-kit.
- The brief said BP1 shows "a utility pole with a wire"; that was my wording and unsourced. Fixed. I also removed the mapping of drawing labels to real streets (labels on the drawings are not facts).
- A line in the brief still names E. Mayo and P. Torres: it is old R5e text from `e688e9e`, left alone.

## Backups
- `slice-36-wip19.rbxl` (636,828 bytes, SHA-256 `2D8B95A8A3889D327197B8A06114D8D83D1A4E2963B48D87B9D834E2429359A1`) holds the state BEFORE R6a.
- **`wip18` on disk does not match 050:** measured 636,331 bytes, SHA-256 `38D6DA57F857638EEAE01A13BE2F3D73D8C933CAE9FD798475CA5E18A4411147`; 050 recorded 635,019 bytes / `FF11D015...298AC`. The owner does not know why; treat the measured value as the real one.
- **R6a and the cap raise exist only in the open Studio session until the owner does Save As `slice-36-wip20.rbxl`** (never Ctrl+S; Studio holds a `.lock`). Studio is green at HEAD now (run_all ok=true), so save it as is. Then hash it (`Get-FileHash -Algorithm SHA256`). **Owed `docs/baseline.md` rows (owner-only): wip17, wip18, wip19, wip20.**

## R6b plan (approved in 050, NOT started; unchanged except the keep-clear list)
`env.addRig(rig, folderName)` gains an optional folder (default `VendorNPCs`, ownership checked for the folder passed); new TREE folder `Crowd` and `builders/site02_crowd.luau` (pattern of `site02_props.luau:201-217`, R15, Animate removed, HRP anchored); 12 figures `Shopper%d` (192 site parts, none own); clusters at both stair feet and in the yard aisles per BP2. Keep clear: Guide z 155..165, wide x -250..-229 z 148..172, band z 140..180, InfoPanel x -247..-235 z 142..154, Road F mouth, **plus the new band rows (north z -4.5..11.1, south z 311.9..324.5) and pole axes (z 14.5 and 308.5)**; 0.5 clear of every vehicle; `VendorNPCs` stays 6..9. Cap math: site 2322 + 192 = 2514 of 2550 (36 spare), own 2134 of 2200. Re-measure the walk with the method above (Edit and Play, cap 506; stop and ask if over). Tests first and shown red.
**Then:** Lomi King (board `..\2nd Reference\lomi house\3d blue print]\Lomi King Architectural Blueprint Board.png`, folder name really ends in `]`; walk 690.81 against cap 805, re-measure), the Standard tier (Carmel, Outlets, Farm, Malarayat), the Light tier (Tagbakin, Cafe): each its own plan, wait for approval, ask the terrain scope per site.

## Notes
- The older notes still apply (050, 049): spawn-and-poll for `run_all` and long calls, `shared.site02_only = "<group>"` for a group, CRLF shot-kit edited with PowerShell, `git commit -F` with a message file, terrain checked with `ReadVoxels` (rays mislead on 0.5 tops; here the ray read 0.00 and agreed).
- Advisor consulted three times (before the plan, before the build, before the feat commit); it caught the pole-name contradiction, the ground probe, the `routes_check`/walk need, and the wrong BP label.
- Commits carry no trailer: the owner's CLAUDE.md overrides the system reminder (which changed its wording three times). `scratch/` is git-ignored.

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `cdaea0a2-08e9-4a54-a8d7-cc16cbc2d3fb`), Edit mode, hash `site02_bands` 7940/138/3370195152 and `run_all` 20002/117/2360878440 in Studio, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows the newest `docs(handoff)` commit on top of `22765ce`; origin `095f6de` (about 75 local commits, count with `git rev-list --count 095f6de..HEAD`; not pushed, ask before pushing). Confirm `slice-36-wip20.rbxl` exists in `backups\`; if not, ask for it.
2. R6b, then the Lomi King plan and the tier plans, as above.
Each job: tests first and shown red, one briefed Sonnet agent (never git, no screenshots), builder run twice identical, groups green, `run_all` red only on the predicted rows, EXPECTED only with the owner's explicit OK, shots beside BOTH blueprints twice, the owner's look before the feat commit, commit test then feat, no trailer.

## Commits (local, no trailer, nothing pushed)
`afa0bd0` test(site02): require band traffic, poles and wires
`72eba37` feat(site02): add band traffic, utility poles and wires
`22765ce` test(run_all): expect the band traffic
(plus the commit that adds this file)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/051-handoff.md and then 050 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows. git status clean; git log shows the newest docs(handoff) commit on top of 22765ce; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Confirm slice-36-wip20.rbxl exists in backups (I save it; never Ctrl+S); ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, each shot taken twice, then my look at the pictures BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue and any on-screen text ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport.
Job: build R6b from handoff 051 (12 more crowd figures, tests first, keep clear of the new band rows and poles, re-measure the walk). After that plan Lomi King (walk under 805, re-measure) and the Standard and Light tiers, and wait for my approval of each plan. End each stretch with the next handoff and remind me to save a backup.
```
