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
