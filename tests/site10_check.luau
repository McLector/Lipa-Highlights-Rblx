-- site10_check: the fidelity spec for Site 10 (New Lipa City Hall), REBUILT from the blueprint drawing (Step C). Written BEFORE the build.
-- Studio copy: ServerStorage.Checks.site10_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site10_check:Clone())      -- returns JSON {passed, failed, failures}
-- Source of truth for the design: scratch/site10/layout.md and scratch/site10/model.py. Retired assertions: briefs/site10.md, "Step C (blueprint rebuild)".
-- The model is built in a world-aligned frame (ORIGIN below), pivot at ORIGIN, facing +X (East). world = ORIGIN + (lx, ly, lz).
-- Checks are grouped by builder module; set shared.site10_only = "blocks" | "wing" | "forecourt" | "landscape" | "general" to run one group.
-- Every assertion is a guard rail: a faithful build of layout.md passes it. Names that the layout writes at ITEM level (WB01, Terrace*, Car_*,
-- LoopRoad ...) are accepted next to the owner's part names (WhiteBrickBox, TerraceStrip, ParkedCar, LoopRing ...); see PAT below.
local HttpService = game:GetService("HttpService")
local ORIGIN = Vector3.new(-270, 0, -305)
-- Real bounds of every part of the model (roads_check's 10 percent margin rule needs these): x -323..-149, z -447..-187.
local B_MIN, B_MAX = Vector3.new(-323, 0, -447), Vector3.new(-149, 0, -187)
-- World pins (fixed by the owner; the local offsets in SiteData row 10 were changed so these stay put).
local PAD = { x0 = -214, x1 = -202, z0 = -266, z1 = -254 }
local GUIDE, PANEL = Vector3.new(-223, 0, -260), Vector3.new(-217, 0, -282)
local JEEPSTOP, JEEPNEY = Vector3.new(-155, 0, -230), Vector3.new(-155, 0, -216)

-- Part-name families. Lua patterns, anchored. A family matches Models and BaseParts; "units" skip anything nested in an already matching ancestor.
local PAT = {
	Column = { "^Column%d*$" },
	RoofBox = { "^RoofBox%d*$", "^CanopyRoofBox%d*$" },
	WhiteBrickBox = { "^WhiteBrickBox%u?%d*$", "^WB%d+$", "^AB%d+$" }, -- layout item names WB01..WB11, AB1..AB5
	GlassBand = { "^GlassBand%u?%d*$" },
	BalconySlab = { "^BalconySlab%u?%d*$", "^CoreBalcony%d+$" }, -- layout item names CoreBalcony1..3
	TerraceStrip = { "^TerraceStrip%u?%d*$", "^Terrace[SN]%d+$" },
	TerraceWall = { "^TerraceWall%u?%d*$", "^Terrace[SN]%d+Wall$" },
	LoopRing = { "^LoopRing%d*$", "^LoopRoad%d*$" }, -- layout item name LoopRoad
	LoopIsland = { "^LoopIsland%d*$" },
	BayLine = { "^BayLine%u?%d*$" },
	ParkedCar = { "^ParkedCar%d*$", "^Car_%a+%d*$" }, -- layout item names Car_A1, Car_Loop1 ...
	Tree = { "^Tree%d*$", "^%a*Tree%d+$" }, -- Tree, Tree3, WalkTree7; not TreeTrunk / TreeCanopy
	Palm = { "^Palm%d*$" },
	Pilotis = { "^Piloti%a*%d*$", "^Pilotis_%w+$" }, -- Pilotis, PilotiA3, PilotiAtrSE2, Pilotis_WB03; not BlockPilotis
	Door = { "^Door%d+$", "^EntranceDoor%d*$" },
	Flag = { "^Flag%d*$" },
	Tread = { "^StepTread%d*$", "^StairTread%d+$" },
	Riser = { "^StepRiser%d*$" },
}
local FLOOR_NAMES = { "^FloorBand%d*$", "^FloorSlab%d*$", "^Slab%d*$", "^GlassBand%u?%d*$", "^RoofSlab%d*$" }

local function run(opts)
	opts = opts or {}
	local only = opts.only
	local results = { passed = 0, failed = 0, failures = {} }
	local function check(name, cond, detail)
		if cond then
			results.passed += 1
		else
			results.failed += 1
			table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
		end
	end
	local function want(group)
		return only == nil or only == group
	end

	-- The model lives in Workspace.Sites or, if the gate says so, Workspace.Staging.
	local site
	for _, parent in ipairs({ workspace:FindFirstChild("Sites"), workspace:FindFirstChild("Staging") }) do
		if parent and parent:FindFirstChild("Site10_CityHall") then site = parent.Site10_CityHall end
	end
	check("Site10_CityHall exists", site ~= nil)
	if not site then
		return HttpService:JSONEncode(results)
	end

	------------------------------------------------------------------ helpers
	local function isRig(inst)
		local p = inst
		while p and p ~= site do
			if p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
		end
		return false
	end
	local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
	local function isKept(inst)
		local p = inst
		while p and p ~= site do
			if KEPT[p.Name] and p.Parent == site then return true end
			p = p.Parent
		end
		return false
	end
	local function matches(name, kind)
		for _, pt in ipairs(PAT[kind]) do
			if string.match(name, pt) then return true end
		end
		return false
	end
	local function matchesAny(name, list)
		for _, pt in ipairs(list) do
			if string.match(name, pt) then return true end
		end
		return false
	end
	-- Own parts: everything the builder made (no rig, no kept placeholder).
	local ownCache
	local function ownParts()
		if ownCache then return ownCache end
		ownCache = {}
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("BasePart") and not isRig(d) and not isKept(d) then table.insert(ownCache, d) end
		end
		return ownCache
	end
	local function parts(kind) -- BaseParts of a family
		local list = {}
		for _, p in ipairs(ownParts()) do
			if matches(p.Name, kind) then table.insert(list, p) end
		end
		return list
	end
	local function units(kind) -- top-level Models/BaseParts of a family
		local list = {}
		for _, d in ipairs(site:GetDescendants()) do
			if (d:IsA("BasePart") or d:IsA("Model")) and matches(d.Name, kind) and not isRig(d) and not isKept(d) then
				local top, a = true, d.Parent
				while a and a ~= site do
					if matches(a.Name, kind) then top = false break end
					a = a.Parent
				end
				if top then table.insert(list, d) end
			end
		end
		return list
	end
	local function unitPos(u) return u:IsA("Model") and u:GetPivot().Position or u.Position end
	local function inside(p, container) return container ~= nil and p:IsDescendantOf(container) end
	local function partsIn(container, filter)
		local list = {}
		if container then
			for _, d in ipairs(container:GetDescendants()) do
				if d:IsA("BasePart") and (filter == nil or filter(d)) then table.insert(list, d) end
			end
		end
		return list
	end

	-- Oriented world bounds (8 corners), cached.
	local bcache = {}
	local function wbounds(p)
		local c = bcache[p]
		if c then return c[1], c[2] end
		local cf, h = p.CFrame, p.Size / 2
		local lo, hi = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, sx in ipairs({ -1, 1 }) do
			for _, sy in ipairs({ -1, 1 }) do
				for _, sz in ipairs({ -1, 1 }) do
					local w = cf * Vector3.new(sx * h.X, sy * h.Y, sz * h.Z)
					lo = Vector3.new(math.min(lo.X, w.X), math.min(lo.Y, w.Y), math.min(lo.Z, w.Z))
					hi = Vector3.new(math.max(hi.X, w.X), math.max(hi.Y, w.Y), math.max(hi.Z, w.Z))
				end
			end
		end
		bcache[p] = { lo, hi }
		return lo, hi
	end
	local function top(p) local _, hi = wbounds(p) return hi.Y end
	local function bottom(p) local lo = wbounds(p) return lo.Y end
	local function height(p) local lo, hi = wbounds(p) return hi.Y - lo.Y end
	local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
	local function round(n, step) step = step or 1 return math.floor(n / step + 0.5) * step end
	local function union(list)
		local lo, hi = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
		for _, p in ipairs(list) do
			local a, b = wbounds(p)
			lo = Vector3.new(math.min(lo.X, a.X), math.min(lo.Y, a.Y), math.min(lo.Z, a.Z))
			hi = Vector3.new(math.max(hi.X, b.X), math.max(hi.Y, b.Y), math.max(hi.Z, b.Z))
		end
		return lo, hi
	end

	-- 2D footprint polygon {{x,z},...} and exact polygon distance (yaw-only parts are exact; tilted parts use their corner box).
	local function footprint(p)
		if math.abs(p.CFrame.UpVector.Y) > 0.99 then
			local cf, h = p.CFrame, p.Size / 2
			local pts = {}
			for _, s in ipairs({ { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } }) do
				local w = cf * Vector3.new(s[1] * h.X, 0, s[2] * h.Z)
				table.insert(pts, { w.X, w.Z })
			end
			return pts
		end
		local lo, hi = wbounds(p)
		return { { lo.X, lo.Z }, { hi.X, lo.Z }, { hi.X, hi.Z }, { lo.X, hi.Z } }
	end
	local function pip(px, pz, P)
		local c = false
		for i = 1, #P do
			local a, b = P[i], P[i % #P + 1]
			if (a[2] > pz) ~= (b[2] > pz) and px < (b[1] - a[1]) * (pz - a[2]) / (b[2] - a[2]) + a[1] then c = not c end
		end
		return c
	end
	local function psd(px, pz, a, b)
		local abx, abz = b[1] - a[1], b[2] - a[2]
		local l2 = abx * abx + abz * abz
		local t = l2 == 0 and 0 or math.max(0, math.min(1, ((px - a[1]) * abx + (pz - a[2]) * abz) / l2))
		local qx, qz = a[1] + abx * t, a[2] + abz * t
		return math.sqrt((px - qx) ^ 2 + (pz - qz) ^ 2)
	end
	local function orient(a, b, c) return (b[1] - a[1]) * (c[2] - a[2]) - (b[2] - a[2]) * (c[1] - a[1]) end
	local function polyDist(A, B)
		for _, v in ipairs(A) do if pip(v[1], v[2], B) then return 0 end end
		for _, v in ipairs(B) do if pip(v[1], v[2], A) then return 0 end end
		local d = math.huge
		for i = 1, #A do
			local a1, a2 = A[i], A[i % #A + 1]
			for j = 1, #B do
				local b1, b2 = B[j], B[j % #B + 1]
				if orient(a1, a2, b1) * orient(a1, a2, b2) < 0 and orient(b1, b2, a1) * orient(b1, b2, a2) < 0 then return 0 end
				d = math.min(d, psd(a1[1], a1[2], b1, b2), psd(a2[1], a2[2], b1, b2), psd(b1[1], b1[2], a1, a2), psd(b2[1], b2[2], a1, a2))
			end
		end
		return d
	end
	local PAD_POLY = { { PAD.x0, PAD.z0 }, { PAD.x1, PAD.z0 }, { PAD.x1, PAD.z1 }, { PAD.x0, PAD.z1 } }
	local function pointPoly(v) return { { v.X - 0.05, v.Z - 0.05 }, { v.X + 0.05, v.Z - 0.05 }, { v.X + 0.05, v.Z + 0.05 }, { v.X - 0.05, v.Z + 0.05 } } end
	local function names(list, n)
		local t = {}
		for i = 1, math.min(#list, n or 4) do table.insert(t, list[i].Name) end
		return #list .. " parts: " .. table.concat(t, ",")
	end

	local wing = site:FindFirstChild("Wing")
	local atrium = wing and wing:FindFirstChild("Atrium")
	local canopy = wing and wing:FindFirstChild("Canopy")
	local function inCanopy(p) return canopy ~= nil and p:IsDescendantOf(canopy) end
	local function inAtrium(p) return atrium ~= nil and p:IsDescendantOf(atrium) end
	local function longWingParts()
		return partsIn(wing, function(p) return not inCanopy(p) and not inAtrium(p) and not isRig(p) end)
	end

	------------------------------------------------------------------ general
	if want("general") then
		local pv = site:GetPivot()
		check("pivot is at (-270, 0, -305), facing East (+X)",
			(pv.Position - ORIGIN).Magnitude < 0.5 and pv.LookVector:Dot(Vector3.new(1, 0, 0)) > 0.999,
			string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
		local wp = site.WorldPivot
		check("WorldPivot is at (-270, 0, -305) with LookVector +X",
			(wp.Position - ORIGIN).Magnitude < 0.5 and wp.LookVector:Dot(Vector3.new(1, 0, 0)) > 0.999,
			string.format("(%.2f, %.2f, %.2f) look %s", wp.X, wp.Y, wp.Z, tostring(wp.LookVector)))

		local own = ownParts()
		local n = #own
		check("own part count is 800..2500", n >= 800 and n <= 2500, tostring(n))

		local unanchored = 0
		for _, p in ipairs(own) do if not p.Anchored then unanchored += 1 end end
		-- Real bounds of every part of the model (kept placeholders included, as roads_check's info line sees them).
		local all = {}
		for _, d in ipairs(site:GetDescendants()) do if d:IsA("BasePart") then table.insert(all, d) end end
		local alo, ahi = union(all)
		check("real model bounds are inside x -323..-149, z -447..-187",
			#all > 0 and alo.X >= B_MIN.X - 0.05 and ahi.X <= B_MAX.X + 0.05 and alo.Z >= B_MIN.Z - 0.05 and ahi.Z <= B_MAX.Z + 0.05,
			string.format("x %.1f..%.1f, z %.1f..%.1f", alo.X, ahi.X, alo.Z, ahi.Z))
		local sp = {}
		for _, cn in ipairs({ "Wing", "Blocks", "Steps", "Forecourt", "Landscape" }) do
			for _, p in ipairs(partsIn(site:FindFirstChild(cn))) do table.insert(sp, p) end
		end
		local slo, shi = union(sp)
		check("structure containers stay inside x -323..-149, z -447..-187",
			#sp > 0 and slo.X >= B_MIN.X - 0.05 and shi.X <= B_MAX.X + 0.05 and slo.Z >= B_MIN.Z - 0.05 and shi.Z <= B_MAX.Z + 0.05,
			string.format("x %.1f..%.1f, z %.1f..%.1f", slo.X, shi.X, slo.Z, shi.Z))
		check("structure spans at least 150 studs in x and 220 in z (a tiny model cannot pass)",
			#sp > 0 and (shi.X - slo.X) >= 150 and (shi.Z - slo.Z) >= 220,
			string.format("%.1f x %.1f", shi.X - slo.X, shi.Z - slo.Z))
		local olo = union(own)
		check("nothing builds below the ground", n > 0 and olo.Y >= -0.5, string.format("min y %.2f", olo.Y))
		check("every part is anchored", n > 0 and unanchored == 0, unanchored .. " unanchored")

		for _, name in ipairs({ "Wing", "Blocks", "Steps", "Forecourt", "Landscape" }) do
			local c = site:FindFirstChild(name)
			local cnt = c and #partsIn(c) or 0
			check("container " .. name .. " holds parts", c ~= nil and cnt > 0, c and (cnt .. " parts") or "missing")
		end
		check("Site10_CityHall has no direct child named Block", site:FindFirstChild("Block") == nil)
		-- The placeholders (Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign, Jeepney) belong to builders/placeholders, never to this builder.
		local stray = {}
		for _, cn in ipairs({ "Wing", "Blocks", "Steps", "Forecourt", "Landscape" }) do
			local c = site:FindFirstChild(cn)
			for _, d in ipairs(c and c:GetDescendants() or {}) do
				if KEPT[d.Name] then table.insert(stray, d:GetFullName()) end
			end
		end
		check("the builder never creates Guide, InfoPanel, JeepStop, JeepSignPole, JeepSign or Jeepney", #stray == 0, table.concat(stray, "; "))

		local images = 0
		for _, d in ipairs(site:GetDescendants()) do
			if not isKept(d) and (d:IsA("Decal") or d:IsA("Texture") or d:IsA("ImageLabel") or d:IsA("ImageButton")) then images += 1 end
		end
		check("zero image instances (signs are text only: no seal, no logo)", images == 0, tostring(images))

		local badText = {}
		for _, g in ipairs(site:GetDescendants()) do
			if g:IsA("TextLabel") and not isKept(g) and g.TextScaled and #g.Text > 14 and not g.Parent:IsA("Frame") then
				table.insert(badText, g.Text:sub(1, 20))
			end
		end
		check("no long TextScaled line sits directly on a board", #badText == 0, table.concat(badText, "; "))

		local logoWords = {}
		for _, d in ipairs(site:GetDescendants()) do
			local t = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
			local u = t:upper()
			if not isKept(d) and (u:find("BAGONG") or u:find("SEAL") or u:find("KOPI") or u:find("ABOITIZ") or u:find("LIPA")) then table.insert(logoWords, t) end
		end
		check("no seal or brand text (no BAGONG, LIPA, SEAL, KOPI, ABOITIZ on any label)", #logoWords == 0, table.concat(logoWords, "; "))

		-- Pins in WORLD space (replace the old reserved zones, which were expressed in the old local frame).
		-- Rule: nothing solid below the canopy within 2 studs (2D) of the spawn pad, the Guide or the InfoPanel; nothing solid below y 20 within
		-- 4 studs of JeepStop or Jeepney. Solid = top above 0.6 (flat paving is allowed). Canopy parts whose lowest point is at least 30 up are exempt.
		local hitPad, hitGuide, hitPanel, hitJeep, hitJeepney = {}, {}, {}, {}, {}
		for _, p in ipairs(own) do
			local lo, hi = wbounds(p)
			if hi.Y > 0.6 then
				local exempt = inCanopy(p) and lo.Y >= 30
				local fp = footprint(p)
				if not exempt then
					if polyDist(fp, PAD_POLY) < 2 then table.insert(hitPad, p) end
					if polyDist(fp, pointPoly(GUIDE)) < 2 then table.insert(hitGuide, p) end
					if polyDist(fp, pointPoly(PANEL)) < 2 then table.insert(hitPanel, p) end
				end
				if lo.Y < 20 then
					if polyDist(fp, pointPoly(JEEPSTOP)) < 4 then table.insert(hitJeep, p) end
					if polyDist(fp, pointPoly(JEEPNEY)) < 4 then table.insert(hitJeepney, p) end
				end
			end
		end
		check("pin: no solid part under the canopy within 2 studs of the spawn pad (x -214..-202, z -266..-254)", #hitPad == 0, names(hitPad))
		check("pin: no solid part within 2 studs of the Guide (-223, -260)", #hitGuide == 0, names(hitGuide))
		check("pin: no solid part within 2 studs of the InfoPanel (-217, -282)", #hitPanel == 0, names(hitPanel))
		check("pin: nothing solid below y 20 within 4 studs of JeepStop (-155, -230)", #hitJeep == 0, names(hitJeep))
		check("pin: nothing solid below y 20 within 4 studs of Jeepney (-155, -216)", #hitJeepney == 0, names(hitJeepney))
	end

	------------------------------------------------------------------ blocks (staggered white-brick boxes)
	if want("blocks") then
		local oldNames = {}
		for _, d in ipairs(site:GetDescendants()) do
			if d.Name == "ElevatedBlock" or d.Name == "BlockPilotis" then table.insert(oldNames, d.Name) end
		end
		check("negative control: no ElevatedBlock or BlockPilotis from the old design remain", #oldNames == 0, #oldNames .. " found")

		local boxes = {}
		for _, p in ipairs(parts("WhiteBrickBox")) do
			if p.ClassName == "Part" then table.insert(boxes, p) end
		end
		local cream = 0
		for _, b in ipairs(boxes) do
			local r, g, bl = rgb(b)
			local mx, mn = math.max(r, g, bl), math.min(r, g, bl)
			if b.Material == Enum.Material.Brick and mn >= 200 and mx <= 250 and (mx - mn) <= 25 then cream += 1 end
		end
		check("at least 14 WhiteBrickBox, class Part, Brick, cream-white (R,G,B 200..250, nearly equal)", #boxes >= 14 and cream == #boxes,
			#boxes .. " boxes, " .. cream .. " cream brick")

		local fronts, heights, nWing = {}, {}, 0
		for _, b in ipairs(boxes) do
			local lz = b.Position.Z - ORIGIN.Z
			if lz <= -3 and lz >= -120 then -- on the long wing (the atrium boxes sit at lz 80 and up)
				nWing += 1
				local _, hi = wbounds(b)
				fronts[round(hi.X - ORIGIN.X, 1)] = true
				heights[round(b.Size.Y, 1)] = true
			end
		end
		local nf, nh = 0, 0
		for _ in pairs(fronts) do nf += 1 end
		for _ in pairs(heights) do nh += 1 end
		check("boxes on the long wing are staggered: at least 3 distinct front-face x offsets", nf >= 3, nf .. " offsets over " .. nWing .. " boxes")
		check("boxes on the long wing have at least 2 distinct heights", nh >= 2, nh .. " heights over " .. nWing .. " boxes")

		local bands = 0
		for _, g in ipairs(parts("GlassBand")) do
			local r, gg, b = rgb(g)
			local darkOk = g.Material == Enum.Material.Glass or (math.max(r, gg, b) < 90 and g.Material ~= Enum.Material.Neon)
			if darkOk and math.max(g.Size.X, g.Size.Z) >= 15 - 0.05 then bands += 1 end
		end
		check("at least 8 GlassBand parts (Glass or dark, none Neon), each spanning at least 15 studs", bands >= 8, bands .. " qualifying of " .. #parts("GlassBand"))

		local core = 0
		for _, s in ipairs(parts("BalconySlab")) do
			local lz = s.Position.Z - ORIGIN.Z
			if lz >= -66 and lz <= -44 then core += 1 end -- the central core, lz -64..-46
		end
		check("at least 3 BalconySlab parts in the central core (lz -64..-46)", core >= 3, core .. " of " .. #parts("BalconySlab"))
	end

	------------------------------------------------------------------ wing, atrium, canopy
	if want("wing") then
		check("Wing contains a model named Atrium", atrium ~= nil and atrium:IsA("Model"), atrium and atrium.ClassName or "missing")
		check("Wing contains a model named Canopy", canopy ~= nil and canopy:IsA("Model"), canopy and canopy.ClassName or "missing")

		-- Atrium is angled against the long wing axes (which are axis aligned): fold the yaw to 0..45 and count parts at 25..45.
		local angled, tested = 0, 0
		for _, p in ipairs(partsIn(atrium)) do
			local r = p.CFrame.RightVector
			if math.abs(r.Y) < 0.1 then -- skip vertical cylinders
				tested += 1
				local yaw = math.abs(math.deg(math.atan2(r.Z, r.X)))
				local m = yaw % 90
				local fold = math.min(m, 90 - m)
				if fold >= 25 and fold <= 45 then angled += 1 end
			end
		end
		check("Atrium is angled: at least 4 of its parts have a yaw of 25..45 degrees against the wing axes", angled >= 4, angled .. " angled of " .. tested)

		-- Canopy: faceted roof (distinct planes tilted 3..25 degrees, in at least 3 directions).
		local planes, dirs = {}, {}
		local nPlanes, nDirs = 0, 0
		for _, p in ipairs(partsIn(canopy)) do
			if string.find(p.Name, "Facet", 1, true) then
				local n
				if p:IsA("WedgePart") then
					n = p.CFrame:VectorToWorldSpace(Vector3.new(0, p.Size.Z, -p.Size.Y).Unit)
				elseif p.ClassName == "Part" then
					n = p.CFrame.UpVector
				end
				if n then
					if n.Y < 0 then n = -n end
					local tilt = math.deg(math.acos(math.clamp(n.Y, -1, 1)))
					if tilt >= 3 and tilt <= 25 then
						local dir = math.deg(math.atan2(n.Z, n.X))
						local key = string.format("%d|%d|%d", round(tilt, 1), round(dir, 5), round(n:Dot(p.Position), 1))
						if not planes[key] then planes[key] = true nPlanes += 1 end
						local dk = round(dir, 20)
						if not dirs[dk] then dirs[dk] = true nDirs += 1 end
					end
				end
			end
		end
		check("Canopy has at least 5 distinct roof facets (planes tilted 3..25 degrees)", nPlanes >= 5, nPlanes .. " planes")
		check("Canopy facets lean in at least 3 distinct directions", nDirs >= 3, nDirs .. " directions")

		local colParts, canopyRoof = {}, {}
		for _, p in ipairs(partsIn(canopy)) do
			if matches(p.Name, "Column") then table.insert(colParts, p) else table.insert(canopyRoof, p) end
		end
		local clo = #canopyRoof > 0 and union(canopyRoof) or Vector3.new(0, -1, 0)
		check("canopy lowest roof point is at least 30 studs above the ground", #canopyRoof > 0 and clo.Y >= 30, string.format("lowest y %.2f", clo.Y))
		if #canopyRoof > 0 and #colParts > 0 then
			local rlo, rhi = union(canopyRoof)
			local klo, khi = union(colParts)
			local over = math.max(klo.X - rlo.X, rhi.X - khi.X, klo.Z - rlo.Z, rhi.Z - khi.Z)
			check("canopy cantilevers at least 10 studs past the Columns on at least one side", over >= 10, string.format("%.1f", over))
		else
			check("canopy cantilevers at least 10 studs past the Columns on at least one side", false, "no canopy roof parts or no Columns")
		end
		local rb = 0
		for _, p in ipairs(partsIn(canopy)) do if string.find(p.Name, "RoofBox", 1, true) then rb += 1 end end
		check("Canopy carries at least 3 RoofBox parts (3 roof boxes)", rb >= 3, tostring(rb))

		-- Columns: at least 6 round, slim, tall.
		local cols = 0
		for _, c in ipairs(parts("Column")) do
			local lo, hi = wbounds(c)
			local round_ = c.Shape == Enum.PartType.Cylinder or string.find(c.Name, "Column", 1, true)
			if round_ and (hi.Y - lo.Y) >= 30 and (hi.X - lo.X) <= 3.05 and (hi.Z - lo.Z) <= 3.05 then cols += 1 end
		end
		check("at least 6 round Columns, each at least 30 tall and at most 3 across", cols >= 6, cols .. " of " .. #parts("Column"))

		-- Long wing: 4 storeys, roof, parapet, roof boxes.
		local lw = longWingParts()
		local ys = {}
		for _, p in ipairs(lw) do
			if matchesAny(p.Name, FLOOR_NAMES) then table.insert(ys, top(p)) end
		end
		table.sort(ys)
		local rows, last = {}, nil
		for _, y in ipairs(ys) do
			if last == nil or y - last >= 6 - 0.05 then table.insert(rows, y) last = y end
		end
		check("long wing has 4 storey lines (floor slab tops or glass-band rows, at least 6 apart) from y 10 to y 40 or more",
			#rows >= 4 and rows[1] >= 10 and rows[#rows] >= 40, #rows .. " rows: " .. table.concat(rows, ",", 1, math.min(#rows, 6)))
		local roofTop = -math.huge
		for _, p in ipairs(lw) do roofTop = math.max(roofTop, top(p)) end
		check("long wing roof top is between 38 and 50", #lw > 0 and roofTop >= 38 and roofTop <= 50, string.format("%.2f", roofTop))
		local parapets = 0
		for _, p in ipairs(lw) do if string.find(p.Name, "Parapet", 1, true) then parapets += 1 end end
		check("long wing has a parapet", parapets >= 1, tostring(parapets))
		local rbw = 0
		for _, p in ipairs(lw) do if matches(p.Name, "RoofBox") then rbw += 1 end end
		check("long wing carries at least 3 RoofBox", rbw >= 3, tostring(rbw))

		local doors = parts("Door")
		local doorsOk = #doors >= 2
		for _, d in ipairs(doors) do if d.Size.Y < 8 - 0.05 then doorsOk = false end end
		check("at least 2 entrance doors, each 8 or more tall", doorsOk, tostring(#doors))
		local rails, railOk = 0, true
		for _, p in ipairs(ownParts()) do
			if string.find(p.Name, "Rail", 1, true) and (inside(p, wing) or inside(p, site:FindFirstChild("Blocks"))) then
				rails += 1
				if p.Size.Y < 3 - 0.05 then railOk = false end
			end
		end
		check("balconies carry railings (at least 6 parts named *Rail*, each 3 tall)", rails >= 6 and railOk, rails .. " rails, all 3 tall: " .. tostring(railOk))

		-- Ground clearance: a 4 wide, 8 tall box standing on the base of every Pilotis overlaps no non-pilotis solid. Ground-level pilotis
		-- are tested from the ground; pilotis that stand on the podium or plinth are tested from their own base.
		local pil = parts("Pilotis")
		check("at least 20 Pilotis exist", #pil >= 20, tostring(#pil))
		local solids = {}
		for _, p in ipairs(ownParts()) do
			if not matches(p.Name, "Pilotis") and top(p) > 0.6 then table.insert(solids, p) end
		end
		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = solids
		local blocked = {}
		for _, p in ipairs(pil) do
			local base = bottom(p)
			local hits = workspace:GetPartBoundsInBox(CFrame.new(p.Position.X, base + 0.05 + 4, p.Position.Z), Vector3.new(4, 8, 4), op)
			if #hits > 0 then table.insert(blocked, p.Name .. "<" .. hits[1].Name) end
		end
		check("a 4 x 8 stud box on the base of every Pilotis overlaps no non-pilotis part", #pil > 0 and #blocked == 0,
			#blocked .. " blocked: " .. table.concat(blocked, ", ", 1, math.min(#blocked, 4)))

		-- Clearance under the raised brick boxes: from the box underside down to the highest support below its centre (other brick boxes
		-- stack on each other and pilotis hold them up, so both are ignored) at least 10 studs.
		local sup = {}
		for _, p in ipairs(solids) do
			if not matches(p.Name, "WhiteBrickBox") then table.insert(sup, p) end
		end
		local op2 = OverlapParams.new()
		op2.FilterType = Enum.RaycastFilterType.Include
		op2.FilterDescendantsInstances = sup
		local worst, worstName, raised = math.huge, "none", 0
		for _, b in ipairs(parts("WhiteBrickBox")) do
			local lo = wbounds(b)
			if lo.Y > 6 then
				raised += 1
				local hits = workspace:GetPartBoundsInBox(CFrame.new(b.Position.X, (lo.Y - 0.01) / 2, b.Position.Z), Vector3.new(2, lo.Y - 0.01, 2), op2)
				local support = 0
				for _, h in ipairs(hits) do
					if top(h) <= lo.Y + 0.05 then support = math.max(support, top(h)) end
				end
				if lo.Y - support < worst then worst, worstName = lo.Y - support, b.Name end
			end
		end
		check("clearance under the raised brick boxes is at least 10 studs", raised > 0 and worst >= 10 - 0.05,
			raised .. " raised boxes, tightest " .. worstName .. string.format(" %.2f", worst == math.huge and 0 or worst))
	end

	------------------------------------------------------------------ steps and forecourt
	if want("forecourt") then
		local steps = site:FindFirstChild("Steps")
		local treads, risers = {}, {}
		for _, p in ipairs(partsIn(steps)) do
			if matches(p.Name, "Tread") then table.insert(treads, p) elseif matches(p.Name, "Riser") then table.insert(risers, p) end
		end
		check("central stair has at least 6 treads", #treads >= 6, tostring(#treads))
		local bad = 0
		if #risers > 0 then
			for _, r in ipairs(risers) do if r.Size.Y > 1.2 + 0.001 then bad += 1 end end
		else -- solid treads: the riser is the rise between neighbouring tread tops (and the first tread from the ground)
			local tops = {}
			for _, t in ipairs(treads) do table.insert(tops, top(t)) end
			table.sort(tops)
			local prev = 0
			for _, y in ipairs(tops) do
				if y - prev > 1.2 + 0.001 then bad += 1 end
				prev = y
			end
		end
		for _, t in ipairs(treads) do if t.Size.X < 2 - 0.001 then bad += 1 end end
		check("every riser is at most 1.2 and every tread at least 2", #treads > 0 and bad == 0, bad .. " off")
		local zlo, zhi = math.huge, -math.huge
		for _, t in ipairs(treads) do
			local lo, hi = wbounds(t)
			zlo, zhi = math.min(zlo, lo.Z), math.max(zhi, hi.Z)
		end
		check("the stair spans at least 18 studs across z", #treads > 0 and (zhi - zlo) >= 18 - 0.05, string.format("%.1f", zhi - zlo))
		local strips = 0
		for _, s in ipairs(partsIn(steps)) do
			if matches(s.Name, "TerraceStrip") and s.Material == Enum.Material.Grass and math.max(s.Size.X, s.Size.Z) >= 20 then strips += 1 end
		end
		check("at least 4 grass TerraceStrip, each at least 20 studs long", strips >= 4, strips .. " qualifying")
		local walls = 0
		for _, s in ipairs(partsIn(steps)) do if matches(s.Name, "TerraceWall") then walls += 1 end end
		check("terrace strips have low walls (at least 4 TerraceWall)", walls >= 4, tostring(walls))

		local ring = parts("LoopRing")
		local island = parts("LoopIsland")
		local asph = 0
		for _, r in ipairs(ring) do if r.Material == Enum.Material.Asphalt then asph += 1 end end
		check("vehicle loop: at least 8 LoopRing segments, all Asphalt, and a LoopIsland", #ring >= 8 and asph == #ring and #island >= 1,
			#ring .. " ring segments, " .. asph .. " asphalt, " .. #island .. " island parts")
		local ilo, ihi = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
		if #island > 0 then ilo, ihi = union(island) end
		local icx, icz = (ilo.X + ihi.X) / 2, (ilo.Z + ihi.Z) / 2
		local outer = 0
		for _, r in ipairs(ring) do
			local cf, h = r.CFrame, r.Size / 2
			for _, sx in ipairs({ -1, 1 }) do
				for _, sz in ipairs({ -1, 1 }) do
					local w = cf * Vector3.new(sx * h.X, 0, sz * h.Z)
					outer = math.max(outer, math.sqrt((w.X - icx) ^ 2 + (w.Z - icz) ^ 2))
				end
			end
		end
		check("the loop ring has an outer radius of at least 15 around the island", #ring > 0 and #island > 0 and outer >= 15, string.format("%.1f", outer))

		local pole = {}
		for _, p in ipairs(ownParts()) do if p.Name == "Flagpole" then table.insert(pole, p) end end
		check("one Flagpole at least 30 tall", #pole == 1 and height(pole[1]) >= 30 - 0.05, #pole == 1 and string.format("%.1f", height(pole[1])) or tostring(#pole))
		if #pole == 1 then
			local d = math.sqrt((pole[1].Position.X - icx) ^ 2 + (pole[1].Position.Z - icz) ^ 2)
			check("the Flagpole stands on the LoopIsland (within 2.5 studs of its centre)", #island > 0 and d <= 2.5, string.format("%.1f", d))
			local lx = pole[1].Position.X - ORIGIN.X
			check("flagpole is on the forecourt (lx 25..100)", lx >= 25 and lx <= 100, string.format("lx %.1f", lx))
		end
		check("the flag is at most 3 parts", #parts("Flag") <= 3, tostring(#parts("Flag")))
		local paving = 0
		for _, p in ipairs(partsIn(site:FindFirstChild("Forecourt"))) do if string.match(p.Name, "Paving$") then paving += 1 end end
		check("forecourt paving exists", paving >= 1, tostring(paving))
		check("parking bay lines (at least 12 BayLine)", #parts("BayLine") >= 12, tostring(#parts("BayLine")))
		local seal = {}
		for _, d in ipairs(site:GetDescendants()) do
			if not isKept(d) and (d:IsA("TextLabel") or d:IsA("TextButton")) and (d.Text:upper():find("BAGONG") or d.Text:upper():find("LIPA")) then
				table.insert(seal, d.Text)
			end
		end
		check("no seal or logo text on the forecourt (no BAGONG or LIPA on any TextLabel or SurfaceGui)", #seal == 0, table.concat(seal, "; "))
	end

	------------------------------------------------------------------ landscape
	if want("landscape") then
		check("at least 12 trees", #units("Tree") >= 12, tostring(#units("Tree")))
		local trunks = 0
		for _, p in ipairs(ownParts()) do if string.find(p.Name, "Trunk", 1, true) then trunks += 1 end end
		check("trees have trunks (at least 12 Trunk parts)", trunks >= 12, tostring(trunks))
		check("at least 3 pocket gardens", (function()
			local g = site:FindFirstChild("Landscape") and site.Landscape:FindFirstChild("PocketGardens")
			return g ~= nil and #g:GetChildren() >= 3
		end)(), "Landscape.PocketGardens with 3+ children")
		check("at least 2 palms", #units("Palm") >= 2, tostring(#units("Palm")))
		local cars = units("ParkedCar")
		check("at least 12 parked cars", #cars >= 12, tostring(#cars))
		local wheels = 0
		for _, p in ipairs(ownParts()) do
			if string.find(p.Name, "Wheel", 1, true) and not string.find(p.Name, "WheelStop", 1, true) then wheels += 1 end
		end
		check("cars have wheels (4 per car)", #cars > 0 and wheels >= 4 * #cars, wheels .. " wheels for " .. #cars .. " cars")
		local pole
		for _, p in ipairs(ownParts()) do if p.Name == "Flagpole" then pole = p end end
		if pole then
			local near = 0
			for _, c in ipairs(cars) do
				local cp = unitPos(c)
				if Vector3.new(cp.X - pole.Position.X, 0, cp.Z - pole.Position.Z).Magnitude < 8 then near += 1 end
			end
			check("no car parked on the flag island", near == 0, tostring(near))
		end
	end

	return HttpService:JSONEncode(results)
end

-- Like the other stored checks this returns the JSON string when required. A builder agent runs one group with
-- shared.site10_only = "blocks" (wing, forecourt, landscape, general) set first; run_all leaves it nil and runs everything.
return run({ only = shared.site10_only })
