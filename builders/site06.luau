-- site06: The Outlets at LIMA Estate + Aboitiz Pitch, rebuilt from "The Outlets at Lima Estate Blueprint.png" (Standard tier, 2026-10-31)
-- ASSEMBLER. Studio copy: ServerStorage.Builders.site06; run with
--   return require(game.ServerStorage.Builders.site06:Clone())()
-- Check: tests/site06_check.luau (ServerStorage.Checks.site06_check), groups general, retail, promenade, parking, pitch, entrance, clear,
-- props. Brief: briefs/site06.md Revision 2. Same coordinator pattern as builders/site05.luau.
-- HARDCODED (kept in step with SiteData row 6, asserted at run time): model Workspace.Sites.Site06_Outlets (must already exist, never
--   created here), ORIGIN (550, 0, -700), slot 450 x 300 (x 325..775, z -850..-550), facing SW. The whole estate is built at one uniform
--   plan scale of 1.05 studs per metre (the board's 430 x 255 m -> about 450 x 268; north of z -118 is the perimeter tree belt).
-- FRAME: world-aligned. Local axes = world axes, world = ORIGIN + (lx, ly, lz): local +X = east, +Z = south, y is height above the
--   ground (y 0; asserted within 0.6 by a raycast). The model faces SW: WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + SW) is written after
--   parenting (the model has no PrimaryPart; asserted).
-- KEEP SET: Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney, LocalNPCs are never touched, moved or recreated (they keep their
--   WORLD positions; SiteData row 6 carries guideLocal / panelLocal for them). EVERY other child of the model is destroyed on every run
--   (a keep list, not a replace list) and rebuilt by the modules. No terrain writes: the old Pavement patches stay where parts do not
--   cover them, and the arrival plaza round the kept cluster is that bare Pavement (nothing is stacked under the JeepStop pad).
-- IDEMPOTENT. Fail-safe order (site03/site05): everything is planned unparented first, so an error leaves the old model untouched; then
--   the old non-kept children are destroyed and the plan is parented in batches with task.wait().
--
-- ============================ MODULE CONTRACT ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site06_<name>.luau), each `return function(env) ... end`, loaded with
-- require(mod:Clone()). A missing module is skipped (reported "missing").
-- Containers (Structure is a grouping Folder that holds no parts; the sites_check guard finds ShopBody, WalkwayRoof, PitchTurf and
--   StandTiers anywhere in the site, so each of those names is used by exactly ONE part):
--     site06_retail      Structure/RetailWest, Structure/RetailCentre, Structure/RetailEast                     900
--     site06_promenade   ShopStreet, Landscape                                                                   700
--     site06_parking     Parking                                                                                 400
--     site06_pitch       SportsField, Structure/Stand, Structure/PitchHouse                                      400
--     site06_entrance    Grounds, EstateModelPedestal, LipaMalvarPanel                                           300
--   Every container holds at most 400 parts (hard error at plan time); the site (built + kept) at most 2500 (BuildCheck).
-- env (LOCAL coordinates, y above the ground): V, CF, ANG, PI, R (sqrt 0.5), SW, SE, ORIGIN, BuildKit, GROUND, C (palette), and helpers
--   box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)          axis-aligned box from min/max corners
--   obox(ctx, name, cf, size, color, material)                       oriented box (cf in local coordinates)
--   vcyl(ctx, name, x, z, y0, y1, dia, color, material)             vertical cylinder
--   gui(part, face, title, body, color, ppstud, titleSize, bodySize) SurfaceGui with fixed-TextSize labels
--   richGui(part, face, richText, ppstud, size)                     one RichText label, fixed TextSize, wrapped
--   palm(ctx, x, z, h) (7 parts), tree(ctx, x, z, h, dia) (3 parts), bench(ctx, cf) (4 parts, seat top 2.2),
--   lamp(ctx, x, z, h) (2 parts: StreetLampPole, StreetLampHead)
--   section(path, fn [, dest [, lift]]), newFolder(path, name [, class]), container(path), used(), budget()
-- DECK (1.3): the rendered terrain (Grass about 0.9, the old Pavement patches about 1.25) hides any part whose top is lower, although
--   physics puts the ground at y 0 (measured 2026-10-31: a 0.5 turf was invisible from 15 to 300 studs; 1.25 showed). So every paved,
--   turf and court area is a deck slab from y 0 to 1.3 (world), and a section built ON a deck passes lift = DECK: its parts are raised
--   1.3, its deck slabs run from local y -DECK to 0, and its inlays sit at most 0.1 above the deck (every edge step stays <= 1.3, the
--   project's walkable step). Only the arrival plaza (x -64..4, z 30..100) stays bare terrain round the kept Guide cluster, a 1.3 sunken
--   court; trees, palms and hedges on the grass verges are not lifted.
-- Rules: anchored parts only (BuildKit), no Decals/Textures/ImageLabels, no brand logos, ASCII only, human scale fixed (doors 8+, rails 3,
-- counters 3.5, chairs 2), every part inside the slot (x -225..225, z -150..150), nothing below y -0.6, the names pinned by
-- tests/site06_check.luau. No randomness: every run is equal.
-- ==========================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi
	local R = math.sqrt(0.5)
	local SW, SE = V(-R, 0, R), V(R, 0, R)

	local ORIGIN = V(550, 0, -700)
	local MODEL_NAME = "Site06_Outlets"
	local SITE_CAP, CONTAINER_CAP = 2500, 400
	local KEEP = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
	local MODULES = {
		{ name = "site06_retail", owns = { ["Structure/RetailWest"] = true, ["Structure/RetailCentre"] = true, ["Structure/RetailEast"] = true }, budget = 900 },
		{ name = "site06_promenade", owns = { ShopStreet = true, Landscape = true }, budget = 700 },
		{ name = "site06_parking", owns = { Parking = true }, budget = 400 },
		{ name = "site06_pitch", owns = { SportsField = true, ["Structure/Stand"] = true, ["Structure/PitchHouse"] = true }, budget = 400 },
		{ name = "site06_entrance", owns = { Grounds = true, EstateModelPedestal = true, LipaMalvarPanel = true }, budget = 300 },
	}
	-- path -> { parent path ("" is the site), class, grouping }
	local TREE = {
		{ "Structure", "", "Folder", true },
		{ "Structure/RetailWest", "Structure", "Model" },
		{ "Structure/RetailCentre", "Structure", "Model" },
		{ "Structure/RetailEast", "Structure", "Model" },
		{ "Structure/Stand", "Structure", "Model" },
		{ "Structure/PitchHouse", "Structure", "Model" },
		{ "ShopStreet", "", "Model" },
		{ "Landscape", "", "Model" },
		{ "Parking", "", "Model" },
		{ "SportsField", "", "Model" },
		{ "Grounds", "", "Model" },
		{ "EstateModelPedestal", "", "Model" },
		{ "LipaMalvarPanel", "", "Model" },
	}

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site06: Workspace.Sites not found (run builders/placeholders first)")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site06: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)
	assert(existing, "site06: Workspace.Sites.Site06_Outlets not found (run builders/placeholders first; this builder never creates it)")
	assert(existing.PrimaryPart == nil, "site06: the model has a PrimaryPart, so a WorldPivot write would not move the pivot")

	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local row = SiteData.byId(6)
	assert(row and row.facing == "SW", "site06: SiteData row 6 is missing or not facing SW")
	assert(row.pos == ORIGIN, string.format("site06: SiteData row 6 is at %s, expected %s", tostring(row and row.pos), tostring(ORIGIN)))
	assert(row.size.X == 450 and row.size.Y == 300, string.format("site06: SiteData row 6 size is %s, expected 450 x 300", tostring(row.size)))

	local ground = nil
	do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { workspace.Terrain }
		local hit = workspace:Raycast(ORIGIN + V(0, 80, 0), V(0, -200, 0), params)
		if hit then
			ground = hit.Position.Y
			assert(math.abs(ground) <= 0.6, string.format("site06: ground at ORIGIN is y %.2f, expected about 0", ground))
		end
	end
	local GROUND = ground or 0
	local DECK = 1.3

	------------------------------------------------------------------ palette (the board, by eye; the old Slice 05/16 photo colours where they agree)
	local C = {
		WHITE = Color3.fromRGB(238, 236, 230), -- render
		OFFWHITE = Color3.fromRGB(226, 224, 218),
		ORANGE = Color3.fromRGB(200, 100, 55), -- timber-look cladding
		ORANGE2 = Color3.fromRGB(186, 90, 48),
		SOFFIT = Color3.fromRGB(176, 86, 46),
		TERRA = Color3.fromRGB(186, 88, 54), -- roof-edge fascia (the board's orange-brown roof rims)
		BROWN = Color3.fromRGB(96, 56, 44), -- canopies and awnings
		MAROON = Color3.fromRGB(112, 52, 44),
		DARK = Color3.fromRGB(34, 36, 42),
		BLACK = Color3.fromRGB(18, 18, 22),
		GLASS = Color3.fromRGB(52, 64, 76),
		SOLAR = Color3.fromRGB(28, 44, 92),
		STEEL = Color3.fromRGB(120, 124, 130),
		CONCRETE = Color3.fromRGB(190, 188, 182),
		PAVING = Color3.fromRGB(206, 202, 194),
		PAVING2 = Color3.fromRGB(184, 176, 164),
		ROAD = Color3.fromRGB(120, 120, 124),
		PARK = Color3.fromRGB(104, 104, 108),
		LINE = Color3.fromRGB(245, 245, 240),
		TURF = Color3.fromRGB(44, 152, 62),
		TURF2 = Color3.fromRGB(56, 168, 74),
		LAWN = Color3.fromRGB(86, 148, 64),
		HEDGE = Color3.fromRGB(52, 110, 56),
		TRUNK = Color3.fromRGB(110, 88, 66),
		LEAF = Color3.fromRGB(58, 122, 56),
		LEAF2 = Color3.fromRGB(84, 144, 62),
		FROND = Color3.fromRGB(64, 128, 52),
		SOIL = Color3.fromRGB(120, 96, 72),
		BULB = Color3.fromRGB(255, 214, 140),
	}
	local M = {
		CONC = Enum.Material.Concrete, PLAS = Enum.Material.SmoothPlastic, METAL = Enum.Material.Metal, GLASS = Enum.Material.Glass,
		GRASS = Enum.Material.Grass, WOOD = Enum.Material.Wood, NEON = Enum.Material.Neon, BRICK = Enum.Material.Brick,
		PAVE = Enum.Material.Pavement, ASPHALT = Enum.Material.Asphalt, FABRIC = Enum.Material.Fabric,
	}

	------------------------------------------------------------------ helpers
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	local function obox(ctx, name, cf, size, color, material)
		return ctx:part(name, size, cf, color, material)
	end
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	-- A SurfaceGui with a title and an optional body line, FIXED TextSize (long labels never use TextScaled).
	local function gui(part, face, title, body, textColor, ppstud, titleSize, bodySize)
		local g = Instance.new("SurfaceGui")
		g.Face = face
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud or 30
		g.Parent = part
		local function lab(name, text, y0, h, font, size)
			local t = Instance.new("TextLabel")
			t.Name = name
			t.Position = UDim2.fromScale(0.04, y0)
			t.Size = UDim2.fromScale(0.92, h)
			t.BackgroundTransparency = 1
			t.TextColor3 = textColor
			t.TextScaled = false
			t.TextSize = size
			t.TextWrapped = true
			t.Font = font
			t.Text = text
			t.Parent = g
		end
		if body then
			lab("Title", title, 0.04, 0.3, Enum.Font.GothamBold, titleSize or 24)
			lab("Body", body, 0.38, 0.58, Enum.Font.GothamMedium, bodySize or 18)
		else
			lab("Title", title, 0.05, 0.9, Enum.Font.GothamBold, titleSize or 24)
		end
		return g
	end
	local function richGui(part, face, richText, ppstud, size)
		local g = Instance.new("SurfaceGui")
		g.Face = face
		g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		g.PixelsPerStud = ppstud or 20
		g.Parent = part
		local t = Instance.new("TextLabel")
		t.Name = "Title"
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.RichText = true
		t.TextScaled = false
		t.TextSize = size or 60
		t.TextWrapped = true
		t.Font = Enum.Font.GothamBlack
		t.TextColor3 = Color3.new(0, 0, 0)
		t.Text = richText
		t.Parent = g
		return g
	end
	-- Palm: trunk, 5 drooping fronds and a head ball (7 parts); frond tips reach about 5.6 studs from the trunk.
	local function palm(ctx, x, z, h)
		local top = V(x, h, z)
		vcyl(ctx, "PalmTrunk", x, z, 0, h, 1.1, C.TRUNK, M.WOOD)
		for k = 0, 4 do
			local a = k * 2 * PI / 5 + 0.3
			local dir = V(math.cos(a), 0, math.sin(a))
			local c = top + dir * 2.6 - V(0, 0.9, 0)
			ctx:part("PalmFrond", V(1.6, 0.25, 6), CFrame.lookAt(c, c + dir * 3 - V(0, 1.4, 0)), C.FROND, M.GRASS)
		end
		ctx:ball("PalmHead", 1.6, CF(top), C.TRUNK, M.WOOD)
	end
	local function tree(ctx, x, z, h, dia)
		vcyl(ctx, "TreeTrunk", x, z, 0, h * 0.55, 1, C.TRUNK, M.WOOD)
		ctx:ball("TreeCrown", dia, CF(x, h - dia * 0.35, z), C.LEAF, M.GRASS)
		ctx:ball("TreeCrown", dia * 0.7, CF(x + dia * 0.2, h - dia * 0.05, z - dia * 0.1), C.LEAF2, M.GRASS)
	end
	-- A bench in frame cf (seat along local x, the backrest on local -Z, sitter faces local +Z): seat top 2.2.
	local function bench(ctx, cf)
		ctx:part("BenchSeat", V(5, 0.4, 1.6), cf * CF(0, 2.0, 0), C.BROWN, M.WOOD)
		ctx:part("BenchBack", V(5, 1.4, 0.3), cf * CF(0, 2.9, -0.75), C.BROWN, M.WOOD)
		for _, dx in ipairs({ -2, 2 }) do
			ctx:part("BenchLeg", V(0.4, 1.8, 1.4), cf * CF(dx, 0.9, 0), C.STEEL, M.METAL)
		end
	end
	local function lamp(ctx, x, z, h)
		h = h or 12
		vcyl(ctx, "StreetLampPole", x, z, 0, h, 0.5, C.DARK, M.METAL)
		ctx:part("StreetLampHead", V(1.6, 0.6, 1.6), CF(x, h + 0.3, z), C.BULB, M.NEON)
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
		if not mod then
			return "missing"
		end
		local fn = require(mod:Clone())
		assert(type(fn) == "function", "site06: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, SITE_CAP - used))
		end
		local function owned(path)
			assert(def.owns[path], string.format("site06: %s does not own container %s", def.name, tostring(path)))
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
			V = V, CF = CF, ANG = ANG, PI = PI, R = R, SW = SW, SE = SE, ORIGIN = ORIGIN, BuildKit = BuildKit, GROUND = GROUND, DECK = DECK, C = C, M = M,
			box = box, obox = obox, vcyl = vcyl, gui = gui, richGui = richGui, palm = palm, tree = tree, bench = bench, lamp = lamp,
			used = function() return used end,
			budget = budget,
		}
		function env.container(path)
			return owned(path)
		end
		function env.newFolder(path, subName, className)
			local inst = Instance.new(className or "Folder")
			inst.Name = subName
			place(inst, owned(path))
			return inst
		end
		function env.section(path, sectionFn, dest, lift)
			local c = owned(path)
			assert(not grouping[c], "site06: grouping node holds no parts: " .. path)
			local target = dest or c
			assert(inside(target, path), "site06: dest is not inside container " .. path)
			local holder = Instance.new("Model")
			local ctx = BuildKit.new(holder, CF(ORIGIN + V(0, lift or 0, 0)), { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
			counts[path] += n
			assert(counts[path] <= CONTAINER_CAP, string.format("site06: container %s holds %d parts, cap %d", path, counts[path], CONTAINER_CAP))
			modUsed += n
			used += n
			for _, p in ipairs(ctx:parts()) do
				place(p, target)
			end
			return target
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
	assert(used + kept <= SITE_CAP, string.format("site06: %d built + %d kept parts exceed the %d site cap", used, kept, SITE_CAP))

	------------------------------------------------------------------ swap
	local site = existing
	for _, child in ipairs(site:GetChildren()) do
		if not KEEP[child.Name] then child:Destroy() end
	end
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 200 == 0 then task.wait() end
	end

	-- Property write: no part moves. Faces SW, at the new slot centre (the kept objects keep their world positions).
	site.WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + SW)

	local names = {}
	for _, c in ipairs(site:GetChildren()) do table.insert(names, c.Name) end
	table.sort(names)
	local total, perContainer = 0, {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then total += 1 end
	end
	for path, n in pairs(counts) do perContainer[#perContainer + 1] = path .. "=" .. n end
	table.sort(perContainer)
	return {
		parts = total,
		builtParts = used,
		keptParts = kept,
		ground = ground,
		modules = report,
		containers = table.concat(perContainer, ","),
		children = table.concat(names, ","),
	}
end
