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

---

# Slice 4 step B (2026-10-27): the plaza and its surroundings follow the plaza blueprint

Source: `2nd Reference/cathedral/3d blueprints/Metropolitan Cathedral Blueprint Plaza Plan.png` (its label text is garbled AI text and is never a fact or signage). The church (`Structure`, including the wing) is pinned: 5 children, 763 parts, box (-48.2, 5, -100.8)..(121.2, 89.5, 9.8), five biggest parts and colours; `tests/site01_check.luau` asserts it.

## Orientation (drawing to world)
The facade faces +Z toward the forecourt, so the drawing's near side (G.A. Solis St, the tower) is -X, the far side (C.M. Recto Ave, the garden and gate) is +X, and the plaza beyond the retaining wall is +Z.

## Added or changed (all inside existing replaced components)
| Drawing | Built |
|---|---|
| Walled parking forecourt, many cars | 16 cars (8 added in the empty bays) |
| Small statues down the middle | 6 `StatuePlinth` / `StatueFigure` along x +-9 |
| Red-brick retaining wall and steps | `RetainBrick` facing (x -120..-76, 98..120), the seating tiers recoloured brick red |
| D-shaped stepped monument mound with looped ribbon | `MoundTier` x3 + `MoundTierFlat` x3 at (108, 36), 3 steps of 1 stud, two `MoundRibbon` rings |
| Walled garden with trees | 8 trees (`GardenTree*`) in the beds, black iron fence (`GardenFence*`) |
| Gateway arch on the C.M. Recto side | `Gateway*` iron arch on stone piers at (110, 18) |
| Lipa Cultural Center | `CulturalCenterBody` x 80..98, z 66..82, 2 storeys, flat parapet, arched windows |
| Open-air stage pavilion, dark peaked roof | `StageDais`, `StageRoofL/R`, posts, white back wall at x 82..98, z 85..97 |
| Palm-planted green strip | `GreenStrip` at x -72, z 56..90 with 5 palms |

## Kept although the drawing differs (existing assertions, owner decisions)
Terracotta paving (drawing: grey grid), the fountain and statue on the axis, the vaulted `CoveredCourt` (the new pavilion stands beside it), the pergola ring, the kiosks, and the wing's direction (it lies inside the pinned `Structure`).

## Other fixes
The CATEDRAL labels (wing entrance, welcome arch) use a fixed `TextSize` sized to the face; the CreditsBoard keeps 4+ studs clear (palms, planters, fence, arch and pergola ring moved or shortened; the arch sits at z 100.8).

---

# Slice 4 step B round 2 (2026-10-27): lot, paver square, stage, Cultural Center, mound, strips

The owner saw round 1 and called it a partial match. Same source drawing (labels garbled, never facts). The church (`Structure`, 763 parts) is untouched and pinned.

## What changed (all inside existing replaced components, so the builder stays idempotent)
| Drawing | Built |
|---|---|
| Big walled asphalt parking lot, yellow bays in rows, 25+ muted cars, small statues down the middle | `ApronPaving` is asphalt (62,64,70, x -100..64, z 10..48); 48 `ParkingBayLine` in two rows plus 4 aisle lines; 35 parked cars of 4 parts each (muted colours, slots skip every lamp, statue, the monument, the kiosks and each kept prop); 7 statues; the 6 lot palms are gone |
| Large grey grid-paver plaza with a big shade tree, lamps, lawn square, palm strips | `ForecourtPaving` grey (150,152,158), 27 `PaverJoint` grid lines, `LawnSquare` 24 x 21 ringed by 8 palms, `GreenStrip` (west) and new `GreenStripE` with 5 palms each, 6 lamp posts, `ShadeTreePlanter` and a 20-wide canopy at (45, 68) |
| Stage pavilion (dark peaked roof), Lipa Cultural Center | `StageDais` 26 x 12, 10 posts, dark roof (rise 5, ridge 27.6 long, top about 19), `CulturalCenterBody` 28 x 15 x 24 with 15 arched windows, a door, 6 pilasters, steps (x 70..98, z 64..79) |
| D-shaped mound with a looped ribbon, walled garden with a gateway arch | mound tiers r 11 / 8.5 / 6 (22 x 22, straight run = radius so nothing hangs over the wall), 32 ribbon bars 1.0 thick rising 17 studs; garden shrunk to x 66..92 (flag at x 72, entrance open on its east side z 12..33); gateway arch R 6.5 with 0.7-thick bars, posts 3 wide, top 16.9 |

Removed from the plaza: the vaulted `CoveredCourt`, the pergola ring and its columns, the terracotta paving and cream inlay bands, the east flower bed, the lot palms.

## Old assertions replaced or removed (rule 4; each replaced by a drawing-based assertion)
| Old name and text | Reason | Replaced by |
|---|---|---|
| "lower paving is terracotta, as in the ground photo (R >= 180, R - B >= 60)" | drawing: grey grid pavers | "lower paving is grey grid pavers (R, G, B within 24 of each other, 120..190)" plus "ForecourtPaving is 150+ wide and 45+ deep with 20+ PaverJoint grid lines" |
| "CoveredCourt stands on the lower plaza: z >= 70, 36+ studs wide, ground level, x >= 34 (east of the open centre)" | the drawing's plaza has no vaulted court | "the vaulted CoveredCourt is gone" |
| "the court roof is a curved vault: 7+ VaultPanel parts at 5+ distinct tilts, each 36+ studs long" | same | folded into the same "is gone" assertion (VaultPanel, CourtPost, VaultRidge count 0) |
| "PergolaRing is a raised round bed at ground level, 18+ studs across, on the lower plaza west of the open centre" | drawing has a lawn square, not a pergola ring | "the pergola ring is gone" plus the LawnSquare assertion |
| "pergola: 6+ white PergolaColumn posts on the ring's south side ..., 6+ PergolaBeam and 4+ shrubs" | same | same |
| "Lipa Cultural Center: a cream block 14+ studs wide and 20-30 tall at x 78..99, z 64..84, ..." | NOT on the owner's named list. Its x >= 78 bound forced the 18-stud box that was too small to read at blueprint scale (item 3 of this round); the owner's rule 3 and the drawing outrank it | "a cream block 26+ wide, 14+ deep and 22-30 tall at x 68..99, z 64..84 ...", same colour, flat top, z >= 64 |
The fountain, kiosks, stairs and seating stay (owner-approved to replace but not needed); their assertions are untouched.

## New assertions (all red first, 91 passed / 17 failed, then 108/0; the mound-overhang one found by the advisor was red too)
Asphalt lot (dark grey, Asphalt material, 150+ x 36+), 40+ bay lines in two rows, 25+ cars of at most 5 parts, muted colours, no car overlaps a lamp, statue, monument, Guide, InfoPanel, JeepStop or Jeepney; paver grid; LawnSquare with 6+ palms; second strip with 4+ palms; 6+ lamps; shade tree planter and canopy 16+ wide; stage footprint, ridge and 8+ posts; mound size and ribbon; gateway size; garden at x 64..94 with the flag at x 70..74; mound stays on the podium and clears the gateway posts.

## Kept although the drawing differs
`LongBuildingW` (long arcaded building on the plaza's west side; its old assertion is not on the approved list; it hides part of the plaza in the blueprint view), the fountain and kiosks, the wing direction (inside the pinned `Structure`), the stacked layout of lot above plaza (the church faces +Z, so the drawing's side-by-side lot and plaza cannot be reproduced), the west `PodiumLawn` with palms beside the tower (no assertion protects it; left alone).

## Numbers
Site parts 1967 -> 2018 (+51); built 1948; church pin unchanged (5 children, 763 parts, box (-48.2, 5, -100.8)..(121.2, 89.5, 9.8)). routes_check: Road C 182 and Road A 409 studs failed the 170 / 400 limits when the garden's east fence closed the corridor; the fence now leaves z 12..33 open (14/14 pass).


## Slice 4 step B round 4 (plaza and surroundings against the owner's ROTATED plan)

Orientation key (confirmed on scratch/refs/cathedral-plaza-rotated.png): church at the TOP, facade facing DOWN = +Z (south). LEFT = WEST (-X): G.A. Solis St, the tower side, the long red-roofed parish and archdiocese wing (3 storeys beside the church, 2 along the lot, cream with arched windows). RIGHT = EAST (+X): C.M. Recto Ave, the walled garden and the gateway arch near the church. Stacked, north to south: church, walled asphalt lot (upper level, y 5), red-brick retaining wall with steps, lower grey-paver plaza (ground). Plaza: stage pavilion SOUTH-WEST, Lipa Cultural Center along the EAST edge, D-shaped mound at the WEST-MIDDLE against the wall, lawn square, palm strips, shade tree. Round 3 (side-by-side lot and plaza) was wrong and discarded.

### What changed
| Drawing | Built |
|---|---|
| Long wing down the west edge, 3 storeys by the church, 2 storeys along the lot | New component `ParishWing` (podium level): `ParishWingBody` ranges x -120..-104 (3 storeys z -98..-12, 2 storeys z -12..16 and 36..46; the gap z 16..36 keeps SideStairsW open, a deliberate deviation from the drawing), two 3-storey `ParishWingCrossBody` ranges toward the tower (x -104..-52) round a courtyard, red `ParishWingRoof`, 74 arched windows, 2 doors 9.5 tall. `LongBuildingW` moved to x -120..-104 (2 storeys, red roof, 22 windows, 2 doors) so the wing runs z -98..98 |
| Bare grey slab and lawn with palms west of the tower | Removed (`PodiumLawn` west, 5 palms); `ApronPavingNW` asphalt x -104..-50, z -46..10 takes the place |
| Lot full width between wing and garden wall, many cars | `ApronPaving` x -104..64; 37 cars (kiosk blockers removed); 48 bay lines; statue row unchanged |
| Brick wall with steps | Fountain, kiosks removed; `StairFlightC` (x -8..8) joins `StairFlightL/R`; brick tiers kept |
| Stage SW | `StageDais` mirrored to x -99..-73, z 82..94 (roof, posts, back wall on the west) |
| Cultural Center along the east edge | `CulturalCenterBody` 22 x 24 x 30 at x 76..98, z 64..94, door and steps on the plaza face |
| Mound west-middle | Moved from the podium NE corner to the ground at x -99..-77, z 49.3..71.3, flat side on the wall; ribbons 14+ above ground |
| Palm strip, flower beds, lamps | Strip x -71 z 56..80; beds beside the Cultural Center; two lamps shifted 2 studs |

### Old assertions replaced (rule 4; none loosened silently)
| Old name and text | Reason | Replaced by |
|---|---|---|
| "FountainBasin stands on the lower plaza on the wall axis ..."; "fountain has 2+ FountainWater surfaces ..."; "FountainStatue is on the axis ..." (3) | the drawing has no fountain on the centre line | "no fountain on the wall axis" and "StairFlightC fills the wall axis" |
| "StairFlightL / StairFlightR: ... beside the fountain (5 -> ...)" | text only: the conditions are unchanged | same conditions, text "down the wall" |
| "EventStage folder holds the fountain, both flights and the seating ..." | no fountain | "EventStage holds the three flights and the seating" |
| "2 kiosks (KioskBody) stand on the podium ..."; "kiosk roofs are orange and stepped ..." (2) | no kiosks in the drawing | "no kiosks (KioskBody, KioskRoof)" |
| "Lipa Cultural Center: a cream block 26+ wide, 14+ deep ... at x 68..99, z 64..84" | the drawing's block runs N-S down the east edge | 18+ wide, 28+ long, x 70..99, z 64..95 |
| "StagePavilion: ... at x 80..99, z 82..99" | stage moves to the south-west | same roof checks, dais x -99..-72, z 80..96 |
| "monument mound: 3+ stepped MoundTier ... far corner x 96..120 on the podium"; "the mound is D-shaped ... straight edge on the wall"; "round 2 mound: footprint 22+ ... ribbon 14+ above the podium"; "round 2 mound stays on the podium (z <= 47.25, x <= 119.5) and clears both gateway posts" (4) | the mound is on the lower plaza at the west-middle | two round 4 mound checks (location, size, D-shape on the wall; ribbon 28+ bars rising 14+ above the ground) |

Two of my own new assertions were corrected after they ran red for test reasons, not model reasons: the mound-ribbon check wrongly compared ribbon height to the podium top, and the door check measured only the rectangular pane (7.4) instead of the full arched opening (9.5).

### New assertions
Wing (ranges on x -121..-103, 3 and 2 storeys, 150+ long with LongBuildingW, side stairs gap, 2+ cross ranges reaching x -56..-50, red roofs, 60+ windows, doors 8+ tall), lot (asphalt spans x <= -100 to >= 62, 36+ cars, old west lawn and palms gone, ApronPavingNW), plaza (stage west, Cultural Center east), mound, StairFlightC, no fountain, no kiosks. Red first: 100 passed / 15 failed against the baseline model, then 115 / 0.

### Numbers
Site parts 2018 -> 2331 (+313); church pin unchanged (5 children, 763 parts, box (-48.2, 5, -100.8)..(121.2, 89.5, 9.8)). routes_check: the first build broke Road C (181 vs 170) because `GardenApron` reached the podium edge at top 5.1 and made the last side step 1.1 high; the apron now stops at x 118 and routes_check is 14/0.



## B3c-0: the owner's colour markup on the Cathedral compound (2026-10-27)

Source: `scratch/refs/owner-markup-cathedral.png` (colour lines on a high oblique screenshot of the compound) and the owner's rotated blueprint. Red = remove, black = replace with fences, blue = remove, magenta = more cathedral building, orange = move the mound and the stage.

### What changed
| Mark | Built |
|---|---|
| Red | `LongBuildingW` and its trim, windows, pilasters and roofs removed; the lot-level `ParishWingBody` at z 36..46 removed |
| Black | the whole west range (z -98..16) and the north cross range, the courtyard lawn and hedges removed; new component `WestFence`: black iron fence 3 studs tall (`IronFencePost` / `IronFenceRail`) on the podium west edge x -119.5 (z -99.5..19 and 33..47, gap z 19..33 for `SideStairsW`), the podium north edge z -99.5 (x -119.5..-52, to the tower) and the plaza west kerb x -100.5 (z 58..99.6, joined to the white south fence at x -96.6). `ApronPaving` and `ApronPavingNW` asphalt now run west to x -119.5; the old courtyard block is `WestLawn` (x -119.5..-50, z -99..-46) with two palms |
| Blue | the south cross range (`ParishWingCrossBody`, z -64..-48) removed; the `ParishWing` component is gone (`buildParishWing` deleted; the name stays in REPLACED so old copies are cleaned) |
| Magenta | new Site component `ChurchAnnex` (153 parts): measured box AnnexBody x 45.4..94, z -99..-42, 26 tall (2 storeys), eave at the wing's WingEave height (local y 26.8), butter-yellow walls, 22 arched windows, red ribbed gable roof (ridge along X) with gable ends, a valley with the wing's back roof. The palm at (60,-72) moved to (106,-72) |
| Orange (mound) | `buildMound`: fully round (no `MoundTierFlat`), centre (0, 69.5): the flights end at z 56, 2.5 studs of ground, tiers r 11 / 8.5 / 6 and both ribbons kept |
| Orange (stage) | the pavilion moved to the centre line: dais (0, 88.5), x -13..13, z 82.5..94.5, white back wall on the SOUTH long side, open to the north, gables at both ends, the step at the east end of the dais; size and look unchanged. 2 studs between mound and dais, 4.8 studs between dais and the south fence line (z 99.3) |

Measured evidence for the annex box: bright marker bars at z -82 and z -99 on the owner's camera angle; the pink line starts level with the z -99 bar (the z -82 bar would sit about 40 px lower), so the north edge is z -99, not the transept's z -82. Details in `scratch/b3c0-journal.md`.

### Deviation from the markup (decided by the builder, please confirm)
The plaza west kerb fence starts at z 58 instead of z 49: a 9-stud pedestrian gate beside the retaining wall stays open. With the fence closed all the way, `routes_check` "spawn -> Cathedral Guide" measured 582 studs (cap 510); the shortest old route enters the plaza from the west at z 50..56 and climbs the west tiers. With the gate it is 476. The cap was not touched.

### Old assertions replaced (rule 4; none loosened silently)
Approved by the orchestrator:

| Old name and text | Why | Replaced by |
|---|---|---|
| "long arcaded building on the lower plaza's west side (LongBuildingW)" | red mark | "B3c-0 no LongBuildingW or ParishWing* parts remain ... no orphan PlazaSquare anywhere in the workspace" |
| "round 4 wing: ParishWingBody ranges on the west edge ... 150+ studs"; "the side stairs stay open (no wing range between z 20 and 32)"; "2+ cross ranges (ParishWingCrossBody ...)"; "LongBuildingW is the 2-storey end of the wing"; "red tile roofs (12+ roof slopes incl. LongRoof ...)" (5) | black, red and blue marks remove the wing, the cross ranges and the roofs | two fence checks: "iron fence runs the west podium edge ... north edge ... plaza west kerb, posts every 6 studs or less" and "iron fence is 3 studs tall and black, 40+ posts, stair gap z 20..32 (and the plaza gate gap) open" |
| "round 4 StagePavilion ... over a raised dais at the SOUTH-WEST (x -99..-72, z 80..96)" | orange mark | same roof, colour and dais-thickness clauses; dais within 4 studs of x 0 at z 80..96, back wall on the south, 4.5+ studs to the south fence line. The size check ("StageDais 24+ wide and 12+ deep, ridge 24+ long ...") is unchanged |
| "round 4 mound: on the lower plaza at the west-middle (x -100..-76), straight edge on the wall ..., 22+ wide, 18+ deep, 3 tiers" | orange mark | "B3c-0 round mound (3+ cylinder tiers, ribbon) centred within 4 studs of x 0, 22+ wide, no flat blocks, south of the stair flights, 2+ studs clear of them". The ribbon check (28+ bars, 14+ above the ground, 0.8+ thick) is unchanged |
| new | magenta mark and the Structure pin | five `ChurchAnnex` checks (Site child of 100+ parts; measured box; touches the wing back wall with its eave within 1 stud of `WingEave`; one block with the church: wall colour, 12+ arched windows, band, red roof, 20+ ribs; no palm inside) and "church Structure untouched: 763 parts, box (-48.2, 5, -100.8)..(121.2, 89.5, 9.8)" |

NOT on the orchestrator's list (the markup contradicts them; please veto if wrong):

| Old name and text | Why | Replaced by |
|---|---|---|
| "round 4 wing: 60+ arched windows (ParishWin_Pane) and 2+ human-scale arched doors" | the wing that carried them is gone | covered by the "no ParishWin_Pane / ParishDoor_Pane left" list in the new removal check |
| "the spawn (0,70) has 8x8 studs of clear ground" | the mound now stands at (0, 69.5); the real SpawnLocation is at (-208, -260), so this box guarded nothing | "walking room round the mound": clear boxes between the foot of the middle flight and the mound and on both sides |
| "the CreditsBoard strip (x +-30, z 90..98) is clear of Site01 geometry" | the stage now stands at z 82.5..94.5; the board is at z 205, so the box was stale. The real board keep-out (4+ studs round the board itself) is unchanged and passes | "walkers pass round both sides of the stage: lanes x +-(15..24), z 83.2..98.8 clear" |
| "the lower plaza has a wide open centre (x -34..30, z 64..88 clear ...)" | the mound and the stage stand on the centre line | "a corridor (x -15..15, z 80.9..82.3) separates the mound from the stage" |
| "round 4 lot: the asphalt spans from the wing (x <= -103) to the garden wall (x >= 62)" | the wing is gone, the asphalt runs to the fence | "from the west fence (x <= -119) to the garden wall (x >= 62)" |
| "round 4 lot: the bare lawn and palms west of the tower are gone (no PodiumLawn or upper PalmTrunk1 at x < -48); asphalt (ApronPavingNW) takes their place" | the markup turns the old courtyard block into lawn with two palms | "WestLawn x -119.5..-50, z -99..-46 on the podium with exactly two palms standing on it; ApronPavingNW asphalt runs west to x <= -119" |
| "round 4 plaza: the stage pavilion is on the west (dais x < -70) and the Cultural Center on the east" | orange mark | "dais abs(x) <= 4 and the Cultural Center on the east (centre x > 40, east face x >= 96)" |

Checks that mention things the builder touched but were NOT edited: "12+ palm trunks" (still passes), "perimeter fence with 20+ posts" (counts the white `FencePost`; the new iron fence uses `IronFencePost`, so it is unchanged), "walled garden ... 10+ GardenFencePost" (unchanged), the CreditsBoard keep-out (unchanged).

### Numbers
Site parts 2331 -> 2121 (built 2051): removed the parish wing (342), the LongBuildingW block (107) and the 3 mound flats; added `ChurchAnnex` (153), `WestFence` (66), `WestLawn` and two palms. `site01_check` 115 -> 117. `build 01 parts` 2331 -> 2121. World parts 8960 -> 8750. Church pin unchanged (5 children, 763 parts, box (-48.2, 5, -100.8)..(121.2, 89.5, 9.8)). `routes_check` 15/0: spawn 476 (cap 510), Road E 203 (cap 320, was 279), Road A 381 (400), Road C 154 (170). Idempotent: a second build gives the same child and part list.

## B3c-0b roads (2026-10-27)

Owner markup: a paved way must run from each bypass straight to the foot of each Cathedral side stair (SideStairsW / SideStairsE, centre z 26, treads at |x| 121..128, foot |x| 128). Added WEST_ENTRY (-170,26)->(-128,26) and EAST_ENTRY (165,26)->(128,26), both 12 wide with joinStart, to RoadData.NEW_ROADS only (ROADS and builders/world.luau untouched; roads_match.js still passes). Paved with builders/roads_extra.luau.

### Exception to an existing assertion (tests/roads_check.luau section 6)
- Old text: `if not (EDGE_STARTS[road.name] and i == 1) then` (every road except the edge starts of A, C and E is checked against the slot's 10 percent margin zone, x -144..144).
- Why: the entrance roads must cross x 128..144 to reach the stairs, so they are inside that zone by design. The slot itself (|x| < 128) stays forbidden.
- New text: `if not (EDGE_STARTS[road.name] and i == 1) and not ENTRY_ROADS[road.name] then`, with `ENTRY_ROADS = { WEST_ENTRY = true, EAST_ENTRY = true }`. Every other road is still checked, and the slot check just above applies to the entrance roads too.
- Compensating assertions (new section 7 of roads_check): each entry ends within 1 stud of the stair foot (|x| 128, same side) and on the stair's centre z, starts on the bypass centre line (axis-aligned, one segment), keeps every point at |x| >= 128, does not touch any tread, and its terrain is Asphalt at the mid-point (x -149 / 146) and at |x| 129 on z 26.

### Further road-rule exceptions (orchestrator decision, owner-visible)
The same two roads also contradicted four more existing assertions in tests/roads_check.luau. They were replaced for WEST_ENTRY and EAST_ENTRY ONLY, all through one shared table at the top of the file, `local ENTRY_ROADS = { WEST_ENTRY = true, EAST_ENTRY = true }` (the section 6 exception above reads the same table). Every other road is checked exactly as before. These are owner-visible exceptions to the road rules.

1. Section 1, margin rule (road widened to w/2+4 must clear every site's real bounds +10 percent; line ~99). Old: `check(road.name .. " seg " .. i .. " margin (w/2+4) clears " .. name .. " bounds +10%", not hit, ...)`. Why: the entrances end at the stair foot, which is inside the Cathedral's +10 percent margin (x -153.6..153.6) by design. Replacement for ENTRY_ROADS against Site01_Cathedral only: the road body (sides w/2, no end caps) must be clear of the Cathedral's real bounds (x -128..128): `not overlap(body, r)`. Against every other site the original margin test still runs.
2. Section 3, "ends on a road centre line" (line ~165). Old: `check(road.name .. " ends on a road centre line", endOn ~= nil, ...)`. Why: an entrance ends at the foot of a stair, on no road. Replacement for ENTRY_ROADS: `ends at the stair foot (|x| 128, z 26)`: `math.abs(last[1]) == 128 and last[2] == 26` (section 7 ties the end to the real stair parts). The "starts on a road centre line" check is unchanged and applies.
3. Section 3, "touches an original road" (line ~175). Old: `check(road.name .. " touches an original road", touchesOriginal)`. Why: both entrances start on a NEW bypass, so neither touches an original road directly. Replacement for ENTRY_ROADS: the road it starts on must be a non-entry new road that itself touches an original road (WEST_BYPASS ends on Road F, EAST_BYPASS on Road G).
4. Section 3, count assertion (line ~185). Old: "RoadData.all() lists the 8 original roads then the 5 new ones (SPUR, two bypasses, two south links)" with `#RoadData.NEW_ROADS == 5`. Why: there are now 7 new roads. Replacement, not a looser number: 8 originals, then exactly these 7 new roads by name and order: SPUR, WEST_BYPASS, EAST_BYPASS, WEST_LINK, EAST_LINK, WEST_ENTRY, EAST_ENTRY.

Guard for the entries is the new section 7 (|x| >= 128, ends at the stair foot on the stair's centre z, starts on the bypass centre line, axis-aligned single segment, no tread contact, Asphalt at the mid-point and at |x| 129).

### Numbers
roads_check 207 -> 260 passed, 0 failed (+53: section 7 adds 19; the rest are the existing per-road checks now also running for the two new roads; every replaced assertion keeps one check per road). Terrain cells 1793852 -> 1793870 (+18, the two 12-wide asphalt strips; run_all EXPECTED not edited, so its cell row and the roads_check count row show MISMATCH until the integrator updates them). roads_extra is idempotent: second and third runs add 0. Measured PathfindingService lengths: spawn -> Cathedral Guide 475.8 (cap 510), Road E 203.1 (320), Road A 381.1 (400), Road C 153.9 (170).

## B3c-0b: the owner's second colour markup on the Cathedral compound (2026-10-27)

Source: `scratch/refs/owner-markup-cathedral-2.png`. Magenta = more parking, orange = the side entrances, green = Cultural Center, blue = white fences to black, red = the gate, black = the statue.

### What changed
| Mark | Built |
|---|---|
| Magenta | 19 cars in two staggered rows (z -36 and -8, x -112..-58 / -109..-61, inside x -115..-55, z -42..6) with 21 `ParkingBayLine` and two aisle lines (aisle z -31..-13); `carSlots` obstruction list now includes both entry walkways |
| Orange | gateway arch, `GatewayPath` moved from z 18 to z 26 (stairs, road and arch on z 26); new `EntryWalkW` (x -117.5..-99) and `EntryWalkE` (x 91.5..100) next to `GatewayPath` (x 100..118), STONE_LIGHT, 10 wide; the garden's east side stays open z 12..33 |
| Green | Cultural Center moved to x -98..-76 (z 64..94), door, steps, pilasters, `FlowerBed`/`BedBloom` and the plaza-face `CCWin` on the east face; the west palm strip moved to x -27 (z 64..83), the old east site is plain pavers |
| Blue | `FencePost`/`FenceRail` colour LAMP_METAL (material Metal) |
| Red | `WelcomeArch` component and builder deleted (name kept in REPLACED); one black south fence run x -100.5..99.4, east line x 99.4 z 49.5..99.6, west kerb line from z 49.5, south kerb closed; the plaza has no gap on the south, east or west |
| Black | the mound is a D (round tiers at (0, 50) plus 3 `MoundTierFlat` blocks from the wall z 48), ribbons 3.5 studs south of the tiers; `StairFlightC` deleted; `StairFlightL/R` centre x +-19 (inner edge 12, 1 stud clear of the statue); bleachers 50 / 72 long, inner edge |x| 26 |

### Found while building: the stair edge
A surface above the podium within 2 studs of the side-stair edge (|x| 120) over the stair width (z 20..32) makes the last riser more than 1 stud for PathfindingService (NoPath for every route). It was already true of the old `ApronPaving` on the west (x to -119.5): the west stair was unusable before. So `ApronPaving` now spans x -117.5..64 with two corner pieces `ApronPavingWestN/S` (x -119.5..-117.5, z 10..20 and 32..48) leaving the stair strip bare, `GatewayPath` stops at x 118 and `EntryWalkW` at x -117.5. New check "nothing rises more than 0.05 above the podium on the stair edge strip".

### Old assertions replaced (rule 4; none loosened silently)
Replaced by renaming the call to `retired(...)` (a no-op defined at the top of tests/site01_check.luau; the old text stays in the file) or by changing the quoted numbers:

| Old name and text | Why | Replaced by |
|---|---|---|
| "round 4: StairFlightC fills the wall axis: 4 treads, tops 4, 3, 2, 1, 16 wide (x -8..8)" (retired) | black mark: the statue stands there | "B3c-0b statue ... no StairFlightC" (D-shape, centre x 0, flat back |z-48| <= 1.5, side flights 1+ clear) |
| "BleacherL/R ... inner edge at |x| 21..23" (numbers changed) | the flights moved out 4 studs | "inner edge at |x| 25..27" (lengths 50+ / 70+ unchanged) |
| "the east fence leaves the lower plaza open toward Road C (nothing at x 99 between z 48 and 68)" (retired) | red/blue marks: east side closed | the three-line gap probe: no open stretch longer than 1 stud on z 99.6 (x -96..96), x -100.5 and x 99.4 (z 49..99.6) |
| 4 WelcomeArch checks (child model 12+ parts; walk-through top 14 / span 12; sign text; two gateposts) (retired; the three nested ones by `if arch and false`) | red mark | "no WelcomeArch component or arch parts remain anywhere in the workspace" |
| "B3c-0 round mound ... centred within 4 studs of x 0, south of the stair flights, 2+ studs clear" (retired) | black mark | the D-shape check above (centre x 0 within 1, flat back on the wall, side flights 1+ clear, nothing above the podium north of z 47.5) |
| "B3c-0 iron fence ... plaza west kerb (z 58..99.6; gate gap z 49..58 open)" and "gate gap (z 49..58) stay open" (numbers changed) | the west gate gap is closed | kerb run z 49.5..99.6; the gate clauses now test z < 49 |
| "round 4 Lipa Cultural Center ... x 70..99, along the east edge" (numbers changed) | green mark | x -99..-70 |
| "B3c-0 plaza ... Cultural Center on the east (centre x > 40, east face x >= 96)" (numbers changed) | green mark | "on the west (centre x < -70, west face x <= -96)" |
| "B3c-0 lot: asphalt spans from the west fence (x <= -119) to the garden wall" (number changed) | stair-edge strip must be bare | x <= -117.4 plus `ApronPavingWestN/S` |

NOT on the orchestrator's list (the markup contradicts them; please veto if wrong):

| Old name and text | Why | Replaced by |
|---|---|---|
| "CATEDRAL labels (wing entrance, welcome arch): 3+ found" (`seen >= 3` -> `seen == 1`) | two of the three labels were the arch sign's two faces | "B3c-0b CATEDRAL label (the wing entrance): 1 found" with the same fixed-TextSize and fit-and-fill clauses |
| "round 4 (replaces 'EventStage folder ...'): EventStage holds the three flights and the seating" (retired) | it required `StairFlightC` | "EventStage holds StairFlightL, StairFlightR and the seating, no StairFlightC, no gazebo stage" |
| walking-room box `moundN` (x -10..10, z 56.4..58.2, "between the foot of the middle flight and the mound") (box moved) | the statue fills that box | the box in front of the statue (x -10..10, z 61.2..63.2); `moundE`/`moundW` and the corridor unchanged |
| second Cultural Center pin in "B3c-0 plaza: stage pavilion on the centre line and the Cultural Center on the east" (numbers changed) | green mark | see above |

The gateway at z 18 was pinned by no assertion; the new checks pin z 26 (arch, SideStairsE, EAST_ENTRY, SideStairsW, WEST_ENTRY).

### Numbers
`site01_check` 117 -> 125 passed, 0 failed (+8 net: 16 new B3c-0b checks, 8 retired). Site parts 2121 -> 2184 (built 2114): +76 car parts, +bay and aisle lines, walkways, MoundTierFlat; -the WelcomeArch. World parts 8750 -> 8813. Church pin unchanged. Idempotent: three builds give the same children, no `WelcomeArch` instance anywhere.

### Routes (PathfindingService in Play, the routes_check method)
spawn -> Cathedral Guide 427.7 (cap 510), Road C 153.0 (170), Road A 380.3 (400), **Road E (0,225) 378.7 (cap 320, OVER)**. WEST_ENTRY -> Guide 171.4, EAST_ENTRY -> Guide 163.8. Road E used to walk in through the south arch gap; with the plaza closed it has to go round to a side stair. No cap and no gap was touched: this needs the orchestrator's or the owner's decision.
