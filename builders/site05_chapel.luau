-- site05_chapel: the CHAPEL of Site 05 (Monastery of Our Lady of Mount Carmel), board rebuild 2026-10-31.
-- Studio copy: ServerStorage.Builders.site05_chapel. Assembler: builders/site05.luau. Check: tests/site05_check.luau, groups facade, chapel.
-- Owns Structure/Facade, Structure/Nave, Structure/Dome, Structure/Annex. Budget 800.
-- Source: the board's front-elevation inset (12.3 px per stud: portico 47 wide, centre block 26, shoulders 42, wings to +-37, low outer
--   wings to +-48, cross top 58) and the 3-D view (triple-arched portico with a flat terrace, wide terracotta stair between cream flank
--   walls with topiary, transept roofs and a big ribbed dome on a windowed drum behind the facade, side wing east, side block west).
--   The facade itself is the Slice 15 photo model (briefs/site05.md Revision 1); the board agrees with it except where Revision 2 says.
-- Frame: local +X east, +Z south (facade side), y above ground; the facade's front plane is z 0, the portico floor B = 6.
-- Pure function of env: nothing is read from the DataModel, so every run builds the same parts.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local box, vcyl = env.box, env.vcyl
	local C3 = Color3.fromRGB
	local WALL, WALL_SHADE, TRIM = C3(248, 226, 170), C3(222, 200, 146), C3(242, 238, 224)
	local ROOF, ROOF_RIB = C3(70, 116, 106), C3(86, 132, 120) -- the board's teal-green
	local DOME, RIB = C3(246, 234, 192), C3(232, 218, 172)
	local TIMBER, MAROON, GLASS = C3(80, 50, 40), C3(110, 40, 36), C3(40, 48, 58)
	local STONE, TERRACOTTA, HEDGE = C3(196, 188, 176), C3(196, 128, 94), C3(52, 110, 56)
	local CONC, PLAS, METAL, WOOD, LEAF = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.Metal, Enum.Material.Wood, Enum.Material.Grass
	local B = 6

	-- An arched window (glass) with a trim surround on a wall face. pos = bottom centre on the wall surface; yaw turns the +Z normal. 4 parts.
	local function arched(ctx, name, pos, yaw, w, h)
		local rot = ANG(0, yaw, 0)
		local normal = rot:VectorToWorldSpace(V(0, 0, 1))
		ctx:window(name .. "_Trim", w + 1.4, h + 0.7, 0.4, CF(pos) * rot, TRIM, CONC)
		ctx:window(name, w, h, 0.4, CF(pos + normal * 0.15) * rot, GLASS)
	end
	local function topiary(ctx, lowName, x, y0, z)
		ctx:ball(lowName, 3.4, CF(x, y0 + 1.7, z), HEDGE, LEAF)
		ctx:ball(lowName .. "Top", 2.2, CF(x, y0 + 3.6, z), HEDGE, LEAF)
	end
	local function roofRibs(ctx, name, cx, cz, eaveY, run, rise, length, n)
		local ang = math.atan2(rise, run)
		for _, side in ipairs({ -1, 1 }) do
			local nx, ny = side * math.sin(ang), math.cos(ang)
			for i = 1, n do
				local t = (i - 0.5) / n
				local x = side * run * (1 - t)
				local y = eaveY + rise * t
				ctx:part(name, V(1.2, 0.25, length), CF(cx + x + nx * 0.15, y + ny * 0.15, cz) * ANG(0, 0, -side * ang), ROOF_RIB, PLAS)
			end
		end
	end

	------------------------------------------------------------------ Facade (front plane z 0)
	env.section("Structure/Facade", function(ctx)
		ctx:part("Podium", V(72, B, 10), CF(0, B / 2, -5), STONE, CONC)
		for i = 1, 6 do
			ctx:part("StairRiser", V(56, 1, 1.7), CF(0, i - 0.5, 0.85 + (6 - i) * 1.7), TERRACOTTA, CONC)
		end
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("FlankWall", V(24, 4, 1.4), CF(s * 40, 2, 8), WALL, CONC)
			ctx:part("FlankWallBase", V(24, 1, 1.6), CF(s * 40, 0.5, 8), MAROON, CONC)
			ctx:part("FlankWallCap", V(24.4, 0.4, 1.8), CF(s * 40, 4.2, 8), TRIM, CONC)
			for k = 0, 3 do
				topiary(ctx, "StairTopiary", s * (31 + 6 * k), 4.4, 8)
			end
		end
		for _, x in ipairs({ -12, 12 }) do
			ctx:part("RailPost", V(0.3, 3, 0.3), CF(x, 1.5, 9.4), STONE, METAL)
			ctx:part("RailPost", V(0.3, 3, 0.3), CF(x, B + 1.5, 0.6), STONE, METAL)
			ctx:part("StairRail", V(0.3, 0.3, 10.4), CF(x, 3 + 1.6, 5) * ANG(0.62, 0, 0), STONE, METAL)
		end
		-- Triple-arched portico.
		env.arch(ctx, "ArchC", { width = 13, height = 13.5, depth = 8, wallWidth = 20, wallHeight = 20, cframe = CF(0, B + 10, -4), color = WALL, material = CONC })
		for _, sx in ipairs({ -16.65, 16.65 }) do
			env.arch(ctx, "ArchS", { width = 9, height = 10.5, depth = 8, wallWidth = 12.7, wallHeight = 20, cframe = CF(sx, B + 10, -4), color = WALL, material = CONC })
			ctx:window("DoorS", 6, 9, 0.8, CF(sx, B, -5.6), TIMBER, WOOD)
		end
		ctx:window("DoorC", 9.6, 11, 0.8, CF(0, B, -5.6), TIMBER, WOOD)
		for _, x in ipairs({ -23, -10.3, 10.3, 23 }) do
			ctx:part("Pilaster", V(2.6, 13, 1.4), CF(x, B + 6.5, 0.7), TRIM, CONC)
			ctx:part("PierPlinth", V(3.2, 2.4, 1.8), CF(x, B + 1.2, 0.9), MAROON, CONC)
			ctx:part("PierLamp", V(0.7, 1.1, 0.5), CF(x, B + 9, 1.65), C3(40, 40, 44), METAL)
		end
		-- Stepped white entablature (the portico's flat terrace roof in the 3-D view).
		ctx:part("EntabLow", V(47, 1.2, 11), CF(0, B + 20.6, -4.5), TRIM, CONC)
		ctx:part("CentreRise", V(26, 1.8, 8), CF(0, B + 21.5, -5), WALL, CONC)
		ctx:part("EntabMid", V(26, 1.2, 11), CF(0, B + 22.4, -4.5), TRIM, CONC)
		for _, x in ipairs({ -14.2, 14.2 }) do
			ctx:part("ReliefBand", V(13, 1.4, 0.4), CF(x, B + 14.8, 0.2), TRIM, CONC)
		end
		ctx:part("CrestFrame", V(3.4, 3.8, 0.3), CF(0, B + 17.5, 0.15), TRIM, CONC)
		ctx:part("Crest", V(2.4, 2.8, 0.4), CF(0, B + 17.5, 0.25), WALL_SHADE, CONC)

		for _, s in ipairs({ -1, 1 }) do
			-- Wings (first step, |x| 23..37, top B+25 = 30.8 in the elevation) with twin-arched windows and three square slits each.
			ctx:part("FacadeOuter", V(14, 25, 16), CF(s * 30, B + 12.5, -8), WALL, CONC)
			ctx:part("ShoulderFill", V(3, 4.4, 9), CF(s * 21.5, B + 22.8, -5.5), WALL, CONC)
			ctx:part("WingCornice", V(14.6, 1, 1.2), CF(s * 30, B + 24.4, 0.2), TRIM, CONC)
			arched(ctx, "ShoulderWin", V(s * 29.5, B + 3, 0), 0, 6.5, 10)
			ctx:part("ShoulderMullion", V(0.5, 10, 0.5), CF(s * 29.5, B + 8, 0.45), TRIM, CONC)
			for k = -1, 1 do
				ctx:part("ShoulderSlit", V(0.9, 2, 0.3), CF(s * (29.5 + 3 * k), B + 18.6, 0.15), GLASS, Enum.Material.Glass)
			end
			for k = 0, 6 do
				ctx:part("Crenel", V(1.4, 1.2, 1.4), CF(s * (23.6 + 2.1 * k), B + 25.6, -0.8), TRIM, CONC)
			end
			for k = 0, 3 do
				ctx:part("Crenel", V(1.4, 1.2, 1.4), CF(s * (14.5 + 1.8 * k), B + 33.6, -1.8), TRIM, CONC)
			end
			arched(ctx, "MidWin", V(s * 17, B + 22, -1), 0, 2.2, 7.5)
			-- Low outer wings (|x| 37..48, top 17.5): flat roofs with a cornice and parapet.
			box(ctx, "FacadeLow", s > 0 and 37 or -48, s > 0 and 48 or -37, 0, 17.5, -16, 0, WALL, CONC)
			box(ctx, "LowCornice", s > 0 and 36.8 or -48.4, s > 0 and 48.4 or -36.8, 16.2, 17.2, -16.4, 0.4, TRIM, CONC)
			box(ctx, "LowParapet", s > 0 and 37 or -48, s > 0 and 48 or -37, 17.5, 18.6, -0.6, 0, WALL, CONC)
			box(ctx, "LowPlinth", s > 0 and 37 or -48, s > 0 and 48 or -37, 0, 1.2, 0, 0.3, MAROON, CONC)
		end
		-- West low wing: the tall arched window of the 3-D view. (The east one carries the annex porch, built in Annex.)
		arched(ctx, "LowWin", V(-42.5, 3, 0), 0, 5, 10)
		-- Second step (40 wide, top B+33), centre block (26 wide, top B+36) with corner posts to 44.3, the pediment.
		ctx:part("FacadeMid", V(40, 12.4, 8), CF(0, B + 26.8, -5), WALL, CONC)
		ctx:part("FacadeCentre", V(26, 3, 8), CF(0, B + 34.5, -5), WALL, CONC)
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("CentrePost", V(2.5, 8.3, 8.4), CF(s * 11.75, 40.15, -5), WALL, CONC)
			ctx:part("PostCap", V(3.1, 0.6, 9), CF(s * 11.75, 44.6, -5), TRIM, CONC)
		end
		ctx:gable("PedTrim", 27, 5, 8, CF(0, B + 36, -5), TRIM, CONC)
		ctx:gable("Ped", 24, 4.1, 8.6, CF(0, B + 36, -5), WALL, CONC)
		for i = 1, 7 do
			ctx:part("PedScallop", V(1.6, 1.6, 0.6), CF(-7.5 + 2.5 * (i - 1), B + 37, -0.7), TRIM, CONC)
		end
		-- Rose window (dia 10, the elevation's 0.42 of the centre block), ringed tracery.
		local ry = 32.2
		ctx:cyl("RoseTrim", V(0.5, 11.2, 11.2), CF(0, ry, -0.85) * ANG(0, PI / 2, 0), TRIM, CONC)
		ctx:cyl("Rose", V(0.4, 10, 10), CF(0, ry, -0.6) * ANG(0, PI / 2, 0), GLASS)
		ctx:cyl("RoseHub", V(0.3, 3, 3), CF(0, ry, -0.35) * ANG(0, PI / 2, 0), TRIM, CONC)
		for k = 0, 3 do
			ctx:part("RoseTracery", V(10, 0.3, 0.2), CF(0, ry, -0.4) * ANG(0, 0, k * PI / 4), TRIM, CONC)
		end
		-- Marian niche with a white statue.
		ctx:part("NicheShelf", V(5.6, 0.6, 1.4), CF(0, B + 31.9, -0.5), TRIM, CONC)
		ctx:part("NicheFrame", V(5, 6.5, 0.5), CF(0, B + 34.9, -0.75), TRIM, CONC)
		ctx:part("NicheRecess", V(3.4, 5, 0.4), CF(0, B + 34.7, -0.5), WALL_SHADE, CONC)
		ctx:part("NicheStatue", V(1.2, 3.4, 0.8), CF(0, B + 33.7, -0.3), TRIM, PLAS)
		ctx:ball("NicheHead", 1.2, CF(0, B + 35.7, -0.3), TRIM, PLAS)
		-- Ringed (Celtic) cross on the apex: top 57.5 (elevation: 9 studs tall).
		local cy = 54.6
		ctx:part("CrossStem", V(1.2, 10.5, 1), CF(0, 52.25, -4), TRIM, CONC)
		ctx:part("CrossArm", V(5, 1.2, 1), CF(0, cy, -4), TRIM, CONC)
		for k = 0, 7 do
			local th = k * PI / 4
			ctx:part("CrossRing", V(1.8, 0.5, 0.7), CF(2.2 * math.cos(th), cy + 2.2 * math.sin(th), -4) * ANG(0, 0, th + PI / 2), TRIM, CONC)
		end
	end)

	------------------------------------------------------------------ Nave (z -10..-66), transept (z -49..-31), west side block
	env.section("Structure/Nave", function(ctx)
		ctx:part("NaveBlock", V(46, 28, 56), CF(0, 14, -38), WALL, CONC)
		ctx:gable("NaveRoof", 50, 11, 58, CF(0, 28, -38), ROOF, PLAS)
		roofRibs(ctx, "NaveRib", 0, -38, 28, 25, 11, 58.4, 6)
		ctx:part("NaveCornL", V(1.2, 1.2, 56), CF(-23.4, 27.4, -38), TRIM, CONC)
		ctx:part("NaveCornR", V(1.2, 1.2, 56), CF(23.4, 27.4, -38), TRIM, CONC)
		-- Tall arched clerestory windows, above the side blocks' eaves (y 18).
		for _, z in ipairs({ -15, -21, -27, -55, -61 }) do
			arched(ctx, "NaveWinE", V(23, 18.4, z), PI / 2, 3.6, 8)
			arched(ctx, "NaveWinW", V(-23, 18.4, z), -PI / 2, 3.6, 8)
		end
		-- Transept arms with gable roofs along X (the green roofs either side of the dome in the 3-D view).
		box(ctx, "TranseptW", -38, -23, 0, 26, -49, -31, WALL, CONC)
		box(ctx, "TranseptE", 23, 38, 0, 26, -49, -31, WALL, CONC)
		ctx:gable("TranseptRoofW", 21, 8, 16, CF(-30.5, 26, -40) * ANG(0, PI / 2, 0), ROOF, PLAS)
		ctx:gable("TranseptRoofE", 21, 8, 16, CF(30.5, 26, -40) * ANG(0, PI / 2, 0), ROOF, PLAS)
		for _, s in ipairs({ -1, 1 }) do
			arched(ctx, "TranseptWin", V(s * 38, 16, -40), s * PI / 2, 3.6, 7)
			box(ctx, "TranseptCornice", s > 0 and 23 or -38.4, s > 0 and 38.4 or -23, 25.4, 26.2, -49.4, -30.6, TRIM, CONC)
		end
		-- West side block (2 low storeys, small windows), behind the facade's west wings, with a hip roof.
		box(ctx, "ChapelWestWing", -48, -23, 0, 18, -58, -16, WALL, CONC)
		env.hipRoof(ctx, "WestWingRoof", -49, -22.5, -59, -15, 18, 6, ROOF, PLAS)
		box(ctx, "WestWingPlinth", -48.3, -47.9, 0, 1.2, -58, -16, MAROON, CONC)
		for k = 0, 4 do
			for _, y in ipairs({ 4, 11 }) do
				ctx:part("WestWingWin", V(0.3, 3.4, 2), CF(-48.1, y + 1.7, -22 - 7.5 * k), GLASS, Enum.Material.Glass)
			end
		end
		-- Sacristy behind the nave (the site-plan inset's block between the chapel and the north edge).
		box(ctx, "Sacristy", -14, 14, 0, 16, -86, -66, WALL, CONC)
		env.hipRoof(ctx, "SacristyRoof", -15, 15, -87, -65.5, 16, 5, ROOF, PLAS)
		for _, x in ipairs({ -15.15, 15.15 }) do
			for k = 0, 2 do
				ctx:part("SacristyWin", V(0.3, 4, 2.4), CF(x, 7, -82 + 6 * k), GLASS, Enum.Material.Glass)
			end
		end
	end)

	------------------------------------------------------------------ Dome over the crossing (0, -40): drum, ribbed dome, lantern, cross
	env.section("Structure/Dome", function(ctx)
		local cx, cz = 0, -40
		box(ctx, "CrossingBase", -13, 13, 28, 38.5, cz - 13, cz + 13, WALL, CONC)
		vcyl(ctx, "DomeDrum", cx, cz, 38, 48, 25, WALL, CONC)
		vcyl(ctx, "DrumBand", cx, cz, 38, 38.8, 26, TRIM, CONC)
		vcyl(ctx, "DrumCornice", cx, cz, 48, 49, 27, TRIM, CONC)
		for k = 0, 7 do
			local a = k * PI / 4 + PI / 8
			local dir = V(math.sin(a), 0, math.cos(a))
			arched(ctx, "DrumWin", V(cx, 40.3, cz) + dir * 12.5, a, 2.2, 5)
		end
		ctx:dome("Dome", 11, 8, CF(cx, 49.5, cz), DOME, RIB, PLAS)
		vcyl(ctx, "Lantern", cx, cz, 60, 64.5, 4.6, TRIM, CONC)
		for k = 0, 3 do
			local a = k * PI / 2
			local dir = V(math.sin(a), 0, math.cos(a))
			ctx:part("LanternWin", V(1, 2.4, 0.3), CF(V(cx, 62.2, cz) + dir * 2.25) * ANG(0, a, 0), GLASS, Enum.Material.Glass)
		end
		ctx:ball("LanternCap", 4.4, CF(cx, 64.8, cz), DOME, PLAS)
		ctx:part("DomeCrossStem", V(0.6, 4.4, 0.6), CF(cx, 67.3, cz), TRIM, CONC)
		ctx:part("DomeCrossArm", V(2.4, 0.6, 0.6), CF(cx, 68.3, cz), TRIM, CONC)
	end)

	------------------------------------------------------------------ Annex: the side wing east of the chapel, and the east low wing's porch
	env.section("Structure/Annex", function(ctx)
		box(ctx, "AnnexBlock", 38, 72, 0, 17, -58, -16, WALL, CONC)
		env.hipRoof(ctx, "AnnexRoof", 37, 73, -59, -15, 17, 6, ROOF, PLAS)
		box(ctx, "AnnexCornice", 37.6, 72.4, 16.2, 17, -16.4, -15.6, TRIM, CONC)
		box(ctx, "AnnexPlinth", 48, 72, 0, 1.2, -16, -15.7, MAROON, CONC)
		for k = 0, 3 do
			for _, y in ipairs({ 3.5, 10.5 }) do
				ctx:part("AnnexWin", V(2.6, 3.6, 0.3), CF(52 + 5.5 * k, y + 1.8, -15.85), GLASS, Enum.Material.Glass)
			end
		end
		for k = 0, 4 do
			for _, y in ipairs({ 3.5, 10.5 }) do
				ctx:part("AnnexWin", V(0.3, 3.6, 2.6), CF(72.15, y + 1.8, -22 - 8 * k), GLASS, Enum.Material.Glass)
			end
		end
		-- The porch of the east low wing (the elevation's flat canopy on two posts).
		ctx:window("AnnexDoor", 5, 8.5, 0.6, CF(42.5, 0, 0.1), TIMBER, WOOD)
		ctx:part("AnnexCanopy", V(8, 0.4, 4), CF(42.5, 10.4, 1.8), ROOF, PLAS)
		for _, x in ipairs({ 39, 46 }) do
			ctx:part("AnnexCanopyPost", V(0.4, 10.2, 0.4), CF(x, 5.1, 3.5), STONE, METAL)
		end
	end)
end
