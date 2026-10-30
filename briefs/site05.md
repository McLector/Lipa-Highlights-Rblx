# Site 05 brief — Monastery of Our Lady of Mount Carmel

Site row: id 5, key `Carmel`, pos (-300, 0, -600), facing S (+Z), footprint 220 x 180 (local x +-110, z +-90), massScale 2.5.
Names and dates stay `[VERIFY]` until sourced in the Slice 12 content gate; the model carries no text beyond the InfoPanel, the shrine tablets and the history-panel titles.
Photos are in `Lipa_structure_Exterior_References/09_Mount_Carmel_Monastery/`. No photo textures (rights are withheld); every surface is a plain coloured part.

## Frame (important)
The site pivot is rotated 180 degrees (RightVector = -X). The builder therefore uses `origin = CFrame.new(site:GetPivot().Position)` and world-aligned local axes: **+Z = south = facade side**, **+X = east**, y up. All offsets below are in that frame, relative to the site centre.

## Reference photos
1. `Chapel_Front_Wide.jpg` — colour and shape source: stepped gable, rose window, niche, triple-arched portico, steps on the left (west), side wing on the right (east).
2. `Carmel_Monastery_Oblique_Official_2021.jpg` — side wing, dome behind the nave, green roofs, monastery block to the west.
3. `Chapel_Lateral_Wing_and_Dome.jpg` — dome: cream, ribbed, square drum with arched dormers, lantern and cross.
4. `Elevated_Roof_and_Facade_Context.jpg` — plan: monastery wing with green roof, hedged courtyard, white Marian statue on a pedestal.
5. `Outdoor_Shrine_Structure.jpg` — shrine: cream gable over a brick-red base, arched timber gate, two tablet panels.
6. `Chapel_Upper_Facade_Detail.jpg` — niche with statue, scalloped corbel band under the pediment, ringed (Celtic) cross.

## Colours (by eye, from the photos)
| Element | Colour |
|---|---|
| Walls | cream-yellow (240, 220, 160) |
| Trim, cornices, statue | warm white (240, 236, 222) |
| Roofs | green (40, 110, 70), ribs (60, 135, 90) |
| Doors | dark timber (80, 50, 40) |
| Plinth stripe, shrine base | maroon / brick red (150, 55, 45) |
| Hedges, topiary | green (52, 110, 56) |

## What is built
**Chapel facade** (about 50 studs wide, local z about +20): stepped gable (tall centre pediment with a scalloped corbel band and a ringed cross, lower shoulders either side); a rose window; a Marian niche with a white statue; a flat coat-of-arms relief; a triple-arched portico (large centre arch, two smaller side arches, timber doors set back); steps with rails on the west side; cone-shrub planters. Door >= 8 studs, risers 1 stud.
**Nave**: side walls with a repeated row of tall arched windows, green ribbed gable roof, plain flat rear (no rear elevation is documented).
**East side wing**: recessed, one large arched window, small square windows, low annex with a green canopy over the door.
**Dome**: square drum near the rear of the nave with an arched dormer on each face, cream ribbed dome, lantern and cross.
**Monastery wing** (west, approximated): 2-storey L-shaped block, green hip roof, veranda canopy, rows of windows.
**Grounds**: paved forecourt, garden walk, hedged courtyard with cone topiaries, white Marian statue on a pedestal, and the outdoor shrine (cream gable, brick-red base, arched timber gate, two tablets reading "THE TEN COMMANDMENTS").

## Required props (each a direct child folder of the site model holding parts)
Placed in an east-side prayer garden, clear of the kept objects.
- `Pews`: 3-4 rows of benches facing the statue.
- `Kneeler`: in front of the statue.
- `Candles`: a rack with Neon flames.
- `HistoryPanels`: 3 standing panels. Titles carry the verify tag because they carry dates: "1946 [VERIFY] - Founding", "1948 [VERIFY] - Reported apparitions", "1951 / 2015 [VERIFY] - Church rulings". Body text on each: "[VERIFY] text added at the Slice 12 content gate". No invented facts.

## Keep clear (existing, kept by the builder)
Guide at (0, +30), JeepStop at (-20, +30) with its sign and jeepney (about (-34, +30)), InfoPanel at about (+12, +24). The road mouth is at (0, +90).

## Forecourt ground
Terrain under the forecourt is repainted Pavement by `builders/world.luau`, region x -352..-248, z -600..-508 (4-stud aligned). Forecourt paving built by site05 stays inside that region.

## Approximated
Reliefs are flat panels; roof tiles are thin ribs over a flat slab; the interior of everything is solid (Carmel gets no interior); the monastery wing layout and the rear are guessed.

## Art-observation hooks for dialogue (Slice 12 will source them)
The entry arch and tall arched windows repeat in a steady rhythm; the stepped top of the front wall gives the facade a clear shape; cream walls against white trim and green roofs (colour contrast).

---

# Revision 1 (Slice 15, fidelity rework) — supersedes the geometry above where they differ

The user judged the Slice 04 model far from the real structure. Rebuilt from 11 new Wikimedia Commons photos (credits in `content/site_credits.md`), in `Lipa_structure_Exterior_References/09_Mount_Carmel_Monastery/rework_2026/` (not in the repo; reference only, never textured), plus OSM footprints (church way 157078294, Carmelite Monastery way 384123043). User decisions: **full rebuild**; the Marian billboard is built as a plain panel (the user left it to me). Nothing is taken from the photos except shapes, proportions and colours.

## New reference photos
| File | What it gives |
|---|---|
| `facade_front_wide_balingit_2018.jpg` | The frontal elevation: all measurements below come from this one (scale: the 68-stud outer facade = 1130 px). |
| `facade_front_trinidad_2013.jpg` | Second frontal, confirms the three-step silhouette and crest. |
| `facade_oblique_a/b_velasquez.jpg`, `facade_side_wing_velasquez.jpg` | Depth of the portico, the east annex, the side wall. |
| `dome_velasquez.jpg` | Dome: cream, 8 ribs, lantern, cross, two small arched windows in the base. |
| `elevated_monastery_roofs_velasquez.jpg`, `elevated_facade_context_velasquez.jpg` | Monastery wing: 2 storeys, paired louvred windows, dark green roof, covered walkway, teal umbrellas, topiary court with the white statue; dome sits behind the nave. |
| `wing_topiary_velasquez.jpg`, `approach_driveway_velasquez.jpg` | Topiary court and the arched Marian billboard on a lava-stone base. |
| `shrine_ten_commandments_velasquez.jpg` | Shrine gate (unchanged). |

## Real vs model (the diff that drove this revision)
| Part | Real | Slice 04 model |
|---|---|---|
| Gable | three steps (outer wall, mid shoulders, central gable) with crenellated white bands; triangular scalloped pediment; ringed cross | stacked pyramid of tiers (ziggurat) |
| Facade proportions | width : height to the cross about 1.8 : 1 | about 0.9 : 1 (52 wide, 58 high) |
| Portico | big centre arch + 2 smaller arches, white pillars on maroon bases, stepped white entablature | arches and pilasters ok; no entablature or pillar caps |
| Shoulders | twin-arched white-framed windows, 3 square slits each | plain dark rectangles |
| Steps | one wide terracotta stair across the portico, flanked by cream walls with a maroon base and cone topiary | narrow grey steps (podium 2 high) |
| Dome | cream, ribbed, behind the nave | small, on a square tower beside the facade |
| Monastery wing | long 2-storey block, dark forest-green roof, covered walkway, umbrellas, L-return | short wing, teal low roof |
| Grounds | Marian billboard, topiary court | neither |

## Scale and frame
Same frame as above (local +Z = south = facade, world-aligned, `ORIGIN = CFrame.new(pivot.Position)`), massScale 2.5, forecourt paving region (local x +-52, z 0..92) and footprint (+-110, +-90) unchanged. The church frontage is 27 m, so the outer facade is **68 studs** wide (the earlier 52 was too narrow); the real compound (231 m x 226 m) is compressed by shortening the monastery wing and dropping window bays. Human-scale parts are fixed: doors >= 8 (centre door 11), risers 1, walkway ceiling 12, storeys >= 12.
`B = 6`: the portico floor, 6 risers of 1 stud above the forecourt (was 2). All heights below are above the ground.

## Built (local studs; numbers measured from the frontal photo)
**Facade** (front plane z = 0, body z -10..0, centred x = 0):
- `Podium` x +-36, top y 6. `StairRiser` x6 (1.0 high, 1.7 deep, 56 wide, terracotta (196,128,94)) from z 10.4 down to z 0.2; `FlankWall` x2 (x +-28..52, z 8, 4 high, cream) with a maroon `FlankWallBase`; 8 `StairTopiary` cones on the walls.
- `Pilaster` x4 (white, 13 high) at x +-10.3 and +-23 with maroon `PierPlinth`; `ArchC` (opening 13 wide, 13.5 high) and `ArchS` x2 (9 wide, 10.5 high, centres x +-16.7); `DoorC` 11 high, `DoorS` 9 high.
- `EntabLow` 47 wide at y 26; `EntabMid` 26 wide at y 28.4; crest on the axis at y 23.5 with two relief bands.
- `FacadeOuter` x2 (x +-23..34, top y 31); `FacadeMid` (40 wide, top y 39); `FacadeCentre` (26 wide, top y 42); `PedTrim` / `Ped` triangle (apex y 47) with 7 `PedScallop`; 12 `Crenel` on the outer shoulders and 8 on the mid shoulders; ringed cross: `CrossStem` top y 52 and 8 `CrossRing`.
- `Rose` (dia 8, centre y 31), niche with white statue (centre y 39.6), `ShoulderWin` x2 (x +-28.5, twin-arched), 3 `ShoulderSlit` per shoulder, `MidWin` x2.

**Nave** (z -10..-66, 46 wide, walls 28): `NaveBlock`, `NaveRoof` dark forest green with ribs, 5 tall arched windows per side. **East annex**: low `AnnexBlock` x 34..50 with a green roof and a canopy over an 8.5-stud door (the old east wing is gone; the prayer garden starts at x 53).
**Dome** over the nave rear at (0, -50): round `DomeDrum` (dia 17), cream `Dome` (dia 16, 8 ribs), `Lantern`, cross (top about y 59), 4 small arched windows in the drum.
**Monastery wing** (west): `MonasteryBlock` x -102..-34, z -34..-8, 24 high; green roof; 24 paired `MonasteryWin` panes in two rows; covered `Walkway` (floor, roof at 12.4, 8 posts) along the front; 5 teal `Umbrella`; `MonasteryReturn` (x -102..-80, z -70..-34) with its own roof. **Court** in front (x -100..-52, z -2..14): raised `CourtLawn`, 8+ `Topiary` cones, a white `CourtStatue`.
**Grounds**: `ForecourtPaving` as before; arched `BillboardPanel` (pale blue, plain, no text) on a dark lava-stone `BillboardBase` at (40, 56), facing +Z. **Shrine**, Pews, Kneeler, Candles, HistoryPanels: unchanged.

Colours: walls (240,220,160); trim (240,236,222); **roofs dark forest green (30,92,56)**, ribs (46,112,70); steps (196,128,94); maroon (110,40,36); umbrellas teal (20,120,110).

## Keep clear
Guide (0, +30), JeepStop (-20, +30) with sign and jeepney (-34, +30), InfoPanel (+12, +24): nothing built may stand in their 8 x 8 zones. The road mouth (0, +90) and the Guide's path stay open.

## Approximated
Reliefs and crests are flat panels; roof tiles are thin ribs; the shoulder windows are one twin-arch unit; the monastery wing is shortened (about 68 studs for a 60 m building) and its rear and L-return are guessed; the billboard figure is a block figure; the true driveway ring is not built (it would need terrain repaint, which needs the user's go).

---

# Revision 2 (Standard tier, 2026-10-31): rebuilt from the Mount Carmel Monastery Blueprint board - supersedes the layout above where they differ

Source: `..\2nd Reference\Mt_carmel_monastery\Mount Carmel Monastery Blueprint.png` (site-plan inset, front-elevation inset, 3-D view), plan `scratch/standard_tier_plan.md` "05 Carmel". The board wins over the photos; the Slice 15 facade stays where the elevation agrees with it. Slot, pivot, footprint, forecourt terrain unchanged (no terrain writes). Guide, InfoPanel, JeepStop, JeepSign*, Jeepney and LocalNPCs are kept untouched.

## Model
`builders/site05.luau` is now a coordinator in the site03 pattern (KEEP list, MODULES, every container <= 400 parts, PART_BUDGET 2500, `WorldPivot = lookAt(ORIGIN, ORIGIN + (0,0,1))` written explicitly). `Structure` is a grouping Folder (Facade, Nave, Dome, Annex, Monastery) so the sites_check orientation guard is unchanged.
- `site05_chapel` (Structure/*): facade as Revision 1 plus the elevation's low outer wings (|x| 37..48, top 17.5), wings widened to |x| 37, corner posts on the centre block (top 44.3), rose dia 10, ringed cross top 57.5; nave with clerestory windows; transept arms; west side block; sacristy behind the nave; dome dia 22 on a dia-25 drum with 8 windows over the crossing (0, -40), lantern, cross top 69.5; side wing east (AnnexBlock x 38..72) with the east low wing's porch.
- `site05_monastery`: 2-storey L (north leg x -106..-28, z -86..-64; west leg x -106..-92 to z -30), walkway, west veranda (x -108..-94, z -30..40), courtyard (x -92..-52) with statue, gazebo, 5 umbrellas, paths, trees, palms, south wall with cone shrubs.
- `site05_rectory`: L of 2-storey east leg (x 84..106, z -88..14) with green awning and north leg (x 30..84, z -88..-72).
- `site05_grounds`: forecourt and drive paving, palm island (x 12..56, z 56..80), east drive to the shrine, perimeter wall (N, E, W, south-west diagonal, south-east; gate piers at x +-14), planting, lamps, shrine in the SE (brick-red, cream gable, green roof, arched door, both tablets facing south), the Revision 1 billboard moved to (-40, 56), a grotto statue for the kneeling pilgrim, prayer garden props (pews unmoved).
Roofs are the board's teal-green (70,116,106); walls (248,226,170).

## Tests first (site05_check, now grouped: `shared.site05_only`)
Red against the 514-part Slice 15 model: general 8/1, facade 25/4, chapel 8/12, monastery 10/6, rectory 1/6, grounds 15/9, clear 7/0; all 68/38. `clear` is constraint-only, so a negative control: an anchored 4x4x4 part in the jeepney box made it 6/1 ("the parked Jeepney's box ... | NegControl"), removed: 7/0. Two test bugs were fixed before that red run (a rotated cylinder was read as reaching below ground; kept-object labels were counted). After the build the new floor pin "site holds 1500..2500 parts" became 1000..2500 (a first estimate from the plan's 2260; the board's features came to 1167). Final: 106/0.

| Old pin (Slice 15) | Replaced by (board) |
|---|---|
| ringed cross stem top y 52 +-2 | top 56..59.5 (elevation: cross 9 studs, top 58) |
| rose on the axis at y 31 +-1.5, 7-9 across | y 31..34, 9.5-11.5 across (0.42 of the centre block) |
| low east AnnexBlock x 34..50, height <= 14 | side wing: x 36..78, 14-20 high, 36+ deep |
| five roofs forest green (R <= 50, G 75..105, B <= 70) | the board's teal-green (R 55..95, G 100..135, B 90..125, G >= R + 25) |
| Dome 15-17 across at z -53..-47 | 21-24 across at z -45..-35 (inset: about 20 across, 40 behind the facade, compressed 0.84) |
| DomeDrum 16-19 across | 23-27 across |
| exactly 4 DrumWin | exactly 8 (the 3-D view's ring of windows) |
| dome cross top y 56..62 | y 64..71 |
| MonasteryBlock x -102..-34, front face z -8 | north leg: 70+ long, x min <= -100, x max -34..-24, south face z -64, back z <= -84 |
| white CourtStatue at x -62..-46 | inside the courtyard, x -92..-52, z -60..30 |
| old veranda gone (VerandaFloor, VerandaCanopy, VerandaPost) | those names stay unused, plus VerandaDeck (west edge, 60+ long), 8+ VerandaColumn 8+ tall, VerandaRoofL green |
| shrine gate kept at (80, -51) | gate in the SE corner (x 70..104, z 50..82), 8+ high |

Every other Slice 15 pin is kept unchanged and passes. New pins: tree and container caps, unique guard names, slot bounds, FacadeLow, CentrePost, transepts, ChapelWestWing, west leg reaches z -40, gazebo, CourtWall, six rectory pins, tablets face south, fixed TextSize on every built label, shrine body and roof, a pew seat under the seated pilgrim, the grotto statue and open sky over the kneeling pilgrim, island, palms, DriveEast, perimeter wall and base, the jeepney box.

## Verification
Coordinator run twice: 1167 and 1167 parts (built 1099, kept 68; chapel 395, monastery 261, rectory 69, grounds 374; largest container Landscape 200; archPaths csg 3, fallback 0). site05_check 106/0; BuildCheck 05 15/0 (1167 parts); sites_check 277/0; npcs_check 237/0; routes_check 16/0. run_all not run (another site was mid-build); its EXPECTED `[5] = { 15, 514 }` would become `{ 15, 1167 }` (owner-only edit).
Hashes (disk equals Studio): `site05` 17111/338/2144024279, `site05_chapel` 13568/235/1130220741, `site05_monastery` 8661/151/2836747863, `site05_rectory` 3181/57/1654202631, `site05_grounds` 12667/201/521100562, `tests/site05_check.luau` 36197/545/1720333103.
Shots: the Studio viewport rendered blank (three tries), so `scratch/site05/shots/S4/` holds raycast rasters made in Studio instead: top-down, an oblique from the SSW, and the front elevation (from the first build, before the lamps and planting were added).

## Board vs model
| Item | Result |
|---|---|
| Stepped facade, three-arch portico, rose, niche, ringed cross, low outer wings | MATCH |
| Dome on a windowed drum with lantern and cross, behind the facade | MATCH |
| 2-storey L on the north and west of the courtyard, walkway, west veranda | MATCH in layout; the courtyard is narrower than the inset's (the elevation's 96-wide facade leaves x -92..-52) |
| Courtyard: statue, umbrellas, gazebo, trees, palms, south wall with cone shrubs | MATCH |
| Side wing east, rectory along the east edge, block on the north edge | MATCH |
| Shrine in the SE corner: brick red, cream gable, green roof, arched door, two tablets | MATCH |
| Palm island, perimeter wall with the south-west diagonal | MATCH; DIFF: the drive is rectangular paving, not the board's curves (forecourt terrain kept by decision) |
| Wide stair | DIFF: 6 risers (portico floor 6), the board draws about 12 |
| Marian billboard | DIFF: not on the board; kept from Revision 1 (plan did not retire it), moved to (-40, 56) |
| Pews | DIFF from the plan: they stay in the east prayer garden, because the seated pilgrim of builders/npcs.luau sits on the z 32 row |

## Open for the orchestrator / owner
- The kneeling pilgrim (npcs.luau, local (80, -43.5)) now kneels at a new grotto statue, not at the Ten Commandments shrine, which moved to the SE. Proposed respot: local (92, 74.5) facing -Z (world -208, -525.5), in front of the shrine door. Not done here: npcs.luau rebuilds every site's NPCs.
- No player-facing sentence is contradicted: the entry arch, tall arched windows, stepped front wall, portico centre arch and the forecourt below the steps all still hold. The history-panel words are unchanged (now fixed TextSize 20/16; every label fits, measured with TextService).
