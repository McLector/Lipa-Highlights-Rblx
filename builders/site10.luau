-- site10: New Lipa City Hall, Brgy. Areza (Slice 3a) ASSEMBLER. Studio copy: ServerStorage.Builders.site10; run with
--   require(game.ServerStorage.Builders.site10:Clone())()
-- Brief: briefs/site10.md. Check: tests/site10_check.luau (ServerStorage.Checks.site10_check).
-- Rebuilt from the blueprint (Step C). HARDCODED (kept in step with SiteData row 10): model Workspace.Sites.Site10_CityHall,
--   ORIGIN (-270, 0, -305), SLOT 240 x 286 = world x -390..-150, z -448..-162.
-- FRAME: world-aligned. Local axes = world axes, world = ORIGIN + (lx, ly, lz). The slot is local x -120..120, z -143..143; the real
--   model fills local x -52..120 (world -322..-150) and z -141..117 (world -446..-188), which keeps roads_check's 10 percent margin
--   rule green. y = height above ground (ground is y 0; the assembler raycasts and asserts it within 0.6). The model faces +X (East).
-- IDEMPOTENT: replaces Wing, Blocks, Steps, Forecourt, Landscape on every run. NEVER touches or creates Guide, InfoPanel, JeepStop,
--   JeepSignPole, JeepSign, Jeepney. No terrain writes. A container only exists if a module asked for it (stubs build nothing).
-- Fail-safe order (same as site09): everything is planned unparented first, so an error leaves the old children untouched; then the
--   old replaced children are destroyed and the plan is parented in batches of <= 400 with task.wait(). Total cap PART_BUDGET = 2500.
-- After parenting, WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + (1,0,0)) (a property write; no part moves).
--
-- ============================ MODULE CONTRACT (for builders of the four modules) ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site10_<name>.luau). Each one is
--     return function(env) ... end
-- and is loaded by the assembler with require(module:Clone()). A missing module is skipped; a stub (empty function) adds nothing.
-- Ownership (container -> module -> check group shared.site10_only):
--     Wing                 site10_wing         "wing"
--     Blocks               site10_blocks       "blocks"
--     Steps AND Forecourt  site10_forecourt    "forecourt"
--     Landscape            site10_landscape    "landscape"
-- Part budgets per module (env.budget() starts at these): wing 900, blocks 500, forecourt 650, landscape 450. The global cap 2500 is
-- asserted by the assembler before anything is parented.
--
-- env fields (all coordinates LOCAL, relative to ORIGIN; y is height above ground):
--   env.V, env.CF, env.ANG   Vector3.new, CFrame.new, CFrame.Angles
--   env.PI                   math.pi
--   env.ORIGIN               Vector3 (-270, 0, -305)
--   env.BuildKit             the BuildKit module (ctx:part / wedge / cyl / ball / gable / window / arch ... see src/ServerStorage/BuildKit.luau)
--   env.GROUND               measured ground height (number, ~0)
--   env.box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)    axis-aligned box from min/max corners
--   env.vcyl(ctx, name, x, z, y0, y1, dia, color, material)         vertical cylinder from y0 to y1 centred on (x, z)
--   env.ball(ctx, name, x, y, z, dia, color, material)               sphere centred on (x, y, z)
--       (same semantics as the site09 helpers; each returns the Part so you can set Transparency, CanCollide, etc.)
--   env.section(containerName, fn [, dest])
--       Makes a fresh BuildKit ctx (origin CFrame.new(ORIGIN), budget = env.budget()), runs fn(ctx), and plans every part it made
--       into the container named containerName ("Wing" | "Blocks" | "Steps" | "Forecourt" | "Landscape"; created on first use as a
--       Model under the site). If `dest` is given (an Instance returned by env.newFolder) the parts go there instead.
--       May be called many times. Returns the destination instance. Errors if you ask for a container you do not own or are over budget.
--   env.newFolder(containerName, subName [, className])
--       Plans an empty Folder (or className, e.g. "Model") named subName inside that container and returns it; pass it as `dest`
--       to env.section. Example: the landscape module makes Landscape.PocketGardens with 3+ child Models, one per garden:
--           local pg = env.newFolder("Landscape", "PocketGardens")
--           local g1 = env.newChild(pg, "PocketGarden1")          -- a Model inside the folder
--           env.section("Landscape", function(ctx) ... end, g1)   -- the parts go into g1
--   env.newChild(parent, name [, className])   plans an empty Model/Folder under an instance returned by newFolder/newChild/section.
--   env.used()      parts planned so far across all modules (own parts; the kept children are not counted)
--   env.budget()    parts this module may still add: min(module budget - module used, 2500 - env.used())
-- Rules: only Anchored parts (BuildKit does it), no Decals/Textures/ImageLabels, text only on signs (see brief), never shrink human
-- scale (doors >= 8, railings 3), keep the pinned WORLD positions clear (spawn pad x -214..-202, z -266..-254; Guide (-223, -260);
-- InfoPanel (-217, -282); JeepStop (-155, -230); Jeepney (-155, -216); see tests/site10_check.luau for the exact clearances and
-- the canopy exemption), stay inside the real bounds world x -323..-149, z -447..-187 (local x -53..121, z -142..118).
-- ===========================================================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi

	local ORIGIN = V(-270, 0, -305)
	local PART_BUDGET = 2500
	local MODEL_NAME = "Site10_CityHall"
	local REPLACED = { Wing = true, Blocks = true, Steps = true, Forecourt = true, Landscape = true }
	-- module name -> { containers it owns, part budget }
	local MODULES = {
		{ name = "site10_wing", owns = { Wing = true }, budget = 900 },
		{ name = "site10_blocks", owns = { Blocks = true }, budget = 500 },
		{ name = "site10_forecourt", owns = { Steps = true, Forecourt = true }, budget = 650 },
		{ name = "site10_landscape", owns = { Landscape = true }, budget = 450 },
	}

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site10: Workspace.Sites not found (run builders/placeholders first)")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site10: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)

	-- Ground probe (no terrain writes). Ignore our own model; other sites sit at y 0.
	local ground = nil
	do
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = existing and { existing } or {}
		local hit = workspace:Raycast(ORIGIN + V(0, 80, 0), V(0, -200, 0), params)
		if hit then
			ground = hit.Position.Y
			assert(math.abs(ground) <= 0.6, string.format("site10: ground at ORIGIN is y %.2f, expected about 0", ground))
		end
	end
	local GROUND = ground or 0

	------------------------------------------------------------------ helpers (same semantics as site09, local frame)
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	local function vcyl(ctx, name, x, z, y0, y1, dia, color, material)
		return ctx:cyl(name, V(y1 - y0, dia, dia), CF(x, (y0 + y1) / 2, z) * ANG(0, 0, PI / 2), color, material)
	end
	local function ball(ctx, name, x, y, z, dia, color, material)
		return ctx:ball(name, dia, CF(x, y, z), color, material)
	end

	------------------------------------------------------------------ plan
	local used = 0
	local plan = {}
	local function place(inst, dest)
		table.insert(plan, { inst = inst, dest = dest })
	end
	-- Containers are created lazily so a stub-only run leaves the model empty. They are planned into SITE_TOKEN (the model, resolved at swap).
	local SITE_TOKEN = {}
	local containers = {}
	local function container(name)
		assert(REPLACED[name], "site10: unknown container " .. tostring(name))
		if not containers[name] then
			local m = Instance.new("Model")
			m.Name = name
			containers[name] = m
			place(m, SITE_TOKEN)
		end
		return containers[name]
	end

	local function runModule(def)
		local mod = builders:FindFirstChild(def.name)
		if not mod then
			return "missing"
		end
		local fn = require(mod:Clone())
		assert(type(fn) == "function", "site10: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, PART_BUDGET - used))
		end
		local function owned(name)
			assert(def.owns[name], string.format("site10: %s does not own container %s", def.name, tostring(name)))
		end
		local env = {
			V = V, CF = CF, ANG = ANG, PI = PI, ORIGIN = ORIGIN, BuildKit = BuildKit, GROUND = GROUND,
			box = box, vcyl = vcyl, ball = ball,
			used = function() return used end,
			budget = budget,
		}
		function env.newFolder(containerName, subName, className)
			owned(containerName)
			local inst = Instance.new(className or "Folder")
			inst.Name = subName
			place(inst, container(containerName))
			return inst
		end
		function env.newChild(parent, name, className)
			local inst = Instance.new(className or "Model")
			inst.Name = name
			place(inst, parent)
			return inst
		end
		function env.section(containerName, sectionFn, dest)
			owned(containerName)
			local target = dest or container(containerName)
			local holder = Instance.new("Model") -- unparented scratch; BuildKit's chunks sit in it and are never parented
			local ctx = BuildKit.new(holder, CF(ORIGIN), { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
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

	local report = {}
	for _, def in ipairs(MODULES) do
		report[def.name] = runModule(def)
	end
	assert(used <= PART_BUDGET, string.format("site10: %d parts exceeds the %d budget", used, PART_BUDGET))

	------------------------------------------------------------------ swap
	local site = existing
	if not site then
		site = Instance.new("Model")
		site.Name = MODEL_NAME
		site.Parent = sites
	end
	for _, child in ipairs(site:GetChildren()) do
		if REPLACED[child.Name] then child:Destroy() end
	end
	-- Containers come first in the plan, so each is parented empty and then filled.
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 300 == 0 then task.wait() end
	end

	-- Property write: no part moves. Writable even without a PrimaryPart.
	site.WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + V(1, 0, 0))

	local names = {}
	for _, c in ipairs(site:GetChildren()) do table.insert(names, c.Name) end
	table.sort(names)
	local total = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then total += 1 end
	end
	return {
		parts = total,
		builtParts = used,
		ground = ground,
		modules = report,
		children = table.concat(names, ","),
	}
end
