-- site03_context: the CONTEXT of Site 03 (Lomi King), job L3d. Built from the Lomi King Architectural Blueprint Board (crops board_left_ctx = north side,
--   board_right_ctx = south side) and the Street View photo. No text, no SurfaceGui, no Decal, nothing above y 72.
-- Studio copy: ServerStorage.Builders.site03_context. Assembler: builders/site03.luau. Check: tests/site03_check.luau, group "context" (also "general", "clear").
-- Owns the Folder Context (budget 300). Direct children of Context:
--   NeighbourN (Model, x 290..342, z 86..112)   grey-blue concrete block: lower 2-storey front part with a ground-floor shopfront and a thin awning, a taller
--                                               3-storey block behind it with a flat roof and parapet, mullioned two-pane windows on the west faces, small windows on
--                                               the south face, a roof service arm that ends the service drop.
--   NeighbourS (Model, x 290..342, z 181..194)  grey-blue 3-storey block: two roll-up shutters on the ground floor (west face), louvred windows on floors 2 and 3,
--                                               a thin balcony slab with a glass balustrade, the upper floor set back, a lower stepped rear block.
--   UtilityPoleN (x 270, z 98) with the GuyWire, UtilityPoleS (x 270, z 186) with the nested SubPole: round concrete poles to y 56, two crossarms, insulators, braces.
--   TransformerA, TransformerB (on UtilityPoleN) and TransformerC (on UtilityPoleS): SEPARATE Models, so the pole boxes stay centred.
--   Wires (Folder of PoleWire* parts): lines between the poles along z over x 267..273 (at y 30 and higher), service drops to the two neighbours, stubs to the slot edge.
--   CarVan (x 276.5..282, z 181.5..193.5) and Motorbike (x 284..286.5, z 182..188.5), parked along z; parts are named Van* and Bike* (the prefix Car is reserved).
-- FRAME: every number is WORLD (x east, z south, y up; this site faces WEST, the street is at small x). env.wbox / wvcyl / wball build world-aligned parts. A ROTATED part
--   (wire, brace, guy, fork) is built by seg(): both end points are converted with env.W (world minus the site origin) BEFORE the CFrame is made, because ctx:part takes a
--   LOCAL CFrame. Pure function of env: no DataModel reads.
-- Seams: nothing east of x 274 between z 113 and z 180 except the neighbours' own faces (no wire there); the Guide box, the panel zone, the aisle and the road mouth stay free
--   of standing parts (the wires cross over them at y 30 and higher, the check measures y 0..8); the driveway z 168..178 and the CornerLamp x 273.3 z 167.2 are not touched.
return function(env)
	local V, CF = env.V, env.CF
	local W, wbox, wvcyl, wball = env.W, env.wbox, env.wvcyl, env.wball
	local PI = math.pi

	-- Colours and materials
	local C3 = Color3.fromRGB
	local WALL, TRIM, FRAME = C3(150, 165, 180), C3(100, 115, 135), C3(70, 82, 100)
	local GLASS, GLASS_LIGHT = C3(25, 45, 85), C3(150, 180, 205)
	local SHUT, SHUT_D, LOUVRE, AWN = C3(170, 175, 182), C3(140, 146, 154), C3(120, 130, 145), C3(110, 122, 135)
	local POLE, POLE_D, STEEL, ARM, INSUL = C3(165, 165, 160), C3(140, 140, 136), C3(60, 62, 68), C3(95, 72, 54), C3(170, 120, 80)
	local TFC, TFD, WIRE, AC = C3(140, 146, 152), C3(105, 110, 116), C3(28, 28, 32), C3(200, 204, 208)
	local SMOOTH, METAL, CONC, GLASSM, WOODM = Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Concrete, Enum.Material.Glass, Enum.Material.Wood

	-- A rotated bar between two WORLD points (square section t, length along local Z).
	local function seg(ctx, name, ax, ay, az, bx, by, bz, t, color, material)
		local a, b = W(ax, ay, az), W(bx, by, bz)
		return ctx:part(name, V(t, t, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), color, material)
	end

	-- Two-pane mullioned window on a west-facing wall (wall face at x = fx), centre z zc, width w, y0..y1. The backing shows between the panes as the mullion.
	local function winWest(ctx, tag, fx, zc, w, y0, y1)
		local pw = (w - 0.7) / 2
		wbox(ctx, "FrameBack" .. tag, fx - 0.2, fx + 0.1, y0, y1, zc - w / 2, zc + w / 2, FRAME, SMOOTH)
		wbox(ctx, "WindowGlassA" .. tag, fx - 0.3, fx - 0.1, y0 + 0.25, y1 - 0.25, zc - w / 2 + 0.2, zc - w / 2 + 0.2 + pw, GLASS, GLASSM)
		wbox(ctx, "WindowGlassB" .. tag, fx - 0.3, fx - 0.1, y0 + 0.25, y1 - 0.25, zc + w / 2 - 0.2 - pw, zc + w / 2 - 0.2, GLASS, GLASSM)
	end

	-- Louvred window on a west-facing wall: dark backing, three louvre slats (6 high from y0).
	local function louvreWest(ctx, tag, fx, zc, w, y0)
		wbox(ctx, "FrameBack" .. tag, fx - 0.3, fx + 0.1, y0, y0 + 6, zc - w / 2, zc + w / 2, FRAME, SMOOTH)
		for i = 1, 3 do
			local yc = y0 + 1.0 + (i - 1) * 2.0
			wbox(ctx, "ShutterLouvre" .. tag .. "_" .. i, fx - 0.45, fx - 0.1, yc - 0.45, yc + 0.45, zc - w / 2 + 0.2, zc + w / 2 - 0.2, LOUVRE, METAL)
		end
	end

	-- Louvred window on the north face (z = 181.2) of NeighbourS, 5 high from y0: dark backing and one louvre plate.
	local function louvreNorth(ctx, tag, xc, w, y0)
		wbox(ctx, "FrameBack" .. tag, xc - w / 2, xc + w / 2, y0, y0 + 5, 181.0, 181.35, FRAME, SMOOTH)
		wbox(ctx, "ShutterLouvre" .. tag, xc - w / 2 + 0.2, xc + w / 2 - 0.2, y0 + 0.4, y0 + 4.6, 180.95, 181.1, LOUVRE, METAL)
	end

	local context = env.container("Context")

	------------------------------------------------------------------ NeighbourN
	local nN = env.newChild(context, "NeighbourN", "Model")
	env.section("Context", function(ctx)
		-- massing: lower front block (2 storeys, west face x 293) and the taller 3-storey block behind it (west face x 306)
		wbox(ctx, "NBlockFront", 293, 306, 0, 24, 86, 112, WALL, CONC)
		wbox(ctx, "NBlockTall", 306, 342, 0, 36, 86, 112, WALL, CONC)

		-- ground-floor shopfront on the west face: header, five piers, four glass bays (the bays are the floor 1 windows)
		wbox(ctx, "NShopHeader", 292.6, 293.1, 8.6, 9.3, 87, 111, FRAME, SMOOTH)
		local pz = { 87, 92.75, 98.5, 104.25, 110 }
		for i = 1, 5 do
			wbox(ctx, "NShopPier" .. i, 292.7, 293.1, 0, 8.6, pz[i], pz[i] + 1, FRAME, SMOOTH)
		end
		for i = 1, 4 do
			wbox(ctx, "WindowShop" .. i, 292.85, 293.05, 0.6, 8.3, pz[i] + 1, pz[i + 1], GLASS, GLASSM)
		end
		-- thin awning, the outermost part of the building (x 290)
		wbox(ctx, "NAwning", 290, 293.1, 9.3, 9.7, 87, 111, AWN, METAL)
		wbox(ctx, "NAwningLip", 290, 290.3, 8.7, 9.7, 87, 111, TRIM, SMOOTH)
		seg(ctx, "NAwningStrutN", 292.8, 8.3, 87.5, 290.4, 9.3, 87.5, 0.25, FRAME, METAL)
		seg(ctx, "NAwningStrutS", 292.8, 8.3, 110.5, 290.4, 9.3, 110.5, 0.25, FRAME, METAL)

		-- floor 2 (y 12..24) on the front block: band, four windows, a transom ribbon across them
		wbox(ctx, "NBand12", 292.6, 306, 11.8, 12.5, 86, 112, TRIM, SMOOTH)
		for i, zc in ipairs({ 91, 97, 103, 109 }) do
			winWest(ctx, "N2_" .. i, 293, zc, 3.6, 15, 21)
		end
		wbox(ctx, "NTransom2", 292.55, 292.7, 17.85, 18.15, 89.2, 110.8, TRIM, SMOOTH)
		-- front block roof: cornice and parapet, two roof units, the service arm that ends the service drop from UtilityPoleN
		wbox(ctx, "NCorniceF", 292.6, 306, 23.4, 24, 86, 112, TRIM, SMOOTH)
		wbox(ctx, "NParapetFW", 292.9, 293.4, 24, 24.9, 86, 112, TRIM, SMOOTH)
		wbox(ctx, "NParapetFN", 293.4, 306, 24, 24.9, 86, 86.5, TRIM, SMOOTH)
		wbox(ctx, "NParapetFS", 293.4, 306, 24, 24.9, 111.5, 112, TRIM, SMOOTH)
		wbox(ctx, "NRoofAC1", 297, 299.6, 24, 25.5, 90, 92.6, AC, SMOOTH)
		wbox(ctx, "NRoofAC2", 297, 299.6, 24, 25.5, 104, 106.6, AC, SMOOTH)
		wvcyl(ctx, "NServiceMast", 293.9, 100.5, 24, 28.6, 0.4, STEEL, METAL)
		wbox(ctx, "NServiceArm", 292.5, 293.9, 27.9, 28.2, 100.35, 100.65, STEEL, METAL)
		wball(ctx, "NServiceKnob", 292.55, 28.05, 100.5, 0.4, INSUL, SMOOTH)

		-- floor 3 (y 24..36) on the tall block west face: four windows and the transom ribbon
		for i, zc in ipairs({ 91, 97, 103, 109 }) do
			winWest(ctx, "N3_" .. i, 306, zc, 3.6, 27.2, 32.8)
		end
		wbox(ctx, "NTransom3", 305.55, 305.7, 29.85, 30.15, 89.2, 110.8, TRIM, SMOOTH)
		-- tall block roof: parapet (top 36.6), stair head and water tank (top 37.9)
		wbox(ctx, "NParapetTW", 305.9, 306.5, 36, 36.6, 86, 112, TRIM, SMOOTH)
		wbox(ctx, "NParapetTE", 341.5, 342, 36, 36.6, 86, 112, TRIM, SMOOTH)
		wbox(ctx, "NParapetTN", 306.5, 341.5, 36, 36.6, 86, 86.5, TRIM, SMOOTH)
		wbox(ctx, "NParapetTS", 306.5, 341.5, 36, 36.6, 111.5, 112, TRIM, SMOOTH)
		wbox(ctx, "NStairHead", 330, 338, 36, 37.6, 92, 99, WALL, CONC)
		wvcyl(ctx, "NWaterTank", 322, 106, 36, 37.9, 3.2, TFD, METAL)

		-- small windows on the south side face (z 112), flush with the wall
		for i, p in ipairs({ { 314, 29.5 }, { 324, 29.5 }, { 334, 29.5 }, { 319, 17.5 }, { 329, 17.5 } }) do
			wbox(ctx, "WindowSmall" .. i, p[1] - 0.9, p[1] + 0.9, p[2] - 0.9, p[2] + 0.9, 111.8, 112.05, GLASS, GLASSM)
		end
	end, nN)

	------------------------------------------------------------------ NeighbourS
	local nS = env.newChild(context, "NeighbourS", "Model")
	env.section("Context", function(ctx)
		-- massing: floors 1-2 (west face x 290.4), floor 3 set back to x 292.4, a lower stepped rear block (top y 30)
		wbox(ctx, "SBlockLow", 290.4, 320, 0, 24, 181.2, 194, WALL, CONC)
		wbox(ctx, "SBlockUpper", 292.4, 320, 24, 36, 181.2, 194, WALL, CONC)
		wbox(ctx, "SBlockRear", 320, 342, 0, 30, 181.2, 194, WALL, CONC)
		-- thin balcony slab over floor 2, glass balustrade 3 high with a steel top rail, trim band at y 12
		wbox(ctx, "SBalcSlab", 289.95, 292.4, 24, 24.7, 181.2, 194, TRIM, SMOOTH)
		local bal = wbox(ctx, "SBalcGlass", 290.0, 290.15, 24.7, 27.7, 181.6, 193.6, GLASS_LIGHT, GLASSM)
		bal.Transparency = 0.5
		wbox(ctx, "SBalcRail", 289.95, 290.2, 27.7, 28.0, 181.4, 193.8, STEEL, METAL)
		wbox(ctx, "SBand12", 289.95, 290.4, 11.8, 12.5, 181.2, 194, TRIM, SMOOTH)

		-- two roll-up shutters on the ground floor (west face): panel, roll casing, two ribs, bottom bar each
		for i, z0 in ipairs({ 181.9, 187.9 }) do
			local z1 = z0 + 5.2
			wbox(ctx, "ShutterPanel" .. i, 290.1, 290.4, 0, 8.6, z0, z1, SHUT, METAL)
			wbox(ctx, "ShutterBox" .. i, 289.95, 290.6, 8.6, 10.2, z0 - 0.2, z1 + 0.2, SHUT_D, METAL)
			wbox(ctx, "ShutterRibA" .. i, 289.95, 290.2, 2.8, 3.05, z0, z1, SHUT_D, METAL)
			wbox(ctx, "ShutterRibB" .. i, 289.95, 290.2, 5.6, 5.85, z0, z1, SHUT_D, METAL)
			wbox(ctx, "ShutterBar" .. i, 289.95, 290.3, 0, 0.6, z0 + 0.6, z1 - 0.6, FRAME, METAL)
		end

		-- louvred windows: three on the west face of floor 2 and three on the set-back west face of floor 3, two each on the north (driveway) face
		for i, zc in ipairs({ 183.2, 187.5, 191.8 }) do
			louvreWest(ctx, "S2_" .. i, 290.4, zc, 3.0, 15)
			louvreWest(ctx, "S3_" .. i, 292.4, zc, 3.0, 27)
		end
		for i, xc in ipairs({ 300, 312 }) do
			louvreNorth(ctx, "S2N" .. i, xc, 3.0, 15)
			louvreNorth(ctx, "S3N" .. i, xc, 3.0, 27)
		end

		-- roofs: upper block parapet (top 36.6), rear block parapet (top 30.6), stair head and water tank
		wbox(ctx, "SParapetUW", 292.4, 292.9, 36, 36.6, 181.2, 194, TRIM, SMOOTH)
		wbox(ctx, "SParapetUN", 292.9, 319.5, 36, 36.6, 181.2, 181.7, TRIM, SMOOTH)
		wbox(ctx, "SParapetUS", 292.9, 319.5, 36, 36.6, 193.5, 194, TRIM, SMOOTH)
		wbox(ctx, "SParapetUE", 319.5, 320, 36, 36.6, 181.7, 193.5, TRIM, SMOOTH)
		wbox(ctx, "SParapetRN", 320, 342, 30, 30.6, 181.2, 181.7, TRIM, SMOOTH)
		wbox(ctx, "SParapetRS", 320, 342, 30, 30.6, 193.5, 194, TRIM, SMOOTH)
		wbox(ctx, "SParapetRE", 341.5, 342, 30, 30.6, 181.7, 193.5, TRIM, SMOOTH)
		wbox(ctx, "SStairHead", 304, 312, 36, 37.6, 185, 191, WALL, CONC)
		wvcyl(ctx, "SWaterTank", 330, 188, 30, 31.9, 3.0, TFD, METAL)

		-- service arm on the set-back wall, between two windows, where the drop from UtilityPoleS ends
		wbox(ctx, "SServiceArm", 291.7, 292.5, 29.1, 29.4, 189.5, 189.8, STEEL, METAL)
		wball(ctx, "SServiceKnob", 291.75, 29.25, 189.65, 0.4, INSUL, SMOOTH)
	end, nS)

	------------------------------------------------------------------ utility poles
	-- A round concrete pole to y 56.2 with two wooden crossarms along x (x - 3.5 .. x + 3.5 at y 52, x - 3.2 .. x + 3.2 at y 46), insulators and two diagonal braces.
	local function buildPole(ctx, x, z)
		wvcyl(ctx, "PoleBase", x, z, 0, 1.6, 1.7, POLE_D, CONC)
		wvcyl(ctx, "PoleShaftLow", x, z, 1.6, 28, 1.3, POLE, CONC)
		wvcyl(ctx, "PoleShaftHigh", x, z, 28, 55.6, 1.1, POLE, CONC)
		wvcyl(ctx, "PoleTop", x, z, 55.6, 56.2, 0.8, STEEL, METAL)
		wvcyl(ctx, "PoleBandHigh", x, z, 50.8, 52.8, 1.4, STEEL, METAL)
		wvcyl(ctx, "PoleBandLow", x, z, 44.8, 46.8, 1.4, STEEL, METAL)
		wbox(ctx, "PoleArmHigh", x - 3.5, x + 3.5, 51.4, 52.2, z - 0.3, z + 0.3, ARM, WOODM)
		wbox(ctx, "PoleArmLow", x - 3.2, x + 3.2, 45.4, 46.2, z - 0.3, z + 0.3, ARM, WOODM)
		for i, dx in ipairs({ -2.8, -1.1, 1.1, 2.8 }) do
			wvcyl(ctx, "PoleInsulatorH" .. i, x + dx, z, 52.2, 53.1, 0.4, INSUL, SMOOTH)
		end
		for i, dx in ipairs({ -2.5, 2.5 }) do
			wvcyl(ctx, "PoleInsulatorL" .. i, x + dx, z, 46.2, 47.1, 0.4, INSUL, SMOOTH)
		end
		seg(ctx, "PoleBraceW", x - 0.6, 48.2, z, x - 2.6, 51.4, z, 0.3, STEEL, METAL)
		seg(ctx, "PoleBraceE", x + 0.6, 48.2, z, x + 2.6, 51.4, z, 0.3, STEEL, METAL)
	end

	local poleN = env.newChild(context, "UtilityPoleN", "Model")
	env.section("Context", function(ctx)
		buildPole(ctx, 270, 98)
		-- the guy wire, diagonal to the ground (board left crop falls toward the south): strap, wire, ground anchor
		wvcyl(ctx, "GuyBand", 270, 98, 29.7, 30.9, 1.5, STEEL, METAL)
		seg(ctx, "GuyWire", 270, 30.3, 98.7, 270, 1.0, 103.8, 0.2, C3(90, 95, 100), METAL)
		wvcyl(ctx, "GuyAnchor", 270, 103.8, 0, 1.1, 0.7, POLE_D, CONC)
	end, poleN)

	local poleS = env.newChild(context, "UtilityPoleS", "Model")
	env.section("Context", function(ctx)
		buildPole(ctx, 270, 186)
	end, poleS)
	-- the board's second, thinner pole beside the south pole (nested inside it)
	local subPole = env.newChild(poleS, "SubPole", "Model")
	env.section("Context", function(ctx)
		wvcyl(ctx, "SubPoleShaft", 271.55, 187.15, 0, 41, 0.7, POLE, CONC)
		wvcyl(ctx, "SubPoleCap", 271.55, 187.15, 41, 41.4, 0.5, STEEL, METAL)
		wbox(ctx, "SubPoleArm", 270.7, 272.4, 39.5, 40, 186.9, 187.4, ARM, WOODM)
		wvcyl(ctx, "SubPoleInsulator1", 271.0, 187.15, 40, 40.8, 0.3, INSUL, SMOOTH)
		wvcyl(ctx, "SubPoleInsulator2", 272.1, 187.15, 40, 40.8, 0.3, INSUL, SMOOTH)
	end, subPole)

	------------------------------------------------------------------ transformers (separate Models, hung on the poles with a gap and two straps)
	local function transformer(ctx, x, z, zPole, d, y0, y1, bushings)
		wvcyl(ctx, "TfBody", x, z, y0, y1, d, TFC, METAL)
		wvcyl(ctx, "TfLid", x, z, y1, y1 + 0.4, d - 0.3, TFD, METAL)
		for i, dx in ipairs(bushings) do
			wvcyl(ctx, "TfBushing" .. i, x + dx, z, y1 + 0.4, y1 + 1.3, 0.35, INSUL, SMOOTH)
		end
		local zlo, zhi = math.min(z, zPole), math.max(z, zPole)
		wbox(ctx, "TfStrapUpper", x - 0.4, x + 0.4, y1 - 0.9, y1 - 0.4, zlo, zhi, STEEL, METAL)
		wbox(ctx, "TfStrapLower", x - 0.4, x + 0.4, y0 + 0.5, y0 + 1.0, zlo, zhi, STEEL, METAL)
	end
	local tfA = env.newChild(context, "TransformerA", "Model")
	env.section("Context", function(ctx) transformer(ctx, 270, 95.9, 98, 2.0, 34.3, 37.9, { -0.5, 0.5 }) end, tfA)
	local tfB = env.newChild(context, "TransformerB", "Model")
	env.section("Context", function(ctx) transformer(ctx, 270, 100.1, 98, 2.0, 34.3, 37.9, { -0.5, 0.5 }) end, tfB)
	local tfC = env.newChild(context, "TransformerC", "Model")
	env.section("Context", function(ctx) transformer(ctx, 270, 183.9, 186, 1.6, 34.6, 37.2, { 0 }) end, tfC)

	------------------------------------------------------------------ wires
	local wires = env.newChild(context, "Wires", "Folder")
	env.section("Context", function(ctx)
		local n = 0
		local function poly(pts) -- consecutive points {x, y, z} joined by straight PoleWire segments
			for i = 1, #pts - 1 do
				n += 1
				local a, b = pts[i], pts[i + 1]
				seg(ctx, "PoleWire" .. n, a[1], a[2], a[3], b[1], b[2], b[3], 0.15, WIRE, SMOOTH)
			end
		end
		-- three lines on the upper crossarm, pole to pole along z: 3 segments, ends at the insulator tops (y 53.2), the middle 2.4..2.7 lower
		for _, l in ipairs({ { 267.2, 2.5 }, { 268.9, 2.7 }, { 271.1, 2.4 } }) do
			local x, sag = l[1], l[2]
			poly({ { x, 53.2, 98 }, { x, 53.2 - sag, 127.3 }, { x, 53.2 - sag, 156.7 }, { x, 53.2, 186 } })
		end
		-- one line on the lower crossarm
		poly({ { 267.5, 47.2, 98 }, { 267.5, 44.9, 127.3 }, { 267.5, 44.9, 156.7 }, { 267.5, 47.2, 186 } })
		-- the lower bundle at third-floor height, on the west side of the poles (2 segments)
		poly({ { 269.2, 33, 98 }, { 269.2, 30.2, 142 }, { 269.2, 33, 186 } })
		-- service drops from the lower crossarms to the neighbours' service arms (each ends on a knob of the neighbour)
		poly({ { 272.5, 47.2, 98 }, { 282.5, 36.2, 99.3 }, { 292.45, 28.05, 100.5 } })
		poly({ { 272.5, 47.2, 186 }, { 282.5, 37.0, 187.3 }, { 291.8, 29.25, 189.65 } })
		-- short runs from the upper crossarms to the slot edge (z 81 and z 199)
		poly({ { 272.8, 53.2, 98 }, { 272.8, 52.3, 81 } })
		poly({ { 272.8, 53.2, 186 }, { 272.8, 52.3, 199 } })
	end, wires)

	------------------------------------------------------------------ vehicles (parked along z, nose to the north)
	local van = env.newChild(context, "CarVan", "Model")
	env.section("Context", function(ctx)
		local BODY, ROOF, VGLASS, TYRE = C3(205, 208, 214), C3(185, 189, 196), C3(40, 55, 75), C3(30, 30, 34)
		wbox(ctx, "VanLower", 277.0, 281.5, 1.3, 4.0, 181.8, 193.2, BODY, SMOOTH)
		wbox(ctx, "VanHood", 277.2, 281.3, 4.0, 4.5, 182.0, 185.5, BODY, SMOOTH)
		wbox(ctx, "VanCabin", 277.1, 281.4, 4.0, 5.8, 185.5, 193.2, BODY, SMOOTH)
		wbox(ctx, "VanRoof", 277.2, 281.3, 5.8, 6.1, 185.7, 193.0, ROOF, SMOOTH)
		wbox(ctx, "VanGlassFront", 277.4, 281.1, 4.5, 5.65, 185.35, 185.5, VGLASS, GLASSM)
		wbox(ctx, "VanGlassRear", 277.4, 281.1, 4.5, 5.65, 193.2, 193.35, VGLASS, GLASSM)
		wbox(ctx, "VanGlassW1", 277.0, 277.12, 4.4, 5.6, 186.0, 189.1, VGLASS, GLASSM)
		wbox(ctx, "VanGlassW2", 277.0, 277.12, 4.4, 5.6, 189.6, 192.7, VGLASS, GLASSM)
		wbox(ctx, "VanGlassE1", 281.38, 281.5, 4.4, 5.6, 186.0, 189.1, VGLASS, GLASSM)
		wbox(ctx, "VanGlassE2", 281.38, 281.5, 4.4, 5.6, 189.6, 192.7, VGLASS, GLASSM)
		wbox(ctx, "VanBumperF", 276.9, 281.6, 1.0, 2.0, 181.5, 182.0, TYRE, SMOOTH)
		wbox(ctx, "VanBumperR", 276.9, 281.6, 1.0, 2.0, 193.0, 193.5, TYRE, SMOOTH)
		wbox(ctx, "VanHeadlight1", 277.4, 278.5, 2.8, 3.6, 181.65, 181.8, C3(255, 244, 205), SMOOTH)
		wbox(ctx, "VanHeadlight2", 280.0, 281.1, 2.8, 3.6, 181.65, 181.8, C3(255, 244, 205), SMOOTH)
		wbox(ctx, "VanGrille", 278.7, 279.8, 2.4, 3.4, 181.7, 181.8, TYRE, SMOOTH)
		wbox(ctx, "VanTaillight1", 277.2, 277.9, 2.9, 3.8, 193.2, 193.35, C3(190, 30, 36), SMOOTH)
		wbox(ctx, "VanTaillight2", 280.6, 281.3, 2.9, 3.8, 193.2, 193.35, C3(190, 30, 36), SMOOTH)
		wbox(ctx, "VanMirrorW", 276.8, 277.1, 4.5, 4.95, 185.7, 186.1, TYRE, SMOOTH)
		wbox(ctx, "VanMirrorE", 281.4, 281.7, 4.5, 4.95, 185.7, 186.1, TYRE, SMOOTH)
		-- wheels: axis along world X (a Cylinder's axis is local X), tyres 0.7 wide, hub caps 0.1 proud of the tyre faces
		local k = 0
		for _, wz in ipairs({ 184.4, 190.6 }) do
			for _, side in ipairs({ "W", "E" }) do
				k += 1
				local tx = side == "W" and 276.95 or 281.55
				local hx = side == "W" and 276.6 or 281.9
				ctx:cyl("VanWheel" .. k, V(0.7, 2.4, 2.4), CF(W(tx, 1.2, wz)), TYRE, SMOOTH)
				ctx:cyl("VanHub" .. k, V(0.2, 1.2, 1.2), CF(W(hx, 1.2, wz)), SHUT, METAL)
			end
		end
	end, van)

	local bike = env.newChild(context, "Motorbike", "Model")
	env.section("Context", function(ctx)
		local TYRE, RED, DARK = C3(30, 30, 34), C3(170, 40, 40), C3(45, 47, 52)
		ctx:cyl("BikeWheelF", V(0.5, 2.2, 2.2), CF(W(285.25, 1.1, 183.1)), TYRE, SMOOTH)
		ctx:cyl("BikeWheelR", V(0.5, 2.2, 2.2), CF(W(285.25, 1.1, 187.35)), TYRE, SMOOTH)
		wbox(ctx, "BikeFenderF", 284.95, 285.55, 2.25, 2.5, 182.2, 184.0, RED, SMOOTH)
		wbox(ctx, "BikeFenderR", 284.95, 285.55, 2.25, 2.5, 186.4, 188.45, RED, SMOOTH)
		wbox(ctx, "BikeEngine", 284.9, 285.6, 1.2, 2.4, 184.3, 186.0, STEEL, METAL)
		wbox(ctx, "BikeTank", 284.8, 285.7, 2.4, 3.1, 184.1, 185.7, RED, SMOOTH)
		wbox(ctx, "BikeSeat", 284.8, 285.7, 2.55, 3.0, 185.7, 187.7, DARK, SMOOTH)
		wbox(ctx, "BikeCowl", 284.7, 285.8, 1.7, 2.55, 185.9, 187.4, RED, SMOOTH)
		wball(ctx, "BikeHeadlight", 285.25, 2.75, 183.5, 0.7, C3(255, 244, 205), SMOOTH)
		seg(ctx, "BikeFork", 285.25, 1.1, 183.1, 285.25, 3.1, 184.0, 0.3, STEEL, METAL)
		wbox(ctx, "BikeHandlebar", 284.3, 286.2, 3.1, 3.4, 183.85, 184.15, STEEL, METAL)
		wbox(ctx, "BikeMirror1", 284.0, 284.3, 3.3, 3.5, 183.85, 184.15, DARK, SMOOTH)
		wbox(ctx, "BikeMirror2", 286.2, 286.5, 3.3, 3.5, 183.85, 184.15, DARK, SMOOTH)
		wbox(ctx, "BikeTail", 285.1, 285.4, 2.35, 2.7, 188.3, 188.45, C3(190, 30, 36), SMOOTH)
		ctx:cyl("BikeExhaust", V(2.1, 0.4, 0.4), CF(W(285.95, 1.5, 187.3)) * CFrame.Angles(0, PI / 2, 0), TFD, METAL)
		seg(ctx, "BikeStand", 284.7, 0.2, 185.6, 285.1, 1.6, 185.6, 0.2, STEEL, METAL)
	end, bike)
end
