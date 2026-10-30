# Handoff 047: street traffic built (R5e), EXPECTED updated, run_all reads ok=true; the street frontage plan is next
Previous: 046-handoff.md (then 045 to 029 for the environment and rules). This file only records what changed after 046.
**046's resume expectation went stale.** It says "expect ok=true" with HEAD on `78cdf5c`. After `8f5f452` (the red R5e tests) the real baseline was `ok=false` with one mismatch (`site02_check failed 3`). That is now resolved: the baseline today is `ok=true`, 0 mismatches, 89 rows.

## Owner decisions since 046 (2026-10-30)
- Street traffic: 8 tricycles, 24 motorbikes, 3 jeepneys (160 parts), the fuller option. Limits raised by the owner: own-part guard 1800 to 2000, site cap 2000 to 2100.
- At the look: **keep** the two double-parked apron jeepneys (`StreetJeepney1` z 66.5, `StreetJeepney2` z 236.5, x -243.5). **No roof lettering** (BP1's section names stay a recorded DIFF). **Plan the street frontage next** (a plan only; nothing is built until the owner approves it).
- `EXPECTED` edit approved: `site02_check` 151, `build[2]` {15, 2082}, `worldParts` 10174, with the own-count correction.

## Status
- Done and committed (local, no trailer, nothing pushed): `8d111b9` feat(site02) street traffic, `ee6a905` test(run_all). `run_all` reads **ok=true, 0 mismatches, 89 rows**; the negative control `run_all({ override = { site02_check = 148 } })` goes red on exactly `site02_check passed 151 (expected 148)`; the plain re-run is ok=true again.
- Pending: the street frontage plan (job 1 below), Lomi King, the Standard tier (Carmel, Outlets, Farm, Malarayat), the Light tier (Tagbakin, Cafe). Owed by the owner: a new backup (see Backups) and a `docs/baseline.md` row (owner-only file; last entry `slice-28`).

## What changed (hashes: bytes / newlines / djb2, disk equals Studio)
- `builders/site02_traffic.luau` 6699/108/2841443412 (LF, new): owns `Yard`, budget 165, 160 parts. `StreetTricycle1..8` (5 parts, Kind Tricycle), `Motorbike1..24` (4 parts, Kind Motorbike, 8 body colours cycled, dark seats), `StreetJeepney1..3` (8 parts, Kind Jeepney). Data tables `TRI`, `MB`, `JEEP` hold the 35 rows (x, z, y0, nose N/S/E/W).
- `builders/site02.luau` 14949/290/467268913: `MODULES` row `site02_traffic`, header table row, `SITE_CAP` 2000 to 2100, the two comments updated.
- `tests/run_all.luau` 17613/117/3103635170 (LF): three numbers with sourced reasons, and the old own-count note corrected.
- `briefs/site02.md`: the R5e built entry appended (positions, measures, correction, honest DIFFs).
- `tests/site02_check.luau` is unchanged since `8f5f452`: 91939/1298/463718247.

## Evidence (run by me)
- Counts: own parts (rigs excluded, the check's own count) 1734 to **1894** (guard 2000); site 1922 to **2082** (cap 2100); `Yard` 129 to **289** (cap 400); traffic module 160. Coordinator run twice with identical counts (by the agent; I re-counted 35 models, 160 parts).
- **Correction:** 046 and `briefs/site02.md` row 333 say own parts 1794 and "about 1954". Those were site totals less 128 vendor rig parts and missed the Guide and shopper rigs. The right figures are 1734 and 1894. The brief and `EXPECTED` now say so.
- Groups: hall 46/0, sheds 17/0, yard 31/0, general 34/0, block 27/0; `sites_check` 277/0; `routes_check` 16/0 in Edit and in Play.
- Walks (PathfindingService, radius 2, height 5, no jump): spawn to Market Guide **428.70** (cap 506) in Edit and in Play, identical across two runs. It was 440.58 before the traffic; I did not establish why it got shorter (`routes_check` notes the mesh is rebuilt on every Studio open). Lomi 690.81 (cap 805), Cafe 493.81 (cap 700), Ate Joy 9.00 (cap 40) are unchanged from 046 and were not re-measured.
- Overlap: 0 hits at 0.5 stud (rotation-aware), nearest part 0.9 (jeepney 3 to a side-stall pole), smallest gap between new vehicles 0.8. Nothing stands in the apron band z 140..180; the stair feet and hall doors are clear. The queue-end slot at z 178.5 does not fit (inside the band), so only z 94 was used.
- Shots I looked at (7, one at a time): north kerb, apron queues, north stair foot, south yard, jeepney 2 and hall door 8, top-down north yard, apron and south yard. I judged them against the crops from memory, not paired side by side; offer the pairing if the owner wants it.

## Line-up table (BP1 `iso_northyard`, `iso_stairN`, BP2 `bp2_iso_vendors_tricycles` / model)
| Element | Result |
|---|---|
| North yard kerb: booths, vans, tricycles | MATCH in look |
| Apron queues of tricycles with motorbikes | MATCH in look; the motorbikes read as dots from far away |
| Stair foot: jeepneys and tricycles nose to tail | MATCH |
| Second jeepney row in the forecourt (jeepneys 1 and 2) | MATCH in look; owner kept it |
| South yard | DIFF: the vehicles sit in the far west, the east half is open concrete |
| Motorbikes | DIFF: not drawn in BP1 or BP2 (creative, at the owner's request) |
| Vehicle forms, count, movement | DIFF: boxy, no lettering; more vehicles than BP2; all parked |
| Street frontage | DIFF, the next job: tall grass meets the paving edge where the blueprints draw E. Mayo St. and P. Torres St. with traffic |

## Notes for later jobs
- **No part headroom left:** site 2082 of 2100. Any crowd of figures or extra booths needs another owner-authorised cap raise.
- **Street plan constraints (from the advisor and this session):**
  - The east kerb is pinned by existing assertions. `roads_check` section 6a has Grass controls just outside the slot, including beside Road F. `world_check` (disk only) has Grass at (-224, 170) and Asphalt at (-224, 160). `site02_check` has a margin rule: the Market's bounds +10% must stay clear of every `NEW_ROADS` body, so a street added to `RoadData.NEW_ROADS` probably trips it, while a plain terrain repaint in `roads_extra` probably does not (verify).
  - Changing any of them needs the owner's explicit OK and a logged reason. `run_all` will move (terrain cells 1796660, probably the `roads_check` count): `EXPECTED` needs the owner's OK again.
  - Never run `builders/world.luau`; the repaint belongs in `builders/roads_extra.luau`.
  - The blueprints name the streets differently: BP1 has P. Torres St. and E. Mayo St.; BP2 adds Malabanan St. and C.B. Lopez St. on other sides. Settle which side is which from the drawings. Any street sign is text and needs approval and a source.
- BP1's roof lettering (DRY GOODS SECTION, WET MARKET AREA, FISH & MEAT) stays out by the owner's decision.
- The older notes still apply: measure walking caps in Edit and Play; Git Bash `grep -c $'\r'` is unreliable (use a PowerShell regex); `run_all` runs `routes_check` in Edit.
- Agents this stretch: one Sonnet agent in two phases (probe and propose, then build and check), 160k + 196k tokens, it stayed off git and screenshots.
- Shot-kit: three rows added (jeepney 2 and door 8, apron top-down, south yard top-down).

## Backups
`slice-36-wip15.rbxl` (630,525 bytes, saved 09:26) holds the red tests but NOT the street traffic, the two builder edits or the `EXPECTED` update. Everything since exists only in the open Studio session. **Ask the owner for Save As `slice-36-wip16.rbxl` (never Ctrl+S; Studio holds a `.lock`), then give them its SHA-256 (`Get-FileHash -Algorithm SHA256`) for their `docs/baseline.md` row.**

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `033919da-405f-4cdb-a780-48d072381070`), Edit mode, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows this handoff commit on top of `ee6a905`; origin `095f6de` (about 58 local commits ahead, count with `git rev-list --count 095f6de..HEAD`; not pushed, ask before pushing). Check that `slice-36-wip16.rbxl` exists; if not, ask for it.
2. Job 1: write a PLAN for the street frontage (read-only first: the constraints above, the blueprints, the terrain under x -228 eastward). Get the owner's approval before any build or any assertion change.
3. Then Lomi King (walk 690.81 against 805; re-measure after its rebuild), the Standard and Light tiers, repainting the terrain under each footprint (ask the owner the scope per site).
Each job: tests first and shown red, one briefed Sonnet agent (never git; no screenshots for the agent), coordinator twice identical, groups green, `run_all` stays ok=true or its changed numbers go into EXPECTED with a reason, shots beside BOTH crops, the owner's look before the feat commit, commit test then feat, no trailer.

## Commits (local, no trailer, nothing pushed)
`8f5f452` test(site02): require the street tricycles, motorbikes and jeepneys
`8d111b9` feat(site02): add street tricycles, motorbikes and jeepneys
`ee6a905` test(run_all): expect the street traffic
(plus the commit that adds this file and the shot-kit rows)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/047-handoff.md and then 046 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows. git status clean; git log shows the 047 handoff commit on top of ee6a905; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Check that slice-36-wip16.rbxl exists; if not, ask me to Save As it (never Ctrl+S); ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, then my look BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport.
Job: plan the street frontage along the Market (tall grass meets the paving edge where the blueprints draw E. Mayo St. and P. Torres St.): a plan only, using the constraints in 047, and wait for my approval; then Lomi King (walk under 805, re-measure), the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe). The part cap is spent (2082 of 2100). End each stretch with the next handoff and remind me to save a backup.
```
