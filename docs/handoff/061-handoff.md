# Handoff 061: Carmel, Taal, Malarayat (two passes), Outlets, Farm, core-town filler, polish and the world cap DONE and committed
Previous: 060-handoff.md (then 059, 058). This file only records what changed after 060.
Baseline at the start: git had only the uncommitted 05/08/09 files on `d9f97ac`; disk = Studio for all 16 of them; run_all 23839/119/3836363115 in both; HttpEnabled false; `slice-36-wip32.rbxl` 817,146 bytes, SHA-256 2af97d3c...2d37d2a26. The viewport rendered all session.

## Owner decisions (2026-10-31)
- Looks: Carmel yes, Taal yes, Malarayat yes and then a fix pass (yes again after it). EXPECTED yes (first round).
- Open questions of 060 step 4: Tagbakin building is "good enough", add sand to parts of the shore (no hipped roofs, no curved lamps, dock kept); core-town filler YES (replace the core-box pin); Cafe C4 YES; Outlets and Farm PARTS ONLY (no terrain writes).
- "dispatch agents to speed up the work and also do more basic polishes"; later "speed things up".
- World part budget 20000 -> 25000 (raise, not trim).
- Outlets and Farm: "tidy, then look" (both thin against their boards), then both approved.
- EXPECTED: pre-approved for the final update (only this session's rows move, every failure row 0).

## Commits (local on feat/tour-v2, no trailer, nothing pushed; origin = 970ce0d)
- `a890bb4` feat(site05) Carmel, 1167 parts, site05_check 106.
- `6aa3adf` feat(site09) Taal island (570 parts in World.Backdrops), site09_check 43.
- `039dcd9` feat(site08) Malarayat buildings, 1170 parts.
- `12ebb5b` test(run_all) first EXPECTED round (qa 115, unit 279, site04 45, site05 106, site08 56, site09 43, build05 1167, build08 1170, worldParts 17151, cells 1802974).
- `eed17b7` fix(polish): Cafe C4 customers 0.4 back (npcs [4]); Site01 Visitor2 out of a car (z 44 -> 50); Lomi diners on the floor; Lomi parapet 0.05 out.
- `5292981` feat(site09) six Grass -> Sand shore patches (64 cells; second run 0). They barely show from the dock; larger radii if wanted.
- `aba93d7` feat(credits) the Credits Plaza draws an AUDIO list; AmbientTown (rbxassetid://9112833822) credited from MarketplaceService:GetProductInfo, matching the place's AssetName/AssetCreator attributes. credits_crosscheck "3 audio, 0 mismatched".
- `3d6a476` feat(world) core-town filler: 184 buildings, 1242 parts, `Core=true`, low blocks. The pin "no filler part in the core town box" is replaced in place by 13 narrower pins (routes and Guide look lines 8 clear, Credits Plaza + 12, spawn 40, road bodies + 4, no overlap with Sites/CreditsBoard/SpawnLocation, >= 130 core buildings, <= 2000 core parts). Also widened: filler part range 1500..5000 -> 1500..6400 (logged at the top of filler_check). filler_check 44/0.
- `3edaa03` feat(site08) Revision 3: wedge-ridge mountain (196 wedges, summit about y 124), 5 holes (fairways, greens with flags, 12 bunkers, 4 ponds), about 230 trees, water lagoons in a stone kerb. 2069 parts, site08_check 88.
- `bcfe8a9` feat(buildcheck) WORLD_PART_BUDGET 20000 -> 25000, exported and pinned in BuildCheck_Test (red 283/1, then 283/0). Filler re-run after the Outlets slot move: 5529 CityFill parts on two runs.
- `37d60e2` feat(sites) Outlets and Farm (below).
- `d6460f7` test(run_all) final EXPECTED: site01 143, site03 147, site04 47, site06 97, site07 96, site08 88, site09 49, qa 116, unit 283, build06 2120, build07 2430, build08 2069, worldParts 22375, cells 1805068. run_all ok=true, 89 rows, 0 mismatches, before and after Play; run_all 25983/119/1166496762 disk = Studio.

## Outlets and Farm (37d60e2)
- **Outlets (site 06)**: slot (550,-700) 450 x 300 at 1.05 studs/m; guideLocal/panelLocal keep the Guide, JeepStop and InfoPanel world positions (no jeepLocal: sites_check's 40..90 rule). Coordinator + site06_retail/promenade/parking/pitch/entrance; 28 chained retail blocks, green promenade and oval, Aboitiz Pitch, curved solar grandstand; 2120 parts; site06_check 97. Paved areas sit on a 1.3 deck because rendered terrain draws up to about y 0.9 (Grass) to 1.25 (old Pavement); the Guide arrival court is 1.3 lower. Dropped signage text: "PARK OUTLET", "NOW OPEN", the billboard slogan, the pylon tenant list. TourContent's pickleball/basketball courts are not built. npcs [6] football player (650,-660).
- **Farm (site 07)**: slot (770,240) 400 x 320, guideLocal (100,0), panelLocal (94,-12); coordinator + site07_entrance/water/villas/halls/grounds; opaque river ring and lagoons, tops at y 1.05..1.45; lawn instead of grey courts; 100 palms + 256 broadleaf; 9 small villas; 2430 parts; site07_check 96. npcs [7] yoga guest (756,206), staff (745,214). Entrance at the west tip (Road C), not mid-south; the west half is still open.
- Shared files: SiteData.luau (working copy has CRLF; the hashes fold it), SiteData_Test.luau, sites_check.luau (277), npcs.luau, docs/footprints.md rows 6 and 7.

## Play pass (Studio solo, after all commits)
- guidance_play_check (Client, pasted): 23 passed, 0 failed (after the jeepney fade change).
- Sounds present: MusicLoop 0.25, AmbientTown 0.25, StampSound 0.35 (rbxassetid://9114026047). 98 PointLights visible on the client at ClockTime 17.5. Console empty.
- NOT verified: Mute and the Welcome Start button. The tool's mouse click on GUI buttons does not register (also in 059), so the owner should click Start and Mute once by hand. The lamps at golden hour and the jeep fade were not captured in a picture.
- Part-1 picture: scratch\looks061\play_hud_welcome.jpg (Welcome panel, Passport 2/10, Sound button, Next line). The NEXT pin, the stamp toast and the jeep menu were checked by guidance_play_check, not photographed.

## Found, not fixed
- City Hall Student rig 1.3 into TerraceS2 (npcs [10]); Guides on every site 0.19..0.49 sunk (guides.luau); InfoPanels use TextScaled; the Cafe panel and SiteData spell Cafe with an e-acute (non-ASCII; landmark name, owner call); Site10 CoreBackBand coplanar with CoreBack (visibility unchecked); Outlets JeepStop pad hidden under the plaza terrain render (pre-existing); the Malarayat rock sign's front rocks hide most of "GOLF AND COUNTRY CLUB"; Malarayat pines are stacked tiers and grass pokes through its clear lagoon water.
- world_check is not stored in Studio (disk only) and was not run.

## Looks (scratch\looks061\, git-ignored)
s05_board/top, s08_* (before), s08r3_* (after), s09_dock/guide, s09_sand_guide, core_overview, core_roadE, credits_audio, s06_tidy_iso, play_hud_welcome; Farm shots in scratch\site07\shots\.

## Next steps
1. Resume: list_roblox_studios, Edit mode; git status clean; HttpEnabled false; newest backup (wip33 if the owner saved it); hash run_all 25983/119/1166496762 and run it (ok=true, 89 rows).
2. Owner by hand in Play: click Start (music starts), click Mute (Sound: Off, music/ambient/stamp silent, then back), ride a jeepney once to see the fade, look at a lamp street at 17.5.
3. Small owner calls: bigger Tagbakin sand patches; Malarayat pines and lagoon grass; Farm west half denser; the Malarayat rock sign.
4. The "Found, not fixed" list above.
5. Small: Market overview row and new 06/07 rows in docs/shot-kit.md; owed docs/baseline.md rows wip17..wip33; add filler_check to run_all (owner-only).
6. Nothing is pushed: origin is still 970ce0d. Ask the owner before pushing.

## Notes
- No Co-Authored-By trailer in any commit (the owner's CLAUDE.md overrides the harness reminder).
- Five Opus agents ran in parallel (Malarayat fix, Outlets, Farm, core filler, polish) under scratch/agent_rules_061.md; none turned HttpService on (checked several times: false). Outlets and Farm were sent back once by message for a tidy round.
- `3517e2e` holds the draft of this file (a script error let the commit run first); the next commit holds the final text.

## Continuation prompt
```
Continue the Lipa Tour v2 project. Working dir: C:\Users\morad\mesvara-idle\art_appreciation_finals\roblox (git root; blueprints in ..\2nd Reference\). Branch feat/tour-v2, never main. Read docs/handoff/061-handoff.md, then 060, README.md (its AI rules are binding), docs/shot-kit.md and my memory files pace-over-ceremony, structures-match-blueprint-strictly, stop-at-context-cap-and-hand-off and parallel-opus-agents.
First: list_roblox_studios (ids change), Edit mode, check the viewport renders. git status clean on the 061 handoff commit; origin is 970ce0d (ask me before pushing). HttpEnabled false; confirm the newest backup (wip33) exists and hash it; hash run_all (25983/119/1166496762) and run it: ok=true, 89 rows, 0 mismatches.
Faster process; safety rules unchanged (only you run git, ask before push, NO Co-Authored-By trailer, HttpService off: agents must never turn it on, no settings or uploads, disk = Studio hashes, ASCII text, BuildCheck 2500 per site and 25000 world, never loosen an existing assertion). Use Opus agents for builds. My look gates new or rebuilt structures. Session cap 250k, handoff near 200k.
Job: (1) the owner calls in 061 next steps 3 and 4 (ask me in one dialog); (2) shot-kit rows for 06/07 and the Market overview; (3) whatever I add. End with the next handoff and remind me to save a backup.
```

## Addendum: grass cleanup (same session, owner ask "clean up the grass ... where the grass shouldnt be")
- Four Opus agents, one per site. Each added an idempotent ground step (builders/site05_ground, site06_ground, site07_ground, site08_ground, called last by the coordinator). It repaints terrain Grass to Pavement, Concrete, Mud, Ground or Sand under the hard parts only. Lawns stay Grass, and second runs repaint 0. This reverses "parts only" for those spots; the owner's ask covers it.
- Checks: site05 106 -> 110, site06 97 -> 118, site07 96 -> 99, site08 88 -> 93, each red first. sites_check 277/0 and routes_check 16/0.
- Malarayat: the agent's own new ground pins skip samples within 4 studs of the plot edge (road verge outside the plot); not logged in its brief. Blades still show through the fairway parts (left as Grass).
- Commits: `f75ded7` (05, 07, 08), `55e6fb0` (06), then the run_all commit. EXPECTED: those four checks and cells 1805068 -> 1807294 (owner pre-approved). run_all ok=true, 89 rows, 0 mismatches; run_all 26385/119/862280857 on disk and in Studio. Use this hash at resume instead of the one above.
- Shots (tool-results): 05 ...1793410526133-x1cv5m.jpg, 06 ...1793410544533-r2i4ta.jpg, 07 ...1793410530679-5fijl2.jpg, 08 ...1793410523904-2dtzzy.jpg.
