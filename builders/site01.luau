-- site01: Metropolitan Cathedral of San Sebastian + Plaza Independencia (Slice 02). The reference builder the other
-- site builders copy. Studio copy: ServerStorage.Builders.site01; run with
--   require(game.ServerStorage.Builders.site01:Clone())()
-- Run builders/placeholders first (it creates Workspace.Sites.Site01_Cathedral with Guide, InfoPanel, JeepStop...).
-- IDEMPOTENT: replaces Block / Structure / Plaza / PlazaPeople / Benches / Lamps / Flagpole / EventStage and keeps
-- Guide, InfoPanel, JeepStop, JeepSign*, Jeepney. Touches nothing outside Workspace.Sites.Site01_Cathedral.
-- (The terrain under the plaza is repainted as Pavement by builders/world.luau, which owns terrain; PlazaPaving
-- below must stay inside that region: x -100..100, z 0..100.)
-- Brief: briefs/site01.md. Colours come from Cathedral_Front_2024.jpg. World axes: x east, z south (+Z is the
-- facade side), y up; the site pivot is at the origin, and everything is placed in world coordinates.
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
	local REPLACED = {
		Block = true, Structure = true, Plaza = true, PlazaPeople = true,
		Benches = true, Lamps = true, Flagpole = true, EventStage = true,
	}

	-- Colours (Cathedral_Front_2024.jpg).
	local WALL = Color3.fromRGB(233, 214, 165)
	local TRIM = Color3.fromRGB(176, 160, 172)
	local ROOF = Color3.fromRGB(176, 58, 52) -- terracotta, as in the aerial photos (the front photo reads dustier)
	local ROOF_RIB = Color3.fromRGB(198, 78, 66)
	local HEDGE = Color3.fromRGB(52, 110, 56)
	local DOME = Color3.fromRGB(236, 226, 196)
	local RIB = Color3.fromRGB(140, 160, 175)
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
	local CONC, PLAS = Enum.Material.Concrete, Enum.Material.SmoothPlastic
	local METAL, WOOD = Enum.Material.Metal, Enum.Material.Wood

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

	local function component(name, parent, fn)
		local model = Instance.new("Model")
		model.Name = name
		local ctx = BuildKit.new(model, CF(), { budget = PART_BUDGET - used })
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

	local OUT = { { 0, 1, 0 }, { 0, -1, PI }, { 1, 0, PI / 2 }, { -1, 0, -PI / 2 } } -- nx, nz, yaw

	------------------------------------------------------------------ Facade
	local function buildFacade(ctx)
		-- Ground register: wall with the arched door opening, the timber door set back in it, a surround.
		arch(ctx, "FacadeBase", { width = 10, height = 13, depth = 10, wallWidth = 44, wallHeight = 18,
			cframe = CF(0, 9, 0), color = WALL, material = CONC })
		ctx:window("Door", 9.2, 11, 0.8, CF(0, 2, 4.0), TIMBER, WOOD)
		ctx:part("DoorJambL", V(1, 8.5, 0.5), CF(-5.5, 4.25, 5.25), TRIM, CONC)
		ctx:part("DoorJambR", V(1, 8.5, 0.5), CF(5.5, 4.25, 5.25), TRIM, CONC)
		ctx:part("Keystone", V(2, 1.6, 0.6), CF(0, 14.4, 5.3), TRIM, CONC)
		ctx:part("Plaque", V(8, 1.6, 0.4), CF(0, 16.3, 5.2), PANEL, CONC)
		-- Two steps up to the door (risers of 1 stud).
		ctx:part("StepHigh", V(20, 2, 2.4), CF(0, 1, 6.2), STONE, CONC)
		ctx:part("StepLow", V(22, 1, 2.4), CF(0, 0.5, 8.6), STONE, CONC)
		ctx:part("Cornice1", V(46, 1.8, 13), CF(0, 18.9, 1.5), TRIM, CONC)
		-- Second register and its window and relief panels.
		ctx:part("Register2", V(44, 16.2, 10), CF(0, 27.9, 0), WALL, CONC)
		arched(ctx, "ChoirWindow", V(0, 22.2, 5), 0, 6, 11)
		for _, side in ipairs({ -1, 1 }) do
			ctx:part("ReliefFrame", V(4.2, 10, 0.3), CF(side * 16, 27.5, 5.05), TRIM, CONC)
			ctx:part("ReliefPanel", V(3.2, 9, 0.4), CF(side * 16, 27.5, 5.2), PANEL, CONC)
		end
		ctx:part("Cornice2", V(46, 2, 13), CF(0, 37, 1.5), TRIM, CONC)
		-- Paired pilasters: base, shaft, capital on each of the two registers.
		for _, x in ipairs({ -19.5, -12.5, 12.5, 19.5 }) do
			ctx:part("Pil1Base", V(4.2, 1.6, 3), CF(x, 0.8, 6.5), TRIM, CONC)
			ctx:part("Pil1Shaft", V(3, 14.8, 2), CF(x, 9, 6), TRIM, CONC)
			ctx:part("Pil1Cap", V(4.2, 1.6, 3), CF(x, 17.2, 6.5), TRIM, CONC)
			ctx:part("Pil2Base", V(4.2, 1.6, 3), CF(x, 20.6, 6.5), TRIM, CONC)
			ctx:part("Pil2Shaft", V(3, 13, 2), CF(x, 27.9, 6), TRIM, CONC)
			ctx:part("Pil2Cap", V(4.2, 1.6, 3), CF(x, 35.2, 6.5), TRIM, CONC)
		end
		-- Pediment with its raking trim behind, the medallion and the Marian niche.
		ctx:gable("PedimentTrim", 47, 13.4, 10.4, CF(0, 37.8, -0.3), TRIM, CONC)
		ctx:gable("Pediment", 44, 12, 10, CF(0, 38, 0), WALL, CONC)
		ctx:cyl("Medallion", V(0.6, 3.8, 3.8), CF(0, 46.6, 5.15) * ANG(0, PI / 2, 0), PANEL, CONC)
		ctx:cyl("MedallionCore", V(0.8, 2.4, 2.4), CF(0, 46.6, 5.25) * ANG(0, PI / 2, 0), DOME, CONC)
		arched(ctx, "Niche", V(0, 38.4, 5), 0, 3, 5.8)
		ctx:part("Statue", V(1.1, 3, 0.8), CF(0, 40.4, 5.5), WHITE, CONC)
		ctx:ball("StatueHead", 1.1, CF(0, 42.3, 5.5), WHITE, CONC)
		-- Small belfry on the apex, with a cross.
		ctx:part("BelfryBlock", V(6, 4.5, 6), CF(0, 51.75, 0), WALL, CONC)
		ctx:part("BelfryCap", V(7, 0.8, 7), CF(0, 54.4, 0), TRIM, CONC)
		arched(ctx, "BelfryWindow", V(0, 50.4, 3.05), 0, 2, 3.2)
		ctx:ball("BelfryDome", 5, CF(0, 55, 0), DOME, CONC)
		ctx:part("BelfryCrossV", V(0.4, 3, 0.4), CF(0, 58.6, 0), TRIM, METAL)
		ctx:part("BelfryCrossH", V(1.8, 0.4, 0.4), CF(0, 59.2, 0), TRIM, METAL)
	end

	------------------------------------------------------------------ Tower
	local TOWER_X, TOWER_Z = -32, -4
	local function buildTower(ctx)
		local cx, cz = TOWER_X, TOWER_Z
		ctx:part("TowerBase", V(20, 18, 20), CF(cx, 9, cz), WALL, CONC)
		ctx:part("TowerPlinth", V(21.6, 1.6, 21.6), CF(cx, 0.8, cz), TRIM, CONC)
		ctx:part("ScreenFrame", V(13, 8, 0.4), CF(cx, 9.5, cz + 10.2), TRIM, CONC)
		ctx:part("Screen", V(11.6, 6.6, 0.3), CF(cx, 9.5, cz + 10.45), Color3.fromRGB(20, 22, 26), PLAS)
		ctx:part("TowerCornice0", V(22.4, 1.6, 22.4), CF(cx, 18.8, cz), TRIM, CONC)
		-- Three octagonal tiers, each narrower than the one below, with arched openings on the four cardinal faces.
		local tiers = {
			{ r = 8.2, h = 14, ww = 3.6, wh = 7.4 },
			{ r = 7.2, h = 13, ww = 3.4, wh = 6.8 },
			{ r = 6.2, h = 12, ww = 3.0, wh = 6.2 },
		}
		local y = 19.6
		for i, t in ipairs(tiers) do
			ctx:octagonRing("Tier" .. i, t.r, t.h, y, 1.6, WALL, CONC, CF(cx, 0, cz))
			local outer = t.r + 0.8
			for _, o in ipairs(OUT) do
				arched(ctx, "Tier" .. i .. "Win", V(cx + o[1] * outer, y + 3.6, cz + o[2] * outer), o[3], t.ww, t.wh)
			end
			y += t.h
			ctx:octagonRing("Cornice" .. i, outer + 0.5, 1.6, y, 1.8, TRIM, CONC, CF(cx, 0, cz))
			y += 1.6
		end
		-- Ribbed cupola with a finial and a cross.
		ctx:dome("Cupola", 6.9, 8, CF(cx, y, cz), DOME, RIB, CONC)
		ctx:ball("Finial", 2.2, CF(cx, y + 7.8, cz), TRIM, METAL)
		ctx:part("CrossV", V(0.5, 4.4, 0.5), CF(cx, y + 10.1, cz), TRIM, METAL)
		ctx:part("CrossH", V(2.6, 0.5, 0.5), CF(cx, y + 10.7, cz), TRIM, METAL)
	end

	------------------------------------------------------------------ Nave
	local function buildNave(ctx)
		local zc, len = -45.5, 81
		for _, side in ipairs({ -1, 1 }) do
			ctx:part("NaveWall", V(2, 34, len), CF(side * 19, 17, zc), WALL, CONC)
			ctx:part("NaveSkirt", V(3, 1.4, len), CF(side * 19.5, 0.7, zc), TRIM, CONC)
			ctx:part("NaveEaveCornice", V(4.4, 1.5, len + 2), CF(side * 19.4, 34.2, zc), TRIM, CONC)
		end
		-- Windows on the visible bays (the transept and the wing hide the rest) and pilaster strips.
		for _, z in ipairs({ -22, -31, -69, -78 }) do
			arched(ctx, "NaveWinL", V(-20, 11, z), -PI / 2, 4.2, 12)
		end
		for _, z in ipairs({ -69, -78 }) do
			arched(ctx, "NaveWinR", V(20, 11, z), PI / 2, 4.2, 12)
		end
		for _, z in ipairs({ -17, -27, -36, -64, -73.5, -84 }) do
			ctx:part("NavePilasterL", V(1.2, 30, 1.4), CF(-20.4, 16, z), TRIM, CONC)
		end
		for _, z in ipairs({ -64, -73.5, -84 }) do
			ctx:part("NavePilasterR", V(1.2, 30, 1.4), CF(20.4, 16, z), TRIM, CONC)
		end
		-- Gabled roof: two slopes from the eaves (y 34 at x = +-21.5) to the ridge (y 46), with ribs.
		local run, rise = 21.5, 12
		local len2 = math.sqrt(run * run + rise * rise)
		local theta = math.atan(rise / run)
		for _, side in ipairs({ -1, 1 }) do
			local cf = CF(side * run / 2, 34 + rise / 2, zc) * ANG(0, 0, -side * theta)
			ctx:part("NaveRoof", V(len2, 0.6, len + 4), cf, ROOF, METAL)
			for z = -6, -86, -3 do
				ctx:part("NaveRoofRib", V(len2, 0.35, 0.6), cf * CF(0, 0.45, z - zc), ROOF_RIB, METAL)
			end
		end
		ctx:part("NaveRidge", V(1.4, 1.2, len + 4), CF(0, 46.3, zc), TRIM, CONC)
		ctx:gable("NaveBackGable", 40, 12, 1.5, CF(0, 34, -86.5), WALL, CONC)
		-- Rounded apse with a stepped roof.
		ctx:cyl("Apse", V(34, 40, 40), CF(0, 17, -86) * ANG(0, 0, PI / 2), WALL, CONC)
		ctx:cyl("ApseCornice", V(1.4, 41.6, 41.6), CF(0, 34, -86) * ANG(0, 0, PI / 2), TRIM, CONC)
		post(ctx, "ApseRoof1", 38, 2.4, 0, 34.7, -86, ROOF, METAL)
		post(ctx, "ApseRoof2", 28, 2.4, 0, 37.1, -86, ROOF, METAL)
		post(ctx, "ApseRoof3", 16, 2.4, 0, 39.5, -86, ROOF, METAL)
	end

	------------------------------------------------------------------ Dome and transept
	local CROSS_Z = -50
	local DRUM_APOTHEM, DRUM_T = 16, 2.5
	local DRUM_OUTER = DRUM_APOTHEM + DRUM_T / 2 -- the drum's outer face, where its windows sit
	local DRUM_BASE, DRUM_TOP = 34, 48
	local DOME_R, DOME_Y = 15, 49.5 -- DOME_Y = DRUM_TOP + the 1.5-stud cornice; the dome top is 64.5
	local function buildDome(ctx)
		-- Crossing block with the transept arms (x +-30): gabled arm roofs with the ridge along X at y 39.5, an end
		-- gable and a window on each arm end. The roofs start at x 18.5 so they also cover the block top where it
		-- would otherwise show between the nave roof ribs.
		ctx:part("CrossingBlock", V(60, 36, 24), CF(0, 18, CROSS_Z), WALL, CONC)
		local armRun, armRise = 13.5, 3.5 -- eaves y 36 at CROSS_Z +- 13.5
		local armLen = math.sqrt(armRun * armRun + armRise * armRise)
		local armTheta = math.atan(armRise / armRun)
		for _, side in ipairs({ -1, 1 }) do
			local rx = side * 24.75 -- the roofs span x 18.5 .. 31
			for _, slope in ipairs({ 1, -1 }) do
				local cf = CF(rx, 36 + armRise / 2, CROSS_Z + slope * armRun / 2) * ANG(slope * armTheta, 0, 0)
				ctx:part("ArmRoof", V(12.5, 0.6, armLen), cf, ROOF, METAL)
				for _, x in ipairs({ 20, 23, 26, 29 }) do
					ctx:part("ArmRoofRib", V(0.5, 0.35, armLen), cf * CF(side * x - rx, 0.45, 0), ROOF_RIB, METAL)
				end
			end
			ctx:gable("ArmEndGable", 24, armRise, 1.5, CF(side * 29.4, 36, CROSS_Z) * ANG(0, PI / 2, 0), WALL, CONC)
			ctx:part("ArmCornice", V(1.2, 1.4, 26), CF(side * 30.1, 35.3, CROSS_Z), TRIM, CONC)
			arched(ctx, "ArmWindow", V(side * 30, 12, CROSS_Z), side * PI / 2, 5, 14)
		end
		-- Octagonal drum with a window on every face, and its cornice.
		local cx, cz = 0, CROSS_Z
		ctx:octagonRing("Drum", DRUM_APOTHEM, DRUM_TOP - DRUM_BASE, DRUM_BASE, DRUM_T, WALL, CONC, CF(cx, 0, cz))
		for k = 1, 8 do
			local theta = (k - 1) * PI / 4
			local nx, nz = math.cos(theta), math.sin(theta)
			-- windows span y 40 .. 46.5, clear of the arm roof ridge (39.5) and of the cornice (48)
			arched(ctx, "DrumWin" .. k, V(cx + nx * DRUM_OUTER, 40, cz + nz * DRUM_OUTER), math.atan2(nx, nz), 3, 6.5)
		end
		ctx:octagonRing("DrumCornice", DRUM_OUTER + 0.6, 1.5, DRUM_TOP, 3.2, TRIM, CONC, CF(cx, 0, cz))
		-- Four small corner turrets on the arm roofs (the roof surface at z = CROSS_Z +- 9.5 is y ~37.0).
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local x, z = sx * 27, CROSS_Z + sz * 9.5
				ctx:part("Turret", V(3.6, 8, 3.6), CF(x, 41, z), WALL, CONC)
				ctx:ball("TurretCap", 4.2, CF(x, 45.4, z), DOME, CONC)
				ctx:part("TurretSlit", V(1.2, 3, 0.3), CF(x, 41, z + sz * 1.85), GLASS, Enum.Material.Glass)
			end
		end
		-- Ribbed dome, lantern and cross.
		ctx:dome("Dome", DOME_R, 8, CF(cx, DOME_Y, cz), DOME, RIB, CONC)
		ctx:octagonRing("Lantern", 2.6, 4, 64.2, 0.6, WALL, CONC, CF(cx, 0, cz))
		ctx:ball("LanternCap", 5.2, CF(cx, 68.6, cz), DOME, CONC)
		ctx:part("DomeCrossV", V(0.5, 4, 0.5), CF(cx, 71.4, cz), TRIM, METAL)
		ctx:part("DomeCrossH", V(2.4, 0.5, 0.5), CF(cx, 72, cz), TRIM, METAL)
	end

	------------------------------------------------------------------ Adjoining wing (viewer's right, +X)
	local function buildWing(ctx)
		local x0, bays, bayW = 22, 8, 8.75
		local pavX = x0 + bayW * 3.5
		local function bayX(i) return x0 + bayW * (i - 0.5) end
		-- Ground floor: eight wall panels with arched openings, a dark backing behind them.
		for i = 1, bays do
			arch(ctx, "WingBay" .. i, { width = 4.6, height = 9.5, depth = 3, wallWidth = bayW, wallHeight = 13,
				cframe = CF(bayX(i), 6.5, -1.5), color = WALL, material = CONC })
		end
		ctx:part("WingBacking", V(70, 10, 0.4), CF(57, 5, -3.2), GLASS, PLAS)
		-- Upper floor, storey bands, pilasters.
		ctx:part("WingUpper", V(70, 13, 3), CF(57, 19.5, -1.5), WALL, CONC)
		ctx:part("WingPlinth", V(70.4, 1, 3.4), CF(57, 0.5, -1.3), TRIM, CONC)
		ctx:part("WingBand", V(70.8, 1.1, 3.6), CF(57, 13.2, -1.2), TRIM, CONC)
		ctx:part("WingEave", V(71.6, 1.6, 4.6), CF(57, 26.8, -0.9), TRIM, CONC)
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
		local front = CF(57, 30.2, -9.1) * ANG(theta, 0, 0)
		local back = CF(57, 30.2, -30.9) * ANG(-theta, 0, 0)
		ctx:part("WingRoofFront", V(72.4, 0.6, len), front, ROOF, METAL)
		ctx:part("WingRoofBack", V(72.4, 0.6, len), back, ROOF, METAL)
		for x = 23, 91, 3 do
			ctx:part("WingRib", V(0.5, 0.35, len), front * CF(x - 57, 0.45, 0), ROOF_RIB, METAL)
			ctx:part("WingRib", V(0.5, 0.35, len), back * CF(x - 57, 0.45, 0), ROOF_RIB, METAL)
		end
		ctx:part("WingRidge", V(72.4, 1, 1.2), CF(57, 33.4, -20), TRIM, CONC)
		ctx:part("WingBackWall", V(70, 27, 2), CF(57, 13.5, -41), WALL, CONC)
		ctx:part("WingEndWall", V(1.6, 27, 40), CF(91.2, 13.5, -20), WALL, CONC)
		ctx:gable("WingEndGable", 40, 6.2, 1.6, CF(91.2, 27, -20) * ANG(0, PI / 2, 0), WALL, CONC)
		for _, z in ipairs({ -10, -30 }) do
			arched(ctx, "WingEndWinLow", V(92, 3, z), PI / 2, 3.6, 8)
			arched(ctx, "WingEndWinUp", V(92, 15.3, z), PI / 2, 3.4, 8)
		end
		-- Central pavilion with a curved gable and a cross.
		ctx:part("PavilionBody", V(12, 29, 5), CF(pavX, 14.5, -0.5), WALL, CONC)
		arched(ctx, "PavilionDoor", V(pavX, 0, 2), 0, 4, 8.5)
		arched(ctx, "PavilionWin", V(pavX, 15.3, 2), 0, 4, 8)
		ctx:part("PavilionPlaque", V(6, 1.2, 0.3), CF(pavX, 12, 2.15), PANEL, CONC)
		for _, s in ipairs({ -1, 1 }) do
			ctx:part("PavilionPilaster", V(1.2, 27, 0.8), CF(pavX + s * 5.4, 13.5, 2.3), TRIM, CONC)
			ctx:ball("PavilionScroll", 2, CF(pavX + s * 6.4, 29.5, 1), DOME, CONC)
		end
		ctx:cyl("PavilionCurve", V(5, 12, 12), CF(pavX, 29, -0.5) * ANG(0, PI / 2, 0), WALL, CONC)
		ctx:part("PavilionShield", V(2.4, 3, 0.3), CF(pavX, 31.5, 2.15), PANEL, CONC)
		ctx:part("PavilionCrossV", V(0.7, 5, 0.7), CF(pavX, 37.5, -0.5), TRIM, METAL)
		ctx:part("PavilionCrossH", V(3, 0.7, 0.7), CF(pavX, 38.6, -0.5), TRIM, METAL)
	end

	------------------------------------------------------------------ Plaza
	local PALMS = {
		{ -88, 38 }, { -88, 62 }, { -88, 86 }, { 88, 38 }, { 88, 62 }, { 88, 86 }, { -34, 16 }, { 34, 16 },
		{ -64, 96 }, { -40, 96 }, { -16, 96 }, { 16, 96 }, { 40, 96 }, { 64, 96 }, -- south row, as in the aerial photo
	}
	local function buildPlaza(ctx)
		ctx:part("PlazaPaving", V(200, 0.1, 94), CF(0, 0, 53), STONE, CONC)
		ctx:part("WingApron", V(78, 0.1, 6), CF(61, 0, 3), STONE, CONC) -- x 22..100, inside the repainted terrain
		-- Kerb (0.3 high) round the plaza so the paving reads as a raised plaza. The side kerbs start at z 6 (the
		-- apron runs z 0..6), and the south kerb leaves a gap at x +-8 for the E_to_Tagbakin road mouth at (0,100).
		ctx:part("KerbWest", V(0.6, 0.3, 94), CF(-100.3, 0.15, 53), STONE_LIGHT, CONC)
		ctx:part("KerbEast", V(0.6, 0.3, 94), CF(100.3, 0.15, 53), STONE_LIGHT, CONC)
		ctx:part("KerbSouthW", V(92, 0.3, 0.6), CF(-54, 0.15, 100.3), STONE_LIGHT, CONC)
		ctx:part("KerbSouthE", V(92, 0.3, 0.6), CF(54, 0.15, 100.3), STONE_LIGHT, CONC)
		-- Hedges (1.8 high): two flanking the tower front, two along the wing front with a gap at the pavilion
		-- (its body and pilasters span x 46.6..58.6 and the scrolls reach 59.4, so the gap is x 44..60).
		ctx:part("HedgeTowerW", V(6, 1.8, 2), CF(-39, 0.95, 9), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeTowerE", V(6, 1.8, 2), CF(-25, 0.95, 9), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeWingW", V(20, 1.8, 2), CF(34, 0.95, 3.5), HEDGE, Enum.Material.Grass)
		ctx:part("HedgeWingE", V(30, 1.8, 2), CF(75, 0.95, 3.5), HEDGE, Enum.Material.Grass)
		for z = 12, 96, 12 do
			ctx:part("PavingBand", V(200, 0.1, 0.8), CF(0, 0.03, z), STONE_DARK, CONC)
		end
		ctx:part("Walkway", V(14, 0.1, 60), CF(0, 0.045, 38), STONE_LIGHT, CONC)
		post(ctx, "PlazaMedallion", 22, 0.1, 0, 0.01, 80, STONE_DARK, CONC)
		post(ctx, "PlazaMedallionCore", 14, 0.1, 0, 0.03, 80, STONE_LIGHT, CONC)
		-- Palms along the plaza edges: three trunk segments leaning slightly, a crown of fronds.
		for i, p in ipairs(PALMS) do
			local px, pz = p[1], p[2]
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
	end

	local function buildBenches(ctx)
		local spots = { { -24, 44 }, { -24, 58 }, { 24, 44 }, { 24, 58 }, { -46, 44 }, { -46, 58 }, { 46, 44 }, { 46, 58 }, { -24, 86 }, { 24, 86 } }
		for _, s in ipairs(spots) do
			local yaw = (s[1] < 0) and -PI / 2 or PI / 2 -- face the walkway
			local cf = CF(s[1], 0, s[2]) * ANG(0, yaw, 0)
			ctx:part("BenchSeat", V(6, 0.5, 2), cf * CF(0, 1.75, 0), TIMBER, WOOD)
			ctx:part("BenchBack", V(6, 2, 0.4), cf * CF(0, 3, 0.9), TIMBER, WOOD)
			ctx:part("BenchLegL", V(0.5, 1.5, 1.8), cf * CF(-2.5, 0.75, 0), LAMP_METAL, METAL)
			ctx:part("BenchLegR", V(0.5, 1.5, 1.8), cf * CF(2.5, 0.75, 0), LAMP_METAL, METAL)
		end
	end

	local function buildLamps(ctx)
		local spots = {}
		for _, z in ipairs({ 14, 36, 58, 80 }) do
			table.insert(spots, { -14, z })
			table.insert(spots, { 14, z })
		end
		for _, z in ipairs({ 30, 60, 90 }) do
			table.insert(spots, { -70, z })
			table.insert(spots, { 70, z })
		end
		for _, s in ipairs(spots) do
			post(ctx, "LampBase", 1.8, 1.2, s[1], 0, s[2], LAMP_METAL, METAL)
			post(ctx, "LampPole", 0.6, 10, s[1], 1.2, s[2], LAMP_METAL, METAL)
			post(ctx, "LampCollar", 1.6, 0.5, s[1], 11.2, s[2], LAMP_METAL, METAL)
			ctx:ball("LampGlobe", 2.2, CF(s[1], 12.6, s[2]), LAMP_GLOW, Enum.Material.Neon)
		end
	end

	local function buildFlagpole(ctx)
		local px, pz = 70, 38
		post(ctx, "FlagBase", 4, 0.8, px, 0, pz, STONE_DARK, CONC)
		post(ctx, "FlagPole", 0.7, 26, px, 0.8, pz, LAMP_METAL, METAL)
		ctx:ball("FlagFinial", 1.4, CF(px, 27.5, pz), Color3.fromRGB(230, 190, 70), METAL)
		ctx:part("FlagBlue", V(0.2, 2.2, 9), CF(px, 25.2, pz + 4.85), Color3.fromRGB(0, 56, 168), PLAS)
		ctx:part("FlagRed", V(0.2, 2.2, 9), CF(px, 23, pz + 4.85), Color3.fromRGB(206, 17, 38), PLAS)
	end

	local function buildStage(ctx)
		-- Public-activity stage facing east onto the walkway, plus a small booth.
		local cx, cz = -70, 45
		ctx:part("StagePlatform", V(24, 3, 14), CF(cx, 1.5, cz), STONE_DARK, CONC)
		ctx:part("StageStepHigh", V(1.8, 2, 10), CF(cx + 12.9, 1, cz), STONE_DARK, CONC)
		ctx:part("StageStepLow", V(1.8, 1, 10), CF(cx + 14.7, 0.5, cz), STONE_DARK, CONC)
		local backdrop = ctx:part("StageBackdrop", V(1, 16, 24), CF(cx - 12.5, 11, cz), PANEL, PLAS)
		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Right
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 30
		gui.Parent = backdrop
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.GothamBold
		label.Text = "PUBLIC EVENTS"
		label.Parent = gui
		for _, px in ipairs({ cx - 11.4, cx + 11.4 }) do
			for _, pz in ipairs({ cz - 6.4, cz + 6.4 }) do
				ctx:part("StagePost", V(0.8, 12, 0.8), CF(px, 9, pz), LAMP_METAL, METAL)
			end
		end
		ctx:part("StageCanopy", V(26, 0.6, 16), CF(cx, 15.3, cz), ROOF, METAL)
		ctx:part("StageFascia", V(26, 1.4, 0.5), CF(cx, 14.4, cz + 8), TRIM, CONC)
		for _, dz in ipairs({ -4, 0, 4 }) do
			ctx:cyl("StageSpot", V(1.2, 1.2, 1.2), CF(cx + 4, 14.2, cz + dz) * ANG(0, 0, PI / 2), LAMP_METAL, METAL)
		end
		-- Booth: counter, two posts, an awning.
		local bx, bz = -48, 60
		ctx:part("BoothCounter", V(5, 3.5, 2), CF(bx, 1.75, bz), TIMBER, WOOD)
		ctx:part("BoothPostL", V(0.4, 8, 0.4), CF(bx - 2.4, 4, bz - 1.4), LAMP_METAL, METAL)
		ctx:part("BoothPostR", V(0.4, 8, 0.4), CF(bx + 2.4, 4, bz - 1.4), LAMP_METAL, METAL)
		ctx:part("BoothAwning", V(6, 0.4, 3.6), CF(bx, 8.2, bz) * ANG(0.2, 0, 0), Color3.fromRGB(200, 60, 60), PLAS)
	end

	------------------------------------------------------------------ Plaza people (idle R15 rigs)
	local function buildPeople()
		local folder = Instance.new("Folder")
		folder.Name = "PlazaPeople"
		local skins = { Color3.fromRGB(224, 172, 130), Color3.fromRGB(198, 134, 92), Color3.fromRGB(141, 85, 60), Color3.fromRGB(241, 194, 125) }
		local shirts = { Color3.fromRGB(200, 60, 60), Color3.fromRGB(60, 100, 170), Color3.fromRGB(230, 200, 80), Color3.fromRGB(90, 150, 100) }
		local spots = { { -18, 50, 0.4 }, { 20, 62, -0.5 }, { -40, 52, 2.6 }, { 44, 64, 3.4 } }
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
			rig:PivotTo(CF(s[1], groundAt(s[1], s[2]) + 3, s[2]) * ANG(0, s[3], 0))
			hrp.Anchored = true
			rig.Parent = folder
		end
		return folder
	end

	------------------------------------------------------------------ Build, then swap
	local people
	local ok, err = pcall(function()
		component("Facade", "Structure", buildFacade)
		component("Tower", "Structure", buildTower)
		component("Nave", "Structure", buildNave)
		component("Dome", "Structure", buildDome)
		component("Wing", "Structure", buildWing)
		component("Plaza", "Site", buildPlaza)
		component("Benches", "Site", buildBenches)
		component("Lamps", "Site", buildLamps)
		component("Flagpole", "Site", buildFlagpole)
		component("EventStage", "Site", buildStage)
		people = buildPeople()
		local peopleParts = countParts(people)
		used += peopleParts
		table.insert(built, { name = "PlazaPeople", parent = "Site", model = people, parts = peopleParts })
		assert(used <= PART_BUDGET, string.format("site01: %d parts exceeds the %d budget", used, PART_BUDGET))
	end)
	if not ok then
		for _, b in ipairs(built) do b.model:Destroy() end
		if people then people:Destroy() end
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
