-- site01: Metropolitan Cathedral of San Sebastian + Plaza Independencia (Slice 02; reworked in Slice 14 from 2023-2025 photos
-- and OSM footprints, see briefs/site01.md). The reference builder the other site builders copy. Studio copy:
-- ServerStorage.Builders.site01; run with
--   require(game.ServerStorage.Builders.site01:Clone())()
-- Run builders/placeholders first (it creates Workspace.Sites.Site01_Cathedral with Guide, InfoPanel, JeepStop...).
-- IDEMPOTENT: replaces Block / Structure / Plaza / PlazaBuildings / PlazaPeople / ParkedVehicles / WelcomeArch / Benches /
-- Lamps / Flagpole / EventStage and keeps Guide, InfoPanel, JeepStop, JeepSign*, Jeepney. Touches nothing outside
-- Workspace.Sites.Site01_Cathedral.
-- The terrain under the plaza is repainted as Pavement by builders/world.luau, which owns terrain. Flat ground parts here
-- must stay inside that region: x -100..100, z 0..100 (tests/site01_check.luau enforces it). The rework needed no terrain write:
-- the church, wing, forecourt and garden stand on a podium RAISE (5) studs above the ground (P1: the forecourt is higher than
-- Plaza Independencia); the retaining wall at z 48 drops to the lower plaza through two flights of 1-stud risers either side of a
-- fountain and statue (ground photo, pass 4: terracotta paving, round pergola garden, vaulted covered court, shade tree, kiosks).
-- Brief: briefs/site01.md. Period: the Dec 2025 scheme (cream-white domes) over the 2023-24 ground photos (butter walls).
-- World axes: x east, z south (+Z is the facade side), y up; the site pivot is at the origin, and everything is placed in
-- world coordinates. massScale 2.0 (2 studs per metre): the church is at true proportions across the front (facade 42,
-- tower 26, transept 88) and its length is compressed by dropping nave bays (real ~85 m, shown ~50 m) to fit z -100..+10.
-- Fail-safe order: everything is built into unparented components first (budget and CSG included); only then are
-- the old children deleted and the components parented one at a time (each < 400 parts). An error before that
-- point destroys the partial build and leaves the placeholder Block untouched.
-- The model object, its WorldPivot and its PrimaryPart are never touched (the pivot is asserted unchanged).
return function()
	local Players = game:GetService("Players")
	local TextService = game:GetService("TextService")
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())

	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local row = SiteData.byId(1)
	local sites = workspace:FindFirstChild("Sites")
	local site = sites and sites:FindFirstChild("Site01_Cathedral")
	assert(site, "site01: Workspace.Sites.Site01_Cathedral not found (run builders/placeholders first)")
	local pivotBefore = site:GetPivot()

	local PART_BUDGET = 2500
	local RAISE = 5 -- the upper level (podium top) above the ground; tests/site01_check.luau pins the same number
	local WALL_Z = 48 -- the retaining wall: the podium's south face
	local UPPER = CF(0, RAISE, 0) -- origin of every component that stands on the podium
	local REPLACED = {
		Block = true, Structure = true, Plaza = true, PlazaBuildings = true, PlazaPeople = true, ParkedVehicles = true,
		WelcomeArch = true, Benches = true, Lamps = true, Flagpole = true, EventStage = true, Podium = true, PlazaLower = true, ParishWing = true, ChurchAnnex = true, WestFence = true, -- ParishWing is gone (B3c-0) but its name stays here so old copies are cleaned
	}

	-- Colours. Walls and trim: Lipa_Cathedral_2024-03-27 / facade_2023-04-05 (butter yellow, mauve-grey). Domes: the
	-- 12-28-2025 drone photos (cream-white). Roofs: saturated red as in the same drone photos.
	local WALL = Color3.fromRGB(232, 200, 120)
	local WALL_PALE = Color3.fromRGB(238, 222, 170)
	local TRIM = Color3.fromRGB(178, 156, 166)
	local ROOF = Color3.fromRGB(196, 52, 46)
	local ROOF_RIB = Color3.fromRGB(214, 76, 64)
	local ROOF_DARK = Color3.fromRGB(112, 56, 48)
	local PAVROOF = Color3.fromRGB(92, 84, 78)
	local BLEACH = Color3.fromRGB(172, 84, 62) -- the plaza drawing: red-brick retaining wall and steps
	local BRICK = Color3.fromRGB(168, 78, 58)
	local CREAM_CC = Color3.fromRGB(240, 228, 190) -- the Lipa Cultural Center
	local STAGE_ROOF = Color3.fromRGB(46, 48, 54) -- the stage pavilion's dark roof
	local STAGE_RIB = Color3.fromRGB(70, 72, 80)
	local HEDGE = Color3.fromRGB(52, 110, 56)
	local LAWN = Color3.fromRGB(88, 142, 72)
	local DOME = Color3.fromRGB(248, 241, 218)
	local RIB = Color3.fromRGB(214, 210, 198)
	local TIMBER = Color3.fromRGB(150, 100, 60)
	local GLASS = Color3.fromRGB(30, 35, 45)
	local PANEL = Color3.fromRGB(120, 140, 160)
	local STONE = Color3.fromRGB(196, 188, 176)
	local STONE_DARK = Color3.fromRGB(168, 158, 146)
	local STONE_LIGHT = Color3.fromRGB(214, 206, 194)
	local WHITE = Color3.fromRGB(236, 236, 232)
	local GREEN = Color3.fromRGB(70, 130, 70)
	local TRUNK = Color3.fromRGB(120, 92, 66)
	local LAMP_METAL = Color3.fromRGB(46, 50, 56)
	local LAMP_GLOW = Color3.fromRGB(255, 232, 170)
	local YELLOW = Color3.fromRGB(240, 200, 40)
	local IRON = Color3.fromRGB(226, 226, 222)
	local SCREEN_BLACK = Color3.fromRGB(20, 22, 26)
	local LOUVRE = Color3.fromRGB(196, 204, 196)
-- Round 2 (plaza drawing): asphalt lot, grey grid pavers, the row of small statues down the middle of the lot.
	local ASPHALT = Color3.fromRGB(62, 64, 70)
	local PAVER = Color3.fromRGB(150, 152, 158)
	local PAVER_JOINT = Color3.fromRGB(118, 120, 126)
	-- B3c-0b (owner's magenta mark): two staggered rows of cars on the asphalt west of the tower, inside x -115..-55, z -42..6 (aisle z -31..-13); n = last car index, x0 = first car x
	local NW_ROWS = { { z = -36, x0 = -112, n = 9, yaw = 0 }, { z = -8, x0 = -109, n = 8, yaw = PI } }
	local STATUES = { { -9, 16 }, { -9, 24 }, { -9, 32 }, { 9, 16 }, { 9, 24 }, { 9, 32 }, { 9, 40 } } -- x, z (clear of the Guide, JeepStop and InfoPanel)
	-- Plaza Independencia from the ground photo: terracotta paving, salmon walls, orange kiosk roofs, a pale vaulted roof.
	local TERRACOTTA = Color3.fromRGB(205, 142, 116)
	local PAVING_CREAM = Color3.fromRGB(226, 200, 170)
	local SALMON = Color3.fromRGB(214, 150, 128)
	local KIOSK_ROOF = Color3.fromRGB(222, 120, 50)
	local VAULT = Color3.fromRGB(236, 230, 210)
	local SOIL = Color3.fromRGB(96, 66, 50)
	local WATER = Color3.fromRGB(96, 156, 196)
	local FLOWERS = { Color3.fromRGB(214, 56, 64), Color3.fromRGB(236, 130, 160), Color3.fromRGB(240, 150, 50), Color3.fromRGB(240, 220, 90) }
	local CONC, PLAS = Enum.Material.Concrete, Enum.Material.SmoothPlastic
	local METAL, WOOD = Enum.Material.Metal, Enum.Material.Wood
	local PLASTER = Enum.Material.Plaster -- matte: SmoothPlastic mirrors the blue sky and turns the white domes lavender
	local ROOFMAT = Enum.Material.Plastic -- Metal renders near-black under Realistic lighting; the photos show flat bright-red steel roofs

	local function countParts(inst)
		local n = inst:IsA("BasePart") and 1 or 0
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then n += 1 end
		end
		return n
	end

	local terrainParams = RaycastParams.new()
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local function groundAt(x, z)
		local r = workspace:Raycast(V(x, 400, z), V(0, -800, 0), terrainParams)
		assert(r, string.format("site01: no terrain at (%.1f, %.1f)", x, z))
		return r.Position.Y
	end

	-- Parts already in the site that survive the rebuild count against the 2,500 budget.
	local used = 0
	for _, c in ipairs(site:GetChildren()) do
		if not REPLACED[c.Name] then used += countParts(c) end
	end
	local keptParts = used

	local built = {} -- { name, parent = "Structure" | "Site", model, parts }
	local archPaths = { csg = 0, fallback = 0 }

	local function component(name, parent, fn, origin)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, origin or CF(), { budget = PART_BUDGET - used })
		fn(ctx)
		ctx:flush()
		used += ctx:count()
		table.insert(built, { name = name, parent = parent, model = model, parts = ctx:count() })
	end

	local function arch(ctx, name, spec)
		local r = ctx:arch(name, spec)
		archPaths[r.path] += 1
		return r
	end

	-- An arched window (glass) with a trim surround, on a wall face. `pos` is the bottom centre on the wall
	-- surface; `yaw` turns the +Z face normal (0 = +Z, PI/2 = +X, PI = -Z, -PI/2 = -X). 4 parts.
	local function arched(ctx, name, pos, yaw, w, h)
		local rot = ANG(0, yaw, 0)
		local normal = rot:VectorToWorldSpace(V(0, 0, 1))
		ctx:window(name .. "_Trim", w + 1.6, h + 0.8, 0.4, CF(pos) * rot, TRIM, CONC)
		ctx:window(name, w, h, 0.4, CF(pos + normal * 0.15) * rot, GLASS)
	end

	-- A vertical cylinder (Roblox cylinders run along local X, so roll them upright).
	local function post(ctx, name, diameter, height, x, baseY, z, color, material)
		return ctx:cyl(name, V(height, diameter, diameter), CF(x, baseY + height / 2, z) * ANG(0, 0, PI / 2), color, material)
	end

	-- A SurfaceGui text label on one face of a part (ASCII only).
	local function label(part, face, text, color, ppS)
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = ppS or 30
		gui.Parent = part
		local l = Instance.new("TextLabel")
		l.Size = UDim2.fromScale(1, 1)
		l.BackgroundTransparency = 1
		l.TextColor3 = color
		-- A fixed TextSize (README rule: never TextScaled for long labels), the largest that fits the face canvas.
		l.TextScaled = false
		l.TextWrapped = true
		l.Font = Enum.Font.GothamBold
		l.Text = text
		local s = part.Size
		local w, h = s.X, s.Y
		if face == Enum.NormalId.Left or face == Enum.NormalId.Right then w = s.Z elseif face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then h = s.Z end
		local cw, ch = w * gui.PixelsPerStud, h * gui.PixelsPerStud
		local size = 8
		for try = 100, 8, -1 do
			local okM, tb = pcall(function() return TextService:GetTextSize(text, try, l.Font, Vector2.new(cw * 0.94, 100000)) end)
			if okM and tb.X <= cw * 0.94 and tb.Y <= ch * 0.9 then size = try break end
		end
		l.TextSize = size
		l.Parent = gui
		return l
	end

	------------------------------------------------------------------ Facade (P3 / P4: three registers, paired round columns)
	local function buildFacade(ctx)
		-- Ground register: wall with the arched door opening, the timber door set back in it, a surround.
		arch(ctx, "FacadeBase", { width = 10, height = 13.5, depth = 10, wallWidth = 42, wallHeight = 20,
			cframe = CF(0, 10, 0), color = WALL, material = CONC })
		ctx:window("Door", 9.2, 11.5, 0.8, CF(0, 2, 4.0), TIMBER, WOOD)
		ctx:part("DoorJambL", V(1, 8.5, 0.5), CF(-5.5, 4.25, 5.25), TRIM, CONC)
		ctx:part("DoorJambR", V(1, 8.5, 0.5), CF(5.5, 4.25, 5.25), TRIM, CONC)
		ctx:part("Keystone", V(2, 1.6, 0.6), CF(0, 15.6, 5.3), TRIM, CONC)
		ctx:part("Plaque", V(8, 1.6, 0.4), CF(0, 17.8, 5.2), PANEL, CONC)
		-- Two steps up to the door (risers of 1 stud).
		ctx:part("StepHigh", V(20, 2, 2.4), CF(0, 1, 6.2), STONE, CONC)
		ctx:part("StepLow", V(22, 1, 2.4), CF(0, 0.5, 8.6), STONE, CONC)
		ctx:part("Cornice1", V(44, 1.8, 13), CF(0, 20.9, 1.5), TRIM, CONC)
		-- Second register: the wall (the anchor the check measures), choir window with a scrolled hood, relief panels.
		ctx:part("FacadeWall", V(42, 17.2, 10), CF(0, 29.4, 0), WALL, CONC)
		arched(ctx, "ChoirWindow", V(0, 23.2, 5), 0, 6, 11)
		ctx:part("ChoirWindowHood", V(10, 1.2, 0.9), CF(0, 34.9, 5.0), TRIM, CONC)
		for _, side in ipairs({ -1, 1 }) do
			ctx:ball("ChoirScroll", 1.8, CF(side * 5.8, 34.2, 5.2), TRIM, CONC)
			ctx:ball("ChoirScrollTip", 1.1, CF(side * 7.4, 35.4, 5.2), TRIM, CONC)
			ctx:part("ReliefFrame", V(4.2, 10, 0.3), CF(side * 14.75, 29.6, 5.05), TRIM, CONC)
			ctx:part("ReliefPanel", V(3.2, 9, 0.4), CF(side * 14.75, 29.6, 5.2), PANEL, CONC)
		end
		ctx:part("Cornice2", V(44, 2, 13), CF(0, 38.9, 1.5), TRIM, CONC)
		-- Paired round columns on both registers: base, shaft (cylinder), capital. 4 per register, 8 shafts in all.
		for _, x in ipairs({ -17.5, -12, 12, 17.5 }) do
			ctx:part("ColumnBase1", V(4.4, 1.4, 4.4), CF(x, 0.7, 6.3), TRIM, CONC)
			post(ctx, "ColumnShaft", 3, 17.4, x, 1.4, 6.3, TRIM, CONC)
			ctx:part("ColumnCap1", V(4.6, 1.6, 4.6), CF(x, 19.6, 6.3), TRIM, CONC)
			ctx:part("ColumnBase2", V(4.4, 1.4, 4.4), CF(x, 22.5, 6.3), TRIM, CONC)
			post(ctx, "ColumnShaft", 3, 13.7, x, 23.2, 6.3, TRIM, CONC)
			ctx:part("ColumnCap2", V(4.6, 1.4, 4.6), CF(x, 37.5, 6.3), TRIM, CONC)
		end
		-- Pediment with its raking trim behind, the IHS medallion and the Marian niche.
		ctx:gable("PedimentTrim", 45, 13.6, 10.4, CF(0, 39.7, -0.3), TRIM, CONC)
		ctx:gable("Pediment", 42, 12.2, 10, CF(0, 39.9, 0), WALL, CONC)
		ctx:cyl("Medallion", V(0.6, 3.8, 3.8), CF(0, 48.2, 5.15) * ANG(0, PI / 2, 0), PANEL, CONC)
		ctx:cyl("MedallionCore", V(0.8, 2.4, 2.4), CF(0, 48.2, 5.25) * ANG(0, PI / 2, 0), DOME, PLASTER)
		arched(ctx, "Niche", V(0, 40.4, 5), 0, 3, 5.8)
		ctx:part("Statue", V(1.1, 3, 0.8), CF(0, 42.4, 5.5), WHITE, CONC)
		ctx:ball("StatueHead", 1.1, CF(0, 44.3, 5.5), WHITE, CONC)
		-- Small belfry on the apex, with a cross.
		ctx:part("BelfryBlock", V(6, 4.5, 6), CF(0, 54.2, 0), WALL, CONC)
		ctx:part("BelfryCap", V(7, 0.8, 7), CF(0, 56.85, 0), TRIM, CONC)
		arched(ctx, "BelfryWindow", V(0, 52.9, 3.05), 0, 2, 3.2)
		ctx:ball("BelfryDome", 5, CF(0, 58, 0), DOME, PLASTER)
		ctx:part("BelfryCrossV", V(0.4, 3, 0.4), CF(0, 61.4, 0), TRIM, METAL)
		ctx:part("BelfryCrossH", V(1.8, 0.4, 0.4), CF(0, 62.0, 0), TRIM, METAL)
	end

	------------------------------------------------------------------ Tower (viewer's left; 4 octagonal tiers, LED screen on the front)
	local TOWER_X, TOWER_Z = -34, -8
	local function buildTower(ctx)
		local cx, cz = TOWER_X, TOWER_Z
		ctx:part("TowerBody", V(26, 22, 26), CF(cx, 11, cz), WALL, CONC)
		ctx:part("TowerPlinth", V(27.6, 1.6, 27.6), CF(cx, 0.8, cz), TRIM, CONC)
		ctx:part("TowerCornice0", V(28.4, 1.6, 28.4), CF(cx, 22.8, cz), TRIM, CONC)
		-- The LED screen (2023-2025 photos): a protruding box with a pale louvred frame on the FRONT of the first tier,
		-- just above the base cornice. Tier 1's flat front face (apothem 11) is at z = cz + 11.
		local front = cz + 11
		ctx:part("ScreenFrame", V(11.4, 8.2, 1.2), CF(cx, 28.5, front + 0.6), LOUVRE, METAL)
		ctx:part("Screen", V(10, 6.8, 0.4), CF(cx, 28.5, front + 1.4), SCREEN_BLACK, PLAS)
		-- Four octagonal tiers, each narrower than the one below, with arched openings (all eight faces from tier 2 up).
		local tiers = {
			{ r = 11, h = 12, ww = 3.6, wh = 7 },
			{ r = 9.8, h = 11, ww = 3.4, wh = 6.6 },
			{ r = 8.6, h = 10, ww = 3.2, wh = 6.2 },
			{ r = 7.4, h = 9, ww = 3.0, wh = 5.6 },
		}
		local y = 23.6
		for i, t in ipairs(tiers) do
			ctx:octagonRing("Tier" .. i, t.r, t.h, y, 1.8, WALL, CONC, CF(cx, 0, cz))
			local outer = t.r + 0.9
			local faces = (i == 1) and { 0, 4, 6 } or { 0, 1, 2, 3, 4, 5, 6, 7 } -- face 2 is the front on tier 1: the screen
			for _, j in ipairs(faces) do
				local th = j * PI / 4
				local nx, nz = math.cos(th), math.sin(th)
				arched(ctx, "Tier" .. i .. "Win", V(cx + nx * outer, y + 2.2, cz + nz * outer), math.atan2(nx, nz), t.ww, t.wh)
			end
			y += t.h
			ctx:octagonRing("Cornice" .. i, outer + 0.5, 1.6, y, 1.8, TRIM, CONC, CF(cx, 0, cz))
			y += 1.6
		end
		-- Cream-white cupola (Dec 2025 repaint) with a finial and a cross.
		ctx:dome("Cupola", 6.6, 8, CF(cx, y, cz), DOME, RIB, PLASTER)
		ctx:ball("Finial", 2.2, CF(cx, y + 6.8, cz), TRIM, METAL)
		ctx:part("TowerCrossV", V(0.5, 5, 0.5), CF(cx, y + 10.0, cz), TRIM, METAL)
		ctx:part("TowerCrossH", V(2.6, 0.5, 0.5), CF(cx, y + 10.8, cz), TRIM, METAL)
	end

	------------------------------------------------------------------ Nave (bays dropped to fit the footprint)
	local NAVE_Z0, NAVE_Z1 = -5, -84
	local function buildNave(ctx)
		local len = NAVE_Z0 - NAVE_Z1
		local zc = (NAVE_Z0 + NAVE_Z1) / 2
		for _, side in ipairs({ -1, 1 }) do
			ctx:part("NaveWall", V(2, 36, len), CF(side * 21, 18, zc), WALL, CONC)
			ctx:part("NaveSkirt", V(3, 1.4, len), CF(side * 21.5, 0.7, zc), TRIM, CONC)
			ctx:part("NaveEaveCornice", V(4.4, 1.5, len + 2), CF(side * 21.4, 36.2, zc), TRIM, CONC)
		end
		-- Left wall windows on the bays beyond the tower, clerestory windows above the wing's eave on the right.
		for _, z in ipairs({ -30, -39 }) do
			arched(ctx, "NaveWinL", V(-22, 11, z), -PI / 2, 4.4, 13)
		end
		for _, z in ipairs({ -9, -20, -31 }) do
			arched(ctx, "NaveClerestoryR", V(22, 29.5, z), PI / 2, 3.6, 5.8)
		end
		for _, z in ipairs({ -30, -39 }) do
			arched(ctx, "NaveClerestoryL", V(-22, 29.5, z), -PI / 2, 3.6, 5.8)
		end
		for _, z in ipairs({ -12, -25, -35, -45 }) do
			ctx:part("NavePilasterL", V(1.2, 33, 1.4), CF(-22.4, 17.5, z), TRIM, CONC)
		end
		-- Gabled roof: two slopes from the eaves (y 36 at x = +-22.5) to the ridge (y 48), with ribs.
		local run, rise = 22.5, 12
		local len2 = math.sqrt(run * run + rise * rise)
		local theta = math.atan(rise / run)
		for _, side in ipairs({ -1, 1 }) do
			local cf = CF(side * run / 2, 36 + rise / 2, zc) * ANG(0, 0, -side * theta)
			ctx:part("NaveRoof", V(len2, 0.6, len + 4), cf, ROOF, ROOFMAT)
			for z = -6, -84, -3 do
				ctx:part("NaveRoofRib", V(len2, 0.35, 0.6), cf * CF(0, 0.45, z - zc), ROOF_RIB, ROOFMAT)
			end
		end
		ctx:part("NaveRidge", V(1.4, 1.2, len + 4), CF(0, 48.3, zc), TRIM, CONC)
		ctx:gable("NaveBackGable", 43, 12, 1.5, CF(0, 36, -84.6), WALL, CONC)
		-- Rounded apse (about 18 m wide, as in the OSM outline) with a stepped roof; its back reaches z -100.
		ctx:cyl("Apse", V(36, 36, 36), CF(0, 18, -82) * ANG(0, 0, PI / 2), WALL, CONC)
		ctx:cyl("ApseCornice", V(1.4, 37.6, 37.6), CF(0, 36, -82) * ANG(0, 0, PI / 2), TRIM, CONC)
		post(ctx, "ApseRoof1", 37, 2.4, 0, 36.7, -82, ROOF, ROOFMAT)
		post(ctx, "ApseRoof2", 27, 2.4, 0, 39.1, -82, ROOF, ROOFMAT)
		post(ctx, "ApseRoof3", 15, 2.4, 0, 41.5, -82, ROOF, ROOFMAT)
	end

	------------------------------------------------------------------ Transept and dome (cream-white, about as wide as the nave)
	local CROSS_Z = -62
	local DRUM_APOTHEM, DRUM_T = 20, 2.5
	local DRUM_OUTER = DRUM_APOTHEM + DRUM_T / 2 -- the drum's outer face, where its windows sit
	local DRUM_BASE, DRUM_TOP = 36, 52
	local DOME_R, DOME_Y = 19, 53.5 -- DOME_Y = DRUM_TOP + the 1.5-stud cornice; the dome top is 72.5
	local function buildDome(ctx)
		-- Transept block (x +-44 = 88 studs; the real transept is about 48 m), with gabled arm roofs (ridge along X at y 43),
		-- an end gable and a window on each arm end.
		ctx:part("TranseptBlock", V(88, 36, 40), CF(0, 18, CROSS_Z), WALL, CONC)
		local armRun, armRise = 20.5, 7
		local armLen = math.sqrt(armRun * armRun + armRise * armRise)
		local armTheta = math.atan(armRise / armRun)
		for _, side in ipairs({ -1, 1 }) do
			local rx = side * 33.25 -- the roofs span x 21.85 .. 44.65
			for _, slope in ipairs({ 1, -1 }) do
				local cf = CF(rx, 36 + armRise / 2, CROSS_Z + slope * armRun / 2) * ANG(slope * armTheta, 0, 0)
				ctx:part("ArmRoof", V(22.8, 0.6, armLen), cf, ROOF, ROOFMAT)
				for _, x in ipairs({ 24, 28, 32, 36, 40, 43.5 }) do
					ctx:part("ArmRoofRib", V(0.5, 0.35, armLen), cf * CF(side * x - rx, 0.45, 0), ROOF_RIB, ROOFMAT)
				end
			end
			ctx:gable("ArmEndGable", 41, armRise, 1.5, CF(side * 44.4, 36, CROSS_Z) * ANG(0, PI / 2, 0), WALL, CONC)
			ctx:part("ArmCornice", V(1.2, 1.4, 42), CF(side * 45, 35.3, CROSS_Z), TRIM, CONC)
			arched(ctx, "ArmWindow", V(side * 44.9, 13, CROSS_Z), side * PI / 2, 5, 14)
		end
		-- Octagonal drum with a window on every face, and its cornice.
		local cx, cz = 0, CROSS_Z
		ctx:octagonRing("Drum", DRUM_APOTHEM, DRUM_TOP - DRUM_BASE, DRUM_BASE, DRUM_T, WALL, CONC, CF(cx, 0, cz))
		for k = 1, 8 do
			local theta = (k - 1) * PI / 4
			local nx, nz = math.cos(theta), math.sin(theta)
			-- windows span y 44.5 .. 51, clear of the arm roof ridge (43) and of the cornice (52)
			arched(ctx, "DrumWin" .. k, V(cx + nx * DRUM_OUTER, 44.5, cz + nz * DRUM_OUTER), math.atan2(nx, nz), 3.2, 6.5)
		end
		ctx:octagonRing("DrumCornice", DRUM_OUTER + 0.6, 1.5, DRUM_TOP, 3.2, TRIM, CONC, CF(cx, 0, cz))
		-- Four small corner turrets on the arm roofs (the roof surface at z = CROSS_Z +- 12 is y ~ 39.9).
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local x, z = sx * 30, CROSS_Z + sz * 12
				ctx:part("Turret", V(3.6, 8, 3.6), CF(x, 43.4, z), WALL, CONC)
				ctx:ball("TurretCap", 4.2, CF(x, 47.8, z), DOME, PLASTER)
				ctx:part("TurretSlit", V(1.2, 3, 0.3), CF(x, 43.4, z + sz * 1.85), GLASS, Enum.Material.Glass)
			end
		end
		-- Ribbed cream-white dome, lantern and cross.
		ctx:dome("Dome", DOME_R, 8, CF(cx, DOME_Y, cz), DOME, RIB, PLASTER)
		ctx:octagonRing("Lantern", 3.2, 5, 71.5, 0.8, WALL, CONC, CF(cx, 0, cz))
		ctx:ball("LanternCap", 6.4, CF(cx, 77.2, cz), DOME, PLASTER)
		ctx:part("DomeCrossV", V(0.5, 4.5, 0.5), CF(cx, 80.4, cz), TRIM, METAL)
		ctx:part("DomeCrossH", V(2.4, 0.5, 0.5), CF(cx, 81.2, cz), TRIM, METAL)
	end

	------------------------------------------------------------------ Adjoining wing (viewer's right, +X; P3 / P4)
	local function buildWing(ctx)
		local x0, bays, bayW = 21, 11, 9
		local wingLen = bays * bayW -- 99
		local mid = x0 + wingLen / 2
		local pavX = x0 + bayW * 3.5
		local entX = x0 + bayW * 9.5
		local function bayX(i) return x0 + bayW * (i - 0.5) end
		-- Ground floor: panels with arched openings, a dark backing behind them.
		for i = 1, bays do
			arch(ctx, "WingBay" .. i, { width = 4.6, height = 9.5, depth = 3, wallWidth = bayW, wallHeight = 13,
				cframe = CF(bayX(i), 6.5, -1.5), color = WALL, material = CONC })
		end
		ctx:part("WingBacking", V(wingLen, 10, 0.4), CF(mid, 5, -3.2), GLASS, PLAS)
		-- Upper floor, storey bands, a pilaster between every bay.
		ctx:part("WingUpper", V(wingLen, 13, 3), CF(mid, 19.5, -1.5), WALL, CONC)
		ctx:part("WingPlinth", V(wingLen + 0.4, 1, 3.4), CF(mid, 0.5, -1.3), TRIM, CONC)
		ctx:part("WingBand", V(wingLen + 0.8, 1.1, 3.6), CF(mid, 13.2, -1.2), TRIM, CONC)
		ctx:part("WingEave", V(wingLen + 1.6, 1.6, 4.6), CF(mid, 26.8, -0.9), TRIM, CONC)
		for i = 0, bays do
			local x = x0 + bayW * i
			ctx:part("WingPilasterLow", V(1.4, 11.4, 0.9), CF(x, 6.7, 0.45), TRIM, CONC)
			ctx:part("WingPilasterUp", V(1.4, 11.2, 0.9), CF(x, 19.6, 0.45), TRIM, CONC)
		end
		for i = 1, bays do
			if i ~= 4 then
				arched(ctx, "WingWin" .. i, V(bayX(i), 15.3, 0), 0, 3.4, 8)
			end
		end
		-- Hipped-style gable roof along X: two slopes with ribs, a ridge, and a gabled right end.
		local run, rise = 21.8, 6
		local len = math.sqrt(run * run + rise * rise)
		local theta = math.atan(rise / run)
		local front = CF(mid, 30.2, -9.1) * ANG(theta, 0, 0)
		local back = CF(mid, 30.2, -30.9) * ANG(-theta, 0, 0)
		ctx:part("WingRoofFront", V(wingLen + 2.4, 0.6, len), front, ROOF, ROOFMAT)
		ctx:part("WingRoofBack", V(wingLen + 2.4, 0.6, len), back, ROOF, ROOFMAT)
		for x = x0 + 2, x0 + wingLen - 2, 3 do
			ctx:part("WingRib", V(0.5, 0.35, len), front * CF(x - mid, 0.45, 0), ROOF_RIB, ROOFMAT)
			ctx:part("WingRib", V(0.5, 0.35, len), back * CF(x - mid, 0.45, 0), ROOF_RIB, ROOFMAT)
		end
		ctx:part("WingRidge", V(wingLen + 2.4, 1, 1.2), CF(mid, 33.4, -20), TRIM, CONC)
		ctx:part("WingBackWall", V(wingLen, 27, 2), CF(mid, 13.5, -41), WALL, CONC)
		ctx:part("WingEndWall", V(1.6, 27, 40), CF(x0 + wingLen - 0.8, 13.5, -20), WALL, CONC)
		ctx:gable("WingEndGable", 40, 6.2, 1.6, CF(x0 + wingLen - 0.8, 27, -20) * ANG(0, PI / 2, 0), WALL, CONC)
		for _, z in ipairs({ -10, -30 }) do
			arched(ctx, "WingEndWinLow", V(x0 + wingLen + 0.1, 3, z), PI / 2, 3.6, 8)
			arched(ctx, "WingEndWinUp", V(x0 + wingLen + 0.1, 15.3, z), PI / 2, 3.4, 8)
		end
		-- Central pavilion: a scrolled (curvilinear) gable with a cross and a shield, a balcony over the entrance.
		ctx:part("PavilionBody", V(12, 29, 5), CF(pavX, 14.5, -0.5), WALL, CONC)
		arched(ctx, "PavilionDoor", V(pavX, 0, 2), 0, 4, 8.5)
		arched(ctx, "PavilionWin", V(pavX, 15.3, 2), 0, 4, 8)
		ctx:part("PavilionPlaque", V(6, 1.2, 0.3), CF(pavX, 11.2, 2.15), PANEL, CONC)
		ctx:part("WingBalcony", V(10, 0.8, 3), CF(pavX, 13.2, 3.4), TRIM, CONC)
		ctx:part("BalconyRail", V(10, 0.4, 0.4), CF(pavX, 15.2, 4.8), TRIM, CONC)
		for k = -4, 4 do
			ctx:part("BalconyBaluster", V(0.4, 1.8, 0.4), CF(pavX + k * 1.2, 14.2, 4.8), TRIM, CONC)
		end
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("PavilionPilaster", V(1.2, 27, 0.8), CF(pavX + s * 5.4, 13.5, 2.3), TRIM, CONC)
			ctx:ball("PavilionScroll", 2.4, CF(pavX + s * 6.6, 29.2, 1), WALL, CONC)
			ctx:ball("PavilionScroll", 1.6, CF(pavX + s * 4.6, 32.4, 1), TRIM, CONC)
		end
		ctx:cyl("PavilionCurve", V(5, 12, 12), CF(pavX, 29, -0.5) * ANG(0, PI / 2, 0), WALL, CONC)
		ctx:part("PavilionShield", V(2.4, 3, 0.3), CF(pavX, 31.5, 2.15), PANEL, CONC)
		ctx:part("PavilionCrossV", V(0.7, 5, 0.7), CF(pavX, 37.5, -0.5), TRIM, METAL)
		ctx:part("PavilionCrossH", V(3, 0.7, 0.7), CF(pavX, 38.6, -0.5), TRIM, METAL)
		-- The far entrance carries the cathedral's name (as in the 2024 photo of the wing end).
		local sign = ctx:part("EntranceSign", V(13, 2.2, 0.3), CF(entX, 11.6, 2.3), GLASS, PLAS)
		label(sign, Enum.NormalId.Back, "CATEDRAL DE SAN SEBASTIAN", Color3.fromRGB(240, 240, 232), 36)
	end

	------------------------------------------------------------------ Podium: the upper level (church, wing, forecourt, garden) and the retaining wall
	local function buildPodium(ctx)
		-- One raised platform, RAISE studs above the ground, carries the church, its wing, the car-park forecourt and the garden
		-- (P1: the forecourt is higher than Plaza Independencia). Its south face (z 56) is the retaining wall; the terrain and the
		-- repainted Pavement are not touched (the podium simply hides them north of z 56).
		ctx:part("Podium", V(240, RAISE, WALL_Z + 100), CF(0, RAISE / 2, (WALL_Z - 100) / 2), STONE, CONC)
		ctx:part("PodiumCornice", V(240.8, 0.6, 1.0), CF(0, RAISE - 0.3, WALL_Z), STONE_LIGHT, CONC)
		ctx:part("PodiumPlinth", V(240.8, 0.8, 1.0), CF(0, 0.4, WALL_Z + 0.1), STONE_DARK, CONC)
	end

	local function palm(ctx, i, px, pz)
		-- three trunk segments leaning slightly, a crown of fronds
		local lean = (i % 2 == 0) and 0.5 or -0.5
		post(ctx, "PalmTrunk1", 1.5, 6, px, 0, pz, TRUNK, WOOD)
		post(ctx, "PalmTrunk2", 1.25, 6, px + lean * 0.5, 6, pz, TRUNK, WOOD)
		post(ctx, "PalmTrunk3", 1, 6, px + lean, 12, pz, TRUNK, WOOD)
		local crown = V(px + lean, 18.4, pz)
		ctx:ball("PalmNut", 1.4, CF(crown), Color3.fromRGB(110, 90, 50), PLAS)
		for k = 1, 7 do
			local yaw = (k - 1) * 2 * PI / 7 + i
			ctx:part("PalmFrond", V(8, 0.25, 2.2), CF(crown) * ANG(0, yaw, 0) * ANG(0, 0, -0.45) * CF(4, 0, 0), GREEN, Enum.Material.Grass)
		end
	end

	------------------------------------------------------------------ Upper level (origin raised): the big asphalt parking lot, monument, garden
	-- A cheaper palm (8 parts): two trunk segments, a nut and five fronds. The first segment keeps the name PalmTrunk1 (the checks count palms by it).
	local function palmLite(ctx, i, px, pz)
		local lean = (i % 2 == 0) and 0.4 or -0.4
		post(ctx, "PalmTrunk1", 1.3, 9, px, 0, pz, TRUNK, WOOD)
		post(ctx, "PalmTrunk2", 1.0, 9, px + lean, 9, pz, TRUNK, WOOD)
		local crown = V(px + lean, 18.4, pz)
		ctx:ball("PalmNut", 1.4, CF(crown), Color3.fromRGB(110, 90, 50), PLAS)
		for k = 1, 5 do
			local yaw = (k - 1) * 2 * PI / 5 + i
			ctx:part("PalmFrond", V(8, 0.25, 2.4), CF(crown) * ANG(0, yaw, 0) * ANG(0, 0, -0.45) * CF(4, 0, 0), GREEN, Enum.Material.Grass)
		end
	end
	local PALMS_UP = {} -- round 2: the lot is asphalt now; the palms that stood on it are gone (the compound palms behind the church stay)
	local GARDEN_BEDS = { { 68, 14 }, { 81, 14 }, { 68, 33 }, { 81, 33 } } -- x, z of each bed's NW corner; 9 x 13 studs
	local function buildPlazaUpper(ctx)
		-- local y 0 is the podium top. Round 2: the forecourt is one big asphalt lot x -100..64 with painted bays in two rows (the plaza drawing);
		-- the walled garden is the east end (x 66..92), the monument mound is at the far corner (x 95..119).
		ctx:part("ApronPaving", V(181.5, 0.1, WALL_Z - 10), CF(-26.75, 0.05, (WALL_Z + 10) / 2), ASPHALT, Enum.Material.Asphalt) -- x -117.5..64, z 10..48 (B3c-0b: it stops 2 studs short of the west podium edge across the stair width, so the last side step stays 1 stud; the two corner pieces below take the asphalt on to the fence)
		ctx:part("ApronPavingWestN", V(2, 0.1, 10), CF(-118.5, 0.05, 15), ASPHALT, Enum.Material.Asphalt) -- x -119.5..-117.5, z 10..20
		ctx:part("ApronPavingWestS", V(2, 0.1, 16), CF(-118.5, 0.05, 40), ASPHALT, Enum.Material.Asphalt) -- x -119.5..-117.5, z 32..48
		ctx:part("ApronPavingNW", V(69.5, 0.1, 56), CF(-84.75, 0.05, -18), ASPHALT, Enum.Material.Asphalt) -- x -119.5..-50, z -46..10: the asphalt beside the tower, out to the west fence
		-- B3c-0: the old courtyard block (x -120..-52, z -99..-48) is a lawn like the one behind the church, with two palms.
		ctx:part("WestLawn", V(69.5, 0.12, 53), CF(-84.75, 0.06, -72.5), LAWN, Enum.Material.Grass) -- x -119.5..-50, z -99..-46
		palm(ctx, 42, -100, -76)
		palm(ctx, 43, -72, -68)
		ctx:part("GardenApron", V(54, 0.1, WALL_Z - 10), CF(91, 0.05, (WALL_Z + 10) / 2), STONE_LIGHT, CONC) -- x 64..118 under the garden and the gateway; stops 2 studs short of the podium edge so the last side step stays 1 stud
		ctx:part("Walkway", V(14, 0.06, WALL_Z - 10), CF(0, 0.13, (WALL_Z + 10) / 2), STONE_LIGHT, CONC)
		-- B3c-0b (orange marks): pale walkways from the side stair tops (x +-120, z 26) into the lot; the east one meets GatewayPath at x 100
		ctx:part("EntryWalkW", V(18.5, 0.1, 10), CF(-108.25, 0.15, 26), STONE_LIGHT, CONC) -- x -117.5..-99: it stops 2 studs short of the stair edge so the last side step stays 1 stud
		ctx:part("EntryWalkE", V(8.5, 0.1, 10), CF(95.75, 0.15, 26), STONE_LIGHT, CONC) -- x 91.5..100
		-- Parapet caps the retaining wall beyond the seating tiers (x < -76 and x > 98).
		ctx:part("Parapet", V(44, 1.4, 1.6), CF(-98, 0.7, WALL_Z - 0.8), STONE_LIGHT, CONC)
		ctx:part("Parapet", V(22, 1.4, 1.6), CF(109, 0.7, WALL_Z - 0.8), STONE_LIGHT, CONC)
		-- Hedges flanking the tower front and the wing front (gap x 44..61 for the pavilion's steps).
		ctx:part("HedgeTowerW", V(8, 1.8, 2), CF(-43, 0.95, 9), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeTowerE", V(8, 1.8, 2), CF(-25, 0.95, 9), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeWingW", V(20, 1.8, 2), CF(33, 0.95, 3.5), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeWingE", V(34, 1.8, 2), CF(81, 0.95, 3.5), HEDGE, Enum.Material.Grass)
		-- Painted bays: two rows (z 14..24 and z 36..46) of 6-stud bays, x -98..64, left open at the walkway and the statues (x -8..10).
		for _, rowZ in ipairs({ 19, 41 }) do
			for i = 0, 27 do
				local lx = -98 + i * 6
				if lx <= -14 or lx >= 16 then
					ctx:part("ParkingBayLine", V(0.3, 0.1, 10), CF(lx, 0.15, rowZ), YELLOW, PLAS)
				end
			end
		end
		for _, z in ipairs({ 24.2, 35.8 }) do
			ctx:part("ParkingAisleLine", V(84, 0.1, 0.3), CF(-56, 0.15, z), YELLOW, PLAS)
			ctx:part("ParkingAisleLine", V(48, 0.1, 0.3), CF(40, 0.15, z), YELLOW, PLAS)
		end
		-- B3c-0b magenta: yellow bay lines round the two rows of the NW lot (cars are 6 apart), and the aisle edges between them.
		for _, row in ipairs(NW_ROWS) do
			for i = 0, row.n + 1 do ctx:part("ParkingBayLine", V(0.3, 0.1, 10), CF(row.x0 - 3 + i * 6, 0.15, row.z), YELLOW, PLAS) end
		end
		for _, z in ipairs({ -30.8, -13.2 }) do ctx:part("ParkingAisleLine", V(56, 0.1, 0.3), CF(-85, 0.15, z), YELLOW, PLAS) end
		-- The saint's monument on a plinth, off the walkway.
		local mx, mz = -10, 40
		ctx:part("MonumentPlinth", V(5.4, 1.4, 5.4), CF(mx, 0.7, mz), STONE_DARK, CONC)
		ctx:part("Monument", V(3.4, 5, 3.4), CF(mx, 3.9, mz), STONE_LIGHT, CONC)
		ctx:part("MonumentCap", V(4.2, 0.6, 4.2), CF(mx, 6.7, mz), STONE_DARK, CONC)
		ctx:part("MonumentStatue", V(1.4, 3.6, 1.0), CF(mx, 8.8, mz), WHITE, CONC)
		ctx:ball("MonumentHead", 1.3, CF(mx, 11.3, mz), WHITE, CONC)
		-- Hedged garden (the lot's east end): a lawn slab, four hedged beds, a path cross at x 79 / z 30.
		ctx:part("GardenLawn", V(26, 0.12, 36), CF(79, 0.06, 28), LAWN, Enum.Material.Grass)
		ctx:part("GardenPathNS", V(4, 0.14, 36), CF(79, 0.07, 28), STONE_LIGHT, CONC)
		ctx:part("GardenPathEW", V(26, 0.14, 4), CF(79, 0.07, 30), STONE_LIGHT, CONC)
		for _, b in ipairs(GARDEN_BEDS) do
			local bx, bz, bw, bd = b[1], b[2], 9, 13
			ctx:part("GardenHedge", V(bw, 1.8, 1.6), CF(bx + bw / 2, 0.9, bz), HEDGE, Enum.Material.Grass)
			ctx:part("GardenHedge", V(bw, 1.8, 1.6), CF(bx + bw / 2, 0.9, bz + bd), HEDGE, Enum.Material.Grass)
			ctx:part("GardenHedge", V(1.6, 1.8, bd), CF(bx, 0.9, bz + bd / 2), HEDGE, Enum.Material.Grass)
			ctx:part("GardenHedge", V(1.6, 1.8, bd), CF(bx + bw, 0.9, bz + bd / 2), HEDGE, Enum.Material.Grass)
		end
		-- The rest of the podium top: lawn with a few palms west of the tower and behind the wing (P1: the compound is green).
		ctx:part("PodiumLawn", V(98, 0.12, 58), CF(71, 0.06, -70), LAWN, Enum.Material.Grass)
		for i, p in ipairs({ { 106, -72 } }) do palm(ctx, i + 40, p[1], p[2]) end -- B3c-0: the palm moved from (60,-72) onto the lawn east of the ChurchAnnex
		for i, p in ipairs(PALMS_UP) do palm(ctx, i, p[1], p[2]) end
		-- A row of small statues down the middle of the lot (the plaza drawing), clear of the Guide, JeepStop and InfoPanel.
		for _, s in ipairs(STATUES) do
			ctx:part("StatuePlinth", V(1.8, 1.2, 1.8), CF(s[1], 0.6, s[2]), STONE_DARK, CONC)
			ctx:part("StatueFigure", V(0.9, 2.8, 0.7), CF(s[1], 2.6, s[2]), STONE_LIGHT, CONC)
			ctx:ball("StatueHead", 0.9, CF(s[1], 4.5, s[2]), STONE_LIGHT, CONC)
		end
		-- Walled garden: a black iron fence round its sides (gaps for the path ends) and trees in the beds.
		do
			local function ironRun(x0, z0, x1, z1)
				local len = (V(x1, 0, z1) - V(x0, 0, z0)).Magnitude
				local n = math.max(1, math.floor(len / 5))
				for i = 0, n do
					local t = i / n
					ctx:part("GardenFencePost", V(0.5, 4, 0.5), CF(x0 + (x1 - x0) * t, 2, z0 + (z1 - z0) * t), LAMP_METAL, METAL)
				end
				local sx, sz = math.abs(x1 - x0) + 0.3, math.abs(z1 - z0) + 0.3
				local mxm, mzm = (x0 + x1) / 2, (z0 + z1) / 2
				for _, yy in ipairs({ 1.2, 3.4 }) do
					ctx:part("GardenFenceRail", sx > sz and V(sx, 0.3, 0.3) or V(0.3, 0.3, sz), CF(mxm, yy, mzm), LAMP_METAL, METAL)
				end
			end
			ironRun(66, 11.5, 76, 11.5)
			ironRun(82, 11.5, 92, 11.5)
			ironRun(66, 12, 66, 27)
			ironRun(66, 33, 66, 46)
			ironRun(91, 34, 91, 46) -- the east side stays open from z 12 to 33: the garden's entrance, facing the gateway arch and the side stairs (routes_check)
			for _, t in ipairs({ { 71, 20 }, { 75, 24 }, { 84, 19 }, { 88, 23 }, { 71, 40 }, { 75, 36 }, { 84, 41 }, { 88, 37 } }) do
				post(ctx, "GardenTreeTrunk", 1.4, 5, t[1], 0, t[2], TRUNK, WOOD)
				ctx:ball("GardenTreeCanopy", 8, CF(t[1], 8.5, t[2]), GREEN, Enum.Material.Grass)
				ctx:ball("GardenTreeCanopy", 6, CF(t[1] + 1.6, 11.5, t[2] - 1), Color3.fromRGB(58, 118, 62), Enum.Material.Grass)
			end
		end
		-- The gateway arch on the C.M. Recto side (x 110, B3c-0b: z 26, the line of SideStairsE and EAST_ENTRY): a bold iron arch (0.7-stud bars) on stone piers, a stone path to the side stairs.
		do
			local gx, gz, baseY, R = 110, 26, 10, 6.5
			ctx:part("GatewayPath", V(18, 0.14, 12), CF(109, 0.07, gz), STONE_LIGHT, CONC) -- x 100..118: B3c-0b, 2 studs short of the stair edge (the path now covers the whole stair width; a surface above the podium within 2 studs of the edge makes the last riser too high for PathfindingService, like GardenApron)
			for _, dz in ipairs({ -R, R }) do
				ctx:part(dz < 0 and "GatewayPostL" or "GatewayPostR", V(3.0, baseY, 3.0), CF(gx, baseY / 2, gz + dz), STONE_DARK, CONC)
				ctx:part("GatewayCap", V(3.6, 1.0, 3.6), CF(gx, baseY + 0.5, gz + dz), STONE_LIGHT, CONC)
			end
			local seg = 16
			for _, radius in ipairs({ R, R - 1.2 }) do
				for k = 0, seg - 1 do
					local a0, a1 = k * PI / seg, (k + 1) * PI / seg
					local p0, p1 = V(radius * math.cos(a0), radius * math.sin(a0), 0), V(radius * math.cos(a1), radius * math.sin(a1), 0)
					local mid, blen = (p0 + p1) / 2, (p1 - p0).Magnitude + 0.2
					local phi = math.atan2(p1.Y - p0.Y, p1.X - p0.X)
					ctx:part("GatewayIron", V(0.7, 0.7, blen), CF(gx, baseY + mid.Y, gz + mid.X) * ANG(-phi, 0, 0), LAMP_METAL, METAL)
				end
			end
			ctx:part("GatewayCrossV", V(0.6, 3.4, 0.6), CF(gx, baseY + R + 2.4, gz), LAMP_METAL, METAL)
			ctx:part("GatewayCrossH", V(0.6, 0.6, 2.2), CF(gx, baseY + R + 3.0, gz), LAMP_METAL, METAL)
		end
	end

------------------------------------------------------------------ ChurchAnnex (B3c-0, the owner's magenta mark): more cathedral building on the green lawn east of the transept
	-- One straight-edged 2-storey block x 45.4..94, z -99..-42 (measured against the owner's picture, scratch/b3c0-journal.md): its west face stands on the transept's east wall, its south face on the
	-- east wing's back wall, so the wing's back roof and the annex roof meet in a valley. Walls, trim, arched windows, red ribbed roof and eave height (WingEave, local y 26.8) are the wing's.
	local function buildChurchAnnex(ctx)
		local x0, x1, z0, z1, H = 45.4, 94, -99, -42, 26
		local W, D = x1 - x0, z1 - z0
		local cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
		ctx:part("AnnexBody", V(W, H, D), CF(cx, H / 2, cz), WALL, CONC)
		ctx:part("AnnexPlinth", V(W + 0.8, 1, D + 0.8), CF(cx, 0.5, cz), TRIM, CONC)
		ctx:part("AnnexBand", V(W + 0.8, 1.1, D + 0.8), CF(cx, 13.2, cz), TRIM, CONC)
		ctx:part("AnnexEave", V(W + 1.2, 1.6, D + 0.8), CF(cx, 26.8, cz), TRIM, CONC)
		-- Pilasters between the bays on the north and east faces, then an arched window per bay and storey on the north, east and west faces.
		for i = 0, 5 do
			local px, pz = x0 + W * i / 5, z0 + D * i / 5
			ctx:part("AnnexPilasterLow", V(1.4, 11.4, 0.9), CF(px, 6.7, z0 - 0.45), TRIM, CONC)
			ctx:part("AnnexPilasterUp", V(1.4, 11.2, 0.9), CF(px, 19.6, z0 - 0.45), TRIM, CONC)
			ctx:part("AnnexPilasterLow", V(0.9, 11.4, 1.4), CF(x1 + 0.45, 6.7, pz), TRIM, CONC)
			ctx:part("AnnexPilasterUp", V(0.9, 11.2, 1.4), CF(x1 + 0.45, 19.6, pz), TRIM, CONC)
		end
		for i = 1, 5 do
			local wx, wz = x0 + W * (i - 0.5) / 5, z0 + D * (i - 0.5) / 5
			arched(ctx, "AnnexWin", V(wx, 3, z0 - 0.1), PI, 3.6, 8)
			arched(ctx, "AnnexWin", V(wx, 15.3, z0 - 0.1), PI, 3.4, 8)
			arched(ctx, "AnnexWin", V(x1 + 0.1, 3, wz), PI / 2, 3.6, 8)
			arched(ctx, "AnnexWin", V(x1 + 0.1, 15.3, wz), PI / 2, 3.4, 8)
		end
		-- The west face is the transept's wall for z -82..-42; the strip north of it (z -99..-82) shows one bay of windows.
		arched(ctx, "AnnexWin", V(x0 - 0.1, 3, z0 + 6), -PI / 2, 3.6, 8)
		arched(ctx, "AnnexWin", V(x0 - 0.1, 15.3, z0 + 6), -PI / 2, 3.4, 8)
		-- Gable roof along X: two slopes with ribs, a ridge, and gable ends east and west (the same pitch as the wing).
		local run, rise = 29, 8
		local len = math.sqrt(run * run + rise * rise)
		local theta = math.atan(rise / run)
		local south = CF(cx, 27.2 + rise / 2, cz + run / 2) * ANG(theta, 0, 0)
		local north = CF(cx, 27.2 + rise / 2, cz - run / 2) * ANG(-theta, 0, 0)
		ctx:part("AnnexRoof", V(W + 1.4, 0.6, len), south, ROOF, ROOFMAT)
		ctx:part("AnnexRoof", V(W + 1.4, 0.6, len), north, ROOF, ROOFMAT)
		for x = x0 + 2, x1 - 2, 3 do
			ctx:part("AnnexRib", V(0.5, 0.35, len), south * CF(x - cx, 0.45, 0), ROOF_RIB, ROOFMAT)
			ctx:part("AnnexRib", V(0.5, 0.35, len), north * CF(x - cx, 0.45, 0), ROOF_RIB, ROOFMAT)
		end
		ctx:part("AnnexRidge", V(W + 1.4, 1, 1.2), CF(cx, 27.2 + rise + 0.2, cz), TRIM, CONC)
		ctx:gable("AnnexEndGableE", D, 8.1, 1.6, CF(x1 - 0.8, 26.8, cz) * ANG(0, PI / 2, 0), WALL, CONC)
		ctx:gable("AnnexEndGableW", D, 8.1, 1.6, CF(x0 + 0.8, 26.8, cz) * ANG(0, -PI / 2, 0), WALL, CONC)
	end

	------------------------------------------------------------------ WestFence (B3c-0, the owner's black lines): a black iron fence where the parish wing stood
	-- 3 studs tall (posts 0.5 x 3, two rails), like the walled garden's GardenFencePost fence. Podium edge x -119.5 (z -99.5..19 and 33..47: the gap z 19..33 keeps SideStairsW open),
	-- the podium's north edge z -99.5 (x -119.5..-52, up to the tower), and the lower plaza's west kerb x -100.5 (z 58..99.6; z 49..58 beside the retaining wall is a pedestrian gate, B3c-0 route cap) joined to the white south fence at x -96.6.
	local function buildWestFence(ctx)
		local function ironRun(x0, z0, x1, z1, baseY)
			local len = (V(x1, 0, z1) - V(x0, 0, z0)).Magnitude
			local n = math.max(1, math.ceil(len / 5))
			for i = 0, n do
				local t = i / n
				ctx:part("IronFencePost", V(0.5, 3, 0.5), CF(x0 + (x1 - x0) * t, baseY + 1.5, z0 + (z1 - z0) * t), LAMP_METAL, METAL)
			end
			local sx, sz = math.abs(x1 - x0) + 0.3, math.abs(z1 - z0) + 0.3
			local mxm, mzm = (x0 + x1) / 2, (z0 + z1) / 2
			for _, yy in ipairs({ 1.0, 2.6 }) do
				ctx:part("IronFenceRail", sx > sz and V(sx, 0.3, 0.3) or V(0.3, 0.3, sz), CF(mxm, baseY + yy, mzm), LAMP_METAL, METAL)
			end
		end
		ironRun(-119.5, -99.5, -119.5, 19, RAISE)
		ironRun(-119.5, 33, -119.5, 47, RAISE)
		ironRun(-119.5, -99.5, -52, -99.5, RAISE)
		ironRun(-100.5, 49.5, -100.5, 99.6, 0) -- B3c-0b: the gate gap z 49..58 is closed
	end

------------------------------------------------------------------ Lower level (ground): Plaza Independencia below the wall
	-- Round 2 (plaza drawing): the plaza is a grey grid-paver square with a big shade tree, lamp posts, a lawn square ringed by palms and two
	-- palm-planted green strips. The pergola ring and the vaulted court are gone. Palms near the CreditsBoard stay out of its 4-stud margin.
	local PALMS_LOW = { { 64, 92 } }
	local STRIP_PALMS = { { -27, 66 }, { -27, 70 }, { -27, 74 }, { -27, 78 }, { -27, 82 } } -- B3c-0b: the strip left the Cultural Center's side (x -71) for x -27
	local STRIP_E_PALMS = { { 62, 64 }, { 62, 69 }, { 62, 74 }, { 62, 79 }, { 62, 84 } }
	local LAWN_PALMS = { { -65, 68 }, { -65, 75 }, { -65, 82 }, { -36, 68 }, { -36, 75 }, { -36, 82 }, { -50, 69 }, { -50, 82 } }
	-- B3c-0 (the owner's orange mark): the stepped monument mound with the ribbon sculpture now stands on the plaza centre line, just south of the middle stair flight (the flights end at
	-- z 56), and is fully round. Three cylinder tiers (radius 11 / 8.5 / 6), risers of 1 stud; 2.5 studs of walking room between the flight and the mound, 2 studs to the stage corridor.
	local function buildMound(ctx)
		local cx, cz = 0, WALL_Z + 2 -- B3c-0b (black mark): in the middle of the stairs, a D with its flat back on the wall: one centre for every tier, so they nest, and a flat block from the wall to the centre
		for k, r in ipairs({ 11, 8.5, 6 }) do
			post(ctx, "MoundTier", r * 2, k, cx, 0, cz, k == 3 and STONE_LIGHT or STONE, CONC)
			ctx:part("MoundTierFlat", V(r * 2, k, cz - WALL_Z), CF(cx, k / 2, (cz + WALL_Z) / 2), k == 3 and STONE_LIGHT or STONE, CONC)
		end
		post(ctx, "MoundBase", 3.4, 1.6, cx, 3, cz, STONE_DARK, CONC)
		-- Two looped ribbons: a tall upright ring and a smaller ring turned across it, each of short, thick bars.
		local function ring(radius, yaw, cy)
			local seg = 16
			for k = 0, seg - 1 do
				local a0, a1 = k * 2 * PI / seg, (k + 1) * 2 * PI / seg
				local p0, p1 = V(radius * math.cos(a0), radius * math.sin(a0), 0), V(radius * math.cos(a1), radius * math.sin(a1), 0)
				local mid, blen = (p0 + p1) / 2, (p1 - p0).Magnitude + 0.2
				local phi = math.atan2(p1.Y - p0.Y, p1.X - p0.X)
				ctx:part("MoundRibbon", V(blen, 1.0, 1.0), CF(cx, cy, cz + 3.5) * ANG(0, yaw, 0) * CF(mid.X, mid.Y, 0) * ANG(0, 0, phi), IRON, METAL)
			end
		end
		ring(6.2, 0, 10.8)
		ring(4.6, PI / 2.6, 10.0)
	end
	local function buildPlazaLower(ctx)
		buildMound(ctx)
		ctx:part("ForecourtPaving", V(200, 0.1, 100 - WALL_Z), CF(0, 0, (WALL_Z + 100) / 2), PAVER, CONC) -- z 48..100: the repainted Pavement (x +-100, z 0..100)
		-- Grid joints of the grey pavers: thin darker lines 10 studs apart across the square (0.03 above the paving so they never z-fight).
		for i = 0, 20 do
			ctx:part("PaverJoint", V(0.3, 0.06, 51.6), CF(-100 + i * 10, 0.08, (WALL_Z + 100) / 2), PAVER_JOINT, CONC)
		end
		for _, z in ipairs({ 56, 64, 72, 80, 88, 96 }) do
			ctx:part("PaverJoint", V(199.6, 0.06, 0.3), CF(0, 0.08, z), PAVER_JOINT, CONC)
		end
		-- Kerb (0.3 high) round the lower plaza. The south kerb leaves a gap at x +-8 for the E_to_Tagbakin road mouth at (0,100).
		ctx:part("KerbWest", V(0.6, 0.3, 100 - WALL_Z), CF(-100.3, 0.15, (WALL_Z + 100) / 2), STONE_LIGHT, CONC)
		ctx:part("KerbEast", V(0.6, 0.3, 100 - WALL_Z), CF(100.3, 0.15, (WALL_Z + 100) / 2), STONE_LIGHT, CONC)
		ctx:part("KerbSouthW", V(100.6, 0.3, 0.6), CF(-50.3, 0.15, 100.3), STONE_LIGHT, CONC) -- B3c-0b: no road mouth any more, the south kerb runs through
		ctx:part("KerbSouthE", V(100.6, 0.3, 0.6), CF(50.3, 0.15, 100.3), STONE_LIGHT, CONC)
		for i, p in ipairs(PALMS_LOW) do palm(ctx, i + 20, p[1], p[2]) end
		-- Palm-planted green strip 1 (west): a lawn border (low hedges) with a palm every 8 studs.
		ctx:part("GreenStrip", V(8, 0.2, 19), CF(-27, 0.1, 73.5), LAWN, Enum.Material.Grass) -- B3c-0b: x -31..-23, z 64..83 (clear of the benches at z 62 and the stage lane z 83.2+)
		ctx:part("StripHedge", V(0.8, 1.2, 19), CF(-31.4, 0.7, 73.5), HEDGE, Enum.Material.Grass)
		ctx:part("StripHedge", V(0.8, 1.2, 19), CF(-22.6, 0.7, 73.5), HEDGE, Enum.Material.Grass)
		for i, p in ipairs(STRIP_PALMS) do palm(ctx, i + 60, p[1], p[2]) end
		-- Palm-planted green strip 2 (east of the shade tree, before the Cultural Center and the stage), z 62..88.
		ctx:part("GreenStripE", V(8, 0.2, 26), CF(62, 0.1, 75), LAWN, Enum.Material.Grass)
		ctx:part("StripHedge", V(0.8, 1.2, 26), CF(57.6, 0.7, 75), HEDGE, Enum.Material.Grass)
		ctx:part("StripHedge", V(0.8, 1.2, 26), CF(66.4, 0.7, 75), HEDGE, Enum.Material.Grass)
		for i, p in ipairs(STRIP_E_PALMS) do palmLite(ctx, i + 80, p[1], p[2]) end
		-- The lawn square (the drawing's green rectangle among the pavers): hedge-edged, ringed by palms.
		ctx:part("LawnSquare", V(24, 0.2, 21), CF(-50, 0.1, 75.5), LAWN, Enum.Material.Grass)
		ctx:part("LawnHedge", V(24.8, 1.2, 0.8), CF(-50, 0.7, 65), HEDGE, Enum.Material.Grass)
		ctx:part("LawnHedge", V(24.8, 1.2, 0.8), CF(-50, 0.7, 86), HEDGE, Enum.Material.Grass)
		ctx:part("LawnHedge", V(0.8, 1.2, 21), CF(-62, 0.7, 75.5), HEDGE, Enum.Material.Grass)
		ctx:part("LawnHedge", V(0.8, 1.2, 21), CF(-38, 0.7, 75.5), HEDGE, Enum.Material.Grass)
		for i, p in ipairs(LAWN_PALMS) do palmLite(ctx, i + 100, p[1], p[2]) end
		-- The red-brick retaining wall (the plaza drawing): a facing on the two stretches of wall the seating does not hide.
		ctx:part("RetainBrick", V(44, 3.9, 0.6), CF(-98, 2.75, WALL_Z + 0.9), BRICK, CONC)
		ctx:part("RetainBrick", V(22, 3.9, 0.6), CF(109, 2.75, WALL_Z + 0.9), BRICK, CONC)
		-- Low salmon planter walls with shrubs along the south fence, leaving the CreditsBoard strip (|x| < 31) clear.
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("PlanterWall", V(34, 1.4, 1.2), CF(s * 79, 0.7, 96.4), SALMON, CONC) -- x 62..96: 4 studs clear of the CreditsBoard
			for i = 0, 5 do
				local sx = s * (65 + i * 6)
				ctx:ball("PlanterShrub", 2.2, CF(sx, 2.3, 96.4), HEDGE, Enum.Material.Grass)
				if i % 3 == 0 then ctx:ball("PlanterBloom", 1.1, CF(sx + 0.5, 3.4, 96.4), FLOWERS[(i + (s > 0 and 1 or 3)) % #FLOWERS + 1], PLAS) end
			end
		end
		-- Flower beds along the Cultural Center's plaza face (round 4: the west building moved to the wing line, off the paving).
		local beds = { { -72.8, 66, 2.4, 5 }, { -72.8, 71.5, 2.4, 5 }, { -72.8, 86, 2.4, 5 }, { -72.8, 91.5, 2.4, 5 } } -- B3c-0b: on the Cultural Center's east face, which is now on the west side
		for bi, b in ipairs(beds) do
			ctx:part("FlowerBed", V(b[3], 0.4, b[4]), CF(b[1], 0.2, b[2]), SOIL, Enum.Material.Ground)
			local n = math.max(3, math.floor(math.max(b[3], b[4]) / 2.4))
			for i = 1, n do
				local t = (i - 0.5) / n - 0.5
				local bx, bz = b[1] + (b[3] > b[4] and t * (b[3] - 1.2) or 0), b[2] + (b[4] >= b[3] and t * (b[4] - 1.2) or 0)
				ctx:ball("BedBloom", 1.2, CF(bx, 0.9, bz), FLOWERS[(i + bi) % #FLOWERS + 1], PLAS)
			end
		end
		-- Lamps on the paver square (six): along the foot of the seating, the green strips and the south edge.
		for _, s in ipairs({ { -64, 62 }, { -36, 62.3 }, { 31, 62.3 }, { 56, 62.5 }, { -64, 94 }, { 66, 92 } }) do
			post(ctx, "LampBase", 1.8, 1.2, s[1], 0, s[2], LAMP_METAL, METAL)
			post(ctx, "LampPole", 0.6, 10, s[1], 1.2, s[2], LAMP_METAL, METAL)
			post(ctx, "LampCollar", 1.6, 0.5, s[1], 11.2, s[2], LAMP_METAL, METAL)
			ctx:ball("LampGlobe", 2.2, CF(s[1], 12.6, s[2]), LAMP_GLOW, Enum.Material.Neon)
		end
		-- Benches at the foot of the seating tiers, facing the stage (north).
		for _, s in ipairs({ { -60, 62 }, { -44, 62 }, { -28, 62 }, { 24, 62 }, { 36, 62 } }) do
			ctx:part("BenchSeat", V(6, 0.5, 2), CF(s[1], 1.75, s[2]), TIMBER, WOOD)
			ctx:part("BenchBack", V(6, 2, 0.4), CF(s[1], 3, s[2] + 0.9), TIMBER, WOOD)
			ctx:part("BenchLegL", V(0.5, 1.5, 1.8), CF(s[1] - 2.5, 0.75, s[2]), LAMP_METAL, METAL)
			ctx:part("BenchLegR", V(0.5, 1.5, 1.8), CF(s[1] + 2.5, 0.75, s[2]), LAMP_METAL, METAL)
		end
		-- Perimeter fence (P1; black since B3c-0b): the whole south side and the east side; with the west kerb fence the plaza is closed all round, the stairs from the lot are the only way in.
		local function fenceRun(x0, z0, x1, z1)
			local len = (V(x1, 0, z1) - V(x0, 0, z0)).Magnitude
			local n = math.max(1, math.floor(len / 6))
			for i = 0, n do
				local t = i / n
				ctx:part("FencePost", V(0.6, 3.2, 0.6), CF(x0 + (x1 - x0) * t, 1.6, z0 + (z1 - z0) * t), LAMP_METAL, METAL)
			end
			local mxm, mzm = (x0 + x1) / 2, (z0 + z1) / 2
			local sx, sz = math.abs(x1 - x0) + 0.4, math.abs(z1 - z0) + 0.4
			if sx > sz then
				ctx:part("FenceRail", V(sx, 0.4, 0.3), CF(mxm, 2.6, mzm), LAMP_METAL, METAL)
				ctx:part("FenceRail", V(sx, 0.4, 0.3), CF(mxm, 1.2, mzm), LAMP_METAL, METAL)
			else
				ctx:part("FenceRail", V(0.3, 0.4, sz), CF(mxm, 2.6, mzm), LAMP_METAL, METAL)
				ctx:part("FenceRail", V(0.3, 0.4, sz), CF(mxm, 1.2, mzm), LAMP_METAL, METAL)
			end
		end
		fenceRun(-100.5, 99.6, 99.4, 99.6) -- z 99.6, B3c-0b: one black run the whole south edge (the arch gap is closed); the posts stay 4 studs clear of the CreditsBoard (it ends at z 95.2)
		fenceRun(99.4, 49.5, 99.4, 99.6) -- B3c-0b: the east side is closed too
	end

------------------------------------------------------------------ Lower-plaza buildings (P1: long cream arcade on the west, the big gabled pavilion)
	local function buildPlazaBuildings(ctx)
		-- (B3c-0: the long west building LongBuildingW that stood here is gone, the owner's red mark.)
		-- The big shade tree on the paver square (plaza drawing and ground photo): a stone planter, a thick trunk and a wide canopy whose bottoms stay above y 12.
		local tx, tz = 45, 68
		post(ctx, "ShadeTreePlanter", 7, 1.2, tx, 0, tz, STONE_LIGHT, CONC)
		post(ctx, "ShadeTreeTrunk", 2.4, 12, tx, 1.2, tz, TRUNK, WOOD)
		for _, c in ipairs({ { 0, 19, 0, 13 }, { 5, 18.5, -2, 10 }, { -5, 18.5, 2, 10 }, { 0, 18.5, 4, 9 }, { -2, 19.5, -5, 10 } }) do
			ctx:ball("ShadeTreeCanopy", c[4], CF(tx + c[1], c[2], tz + c[3]), GREEN, Enum.Material.Grass)
		end
		-- The Lipa Cultural Center (plaza drawing): a long 2-storey cream block down the plaza's EAST edge (x 76..98, z 64..94) with a flat parapet and arched windows
		-- on the plaza (west) and south faces; the door and its steps face the plaza; z < 64 stays open for Road C.
		do
			local x0, x1, z0, z1, H = -98, -76, 64, 94, 24 -- B3c-0b (green mark): the plaza's WEST side, door, steps and beds on the east face
			local cxm, czm = (x0 + x1) / 2, (z0 + z1) / 2
			ctx:part("CulturalCenterBody", V(x1 - x0, H, z1 - z0), CF(cxm, H / 2, czm), CREAM_CC, CONC)
			ctx:part("CulturalCenterPlinth", V(x1 - x0 + 0.8, 1.2, z1 - z0 + 0.8), CF(cxm, 0.6, czm), TRIM, CONC)
			ctx:part("CulturalCenterBand", V(x1 - x0 + 0.8, 0.8, z1 - z0 + 0.8), CF(cxm, H / 2 + 0.4, czm), TRIM, CONC)
			ctx:part("CulturalCenterCornice", V(x1 - x0 + 1.6, 1.2, z1 - z0 + 1.6), CF(cxm, H + 0.6, czm), TRIM, CONC)
			ctx:part("CulturalCenterParapet", V(x1 - x0 + 0.4, 1.8, z1 - z0 + 0.4), CF(cxm, H + 2.1, czm), WHITE, CONC)
			for _, x in ipairs({ -92, -86, -80 }) do
				arched(ctx, "CCWin", V(x, 1.8, z1), 0, 2.8, 7)
				arched(ctx, "CCWin", V(x, 13.8, z1), 0, 2.8, 7.4)
			end
			for _, z in ipairs({ 68, 73.5, 84.5, 90 }) do arched(ctx, "CCWin", V(x1, 1.8, z), PI / 2, 2.8, 7) end
			for _, z in ipairs({ 68, 73.5, 79, 84.5, 90 }) do arched(ctx, "CCWin", V(x1, 13.8, z), PI / 2, 2.8, 7.4) end
			arched(ctx, "CCDoor", V(x1, 0.6, 79), PI / 2, 3.4, 9.5)
			for _, z in ipairs({ 64.5, 70.8, 76.2, 81.8, 87.2, 93.5 }) do
				ctx:part("CulturalCenterPilaster", V(0.8, H - 1.6, 1.0), CF(x1 + 0.2, H / 2, z), TRIM, CONC)
			end
			ctx:part("CulturalCenterSteps", V(2.4, 0.8, 9), CF(x1 + 1.4, 0.4, 79), STONE_LIGHT, CONC)
		end
		-- The open-air stage pavilion (B3c-0, the owner's orange mark): on the plaza centre line near the south edge, just inside the Welcome Arch, open side facing NORTH, white back wall on the south
		-- long side, a raised dais under a big dark peaked roof on posts, gables at both ends. Dais x -13..13, z 82.5..94.5: 2 studs from the mound (z 80.5), 4.8 studs from the south fence line
		-- (z 99.3), so walkers coming through the arch slide round either end. The roof ridge runs along X; the eaves stay clear of the fence (roof edge z 94.8).
		do
			local px, pz, DAIS = 0, 88.5, 1.6
			local topY0 = DAIS + 11 -- post tops / eave line
			local rise, run = 5, 6
			local theta = math.atan(rise / run)
			local slope = math.sqrt(run * run + rise * rise) + 0.9
			ctx:part("StageDais", V(26, DAIS, 12), CF(px, DAIS / 2, pz), STONE_LIGHT, CONC)
			ctx:part("StageStep", V(1.6, 0.8, 6), CF(px + 13.8, 0.4, pz - 2), STONE, CONC) -- at the east end of the dais, so the north side stays a clear lane
			for _, x in ipairs({ px - 12, px - 6, px, px + 6, px + 12 }) do
				for _, dz in ipairs({ -5, 5 }) do
					post(ctx, "StagePavilionPost", 0.9, 11, x, DAIS, pz + dz, WHITE, CONC)
				end
			end
			for _, dz in ipairs({ -5, 5 }) do
				ctx:part("StageBeam", V(26.6, 0.7, 0.8), CF(px, topY0 + 0.3, pz + dz), STAGE_RIB, CONC)
			end
			for _, s in ipairs({ -1, 1 }) do
				local cf = CF(px, topY0 + rise / 2 + 0.55, pz + s * run / 2) * ANG(s * theta, 0, 0)
				ctx:part(s < 0 and "StageRoofL" or "StageRoofR", V(27.4, 0.6, slope), cf, STAGE_ROOF, ROOFMAT)
				for k = 0, 9 do
					ctx:part("StageRoofRib", V(0.45, 0.3, slope), cf * CF(-11.7 + k * 2.6, 0.42, 0), STAGE_RIB, ROOFMAT)
				end
			end
			ctx:part("StageRidge", V(27.6, 0.8, 1.2), CF(px, topY0 + rise + 0.9, pz), STAGE_RIB, ROOFMAT)
			ctx:part("StageBackWall", V(25.6, 11, 0.6), CF(px, DAIS + 5.5, pz + 5.7), WHITE, CONC)
			for _, sx in ipairs({ -1, 1 }) do
				ctx:gable("StageGable", 11.4, rise + 0.3, 0.6, CF(px + sx * 12.7, topY0 + 0.65, pz) * ANG(0, PI / 2, 0), WHITE, CONC)
			end
		end
	end

	------------------------------------------------------------------ Benches, lamps, flagpole (upper level, origin raised)
	local function buildBenches(ctx)
		-- Round 2: the lot has no benches (asphalt bays); three benches stand on the walled garden's paths, facing each other across them.
		local spots = { { 88, 30, 0 }, { 79, 20, PI / 2 }, { 79, 40, -PI / 2 } }
		for _, s in ipairs(spots) do
			local cf = CF(s[1], 0, s[2]) * ANG(0, s[3], 0)
			ctx:part("BenchSeat", V(6, 0.5, 2), cf * CF(0, 1.75, 0), TIMBER, WOOD)
			ctx:part("BenchBack", V(6, 2, 0.4), cf * CF(0, 3, 0.9), TIMBER, WOOD)
			ctx:part("BenchLegL", V(0.5, 1.5, 1.8), cf * CF(-2.5, 0.75, 0), LAMP_METAL, METAL)
			ctx:part("BenchLegR", V(0.5, 1.5, 1.8), cf * CF(2.5, 0.75, 0), LAMP_METAL, METAL)
		end
	end

	local function buildLamps(ctx)
		local spots = {}
		for _, z in ipairs({ 14, 30, 44 }) do
			table.insert(spots, { -14, z })
			table.insert(spots, { 14, z })
		end
		for _, p in ipairs({ { -62, 30 }, { 84, 30 }, { 79, 14 }, { 79, 45 } }) do
			table.insert(spots, p)
		end
		for _, s in ipairs(spots) do
			post(ctx, "LampBase", 1.8, 1.2, s[1], 0, s[2], LAMP_METAL, METAL)
			post(ctx, "LampPole", 0.6, 10, s[1], 1.2, s[2], LAMP_METAL, METAL)
			post(ctx, "LampCollar", 1.6, 0.5, s[1], 11.2, s[2], LAMP_METAL, METAL)
			ctx:ball("LampGlobe", 2.2, CF(s[1], 12.6, s[2]), LAMP_GLOW, Enum.Material.Neon)
		end
	end

	local function buildFlagpole(ctx)
		local px, pz = 72, 30 -- on the garden's east-west path, west end (the Flagpole stays near x 70)
		post(ctx, "FlagBase", 4, 0.8, px, 0, pz, STONE_DARK, CONC)
		post(ctx, "FlagPole", 0.7, 26, px, 0.8, pz, LAMP_METAL, METAL)
		ctx:ball("FlagFinial", 1.4, CF(px, 27.5, pz), Color3.fromRGB(230, 190, 70), METAL)
		ctx:part("FlagBlue", V(0.2, 2.2, 9), CF(px, 25.2, pz + 4.85), Color3.fromRGB(0, 56, 168), PLAS)
		ctx:part("FlagRed", V(0.2, 2.2, 9), CF(px, 23, pz + 4.85), Color3.fromRGB(206, 17, 38), PLAS)
	end

------------------------------------------------------------------ EventStage = the three flights down the retaining wall, the brick seating tiers and the side stairs (plaza drawing)
	local function buildStage(ctx)
		-- World coordinates (ground origin). Round 4 (plaza drawing: the red-brick retaining wall with steps; no fountain, no kiosks): three flights of steps down the wall,
		-- 4 treads each with tops 4, 3, 2, 1 and risers of exactly 1 stud: one either side of the walkway and one in the middle (x -8..8, where round 2 had the fountain).
		-- Seating tiers run on from the flights: 4 tiers of 3-stud treads, risers of 1 stud (the east side is the longer one). Side stairs at both podium ends give street
		-- access (Roads A, C). The folder keeps the name EventStage because SiteData lists it.
		for k = 1, 4 do
			local z = WALL_Z + 2 * (k - 1) + 1
			ctx:part("StairFlightL", V(14, RAISE - k, 2), CF(-19, (RAISE - k) / 2, z), STONE, CONC) -- B3c-0b: the middle flight is gone (the statue stands there), the side flights moved out 4 studs
			ctx:part("StairFlightR", V(14, RAISE - k, 2), CF(19, (RAISE - k) / 2, z), STONE, CONC)
		end
		for k = 1, 4 do
			local z = WALL_Z + 3 * (k - 1) + 1.5
			ctx:part("BleacherL", V(50, RAISE - k, 3), CF(-51, (RAISE - k) / 2, z), BLEACH, CONC)
			ctx:part("BleacherR", V(72, RAISE - k, 3), CF(62, (RAISE - k) / 2, z), BLEACH, CONC)
		end
		for k = 1, 4 do
			local x = 120 + 2 * (k - 1) + 1
			ctx:part("SideStairsE", V(2, RAISE - k, 12), CF(x, (RAISE - k) / 2, 26), STONE, CONC)
			ctx:part("SideStairsW", V(2, RAISE - k, 12), CF(-x, (RAISE - k) / 2, 26), STONE, CONC)
		end
	end

	------------------------------------------------------------------ Parked vehicles (P1/P2 and the plaza drawing): about 30 cheap cars (4 parts each) on the asphalt lot; the lower plaza is open
	-- Muted colours (the drawing's cars are whites, silvers, greys and dull blues, reds and greens).
	local CAR_COLORS = {
		Color3.fromRGB(232, 232, 228), Color3.fromRGB(206, 208, 212), Color3.fromRGB(150, 156, 164), Color3.fromRGB(96, 100, 108),
		Color3.fromRGB(150, 64, 60), Color3.fromRGB(64, 84, 120), Color3.fromRGB(188, 172, 120), Color3.fromRGB(92, 112, 96),
		Color3.fromRGB(122, 104, 86), Color3.fromRGB(232, 232, 228), Color3.fromRGB(206, 208, 212),
	}
	local function carSlots()
		-- Obstacles (x0, x1, z0, z1): the statues, the monument, the lamp posts, and every kept prop (Guide, InfoPanel, JeepStop, sign, Jeepney).
		local obs = {}
		local function add(cx, cz, hx, hz) table.insert(obs, { cx - hx, cx + hx, cz - hz, cz + hz }) end
		for _, s in ipairs(STATUES) do add(s[1], s[2], 1.6, 1.6) end
		add(-10, 40, 3.4, 3.4)
		for _, z in ipairs({ 14, 30, 44 }) do add(-14, z, 1.4, 1.4) add(14, z, 1.4, 1.4) end
		add(-62, 30, 1.4, 1.4)
		add(-109.5, 26, 11.3, 5.8) -- B3c-0b: the entry walkways (west x -120..-99, east x 91.5..120, z 21..31) stay free of cars
		add(105.75, 26, 14.8, 5.8)
		for _, c in ipairs(site:GetChildren()) do
			if not REPLACED[c.Name] then
				local cf, size
				if c:IsA("Model") then cf, size = c:GetBoundingBox() elseif c:IsA("BasePart") then cf, size = c.CFrame, c.Size end
				if cf then
					local ex = (math.abs(cf.RightVector.X) * size.X + math.abs(cf.UpVector.X) * size.Y + math.abs(cf.LookVector.X) * size.Z) / 2
					local ez = (math.abs(cf.RightVector.Z) * size.X + math.abs(cf.UpVector.Z) * size.Y + math.abs(cf.LookVector.Z) * size.Z) / 2
					add(cf.Position.X, cf.Position.Z, ex + 0.8, ez + 0.8)
				end
			end
		end
		local slots = {}
		for rowIdx, rowZ in ipairs({ 19, 41 }) do
			for j = 0, 26 do
				local cx = -95 + j * 6
				if cx <= -17 or cx >= 19 then
					local blocked = false
					for _, o in ipairs(obs) do
						if cx + 2.4 > o[1] and cx - 2.4 < o[2] and rowZ + 5.2 > o[3] and rowZ - 5.2 < o[4] then blocked = true break end
					end
					if not blocked and (j * 7 + rowIdx * 3) % 7 ~= 0 then
						table.insert(slots, { cx, rowZ, rowIdx == 1 and 0 or PI, CAR_COLORS[(j * 5 + rowIdx * 3) % #CAR_COLORS + 1] })
					end
				end
			end
		end
		-- B3c-0b magenta: the NW lot, 19 cars in two staggered rows (the aisle between them is z -31..-13), skipping anything that would stand on an obstacle.
		for rIdx, row in ipairs(NW_ROWS) do
			for j = 0, row.n do
				local cx, blocked = row.x0 + j * 6, false
				for _, o in ipairs(obs) do
					if cx + 2.4 > o[1] and cx - 2.4 < o[2] and row.z + 5.2 > o[3] and row.z - 5.2 < o[4] then blocked = true break end
				end
				if not blocked then table.insert(slots, { cx, row.z, row.yaw, CAR_COLORS[(j * 3 + rIdx * 5) % #CAR_COLORS + 1] }) end
			end
		end
		return slots
	end
	local function buildVehicles()
		local folder = Instance.new("Folder")
		folder.Name = "ParkedVehicles"
		local total = 0
		for i, spec in ipairs(carSlots()) do
			local model = Instance.new("Model")
			model.Name = "Vehicle" .. i
			local ctx = BuildKit.new(model, CF(spec[1], RAISE, spec[2]) * ANG(0, spec[3], 0), { budget = PART_BUDGET - used - total })
			ctx:part("VehicleBody", V(4.4, 2.6, 10), CF(0, 2.2, 0), spec[4], PLAS)
			ctx:part("VehicleCabin", V(4.0, 1.9, 5.6), CF(0, 4.45, -0.6), spec[4], PLAS)
			ctx:part("VehicleGlass", V(4.05, 1.1, 5.0), CF(0, 4.6, -0.6), GLASS, Enum.Material.Glass)
			ctx:part("VehicleUnder", V(4.0, 1.1, 8.4), CF(0, 0.55, 0), LAMP_METAL, PLAS)
			ctx:flush()
			total += ctx:count()
			model.Parent = folder
		end
		return folder, total
	end

------------------------------------------------------------------ Plaza people (idle R15 rigs)
	local function buildPeople()
		local folder = Instance.new("Folder")
		folder.Name = "PlazaPeople"
		local skins = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60), Color3.fromRGB(241, 194, 125) }
		local shirts = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(60, 100, 170), Color3.fromRGB(230, 200, 80), Color3.fromRGB(90, 150, 100) }
		local spots = { { -18, 36, 0.4, true }, { 20, 44, -0.5, true }, { -34, 66, 2.6 }, { 30, 66, 3.4 } } -- x, z, yaw, on the upper level?
		for i, s in ipairs(spots) do
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = skins[i]
			desc.TorsoColor, desc.LeftArmColor, desc.RightArmColor = shirts[i], shirts[i], shirts[i]
			desc.LeftLegColor, desc.RightLegColor = Color3.fromRGB(50, 50, 70), Color3.fromRGB(50, 50, 70)
			local rig = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
			desc:Destroy()
			rig.Name = "Visitor" .. i
			for _, d in ipairs(rig:GetDescendants()) do
				if d:IsA("BasePart") then d.Anchored = false end
			end
			local hrp = rig:WaitForChild("HumanoidRootPart")
			local hum = rig:FindFirstChildOfClass("Humanoid")
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.WalkSpeed = 0
			rig.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
			rig:SetAttribute("SiteId", row.id)
			rig:PivotTo(CF(s[1], groundAt(s[1], s[2]) + 3 + (s[4] and RAISE or 0), s[2]) * ANG(0, s[3], 0))
			hrp.Anchored = true
			rig.Parent = folder
		end
		return folder
	end

	------------------------------------------------------------------ Build, then swap
	local people, vehicles
	local ok, err = pcall(function()
		component("Podium", "Site", buildPodium)
		component("Facade", "Structure", buildFacade, UPPER)
		component("Tower", "Structure", buildTower, UPPER)
		component("Nave", "Structure", buildNave, UPPER)
		component("Dome", "Structure", buildDome, UPPER)
		component("Wing", "Structure", buildWing, UPPER)
		component("Plaza", "Site", buildPlazaUpper, UPPER)
		component("ChurchAnnex", "Site", buildChurchAnnex, UPPER)
		component("WestFence", "Site", buildWestFence)
		component("PlazaLower", "Site", buildPlazaLower)
		component("PlazaBuildings", "Site", buildPlazaBuildings)
		component("Benches", "Site", buildBenches, UPPER)
		component("Lamps", "Site", buildLamps, UPPER)
		component("Flagpole", "Site", buildFlagpole, UPPER)
		component("EventStage", "Site", buildStage)
		local vehicleParts
		vehicles, vehicleParts = buildVehicles()
		used += vehicleParts
		table.insert(built, { name = "ParkedVehicles", parent = "Site", model = vehicles, parts = vehicleParts })
		people = buildPeople()
		local peopleParts = countParts(people)
		used += peopleParts
		table.insert(built, { name = "PlazaPeople", parent = "Site", model = people, parts = peopleParts })
		assert(used <= PART_BUDGET, string.format("site01: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, b in ipairs(built) do b.model:Destroy() end
		if people then people:Destroy() end
		if vehicles then vehicles:Destroy() end
		error("site01: build failed, the placeholder Block was left untouched: " .. tostring(err), 0)
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

	-- The kept props (Guide, InfoPanel, JeepStop, its sign and jeepney) move up to the forecourt. The attribute makes this idempotent.
	for _, child in ipairs(site:GetChildren()) do
		if not REPLACED[child.Name] then
			local delta = RAISE - (child:GetAttribute("Site01Raise") or 0)
			if delta ~= 0 then
				if child:IsA("Model") then
					child:PivotTo(child:GetPivot() + V(0, delta, 0))
				elseif child:IsA("BasePart") then
					child.CFrame = child.CFrame + V(0, delta, 0)
				end
				child:SetAttribute("Site01Raise", RAISE)
			end
		end
	end

	local pivotAfter = site:GetPivot()
	assert((pivotAfter.Position - pivotBefore.Position).Magnitude < 1e-3 and pivotAfter.LookVector:Dot(pivotBefore.LookVector) > 0.9999,
		"site01: the site pivot changed during the build")

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
