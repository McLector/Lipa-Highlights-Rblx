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
