-- site05: Monastery of Our Lady of Mount Carmel, rebuilt from "Mount Carmel Monastery Blueprint.png" (Standard tier, 2026-10-31) ASSEMBLER.
-- Studio copy: ServerStorage.Builders.site05; run with
--   return require(game.ServerStorage.Builders.site05:Clone())()
-- Check: tests/site05_check.luau (ServerStorage.Checks.site05_check), groups general, facade, chapel, monastery, rectory, grounds, clear.
-- Brief: briefs/site05.md Revision 2. Same coordinator pattern as builders/site03.luau.
-- HARDCODED (kept in step with SiteData row 5, asserted at run time): model Workspace.Sites.Site05_Carmel (must already exist, never created
--   here), ORIGIN (-300, 0, -600), slot 220 x 180, facing S.
-- FRAME: world-aligned. Local axes = world axes, world = ORIGIN + (lx, ly, lz): local +X = east, +Z = south = the facade side, y is height
--   above the ground (ground y 0; asserted within 0.6 by a raycast). The model faces +Z: WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + (0,0,1))
--   is written after parenting (RightVector -X, the "yawed 180" pivot of the old builder).
-- KEEP SET: Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney, LocalNPCs are never touched, moved or recreated. EVERY other child of
--   the model is destroyed on every run (a keep list, not a replace list) and rebuilt by the modules. No terrain writes (the forecourt
--   Pavement region x -52..52, z 0..92 of builders/world.luau stays as it is).
-- IDEMPOTENT. Fail-safe order (site03): everything is planned unparented first, so an error leaves the old model untouched; then the old
--   non-kept children are destroyed and the plan is parented in batches with task.wait().
--
-- ============================ MODULE CONTRACT ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site05_<name>.luau), each `return function(env) ... end`, loaded with
-- require(mod:Clone()). A missing module is skipped (reported "missing").
-- Containers (Structure is a grouping Folder that holds no parts; the sites_check guard searches it for Podium, NaveBlock, AnnexBlock,
--   MonasteryBlock):
--     site05_chapel      Structure/Facade, Structure/Nave, Structure/Dome, Structure/Annex                 800
--     site05_monastery   Structure/Monastery, Garden                                                       600
--     site05_rectory     Rectory                                                                           300
--     site05_grounds     Grounds, Landscape, Shrine, Pews, Kneeler, Candles, HistoryPanels                 900
--   Every container holds at most 400 parts (hard error at plan time); the site (built + kept) at most 2500 (BuildCheck).
-- env (LOCAL coordinates, y above ground): V, CF, ANG, PI, ORIGIN, BuildKit, GROUND, and the helpers
--   box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)          axis-aligned box from min/max corners
--   vcyl(ctx, name, x, z, y0, y1, dia, color, material)             vertical cylinder
--   ball(ctx, name, x, y, z, dia, color, material)                  sphere
--   strip(ctx, name, x0, x1, y0, y1, z0, z1, d, color, material)    wedge over a box, slope rising toward the axis unit vector d
--   corner(ctx, name, x0, x1, y0, y1, z0, z1, sx, sz, color, mat)  corner wedge over a SQUARE base, apex over the base corner (sx, sz)
--   hipRoof(ctx, name, x0, x1, z0, z1, y0, rise, color, material)   hip roof (ridge along the long side); the first slope is named `name`
--   arch(ctx, name, spec)                                           BuildKit arch, counted in the report's archPaths
--   gui(part, face, title, body, color, ppstud, titleSize, bodySize) SurfaceGui with fixed-TextSize labels
--   palm(ctx, x, z, h, lean) (7 parts), tree(ctx, x, z, h, dia) (3 parts), shrub(ctx, x, z, dia) (1 part)
--   section(path, fn [, dest]), newFolder(path, name [, class]), container(path), used(), budget()
-- Rules: anchored parts only (BuildKit), no Decals/Textures/ImageLabels, ASCII only, human scale fixed (doors 8+, rails 3, counters 3.5,
-- chairs 2), every part inside the slot, nothing below y -0.6, the names pinned by tests/site05_check.luau. No randomness: every run is equal.
-- ==========================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi

	local ORIGIN = V(-300, 0, -600)
	local MODEL_NAME = "Site05_Carmel"
	local SITE_CAP, CONTAINER_CAP = 2500, 400
	local KEEP = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
	local MODULES = {
		{ name = "site05_chapel", owns = { ["Structure/Facade"] = true, ["Structure/Nave"] = true, ["Structure/Dome"] = true, ["Structure/Annex"] = true }, budget = 800 },
		{ name = "site05_monastery", owns = { ["Structure/Monastery"] = true, Garden = true }, budget = 600 },
		{ name = "site05_rectory", owns = { Rectory = true }, budget = 300 },
		{ name = "site05_grounds", owns = { Grounds = true, Landscape = true, Shrine = true, Pews = true, Kneeler = true, Candles = true, HistoryPanels = true }, budget = 900 },
	}
	-- path -> { parent path ("" is the site), class, grouping }
	local TREE = {
		{ "Structure", "", "Folder", true },
		{ "Structure/Facade", "Structure", "Model" },
		{ "Structure/Nave", "Structure", "Model" },
		{ "Structure/Dome", "Structure", "Model" },
		{ "Structure/Annex", "Structure", "Model" },
		{ "Structure/Monastery", "Structure", "Model" },
		{ "Garden", "", "Model" },
		{ "Rectory", "", "Model" },
		{ "Grounds", "", "Model" },
		{ "Landscape", "", "Model" },
		{ "Shrine", "", "Model" },
		{ "Pews", "", "Model" },
		{ "Kneeler", "", "Model" },
		{ "Candles", "", "Model" },
		{ "HistoryPanels", "", "Model" },
	}

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site05: Workspace.Sites not found (run builders/placeholders first)")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site05: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)
	assert(existing, "site05: Workspace.Sites.Site05_Carmel not found (run builders/placeholders first; this builder never creates it)")

	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local row = SiteData.byId(5)
	assert(row and row.facing == "S", "site05: SiteData row 5 is missing or not facing S")
	assert(row.pos == ORIGIN, string.format("site05: SiteData row 5 is at %s, expected %s", tostring(row and row.pos), tostring(ORIGIN)))
	assert(row.size.X == 220 and row.size.Y == 180, string.format("site05: SiteData row 5 size is %s, expected 220 x 180", tostring(row.size)))

	local ground = nil
	do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { existing }
		local hit = workspace:Raycast(ORIGIN + V(0, 80, 0), V(0, -200, 0), params)
		if hit then
			ground = hit.Position.Y
			assert(math.abs(ground) <= 0.6, string.format("site05: ground at ORIGIN is y %.2f, expected about 0", ground))
		end
	end
	local GROUND = ground or 0

	------------------------------------------------------------------ helpers
	local UP = V(0, 1, 0)
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, CF(x, y, z), color, material)
	end
	-- Wedge over a box; the slope rises toward the horizontal axis unit vector d (the vertical face is on that side). (site03_tower.)
	local function strip(ctx, name, x0, x1, y0, y1, z0, z1, d, color, material)
		local size = (math.abs(d.X) > 0.5) and V(z1 - z0, y1 - y0, x1 - x0) or V(x1 - x0, y1 - y0, z1 - z0)
		local cf = CFrame.fromMatrix(V((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), UP:Cross(d), UP, d)
		return ctx:wedge(name, size, cf, color, material)
	end
	-- Corner wedge over a SQUARE base; the apex stands over the base corner on the (sx, sz) side. (site03_tower, verified there.)
	local EX = { ["1,-1"] = V(1, 0, 0), ["1,1"] = V(0, 0, 1), ["-1,1"] = V(-1, 0, 0), ["-1,-1"] = V(0, 0, -1) }
	local function corner(ctx, name, x0, x1, y0, y1, z0, z1, sx, sz, color, material)
		local ex = EX[sx .. "," .. sz]
		local cf = CFrame.fromMatrix(V((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), ex, UP, ex:Cross(UP))
		return ctx:_make("CornerWedgePart", name, V(x1 - x0, y1 - y0, z1 - z0), cf, color, material)
	end
	-- Hip roof over x0..x1, z0..z1 from eave y0 rising `rise`: 2 slopes + 4 hip corners (2 + 4 parts; 4 if square).
	local function hipRoof(ctx, name, x0, x1, z0, z1, y0, rise, color, material)
		local y1 = y0 + rise
		local made = {}
		if (x1 - x0) >= (z1 - z0) then
			local hw, zc = (z1 - z0) / 2, (z0 + z1) / 2
			if x1 - x0 > z1 - z0 + 0.01 then
				table.insert(made, strip(ctx, name, x0 + hw, x1 - hw, y0, y1, zc, z1, V(0, 0, -1), color, material))
				table.insert(made, strip(ctx, name .. "S", x0 + hw, x1 - hw, y0, y1, z0, zc, V(0, 0, 1), color, material))
			end
			table.insert(made, corner(ctx, name .. "Hip", x1 - hw, x1, y0, y1, z0, zc, -1, 1, color, material))
			table.insert(made, corner(ctx, name .. "Hip", x1 - hw, x1, y0, y1, zc, z1, -1, -1, color, material))
			table.insert(made, corner(ctx, name .. "Hip", x0, x0 + hw, y0, y1, z0, zc, 1, 1, color, material))
			table.insert(made, corner(ctx, name .. "Hip", x0, x0 + hw, y0, y1, zc, z1, 1, -1, color, material))
		else
			local hd, xc = (x1 - x0) / 2, (x0 + x1) / 2
			table.insert(made, strip(ctx, name, xc, x1, y0, y1, z0 + hd, z1 - hd, V(-1, 0, 0), color, material))
			table.insert(made, strip(ctx, name .. "S", x0, xc, y0, y1, z0 + hd, z1 - hd, V(1, 0, 0), color, material))
			table.insert(made, corner(ctx, name .. "Hip", x0, xc, y0, y1, z1 - hd, z1, 1, -1, color, material))
			table.insert(made, corner(ctx, name .. "Hip", xc, x1, y0, y1, z1 - hd, z1, -1, -1, color, material))
			table.insert(made, corner(ctx, name .. "Hip", x0, xc, y0, y1, z0, z0 + hd, 1, 1, color, material))
			table.insert(made, corner(ctx, name .. "Hip", xc, x1, y0, y1, z0, z0 + hd, -1, 1, color, material))
		end
		return made
	end
	local archPaths = { csg = 0, fallback = 0 }
	local function arch(ctx, name, spec)
		local r = ctx:arch(name, spec)
		archPaths[r.path] += 1
		return r
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
			t.Position = UDim2.fromScale(0.05, y0)
			t.Size = UDim2.fromScale(0.9, h)
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
	local TRUNK, FROND, LEAF_D, LEAF_L = Color3.fromRGB(120, 96, 70), Color3.fromRGB(64, 128, 52), Color3.fromRGB(46, 104, 50), Color3.fromRGB(80, 136, 60)
	-- Palm: trunk, 5 drooping fronds and a head ball (7 parts). lean tilts the trunk toward +X by that many studs at the top.
	local function palm(ctx, x, z, h, lean)
		lean = lean or 0
		local top = V(x + lean, h, z)
		local base = V(x, 0, z)
		local axis = (top - base)
		ctx:cyl("PalmTrunk", V(axis.Magnitude, 1.1, 1.1), CFrame.lookAt((base + top) / 2, top) * ANG(0, PI / 2, 0), TRUNK, Enum.Material.Wood)
		for k = 0, 4 do
			local a = k * 2 * PI / 5 + 0.3
			local dir = V(math.cos(a), 0, math.sin(a))
			local c = top + dir * 2.6 - V(0, 0.9, 0)
			ctx:part("PalmFrond", V(1.6, 0.25, 6), CFrame.lookAt(c, c + dir * 3 - V(0, 1.4, 0)), FROND, Enum.Material.Grass)
		end
		ctx:ball("PalmHead", 1.6, CF(top), TRUNK, Enum.Material.Wood)
	end
	local function tree(ctx, x, z, h, dia)
		vcyl(ctx, "TreeTrunk", x, z, 0, h * 0.55, 1, TRUNK, Enum.Material.Wood)
		ctx:ball("TreeCrown", dia, CF(x, h - dia * 0.35, z), LEAF_D, Enum.Material.Grass)
		ctx:ball("TreeCrown", dia * 0.7, CF(x + dia * 0.2, h - dia * 0.05, z - dia * 0.1), LEAF_L, Enum.Material.Grass)
	end
	local function shrub(ctx, x, z, dia)
		ctx:ball("Shrub", dia, CF(x, dia * 0.3, z), LEAF_D, Enum.Material.Grass)
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
		assert(type(fn) == "function", "site05: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, SITE_CAP - used))
		end
		local function owned(path)
			assert(def.owns[path], string.format("site05: %s does not own container %s", def.name, tostring(path)))
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
			V = V, CF = CF, ANG = ANG, PI = PI, ORIGIN = ORIGIN, BuildKit = BuildKit, GROUND = GROUND,
			box = box, vcyl = vcyl, ball = ball, strip = strip, corner = corner, hipRoof = hipRoof, arch = arch, gui = gui,
			palm = palm, tree = tree, shrub = shrub,
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
		function env.section(path, sectionFn, dest)
			local c = owned(path)
			assert(not grouping[c], "site05: grouping node holds no parts: " .. path)
			local target = dest or c
			assert(inside(target, path), "site05: dest is not inside container " .. path)
			local holder = Instance.new("Model")
			local ctx = BuildKit.new(holder, CF(ORIGIN), { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
			counts[path] += n
			assert(counts[path] <= CONTAINER_CAP, string.format("site05: container %s holds %d parts, cap %d", path, counts[path], CONTAINER_CAP))
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
	assert(used + kept <= SITE_CAP, string.format("site05: %d built + %d kept parts exceed the %d site cap", used, kept, SITE_CAP))

	------------------------------------------------------------------ swap
	local site = existing
	for _, child in ipairs(site:GetChildren()) do
		if not KEEP[child.Name] then child:Destroy() end
	end
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 200 == 0 then task.wait() end
	end

	-- Property write: no part moves. Faces +Z (south); RightVector -X, as before the rebuild.
	site.WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + V(0, 0, 1))

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
		archPaths = archPaths,
		containers = table.concat(perContainer, ","),
		children = table.concat(names, ","),
	}
end
