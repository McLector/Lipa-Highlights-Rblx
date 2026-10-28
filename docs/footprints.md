# Footprints: approved growth table (Slice 4, 2026-10-27)

The owner approved growing footprints to fit the blueprints ("the bigger the better"). Sizes below are the **target slots**. Each one is applied by `SiteData`, `RoadData` and check edits at the **start of that site's own rebuild** (tests first, red), not all at once, because moving a centre shifts the site's pinned positions and the pivot checks stay red until the model is rebuilt. World axes: North is -Z, East is +X. Sizes are X extent by Z extent as in `SiteData`.

| Site | Blueprint size (studs/m) | Today | Target | Notes |
|---|---|---|---|---|
| 1 Cathedral | about 54 x 68 m (2.0) | 240 x 200 | keep | already larger than the drawing |
| 2 Market | 110 x 116 m (3.0): 330 along z, 348 along x | 348 x 330 at (-402,160) (data applied, Slice 4 job 3; the model is still the 2014 one until the rebuild) | 348 x 330 at about (-402,160) | east edge stays x -228 (Road F end); z -5..325 keeps 19 studs from Road E (z 344 edge) and 52 from the west bypass |
| 3 Lomi King | lot 6 x 25 m (3.5) | 100 x 80 | keep | |
| 4 Cafe | no drawing | 100 x 80 | keep | |
| 5 Carmel | about 82 x 68 m (2.5) | 220 x 180 | keep | the drawing fits |
| 6 Outlets | about 430 x 255 m (drawing also says 12.4 ha, inconsistent) | 300 x 200 at (550,-650) | about 450 x 300 at (550,-700) | south edge stays z -550, flush with Road B's end |
| 7 Farm | oval of 39 zones, about 52 ha, no printed size | 260 x 260 at (700,240) | about 400 x 320 at (770,240), oval | west edge stays x 570 (Road C end); east edge x 970; far below true scale |
| 8 Malarayat | not to scale | 400 x 320 | keep, or modest growth toward z 880 | world edge at z 1000 |
| 9 Tagbakin | photos only | 240 x 200 | keep | |
| 10 City Hall | 180 x 120 m (2.0): 360 along z, 240 along x | 200 x 140 at (-250,-260) | 240 x 286 at (-270,-305), applied in Step C (blueprint rebuild) | full 360 width would need the west bypass removed; z -448..-162 stays clear of the Carmel road (z -460) and the bypass leg (z -150); east edge stays x -150 |

Site 10 (Step C, applied): slot 240 x 286 at (-270,-305) as approved (x -390..-150, z -448..-162, facing E). The model is built at one uniform plan scale of about 1.43 studs per metre, so that the drawing's 3:2 proportion holds and `roads_check`'s margin rule (real bounds +10 percent against road width/2 + 4) stays green with no road change. Real bounds x -322..-150, z -446..-188 (the check allows x -323..-149, z -447..-187). The pinned world positions are unchanged (Guide -223/-260, JeepStop -155/-230, InfoPanel -217/-282, spawn pad x -214..-202, z -266..-254); only the local offsets changed to (47,45), (115,75) and (53,23). The canopy overhangs the spawn pad at height (owner decision: canopy as drawn); nothing solid stands below it near the pad, the Guide or the InfoPanel.

Site 2 (applied in the data, Slice 4 Market rebuild from BP1, job 3 data and ground): slot 348 x 330 at (-402,160) as approved (x -576..-228, z -5..325, facing E, massScale 3.0). The old 2014 model is still in the place until the rebuild (job 4/5); its measured bounds today are x -421..-229, z 84..260 (`roads_check` info line). SPECIFIED for the new model, to be measured after the rebuild (`scratch/site02/layout.md` section 2): one uniform plan scale of 2.90 studs per metre (the 110 m frontage reading), so BP1's drawn proportion holds (depth 1.31 x frontage), and real bounds x -559.6..-229.0, z 33.3..276.3 (margins to the slot: west 16.4, east 1.0, north 38.3, south 48.7). Projected margin rule: with the 10 percent road margin the east edge would be -229 + 33.1 = -195.9, under the west bypass body edge at x -180, so `roads_check`'s margin rule should stay green with no road change. Applied now: the Guide and the InfoPanel move to the forecourt at the stairs (owner decision 2026-10-29): Guide (-241, 0, 160) = `guideLocal` (161, 0), InfoPanel centre (-247, 5, 148), 12 x 8, facing E = `panelLocal` (155, -12). The Market keeps no JeepStop. The two shoppers stand at (-380, 255) and (-372, 258). The site pivot is (-402, 0, 160), facing E, written as a property (no part moved). The whole slot is repainted Concrete (owner decision): `builders/roads_extra.luau` CONCRETE gains four chunks x -576..-228, z -8..328 (z -5..325 widened to the 4-stud grid); Asphalt and everything outside the slot are untouched (7308 surface voxels changed, 5828 Grass and 1480 Pavement, none outside). Margin rule note: any part pushed east of x -228 (a rig or the Guide included) would trip both the slot check and the margin check; the new builder must keep every part inside the slot.

Rules for each application:
- Pinned world positions (Guide, JeepStop, InfoPanel, spawn pad) keep their world coordinates where the sites checks require it; the local offsets (`guideLocal`, `jeepLocal`, `panelLocal`) are adjusted for the new centre.
- Human-scale parts stay fixed.
- `roads_check`, `routes_check`, `qa_check`, `sites_check` and `placeholders_check` stay green (re-derive expected numbers with a reason in `EXPECTED`).
- World part budget: 20,000 cap, 8312 today; the cap is raised only deliberately.

## Cathedral south growth (Slice 4 B3b, data and roads)
- `SiteData` row 1 is now centre (0, 57.5), size 240 x 315 (z -100..215; x kept at 240 so Road C's start at x 120 stays outside the slot). `guideLocal` (-27.5, 0) and `panelLocal` (-33.5, -12) keep the Guide (0,30), the JeepStop (-20,30) and the InfoPanel (12,24) where they were; a unit test pins the literal world values.
- The model's WorldPivot is written to (0, 0, 57.5), facing +Z, by a property write (no part moves). `site01_check` expects that pivot. Do not run `placeholders({only={1}})`: it would rebuild site 1.
- Roads: E starts at (0,225), F starts at the west bypass end (-170,160), G at the east bypass end (165,140). New `WEST_LINK` and `EAST_LINK` (NEW_ROADS) join the bypass ends to Road E at z 260, clear of the slot's margin zone (z to 246.5). `roads_check` section 6 keeps every road out of the slot and its 10 percent margin except the first segments of A, C and E.
- The old asphalt under the new compound area (Road E z 100..215, F and G from x 0 to the bypasses) is not repainted.
