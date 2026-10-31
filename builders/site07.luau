-- site07: The Farm at San Benito, rebuilt from "San_benito_blueprint.png" (Standard tier, 2026-10-31) ASSEMBLER.
-- Studio copy: ServerStorage.Builders.site07; run with
--   return require(game.ServerStorage.Builders.site07:Clone())()
-- Check: tests/site07_check.luau (ServerStorage.Checks.site07_check), groups general, entrance, south, centre, north, east, planting, ground.
-- Brief: briefs/site07.md Revision 2. Same coordinator pattern as builders/site05.luau.
-- HARDCODED (kept in step with SiteData row 7, asserted at run time): model Workspace.Sites.Site07_Farm (must already exist, never created
--   here), ORIGIN (770, 0, 240), slot 400 x 320 (x 570..970, z 80..400), facing W.
-- FRAME: WORLD coordinates. The helpers take world x, y, z directly (+X east, +Z south, y above the ground at 0). The board's north is
--   world north. The model faces W: WorldPivot = CFrame.lookAt(ORIGIN, ORIGIN + (-1,0,0)) is written after parenting.
-- KEEP SET: Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney, LocalNPCs are never touched, moved or recreated. EVERY other child
--   of the model is destroyed on every run (a keep list, not a replace list) and rebuilt by the modules. NO TERRAIN WRITES in the modules (the last step, site07_ground, only repaints Grass): the rivers and
--   lagoons are parts, flush with the ground; the old Pavement cells and the old terrain lagoon (x 700..800, z 300..352) are covered by parts.
-- IDEMPOTENT. Fail-safe order (site05): everything is planned unparented first, so an error leaves the old model untouched; then the old
--   non-kept children are destroyed and the plan is parented in batches with task.wait().
--
-- ============================ MODULE CONTRACT ============================
-- Modules are FLAT siblings in ServerStorage.Builders (disk: builders/site07_<name>.luau), each `return function(env) ... end`, loaded with
-- require(mod:Clone()). A missing module is skipped (reported "missing").
--     site07_entrance  Structure/River, Structure/Entrance, Structure/Banaba, Structure/Parking                    500
--     site07_water     Structure/BigLagoon, Structure/Acqua, Structure/FrontOffice                                  350
--     site07_villas    GardenPavilion, Structure/GlassVilla, NarraVillas, Amphitheater, SmallVillas                  550
--     site07_halls     Structure/Temple, Structure/Sanctuary                                                        300
--     site07_grounds   LandscapedPath/*, WellnessPanel, Structure/PalmsA, PalmsB, PalmsC, Trees, TreesB           1850
--   Every container holds at most 400 parts (hard error at plan time); the site (built + kept) at most 2500 (BuildCheck).
-- env (WORLD coordinates): V, CF, ANG, PI, ORIGIN, BuildKit, LAYOUT, and the helpers
--   box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)          axis-aligned box from min/max corners
--   seg(ctx, name, x0, z0, x1, z1, w, y0, y1, color, material, ext)  horizontal box from (x0,z0) to (x1,z1), w wide, ends extended by ext
--   vcyl(ctx, name, x, z, y0, y1, dia, color, material)             vertical cylinder (a disc when flat)
--   ball(ctx, name, x, y, z, dia, color, material)                  sphere
--   strip / corner / hipRoof(ctx, name, x0, x1, z0, z1, y0, rise, color, material)   as builders/site05.luau (the first slope is `name`)
--   ring(ctx, name, cx, cz, r, n, w, y0, y1, color, material, skip)  n-sided ring of boxes (radius r to the segment centre, w deep);
--                                                                    skip(k) -> true leaves segment k out
--   palm(ctx, x, z, h) (8 parts), tree(ctx, x, z, h, dia) (3 parts), shrub(ctx, x, z, dia) (1 part)
--   gui(part, face, title, body, color, ppstud, titleSize, bodySize) SurfaceGui with fixed-TextSize labels
--   section(path, fn [, dest]), newFolder(path, name [, class]), container(path), used(), budget()
-- Rules: anchored parts only (BuildKit), no Decals/Textures/ImageLabels, ASCII only, human scale fixed (doors 8+, rails 3, counters 3.5,
-- chairs 2), every part inside the slot, nothing below y -1, the names pinned by tests/site07_check.luau. No randomness: every run is equal.
-- ==========================================================================
return function()
	local BuildKit = require(game.ServerStorage.BuildKit:Clone())
	local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
	local PI = math.pi

	local ORIGIN = V(770, 0, 240)
	local MODEL_NAME = "Site07_Farm"
	local SITE_CAP, CONTAINER_CAP = 2500, 400
	local KEEP = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
	local MODULES = {
		{ name = "site07_entrance", owns = { ["Structure/River"] = true, ["Structure/Entrance"] = true, ["Structure/Banaba"] = true, ["Structure/Parking"] = true }, budget = 500 },
		{ name = "site07_water", owns = { ["Structure/BigLagoon"] = true, ["Structure/Acqua"] = true, ["Structure/FrontOffice"] = true }, budget = 350 },
		{ name = "site07_villas", owns = { GardenPavilion = true, ["Structure/GlassVilla"] = true, ["Structure/NarraVillas"] = true, ["Structure/Amphitheater"] = true,
			["Structure/SmallVillas"] = true }, budget = 550 },
		{ name = "site07_halls", owns = { ["Structure/Temple"] = true, ["Structure/Sanctuary"] = true }, budget = 300 },
		{ name = "site07_grounds", owns = { ["LandscapedPath/Entry"] = true, ["LandscapedPath/Plaza"] = true, ["LandscapedPath/Walks"] = true, WellnessPanel = true,
			["Structure/PalmsA"] = true, ["Structure/PalmsB"] = true, ["Structure/PalmsC"] = true, ["Structure/Trees"] = true, ["Structure/TreesB"] = true }, budget = 1850 },
	}
	-- path -> { name path, parent path ("" is the site), class, grouping }
	local TREE = {
		{ "Structure", "", "Folder", true },
		{ "Structure/River", "Structure", "Model" },
		{ "Structure/Entrance", "Structure", "Model" },
		{ "Structure/Banaba", "Structure", "Model" },
		{ "Structure/Parking", "Structure", "Model" },
		{ "Structure/BigLagoon", "Structure", "Model" },
		{ "Structure/Acqua", "Structure", "Model" },
		{ "Structure/FrontOffice", "Structure", "Model" },
		{ "Structure/GlassVilla", "Structure", "Model" },
		{ "Structure/NarraVillas", "Structure", "Model" },
		{ "Structure/Amphitheater", "Structure", "Model" },
		{ "Structure/SmallVillas", "Structure", "Model" },
		{ "Structure/Temple", "Structure", "Model" },
		{ "Structure/Sanctuary", "Structure", "Model" },
		{ "Structure/PalmsA", "Structure", "Model" },
		{ "Structure/PalmsB", "Structure", "Model" },
		{ "Structure/PalmsC", "Structure", "Model" },
		{ "Structure/Trees", "Structure", "Model" },
		{ "Structure/TreesB", "Structure", "Model" },
		{ "GardenPavilion", "", "Model" },
		{ "LandscapedPath", "", "Model", true },
		{ "LandscapedPath/Entry", "LandscapedPath", "Model" },
		{ "LandscapedPath/Plaza", "LandscapedPath", "Model" },
		{ "LandscapedPath/Walks", "LandscapedPath", "Model" },
		{ "WellnessPanel", "", "Model" },
	}

	-- The board's zones as built (WORLD boxes x0, x1, z0, z1). The grounds module keeps planting out of them; briefs/site07.md Revision 2
	-- lists the same numbers. Eyes and targets of the sites_check sight-lines are here too, so no palm stands in front of them.
	local LAYOUT = {
		ellipse = { cx = 770, cz = 240, a = 189, b = 147, w = 14 }, -- river centre line and width: water a 182..196, b 140..154
		occupied = {
			{ 566, 656, 208, 258 }, -- bridge, gate, guard post, entry path
			{ 650, 702, 186, 264 }, -- arrival plaza (Guide, JeepStop, jeepney, InfoPanel)
			-- tidy (owner's look): the central plaza became lawn with walks; only its features stay clear of planting
			{ 698, 710, 188, 212 }, -- Wellness board
			{ 742, 770, 192, 220 }, -- round thatched pavilion and the staff spot (745, 214)
			{ 716, 772, 220, 276 }, -- amphitheater
			{ 772, 816, 212, 260 }, -- glass villa
			{ 712, 808, 120, 204 }, -- Big Lagoon and its pavilion
			{ 664, 714, 122, 192 }, -- Temple of Five Elements and the labyrinth
			{ 810, 832, 114, 142 }, { 840, 862, 124, 152 }, { 869, 891, 140, 168 }, -- Narra villas and pools
			{ 840, 942, 224, 270 }, -- Front Office and its lagoon
			{ 822, 918, 278, 316 }, -- Holistic Medical Sanctuary
			{ 690, 710, 256, 300 }, { 690, 756, 282, 300 }, -- south walk (lanes c and d)
			{ 706, 798, 290, 352 }, -- Banaba hall, forecourt and canopy
			{ 642, 702, 256, 346 }, -- parking and its drive
			{ 602, 650, 250, 300 }, -- Acqua Hydrotherapy
		},
		-- tidy (owner's look): the board's many small brown hip-roof villas, {x, z, pool side}: Garden Glass on the north edge, Acacia and
		-- Mahogany Luxury on the west edge, Mahogany Pool Villas in the south-west (each 10 x 8, a hip roof, a door toward the centre).
		smallVillas = {
			{ 744, 114 }, { 766, 110 }, { 790, 112 },
			{ 603, 205 }, { 613, 188 }, { 626, 172 }, { 640, 158 },
			{ 626, 306, "E" }, { 643, 318, "N" }, -- pool on that side
		},
		corridors = { -- sight-line triangles (eye, a, b) in x/z, kept clear of planting
			{ { 664, 234 }, { 780, 218 }, { 780, 254 } },
			{ { 576, 236 }, { 780, 218 }, { 780, 254 } },
			{ { 664, 234 }, { 746, 194 }, { 768, 218 } },
		},
	}

	local sites = workspace:FindFirstChild("Sites")
	assert(sites, "site07: Workspace.Sites not found (run builders/placeholders first)")
	local builders = game.ServerStorage:FindFirstChild("Builders")
	assert(builders, "site07: ServerStorage.Builders not found")
	local existing = sites:FindFirstChild(MODEL_NAME)
	assert(existing, "site07: Workspace.Sites.Site07_Farm not found (run builders/placeholders first; this builder never creates it)")

	local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
	local row = SiteData.byId(7)
	assert(row and row.facing == "W", "site07: SiteData row 7 is missing or not facing W")
	assert(row.pos == ORIGIN, string.format("site07: SiteData row 7 is at %s, expected %s", tostring(row and row.pos), tostring(ORIGIN)))
	assert(row.size.X == 400 and row.size.Y == 320, string.format("site07: SiteData row 7 size is %s, expected 400 x 320", tostring(row.size)))

	------------------------------------------------------------------ helpers (world coordinates)
	local UP = V(0, 1, 0)
	local function box(ctx, name, x0, x1, y0, y1, z0, z1, color, material)
		return ctx:part(name, V(x1 - x0, y1 - y0, z1 - z0), CF((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), color, material)
	end
	local function seg(ctx, name, x0, z0, x1, z1, w, y0, y1, color, material, ext)
		local a, b = V(x0, (y0 + y1) / 2, z0), V(x1, (y0 + y1) / 2, z1)
		local len = (b - a).Magnitude + 2 * (ext or 0)
		return ctx:part(name, V(w, y1 - y0, len), CFrame.lookAt((a + b) / 2, b), color, material)
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
	-- Hip roof over x0..x1, z0..z1 from eave y0 rising `rise`: 2 slopes + 4 hip corners (2 + 4 parts; 4 if square). As builders/site05.luau.
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
	-- n-sided ring of boxes around (cx, cz): segment k is centred at angle (k + 0.5) * 2 pi / n, radius r, w deep (radially).
	local function ring(ctx, name, cx, cz, r, n, w, y0, y1, color, material, skip)
		local made = {}
		local side = 2 * (r + w / 2) * math.tan(PI / n) + 0.2
		for k = 0, n - 1 do
			if not (skip and skip(k)) then
				local a = (k + 0.5) * 2 * PI / n
				local c = V(cx + r * math.cos(a), (y0 + y1) / 2, cz + r * math.sin(a))
				local out = V(math.cos(a), 0, math.sin(a))
				table.insert(made, ctx:part(name, V(side, y1 - y0, w), CFrame.lookAt(c, c + out), color, material))
			end
		end
		return made
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
	local TRUNK, FROND, LEAF_D, LEAF_L = Color3.fromRGB(120, 98, 70), Color3.fromRGB(56, 118, 50), Color3.fromRGB(40, 96, 46), Color3.fromRGB(78, 134, 58)
	-- Palm (8 parts): a leaning trunk, 6 long drooping fronds (9.5 long, not colliding) and a head. The lean follows the position, so every run is equal.
	local function palm(ctx, x, z, h)
		local la = ((x * 7.3 + z * 3.1) % 360) * PI / 180
		local top = V(x + 1.2 * math.cos(la), h, z + 1.2 * math.sin(la))
		local base = V(x, 0, z)
		local axis = top - base
		ctx:cyl("PalmTrunk", V(axis.Magnitude, 1.2, 1.2), CFrame.lookAt((base + top) / 2, top) * ANG(0, PI / 2, 0), TRUNK, Enum.Material.Wood)
		for k = 0, 5 do
			local a = k * PI / 3 + la
			local dir = V(math.cos(a), 0, math.sin(a))
			local c = top + dir * 4.2 - V(0, 1.1, 0)
			local f = ctx:part("PalmFrond", V(2.6, 0.3, 9.5), CFrame.lookAt(c, c + dir * 4 - V(0, 1.3, 0)), FROND, Enum.Material.Grass)
			f.CanCollide = false
		end
		ctx:ball("PalmHead", 1.7, CF(top), TRUNK, Enum.Material.Wood)
	end
	local function tree(ctx, x, z, h, dia)
		vcyl(ctx, "TreeTrunk", x, z, 0, h * 0.55, 1.2, TRUNK, Enum.Material.Wood)
		-- crowns do not collide (the trunk does), like the palm fronds: a walk under a low crown stays free
		ctx:ball("TreeCrown", dia, CF(x, h - dia * 0.35, z), LEAF_D, Enum.Material.Grass).CanCollide = false
		ctx:ball("TreeCrown", dia * 0.7, CF(x + dia * 0.2, h - dia * 0.05, z - dia * 0.1), LEAF_L, Enum.Material.Grass).CanCollide = false
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
		assert(type(fn) == "function", "site07: " .. def.name .. " must return function(env)")
		local modUsed = 0
		local function budget()
			return math.max(0, math.min(def.budget - modUsed, SITE_CAP - used))
		end
		local function owned(path)
			assert(def.owns[path], string.format("site07: %s does not own container %s", def.name, tostring(path)))
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
			V = V, CF = CF, ANG = ANG, PI = PI, ORIGIN = ORIGIN, BuildKit = BuildKit, LAYOUT = LAYOUT,
			box = box, seg = seg, vcyl = vcyl, ball = ball, strip = strip, corner = corner, hipRoof = hipRoof, ring = ring, gui = gui,
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
			assert(not grouping[c], "site07: grouping node holds no parts: " .. path)
			local target = dest or c
			assert(inside(target, path), "site07: dest is not inside container " .. path)
			local holder = Instance.new("Model")
			local ctx = BuildKit.new(holder, CFrame.new(), { budget = budget() })
			sectionFn(ctx)
			local n = ctx:count()
			counts[path] += n
			assert(counts[path] <= CONTAINER_CAP, string.format("site07: container %s holds %d parts, cap %d", path, counts[path], CONTAINER_CAP))
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
	assert(used + kept <= SITE_CAP, string.format("site07: %d built + %d kept parts exceed the %d site cap", used, kept, SITE_CAP))

	------------------------------------------------------------------ swap
	local site = existing
	for _, child in ipairs(site:GetChildren()) do
		if not KEEP[child.Name] then child:Destroy() end
	end
	for i, e in ipairs(plan) do
		e.inst.Parent = (e.dest == SITE_TOKEN) and site or e.dest
		if i % 200 == 0 then task.wait() end
	end

	-- Property write: no part moves. Faces W, as SiteData row 7 says.
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
	-- grass cleanup (2026-10-31): the last step repaints the terrain Grass under the ground-level parts (builders/site07_ground.luau,
	-- Grass -> Mud / Pavement / Ground only, inside the slot). Idempotent; skipped if the module is missing.
	local groundMod = builders:FindFirstChild("site07_ground")
	local ground = groundMod and require(groundMod:Clone())() or nil
	return {
		ground = ground and (ground.repainted .. " repainted") or "missing",
		parts = total,
		builtParts = used,
		keptParts = kept,
		modules = report,
		containers = table.concat(perContainer, ","),
		children = table.concat(names, ","),
	}
end
