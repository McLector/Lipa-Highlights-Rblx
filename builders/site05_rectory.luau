-- site05_rectory: the AUXILIARY BUILDING (rectory / support facilities) of Site 05, board rebuild 2026-10-31.
-- Studio copy: ServerStorage.Builders.site05_rectory. Assembler: builders/site05.luau. Check: tests/site05_check.luau, group rectory.
-- Owns Rectory. Budget 300.
-- Source: the board's 3-D view (a long cream 2-storey block with a green hip roof down the east edge, a green awning on posts along its
--   west face, doors and rows of windows) and the site-plan inset (a long block on the east edge and a second block on the north edge,
--   east of the chapel). Both are built as one L: east leg x 84..106, z -88..14; north leg x 30..84, z -88..-72.
-- The awning stops short of the kneeling pilgrim's spot (80, -43.5): she keeps open sky (site05_check "nothing stands over...").
-- Frame: local +X east, +Z south, y above ground. Pure function of env.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local box = env.box
	local C3 = Color3.fromRGB
	local WALL, TRIM, MAROON = C3(248, 226, 170), C3(242, 238, 224), C3(110, 40, 36)
	local ROOF, GLASS, STONE, TIMBER = C3(70, 116, 106), C3(40, 48, 58), C3(196, 188, 176), C3(80, 50, 40)
	local CONC, PLAS, METAL, WOOD, GL = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Wood, Enum.Material.Glass

	env.section("Rectory", function(ctx)
		-- East leg, two storeys (top 22).
		box(ctx, "RectoryBlock", 84, 106, 0, 22, -88, 14, WALL, CONC)
		env.hipRoof(ctx, "RectoryRoof", 83, 107, -89, 15, 22, 7, ROOF, PLAS)
		box(ctx, "RectoryCornice", 83.6, 84, 21.2, 22.2, -72, 14, TRIM, CONC)
		box(ctx, "RectoryBand", 83.7, 84, 10.8, 11.4, -72, 14, TRIM, CONC)
		box(ctx, "RectoryPlinth", 83.7, 84, 0, 1.2, -72, 14, MAROON, CONC)
		for k = 0, 8 do
			local z = -66 + 9 * k
			for _, y in ipairs({ 3.5, 14 }) do
				box(ctx, "RectoryWin", 83.7, 84, y, y + 4.4, z - 1.4, z + 1.4, GLASS, GL)
			end
		end
		for k = 0, 2 do
			for _, y in ipairs({ 3.5, 14 }) do
				box(ctx, "RectoryWin", 88 + 7 * k, 90.8 + 7 * k, y, y + 4.4, 14, 14.3, GLASS, GL)
			end
		end
		for _, z in ipairs({ -25.5, 1.5 }) do
			ctx:window("RectoryDoor", 4.5, 8.6, 0.5, CF(83.8, 0, z) * ANG(0, -PI / 2, 0), TIMBER, WOOD)
		end
		-- Green awning on posts along the west face, in two runs (open over the kneeling pilgrim at z -43.5).
		for _, run in ipairs({ { -34, 12 }, { -70, -53 } }) do
			ctx:part("RectoryCanopy", V(4, 0.4, run[2] - run[1]), CF(82, 10.4, (run[1] + run[2]) / 2), ROOF, PLAS)
			local n = math.floor((run[2] - run[1]) / 8)
			for k = 0, n do
				local z = run[1] + 0.5 + k * (run[2] - run[1] - 1) / n
				box(ctx, "CanopyPost", 80.2, 80.6, 0, 10.2, z - 0.2, z + 0.2, STONE, METAL)
			end
		end
		-- North leg (z -88..-72), east of the chapel, one storey taller than the walkway (top 18).
		box(ctx, "RectoryNorth", 30, 84, 0, 18, -88, -72, WALL, CONC)
		env.hipRoof(ctx, "RectoryNorthRoof", 29, 85, -89, -71, 18, 6, ROOF, PLAS)
		box(ctx, "RectoryNorthPlinth", 30, 84, 0, 1.2, -72, -71.7, MAROON, CONC)
		for k = 0, 5 do
			for _, y in ipairs({ 3, 11 }) do
				box(ctx, "RectoryWin", 35 + 8.5 * k, 37.8 + 8.5 * k, y, y + 4, -71.85, -71.55, GLASS, GL)
			end
		end
	end)
end
