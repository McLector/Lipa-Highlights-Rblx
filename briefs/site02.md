# Site 02 brief — Candido B. Lopez Memorial Public Market

> **Slice 14 relocation (read first).** The town core was crowded (10-20 studs between this site and the Cathedral compound), so the user had the Market moved: **(-230, 160) -> (-330, 160)** (dx -100, z unchanged), a clear gap of about 100+ studs. Every world coordinate in this brief is the ORIGINAL one; add -100 to x to get the current position. The builder follows the site pivot (see the header comment in builders/site02.luau). Terrain: road F now runs along z 160 from Road E (x 0) to x -228, and the paving region moved (x -276..-128 -> x -376..-228); both live in builders/world.luau and tests/world_check.luau. structure_model_positioning.png is not edited: this is a documented deviation from it.

Site row: id 2, key `Market`, pos (-230, 0, 160), facing E, footprint 200 x 160 world-aligned (x -330..-130, z 80..240; paved region x -276..-128, z 80..240), massScale 3.0, **no JeepStop**. Required props (direct children of `Site02_Market`, each holding at least one part): `MarketStalls`, `Baskets`, `Produce`, `PriceSigns`, `VendorNPCs`.
Proper name: **Candido B. Lopez Memorial Public Market** (`[VERIFY]` until sourced). **The photos date from 2014 (facade), 2010 (street) and 2011 (stalls)**; the model shows the market as photographed, and the dialogue must say so. No current rear or aerial views exist, so sides and rear are approximated.
Photos: `Lipa_structure_Exterior_References/03_Lipa_Public_Market/`. No photo textures (rights withheld): plain coloured parts, signage is SurfaceGui text. Brand names and ads in the photos (pharmacy billboard, shop signs) are NOT reproduced; shop signs use generic words ("TINDAHAN", "PRUTAS", "GULAY").

## Requirement source (`modern_lipa_highlights_wt_details.md`, "What You Could Display")
"Several market stalls with baskets, price signs, food, and vendor figures." Mapped to the five SiteData props: `MarketStalls`, `Baskets`, `Produce` (food), `PriceSigns`, `VendorNPCs`. The row says the palengke shows everyday Lipa (food vendors, produce, coffee, local delicacies, small businesses): ordinary community life.

## Frames (important)
The site pivot is yawed to E (LookVector = (1, 0, 0), RightVector = (0, 0, 1)). The builder does **not** use the pivot as its origin.
- `ORIGIN = CFrame.new(pivot position)`: world-aligned, +X east, +Z south. Pivot = (-230, 0, 160).
- `MK = ORIGIN * CFrame.fromMatrix(Vector3.zero, Vector3.new(0, 0, -1), Vector3.new(0, 1, 0), Vector3.new(1, 0, 0))`: the market frame. **Local +Z = E = the frontage / outward direction, local +X = N (-Z world) = the viewer's right when facing the facade**, local +Y up. (Built with `fromMatrix`, not a yaw. X cross Y = Z holds.) World = ORIGIN offset (x = lz, z = -lx).
- A SurfaceGui facing the frontage (east) sits on the part's local +Z face = `Enum.NormalId.Back`.
- Terrain top is y = 0 (Pavement under the whole region); everything sits on y = 0.

## Reference photos
1. `Market_Facade_2014.jpg` (the main reference). A long **two-storey block**, cream/yellow walls (about (222, 190, 110)), **maroon pilasters** (about (120, 40, 40)) at a regular rhythm, **arched ground-floor bays** with gridded glazing, upper storey with a row of windows under **tilted awning shutters** (grey-brown), a **long white sign band** with big blue capitals "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET" (blue (40, 70, 170)) running along the top, a **blue roof edge**, one **exterior diagonal staircase** with a covered rail climbing the facade (south of centre as the viewer sees it from the street: left of centre), a **north-end balcony** with yellow columns and a rail, low **tin-roof stalls** along the ground frontage.
2. `Market_Surrounding_Street_2010.jpg`: the same colours from the street, tarp awnings, tricycles and jeeps in a crowded street, concrete parapets.
3. `Market_Open_Air_Vegetable_Stalls_2011.jpg`: open **concrete yard**, wooden carts and crates, tarp-covered heaps, blue tarp canopies, umbrellas, produce baskets, weighing scales, vendors and shoppers.

## Colours (by eye, from the photos)
| Element | Colour |
|---|---|
| Wall cream-yellow | (222, 190, 110); upper band lighter (232, 214, 150) |
| Maroon pilasters / trim | (120, 40, 40) |
| Name band | white (236, 234, 228); letters blue (40, 70, 170) |
| Roof edge | blue (50, 70, 150) |
| Awning shutters | grey-brown (110, 96, 84) |
| Glazing | (60, 76, 88), Glass, 0.3 transparent |
| Tin roofs | rust (150, 90, 60) and grey (130, 134, 138) |
| Tarps | blue (40, 100, 190), green (60, 150, 80), orange (230, 130, 40) |
| Wood (carts, crates, stall frames) | (150, 110, 70) |
| Yard concrete | (160, 158, 152) |

## What is built (frame in brackets). Anchors are ONE uniquely named BasePart each; no Model/Folder may share an anchor's name.
- `Structure/Hall` [MK]: the two-storey market hall, depth 40 (world x -270..-230, so local z -40..0 from the frontage line), length 150 along the world Z axis (world z 85..235). Storey height 12 (human scale never shrinks; bays are **dropped** to fit, never squeezed). Single anchor part **`HallBody`** = the cream wall block, centred at the hall centre. Maroon pilasters on the east face at a regular rhythm; arched ground bays (kit `arch`) with gridded glazing; upper storey windows with tilted awning shutters; blue roof edge and a flat/low-pitch roof; side and rear walls plain (approximated).
- `Structure/Hall` **name sign**: single anchor part **`NameBand`** = the white sign band on the east face above the upper windows; its SurfaceGui (face `Back`) reads "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET" in blue. `NameBand` must sit on the east frontage (x > HallBody x + 10).
- `Structure/ExteriorStair`: diagonal exterior stair with railings and a sloped cover, in the **south half** of the frontage (viewer's left, local x negative), landing on the upper level. Risers 1 high.
- `Structure/EndBalcony`: balcony with columns and a rail at the **north (-Z) end** of the upper floor on the frontage. Single anchor part **`BalconyDeck`** = its floor. It must be north of HallBody's centre by more than 25 (world z < HallBody z - 25).
- `Structure/FrontStalls`: low tin-roof lean-to stalls along the hall's ground frontage (rust and grey roofs, wooden posts), with gaps for the stair and for the aisle.
- `YardSlab`: **one part, at most 0.3 studs thick**, the concrete trading apron of the yard: suggested x -176..-136, z 90..230 (centre about (-156, 160)). It must be east of HallBody by more than 30 and **must not overlap the Guide keep-clear box**. (The terrain is already Pavement, so no slab is needed for the grass; this part only marks the apron and carries joint lines.)
- `MarketStalls` [MK]: rows of stalls in the yard, x -226..-134 world: wooden frame stalls (counter 3.5 high), tarp canopies (blue, green, orange) on poles, umbrellas, wooden carts with wheels, crates stacks, a few tarp-covered heaps (low domes). Leave the aisle and keep-clear free.
- `Baskets`: round woven baskets (cylinders, brown) on counters and ground, some tilted wedges for display crates.
- `Produce`: heaps of coloured balls/cylinders on trays: tomatoes (red), onions (purple), peppers (green), squash (orange), bananas (yellow wedges/cylinders), fish tray (silver), cut greens (green). Small parts, but count budget.
- `PriceSigns`: small boards on posts at stalls, SurfaceGui text such as "KAMATIS  P 80/kg", "SIBUYAS  P 120/kg", "SAGING  P 60/kg". One larger board at the yard entrance: "SAMPLE PRICES - FOR ILLUSTRATION". These numbers are **illustrative, not 2014 data**; the board says so.
- `VendorNPCs` [folder, direct child of the site]: 6 to 8 idle R15 vendors and shoppers behind/among the stalls, built **exactly like `builders/site01.luau` `buildPeople`** (HumanoidDescription colours, `Players:CreateHumanoidModelFromDescription`, all parts unanchored first, `HumanoidRootPart` anchored last, `DisplayDistanceType.None`, `WalkSpeed 0`, `ModelStreamingMode.Atomic`, attribute `SiteId = 2`, `PivotTo` at ground + 3, names `Vendor1`..). `NpcIdle` (ServerScriptService) plays the idle animation at runtime on every Humanoid under `Workspace.Sites`, so vendors need nothing extra. **`CreateHumanoidModelFromDescription` yields, so build the vendors in their own chunk before the swap**, as site01 does.
- Ground dressing: a few tricycles or a parked jeep silhouette at the road mouth are optional; lamp posts along the aisle; no overhead wires.

## Keep clear (existing, kept by the builder; world coordinates)
- **Guide** at (-200, 0, 160), facing E. Keep a box x -212..-188, z 148..172, y 0..14 free of built parts. (The Guide's prompt radius is 12.)
- **InfoPanel** at about (-206, 5, 148), a 12 x 8 board facing E: keep its front (east) side open, 12 studs deep, and nothing built through the panel.
- **The aisle**: a 12-wide strip from the road F mouth west to the Guide: x -200..-128, z 154..166, kept free of stalls and signs so a player can walk from the road to the Guide.
- **Road F** is outside the footprint paving (asphalt at x -128..-120, z 70..160): build nothing east of x -130.
- Nothing may overlap `Guide` or `InfoPanel`. A final step queries exact-size boxes for the Guide volume (10x10x10) and the aisle (about 12 studs wide, 4 tall) for overlaps with built parts and reports the result.

## Ground (decided before the build; the worker does NOT touch Terrain)
Terrain under **x -276..-128, z 80..240** was repainted Pavement (the Market paving probe in `world_check`). Thin parts do not hide grass, and anything at ground level OUTSIDE that region would be buried by tall grass blades. **Everything thin at ground level (slabs, baskets, produce trays, ground tarps, shadows) must lie inside x -276..-128, z 80..240.** Taller structures may extend slightly beyond but the hall, yard and all props are planned inside it. The hall's own x extent is -270..-230.

## Approximated
Sides and rear of the hall (plain walls); interior (none: closed arcade with dark glazing); the exact number of bays (dropped to fit 150 studs); the street, tricycles and wires; stall contents (representative produce); prices (illustrative).

## Art-observation hooks for dialogue (Slice 12 will source them)
Rhythm of arched bays and maroon pilasters against a cream wall; the strong horizontal of the long name band; the diagonal stair as the one dynamic line; the colour accents of tarps and produce against concrete; a lived-in, layered street-market scene as everyday community life.

## Revision 1 (Slice 17): fidelity rework (2014 facade + OSM massing)
The user judged the model against the real market and chose **the 2014 facade with OSM massing** (not the 2025 state), with the photos already on disk: Wikimedia Commons has no category or street-level file of the market (searched 2026-10-22; the C.M. Recto and Rizal Street photos have no coordinates and no market in them). The approved dialogue ("as photographed in 2014") is unchanged. The footprint (200 x 160) and SiteData are unchanged. Checks: `tests/site02_check.luau` (45), written before the rebuild and run red against the old model (26 passed, 19 failed).

**OSM (ODbL, Overpass 2026-10-22):** way 465374399 "Candido B. Lopez - Memorial Public Market": about 84 x 40 m, 3 levels, 11 m, roof colour #6b88b4 (blue-grey). Neighbours read for context and not modelled: LGU parking building 465374433 (4 levels), Wet Market 1315225896 (roof #4f5b86), marketplace compound 1365681180. The 2025 drone shot (credited under Site 1) shows the market but could not be pinned in it, so no roof or layout is drawn from it.

**Current coordinates for the keep-clear zones** (the "Keep clear" section above is in the original, pre-Slice-14 coordinates; add -100 to x): Guide (-300, 0, 160), box x -312..-288, z 148..172; InfoPanel (-306, 5, 148), a 12 x 8 board facing E; aisle x -300..-228, z 154..166; paved region x -376..-228, z 80..240 (the hall's own walls extend west of it, which is fine because they are tall). `site02_check` tests all of them.

### Real vs model (what changed)
| # | Real (2014 photo / OSM) | Before | Now |
|---|---|---|---|
| 1 | Depth about 40 m | 40-stud slab (x -370..-330) | `HallBody` 150 x 24 x **90** (x -420..-330); bays were never squeezed, depth is not a repeat |
| 2 | Low-pitch blue-grey roof | flat top | 2 `RoofSlope` slabs (107,136,180) at 8 degrees, ridge along the hall at y 30.9, 30 `RoofSeam` strips, 4 `Gable*` wedges; blue `RoofEdge` kept; the old N/S edge strips are gone |
| 3 | Capitals fill the sign band | 3 high, small text | `NameBand` 120 x **5**, lx -45..75, fixed 60 px text (TextScaled with wrapping off rendered at a tenth of the width) |
| 4 | Cantilevered south gallery under a dark awning | none | `UpperGallery` deck (lx -76..-40, top 12.05), `GalleryFascia`, `GalleryRail` + 12 `GalleryPost`, `GalleryWall` (maroon) with 4 `GalleryOpening`, `GalleryAwning` (dark, tilted) |
| 5 | Open upper bays, tilted shutters in pairs | dark flat panes, thin hoods | bays k 4..15: recessed glass plus **2 `Shutter`s** each (24), tilted 26 degrees, y 15.2 and 18.4 |
| 6 | Round yellow portico columns under the gallery | none | 4 `PorticoColumn` (lx -74, -66, -58, -50); the 16 arched, gridded ground bays stay behind them |
| 7 | Stair rises to the SOUTH along the facade, roofed over its full run | short stair, perpendicular to the wall | 12 risers of 1 from lx -22 to -46 (lz 9 to 4), 2 `StairStringer` panels, rails, `StairCover` over the whole run, 6 yellow `StairPier`s; lands on the gallery deck |
| 8 | North balcony on round yellow columns, pink-maroon ground | 3 columns | 5 `BalconyColumn`, 11 balusters, `EndBayWall` spandrel |
| 9 | Stained, weathered wall | uniform paint | `UpperWall` (lighter cladding) and 6 red-oxide `RustPatch`es over arches (colour only) |
| 10 | Tin lean-tos hard against the facade, tricycles, dense yard | 4 lean-to segments with a stair gap; 5 rows of booths out to z 94 | 8 `LeanRoof` segments (lx -16..50) with counters and posts; **3 tricycles** (`TricycleBody`, 3 wheels, roof, 4 posts each) at the yard's mouth; booth rows 17 apart (z 12..80), cart, heaps and vendors moved to match |
| 11 | Blue pharmacy billboard (top left) | none | `Billboard` 30 x 5, plain blue, **no text** (brands are never reproduced) |
| 12 | Sides and rear unknown | plain | still approximated: plain cream with a maroon `SideBase`/`RearBase`, 8 `RearWindow`s, 6 `EndWindow`s |

**Kept as-is:** Guide, InfoPanel, the five required props (`MarketStalls`, `Baskets`, `Produce`, `PriceSigns`, `VendorNPCs`), the anchors `HallBody`/`NameBand`/`BalconyDeck`/`YardSlab`, the sample-price board, pivot (-330, 0, 160) facing E. No terrain repaint; all thin ground parts stay inside the paved region.

**Result:** 1,104 parts (1,087 built + 17 kept; 960 without the 8 vendor rigs), BuildCheck 15/0, checkWorld 6256 (6128 - 976 + 1104).

**Approximated:** the ridge runs along the long axis (the photo shows no roof pitch direction); the roof is a stand-in for the OSM colour, not seen in a photo; sides, rear, interior; the exact bay count (16 kept); stall contents; prices (illustrative).

## Rebuild from BP1 (Slice 4, 2026-10-29)

Status: **tests first.** `tests/site02_check.luau` and the other pins listed below were rewritten before any builder change and shown red against the unchanged model (counts in `scratch/site02/tests_journal_A.md`). Everything above this section describes the PREVIOUS model (2014 facade, 90-deep hall at (-330, 160)); where it disagrees with this section, this section wins. The builder and the data files (`builders/site02.luau`, `SiteData.luau`, `TourContent.luau`, `content/*.md`, `RoadData`, `roads_extra.luau`) are a separate job; this section is the specification they build to.

### Owner decisions (2026-10-29)
- **The whole Market slot is repainted Concrete** (x -576..-228, z -5..325), replacing the old Pavement region (x -376..-228, z 80..240). The repaint is a separate job in `builders/roads_extra.luau`; `roads_check` section 6a and `world_check` pin it.
- **Guide and InfoPanel move to the forecourt at the stairs**: Guide (-241, 0, 160), InfoPanel (-247, 5, 148), 12 x 8, facing E. Both are reached through `guideLocal` / `panelLocal` in `SiteData` (as rows 1 and 10), the Market keeps **no JeepStop**.
- **The rooftop scaffold is built with no text** (no SurfaceGui, BillboardGui, TextLabel, Decal or Texture, nothing adorned to it). The pharmacy, cigarette and shop ads of the photos are never reproduced.
- **New first dialogue line** (replaces "Our facade photo is from 2014, so it may look different today."): **"Our model follows a plan drawing and recent street photos, so some details may differ."** (86 characters, ASCII). First line = the old 118-character sentence + one space + this sentence = 205 characters, under the 220 limit in `SiteData_Test`. The owner approved a longer wording (225 characters, over the limit); the orchestrator shortened it and discloses that to the owner. No dialogue, `lookAt` or `talkAgain` line may mention 2014 or the facade photo (`TourContent_Test` scans every Market text field). Flag for the owner: the current `lookAt` ("rounded arches ... rows of windows above them ... the stairs") describes the old facade and no longer matches BP1 (arches only on the top floor, two stairs).

### Source ranking
1. **BP1 (`PublicMarketBP1.jpg`) for massing and layout**: plan, front elevation, isometric, at one uniform scale (see below).
2. **Photos for colour and detail** (2023 and 2026 Street View, the aerial): wall cream, red pilasters and columns, rusty scaffold pipe, tin lean-tos, tarps.
3. **BP2 agrees** on the red roofs and the rooftop scaffold (its elevation shows two lattice panels over the south wing); BP2 does not decide anything BP1 draws. Disagreements are logged in `scratch/site02/layout.md` section 8 (D1..D17).

### Scale and bounds (`scratch/site02/layout.md` sections 1, 2)
- Slot **348 x 330** studs, centre (-402, 160), facing E: **x -576..-228, z -5..325**. East edge x -228 is where Road F's asphalt ends.
- One uniform plan scale k = 0.36 studs per source pixel (2.90 studs/m on the 110 m reading); heights from the elevation (0.1545 studs per pixel), rounded to 0.5. The depth (game x) is the longer dimension: 1.31 x the frontage, which BP1's drawn proportion gives and its labels contradict (110.00 m / 116.00 m on the frontage lines).
- **Real bounds** (what BuildCheck and `roads_check` measure): **x -559.6..-229.0, z 33.3..276.3** (330.6 deep, 243.0 wide). Margins to the slot: west 16.4, east 1.0, north 38.3, south 48.7. With the 10 percent road margin the east edge is -229 + 33.1 = -195.9, under -180: the west bypass (x about -170) stays clear.
- The drawn forecourt in front of the portico is only 9.4 studs and already the street lane, so the model adds 12 studs of forecourt depth: portico front face x -250.4, apron edge x -229, Guide at x -241.
- Front arcade (3 storeys): x -299.7..-262.6, z 71.4..249.3, floor-2 level y 9.5, floor-3 level y 18.5, cornice y 30.5; pavilion body x -303.3..-262.6, z 145.6..174.4; wing roofs ridge 34.5; pavilion apex 36.0; rooftop scaffold over the SOUTH wing only (z 177.6..231, y 31..50).
- Part budget (layout.md section 6): about 1346 parts in 8 batches of at most 400. **Open question for the builder:** the kept props `MarketStalls`, `Baskets`, `Produce`, `PriceSigns` hold 585 parts today (the layout budgets 150 for them). `site02_check` keeps the old guard "non-rig parts 950..1500" and adds "site total (rigs included) at most 2000". Keeping all 585 prop parts plus about 1196 for the rest would exceed 1500; trim the props or ask for the guard to move.

### NAMING CONTRACT (copy of the head of `tests/site02_check.luau`; builders MUST follow it)
The check finds the model in `Workspace.Staging` first, then `Workspace.Sites`. Run one group with `shared.site02_only = "hall" | "sheds" | "yard" | "general"` before `require(...:Clone())`; the run_all call leaves it nil and runs all four. Guards beyond the contract (tightened in part B, 2026-10-29): nothing in `Structure` or `Yard` may have a point below y -0.5, and **no part anywhere in the site (rigs excluded) below y -0.6** (a dome, heap or ball may sink at most 0.6; the old `TarpHeap` had a corner at y -2.2, so the builder must rebuild it). **No `TextScaled` label whose longest LINE has more than 14 characters anywhere in the site** (README rule 7: long labels use a fixed `TextSize`; the two-line `PriceBoard` labels of 7 + 7 characters are fine; a Frame around the label does not exempt it). Only the shared Guide and InfoPanel widgets are exempt: the InfoPanel label (115 characters, `TextScaled`) comes from `builders/placeholders`, not from the Market builder. **Finding for the owner:** the old `SampleBoard` carries a 32-character single-line `TextScaled` label; the check now reports it, so the builder gives it a fixed `TextSize`. Counts without a plus are exact: 19 `Pilaster`, 18 `GroundBay`, 14 `ArchWindow` + 4 `ArchWindowTall` (18 arches), 4 `PorticoColumn`, 10 steps per stair, 8 tricycles, 5 `StreetStall`. Names marked part-only must be BaseParts (a `Door` built as a Model does not count); `GroundBay`, `ArchWindow`, `ArchWindowTall`, `ShedA`..`ShedD`, `WetMarket1/2`, `DryGoods`, `TruckBay`, `Truck`, `StreetStall` and `SideStallS/N` may be a part or a Model. A roof lantern (optional, layout.md 3.1) must NOT match `PavilionRoof%u?%d*` (its top would count as the apex; `PavilionRoofL` does match); name it `PavilionLantern`. The portico columns are held to their EAST EDGE (centre + radius at most -250.39, so a radius-1.2 column needs a centre of -251.6 or further west): a column at centre -251 would reach x -249.8 and intrude the aisle and the wide Guide box.

```text
===================================== NAMING CONTRACT (builders MUST follow it) =====================================
World frame, no yaw tricks: world x east (+), z south (+), y up. The site pivot is (-402, 0, 160) facing E; every number below is WORLD.
Slot x -576..-228, z -5..325. Real bounds x -559.6..-229.0, z 33.3..276.3 (uniform plan scale 2.90 studs/m). The ground under the slot is Concrete.
Direct children of Site02_Market: Guide, InfoPanel (ONE BasePart), Structure (Folder), Yard (Model, holds YardSlab), MarketStalls, Baskets, Produce,
  PriceSigns, VendorNPCs, LocalNPCs.  Inside Structure (Folders or Models): Hall/Shell, Hall/Windows, Stairs, Scaffold, Sheds/Gabled, Sheds/Markets,
  Bagsakan, Forecourt. Grouping nodes (Structure, Structure/Hall, Structure/Sheds) hold NO direct parts. Every OTHER Model/Folder holds at most 400 parts in
  its whole subtree (batch rule); Stairs may be one container (46 parts).
ANCHORS: ONE BasePart each in the whole site, no Model/Folder shares the name: HallBody, PavilionBody, NameBand, YardSlab (and the old SampleBoard).
  HallBody  = cream wall block of the front arcade, x -299.7..-262.6 (east face -262.6 +-2.5, west face -304..-296), z 71.4..249.3 (+-3), top y 28.5..32.
  PavilionBody = the central pavilion block, x -303.3..-262.6 (+-3), z 145.6..174.4 (+-2.5, centre z 160 +-2), top y 28.5..32.
  NameBand  = white band on the east frontage, centre x -266..-249, 3.5+ tall (y between 14 and 31.5), 40+ long along z inside z 71..250. Its ONE SurfaceGui
    faces east (the Face whose world normal is +X), holds ONE TextLabel "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET", blue text, fixed TextSize (TextScaled false).
  YardSlab  = the forecourt apron, ONE thin part (Size.Y at most 0.31), x -250.4..-229, z 33.3..276.3.
NAME KINDS: the patterns below (Lua patterns, anchored) are matched against BASEPARTS unless marked [unit]; a Model that carries a part-only name is invisible
  to the check (a Door built as a Model does not count). [unit] = a BasePart OR a Model, measured over all its parts: GroundBay, ArchWindow, ArchWindowTall,
  ShedA..D, WetMarket1/2, DryGoods, TruckBay, Truck, StreetStall, SideStallS/N. A number without "+" is EXACT (19 Pilaster, 18 GroundBay, 14 ArchWindow + 4
  ArchWindowTall, 4 PorticoColumn, 10 steps per stair, 8 tricycles, 5 StreetStall); "+" means at least.
GUARDS beyond the names: nothing in Structure or Yard has a point below y -0.5, and NO part anywhere in the site (rigs excluded) has a point below y -0.6 (a dome,
  heap or ball may sink at most 0.6). No TextScaled label whose longest LINE has more than 14 characters anywhere in the site, except the shared Guide and InfoPanel
  widgets (the InfoPanel label comes from builders/placeholders and is TextScaled); a Frame around the label does not exempt it (README rule 7: long labels use a
  fixed TextSize; a two-line board "KAMATIS" / "P 80/kg" is fine). No brand words, zero images.
HALL (Structure/Hall/Shell, Structure/Hall/Windows):
  Pilaster%d+            19 red (176,62,50) strips, 1.6 wide, full height (>= 28), centre x -267..-258, z from the south end to the north end.
  GroundBay%d+ [unit]    18 open rectangular bays of the ground storey (7 south, 3 pavilion, 8 north), bottom <= 1, height 8..10.3. NO arches below y 9.
  Door%d+                ground-storey doors, 8..9.6 tall.
  ArchWindow%d+ [unit]   floor-3 arched openings (14): each a Model or part, bottom >= 18, top <= 27, centre x -268..-258.
  ArchWindowTall%d+ [unit] tall double-height arched grid windows (4): bottom 9..10.8, top >= 23.5; at the two end bays (z about 77.4 and 243.3) and
                         the two pavilion flanks (z about 150.4 and 169.6). The pavilion centre arch (z 160) is an ordinary ArchWindow. 18 arches in all.
  Window2_%d+            floor-2 rectangular windows, y 12..19.5.
  FloorSlab2%u?%d* / FloorSlab3%u?%d*   top y 9.5 and 18.5 (+-0.7).  Cornice%u?%d*   top y 30.5 (+-1.2), at least 2.
  Balustrade2%u?%d* / Balustrade3%u?%d*  rail top y 12.5 and 21.5 (+-0.7).  RailPost%d+  posts of EVERY railing, 3.0 tall (2.9..3.4).
  WingRoof%u?%d*         low red hip roofs (172,78,72), at least 8 parts, highest top (ridge) 34.5 +-1.0, z union covers 74..247.
  PavilionRoof%u?%d*     red hip roof, at least 4 parts, apex 36 +-1.0 and higher than the wing ridge by at least 0.5. A roof lantern is named PavilionLantern:
                         any name matching this pattern (PavilionRoofL, PavilionRoof2) counts as roof and its top would be the apex.
  Portico%a*%d*          portico parts; max east face -250.4 (+-2). PorticoColumn%d+ (exactly 4): round (Cylinder), red, 9+ tall, standing on the ground,
                         centre x -260 or further east, z 146..174, and the EAST EDGE (centre + radius) at most -250.39 so that no column reaches the aisle box
                         (x -250.4..-228) or the wide Guide box (x -250..-229): with radius 1.2 that is a centre of -251.6 or further west.
STAIRS (Structure/Stairs): two stairs, mirror-symmetric about z 160. North stair N, south stair S.
  StepN%d+ / StepS%d+    10 each, index 1 = foot, 10 = top. Size.X = width 6 (+-0.8), Size.Y = height of that step's tread above ground (a solid block),
                         so tops rise 0.85..1.0 per step, step 1 top <= 1.0, step 10 top 9.5 (+-0.6). Foot step centre x -258..-250, z 90..100 (N) / 221..232 (S);
                         top step centre x -266..-259, z 140..150 (N) / 170..180 (S). |z-160| shrinks every step. StepS(i).z + StepN(i).z = 320 (+-1.5).
  StairPostN%d+ / StairPostS%d+   rail posts (3 tall, 6+ each).  StairRailN%d* / StairRailS%d*  rails (2+ each).  StairLandingN / StairLandingS top y 9.5 (+-0.7).
SCAFFOLD (Structure/Scaffold): rooftop lattice over the SOUTH wing only. Parts named ScaffoldP1<Role><n> and ScaffoldP2<Role><n> (Role = Post, Rail, Brace or
  Truss), steel pipe, rusty (128,98,82), pipe thin (two smallest dimensions <= 1.2), z 177.6..231 (P1 205.3..231, P2 177.6..203.8, +-3), y 30.5..51, x -274..-263.
  40..80 parts. NO SurfaceGui, BillboardGui, TextLabel, Decal or Texture anywhere under it and no gui adorned to it.
SHEDS (Structure/Sheds/Gabled, Structure/Sheds/Markets): Models ShedA, ShedB, ShedC, ShedD (x -471.4..-415.6; A z 196.7..232.0, B 158.6..190.2,
  C 115.0..157.8, D 72.2..107.4, +-3). Inside each: Shed<L>Wall%d+, Shed<L>Column%d+, Shed<L>Roof%d+ (>= 2 red slopes (172,78,72) +-25), Shed<L>Ridge,
  Shed<L>Clerestory%d+ (>= 1, top >= roof top + 2, centre z inside the shed). Shed top 16..23. Models WetMarket1 (x -376..-312.3, z 190.6..231.6) and WetMarket2
  (z 107.8..158.6), DryGoods (x -379.6..-311.2, z 159.6..189.5), parts CrossAisle%a*%d* (x -311.2..-299.7, z 71.4..249.3), MidBand%d+ roofs (optional).
  Counter%d+  stall counters (top y 3.5 +-0.2), at least 8 inside each WetMarket. Canopy%d* tarps: at least 28 in all, 3+ colours.
BAGSAKAN (Structure/Bagsakan): parts Bagsakan%a+%d* (BagsakanWall, BagsakanRoof (>= 2 red slopes), BagsakanDoor) forming the long shed x -556..-506.3,
  z 84..240.6 (+-3), ridge 19 (+-2.5); TruckBay%d+ (6: centres x -505..-488, three with z <= 136, three with z >= 188) and Truck%d+ (Models, one on each bay,
  within 6 studs in z and inside the bay's x range).
FORECOURT (Structure/Forecourt, Yard): LeanRoof%d+ (4, tin colours, x -265..-253, z 70..91 or 229..250), TricycleBody%d+ (8) with TricycleWheel%d+ (>= 24) and
  TricycleRoof%d+ (>= 8), x -237..-231, z 100..136 (4) and 184..220 (4); StreetStall%d+ Models (5) x -241..-235, z 244, 254, 264 and 62, 52 (+-3.5).
  SideStallS%d+ (>= 10, z 232.4..276.3) and SideStallN%d+ (>= 10, z 33.3..71.1), x -471.4..-311.2. LocalNPCs: ShopperBayong1/2 (Role attribute) at
  (-380, 255) and (-372, 258) +-3.
Other names: PriceBoard%d* (>= 28, numbered or not, one label reads KAMATIS), Counter, Canopy as above; every name is ASCII; SurfaceGui text ASCII only.
======================================================================================================================
```

## Rebuild from BP1: replaced assertions

Every row was checked against `git diff` of `tests/` (old text from `git show HEAD:tests/<file>`). The old assertion is gone; the new one carries the BP1 / photo reason. Old numbers are the ones the old check really asserted (the Guide box was 24 x 14 x 24, not 24 x 24 x 11, and the old aisle ran from x -294).

### `tests/site02_check.luau` (rewritten; groups `hall`, `sheds`, `yard`, `general`)
| Old assertion | Why (BP1 / photos) | New |
|---|---|---|
| Site pivot (-330, 0, 160) facing E | New slot, owner decision | Pivot (-402, 0, 160) facing E |
| Guide at (-300, 160); InfoPanel at (-306, 148) | Owner: Guide and InfoPanel at the stairs on the forecourt | Guide (-241, 0, 160) within 1; InfoPanel centre (-247, 5, 148) within 1, 12 x 8, thin along x (faces E) |
| Nothing within the Guide keep-clear box 24 x 14 x 24 (x -312..-288, y 0..14, z 148..172) | The portico face at x -250.4 forces the cut | Box x -250..-229, z 148..172, y 0..14, plus a 10 x 10 x 10 box x -246..-236, z 155..165, y 0..10 around the Guide |
| Aisle from the road to the Guide x -294..-228, z 154..166, 5 tall | Guide moved to x -241 | Aisle x -250.4..-228, z 154..166, y 0..6 (part tops under 0.6 ignored) |
| InfoPanel east side open, 12 deep (x -305.75..-293.75, z 142..154) | Panel moved | x -247..-235, z 142..154, y 1..9 |
| HallBody about 90 deep (x -420..-330), 150 long, 24 tall | BP1 plan and elevation: front arcade 37.1 deep, 177.8 long, cornice 30.5 | HallBody east face -262.6 (+-2.5), west -304..-296, z 71.4..249.3 (+-3), top y 28.5..32 (about 30.5), light; new PavilionBody (x -303.3..-262.6, z 145.6..174.4, centred z 160) |
| 2 RoofSlope blue-grey (#6b88b4), tilt 3..14 degrees; 20+ RoofSeam; 4+ Gable; RoofEdge kept | BP1 low hip roofs; photos and BP2 show red steel | WingRoof (8+ parts, red 172,78,72, ridge 34.5 +-1, z 74..247 covered) and PavilionRoof (4+ red parts, apex 36 +-1, at least 0.5 above the wing ridge) |
| NameBand: 4+ tall, white, east of the hall, reads the name, starts north of the gallery | BP1 elevation frontage band; no gallery any more | NameBand ONE unique part: white, 3.5+ tall, 40+ long, centre x -266..-249, y 14..31.5, z inside 71..250; ONE SurfaceGui whose face normal (from the CFrame) is +X; TextLabel "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET", blue capitals, fixed TextSize 20+ (TextScaled false). The name is kept. |
| Billboard: plain blue panel 4+ tall over the gallery, no text | Not in BP1; BP2 shows a scaffold, not a panel | Retired. Brand ban instead: no ROSE PHARMACY, PHARMACY, BOTIKA, DRUGSTORE, MARLBORO, CIGARETTE in any text or name; zero Decal/Texture/ImageLabel; the scaffold carries no gui |
| UpperWall cladding + 4+ maroon RustPatch | BP1 plain walls, photos cream with red trim | HallBody light (every channel 190+, spread at most 45); red Pilasters |
| 17+ parts named exactly `Pilaster` (maroon) | BP1 elevation: 19 pilasters; photos: red (176,62,50) | Exactly 19 `Pilaster%d+`, red, full height 28+, centre x -267..-258, from z 77 or less to 243 or more (part B: was 18..20) |
| 12+ `ArchBay` and 12+ `BayMullion` (arched ground bays) | BP1: ground storey is rectangular bays; arches only on floor 3 | Exactly 18 `GroundBay%d+` units from the ground, 8..10.3 tall (part B: was 16..20); no unit named `Arch*` with a point below y 9; 4+ `Door%d+` 8..9.6 tall; exactly 14 `ArchWindow%d+` (bottom 18+, top 27 or less) and exactly 4 `ArchWindowTall%d+` (bottom 9..10.8, top 23.5+; part B: was 16..20 in all and 4..5 tall) at z 77.4, 243.3, 150.4, 169.6 |
| 16+ tilted `Shutter` awnings | Not in BP1 | Removed (no assertion) |
| `UpperGallery` deck, `GalleryRail`, 8+ `GalleryPost`, `GalleryAwning`, `GalleryFascia`, `GalleryWall`, 3+ `GalleryOpening` | BP1 elevation: floor-2 and floor-3 balustrades, no gallery | `FloorSlab2` top 9.5, `FloorSlab3` top 18.5 (+-0.7); 2+ `Cornice` top 30.5 (+-1.2); `Balustrade2` / `Balustrade3` top 12.5 / 21.5 (+-0.7); 12+ `RailPost%d+` 2.9..3.4 tall; 12+ `Window2_%d+` y 12..19.5 |
| 4+ round yellow `PorticoColumn`, 10+ tall, at lx -77..-37 | BP1 pavilion portico; photos: red round columns | Exactly 4 `PorticoColumn%d+`: Cylinder, red, 9+ tall, on the ground, centre x -260 or further east, east edge at most -250.39 (part B: was centre x -260..-251, which let a radius-1.2 column reach x -249.8), z 146..174; portico front face x -250.4 (+-2) |
| One stair: `Step1..Step12` rising 1 each along the facade, `StairCover`, 4+ yellow `StairPier`, `StairStringer`, 2 `StairRail` | BP1 plan: two symmetric stairs to the floor-2 deck | `StepN1..10` and `StepS1..10` (solid blocks, width 6 +-0.8, tops rise 0.85..1.0, step 1 top 1.0 or less, step 10 top 9.5 +-0.6, each step nearer z 160), mirror-symmetric about z 160 (z sums 320 +-1.5); per stair 6+ `StairPost` 2.9..3.4 tall, 2+ `StairRail`, one `StairLanding` top 9.5 |
| `BalconyDeck` north of z 135, 5+ yellow `BalconyColumn`, `BalconyRail`, maroon `EndBayWall` | No north balcony in BP1 | Retired. The `sites_check` Market guard "balcony is at the north end" becomes "rooftop scaffold is at the south end" (mean z of the Scaffold parts above the HallBody z + 15) |
| 8+ `LeanRoof` tin, none south of lx -20 | layout.md 3.3 | Exactly 4 `LeanRoof%d+`, tin (rust, dark rust, galvanised grey; the old (150,90,60) and (130,134,138) pass too), x -265..-253, z 70..91 or 229..250 |
| 28+ `Counter`, all with world x <= -246 | The market now spans x -576..-228 | 28+ `Counter`, none east of x -232; every counter top 3.3..3.8 (human scale 3.5) |
| 2+ `TricycleBody`, 6+ wheels, 2+ roofs | layout.md 3.3 | Exactly 8 `TricycleBody%d+` (4 at z 100..136, 4 at z 184..220, x -237..-231), 24+ `TricycleWheel%d+`, 8+ `TricycleRoof%d+` |
| Every part inside x -440..-220, z 72..248 (footprint + 10 percent) | The slot | Every non-rig part inside x -576..-228, z -5..325 (rotated corners included), nothing east of x -228 |
| Thin ground parts inside the Pavement x -376..-228, z 80..240 | The ground is Concrete over the whole slot | Thin ground parts (0.35 or less) inside the slot |
| `YardSlab` 0.3 thick | Apron | `YardSlab` ONE unique part, at most 0.31 thick, x -250.4..-229 (+-1.5), z 33.3..276.3 (+-2.5) |

**Kept (same rule, same numbers):** the five required props exist and hold parts (`MarketStalls`, `Baskets`, `Produce`, `PriceSigns`, `VendorNPCs`); 6..9 vendor rigs; 28+ `PriceBoard` (the pattern is now `PriceBoard%d*`, numbered or not; one label must read KAMATIS, which the old check only claimed); every non-rig part anchored; `SampleBoard` present; 28+ `Canopy` tarps in 3+ colours; part count (rigs excluded) 950..1500; Guide and InfoPanel present as direct children.

**New (nothing replaced):** PavilionBody; sheds A..D (x -471.4..-415.6, red slopes, clerestory), WetMarket1/2 with 8+ counters each, DryGoods, CrossAisle; Bagsakan (x -556..-506.3, z 84..240.6, ridge 19), 6 truck bays each with a Truck; the rooftop scaffold (40..80 rusty pipe parts, two panels, south wing, no text); stairs mirror symmetry; 5 street stalls; 10+ side-yard stalls on each side; ShopperBayong1/2 at (-380, 255) and (-372, 258); Structure/Hall/Sheds grouping nodes hold no direct parts; every other container at most 400 parts; site total at most 2000; margin rule against `RoadData.NEW_ROADS` (bounds of ALL parts, rigs and Guide included, +10 percent, road half-width + 4), as `roads_check` measures it; nothing in `Structure` or `Yard` below y -0.5 and nothing anywhere below y -0.6; no `TextScaled` label with a line over 14 characters anywhere (Guide and InfoPanel exempt); one street stall on each of the five rows; ASCII-only text; zero image instances; no brand names.

### Other tests changed (same job)
| File | Old | Why | New |
|---|---|---|---|
| `SiteData_Test` "positions and facings match the layout" | `[2] = { -330, 160, "E" }` | New slot | `[2] = { -402, 160, "E" }` |
| `SiteData_Test` "market sits at -330,160" | pos (-330, 160) only | New slot and size | "market slot is centre (-402,160), size 348 x 330, facing E: x -576..-228, z -5..325" |
| (new) `SiteData_Test` "row 2: Guide (-241,0,160) and InfoPanel (-247,148) pinned ..." | rows 2..9 used the old formulas (guide 30 ahead, no `guideLocal`) | Guide and InfoPanel on the forecourt | Row 2 carries `guideLocal` and `panelLocal` (Vector2), no `jeepLocal`, no JeepStop, both inside the footprint |
| `SiteData_Test` "rows 2 to 9 keep the old guidePos and jeepStopPos formulas" | loop 2..9 | Row 2 is now explicit | "rows 3 to 9 ..." loop 3..9 |
| `SiteData_Test` "Market text notes the 2014 photo date" | first line carries 2014 | Facade photo is no longer the source | "Market first line says the model follows a plan drawing and recent street photos; no line mentions 2014" |
| (new) `TourContent_Test` "Market text: no field mentions 2014 or the facade photo, and the new plan-drawing line is spoken" | `talkAgain[3]` said "Our facade photo is from 2014 ..." | Same | Scans headline, blurb, lookAt, goodbye, firstTalk, talkAgain |
| `roads_check` (new section 6a, +3 checks, nothing replaced) | none | Owner: whole slot Concrete | 30 samples at least 4 studs inside the slot are Concrete (the old Pavement area and the old grass area); Grass controls just outside (west, north, south, beside Road F); Asphalt control at (-224, 160) |
| `sites_check` Market orientation guard | `NameBand` and `YardSlab` guards plus "balcony is at the north end" | No balcony in BP1 | the two kept guards plus "rooftop scaffold is at the south end" |
| `world_check` "floor west of Market" | Grass at (-500, 160) | (-500, 160) is inside the slot | Grass at (-590, 160), named "west of the Market slot" |
| `world_check` "Market paving is Pavement ..." | Pavement at 7 points over x -374..-230, z 82..238; Grass controls (-380,160), (-300,78), (-300,242) | Those cells are now inside the slot | "Market ground is Concrete over the whole slot ..." at 11 points; Grass controls (-580,160), (-400,-12), (-300,332), (-224,170); Asphalt control (-224,160) |

`world_check` is not part of `run_all`; run against the unchanged terrain it also reports two failures in code this job did not touch (the plaza control cell (50, 102) is Pavement since the stretched Cathedral plaza, and the old Cafe spot (160, -122) is Asphalt). They are not caused by the Market and are left alone.

### What stays red until the builders run
`site02_check` (hall, sheds, yard, general), `SiteData_Test` (4 cases, after `SiteData.luau` changes), `TourContent_Test` (1 case, after `TourContent.luau` changes), `roads_check` 6a (after the `roads_extra.luau` repaint), `sites_check` scaffold guard (after the rebuild), `world_check` Market block (after the repaint). `EXPECTED` in `tests/run_all.luau` is owner-only: the new numbers are the integrator's to set: unit run 248, roads_check 270, and site02_check **96** on a complete model (part B proved it on a faithful fake: 96 passed, 0 failed; it reports 91 checks against the old model because five checks only run when their part exists: the PavilionBody bounds check and the four "ShedX is gabled" checks), plus the new build 02 part count and terrain cell count.

### Slice 4 Market, job 3 (data and ground), 2026-10-29
Applied with the old 2014 model still in place (no model was built or rebuilt):
- `SiteData` row 2 is centre (-402, 160), size 348 x 330, facing E, massScale 3.0, with `guideLocal` (161, 0) and `panelLocal` (155, -12) (facing E: world = (-402 + lx, 160 + lz)), so the Guide is at (-241, 0, 160) and the InfoPanel centre at (-247, 5, 148). No `jeepLocal`, no JeepStop. First dialogue line: the 118-character name sentence + the owner-approved "Our model follows a plan drawing and recent street photos, so some details may differ." = 205 characters. `TourContent` site 2 `talkAgain[3]` now carries the same sentence (no field mentions 2014 or the facade photo); `content/tour_content.md` and `content/tour_content_changes.md` mirror it (crosscheck: 0 mismatched). The `lookAt` line is untouched and still describes the old facade (flagged for the owner).
- Studio pins by property write: `Site02_Market` WorldPivot (-402, 0, 160) looking +X; Guide pivot (-241, 3, 160); InfoPanel (-247, 5, 148), 12 x 8 x 0.5, facing E; `ShopperBayong1` / `ShopperBayong2` at (-380, 3.247, 255) / (-372, 3.247, 258) (lowest body part on the Concrete surface y 0). The fingerprint of the 1088 parts other than the Guide model and the shoppers is unchanged (1234249348; the InfoPanel counted at its old position). `builders/npcs.luau` CAST[2] carries the new shopper positions (3 lines changed, all Market). `builders/guides.luau` only dresses existing Guides; `builders/placeholders.luau` `buildProps` already derives the Guide (ground + 3) and the InfoPanel (ground + 5) from `SiteData.guidePos` and `panelLocal`, so neither needed an edit.
- Ground: `builders/roads_extra.luau` CONCRETE gains four chunks x -576..-228, z -8..328 (z -5..325 widened to the 4-stud grid), a `task.wait()` after each region. Run 1: terrain cells 1794962 -> 1796660 (+1698; cause not established). Observed: 7308 surface voxels changed material, 5828 Grass and 1480 Pavement to Concrete, 0 voxels changed outside the slot over x/z -1000..1100, y -4..4 (run 1 compared materials only, not occupancy); the repainted surface voxels read occupancy 0.5039, the same as the Grass controls. Run 2: 1796660 -> 1796660, 0 material and 0 occupancy changes. The 6a samples read Concrete; the controls (-580,160), (-590,160), (-400,-12), (-300,332), (-224,170), (-224,150) read Grass and (-224,160) Asphalt; the old City Hall concrete points are unchanged.
- Numbers after this job: unit 248/0, `roads_check` 270/0, `sites_check` 276/1 (scaffold guard, red until the builder exists), `site02_check` 45/46 (was 41/50; pivot, Guide, InfoPanel and shopper assertions now pass), npcs 237/0, guides 123/0, qa 85/0, placeholders 32/0, routes 16/0, `world_check` 44/2 (only the two known reds: plaza control cell (50,102) is Pavement; old Cafe spot (160,-122) is Asphalt), build 02 parts 1148, world parts 9240.
- For the builder (job 4/5): the old model's props stand in the new forecourt boxes (`site02_check` reports UmbrellaTop, SamplePost, SampleBoard and Crate in the wide Guide box x -250..-229, z 148..172, and UmbrellaTop, UmbrellaPole in front of the InfoPanel); the rebuild must clear or move them. `EXPECTED` in `tests/run_all.luau` (owner-only) still reads roads_check 267, unit 246 and terrain cells 1794962; the integrator sets 270, 248 and 1796660.

### Slice 4 Market, portico fix, 2026-10-29 (BP1 audit, crop `iso_portico.png`)
Replaced or added assertions (group `hall`), each mirroring the blueprint; the owner's rule: BP1 is the absolute truth for look and design.
| Old | Why | New |
|---|---|---|
| Portico: 4 red columns 9+ tall under a hip roof that reaches x -250.4 (the model built them 28 tall with entablature, capitals, cornice and beams) | BP1 draws the pavilion's projection as a LOW TERRACE at floor-2 height on slim posts with a balustrade, open above, no roof over it | `PorticoColumn` keeps exactly 4 round red posts but none rises above y 12 (built 9.3); ONE `PorticoDeck` (top 9.5 +-0.7, x -262.6..-250.4, z 145.6..174.4); no `PorticoEntablature/Capital/Cornice/Beam`; 3+ `Balustrade2` rails and 8+ `RailPost` posts on the deck (rail top 12.5, checked with the other floor-2 rails); `PavilionRoof` east edge at most x -262 |
| (none) | BP1 shows a small flight of ground steps at the terrace's front corner | exactly 4 `PorchStep1..4`, each 0.2..0.6 above the one before, south of the deck (z 174..184), east edge at most x -250.39, top at most 2.5. Not named `Step[NS]` (those groups keep exactly 10) or `Portico...` (east-face rule) |

Decision for the yard job (vehicles, owner: "you decide; my concern is only that we match the blueprint"): BP1 draws jeepney- and van-sized vehicles beside both stair feet and in both side yards, and trucks at the Bagsakan bays; it draws nothing tricycle sized. The old assertion "exactly 8 `TricycleBody` ..." came from the 2014 photo layout, not from BP1, and is to be replaced when the yard is built by parked-vehicle assertions (`ParkedVehicle%d+` Models with a `Kind` attribute Jeepney or Van, human scale, 10 parts or fewer each, outside the aisle and Guide boxes). Vehicle counts shrink to fit the part budget; the vehicles never shrink (README rule 7).

### Slice 4 Market, sheds assertions replaced, 2026-10-29 (BP1 audit)
| Old | Why | New |
|---|---|---|
| Bagsakan ridge 19 (+-2.5) | BP1 iso: the Bagsakan pitch is very low and the ridge reads about 15.5 | ridge 16 (+-2.5) |
| WetMarket2 z 107.8..158.6 (+-4), 8+ `Counter` inside each WetMarket | BP1 plan: wet market 2's stall field is z 115..150; wet market 1 has 28 stalls (2x3 + 2x3 over 2x4 + 2x4 round a plus-shaped aisle), wet market 2 has 35 (3x3 + 2x3 over 3x4 + 2x4) | WetMarket2 z 112..153 (+-4); `Counter` at least 24 inside WetMarket1 and at least 30 inside WetMarket2 |

| ShedC z 115.0..157.8 (+-3) | BP1 plan (audit 2026-10-29, confidence medium): sheds B and C are separated by a roof-free aisle at z 150.5..159, so C ends at 150.5. The old 157.8 swallowed the aisle. The builder left the model true to the drawing and the check red until this change | ShedC z 115.0..150.5 (+-3) |

### Slice 4 Market, BP2 becomes equal authority, 2026-10-29 (audit `scratch/site02/audit_bp2.md`)
The owner: BP1 and BP2 are both absolute truth. Decided with them: the north wing keeps BP1's 7 arches and takes BP2's huge broad ribbed hip roof (hybrid); BP2's louvred corner block with the checkerboard hoarding is modelled; the tricycle queue BP2 labels stays, with BP1's jeepneys and vans added next to it; the name text stays CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET.
| Old | Why | New |
|---|---|---|
| (none: the north wing used the same low hip as the south wing, 10 parts, x -299.7..-262.6, z 71.4..145.6, ridge 34.5) | BP2 elevation: the north half sits under one huge ribbed hip roof, flush at the pavilion's north face, hipped at the north end only, ridge 1.5..1.9 under the pavilion apex. BP2 wall stops at y 19.1 with no arches; the hybrid keeps the arches, so the roof is broad rather than tall (eave 30.5, ridge 35.4) | 12+ `WingRoof` parts north of the pavilion spanning x -303.7..-258.6 (+-1.5), z 66..145.6 (+-1.5), ridge 35.4 (+-0.5); 6+ red `RoofRib%d+` strips inside that extent (y 30.4..36). The existing wing ridge 34.5 (+-1.0) and pavilion apex 36 higher by 0.5 still hold |
Not changed (both drawings agree with the model or the owner chose): stair run 52, scaffold pair, wet-market counts 28 and 35, flat tarps kept (contract wants 28+ canopies), pavilion flank arches stay double height. Still open from the audit: wing arch pitch 9.25 and width 7.9 (the bay grid, pilasters and ground bays move with it), flank arches 5.0 wide, lean-tos (3 fit; the old "4 LeanRoof" assertion changes), street vendors (more than 5), service block, corner block (primary x -574..-540, z 252..322, height 30), Bagsakan roof colour.
Owner decision 2026-10-29: the Bagsakan roof stays red (BP2 does not fill it red, but the owner keeps the red steel colour); the assertion "Bagsakan 2+ red roof slopes" is unchanged.

### Slice 4 Market, wing and flank arches (R1), 2026-10-29
| Old | Why | New |
|---|---|---|
| (none: arch width and pitch were not asserted; model had north pitch 8.9 / 6.6 wide, south pitch 10.5 / 7.6 wide, flank arches 7.4 wide) | BP1 and BP2 agree (audit_bp2 A6, A8): the wing arches repeat at pitch 9.25 and read 7.9 wide, the pavilion flank arches 4.9..5.0 wide | 7 north and 6 south `ArchWindow` units with outer frame width 7.9 (+-0.5), consecutive centre pitch 9.25 (+-0.4) in each wing; exactly 2 `ArchWindowTall` between z 146 and 174, each 5.0 wide (+-0.5). Double height kept: the existing `ArchWindowTall` bottom 9..10.8 and top 23.5+ stay |

### Slice 4 Market, end arch bays (R1b), 2026-10-29
Close-ups of the south wing and the pavilion flanks (beside `elev_left.png`, `elev_right.png`) showed two DIFFs. BP1's elevation draws each tall end arch clear of rails on both floors, centred between its two pilasters (about 2 studs of wall each side), and keeps a short railed strip beyond the end pilaster (about 4.0 studs at the south end, about 3 at the north end). The model ran one balustrade and its posts across both end arches, and its south arch sat against the end pilaster with 8.5 studs of bare wall on the other side.
| Old | Why | New |
|---|---|---|
| Tall windows at the end bays: `hasAt(tall, 243.3, 4)` (south) | BP1 crop `elev_left.png`: the arch (8.6 wide) is centred in an 11.2 clear bay, with the end pilaster and a 4.0 strip beyond it; at the fixed frontage (hall end z 249.3, last wing pilaster z 229.9) that puts the arch centre at about z 237.0 | `hasAt(tall, 237.0, 2.5)` for the south end; the north end keeps `hasAt(tall, 77.4, 4)` (its end region is only 9.45 wide, so no outer strip fits) |
| (none: rails across the end arches were not asserted) | BP1 and BP2 draw no rail across the tall end arch bay | No `Balustrade2*` or `Balustrade3*` part and no `RailPost` crosses either end arch |
| (none) | BP1 crop: each end arch is centred in its bay | At most 3.5 studs of bare wall between each end arch and the nearest pilaster on either side |
| (none) | BP1 crop `elev_left.png`: railed strip beyond the end pilaster, both floors | `Balustrade2E` and `Balustrade3E` (3+ long) inside z 243.5..249.6 |
Not matched (honest DIFF): the north end has no outer strip (9.45 between the last wing pilaster and the hall end, the drawing implies about 14); the drawing also runs rails across the pavilion centre bay.
Stale header comments fixed in the same commit: pilasters "1.6 wide" is 1.4 wide, the north wing roof reaches 35.4.

### Slice 4 Market, part guard (R4), 2026-10-29
| Old | Why | New |
|---|---|---|
| Own parts (rigs excluded) 950..1500 | The model is 956 parts today; the corner block (about 60), service block (about 25), yard and vehicles (about 550 to 700) cannot fit under 1500. Owner, 2026-10-29: "raise it as much as u need" | Own parts 950..1800; the site total (rigs included) at most 2000 and the coordinator's hard cap stay unchanged. Nothing goes red from this change (956 is inside both bounds) |

### Slice 4 Market, corner block and service block (R2, R3), 2026-10-29
Owner, 2026-10-29: "make the adjustments if u have to if it will serve the blue print better". New group `block` in `tests/site02_check.luau` (nothing replaced, nothing loosened); new containers `Structure/CornerBlock` and `Structure/ServiceBlock` (not grouping nodes; the 400-part batch rule applies to each).
| Item | Source | Spec in the check |
|---|---|---|
| Corner block | BP2 iso (`bp2_iso_corner_block.png`, `bp2_iso_block_whole.png`): louvred 4-5 storey block, long face parallel to the hall front, checkerboard hoarding facing east. BP1 iso draws only a 2-storey louvred box (marked DIFF, owner decision for BP2's height) | x -574..-540, z 244..324 (80 long: BP2 draws about 100, the slot allows 80 without touching the Bagsakan), top y 29..32; ONE `CornerBlockBody`; exactly 12 `Checker` squares 8 x 6 on the east face covering z 272..296, y 3..27, neighbours alternate white and blue-grey; 10+ `Louvre` (3+ per end and 3+ beside the hoarding); 3+ `BlockBand`; 2+ `BlockDoor` 8..9.6 tall; 40..120 parts; no text, gui or decal; nothing else within 1 stud |
| Service block and annex | BP1 plan (block z 33..60, annex z 60..85, MED) and BP2 plan at the Bagsakan's north-west | ONE `ServiceBlockBody` x -552..-497, z 33..60; ONE `ServiceAnnex` z 60..83 (the Bagsakan walls start at z 84); 4+ `ServiceRoofEdge`; 2+ `ServiceDoor` 8..9.6 tall; 12..60 parts; no text; nothing else within 1 stud |
Departure from the drawing, logged: BP1 reads the service block about 7 tall, but README rule 7 fixes doors at 8 studs or more, so the top is 9..10.5 (still far below the Bagsakan ridge 16). Left off on purpose: BP2's street sign "C.B. LOPEZ ST" and the ring logo (text needs the owner's approval and a source). Proof before any build: the group is 1 passed / 2 failed against the real model (both folders missing), 19/0 against a faithful fake in `Workspace.Staging`, and three deliberate breaks (alike checker neighbours, a 7-tall door, a gui on the service block) each failed the right assertion (16/3). The fake was deleted.

### Slice 4 Market, block fidelity round (R6), 2026-10-29
The owner asked me to compare the corner block and the service block with BP2 and say what is wrong ("just take a look on the bp2 and see what's wrong"). Reading `bp2_iso_block_whole.png`, `bp2_iso_corner_block.png` and BP1 `iso_bags.png` beside the model gave seven DIFFs. Replaced assertions and new ones (group `block`):
| Old | Why | New |
|---|---|---|
| 12 `Checker` squares covering z 272..296 | BP2 sets the hoarding in the north half of the long face, with louvre panels between it and the north end | covering z 258..282 (+-2), y 3..27 unchanged |
| Corner block holds 40..120 parts | The hip roof, the panel ribs and the big south screen are drawn in BP2 and need about 40 more parts | 40..170 parts |
| Service block bounds x -553..-496, z 32..84 | BP1 draws an overhanging flat canopy roof; the eaves go 1.5..2 past the walls (north, east, west; not past the annex's south wall, the Bagsakan walls start at z 84) | x -554.5..-495, z 31..84; the rest unchanged (top at most 10.5) |
| (none) dark squares near-black (35,38,44) | BP2 draws white and blue-grey squares | 6 white squares (R+G+B 2.4+) and 6 blue-grey (1.2..1.7, blue above red); the alternation rule (neighbours differ by 1.0+) is unchanged |
| (none) frame 0.3 proud, behind the squares | BP2 draws the hoarding as a panel standing off the wall | 4+ `BlockFrame` parts whose east face is at least 1.0 proud (x -539.05 or more) and enclose the squares by 0.2+ |
| (none) 3+ louvres beside the hoarding at z 258..270 and 298..310 | the hoarding moved; louvres now sit north (above the door) and south of it | 3+ east-face louvres north of z 257.5 or south of z 282.5 |
| (none) six small south louvres | BP2 wraps one large dense louvre screen round the south end | south-face `Louvre` panels cover 450+ square studs and carry 20+ `LouvreSlat` strips |
| (none) flat roof with 3 `BlockRoofBox` | BP2 draws a clean low hip roof inside the parapet | 4+ `BlockHip` slopes and a `BlockHipRidge` inside x -573..-541, z 245..323, top y 31.2..32.0; no `BlockRoofBox` |
| (none) horizontal bands only | BP2 divides the faces into a vertical panel grid | 8+ thin `BlockRib` strips (14+ tall), 4+ on the east face, none across the hoarding; east-face `BlockBand`s are cut round the hoarding |
| (none) | BP1 iso: overhanging flat canopy over the service block | 2+ `ServiceCanopy` slabs, 0.8 thick at most, top y 9.4..10.5, overhang 1.4+ on the north, east and west |
Not built (honest DIFFs): BP2's street-level ledge at the south end would project past z 325, the slot edge; BP2's tall element at the north-east top corner (too faint to read); the street sign and ring logo (text needs approval and a source). The service block stays 9.6 tall (BP1 reads about 7; doors need 8, README rule 7).

### Slice 4 Market, street front (R5a), 2026-10-29
BP2's iso crops (`bp2_iso_leantos_left.png`, `bp2_iso_vendors_tricycles.png`, audit rows A22, A23, A25) contradict two old assertions and add a third. The owner's rule: both blueprints are the absolute truth.
| Old | Why | New |
|---|---|---|
| Exactly 4 `LeanRoof`, tin colours (rust or grey), x -265..-253, z 70..91 or 229..250 | BP2 draws about 5 big red mono-pitch roofs at the street edge of the north wing, each about 24..30 long and 12..14 deep, eave about 8..9 rising to about 12..13. Only 3 fit the model: two on the strip north of the hall end wall and one in front of the north wing between the end wall and the north stair foot. The colour is BP2's red | Exactly 3 `LeanRoof`, red (172,78,72 +-28), 14..30 long, 9..14.5 deep, eave y 7.5..9.5, high edge y 11.5..13.3: 2 on x -312..-250, z 52..72 and 1 on x -264..-248, z 70..90; 8+ `LeanPost` (7.5..9.5 tall, on the ground); nothing within 1 stud of a step or landing |
| Exactly 5 `StreetStall` on the five rows z 244, 254, 264, 62, 52 at x -241..-235 | BP2 draws dense umbrella and tent clusters at the hall's front corners, about 10..12 tents, not five in a line | 10..12 `StreetStall` units in two clusters (4+ in x -248..-231, z 36..60 and 4+ in x -248..-231, z 250..274), each on the ground, 6.5..11 tall, 3+ parts, none elsewhere, no two overlapping |
| (none) | BP2 draws 5..6 thin lamp posts with a head along the kerb and beside the stairs | 6..8 `LampPost` (8..14 tall, on the ground, x -250.4..-229, outside z 148..172) each with a `LampHead` on top, as many heads as posts |
Left out on purpose (honest DIFF): the two zebra crossings of BP2 lie on the street east of x -228, outside the slot, and would break the slot and margin rules; the standing crowd of BP2 is not modelled beyond the vendor rigs (R5b).

### Slice 4 Market, side yards, props, boards and vendors (R5b), 2026-10-30
Owner decisions this session: the north side yard is a hybrid of BP1's two readings (plan crop: two narrow columns of small stalls; iso `iso_northyard`: one row of pyramid-roof booths with a long low awning on the shed wall and vans at the kerb): a row of 11 booths in front of a low awning that carries 11 counters, vans at the kerb in R5c. The south yard is two rows of 5 booths either side of the shoppers' aisle (BP1's plan reads about 7 blocks of 2x2 stalls: logged DIFF), 2 vans at the west end in R5c. Nothing replaced: new guard rails in the `yard` group, shown red against the model without side yards, props, boards or vendors (yard 16 passed / 9 failed, 6 of the 9 new).
| Item | Source | Spec in the check |
|---|---|---|
| Side booths | BP1 `iso_northyard` and `iso_shedsA` (pyramid-roof canopy booths), BP2 `bp2_plan_whole` | exactly 21 `SideStallN/S` units (11 north, 10 south), each on the ground, 7..11 tall, 3+ parts including a `Counter` and a `SideCanopy` |
| Side booth pyramid roofs (R5d, new assertion) | BP1 `iso_northyard` and `iso_shedsA` (hipped pyramid canopies, not stepped slabs) | each of the 21 booths has 4+ `SideCanopy%d+` parts; rays straight down (Include filter on that booth, any part class) rise over the pole tops: apex 1.2..4 (4 rays, one per quarter, 0.25 off the seams), eaves and corners 0.4 inside the edge 0..0.6, diagonal mid-points 0.6..1.3. Added beside the 21-unit check, which is unchanged. Reason: the flat two-plate roof read as a stepped slab (apex rise 0.85) where both blueprints show a pyramid. |
| North awning | BP1 `iso_northyard` (continuous low awning on the shed wall) | 7+ `SideAwningN` parts including a slab 100+ long, top y 7.2..8.2, z 62..71.1, with 11+ counters under it |
| Vendors | BP2 `bp2_iso_vendors_tricycles` (street vendors beside the stalls) | 6..9 rigs in `VendorNPCs`, feet on the ground, within 2.5 studs of a `Counter` or `Table`, outside the Guide, aisle and InfoPanel boxes, not inside any part |
| Price boards | brief section "Price signs" (illustrative prices) | 28+ `PriceBoard`, each within 3 studs of a counter, every label a fixed TextSize |
| `SampleBoard` | old brief, README rule 7 | one label "SAMPLE PRICES - FOR ILLUSTRATION", TextScaled off, inside the slot, clear of the wide Guide box |
| Goods | task wording "baskets, price signs, food" | `Produce` 40+ parts, `Baskets` 20+ parts, 80 percent of each within 4 studs of a counter; `MarketStalls` 15+ parts |

### Slice 4 Market, parked jeepneys and vans (R5c), 2026-10-30
Decision 2026-10-29 (owner, "you decide; my concern is only that we match the blueprint"): the 8-tricycle assertion stays (BP2 labels a TRICYCLE QUEUE) and BP1's jeepney and van sized vehicles are added next to it. BP1 `iso_stairN` draws 4 to 5 vehicles beside each stair foot, `iso_northyard` 6 to 8 boxy forms at the north kerb, `iso_shedsA` 3 to 4 in the south yard; BP2 draws a kerb row of 12 vans. Counts shrink to the part budget (11 vehicles), the vehicles never shrink (README rule 7). Nothing replaced.
| Item | Source | Spec in the check |
|---|---|---|
| `ParkedVehicle%d+` Models | BP1 `iso_stairN`, `iso_northyard`, `iso_shedsA`; BP2 `bp2_iso_vendors_tricycles` | exactly 11; attribute `Kind` Jeepney or Van; 4..10 parts; 9..14 long, 5..7.5 wide, 5..8 tall; on the ground; clear of the Guide, aisle and InfoPanel boxes; 2+ at each stair foot (centre x -240..-228, z 60..98 and 222..258), 4+ in the north yard, 2+ in the south yard |
| Overlap | BP1 plan | no vehicle overlaps another vehicle or any other built part above the ground slab |
Planned slots: apron north z 68 and 80, apron south z 229 and 241 (x -233.5, 11 long along z, beside the tricycle strips z 100..136 and 184..220 and clear of the stall clusters); north yard kerb x -450, -420, -390, -360, -330 at z 36..42; south yard west end x -455 and -435 at z 263..269.
Counter naming (R5b-1 finding): the yard names each street-stall counter `Stall<i>Table`, not `Table`. The R5b guard rails first matched `^Table%d*$` and so saw no street counter; they now match `^Counter%d*$` or `^Stall%d+Table$`. The agent's workaround (11 thin cloth parts named `Table1..11`) was dropped from `site02_props` because it added nothing the blueprints show.

### Slice 4 Market, side yards, props, boards and vendors (R5b) built, 2026-10-30
Owner look after my MATCH/DIFF table: the side yards look decent and can be polished further (next session). Board prices: the owner left them to me, "base on Philippine pricing, not too strict"; the 11 illustrative prices stay (KAMATIS P 80/kg, SIBUYAS P 120/kg, SAGING P 60/kg, MANGGA P 150/kg, BAWANG P 160/kg, TALONG P 70/kg, REPOLYO P 50/kg, PATATAS P 90/kg, KALAMANSI P 100/kg, LUYA P 130/kg, ISDA P 180/kg) and the `SampleBoard` says "SAMPLE PRICES - FOR ILLUSTRATION". Built: `site02_yard` side yards (21 `SideStall` booths of 7 parts, the north awning with 11 counters), `site02_props` (32 `PriceBoard`, `SampleBoard`, 8 vendor rigs, produce, baskets, carts, crates), coordinator rig hook `env.addRig` and the five prop folders.
Accepted deviations from the allocation: north booth counters z 53..55 (vendor at z 56.5 under the roof edge), south street row z 263..270 (a 1-stud edge had reached the aisle), price boards hang on the counter fronts so the goods stay visible.
Honest DIFFs: booth roofs are two stacked flat plates, not pyramids (a 4-wedge pyramid needs 9 parts a booth); the south yard has 5 pairs of booths, BP1's plan reads about 7 blocks of 2x2; no crowd of figures (BP2 draws 20+); the kerb strips of both yards wait for the vehicles (R5c); the south side yard was not shot from above.

### Slice 4 Market, parked jeepneys, vans and the tricycle queue (R5c) built, 2026-10-30
Built in the new module `builders/site02_vehicles.luau` (owns `Yard`, budget 160, 128 parts used; the coordinator `MODULES` list and header gained the entry). 8 tricycles (`TricycleBody/Roof/Wheel`, 5 parts each, x -234, z 103.5..132 and 188..216.5, on the apron slab) and 11 `ParkedVehicle` Models of 8 parts (Kind Jeepney or Van): 2 jeepneys at each stair foot (x -233.5, z 68, 80 and 229, 241, long axis along the street), 5 vans and jeepneys at the north yard kerb (x -450..-330 step 30, z 39), 2 vans at the west end of the south yard (x -455 and -435, z 266). No slot moved; overlap queries found no clash. Nothing replaced, no assertion touched: the R5c guard rails committed in `85bbef0` (and the older 8-tricycle assertion) are now green (yard 27/0, general 34/0, `sites_check` 277/0, `site02_check` 147/0).
Honest DIFFs: vehicles are boxy plastic forms (hood, glass band, flat top, 4 wheels), not the detailed jeepneys of the drawings (no chrome, no side lettering, no route board: text and decals are banned); a tricycle is one body box with a flat roof and 3 wheels; the tricycle queue reads as a row of coloured boxes beside the real-size jeepneys; BP2 draws 12 vans along the kerb, the model has 4 on the aprons plus the yard rows (11 in all, the part budget); the stair-foot jeepneys sit on the apron slab, so they are 0.3 higher than the yard vans.