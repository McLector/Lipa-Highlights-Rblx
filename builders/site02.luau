-- site02: Candido B. Lopez Memorial Public Market (Slice 4, rebuilt from PublicMarketBP1.jpg) ASSEMBLER. Studio copy: ServerStorage.Builders.site02; run with
--   return require(game.ServerStorage.Builders.site02:Clone())()
-- Brief: briefs/site02.md ("Rebuild from BP1" and the NAMING CONTRACT). Check: tests/site02_check.luau (ServerStorage.Checks.site02_check).
-- HARDCODED (kept in step with SiteData row 2): model Workspace.Sites.Site02_Market, ORIGIN (-402, 0, 160), slot 348 x 330 = world x -576..-228, z -5..325.
-- FRAME: world-aligned. Local axes = world axes, world = ORIGIN + (lx, ly, lz); y is height above the ground (ground is y 0; the assembler
--   raycasts and asserts it within 0.6). The model faces +X (East): WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + (1,0,0)) is written after parenting.
-- KEEP SET: Guide, InfoPanel, LocalNPCs are never touched, moved or recreated. EVERY other child of the model (old Structure, Yard, MarketStalls, Baskets,
--   Produce, PriceSigns, VendorNPCs, loose parts) is destroyed on every run (a keep list, not a replace list); this job builds no vendors or props.
-- IDEMPOTENT. Fail-safe order (same as site10): everything is planned unparented first, so an error leaves the old model untouched; then the
--   old non-kept children are destroyed and the plan is parented in batches with task.wait(). No terrain writes.
-- The Structure tree of the naming contract is always created (empty Folders are fine; Yard is a Model). Grouping nodes Structure, Structure/Hall and
--   Structure/Sheds never hold parts: env.section refuses them.
--
-- ============================ MODULE CONTRACT ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site02_<name>.luau). Each one is
--     return function(env) ... end
-- and is loaded with require(mod:Clone()). A missing module is skipped; a module returning an empty function adds nothing.
-- Container paths (relative to Structure, plus "Yard"): "Hall/Shell", "Hall/Windows", "Stairs", "Scaffold", "Sheds/Gabled", "Sheds/Markets",
--   "Bagsakan", "CornerBlock", "ServiceBlock", "Forecourt", "Yard" (a Model directly under the site; the others are Folders). Ownership and part budgets:
--     site02_hall   Hall/Shell, Hall/Windows                        420  (two containers, each at most 400 parts)
--     site02_front  Hall/Shell (portico), Stairs, Scaffold          200
--     site02_sheds  Sheds/Gabled, Sheds/Markets, Bagsakan           450
--     site02_block   CornerBlock, ServiceBlock                      150
--     site02_yard   Forecourt, Yard                                 550
--   Every container holds at most 400 parts in its subtree (hard error at plan time); the site (built + kept parts) at most 2000.
-- env fields (LOCAL coordinates unless the name starts with w; y is height above ground):
--   env.V, env.CF, env.ANG, env.PI, env.ORIGIN (Vector3 -402,0,160), env.BuildKit, env.GROUND
--   env.box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)      axis-aligned box from min/max corners (local)
--   env.vcyl(ctx, name, x, z, y0, y1, dia, color, material)           vertical cylinder (local)
--   env.ball(ctx, name, x, y, z, dia, color, material)                sphere (local)
--   env.wbox / env.wvcyl / env.wball   the same three, but x and z are WORLD coordinates (contract numbers can be typed as they are)
--   env.W(x, y, z)           world point -> local Vector3
--   env.container(path)      the planned container instance (owned paths only)
--   env.section(path, fn [, dest])   fresh BuildKit ctx (origin CFrame.new(ORIGIN), budget = env.budget()), runs fn(ctx), plans every part it made
--                            into the container, or into dest (an instance from newFolder/newChild) which must lie inside that container
--   env.newFolder(path, subName [, className])   planned empty Folder (or className) inside the container; returns it
--   env.newChild(parent, name [, className])     planned empty Model/Folder under an instance returned by container/newFolder/newChild
--   env.used()  parts planned so far, all modules     env.budget()  parts this module may still add
-- Rules: only anchored parts (BuildKit does it), no Decals/Textures/ImageLabels, ASCII text only, human scale fixed (doors 8+, rails 3),
-- nothing below y -0.5 (domes and heaps -0.6), every part inside the slot, the pinned names of the contract.
-- ==========================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi

	local ORIGIN = V(-402, 0, 160)
	local MODEL_NAME = "Site02_Market"
	local SITE_CAP, CONTAINER_CAP = 2000, 400
	local KEEP = { Guide = true, InfoPanel = true, LocalNPCs = true }
	local MODULES = {
		{ name = "site02_hall", owns = { ["Hall/Shell"] = true, ["Hall/Windows"] = true }, budget = 420 },
		{ name = "site02_front", owns = { ["Hall/Shell"] = true, Stairs = true, Scaffold = true }, budget = 200 },
		{ name = "site02_sheds", owns = { ["Sheds/Gabled"] = true, ["Sheds/Markets"] = true, Bagsakan = true }, budget = 450 },
		{ name = "site02_block", owns = { CornerBlock = true, ServiceBlock = true }, budget = 150 },
		{ name = "site02_yard", owns = { Forecourt = true, Yard = true }, budget = 550 },
	}
	-- path -> { parent path ("" is the site), class, grouping }
	local TREE = {
		{ "Structure", "", "Folder", true },
		{ "Hall", "Structure", "Folder", true },
		{ "Hall/Shell", "Hall", "Folder" },
		{ "Hall/Windows", "Hall", "Folder" },
		{ "Stairs", "Structure", "Folder" },
		{ "Scaffold", "Structure", "Folder" },
		{ "Sheds", "Structure", "Folder", true },
		{ "Sheds/Gabled", "Sheds", "Folder" },
		{ "Sheds/Markets", "Sheds", "Folder" },
		{ "Bagsakan", "Structure", "Folder" },
		{ "CornerBlock", "Structure", "Folder" },
		{ "ServiceBlock", "Structure", "Folder" },
		{ "Forecourt", "Structure", "Folder" },
		{ "Yard", "", "Model" },
	}

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site02: Workspace.Sites not found (run builders/placeholders first)")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site02: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)

	-- Ground probe (no terrain writes). Ignore our own model.
	local ground = nil
	do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = existing and { existing } or {}
		local hit = workspace:Raycast(ORIGIN + V(0, 80, 0), V(0, -200, 0), params)
		if hit then
			ground = hit.Position.Y
			assert(math.abs(ground) <= 0.6, string.format("site02: ground at ORIGIN is y %.2f, expected about 0", ground))
		end
	end
	local GROUND = ground or 0

	------------------------------------------------------------------ helpers
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, CF(x, y, z), color, material)
	end
	local ox, oz = ORIGIN.X, ORIGIN.Z
	local function wbox(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return box(ctx, name, x0 - ox, x1 - ox, y0, y1, z0 - oz, z1 - oz, color, material)
	end
	local function wvcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return vcyl(ctx, name, x - ox, z - oz, y0, y1, dia, color, material)
	end
	local function wball(ctx, name, x, y, z, dia, color, material)
		return ball(ctx, name, x - ox, y, z - oz, dia, color, material)
	end

	------------------------------------------------------------------ plan
	local used = 0
	local plan = {}
	local SITE_TOKEN = {}
	local planParent = {} -- planned instance -> planned destination (instances are not linked until the swap)
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
		assert(type(fn) == "function", "site02: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, SITE_CAP - used))
		end
		local function owned(path)
			assert(def.owns[path], string.format("site02: %s does not own container %s", def.name, tostring(path)))
			return containers[path]
		end
		local function inside(dest, path) -- is dest the container or a planned descendant of it?
			local cur = dest
			while cur and cur ~= SITE_TOKEN do
				if cur == containers[path] then return true end
				cur = planParent[cur]
			end
			return false
		end
		local env = {
			V = V, CF = CF, ANG = ANG, PI = PI, ORIGIN = ORIGIN, BuildKit = BuildKit, GROUND = GROUND,
			box = box, vcyl = vcyl, ball = ball, wbox = wbox, wvcyl = wvcyl, wball = wball,
			W = function(x, y, z) return V(x - ox, y, z - oz) end,
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
		function env.newChild(parent, name, className)
			local inst = Instance.new(className or "Model")
			inst.Name = name
			assert(planParent[parent] ~= nil, "site02: newChild parent is not a planned instance")
			place(inst, parent)
			return inst
		end
		function env.section(path, sectionFn, dest)
			local c = owned(path)
			assert(not grouping[c], "site02: grouping node holds no parts: " .. path)
			local target = dest or c
			assert(inside(target, path), "site02: dest is not inside container " .. path)
			local holder = Instance.new("Model") -- unparented scratch; BuildKit's chunks sit in it and are never parented
			local ctx = BuildKit.new(holder, CF(ORIGIN), { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
			counts[path] += n
			assert(counts[path] <= CONTAINER_CAP, string.format("site02: container %s holds %d parts, cap %d", path, counts[path], CONTAINER_CAP))
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
	if existing then
		for _, child in ipairs(existing:GetChildren()) do
			if KEEP[child.Name] then
				if child:IsA("BasePart") then kept += 1 end
				for _, d in ipairs(child:GetDescendants()) do
					if d:IsA("BasePart") then kept += 1 end
				end
			end
		end
	end
	assert(used + kept <= SITE_CAP, string.format("site02: %d built + %d kept parts exceed the %d site cap", used, kept, SITE_CAP))

	------------------------------------------------------------------ swap
	local site = existing
	if not site then
		site = Instance.new("Model")
		site.Name = MODEL_NAME
		site.Parent = sites
	end
	for _, child in ipairs(site:GetChildren()) do
		if not KEEP[child.Name] then child:Destroy() end
	end
	-- Containers come first in the plan, so each is parented empty and then filled, in batches.
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 200 == 0 then task.wait() end
	end

	-- Property write: no part moves. Writable even without a PrimaryPart.
	site.WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + V(1, 0, 0))

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
