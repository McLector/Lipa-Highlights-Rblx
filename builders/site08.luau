-- site08: Mount Malarayat Golf & Country Club, rebuilt from the Mount Malarayat Golf Resort Blueprint board (Revision 2, 2026-10-31; Revision 3 the same day: mountain, course, planting, lagoons). ASSEMBLER.
-- Studio copy: ServerStorage.Builders.site08; run with
--   return require(game.ServerStorage.Builders.site08:Clone())()
-- Check: tests/site08_check.luau (ServerStorage.Checks.site08_check), groups general, entrance, clubhouse, hotel, context; plus the site-8 block of
--   tests/sites_check.luau (orientation, lanes, keep-clear boxes, sight-lines). Brief: briefs/site08.md (Revision 2 at the end).
-- HARDCODED (asserted at run time against SiteData row 8): model Workspace.Sites.Site08_Malarayat (must already exist, never created here),
--   pivot (560, 19.8, 720) facing NW, slot 400 x 320 (x 360..760, z 560..880). The ground is the plane y = 0.1 (x - 360) - 0.2 with the clubhouse
--   pad cut flat at y 20 (x 572..668, z 704..844); every module seats its parts by raycasting workspace.Terrain (env.gnd). No terrain writes, except site08_ground at the end.
-- FRAMES: the pivot is yawed NW and is NOT an origin.
--   env.ID   world frame (identity): x, y, z are world coordinates.
--   env.CFL  the clubhouse frame: ORIGIN (620, 20, 780), local +X = SW, local +Z = NW (the frontage), +Y up; world = (620 - s(lx+lz), 20 + ly, 780 + s(lx-lz)).
--            A SurfaceGui on a CFL part's frontage is its local +Z face = Enum.NormalId.Back.
-- KEEP SET: Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney, LocalNPCs are never touched. Every other child is destroyed on each run and rebuilt.
-- IDEMPOTENT, fail-safe (site03 pattern): everything is planned unparented first; only then are the old children destroyed and the plan parented in batches
--   of 200 with task.wait(). The WorldPivot is written explicitly at the end (no part moves).
--
-- ============================ MODULE CONTRACT ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site08_<name>.luau), each `return function(env) ... end`, loaded with require(mod:Clone()).
--   site08_clubhouse  Clubhouse, Structure/Forecourt, Structure/Pool                               560
--   site08_hotel      Hotel                                                                         360
--   site08_context    MountainBackdrop, LeisureSpacesPanel, Structure/Pond, Structure/Course,
--                     Structure/Trees                                                               720
--   site08_entrance   Entrance                                                                      400
--   site08_course     Structure/Fairways, Structure/Ponds, Structure/Woods, Structure/Grove,
--                     Structure/Palms (Revision 3: the board's course and dense planting)           1150
-- Every container holds at most 400 parts (hard error at plan time); the site (built + kept) at most 2500 (BuildCheck).
-- env: V CF ANG PI S PADY ORIGIN CFL ID BuildKit C (colours) M (materials) rng (Random, fixed seed per module)
--   env.gnd(x, z)                          terrain height under a world point
--   env.lw(lx, ly, lz)                     clubhouse-local -> world Vector3 (ly from PADY)
--   env.box/vcyl/ball(ctx, ...)            min/max box, vertical cylinder, sphere in the ctx frame
--   env.hip(ctx, cf, L, D, h, color, mat)  hip roof: 2 wedges + 4 CornerWedgeParts named RoofTile, eave plane centred at cf, ridge along local X (L >= D) or Z
--   env.arch(ctx, name, cf, w, h, depth, color, mat)  arched opening: a box w x (h - w/2) and a half-hidden disc of diameter w on top (name and name.."Head")
--   env.palm/pine/broadleaf/clump(ctx, x, z)            planting, seated on the terrain (world frame ctx)
--   env.slab(ctx, name, cx, cz, dx, dz, len, wid, lift, thick, color, mat)   a plate lying on the slope: top `lift` above the terrain at
--                                          (cx, cz), tilted with the local terrain gradient, long axis along (dx, dz)
--   env.disc(ctx, name, cx, cz, dia, lift, thick, color, mat)                a round plate (Cylinder, axis = the terrain normal), same seating
--   env.sightClear(x, z, r, ytop)          false if a thing of radius r and top ytop at (x, z) would cut a pinned sight-line (road eye or Guide eye to the
--                                          clubhouse windows) or stand in a walking lane or keep-clear box
--   env.section(path, fn [, dest [, frame]])   fresh BuildKit ctx (frame default ID), plans its parts into the container or dest
--   env.roof(path, parent, frame, cf, L, D, h [, color])  a Model RoofHip under parent (planned) holding one hip roof; returns the Model
--   env.newFolder(path, name [, class])    planned Folder/Model inside an owned container      env.newChild(parent, name [, class])
--   env.used() env.budget()
-- Rules: anchored parts only, no Decals/Textures/ImageLabels, ASCII text, human scale fixed (doors 8+, rails 3), every part inside the slot,
--   pinned names unique (ClubhouseRoofMain, ClubhouseEntryGable, PorteCochere, PoolWater, IslandFlag, BackdropPeak, LeisureBoard).
-- ==========================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local S = 0.70711

	local POS = V(560, 19.8, 720)
	local MODEL_NAME = "Site08_Malarayat"
	local SITE_CAP, CONTAINER_CAP, PART_BUDGET = 2500, 400, 2500
	local PADY = 20.0
	local ORIGIN = V(620, PADY, 780)
	local CFL = CFrame.fromMatrix(ORIGIN, V(-S, 0, S), V(0, 1, 0))
	local ID = CFrame.new()
	local KEEP = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
	local MODULES = {
		{ name = "site08_clubhouse", owns = { Clubhouse = true, ["Structure/Forecourt"] = true, ["Structure/Pool"] = true }, budget = 560, seed = 801 },
		{ name = "site08_hotel", owns = { Hotel = true }, budget = 360, seed = 802 },
		{ name = "site08_context", owns = { MountainBackdrop = true, LeisureSpacesPanel = true, ["Structure/Pond"] = true, ["Structure/Course"] = true,
			["Structure/Trees"] = true }, budget = 720, seed = 803 },
		{ name = "site08_entrance", owns = { Entrance = true }, budget = 400, seed = 804 },
		{ name = "site08_course", owns = { ["Structure/Fairways"] = true, ["Structure/Ponds"] = true, ["Structure/Woods"] = true,
			["Structure/Grove"] = true, ["Structure/Palms"] = true }, budget = 1150, seed = 805 },
	}
	local TREE = {
		{ "Clubhouse", "", "Model" },
		{ "MountainBackdrop", "", "Model" },
		{ "LeisureSpacesPanel", "", "Model" },
		{ "Entrance", "", "Model" },
		{ "Hotel", "", "Model" },
		{ "Structure", "", "Folder", true },
		{ "Structure/Forecourt", "Structure", "Model" },
		{ "Structure/Pool", "Structure", "Model" },
		{ "Structure/Pond", "Structure", "Model" },
		{ "Structure/Course", "Structure", "Model" },
		{ "Structure/Trees", "Structure", "Model" },
		{ "Structure/Woods", "Structure", "Model" },
		{ "Structure/Fairways", "Structure", "Model" },
		{ "Structure/Ponds", "Structure", "Model" },
		{ "Structure/Grove", "Structure", "Model" },
		{ "Structure/Palms", "Structure", "Model" },
	}

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site08: Workspace.Sites not found")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site08: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)
	assert(existing, "site08: Workspace.Sites.Site08_Malarayat not found (this builder never creates it)")
	local row = SiteData.byId(8)
	assert(row and row.facing == "NW", "site08: SiteData row 8 is missing or not facing NW")
	assert((row.pos - POS).Magnitude < 1e-3, "site08: SiteData row 8 is at " .. tostring(row.pos) .. ", expected " .. tostring(POS))
	assert(row.size.X == 400 and row.size.Y == 320, "site08: SiteData row 8 size is " .. tostring(row.size) .. ", expected 400 x 320")

	------------------------------------------------------------------ colours and materials
	local okTile = pcall(function() return Enum.Material.ClayRoofTiles end)
	local C = {
		TERRA = Color3.fromRGB(200, 84, 52), TERRA_CAP = Color3.fromRGB(168, 64, 40),
		CREAM = Color3.fromRGB(238, 228, 204), TRIM = Color3.fromRGB(246, 243, 234), SAND = Color3.fromRGB(214, 198, 166),
		STONE = Color3.fromRGB(176, 160, 130), ROCK = Color3.fromRGB(128, 116, 100), ROCK_D = Color3.fromRGB(96, 88, 78), ROCK_L = Color3.fromRGB(150, 138, 120),
		GLASS = Color3.fromRGB(120, 160, 175), DARK = Color3.fromRGB(74, 70, 66), IRON = Color3.fromRGB(40, 40, 44),
		PAVE = Color3.fromRGB(150, 150, 156), PAVE_L = Color3.fromRGB(196, 192, 184), CONC = Color3.fromRGB(186, 178, 166),
		BRICK = Color3.fromRGB(160, 70, 50), COPING = Color3.fromRGB(226, 214, 190), AQUA = Color3.fromRGB(60, 180, 215),
		LAGOON = Color3.fromRGB(52, 120, 160), FOAM = Color3.fromRGB(225, 240, 245),
		PINE = Color3.fromRGB(40, 92, 52), TRUNK = Color3.fromRGB(120, 98, 70), FROND = Color3.fromRGB(50, 110, 50),
		LEAF = Color3.fromRGB(52, 112, 50), LEAF_D = Color3.fromRGB(38, 90, 44), SHRUB = Color3.fromRGB(46, 100, 50),
		MTN = Color3.fromRGB(70, 104, 96), MTN_D = Color3.fromRGB(52, 82, 76), TIMBER = Color3.fromRGB(150, 104, 64), BROWN = Color3.fromRGB(130, 90, 60),
		WHITE = Color3.fromRGB(245, 245, 240), RED = Color3.fromRGB(210, 45, 45), YELLOW = Color3.fromRGB(226, 190, 60), BLUE = Color3.fromRGB(50, 80, 160),
		FLOWER_R = Color3.fromRGB(200, 50, 60), FLOWER_Y = Color3.fromRGB(235, 200, 70), BOARD = Color3.fromRGB(240, 236, 224), TEXT = Color3.fromRGB(40, 60, 50),
		BLACK = Color3.fromRGB(30, 30, 34), CART_T = Color3.fromRGB(190, 160, 110),
	}
	local M = {
		TILE = okTile and Enum.Material.ClayRoofTiles or Enum.Material.Slate, SMOOTH = Enum.Material.SmoothPlastic, PLASTER = Enum.Material.Plaster,
		SLATE = Enum.Material.Slate, LIME = Enum.Material.Limestone, GLASS = Enum.Material.Glass, WOOD = Enum.Material.Wood, CONC = Enum.Material.Concrete,
		BRICK = Enum.Material.Brick, PAVE = Enum.Material.Pavement, GRASS = Enum.Material.LeafyGrass, METAL = Enum.Material.Metal, ROCK = Enum.Material.Rock,
		BASALT = Enum.Material.Basalt,
	}
	pcall(function() if Enum.Material.Plaster == nil then M.PLASTER = Enum.Material.SmoothPlastic end end)

	------------------------------------------------------------------ ground and frames
	local terrainParams = RaycastParams.new()
	terrainParams.FilterType = Enum.RaycastFilterType.Include
	terrainParams.FilterDescendantsInstances = { workspace.Terrain }
	local function gnd(x, z)
		local r = workspace:Raycast(V(x, 200, z), V(0, -400, 0), terrainParams)
		return r and r.Position.Y or (0.1 * (x - 360) - 0.2)
	end
	do
		local g = gnd(620, 780)
		assert(math.abs(g - PADY) <= 0.6, string.format("site08: the clubhouse pad is at y %.2f, expected %.1f", g, PADY))
	end
	local function lw(lx, ly, lz)
		return ORIGIN + V(-S * (lx + lz), ly, S * (lx - lz))
	end

	------------------------------------------------------------------ geometry helpers
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, CF(x, y, z), color, material)
	end
	-- Hip roof (probed 2026-10-31: a WedgePart rises toward +Z; a CornerWedgePart's peak edge is at its local (+X, -Z) corner).
	-- cf = centre of the eave plane; L along local X, D along local Z; h = rise. L < D is built turned 90 degrees.
	local function hip(ctx, cf, L, D, h, color, mat)
		color, mat = color or C.TERRA, mat or M.TILE
		if L < D then
			cf = cf * ANG(0, PI / 2, 0)
			L, D = D, L
		end
		local a = D / 2
		local parts = {}
		if L - D > 0.05 then
			table.insert(parts, ctx:wedge("RoofTile", V(L - D, h, a), cf * CF(0, h / 2, -a / 2), color, mat))
			table.insert(parts, ctx:wedge("RoofTile", V(L - D, h, a), cf * CF(0, h / 2, a / 2) * ANG(0, PI, 0), color, mat))
		end
		local cx = (L - D) / 2 + a / 2
		for _, c in ipairs({ { 1, -1, PI }, { -1, -1, -PI / 2 }, { 1, 1, PI / 2 }, { -1, 1, 0 } }) do
			table.insert(parts, ctx:_make("CornerWedgePart", "RoofTile", V(a, h, a), cf * CF(c[1] * cx, h / 2, c[2] * a / 2) * ANG(0, c[3], 0), color, mat))
		end
		return parts
	end
	-- Arched opening facing local -Z of cf (cf = bottom centre of the opening on the wall face). Box below the springing line, disc on top.
	-- The disc is thinner and set back (+Z, into the wall) so the box's face stays in front where they overlap: a ray to the box centre must hit the box.
	local function arch(ctx, name, cf, w, h, depth, color, mat)
		local r = w / 2
		local body = ctx:part(name, V(w, h - r, depth), cf * CF(0, (h - r) / 2, 0), color, mat)
		local head = ctx:cyl(name .. "Head", V(depth * 0.6, w, w), cf * CF(0, h - r, depth * 0.25) * ANG(0, PI / 2, 0), color, mat)
		return body, head
	end

	------------------------------------------------------------------ planting (one spec for the whole site; site08_check pins palms and pines)
	local function pine(ctx, x, z)
		local g = gnd(x, z)
		vcyl(ctx, "PineTrunk", x, z, g, g + 34, 1.2, C.TRUNK, M.WOOD)
		for k = 0, 7 do
			local y0 = 6 + k * 3.5
			vcyl(ctx, "PineTier", x, z, g + y0, g + y0 + 3.2, 9.5 - k * 0.95, C.PINE, M.GRASS)
		end
	end
	local function palm(ctx, x, z)
		local g = gnd(x, z)
		local h = 18
		for k = 0, 2 do
			vcyl(ctx, "PalmTrunk", x, z, g + k * h / 3, g + (k + 1) * h / 3, 1.2, C.TRUNK, M.WOOD)
		end
		for k = 1, 8 do
			local ang = (k - 1) * PI / 4 + 0.3
			local fr = ctx:part("PalmFrond", V(9.5, 0.3, 1.8), CF(x, g + h, z) * ANG(0, ang, 0) * CF(4.6, 0, 0) * ANG(0, 0, -0.5), C.FROND, M.GRASS)
			fr.CanCollide = false
		end
	end
	-- Broadleaf tree (the board's woods): trunk 9 high, two overlapping non-colliding crowns. size 1 = crown about 12 across.
	local function broadleaf(ctx, x, z, size)
		size = size or 1
		local g = gnd(x, z)
		vcyl(ctx, "BroadleafTrunk", x, z, g, g + 9 * size, 1.4 * size, C.TRUNK, M.WOOD)
		local c1 = ball(ctx, "BroadleafCrown", x, g + 11 * size, z, 12 * size, C.LEAF, M.GRASS)
		local c2 = ball(ctx, "BroadleafCrown", x + 2.5 * size, g + 13.5 * size, z - 1.5 * size, 8.5 * size, C.LEAF_D, M.GRASS)
		c1.CanCollide, c2.CanCollide = false, false
	end
	-- Plates lying on the slope (Revision 3: fairways, greens, bunkers, ponds, lagoons). The terrain gradient is read from four raycasts 2 studs
	-- around the centre; the top surface sits `lift` above the terrain at the centre (>= 0.8, the brief's thin-plate rule) and follows the slope.
	local function groundFrame(cx, cz, dx, dz)
		local gx = (gnd(cx + 2, cz) - gnd(cx - 2, cz)) / 4
		local gz = (gnd(cx, cz + 2) - gnd(cx, cz - 2)) / 4
		local n = V(-gx, 1, -gz).Unit
		local f = V(dx, gx * dx + gz * dz, dz).Unit
		return n, f
	end
	local function slab(ctx, name, cx, cz, dx, dz, len, wid, lift, thick, color, material)
		local n, f = groundFrame(cx, cz, dx, dz)
		local top = V(cx, gnd(cx, cz) + lift, cz)
		return ctx:part(name, V(len, thick, wid), CFrame.fromMatrix(top - n * (thick / 2), f, n), color, material)
	end
	local function disc(ctx, name, cx, cz, dia, lift, thick, color, material)
		local n, f = groundFrame(cx, cz, 1, 0)
		local top = V(cx, gnd(cx, cz) + lift, cz)
		return ctx:cyl(name, V(thick, dia, dia), CFrame.fromMatrix(top - n * (thick / 2), n, f), color, material)
	end
	local function clump(ctx, x, z, color)
		local g = gnd(x, z)
		ball(ctx, "Shrub", x, g + 1.2, z, 2.4, color or C.SHRUB, M.GRASS).CanCollide = false
		ball(ctx, "Shrub", x + 1.1, g + 1.1, z + 0.7, 2.0, C.SHRUB, M.GRASS).CanCollide = false
	end

	------------------------------------------------------------------ pinned sight-lines, lanes and keep-clear boxes (mirror of sites_check, site 8)
	local EYES = { V(450, 14.5, 556), V(534.6, 23.2, 694.6) }
	local TARGETS = {}
	for _, lx in ipairs({ -60, -45, -30, -15, 15, 30, 45, 58, 66 }) do
		for _, ly in ipairs({ 8, 18 }) do table.insert(TARGETS, lw(lx, ly, 14)) end
	end
	local LANES = {
		{ { 450, 552 }, { 450, 700 }, { 524, 700 } },
		{ { 548, 708 }, { 592, 752 } },
		{ { 585, 753 }, { 537, 815 } },
		{ { 520, 722 }, { 436, 758 }, { 426, 788 } },
	}
	local BOXES = { { 526.8, 550.8, 686.8, 710.8 }, { 523, 539, 700, 716 }, { 546, 580, 662, 692 } }
	local function segDist(px, pz, ax, az, bx, bz)
		local dx, dz = bx - ax, bz - az
		local t = math.clamp(((px - ax) * dx + (pz - az) * dz) / (dx * dx + dz * dz), 0, 1)
		return math.sqrt((px - ax - t * dx) ^ 2 + (pz - az - t * dz) ^ 2), t
	end
	local function sightClear(x, z, r, ytop)
		for _, lane in ipairs(LANES) do
			for i = 1, #lane - 1 do
				local d = segDist(x, z, lane[i][1], lane[i][2], lane[i + 1][1], lane[i + 1][2])
				if d < r + 2.5 then return false end
			end
		end
		for _, b in ipairs(BOXES) do
			if x + r > b[1] and x - r < b[2] and z + r > b[3] and z - r < b[4] then return false end
		end
		for _, e in ipairs(EYES) do
			for _, t in ipairs(TARGETS) do
				local d, tt = segDist(x, z, e.X, e.Z, t.X, t.Z)
				if d < r + 1 and tt > 0 and tt < 1 then
					local yRay = e.Y + (t.Y - e.Y) * tt
					if ytop > yRay - 0.5 then return false end
				end
			end
		end
		return true
	end

	------------------------------------------------------------------ plan
	local used = 0
	local plan = {}
	local SITE_TOKEN = {}
	local planParent = {}
	local function place(inst, dest)
		planParent[inst] = dest
		table.insert(plan, { inst = inst, dest = dest })
	end
	local containers, grouping, counts = {}, {}, {}
	for _, t in ipairs(TREE) do
		local inst = Instance.new(t[3])
		inst.Name = t[1]:match("[^/]+$")
		containers[t[1]] = inst
		grouping[inst] = t[4] == true
		counts[t[1]] = 0
		place(inst, t[2] == "" and SITE_TOKEN or containers[t[2]])
	end

	local report = {}
	local function runModule(def)
		local mod = builders:FindFirstChild(def.name)
		if not mod then return "missing" end
		local fn = require(mod:Clone())
		assert(type(fn) == "function", "site08: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, SITE_CAP - used))
		end
		local function owned(path)
			assert(def.owns[path], string.format("site08: %s does not own container %s", def.name, tostring(path)))
			return containers[path]
		end
		local function inside(dest, path)
			local cur = dest
			while cur and cur ~= SITE_TOKEN do
				if cur == containers[path] then return true end
				cur = planParent[cur]
			end
			return false
		end
		local env = {
			V = V, CF = CF, ANG = ANG, PI = PI, S = S, PADY = PADY, ORIGIN = ORIGIN, CFL = CFL, ID = ID, BuildKit = BuildKit, C = C, M = M,
			rng = Random.new(def.seed), gnd = gnd, lw = lw, box = box, vcyl = vcyl, ball = ball, hip = hip, arch = arch,
			palm = palm, pine = pine, broadleaf = broadleaf, clump = clump, sightClear = sightClear, slab = slab, disc = disc,
			used = function() return used end, budget = budget,
		}
		function env.container(path) return owned(path) end
		function env.newFolder(path, name, className)
			local inst = Instance.new(className or "Folder")
			inst.Name = name
			place(inst, owned(path))
			return inst
		end
		function env.newChild(parent, name, className)
			local inst = Instance.new(className or "Model")
			inst.Name = name
			assert(planParent[parent] ~= nil, "site08: newChild parent is not a planned instance")
			place(inst, parent)
			return inst
		end
		function env.section(path, sectionFn, dest, frame)
			local c = owned(path)
			assert(not grouping[c], "site08: grouping node holds no parts: " .. path)
			local target = dest or c
			assert(inside(target, path), "site08: dest is not inside container " .. path)
			local ctx = BuildKit.new(Instance.new("Model"), frame or ID, { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
			counts[path] += n
			assert(counts[path] <= CONTAINER_CAP, string.format("site08: container %s holds %d parts, cap %d", path, counts[path], CONTAINER_CAP))
			modUsed += n
			used += n
			for _, p in ipairs(ctx:parts()) do place(p, target) end
			return target
		end
		function env.roof(path, parent, frame, cf, L, D, h, color)
			local m = Instance.new("Model")
			m.Name = "RoofHip"
			place(m, parent or owned(path))
			env.section(path, function(ctx) hip(ctx, cf, L, D, h, color) end, m, frame)
			return m
		end
		fn(env)
		return modUsed
	end
	for _, def in ipairs(MODULES) do
		report[def.name] = runModule(def)
	end

	local kept = 0
	for _, child in ipairs(existing:GetChildren()) do
		if KEEP[child.Name] then
			if child:IsA("BasePart") then kept += 1 end
			for _, d in ipairs(child:GetDescendants()) do
				if d:IsA("BasePart") then kept += 1 end
			end
		end
	end
	assert(used + kept <= PART_BUDGET, string.format("site08: %d built + %d kept parts exceed the %d site cap", used, kept, PART_BUDGET))

	------------------------------------------------------------------ swap
	local site = existing
	for _, child in ipairs(site:GetChildren()) do
		if not KEEP[child.Name] then child:Destroy() end
	end
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 200 == 0 then task.wait() end
	end
	site.WorldPivot = CFrame.lookAt(POS, POS + V(-S, 0, -S))
	-- Polish (2026-10-31): repaint the terrain Grass under the water, bunkers and paving (the one terrain write; idempotent).
	local groundMod = builders:FindFirstChild("site08_ground")
	local ground = groundMod and require(groundMod:Clone())() or nil

	local names = {}
	for _, c in ipairs(site:GetChildren()) do table.insert(names, c.Name) end
	table.sort(names)
	local total = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then total += 1 end
	end
	local perContainer = {}
	for path, n in pairs(counts) do perContainer[#perContainer + 1] = path .. "=" .. n end
	table.sort(perContainer)
	local mods = {}
	for k, v in pairs(report) do mods[#mods + 1] = k .. "=" .. tostring(v) end
	table.sort(mods)
	return {
		parts = total,
		builtParts = used,
		keptParts = kept,
		modules = table.concat(mods, ","),
		containers = table.concat(perContainer, ","),
		children = table.concat(names, ","),
		groundRepainted = ground and ground.repaintedVoxels or "missing",
	}
end
