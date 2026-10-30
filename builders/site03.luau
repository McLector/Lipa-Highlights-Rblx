-- site03: Lomi King (Slice 07, rebuilt from the Lomi King Architectural Blueprint Board and the Street View photo, plan L1b) ASSEMBLER. Studio copy: ServerStorage.Builders.site03; run with
--   return require(game.ServerStorage.Builders.site03:Clone())()
-- Check: tests/site03_check.luau (ServerStorage.Checks.site03_check), groups general, tower, front, dining, context, clear. Design source: docs/handoff/053-handoff.md "Lomi King plan".
-- HARDCODED (kept in step with SiteData row 3, asserted at run time): model Workspace.Sites.Site03_Lomi (must already exist, never created here),
--   ORIGIN (292, 0, 140), slot 100 x 110, facing W. Same coordinator pattern as builders/site02.luau.
-- FRAME: world-aligned by default. Local axes = world axes, world = ORIGIN + (lx, ly, lz); y is height above the ground (ground is y 0; the assembler
--   raycasts and asserts it within 0.6). The model faces -X (West): WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + (-1,0,0)) is written after parenting (site02 faces east).
--   env.LK is the site's yawed frame, the Lomi frame of the old single-file builder: CF(ORIGIN) * fromMatrix(0, (0,0,1), (0,1,0), (-1,0,0)).
--   Local +X = South, local +Z = West (the frontage, outward), world = ORIGIN + (-lz, ly, lx). env.section(path, fn, dest, frame) builds in that frame when given it as 4th argument.
--   A SurfaceGui on the frontage side is on the part's local +Z face = Enum.NormalId.Back (the west face only because of LK).
-- KEEP SET: Guide, InfoPanel, LocalNPCs are never touched, moved or recreated. EVERY other child of the model (old Structure, Block, Counter, Tables, LomiBowls, Menu,
--   Utensils, Diners, loose parts) is destroyed on every run (a keep list, not a replace list) and rebuilt by the modules.
-- IDEMPOTENT. Fail-safe order (same as site02): everything is planned unparented first, so an error leaves the old model untouched; then the
--   old non-kept children are destroyed and the plan is parented in batches with task.wait(). No terrain writes.
-- The tree of containers is always created, even when a module is missing (empty Models and Folders are fine). Counter, Tables, LomiBowls, Menu and Utensils must be
--   DIRECT children of the site holding parts (BuildCheck requires it). No grouping nodes here: every container may hold parts.
--
-- ============================ MODULE CONTRACT ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site03_<name>.luau). Each one is
--     return function(env) ... end
-- and is loaded with require(mod:Clone()). A missing module is skipped (reported as "missing"); a module returning an empty function adds nothing.
-- Container paths (all direct children of the site): Counter, Tables, LomiBowls, Menu, Utensils, Patio, Podium, Tower, Crown, Storefront, Sign (Models),
--   Diners (a Folder for the diner rigs) and Context (a Folder). Ownership and part budgets:
--     site03_dining   Counter, Tables, LomiBowls, Menu, Utensils, Patio, Diners    260  (231 parts; the 3 diner rigs are outside the budget)
--     site03_tower    Podium, Tower, Crown                                          400
--     site03_front    Storefront, Sign                                              220
--     site03_context  Context                                                       300
--   Every container holds at most 400 parts in its subtree (hard error at plan time); the site (built + kept parts) at most 2500 (BuildCheck's SITE_PART_BUDGET).
-- env fields (LOCAL coordinates unless the name starts with w; y is height above ground):
--   env.V, env.CF, env.ANG, env.PI, env.ORIGIN (Vector3 292,0,140), env.BuildKit, env.GROUND, env.LK (the yawed Lomi frame, a CFrame)
--   env.box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)      axis-aligned box from min/max corners (local)
--   env.vcyl(ctx, name, x, z, y0, y1, dia, color, material)           vertical cylinder (local)
--   env.ball(ctx, name, x, y, z, dia, color, material)                sphere (local)
--   env.wbox / env.wvcyl / env.wball   the same three, but x and z are WORLD coordinates (contract numbers can be typed as they are)
--   env.W(x, y, z)           world point -> local Vector3 (for the default world-aligned frame)
--   env.container(path)      the planned container instance (owned paths only)
--   env.section(path, fn [, dest [, frame]])   fresh BuildKit ctx (origin CFrame.new(ORIGIN), or frame when given; budget = env.budget()), runs fn(ctx), plans every part it made
--                            into the container, or into dest (an instance from newFolder/newChild) which must lie inside that container
--   env.newFolder(path, subName [, className])   planned empty Folder (or className) inside the container; returns it
--   env.newChild(parent, name [, className])     planned empty Model/Folder under an instance returned by container/newFolder/newChild
--   env.addRig(rig [, folderName])   rig = an UNPARENTED Model with a Humanoid, already positioned (CreateHumanoidModelFromDescription yields: build it in the module). folderName
--                            defaults to "VendorNPCs", which does not exist here, so pass "Diners"; the module must own that folder. Plans the rig into it. Its BaseParts count toward
--                            env.used() (the 2500 site cap) but NOT toward the module budget or the 400-part container rule. The returned table reports the total as rigParts.
--   env.used()  parts planned so far, all modules (rigs included)     env.budget()  parts this module may still add
-- Rules: only anchored parts (BuildKit does it), no Decals/Textures/ImageLabels, ASCII text only, human scale fixed (doors 8+, rails 3),
-- nothing below y -0.5 (domes and heaps -0.6), every part inside the slot, the pinned names of the check's NAMING CONTRACT.
-- ==========================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi

	local ORIGIN = V(292, 0, 140)
	local MODEL_NAME = "Site03_Lomi"
	local SITE_CAP, CONTAINER_CAP = 2500, 400
	local KEEP = { Guide = true, InfoPanel = true, LocalNPCs = true }
	local MODULES = {
		{ name = "site03_dining", owns = { Counter = true, Tables = true, LomiBowls = true, Menu = true, Utensils = true, Patio = true, Diners = true }, budget = 260 },
		{ name = "site03_tower", owns = { Podium = true, Tower = true, Crown = true }, budget = 400 },
		{ name = "site03_front", owns = { Storefront = true, Sign = true }, budget = 220 },
		{ name = "site03_context", owns = { Context = true }, budget = 300 },
	}
	-- path -> { parent path ("" is the site), class, grouping }
	local TREE = {
		{ "Counter", "", "Model" },
		{ "Tables", "", "Model" },
		{ "LomiBowls", "", "Model" },
		{ "Menu", "", "Model" },
		{ "Utensils", "", "Model" },
		{ "Patio", "", "Model" },
		{ "Diners", "", "Folder" },
		{ "Podium", "", "Model" },
		{ "Tower", "", "Model" },
		{ "Crown", "", "Model" },
		{ "Storefront", "", "Model" },
		{ "Sign", "", "Model" },
		{ "Context", "", "Folder" },
	}

	-- The Lomi frame of the old builder: local +X = South, local +Z = West (frontage, outward).
	local LK = CF(ORIGIN) * CFrame.fromMatrix(V(0, 0, 0), V(0, 0, 1), V(0, 1, 0), V(-1, 0, 0))

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site03: Workspace.Sites not found (run builders/placeholders first)")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site03: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)
	assert(existing, "site03: Workspace.Sites.Site03_Lomi not found (run builders/placeholders first; this builder never creates it)")

	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local row = SiteData.byId(3)
	assert(row and row.facing == "W", "site03: SiteData row 3 is missing or not facing W")
	assert(row.pos == ORIGIN, string.format("site03: SiteData row 3 is at %s, expected %s", tostring(row and row.pos), tostring(ORIGIN)))
	assert(row.size.X == 100 and row.size.Y == 110, string.format("site03: SiteData row 3 size is %s, expected 100 x 110", tostring(row.size)))

	-- Ground probe (no terrain writes). Ignore our own model.
	local ground = nil
	do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { existing }
		local hit = workspace:Raycast(ORIGIN + V(0, 80, 0), V(0, -200, 0), params)
		if hit then
			ground = hit.Position.Y
			assert(math.abs(ground) <= 0.6, string.format("site03: ground at ORIGIN is y %.2f, expected about 0", ground))
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
	local rigParts = 0
	local function runModule(def)
		local mod = builders:FindFirstChild(def.name)
		if not mod then
			return "missing"
		end
		local fn = require(mod:Clone())
		assert(type(fn) == "function", "site03: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, SITE_CAP - used))
		end
		local function owned(path)
			assert(def.owns[path], string.format("site03: %s does not own container %s", def.name, tostring(path)))
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
			V = V, CF = CF, ANG = ANG, PI = PI, ORIGIN = ORIGIN, BuildKit = BuildKit, GROUND = GROUND, LK = LK,
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
			assert(planParent[parent] ~= nil, "site03: newChild parent is not a planned instance")
			place(inst, parent)
			return inst
		end
		function env.section(path, sectionFn, dest, frame)
			local c = owned(path)
			assert(not grouping[c], "site03: grouping node holds no parts: " .. path)
			local target = dest or c
			assert(inside(target, path), "site03: dest is not inside container " .. path)
			local holder = Instance.new("Model") -- unparented scratch; BuildKit's chunks sit in it and are never parented
			local ctx = BuildKit.new(holder, frame or CF(ORIGIN), { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
			counts[path] += n
			assert(counts[path] <= CONTAINER_CAP, string.format("site03: container %s holds %d parts, cap %d", path, counts[path], CONTAINER_CAP))
			modUsed += n
			used += n
			for _, p in ipairs(ctx:parts()) do
				place(p, target)
			end
			return target
		end
		function env.addRig(rig, folderName)
			folderName = folderName or "VendorNPCs"
			assert(def.owns[folderName], "site03: " .. def.name .. " does not own " .. folderName .. ", so it cannot add rigs to it")
			assert(typeof(rig) == "Instance" and rig:IsA("Model") and rig:FindFirstChildOfClass("Humanoid"), "site03: addRig needs a Model with a Humanoid")
			assert(rig.Parent == nil, "site03: addRig takes an unparented rig")
			local n = 0
			for _, d in ipairs(rig:GetDescendants()) do
				if d:IsA("BasePart") then n += 1 end
			end
			rigParts += n
			used += n -- the site cap sees the rig; the module budget and counts[path] do not
			place(rig, containers[folderName])
			return rig
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
	assert(used + kept <= SITE_CAP, string.format("site03: %d built + %d kept parts exceed the %d site cap", used, kept, SITE_CAP))

	------------------------------------------------------------------ swap
	local site = existing
	for _, child in ipairs(site:GetChildren()) do
		if not KEEP[child.Name] then child:Destroy() end
	end
	-- Containers come first in the plan, so each is parented empty and then filled, in batches.
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 200 == 0 then task.wait() end
	end

	-- Property write: no part moves. Writable even without a PrimaryPart.
	site.WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + V(-1, 0, 0))

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
		rigParts = rigParts,
		keptParts = kept,
		ground = ground,
		modules = report,
		containers = table.concat(perContainer, ","),
		children = table.concat(names, ","),
	}
end
