-- site05_monastery: the MONASTERY of Site 05 (Monastery of Our Lady of Mount Carmel), board rebuild 2026-10-31.
-- Studio copy: ServerStorage.Builders.site05_monastery. Assembler: builders/site05.luau. Check: tests/site05_check.luau, group monastery.
-- Owns Structure/Monastery and Garden. Budget 600.
-- Source: the board's site-plan inset (the 2-storey wing is an L on the north and west of the courtyard; a covered veranda runs down the
--   west edge) and the 3-D view (cream walls, green roofs, paired windows in two rows, a covered walkway along the courtyard face, a
--   landscaped courtyard with a white Marian statue on a pedestal, teal umbrellas, a green gazebo, palms and round trees, a cream wall with
--   cone shrubs closing it on the south).
-- Frame: local +X east, +Z south, y above ground. Layout: north leg x -106..-28, z -86..-64; west leg (MonasteryReturn) x -106..-92,
--   z -86..-30; veranda x -108..-94, z -30..40; courtyard x -92..-52, z -57..33; the chapel's west side block starts at x -48.
-- Pure function of env: every run builds the same parts.
return function(env)
	local V, CF, PI = env.V, env.CF, env.PI
	local box, vcyl = env.box, env.vcyl
	local C3 = Color3.fromRGB
	local WALL, TRIM, MAROON = C3(248, 226, 170), C3(242, 238, 224), C3(110, 40, 36)
	local ROOF, ROOF_RIB = C3(70, 116, 106), C3(86, 132, 120)
	local GLASS, STONE, STONE_LIGHT = C3(40, 48, 58), C3(196, 188, 176), C3(214, 206, 194)
	local LAWN, HEDGE, TERRACOTTA, TEAL = C3(86, 140, 60), C3(52, 110, 56), C3(186, 120, 90), C3(40, 118, 112)
	local CONC, PLAS, METAL, WOOD, LEAF, GL = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Wood, Enum.Material.Grass, Enum.Material.Glass

	local function topiary(ctx, lowName, x, y0, z)
		ctx:ball(lowName, 3.4, CF(x, y0 + 1.7, z), HEDGE, LEAF)
		ctx:ball(lowName .. "Top", 2.2, CF(x, y0 + 3.6, z), HEDGE, LEAF)
	end

	------------------------------------------------------------------ the 2-storey L, the walkway, the veranda
	env.section("Structure/Monastery", function(ctx)
		-- North leg.
		box(ctx, "MonasteryBlock", -106, -28, 0, 24, -86, -64, WALL, CONC)
		ctx:gable("MonasteryRoof", 25, 7, 80, CF(-67, 24, -75) * CFrame.Angles(0, PI / 2, 0), ROOF, PLAS)
		box(ctx, "MonasteryCornice", -106.4, -27.6, 23.2, 24.2, -64.4, -63.6, TRIM, CONC)
		box(ctx, "MonasteryPlinth", -92, -28, 0, 1.2, -64.3, -63.9, MAROON, CONC)
		box(ctx, "FloorBand", -92, -28, 12, 12.6, -64.3, -63.8, TRIM, CONC)
		for k = 0, 11 do
			for _, y in ipairs({ 3.5, 15.5 }) do
				for _, dx in ipairs({ -1.2, 1.2 }) do
					box(ctx, "MonasteryWin", -88 + 5.2 * k + dx - 1, -88 + 5.2 * k + dx + 1, y, y + 4.6, -64.15, -63.85, GLASS, GL)
				end
			end
		end
		-- Covered walkway along the courtyard face (roof 12.4, posts every 8).
		box(ctx, "WalkwayFloor", -92, -28, 0, 0.4, -64, -57, STONE, CONC)
		ctx:part("WalkwayRoof", V(66, 0.5, 8), CF(-60, 12.4, -60.5), ROOF, PLAS)
		box(ctx, "WalkwayFascia", -93, -27, 11.6, 12.2, -56.8, -56.4, TRIM, CONC)
		for k = 0, 8 do
			box(ctx, "WalkwayPost", -90.25 + 7.9 * k, -89.75 + 7.9 * k, 0.4, 12.15, -57.6, -57.1, TRIM, CONC)
		end
		-- West leg (the L's return), running south to z -30.
		box(ctx, "MonasteryReturn", -106, -92, 0, 24, -86, -30, WALL, CONC)
		ctx:gable("MonasteryReturnRoof", 17, 6, 58, CF(-99, 24, -58), ROOF, PLAS)
		box(ctx, "ReturnCornice", -92.4, -91.6, 23.2, 24.2, -64, -30, TRIM, CONC)
		for k = 0, 3 do
			for _, y in ipairs({ 3.5, 15.5 }) do
				box(ctx, "ReturnWin", -91.85, -91.55, y, y + 4.6, -60 + 7.5 * k, -57 + 7.5 * k, GLASS, GL)
			end
		end
		box(ctx, "ReturnSouthWin", -101, -97, 15.5, 20.1, -29.85, -29.55, GLASS, GL)
		-- Covered veranda down the west edge: deck, two rows of columns, beams, a green gable roof.
		box(ctx, "VerandaDeck", -108, -94, 0, 0.4, -30, 40, STONE_LIGHT, CONC)
		for k = 0, 8 do
			local z = -27 + 8.4 * k
			for _, x in ipairs({ -94.6, -107.4 }) do
				box(ctx, "VerandaColumn", x - 0.35, x + 0.35, 0.4, 10, z - 0.35, z + 0.35, TRIM, CONC)
			end
		end
		for _, x in ipairs({ -94.6, -107.4 }) do
			box(ctx, "VerandaBeam", x - 0.4, x + 0.4, 9.4, 10.2, -30, 40, TRIM, CONC)
		end
		ctx:gable("VerandaRoof", 17, 5, 72, CF(-101, 10.2, 5), ROOF, PLAS)
		box(ctx, "VerandaRidgeRib", -101.4, -100.6, 15.1, 15.4, -31, 41, ROOF_RIB, PLAS)
		-- Standing-seam ribs parallel to the ridges of the three long gable roofs (the board's ribbed green roofs).
		local function ribs(name, cx, cz, eaveY, run, rise, length, alongX, n)
			local ang = math.atan2(rise, run)
			for _, side in ipairs({ -1, 1 }) do
				for i = 1, n do
					local t = (i - 0.5) / n
					local off, y = side * run * (1 - t), eaveY + rise * t + 0.15 / math.cos(ang)
					if alongX then
						ctx:part(name, V(length, 0.25, 1.1), CF(cx, y, cz + off) * CFrame.Angles(side * ang, 0, 0), ROOF_RIB, PLAS)
					else
						ctx:part(name, V(1.1, 0.25, length), CF(cx + off, y, cz) * CFrame.Angles(0, 0, -side * ang), ROOF_RIB, PLAS)
					end
				end
			end
		end
		ribs("MonasteryRib", -67, -75, 24, 12.5, 7, 80.4, true, 5)
		ribs("ReturnRib", -99, -58, 24, 8.5, 6, 58.4, false, 3)
		ribs("VerandaRib", -101, 5, 10.2, 8.5, 5, 72.4, false, 3)
	end)

	------------------------------------------------------------------ the landscaped courtyard
	env.section("Garden", function(ctx)
		box(ctx, "CourtLawn", -92, -52, 0, 0.4, -57, 33, LAWN, LEAF)
		box(ctx, "CourtPath", -92, -52, 0.4, 0.65, -4, -1, TERRACOTTA, CONC)
		box(ctx, "CourtPathN", -74, -71, 0.4, 0.65, -57, 33, TERRACOTTA, CONC)
		box(ctx, "ChapelPath", -52, -48, 0, 0.45, -58, 33, TERRACOTTA, CONC)
		box(ctx, "CourtHedge", -92, -90.6, 0.4, 2.6, -56, 32, HEDGE, LEAF)
		box(ctx, "CourtHedgeE", -53.4, -52, 0.4, 2.6, -56, 32, HEDGE, LEAF)
		-- White Marian statue on a pedestal in the north-west of the court (the 3-D view's statue by the wing).
		local sx, sz = -82, -46
		ctx:part("Pedestal", V(4, 4, 4), CF(sx, 2.4, sz), STONE_LIGHT, CONC)
		ctx:part("PedestalCap", V(4.6, 0.5, 4.6), CF(sx, 4.65, sz), TRIM, CONC)
		ctx:part("CourtStatue", V(1.8, 5, 1.4), CF(sx, 7.4, sz), TRIM, PLAS)
		ctx:part("StatueArms", V(4, 0.5, 0.6), CF(sx, 8.8, sz), TRIM, PLAS)
		ctx:ball("StatueHead", 1.6, CF(sx, 10.6, sz), TRIM, PLAS)
		ctx:part("StatueHalo", V(2.2, 2.2, 0.3), CF(sx, 10.6, sz - 0.6), TRIM, PLAS)
		-- Green gazebo in the south-west of the court.
		local gx, gz = -82, 22
		box(ctx, "GazeboFloor", gx - 5, gx + 5, 0.4, 0.8, gz - 5, gz + 5, STONE_LIGHT, CONC)
		for _, dx in ipairs({ -4, 4 }) do
			for _, dz in ipairs({ -4, 4 }) do
				box(ctx, "GazeboPost", gx + dx - 0.3, gx + dx + 0.3, 0.8, 9.2, gz + dz - 0.3, gz + dz + 0.3, TRIM, CONC)
			end
		end
		box(ctx, "GazeboRoof", gx - 6, gx + 6, 9.2, 9.6, gz - 6, gz + 6, ROOF, PLAS)
		env.hipRoof(ctx, "GazeboCap", gx - 6, gx + 6, gz - 6, gz + 6, 9.6, 4, ROOF, PLAS)
		-- Five teal umbrellas with small tables.
		for _, p in ipairs({ { -62, -48 }, { -62, -22 }, { -86, -10 }, { -64, 8 }, { -78, 10 } }) do
			vcyl(ctx, "UmbrellaPole", p[1], p[2], 0.4, 7.6, 0.3, STONE, METAL)
			vcyl(ctx, "Umbrella", p[1], p[2], 7.6, 8.1, 7, TEAL, PLAS)
			vcyl(ctx, "UmbrellaTable", p[1], p[2], 2.4, 2.8, 3, C3(236, 232, 222), PLAS)
		end
		-- Cone topiaries along the paths.
		for _, p in ipairs({ { -76, -50 }, { -69, -50 }, { -76, -36 }, { -69, -36 }, { -76, -22 }, { -69, -22 }, { -88, 2 }, { -58, 2 }, { -76, 26 }, { -69, 26 } }) do
			topiary(ctx, "Topiary", p[1], 0.4, p[2])
		end
		-- Round trees, shrubs and palms (the court's dense planting).
		for _, p in ipairs({ { -86, -28, 11, 6 }, { -58, -36, 12, 6.5 }, { -86, 8, 10, 5.5 }, { -58, -6, 11, 6 }, { -66, 20, 10, 5.5 }, { -84, -54, 9, 5 } }) do
			env.tree(ctx, p[1], p[2], p[3], p[4])
		end
		for _, p in ipairs({ { -88, -40 }, { -56, -52 }, { -64, -30 }, { -80, -18 }, { -56, 14 }, { -88, 30 }, { -60, 30 }, { -79, 0 } }) do
			env.shrub(ctx, p[1], p[2], 3)
		end
		for _, p in ipairs({ { -66, -54, 9, 5 }, { -88, -36, 10, 5 }, { -60, -12, 10, 5.5 } }) do
			env.tree(ctx, p[1], p[2], p[3], p[4])
		end
		for _, p in ipairs({ { -80, -30 }, { -66, -40 }, { -86, -2 }, { -56, -26 }, { -66, 16 }, { -76, 30 }, { -90, 14 }, { -58, -44 }, { -82, -56 }, { -64, -2 } }) do
			env.shrub(ctx, p[1], p[2], 2.6)
		end
		env.palm(ctx, -56, 24, 15, 0.8)
		env.palm(ctx, -60, 28, 13, -0.6)
		env.palm(ctx, -90, -20, 14, 0.5)
		-- The cream wall closing the court on the south, with cone shrubs on top (3-D view).
		box(ctx, "CourtWall", -94, -48, 0, 5, 33.4, 34.6, WALL, CONC)
		box(ctx, "CourtWallBase", -94, -48, 0, 1, 33.3, 34.7, MAROON, CONC)
		box(ctx, "CourtWallCap", -94.2, -47.8, 5, 5.4, 33.2, 34.8, TRIM, CONC)
		for k = 0, 4 do
			topiary(ctx, "WallTopiary", -90 + 9 * k, 5.4, 34)
		end
	end)
end
