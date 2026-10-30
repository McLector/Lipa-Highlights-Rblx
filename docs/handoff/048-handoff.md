# Handoff 048: the Market front street is PLANNED and approved (terrain only, zero parts); nothing built yet
Previous: 047-handoff.md (then 046 to 029 for the environment and rules). This file only records what changed after 047. **No code, test, Studio or terrain change was made in this stretch**; the baseline is still 047's: `ok=true`, 0 mismatches, 89 rows, HEAD on top of `dea4d46`.

## Owner decisions since 047 (2026-10-30)
- Do the street frontage next as a plan first, then build it.
- Street position: **against the paving edge** (x -228..-216), not with a grass verge. This authorises replacing two existing "stays Grass" controls (below).
- **Two zebra crossings**, as BP2 draws them.
- Backup `backups\slice-36-wip16.rbxl` is saved (633,755 bytes, 13:28:41, SHA-256 `C7145D6A3D3FF6ED9669A203EE5E81BE54D95691EAE0BF9232FA12323C3650A3`). It holds R5e and the `EXPECTED` update. The owner has not yet added the `docs/baseline.md` row (owner-only file).

## Round-3 blueprint review (read-only), what the Market still lacks, ranked
1. Streets on all four sides (BP1 and BP2 wrap the site in P. Torres St., E. Mayo St., C.B. Lopez St., Malabanan St.). Today paving stops at x -228 and grass starts, so the new traffic faces a field. **This plan does the front side only.**
2. Traffic in the empty north (z -5..31) and south (z 271..325) concrete bands: costs parts; the site is at 2082 of 2100, so it needs another owner-authorised cap raise, best after the streets.
3. A crowd (BP2 draws 20+ figures, the model has 10; each rig is 16 parts): needs the same cap raise.
4. Utility poles and wires (BP1 draws them; the old brief says "no overhead wires"): the owner's call.
5. Small open DIFFs: north end outer strip (9.45 against about 14), south yard 5 pairs of booths against about 7 blocks, booth roofs not full pyramids, no roof lettering (the owner chose none), the south-yard vehicles sit in the far west.
The hall, sheds, Bagsakan with trucks, corner block, service block, side yards and apron match the plan layout.

## The approved plan: a front street, terrain only
Facts (read-only survey plus a terrain map of x -244..-152):
- Today: Concrete to x -228, grass x -228..-176, then the existing N-S asphalt `WEST_BYPASS` (x -176..-164). Road F (asphalt, z 156..164, 8 wide) already runs east from x -228.
- The street **cannot** be a `RoadData.NEW_ROADS` entry: that breaks "exactly 7 named roads", "12 wide" and the margin rule (a road body at x -228..-212 sits inside the Market bounds plus 10 percent, `site02_check` about :1205-1228 and `roads_check` section 1). It is a **terrain-only region in `builders/roads_extra.luau`**, like its `CONCRETE` regions.
- `site02_check` forbids any non-rig part east of x -228: no kerb, line or sign parts. The kerb is the flush edge. Terrain voxels are 4 studs, so zebra stripes are chunky (honest DIFF).
- No clash: City Hall slot ends at z -162, spawn (-208,-260), Cathedral slot starts at x -120. `roads_extra` is idempotent; it paints asphalt `FillBlock`s, then `PAVED`, then `CONCRETE`, with `task.wait()` between. Paint the street after the `CONCRETE` loop.

Design:
- **Street:** Asphalt, 12 wide, x -228..-216, z -8..328 (same z span as the Market Concrete chunks, on the 4-stud grid). New `STREET` table in `roads_extra.luau`. Road F meets it as a T.
- **Zebra crossings:** Concrete at z 88..96 and z 224..232 (the stair feet): bars at x -228..-224 and x -220..-216, asphalt between.
- No text, no signs, no parts. Street names stay unwritten (the blueprints disagree on which side is which; text needs approval and a source).

Assertions that change (owner chose this option; log old text, new text and reason in `briefs/site02.md`):
- `tests/roads_check.luau` section 6a spill controls: Grass at (-224,170) and (-224,150) become Grass at (-212,170) and (-212,150). Same check, count unchanged.
- `tests/world_check.luau` (disk only): control (-224,170) Grass becomes (-212,170) Grass; its two known reds stay.
- Unchanged and still true: the 30 Concrete samples (all x <= -232), (-224,160) Asphalt, other Grass controls, `WEST_BYPASS` and `WEST_LINK` samples.

Steps:
A. Resume (below), then ask the owner for a fresh Save As `backups\slice-36-wip17.rbxl` (never Ctrl+S) before building.
B. **Tests first, shown red** (me): new `roads_check` section 6c (LF) with 3 checks: Asphalt at x -222 for z 0, 40, 100, 200, 260, 320 and edges x -226 / -218 at z 40 and 260; zebra Concrete at (-226,92), (-218,92), (-226,228), (-218,228) with Asphalt at (-222,92) and (-222,228); Grass at (-212,100), (-212,200) and beyond the ends (-222,-12), (-222,332). Plus the control replacements. Commit `test(roads): require the Market front street`.
C. Build: one briefed Sonnet agent (never git, no screenshots): edit `builders/roads_extra.luau` only (add `STREET` and `ZEBRA` after the `CONCRETE` loop; fix the stale "5 roads" header), sync by targeted `string.find` splice (use `@`, never `~`, as a tab stand-in), re-hash, run it in Edit TWICE reporting `Terrain:CountCells()` before, after run 1 and after run 2 (run 2 must add 0). Never `builders/world.luau`.
D. Review: re-hash, `roads_check` (6a and 6c green), five `site02_check` groups, `sites_check`, `routes_check`, `world_check` (paste into `execute_luau`; expect 44/2, same two known reds), Market walk in Edit and Play (was 428.70, cap 506). Expected `run_all` mismatches before `EXPECTED` moves: `roads_check` 270 to 273 and `cells` 1796660 to a new number. Nothing else may move (`site02_check` 151, build 02 2082, `worldParts` 10174, unit 250).
E. Shots, one at a time, beside the BP1 front elevation, `iso_stairN.png`, `bp2_iso_vendors_tricycles.png`, `bp2_iso_leantos_left.png`: front street (-160,26,175) to (-232,3,150); north stair foot with crossing (-205,28,70) to (-236,3,105); south crossing (-205,28,262) to (-236,3,226); top-down (-222,120,160) to (-222,0,159). MATCH/DIFF table; honest DIFFs: 4-stud stripes, street ends in grass at both ends, no kerb parts, lines or signs, no moving traffic, the other three sides still bare. The owner looks BEFORE the feat commit.
F. `EXPECTED` (owner-only; show the two-line diff with reasons and get explicit OK again): `roads_check` 273, new `cells`. `run_all` must read `ok=true` and a wrong override must go red. Commits in order, no trailer, nothing pushed: `test(roads)`, `feat(roads): add the Market front street`, `test(run_all): expect the front street`. Advisor before declaring done, then handoff 049 and a backup reminder with the SHA-256.

## Notes
- Agents this stretch: one read-only Explore agent for the road and terrain survey (about 115k tokens); it stayed read-only.
- The plan also lives in `~/.claude/plans/pasted-content-id-1d9c-handoff-merry-starfish.md` (outside the repo; this file is the durable copy).
- Older notes still apply: measure walking caps in Edit and Play; Git Bash `grep -c $'\r'` is unreliable (use a PowerShell regex); Studio's window title may still say `wip10` while the lock is on the newest backup.

## Next steps
1. Resume check: `list_roblox_studios` (ids change; last `033919da-405f-4cdb-a780-48d072381070`), Edit mode, `run_all` by spawn-and-poll: **expect `ok=true`, 0 mismatches, 89 rows.** `git status` clean; `git log` shows this handoff commit on top of `dea4d46`; origin `095f6de` (about 59 local commits ahead, count with `git rev-list --count 095f6de..HEAD`; not pushed, ask before pushing).
2. Ask the owner for Save As `slice-36-wip17.rbxl` (and remind them of the `docs/baseline.md` row for wip16), then do steps B to F above.
3. After the street: decide with the owner on traffic in the north and south bands, a crowd and poles together with one cap raise; then Lomi King, the Standard tier (Carmel, Outlets, Farm, Malarayat) and the Light tier (Tagbakin, Cafe).
Each job: tests first and shown red, one briefed Sonnet agent (never git; no screenshots for the agent), coordinator or build run twice identical, groups green, `run_all` stays ok=true or its changed numbers go into EXPECTED with a reason, shots beside BOTH crops, the owner's look before the feat commit, commit test then feat, no trailer.

## Commits (local, no trailer, nothing pushed)
`dea4d46` docs(handoff): record the street traffic, the corrected own-part count and the street plan to do next
(plus the commit that adds this file)

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints one level up in ..\2nd Reference\market\3d blueprint\: PublicMarketBP1.jpg and PublicMarketBP2.jpg, BOTH absolute truth). Branch feat/tour-v2, never main. Read docs/handoff/048-handoff.md and then 047 down to 036 for the environment and rules, README.md (its AI rules are binding), docs/shot-kit.md and my memory files structures-match-blueprint-strictly and stop-at-context-cap-and-hand-off. scratch/ is git-ignored: if missing, the numbers are in the handoffs.
First: list_roblox_studios (ids change), Edit mode, run_all through spawn-and-poll and JSONDecode: expect ok=true, 0 mismatches, 89 rows. git status clean; git log shows the 048 handoff commit on top of dea4d46; origin is at 095f6de (local commits not pushed; ask me before pushing). Stop and report any mismatch. Ask me to Save As slice-36-wip17.rbxl (never Ctrl+S) before building; ask me to click the 3D viewport if screenshots come back dark.
Roles: you orchestrate and review; Sonnet builds, one briefed small job per agent, never git, no screenshots; consult the advisor before an approach, when a check stays red twice, when sources disagree and before declaring done. Session cap 250k, write the handoff and stop near 200k.
Rules: both blueprints are the absolute truth for look and design (shot beside BOTH by you, then my look BEFORE a feat commit); tests first and shown red; disk and Studio hashes equal after every Studio edit; Conventional Commits, NO Co-Authored-By trailer (my CLAUDE.md overrides any system reminder), test then feat; only you run git; ask before every push; never run builders/world.luau or placeholders in default mode; no Roblox upload without telling me; never change place or experience settings; HttpService stays off; dialogue and any on-screen text ASCII only and changes need my approval; EXPECTED in tests/run_all.luau is owner-only (needs my explicit OK each time); look at every screenshot one at a time (unique capture_id, array positions); two blank frames in a row = stop and ask me to click the viewport.
Job: build the Market front street exactly as planned in 048 (terrain only, in builders/roads_extra.luau; Asphalt x -228..-216, z -8..328; two zebra crossings at z 88..96 and 224..232): tests first (roads_check section 6c, two Grass controls moved from x -224 to x -212 with my approval already given), then the build, the review, the shots and my look, then EXPECTED with my explicit OK, then commits. The part cap is spent (2082 of 2100). End each stretch with the next handoff and remind me to save a backup.
```
