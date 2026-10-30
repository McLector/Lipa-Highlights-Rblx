# Handoff 060: new-player guidance DONE; filler, Cafe fixes and a polish pass DONE; Malarayat REBUILT but not looked at; Carmel and Taal IN PROGRESS
Previous: 059-handoff.md (then 058, 057). This file only records what changed after 059.
Baseline at the start: git clean on `970ce0d` (= origin), `run_all` ok=true, 89 rows, 0 mismatches; `slice-36-wip30.rbxl` 710,556 bytes; then the owner saved `slice-36-wip31.rbxl` (716,599 bytes) after part 1.

## Owner decisions (2026-10-31)
- Part 1 plan and its text table approved ("go").
- After part 1: "spawn and orchestrate agents even if it had to be opus... on remaining unanswered open questions u do what u think is good... keep going". Taken as the yes to EXPECTED for part 1 and as delegation of the tier questions. Decisions made: no terrain writes for 05/08 (lagoon from parts), Malarayat gatehouse cream (board wins), the rock-sign lettering "MOUNT MALARAYAT / GOLF AND COUNTRY CLUB" added as new on-screen text, Outlets at 1.05 studs/m when it is built, Opus builder agents.
- Later asks: "build more filler buildings", "the tagbakin, there's supposed to be the taal in front of the building", "polish ... small effort big returns".

## Commits (local on feat/tour-v2, no trailer, nothing pushed; origin = 970ce0d)
- `cbd89cd` feat(guidance): GuidanceLogic (pure, positions from SiteData), Next line + NEXT pin (PassportClient), stamp and refusal messages, jeep menu marks + footnote, camera to the guide after a ride, client-side prompt words "Talk (get a stamp)" / "Choose a ride", Welcome Step1 names Ate Joy. GuidanceLogic_Test red then 21/21; qa_check red 86/14 then 100/0; tests/guidance_play_check.luau (Play, CLIENT datamodel, paste the file) 23/0.
- `d548eed` test(run_all): qa_check 85 -> 100, unitRun 254 -> 275; run_all ok=true, 0 mismatches at that point.
- `db22473` feat(world): CityFill 262 bldg / 2387 parts -> 532 / 4283 (rows 5-6, gap fill, Road A/B corner); reserves the future Outlets (x 325..775, z -850..-550) and Farm (x 570..970, z 80..400) slots +26, Malarayat entrance (60 around (450,560)), Tagbakin (250 around (-600,550) and x < -480 for z > 300). filler_check red 22/9 then 31/0; roads 281/0; routes 16/0 (Edit). Cells 1800504 -> 1802974 (+0 on rerun). Core-town pass NOT done: the existing pin "no filler part in the core town box" forbids it (owner call).
- `1357160` fix(site04): Cafe sign band 0.05 off the arcade ceiling, table bases +0.15, floor slab/edge tiles 0.05 inside the walls, staff on the floor (were 0.4 sunk). 705 parts unchanged. site04_check red 41/4 then 45/0. Finding: terrain paving draws over the Cafe's 0.2 floor parts, so the floor/table bases never show.
- `bac3edd` feat(polish): jeepney fade (8 s safety timeout), passport grid fixed TextSize 14, stamp sound rbxassetid://9114026047 (Pro Sound Effects via Creator Store, vol 0.35, muted by Mute) + counter pop, LampGlow.server.luau (runtime PointLights on 71 lamp heads, cap 300), music + stamp sound credited in a new CreditsData.audio list and "## Audio" in site_credits.md (credits_crosscheck: "... 78 references, 4 notices, 2 audio, 0 mismatched"). qa_check red 100/11 then 115/0; unit 279/3 then 279/0. NOT played yet (agents held Edit). The credits board does not draw the audio list (builders/credits.luau unchanged); AmbientTown's sound is still uncredited.

## Not committed (in Studio and on disk, waiting for the owner's look)
- **Site 08 Malarayat rebuilt** by an Opus agent: coordinator `builders/site08.luau` + `site08_clubhouse`, `site08_hotel`, `site08_context`, `site08_entrance`; `tests/site08_check.luau` red 25/31 then 56/0; sites_check 277/0; BuildCheck 14/0; 1170 parts (plan said ~1970: hotel and entrance are lighter than planned). Revision 2 table in `briefs/site08.md`. Agent-reported DIFFs: clubhouse and mountain left of the gate axis (sites_check pins), straight drive, rectangular lagoons (shallow uphill ends, grass may poke through), flat portal beam over the drive, planter off-centre (NPCs on the axis). It lowered its own new part-count floor 1400 -> 900 after building (logged in the brief): review that pin.
  - **Rule break:** the agent turned HttpService ON temporarily to sync files from a local server, then off. Verified off by me (HttpEnabled false).
- **Site 05 Carmel** (agent still running at writing time): coordinator + `site05_chapel`, `site05_monastery`, `site05_rectory`, `site05_grounds`; run_all saw site05_check 106 passed, 1167 parts.
- **Taal Volcano** (agent still running): `builders/site09_taal.luau` replaces exactly `World.Backdrops.Taal_Volcano` and `Taal_Ridge` with a low wide island (root part keeps the name `Taal_Volcano`); `builders/world.luau` (never run) would recreate the old balls. run_all saw site09_check 43 passed.
- No picture of 05, 08 or the volcano has been compared with its blueprint: the Studio viewport rendered blank (dark grey + view cube) for most of the session; the owner must bring the Studio window and the place tab to the front.

## run_all now (ok=false, only counts that moved on purpose; no check fails)
qa_check 100 -> 115, unitRun 275 -> 279, site04_check 41 -> 45, site05_check 71 -> (final), site08_check 29 -> 56, site09_check 26 -> (final), build 05 parts 514 -> (final), build 08 parts 703 -> 1170, checkWorld parts 13567 -> (final), terrain cells 1800504 -> 1802974. One EXPECTED update after the 05/08/09 looks (owner yes/no).

## Hashes (disk = Studio, checked by me unless noted)
GuidanceLogic 4656/120/3128540558; GuidanceLogic_Test 9166/194/4263025072; WelcomeClient 4429/106/3772379284; GuideClient 8197/243/4181806711; JeepneyClient 10750/284/3323363545; PassportClient 18966/512/1500044271; LampGlow 2192/70/1055676340; CreditsData 49777/241/3588069240; CreditsData_Test 21545/485/1507943517; qa_check 36783/549/2800022480; run_all 23839/119/3836363115; filler 25782/533/2399936420; filler_check 18419/369/2352875607; site04 24191/498/3031086629; site04_check 15175/309/1200819348. Site 08 files: agent-reported only.

## Next steps
1. Resume: list_roblox_studios, Edit mode; git status shows only the uncommitted 05/08/09 files; HttpEnabled false; confirm the newest backup (wip32 or later) and hash run_all.
2. Viewport on: shots of 08 (475,66,465 -> 560,30,720; top-down 560,330,721 -> 560,0,720), 05 (shot-kit row + top-down -300,260,-599 -> -300,0,-600) and the volcano from the Tagbakin Guide, each beside its board; owner's look; feat commits per site; then one EXPECTED yes/no.
3. One Play pass: guidance_play_check (client) again after the jeep fade change, a stamp with sound and Mute, a refused ride, the lamps at golden hour; then the part-1 pictures (HUD line, NEXT pin, toast, menu).
4. Open owner questions: Tagbakin hipped roofs instead of flat tiers (makes "stepped roofs" untrue), curved-arm lamps, keep the dock (scratch/light_tier_plan.md); core-town filler pass (needs the core-box pin replaced); Malarayat density (1170 parts vs the planned ~1970); Cafe C4 (customers' legs through a table, fix in shared npcs.luau).
5. Outlets and Farm rebuilds (slot moves: SiteData, docs/footprints.md, roads_extra paint region; the filler already keeps their new slots clear).
6. Small: Market overview row for docs/shot-kit.md (candidate camera (-150,55,255) -> (-310,14,160), unverified); owed docs/baseline.md rows wip17..wip31.

## Notes
- No Co-Authored-By trailer in any commit (the owner's CLAUDE.md overrides the harness reminder).
- Agents: Opus builders for 05, 08, 09-Taal, filler, polish, Cafe fixes, and a read-only Light tier planner (scratch/light_tier_plan.md). One polish agent ran `git diff --stat` once (read-only).
