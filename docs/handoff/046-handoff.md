# Handoff 046: Play walks measured, Market walking cap tightened, EXPECTED updated so run_all reads ok=true; the owner's side-by-side look is pending
Previous: 045-handoff.md (then 044 to 029 for the environment and rules). This file only records what changed after 045.
**This file REPLACES 045's resume expectation.** 045 and its continuation prompt say to expect `ok=false` with six mismatch lines. That is no longer true: the baseline is now `ok=true`, 0 mismatches, 89 rows. Do not stop and report `ok=true` as a mismatch.

## Owner decisions since 045
- I may edit `tests/run_all.luau` (owner-only) for this one change, with a sourced reason on every number (answered "You apply it (explicit OK)" in AskUserQuestion). Done, shown as a diff before the commit.
- Market walking cap: the owner answered "adjust as much as needed to tailor the new changes and upcoming changes maybe?". I read that as: set the Market cap to measured +15% (the owner rule of 2026-10-27) and leave Lomi (805) and Cafe (700) until their own rebuilds re-measure them. This reading was flagged in the plan and not contradicted; correct it if wrong.
- Backups: `slice-36-wip14.rbxl` (628,778 bytes, byte-identical to wip13, SHA-256 3D65CA33...3C99) holds the roofs and the look-at line but NOT the cap and EXPECTED edits below (those exist in Studio only). Studio holds a `.lock` on wip14: a plain Ctrl+S overwrites it. Ask for Save As `slice-36-wip15.rbxl` first thing.

## Status
- Done and committed (local, no trailer, nothing pushed): Play walks measured, `SHOP_CAP[2]` 700 to 506, `EXPECTED` updated (six numbers with reasons), shot-kit rows. `run_all` reads **ok=true, 0 mismatches, 89 rows**.
- Pending: the owner's own side-by-side look (shots below), the owner's `docs/baseline.md` row (owner-only file, last entry is `slice-28`, 2026-10-27; a verified ok=true backup is exactly when a row is due: offer the SHA-256 of wip15 once saved), Lomi King, the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe). Booth variety and vendor poses stay deferred polish (zero-part work).

## What changed
- `tests/routes_check.luau` 7403/102/1909353886 (LF): `SHOP_CAP = { [2] = 506, [3] = 805, [4] = 700 }` with a comment (measured 440.58 on 2026-10-30, the same in Edit and in Play, was 461.53 in handoff 036; 506 is that plus 15 percent, rounded down).
- `tests/run_all.luau` 17001/117/1122641625 (LF): `site02_check` 45 to 148, `roads_check` 267 to 270 (+3 section 6a Market ground), `unitRun` 246 to 250, `build[2]` {15, 1148} to {15, 1922} (moved onto its own line to carry its reason), `worldParts` 9240 to 10014, `cells` 1794962 to 1796660 (Market concrete repaint, 7308 surface voxels, second run adds 0, cause of the count rise not established). Each with a sourced reason comment.
- `docs/shot-kit.md` (CRLF, edited with a PowerShell line insert): three Market rows (north booths close, south booth row, north booth row top-down) and the old north-yard iso row marked "too wide to judge booths: use the close row".

## Evidence (run by me)
- Disk equals Studio for `routes_check` and `run_all` (hashes above).
- Red first for the cap: a throwaway clone of `routes_check` with the Market cap at 300 fails in Play ("spawn -> Market Guide is walkable ... in at most 300 studs | 441 studs", 15 passed 1 failed); the real cap passes. Red first for EXPECTED: the six mismatch lines before the edit; after it `ok=true`, and the negative control `run_all({ override = { site02_check = 147 } })` goes red on exactly that line.
- Walks (PathfindingService, radius 2, height 5, no jump; identical in Edit and in Play): spawn to Market Guide 440.58 (cap 506), Lomi 690.81 (cap 805), Cafe 493.81 (cap 700), Ate Joy 9.00 (cap 40). `routes_check` 16/0 in Play and in Edit.
- `world_check` (disk only, not in Studio and not in `run_all`; a Sonnet agent pasted it into `execute_luau`, comments stripped): 44 passed / 2 failed, exactly the two known reds from 036 (plaza control cell (50,102) is Pavement, expected Grass; cell (160,-122) is Asphalt, expected Grass). Not ours; do not fix them under this branch's jobs.
- The new look-at line's claims, checked against the model (the tests only pin the string): the main arch row (14 `ArchWindow`, frames y 20.8 to 26.4) is the top storey, above the middle storey windows (y 12.5 to 16.7) and the rectangular ground bays (y 0.1 to 9.0); both stairs climb toward the middle: north stair foot z 91.5 up to its landing at z 145.6 to 148, south stair foot z 228.5 up to its landing at z 172.0 to 174.4, the middle being z 160.
- Shots I looked at: north stair foot (-205,28,70) to (-236,3,105), street front (-190,26,175) to (-240,4,130), and the earlier roof shots (close booths, south row, north top-down).

## Line-up table (BP1 `iso_stairN`, `iso_northyard`, `iso_shedsA`, BP2 `bp2_iso_vendors_tricycles` / model)
| Element | Result |
|---|---|
| Three-storey arcade with arched upper windows, stair along the front | MATCH in look |
| Jeepneys nose to tail along the kerb, tricycle queue of coloured boxes | MATCH in look |
| Pyramid-roofed booths in rows with a vendor under each | MATCH |
| Street frontage | DIFF, a scope question for the owner: both shots show tall grass up to the kerb where the blueprints draw E. Mayo St. and P. Torres St. That ground is outside the slot; listed, not fixed |
| Look-at line claims (top-floor arches, two stairs climb toward the middle) | MATCH, checked against the model (Evidence) |
| Roof colours (pinwheel A and A2), pitch about 24 degrees unverified, no eave fringe, all 21 booths one shape | DIFF, open (see 045) |
Older DIFFs from 040 to 045 are still open. The owner's look at the shots is PENDING.

## Notes for later jobs
- **Market cap 506 vs a route of 440.58:** a later site build that lengthens the spawn-to-Market route turns `routes_check` red. The fix is to re-measure in Play and Edit with the owner's OK under the +15% rule, never to raise the cap quietly.
- `run_all` runs `routes_check` in Edit mode (the pathfinding mesh is rebuilt on every open), so measure caps in both modes and base them on the larger.
- Git Bash `grep -c $'\r'` is unreliable here (it counted every line). Count CRLF with a PowerShell regex: `[regex]::Matches($t, "`r`n")`. Real endings: `run_all.luau`, `routes_check.luau`, `briefs/site02.md` (mostly), `TourContent.luau`, `content/*.md`, tests are LF; `SiteData.luau`, `docs/shot-kit.md` are CRLF.
- Agents this stretch: one read-only Sonnet agent for `world_check` (75k tokens, 5 calls; it stayed read-only). Entering Play while an agent uses `execute_luau` would switch the datamodel under it: wait for the agent first.
- Advisor consulted once before the handoff (it asked for this resume-expectation fix, the backup request, the grass-frontage row, the look-at claim check and the shot-kit rows).

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `033919da-405f-4cdb-a780-48d072381070`), Edit mode, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows this handoff commit on top of `78cdf5c`; origin `095f6de` (about 55 local commits ahead, not pushed; ask before pushing). Confirm `slice-36-wip14.rbxl` exists and ask for Save As `slice-36-wip15.rbxl`.
2. The owner's side-by-side look (the shot-kit rows above, one capture at a time); record their answer, including the grass frontage scope question.
3. Lomi King (spawn-to-Lomi walk 690.81 against 805; re-measure after its rebuild), then the Standard and Light tiers, repainting the terrain under each footprint (ask the owner the scope per site). Optional: booth variety and vendor poses.
Each job: tests first and shown red, one briefed Sonnet agent (never git; no screenshots for the agent), coordinator twice identical, groups green, `run_all` stays ok=true or its changed numbers go into EXPECTED with a reason, shots beside BOTH crops, the owner's look before the feat commit, commit test then feat, no trailer.

## Commits (local, no trailer, nothing pushed, origin `095f6de`; count with `git rev-list --count 095f6de..HEAD`)
`134e3d6` test(routes): tighten the Market walking cap to the measured length
`78cdf5c` test(run_all): expect the Market rebuilt from the blueprint
(plus the commit that adds this file and the shot-kit rows)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/046-handoff.md and then 045 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows (046 REPLACES the six-mismatch expectation of 045). git status clean; git log shows the 046 handoff commit on top of 78cdf5c; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Confirm slice-36-wip14.rbxl exists and ask me to Save As slice-36-wip15.rbxl (never Ctrl+S) before the next rebuild; ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, then my look BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport.
Job: show me the side-by-side look and record my answer (including the grass frontage scope question); then Lomi King (walk under 805, re-measure), the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe), repainting the terrain under each footprint (ask me the scope per site). Booth variety and vendor poses are deferred zero-part polish I can ask for any time. End each stretch with the next handoff and remind me to save a backup.
```
