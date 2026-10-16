-- site05: Monastery of Our Lady of Mount Carmel (Slice 04). Studio copy: ServerStorage.Builders.site05; run with
--   require(game.ServerStorage.Builders.site05:Clone())()
-- Run builders/placeholders first (it creates Workspace.Sites.Site05_Carmel with Guide, InfoPanel, JeepStop...).
-- IDEMPOTENT: replaces Block / Structure / Grounds / Garden / Shrine / Pews / Kneeler / Candles / HistoryPanels and keeps
-- Guide, InfoPanel, JeepStop, JeepSign*, Jeepney. Touches nothing outside Workspace.Sites.Site05_Carmel.
-- (The terrain under the forecourt is repainted Pavement by builders/world.luau: x -352..-248, z -600..-508. The forecourt
-- paving below must stay inside that region.)
-- Brief: briefs/site05.md. FRAME: the site pivot is yawed 180 degrees (RightVector = -X), so the pivot is NOT used as
-- the origin. origin = CFrame.new(pivot position): local +X = east, +Z = south = facade side, y up.
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

	-- Colours (Chapel_Front_Wide.jpg, Carmel_Monastery_Oblique_Official_2021.jpg, Outdoor_Shrine_Structure.jpg).
	local WALL = Color3.fromRGB(240, 220, 160)
	local WALL_SHADE = Color3.fromRGB(214, 196, 140)
	local TRIM = Color3.fromRGB(240, 236, 222)
	local ROOF = Color3.fromRGB(40, 110, 70)
	local ROOF_RIB = Color3.fromRGB(60, 135, 90)
	local DOME = Color3.fromRGB(244, 232, 190)
	local RIB = Color3.fromRGB(226, 212, 168)
	local TIMBER = Color3.fromRGB(80, 50, 40)
	local MAROON = Color3.fromRGB(150, 55, 45)
	local HEDGE = Color3.fromRGB(52, 110, 56)
	local GLASS = Color3.fromRGB(40, 48, 58)
	local STONE = Color3.fromRGB(196, 188, 176)
	local STONE_LIGHT = Color3.fromRGB(214, 206, 194)
	local PAVE = Color3.fromRGB(150, 148, 144)
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

	-- A cone shrub in a planter (2 balls + planter = 3 parts).
	local function shrub(ctx, x, y0, z)
		ctx:part("Planter", V(3, 1.4, 3), CF(x, y0 + 0.7, z), TRIM, CONC)
		ctx:ball("Shrub", 4.2, CF(x, y0 + 3.1, z), HEDGE, LEAF)
		ctx:ball("ShrubTop", 3, CF(x, y0 + 5, z), HEDGE, LEAF)
	end

	-- A white Marian statue on a pedestal (6 parts). baseY = top of the ground slab.
	local function statue(ctx, x, baseY, z)
		ctx:part("Pedestal", V(4, 4, 4), CF(x, baseY + 2, z), STONE_LIGHT, CONC)
		ctx:part("PedestalCap", V(4.6, 0.5, 4.6), CF(x, baseY + 4.25, z), TRIM, CONC)
		ctx:part("StatueBody", V(1.8, 5, 1.4), CF(x, baseY + 7, z), TRIM, PLAS)
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

	local B = 2 -- podium height: the portico floor

	------------------------------------------------------------------ Facade (z -9..+4, x +-26)
	local function buildFacade(ctx)
		ctx:part("Podium", V(52, 2, 10), CF(0, 1, -4), STONE, CONC)
		ctx:part("Step1", V(34, 1, 3), CF(0, 0.5, 2.5), STONE, CONC) -- risers of 1 stud
		-- Triple-arched portico: one large centre arch, two smaller side arches, timber doors set back in each.
		arch(ctx, "ArchC", { width = 12, height = 14, depth = 8, wallWidth = 20, wallHeight = 16,
			cframe = CF(0, B + 8, -4), color = WALL, material = CONC })
		for _, sx in ipairs({ -17.5, 17.5 }) do
			arch(ctx, "ArchS", { width = 8, height = 11, depth = 8, wallWidth = 15, wallHeight = 16,
				cframe = CF(sx, B + 8, -4), color = WALL, material = CONC })
			ctx:window("DoorS", 6, 9, 0.8, CF(sx, B, -5.6), TIMBER, WOOD)
		end
		ctx:window("DoorC", 9.2, 11, 0.8, CF(0, B, -5.6), TIMBER, WOOD)
		for _, x in ipairs({ -25, -10, 10, 25 }) do
			ctx:part("Pilaster", V(2.6, 16, 1.4), CF(x, B + 8, 0.7), TRIM, CONC)
			ctx:part("PierPlinth", V(3.2, 2, 1.8), CF(x, B + 1, 0.9), MAROON, CONC)
		end
		-- Coat-of-arms relief above the west side arch (flat panel).
		ctx:part("CrestFrame", V(3.4, 3.8, 0.3), CF(-17.5, B + 13.6, 0.15), TRIM, CONC)
		ctx:part("Crest", V(2.4, 2.8, 0.4), CF(-17.5, B + 13.6, 0.25), WALL_SHADE, CONC)

		ctx:part("Cornice1", V(53, 1.6, 10.4), CF(0, B + 16.8, -4), TRIM, CONC)
		ctx:part("Register2", V(50, 10.4, 8), CF(0, B + 22.8, -4), WALL, CONC)
		-- Rose window with three spokes.
		ctx:cyl("RoseTrim", V(0.5, 9.6, 9.6), CF(0, B + 23, 0.1) * ANG(0, PI / 2, 0), TRIM, CONC)
		ctx:cyl("Rose", V(0.4, 8, 8), CF(0, B + 23, 0.3) * ANG(0, PI / 2, 0), GLASS)
		for k = 0, 2 do
			ctx:part("RoseSpoke", V(8, 0.35, 0.2), CF(0, B + 23, 0.6) * ANG(0, 0, k * PI / 3), TRIM, CONC)
		end
		ctx:part("Cornice2", V(52, 1.2, 9.6), CF(0, B + 28.6, -4.2), TRIM, CONC)
		-- Stepped upper tiers.
		ctx:part("Tier2", V(36, 8, 8), CF(0, B + 33.2, -4), WALL, CONC)
		ctx:part("Cornice3", V(38, 1.2, 9.6), CF(0, B + 37.8, -4.2), TRIM, CONC)
		ctx:part("Tier3", V(22, 5, 8), CF(0, B + 40.9, -4), WALL, CONC)
		-- Pediment: white border gable behind a slightly smaller cream gable.
		ctx:gable("PedTrim", 25, 8, 8, CF(0, B + 43.4, -4), TRIM, CONC)
		ctx:gable("Ped", 22, 6.6, 9, CF(0, B + 43.4, -4), WALL, CONC)
		-- Scalloped corbel band under the pediment.
		for i = 1, 7 do
			ctx:part("Scallop", V(1.6, 1.6, 0.6), CF(-7.5 + 2.5 * (i - 1), B + 42.4, 0.3), TRIM, CONC)
		end
		-- Marian niche with a white statue.
		ctx:part("NicheShelf", V(5.6, 0.6, 1.4), CF(0, B + 30.3, 0.6), TRIM, CONC)
		ctx:part("NicheFrame", V(5, 6.5, 0.5), CF(0, B + 33.6, 0.25), TRIM, CONC)
		ctx:part("NicheRecess", V(3.4, 5, 0.4), CF(0, B + 33.5, 0.5), WALL_SHADE, CONC)
		ctx:part("NicheStatue", V(1.2, 3.4, 0.8), CF(0, B + 32.4, 0.8), TRIM, PLAS)
		ctx:ball("NicheHead", 1.2, CF(0, B + 34.5, 0.8), TRIM, PLAS)
		-- Ringed (Celtic) cross on the apex.
		local cy = B + 56.4
		ctx:part("CrossStem", V(1, 7, 0.9), CF(0, B + 54.9, -3.5), TRIM, CONC)
		ctx:part("CrossArm", V(4, 1, 0.9), CF(0, cy, -3.5), TRIM, CONC)
		for k = 0, 7 do
			local th = k * PI / 4
			ctx:part("CrossRing", V(1.45, 0.45, 0.6), CF(1.8 * math.cos(th), cy + 1.8 * math.sin(th), -3.5) * ANG(0, 0, th + PI / 2), TRIM, CONC)
		end
		-- Handrails over the two steps.
		for _, x in ipairs({ -15, 15 }) do
			ctx:part("RailPostLow", V(0.3, 3, 0.3), CF(x, 1.5, 4), STONE, METAL)
			ctx:part("RailPostHigh", V(0.3, 3, 0.3), CF(x, B + 1.5, 1), STONE, METAL)
			ctx:part("Rail", V(0.3, 0.3, 3.2), CF(x, 4, 2.5) * ANG(0.32, 0, 0), STONE, METAL)
		end
	end

	------------------------------------------------------------------ Nave (z -8..-66, x +-21)
	local function buildNave(ctx)
		ctx:part("NaveBlock", V(42, 26, 58), CF(0, 15, -37), WALL, CONC)
		ctx:gable("NaveRoof", 46, 12, 60, CF(0, 28, -37), ROOF, PLAS)
		roofRibs(ctx, "NaveRib", 0, -37, 28, 23, 12, 60.4, 6)
		ctx:part("NaveCornL", V(1.2, 1.2, 58), CF(-21.4, 27.4, -37), TRIM, CONC)
		ctx:part("NaveCornR", V(1.2, 1.2, 58), CF(21.4, 27.4, -37), TRIM, CONC)
		-- The repeated tall arched windows: six per side.
		ctx:repeatAlong(6, V(0, 0, -16), V(0, 0, -8), function(_, p)
			arched(ctx, "NaveWinE", V(21, 8, p.Z), PI / 2, 4, 11)
			arched(ctx, "NaveWinW", V(-21, 8, p.Z), -PI / 2, 4, 11)
		end)
	end

	------------------------------------------------------------------ East wing (x +21..+66, recessed)
	local function buildEastWing(ctx)
		ctx:part("EastWingBlock", V(31, 20, 38), CF(36.5, 12, -25), WALL, CONC)
		ctx:gable("EastWingRoof", 33, 7, 40, CF(36.5, 22, -25), ROOF, PLAS)
		ctx:part("EastWingCornice", V(32, 1, 1.2), CF(36.5, 21.5, -6.4), TRIM, CONC)
		arched(ctx, "WingBigWin", V(36, 8, -6), 0, 8, 12)
		for _, x in ipairs({ 27, 30, 42, 45 }) do
			ctx:part("WingSmallWin", V(1.6, 2, 0.3), CF(x, 18, -5.9), GLASS, Enum.Material.Glass)
		end
		-- Low annex with a green canopy over its door (door 8.5 studs).
		ctx:part("AnnexBlock", V(14, 10, 24), CF(59, 7, -18), WALL, CONC)
		ctx:part("AnnexRoof", V(15, 0.6, 25), CF(59, 12.3, -18), ROOF, PLAS)
		ctx:window("AnnexDoor", 5, 8.5, 0.6, CF(59, B, -5.8), TIMBER, WOOD)
		ctx:part("AnnexCanopy", V(9, 0.4, 4), CF(59, 11.2, -4), ROOF, PLAS)
		for _, x in ipairs({ 55, 63 }) do
			ctx:part("AnnexCanopyPost", V(0.4, 9.2, 0.4), CF(x, 6.6, -2.2), STONE, METAL)
		end
	end

	------------------------------------------------------------------ Monastery wing (west, approximated) + dome
	local function buildMonastery(ctx)
		ctx:part("MonasteryBlock", V(49, 20, 40), CF(-47.5, 12, -34), WALL, CONC)
		ctx:gable("MonasteryRoof", 42, 8, 51, CF(-47.5, 22, -34) * ANG(0, PI / 2, 0), ROOF, PLAS)
		ctx:part("MonasteryCornice", V(50, 1, 1.2), CF(-47.5, 21.5, -14.4), TRIM, CONC)
		-- Two rows of rectangular windows on the south face.
		for _, y in ipairs({ 8, 16 }) do
			ctx:repeatAlong(8, V(-68, y, -13.9), V(6, 0, 0), function(_, p)
				ctx:part("MonasteryWin", V(3.6, 5, 0.3), CF(p), GLASS, Enum.Material.Glass)
			end)
		end
		-- Veranda: floor, green canopy, posts.
		ctx:part("VerandaFloor", V(49, 0.4, 7), CF(-47.5, 0.2, -10.5), STONE, CONC)
		ctx:part("VerandaCanopy", V(49, 0.5, 7.4), CF(-47.5, 12.5, -10.5), ROOF, PLAS)
		ctx:repeatAlong(6, V(-70, 0, -7.5), V(9, 0, 0), function(_, p)
			ctx:part("VerandaPost", V(0.5, 12, 0.5), CF(p.X, 6.4, p.Z), TRIM, CONC)
		end)
	end

	local function buildDome(ctx)
		local cx, cz = -47, -34
		ctx:part("DrumBlock", V(14, 16, 14), CF(cx, 32, cz), WALL, CONC)
		ctx:part("DrumCornice", V(15.4, 1, 15.4), CF(cx, 40.5, cz), TRIM, CONC)
		for _, f in ipairs({ { 7, 0, PI / 2 }, { -7, 0, -PI / 2 }, { 0, 7, 0 }, { 0, -7, PI } }) do
			arched(ctx, "DrumWin", V(cx + f[1], 30, cz + f[2]), f[3], 3, 7)
		end
		ctx:dome("Dome", 7.2, 8, CF(cx, 41, cz), DOME, RIB, PLAS)
		post(ctx, "Lantern", 3, 5, cx, 48, cz, TRIM, CONC)
		ctx:ball("LanternCap", 3.4, CF(cx, 53.5, cz), DOME, PLAS)
		ctx:part("DomeCrossStem", V(0.5, 4, 0.5), CF(cx, 56, cz), TRIM, CONC)
		ctx:part("DomeCrossArm", V(2, 0.5, 0.5), CF(cx, 56.5, cz), TRIM, CONC)
	end

	------------------------------------------------------------------ Grounds: forecourt, low walls, hedges, shrubs
	local function buildGrounds(ctx)
		ctx:part("ForecourtPaving", V(100, 0.1, 86), CF(0, 0.05, 45), PAVE, CONC) -- inside the repainted terrain region
		ctx:cyl("ForecourtMedallion", V(0.15, 10, 10), CF(0, 0.17, 50) * ANG(0, 0, PI / 2), STONE_LIGHT, CONC)
		for _, sx in ipairs({ -38, 38 }) do
			ctx:part("LowWallBase", V(26, 1, 1.4), CF(sx, 0.5, 12), MAROON, CONC)
			ctx:part("LowWall", V(26, 2.4, 1.2), CF(sx, 2.2, 12), WALL, CONC)
			ctx:part("LowWallCap", V(26.4, 0.4, 1.6), CF(sx, 3.6, 12), TRIM, CONC)
			ctx:part("FrontHedge", V(26, 2.5, 2), CF(sx, 1.25, 9.6), HEDGE, LEAF)
		end
		for _, x in ipairs({ -24, -30, -36, -42, 24, 30, 36, 42 }) do
			shrub(ctx, x, 0.1, 6.5)
		end
	end

	------------------------------------------------------------------ Garden: west topiary court, east prayer garden
	local function buildGarden(ctx)
		-- West court: hedge and a row of cone topiaries beside the portico.
		ctx:part("CourtHedge", V(26, 2.5, 2), CF(-37, 1.35, -3), HEDGE, LEAF)
		for i = 0, 5 do
			local x = -48 + 3.6 * i
			ctx:ball("Topiary", 3.4, CF(x, 2.1, 1), HEDGE, LEAF)
			ctx:ball("TopiaryTop", 2.2, CF(x, 4, 1), HEDGE, LEAF)
		end
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

	------------------------------------------------------------------ Required props
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
		component("EastWing", "Structure", buildEastWing)
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
