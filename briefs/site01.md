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
