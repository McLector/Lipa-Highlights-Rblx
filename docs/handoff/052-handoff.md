# Handoff 052: R6b (11 crowd figures) is BUILT and committed; Lomi King and the tier plans are NOT started
Previous: 051-handoff.md (then 050 to 036 for the environment and rules). This file only records what changed after 051.
Baseline now: `run_all` reads **ok=true, 89 rows, 0 mismatches**; HEAD is the commit that adds this file, on top of `e031632`; 80 commits ahead of origin `095f6de` (count with `git rev-list --count 095f6de..HEAD`; nothing pushed, ask before pushing).

## Owner decisions and approvals since 051 (2026-10-30)
- Saved `slice-36-wip20.rbxl` (643,375 bytes, SHA-256 `22CE26668D99FE188B4DCF33F86333119587FF490F95A1F00F3C11BF236E7B4D`): the state after R6a, before R6b.
- The R6a EXPECTED edit (`22765ce`): **"Yes, confirmed"** (plain). The open note in 051 is closed.
- **Crowd size: 11, not 12.** The build showed BuildCheck's per-site cap of 2500 (see "Cap" below). The owner chose "11 figures" over raising the shared cap.
- R6b look: **"Commit as built"**, after my honest MATCH/DIFF table and 8 pictures (below).
- **EXPECTED for R6b (`e031632`): the answer was conditional, not a plain yes**: "if not necessary we may skip but if it is necessary according to overall plan go". I judged it necessary (run_all is the README's session-start gate and would stay red on exactly three rows) and said so in the commit body, which calls it an interpretation. **Ask the owner a plain yes/no first thing next session**; if no, revert `e031632` (run_all then goes red on exactly `site02_check` 184, build 02 parts 2498, `worldParts` 10590).

## Cap (read this: it corrects 050, 051 and my own plan)
- **The real per-site ceiling is BuildCheck's `SITE_PART_BUDGET = 2500`** (`src/ServerStorage/BuildCheck.luau:11`, pinned by `tests/BuildCheck_Test.luau`, repeated as `PART_BUDGET = 2500` in every builder). The R6a raise of the Market's own `SITE_CAP` and `CAP.total` to 2550 can never be reached: BuildCheck fails first. My R6b plan counted only 2550 ("36 spare") and missed this; the first build (12 figures, 2514 parts) turned `build 02` red on `part budget <= 2500`.
- **The Market is at 2498, 2 parts spare.** Any more Market parts (booth goods, eave fringe, more figures) need an owner decision first.
- **Open owner question: tighten `SITE_CAP`/`CAP.total` back from 2550 to 2500** so the numbers stop misleading? Not changed.

## What changed (hashes: bytes / newlines / djb2, disk equals Studio)
- `builders/site02_crowd.luau` 4153/58/919940246 (new, LF): 11 R15 rigs `Shopper1..Shopper11` (16 parts each, 176 in all; vendor recipe, no Accessory, Animate removed, HRP anchored, DisplayDistanceType None, SiteId 2), data table `SHOPPERS` { x, z, y0, facing }. Positions (x, z): north foot (-246.5, 82), (-245, 87), (-247, 98), (-245, 103) as two facing pairs; south foot (-248, 220), (-246, 225) a pair and (-248, 214) one beside it; north yard (-411, 46), (-370, 46) facing the booths; south yard aisle (-420, 252), (-335, 251) facing the shed-row booths. Apron figures y0 0.3, yard figures y0 0. Snaps from my targets: Shopper1 x -247 to -246.5 (LeanPost8), the south pair moved off z 232..237 (jeepney SJ2 and LampPost5 fill the apron there), the yard figure x -415 to -411 (kerb tricycle STri6).
- `builders/site02.luau` 15764/297/2527473549: `env.addRig(rig, folderName)` (optional, default `VendorNPCs`, ownership checked for the folder passed), `TREE` row `Crowd`, `MODULES` row `site02_crowd` (budget 0, rigs sit outside the module budget and the 400-part rule), header comments.
- `tests/site02_check.luau` 117960/1749/3515809567: new group `crowd` (16 checks) and `Crowd` in the `general` direct-child list (1 check). Only crowd-group lines were touched after the first commit (12 to 11, 192 to 176, 23 to 22).
- `tests/run_all.luau` 20864/117/3856229561: `site02_check` 184, `build 02` { 15, 2498 }, `worldParts` 10590, each with a reason (owner-only file; see the conditional answer above).
- `briefs/site02.md` (R6b entry with MATCH/DIFF; LF), `docs/shot-kit.md` (CRLF, two Market rows).

## Evidence (run by me, not taken from the agents' words)
- **Red first:** `crowd` 1 passed / 16 failed (the one pass is the standing "Site02_Market exists"), committed `6e863c4`. Then, after the cap finding, the same checks changed to 11 and shown red against the 12-figure build (1/16 again), committed `4a8adc6`.
- **Build:** coordinator by the agent twice and by me once, identical: parts 2498, builtParts 2437, rigParts 304, keptParts 61. Groups crowd 17/0, general 35/0, yard 31/0, bands 17/0, hall 46/0, sheds 17/0, block 27/0 (mine). BuildCheck 02: 15 passed, 0 failed, parts 2498. The first 12-figure build also passed every group (parts 2514, rigParts 320).
- **Negative controls (on the 12-figure build, same checks except the counts):** a figure moved into the Guide box went red on keep-clear and on spacing; a figure on top of another, on spacing; a figure on a kerb tricycle, on "clear of every built part"; a figure at x -224 (the street), on "east of x -229" and on grounded. Restored: 17/0. **Not re-run on the 11-figure build.**
- **`run_all`:** after the 11-figure build exactly three mismatches (`site02_check` 184, build 02 parts 2498, `worldParts` 10590); after `e031632`, ok=true, 89 rows; override `site02_check = 167` goes red on exactly `site02_check passed: got 184, expected 167`.
- **Walk 429.63 (110 waypoints), same method as 051** (PathfindingService, `AgentRadius 2, AgentHeight 5, AgentCanJump true`, from `SpawnLocation + (0,3,0)` to the Guide pivot): in **Edit** with `Crowd` in place, with it detached and restored (all three identical, so R6b does not change it); in **Play with `Crowd` in place only** (Play was NOT run with the crowd removed). Cap 506. `routes_check` 16/0 in Edit and in Play. (The earlier 12-figure build measured the same.)
- **Shots** (each view twice with a wait; all eight lit; in `scratch\site02\shots\`): `r6b_1_north_foot_take1/2.jpg` (-205,28,70 to -236,3,105), `r6b_2_south_foot_take1/2.jpg` (-205,28,262 to -236,3,215), `r6b_3_south_yard_take1/2.jpg` (-300,40,310 to -400,4,255), `r6b_4_north_close_take1/2.jpg` (-228,10,112 to -246,3.5,90). Compared with BP1 `iso_stairN`, `iso_shedsA` and BP2 `bp2_iso_vendors_tricycles`, `bp2_iso_whole` (viewed this session).
  **Gap:** the plan also listed a north-booths close view beside `iso_northyard.png`; it was replaced by the stair-foot close-up, so **the two north-yard figures (Shopper8 at (-411, 46), Shopper9 at (-370, 46)) are in no shot** and the "single figures in the yard aisles" claim rests on the south yard only. Offer the owner those shots first thing, and `iso_northyard.png` was not opened this session.

## Line-up table
| Element | Result |
|---|---|
| Figures at both stair feet beside the tricycle queue and jeepneys, in facing pairs | MATCH in look (BP1 `iso_stairN`, BP2 `bp2_iso_vendors_tricycles`) |
| Single figures in the south yard aisle | MATCH in look (BP1 `iso_shedsA`) |
| North yard figures | not shot (see the gap above) |
| Number of figures | DIFF: 11 against BP2's 20+ at the front alone; the second south-foot pair is one figure short because of the cap |
| Street and zebra crossings | DIFF: BP2 draws figures there; the site's real-bounds rule forbids parts east of x -229, so none |
| Poses and props | DIFF: all static, default pose, no props; they read small from far away |

## Backups
- `slice-36-wip20.rbxl` holds the state BEFORE R6b. **The `.lock` is on wip20, though Studio's title may still read wip18: a plain Ctrl+S would overwrite the pre-R6b backup.**
- **R6b (the crowd, the builders, the `run_all` edit) exists only in the open Studio session until the owner does Save As `slice-36-wip21.rbxl`** (never Ctrl+S). Studio is green at HEAD (run_all ok=true). Then hash it (`Get-FileHash -Algorithm SHA256`).
- **Owed `docs/baseline.md` rows (owner-only): wip17, wip18, wip19, wip20 (hash above), wip21.** The wip18 hash on disk (636,331 bytes, `38D6DA57...1147`) differs from 050's note; treat the measured one as real.

## Notes
- Agents: tests 93k tokens, first build 99k, tests 12 to 11 69k, builder 12 to 11 64k; none used git or screenshots; all four reports matched my re-checks (hashes, groups, coordinator).
- Method notes still apply: spawn-and-poll for `run_all`, the coordinator and the walk; `shared.site02_only = "<group>"` for one group; CRLF shot-kit edited with PowerShell; `git commit -F` with a message file; start Play only after no agent is using `execute_luau`.
- `AskUserQuestion` answers can be conditional; ask for a plain yes/no on EXPECTED and say before and after values.
- Commits carry no trailer (the owner's CLAUDE.md overrides the system reminder, which asked for one). `scratch/` is git-ignored.
- Advisor consulted twice (before the plan: it asked for the figure-side keep-clear tests, the free-space probe, the BP1 crops and the walk isolation; before declaring done: the cap framing, the two gaps above). The plan and the Lomi King / tier plans were NOT written because the session was at its handoff point.

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `cdaea0a2-08e9-4a54-a8d7-cc16cbc2d3fb`), Edit mode, hash `site02_crowd` 4153/58/919940246 and `run_all` 20864/117/3856229561 in Studio, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows the newest `docs(handoff)` commit on top of `e031632`; origin `095f6de`. Confirm `slice-36-wip21.rbxl` exists in `backups\`; if not, ask for it.
2. Ask the owner: the plain yes/no on the `e031632` EXPECTED edit; whether to tighten `SITE_CAP`/`CAP.total` 2550 to 2500; and offer the north-yard shots beside `iso_northyard.png` (camera -418,15,34 to -445,6,54 is in the shot-kit as the north booths close row).
3. Plan Lomi King (board `..\2nd Reference\lomi house\3d blue print]\Lomi King Architectural Blueprint Board.png`, folder name really ends in `]`; walk 690.81 against cap 805, re-measure after any change; existing `builders/site03.luau` 21.7 KB, `tests/site03_check.luau`, `briefs/site03.md`; BuildCheck cap 2500 applies), then plan the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe): each its own plan, wait for approval, ask the terrain scope per site. Read the blueprint first, shoot beside it.
Each job: tests first and shown red, one briefed Sonnet agent (never git, no screenshots), builder run twice identical, groups green, `run_all` red only on the predicted rows, EXPECTED only with the owner's explicit OK, shots beside BOTH blueprints twice, the owner's look before the feat commit, commit test then feat, no trailer. Check BuildCheck's 2500 per-site cap in the plan this time.

## Commits (local, no trailer, nothing pushed)
`6e863c4` test(site02): require the market crowd
`4a8adc6` test(site02): cap the market crowd at 11 figures
`cea9376` feat(site02): add the market crowd
`e031632` test(run_all): expect the market crowd
(plus the commit that adds this file and corrects one walk sentence in the brief)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/052-handoff.md and then 051 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows. git status clean; git log shows the newest docs(handoff) commit on top of e031632; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Confirm slice-36-wip21.rbxl exists in backups (I save it; never Ctrl+S); ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, each shot taken twice, then my look at the pictures BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue and any on-screen text ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time, ask a plain yes/no with before and after values); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport. BuildCheck caps every site at 2500 parts: count against it in every plan.
Job: first ask me the plain yes/no on the e031632 EXPECTED edit, whether to tighten the Market SITE_CAP 2550 to 2500, and offer the north-yard crowd shots beside iso_northyard.png. Then plan Lomi King (walk under 805, re-measure) and the Standard and Light tiers, one plan each, and wait for my approval of each plan. End each stretch with the next handoff and remind me to save a backup.
```
