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
