-- site06: The Outlets at LIMA Estate + Aboitiz Pitch (Slice 05). Studio copy: ServerStorage.Builders.site06; run with
--   require(game.ServerStorage.Builders.site06:Clone())()
-- Run builders/placeholders first (it creates Workspace.Sites.Site06_Outlets with Guide, InfoPanel, JeepStop...).
-- IDEMPOTENT: replaces Block / Structure / Grounds / ShopStreet / SportsField / EstateModelPedestal / LipaMalvarPanel and keeps
-- Guide, InfoPanel, JeepStop, JeepSign*, Jeepney. Touches nothing outside Workspace.Sites.Site06_Outlets. No terrain change:
-- every paved or turf surface is a part at least 0.4 thick.
-- Brief: briefs/site06.md. FRAMES: the site pivot is yawed to SW, so it is NOT used as the origin.
--   ORIGIN = CFrame.new(pivot position): world-aligned, +X east, +Z south (grounds, parking, pitch, stand).
--   SH     = ORIGIN * fromMatrix((-10,0,-50), SE, up, SW): the shop frame, local +Z = SW = the frontage, local +X = SE.
--   A SurfaceGui on the frontage side of a part in SH (or SIGN) is on the part's local +Z face = Enum.NormalId.Back.
-- Keep clear: the Guide, JeepStop pad and Jeepney sit at shop-frame z about 58; the forecourt slab ends at z 42 and a 6-stud
-- path joins it to the pad. Nothing is stacked under the kept objects.
-- Fail-safe order as in site01/site05: everything is built into unparented components first (budget included); only then are
-- the old children deleted and the components parented one at a time. An error before that point destroys the partial build
-- and leaves the placeholder Block untouched. The model, its WorldPivot and PrimaryPart are never touched.
return function()
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(6)
	assert(row and row.facing == "SW", "site06: SiteData row 6 is missing or not facing SW")
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site06_Outlets")
	assert(site, "site06: Workspace.Sites.Site06_Outlets not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()
	local ORIGIN = CF(pivotBefore.Position)

	local R = math.sqrt(0.5)
	local SE, SW = V(R, 0, R), V(-R, 0, R)
	local UP = V(0, 1, 0)
	local SH_L = CFrame.fromMatrix(V(-10, 0, -50), SE, UP, SW) -- shop frame, relative to the site centre
	local SH = ORIGIN * SH_L
	local SIGN = CFrame.fromMatrix(V(-82, 0, 50), SE, UP, SW) -- entrance sign frame, relative to the site centre

	local PART_BUDGET = 2500
	local REPLACED = {
		Block = true, Structure = true, Grounds = true, ShopStreet = true, SportsField = true,
		EstateModelPedestal = true, LipaMalvarPanel = true,
	}

	-- Colours (Outlets_Corner_Storefront.jpg, Outlets_Storefront_Front.jpg, Outlets_Facade_and_Covered_Walkway.jpg,
	-- Outlets_Entrance_Sign.jpg, Aboitiz_Pitch_Stand_From_Above.jpg).
	local ORANGE = Color3.fromRGB(200, 100, 55)
	local ORANGE2 = Color3.fromRGB(190, 93, 50)
	local SOFFIT = Color3.fromRGB(176, 86, 46)
	local WHITE = Color3.fromRGB(236, 234, 228)
	local GREY = Color3.fromRGB(214, 212, 206)
	local BROWN = Color3.fromRGB(90, 50, 40)
	local DARK = Color3.fromRGB(28, 30, 36)
	local BLACK = Color3.fromRGB(18, 18, 22)
	local GLASSC = Color3.fromRGB(60, 76, 88)
	local STEEL = Color3.fromRGB(120, 124, 130)
	local TURF = Color3.fromRGB(50, 130, 60)
	local TURF2 = Color3.fromRGB(58, 142, 68)
	local LINE_W = Color3.fromRGB(240, 240, 236)
	local LINE_O = Color3.fromRGB(210, 110, 40)
	local CONCRETE = Color3.fromRGB(190, 188, 182)
	local CONCRETE_LIGHT = Color3.fromRGB(214, 212, 206)
	local BRICK = Color3.fromRGB(74, 72, 76)
	local ASPHALT = Color3.fromRGB(88, 88, 94)
	local SOLAR = Color3.fromRGB(28, 44, 92)
	local LEAF = Color3.fromRGB(58, 120, 58)
	local TRUNK = Color3.fromRGB(104, 84, 64)
	local HEDGE = Color3.fromRGB(52, 110, 56)
	local YELLOW = Color3.fromRGB(240, 200, 40)
	local BULB = Color3.fromRGB(255, 214, 140)
	local CONC, PLAS = Enum.Material.Concrete, Enum.Material.SmoothPlastic
	local METAL, GLASS = Enum.Material.Metal, Enum.Material.Glass
	local NEON, LEAFM, WOOD = Enum.Material.Neon, Enum.Material.Grass, Enum.Material.Wood

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

	local function component(name, parent, origin, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, origin, { budget = PART_BUDGET - used })
		fn(ctx, model)
		ctx:flush()
		used += ctx:count()
		table.insert(built, { name = name, parent = parent, model = model, parts = ctx:count() })
	end

	-- A glazing panel: glass material, see-through over the dark core.
	local function glass(ctx, name, size, cf)
		local p = ctx:part(name, size, cf, GLASSC, GLASS)
		p.Transparency = 0.3
		p.Reflectance = 0.05
		return p
	end

	-- A net panel (fences, goals): thin and see-through.
	local function net(ctx, name, size, cf, color)
		local p = ctx:part(name, size, cf, color or STEEL, PLAS)
		p.Transparency = 0.6
		return p
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

	-- One coloured RichText label filling a face (the entrance sign).
	local function richGui(part, face, richText, ppstud)
		local g = Instance.new("SurfaceGui")
		g.Face = face
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud or 30
		g.Parent = part
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.RichText = true
		t.TextScaled = true
		t.Font = Enum.Font.GothamBlack
		t.TextColor3 = Color3.new(0, 0, 0)
		t.Text = richText
		t.Parent = g
	end

	-- A slim tree in a planter (4 parts): thin trunk, flat two-tier crown (Outlets_Storefront_Front.jpg).
	local function tree(ctx, x, z)
		ctx:part("TreePlanter", V(3.2, 1, 3.2), CF(x, 0.9, z), CONCRETE_LIGHT, CONC)
		post(ctx, "TreeTrunk", 0.7, 9, x, 1.4, z, TRUNK, WOOD)
		ctx:cyl("TreeCrown", V(2.2, 8.5, 8.5), CF(x, 10.2, z) * ANG(0, 0, PI / 2), LEAF, LEAFM)
		ctx:cyl("TreeCrownTop", V(1.8, 5.5, 5.5), CF(x, 12, z) * ANG(0, 0, PI / 2), LEAF, LEAFM)
	end

	-- A bench facing -Z (north in the shop frame): seat, backrest, two legs (4 parts). Sits on the forecourt slab (top 0.4).
	local function bench(ctx, x, z)
		ctx:part("BenchSeat", V(5, 0.4, 1.6), CF(x, 2.4, z), BROWN, WOOD)
		ctx:part("BenchBack", V(5, 1.4, 0.3), CF(x, 3.3, z + 0.75), BROWN, WOOD)
		for _, dx in ipairs({ -2, 2 }) do
			ctx:part("BenchLeg", V(0.4, 2, 1.4), CF(x + dx, 1.4, z), STEEL, METAL)
		end
	end

	-- A palm (9 parts): trunk, crown ball, seven drooping fronds. World-aligned frame.
	local function palm(ctx, x, z)
		post(ctx, "PalmTrunk", 1.4, 15, x, 0, z, TRUNK, WOOD)
		ctx:ball("PalmCrown", 2.2, CF(x, 15.4, z), LEAF, LEAFM)
		for k = 0, 6 do
			local th = k * 2 * PI / 7
			ctx:part("PalmFrond", V(7, 0.25, 1.6), CF(x, 15.2, z) * ANG(0, th, 0) * CF(3.4, 0, 0) * ANG(0, 0, -0.35), LEAF, LEAFM)
		end
	end

	-- A parked car (3 parts): dark underbody (reads as wheels), coloured body, glass cabin. Long axis along Z.
	local function car(ctx, x, z, color)
		ctx:part("CarUnder", V(3.6, 0.8, 7.6), CF(x, 0.8, z), BLACK, PLAS)
		ctx:part("CarBody", V(4.2, 1.5, 8.4), CF(x, 1.95, z), color, PLAS)
		local cab = ctx:part("CarCabin", V(3.6, 1.3, 4.4), CF(x, 3.35, z - 0.3), GLASSC, GLASS)
		cab.Transparency = 0.2
	end

	------------------------------------------------------------------ Shop block: the corner "Park Outlet" unit (SH frame)
	-- The frame is 76 wide (x +-38), 34 tall, 34 deep (z +-17); the top band overhangs 4 studs in front of the end legs.
	local function buildShop(ctx)
		ctx:part("ShopBody", V(68, 24, 26), CF(0, 12, -1), DARK, CONC)
		-- Two storeys of glazing between the left leg (x -38..-29) and the black panel (x 17..31).
		for i = 0, 4 do
			local x = -29 + 9.2 * i + 4.6
			glass(ctx, "GlassGround", V(8.6, 11, 0.4), CF(x, 6, 12.6))
			glass(ctx, "GlassUpper", V(8.6, 10, 0.4), CF(x, 18.5, 12.6))
		end
		for i = 0, 5 do
			local x = -29 + 9.2 * i
			ctx:part("MullionGround", V(0.7, 12, 0.9), CF(x, 6, 12.7), STEEL, METAL)
			ctx:part("MullionUpper", V(0.7, 11, 0.9), CF(x, 18.5, 12.7), STEEL, METAL)
		end
		-- Orange timber-look frame: planked end legs and a planked, overhanging top band.
		local function plank(i) return (i % 2 == 0) and ORANGE or ORANGE2 end
		for i = 0, 2 do
			ctx:part("LegLeft", V(3, 34, 34), CF(-36.5 + 3 * i, 17, 0), plank(i), PLAS)
		end
		for i = 0, 1 do
			ctx:part("LegRight", V(3.5, 34, 34), CF(32.75 + 3.5 * i, 17, 0), plank(i), PLAS)
		end
		for i = 1, 20 do
			ctx:part("BandPlank", V(3.8, 10, 38), CF(-38 + 3.8 * (i - 0.5), 29, 2), plank(i), PLAS)
		end
		-- Soffit under the overhang with two rows of downlights.
		ctx:part("Soffit", V(60, 0.3, 9), CF(0, 23.85, 16.5), SOFFIT, PLAS)
		for _, z in ipairs({ 14, 19 }) do
			ctx:repeatAlong(4, V(-24, 23.6, z), V(16, 0, 0), function(_, p)
				ctx:part("Downlight", V(1.2, 0.15, 1.2), CF(p), BULB, NEON)
			end)
		end
		-- Black side panel with the shop name.
		ctx:part("NamePanel", V(14, 23, 0.6), CF(24, 11.5, 12.6), BLACK, PLAS)
		-- The lettering sits on its own plate on the lower storey, clear of the canopy at y 12.6.
		local plate = ctx:part("NameText", V(12, 5, 0.2), CF(24, 7.5, 13.0), BLACK, PLAS)
		gui(plate, Enum.NormalId.Back, "PARK OUTLET", nil, Color3.new(1, 1, 1), 30)
		-- Brown cantilevered canopy between the floors, on angled steel struts.
		ctx:part("ShopCanopy", V(80, 0.7, 12), CF(0, 12.6, 17.5), BROWN, PLAS)
		ctx:repeatAlong(8, V(-35, 10.5, 15.55), V(10, 0, 0), function(_, p)
			ctx:part("CanopyStrut", V(0.4, 0.4, 6.9), CF(p) * ANG(-0.55, 0, 0), STEEL, METAL)
		end)
	end

	------------------------------------------------------------------ White neighbour: its own roofline, orange tower (SH frame)
	local function buildWing(ctx)
		ctx:part("WingBody", V(40, 22, 24), CF(66, 11, 2), WHITE, CONC)
		ctx:part("WingParapet", V(40.8, 0.8, 24.8), CF(66, 22.4, 2), GREY, CONC)
		-- Tall orange accent panel at the SE end, standing 4 studs above the roof.
		for i = 0, 2 do
			ctx:part("AccentPlank", V(3.5, 26, 1.6), CF(77.5 + 3.5 * i, 13, 14.8), (i % 2 == 0) and ORANGE or ORANGE2, PLAS)
		end
		for i = 0, 2 do
			local x = 51 + 9.8 * i
			glass(ctx, "WingGlassGround", V(9.2, 10, 0.4), CF(x, 5.6, 14.2))
			glass(ctx, "WingGlassUpper", V(9.2, 5, 0.3), CF(x, 17.2, 14.1))
		end
		for i = 0, 3 do
			ctx:part("WingMullion", V(0.6, 11, 0.7), CF(46.2 + 9.8 * i, 5.6, 14.3), STEEL, METAL)
		end
		-- Rooftop solar array (4 x 3), slightly tilted.
		for i = 0, 3 do
			for j = 0, 2 do
				ctx:part("SolarPanel", V(7.5, 0.3, 5), CF(51 + 9.5 * i, 23.4, -5 + 6 * j) * ANG(0.18, 0, 0), SOLAR, PLAS)
			end
		end
	end

	------------------------------------------------------------------ Covered walkway continuing the canopy (SH frame)
	local function buildWalkway(ctx)
		ctx:part("WalkwayRoof", V(46, 0.7, 14), CF(63, 12.4, 19) * ANG(0.07, 0, 0), BROWN, PLAS)
		ctx:part("WalkwayFascia", V(46, 1, 0.4), CF(63, 11.6, 26), WHITE, PLAS)
		for _, x in ipairs({ 46, 58, 70, 83 }) do
			post(ctx, "WalkwayPost", 0.7, 11.4, x, 0, 25.4, STEEL, METAL)
		end
	end

	------------------------------------------------------------------ Aboitiz Pitch stand: three angled segments, south of the pitch (ORIGIN frame)
	local function buildStand(ctx)
		local cxs = { 101.5, 121, 140.5 }
		local yaws = { 0.12, 0, -0.12 }
		local dzs = { -1.2, 0, -1.2 }
		for k = 1, 3 do
			local seg = CF(cxs[k], 0, 18.5 + dzs[k]) * ANG(0, yaws[k], 0)
			for i = 0, 4 do
				local h = 1.4 * (i + 1)
				local name = (k == 2 and i == 0) and "StandTiers" or "StandTier"
				ctx:part(name, V(19, h, 5), seg * CF(0, h / 2, 8.5 + 5 * i - 18.5), CONCRETE, CONC)
			end
			ctx:part("StandBackWall", V(19, 13, 0.8), seg * CF(0, 6.5, 12.9), WHITE, CONC)
			ctx:part("StandCanopy", V(19.4, 0.6, 15), seg * CF(0, 13.6, 5.5), BROWN, PLAS)
			for _, sx in ipairs({ -9, 9 }) do
				ctx:cyl("StandPost", V(13.3, 0.8, 0.8), seg * CF(sx, 6.65, -1.5) * ANG(0, 0, PI / 2), STEEL, METAL)
			end
			for _, sx in ipairs({ -4.8, 4.8 }) do
				for _, sz in ipairs({ 2, 9.3 }) do
					ctx:part("StandSolar", V(9, 0.25, 6.5), seg * CF(sx, 14.05, sz), SOLAR, PLAS)
				end
			end
		end
		-- Central stair up the middle segment.
		local mid = CF(cxs[2], 0, 18.5)
		for i = 0, 4 do
			local h = 1.4 * (i + 1) + 0.1
			ctx:part("StandStair", V(2.6, h, 5), mid * CF(0, h / 2, 8.5 + 5 * i - 18.5), CONCRETE_LIGHT, CONC)
		end
	end

	------------------------------------------------------------------ Sports field: the Aboitiz Pitch (ORIGIN frame)
	local function buildPitch(ctx)
		local cx, w, l = 121, 62, 96
		local north, south = -96, 0
		ctx:part("PitchTurf", V(w, 0.5, l), CF(cx, 0.25, (north + south) / 2), TURF, PLAS)
		for k = 0, 3 do -- mown stripes: every other 12-stud band
			ctx:part("PitchStripe", V(w, 0.05, 12), CF(cx, 0.525, south - 6 - 24 * k), TURF2, PLAS)
		end
		local function line(x, z, sx, sz, color)
			return ctx:part("PitchLine", V(sx, 0.05, sz), CF(x, 0.575, z), color or LINE_W, PLAS)
		end
		-- Boundary, halfway line and centre circle (12 straight segments).
		line(cx, north + 1.5, w - 3, 0.35)
		line(cx, south - 1.5, w - 3, 0.35)
		line(cx - (w - 3) / 2, (north + south) / 2, 0.35, l - 3)
		line(cx + (w - 3) / 2, (north + south) / 2, 0.35, l - 3)
		line(cx, (north + south) / 2, w - 3, 0.35)
		for k = 0, 11 do
			local th = k * PI / 6
			ctx:part("PitchCircle", V(4.3, 0.05, 0.35), CF(cx + 8 * math.cos(th), 0.575, -48 + 8 * math.sin(th)) * ANG(0, -th + PI / 2, 0), LINE_W, PLAS)
		end
		-- Penalty and goal areas at both ends (dir = +1 runs south from the north goal line, -1 north from the south one).
		local function penalty(z0, dir)
			line(cx, z0 + dir * 14, 30, 0.35)
			line(cx - 15, z0 + dir * 7, 0.35, 14)
			line(cx + 15, z0 + dir * 7, 0.35, 14)
			line(cx, z0 + dir * 5, 14, 0.35)
			line(cx - 7, z0 + dir * 2.5, 0.35, 5)
			line(cx + 7, z0 + dir * 2.5, 0.35, 5)
		end
		penalty(north + 1.5, 1)
		penalty(south - 1.5, -1)
		-- Orange small-sided pitch markings in the southern half (Aboitiz_Pitch_Stand_From_Above.jpg).
		line(cx, -34, 42, 0.35, LINE_O)
		line(cx, -8, 42, 0.35, LINE_O)
		line(cx - 21, -21, 0.35, 26, LINE_O)
		line(cx + 21, -21, 0.35, 26, LINE_O)
		-- Two full-size goals with nets (dir = +1 when the pitch lies to the south of the goal line).
		local function goal(z, dir)
			local gw, gh, gd = 18, 6, 4
			for _, sx in ipairs({ -1, 1 }) do
				ctx:part("GoalPost", V(0.5, gh, 0.5), CF(cx + sx * gw / 2, 0.5 + gh / 2, z), WHITE, METAL)
				net(ctx, "GoalSideNet", V(0.1, gh, gd), CF(cx + sx * gw / 2, 0.5 + gh / 2, z - dir * gd / 2), WHITE)
			end
			ctx:part("GoalBar", V(gw + 0.5, 0.5, 0.5), CF(cx, 0.5 + gh, z), WHITE, METAL)
			net(ctx, "GoalBackNet", V(gw, gh, 0.1), CF(cx, 0.5 + gh / 2, z - dir * gd), WHITE)
			net(ctx, "GoalTopNet", V(gw, 0.1, gd), CF(cx, 0.5 + gh, z - dir * gd / 2), WHITE)
		end
		goal(north + 1.5, 1)
		goal(south - 1.5, -1)
		-- Five small training goals lined up along the stand side, each turned a little.
		for i, x in ipairs({ 100, 109, 118, 129, 139 }) do
			local base = CF(x, 0, -5) * ANG(0, ({ 0.5, -0.3, 0.2, -0.5, 0.3 })[i], 0)
			for _, sx in ipairs({ -3.5, 3.5 }) do
				ctx:part("TrainGoalPost", V(0.35, 3.4, 0.35), base * CF(sx, 0.5 + 1.7, 0), WHITE, METAL)
			end
			ctx:part("TrainGoalBar", V(7.3, 0.35, 0.35), base * CF(0, 0.5 + 3.4, 0), WHITE, METAL)
			net(ctx, "TrainGoalNet", V(7, 3.4, 0.1), base * CF(0, 0.5 + 1.7, -1.8), WHITE)
		end
		-- Perimeter fence (east, north, west; the stand closes the south side) and its posts.
		local fh = 8
		net(ctx, "FenceEast", V(0.15, fh, 102), CF(154, fh / 2, -48), STEEL)
		net(ctx, "FenceWest", V(0.15, fh, 102), CF(88, fh / 2, -48), STEEL)
		net(ctx, "FenceNorth", V(w + 4, fh, 0.15), CF(cx, fh / 2, -99), STEEL)
		for i = 0, 8 do
			local z = -96 + 12 * i
			post(ctx, "FencePost", 0.5, fh, 154, 0, z, STEEL, METAL)
			post(ctx, "FencePost", 0.5, fh, 88, 0, z, STEEL, METAL)
		end
		for i = 0, 5 do
			post(ctx, "FencePost", 0.5, fh, 92 + 12 * i, 0, -99, STEEL, METAL)
		end
		-- Four floodlight masts at the corners.
		for _, p in ipairs({ { 86, -98 }, { 156, -98 }, { 156, 2 }, { 86, 2 } }) do
			post(ctx, "FloodMast", 1, 28, p[1], 0, p[2], STEEL, METAL)
			ctx:part("FloodHead", V(6, 3, 1), CF(p[1], 28.5, p[2]) * ANG(0.3, 0, 0), BLACK, PLAS)
		end
	end

	------------------------------------------------------------------ Shop street: forecourt, trees, string lights, pylon (SH frame)
	local function buildStreet(ctx)
		ctx:part("ForecourtSlab", V(140, 0.4, 24), CF(20, 0.2, 30), BRICK, CONC)
		ctx:part("ConnectPath", V(6, 0.3, 9), CF(22.4, 0.15, 46.5), CONCRETE_LIGHT, CONC) -- z 42..51: stops at the pad's near corner (51.4)
		for _, x in ipairs({ 6, 56, 84 }) do
			tree(ctx, x, 40)
		end
		for _, x in ipairs({ -36, -24, -12, 0, 12 }) do
			post(ctx, "Bollard", 0.9, 3.6, x, 0.4, 26.5, YELLOW, PLAS)
		end
		for _, x in ipairs({ -24, 24, 48, 72 }) do
			bench(ctx, x, 37)
		end
		-- String lights: three poles and two sagging spans with warm bulbs.
		local poles = { -44, -18, 28 }
		for _, x in ipairs(poles) do
			post(ctx, "LightPole", 0.6, 14.1, x, 0.4, 25, STEEL, METAL)
		end
		for s = 1, 2 do
			local x0, x1 = poles[s], poles[s + 1]
			local xm = (x0 + x1) / 2
			local top, low = V(x0, 14.5, 25), V(xm, 13.1, 25)
			local top2 = V(x1, 14.5, 25)
			for _, seg in ipairs({ { top, low }, { low, top2 } }) do
				local a, b = seg[1], seg[2]
				ctx:part("LightWire", V(0.12, 0.12, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), BLACK, PLAS)
			end
			local n = (s == 1) and 5 or 8
			for i = 1, n do
				local t = i / (n + 1)
				local y = 14.5 - 1.4 * (1 - math.abs(2 * t - 1))
				ctx:ball("Bulb", 0.6, CF(x0 + (x1 - x0) * t, y - 0.45, 25), BULB, NEON)
			end
		end
		-- Wayfinding pylon with text rows (text only).
		ctx:part("PylonBody", V(3.2, 11, 1.2), CF(40, 5.9, 28), STEEL, METAL)
		for i, text in ipairs({ "SHOPS", "ABOITIZ PITCH", "PARKING", "RESTROOM" }) do
			local bar = ctx:part("PylonSign", V(2.9, 1.5, 0.2), CF(40, 9.4 - 1.9 * (i - 1), 28.7), WHITE, PLAS)
			gui(bar, Enum.NormalId.Back, text, nil, Color3.fromRGB(30, 36, 48), 40)
		end
	end

	------------------------------------------------------------------ Grounds: entrance sign, entry path, car park, palms, hedges
	local function buildGrounds(ctx)
		-- Entrance sign (SIGN frame, faces SW toward the road mouth): paved apron with painted stripes, plinth, slatted frame,
		-- coloured lettering on a silver back panel seen through the slats (Outlets_Entrance_Sign.jpg).
		ctx:part("SignApron", V(38, 0.4, 20), SIGN * CF(0, 0.2, 12), CONCRETE_LIGHT, CONC)
		for i = 0, 8 do
			ctx:part("SignStripe", V(1.3, 0.05, 14), SIGN * CF(-16 + 4 * i, 0.43, 12) * ANG(0, 0.35, 0), BLACK, PLAS)
		end
		ctx:part("SignPlinth", V(36, 1.2, 4.4), SIGN * CF(0, 0.6, 0), WHITE, CONC)
		local back = ctx:part("EntranceSign", V(34, 13, 0.5), SIGN * CF(0, 7.7, -0.6), Color3.fromRGB(205, 206, 208), PLAS)
		richGui(back, Enum.NormalId.Back,
			'<font color="#D8231F">%</font> <font color="#2B2E3A">THE</font> <font color="#0A4FC4">O</font>'
				.. '<font color="#2FA83A">U</font><font color="#0A4FC4">T</font><font color="#E0502A">L</font>'
				.. '<font color="#B1182B">E</font><font color="#E5A21E">T</font><font color="#4B1B5A">S</font>', 24)
		for i = 0, 14 do
			ctx:part("SignSlat", V(0.8, 14, 1.6), SIGN * CF(-16.8 + 2.4 * i, 8.2, 1.0), WHITE, CONC)
		end
		ctx:part("SignCap", V(36, 1, 4.4), SIGN * CF(0, 15.7, 0), WHITE, CONC)

		-- Entry path from the road mouth (-120, +100), with a spur east toward the Guide (it stops 21 studs short of her).
		ctx:part("EntryPath", V(12, 0.4, 76), CF(-120, 0.2, 62), CONCRETE_LIGHT, CONC)
		ctx:part("EntrySpur", V(86, 0.4, 10), CF(-83, 0.2, 25), CONCRETE_LIGHT, CONC)

		-- Car park south of the shops: slab, bay lines, a few cars, light poles.
		ctx:part("CarParkSlab", V(118, 0.4, 46), CF(-1, 0.2, 75), ASPHALT, CONC)
		for _, zc in ipairs({ 62, 88 }) do
			ctx:repeatAlong(13, V(-54, 0.43, zc), V(9, 0, 0), function(_, p)
				ctx:part("BayLine", V(0.3, 0.05, 12), CF(p), LINE_W, PLAS)
			end)
		end
		car(ctx, -36, 62, WHITE)
		car(ctx, -9, 62, Color3.fromRGB(170, 40, 40))
		car(ctx, -27, 88, Color3.fromRGB(150, 154, 160))
		car(ctx, 18, 88, Color3.fromRGB(30, 50, 110))
		car(ctx, 45, 88, Color3.fromRGB(60, 62, 68))
		for _, x in ipairs({ -40, -10, 20, 50 }) do
			post(ctx, "CarParkPole", 0.8, 16, x, 0.4, 75, STEEL, METAL)
			ctx:part("CarParkLamp", V(4, 0.6, 1.2), CF(x, 16.6, 75), BULB, NEON)
		end

		-- Palm rows along the entry path and the car park's west edge.
		for _, p in ipairs({ { -132, 34 }, { -132, 50 }, { -132, 66 }, { -132, 82 }, { -132, 96 }, { -66, 56 }, { -66, 76 }, { -66, 96 } }) do
			palm(ctx, p[1], p[2])
		end
		-- Low hedges along the car park's north edge and the spur.
		for i = 0, 4 do
			ctx:part("Hedge", V(20, 1.8, 1.6), CF(-52 + 22 * i, 0.9, 50), HEDGE, LEAFM)
		end
		for i = 0, 2 do
			ctx:part("Hedge", V(20, 1.8, 1.6), CF(-110 + 24 * i, 0.9, 32), HEDGE, LEAFM)
		end
	end

	------------------------------------------------------------------ Required props: estate model pedestal and the Lipa/Malvar panel (SH frame)
	local function buildPedestal(ctx)
		local x, z = -12, 31
		local plinth = ctx:part("Plinth", V(8, 3.5, 8), CF(x, 2.15, z), WHITE, CONC)
		gui(plinth, Enum.NormalId.Back, "LIMA ESTATE MODEL", "A small model of the estate. LIMA Estate spans Lipa and Malvar.", Color3.fromRGB(30, 36, 48), 40)
		ctx:part("ModelBase", V(7.4, 0.3, 7.4), CF(x, 4.05, z), DARK, PLAS)
		ctx:part("ModelPitch", V(2.6, 0.15, 4.2), CF(x + 1.9, 4.28, z - 0.8), TURF, PLAS)
		ctx:part("ModelShop", V(2.4, 1.6, 2), CF(x - 2, 5, z - 2), ORANGE, PLAS)
		ctx:part("ModelWing", V(2.8, 1.1, 1.8), CF(x - 0.8, 4.7, z + 0.2), WHITE, PLAS)
		ctx:part("ModelStand", V(2.6, 0.45, 0.8), CF(x + 1.9, 4.4, z + 2), CONCRETE, PLAS)
		local case = ctx:part("ModelCase", V(7.4, 3, 7.4), CF(x, 5.65, z), GLASSC, GLASS)
		case.Transparency = 0.75
	end

	local function buildPanel(ctx)
		local cx, z = -40, 31
		for _, dx in ipairs({ -9.5, 9.5 }) do
			ctx:part("PanelPost", V(0.6, 13.6, 0.6), CF(cx + dx, 6.8, z - 0.5), STEEL, METAL)
		end
		local title = ctx:part("PanelTitle", V(22, 2.4, 0.5), CF(cx, 12.4, z), Color3.fromRGB(30, 36, 48), PLAS)
		gui(title, Enum.NormalId.Back, "LIMA ESTATE SPANS LIPA AND MALVAR", nil, Color3.new(1, 1, 1), 40)
		local left = ctx:part("PanelLipa", V(10.75, 6, 0.5), CF(cx - 5.625, 8.2, z), Color3.fromRGB(30, 70, 140), PLAS)
		gui(left, Enum.NormalId.Back, "LIPA CITY", nil, Color3.new(1, 1, 1), 40)
		local right = ctx:part("PanelMalvar", V(10.75, 6, 0.5), CF(cx + 5.625, 8.2, z), Color3.fromRGB(40, 120, 70), PLAS)
		gui(right, Enum.NormalId.Back, "MALVAR", nil, Color3.new(1, 1, 1), 40)
		ctx:part("PanelDivider", V(0.5, 6, 0.7), CF(cx, 8.2, z), WHITE, PLAS)
		local foot = ctx:part("PanelFooter", V(22, 2, 0.5), CF(cx, 4.2, z), Color3.fromRGB(30, 36, 48), PLAS)
		gui(foot, Enum.NormalId.Back, "Schematic map, not to scale. The estate spans Lipa and Malvar.", nil, Color3.new(1, 1, 1), 40)
	end

	------------------------------------------------------------------ Build, then swap
	local ok, err = pcall(function()
		component("ShopBlock", "Structure", SH, buildShop)
		component("WhiteWing", "Structure", SH, buildWing)
		component("Walkway", "Structure", SH, buildWalkway)
		component("Stand", "Structure", ORIGIN, buildStand)
		component("SportsField", "Site", ORIGIN, buildPitch)
		component("ShopStreet", "Site", SH, buildStreet)
		component("Grounds", "Site", ORIGIN, buildGrounds)
		component("EstateModelPedestal", "Site", SH, buildPedestal)
		component("LipaMalvarPanel", "Site", SH, buildPanel)
		assert(used <= PART_BUDGET, string.format("site06: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, b in ipairs(built) do b.model:Destroy() end
		error("site06: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
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
		"site06: the site pivot changed during the build")

	local perComponent = {}
	for _, b in ipairs(built) do perComponent[b.name] = b.parts end
	return {
		parts = countParts(site),
		keptParts = keptParts,
		builtParts = used - keptParts,
		components = perComponent,
	}
end
