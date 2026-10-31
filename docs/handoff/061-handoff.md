# Handoff 061: Carmel, Taal, Malarayat (two passes), core-town filler, polish and the world cap DONE; Outlets and Farm IN TIDY
Previous: 060-handoff.md (then 059, 058). This file only records what changed after 060.
Baseline at the start: git had only the uncommitted 05/08/09 files on `d9f97ac`; disk = Studio for all 16 of them; run_all 23839/119/3836363115 in both; HttpEnabled false; `slice-36-wip32.rbxl` 817,146 bytes, SHA-256 2af97d3c...2d37d2a26. The viewport rendered all session.

## Owner decisions (2026-10-31)
- Looks: Carmel yes, Taal yes, Malarayat yes and then a fix pass (yes again after it). EXPECTED yes (first round).
- Open questions of 060 step 4: Tagbakin building is "good enough", add sand to parts of the shore (no hipped roofs, no curved lamps, dock kept); core-town filler YES (replace the core-box pin); Cafe C4 YES; Outlets and Farm PARTS ONLY (no terrain writes).
- "dispatch agents to speed up the work and also do more basic polishes"; later "speed things up".
- World part budget 20000 -> 25000 (raise, not trim).
- Outlets and Farm: "tidy, then look" (both thin against their boards).

## Commits (local on feat/tour-v2, no trailer, nothing pushed; origin = 970ce0d)
- `a890bb4` feat(site05) Carmel, 1167 parts, site05_check 106.
- `6aa3adf` feat(site09) Taal island (570 parts in World.Backdrops), site09_check 43.
- `039dcd9` feat(site08) Malarayat buildings, 1170 parts.
- `12ebb5b` test(run_all) EXPECTED: qa 115, unit 279, site04 45, site05 106, site08 56, site09 43, build05 1167, build08 1170, worldParts 17151, cells 1802974. run_all then ok=true, 89 rows, 0 mismatches; run_all 24896/119/4008443808 disk = Studio.
- `eed17b7` fix(polish): Cafe C4 customers 0.4 back (npcs [4]); Site01 Visitor2 out of a car (z 44 -> 50); Lomi diners on the floor; Lomi parapet 0.05 out. site01 143, site03 147, site04 47.
- `5292981` feat(site09) six Grass -> Sand shore patches (64 cells; second run 0). site09_check 49. They barely show from the dock; larger radii if wanted.
- `aba93d7` feat(credits) the Credits Plaza draws an AUDIO list; AmbientTown credited (title/creator from MarketplaceService:GetProductInfo, matches the place's AssetName/AssetCreator attributes). qa 116; credits_crosscheck "3 audio, 0 mismatched".
- `3d6a476` feat(world) core-town filler: 184 buildings, 1242 parts, `Core=true`, low blocks. The pin "no filler part in the core town box" is replaced in place by 13 narrower pins (routes and Guide look lines 8 clear, Credits Plaza + 12, spawn 40, road bodies + 4, no overlap with Sites/CreditsBoard/SpawnLocation, >= 130 core buildings, <= 2000 core parts). Also widened: filler part range 1500..5000 -> 1500..6400 (logged at the top of filler_check). filler_check 44/0.
- `3edaa03` feat(site08) Revision 3: wedge-ridge mountain (196 wedges, summit about y 124), 5 holes (fairways, greens with flags, 12 bunkers, 4 ponds), about 230 trees, water lagoons in a stone kerb. 2069 parts, site08_check 88. Pines are still stacked tiers; grass blades poke through the clear lagoon water.
- `bcfe8a9` feat(buildcheck) WORLD_PART_BUDGET 20000 -> 25000, exported and pinned in BuildCheck_Test (red 283/1, then 283/0). Filler re-run after the Outlets slot move: 5529 CityFill parts on two runs.

## Not committed (in Studio and on disk)
- **Outlets (site 06)**: slot (550,-700) 450 x 300, guideLocal/panelLocal keep the Guide, JeepStop and InfoPanel world positions (no jeepLocal: sites_check's 40..90 rule). Coordinator + site06_retail/promenade/parking/pitch/entrance; 1787 parts before the tidy; site06_check 91/0. Paved areas on a 1.3 deck (terrain renders up to about y 0.9 to 1.25); the Guide arrival court is 1.3 lower. Dropped signage text: "PARK OUTLET", "NOW OPEN", the billboard slogan, the pylon tenant list; TourContent's pickleball/basketball courts are not built. Tidy pass running: chained retail blocks, green promenade and oval plaza, trees.
- **Farm (site 07)**: slot (770,240) 400 x 320, guideLocal (100,0), panelLocal (94,-12); coordinator + site07_entrance/water/villas/halls/grounds; 2052 parts before the tidy; site07_check 91/0; npcs [7] yoga guest (756,206), staff (745,214). Entrance at the west tip (Road C), not mid-south. Tidy pass running: rivers read as water, smaller grey courts, dense canopy, small brown villas.
- Shared files touched by both: SiteData.luau, SiteData_Test.luau, sites_check.luau, npcs.luau ([6] football player (650,-660), [7]), docs/footprints.md rows 6 and 7.

## Found, not fixed
- City Hall Student rig 1.3 into TerraceS2 (npcs [10]); Guides on every site 0.19..0.49 sunk (guides.luau); InfoPanels use TextScaled; Cafe panel and SiteData spell Cafe with an e-acute (non-ASCII; landmark name, owner call); Site10 CoreBackBand coplanar with CoreBack (visibility unchecked); Outlets JeepStop pad hidden under the plaza terrain render (pre-existing); Malarayat rock sign hides most of "GOLF AND COUNTRY CLUB" behind its own front rocks.
- world_check is not stored in Studio (disk only) and was not run.

## Next steps
1. Resume: list_roblox_studios, Edit mode; git status; HttpEnabled false; newest backup; hash run_all.
2. (filled in at the end of 061)
