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
	local wb07 = site:FindFirstChild("WB07", true) -- the seal slab (owner decision 2026-10-28: the city seal and BAGONG LIPA wordmark go here)
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

		-- REPLACED 2026-10-28 (owner decision: the seal slab WB07 carries the city seal and the BAGONG LIPA wordmark, built from parts and text).
		-- Old text: check("no seal or brand text (no BAGONG, LIPA, SEAL, KOPI, ABOITIZ on any label)", #logoWords == 0, ...)
		-- SEAL, KOPI and ABOITIZ stay forbidden on every label; BAGONG is allowed only on the TextLabel LogoBagong, LIPA only on LogoLipa, both inside WB07.
		local logoWords = {}
		local function logoLabelOk(d, labelName)
			return d:IsA("TextLabel") and d.Name == labelName and wb07 ~= nil and d:IsDescendantOf(wb07)
		end
		for _, d in ipairs(site:GetDescendants()) do
			local t = (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text or ""
			local u = t:upper()
			if not isKept(d) then
				if u:find("SEAL") or u:find("KOPI") or u:find("ABOITIZ") then
					table.insert(logoWords, t)
				elseif u:find("BAGONG") and not logoLabelOk(d, "LogoBagong") then
					table.insert(logoWords, t .. " (" .. d:GetFullName() .. ")")
				elseif u:find("LIPA") and not logoLabelOk(d, "LogoLipa") then
					table.insert(logoWords, t .. " (" .. d:GetFullName() .. ")")
				end
			end
		end
		check("no stray seal or brand text: SEAL, KOPI, ABOITIZ nowhere; BAGONG only on LogoBagong and LIPA only on LogoLipa, both inside WB07",
			#logoWords == 0, table.concat(logoWords, "; "))

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

		-- Facade guard rails (added after the first build read as small deep pods; the drawing and the photo show a few big FLAT slabs).
		-- Main slab = the part named exactly WhiteBrickBox in a long-wing box model WB01..WB11 (WhiteBrickBoxC/F/W detail parts are ignored).
		-- On the long wing the facade normal is +X, so Size.X is the slab depth and Size.Z its width.
		local slabs = {}
		for _, p in ipairs(parts("WhiteBrickBox")) do
			if p.Name == "WhiteBrickBox" and p.ClassName == "Part" and p.Parent and string.match(p.Parent.Name, "^WB%d+$") then
				table.insert(slabs, p)
			end
		end
		-- Drawing: slabs are thin plates, about 3 to 5 studs deep and 12 to 30 wide; pods 8 to 15 deep read wrong.
		local fat = {}
		for _, s in ipairs(slabs) do
			local d, w = s.Size.X, s.Size.Z
			if d > 6.5 + 0.001 or d > 0.6 * w + 0.001 or w < 8 - 0.05 then
				table.insert(fat, string.format("%s %.1fx%.1f", s.Parent.Name, d, w))
			end
		end
		check("long wing main slabs are flat: depth at most 6.5 and at most 0.6 of width, width at least 8", #slabs >= 4 and #fat == 0,
			#fat .. " of " .. #slabs .. " off (depth x width): " .. table.concat(fat, ", "))

		-- Drawing and photo: the big slabs rise to the roof line. One-sided on purpose (slabs may stand above the glass behind them).
		local roofTopY = -math.huge
		for _, p in ipairs(longWingParts()) do
			if string.match(p.Name, "^RoofSlab%d*$") then roofTopY = math.max(roofTopY, top(p)) end
		end
		local atRoof = 0
		for _, s in ipairs(slabs) do
			if top(s) >= roofTopY - 0.5 then atRoof += 1 end
		end
		check("at least 4 long-wing main slabs reach the roof line (top at least the highest RoofSlab top minus 0.5)",
			roofTopY > -math.huge and atRoof >= 4, string.format("%d of %d slabs, roof slab top %.2f", atRoof, #slabs, roofTopY))

		-- Drawing: glass is a mid blue-grey with a clear blue bias, not near-black (drawing panes sit at about 50,63,85 up to 97,106,121).
		local glassBad = {}
		local glassBands = parts("GlassBand")
		for _, g in ipairs(glassBands) do
			local r, gg, b = rgb(g)
			local mx = math.max(r, gg, b)
			if g.Material ~= Enum.Material.Glass or mx < 80 or mx > 160 or b + 0.5 < mx or b < r + 15 then
				table.insert(glassBad, string.format("%s (%d,%d,%d) %s", g.Name, round(r), round(gg), round(b), g.Material.Name))
			end
		end
		check("every GlassBand is Glass and mid blue-grey: max channel 80..160, blue largest, blue at least red + 15",
			#glassBands > 0 and #glassBad == 0,
			#glassBad .. " of " .. #glassBands .. " off: " .. table.concat(glassBad, "; ", 1, math.min(#glassBad, 3)))

		-- Guard rail (already true): the north-end (lowest lz) long-wing box is plain. No seal, logo or label of any kind on it.
		local endZ = math.huge
		for _, s in ipairs(slabs) do endZ = math.min(endZ, s.Position.Z) end
		local endBoxes, sealBad = 0, {}
		for _, s in ipairs(slabs) do
			if s.Position.Z <= endZ + 0.5 then
				endBoxes += 1
				for _, d in ipairs(s.Parent:GetDescendants()) do
					if d:IsA("Decal") or d:IsA("Texture") or d:IsA("SurfaceGui") or d:IsA("TextLabel") or d:IsA("ImageLabel") then
						table.insert(sealBad, s.Parent.Name .. "/" .. d.ClassName)
					end
				end
			end
		end
		check("the north-end long-wing box carries no Decal, Texture, SurfaceGui, TextLabel or ImageLabel",
			endBoxes >= 1 and #sealBad == 0, endBoxes .. " end boxes, " .. #sealBad .. " found: " .. table.concat(sealBad, ", ", 1, math.min(#sealBad, 4)))

		------------------------------------------------------------------ logo on the seal slab WB07 (owner decision 2026-10-28)
		-- The drawing and the photo show a round city seal with a BAGONG LIPA wordmark under it on the upper-right slab of the long wing. Built from
		-- parts and text only (no Decal, Texture or image: the site-wide "zero image instances" check still covers that). Local frame: WB07 faces +X.
		-- Front face: WB07's main WhiteBrickBox front is x -242.5, but the centre facet WhiteBrickBoxF reaches x -240.5 (bed lines to -240.35), so the
		-- logo must sit in FRONT of the facet: back within 0.6 of the facet front, front face at least 0.2 proud of it.
		do
			local function isWhite(r, g, b) local mx, mn = math.max(r, g, b), math.min(r, g, b) return mn >= 200 and (mx - mn) <= 45 end
			local function isBlue(r, g, b) return b >= 100 and b >= r + 40 and b >= g + 20 end
			local function isRed(r, g, b) return r >= 120 and r >= g + 60 and r >= b + 60 end
			local function isGreen(r, g, b) return g >= 90 and g >= r + 25 and g >= b + 25 end
			local function isGold(r, g, b) return r >= 170 and g >= 130 and b <= 110 and r - b >= 80 and g - b >= 60 end
			local function col3(c) return c.R * 255, c.G * 255, c.B * 255 end

			local slab07
			for _, s in ipairs(slabs) do
				if wb07 and s.Parent == wb07 then slab07 = s end
			end
			local logo = wb07 and wb07:FindFirstChild("SealLogo")
			-- Reason: the seal must be one Model named SealLogo inside the seal slab model WB07.
			check("SealLogo is a Model inside WB07 (next to WB07's main WhiteBrickBox slab)", logo ~= nil and logo:IsA("Model") and slab07 ~= nil,
				logo and logo.ClassName or "SealLogo missing in WB07")

			local lo7, hi7, Fx = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0), nil
			if slab07 then
				lo7, hi7 = wbounds(slab07)
				Fx = hi7.X
				for _, d in ipairs(wb07:GetChildren()) do
					if d:IsA("BasePart") and d.Name == "WhiteBrickBoxF" then
						local _, h = wbounds(d)
						Fx = math.max(Fx, h.X)
					end
				end
			end

			local discs, logoParts = {}, {}
			for _, d in ipairs(logo and logo:GetDescendants() or {}) do
				if d:IsA("BasePart") then
					table.insert(logoParts, d)
					if d.ClassName == "Part" and d.Shape == Enum.PartType.Cylinder and math.abs(d.Size.Y - d.Size.Z) <= 0.05 then table.insert(discs, d) end
				end
			end
			local outer
			for _, d in ipairs(discs) do
				if not outer or d.Size.Y > outer.Size.Y then outer = d end
			end
			local conc, diam, nDiam = {}, {}, 0
			if outer then
				for _, d in ipairs(discs) do
					if math.abs(d.Position.Y - outer.Position.Y) <= 0.1 and math.abs(d.Position.Z - outer.Position.Z) <= 0.1 then
						table.insert(conc, d)
						local k = round(d.Size.Y, 0.1)
						if not diam[k] then diam[k] = true nDiam += 1 end
					end
				end
			end
			-- Reason: a seal is concentric rings; five discs in three or more diameters is the least that can show ring, field and details.
			check("SealLogo has at least 5 concentric Cylinder discs (Size.Y = Size.Z, centres within 0.1 in Y and Z) in at least 3 diameters",
				#conc >= 5 and nDiam >= 3, #discs .. " cylinder discs, " .. #conc .. " concentric, " .. nDiam .. " diameters")
			-- Reason: the drawing's seal is about half the slab's height; 6..9 studs on a 15.4 high slab, and discs must stay thin plates.
			local thick = 0
			for _, d in ipairs(discs) do thick = math.max(thick, d.Size.X) end
			check("seal outer diameter is 6..9 studs and no disc is thicker than 0.6",
				outer ~= nil and outer.Size.Y >= 6 and outer.Size.Y <= 9 and thick <= 0.6 + 0.001,
				outer and string.format("outer %.2f, thickest %.2f", outer.Size.Y, thick) or "no discs")

			-- Reason: the drawing seal is a white or gold ring, a blue field, red and green details.
			local hasW, hasB, hasR, hasG, hasGold = false, false, false, false, false
			for _, d in ipairs(logoParts) do
				if d.Name ~= "LogoText" then
					local r, g, b = col3(d.Color)
					hasW = hasW or isWhite(r, g, b)
					hasB = hasB or isBlue(r, g, b)
					hasR = hasR or isRed(r, g, b)
					hasG = hasG or isGreen(r, g, b)
					hasGold = hasGold or isGold(r, g, b)
				end
			end
			check("seal colours: white or cream, blue, red, and green or gold are all present",
				hasW and hasB and hasR and (hasG or hasGold),
				string.format("white %s blue %s red %s green %s gold %s", tostring(hasW), tostring(hasB), tostring(hasR), tostring(hasG), tostring(hasGold)))

			-- Reason: the discs must be visible on the slab: facing +X, proud of the centre facet, whole disc inside the slab, inside the outer disc.
			local misplaced = {}
			for _, d in ipairs(discs) do
				local why
				local lo, hi = wbounds(d)
				if math.abs(d.CFrame.RightVector.X) < 0.99 then
					why = "axis not X"
				elseif Fx == nil then
					why = "no slab"
				elseif lo.X < Fx - 0.3 or lo.X > Fx + 0.6 then
					why = string.format("back x %.2f outside %.2f..%.2f", lo.X, Fx - 0.3, Fx + 0.6)
				elseif hi.X < Fx + 0.2 then
					why = string.format("front x %.2f buried (needs at least %.2f)", hi.X, Fx + 0.2)
				elseif lo.Y < lo7.Y or hi.Y > hi7.Y or lo.Z < lo7.Z or hi.Z > hi7.Z then
					why = "sticks out of the slab y/z extent"
				elseif outer and math.sqrt((d.Position.Y - outer.Position.Y) ^ 2 + (d.Position.Z - outer.Position.Z) ^ 2) + d.Size.Y / 2 > outer.Size.Y / 2 + 0.1 then
					why = "outside the outer disc"
				end
				if why then table.insert(misplaced, d.Name .. ": " .. why) end
			end
			check("every seal disc faces +X, sits on WB07's front face (back within 0.6 of the centre facet, 0.2 proud), and lies inside the slab and the outer disc",
				#discs >= 1 and #misplaced == 0, #misplaced .. " off of " .. #discs .. ": " .. table.concat(misplaced, "; ", 1, math.min(#misplaced, 3)))

			local logoTop = -math.huge
			for _, p in ipairs(logoParts) do logoTop = math.max(logoTop, top(p)) end
			check("the logo stays below the roof line: top at most the highest RoofSlab top minus 1",
				#logoParts > 0 and roofTopY > -math.huge and logoTop <= roofTopY - 1,
				string.format("logo top %.2f, roof slab top %.2f", logoTop, roofTopY))

			-- Wordmark: one thin plain part LogoText inside SealLogo, one SurfaceGui, two TextLabels.
			local lt = logo and logo:FindFirstChild("LogoText", true)
			local labels, bag, lip = {}, {}, {}
			for _, d in ipairs(logo and logo:GetDescendants() or {}) do
				if d:IsA("TextLabel") then
					table.insert(labels, d)
					if d.Name == "LogoBagong" then table.insert(bag, d) elseif d.Name == "LogoLipa" then table.insert(lip, d) end
				end
			end
			-- Reason: the wordmark carrier must be a thin plain block part; labels need a SurfaceGui that faces +X and belongs to it.
			local ltOk = lt ~= nil and lt.ClassName == "Part" and lt.Shape == Enum.PartType.Block and lt.Size.X <= 0.6 + 0.001 and lt:IsDescendantOf(logo)
			check("LogoText is a thin plain Part (Block, at most 0.6 deep) inside SealLogo", ltOk,
				lt and string.format("%s size %s", lt.ClassName, tostring(lt.Size)) or "LogoText missing")
			-- Reason: exactly the two words of the wordmark, nothing else written on the seal (no ring text, no SEAL label).
			local sitebag, sitelip = 0, 0
			for _, d in ipairs(site:GetDescendants()) do
				if d:IsA("TextLabel") and d.Name == "LogoBagong" then sitebag += 1 end
				if d:IsA("TextLabel") and d.Name == "LogoLipa" then sitelip += 1 end
			end
			check("exactly one TextLabel LogoBagong reading BAGONG and one LogoLipa reading LIPA, and no other TextLabel in SealLogo",
				#bag == 1 and #lip == 1 and #labels == 2 and bag[1].Text == "BAGONG" and lip[1].Text == "LIPA" and sitebag == 1 and sitelip == 1,
				string.format("%d LogoBagong, %d LogoLipa, %d labels in SealLogo, %d/%d on the site", #bag, #lip, #labels, sitebag, sitelip))
			local two = (#bag == 1 and #lip == 1) and { bag[1], lip[1] } or {}
			local guiBad = {}
			for _, d in ipairs(two) do
				local gui = d:FindFirstAncestorWhichIsA("SurfaceGui")
				if not (gui and lt and gui.Face == Enum.NormalId.Right and gui.Enabled and (gui.Adornee == lt or (gui.Adornee == nil and gui.Parent == lt))) then
					table.insert(guiBad, d.Name)
				end
			end
			check("both wordmark labels sit in an enabled SurfaceGui on LogoText with Face Right (+X)",
				#two == 2 and #guiBad == 0 and lt ~= nil and lt.CFrame.RightVector.X > 0.99,
				#two == 2 and (#guiBad .. " bad: " .. table.concat(guiBad, ",")) or "the two labels are missing")
			-- Reason: README rule 7 (fixed TextSize, never TextScaled), plain ASCII, no rich text, the drawing's red BAGONG and blue LIPA.
			local styleBad = {}
			for _, d in ipairs(two) do
				if d.TextScaled or d.RichText or type(d.TextSize) ~= "number" or d.TextSize < 20 or d.Text:find("[^\32-\126]") then
					table.insert(styleBad, string.format("%s scaled=%s rich=%s size=%s", d.Name, tostring(d.TextScaled), tostring(d.RichText), tostring(d.TextSize)))
				end
			end
			check("wordmark labels: TextScaled false, RichText false, fixed TextSize at least 20, ASCII only",
				#two == 2 and #styleBad == 0, #two == 2 and (#styleBad .. " bad: " .. table.concat(styleBad, "; ")) or "the two labels are missing")
			local rr, rg, rb = col3(bag[1] and bag[1].TextColor3 or Color3.new(0, 0, 0))
			local br, bg, bb = col3(lip[1] and lip[1].TextColor3 or Color3.new(0, 0, 0))
			check("BAGONG is red-dominant and LIPA is blue-dominant", #two == 2 and isRed(rr, rg, rb) and isBlue(br, bg, bb),
				string.format("BAGONG (%.0f,%.0f,%.0f) LIPA (%.0f,%.0f,%.0f)", rr, rg, rb, br, bg, bb))
			-- Reason: in the drawing the wordmark sits under the seal on the same slab face.
			local wmWhy = "LogoText or seal missing"
			if lt and outer and Fx ~= nil then
				local lo, hi = wbounds(lt)
				local sealBottom = outer.Position.Y - outer.Size.Y / 2
				wmWhy = nil
				if lt.Position.Y > sealBottom + 0.5 then
					wmWhy = string.format("centre y %.2f is above the seal bottom %.2f", lt.Position.Y, sealBottom)
				elseif lo.Y < lo7.Y + 0.3 or hi.Y > hi7.Y or lo.Z < lo7.Z or hi.Z > hi7.Z then
					wmWhy = "outside the slab extent"
				elseif lo.X < Fx - 0.3 or lo.X > Fx + 0.6 or hi.X < Fx + 0.2 then
					wmWhy = string.format("x %.2f..%.2f not on the front face (%.2f)", lo.X, hi.X, Fx)
				end
			end
			check("LogoText sits under the seal, inside WB07's extent and on its front face", wmWhy == nil, wmWhy)

			-- Reason: the logo must not collide with a roof box or a rail.
			local hit = {}
			for _, p in ipairs(ownParts()) do
				if (string.find(p.Name, "RoofBox", 1, true) or string.find(p.Name, "Rail", 1, true)) and not (logo and p:IsDescendantOf(logo)) then
					local plo, phi = wbounds(p)
					for _, l in ipairs(logoParts) do
						local llo, lhi = wbounds(l)
						if llo.X < phi.X and lhi.X > plo.X and llo.Y < phi.Y and lhi.Y > plo.Y and llo.Z < phi.Z and lhi.Z > plo.Z then
							table.insert(hit, l.Name .. "x" .. p.Name)
							break
						end
					end
				end
			end
			check("no SealLogo part intersects a RoofBox or a *Rail* part", #logoParts > 0 and #hit == 0,
				#logoParts == 0 and "no logo parts" or (#hit .. " hits: " .. table.concat(hit, ", ", 1, math.min(#hit, 3))))
		end

		------------------------------------------------------------------ atrium south corner strip (owner decision 2026-10-28)
		-- The atrium's south corner (edge 4, u 52..L, L = 58.97, y 14.4..42.8) was bare dark glass: a slab there made the centre column of AB1 sit over
		-- RailSW2 and the 10-stud clearance rule (wing group) fell to 5.20. Rule: the strip face is at least 35 percent covered by the main slabs
		-- (parts named WhiteBrickBox) standing in front of the glass, and no uncovered run along the strip is wider than 5 studs. Measured today: 0 percent, bare run 6.75 (the strip is 6.97 wide).
		-- A faithful value: upper tier AB1 reaching u 58.97 covers 47 percent with no bare run. The 10-stud clearance rule must keep passing.
		do
			local wall = atrium and atrium:FindFirstChild("AtriumWallSE")
			local function mainOf(label)
				local m = site:FindFirstChild(label, true)
				return m and m:FindFirstChild("WhiteBrickBox")
			end
			local ab1, ab2 = mainOf("AB1"), mainOf("AB2")
			local railSW2 = atrium and atrium:FindFirstChild("RailSW2")
			local railTxt = railSW2 and string.format("RailSW2 at (%.2f, %.2f, %.2f)", railSW2.Position.X, railSW2.Position.Y, railSW2.Position.Z) or "RailSW2 missing"
			local frac, bareRun, why = 0, math.huge, nil
			if wall and ab1 and ab2 then
				local t = wall.CFrame.RightVector
				if (ab1.Position - ab2.Position):Dot(t) < 0 then t = -t end
				local out = ab1.CFrame.RightVector
				if out:Dot(Vector3.new(1, 0, 0)) < 0 then out = -out end
				local L = wall.Size.X
				local U0, U1, Y0, Y1 = 52, L, 14.4, 42.8
				local rects = {}
				for _, p in ipairs(parts("WhiteBrickBox")) do
					if p.Name == "WhiteBrickBox" and p.ClassName == "Part" and (p.Position - wall.Position):Dot(out) >= 2.0 then
						local cf, h = p.CFrame, p.Size / 2
						local u0, u1, y0, y1 = math.huge, -math.huge, math.huge, -math.huge
						for _, sx in ipairs({ -1, 1 }) do
							for _, sy in ipairs({ -1, 1 }) do
								for _, sz in ipairs({ -1, 1 }) do
									local w = cf * Vector3.new(sx * h.X, sy * h.Y, sz * h.Z)
									local u = (w - wall.Position):Dot(t) + L / 2
									u0, u1, y0, y1 = math.min(u0, u), math.max(u1, u), math.min(y0, w.Y), math.max(y1, w.Y)
								end
							end
						end
						table.insert(rects, { u0, u1, y0, y1 })
					end
				end
				local du, dy = 0.25, 0.2
				local nu, ny = math.floor((U1 - U0) / du), math.floor((Y1 - Y0) / dy)
				local covered, run, longest = 0, 0, 0
				for i = 1, nu do
					local u = U0 + (i - 0.5) * du
					local colHit = false
					for j = 1, ny do
						local y = Y0 + (j - 0.5) * dy
						for _, r in ipairs(rects) do
							if u >= r[1] and u <= r[2] and y >= r[3] and y <= r[4] then covered += 1 colHit = true break end
						end
					end
					if colHit then run = 0 else run += du longest = math.max(longest, run) end
				end
				frac, bareRun = covered / (nu * ny), longest
			else
				why = "AtriumWallSE, AB1 or AB2 missing"
			end
			-- Reason: a bare dark panel 14 tall at the atrium corner is not in the drawing; slabs wrap the atrium faces. Keep RailSW2 clear (clearance rule).
			check("atrium south corner strip (edge 4, u 52..59, y 14.4..42.8) is at least 35 percent covered by WhiteBrickBox slabs in front of the glass",
				why == nil and frac >= 0.35,
				string.format("%.1f percent covered; %s; keep 'clearance under the raised brick boxes' at 10 or more", frac * 100, why or railTxt))
			check("no bare run wider than 5 studs along the atrium south corner strip (no slab at any height over that stretch)",
				why == nil and bareRun <= 5.0 + 0.001,
				string.format("widest bare run %.2f studs; %s", bareRun, why or railTxt))
		end

		------------------------------------------------------------------ atrium outer-end slab proportions (owner complaint 2026-10-30)
		-- Drawing (blueprint, atrium end, 2x crop at about 11.7 px per stud): the slabs are flat plates and two of them are TALLER than wide
		-- (left slab 225 x 290 px, centre slab 215 x 300 px: apparent height/width 1.3 and 1.4; faces are foreshortened, so the true ratio is 0.9 or more),
		-- one is low and wide (250 x 140 px, about 0.56), plus a small one. The model has AB1..AB5 all wide bands (height/width 0.38..0.56); only the
		-- narrow corner strip AB6 (6.6 wide) is tall. Strips narrower than 12 studs do not count: the drawing's tall slabs are 16 studs wide or more.
		do
			local tallN, lowN, tallTxt = 0, 0, {}
			for _, p in ipairs(parts("WhiteBrickBox")) do
				if p.Name == "WhiteBrickBox" and p.ClassName == "Part" and p.Parent and string.match(p.Parent.Name, "^AB%d+$") then
					local h, w = p.Size.Y, p.Size.Z -- height, width along the face (Size.X is the depth)
					if w >= 12 - 0.05 and h >= 0.9 * w - 0.001 and h <= 28.8 + 0.05 then tallN += 1 end
					if w >= 12 - 0.05 and h <= 0.7 * w + 0.001 then lowN += 1 end
					table.insert(tallTxt, string.format("%s %.1fh x %.1fw", p.Parent.Name, h, w))
				end
			end
			-- Reason: drawing-faithful atrium slabs include at least two tall plates (height at least 0.9 of width, width at least 12, height at most the 28.8 wall).
			check("at least 2 atrium slabs (AB main WhiteBrickBox, width at least 12) are tall: height at least 0.9 x width and at most 28.8",
				tallN >= 2, tallN .. " tall: " .. table.concat(tallTxt, ", "))
			-- Reason: the drawing also keeps one low wide slab in front (about 0.56), so the tall ones must not replace it.
			check("at least 1 atrium slab (AB main WhiteBrickBox, width at least 12) stays low and wide: height at most 0.7 x width",
				lowN >= 1, lowN .. " low: " .. table.concat(tallTxt, ", "))
		end
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

		-- Column layout (owner complaint 2026-10-30). Drawing (blueprint, 2x crop): 4 big columns in the front plane (gaps 100, 130, 50 px: uneven)
		-- and about 3 to 4 more standing further in (their bases sit about 230 px up the screen, roughly 15 to 20 studs behind): about 8 in all,
		-- not one straight evenly spaced row. The model has Column1..8 on one straight line, 6 x 6.7 studs apart (all at the same depth).
		-- Depth = distance along the outward normal of the canopy front edge (edge 2/3, direction (0.666, 0.745) in x,z; outward is (0.747, -0.666)).
		-- Every column keeps the existing rules: at least 30 tall (they must still reach the canopy soffit at y 45, so the builder keeps them tall),
		-- at most 3 across, and the 10-stud cantilever rule is unaffected as the front row keeps the extent.
		do
			local nrm = Vector3.new(0.747, 0, -0.666)
			local list, smax = {}, -math.huge
			for _, c in ipairs(parts("Column")) do
				local lo, hi = wbounds(c)
				if c.Shape == Enum.PartType.Cylinder and (hi.Y - lo.Y) >= 30 and (hi.X - lo.X) <= 3.05 and (hi.Z - lo.Z) <= 3.05 then
					local s = c.Position:Dot(nrm)
					table.insert(list, s)
					smax = math.max(smax, s)
				end
			end
			local front, back = 0, 0
			for _, s in ipairs(list) do
				if s >= smax - 3 then front += 1 elseif s <= smax - 6 then back += 1 end
			end
			-- Reason: the drawing shows 4 big front columns (the brief allows 4 to 6); a row of 8 or more on one line reads wrong.
			check("front column row (within 3 studs of the front depth) has 4 to 6 round Columns", front >= 4 and front <= 6,
				string.format("%d in the front row of %d columns (front depth %.1f)", front, #list, smax))
			-- Reason: the drawing has 3 to 4 further columns standing behind the front row (we ask for at least 2, 6 or more studs behind; the whole set stays at most 10).
			check("at least 2 round Columns stand 6 or more studs behind the front row, and there are at most 10 Columns",
				back >= 2 and #list <= 10, string.format("%d behind the front row, %d columns in all", back, #list))
		end

		-- Atrium glazing grid (owner complaint 2026-10-30). Drawing (4x crop of the south end): the dark glass is a grid of panes about 14 px (2.4 studs)
		-- wide and 2.2 high, three pane rows per band, with grey spandrel bands under each band; the model has only vertical mullions about 6 studs apart
		-- and no horizontal bars, so the glass reads as plain navy planes. Guard: mullion spacing at most 4.0 and at least 2 horizontal Transom bars per wall.
		do
			for _, sfx in ipairs({ "SE", "SW" }) do
				local wall = atrium and atrium:FindFirstChild("AtriumWall" .. sfx)
				local mull, trans = 0, 0
				for _, p in ipairs(partsIn(atrium)) do
					if string.match(p.Name, "^AtriumMullion" .. sfx .. "%d+$") then mull += 1 end
					if string.match(p.Name, "^AtriumTransom" .. sfx .. "%d+$") then trans += 1 end
				end
				local L = wall and wall.Size.X or 0
				check("atrium " .. sfx .. " glazing: mullions at most 4.0 studs apart (wall length / (count + 1))",
					wall ~= nil and L / (mull + 1) <= 4.0 + 0.001,
					string.format("%d AtriumMullion%s on %.1f studs: %.2f apart", mull, sfx, L, L / (mull + 1)))
				check("atrium " .. sfx .. " glazing: at least 2 horizontal AtriumTransom" .. sfx .. "N bars", wall ~= nil and trans >= 2, trans .. " transoms")
			end
		end

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
		-- REPLACED 2026-10-28 (owner decision: the logo text lives on WB07 in Blocks; the old loop scanned the whole site and would trip it).
		-- Old text: check("no seal or logo text on the forecourt (no BAGONG or LIPA on any TextLabel or SurfaceGui)", #seal == 0, ...), loop over site:GetDescendants().
		-- Same rule, scoped to the containers where it still holds: Forecourt, Steps and Landscape.
		local seal = {}
		for _, cn in ipairs({ "Forecourt", "Steps", "Landscape" }) do
			local c = site:FindFirstChild(cn)
			for _, d in ipairs(c and c:GetDescendants() or {}) do
				if not isKept(d) and (d:IsA("TextLabel") or d:IsA("TextButton")) and (d.Text:upper():find("BAGONG") or d.Text:upper():find("LIPA")) then
					table.insert(seal, d.Text)
				end
			end
		end
		check("no seal or logo text in Forecourt, Steps or Landscape (no BAGONG or LIPA on any TextLabel or TextButton)", #seal == 0, table.concat(seal, "; "))
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
