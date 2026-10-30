-- site05_grounds: the GROUNDS of Site 05 (Monastery of Our Lady of Mount Carmel), board rebuild 2026-10-31.
-- Studio copy: ServerStorage.Builders.site05_grounds. Assembler: builders/site05.luau. Check: tests/site05_check.luau, groups grounds, clear.
-- Owns Grounds, Landscape, Shrine, Pews, Kneeler, Candles, HistoryPanels. Budget 900.
-- Source: the board's 3-D view and site-plan inset: grey arrival driveway from the south with a palm island, the forecourt below the steps,
--   a cream perimeter wall with a maroon base (a long diagonal run on the south-west), palms and round trees, and the outdoor shrine
--   (Ten Commandments) in the SE corner: brick-red walls, a cream gable under a green roof, an arched timber double door, two white
--   tablets either side, facing south. Kept from Revision 1: the plain Marian billboard (moved off the island), the prayer-garden props.
-- Kept spots: the Guide (0, 30), JeepStop (-20, 30), Jeepney (-34, 30), InfoPanel (12, 24), the lane x +-4, z 34..90 stay clear. The
--   pilgrims of builders/npcs.luau (not rebuilt here) keep a pew seat under (75, 32) and a grotto statue north of (80, -43.5).
-- Thin parts (0.2 or less) stay inside the terrain's Pavement region x +-52, z 0..92; everything outside it is 0.3+ thick.
-- Frame: local +X east, +Z south, y above ground. Pure function of env (no randomness).
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local box, vcyl = env.box, env.vcyl
	local C3 = Color3.fromRGB
	local WALL, TRIM, MAROON = C3(248, 226, 170), C3(242, 238, 224), C3(110, 40, 36)
	local ROOF, ASPHALT, PAVE, KERB = C3(70, 116, 106), C3(112, 114, 120), C3(138, 138, 140), C3(196, 192, 184)
	local STONE, STONE_LIGHT, LAWN, HEDGE = C3(196, 188, 176), C3(214, 206, 194), C3(86, 140, 60), C3(52, 110, 56)
	local BRICK_RED, TIMBER, LAVA, BILLBOARD = C3(138, 62, 50), C3(80, 50, 40), C3(70, 66, 64), C3(170, 215, 225)
	local PEW, KNEEL_PAD, PANEL, FLAME, POT = C3(120, 78, 48), C3(140, 40, 50), C3(30, 36, 48), C3(255, 200, 90), C3(176, 104, 70)
	local CONC, PLAS, METAL, WOOD, LEAF = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Wood, Enum.Material.Grass
	local SLATE, BRICK = Enum.Material.Slate, Enum.Material.Brick

	local function statue(ctx, x, baseY, z, bodyName)
		ctx:part("Pedestal", V(4, 4, 4), CF(x, baseY + 2, z), STONE_LIGHT, CONC)
		ctx:part("PedestalCap", V(4.6, 0.5, 4.6), CF(x, baseY + 4.25, z), TRIM, CONC)
		ctx:part(bodyName, V(1.8, 5, 1.4), CF(x, baseY + 7, z), TRIM, PLAS)
		ctx:part("StatueArms", V(4, 0.5, 0.6), CF(x, baseY + 8.4, z), TRIM, PLAS)
		ctx:ball("StatueHead", 1.6, CF(x, baseY + 10.2, z), TRIM, PLAS)
	end
	-- A wall run between two ground points: cream wall 6 high, maroon base, white cap, piers every ~16 studs.
	local function wallRun(ctx, a, b)
		local mid = (a + b) / 2
		local len = (b - a).Magnitude
		local frame = CFrame.lookAt(mid, mid + (b - a)) * ANG(0, PI / 2, 0) -- local X along the run
		ctx:part("PerimeterWall", V(len, 6, 1.2), frame * CF(0, 3, 0), WALL, CONC)
		ctx:part("WallBase", V(len, 1, 1.4), frame * CF(0, 0.5, 0), MAROON, CONC)
		ctx:part("WallCap", V(len + 0.4, 0.4, 1.6), frame * CF(0, 6.2, 0), TRIM, CONC)
		local n = math.max(1, math.floor(len / 16 + 0.5))
		for k = 0, n do
			ctx:part("WallPier", V(1.8, 6.8, 1.8), frame * CF(-len / 2 + 0.9 + k * (len - 1.8) / n, 3.4, 0), WALL, CONC)
		end
	end

	------------------------------------------------------------------ Grounds: paving, driveway, island, wall, billboard, grotto, prayer slab
	env.section("Grounds", function(ctx)
		-- Forecourt and arrival driveway (thin, inside the Pavement region).
		ctx:part("ForecourtPaving", V(100, 0.1, 86), CF(0, 0.05, 45), PAVE, CONC)
		box(ctx, "DriveMain", -12, 12, 0.1, 0.2, 14, 88, ASPHALT, CONC)
		box(ctx, "DriveWest", -52, -12, 0.1, 0.2, 14, 42, ASPHALT, CONC)
		box(ctx, "DriveSouth", 12, 52, 0.1, 0.2, 81, 88, ASPHALT, CONC)
		box(ctx, "DriveForecourt", -12, 52, 0.1, 0.2, 12, 50, ASPHALT, CONC)
		-- The east loop to the shrine (outside the Pavement region: 0.3 thick).
		box(ctx, "DriveEast", 52, 78, 0, 0.3, 48, 88, ASPHALT, CONC)
		box(ctx, "ShrineYard", 78, 108, 0, 0.3, 52, 87.5, STONE_LIGHT, CONC)
		-- The palm island: a stadium of lawn inside a kerb (x 12..56, z 56..80).
		box(ctx, "IslandKerb", 24, 44, 0, 0.5, 56, 80, KERB, CONC)
		vcyl(ctx, "IslandKerbEnd", 24, 68, 0, 0.5, 24, KERB, CONC)
		vcyl(ctx, "IslandKerbEnd", 44, 68, 0, 0.5, 24, KERB, CONC)
		box(ctx, "IslandLawn", 24, 44, 0, 0.7, 56.6, 79.4, LAWN, LEAF)
		vcyl(ctx, "IslandLawnEnd", 24, 68, 0, 0.7, 22.8, LAWN, LEAF)
		vcyl(ctx, "IslandLawnEnd", 44, 68, 0, 0.7, 22.8, LAWN, LEAF)
		-- Perimeter wall: north, east, west, the long south-west diagonal, the south-east run; gate piers at the road mouth.
		wallRun(ctx, V(-109.4, 0, -89.4), V(109.4, 0, -89.4))
		wallRun(ctx, V(109.4, 0, -89.4), V(109.4, 0, 88.4))
		wallRun(ctx, V(-109.4, 0, -89.4), V(-109.4, 0, 44))
		wallRun(ctx, V(-109.4, 0, 44), V(-15, 0, 88.4))
		wallRun(ctx, V(15, 0, 88.4), V(109.4, 0, 88.4))
		for _, x in ipairs({ -14, 14 }) do
			box(ctx, "GatePier", x - 1.4, x + 1.4, 0, 8, 87, 89.8, WALL, CONC)
			box(ctx, "GatePierCap", x - 1.7, x + 1.7, 8, 8.6, 86.7, 90.1, TRIM, CONC)
		end
		-- Planting bed along the inside of the diagonal wall.
		do
			local a, b = V(-106, 0, 41), V(-18, 0, 82)
			local mid = (a + b) / 2
			ctx:part("PlantingBed", V((b - a).Magnitude, 0.4, 7), CFrame.lookAt(mid, mid + (b - a)) * ANG(0, PI / 2, 0) * CF(0, 0.2, 0), LAWN, LEAF)
		end
		-- The plain Marian billboard of Revision 1, on a lava-stone base, facing the road (+Z); no text, no picture.
		local bx, bz = -40, 56
		ctx:part("BillboardBase", V(8, 4.5, 5), CF(bx, 2.25, bz), LAVA, SLATE)
		for _, r in ipairs({ { -3.4, 1.7, 1.6 }, { 3.4, 1.5, 1.9 }, { 0.4, 1.1, 3.3 } }) do
			ctx:ball("BillboardRock", 3.4, CF(bx + r[1], r[2], bz + r[3]), LAVA, SLATE)
		end
		ctx:window("BillboardFrame", 9.6, 14, 0.4, CF(bx, 4.4, bz - 0.3), TRIM, CONC)
		ctx:window("BillboardPanel", 8.4, 13, 0.6, CF(bx, 4.5, bz), BILLBOARD, PLAS)
		ctx:part("BillboardFigure", V(2.6, 6, 0.3), CF(bx, 8.6, bz + 0.45), TRIM, PLAS)
		ctx:ball("BillboardHead", 1.6, CF(bx, 12.3, bz + 0.45), TRIM, PLAS)
		-- A small Marian grotto between the side wing and the rectory, before the kneeling pilgrim (80, -43.5).
		box(ctx, "GrottoPad", 75, 85, 0, 0.4, -56, -46.5, STONE_LIGHT, CONC)
		statue(ctx, 80, 0.4, -50, "GrottoStatue")
		-- East prayer garden slab under the pews, the statue the pews face, and the history panels.
		box(ctx, "PrayerSlab", 54, 98, 0, 0.4, 14, 47, STONE_LIGHT, CONC)
		statue(ctx, 78, 0.4, 17, "PrayerStatue")
	end)

	------------------------------------------------------------------ Landscape: palms, trees, shrubs (fixed spots, no randomness)
	env.section("Landscape", function(ctx)
		for _, p in ipairs({ { 20, 64, 14, 0.6 }, { 30, 60, 16, -0.5 }, { 40, 62, 13, 0.4 }, { 49, 70, 15, -0.7 }, { 34, 73, 14, 0.5 }, { 24, 75, 12, -0.4 } }) do
			env.palm(ctx, p[1], p[2], p[3], p[4])
		end
		for _, p in ipairs({ { 28, 66 }, { 38, 69 }, { 44, 76 }, { 18, 70 }, { 44, 60 }, { 33, 78 } }) do
			env.shrub(ctx, p[1], p[2], 2.6)
		end
		for _, p in ipairs({ { -46, 22, 15, 0.6 }, { 56, 16, 16, -0.6 }, { -92, 44, 14, 0.5 }, { -60, 60, 15, -0.5 }, { -28, 76, 13, 0.6 }, { 100, 50, 15, -0.6 }, { 62, 30, 14, 0.4 } }) do
			env.palm(ctx, p[1], p[2], p[3], p[4])
		end
		for _, p in ipairs({ { -76, 52, 11, 6 }, { -46, 68, 10, 5.5 }, { -18, 80, 9, 5 }, { 104, 80, 11, 6 }, { 82, 84, 10, 5.5 }, { 104, 60, 10, 5 } }) do
			env.tree(ctx, p[1], p[2], p[3], p[4])
		end
		for _, p in ipairs({ { -100, 46 }, { -84, 52 }, { -68, 60 }, { -52, 66 }, { -36, 74 }, { -22, 80 }, { 56, 4 }, { -56, 4 }, { 86, 76 }, { 98, 76 }, { 106, 70 }, { 74, -52 }, { 86, -54 } }) do
			env.shrub(ctx, p[1], p[2], 3)
		end
		-- Denser planting where the board draws it: the north yards beside the sacristy, the yard between the side wing and the rectory
		-- (clear of the kneeling pilgrim's column x 78.5..81.5, z -45..-42), the rectory front, the shrine garden, the facade beds, the
		-- south-west bed.
		for _, p in ipairs({ { -21, -80, 10, 5.5 }, { -21, -71, 9, 5 }, { 22, -80, 10, 5.5 }, { 22, -71, 9, 5 }, { 76.5, -24, 10, 5 }, { 76.5, -33, 9, 4.5 },
			{ 76, 2, 10, 5 }, { 76, 10, 9, 4.5 }, { 92, 82, 9, 5 }, { -86, 48, 10, 5 }, { -62, 58, 9, 5 }, { -38, 68, 9, 4.5 } }) do
			env.tree(ctx, p[1], p[2], p[3], p[4])
		end
		for _, p in ipairs({ { -40, 3 }, { -44, 3 }, { -47, 4 }, { 54, -10 }, { 60, -10 }, { 66, -10 }, { 76, -12 },
			{ 76, -56 }, { 82, 54 }, { 80, 62 }, { 80, 70 }, { 104, 54 }, { 102, 86 }, { 86, 86 }, { -96, 46 }, { -76, 55 }, { -44, 70 }, { -24, 79 } }) do
			env.shrub(ctx, p[1], p[2], 2.6)
		end
		-- Lamp posts along the main drive and by the stair (the board's black lamps at the entrance).
		for _, p in ipairs({ { -14, 50 }, { -14, 70 }, { 14, 46 }, { -26, 12 }, { 26, 12 }, { 50, 46 } }) do
			vcyl(ctx, "LampPost", p[1], p[2], 0, 9, 0.4, C3(36, 36, 40), METAL)
			box(ctx, "LampHead", p[1] - 0.5, p[1] + 0.5, 9, 10.4, p[2] - 0.5, p[2] + 0.5, C3(250, 240, 200), Enum.Material.Neon)
			box(ctx, "LampCap", p[1] - 0.7, p[1] + 0.7, 10.4, 10.7, p[2] - 0.7, p[2] + 0.7, C3(36, 36, 40), METAL)
		end
	end)

	------------------------------------------------------------------ Shrine: brick-red chapel, cream gable, green roof, arched door, tablets
	env.section("Shrine", function(ctx)
		local cx, fz = 92, 70 -- centre x, front face z
		box(ctx, "ShrineBody", cx - 9, cx + 9, 0, 10, fz - 12, fz, BRICK_RED, BRICK)
		box(ctx, "ShrinePlinth", cx - 9.2, cx + 9.2, 0, 0.8, fz - 12.2, fz + 0.2, STONE, CONC)
		ctx:window("ShrineArch", 7, 9.8, 0.3, CF(cx, 0.4, fz + 0.05), TRIM, CONC)
		ctx:window("ShrineGate", 5.4, 8.6, 0.5, CF(cx, 0.4, fz + 0.15), TIMBER, WOOD)
		ctx:part("ShrineGateSplit", V(0.2, 8, 0.2), CF(cx, 4.4, fz + 0.45), C3(50, 32, 26), WOOD)
		ctx:gable("ShrineRoof", 21, 6.6, 15, CF(cx, 10, fz - 6), ROOF, PLAS)
		box(ctx, "ShrineBand", cx - 9.4, cx + 9.4, 9.6, 10.6, fz - 0.2, fz + 1.4, WALL, CONC)
		ctx:gable("ShrineGable", 18, 5.4, 0.4, CF(cx, 10.4, fz + 1.55), WALL, CONC)
		box(ctx, "ShrineStep", cx - 5, cx + 5, 0.3, 0.7, fz, fz + 2.4, STONE, CONC)
		for i, sx in ipairs({ -6.3, 6.3 }) do
			local tablet = ctx:part("Tablet" .. i, V(4.4, 6, 0.3), CF(cx + sx, 5.5, fz + 0.15), TRIM, CONC)
			env.gui(tablet, Enum.NormalId.Back, "THE TEN COMMANDMENTS", i == 2 and "(continued)" or nil, Color3.fromRGB(30, 30, 30), 40, 18, 16)
		end
		for _, sx in ipairs({ -7.5, 7.5 }) do
			vcyl(ctx, "ShrinePot", cx + sx, fz + 2, 0.3, 1.9, 1.6, POT, CONC)
			ctx:ball("ShrinePlant", 2, CF(cx + sx, 2.6, fz + 2), HEDGE, LEAF)
		end
	end)

	------------------------------------------------------------------ Required props (the prayer garden, as in Slice 04; the pew rows stay put)
	env.section("Pews", function(ctx)
		for i = 0, 3 do
			local z = 26 + 6 * i
			ctx:part("PewSeat", V(12, 0.6, 2.2), CF(78, 1.9, z), PEW, WOOD)
			ctx:part("PewBack", V(12, 3, 0.4), CF(78, 3.4, z + 1), PEW, WOOD)
			for _, lx in ipairs({ 72.6, 83.4 }) do
				ctx:part("PewLeg", V(0.6, 1.5, 2), CF(lx, 1.15, z), PEW, WOOD)
			end
		end
	end)
	env.section("Kneeler", function(ctx)
		ctx:part("KneelerBase", V(10, 1.2, 2.4), CF(78, 1, 21.5), PEW, WOOD)
		ctx:part("KneelerPad", V(9.6, 0.4, 1.6), CF(78, 1.8, 21.5), KNEEL_PAD, PLAS)
		ctx:part("KneelerRail", V(10, 1.8, 0.4), CF(78, 2.5, 20.1), PEW, WOOD)
	end)
	env.section("Candles", function(ctx)
		ctx:part("CandleRack", V(6, 2.6, 2.4), CF(66, 1.7, 18), STONE, CONC)
		for r = 0, 1 do
			for c = 0, 4 do
				local x, z = 63.8 + 1.1 * c, 17.5 + 1.1 * r
				vcyl(ctx, "Candle", x, z, 3, 4.1, 0.5, TRIM, PLAS)
				ctx:ball("Flame", 0.45, CF(x, 4.3, z), FLAME, Enum.Material.Neon)
			end
		end
	end)
	env.section("HistoryPanels", function(ctx)
		local titles = {
			"1946 - Founding",
			"1948 - Reported apparitions",
			"1951 and 2015 - Church rulings",
		}
		-- Approved Slice 12 text (content/dialogue_draft.md), unchanged; fixed TextSize (20 title, 16 body) at 30 px per stud.
		local bodies = {
			"Carmelite community founded on May 31, 1946.",
			"Teresita Castillo reported apparitions of Mary. The reports drew pilgrims to Lipa.",
			"1951: bishops found no supernatural basis. 2015: Arguelles' declaration was rejected by the Holy See.",
		}
		for i, z in ipairs({ 22, 34, 46 }) do
			for _, dz in ipairs({ -4, 4 }) do
				ctx:part("PanelPost", V(0.5, 2.6, 0.5), CF(97.5, 1.7, z + dz), STONE, METAL)
			end
			local board = ctx:part("HistoryPanel" .. i, V(0.4, 6, 10), CF(97.5, 6, z), PANEL, PLAS)
			env.gui(board, Enum.NormalId.Left, titles[i], bodies[i], Color3.new(1, 1, 1), 30, 20, 16)
		end
	end)
end
