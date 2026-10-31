# Handoff 062: owner calls of 061 steps 3 and 4 DONE; filler_check in run_all; baseline wip17..wip33; shot-kit rows
Previous: 061-handoff.md (then 060, 059). This file only records what changed after 061.
Baseline at the start: git clean on `6751bfd`; origin = 970ce0d; HttpEnabled false; `slice-36-wip33.rbxl` 959,960 bytes, SHA-256 207c23c6...1a7add0; run_all 26385/119/862280857 disk = Studio, ok=true, 89 rows, 0 mismatches. The viewport rendered all session. Studio's window title still says wip26 (the .lock is on wip33).

## Owner decisions (2026-10-31)
- 061 step 3, all four: bigger Tagbakin sand, Malarayat pines + lagoon grass, Farm west denser, Malarayat rock sign.
- 061 step 4, all: rig fixes (City Hall Student, sunk Guides), InfoPanel fixed TextSize, CoreBackBand + Outlets JeepStop, filler_check into run_all.
- Cafe e-acute: KEEP the accent (exact landmark name; an allowed exception to the ASCII rule; README not edited).
- docs/baseline.md rows wip17..wip33: yes, written by me.
- Looks: Tagbakin yes, Malarayat yes (and keep the LeafyGrass verge write outside the plot), Farm yes as is (west still thinner than the east; see below). EXPECTED yes.
- "speed it up": agents were told to skip extra rounds; Lomi King concern raised and then withdrawn by the owner ("never mind").

## Commits (local on feat/tour-v2, no trailer, nothing pushed; origin = 970ce0d)
- `0aeb424` test(run_all): filler_check = 44 as a stored check (red with override 45 first); 18 stored checks, 91 rows.
- `49e133d` + `f411a8f` docs(baseline) wip17..wip33 log, wip33 the working backup; docs(shot-kit) Market overview (-150,55,255 -> -310,14,160) and Outlets whole-site + top-down rows. NOTE: wip32 on disk is 938,089 bytes / a5ea01d4..., not the 817,146 / 2af97d3c... recorded in 061: it was re-saved later under the same name.
- `8b77827` feat(site09): six patches -> four beaches on both shore arms (sand cells 64 -> 357), placed from the Halang lake photos (no board draws a beach). site09_check red 52/2 -> 54/0; Revision 4 in briefs/site09.md. Reads from the dock; from the far Guide camera it is still a thin strip in the fog.
- `9110ee8` feat(site08): pines = trunk + 4 tapering pyramid tiers (all 10 kept: the planting pin needs >= 230 trees, there are 231); site08_ground repaints an 8-stud ring round each water part, including the Grass row just outside the plot (z 556..560), to LeafyGrass (no blades; under water stays Mud); five front rocks off the sign, two flank it, both text lines clear (63 rays per line from 3 eyes). site08_check red 92/10 -> 102/0; 2150 parts on two runs. The 4-stud edge skip of the 061 ground pins is now justified in the Revision 4 table.
- `d2b371d` fix(sites): Guides seated by guides.luau after the site builders (+0.19..+0.49; guides takes opts.only); InfoPanels TextSize 36 + UIPadding, JeepSigns too, billboard 14, qa_check proves fit (tallest 252/296 px, widest 443/448); JeepStop pads on terrain are slabs to 1.4 above it (Outlets, City Hall, Tagbakin, Farm, Malarayat); Student on the TerraceS2 tread; CoreBackBand 0.05 off CoreBack. Also fixed two placeholders only-mode bugs (site01 podium lift lost; a stray Block added to site03). Only-mode passes were run on 01..06, 09, 10 (agent) and 07, 08 (me), each followed by guides and npcs with the same list.
- `07a0dd4` feat(site07): 49 palms outside the river ring -> 3-part broadleaf (palms 100 -> 62); the west gets 8 small villas, the Pure Energy Gym, walks A/F/G and 14 hedges. site07_check red 100/9 -> 109/0; 2372 parts (was 2430). West canopy 11.0% -> 13.2% (east 49%): the pinned sight-line corridors, plaza, parking and Acqua cover most of the west. More needs an owner call (palms in the corridor margins, the entrance mid-south as the board draws it, or a smaller plaza).
- `325c9e8` test(run_all) EXPECTED (owner yes): guides 133, npcs 238, placeholders 39, qa 127, site07 109, site08 102, site09 54, site10 97, build07 2372, build08 2150, worldParts 22398, cells 1807492. run_all ok=true, 91 rows, 0 mismatches; run_all 27417/120/3268504047 disk = Studio.
- Next commit: this file and the Farm shot-kit rows (770,300,540 -> 770,0,225; top-down 770,330,241 -> 770,0,240).

## Hashes (disk = Studio; checked by me in Studio for the starred ones, the rest agent-reported and matched on disk by me)
placeholders* 3257053621, guides* 108645357, npcs* 110834555, site10_wing* 3831949939, qa_check* 1044496233, placeholders_check* 4195426979, guides_check 2385587377, npcs_check 861532177, site10_check 3854321439; site07* 2880976749, site07_grounds* 3553319030, site07_halls* 3552154649, site07_check* 2771231415; site08 2204918251, site08_context 108666564, site08_entrance 2869902959, site08_ground 1176963891, site08_check 20110142; site09_shore 1241501347, site09 307927368, site09_check 661877107; run_all* 3268504047.

## Found, not fixed
- City Hall InfoPanel now sits 0.3 lower on terrain (the Forecourt no longer reaches under it).
- The new JeepStop pads do not collide, so legs sink into them (look call); Malarayat's pad is about 2.9 tall on its slope.
- Jeepney wheels still sink into the terrain render.
- placeholders default mode (never run) builds terrain-style pads before structures exist: after any full rebuild, re-run only-mode.
- CountCells rises on pure ReplaceMaterial repaints (+28, +162, +8 this session); cause still not established.
- Still open from 061: Mute and Welcome Start clicked by hand in Play; Malarayat dark patch on the east lagoon is shadow from the back rocks (raycasts show water on top); world_check not stored in Studio.

## Agents (scratch/agent_rules_062.md)
Four Opus agents in parallel: Tagbakin sand, Malarayat, Farm west, Fixes. The 061 "never run placeholders" rule got a scoped exception (only-mode, explicit list, sites no other agent was rebuilding). HttpService stayed false (checked several times). None ran git.

## Next steps
1. Resume: list_roblox_studios, Edit mode; git status clean on the 062 handoff commit; HttpEnabled false; newest backup (wip34 if the owner saved it) and its hash; run_all 27417/120/3268504047, ok=true, 91 rows.
2. Owner by hand in Play: Start, Mute, one jeepney ride, a lamp street at 17.5 (open since 061).
3. Owner calls: Farm west further (palms in corridor margins / entrance mid-south / smaller plaza); JeepStop pads collidable or not; City Hall panel 0.3; jeepney wheels.
4. Nothing is pushed: origin is still 970ce0d. Ask the owner before pushing.

## Notes
- No Co-Authored-By trailer in any commit (the owner's CLAUDE.md overrides the harness reminder).
- Looks this session (tool-results): 09 dock ...1793412326684-je5y34.jpg, top ...1793412345524-i4hwz2.jpg; 08 board ...1793412859646-hs48l7.jpg, sign ...1793412789346-8eoxhq.jpg, lagoon ...1793412802497-0mr27t.jpg; Lomi panel ...1793413030076-vp5fnh.jpg; Farm scratch/site07/shots/board_view_062.jpg and top_down_062.jpg; Market overview ...1793411733387-0bppp8.jpg; Outlets ...1793411742492-wuo6b3.jpg and ...1793411750417-pvxsqm.jpg.

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints in ..\2nd Reference\). Branch feat/tour-v2, never main. Read docs/handoff/062-handoff.md, then 061, README.md (its AI rules are binding), docs/shot-kit.md and my memory files pace-over-ceremony, structures-match-blueprint-strictly, stop-at-context-cap-and-hand-off and parallel-opus-agents.
First: list_roblox_studios (ids change), Edit mode, check the viewport renders. git status clean on the 062 handoff commit; origin is 970ce0d (ask me before pushing). HttpEnabled false; confirm the newest backup (wip34) exists and hash it; hash run_all (27417/120/3268504047) and run it: ok=true, 91 rows, 0 mismatches.
Faster process; safety rules unchanged (only you run git, ask before push, NO Co-Authored-By trailer, HttpService off: agents must never turn it on, no settings or uploads, disk = Studio hashes, ASCII text, BuildCheck 2500 per site and 25000 world, never loosen an existing assertion). Use Opus agents for builds. My look gates new or rebuilt structures. Session cap 250k, handoff near 200k.
Job: (1) the owner calls in 062 next step 3 (ask me in one dialog); (2) whatever I add. End with the next handoff and remind me to save a backup.
```
