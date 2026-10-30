-- site03_tower: the TOWER of Site 03 (Lomi King), job L3b. Built from the Lomi King Architectural Blueprint Board (crops board_crown, board_facade) and the Street View photo.
-- Studio copy: ServerStorage.Builders.site03_tower. Assembler: builders/site03.luau. Check: tests/site03_check.luau, group "tower".
-- Owns Podium (ground storey shell + ceiling slab), Tower (floors 2..4, y 16..52) and Crown (grille floor, hip eave, pavilion, roof core). Budget 400, about 300 used.
-- All numbers are WORLD (x east, z south, y up; the site faces WEST, the front of the tower is its x = 284 face). env.wbox / env.W convert to the assembler's local frame.
-- Pure function of env: nothing is read from the DataModel, so every run builds the same parts.
-- Board features built: ground storey open at the front for the dining; four storeys with the curved glass bay (3 floors, 5 facets each, cream spandrel cylinders, mullions),
--   dark-salmon piers either side of the bay, bracket ledges at the floor lines beside the bay, six barred windows with round motifs (GrilleBar1..6 Models), small side-wall windows
--   with grey sun hoods, a recessed fifth floor behind an ornate iron balcony grille (7 ring motifs across the front, rings on both sides), a grey skirt roof (hip eave) on a cream
--   fascia, a pavilion with a front gable (dark boarded gable, cream barge boards) and a hipped back end on a grey-brown corrugated roof, and the stair head (RoofCore) with a skylight.
-- Names: Podium*, LomiBody, BandLedge*, CurvedBay* (glass, spandrels, mullions only), BayPier*, Ledge*, GrilleBar1..6 (Models) holding BarWindow* and GrilleBar* parts,
--   SideWin*, SunHood*, BalconySlab, UpperWall, BalconyGrille*, BalconyRing*, HipEaveSlab, Skirt*, RoofDeck, Pavilion*, RoofSlope*, RoofHip*, RoofCore, Skylight, RoofCap.
-- Deviations from the prompt numbers (conflicts with the finished dining and the SEAMS): the south end of the ground storey is a SHELL (front wall, south wall, rear wall), not a solid
--   block, because the counter (x 315..320) runs on to z 160; the rear wall over the dining starts at y 0.2 (FloorTile fills y 0..0.2 up to x 328); the podium slab and south wall stop at
--   z 165.5 because the front module's south return band stands at z 165.5..166.5.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local B, W = env.wbox, env.W
	local C3 = Color3.fromRGB
	local SMOOTH, CONCRETE, METAL = Enum.Material.SmoothPlastic, Enum.Material.Concrete, Enum.Material.Metal
	local GLASS, CORR = Enum.Material.Glass, Enum.Material.Metal -- CORR: the roof sheets (there is no CorrugatedMetal member)
	local SALMON, PIER, CREAM = C3(238, 150, 125), C3(225, 135, 112), C3(245, 180, 155)
	local CONC, PLINTH = C3(205, 160, 148), C3(150, 122, 114)
	local ROOF, IRON, GLASSC, MULL = C3(110, 95, 85), C3(40, 40, 45), C3(40, 70, 110), C3(70, 75, 90)
	local HOOD, GABLE, SKY, RINGFILL = C3(150, 150, 155), C3(85, 60, 48), C3(190, 220, 240), C3(205, 120, 100)
	local UP = V(0, 1, 0)

	local function glassOf(p, transparency)
		p.Transparency = transparency
		return p
	end
	-- Wedge strip over a world box; the slope rises toward the horizontal unit vector d (the vertical face is on that side).
	local function strip(ctx, name, x0, x1, y0, y1, z0, z1, d, color, material)
		local size = (math.abs(d.X) > 0.5) and V(z1 - z0, y1 - y0, x1 - x0) or V(x1 - x0, y1 - y0, z1 - z0)
		local cf = CFrame.fromMatrix(W((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), UP:Cross(d), UP, d)
		return ctx:wedge(name, size, cf, color, material)
	end
	-- Corner (hip) wedge over a SQUARE world base; the apex stands over the base corner at (sx, sz) = signs of the world x and z direction of the apex.
	local EX = { ["1,-1"] = V(1, 0, 0), ["1,1"] = V(0, 0, 1), ["-1,1"] = V(-1, 0, 0), ["-1,-1"] = V(0, 0, -1) }
	local function corner(ctx, name, x0, x1, y0, y1, z0, z1, sx, sz, color, material)
		local ex = EX[sx .. "," .. sz]
		local cf = CFrame.fromMatrix(W((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), ex, UP, ex:Cross(UP))
		return ctx:_make("CornerWedgePart", name, V(x1 - x0, y1 - y0, z1 - z0), cf, color, material)
	end
	-- A board along the direction vz (unit), width along vx (unit, perpendicular), size = (across vx, across vy, along vz), centred on a world point.
	local function board(ctx, name, cx, cy, cz, vx, vz, size, color, material)
		return ctx:part(name, size, CFrame.fromMatrix(W(cx, cy, cz), vx, vz:Cross(vx), vz), color, material)
	end

	------------------------------------------------------------------ Podium: ground storey shell and ceiling slab
	env.section("Podium", function(ctx)
		B(ctx, "PodiumSlab", 284, 328, 14, 16, 114, 165.5, CONC, CONCRETE) -- top y 16 = the storey slab; pendant cords end at y 14
		B(ctx, "PodiumNorthWall", 284, 328, 0, 14, 114, 116, CONC, CONCRETE)
		B(ctx, "PodiumRearWallN", 326, 328, 0.2, 14, 116, 150, CONC, CONCRETE) -- behind the MenuBoard (back face x 326.0); FloorTile fills y 0..0.2
		B(ctx, "PodiumRearWallS", 326, 328, 0, 14, 150, 165.5, CONC, CONCRETE)
		B(ctx, "PodiumSouthWall", 284, 326, 0, 14, 163.5, 165.5, CONC, CONCRETE)
		B(ctx, "PodiumSouthBayFront", 284, 285.2, 0, 14, 150, 163.5, CONC, CONCRETE) -- closes the south bay; the counter stays inside
		B(ctx, "PodiumPlinth", 284, 328, 0, 1.2, 113.6, 114, PLINTH, CONCRETE)
		B(ctx, "PodiumParapetN", 284, 328, 16, 17.2, 114, 114.6, CONC, CONCRETE)
		B(ctx, "PodiumParapetS", 284, 328, 16, 17.2, 164.9, 165.5, CONC, CONCRETE)
		B(ctx, "PodiumParapetE", 327.4, 328.05, 16, 17.2, 114.6, 164.9, CONC, CONCRETE) -- 0.05 proud of LomiBody's east face (no flicker, session 061)
	end)

	------------------------------------------------------------------ Tower: floors 2..4
	local FLOORS = { 16, 28, 40 } -- floor lines; each storey is 12 tall
	env.section("Tower", function(ctx)
		B(ctx, "LomiBody", 284, 328, 16, 52, 124, 158, SALMON, SMOOTH)
		-- thin bands along the whole facade at the floor lines (y 16 is the podium slab, y 52 the balcony slab)
		B(ctx, "BandLedge28", 283.2, 285, 27.7, 28.7, 124, 158, CREAM, SMOOTH)
		B(ctx, "BandLedge40", 283.2, 285, 39.7, 40.7, 124, 158, CREAM, SMOOTH)

		-- curved glass bay: cream spandrel cylinders (dia 12, centre x 286, z 141: front x 280, z 135..147), five glass facets on the same circle, six mullions
		local BCX, BCZ, BR = 286, 141, 6
		for i, r in ipairs({ { 16, 17.5 }, { 26.4, 29.6 }, { 38.4, 41.6 } }) do
			env.wvcyl(ctx, "CurvedBaySpandrel" .. i, BCX, BCZ, r[1], r[2], 12, CREAM, SMOOTH)
		end
		local endAng = math.acos((BCX - 284) / BR) -- where the circle meets the facade plane x = 284
		local NF = 5
		local stepA = 2 * endAng / NF
		local chordLen = 2 * BR * math.sin(stepA / 2)
		local chordDist = BR * math.cos(stepA / 2)
		local glassRows = { { 17.5, 26.4 }, { 29.6, 38.4 }, { 41.6, 50.4 } }
		for fl, r in ipairs(glassRows) do
			env.wvcyl(ctx, "CurvedBayCore" .. fl, BCX, BCZ, r[1], r[2], 11, C3(30, 48, 80), SMOOTH) -- dark interior seen through the glass
			for k = 1, NF do
				local phi = -endAng + (k - 0.5) * stepA
				local nx, nz = -math.cos(phi), math.sin(phi)
				local n = V(nx, 0, nz)
				local dist = chordDist - 0.25
				local cf = CFrame.fromMatrix(W(BCX + nx * dist, (r[1] + r[2]) / 2, BCZ + nz * dist), n, UP, n:Cross(UP))
				glassOf(ctx:part("CurvedBayGlass" .. fl .. "_" .. k, V(0.5, r[2] - r[1], chordLen), cf, GLASSC, GLASS), 0.2)
			end
			for j = 1, NF - 1 do
				local psi = -endAng + j * stepA
				local mx, mz = BCX - (BR - 0.25) * math.cos(psi), BCZ + (BR - 0.25) * math.sin(psi)
				B(ctx, "CurvedBayMullion" .. fl .. "_" .. j, mx - 0.25, mx + 0.25, r[1], r[2], mz - 0.25, mz + 0.25, MULL, METAL)
			end
		end

		-- the piers either side of the bay, full height up to the balcony slab
		B(ctx, "BayPierN", 282.6, 284, 16, 50.4, 132, 135.4, PIER, SMOOTH)
		B(ctx, "BayPierS", 282.6, 284, 16, 50.4, 146.6, 150, PIER, SMOOTH)

		-- stepped bracket ledges beside the bay at the floor lines 28 and 40 (north section z 124..132, south z 150..158)
		for _, L in ipairs({ 28, 40 }) do
			for s, z in ipairs({ { 124, 132 }, { 150, 158 } }) do
				B(ctx, "LedgeTop" .. L .. "_" .. s, 281.4, 284, L - 0.4, L + 1.6, z[1], z[2], CREAM, SMOOTH)
				B(ctx, "LedgeBracket" .. L .. "_" .. s, 282.4, 284, L - 1.6, L - 0.4, z[1], z[2], PIER, SMOOTH)
			end
		end

		-- plain small windows with grey sun hoods on the side faces (board: the south wall shows three, one per floor); two positions per face and floor
		for _, L in ipairs(FLOORS) do
			local yc = L + 7
			for _, x in ipairs({ 292, 312 }) do
				for _, side in ipairs({ "S", "N" }) do
					local tag = side .. L .. "_" .. x
					local z0 = (side == "S") and 158 or 124
					local o = (side == "S") and 1 or -1 -- outward
					local function zr(a, b) -- z range from offsets a..b measured outward from the wall face
						local p, q = z0 + o * a, z0 + o * b
						return math.min(p, q), math.max(p, q)
					end
					local fa, fb = zr(0, 0.3)
					B(ctx, "SideWinFrame" .. tag, x - 1.5, x + 1.5, yc - 2, yc + 2, fa, fb, PIER, SMOOTH)
					local ga, gb = zr(0.3, 0.55)
					glassOf(B(ctx, "SideWinGlass" .. tag, x - 1, x + 1, yc - 1.7, yc + 1.7, ga, gb, GLASSC, GLASS), 0)
					local ha, hb = zr(0, 1.6)
					B(ctx, "SunHood" .. tag, x - 1.9, x + 1.9, yc + 2.3, yc + 2.9, ha, hb, HOOD, CONCRETE)
				end
			end
		end
	end)

	-- six barred windows, one Model each (GrilleBar1..6): floors 2, 3, 4, north (z 128.5) then south (z 153.5) of the bay
	local n = 0
	for _, L in ipairs(FLOORS) do
		for _, zc in ipairs({ 128.5, 153.5 }) do
			n += 1
			local yc = L + 6.6
			local model = env.newChild(env.container("Tower"), "GrilleBar" .. n, "Model")
			env.section("Tower", function(ctx)
				B(ctx, "BarWindowFrame", 283.5, 284, yc - 3.2, yc + 3.2, zc - 3.1, zc + 3.1, PIER, SMOOTH)
				glassOf(B(ctx, "BarWindowGlass", 283.2, 283.5, yc - 2.9, yc + 2.9, zc - 2.8, zc + 2.8, GLASSC, GLASS), 0)
				for i, dz in ipairs({ -2.1, -0.7, 0.7, 2.1 }) do
					B(ctx, "GrilleBarV" .. i, 282.9, 283.2, yc - 2.9, yc + 2.9, zc + dz - 0.12, zc + dz + 0.12, IRON, METAL)
				end
				for i, dy in ipairs({ 2.7, 0.3, -2.7 }) do
					B(ctx, "GrilleBarRail" .. i, 282.9, 283.2, yc + dy - 0.15, yc + dy + 0.15, zc - 2.8, zc + 2.8, IRON, METAL)
				end
				for i, dz in ipairs({ -0.9, 0.9 }) do -- the round motif of the bars, two touching discs in the lower half
					ctx:cyl("GrilleBarRing" .. i, V(0.3, 1.7, 1.7), CF(W(283.0, yc - 1.4, zc + dz)), IRON, METAL)
				end
			end, model)
		end
	end

	------------------------------------------------------------------ Crown: grille floor, hip eave, pavilion, roof core
	env.section("Crown", function(ctx)
		-- balcony deck at y 52 (3.6 deep in front, 3 on both sides, ends at x 316 where the stair head rises) and the recessed fifth floor
		B(ctx, "BalconySlab", 280.4, 316, 50.4, 52, 121, 161, CREAM, SMOOTH)
		B(ctx, "UpperWall", 284, 328, 52, 62, 124, 158, SALMON, SMOOTH)

		-- iron grille: rails, bars every 2 studs, corner posts; ring motifs are three layers (dark ring, wall-coloured disc, dark eye), all cylinders
		local RAILS = { { 52, 52.9 }, { 54.6, 55.2 }, { 59.4, 60 }, { 60.9, 61.7 } }
		local function ring(tag, axis, base, outward, along, cy)
			-- axis "x": faces west/east at z = along; axis "z": faces north/south at x = along. base = the bars' front face, outward = -1 or +1
			local layers = { { 0.15, 0.3, 3.6, IRON }, { 0.35, 0.1, 2.8, RINGFILL }, { 0.45, 0.1, 1.2, IRON } }
			local names = { "BalconyRing", "BalconyRingFill", "BalconyRingEye" }
			for i, l in ipairs(layers) do
				local c = base + outward * l[1]
				local p = (axis == "x") and (W(c, cy, along)) or (W(along, cy, c))
				local cf = (axis == "x") and CF(p) or (CF(p) * ANG(0, PI / 2, 0))
				ctx:cyl(names[i] .. tag, V(l[2], l[3], l[3]), cf, l[4], METAL)
			end
		end
		-- front run (plane x 280.6..281.2, z 121..161)
		for i, r in ipairs(RAILS) do
			B(ctx, "BalconyGrilleRailF" .. i, 280.7, 281.2, r[1], r[2], 121.2, 160.8, IRON, METAL)
		end
		for i = 0, 18 do
			local z = 122 + 2 * i
			B(ctx, "BalconyGrilleBarF" .. (i + 1), 280.9, 281.2, 52.9, 60.9, z - 0.14, z + 0.14, IRON, METAL)
		end
		B(ctx, "BalconyGrillePostFN", 280.6, 281.5, 52, 61.7, 121.2, 122.1, IRON, METAL)
		B(ctx, "BalconyGrillePostFS", 280.6, 281.5, 52, 61.7, 159.9, 160.8, IRON, METAL)
		for i = 1, 7 do -- seven rings in a row across the front, as on the board
			ring("F" .. i, "x", 280.9, -1, 121 + (i - 0.5) * 40 / 7, 57.2)
		end
		-- side runs: north (front face z 121.2, bars z 121.5..121.8), south (z 160.8, bars z 160.2..160.5), x 281.2..316
		for i, r in ipairs(RAILS) do
			B(ctx, "BalconyGrilleRailN" .. i, 281.2, 316, r[1], r[2], 121.3, 121.8, IRON, METAL)
			B(ctx, "BalconyGrilleRailS" .. i, 281.2, 316, r[1], r[2], 160.2, 160.7, IRON, METAL)
		end
		for i = 0, 16 do
			local x = 283 + 2 * i
			B(ctx, "BalconyGrilleBarN" .. (i + 1), x - 0.14, x + 0.14, 52.9, 60.9, 121.5, 121.8, IRON, METAL)
			B(ctx, "BalconyGrilleBarS" .. (i + 1), x - 0.14, x + 0.14, 52.9, 60.9, 160.2, 160.5, IRON, METAL)
		end
		B(ctx, "BalconyGrilleReturnN", 315.6, 316, 52, 61.7, 121.2, 124, IRON, METAL)
		B(ctx, "BalconyGrilleReturnS", 315.6, 316, 52, 61.7, 158, 160.8, IRON, METAL)
		for i, x in ipairs({ 288, 298.5, 309 }) do
			ring("N" .. i, "z", 121.5, -1, x, 57.2)
			ring("S" .. i, "z", 160.5, 1, x, 57.2)
		end

		-- hip eave: cream fascia slab (overhangs the grille line by 2) under a grey skirt roof that climbs 1.4 over 5 studs on all four sides, hip corners mitred
		B(ctx, "HipEaveSlab", 278.5, 330, 62, 63.6, 119, 163, CREAM, SMOOTH)
		local X0, X1, X2, X3, Z0, Z1, Z2, Z3 = 278.5, 283.5, 325, 330, 119, 124, 158, 163
		local Y0, Y1 = 63.6, 65
		strip(ctx, "SkirtFront", X0, X1, Y0, Y1, Z1, Z2, V(1, 0, 0), ROOF, CORR)
		strip(ctx, "SkirtBack", X2, X3, Y0, Y1, Z1, Z2, V(-1, 0, 0), ROOF, CORR)
		strip(ctx, "SkirtNorth", X1, X2, Y0, Y1, Z0, Z1, V(0, 0, 1), ROOF, CORR)
		strip(ctx, "SkirtSouth", X1, X2, Y0, Y1, Z2, Z3, V(0, 0, -1), ROOF, CORR)
		corner(ctx, "SkirtCornerNW", X0, X1, Y0, Y1, Z0, Z1, 1, 1, ROOF, CORR)
		corner(ctx, "SkirtCornerNE", X2, X3, Y0, Y1, Z0, Z1, -1, 1, ROOF, CORR)
		corner(ctx, "SkirtCornerSW", X0, X1, Y0, Y1, Z2, Z3, 1, -1, ROOF, CORR)
		corner(ctx, "SkirtCornerSE", X2, X3, Y0, Y1, Z2, Z3, -1, -1, ROOF, CORR)
		B(ctx, "RoofDeck", X1, X2, Y0, Y1, Z1, Z2, ROOF, CORR)

		-- pavilion: walls x 295..315, z 129..153, y 64..70 on the deck; roof eave x 293.5..316, z 127.5..154.5, apex y 77. Front gable (street side), hipped back end.
		B(ctx, "PavilionWall", 295, 315, 64, 70, 129, 153, SALMON, SMOOTH)
		local RX0, RX1, RZ0, RZ1, RZM = 293.5, 316, 127.5, 154.5, 141
		local HX = RX1 - 13.5 -- the hip starts here (x 302.5); the ridge runs x 293.5..302.5
		strip(ctx, "RoofSlopeN", RX0, HX, 70, 77, RZ0, RZM, V(0, 0, 1), ROOF, CORR)
		strip(ctx, "RoofSlopeS", RX0, HX, 70, 77, RZM, RZ1, V(0, 0, -1), ROOF, CORR)
		corner(ctx, "RoofHipNE", HX, RX1, 70, 77, RZ0, RZM, -1, 1, ROOF, CORR)
		corner(ctx, "RoofHipSE", HX, RX1, 70, 77, RZM, RZ1, -1, -1, ROOF, CORR)
		-- the gable end: dark boarded triangle in front of the roof's west face, cream barge boards on both rakes, a cream tie board under it
		strip(ctx, "PavilionGableN", RX0 - 0.2, RX0, 70, 77, RZ0, RZM, V(0, 0, 1), GABLE, Enum.Material.Wood)
		strip(ctx, "PavilionGableS", RX0 - 0.2, RX0, 70, 77, RZM, RZ1, V(0, 0, -1), GABLE, Enum.Material.Wood)
		local L = math.sqrt(13.5 * 13.5 + 7 * 7)
		local s, c = 7 / L, 13.5 / L
		board(ctx, "PavilionBargeN", RX0 - 0.1, 73.5 + c * 0.3, (RZ0 + RZM) / 2 - s * 0.3, V(1, 0, 0), V(0, s, c), V(0.8, 0.7, L + 0.8), CREAM, SMOOTH)
		board(ctx, "PavilionBargeS", RX0 - 0.1, 73.5 + c * 0.3, (RZM + RZ1) / 2 + s * 0.3, V(-1, 0, 0), V(0, s, -c), V(0.8, 0.7, L + 0.8), CREAM, SMOOTH)
		B(ctx, "PavilionTieBoard", RX0 - 0.4, RX0 + 0.3, 69.6, 70.3, RZ0 - 0.3, RZ1 + 0.3, CREAM, SMOOTH)
		B(ctx, "PavilionEaveBoardN", RX0, RX1, 69.7, 70.3, RZ0 - 0.3, RZ0 + 0.4, CREAM, SMOOTH)
		B(ctx, "PavilionEaveBoardS", RX0, RX1, 69.7, 70.3, RZ1 - 0.4, RZ1 + 0.3, CREAM, SMOOTH)
		B(ctx, "PavilionEaveBoardE", RX1 - 0.6, RX1, 69.7, 70.3, RZ0, RZ1, CREAM, SMOOTH)
		B(ctx, "PavilionRidge", RX0 - 0.3, HX + 0.5, 76.8, 77.4, RZM - 0.4, RZM + 0.4, ROOF, CORR)

		-- stair head on the back right of the roof (x 316..328, z 150..158) up to y 70, a cream cap, and a skylight beside it
		B(ctx, "RoofCore", 316, 328, 63.6, 70, 150, 158, SALMON, SMOOTH)
		B(ctx, "RoofCap", 316, 328.4, 70, 70.5, 149.6, 158.4, CREAM, SMOOTH)
		glassOf(B(ctx, "Skylight", 318, 325, 65, 66, 146.2, 149.4, SKY, GLASS), 0.3)
	end)
end
