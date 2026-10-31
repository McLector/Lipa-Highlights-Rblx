-- site07_entrance: the river ring, the main entrance (bridge, gate, guard post), the Banaba function hall and the parking of Site 07.
-- Studio copy: ServerStorage.Builders.site07_entrance. Assembler: builders/site07.luau. Check: tests/site07_check.luau, groups entrance, south.
-- Owns Structure/River, Structure/Entrance, Structure/Banaba, Structure/Parking. Budget 500.
-- Source: "San_benito_blueprint.png" (main view and inset A): the oval is ringed by the North and South rivers; the main entrance and guard
--   post stand at the bridge over the South river; the Banaba function hall (a long 2-storey block under three brown hip roofs) and the
--   parking area lie beside the entrance along the South river.
-- DIFF (logged in briefs/site07.md Revision 2): the road arrives at the oval's WEST tip (Road C ends at x 570, z 240), so the bridge, gate and
--   guard post stand there, where the South river curls round the tip; the board draws them mid-south. The hall and the parking stay beside
--   the entrance in the south-west, as on the board. The hall covers the old terrain lagoon (x 700..800, z 300..352) with its court slab.
-- Frame: WORLD coordinates, y above the ground (0). Pure function of env. No text.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local box, vcyl, seg, hipRoof = env.box, env.vcyl, env.seg, env.hipRoof
	local C3 = Color3.fromRGB
	-- tidy (owner's look): one opaque deep blue-teal, raised to y 1.1 (rendered grass blades reach about y 0.9); grassy banks
	local WATER, BANK, LAWN = C3(28, 104, 142), C3(64, 86, 46), C3(104, 124, 60)
	local STONE, CREAM, TIMBER, DARK = C3(206, 198, 180), C3(236, 226, 204), C3(140, 90, 56), C3(72, 50, 36)
	local ROOF, GLASS, ASPHALT, LINE = C3(146, 90, 58), C3(70, 96, 110), C3(72, 72, 76), C3(236, 236, 230)
	local RED, WHITE = C3(190, 50, 40), C3(240, 240, 236)
	local SMOOTH, WOOD, GL, CONC, SLATE = Enum.Material.SmoothPlastic, Enum.Material.Wood, Enum.Material.Glass, Enum.Material.Concrete, Enum.Material.Slate
	local E = env.LAYOUT.ellipse

	------------------------------------------------------------------ River ring: 60 chords of the centre ellipse, water 14 wide (top 1.1) over a grassy bank 18 wide (top 0.95)
	env.section("Structure/River", function(ctx)
		local N = 60
		local function P(k)
			local t = 2 * PI * k / N
			return E.cx + E.a * math.cos(t), E.cz + E.b * math.sin(t)
		end
		for k = 0, N - 1 do
			local x0, z0 = P(k)
			local x1, z1 = P(k + 1)
			seg(ctx, "RiverBank", x0, z0, x1, z1, E.w + 4, 0, 0.95, BANK, Enum.Material.Grass, 0.6)
			local w = seg(ctx, "RiverWater", x0, z0, x1, z1, E.w, 0.3, 1.1, WATER, SMOOTH, 0.6)
			w.CanCollide = false
		end
	end)

	------------------------------------------------------------------ Entrance: bridge at the road mouth, gate, guard post
	env.section("Structure/Entrance", function(ctx)
		-- Bridge over the river at the west tip (water x 574..588 on z 240, top 1.1): deck top 1.7, a ramp at each end, parapets 3 high.
		box(ctx, "EntryBridge", 573.8, 592.2, 1.0, 1.7, 232, 248, STONE, CONC)
		env.strip(ctx, "BridgeRamp", 570.3, 573.8, 0, 1.7, 232, 248, V(1, 0, 0), STONE, CONC)
		env.strip(ctx, "BridgeRamp", 592.2, 595.7, 0, 1.7, 232, 248, V(-1, 0, 0), STONE, CONC)
		-- Solid parapets 3 high on the deck (the board's bridge has low white side walls), with a timber cap.
		box(ctx, "BridgeRail", 574, 592, 1.7, 4.7, 232.2, 232.8, CREAM, CONC)
		box(ctx, "BridgeRail", 574, 592, 1.7, 4.7, 247.2, 247.8, CREAM, CONC)
		box(ctx, "BridgeRailCap", 573.8, 592.2, 4.7, 4.9, 232.1, 232.9, TIMBER, WOOD)
		box(ctx, "BridgeRailCap", 573.8, 592.2, 4.7, 4.9, 247.1, 247.9, TIMBER, WOOD)
		for _, z in ipairs({ 231, 249 }) do
			box(ctx, "BridgeAbutment", 570.5, 575, 0, 1.9, z - 1.2, z + 1.2, STONE, SLATE)
			box(ctx, "BridgeAbutment", 591, 595.5, 0, 1.9, z - 1.2, z + 1.2, STONE, SLATE)
		end

		-- Main entrance gate just past the bridge: two stone piers either side of the drive, a timber beam at y 10, a brown hip roof.
		box(ctx, "GatePier", 610, 614, 0, 11, 225, 230, CREAM, CONC)
		box(ctx, "GatePier", 610, 614, 0, 11, 250, 255, CREAM, CONC)
		box(ctx, "GatePierCap", 609.6, 614.4, 11, 11.5, 224.6, 230.4, STONE, CONC)
		box(ctx, "GatePierCap", 609.6, 614.4, 11, 11.5, 249.6, 255.4, STONE, CONC)
		box(ctx, "GateBeam", 609.6, 614.4, 10, 11.5, 230, 250, DARK, WOOD)
		hipRoof(ctx, "GateRoof", 607.5, 616.5, 223, 257, 11.5, 3, ROOF, SLATE)

		-- Guard post booth beside the drive (north side), past the gate: cream walls, door 8.2 tall on the south face, windows, hip roof.
		box(ctx, "GuardPostBody", 618, 628, 0, 9, 214, 224, CREAM, CONC)
		box(ctx, "GuardPostDoor", 621, 625, 0, 8.2, 224, 224.3, DARK, WOOD)
		box(ctx, "GuardPostWindow", 617.8, 618, 3.5, 7, 216, 222, GLASS, GL)
		box(ctx, "GuardPostWindow", 626, 628, 3.5, 7, 224, 224.2, GLASS, GL)
		box(ctx, "GuardPostSill", 617.5, 618, 3, 3.5, 216, 222, TIMBER, WOOD)
		hipRoof(ctx, "GuardPostRoof", 616.5, 629.5, 213, 225, 9, 3.5, ROOF, SLATE)
		-- Barrier post with its arm raised (it never crosses the drive).
		box(ctx, "BarrierPost", 628.2, 629.2, 0, 3.5, 226, 227, RED, SMOOTH)
		local arm = box(ctx, "BarrierArm", 628.4, 629, 3.5, 13, 226.2, 226.8, WHITE, SMOOTH)
		arm.CanCollide = false
	end)

	------------------------------------------------------------------ Banaba function hall: court over the old terrain lagoon, 2-storey block, 3 roofs
	env.section("Structure/Banaba", function(ctx)
		-- The court slab is buried 0.5 into the ground so the terrain water under it (waves 0.15) never shows; it reaches 6 studs past the
		-- water cells (x 700..800, z 300..352) because the terrain smooths the water's edge about 4 studs onto the grass. Tidy (owner's look):
		-- it is lawn now, with a small stone forecourt at the entrance and a walk along the front, not a grey court.
		box(ctx, "BanabaCourt", 694, 806, -0.5, 0.35, 292, 360, LAWN, Enum.Material.Grass)
		box(ctx, "BanabaForecourt", 738, 766, 0.35, 0.42, 292, 314, STONE, SLATE)
		box(ctx, "BanabaWalk", 712, 792, 0.35, 0.42, 309, 313.6, STONE, SLATE)
		box(ctx, "BanabaHallBody", 714, 790, 0.35, 19, 314, 344, CREAM, CONC)
		box(ctx, "BanabaPlinth", 713.6, 790.4, 0.35, 1.2, 313.6, 344.4, STONE, CONC)
		box(ctx, "BanabaBand", 713.7, 790.3, 9.6, 10.4, 313.7, 314, TIMBER, WOOD)
		-- North face (toward the parking and the walk): ground-floor glass bays, the entrance doors, the upper windows.
		for k = 0, 8 do
			local x = 717 + 8 * k
			if x < 744 or x > 758 then
				box(ctx, "BanabaGlass", x, x + 6, 1.5, 8.6, 313.75, 314, GLASS, GL)
			end
		end
		box(ctx, "BanabaDoor", 747, 757, 0.35, 8.8, 313.7, 314, DARK, WOOD)
		for k = 0, 9 do
			local x = 717.5 + 7.4 * k
			box(ctx, "BanabaWindow", x, x + 4, 12, 16.5, 313.75, 314, GLASS, GL)
		end
		-- Three brown hip roof sections (the board's lower west and east roofs and the taller centre), plus the entrance canopy.
		hipRoof(ctx, "BanabaRoof", 712, 738, 312, 346, 19, 5, ROOF, SLATE)
		hipRoof(ctx, "BanabaRoof", 736, 770, 310, 348, 19, 7, ROOF, SLATE)
		hipRoof(ctx, "BanabaRoof", 768, 792, 312, 346, 19, 5, ROOF, SLATE)
		for _, x in ipairs({ 744.5, 759.5 }) do
			for _, z in ipairs({ 302.5, 312.5 }) do
				vcyl(ctx, "CanopyPost", x, z, 0.35, 9, 0.8, CREAM, CONC)
			end
		end
		hipRoof(ctx, "BanabaRoof", 743, 761, 301, 314, 9, 2.5, ROOF, SLATE)
		-- Planters along the front (low, under 3).
		for _, x in ipairs({ 722, 734, 770, 782 }) do
			box(ctx, "BanabaPlanter", x - 3, x + 3, 0.35, 1.4, 306, 309, STONE, CONC)
			box(ctx, "BanabaPlanterGreen", x - 2.6, x + 2.6, 1.4, 2.4, 306.4, 308.6, C3(46, 104, 50), Enum.Material.Grass)
		end
	end)

	------------------------------------------------------------------ Parking: lot west of the hall, its drive from the plaza, bays and cars
	env.section("Structure/Parking", function(ctx)
		box(ctx, "ParkingLot", 652, 698, 0, 0.28, 300, 340, ASPHALT, CONC)
		box(ctx, "ParkingDrive", 648, 656, 0, 0.28, 260, 300, ASPHALT, CONC)
		for k = 0, 8 do
			local x = 656 + 5 * k
			box(ctx, "ParkingLine", x - 0.15, x + 0.15, 0.28, 0.32, 302, 313, LINE, SMOOTH)
			box(ctx, "ParkingLine", x - 0.15, x + 0.15, 0.28, 0.32, 327, 338, LINE, SMOOTH)
		end
		local cars = {
			{ 658.5, 307.5, C3(200, 200, 205) }, { 663.5, 307.5, C3(40, 60, 110) }, { 678.5, 307.5, C3(150, 30, 30) },
			{ 688.5, 307.5, C3(230, 230, 228) }, { 668.5, 332.5, C3(60, 60, 64) }, { 683.5, 332.5, C3(180, 170, 150) },
		}
		for _, c in ipairs(cars) do
			local x, z = c[1], c[2]
			box(ctx, "CarBody", x - 2, x + 2, 0.9, 2.6, z - 4.2, z + 4.2, c[3], SMOOTH)
			box(ctx, "CarCabin", x - 1.8, x + 1.8, 2.6, 4.1, z - 2, z + 1.6, GLASS, GL)
			for _, wz in ipairs({ z - 2.6, z + 2.6 }) do
				ctx:cyl("CarWheels", V(4.2, 1.6, 1.6), CF(x, 0.8, wz), DARK, SMOOTH)
			end
		end
	end)
end
