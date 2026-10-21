-- site05: Monastery of Our Lady of Mount Carmel (Slice 04, reworked in Slice 15). Studio copy: ServerStorage.Builders.site05; run with
--   require(game.ServerStorage.Builders.site05:Clone())()
-- Run builders/placeholders first (it creates Workspace.Sites.Site05_Carmel with Guide, InfoPanel, JeepStop...).
-- IDEMPOTENT: replaces Block / Structure / Grounds / Garden / Shrine / Pews / Kneeler / Candles / HistoryPanels and keeps
-- Guide, InfoPanel, JeepStop, JeepSign*, Jeepney. Touches nothing outside Workspace.Sites.Site05_Carmel.
-- (The terrain under the forecourt is repainted Pavement by builders/world.luau: x -352..-248, z -600..-508. The forecourt
-- paving below must stay inside that region.)
-- Brief: briefs/site05.md "Revision 1 (Slice 15)"; spec: tests/site05_check.luau. FRAME: the site pivot is yawed 180 degrees
-- (RightVector = -X), so the pivot is NOT used as the origin. origin = CFrame.new(pivot position): local +X = east,
-- +Z = south = facade side, y up. All heights are above the ground; the portico floor is B = 6 (six risers of one stud).
-- Fail-safe order as in site01: everything is built into unparented components first (budget and CSG included); only then
-- are the old children deleted and the components parented one at a time. An error before that point destroys the partial
-- build and leaves the placeholder Block untouched. The model, its WorldPivot and PrimaryPart are never touched.
return function()
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(5)
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site05_Carmel")
	assert(site, "site05: Workspace.Sites.Site05_Carmel not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	local ORIGIN = CF(pivotBefore.Position)

	local PART_BUDGET = 2500
	local REPLACED = {
		Block = true, Structure = true, Grounds = true, Garden = true, Shrine = true,
		Pews = true, Kneeler = true, Candles = true, HistoryPanels = true,
	}

	-- Colours (facade_front_wide_balingit_2018.jpg, elevated_monastery_roofs_velasquez.jpg, dome_velasquez.jpg).
	local WALL = Color3.fromRGB(240, 220, 160)
	local WALL_SHADE = Color3.fromRGB(214, 196, 140)
	local TRIM = Color3.fromRGB(240, 236, 222)
	local ROOF = Color3.fromRGB(30, 92, 56) -- dark forest green (the Slice 04 teal was too light)
	local ROOF_RIB = Color3.fromRGB(46, 112, 70)
	local DOME = Color3.fromRGB(244, 232, 190)
	local RIB = Color3.fromRGB(226, 212, 168)
	local TIMBER = Color3.fromRGB(80, 50, 40)
	local MAROON = Color3.fromRGB(110, 40, 36)
	local HEDGE = Color3.fromRGB(52, 110, 56)
	local LAWN = Color3.fromRGB(86, 140, 60)
	local GLASS = Color3.fromRGB(40, 48, 58)
	local STONE = Color3.fromRGB(196, 188, 176)
	local STONE_LIGHT = Color3.fromRGB(214, 206, 194)
	local PAVE = Color3.fromRGB(150, 148, 144)
	local TERRACOTTA = Color3.fromRGB(196, 128, 94)
	local TEAL = Color3.fromRGB(20, 120, 110)
	local LAVA = Color3.fromRGB(70, 66, 64)
	local BILLBOARD = Color3.fromRGB(170, 215, 225)
	local PEW = Color3.fromRGB(120, 78, 48)
	local KNEEL_PAD = Color3.fromRGB(140, 40, 50)
	local PANEL = Color3.fromRGB(30, 36, 48)
	local FLAME = Color3.fromRGB(255, 200, 90)
	local CONC, PLAS = Enum.Material.Concrete, Enum.Material.SmoothPlastic
	local METAL, WOOD = Enum.Material.Metal, Enum.Material.Wood
	local BRICK, LEAF = Enum.Material.Brick, Enum.Material.Grass

	local function countParts(inst)
		local n = inst:IsA("BasePart") and 1 or 0
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		return n
	end

	-- Parts already in the site that survive the rebuild count against the 2,500 budget.
	local used = 0
	for _, c in ipairs(site:GetChildren()) do
		if not REPLACED[c.Name] then used += countParts(c) end
	end
	local keptParts = used

	local built = {} -- { name, parent = "Structure" | "Site", model, parts }
	local archPaths = { csg = 0, fallback = 0 }

	local function component(name, parent, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, ORIGIN, { budget = PART_BUDGET - used })
		fn(ctx, model)
		ctx:flush()
		used += ctx:count()
		table.insert(built, { name = name, parent = parent, model = model, parts = ctx:count() })
	end

	local function arch(ctx, name, spec)
		local r = ctx:arch(name, spec)
		archPaths[r.path] += 1
		return r
	end

	-- An arched window (glass) with a trim surround on a wall face. `pos` is the bottom centre on the wall surface;
	-- `yaw` turns the +Z face normal (0 = +Z, PI/2 = +X, PI = -Z, -PI/2 = -X). 4 parts.
	local function arched(ctx, name, pos, yaw, w, h)
		local rot = ANG(0, yaw, 0)
		local normal = rot:VectorToWorldSpace(V(0, 0, 1))
		ctx:window(name .. "_Trim", w + 1.4, h + 0.7, 0.4, CF(pos) * rot, TRIM, CONC)
		ctx:window(name, w, h, 0.4, CF(pos + normal * 0.15) * rot, GLASS)
	end

	-- A vertical cylinder (Roblox cylinders run along local X, so roll them upright).
	local function post(ctx, name, diameter, height, x, baseY, z, color, material)
		return ctx:cyl(name, V(height, diameter, diameter), CF(x, baseY + height / 2, z) * ANG(0, 0, PI / 2), color, material)
	end

	-- A SurfaceGui with a title and an optional body line on one face of a part.
	local function gui(part, face, title, body, textColor, ppstud)
		local g = Instance.new("SurfaceGui")
		g.Face = face
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud or 30
		g.Parent = part
		local function lab(text, y0, h, font)
			local t = Instance.new("TextLabel")
			t.Position = UDim2.fromScale(0, y0)
			t.Size = UDim2.fromScale(1, h)
			t.BackgroundTransparency = 1
			t.TextColor3 = textColor
			t.TextScaled = true
			t.TextWrapped = true
			t.Font = font
			t.Text = text
			t.Parent = g
		end
		if body then
			lab(title, 0.04, 0.3, Enum.Font.GothamBold)
			lab(body, 0.38, 0.55, Enum.Font.GothamMedium)
		else
			lab(title, 0.05, 0.9, Enum.Font.GothamBold)
		end
	end

	-- A cone topiary: a ball and a smaller ball above it (2 parts). `lowName` names the lower ball.
	local function topiary(ctx, lowName, x, y0, z)
		ctx:ball(lowName, 3.4, CF(x, y0 + 1.7, z), HEDGE, LEAF)
		ctx:ball(lowName .. "Top", 2.2, CF(x, y0 + 3.6, z), HEDGE, LEAF)
	end

	-- A white Marian statue on a pedestal (6 parts). baseY = top of the ground slab; bodyName names the figure.
	local function statue(ctx, x, baseY, z, bodyName)
		ctx:part("Pedestal", V(4, 4, 4), CF(x, baseY + 2, z), STONE_LIGHT, CONC)
		ctx:part("PedestalCap", V(4.6, 0.5, 4.6), CF(x, baseY + 4.25, z), TRIM, CONC)
		ctx:part(bodyName or "StatueBody", V(1.8, 5, 1.4), CF(x, baseY + 7, z), TRIM, PLAS)
		ctx:part("StatueArms", V(4, 0.5, 0.6), CF(x, baseY + 8.4, z), TRIM, PLAS)
		ctx:ball("StatueHead", 1.6, CF(x, baseY + 10.2, z), TRIM, PLAS)
		ctx:part("StatueHalo", V(0.3, 2.2, 2.2), CF(x, baseY + 10.2, z - 0.6), TRIM, PLAS)
	end

	-- Roof ribs: thin strips lying on both slopes of a gable whose ridge runs along Z.
	-- eave = (half width, eave y); rise = ridge height above the eave; n ribs per slope; length along Z.
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

	local B = 6 -- portico floor, studs above the forecourt

	------------------------------------------------------------------ Facade (front plane z = 0, body z -10..0, x +-34)
	-- Heights are measured from the 2018 frontal photo: 68 studs = the outer facade (1130 px); the three steps rise to B+25,
	-- B+33 and B+36, the pediment apex to B+41 and the ringed cross to B+46.
	local function buildFacade(ctx)
		ctx:part("Podium", V(72, B, 10), CF(0, B / 2, -5), STONE, CONC)
		-- One wide terracotta stair across the portico: six risers of 1 stud, each a solid block down to the ground.
		for i = 1, 6 do
			ctx:part("StairRiser", V(56, 1, 1.7), CF(0, i - 0.5, 0.85 + (6 - i) * 1.7), TERRACOTTA, CONC)
		end
		-- Cream flank walls with a maroon base stripe and cone topiary, beside the stair (x +-28..52).
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("FlankWall", V(24, 4, 1.4), CF(s * 40, 2, 8), WALL, CONC)
			ctx:part("FlankWallBase", V(24, 1, 1.6), CF(s * 40, 0.5, 8), MAROON, CONC)
			ctx:part("FlankWallCap", V(24.4, 0.4, 1.8), CF(s * 40, 4.2, 8), TRIM, CONC)
			for k = 0, 3 do
				topiary(ctx, "StairTopiary", s * (31 + 6 * k), 4.4, 8)
			end
		end
		-- Handrails over the stair.
		for _, x in ipairs({ -12, 12 }) do
			ctx:part("RailPost", V(0.3, 3, 0.3), CF(x, 1.5, 9.4), STONE, METAL)
			ctx:part("RailPost", V(0.3, 3, 0.3), CF(x, B + 1.5, 0.6), STONE, METAL)
			ctx:part("StairRail", V(0.3, 0.3, 10.4), CF(x, 3 + 1.6, 5) * ANG(0.62, 0, 0), STONE, METAL)
		end

		-- Triple-arched portico: one large centre arch, two smaller side arches, timber doors set back in each.
		arch(ctx, "ArchC", { width = 13, height = 13.5, depth = 8, wallWidth = 20, wallHeight = 20,
			cframe = CF(0, B + 10, -4), color = WALL, material = CONC })
		for _, sx in ipairs({ -16.65, 16.65 }) do
			arch(ctx, "ArchS", { width = 9, height = 10.5, depth = 8, wallWidth = 12.7, wallHeight = 20,
				cframe = CF(sx, B + 10, -4), color = WALL, material = CONC })
			ctx:window("DoorS", 6, 9, 0.8, CF(sx, B, -5.6), TIMBER, WOOD)
		end
		ctx:window("DoorC", 9.6, 11, 0.8, CF(0, B, -5.6), TIMBER, WOOD)
		-- White pilasters (13 high) on maroon plinths.
		for _, x in ipairs({ -23, -10.3, 10.3, 23 }) do
			ctx:part("Pilaster", V(2.6, 13, 1.4), CF(x, B + 6.5, 0.7), TRIM, CONC)
			ctx:part("PierPlinth", V(3.2, 2.4, 1.8), CF(x, B + 1.2, 0.9), MAROON, CONC)
		end
		-- Stepped white entablature: low across the portico, raised over the centre arch.
		ctx:part("EntabLow", V(47, 1.2, 11), CF(0, B + 20.6, -4.5), TRIM, CONC)
		ctx:part("CentreRise", V(26, 1.8, 8), CF(0, B + 21.5, -5), WALL, CONC)
		ctx:part("EntabMid", V(26, 1.2, 11), CF(0, B + 22.4, -4.5), TRIM, CONC)
		-- Relief bands over the side arches and the coat of arms over the centre arch.
		for _, x in ipairs({ -14.2, 14.2 }) do
			ctx:part("ReliefBand", V(13, 1.4, 0.4), CF(x, B + 14.8, 0.2), TRIM, CONC)
		end
		ctx:part("CrestFrame", V(3.4, 3.8, 0.3), CF(0, B + 17.5, 0.15), TRIM, CONC)
		ctx:part("Crest", V(2.4, 2.8, 0.4), CF(0, B + 17.5, 0.25), WALL_SHADE, CONC)

		-- Outer shoulders (first step, x +-23..34, top B+25) with twin-arched windows and three square slits each.
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("FacadeOuter", V(11, 25, 10), CF(s * 28.5, B + 12.5, -5), WALL, CONC)
			ctx:part("ShoulderFill", V(3, 4.4, 9), CF(s * 21.5, B + 22.8, -5.5), WALL, CONC)
			arched(ctx, "ShoulderWin", V(s * 28.5, B + 3, 0), 0, 6, 10)
			ctx:part("ShoulderMullion", V(0.5, 10, 0.5), CF(s * 28.5, B + 8, 0.45), TRIM, CONC)
			for k = -1, 1 do
				ctx:part("ShoulderSlit", V(0.9, 2, 0.3), CF(s * (28.5 + 3 * k), B + 19.8, 0.15), GLASS, Enum.Material.Glass)
			end
			-- crenellated white band along the top of the shoulder (6) and of the mid step (4)
			for k = 0, 5 do
				ctx:part("Crenel", V(1.4, 1.2, 1.4), CF(s * (23.5 + 1.9 * k), B + 25.6, -0.8), TRIM, CONC)
			end
			for k = 0, 3 do
				ctx:part("Crenel", V(1.4, 1.2, 1.4), CF(s * (14.5 + 1.8 * k), B + 33.6, -1.8), TRIM, CONC)
			end
			arched(ctx, "MidWin", V(s * 17, B + 22, -1), 0, 2.2, 7.5)
		end
		-- Second step (40 wide, top B+33), third step (26 wide, top B+36), and the pediment.
		ctx:part("FacadeMid", V(40, 12.4, 8), CF(0, B + 26.8, -5), WALL, CONC)
		ctx:part("FacadeCentre", V(26, 3, 8), CF(0, B + 34.5, -5), WALL, CONC)
		ctx:gable("PedTrim", 27, 5, 8, CF(0, B + 36, -5), TRIM, CONC)
		ctx:gable("Ped", 24, 4.1, 8.6, CF(0, B + 36, -5), WALL, CONC)
		for i = 1, 7 do
			ctx:part("PedScallop", V(1.6, 1.6, 0.6), CF(-7.5 + 2.5 * (i - 1), B + 37, -0.7), TRIM, CONC)
		end
		-- Rose window (white trim, dark glass, three spokes dropped: the photo shows a ringed tracery).
		ctx:cyl("RoseTrim", V(0.5, 8.6, 8.6), CF(0, B + 26.3, -0.85) * ANG(0, PI / 2, 0), TRIM, CONC)
		ctx:cyl("Rose", V(0.4, 7.4, 7.4), CF(0, B + 26.3, -0.6) * ANG(0, PI / 2, 0), GLASS)
		for k = 0, 2 do
			ctx:part("RoseTracery", V(7.4, 0.3, 0.2), CF(0, B + 26.3, -0.4) * ANG(0, 0, k * PI / 3), TRIM, CONC)
		end
		-- Marian niche with a white statue.
		ctx:part("NicheShelf", V(5.6, 0.6, 1.4), CF(0, B + 31.6, -0.5), TRIM, CONC)
		ctx:part("NicheFrame", V(5, 6.5, 0.5), CF(0, B + 34.6, -0.75), TRIM, CONC)
		ctx:part("NicheRecess", V(3.4, 5, 0.4), CF(0, B + 34.4, -0.5), WALL_SHADE, CONC)
		ctx:part("NicheStatue", V(1.2, 3.4, 0.8), CF(0, B + 33.4, -0.3), TRIM, PLAS)
		ctx:ball("NicheHead", 1.2, CF(0, B + 35.4, -0.3), TRIM, PLAS)
		-- Ringed (Celtic) cross on the apex: top B+46.
		local cy = B + 44
		ctx:part("CrossStem", V(1, 7, 0.9), CF(0, B + 42.5, -4), TRIM, CONC)
		ctx:part("CrossArm", V(4, 1, 0.9), CF(0, cy, -4), TRIM, CONC)
		for k = 0, 7 do
			local th = k * PI / 4
			ctx:part("CrossRing", V(1.45, 0.45, 0.6), CF(1.8 * math.cos(th), cy + 1.8 * math.sin(th), -4) * ANG(0, 0, th + PI / 2), TRIM, CONC)
		end
	end

	------------------------------------------------------------------ Nave (z -10..-66, x +-23)
	local function buildNave(ctx)
		ctx:part("NaveBlock", V(46, 28, 56), CF(0, 14, -38), WALL, CONC)
		ctx:gable("NaveRoof", 50, 11, 58, CF(0, 28, -38), ROOF, PLAS)
		roofRibs(ctx, "NaveRib", 0, -38, 28, 25, 11, 58.4, 6)
		ctx:part("NaveCornL", V(1.2, 1.2, 56), CF(-23.4, 27.4, -38), TRIM, CONC)
		ctx:part("NaveCornR", V(1.2, 1.2, 56), CF(23.4, 27.4, -38), TRIM, CONC)
		-- The repeated tall arched windows: five per side.
		ctx:repeatAlong(5, V(0, 0, -18), V(0, 0, -9), function(_, p)
			arched(ctx, "NaveWinE", V(23, 8, p.Z), PI / 2, 4, 11)
			arched(ctx, "NaveWinW", V(-23, 8, p.Z), -PI / 2, 4, 11)
		end)
	end

	------------------------------------------------------------------ East annex (low block east of the facade, x 34..50)
	local function buildAnnex(ctx)
		ctx:part("AnnexBlock", V(16, 12, 20), CF(42, 6, -12), WALL, CONC)
		ctx:part("AnnexRoof", V(17, 0.6, 21), CF(42, 12.3, -12), ROOF, PLAS)
		ctx:part("AnnexCornice", V(16.6, 0.8, 1), CF(42, 11.4, -1.6), TRIM, CONC)
		ctx:window("AnnexDoor", 5, 8.5, 0.6, CF(42, 0, -1.8), TIMBER, WOOD)
		ctx:part("AnnexCanopy", V(9, 0.4, 4), CF(42, 10.4, -0.2), ROOF, PLAS)
		for _, x in ipairs({ 38, 46 }) do
			ctx:part("AnnexCanopyPost", V(0.4, 10.2, 0.4), CF(x, 5.1, 1.6), STONE, METAL)
		end
	end

	------------------------------------------------------------------ Monastery wing (west): long 2-storey block, walkway, L-return
	local function buildMonastery(ctx)
		ctx:part("MonasteryBlock", V(68, 24, 26), CF(-68, 12, -21), WALL, CONC)
		ctx:gable("MonasteryRoof", 32, 7, 72, CF(-68, 24, -21) * ANG(0, PI / 2, 0), ROOF, PLAS)
		ctx:part("MonasteryEave", V(72, 0.7, 1.4), CF(-68, 23.8, -7.6), ROOF_RIB, PLAS)
		ctx:part("MonasteryCornice", V(69, 1, 1.2), CF(-68, 23.4, -7.6), TRIM, CONC)
		-- Paired louvred windows in two rows (six pairs per row, two panes each).
		for _, y in ipairs({ 6.5, 17.5 }) do
			for k = 0, 5 do
				for _, dx in ipairs({ -1.9, 1.9 }) do
					ctx:part("MonasteryWin", V(3, 5, 0.3), CF(-98 + 10.8 * k + dx, y, -7.85), GLASS, Enum.Material.Glass)
				end
			end
		end
		-- Covered walkway along the front: floor, dark green roof at 12.4, eight posts, five teal umbrellas.
		ctx:part("WalkwayFloor", V(68, 0.4, 6), CF(-68, 0.2, -5), STONE, CONC)
		ctx:part("WalkwayRoof", V(70, 0.5, 7.4), CF(-68, 12.4, -4.7), ROOF, PLAS)
		for k = 0, 7 do
			ctx:part("WalkwayPost", V(0.5, 12, 0.5), CF(-100 + 9.5 * k, 6.2, -2.3), TRIM, CONC)
		end
		for k = 0, 4 do
			local x = -94 + 11 * k
			post(ctx, "UmbrellaPole", 0.3, 7, x, 0.4, -5.2, STONE, METAL)
			ctx:cyl("Umbrella", V(0.5, 7, 7), CF(x, 8.2, -5.2) * ANG(0, 0, PI / 2), TEAL, PLAS)
		end
		-- L-shaped return wing to the north of the court (guessed; no photo shows its rear).
		ctx:part("MonasteryReturn", V(22, 24, 36), CF(-91, 12, -52), WALL, CONC)
		ctx:gable("MonasteryReturnRoof", 26, 7, 40, CF(-91, 24, -52), ROOF, PLAS)
		for _, z in ipairs({ -42, -52, -62 }) do
			for _, y in ipairs({ 6.5, 17.5 }) do
				ctx:part("ReturnWin", V(0.3, 5, 3.6), CF(-79.85, y, z), GLASS, Enum.Material.Glass)
			end
		end
	end

	------------------------------------------------------------------ Dome over the nave rear: round drum, cream ribbed dome, lantern, cross
	local function buildDome(ctx)
		local cx, cz = 0, -50
		ctx:cyl("DomeDrum", V(12, 17, 17), CF(cx, 36, cz) * ANG(0, 0, PI / 2), WALL, CONC)
		ctx:cyl("DrumCornice", V(1, 19, 19), CF(cx, 42.3, cz) * ANG(0, 0, PI / 2), TRIM, CONC)
		for _, f in ipairs({ { 8.45, 0, PI / 2 }, { -8.45, 0, -PI / 2 }, { 0, 8.45, 0 }, { 0, -8.45, PI } }) do
			arched(ctx, "DrumWin", V(cx + f[1], 32.5, cz + f[2]), f[3], 3, 7)
		end
		ctx:dome("Dome", 8, 8, CF(cx, 42.5, cz), DOME, RIB, PLAS)
		post(ctx, "Lantern", 3, 5, cx, 49.5, cz, TRIM, CONC)
		ctx:ball("LanternCap", 3.4, CF(cx, 55, cz), DOME, PLAS)
		ctx:part("DomeCrossStem", V(0.5, 4, 0.5), CF(cx, 57.4, cz), TRIM, CONC)
		ctx:part("DomeCrossArm", V(2, 0.5, 0.5), CF(cx, 58.4, cz), TRIM, CONC)
	end

	------------------------------------------------------------------ Grounds: forecourt paving, medallion, the Marian billboard
	local function buildGrounds(ctx)
		ctx:part("ForecourtPaving", V(100, 0.1, 86), CF(0, 0.05, 45), PAVE, CONC) -- inside the repainted terrain region
		ctx:cyl("ForecourtMedallion", V(0.15, 10, 10), CF(0, 0.17, 50) * ANG(0, 0, PI / 2), STONE_LIGHT, CONC)
		-- The arched Marian billboard on a lava-stone base, facing the road (+Z). Plain colours, no text, no photo texture.
		local bx, bz = 40, 56
		ctx:part("BillboardBase", V(8, 4.5, 5), CF(bx, 2.25, bz), LAVA, Enum.Material.Slate)
		for _, r in ipairs({ { -3.4, 1.7, 1.6 }, { 3.4, 1.5, 1.9 }, { 0.4, 1.1, 3.3 } }) do
			ctx:ball("BillboardRock", 3.4, CF(bx + r[1], r[2], bz + r[3]), LAVA, Enum.Material.Slate)
		end
		ctx:window("BillboardFrame", 9.6, 14, 0.4, CF(bx, 4.4, bz - 0.3), TRIM, CONC)
		ctx:window("BillboardPanel", 8.4, 13, 0.6, CF(bx, 4.5, bz), BILLBOARD, PLAS)
		ctx:part("BillboardFigure", V(2.6, 6, 0.3), CF(bx, 8.6, bz + 0.45), TRIM, PLAS)
		ctx:ball("BillboardHead", 1.6, CF(bx, 12.3, bz + 0.45), TRIM, PLAS)
	end

	------------------------------------------------------------------ Garden: west topiary court, east prayer garden
	local function buildGarden(ctx)
		-- West court in front of the monastery wing (x -101..-51, z -2..14): a raised lawn so the terrain's grass blades
		-- are hidden, a terracotta path, cone topiaries, a hedge and the white statue on its pedestal.
		ctx:part("CourtLawn", V(50, 0.4, 16), CF(-76, 0.2, 6), LAWN, LEAF)
		ctx:part("CourtPath", V(40, 0.25, 3), CF(-76, 0.525, 6), TERRACOTTA, CONC)
		ctx:part("CourtHedge", V(50, 2.5, 1.6), CF(-76, 1.65, 13.4), HEDGE, LEAF)
		for k = 0, 5 do
			topiary(ctx, "Topiary", -97 + 8.5 * k, 0.4, 10)
		end
		for k = 0, 3 do
			topiary(ctx, "Topiary", -93 + 8.5 * k, 0.4, 2)
		end
		statue(ctx, -56, 0.4, 6, "CourtStatue")
		-- East prayer garden: a raised stone slab (0.4 thick so no grass shows), a connecting path, the statue.
		ctx:part("PrayerSlab", V(46, 0.4, 56), CF(76, 0.2, 32), STONE_LIGHT, CONC)
		ctx:part("PrayerPath", V(8, 0.3, 6), CF(51.5, 0.15, 18), STONE_LIGHT, CONC)
		statue(ctx, 78, 0.4, 12)
		ctx:part("PrayerHedgeN", V(46, 2.5, 1.6), CF(76, 1.65, 3.4), HEDGE, LEAF)
		ctx:part("PrayerHedgeS", V(46, 2.5, 1.6), CF(76, 1.65, 59.4), HEDGE, LEAF)
		ctx:part("PrayerHedgeE", V(1.6, 2.5, 56), CF(98.6, 1.65, 32), HEDGE, LEAF)
	end

	------------------------------------------------------------------ Shrine: gable over a brick-red base, arched gate, tablets
	local function buildShrine(ctx)
		local cx, cz = 80, -51
		arch(ctx, "ShrineWall", { width = 6, height = 8, depth = 6, wallWidth = 18, wallHeight = 11,
			cframe = CF(cx, 5.5, cz), color = MAROON, material = BRICK })
		ctx:window("ShrineGate", 5.4, 8, 0.5, CF(cx, 0, cz + 0.4), TIMBER, WOOD)
		ctx:part("ShrineGableBlock", V(20, 3, 6.6), CF(cx, 12.5, cz), WALL, CONC)
		ctx:gable("ShrineGable", 20, 7, 6.6, CF(cx, 14, cz), WALL, CONC)
		ctx:part("ShrineEdgeL", V(0.5, 0.5, 7), CF(cx - 5.3, 17.2, cz) * ANG(0, 0, 0.62), ROOF, PLAS)
		ctx:part("ShrineEdgeR", V(0.5, 0.5, 7), CF(cx + 5.3, 17.2, cz) * ANG(0, 0, -0.62), ROOF, PLAS)
		ctx:part("ShrineStep", V(8, 0.4, 2.4), CF(cx, 0.2, cz + 4.2), STONE, CONC)
		for i, sx in ipairs({ -6, 6 }) do
			local tablet = ctx:part("Tablet" .. i, V(4.4, 6, 0.3), CF(cx + sx, 5.5, cz + 3.15), TRIM, CONC)
			gui(tablet, Enum.NormalId.Back, "THE TEN COMMANDMENTS", i == 2 and "(continued)" or nil, Color3.fromRGB(30, 30, 30), 40)
		end
	end

	------------------------------------------------------------------ Required props (unchanged from Slice 04)
	local function buildPews(ctx)
		for i = 0, 3 do
			local z = 26 + 6 * i
			ctx:part("PewSeat", V(12, 0.6, 2.2), CF(78, 1.9, z), PEW, WOOD)
			ctx:part("PewBack", V(12, 3, 0.4), CF(78, 3.4, z + 1), PEW, WOOD)
			for _, lx in ipairs({ 72.6, 83.4 }) do
				ctx:part("PewLeg", V(0.6, 1.5, 2), CF(lx, 1.15, z), PEW, WOOD)
			end
		end
	end

	local function buildKneeler(ctx)
		ctx:part("KneelerBase", V(10, 1.2, 2.4), CF(78, 1, 18), PEW, WOOD)
		ctx:part("KneelerPad", V(9.6, 0.4, 1.6), CF(78, 1.8, 18), KNEEL_PAD, PLAS)
		ctx:part("KneelerRail", V(10, 1.8, 0.4), CF(78, 2.5, 19.4), PEW, WOOD)
	end

	local function buildCandles(ctx)
		ctx:part("CandleRack", V(6, 2.6, 2.4), CF(70, 1.7, 10), STONE, CONC)
		for r = 0, 1 do
			for c = 0, 4 do
				local x, z = 67.8 + 1.1 * c, 9.5 + 1.1 * r
				post(ctx, "Candle", 0.5, 1.1, x, 3, z, TRIM, PLAS)
				ctx:ball("Flame", 0.45, CF(x, 4.3, z), FLAME, Enum.Material.Neon)
			end
		end
	end

	local function buildHistoryPanels(ctx)
		local titles = {
			"1946 - Founding",
			"1948 - Reported apparitions",
			"1951 and 2015 - Church rulings",
		}
		-- Approved Slice 12 text (content/dialogue_draft.md); keep each body near 100 characters, the label is TextScaled.
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
			gui(board, Enum.NormalId.Left, titles[i], bodies[i], Color3.new(1, 1, 1), 30)
		end
	end

	------------------------------------------------------------------ Build, then swap
	local ok, err = pcall(function()
		component("Facade", "Structure", buildFacade)
		component("Nave", "Structure", buildNave)
		component("Annex", "Structure", buildAnnex)
		component("Monastery", "Structure", buildMonastery)
		component("Dome", "Structure", buildDome)
		component("Grounds", "Site", buildGrounds)
		component("Garden", "Site", buildGarden)
		component("Shrine", "Site", buildShrine)
		component("Pews", "Site", buildPews)
		component("Kneeler", "Site", buildKneeler)
		component("Candles", "Site", buildCandles)
		component("HistoryPanels", "Site", buildHistoryPanels)
		assert(used <= PART_BUDGET, string.format("site05: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, b in ipairs(built) do b.model:Destroy() end
		error("site05: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
	end

	for _, child in ipairs(site:GetChildren()) do
		if REPLACED[child.Name] then child:Destroy() end
	end
	local structure = Instance.new("Folder")
	structure.Name = "Structure"
	structure.Parent = site
	for _, b in ipairs(built) do
		b.model.Parent = (b.parent == "Structure") and structure or site
		task.wait()
	end

	local pivotAfter = site:GetPivot()
	assert((pivotAfter.Position - pivotBefore.Position).Magnitude < 1e-3 and pivotAfter.LookVector:Dot(pivotBefore.LookVector) > 0.9999,
		"site05: the site pivot changed during the build")

	local perComponent = {}
	for _, b in ipairs(built) do perComponent[b.name] = b.parts end
	return {
		parts = countParts(site),
		keptParts = keptParts,
		builtParts = used - keptParts,
		components = perComponent,
		archPaths = archPaths,
	}
end
