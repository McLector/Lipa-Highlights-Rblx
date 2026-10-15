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
| Nave roof, wing roofs | maroon (150, 60, 70), corrugated look via thin ribs |
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

**Dome**: on the nave axis, about 50 studs behind the facade, over a drum with arched windows and four small corner turrets; ribbed dome with a lantern. Top about 70 studs.

**Rear**: no rear elevation is documented, so the nave ends in a plain rounded apse.

**Adjoining wing** (viewer's right, +X, front face recessed about 5 studs behind the facade): 2 storeys, arched upper windows in pilaster bays, red hip roof, a central pavilion with a curved gable and cross. About 70 studs long.

## Plaza and required props
South half of the footprint (z +10 … +100): low paving (top ≈ +0.05, cut around the JeepStop pad, InfoPanel and spawn), a central walkway to the door.
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
