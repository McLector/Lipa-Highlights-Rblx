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
-- Plaza Independencia); the retaining wall at z 56 drops to the lower plaza through two flights of 1-stud risers and a landing.
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
	local WALL_Z = 56 -- the retaining wall: the podium's south face
	local UPPER = CF(0, RAISE, 0) -- origin of every component that stands on the podium
	local REPLACED = {
		Block = true, Structure = true, Plaza = true, PlazaBuildings = true, PlazaPeople = true, ParkedVehicles = true,
		WelcomeArch = true, Benches = true, Lamps = true, Flagpole = true, EventStage = true, Podium = true, PlazaLower = true,
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
		l.TextScaled = true
		l.Font = Enum.Font.GothamBold
		l.Text = text
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
		ctx:part("Podium", V(240, RAISE, 156), CF(0, RAISE / 2, WALL_Z - 78), STONE, CONC)
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

	------------------------------------------------------------------ Upper level (origin raised): the wide car-park forecourt, monument, garden
	local PALMS_UP = { { 68, 13 }, { 68, 53 }, { 42, 33 }, { 96, 33 }, { -34, 16 }, { 34, 16 } }
	local GARDEN_BEDS = { { 40, 14 }, { 72, 14 }, { 40, 34 }, { 72, 34 } } -- x, z of each bed's NW corner; 24 x 18 studs
	local function buildPlazaUpper(ctx)
		-- local y 0 is the podium top. The forecourt is asphalt grey with painted bays (P1), a light walkway on the church axis.
		ctx:part("ApronPaving", V(200, 0.1, 46), CF(0, 0.05, 33), Color3.fromRGB(104, 106, 112), CONC) -- z 10..56
		ctx:part("Walkway", V(14, 0.06, 46), CF(0, 0.13, 33), STONE_LIGHT, CONC)
		-- Parapet caps the retaining wall on both sides of the stairs and the landing (x +-62 and beyond).
		ctx:part("Parapet", V(58, 1.4, 1.6), CF(-91, 0.7, WALL_Z - 0.8), STONE_LIGHT, CONC)
		ctx:part("Parapet", V(58, 1.4, 1.6), CF(91, 0.7, WALL_Z - 0.8), STONE_LIGHT, CONC)
		-- Hedges flanking the tower front and the wing front (gap x 44..61 for the pavilion's steps).
		ctx:part("HedgeTowerW", V(8, 1.8, 2), CF(-43, 0.95, 9), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeTowerE", V(8, 1.8, 2), CF(-25, 0.95, 9), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeWingW", V(20, 1.8, 2), CF(33, 0.95, 3.5), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeWingE", V(34, 1.8, 2), CF(81, 0.95, 3.5), HEDGE, Enum.Material.Grass)
		-- Painted parking bays west of the walkway: two rows of 8 bays (9 lines each), an aisle line, and the hatch on the right.
		for _, rowZ in ipairs({ 19, 41 }) do
			for i = 0, 8 do
				ctx:part("ParkingBayLine", V(0.3, 0.1, 10), CF(-92 + i * 6, 0.15, rowZ), YELLOW, PLAS)
			end
		end
		ctx:part("ParkingAisleLine", V(48, 0.1, 0.3), CF(-68, 0.15, 30), YELLOW, PLAS)
		for k = 0, 5 do
			ctx:part("ApronMarking", V(0.4, 0.1, 7), CF(14 + k * 5, 0.15, 46) * ANG(0, 0.6, 0), YELLOW, PLAS)
		end
		-- The saint's monument on a plinth, off the walkway.
		local mx, mz = -10, 40
		ctx:part("MonumentPlinth", V(5.4, 1.4, 5.4), CF(mx, 0.7, mz), STONE_DARK, CONC)
		ctx:part("Monument", V(3.4, 5, 3.4), CF(mx, 3.9, mz), STONE_LIGHT, CONC)
		ctx:part("MonumentCap", V(4.2, 0.6, 4.2), CF(mx, 6.7, mz), STONE_DARK, CONC)
		ctx:part("MonumentStatue", V(1.4, 3.6, 1.0), CF(mx, 8.8, mz), WHITE, CONC)
		ctx:ball("MonumentHead", 1.3, CF(mx, 11.3, mz), WHITE, CONC)
		-- Hedged garden (east of the forecourt): a lawn slab, four hedged beds, a path cross at x 68 / z 33.
		ctx:part("GardenLawn", V(62, 0.12, 42), CF(68, 0.06, 31), LAWN, Enum.Material.Grass)
		ctx:part("GardenPathNS", V(8, 0.14, 42), CF(68, 0.07, 31), STONE_LIGHT, CONC)
		ctx:part("GardenPathEW", V(62, 0.14, 4), CF(68, 0.07, 33), STONE_LIGHT, CONC)
		for _, b in ipairs(GARDEN_BEDS) do
			local bx, bz, bw, bd = b[1], b[2], 24, 18
			ctx:part("GardenHedge", V(bw, 1.8, 1.6), CF(bx + bw / 2, 0.9, bz), HEDGE, Enum.Material.Grass)
			ctx:part("GardenHedge", V(bw, 1.8, 1.6), CF(bx + bw / 2, 0.9, bz + bd), HEDGE, Enum.Material.Grass)
			ctx:part("GardenHedge", V(1.6, 1.8, bd), CF(bx, 0.9, bz + bd / 2), HEDGE, Enum.Material.Grass)
			ctx:part("GardenHedge", V(1.6, 1.8, bd), CF(bx + bw, 0.9, bz + bd / 2), HEDGE, Enum.Material.Grass)
		end
		-- The rest of the podium top: lawn with a few palms west of the tower and behind the wing (P1: the compound is green).
		ctx:part("PodiumLawn", V(70, 0.12, 106), CF(-83, 0.06, -45), LAWN, Enum.Material.Grass)
		ctx:part("PodiumLawn", V(98, 0.12, 58), CF(71, 0.06, -70), LAWN, Enum.Material.Grass)
		for i, p in ipairs({ { -100, -60 }, { -100, -28 }, { -100, 0 }, { -72, -66 }, { -72, -36 }, { 60, -72 } }) do palm(ctx, i + 40, p[1], p[2]) end
		for i, p in ipairs(PALMS_UP) do palm(ctx, i, p[1], p[2]) end
	end

	------------------------------------------------------------------ Lower level (ground): Plaza Independencia below the wall
	local PALMS_LOW = { { 34, 92 }, { 44, 92 }, { 54, 92 }, { 64, 92 }, { 76, 92 }, { 88, 92 }, { -44, 92 }, { -58, 92 }, { -72, 92 }, { -84, 92 } }
	local TENTS = { { 72, 76, WHITE }, { 80, 76, Color3.fromRGB(60, 100, 170) }, { 88, 76, WHITE }, { 76, 85, Color3.fromRGB(60, 100, 170) } }
	local function buildPlazaLower(ctx)
		ctx:part("ForecourtPaving", V(200, 0.1, 44), CF(0, 0, 78), STONE, CONC) -- z 56..100: the repainted Pavement (x +-100, z 0..100)
		-- Kerb (0.3 high) round the lower plaza. The south kerb leaves a gap at x +-8 for the E_to_Tagbakin road mouth at (0,100).
		ctx:part("KerbWest", V(0.6, 0.3, 44), CF(-100.3, 0.15, 78), STONE_LIGHT, CONC)
		ctx:part("KerbEast", V(0.6, 0.3, 44), CF(100.3, 0.15, 78), STONE_LIGHT, CONC)
		ctx:part("KerbSouthW", V(92, 0.3, 0.6), CF(-54, 0.15, 100.3), STONE_LIGHT, CONC)
		ctx:part("KerbSouthE", V(92, 0.3, 0.6), CF(54, 0.15, 100.3), STONE_LIGHT, CONC)
		-- The open light slab on the east (P1) and the market tents on it.
		ctx:part("PlazaSlab", V(32, 0.06, 22), CF(80, 0.13, 80), STONE_LIGHT, CONC)
		for _, t in ipairs(TENTS) do
			ctx:part("PlazaTent", V(6, 0.3, 6), CF(t[1], 9.3, t[2]), t[3], PLAS)
			for _, dx in ipairs({ -2.7, 2.7 }) do
				for _, dz in ipairs({ -2.7, 2.7 }) do
					ctx:part("TentPost", V(0.3, 9, 0.3), CF(t[1] + dx, 4.5, t[2] + dz), WHITE, METAL)
				end
			end
		end
		for i, p in ipairs(PALMS_LOW) do palm(ctx, i + 20, p[1], p[2]) end
		-- Lamps on the lower plaza.
		for _, s in ipairs({ { -46, 66 }, { 46, 66 }, { -80, 66 }, { 90, 66 } }) do
			post(ctx, "LampBase", 1.8, 1.2, s[1], 0, s[2], LAMP_METAL, METAL)
			post(ctx, "LampPole", 0.6, 10, s[1], 1.2, s[2], LAMP_METAL, METAL)
			post(ctx, "LampCollar", 1.6, 0.5, s[1], 11.2, s[2], LAMP_METAL, METAL)
			ctx:ball("LampGlobe", 2.2, CF(s[1], 12.6, s[2]), LAMP_GLOW, Enum.Material.Neon)
		end
		-- White perimeter fence (P1): the south side with the road-mouth gap at x +-8, and the east side.
		local function fenceRun(x0, z0, x1, z1)
			local len = (V(x1, 0, z1) - V(x0, 0, z0)).Magnitude
			local n = math.max(1, math.floor(len / 6))
			for i = 0, n do
				local t = i / n
				ctx:part("FencePost", V(0.6, 3.2, 0.6), CF(x0 + (x1 - x0) * t, 1.6, z0 + (z1 - z0) * t), WHITE, CONC)
			end
			local mxm, mzm = (x0 + x1) / 2, (z0 + z1) / 2
			local sx, sz = math.abs(x1 - x0) + 0.4, math.abs(z1 - z0) + 0.4
			if sx > sz then
				ctx:part("FenceRail", V(sx, 0.4, 0.3), CF(mxm, 2.6, mzm), WHITE, CONC)
				ctx:part("FenceRail", V(sx, 0.4, 0.3), CF(mxm, 1.2, mzm), WHITE, CONC)
			else
				ctx:part("FenceRail", V(0.3, 0.4, sz), CF(mxm, 2.6, mzm), WHITE, CONC)
				ctx:part("FenceRail", V(0.3, 0.4, sz), CF(mxm, 1.2, mzm), WHITE, CONC)
			end
		end
		fenceRun(-96, 99.4, -10, 99.4)
		fenceRun(10, 99.4, 96, 99.4)
		fenceRun(99.4, 60, 99.4, 99)
	end

	------------------------------------------------------------------ Lower-plaza buildings (P1: long cream arcade on the west, the big gabled pavilion)
	local function buildPlazaBuildings(ctx)
		-- West: a long two-storey cream building with arched windows facing the plaza, a maroon hip roof (z 58..98).
		local bx, z0, z1, bays = -92, 58, 98, 5
		local len, zc = z1 - z0, (z0 + z1) / 2
		ctx:part("LongBuildingW", V(14, 24, len), CF(bx, 12, zc), WALL_PALE, CONC)
		ctx:part("LongBuildingWBand", V(15, 1, len + 1), CF(bx, 12.5, zc), TRIM, CONC)
		ctx:part("LongBuildingWEave", V(16, 1.2, len + 2), CF(bx, 24.4, zc), TRIM, CONC)
		local face = bx + 7 -- the east face, toward the plaza
		for i = 1, bays do
			local z = z0 + (i - 0.5) * (len / bays)
			arched(ctx, "LongWinLow", V(face, 1.5, z), PI / 2, 3.6, 8.5)
			arched(ctx, "LongWinUp", V(face, 13.5, z), PI / 2, 3.6, 8)
		end
		for i = 0, bays do
			ctx:part("LongPilaster", V(0.9, 22, 1.2), CF(face + 0.4, 11.5, z0 + i * (len / bays)), TRIM, CONC)
		end
		local run, rise = 8.4, 4
		local rlen = math.sqrt(run * run + rise * rise)
		local th = math.atan(rise / run)
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("LongRoof", V(rlen, 0.6, len + 2), CF(bx + s * run / 2, 24.6 + rise / 2, zc) * ANG(0, 0, -s * th), ROOF_DARK, ROOFMAT)
		end
		ctx:part("LongRidge", V(1, 0.9, len + 2), CF(bx, 28.7, zc), TRIM, CONC)
		-- The pavilion (P1): a low hall under a big grey-brown gabled roof, with palms in front. x 22..64, z 72..88.
		local cx, cz = 43, 80
		ctx:part("CivicBuildingS", V(42, 8, 16), CF(cx, 4, cz), WALL_PALE, CONC)
		ctx:part("CivicEave", V(44, 0.8, 18), CF(cx, 8.4, cz), TRIM, CONC)
		for i = 1, 5 do
			arched(ctx, "CivicWin", V(cx - 21 + i * 7, 1.5, cz - 8), PI, 3.2, 5.4)
		end
		local prun, prise = 9.4, 6.6
		local plen = math.sqrt(prun * prun + prise * prise)
		local pth = math.atan(prise / prun)
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("CivicRoof", V(44, 0.6, plen), CF(cx, 8.8 + prise / 2, cz + s * prun / 2) * ANG(-s * pth, 0, 0), PAVROOF, ROOFMAT)
		end
		ctx:part("CivicRidge", V(44, 0.8, 0.9), CF(cx, 8.8 + prise + 0.2, cz), TRIM, CONC)
		ctx:gable("CivicGableW", 16.4, prise, 0.8, CF(cx - 22, 8.4, cz) * ANG(0, PI / 2, 0), WALL_PALE, CONC)
		ctx:gable("CivicGableE", 16.4, prise, 0.8, CF(cx + 22, 8.4, cz) * ANG(0, PI / 2, 0), WALL_PALE, CONC)
	end

	------------------------------------------------------------------ Welcome Arch (P6): wrought-iron arch on stone gateposts, at the road mouth
	local function buildWelcomeArch(ctx)
		local z = 100 -- the posts (z 98.8..101.2) stay clear of the CreditsBoard strip, which ends at z 98.5
		local R = 7.4
		local baseY = 12
		for _, s in ipairs({ -1, 1 }) do
			ctx:part(s < 0 and "GatepostL" or "GatepostR", V(2.4, baseY, 2.4), CF(s * (R + 1.2), baseY / 2, z), STONE_DARK, CONC)
			ctx:part("GatepostCap", V(2.8, 0.8, 2.8), CF(s * (R + 1.2), baseY + 0.4, z), STONE_LIGHT, CONC)
			ctx:part("GatepostPlinth", V(2.8, 1.2, 2.8), CF(s * (R + 1.2), 0.6, z), STONE_LIGHT, CONC)
		end
		-- Two concentric iron arcs (outer R, inner R - 1.1) built from short bars.
		local seg = 16
		for _, radius in ipairs({ R, R - 1.1 }) do
			for k = 0, seg - 1 do
				local a0, a1 = k * PI / seg, (k + 1) * PI / seg
				local p0 = V(radius * math.cos(a0), radius * math.sin(a0), 0)
				local p1 = V(radius * math.cos(a1), radius * math.sin(a1), 0)
				local mid = (p0 + p1) / 2
				local blen = (p1 - p0).Magnitude + 0.1
				local phi = math.atan2(p1.Y - p0.Y, p1.X - p0.X)
				ctx:part("ArchIron", V(blen, 0.35, 0.35), CF(mid.X, baseY + mid.Y, z) * ANG(0, 0, phi), IRON, METAL)
			end
		end
		ctx:part("ArchCrossV", V(0.4, 3.2, 0.4), CF(0, baseY + R + 2.2, z), IRON, METAL)
		ctx:part("ArchCrossH", V(2.2, 0.4, 0.4), CF(0, baseY + R + 2.8, z), IRON, METAL)
		-- The wire lettering, as text on a clear plate between the arcs: readable from the plaza and from the street.
		local plate = ctx:part("ArchSign", V(8.4, 4.2, 0.2), CF(0, baseY + 3.8, z), IRON, PLAS)
		plate.Transparency = 1
		local text = "CATEDRAL de SAN SEBASTIAN\n10 de ABRIL 1910\nENTRANCE"
		label(plate, Enum.NormalId.Front, text, IRON, 40)
		label(plate, Enum.NormalId.Back, text, IRON, 40)
		ctx:part("ArchYearL", V(1.8, 0.9, 0.2), CF(-(R + 1.2), 6, z - 1.25), IRON, METAL)
		ctx:part("ArchYearR", V(1.8, 0.9, 0.2), CF(R + 1.2, 6, z - 1.25), IRON, METAL)
	end

	------------------------------------------------------------------ Benches, lamps, flagpole (upper level, origin raised)
	local function buildBenches(ctx)
		-- walkway benches, and benches on the garden path (facing each other across it)
		local spots = { { -24, 40, -PI / 2 }, { -24, 50, -PI / 2 }, { 24, 40, PI / 2 }, { 24, 50, PI / 2 },
			{ 65.5, 24, PI / 2 }, { 70.5, 24, -PI / 2 }, { 65.5, 44, PI / 2 }, { 70.5, 44, -PI / 2 } }
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
		for _, z in ipairs({ 14, 32, 50 }) do
			table.insert(spots, { -14, z })
			table.insert(spots, { 14, z })
		end
		for _, p in ipairs({ { 68, 20 }, { 68, 48 }, { 80, 33 }, { 92, 33 }, { -62, 30 } }) do
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
		local px, pz = 68, 33 -- the garden's path crossing
		post(ctx, "FlagBase", 4, 0.8, px, 0, pz, STONE_DARK, CONC)
		post(ctx, "FlagPole", 0.7, 26, px, 0.8, pz, LAMP_METAL, METAL)
		ctx:ball("FlagFinial", 1.4, CF(px, 27.5, pz), Color3.fromRGB(230, 190, 70), METAL)
		ctx:part("FlagBlue", V(0.2, 2.2, 9), CF(px, 25.2, pz + 4.85), Color3.fromRGB(0, 56, 168), PLAS)
		ctx:part("FlagRed", V(0.2, 2.2, 9), CF(px, 23, pz + 4.85), Color3.fromRGB(206, 17, 38), PLAS)
	end

	------------------------------------------------------------------ EventStage = the central landing and the two flights of steps (P1)
	local function buildStage(ctx)
		-- World coordinates (ground origin). The landing (x +-18, z 56..64) is a solid block at podium height on the wall axis; the
		-- gazebo roof on it faces the lower plaza. Two flights of 4 wide steps (risers of exactly 1 stud) go down on each side.
		ctx:part("StageLanding", V(36, RAISE, 8), CF(0, RAISE / 2, WALL_Z + 4), STONE, CONC)
		for k = 1, 4 do
			local z = WALL_Z + 2 * (k - 1) + 1
			ctx:part("StairsL", V(44, RAISE - k, 2), CF(-40, (RAISE - k) / 2, z), STONE, CONC)
			ctx:part("StairsR", V(44, RAISE - k, 2), CF(40, (RAISE - k) / 2, z), STONE, CONC)
		end
		for _, px in ipairs({ -10.5, 10.5 }) do
			for _, pz in ipairs({ WALL_Z + 1.5, WALL_Z + 6.5 }) do
				ctx:part("StagePost", V(0.8, 9.5, 0.8), CF(px, RAISE + 4.75, pz), LAMP_METAL, METAL)
			end
		end
		ctx:part("StageCanopy", V(26, 0.6, 10), CF(0, RAISE + 9.8, WALL_Z + 4), ROOF, ROOFMAT)
		local fascia = ctx:part("StageFascia", V(26, 2.2, 0.5), CF(0, RAISE + 8.4, WALL_Z + 9), TRIM, CONC)
		label(fascia, Enum.NormalId.Back, "PUBLIC EVENTS", Color3.new(1, 1, 1), 30) -- readable from the lower plaza (the spawn)
	end

	------------------------------------------------------------------ Parked vehicles (P1/P2): cars on the forecourt, vans on the lower plaza; each its own Model
	local VEHICLES = {
		-- x, z, yaw (0 = nose south), body colour, upper level?
		{ -89, 19, 0, Color3.fromRGB(236, 236, 232), true }, { -83, 19, 0, Color3.fromRGB(150, 156, 164), true },
		{ -71, 19, 0, Color3.fromRGB(180, 50, 46), true }, { -65, 19, 0, Color3.fromRGB(236, 236, 232), true },
		{ -89, 41, PI, Color3.fromRGB(40, 60, 110), true }, { -77, 41, PI, Color3.fromRGB(236, 236, 232), true },
		{ -65, 41, PI, Color3.fromRGB(210, 190, 90), true }, { -53, 41, PI, Color3.fromRGB(150, 156, 164), true },
		{ -80, 72, PI, Color3.fromRGB(236, 236, 232), false }, { -74, 72, PI, Color3.fromRGB(236, 236, 232), false },
		{ -68, 72, PI, Color3.fromRGB(150, 156, 164), false }, { -62, 72, PI, Color3.fromRGB(236, 236, 232), false },
		{ -56, 72, PI, Color3.fromRGB(60, 110, 70), false }, { -74, 84, PI, Color3.fromRGB(236, 236, 232), false },
		{ -62, 84, PI, Color3.fromRGB(180, 50, 46), false },
	}
	local function buildVehicles()
		local folder = Instance.new("Folder")
		folder.Name = "ParkedVehicles"
		local total = 0
		for i, spec in ipairs(VEHICLES) do
			local model = Instance.new("Model")
			model.Name = "Vehicle" .. i
			local y = spec[5] and RAISE or 0
			local ctx = BuildKit.new(model, CF(spec[1], y, spec[2]) * ANG(0, spec[3], 0), { budget = PART_BUDGET - used - total })
			ctx:part("VehicleBody", V(4.4, 2.6, 10), CF(0, 2.2, 0), spec[4], PLAS)
			ctx:part("VehicleCabin", V(4.0, 1.9, 5.6), CF(0, 4.45, -0.6), spec[4], PLAS)
			ctx:part("VehicleGlass", V(4.05, 1.1, 5.0), CF(0, 4.6, -0.6), GLASS, Enum.Material.Glass)
			for _, wx in ipairs({ -2.1, 2.1 }) do
				for _, wz in ipairs({ -3.1, 3.1 }) do
					ctx:cyl("VehicleWheel", V(0.8, 2.2, 2.2), CF(wx, 1.1, wz), LAMP_METAL, PLAS)
				end
			end
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
		component("PlazaLower", "Site", buildPlazaLower)
		component("PlazaBuildings", "Site", buildPlazaBuildings)
		component("WelcomeArch", "Site", buildWelcomeArch)
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
