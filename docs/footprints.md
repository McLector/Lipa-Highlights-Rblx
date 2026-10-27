# Footprints: approved growth table (Slice 4, 2026-10-27)

The owner approved growing footprints to fit the blueprints ("the bigger the better"). Sizes below are the **target slots**. Each one is applied by `SiteData`, `RoadData` and check edits at the **start of that site's own rebuild** (tests first, red), not all at once, because moving a centre shifts the site's pinned positions and the pivot checks stay red until the model is rebuilt. World axes: North is -Z, East is +X. Sizes are X extent by Z extent as in `SiteData`.

| Site | Blueprint size (studs/m) | Today | Target | Notes |
|---|---|---|---|---|
| 1 Cathedral | about 54 x 68 m (2.0) | 240 x 200 | keep | already larger than the drawing |
| 2 Market | 110 x 116 m (3.0): 330 along z, 348 along x | 200 x 160 at (-330,160) | 348 x 330 at about (-402,160) | east edge stays x -228 (Road F end); z -5..325 keeps 19 studs from Road E (z 344 edge) and 52 from the west bypass |
| 3 Lomi King | lot 6 x 25 m (3.5) | 100 x 80 | keep | |
| 4 Cafe | no drawing | 100 x 80 | keep | |
| 5 Carmel | about 82 x 68 m (2.5) | 220 x 180 | keep | the drawing fits |
| 6 Outlets | about 430 x 255 m (drawing also says 12.4 ha, inconsistent) | 300 x 200 at (550,-650) | about 450 x 300 at (550,-700) | south edge stays z -550, flush with Road B's end |
| 7 Farm | oval of 39 zones, about 52 ha, no printed size | 260 x 260 at (700,240) | about 400 x 320 at (770,240), oval | west edge stays x 570 (Road C end); east edge x 970; far below true scale |
| 8 Malarayat | not to scale | 400 x 320 | keep, or modest growth toward z 880 | world edge at z 1000 |
| 9 Tagbakin | photos only | 240 x 200 | keep | |
| 10 City Hall | 180 x 120 m (2.0): 360 along z, 240 along x | 200 x 140 at (-250,-260) | 240 x 286 at about (-270,-305) | full 360 width would need the west bypass removed; z -448..-162 stays clear of the Carmel road (z -460) and the bypass leg (z -150); east edge stays x -150 |

Rules for each application:
- Pinned world positions (Guide, JeepStop, InfoPanel, spawn pad) keep their world coordinates where the sites checks require it; the local offsets (`guideLocal`, `jeepLocal`, `panelLocal`) are adjusted for the new centre.
- Human-scale parts stay fixed.
- `roads_check`, `routes_check`, `qa_check`, `sites_check` and `placeholders_check` stay green (re-derive expected numbers with a reason in `EXPECTED`).
- World part budget: 20,000 cap, 8312 today; the cap is raised only deliberately.
