-- site02_check: the fidelity spec for Site 02 (Candido B. Lopez Memorial Public Market), REBUILT strictly from PublicMarketBP1.jpg (Slice 4, 2026-10-29). Written BEFORE the build.
-- Studio copy: ServerStorage.Checks.site02_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site02_check:Clone())      -- returns JSON {passed, failed, failures}
-- Groups (set shared.site02_only = "hall" | "sheds" | "yard" | "general" first to run one; run_all leaves it nil and runs all). Each group tests only its own parts.
-- Design source: scratch/site02/layout.md (numbers) and BP1. Replaced assertions: briefs/site02.md "Rebuild from BP1: replaced assertions".
--
-- ===================================== NAMING CONTRACT (builders MUST follow it) =====================================
-- World frame, no yaw tricks: world x east (+), z south (+), y up. The site pivot is (-402, 0, 160) facing E; every number below is WORLD.
-- Slot x -576..-228, z -5..325. Real bounds x -559.6..-229.0, z 33.3..276.3 (uniform plan scale 2.90 studs/m). The ground under the slot is Concrete.
-- Direct children of Site02_Market: Guide, InfoPanel (ONE BasePart), Structure (Folder), Yard (Model, holds YardSlab), MarketStalls, Baskets, Produce,
--   PriceSigns, VendorNPCs, LocalNPCs.  Inside Structure (Folders or Models): Hall/Shell, Hall/Windows, Stairs, Scaffold, Sheds/Gabled, Sheds/Markets,
--   Bagsakan, Forecourt. Grouping nodes (Structure, Structure/Hall, Structure/Sheds) hold NO direct parts. Every OTHER Model/Folder holds at most 400 parts in
--   its whole subtree (batch rule); Stairs may be one container (46 parts).
-- ANCHORS: ONE BasePart each in the whole site, no Model/Folder shares the name: HallBody, PavilionBody, NameBand, YardSlab (and the old SampleBoard).
--   HallBody  = cream wall block of the front arcade, x -299.7..-262.6 (east face -262.6 +-2.5, west face -304..-296), z 71.4..249.3 (+-3), top y 28.5..32.
--   PavilionBody = the central pavilion block, x -303.3..-262.6 (+-3), z 145.6..174.4 (+-2.5, centre z 160 +-2), top y 28.5..32.
--   NameBand  = white band on the east frontage, centre x -266..-249, 3.5+ tall (y between 14 and 31.5), 40+ long along z inside z 71..250. Its ONE SurfaceGui
--     faces east (the Face whose world normal is +X), holds ONE TextLabel "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET", blue text, fixed TextSize (TextScaled false).
--   YardSlab  = the forecourt apron, ONE thin part (Size.Y at most 0.31), x -250.4..-229, z 33.3..276.3.
-- NAME KINDS: the patterns below (Lua patterns, anchored) are matched against BASEPARTS unless marked [unit]; a Model that carries a part-only name is invisible
--   to the check (a Door built as a Model does not count). [unit] = a BasePart OR a Model, measured over all its parts: GroundBay, ArchWindow, ArchWindowTall,
--   ShedA..D, WetMarket1/2, DryGoods, TruckBay, Truck, StreetStall, SideStallS/N. A number without "+" is EXACT (19 Pilaster, 18 GroundBay, 14 ArchWindow + 4
--   ArchWindowTall, 4 PorticoColumn, 10 steps per stair, 8 tricycles, 5 StreetStall); "+" means at least.
-- GUARDS beyond the names: nothing in Structure or Yard has a point below y -0.5, and NO part anywhere in the site (rigs excluded) has a point below y -0.6 (a dome,
--   heap or ball may sink at most 0.6). No TextScaled label whose longest LINE has more than 14 characters anywhere in the site, except the shared Guide and InfoPanel
--   widgets (the InfoPanel label comes from builders/placeholders and is TextScaled); a Frame around the label does not exempt it (README rule 7: long labels use a
--   fixed TextSize; a two-line board "KAMATIS" / "P 80/kg" is fine). No brand words, zero images.
-- HALL (Structure/Hall/Shell, Structure/Hall/Windows):
--   Pilaster%d+            19 red (176,62,50) strips, 1.4 wide, full height (>= 28), centre x -267..-258, z from the south end to the north end.
--   GroundBay%d+ [unit]    18 open rectangular bays of the ground storey (7 south, 3 pavilion, 8 north), bottom <= 1, height 8..10.3. NO arches below y 9.
--   Door%d+                ground-storey doors, 8..9.6 tall.
--   ArchWindow%d+ [unit]   floor-3 arched openings (14): each a Model or part, bottom >= 18, top <= 27, centre x -268..-258.
--   ArchWindowTall%d+ [unit] tall double-height arched grid windows (4): bottom 9..10.8, top >= 23.5; at the two end bays (z about 77.4 and 237.0) and
--                          the two pavilion flanks (z about 150.4 and 169.6). The pavilion centre arch (z 160) is an ordinary ArchWindow. 18 arches in all.
--   Window2_%d+            floor-2 rectangular windows, y 12..19.5.
--   FloorSlab2%u?%d* / FloorSlab3%u?%d*   top y 9.5 and 18.5 (+-0.7).  Cornice%u?%d*   top y 30.5 (+-1.2), at least 2.
--   Balustrade2%u?%d* / Balustrade3%u?%d*  rail top y 12.5 and 21.5 (+-0.7).  RailPost%d+  posts of EVERY railing, 3.0 tall (2.9..3.4).
--   WingRoof%u?%d*         low red hip roofs (172,78,72), at least 8 parts, highest top (ridge) 34.5 +-1.0 (the north wing's broad hip reaches 35.4, see its own assertion), z union covers 74..247.
--   PavilionRoof%u?%d*     red hip roof, at least 4 parts, apex 36 +-1.0 and higher than the wing ridge by at least 0.5. A roof lantern is named PavilionLantern:
--                          any name matching this pattern (PavilionRoofL, PavilionRoof2) counts as roof and its top would be the apex.
--   PorticoDeck            ONE part, the terrace: top y 9.5 (+-0.7), x -262.6..-250.4, z 145.6..174.4. BP1: a low terrace on slim posts with a balustrade
--                          (Balustrade2P%d rails, RailPost%d+ posts, 3 tall), open above, no roof over it: no PorticoEntablature/Capital/Cornice/Beam, no
--                          PorticoColumn top above y 12, PavilionRoof east edge at most x -262. PorchStep1..4: a short ground flight at the terrace's south-front corner.
--   Portico%a*%d*          portico parts; max east face -250.4 (+-2). PorticoColumn%d+ (exactly 4): round (Cylinder), red, 9+ tall (9.3), standing on the ground,
--                          centre x -260 or further east, z 146..174, and the EAST EDGE (centre + radius) at most -250.39 so that no column reaches the aisle box
--                          (x -250.4..-228) or the wide Guide box (x -250..-229): with radius 1.2 that is a centre of -251.6 or further west.
-- STAIRS (Structure/Stairs): two stairs, mirror-symmetric about z 160. North stair N, south stair S.
--   StepN%d+ / StepS%d+    10 each, index 1 = foot, 10 = top. Size.X = width 6 (+-0.8), Size.Y = height of that step's tread above ground (a solid block),
--                          so tops rise 0.85..1.0 per step, step 1 top <= 1.0, step 10 top 9.5 (+-0.6). Foot step centre x -258..-250, z 90..100 (N) / 221..232 (S);
--                          top step centre x -266..-259, z 140..150 (N) / 170..180 (S). |z-160| shrinks every step. StepS(i).z + StepN(i).z = 320 (+-1.5).
--   StairPostN%d+ / StairPostS%d+   rail posts (3 tall, 6+ each).  StairRailN%d* / StairRailS%d*  rails (2+ each).  StairLandingN / StairLandingS top y 9.5 (+-0.7).
-- SCAFFOLD (Structure/Scaffold): rooftop lattice over the SOUTH wing only. Parts named ScaffoldP1<Role><n> and ScaffoldP2<Role><n> (Role = Post, Rail, Brace or
--   Truss), steel pipe, rusty (128,98,82), pipe thin (two smallest dimensions <= 1.2), z 177.6..231 (P1 205.3..231, P2 177.6..203.8, +-3), y 30.5..51, x -274..-263.
--   40..80 parts. NO SurfaceGui, BillboardGui, TextLabel, Decal or Texture anywhere under it and no gui adorned to it.
-- SHEDS (Structure/Sheds/Gabled, Structure/Sheds/Markets): Models ShedA, ShedB, ShedC, ShedD (x -471.4..-415.6; A z 196.7..232.0, B 158.6..190.2,
--   C 115.0..150.5 (BP1: roof-free aisle z 150.5..159 between B and C), D 72.2..107.4, +-3). Inside each: Shed<L>Wall%d+, Shed<L>Column%d+, Shed<L>Roof%d+ (>= 2 red slopes (172,78,72) +-25), Shed<L>Ridge,
--   Shed<L>Clerestory%d+ (>= 1, top >= roof top + 2, centre z inside the shed). Shed top 16..23. Models WetMarket1 (x -376..-312.3, z 190.6..231.6) and WetMarket2
--   (z 112..153, BP1), DryGoods (x -379.6..-311.2, z 159.6..189.5), parts CrossAisle%a*%d* (x -311.2..-299.7, z 71.4..249.3), MidBand%d+ roofs (optional).
--   Counter%d+  stall counters (top y 3.5 +-0.2), at least 24 inside WetMarket1 and 30 inside WetMarket2 (BP1: 28 and 35 stalls). Canopy%d* tarps: at least 28 in all, 3+ colours.
-- BAGSAKAN (Structure/Bagsakan): parts Bagsakan%a+%d* (BagsakanWall, BagsakanRoof (>= 2 red slopes), BagsakanDoor) forming the long shed x -556..-506.3,
--   z 84..240.6 (+-3), ridge 16 (+-2.5, BP1 pitch); TruckBay%d+ (6: centres x -505..-488, three with z <= 136, three with z >= 188) and Truck%d+ (Models, one on each bay,
--   within 6 studs in z and inside the bay's x range).
-- FORECOURT (Structure/Forecourt, Yard): LeanRoof%d+ (4, tin colours, x -265..-253, z 70..91 or 229..250), TricycleBody%d+ (8) with TricycleWheel%d+ (>= 24) and
--   TricycleRoof%d+ (>= 8), x -237..-231, z 100..136 (4) and 184..220 (4); StreetStall%d+ Models (5) x -241..-235, z 244, 254, 264 and 62, 52 (+-3.5).
--   SideStallS%d+ (>= 10, z 232.4..276.3) and SideStallN%d+ (>= 10, z 33.3..71.1), x -471.4..-311.2. LocalNPCs: ShopperBayong1/2 (Role attribute) at
--   (-380, 255) and (-372, 258) +-3.
-- Other names: PriceBoard%d* (>= 28, numbered or not, one label reads KAMATIS), Counter, Canopy as above; every name is ASCII; SurfaceGui text ASCII only.
-- ======================================================================================================================
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(-402, 0, 160)
local SLOT = { x0 = -576, x1 = -228, z0 = -5, z1 = 325 }
local BRANDS = { "ROSE PHARMACY", "PHARMACY", "BOTIKA", "DRUGSTORE", "MARLBORO", "CIGARETTE" } -- read in the photos (Marlboro signs, Rose Pharmacy map label)
local CAP = { part = 400, total = 2000 }

local function run(opts)
	local only = (opts or {}).only
	local results = { passed = 0, failed = 0, failures = {} }
	local function check(name, cond, detail)
		if cond then
			results.passed += 1
		else
			results.failed += 1
			table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
		end
	end
	local site
	for _, parentName in ipairs({ "Staging", "Sites" }) do -- by name: ipairs over { nil, x } would stop at the nil
		local parent = workspace:FindFirstChild(parentName)
		if parent and parent:FindFirstChild("Site02_Market") then site = site or parent.Site02_Market end
	end
	check("Site02_Market exists", site ~= nil)
	if not site then return HttpService:JSONEncode(results) end

	------------------------------------------------------------------ helpers
	local function isRig(inst)
		local p = inst
		while p and p ~= site do
			if p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
		end
		return false
	end
	local KEPT = { Guide = true, InfoPanel = true }
	local function isKept(inst)
		local p = inst
		while p and p ~= site do
			if KEPT[p.Name] and p.Parent == site then return true end
			p = p.Parent
		end
		return false
	end
	local own = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then table.insert(own, d) end
	end
	local bc = {}
	local function wb(p)
		local c = bc[p]
		if c then return c[1], c[2] end
		local cf, h = p.CFrame, p.Size / 2
		local lo, hi = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
		for _, sx in ipairs({ -1, 1 }) do for _, sy in ipairs({ -1, 1 }) do for _, sz in ipairs({ -1, 1 }) do
			local w = cf * Vector3.new(sx * h.X, sy * h.Y, sz * h.Z)
			lo = Vector3.new(math.min(lo.X, w.X), math.min(lo.Y, w.Y), math.min(lo.Z, w.Z))
			hi = Vector3.new(math.max(hi.X, w.X), math.max(hi.Y, w.Y), math.max(hi.Z, w.Z))
		end end end
		bc[p] = { lo, hi }
		return lo, hi
	end
	local function union(list)
		local lo, hi = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
		for _, p in ipairs(list) do
			local a, b = wb(p)
			lo = Vector3.new(math.min(lo.X, a.X), math.min(lo.Y, a.Y), math.min(lo.Z, a.Z))
			hi = Vector3.new(math.max(hi.X, b.X), math.max(hi.Y, b.Y), math.max(hi.Z, b.Z))
		end
		return lo, hi
	end
	local function partsIn(inst)
		if inst:IsA("BasePart") then return { inst } end
		local t = {}
		for _, d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then table.insert(t, d) end end
		return t
	end
	local function ub(u) return union(partsIn(u)) end
	local function named(pat) -- non-rig BaseParts whose name matches the Lua pattern
		local t = {}
		for _, p in ipairs(own) do if p.Name:match(pat) then table.insert(t, p) end end
		return t
	end
	local function units(pat) -- top-level Models / BaseParts matching the pattern (not nested in a match)
		local t = {}
		for _, d in ipairs(site:GetDescendants()) do
			if (d:IsA("BasePart") or d:IsA("Model")) and d.Name:match(pat) and not isRig(d) and not isKept(d) then
				local top, a = true, d.Parent
				while a and a ~= site do if a.Name:match(pat) then top = false break end a = a.Parent end
				if top and #partsIn(d) > 0 then table.insert(t, d) end -- an empty Model is not a unit: it would pass every bounds test vacuously
			end
		end
		return t
	end
	local function cen(u) local lo, hi = ub(u) return (lo + hi) / 2 end
	local function between(v, a, b) return v ~= nil and v >= a and v <= b end
	local function near(v, t, tol) return v ~= nil and math.abs(v - t) <= tol end
	local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
	local function light(p) local r, g, b = rgb(p); return math.min(r, g, b) >= 190 and math.max(r, g, b) - math.min(r, g, b) <= 45 end -- 190: the shaded wall (214,208,194) of layout.md section 4 passes too
	local function white(p) local r, g, b = rgb(p); return r >= 225 and g >= 220 and b >= 205 end
	local function redTrim(p) local r, g, b = rgb(p); return r >= 140 and g <= 100 and b <= 90 and r >= g + 60 end
	local function roofRed(p) local r, g, b = rgb(p); return math.abs(r - 172) <= 28 and math.abs(g - 78) <= 28 and math.abs(b - 72) <= 28 end -- 28: the sun-faded hips (176,100,98) of layout.md section 4 pass too
	local function rusty(p) local r, g, b = rgb(p); return between(r, 105, 150) and between(g, 78, 120) and between(b, 62, 105) end
	local function tinCol(p) -- layout.md section 4: rust (146,76,64), dark rust (122,60,52), galvanised grey (150,154,158); the old model's (150,90,60) and (130,134,138) pass too
		local r, g, b = rgb(p)
		local rust = r >= 108 and r <= 160 and g >= 46 and g <= 92 and b >= 38 and b <= 80 and r >= g + 40
		local grey = math.min(r, g, b) >= 124 and math.max(r, g, b) <= 172 and math.max(r, g, b) - math.min(r, g, b) <= 20
		return rust or grey
	end
	local function sx(v) return string.format("%.1f", v) end
	local function single(name) -- ONE BasePart named name, and no Model/Folder shares the name
		local parts, clash = named("^" .. name .. "$"), 0
		for _, d in ipairs(site:GetDescendants()) do if d.Name == name and not d:IsA("BasePart") then clash += 1 end end
		return parts[1], #parts == 1 and clash == 0, #parts .. " parts, " .. clash .. " containers named " .. name
	end
	local function container(path) -- "Structure/Hall/Shell" -> Instance or nil
		local c = site
		for seg in path:gmatch("[^/]+") do c = c and c:FindFirstChild(seg) end
		return c
	end
	local function pcallGroup(name, fn)
		if only ~= nil and only ~= name then return end
		local ok, err = pcall(fn)
		if not ok then check("group " .. name .. " ran without a script error", false, tostring(err)) end
	end
	local function blockers(centre, size, minTop)
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = { site }
		local bad = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(centre), size, params)) do
			-- ground slabs (top within 0.6 of the ground) are fine, standing objects are not
			if not isKept(p) and not isRig(p) and p.Position.Y + p.Size.Y / 2 > (minTop or 0.6) then table.insert(bad, p.Name) end
		end
		return bad
	end

	------------------------------------------------------------------ hall: front arcade, pavilion, stairs, scaffold, name band
	pcallGroup("hall", function()
		local hb, hbOk, hbd = single("HallBody")
		check("HallBody is ONE unique part (no container shares the name)", hbOk, hbd)
		if hb then
			local lo, hi = wb(hb)
			check("HallBody: east face x -262.6 (+-2.5), west face -304..-296, z 71.4..249.3 (+-3), top y 28.5..32",
				near(hi.X, -262.6, 2.5) and between(lo.X, -304, -296) and near(lo.Z, 71.4, 3) and near(hi.Z, 249.3, 3) and between(hi.Y, 28.5, 32),
				string.format("x %s..%s z %s..%s top %s", sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z), sx(hi.Y)))
			check("HallBody walls are light (white or cream)", light(hb))
		end
		local pb, pbOk, pbd = single("PavilionBody")
		check("PavilionBody is ONE unique part", pbOk, pbd)
		if pb then
			local lo, hi = wb(pb)
			check("PavilionBody: centred z 160 (+-2), z 145.6..174.4 (+-2.5), west face -303.3 (+-3), east face -262.6 (+-3), top y 28.5..32, light",
				near((lo.Z + hi.Z) / 2, 160, 2) and near(lo.Z, 145.6, 2.5) and near(hi.Z, 174.4, 2.5) and near(lo.X, -303.3, 3) and near(hi.X, -262.6, 3) and between(hi.Y, 28.5, 32) and light(pb),
				string.format("x %s..%s z %s..%s top %s", sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z), sx(hi.Y)))
		end
		-- pilasters
		local pil = named("^Pilaster%d+$")
		local okPil, zmin, zmax = 0, 1e9, -1e9
		for _, p in ipairs(pil) do
			local lo, hi = wb(p)
			if redTrim(p) and hi.Y - lo.Y >= 28 and between(p.Position.X, -267, -258) then okPil += 1 end
			zmin, zmax = math.min(zmin, p.Position.Z), math.max(zmax, p.Position.Z)
		end
		check("exactly 19 red full-height Pilaster parts on the east face, from the south end to the north end",
			#pil == 19 and okPil == #pil and zmin <= 77 and zmax >= 243, #pil .. " pilasters, " .. okPil .. " ok, z " .. sx(zmin) .. ".." .. sx(zmax))
		-- ground storey: open rectangular bays, no arches
		local bays = units("^GroundBay%d+$")
		local badBay = 0
		for _, u in ipairs(bays) do
			local lo, hi = ub(u)
			if not (lo.Y <= 1 and between(hi.Y - lo.Y, 8, 10.3)) then badBay += 1 end
		end
		check("exactly 18 ground-storey open rectangular GroundBay units, bottom at the ground, 8..10.3 tall", #bays == 18 and badBay == 0, #bays .. " bays, " .. badBay .. " off")
		local lowArch = {}
		for _, u in ipairs(units("^Arch")) do
			local lo = ub(u)
			if lo.Y < 9 then table.insert(lowArch, u.Name) end
		end
		check("no arch on floor 1: every unit named Arch* has its lowest point at y 9 or higher", #lowArch == 0, #lowArch .. ": " .. table.concat(lowArch, ",", 1, math.min(#lowArch, 4)))
		local doors = named("^Door%d+$")
		local badDoor = 0
		for _, d in ipairs(doors) do local lo, hi = wb(d) if not between(hi.Y - lo.Y, 8, 9.6) then badDoor += 1 end end
		check("ground-storey doors: 4+ Door parts, each 8..9.6 tall (human scale)", #doors >= 4 and badDoor == 0, #doors .. " doors, " .. badDoor .. " off")
		-- arched openings on the top floor
		local norm, tall = units("^ArchWindow%d+$"), units("^ArchWindowTall%d+$")
		local badN, badT = 0, 0
		for _, u in ipairs(norm) do local lo, hi = ub(u) local c = (lo + hi) / 2 if not (lo.Y >= 18 and hi.Y <= 27 and between(c.X, -268, -258)) then badN += 1 end end
		for _, u in ipairs(tall) do local lo, hi = ub(u) local c = (lo + hi) / 2 if not (between(lo.Y, 9, 10.8) and hi.Y >= 23.5 and between(c.X, -268, -258)) then badT += 1 end end
		check("exactly 18 arched openings on the front face: 14 ArchWindow + 4 tall double-height arched grid windows (ArchWindowTall)",
			#norm == 14 and #tall == 4 and badN == 0 and badT == 0,
			#norm .. " arches + " .. #tall .. " tall, off " .. badN .. "/" .. badT)
		local function hasAt(list, z, tol) for _, u in ipairs(list) do if near(cen(u).Z, z, tol) then return true end end return false end
		check("tall windows sit at the two end bays (north z 77.4, south z 237.0: centred between the last two pilasters) and on both flanks of the pavilion (z 150.4 and 169.6); the pavilion centre arch (z 160) is ordinary",
			hasAt(tall, 77.4, 4) and hasAt(tall, 237.0, 2.5) and hasAt(tall, 150.4, 5) and hasAt(tall, 169.6, 5) and hasAt(norm, 160, 3))
		-- BP1 and BP2 agree (audit_bp2 A6, A8): the arches on both wings repeat at pitch 9.25 and are 7.9 wide (outer frame), the two pavilion flank arches are 5.0 wide
		local function wingArches(z0, z1)
			local t = {}
			for _, u in ipairs(norm) do local c = cen(u) if c.Z > z0 and c.Z < z1 then table.insert(t, u) end end
			table.sort(t, function(a, b) return cen(a).Z < cen(b).Z end)
			return t
		end
		local function archDims(t)
			local badW, badP = 0, 0
			for i, u in ipairs(t) do
				local lo, hi = ub(u)
				if not near(hi.Z - lo.Z, 7.9, 0.5) then badW += 1 end
				if i > 1 and not near(cen(u).Z - cen(t[i - 1]).Z, 9.25, 0.4) then badP += 1 end
			end
			return badW, badP
		end
		local archN, archS = wingArches(80, 146), wingArches(174, 240)
		local nW, nP = archDims(archN)
		local sW, sP = archDims(archS)
		check("wing arches follow both drawings: 7 north and 6 south ArchWindow, each 7.9 wide (+-0.5), repeating at pitch 9.25 (+-0.4)",
			#archN == 7 and #archS == 6 and nW + sW == 0 and nP + sP == 0,
			#archN .. " north, " .. #archS .. " south, " .. (nW + sW) .. " off width, " .. (nP + sP) .. " off pitch")
		local flank, badFlank = {}, 0
		for _, u in ipairs(tall) do
			local c = cen(u)
			if between(c.Z, 146, 174) then
				table.insert(flank, u)
				local lo, hi = ub(u)
				if not near(hi.Z - lo.Z, 5.0, 0.5) then badFlank += 1 end
			end
		end
		check("pavilion flank arches (ArchWindowTall between z 146 and 174): exactly 2, each 5.0 wide (+-0.5), double height kept", #flank == 2 and badFlank == 0, #flank .. " flank arches, " .. badFlank .. " off width")
		-- R1b (BP1 elevation crops elev_left and elev_right, BP2 elevation): the tall end arch bay carries no rail across it on either floor, the arch stands
		-- centred between its two pilasters (the drawing leaves about 2 studs of wall each side), and the south end keeps a short railed strip beyond its end pilaster
		local endArch = {}
		for _, u in ipairs(tall) do local c = cen(u) if c.Z < 100 or c.Z > 200 then table.insert(endArch, u) end end
		local crossed, gapBad, gapDetail = {}, 0, {}
		local pilLoHi = {}
		for _, p in ipairs(pil) do local lo, hi = wb(p) table.insert(pilLoHi, { lo = lo.Z, hi = hi.Z }) end
		for _, u in ipairs(endArch) do
			local alo, ahi = ub(u)
			for _, p in ipairs(named("^Balustrade[23]%u?%d*$")) do
				local rlo, rhi = wb(p)
				if rlo.Z < ahi.Z - 0.5 and rhi.Z > alo.Z + 0.5 then table.insert(crossed, p.Name .. "@" .. sx(cen(u).Z)) end
			end
			for _, p in ipairs(named("^RailPost%d+$")) do
				if p.Position.Z > alo.Z and p.Position.Z < ahi.Z and p.Position.X > -266 then table.insert(crossed, p.Name .. "@" .. sx(cen(u).Z)) end
			end
			local gL, gR = math.huge, math.huge
			for _, q in ipairs(pilLoHi) do
				if q.hi <= alo.Z + 0.5 then gL = math.min(gL, alo.Z - q.hi) end
				if q.lo >= ahi.Z - 0.5 then gR = math.min(gR, q.lo - ahi.Z) end
			end
			if gL > 3.5 or gR > 3.5 then gapBad += 1 end
			table.insert(gapDetail, sx(cen(u).Z) .. ": " .. sx(gL) .. "/" .. sx(gR))
		end
		check("end arch bays have no balustrade or rail post across them (floor 2 and floor 3), as BP1 and BP2 draw the tall grid arch clear of rails",
			#endArch == 2 and #crossed == 0, #crossed .. " crossings: " .. table.concat(crossed, ", ", 1, math.min(#crossed, 4)))
		check("each end arch stands centred in its bay: at most 3.5 studs of bare wall to the pilaster on either side (BP1 shows about 2)",
			#endArch == 2 and gapBad == 0, table.concat(gapDetail, " | "))
		local stripOk = { [2] = false, [3] = false }
		for _, p in ipairs(named("^Balustrade[23]E%d*$")) do
			local lo, hi = wb(p)
			if lo.Z >= 243.5 and hi.Z <= 249.6 and hi.Z - lo.Z >= 3 then stripOk[tonumber(p.Name:match("^Balustrade(%d)"))] = true end
		end
		check("south end strip beyond the end pilaster (z 243.5..249.6) carries a rail on floor 2 and on floor 3 (Balustrade2E / Balustrade3E, 3+ long)",
			stripOk[2] and stripOk[3], "floor 2 " .. tostring(stripOk[2]) .. ", floor 3 " .. tostring(stripOk[3]))
		local w2 = named("^Window2_%d+$")
		local badW = 0
		for _, w in ipairs(w2) do local lo, hi = wb(w) if not (lo.Y >= 12 and hi.Y <= 19.5) then badW += 1 end end
		check("12+ rectangular floor-2 windows (Window2_n), y 12..19.5", #w2 >= 12 and badW == 0, #w2 .. " windows, " .. badW .. " off")
		-- storeys
		local function levelOk(pat, y, minCount)
			local l, bad = named(pat), 0
			for _, p in ipairs(l) do local _, hi = wb(p) if not near(hi.Y, y, 0.7) then bad += 1 end end
			return #l >= minCount and bad == 0, #l .. " parts, " .. bad .. " off"
		end
		local ok2, d2 = levelOk("^FloorSlab2%u?%d*$", 9.5, 1)
		local ok3, d3 = levelOk("^FloorSlab3%u?%d*$", 18.5, 1)
		local okC, dC = levelOk("^Cornice%u?%d*$", 30.5, 2)
		check("storey levels: FloorSlab2 top 9.5, FloorSlab3 top 18.5 (+-0.7)", ok2 and ok3, d2 .. " / " .. d3)
		local corn = named("^Cornice%u?%d*$")
		local badCorn = 0
		for _, p in ipairs(corn) do local _, hi = wb(p) if not near(hi.Y, 30.5, 1.2) then badCorn += 1 end end
		check("cornice: 2+ Cornice parts with top y 30.5 (+-1.2)", #corn >= 2 and badCorn == 0, #corn .. " parts, " .. badCorn .. " off")
		local okB2, dB2 = levelOk("^Balustrade2%u?%d*$", 12.5, 1)
		local okB3, dB3 = levelOk("^Balustrade3%u?%d*$", 21.5, 1)
		check("balustrades 3 high: rail top y 12.5 (floor 2) and 21.5 (floor 3)", okB2 and okB3, dB2 .. " / " .. dB3)
		-- roofs
		local wr, pr = named("^WingRoof%u?%d*$"), named("^PavilionRoof%u?%d*$")
		local wlo, whi = union(wr)
		local plo, phi = union(pr)
		local wrRed, prRed = 0, 0
		for _, p in ipairs(wr) do if roofRed(p) then wrRed += 1 end end
		for _, p in ipairs(pr) do if roofRed(p) then prRed += 1 end end
		check("wing roofs: 8+ low red hip parts, ridge y 34.5 (+-1), covering z 74..247",
			#wr >= 8 and wrRed == #wr and near(whi.Y, 34.5, 1) and wlo.Z <= 76 and whi.Z >= 245,
			#wr .. " parts (" .. wrRed .. " red), ridge " .. (#wr > 0 and sx(whi.Y) or "n/a") .. ", z " .. (#wr > 0 and (sx(wlo.Z) .. ".." .. sx(whi.Z)) or "n/a"))
		check("central pavilion hip roof: 4+ red parts, apex y 36 (+-1) and higher than the wing ridge", #pr >= 4 and prRed == #pr and #wr > 0 and near(phi.Y, 36, 1) and phi.Y >= whi.Y + 0.5,
			#pr .. " parts, apex " .. (#pr > 0 and sx(phi.Y) or "n/a") .. " vs wing ridge " .. (#wr > 0 and sx(whi.Y) or "n/a"))
		-- BP2 (audit_bp2 A1/D1, owner chose the hybrid): the NORTH wing keeps its 7 arches but carries BP2's huge broad ribbed hip roof: it starts flush at the
		-- pavilion's north face, runs 5.4 past the north end, overhangs 4 each side and has a long flat ridge (eave 30.5, ridge 35.4, still 0.6 under the pavilion apex)
		local nwr = {}
		for _, p in ipairs(wr) do if p.Position.Z < 146 then table.insert(nwr, p) end end
		local nlo, nhi = union(nwr)
		check("north wing roof is BP2's huge broad hip: 12+ WingRoof parts north of the pavilion, x -303.7..-258.6 (+-1.5), z 66..145.6 (+-1.5), ridge y 35.4 (+-0.5)",
			#nwr >= 12 and near(nlo.X, -303.7, 1.5) and near(nhi.X, -258.6, 1.5) and near(nlo.Z, 66, 1.5) and near(nhi.Z, 145.6, 1.5) and near(nhi.Y, 35.4, 0.5),
			#nwr .. " parts" .. (#nwr > 0 and string.format(", x %s..%s z %s..%s ridge %s", sx(nlo.X), sx(nhi.X), sx(nlo.Z), sx(nhi.Z), sx(nhi.Y)) or ""))
		local ribs, badRib = named("^RoofRib%d+$"), 0
		for _, p in ipairs(ribs) do
			local lo, hi = wb(p)
			if not (lo.X >= -304.2 and hi.X <= -258.1 and lo.Z >= 65.5 and hi.Z <= 146.1 and lo.Y >= 30.4 and hi.Y <= 36.0 and redTrim(p)) then badRib += 1 end
		end
		check("BP2 ribbed roof: 6+ RoofRib strips on the north hip, all inside its extent (y 30.4..36), red", #ribs >= 6 and badRib == 0, #ribs .. " ribs, " .. badRib .. " off")
		-- portico
		local por, cols = named("^Portico%a*%d*$"), named("^PorticoColumn%d+$")
		local _, porHi = union(por)
		local badCol = 0
		for _, c in ipairs(cols) do
			local lo, hi = wb(c)
			-- the EAST EDGE decides, not the centre: a centre of -251 with radius 1.2 would reach x -249.8, inside the aisle box (x -250.4..) and the wide Guide box (x -250..)
			if not (c.Shape == Enum.PartType.Cylinder and redTrim(c) and hi.Y - lo.Y >= 9 and lo.Y <= 1 and c.Position.X >= -260 and hi.X <= -250.39 and between(c.Position.Z, 146, 174)) then badCol += 1 end
		end
		check("portico: front face x -250.4 (+-2), exactly 4 round red PorticoColumn parts (9+ tall, on the ground, east edge at most x -250.39)", #por > 0 and near(porHi.X, -250.4, 2) and #cols == 4 and badCol == 0,
			#cols .. " columns, " .. badCol .. " off, front " .. (#por > 0 and sx(porHi.X) or "n/a"))
		-- BP1 (audit 2026-10-29, crop iso_portico): the pavilion's projection is a LOW TERRACE at floor-2 height on slim posts with a balustrade, open above, no roof over it
		local deck, deckOk, deckD = single("PorticoDeck")
		check("PorticoDeck is ONE unique part", deckOk, deckD)
		if deck then
			local lo, hi = wb(deck)
			check("PorticoDeck: top y 9.5 (+-0.7), x -262.6..-250.4 (+-1), z 145.6..174.4 (+-1.5)",
				near(hi.Y, 9.5, 0.7) and near(lo.X, -262.6, 1) and near(hi.X, -250.4, 1) and hi.X <= -250.39 and near(lo.Z, 145.6, 1.5) and near(hi.Z, 174.4, 1.5),
				string.format("x %s..%s z %s..%s top %s", sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z), sx(hi.Y)))
		end
		local tallCol = 0
		for _, c in ipairs(cols) do local _, hi = wb(c) if hi.Y > 12 then tallCol += 1 end end
		check("portico posts are slim terrace posts: no PorticoColumn top above y 12", #cols == 4 and tallCol == 0, tallCol .. " of " .. #cols .. " rise above y 12")
		local oldTop = #named("^PorticoEntablature%d*$") + #named("^PorticoCapital%d*$") + #named("^PorticoCornice%d*$") + #named("^PorticoBeam%d*$")
		check("no portico entablature, capitals, cornice or beams (BP1: open above the terrace)", oldTop == 0, oldTop .. " parts")
		local pRail, pPost = 0, 0
		for _, p in ipairs(named("^Balustrade2%u?%d*$")) do local lo, hi = wb(p) if lo.X >= -262.7 and hi.X <= -250.3 and lo.Z >= 145 and hi.Z <= 175 then pRail += 1 end end
		for _, p in ipairs(named("^RailPost%d+$")) do local lo, hi = wb(p) if lo.X >= -262.7 and hi.X <= -250.3 and lo.Z >= 145 and hi.Z <= 175 and near(lo.Y, 9.5, 0.7) then pPost += 1 end end
		check("terrace balustrade: 3+ Balustrade2 rails and 8+ RailPost posts standing on the deck (rail top 12.5 is checked with the other floor-2 rails)", pRail >= 3 and pPost >= 8, pRail .. " rails, " .. pPost .. " posts")
		check("pavilion hip roof stops at the body: PavilionRoof east edge at most x -262 (BP1: no roof over the terrace)", #pr > 0 and phi.X <= -262, #pr > 0 and ("east edge " .. sx(phi.X)) or "no roof")
		local ps = {}
		for _, p in ipairs(named("^PorchStep%d+$")) do ps[tonumber(p.Name:match("%d+$"))] = p end
		local psOk, psD = #ps == 4, #ps .. " steps"
		if psOk then
			for i = 1, 4 do
				local lo, hi = wb(ps[i])
				if not (hi.X <= -250.39 and lo.X >= -262 and between(lo.Z, 174, 184) and hi.Y <= 2.5 and lo.Y <= 0.2) then psOk, psD = false, "step " .. i .. " off: " .. string.format("x %s..%s z %s..%s top %s", sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z), sx(hi.Y)) break end
				if i > 1 then
					local _, hp = wb(ps[i - 1])
					local rise = hi.Y - hp.Y
					if rise < 0.2 or rise > 0.6 or not (ps[i].Position.Z < ps[i - 1].Position.Z) then psOk, psD = false, "step " .. i .. " rise " .. sx(rise) break end
				end
			end
		end
		check("BP1 ground flight at the terrace's south-front corner: exactly 4 PorchStep parts, each rising 0.2..0.6 toward the deck, east edge at most x -250.39, top at most 2.5", psOk, psD)
		-- name band
		local nb, nbOk, nbd = single("NameBand")
		check("NameBand is ONE unique part", nbOk, nbd)
		if nb then
			local lo, hi = wb(nb)
			check("NameBand: white, 3.5+ tall, 40+ long, on the east frontage (centre x -266..-249, y 14..31.5, z inside 71..250)",
				white(nb) and hi.Y - lo.Y >= 3.5 and hi.Z - lo.Z >= 40 and between(nb.Position.X, -266, -249) and lo.Y >= 14 and hi.Y <= 31.5 and lo.Z >= 71 and hi.Z <= 250,
				string.format("y %s..%s z %s..%s x %s", sx(lo.Y), sx(hi.Y), sx(lo.Z), sx(hi.Z), sx(nb.Position.X)))
			local guis = {}
			for _, g in ipairs(nb:GetChildren()) do if g:IsA("SurfaceGui") then table.insert(guis, g) end end
			local g = guis[1]
			local facesEast = g ~= nil and (nb.CFrame:VectorToWorldSpace(Vector3.FromNormalId(g.Face))):Dot(Vector3.new(1, 0, 0)) > 0.99
			local lab = g and g:FindFirstChildWhichIsA("TextLabel", true)
			check("NameBand has ONE SurfaceGui facing east with a TextLabel reading CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET",
				#guis == 1 and facesEast and lab ~= nil and lab.Text:upper() == "CANDIDO B. LOPEZ MEMORIAL PUBLIC MARKET", #guis .. " guis, east " .. tostring(facesEast) .. ", text " .. (lab and lab.Text or "none"))
			local br, bg, bb = 0, 0, 0
			if lab then br, bg, bb = lab.TextColor3.R * 255, lab.TextColor3.G * 255, lab.TextColor3.B * 255 end
			check("NameBand text: blue capitals, fixed TextSize (TextScaled false, TextSize 20+)",
				lab ~= nil and lab.TextScaled == false and lab.TextSize >= 20 and bb >= 120 and br <= 90 and bb > br + 50 and lab.Text == lab.Text:upper(), lab and ("size " .. lab.TextSize .. " scaled " .. tostring(lab.TextScaled)) or "no label")
		end
		-- stairs
		local function steps(prefix)
			local t = {}
			for _, p in ipairs(named("^" .. prefix .. "%d+$")) do t[tonumber(p.Name:match("%d+$"))] = p end
			return t
		end
		local N, S = steps("StepN"), steps("StepS")
		local function top(p) local _, hi = wb(p) return hi.Y end
		local function stairOk(T, zFoot, zTop)
			if #T ~= 10 then return false, "steps " .. #T end
			for i = 1, 10 do if T[i] == nil then return false, "missing " .. i end end
			local d = string.format("foot %s,%s top %s,%s", sx(T[1].Position.X), sx(T[1].Position.Z), sx(T[10].Position.X), sx(T[10].Position.Z))
			if not (between(T[1].Position.X, -258, -250) and between(T[1].Position.Z, zFoot[1], zFoot[2]) and between(T[10].Position.X, -266, -259) and between(T[10].Position.Z, zTop[1], zTop[2])) then return false, d end
			if not (top(T[1]) <= 1.0 and near(top(T[10]), 9.5, 0.6)) then return false, "heights " .. sx(top(T[1])) .. ".." .. sx(top(T[10])) end
			for i = 1, 10 do
				if not near(T[i].Size.X, 6, 0.8) then return false, "width " .. sx(T[i].Size.X) end
				if i > 1 then
					local rise = top(T[i]) - top(T[i - 1])
					if rise < 0.85 or rise > 1.0 + 1e-3 then return false, "riser " .. i .. " is " .. sx(rise) end
					if not (math.abs(T[i].Position.Z - 160) < math.abs(T[i - 1].Position.Z - 160)) then return false, "step " .. i .. " does not climb toward the pavilion" end
				end
			end
			return true, d
		end
		local okN, dN = stairOk(N, { 90, 100 }, { 140, 150 })
		local okS, dS = stairOk(S, { 221, 232 }, { 170, 180 })
		check("north stair: 10 steps (width 6, risers 0.85..1.0, walkable), foot near z 94, climbing toward the pavilion to z 145 at y 9.5", okN, dN)
		check("south stair: 10 steps (width 6, risers 0.85..1.0, walkable), foot near z 227, climbing toward the pavilion to z 175 at y 9.5", okS, dS)
		local sym = okN and okS
		if sym then
			for i = 1, 10 do
				if not (near(N[i].Position.Z + S[i].Position.Z, 320, 1.5) and near(N[i].Position.X, S[i].Position.X, 1) and near(top(N[i]), top(S[i]), 0.1)) then sym = false end
			end
		end
		check("the two stairs are mirror-symmetric about z 160 (z sums 320 +-1.5, same x and tops)", sym)
		local function railOk(letter)
			local posts, rails, landing = named("^StairPost" .. letter .. "%d+$"), named("^StairRail" .. letter .. "%d*$"), named("^StairLanding" .. letter .. "$")
			local bad = 0
			for _, p in ipairs(posts) do local lo, hi = wb(p) if not between(hi.Y - lo.Y, 2.9, 3.4) then bad += 1 end end
			return #posts >= 6 and bad == 0 and #rails >= 2 and #landing == 1 and near(top(landing[1]), 9.5, 0.7)
		end
		check("each stair has 6+ rail posts 3 tall, 2+ rails and a landing at y 9.5 (+-0.7)", railOk("N") and railOk("S"))
		local rp = named("^RailPost%d+$")
		local badRp = 0
		for _, p in ipairs(rp) do local lo, hi = wb(p) if not between(hi.Y - lo.Y, 2.9, 3.4) then badRp += 1 end end
		check("railing posts (RailPost) are 3 tall (human scale), 12+ of them", #rp >= 12 and badRp == 0, #rp .. " posts, " .. badRp .. " off")
		-- scaffold
		local sc = container("Structure/Scaffold")
		local sp = sc and partsIn(sc) or {}
		local zlo, zhi = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
		if #sp > 0 then zlo, zhi = union(sp) end
		local nonPipe, nonRust, textual, badName = 0, 0, 0, 0
		for _, p in ipairs(sp) do
			local d = { p.Size.X, p.Size.Y, p.Size.Z }
			table.sort(d)
			if d[2] > 1.2 then nonPipe += 1 end
			if not rusty(p) then nonRust += 1 end
			if not p.Name:match("^ScaffoldP[12]%a+%d*$") then badName += 1 end
		end
		if sc then
			for _, d in ipairs(sc:GetDescendants()) do
				if d:IsA("SurfaceGui") or d:IsA("BillboardGui") or d:IsA("ScreenGui") or d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("ImageLabel") or d:IsA("Decal") or d:IsA("Texture") then textual += 1 end
			end
		end
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("LayerCollector") and d.Adornee and sc and d.Adornee:IsDescendantOf(sc) then textual += 1 end
		end
		check("rooftop scaffold: 40..80 steel-pipe parts named ScaffoldP1/P2<Role><n>, all pipe thin and rusty (128,98,82)", #sp >= 40 and #sp <= 80 and nonPipe == 0 and nonRust == 0 and badName == 0,
			#sp .. " parts, " .. nonPipe .. " not pipe, " .. nonRust .. " not rusty, " .. badName .. " badly named")
		check("scaffold sits over the SOUTH wing only: z 177.6..231 (+-3), y 30.5..51, x -274..-263", #sp > 0 and zlo.Z >= 174.6 and zhi.Z <= 234 and zlo.Y >= 30 and zhi.Y <= 51.5 and zlo.X >= -274.5 and zhi.X <= -262.5,
			#sp > 0 and string.format("x %s..%s y %s..%s z %s..%s", sx(zlo.X), sx(zhi.X), sx(zlo.Y), sx(zhi.Y), sx(zlo.Z), sx(zhi.Z)) or "no scaffold")
		local function panelZ(tag)
			local t = {}
			for _, p in ipairs(sp) do if p.Name:match("^ScaffoldP" .. tag) then table.insert(t, p) end end
			if #t == 0 then return nil end
			local a, b = union(t)
			return a.Z, b.Z, #t
		end
		local a1, b1, n1 = panelZ("1")
		local a2, b2, n2 = panelZ("2")
		check("two lattice panels side by side: P1 z 205.3..231, P2 z 177.6..203.8 (+-3), 20+ parts each", a1 ~= nil and a2 ~= nil and near(a1, 205.3, 3) and near(b1, 231, 3) and near(a2, 177.6, 3) and near(b2, 203.8, 3) and n1 >= 20 and n2 >= 20)
		check("scaffold carries NO SurfaceGui, BillboardGui, TextLabel, Decal or Texture and no gui is adorned to it", sc ~= nil and textual == 0, textual .. " found")
	end)

	------------------------------------------------------------------ sheds: gabled sheds, wet markets, Bagsakan
	pcallGroup("sheds", function()
		local spec = { A = { 196.7, 232.0 }, B = { 158.6, 190.2 }, C = { 115.0, 150.5 }, D = { 72.2, 107.4 } }
		local found = 0
		for letter, z in pairs(spec) do
			local u = units("^Shed" .. letter .. "$")[1]
			local lo, hi
			if u then lo, hi = ub(u); found += 1 end
			check("Shed" .. letter .. " exists: x -471.4..-415.6, z " .. z[1] .. ".." .. z[2] .. " (+-3), top y 16..23",
				u ~= nil and near(lo.X, -471.4, 3) and near(hi.X, -415.6, 3) and near(lo.Z, z[1], 3) and near(hi.Z, z[2], 3) and between(hi.Y, 16, 23),
				u and string.format("x %s..%s z %s..%s top %s", sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z), sx(hi.Y)) or "missing")
			if u then
				local slopes, clere, maxRoof = {}, {}, -1e9
				for _, p in ipairs(partsIn(u)) do
					if p.Name:match("^Shed" .. letter .. "Roof%d+$") then table.insert(slopes, p) maxRoof = math.max(maxRoof, select(2, wb(p)).Y) end
					if p.Name:match("^Shed" .. letter .. "Clerestory%d+$") then table.insert(clere, p) end
				end
				local redN = 0
				for _, p in ipairs(slopes) do if roofRed(p) then redN += 1 end end
				local clereOk = #clere >= 1
				for _, p in ipairs(clere) do
					local clo, chi = wb(p)
					if not (chi.Y >= maxRoof + 2 and clo.Z >= z[1] - 1 and chi.Z <= z[2] + 1) then clereOk = false end
				end
				check("Shed" .. letter .. " is gabled with a clerestory strip: 2+ red roof slopes (172,78,72), 1+ Clerestory top >= roof top + 2 inside the shed",
					#slopes >= 2 and redN == #slopes and clereOk and #named("^Shed" .. letter .. "Ridge$") >= 1, #slopes .. " slopes (" .. redN .. " red), " .. #clere .. " clerestory")
			end
		end
		-- BP1 plan and iso (audit 2026-10-29): wet market 1 has 28 stalls (2x3 + 2x3 over 2x4 + 2x4 round a plus-shaped aisle), wet market 2 has 35 (3x3 + 2x3 over 3x4 + 2x4);
		-- WetMarket2's stall field is z 115..150, not 107.8..158.6 (old text), so its bounds become z 112..153 (+-4 covers a canopy overhang)
		for name, z in pairs({ WetMarket1 = { 190.6, 231.6, 24 }, WetMarket2 = { 112, 153, 30 } }) do
			local u = units("^" .. name .. "$")[1]
			local lo, hi
			if u then lo, hi = ub(u) end
			local n = 0
			if u then for _, p in ipairs(partsIn(u)) do if p.Name:match("^Counter%d*$") then n += 1 end end end
			check(name .. " is an open stall grid: x -376..-312.3, z " .. z[1] .. ".." .. z[2] .. " (+-4), " .. z[3] .. "+ Counter stalls inside (BP1: 28 and 35 stalls)",
				u ~= nil and near(lo.X, -376, 4) and near(hi.X, -312.3, 4) and near(lo.Z, z[1], 4) and near(hi.Z, z[2], 4) and n >= z[3], u and (n .. " counters") or "missing")
		end
		local dg = units("^DryGoods$")[1]
		local dlo, dhi
		if dg then dlo, dhi = ub(dg) end
		check("DryGoods area: x -379.6..-311.2, z 159.6..189.5 (+-4)", dg ~= nil and near(dlo.X, -379.6, 4) and near(dhi.X, -311.2, 4) and near(dlo.Z, 159.6, 4) and near(dhi.Z, 189.5, 4))
		local ca = named("^CrossAisle%a*%d*$")
		local calo, cahi = union(ca)
		check("cross aisle canopy strip behind the arcade: x -311.2..-299.7 (+-3), z 71.4..249.3 (+-3)", #ca > 0 and near(calo.X, -311.2, 3) and near(cahi.X, -299.7, 3) and near(calo.Z, 71.4, 3) and near(cahi.Z, 249.3, 3))
		-- Bagsakan
		local bag = named("^Bagsakan%a+%d*$")
		local blo, bhi = union(bag)
		local broof, redB = named("^BagsakanRoof%d+$"), 0
		for _, p in ipairs(broof) do if roofRed(p) then redB += 1 end end
		-- BP1 iso (audit 2026-10-29): the Bagsakan pitch is very low and the ridge reads about 15.5, not 19 (old text), so the ridge becomes 16 (+-2.5)
		check("Bagsakan long shed: x -556..-506.3 (+-3), z 84..240.6 (+-3), ridge y 16 (+-2.5), 2+ red roof slopes",
			#bag > 0 and near(blo.X, -556, 3) and near(bhi.X, -506.3, 3) and near(blo.Z, 84, 3) and near(bhi.Z, 240.6, 3) and near(bhi.Y, 16, 2.5) and #broof >= 2 and redB == #broof,
			#bag > 0 and string.format("x %s..%s z %s..%s top %s", sx(blo.X), sx(bhi.X), sx(blo.Z), sx(bhi.Z), sx(bhi.Y)) or "missing")
		local bays, trucks = units("^TruckBay%d+$"), units("^Truck%d+$")
		local nN, nS, badBay, hasTruck = 0, 0, 0, 0
		for _, b in ipairs(bays) do
			local c = cen(b)
			local lo, hi = ub(b)
			if not (lo.X >= -508 and hi.X <= -485) then badBay += 1 end
			if c.Z <= 136 then nN += 1 elseif c.Z >= 188 then nS += 1 else badBay += 1 end
			for _, t in ipairs(trucks) do
				local tc = cen(t)
				if math.abs(tc.Z - c.Z) <= 6 and tc.X >= lo.X - 1 and tc.X <= hi.X + 1 then hasTruck += 1 break end
			end
		end
		check("6 truck bays (3 north z <= 136, 3 south z >= 188) at x -505..-488, each with a Truck on it", #bays >= 6 and nN >= 3 and nS >= 3 and badBay == 0 and hasTruck == #bays,
			#bays .. " bays (" .. nN .. "N/" .. nS .. "S), " .. badBay .. " off, " .. hasTruck .. " with trucks")
		local cnt = named("^Counter%d*$")
		local tarps, colours = named("^Canopy%d*$"), {}
		for _, p in ipairs(tarps) do colours[string.format("%d,%d,%d", rgb(p))] = true end
		local nc = 0
		for _ in pairs(colours) do nc += 1 end
		check("tarp canopies in 3+ colours (blue, green, orange)", #tarps >= 28 and nc >= 3, #tarps .. " canopies, " .. nc .. " colours")
		local eastCnt = 0
		for _, p in ipairs(cnt) do if p.Position.X > -232 then eastCnt += 1 end end
		check("28+ stall Counters in all, none east of x -232", #cnt >= 28 and eastCnt == 0, #cnt .. " counters, " .. eastCnt .. " east of x -232")
	end)

	------------------------------------------------------------------ yard: forecourt, Guide, InfoPanel, aisle, queues, side yards
	pcallGroup("yard", function()
		local ys, ysOk, ysd = single("YardSlab")
		check("YardSlab is ONE unique part (no container shares the name)", ysOk, ysd)
		if ys then
			local lo, hi = wb(ys)
			check("YardSlab: at most 0.31 thick, x -250.4..-229 (+-1.5), z 33.3..276.3 (+-2.5)", ys.Size.Y <= 0.31 and near(lo.X, -250.4, 1.5) and near(hi.X, -229, 1.5) and near(lo.Z, 33.3, 2.5) and near(hi.Z, 276.3, 2.5),
				string.format("thick %s x %s..%s z %s..%s", sx(ys.Size.Y), sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z)))
		end
		check("the sample-price board is kept (SampleBoard)", #named("^SampleBoard$") == 1)
		local guide, panel = site:FindFirstChild("Guide"), site:FindFirstChild("InfoPanel")
		local gp = guide and guide:GetPivot().Position
		check("Guide stands at (-241, 0, 160)", gp ~= nil and Vector3.new(gp.X + 241, 0, gp.Z - 160).Magnitude < 1, gp and tostring(gp) or "missing")
		local plo, phi
		if panel and panel:IsA("BasePart") then plo, phi = wb(panel) end
		check("InfoPanel is centred (-247, 5, 148), 12 x 8, facing east (thin along x)",
			plo ~= nil and near(panel.Position.X, -247, 1) and near(panel.Position.Y, 5, 1) and near(panel.Position.Z, 148, 1) and near(phi.Z - plo.Z, 12, 0.6) and near(phi.Y - plo.Y, 8, 0.6) and phi.X - plo.X <= 2.5,
			(panel and panel:IsA("BasePart")) and tostring(panel.Position) or "missing or not a BasePart")
		if guide then
			local bad = blockers(Vector3.new(gp.X, 5, gp.Z), Vector3.new(10, 10, 10)) -- y 0..10 whatever the height of the rig pivot
			check("keep-clear box x -246..-236, z 155..165, y 0..10 around the Guide holds no built part", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
			local bad2 = blockers(Vector3.new(-239.5, 7, 160), Vector3.new(21, 14, 24)) -- the old Guide box (HEAD: 24 x 14 x 24, x -312..-288, y 0..14, z 148..172), cut in x only to -250..-229 (the portico face is at -250.4)
			check("wider Guide box x -250..-229, z 148..172, y 0..14 holds no built part", #bad2 == 0, table.concat(bad2, ", ", 1, math.min(#bad2, 6)))
		end
		do
			local bad = blockers(Vector3.new(-239.2, 3.3, 160), Vector3.new(22.4, 5.4, 12))
			check("the aisle from the Road F mouth (x -250.4..-228, z 154..166, y 0..6) is open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
			local bad3 = blockers(Vector3.new(-241, 5, 148), Vector3.new(12, 8, 12))
			check("the InfoPanel's front (x -247..-235, z 142..154, 12 deep) is open", #bad3 == 0, table.concat(bad3, ", ", 1, math.min(#bad3, 6)))
		end
		do
			local hit = {}
			for _, p in ipairs(own) do
				if not isKept(p) then
					local lo, hi = wb(p)
					for _, k in ipairs({ guide, panel }) do
						if k then
							local klo, khi = ub(k)
							if hi.Y > 0.6 and lo.X < khi.X and hi.X > klo.X and lo.Y < khi.Y and hi.Y > klo.Y and lo.Z < khi.Z and hi.Z > klo.Z then table.insert(hit, p.Name .. "/" .. k.Name) end
						end
					end
				end
			end
			check("nothing built overlaps the Guide or the InfoPanel", #hit == 0, table.concat(hit, ", ", 1, math.min(#hit, 4)))
		end
		-- shoppers
		local function rigAt(role)
			local f = site:FindFirstChild("LocalNPCs")
			for _, r in ipairs(f and f:GetChildren() or {}) do
				if r:GetAttribute("Role") == role or r.Name == role then return r:FindFirstChild("HumanoidRootPart") end
			end
		end
		local s1, s2 = rigAt("ShopperBayong1"), rigAt("ShopperBayong2")
		check("ShopperBayong1 and ShopperBayong2 stand in the south side yard at about (-380, 255) and (-372, 258)",
			s1 ~= nil and s2 ~= nil and Vector3.new(s1.Position.X + 380, 0, s1.Position.Z - 255).Magnitude <= 3 and Vector3.new(s2.Position.X + 372, 0, s2.Position.Z - 258).Magnitude <= 3,
			(s1 and tostring(s1.Position) or "none") .. " / " .. (s2 and tostring(s2.Position) or "none"))
		-- tricycle queues
		local tri = named("^TricycleBody%d+$")
		local nQ, sQ, badTri = 0, 0, 0
		for _, t in ipairs(tri) do
			local p = t.Position
			if between(p.X, -237, -231) and between(p.Z, 100, 136) then nQ += 1 elseif between(p.X, -237, -231) and between(p.Z, 184, 220) then sQ += 1 else badTri += 1 end
		end
		check("8 tricycles queue at the apron (4 north z 100..136, 4 south z 184..220, x -237..-231) with 24+ wheels and 8+ roofs",
			#tri == 8 and nQ == 4 and sQ == 4 and badTri == 0 and #named("^TricycleWheel%d+$") >= 24 and #named("^TricycleRoof%d+$") >= 8, #tri .. " bodies (" .. nQ .. "N/" .. sQ .. "S), " .. #named("^TricycleWheel%d+$") .. " wheels")
		-- lean-tos
		local lean, badLean = named("^LeanRoof%d+$"), 0
		for _, p in ipairs(lean) do
			if not (tinCol(p) and between(p.Position.X, -265, -253) and (between(p.Position.Z, 70, 91) or between(p.Position.Z, 229, 250))) then badLean += 1 end
		end
		check("4 tin lean-to roofs on the ground frontage (rust or grey, x -265..-253, z 70..91 or 229..250, clear of the stair feet)", #lean == 4 and badLean == 0, #lean .. " roofs, " .. badLean .. " off")
		-- street stalls and side yards
		local st, badSt = units("^StreetStall%d+$"), 0
		for _, u in ipairs(st) do
			local c = cen(u)
			local okz = false
			for _, z in ipairs({ 244, 254, 264, 62, 52 }) do if near(c.Z, z, 3.5) then okz = true end end
			if not (between(c.X, -241, -235) and okz) then badSt += 1 end
		end
		local missingZ = {}
		for _, z in ipairs({ 244, 254, 264, 62, 52 }) do -- each of the five rows is taken by a stall (two stalls on one row do not pass)
			local taken = false
			for _, u in ipairs(st) do if near(cen(u).Z, z, 3.5) then taken = true end end
			if not taken then table.insert(missingZ, z) end
		end
		check("5 street stalls on the apron (x -241..-235), one on each of z 244, 254, 264, 62, 52", #st == 5 and badSt == 0 and #missingZ == 0, #st .. " stalls, " .. badSt .. " off, rows without a stall: " .. table.concat(missingZ, ","))
		local function yardOk(pat, z0, z1)
			local l, bad = units(pat), 0
			for _, u in ipairs(l) do local lo, hi = ub(u) if not (lo.X >= -473 and hi.X <= -309 and lo.Z >= z0 - 1 and hi.Z <= z1 + 1) then bad += 1 end end
			return #l >= 10 and bad == 0, #l .. " blocks, " .. bad .. " outside"
		end
		local okS2, dS2 = yardOk("^SideStallS%d+$", 232.4, 276.3)
		local okN2, dN2 = yardOk("^SideStallN%d+$", 33.3, 71.1)
		check("side yards: 10+ stall blocks in the south yard (z 232.4..276.3) and 10+ in the north yard (z 33.3..71.1), x -471.4..-311.2", okS2 and okN2, dS2 .. " / " .. dN2)
	end)

	------------------------------------------------------------------ block: corner block (BP2) and service block (BP1 plan, BP2 plan)
	-- CornerBlock (Structure/CornerBlock): BP2's louvred 4-storey block with the black-and-white checkerboard hoarding, long face parallel to the hall front, hoarding facing
	--   east. Parts: ONE CornerBlockBody; 12 Checker%d+ (3 wide x 4 high squares of 8 x 6 on the east face); 10+ Louvre%d+; 3+ BlockBand%d+; 2+ BlockDoor%d+ (8..9.6 tall).
	--   Bounds x -574..-540, z 244..324 (BP2 draws it about 100 long; the slot allows 80 without touching the Bagsakan), top 29..32. No text, no decals.
	-- ServiceBlock (Structure/ServiceBlock): BP1 plan z 33..60 plus annex z 60..85 at the Bagsakan's north-west, flat roofs. Parts: ONE ServiceBlockBody, ONE ServiceAnnex,
	--   4+ ServiceRoofEdge%d+, 2+ ServiceDoor%d+ (8..9.6 tall, README rule 7). BP1 reads the height at about 7; a door 8 tall needs a body of at least 9, so the top is 9..10.5.
	pcallGroup("block", function()
		local function noText(root)
			local n = 0
			for _, d in ipairs(root:GetDescendants()) do
				if d:IsA("SurfaceGui") or d:IsA("BillboardGui") or d:IsA("TextLabel") or d:IsA("Decal") or d:IsA("Texture") then n += 1 end
			end
			return n
		end
		local function touching(root, lo, hi) -- own parts outside root that come within 1 stud of the box
			local hit = {}
			for _, p in ipairs(own) do
				if not p:IsDescendantOf(root) then
					local a, b = wb(p)
					if a.X < hi.X + 1 and b.X > lo.X - 1 and a.Y < hi.Y + 1 and b.Y > lo.Y - 1 and a.Z < hi.Z + 1 and b.Z > lo.Z - 1 then table.insert(hit, p.Name) end
				end
			end
			return hit
		end
		local function tallDoors(pat)
			local l, bad = named(pat), 0
			for _, d in ipairs(l) do local lo, hi = wb(d) if not (between(hi.Y - lo.Y, 8, 9.6) and lo.Y <= 0.6) then bad += 1 end end
			return l, bad
		end
		-- corner block
		local cb = container("Structure/CornerBlock")
		local cbN = cb and #partsIn(cb) or 0
		check("Structure/CornerBlock exists and holds 40..120 parts (BP2 louvred block with the checkerboard hoarding)", cbN >= 40 and cbN <= 120, cb and tostring(cbN) or "missing")
		if cb then
			local clo, chi = ub(cb)
			check("CornerBlock bounds: x -574..-540 (+-2), z 244..324 (+-2), top y 29..32, nothing below y -0.5, inside the slot",
				near(clo.X, -574, 2) and near(chi.X, -540, 2) and near(clo.Z, 244, 2) and near(chi.Z, 324, 2) and between(chi.Y, 29, 32) and clo.Y >= -0.5 and clo.X >= -576 and chi.Z <= 325,
				string.format("x %s..%s y %s..%s z %s..%s", sx(clo.X), sx(chi.X), sx(clo.Y), sx(chi.Y), sx(clo.Z), sx(chi.Z)))
			local body, bodyOk, bodyD = single("CornerBlockBody")
			check("CornerBlockBody is ONE unique part: x -574..-540 (+-1.5), z 244..324 (+-2), top y 29..31.5", bodyOk and body ~= nil and (function()
				local lo, hi = wb(body)
				return near(lo.X, -574, 1.5) and near(hi.X, -540, 1.5) and near(lo.Z, 244, 2) and near(hi.Z, 324, 2) and between(hi.Y, 29, 31.5)
			end)(), bodyD)
			-- checkerboard hoarding on the east face
			local chk = named("^Checker%d+$")
			local badChk = 0
			for _, p in ipairs(chk) do
				local lo, hi = wb(p)
				if not (between(hi.X, -541, -538) and near(hi.Z - lo.Z, 8, 1) and near(hi.Y - lo.Y, 6, 1)) then badChk += 1 end
			end
			local klo, khi = union(chk)
			check("checkerboard hoarding: exactly 12 Checker squares of 8 x 6 on the east face (x -541..-538), covering z 272..296 (+-2) and y 3..27 (+-1)",
				#chk == 12 and badChk == 0 and near(klo.Z, 272, 2) and near(khi.Z, 296, 2) and near(klo.Y, 3, 1) and near(khi.Y, 27, 1),
				#chk .. " squares, " .. badChk .. " off" .. (#chk > 0 and string.format(", z %s..%s y %s..%s", sx(klo.Z), sx(khi.Z), sx(klo.Y), sx(khi.Y)) or ""))
			local flat, badAlt = 0, 0
			for i = 1, #chk do
				local ci = chk[i].Position
				for j = i + 1, #chk do
					local cj = chk[j].Position
					local dz, dy = math.abs(ci.Z - cj.Z), math.abs(ci.Y - cj.Y)
					if (near(dz, 8, 1) and dy < 1) or (near(dy, 6, 1) and dz < 1) then
						local bi, bj = chk[i].Color.R + chk[i].Color.G + chk[i].Color.B, chk[j].Color.R + chk[j].Color.G + chk[j].Color.B
						flat += 1
						if math.abs(bi - bj) < 1.0 then badAlt += 1 end -- channels are 0..1, so 1.0 is a third of the white-to-dark range
					end
				end
			end
			check("checkerboard alternates: every pair of neighbouring squares differs strongly in brightness (white against blue-grey), 17 neighbour pairs in a 3 x 4 grid",
				flat == 17 and badAlt == 0, flat .. " pairs, " .. badAlt .. " too alike")
			-- louvres on the north and south ends and beside the hoarding
			local lv = named("^Louvre%d+$")
			local lvN, lvS, lvE = 0, 0, 0
			for _, p in ipairs(lv) do
				local lo, hi = wb(p)
				local c = (lo + hi) / 2
				if c.Z <= 247 then lvN += 1 elseif c.Z >= 321 then lvS += 1 elseif hi.X >= -541.5 and (hi.Z <= 271 or lo.Z >= 297) then lvE += 1 end
			end
			check("louvres: 10+ Louvre parts, 3+ on the north end (z <= 247), 3+ on the south end (z >= 321) and 3+ on the east face beside the hoarding",
				#lv >= 10 and lvN >= 3 and lvS >= 3 and lvE >= 3, #lv .. " louvres: " .. lvN .. " north, " .. lvS .. " south, " .. lvE .. " east")
			local bands = named("^BlockBand%d+$")
			local bLo, bHi = 1e9, -1e9
			for _, p in ipairs(bands) do bLo, bHi = math.min(bLo, p.Position.Y), math.max(bHi, p.Position.Y) end
			check("storey bands: 3+ BlockBand parts whose heights spread over at least 7 studs (four storeys read as four)", #bands >= 3 and bHi - bLo >= 7, #bands .. " bands, spread " .. (#bands > 0 and sx(bHi - bLo) or "n/a"))
			local bd, badBd = tallDoors("^BlockDoor%d+$")
			check("corner block doors: 2+ BlockDoor parts on the ground, each 8..9.6 tall (human scale)", #bd >= 2 and badBd == 0, #bd .. " doors, " .. badBd .. " off")
			check("corner block carries no text, gui or decal (the street sign and ring logo of BP2 stay off)", noText(cb) == 0, noText(cb) .. " found")
			local hit = touching(cb, clo, chi)
			check("corner block stands clear of everything else (Bagsakan, side yards, props): nothing within 1 stud of it", #hit == 0, #hit .. ": " .. table.concat(hit, ", ", 1, math.min(#hit, 4)))
		end
		-- service block and annex
		local sb = container("Structure/ServiceBlock")
		local sbN = sb and #partsIn(sb) or 0
		check("Structure/ServiceBlock exists and holds 12..60 parts (BP1 plan block and annex at the Bagsakan's north-west)", sbN >= 12 and sbN <= 60, sb and tostring(sbN) or "missing")
		if sb then
			local sbody, sbOk, sbD = single("ServiceBlockBody")
			check("ServiceBlockBody is ONE unique part: x -552..-497 (+-2), z 33..60 (+-2), top y 9..10.5", sbOk and sbody ~= nil and (function()
				local lo, hi = wb(sbody)
				return near(lo.X, -552, 2) and near(hi.X, -497, 2) and near(lo.Z, 33, 2) and near(hi.Z, 60, 2) and between(hi.Y, 9, 10.5)
			end)(), sbD)
			local ann, annOk, annD = single("ServiceAnnex")
			check("ServiceAnnex is ONE unique part south of the block: x inside -553..-496, z 60..83 (+-2.5), top y 8..10.5, built against the block (z gap at most 1)", annOk and ann ~= nil and sbody ~= nil and (function()
				local lo, hi = wb(ann)
				local blo, bhi = wb(sbody)
				return lo.X >= -553 and hi.X <= -496 and near(lo.Z, 60, 2.5) and near(hi.Z, 83, 2.5) and between(hi.Y, 8, 10.5) and math.abs(lo.Z - bhi.Z) <= 1
			end)(), annD)
			local re = named("^ServiceRoofEdge%d+$")
			check("service block roof edge: 4+ ServiceRoofEdge parts (flat roof with a low parapet)", #re >= 4, tostring(#re))
			local sd, badSd = tallDoors("^ServiceDoor%d+$")
			check("service block doors: 2+ ServiceDoor parts on the ground, each 8..9.6 tall (human scale)", #sd >= 2 and badSd == 0, #sd .. " doors, " .. badSd .. " off")
			local slo, shi = ub(sb)
			check("service block bounds: x -553..-496, z 32..84 (nothing reaches the Bagsakan walls at z 84), nothing below y -0.5, top at most 10.5",
				slo.X >= -553 and shi.X <= -496 and slo.Z >= 32 and shi.Z <= 84 and slo.Y >= -0.5 and shi.Y <= 10.5,
				string.format("x %s..%s y %s..%s z %s..%s", sx(slo.X), sx(shi.X), sx(slo.Y), sx(shi.Y), sx(slo.Z), sx(shi.Z)))
			check("service block carries no text, gui or decal", noText(sb) == 0, noText(sb) .. " found")
			local sHit = touching(sb, slo, shi)
			check("service block stands clear of everything else (Bagsakan, truck lane, north side yard): nothing within 1 stud of it", #sHit == 0, #sHit .. ": " .. table.concat(sHit, ", ", 1, math.min(#sHit, 4)))
		end
	end)

	------------------------------------------------------------------ general: whole-site rules
	pcallGroup("general", function()
		local pv = site:GetPivot()
		check("site pivot is at the SiteData pos (-402, 0, 160), facing E", (pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(1, 0, 0)) > 0.999,
			string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
		for _, n in ipairs({ "Guide", "InfoPanel", "Structure", "Yard", "MarketStalls", "Baskets", "Produce", "PriceSigns", "VendorNPCs", "LocalNPCs" }) do
			check("direct child " .. n .. " exists", site:FindFirstChild(n) ~= nil)
		end
		local structureParts = 0
		for _, p in ipairs(site:FindFirstChild("Structure") and site.Structure:GetChildren() or {}) do if p:IsA("BasePart") then structureParts += 1 end end
		check("InfoPanel is one BasePart and Structure exists with no direct parts (grouping node)", site:FindFirstChild("InfoPanel") ~= nil and site.InfoPanel:IsA("BasePart") and site:FindFirstChild("Structure") ~= nil and structureParts == 0,
			structureParts .. " direct parts in Structure")
		for _, name in ipairs({ "MarketStalls", "Baskets", "Produce", "PriceSigns" }) do
			local c = site:FindFirstChild(name)
			check("prop " .. name .. " exists and holds parts", c ~= nil and #c:GetDescendants() > 0)
		end
		local vend, rigs = site:FindFirstChild("VendorNPCs"), 0
		for _, v in ipairs(vend and vend:GetChildren() or {}) do if v:FindFirstChildOfClass("Humanoid") then rigs += 1 end end
		check("VendorNPCs holds 6 to 9 vendors", rigs >= 6 and rigs <= 9, tostring(rigs))
		local boards, kamatis = named("^PriceBoard%d*$"), false
		for _, b in ipairs(boards) do
			for _, l in ipairs(b:GetDescendants()) do if l:IsA("TextLabel") and l.Text:upper():find("KAMATIS", 1, true) then kamatis = true end end
		end
		check("price boards: 28+ PriceBoard (numbered or not), one label reads KAMATIS", #boards >= 28 and kamatis, #boards .. " boards, KAMATIS " .. tostring(kamatis))
		local unanchored, outside, thin = {}, {}, {}
		for _, d in ipairs(own) do
			if not d.Anchored then table.insert(unanchored, d.Name) end
			local lo, hi = wb(d)
			if lo.X < SLOT.x0 - 0.05 or hi.X > SLOT.x1 + 0.05 or lo.Z < SLOT.z0 - 0.05 or hi.Z > SLOT.z1 + 0.05 then table.insert(outside, d.Name .. " " .. tostring(d.Position)) end
			if hi.Y - lo.Y <= 0.35 and lo.Y <= 0.3 and (lo.X < SLOT.x0 - 0.05 or hi.X > SLOT.x1 + 0.05 or lo.Z < SLOT.z0 - 0.05 or hi.Z > SLOT.z1 + 0.05) then table.insert(thin, d.Name) end
		end
		check("every non-rig part is anchored", #unanchored == 0, table.concat(unanchored, ", ", 1, math.min(#unanchored, 6)))
		check("every non-rig part is inside the slot (x -576..-228, z -5..325), rotated corners included, nothing east of x -228", #outside == 0, table.concat(outside, "; ", 1, math.min(#outside, 4)))
		check("thin ground parts (<= 0.35 thick, on the ground) lie inside the Concrete slot", #thin == 0, table.concat(thin, "; ", 1, math.min(#thin, 4)))
		-- real bounds of EVERY BasePart (rigs and the Guide included) against the roads, the way roads_check measures them
		local r = { x0 = 1e9, x1 = -1e9, z0 = 1e9, z1 = -1e9 }
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("BasePart") then
				local lo, hi = wb(d)
				r = { x0 = math.min(r.x0, lo.X), x1 = math.max(r.x1, hi.X), z0 = math.min(r.z0, lo.Z), z1 = math.max(r.z1, hi.Z) }
			end
		end
		check("real bounds (all parts, rigs and Guide included) reach x -560..-228 and keep 18 studs of x clear room for the road margin (max x + 10 percent of the x extent < -180)",
			r.x0 >= -576.05 and r.x1 <= -227.95 and r.x1 + 0.1 * (r.x1 - r.x0) < -180, string.format("x %s..%s z %s..%s", sx(r.x0), sx(r.x1), sx(r.z0), sx(r.z1)))
		local okRD, RoadData = pcall(function() return require(game.ReplicatedStorage.LipaShared.RoadData:Clone()) end)
		local hit = {}
		if okRD then
			local sl = { x0 = r.x0 - 0.1 * (r.x1 - r.x0), x1 = r.x1 + 0.1 * (r.x1 - r.x0), z0 = r.z0 - 0.1 * (r.z1 - r.z0), z1 = r.z1 + 0.1 * (r.z1 - r.z0) }
			for _, road in ipairs(RoadData.NEW_ROADS) do
				for i = 1, #road.pts - 1 do
					local a, b = road.pts[i], road.pts[i + 1]
					local h = road.w / 2 + 4
					local w = { x0 = math.min(a[1], b[1]) - h, x1 = math.max(a[1], b[1]) + h, z0 = math.min(a[2], b[2]) - h, z1 = math.max(a[2], b[2]) + h }
					if w.x0 < sl.x1 - 1e-6 and sl.x0 < w.x1 - 1e-6 and w.z0 < sl.z1 - 1e-6 and sl.z0 < w.z1 - 1e-6 then table.insert(hit, road.name .. " seg " .. i) end
				end
			end
		end
		check("margin rule: bounds +10 percent stay clear of every NEW_ROADS body (w/2+4), as roads_check measures", okRD and #hit == 0, okRD and table.concat(hit, ", ") or "RoadData did not load")
		local st0, y0 = site:FindFirstChild("Structure"), site:FindFirstChild("Yard") -- the structures: held to y -0.5; every other prop is held to the site-wide y -0.6 below
		local newWork = {}
		for _, p in ipairs(own) do
			if (st0 ~= nil and p:IsDescendantOf(st0)) or (y0 ~= nil and p:IsDescendantOf(y0)) then table.insert(newWork, p) end
		end
		local lo = union(newWork)
		check("nothing in the Structure or the Yard builds below the ground (lowest point at least -0.5)", #newWork > 0 and lo.Y >= -0.501, #newWork > 0 and sx(lo.Y) or "no Structure or Yard parts")
		local lowest, lowName = 1e9, "none"
		for _, p in ipairs(own) do -- the old TarpHeap had a corner at y -2.2; a dome, heap or ball may sink at most 0.6 into the ground
			local plo = wb(p)
			if plo.Y < lowest then lowest, lowName = plo.Y, p:GetFullName():sub(#site:GetFullName() + 2) end
		end
		check("no part anywhere in the site (rigs excluded) goes below y -0.6 (domes and heaps sink at most 0.6)", #own > 0 and lowest >= -0.601, sx(lowest) .. " at " .. lowName)
		check("part count (rigs excluded) is between 950 and 1800 (the old model had 960; raised from 1500 for the corner block, service block, yard and vehicles)", #own >= 950 and #own <= 1800, tostring(#own))
		local all = 0
		for _, d in ipairs(site:GetDescendants()) do if d:IsA("BasePart") then all += 1 end end
		check("site total (rigs included) is at most " .. CAP.total, all <= CAP.total, tostring(all))
		-- batch rule
		local st = site:FindFirstChild("Structure")
		local GROUPING = {} -- a table constructor with a nil key ({ [nil] = true }) is a runtime error, so fill it only when Structure exists
		if st then
			GROUPING[st] = true
			for _, n in ipairs({ "Hall", "Sheds" }) do GROUPING[st:FindFirstChild(n) or site] = true end
		end
		local big, groupParts = {}, {}
		for _, d in ipairs(site:GetDescendants()) do
			if (d:IsA("Folder") or d:IsA("Model")) and not isRig(d) and not d:FindFirstChildOfClass("Humanoid") and d ~= site and not isKept(d) and d.Name ~= "VendorNPCs" and d.Name ~= "LocalNPCs" then
				local n = 0
				for _, q in ipairs(d:GetDescendants()) do if q:IsA("BasePart") then n += 1 end end
				if GROUPING[d] then
					for _, q in ipairs(d:GetChildren()) do if q:IsA("BasePart") then table.insert(groupParts, d.Name) end end
				elseif n > CAP.part then
					table.insert(big, d.Name .. " " .. n)
				end
			end
		end
		check("batch rule: every Model/Folder holds at most 400 parts (grouping nodes hold none directly)", #big == 0 and #groupParts == 0, table.concat(big, "; ") .. " " .. table.concat(groupParts, ","))
		-- human scale
		local ctr, badC = named("^Counter%d*$"), 0
		for _, c in ipairs(ctr) do local _, hi = wb(c) if not between(hi.Y, 3.3, 3.8) then badC += 1 end end
		check("human scale: stall counters are 3.5 high (tops 3.3..3.8)", badC == 0, #ctr .. " counters, " .. badC .. " off")
		-- text
		local images, nonAscii, brandHits, longScaled = 0, {}, {}, {}
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("Decal") or d:IsA("Texture") or d:IsA("ImageLabel") or d:IsA("ImageButton") then images += 1 end
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				local t = d.Text
				for i = 1, #t do if t:byte(i) > 127 then table.insert(nonAscii, d:GetFullName()) break end end
				for _, b in ipairs(BRANDS) do if t:upper():find(b, 1, true) then table.insert(brandHits, t) end end
				local longest = 0
				for line in (t .. "\n"):gmatch("(.-)\n") do longest = math.max(longest, #line) end -- the longest LINE: a two-line price board of 7 + 7 characters is short
				-- whole site (README rule 7); only the shared Guide and InfoPanel widgets are exempt (the InfoPanel label is TextScaled, made by builders/placeholders); a Frame does not exempt
				if d.TextScaled and longest > 14 and not isKept(d) then
					local owner = d:FindFirstAncestorWhichIsA("BasePart")
					table.insert(longScaled, (owner and owner.Name or d.Parent.Name) .. ":" .. t:sub(1, 16))
				end
			end
			for _, b in ipairs(BRANDS) do if d.Name:upper():find(b, 1, true) then table.insert(brandHits, d.Name) end end
		end
		check("zero image instances (signs are text only, no logos)", images == 0, tostring(images))
		check("all SurfaceGui and label text is ASCII only", #nonAscii == 0, table.concat(nonAscii, "; ", 1, math.min(#nonAscii, 3)))
		check("no brand names or logos (pharmacy, cigarette) in any text or part name", #brandHits == 0, table.concat(brandHits, "; ", 1, math.min(#brandHits, 3)))
		check("no TextScaled label with a line over 14 characters anywhere in the site, except the shared Guide and InfoPanel (long labels use a fixed TextSize)", #longScaled == 0, table.concat(longScaled, "; ", 1, math.min(#longScaled, 3)))
	end)

	return HttpService:JSONEncode(results)
end

-- Like the other stored checks this returns the JSON string when required. A builder agent runs one group with shared.site02_only = "hall" (sheds, yard, general) set first.
return run({ only = shared.site02_only })
