# Site 01 brief — Plaza Independencia & Metropolitan Cathedral (San Sebastian)

Site row: id 1, key `Cathedral`, pos (0, 0, 0), facing S (+Z), footprint 240 × 200 (x ±120, z ±100), massScale 2.0.
Names stay `[VERIFY]` until sourced in the Slice 12 content gate; the model carries no text beyond the existing InfoPanel.
All photos are in `Lipa_structure_Exterior_References/04_Cathedral_and_Plaza/`. No photo textures are used (rights are withheld); every surface is a plain coloured part.

## Period and colour source
The **2024 scheme**. **Colour source photo: `Cathedral_Front_2024.jpg`.** The overcast light makes it the most neutral of the 2024 shots, so screenshots are compared with this one. `Cathedral_Front_Oblique_2024.jpg` is more saturated (sun + camera); it is a shape reference only.

| Element | Colour (approx., sampled by eye from the source photo) |
|---|---|
| Walls | cream-yellow (233, 214, 165) |
| Pilasters, cornices, trim, arch surrounds | mauve-grey (176, 160, 172) |
| Tower cupola and main dome | cream (236, 226, 196) with blue-grey ribs (140, 160, 175) |
| Nave, transept and wing roofs | terracotta red (176, 58, 52), ribs (198, 78, 66), corrugated look via thin ribs. The aerial photos show a brighter red than `Cathedral_Front_2024.jpg` (dusty maroon), so the roofs follow the aerials. |
| Door | warm timber (150, 100, 60) |

Left out on purpose: the purple Lenten banners (seasonal) and the parked cars.

## Reference photos
1. `Cathedral_Front_2024.jpg` — straight-on front: massing, colours, register heights, wing arcade rhythm.
2. `Cathedral_Front_Oblique_2024.jpg` — facade detail: columns in pairs, medallion, niche, relief panels, door surround.
3. `Cathedral_Tower_Detail.jpg` — tower: octagonal tiers, arched openings stepping up, cornice at each tier, cupola.
4. `Cathedral_Dome_and_Side_Wing.jpg` — dome: ribbed (8 ribs), tall drum with arched windows, four small corner turrets, lantern + finial.
5. `Cathedral_Downtown_Aerial_Alternate_01.jpg` — massing and plan: dome behind the facade on the nave axis, wing to the viewer's right, plaza in front. An aerial is perspective context, not a measured plan.

## What is built
> Superseded in part by Revision 5 (below): the tower (7 tiers, small cap), the dome, the wing (now on the west flank), the forecourt walls, the monument and the stage roof.
**Bell tower** (viewer's left, −X, attached to the facade): octagonal in plan, 4 tiers narrowing upward. Each tier has arched openings on the visible faces and a projecting cornice on top. Cream ribbed cupola with a lantern, finial and cross. A dark panel (the LED screen) sits at its base on the front face. About 80 studs tall.

**Facade** (3 registers, 44 studs wide): paired pilasters (mauve-grey) carry cornices between registers.
- Ground: arched main door (≥ 8 studs, in practice about 12) with a surround, a plaque above, steps up from the plaza (risers 1 stud).
- Middle: arched choir window; flat inset relief panels on both sides.
- Upper: Marian niche with a statue, IHS medallion, and a triangular pediment carrying a small belfry cupola + cross. Apex about 50 studs.

**Nave**: plain walls with arched windows along the sides, red roof running back about 90 studs. Nave bays are dropped to fit the footprint (massScale rule: drop repeats, never shrink human-scale parts).

**Transept and dome**: on the nave axis, about 50 studs behind the facade (z −50). The crossing block is 60 wide (x ±30, 12 studs of arm each side of the nave) with gabled arm roofs (ridge along X at y 39.5), an end gable and an arched window on each arm end. On top, an octagonal drum (apothem 16, y 34–48) with an arched window on every face and a cornice, four small corner turrets on the arm roofs, and a ribbed dome of radius 15 (dome top 64.5) with a lantern, cap and cross (cross top 73.4, just below the tower's 75.7). The enlarged dome and transept follow the aerial photos, where the dome is about as wide as the nave.

**Rear**: no rear elevation is documented, so the nave ends in a plain rounded apse.

**Adjoining wing** (viewer's right, +X, front face recessed about 5 studs behind the facade): 2 storeys, arched upper windows in pilaster bays, red hip roof, a central pavilion with a curved gable and cross. About 70 studs long.

## Plaza and required props
South half of the footprint (z +6 … +100): low paving (top ≈ +0.05, so it never hides the JeepStop pad, InfoPanel or spawn), a central walkway to the door, a paving medallion, and a 0.3-stud kerb round the edge with a gap at x ±8 for the road mouth at (0, 100). The terrain under it (x ±100, z 0…100) is repainted as Pavement by `builders/world.luau` so grass does not show through. Hedges flank the tower front and the wing front; a south row of palms echoes the aerial photo.
Required prop names, each a **direct child folder of the site model containing at least one part**:
- `PlazaPeople`: 4 idle R15 rigs, never named `Guide`, only the HumanoidRootPart anchored.
- `Benches`, `Lamps`: along both plaza flanks.
- `Flagpole`: x ≈ +70.
- `EventStage`: x ≈ −70, a low platform with a backdrop (the public-activity booth).
Plus a few palms along the plaza edge for scale and shade.

## Keep clear (existing, kept by the builder)
Guide at (0, 30), JeepStop at (−20, 30) with its sign and jeepney, InfoPanel at about (12, 24), spawn at (0, 70) looking at the door.

## Approximated
- Facade relief panels, medallion and statue: flat or simple blocks, no sculpting.
- Corrugated roofs: thin ribs over a flat slab.
- The wing's interior, the nave's interior and everything behind the facade: solid.
- Dome position along the nave axis: judged from the aerial and the dome photo.

## Art-observation hooks for dialogue (Slice 12 will source them)
The tower's tiers narrow as they rise (emphasis, rhythm); the paired pilasters repeat across the facade and again in the wing's arcade; the cream walls are set against mauve-grey trim and the maroon roofs (colour contrast).

---

# Slice 14 rework — real vs model (research draft, 2026-10-17)

**Status: DRAFT for user review. Nothing has been rebuilt.** Photos are in `Lipa_structure_Exterior_References/04_Cathedral_and_Plaza/rework_2026/` (Wikimedia Commons, 2000 px renditions; author/licence/URL per file in that folder's `REFERENCE_NOTES.txt`). `more_reference.docx` was used only as a list of leads: it is an AI-written report, its images are AI illustrations, and it places the LED screen on a "right-hand" tower (every photo shows the tower, and the screen, on the viewer's LEFT).

## Evidence used
| Tag | File / source | Date | Used for |
|---|---|---|---|
| P1 | `02_..._CM_Recto_Avenue_drone_..._12-28-2025_.jpg` | 28 Dec 2025 | newest: massing, roofs, dome colour, forecourt + plaza layout |
| P2 | `01_..._Public_Market_CM_Recto_Avenue_drone_..._12-28-2025_.jpg` | 28 Dec 2025 | second aerial angle, plaza context |
| P3 | `07_Lipa_Cathedral_2024-03-27.jpg` | 27 Mar 2024 | straight-on facade, tower, wing arcade (best ground view) |
| P4 | `09_Lipa_Cathedral_facade_2023-04-05.jpg` | 5 Apr 2023 | facade detail, door, pediment, wing pavilion |
| P5 | `08_Lipa_Cathedral_dome_2023-04-05.jpg` | 5 Apr 2023 | dome (not yet viewed in detail) |
| P6 | `04_..._Welcome_Arch_Batangas_Apr_2024.jpg` | 14 Apr 2024 | Welcome Arch |
| OSM | way 249138738 (building), way 111718344 (religious compound), way 112418176 (park "Plaza Independencia"), Overpass 2026-10-17 | live | real footprint dimensions, in metres |
| M1/M2 | Studio screen captures of the current Site01 (front, aerial) | 2026-10-17 | the "model" side of each diff line |

## Real dimensions (OSM, metres) vs model (studs at massScale 2.0 = 2 studs/m)
Measured from the OSM polygons by minimum-area rectangle (rotation ~69.5 deg; the real church faces roughly ENE, which we map to our "S" facing, so only the relative layout matters).
| Element | Real (measured) | Model today | Verdict |
|---|---|---|---|
| Nave width / facade width | ~36 m | 44 studs = 22 m | **model ~40% too narrow** |
| Transept width (crossing) | ~48 m | 60 studs = 30 m | **~38% too narrow** |
| Overall length, facade to apse | ~85 m | ~110 studs = 55 m | **compressed 35%**; the footprint (z -100..+10) holds 55 m at 2.0 |
| Apse | round, ~18 m wide, at the far end | plain rounded apse | roughly right, size follows from the above |
| Dome | on the crossing, drum + large dome, about as wide as the nave | radius 15 studs = 15 m dia | dome reads too small and the wrong colour (see below) |
| Frontage incl. the long wing | estimated ~100 m (facade+tower ~36 m, wing ~1.8x that, from P1) | ~110 studs wing = 55 m | estimate only: wing is **far longer** in the photos |
| Plaza / forecourt depth to the street | roughly 100 m (forecourt ~60 m + amphitheatre area), estimated from P1 | 90 studs = 45 m | compress, see plaza |
| Heights | **not measured** (perspective in P3/P4 is too steep). Photo ratio only: tower clearly taller than the facade apex, about 1.3-1.4x (P3) | tower 80 studs, facade apex 50 | decide at rebuild from a ratio, mark as estimated |

## Cathedral: what differs (photo vs model screenshot)
1. **Dome colour (and period).** P1/P2 (Dec 2025): the main dome and the tower cupola are **cream-white** with pale ribs. P3/P4/P5 (2023-24): the same domes were **gold-yellow with blue-grey ribs**. M1/M2: the model has **blue-grey domes**, matching neither. *The domes were repainted between Apr 2024 and Dec 2025.* **Decision needed: build the 2025 scheme (recommended, newest) or the 2024 scheme.**
2. **Wall colour.** P3/P4: warm butter-yellow with mauve-grey trim; P1: paler cream. M1: a greyish cream-green that reads wrong. Re-sample colours from P3 (ground) and P1 (aerial) and put numbers in the table.
3. **Tower proportions.** P3: four octagonal tiers, each with a projecting cornice, **two arched openings per visible face on the upper tiers, one on the lower**, a slender onion cupola with a lantern and cross; the tower is wide and stands full-height out of the facade corner. M1: the tower is too thin and short, the cupola too flat.
4. **LED screen.** P3/P4/P1: a large dark panel with a pale louvred frame, on the tower's **front face just above the ground-floor cornice** (higher than our panel, which sits at the base). Keep it on the viewer's-left tower.
5. **Facade (P3/P4).** Three registers. Paired columns (round, with capitals) flank the door, not flat pilasters. Triangular pediment with a **small belfry cupola + cross at the apex**. Round **IHS medallion** over a **niche with a statue**, two framed **relief panels** (San Pablo / San Pedro) at register two, arched **choir window** with a scrolled hood, and a Latin plaque over the **arched main door with a decorated surround and a flight of steps**. M1 has the right idea but flat, thin and too plain (no scrolled hood, no paired columns, no steps detail).
6. **Roofs (P1/P2).** One huge red nave roof, a gabled transept, a red hip roof over the wing's return, and a **white/cream dome that dominates the skyline**. M2: the roofs are a darker maroon and the dome is small in comparison.
7. **Wing (viewer's right, P3/P4).** Long two-storey cream arcade: **arched upper windows with a pilaster between every bay, a balcony balustrade at the pavilion, a central pavilion with a scrolled (curvilinear) gable carrying a cross and a coat of arms**, an arched ground entrance with "CATEDRAL DE SAN SEBASTIAN" lettering at the far end, red roof. M1: recognisable, but about half the real length, with a plain rounded gable instead of the scrolled one and no balcony.
8. **Welcome Arch (P6).** A freestanding **wrought-iron arch** reading "CATEDRAL de SAN SEBASTIAN / 10 de ABRIL 1910 / ENTRANCE" with a cross on top, between stone gateposts (dated 1894), at the compound's street gate with white fencing. **Missing from the model.** It is a small, cheap, distinctive landmark worth adding.

## Plaza: what differs (P1/P2 vs M1/M2)
Plaza Independencia is not an empty slab. Reading P1/P2 (Dec 2025) from the facade outward:
1. A **large open paved forecourt used as a car park**: painted yellow guide lines, many parked cars and jeepney-style vehicles, a small **monument/statue** on the church axis. M1/M2: bare slab with lamps and benches.
2. Beyond it, a **stepped amphitheatre**: a central stage/dais with **a flight of wide steps (bleachers) on each side**, shaded by trees; a large (seasonal) Christmas tree stands on the stage in Dec 2025. M1/M2: a small flat "event stage", no steps.
3. **Hedged gardens** with clipped hedges, paths and **palms** on the plaza's right flank, plus palm rows along the south side. M1/M2: a few lamp-height palms, no hedged gardens.
4. **Enclosing buildings**: a long two-storey cream building with arched windows on the plaza's left; a **gabled brown-roofed civic building** at the south end, behind a white perimeter fence and a street. M1/M2: nothing around the plaza.
5. **Layout is a forecourt first, then the amphitheatre**, in real life roughly 2x deeper than the footprint allows. OSM draws the named park polygon (78 x 106 m) off to the east of the church, so OSM and the photos agree that the "plaza" is the whole civic space in front of and beside the facade, not only the rectangle in front of the door.
6. **Not confirmed:** names of the monument, the amphitheatre, the civic building and the long building. A web search found nothing usable for Lipa's plaza; **do not label them**. Describe them generically in dialogue.

## What I propose (needs your call; nothing is hard to reverse yet)
- **Keep SiteData pos, facing and the 240 x 200 footprint unchanged.** The layout image is authoritative and sites 2/3/4 sit 10-20 studs away. All "sizing" fixes happen inside the box by dropping repeats (nave bays) and compressing the plaza, keeping human-scale parts fixed.
- **Rescale the church to its true proportions** (facade 72 studs, transept 96, tower and dome re-proportioned to the photos) at massScale 2.0, and **drop nave bays** so the length (~52 m shown of 85 m real) fits z -100..+10.
- **Rebuild the plaza** in the real order within z +10..+100: church steps, then a compressed forecourt (monument, yellow bay lines, a few parked-vehicle props), then the stepped amphitheatre with a central stage, hedged gardens and palms on one flank, a perimeter fence, and the two enclosing buildings as simple massing.
- **Terrain:** the plaza is already repainted Pavement (x +-100, z 0..100). If the gardens and amphitheatre need grass/pavement changes, I would patch only those cells (and mirror it into `world.luau`), not re-run the whole world. I will ask before touching terrain.

---

# Revision 2 (2026-10-17): the plaza has two levels (user correction, confirmed on a crop of the 28 Dec 2025 drone photo)

The first rework treated the plaza as one flat slab with an amphitheatre. The user pointed out, and a close crop of `02_..._CM_Recto_Avenue_drone_..._12-28-2025_.jpg` confirms, that the real layout is:

1. **A wide car-park forecourt directly in front of the cathedral** (grey asphalt, painted bays, many parked cars on the west side, a small monument on the church axis, parked tricycles near the wall).
2. **A retaining wall across the forecourt's south edge with two long flights of steps going DOWN** to a central landing (the round-roofed gazebo that carries the seasonal tree) and on to the lower plaza.
3. **The lower Plaza Independencia**: a paved plaza below the wall with parked vans on the west, a big grey-brown gabled pavilion with palms in front, a light open slab with market tents on the east, a long arcaded cream building on the west, and a white balustrade fence along the street.
4. The **hedged garden** east of the forecourt, on the upper level.

## How it is built (builders/site01.luau, `RAISE = 5`)
- A **Podium** (x +-120, z -100..56, 5 studs high) carries the church, wing, forecourt and garden; its south face (z 56) is the retaining wall. Every upper component is built with an origin raised by 5, so all local coordinates are unchanged.
- **StageLanding** (x +-18, z 56..64, top 5) with the gazebo roof and the "PUBLIC EVENTS" fascia facing the lower plaza; **StairsL / StairsR**: 4 treads each, risers of exactly 1 stud (5 -> 4 -> 3 -> 2 -> 1 -> ground), x 18..62 on each side; **Parapet** caps the wall beyond the stairs.
- The kept props (Guide, InfoPanel, JeepStop, sign, jeepney) are raised by 5 (the `Site01Raise` attribute makes the move idempotent). The spawn stays on the lower plaza at (0, 70), looking north up the steps at the church.
- Terrain is untouched: the lower plaza sits on the existing repainted Pavement (z 56..100); the podium hides the rest.
- Player-facing consequence: the door is hidden behind the wall from the spawn (the church rises above it), so a visitor climbs the steps to reach the Guide.
- Simplifications: the seasonal Christmas tree and the signage letters on the wall are not modelled; the real stairs are longer and terraced; the forecourt is about half its real depth; the pavilion is one gabled hall, not the real cross-gabled roof.

---

# Revision 3 (2026-10-17): stage, seating and a wide lower plaza (user: "revisit the scale")

> Superseded in part by Revision 4 (below): the gazebo stage (`StageLanding`, `StagePost`, `StageCanopy`, `StageFascia`), the gabled pavilion
> (`CivicBuildingS`), the market tents and slab and the lower-plaza vans are gone. The seating, the side stairs, the scale decision and the
> walkability review still stand.

User feedback on Revision 2: the real Plaza Independencia is a **wide open space with seating around the stairs and a stage**. In the drone crop the terraced tiers either side of the gazebo landing are seating, the landing is the stage, and the lower plaza is deeper than the forecourt. Revision 2 had a 36-stud landing, 4-step stairs and the pavilion in the middle of the plaza.

Scale decision: the footprint (240 x 200 studs) and massScale 2.0 are fixed, and human-scale parts are never shrunk, so the **forecourt is shortened (46 -> 38 studs) and the wall moves from z 56 to z 48** to give the room to the stage, the seating and the open plaza. The real lower plaza is still about 1.6x the forecourt, so this remains a compression.

## What changed (builders/site01.luau, `WALL_Z = 48`)
- **Stage**: `StageLanding` 56 x 12 (about 0.8 of the church frontage, measured from the drone crop), gazebo roof 38 x 12 on four posts, fascia label facing the lower plaza.
- **Seating**: `BleacherL` (48 long) and `BleacherR` (70 long; the east side is the longer one in the photo), 4 tiers each, **3 studs deep** so people can sit and stand on them, risers exactly 1 stud, brown-grey like the photo. 5 benches at their foot.
- **Open lower plaza**: the pavilion moved east (x 36..78), the centre x -34..30, z 64..88 stays clear (the spawn, the Guide's approach and the CreditsBoard strip too); vans on the west, tents and a light slab on the east.
- **Forecourt** (z 10..48): garden, parking bays, monument, benches and lamps re-fitted to the shorter depth.
- **Walkability (design review)**: the podium's wall would have left Roads A and C dead-ending, so `SideStairsW` / `SideStairsE` (4 steps of 1 stud, 12 wide, z 20..32) give street-level access, and the east fence leaves a 22-stud opening toward Road C. `tests/routes_check.luau` proves it with PathfindingService (no jumping): Road C to the Guide is 156 studs with the side stairs and 180 without, Road A 383 / 407. Players could already reach the forecourt by the seating, so the stairs are a convenience of about 24 studs, not a fix for an unreachable area.

---

# Revision 4 (2026-10-17): Plaza Independencia from the user's ground photo

The user supplied a ground-level photo of the plaza taken from a raised street corner (it carries a campaign watermark, so its source and licence must be settled with the user before it goes into `CreditsData`; nothing from it is copied or textured). It shows what sits below the car park, and it overrides the drone-photo reading of Revision 3 where they differ. Decisions (user): a **fountain and statue** replace the gazebo stage at the centre of the stairs; the pavilion gets a **curved roof**; the **vans and tents go**.

## What the photo shows, and what is built
| Photo | Built (`builders/site01.luau`) |
|---|---|
| Warm terracotta paving with cream bands | `ForecourtPaving` is terracotta (205, 142, 116); two `PavingInlay` bands (z 63.4 and z 89) |
| Stepped fountain with a statue on the axis of the stairs, two orange-roofed kiosks | `FountainBasin` (14 across, ground), `FountainBasinUpper`, two translucent non-colliding `FountainWater` discs, columns, `FountainPlinth`, block-figure `FountainStatue` (top y 13.6) and head; two `KioskBody` (round, x +-32, z 44, on the podium) with four orange stepped `KioskRoof` discs each |
| Terraced steps up to the church level | `StairFlightL/R` (x +-8..22, 4 treads of 2 studs, tops 4 / 3 / 2 / 1, then a 1-stud drop to the ground); `BleacherL/R` now run on from the flights (x -76..-22 and 22..98) |
| Round raised garden with a half-ring of white pergola columns, shrubs and flowers | `PergolaRing` (24 across, 1.6 high, salmon) at (-52, 80) with `RingLawn`, `RingShrub` / `RingBloom`, 7 `PergolaColumn` on the south side, 6 `PergolaBeam`, 7 `PergolaRafter` |
| Large curved pavilion roof with a big shade tree beside it | `CoveredCourt` (x 36..78, z 72..88): 12 `CourtPost`, 2 `CourtBeam`, a barrel vault of nine `VaultPanel` (radius 9.2, +-60 degrees, axis along X) and a `VaultRidge`; `ShadeTree` (`ShadeTreeTrunk` at (35, 66), five `ShadeTreeCanopy` balls with bottoms above y 12.5) |
| Low salmon planter walls with shrubs along the street; flower beds | two `PlanterWall` runs (|x| 34..96, z 96.4, leaving the CreditsBoard strip clear) with shrubs; six `FlowerBed` (four along the long west building, two before the court) |

Removed: the `StageLanding` gazebo and its fascia, `CivicBuildingS` and its roof, `PlazaTent` / `TentPost` / `PlazaSlab`, all seven lower-plaza vans (the eight forecourt cars stay), and the two west palms that stood on the pergola ring's edge.

Kept exactly: `RAISE = 5`, `WALL_Z = 48`, the footprint, the forecourt and church, the Welcome Arch, the spawn (0, 70), the CreditsBoard strip, the open centre (x -34..30, z 64..88), the east fence opening toward Road C, the side stairs.

## Approximated
- The street-corner steps in the photo are not built: the lower plaza stays level with the street so the routes and the spawn are unchanged.
- The statue is a block figure and the water is a static translucent disc (no particles).
- The kiosks are round, not six-sided; the vault has no end arches or ribs.
- Names of the fountain, kiosks and court are not known: describe them generically in dialogue.

## Pitfall recorded
In Studio a stray drag moved the whole Site01 model by (-57.5, 0.2, 20.3) during this pass. It surfaced only as a dozen unrelated `site01_check` failures. `site01_check` now fails first on "site pivot is at the SiteData pos (0, 0, 0), facing +Z".

# Revision 5 (Slice 4): blueprint pass

> Written after the build, out of order: this brief was meant to be written before the change, and was not. The list below describes what is built and what the tests in `tests/site01_check.luau` (the Revision 5 block) assert. Source: `2nd Reference/cathedral/3d blueprints/Metropolitan Cathedral Blueprint Plaza Plan.png`. Its labels are garbled and are NOT signage: no blueprint text appears in the model. Precedence: the blueprint decides massing, layout and proportion; the photos win on visible detail, except where the owner's gap list overrides (walls, item 10).

## Ranked diff list (12 items, most visible first)
| # | Blueprint shows | Before | Built (part names the tests assert) | Target size (studs) |
|---|---|---|---|---|
| 1 | 7-tier octagonal bell tower with a small cream domed cap, at the SW corner of the facade | 4 tiers, cupola 13 wide | `Tier1..7` (8 segments each, `Tier<i>1..8`), `Tier<i>Win_Pane` (3 on tier 1, 4 on tiers 2-7), `Cornice<i>`, `Cupola` | tier radius 11.0 down to 6.5 in steps of about 0.8; tier heights 7.0 to 4.4; cap 10.8 across; cross top about 84.5 |
| 2 | Large cream dome with a lantern and a cross, on a drum with 8 windows | radius 19 (38 across), drum apothem 20 | `Dome` (46 across), `Drum1..8`, `DrumWin1..8_Pane`, `Lantern1..8`, `LanternCap`, `DomeCrossV`/`H` | dome radius 23, top y 76.5; drum apothem 24 (side 19.9); lantern apothem 4.2 |
| 3 | 2-storey parish and archdiocese office wing on the G.A. Solis (SW) flank, arcade facing the street, red roof | 2-storey arcade on the EAST flank (+X), 11 bays | `WingWest`: `WingUpper`, `WingUpperFront`, `WingBay1,2,4,5` (arched), `WingWin1,2,4,5_Pane`, `PavilionDoor`/`PavilionWin`, `EntranceSign`, `WingRoofFront`/`Back` (red tile ribs) | 45 long (z -62..-17), 12 deep (x -48.5..-60.5), storey band at y 13, eave at y 26.8 |
| 4 | 3-storey parish and archdiocese office wing at the far (back-left) end of the SW flank | none | `Office`: `OfficeBody`, `OfficeS<k>Win<i>` (5 / 6 / 6 windows on storeys 1-3), `OfficeBand1..3`, `OfficeDoor` (8.2 tall), `OfficePilaster`, `OfficeRoofFront`/`Back` (red) | 34 long (z -100..-66), 12 deep, 25.5 tall, storeys 8.5 |
| 5 | Walled parking forecourt with a retaining wall and steps (5 m drop) | open on the east and west edges | `ForecourtWallW`/`E` (2 segments each, brick, 3 tall), `ForecourtPier` (4 per side), `RetainBrickW`/`E` (brick skins on the podium's south face); gateway z 16..36 kept clear for the side stairs (a test asserts it) | walls at x +-100.6, z 10..16 and 36..46; gateway 20 studs |
| 6 | Perimeter railing in dark iron | white posts and rails | `FencePost`, `FenceRail` (dark iron, `LAMP_METAL`) | posts 3.2 tall (railings 3 minimum) |
| 7 | D-shaped monument mound with a looped ribbon sculpture | plinth with a statue | `MonumentPlinth` (12 strips in 3 terraces), `MonumentRibbon` (12 bars), `Monument` (pedestal) | half-disc radii 6.5 / 4.6 / 2.8 with the flat side at (22, 46); ribbon radius 2.4, top about y 13 (world) |
| 8 | Lipa Cultural Center: a 2-storey cream block with arched windows, at the far corner of the plaza | none | `CulturalCentreBody`, `CulturalS1W1..4_Pane`, `CulturalS2W1..3_Pane`, `CulturalDoor_Pane` (8.5 tall), `CulturalRoof`, `CulturalParapet` | 16 x 18 x 17 at x 80..96, z 65..82; south face at z 82, clear of the palm fronds |
| 9 | Open-air stage pavilion with a dark peaked roof | pale barrel vault (9 panels) | `CoveredCourt` and `CourtPost` (kept), `StageRoof` (2 planes, colour 58/60/66, tilt about 38 degrees), `StageRidge`, `StageGable` | eaves at y 9.8, ridge at y 16.8 |
| 10 | Cream walls, as the blueprint shows. Departs from the 2024 photos, which are butter-yellow | (232, 200, 120) | `WALL` = (240, 226, 186), used by the facade, tower, nave and wings | the owner may revert by restoring the old `WALL` value |
| 11 | Garden with trees north-east of the church | none | `GardenTreeTrunk`, `GardenTreeCanopy` (6 trees, 3 balls each) | canopy balls 4.6 to 6.5 across |
| 12 | Palms along the plaza edges | 20 palm trunks | `PalmTrunk1` (22 now; new palms at (-40, 72) and (-40, 84)) | fronds 8 |

Other changes, not separate items: the new wings have red roofs with tile ribs every 3 studs; the bench at (24, 42) is removed (the mound's site); `PlazaPeople` Visitor2 moves from (20, 44) to (-44, 34); the lower lamp at (90, 66) moves to (97.5, 62); the brick parapets replace the stone ones. The fountain, stairs, kiosks and seating are unchanged.

## Totals
- Site 01 parts: 1683 -> 1775 (+92). Max |x| stays 128.0 (roads_check 94/0; the cathedral is 31 studs from the EAST_BYPASS at x 165).
- Checks: `site01_check` 115 passed, 0 failed. Before the build: 77 passed, 38 failed (the new Revision 5 checks were red).

## Disclosed reversals (not approved by the owner, reversible)
- **Stage roof (item 9).** The curved vault was a user decision recorded in Revision 4 ("the pavilion gets a curved roof"), not only a photo detail. It is replaced by the dark peaked roof that the blueprint and the gap list ask for. To revert, restore the vault loop in `buildPlazaBuildings` (the Revision 4 code is in the git history of `builders/site01.luau`).
- **West wing (item 3).** The arcade wing sat on the viewer's right (+X). The Slice 14 rework, item 7, cites photos P3 and P4 for that position, and the old model followed them. The blueprint has no wing on the east flank and shows parking and garden there, so layout precedence moved the wing to the SW flank. The photo evidence that points the other way is P3 (2024 straight-on) and P4 (2023 facade), where the wing is on the right.

## Not done
- **Podium height.** The blueprint's "5M DROP / RETAINING WALL" is 5 m, which is 10 studs. RAISE stays 5 studs (2.5 m). RAISE is pinned across the flights, the seating, the Guide, the side stairs and the checks. Owner decision needed.
- **Forecourt depth.** The label "WALLED PARKING FORECOURT (~6?M DEEP)" is garbled, so the forecourt stays at 38 studs (19 m).
- **Visual check of the after shots.** Not done. The Studio 3D viewport returned blank frames (three in a row, on two camera positions) after the rebuilds. The scene itself is intact: 1775 parts, full terrain, no leftover scratch folder. Someone in Studio needs to bring the 3D viewport forward and retake the six shots (front oblique, straight-on, tower close-up; two captures each).
- **Label sizing.** `label()` sets `TextScaled = true`, and the rebuilt CATEDRAL sign goes through it. Constraint 6 asks for a fixed TextSize on long labels. It is not changed without a visual check, because a blind change can clip the sign.
- **Roof tiles** are ribs on a flat slab, as before. There is no tile texture.
- **Dark panels in the before shot** are `Workspace.World.CreditsBoard` (not Site01's model; `credits.luau` owns it). Not changed.
