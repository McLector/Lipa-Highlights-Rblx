# Site 06 brief - The Outlets at LIMA Estate + Aboitiz Pitch

Site row: id 6, key `Outlets`, pos (550, 0, -650), facing SW, footprint 300 x 200 (local x +-150, z +-100), massScale 2.5.
Names stay as in the sources: "The Outlets at LIMA Estate" (renamed 2025, formerly The Outlets at Lipa). **LIMA Estate spans Lipa and Malvar**, so the model shows the boundary only as a labelled panel with the detail marked `[VERIFY]`; no invented geography.
Photos are in `Lipa_structure_Exterior_References/05_The_Outlets_LIMA/`. No photo textures (rights are withheld); every surface is a plain coloured part, and signage is SurfaceGui text.

## Requirement source (`modern_lipa_highlights_wt_details.md`, "What You Could Display")
"An outdoor shopping street and sports field, alongside a small model explaining the estate." Mapped to the four SiteData props:
`ShopStreet` (outdoor shopping street), `SportsField` (the Aboitiz Pitch with its stand), `EstateModelPedestal` (the small model), `LipaMalvarPanel` (the Lipa/Malvar boundary panel).
The details md also says the place stands for shopping, dining, recreation and the city's relationship with a growing industrial economy; that is dialogue material for Slice 12, not geometry.

## Frames (important)
The site pivot is yawed to SW (LookVector = (-0.707, 0, 0.707), RightVector = (-0.707, 0, -0.707)). The builder does **not** use the pivot as its origin.
- `ORIGIN = CFrame.new(pivot position)`: world-aligned, +X east, +Z south. Used for grounds, parking, pitch, stand.
- `SH = ORIGIN * CFrame.fromMatrix((-10, 0, -50), SE, up, SW)`: the shop frame. Local +Z = SW = the frontage / outward direction, local +X = SE (0.707, 0, 0.707). Built with `fromMatrix`, not a yaw, so the axes are explicit.
- A SurfaceGui that faces the frontage sits on the part's local +Z face = `Enum.NormalId.Back`.

## Reference photos (one block, identified)
The notes say different blocks have different designs, so the model is **one** identified block plus a visibly separate neighbour:
1. `Outlets_Corner_Storefront.jpg` and `Outlets_Storefront_Front.jpg` define the **corner unit** (`ShopBlock`): two-storey glass storefront inside a deep orange timber-look frame (two end legs, a deep top band that overhangs, a soffit with downlights), a brown cantilevered canopy between the floors, a black side panel with white "PARK OUTLET" text, slim trees, string lights, bollards, the wayfinding pylon.
2. `Outlets_Facade_and_Covered_Walkway.jpg` defines the **white neighbour** (`WhiteWing`): white render, one tall orange accent panel, brown shed awning, steel posts. It has its own, lower roofline and solar panels (`Outlets_Aerial_Oblique_01.jpg`).
3. `Outlets_Entrance_Sign.jpg` defines the **entrance sign**: white slat frame, "%" in red, "THE" dark, "OUTLETS" in multicolour letters, black stripes painted on the paving in front.
4. `Aboitiz_Pitch_Stand_From_Above.jpg` and `Outlets_Whole_Site_Overhead.jpg` define the **pitch and stand**: turf with white and orange lines, small training goals lined up along the stand side, a tiered concrete stand that curves, a brown canopy with dark-blue solar panels, a fence around the pitch. The stand is on the south side of the pitch in the overhead, the pitch is east of the shops.
5. `Outlets_Aerial_Oblique_01.jpg`: palm-lined road, car park, context.

## Colours (by eye, from the photos)
| Element | Colour |
|---|---|
| Orange timber-look cladding | (200, 100, 55) with alternate planks (192, 94, 50) |
| White render | (236, 234, 228) |
| Brown canopies, awnings | (90, 50, 40) |
| Dark core, black panel | (28, 30, 36) |
| Glazing | (60, 76, 88), Glass, 0.3 transparent |
| Turf | (50, 130, 60); lines white and orange (210, 110, 40) |
| Concrete stand | (190, 188, 182) |
| Brick forecourt | (74, 72, 76) |
| Solar panels | (28, 44, 92) |

## What is built (frame in brackets)
- `Structure/ShopBlock` [SH]: `ShopBody` (dark core), glazing with mullions on both storeys, orange frame (planked end legs and a planked top band overhanging 4 studs), soffit with 8 downlights, brown canopy on 8 brackets, black side panel with "PARK OUTLET". Storeys 12 studs, doors 11.
- `Structure/WhiteWing` [SH]: white block to the SE of the shop, orange accent panel, brown shed awning, glazing, a 12-panel solar array.
- `Structure/Walkway` [SH]: `WalkwayRoof`, the covered walkway continuing the canopy along the wing, on 4 steel posts.
- `Structure/Stand` [ORIGIN]: south of the pitch; three straight segments angled to suggest the curve, five tiers, white back wall, brown canopy with solar strips, a stair. `StandTiers` is the single anchor part for the guard.
- `SportsField` [ORIGIN]: `PitchTurf` 62 x 96 at x 90..152, z -96..0; lines, two full goals, five training goals, perimeter fence, four floodlight masts.
- `ShopStreet` [SH]: brick forecourt slab (0.4 thick), connecting path, slim trees in planters, string-light poles with bulbs, bollards, wayfinding pylon with text rows, benches.
- `Grounds` [ORIGIN/own frame]: entrance sign with striped paving, entry path from the road mouth, car park with bay lines and a few cars, light poles, palm rows, hedges.
- `EstateModelPedestal` [SH]: plinth, glass case, miniature white and orange blocks and a green pitch, label "LIMA ESTATE MODEL".
- `LipaMalvarPanel` [SH]: standing board, title "LIMA ESTATE SPANS LIPA AND MALVAR", two halves "LIPA CITY" / "MALVAR", body "[VERIFY] map and boundary detail added at the Slice 12 content gate".

## Keep clear (existing, kept by the builder; local to the site centre, +X east, +Z south)
Guide at (-21, +21); InfoPanel at about (-8.5, +25.5); JeepStop pad at (-35.4, +7.1) (10 x 10); Jeepney at about (-45, -3) (10 x 16). **The jeepney ride lands the player at JeepStop + 5 studs up, facing SW** (`JeepneyServer`: `CFrame.new(stopPos + (0,5,0))`), so nothing may stand within 10 studs of the pad, and the straight path from the pad to the Guide stays open.
Nothing is stacked under that cluster: the forecourt slab ends 12 studs short of it (shop-frame z 18..42) and a 6-stud path joins it to the pad, so the pad (top y 0.4) never z-fights with a slab. A build step queries the landing box, the Guide box and the path for overlaps with built parts; the result goes in the handoff.
The road mouth is at (-120, +100); the entry path starts there.

## Ground
No terrain change (world.luau, world_check and the cell count stay as they are). Every paved or turf surface is a part at least 0.4 thick, so grass blades do not show through.

## Approximated
One block stands in for the complex; the curved stand is three straight segments; lawns and the landscaped garden are plain terrain grass plus hedges; roofs are flat; no interiors; the logos in the photos are replaced by text.

## Revision 1 (Slice 16): approach road, junction, roofs and layout
New references (credited in `content/site_credits.md`): eight Commons junction photos by Judgefloro (CC0, 2019-09-23, `Category:The_Outlets_at_Lipa`) and the LIMA Estate 2025 drone shot (Aboitiz Economic Estates, CC BY-SA 4.0). The Commons set shows only the road side (no shop block or pitch), so the shop facades, pitch and stand keep following the architizer photos above. Decisions with the user: use Commons for the junction, drone shot for layout and roofs, and the recommended middle scope (one extra block, not a full cluster).
Real vs model, and what changed (origin frame unless "SH"; `tests/site06_check.luau` pins every number):
| Area | Real | Now built |
|---|---|---|
| Road | light-grey concrete, black and yellow kerbs, zebra crossing | `EntryPath` 16 wide (x -128..-112), 34 painted `KerbBlack`/`KerbYellow` segments, 7 `ZebraStripe` at z 91 |
| Sidewalks | light interlocking pavers | two 0.4-thick `PaverStrip` (5 x 68) |
| Avenue and lamps | royal palms both sides, cobra-head lamps, purple banners | 4 avenue palms, 4 lamps with `LampBanner` ("NOW OPEN"), 2 orange `WaterBarrier` |
| Island | ~30 clipped round shrubs, foxtail palms, lava rock, yellow chain bollards | `IslandLawn` x -150..-136, 28 `Topiary` in five greens, 3 palms, 2 `IslandRock`, 7 `ChainBollard`, 6 `ChainLink` |
| Billboard | roadside, steel frame, "%/OUTLETS" | `BillboardPanel` 24 x 10 on 2 posts at x -152, bottom 17 above ground, text only |
| Pylon | tall stacked tenant panels, red chevron | `PylonBody` 26 tall at (-94, 98), 7 `PylonSign` (generic names plus ABOITIZ PITCH), `PylonChevron` red on `PylonChevronDark` |
| Entrance | low white office, red door, canopy | `OfficeBody` 10 x 9 x 12 at (-87, 86), `OfficeDoor` 8.6 high, `OfficeCanopy` on 2 posts |
| Roofs | blue solar, brown-maroon fascia | `ShopSolar` (6) on the shop block, `WingFascia`, `SecondSolar` (8), `SecondFascia` |
| Layout | many blocks round courtyards | `SecondBlock` (SH x 56..92, z 46..60, 22 high) across a courtyard: `CourtyardLink` slab, 2 `CourtyardPlanter`, 4 `CourtyardShrub` |
| Pitch side | long maroon and white block along the pitch | `PitchBlock` 9 x 10 x 72 at x 77, 6 `PitchBlockSolar`, 3 `PitchBlockDoor` |
| Pitch | bright turf | `PitchTurf` (44, 152, 62); the south fence was dropped because the stand closes that side |
The car park slab moved 9 studs south (z 62..106) and is light concrete; the old flat `Hedge` boxes and the old 11-stud pylon are gone. Kept and untouched: Guide, InfoPanel, JeepStop, Jeepney, the entrance sign, estate pedestal, Lipa/Malvar panel, stand, walkway.
Not measured: the drone shot's compass orientation (assumed pitch south-east of the cluster, as built); the pylon tenant list is generic, not the photographed shop names. No terrain change. Parts 512 -> 687.

## Art-observation hooks for dialogue (Slice 12 will source them)
Strong colour contrast of warm orange timber cladding against white render and dark glass; deep overhangs that create shade and a clear horizontal rhythm; repeated vertical slats and planks; open green pitch against the dense block of shops.

# Revision 2 (Standard tier, 2026-10-31): rebuilt from "The Outlets at Lima Estate Blueprint.png", slot moved - supersedes the layout above

Source: `..\2nd Reference\outlets_lima_lipa\3d blueprint\The Outlets at Lima Estate Blueprint.png` (3-D view, site-plan inset, promenade, elevation, pitch and monument insets) and `outlets_lipa.jpg`; plan `scratch/standard_tier_plan.md` "06 Outlets". Owner decisions: the whole estate at one uniform 1.05 studs/m, slot 450 x 300 at (550,-700) (x 325..775, z -850..-550, the south edge flush with Road B's end), facing SW, parts only (no terrain writes), no brand logos, human-scale parts fixed.

## Slot and data
- `SiteData` row 6: pos (550,0,-700), size 450 x 300, `guideLocal` (65.3553391, -35.3553391), `panelLocal` (59.3553391, -47.3553391). Measured in Studio before the move: Guide HRP (528.787, 3, -628.787), JeepStop (514.645, 0.2, -642.929), InfoPanel (541.515, 5, -624.544); the locals are the old (30, 0) and (24, -12) plus the centre shift 25 * sqrt 2. No `jeepLocal`: the default (20 to the right of the Guide) already lands on the stop, and a `jeepLocal` row would switch sites_check to its "own curb, 40..90 studs from the Guide" rule (the stop is 20 away).
- Ground: raycasts every 20 studs over x 315..785, z -860..-540 hit terrain Grass (or the old Pavement patches) at y 0.0 everywhere, so the new strip z -850..-750 has ground and no slab was needed for that.
- The rendered terrain does NOT match its physics: a 0.5-thick turf at y 0..0.5 was invisible from 15 to 300 studs (Grass renders up to about 0.9, the old Pavement patches up to about 1.25 above the physical y 0). So every paved, turf and court area is a DECK slab from world y 0 to 1.3 (the project's walkable step) and everything standing on it is lifted 1.3 (`DECK` and `section(..., lift)` in `builders/site06.luau`). Inlays (spine, walks, oval, markings) stand at most 0.1 above a deck. Only the arrival plaza round the kept Guide / JeepStop / Jeepney / InfoPanel (x -64..4, z 30..100) stays the bare terrain Pavement, a 1.3 sunken court; the kept objects are untouched.

## Model (local frame: origin (550,0,-700), +X east, +Z south; the estate is z -118..150, the tree belt north of it)
`builders/site06.luau` is a coordinator in the site05 pattern (KEEP list Guide, InfoPanel, JeepStop, JeepSign*, Jeepney, LocalNPCs; MODULES; every container <= 400; PART_BUDGET 2500; `WorldPivot = lookAt(ORIGIN, ORIGIN + SW)` written explicitly; asserts no PrimaryPart).
- `site06_retail` (Structure/RetailWest, RetailCentre, RetailEast): 19 blocks plus the identified ShopBlock, placed from the site-plan inset: white render, terracotta roof rims on four sides, dark glass storefronts with mullions, 1-2 doors 8.8 high, sign band, brown awnings, upper glazing on the 16-high blocks, side and back glazing, an orange timber volume (3 high above the roof, ribs, glass slot) on 15 blocks, solar strips in rows over every roof, a roof unit. Five west blocks turned 10..30 degrees. ShopBlock (x 5..35, z 7..37, 20 high): orange timber frame (2 legs, band with 8 planks, soffit with downlights), 6 dark glass panes, brown ShopCanopy between the floors, the covered walkway WalkwayRoof in front on 5 posts.
- `site06_promenade` (ShopStreet, Landscape): the cluster deck (7 ClusterPaving pieces), the spine (x -52..-18, z -20..30) to the oval plaza (stadium 30 x 48 at (-34,-40): paving, lawn, ring, inner lawn, centre planter and tree, 4 paths, 2 benches), 4 covered walkways (159 studs of canopy, 15 posts), outdoor dining (4 sets), string lights, lamps, the entry walk from Road B's mouth to the plaza, the ShopBlock walkway paving, the pitch walk; plaza edge fittings (5 planter trees, 4 lamps, 3 benches) on the bare plaza; the north-west landscaped garden (lawn deck, 6 winding path segments, round node, trees, shrubs); trees between the blocks; the north tree belt, the west strip, palms on the verges.
- `site06_parking` (Parking): the north-east court (x 62..186, z -98..-18, 4 rows, 80 bay lines, 2 tree islands and a planted north strip, 5 lamps, 34 cars), the west court (x -210..-172, z 30..120, island, lamp, 8 cars), the south court beside the stand (x -2..44, z 100..134, 4 cars). Cars and bays human scale (car 5 x 10, bay 6 x 12).
- `site06_pitch` (SportsField, Structure/Stand, Structure/PitchHouse): turf deck x 49..187, z -1..96 (long axis E-W as on the board), FIFA lines at 1.05 studs/m (110 x 71.4: touch, goal, halfway, centre circle, penalty and goal areas, spots), mowing stripes, 2 goals 12 x 6 (human scale) at the E and W ends, 3 training goals, 2 dugouts, fence N/W/E with a west gate, 4 floodlights, the "ABOITIZ PITCH" sign at the west gate facing the promenade; the curved grandstand on a concrete apron (9 segments round (118,-128), front radius 236, middle 7 further south than the ends; 4 tiers, white support building with an orange band and 3 doors, brown roof with solar panels, 2 aisle stairs); the brown-roofed support pavilion at the pitch's north-west corner.
- `site06_entrance` (Grounds, EstateModelPedestal, LipaMalvarPanel): ring road decks (S, W, E, N), the EntryRoad wedge ramp down to Road B's end (x -126..-114, y 0 at z 150), zebra crossing, lamps, a palm, the slatted "% THE OUTLETS" monument at (-90,121) facing SW (10 front slats, 4 rear slats, lettering panel, bed, shrubs), perimeter hedges; the estate model on a plinth (on a 1.5 base, above the rendered plaza terrain) and the Lipa/Malvar panel on the plaza, words unchanged.

## Tests first
- `tests/site06_check.luau` rewritten in groups (`shared.site06_only`): red against the Slice 16 model 32 passed / 57 failed (89). First build 86/3: two build faults fixed (GardenShrub reached y -0.6; the part floor) and one test bug (the monument text is RichText, so the colour tags split OUTLETS; the pin now strips tags first). Then 89/0. After the deck finding, new pins written first and shown red on the pre-deck model, 89/2 (decks 1.2..1.45 high; bench seat above the surface beneath), then the deck build: 91/0.
- `SiteData_Test`: [6] position row replaced, the "rows 3 to 9 keep the old formulas" loop skips 6 (one line, beside the Farm's skip of 7), new case "row 6: slot (550,-700) 450 x 300 ..." pinning the literal world positions (tolerance 1e-3, float32). Red: 48 run, 3 failed (2 of them row 6; the third was the Farm's row-7 case, not yet applied then); green 48/0 after the SiteData edit.
- `sites_check`: no edit needed. Its three site-6 guards stay true with the new anchors: WalkwayRoof is 16.6 studs SW of ShopBody, PitchTurf is 98 east of it, StandTiers is 62 south of the turf.

| Old pin | Replaced by |
|---|---|
| pivot at (550, 0, -650) | (550, 0, -700), facing SW |
| part count 600..2500 | 1700..2500 |
| every part inside footprint +10% (abs x <= 165, abs z <= 110) | every built part inside the slot itself (x -225..225, z -150..150) |
| JeepStop at local (-35.4, 7.1), Guide at local (-21.2, 21.2) | the same world points as literals (514.6, -642.9), (528.8, -628.8); InfoPanel (541.5, -624.5) added |
| Slice 16 junction: EntryPath 16 wide, KerbBlack/Yellow, ZebraStripe at z 91, PaverStrip, lamp banners, palm avenue, IslandLawn, 24 Topiary, IslandRock, ChainBollard/Link, WaterBarrier, Billboard, Pylon (7 tenant signs, chevron), entrance Office, CarParkSlab z 61+ | not on the board: names retired (pinned unused); entrance group: EntryRoad at Road B's end, ring road, slatted monument within 45 of the mouth facing SW, hedges |
| 12 SolarPanel, 6 ShopSolar above y 34, WingFascia, SecondBody x 56..92 z 46..60 and its fascia/glass/door/solar, CourtyardLink/Planter/Shrub | retail group: 18..24 white low-rise bodies (12..22 high) spread over the west two thirds, no overlaps, 3+ turned, 10+ timber volumes, 70+ solar strips, 18+ dark glass, 18+ doors 8.5+, 18+ terracotta rims; ShopBlock frame, glass and canopy |
| PitchTurf 62 x 96 at x 121 (G 140+) | 120..140 x 84..100, centre x 105..130, z 38..58, G 140+; E-W goals; white field markings; ABOITIZ PITCH sign; fence; 4 masts 24+ |
| StandTiers kept with 5 StandStair | stand south of the turf by 30+, 24+ tiers, curved (middle front 5+ further south), roof with solar, 3+ doors 8.5+ |
| PitchBlock x 70..84 with fascia, solar, doors | retired (not on the board); the brown-roofed pavilion at the pitch's NW corner |
| EntranceSign / Plinth / PanelTitle / ShopCanopy / WalkwayRoof kept | props group (texts exact) plus the ShopCanopy and WalkwayRoof pins |
| (after the first build) bench seat top 1.8..2.4 from y 0 | measured above the surface beneath the seat (benches on decks stand 1.3 higher) |
| (after the first build) clear-group boxes count any part with top > 0.6 | the named ground layers (decks, inlays, markings) are skipped by name; everything else as before |

## Verification
Coordinator run twice: 1787 and 1787 parts (built 1700, kept 87; retail 578, promenade 480, parking 375, pitch 196, entrance 71; largest container Parking 375). npcs ({only = {6}}) re-run after the final build: the FootballPlayer moved to (650, -660) facing west (the goals are now E and W); the shoppers keep (575,-645) and (566,-652), now on the walkway deck. site06_check 91/0; BuildCheck 06 15/0 (1787 parts); sites_check 277/0; npcs_check 237/0; guides_check 123/0; routes_check 16/0 (Edit); roads_check 281/0; qa_check 116/0; placeholders_check 32/0; unit suite 282 run / 0 failed. filler_check 42/2: Bldg098 (x 258..285, z -572..-538) now lies inside the Outlets box (footprint +10% +24 reaches x 278.5); the world part count is 21662 (over the 20000 cap with every agent's work).
The site total (1787) is under the 2000..2300 asked for: the world was already at 21658 parts with the Farm and Malarayat rebuilds, so the build was not padded.

## Board vs model
| Item | Result |
|---|---|
| ~20 low-rise blocks round the promenade: white render, orange timber volumes, dark glass, solar roofs | MATCH in kind; DIFF: sparser than the board's dense clusters, no open-air courtyards inside the blocks |
| Central promenade with the oval plaza north of it | MATCH (spine and stadium oval) |
| Parking courts W and NE with islands and cars | MATCH; DIFF: the west court is smaller than the 3-D view's, no east-side parallel parking |
| Aboitiz Pitch with markings, curved grandstand with solar roof, support pavilion | MATCH; DIFF: goals 12 x 6 (human scale, not 7.7 x 2.6), stand of 9 straight segments with a flat roof |
| Slatted "% THE OUTLETS" monument at the SW entrance | MATCH; DIFF: the entry is at Road B (local x -120), about 45 east of the board's |
| Perimeter road and tree belt | MATCH, simplified |
| Arrival plaza round the kept Guide cluster | DIFF: not on the board; a bare 1.3 sunken court so the kept objects stay untouched |
| Estate proportion | DIFF: 450 x 268 from the printed 430 x 255 m; block positions read off the inset with a 1.12 stretch along z |

## Open for the orchestrator / owner
- Pre-existing, kept objects: the JeepStop pad (top 0.4) is hidden under the rendered plaza Pavement (close capture), and the Guide's feet sink into it slightly. Not touched (kept set).
- filler_check: Bldg098 must move west of x 278.5 (filler agent's file).
- Text change table: dropped with the Slice 16 junction: "PARK OUTLET", "NOW OPEN" banners, the billboard "% THE OUTLETS / ALL-OUT ON GREAT DEALS. GREAT FINDS.", the pylon tenant list; "ABOITIZ PITCH" kept as the pitch sign (same words, new place). Monument, model and panel words unchanged (now fixed TextSize). Dialogue unchanged and still true (orange timber block against white walls and dark glass, long canopy along the covered walkway, slatted sign by the road, the big field). TourContent's "pickleball and basketball courts" are not built.

## Tidy round (owner, 2026-10-31)
8 chaining bars added (WestMidBar, WestNorthBar, WestBar, CentralNorth, OvalNorth, SpineWestN, SpineEastN, EastBar; 28 bodies); the spine is a central path between two SpineBed lawn beds with trees, shrubs and benches; 14 OvalShrub and 4 rim trees round the oval; two raised PlazaBed beds with 5 trees on the arrival court (the planters at (-36,97) and (-20,97) and the bench at (-12,46) went); 23 more trees and 8 palms (3 on the NE island). Pins first, red 90/7 then 97/0: REPLACED "18..24 retail block bodies" -> 24..32; new: 16+ bodies within 4 studs of another, green SpineBed beds with 6+ trees, 12+ OvalShrub, 2+ PlazaBed beds with 4+ trees, 220+ TreeCrown and 24+ PalmTrunk, 22+ trees and palms on the parking islands. One build fix: a tree at (-50,103) touched the walk lane, moved to (-44,103). Coordinator twice: 2120 / 2120 parts (built 2033).
