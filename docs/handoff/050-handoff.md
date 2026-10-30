# Handoff 050: the Market side roads are BUILT and committed (terrain only, zero parts); R6a (band traffic, poles, wires, cap raise) and R6b (crowd) are planned and approved but NOT started
Previous: 049-handoff.md (then 048 to 036 for the environment and rules). This file only records what changed after 049.
Baseline now: `run_all` reads **ok=true, 89 rows, 0 mismatches**; HEAD is the commit that adds this file, on top of `e8edef6`.

## Owner decisions and approvals since 049 (2026-10-30)
- The four front-street pictures: "do wat u think is best" (my call: white zebra bars, and finish the street ends).
- Side streets: "Yes, both". Poles: "Poles and wires". Crowd: "12 more". Cap raise: "do what u think is best and what must be" (my call: own guard 2000 to 2200, site cap 2100 to 2550, one raise for R6a and R6b together; NOT yet applied).
- **The south street was revised after a survey:** an Asphalt road already runs at z 344..356 (east of x -480; a N-S road also leaves it at x -480). The owner chose "Use the existing road": no new south street; the front street is extended to T into it and the grass strip z 328..344 became Concrete.
- Zebra bars: at the look the owner answered "I ll trust ur judgement": I kept Salt (no visible gain in the pictures, an honest DIFF, see below).
- `EXPECTED` (owner-only): asked explicitly ("May I set those two numbers?"), answered "do whats best". I read that as the OK for exactly `roads_check` 273 to 278 and `cells` 1796726 to 1796830, and said so in the commit and brief. Correct me if that was not meant.

## What changed (hashes: bytes / newlines / djb2, disk equals Studio)
- `builders/roads_extra.luau` 8201/132/2109945818 (LF): `SIDE_STREETS` (Asphalt x -576..-216, z -20..-8), `STREET_SOUTH` (Asphalt x -228..-216, z 328..344), `VERGE_SOUTH` (Grass/Pavement to Concrete, x -576..-228, z 328..344, two regions split at x -400), ZEBRA bars Salt; order verge, street, side street, extension, bars. Return gained `sideStreets`, `southVerge`.
- `tests/roads_check.luau` 41015/647/2620176729 (LF): 6d bars Salt and its end controls (-222,-24) and (-212,334); 6a controls (-400,-24) and (-300,360); new 6e with 5 checks. `tests/world_check.luau` (disk only): the same two controls moved.
- `tests/run_all.luau` 19155/117/4194379737 (LF): `roads_check` 278, `cells` 1796830, each with a sourced reason.
- `briefs/site02.md`: planned entry (old text, new text, reason for every replaced control) and built entry. `docs/shot-kit.md` (CRLF): three Market rows.

## Evidence (run by me)
- **Red first:** `roads_check` 274 passed / 4 failed (bars, north street, extension, verge). A first attempt that assumed a new south street at z 328..340 read 273/3 and exposed the existing road at (-222,344).
- **Build:** one Sonnet agent (75k tokens), stayed off git and screenshots. I re-hashed disk and Studio, read the full diff, re-ran `roads_check`: **278/0**. `CountCells` 1796726 to 1796830 (+104) on run 1, run 2 adds 0.
- **Other checks:** `world_check` 43/3 with the old controls (the extra red was exactly the two moved controls; run by a read-only Sonnet agent, 76k tokens), the two known reds unchanged ((50,102) Pavement and (160,-122) Asphalt). After moving its two controls (`020e58a`) I re-ran `world_check` (read-only Sonnet agent): **44/2**, exactly the two known reds, so the moved controls pass. `routes_check` 16/0 in Edit and in Play. Spawn to Market Guide **426.44** in Edit and in Play (my ad hoc PathfindingService measure, radius 2, height 5; cap 506; it differs a little from the 422.86 `routes_check` logs because the endpoints differ).
- **`run_all`:** before `EXPECTED` moved exactly two mismatches (`roads_check` 278 vs 273, cells 1796830 vs 1796726); after, ok=true, 89 rows; `override = { roads_check = 273 }` goes red on exactly `roads_check passed: got 278, expected 273`.
- **Shots** (each view taken once, the two corner views twice; none blank; one background capture timed out and was retaken): copies for the owner, git-ignored, in `scratch\site02\shots\`: `job1_1_north_crossing.jpg`, `job1_2_south_crossing.jpg`, `job1_3_south_crossing_topdown.jpg`, `job1_4_street_along_south_crossing.jpg`, `job1_5_north_corner_side_street.jpg`, `job1_6_south_corner_T_and_verge.jpg`.
  Not taken twice with a wait: the crossing views. The owner looked at the pictures AFTER my honest summary but before the feat commit.

## Line-up table (BP1 `iso_stairN`, `iso_northyard`, BP2 `bp2_iso_vendors_tricycles`, `bp2_iso_whole`)
| Element | Result |
|---|---|
| Front street meets a cross street at its south end | MATCH: T into the existing road, the Market ground flush with it |
| North side street | MATCH in layout; DIFF: reads about like the concrete from far away |
| Zebra bars | DIFF: Salt did not visibly improve them; the hall's shadow covers the street, the west bar blends with the Concrete beside it, grass blades half-hide the east bar |
| Lane lines, kerbs, street names | DIFF: none (parts east of x -228 forbidden, text needs approval) |
| West and north-west sides | DIFF: the existing south road ends at x -480, no street along the west side |

## Planned and approved, NOT built (the plan also lives in `~/.claude/plans/pasted-content-id-c6dd-continue-the-adaptive-badger.md`, outside the repo; this is the durable copy)
**R6a, band traffic, poles and wires, with the cap raise** (one Sonnet agent, tests first):
- Own-part guard 2000 to **2200** (`tests/site02_check.luau:1242`), `SITE_CAP` (`builders/site02.luau:57`) and the check's `CAP.total` (:73, :1245) 2100 to **2550**. Log it in the brief as an owner-authorised raise for R6a and R6b together. Own parts are 1894, site 2082 now.
- New module `builders/site02_bands.luau` owning a new TREE folder `BandTraffic` (budget about 250; a `MODULES` row in `site02.luau`, data tables in the style of `site02_traffic.luau`). Per band (north z -5..31, south z 271..325): a kerb row of 6 jeepneys or vans (8 parts), 4 tricycles (5), 6 motorbikes (4) = 92 parts a band (184); 12 poles, 6 a band (`UtilityPole` about 24 tall, `PoleArm`, `PoleLamp`, 3 parts each = 36); wires `PoleWire`, 2 per gap above 14 studs (5 gaps a band, 20 parts). Facing the side street: the north band faces the new north street (z -20..-8); the SOUTH band now faces a 16-stud Concrete verge and the existing road at z 344 (not a street against the edge).
- Keep clear of `STri3` (z 273.5) and `SJ3` (x -400, z 273.6) in the south band (z 270.9..276.3), the corner block and the Bagsakan truck lane.
- Names no current rule matches: `BandJeepney%d`, `BandTricycle%d`, `BandMotorbike%d`, parts like `BandTriBody`. NEVER `TricycleBody`, `ParkedVehicle`, `LampPost`, `LampHead` (`site02_check` :718-730 allows 6..8 lamp posts on the apron only). Grep every check for each name first.
- Tests first (red): counts per kind and band, everything in its band (x -576..-228) and on the ground, no overlaps at 0.5, 12 poles 20..28 tall, wires above 14, caps 2200 and 2550. Note `site02_check` :1203 keeps every non-rig part inside x -576..-228, z -5..325: poles and traffic must stay inside the slot (the verge and side streets are outside it).
- Expected `run_all` movement: `site02_check`, `build[2]`, `worldParts` only. Then shots (twice each) beside `iso_northyard.png` and `iso_shedsA.png`, your look, `EXPECTED` OK, commits `test(site02)`, `feat(site02)`, `test(run_all)`.
**R6b, the crowd** (after R6a): `env.addRig(rig, folderName)` gains an optional folder (default `VendorNPCs`, ownership checked for the folder passed); new TREE folder `Crowd` and `builders/site02_crowd.luau` (pattern of `site02_props.luau:201-217`, R15, Animate removed, HRP anchored); 12 figures `Shopper%d` (192 site parts, none own); BP2's clusters at both stair feet outside the keep-clear boxes (Guide z 155..165, wide x -250..-229 z 148..172, band z 140..180, InfoPanel x -247..-235 z 142..154, Road F mouth), and in the yard aisles; 0.5 clear of vehicles; `VendorNPCs` must stay 6..9. Re-measure the Market walk in Edit and Play (cap 506; stop and ask if over).
**Then:** Lomi King (board `..\2nd Reference\lomi house\3d blue print]\Lomi King Architectural Blueprint Board.png`, folder name really ends in `]`; existing `builders/site03.luau` 21.7 KB, `tests/site03_check.luau`, `briefs/site03.md`; walk 690.81 against cap 805, re-measure), the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe), each with its own approved plan, asking the terrain scope per site.

## Notes
- Terrain voxel facts learned: roads are FillBlock centre y -4, 4 thick, giving occupancy 0.5 in the voxel [-4,0) over Grass at 1.00 (surface y -2); terrain `Raycast` returns misleading materials on 0.5-occupancy tops (it reported Asphalt and Grass over Salt voxels), so check terrain with `ReadVoxels`, not rays. `ReadVoxels` returns (materials, occupancies).
- The hall's shadow covers the front street in every shot; the grass blades (Grass decoration) hide street edges at low angles and stream out at distance.
- The old notes still apply: measure walking caps in Edit and Play; Git Bash `grep -c $'\r'` is unreliable (use a PowerShell regex); `run_all` and long calls need spawn-and-poll; PowerShell 5.1 mangles `git commit -F -` from a here-string, so write the message to a file in the scratchpad and use `git commit -F <file>`; shot-kit is CRLF (edit with PowerShell), the brief is LF with 3 CRLF lines.
- Commits carry no trailer: the owner's CLAUDE.md overrides the system reminder.
- Advisor consulted twice: before the plan (it asked for the tier-budget and naming greps, the owner questions, the side-street question and the two-job split) and after Job 1 (it asked for the `world_check` re-run, this correction pass and the owner questions below). The R6 stretch itself is not done (R6a, R6b open).
- **The z 344..356 road is `E_to_Tagbakin`** (`builders/world.luau:19`, w 12, points (0,225), (0,350), (-480,350), (-480,526), (-548,526)): the Tagbakin route, not a leftover. `roads_check` 6e pins (-400,348) and (-222,348) as Asphalt, and the front street's T joins it. Do not remove it.
- **Open for the owner:** the `EXPECTED` edit (`e8edef6`, `roads_check` 278, `cells` 1796830) rests on "do whats best", not an explicit yes; if the owner says no, revert that commit and the run_all goes ok=false with exactly those two mismatches.

## Backups
`slice-36-wip18.rbxl` (635,019 bytes, SHA-256 `FF11D01564AB1AB67E158F1786F02F6750A47EB18E32D660521D164894E298AC`) holds the street but NOT this stretch's side roads, bars, `EXPECTED` and the world_check edit (those exist in the open Studio session). **Ask the owner to Save As `slice-36-wip19.rbxl` (never Ctrl+S; Studio holds a `.lock`), then give them its SHA-256 (`Get-FileHash -Algorithm SHA256`) for their `docs/baseline.md` row (owner-only; the wip16 row exists, wip17 and wip18 are owed).**

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `033919da-405f-4cdb-a780-48d072381070`), Edit mode, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows the newest `docs(handoff)` commit on top of `e8edef6`; origin `095f6de` (about 70 local commits, count with `git rev-list --count 095f6de..HEAD`; not pushed, ask before pushing). Confirm `slice-36-wip19.rbxl` exists in `backups\`; if not, ask for it.
2. R6a, then R6b, as planned above (tests first and shown red, one briefed Sonnet agent each, never git, no screenshots for the agent).
3. Then Lomi King and the tiers.
Each job: tests first and shown red, builder run twice identical, groups green, `run_all` stays ok=true or its changed numbers go into EXPECTED with the owner's explicit OK and a reason, shots beside BOTH crops taken twice, the owner's look before the feat commit, commit test then feat, no trailer.

## Commits (local, no trailer, nothing pushed)
`3790453` test(roads): require white zebra bars and the Market side roads
`020e58a` test(roads): move the world_check controls off the new side roads
`96e4797` feat(roads): add the Market north side street and join the front street to the south road
`e8edef6` test(run_all): expect the Market side roads
(plus the commit that adds this file and the shot-kit rows)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/050-handoff.md and then 049 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows. git status clean; git log shows the newest docs(handoff) commit on top of e8edef6; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Confirm slice-36-wip19.rbxl exists in backups (I save it; never Ctrl+S); ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, each shot taken twice, then my look at the pictures BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue and any on-screen text ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport.
Job: build the approved plan in handoff 050: R6a (band traffic, poles and wires, the cap raise 2000 to 2200 own and 2100 to 2550 site) then R6b (12 more crowd figures), tests first. After that plan Lomi King (walk under 805, re-measure) and the Standard and Light tiers, and wait for my approval of each plan. End each stretch with the next handoff and remind me to save a backup.
```
