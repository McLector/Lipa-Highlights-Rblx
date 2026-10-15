# Site 06 brief — The Outlets at LIMA Estate + Aboitiz Pitch

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

## Art-observation hooks for dialogue (Slice 12 will source them)
Strong colour contrast of warm orange timber cladding against white render and dark glass; deep overhangs that create shade and a clear horizontal rhythm; repeated vertical slats and planks; open green pitch against the dense block of shops.
