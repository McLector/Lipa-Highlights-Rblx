-- site02_check: the fidelity spec for Site 02 (Candido B. Lopez Memorial Public Market), REBUILT strictly from PublicMarketBP1.jpg (Slice 4, 2026-10-29). Written BEFORE the build.
-- Studio copy: ServerStorage.Checks.site02_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site02_check:Clone())      -- returns JSON {passed, failed, failures}
-- Groups (set shared.site02_only = "hall" | "sheds" | "yard" | "bands" | "crowd" | "general" first to run one; run_all leaves it nil and runs all). Each group tests only its own parts.
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
local CAP = { part = 400, total = 2550 } -- total raised 2000 to 2100 for the street traffic (R5e, owner-authorised 2026-10-30, logged in briefs/site02.md); raised 2100 to 2550 for the band traffic and the crowd, R6a and R6b, owner-authorised 2026-10-30, logged in briefs/site02.md

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
		-- lean-tos: BP2 iso (bp2_iso_leantos_left.png) draws big red mono-pitch roofs along the street edge of the north wing; 3 fit the model
		local lean, badLean, leanN, leanW = named("^LeanRoof%d+$"), 0, 0, 0
		for _, p in ipairs(lean) do
			local lo, hi = wb(p)
			local c = (lo + hi) / 2
			local dx, dz = hi.X - lo.X, hi.Z - lo.Z
			local long, deep = math.max(dx, dz), math.min(dx, dz)
			local siteN = between(c.X, -312, -250) and between(c.Z, 52, 72) -- the strip north of the hall end wall
			local siteW = between(c.X, -264, -248) and between(c.Z, 70, 90) -- the front of the north wing, between the end wall and the north stair foot
			if siteN then leanN += 1 elseif siteW then leanW += 1 end
			if not (roofRed(p) and (siteN or siteW) and between(long, 14, 30) and between(deep, 9, 14.5) and between(lo.Y, 7.5, 9.5) and between(hi.Y, 11.5, 13.3)) then badLean += 1 end
		end
		check("3 red lean-to roofs (BP2: mono-pitch, 14..30 long, 9..14.5 deep, eave y 8..9, high edge y 12..13): 2 on the strip north of the hall end (x -312..-250, z 52..72) and 1 in front of the north wing (x -264..-248, z 70..90)",
			#lean == 3 and badLean == 0 and leanN == 2 and leanW == 1, #lean .. " roofs, " .. badLean .. " off, " .. leanN .. " north strip, " .. leanW .. " wing front")
		check("lean-to posts: 8+ LeanPost parts, each 7.5..9.5 tall and standing on the ground", (function()
			local posts, bad = named("^LeanPost%d+$"), 0
			for _, p in ipairs(posts) do local lo, hi = wb(p) if not (between(hi.Y - lo.Y, 7.5, 9.5) and lo.Y <= 0.6) then bad += 1 end end
			return #posts >= 8 and bad == 0
		end)(), #named("^LeanPost%d+$") .. " posts")
		do
			local stairs, hitStair = {}, {}
			for _, p in ipairs(own) do if p.Name:match("^Step[NS]%d+$") or p.Name:match("^StairLanding[NS]$") then table.insert(stairs, p) end end
			for _, r in ipairs(lean) do
				local a, b = wb(r)
				for _, s in ipairs(stairs) do
					local c, d = wb(s)
					if a.X < d.X + 1 and b.X > c.X - 1 and a.Y < d.Y + 1 and b.Y > c.Y - 1 and a.Z < d.Z + 1 and b.Z > c.Z - 1 then table.insert(hitStair, r.Name .. "/" .. s.Name) end
				end
			end
			check("lean-to roofs stand clear of the stair feet (3 roofs, nothing within 1 stud of a step or landing)", #lean == 3 and #stairs > 0 and #hitStair == 0, #hitStair .. ": " .. table.concat(hitStair, ", ", 1, math.min(#hitStair, 4)))
		end
		-- street vendors: BP2 draws dense umbrella and tent clusters at the hall's front corners (about 10..12 tents)
		local st, nN, nS, badSt, overlapSt = units("^StreetStall%d+$"), 0, 0, 0, 0
		for i, u in ipairs(st) do
			local lo, hi = ub(u)
			local c = (lo + hi) / 2
			if between(c.X, -248, -231) and between(c.Z, 36, 60) then nN += 1 elseif between(c.X, -248, -231) and between(c.Z, 250, 274) then nS += 1 else badSt += 1 end
			if not (between(hi.Y, 6.5, 11) and lo.Y <= 0.6 and #partsIn(u) >= 3) then badSt += 1 end
			for j = i + 1, #st do
				local a, b = ub(st[j])
				if lo.X < b.X - 0.2 and hi.X > a.X + 0.2 and lo.Z < b.Z - 0.2 and hi.Z > a.Z + 0.2 then overlapSt += 1 end
			end
		end
		check("10..12 street stalls (BP2 vendors) in two clusters: 4+ in the north cluster (x -248..-231, z 36..60) and 4+ in the south cluster (z 250..274), each on the ground, 6.5..11 tall, 3+ parts, none elsewhere, no two overlapping",
			#st >= 10 and #st <= 12 and nN >= 4 and nS >= 4 and badSt == 0 and overlapSt == 0, #st .. " stalls (" .. nN .. "N/" .. nS .. "S), " .. badSt .. " off, " .. overlapSt .. " overlapping pairs")
		-- lamp posts (BP2 iso: 5..6 thin posts with a lamp head along the kerb and beside the stairs)
		do
			local posts, heads, badLamp = named("^LampPost%d+$"), named("^LampHead%d+$"), 0
			for _, p in ipairs(posts) do
				local lo, hi = wb(p)
				local c = (lo + hi) / 2
				local headed = false
				for _, h in ipairs(heads) do
					local a, b = wb(h)
					if math.abs((a.X + b.X) / 2 - c.X) <= 1 and math.abs((a.Z + b.Z) / 2 - c.Z) <= 1 and b.Y >= hi.Y - 0.5 and a.Y <= hi.Y + 1 then headed = true end
				end
				if not (between(hi.Y - lo.Y, 8, 14) and lo.Y <= 0.6 and between(c.X, -250.4, -229) and not between(c.Z, 148, 172) and headed) then badLamp += 1 end
			end
			check("6..8 lamp posts, each 8..14 tall on the ground on the apron (x -250.4..-229), outside the Guide band (z 148..172), each with a LampHead on top; as many heads as posts",
				#posts >= 6 and #posts <= 8 and #heads == #posts and badLamp == 0, #posts .. " posts, " .. #heads .. " heads, " .. badLamp .. " off")
		end
		local function yardOk(pat, z0, z1)
			local l, bad = units(pat), 0
			for _, u in ipairs(l) do local lo, hi = ub(u) if not (lo.X >= -473 and hi.X <= -309 and lo.Z >= z0 - 1 and hi.Z <= z1 + 1) then bad += 1 end end
			return #l >= 10 and bad == 0, #l .. " blocks, " .. bad .. " outside"
		end
		local okS2, dS2 = yardOk("^SideStallS%d+$", 232.4, 276.3)
		local okN2, dN2 = yardOk("^SideStallN%d+$", 33.3, 71.1)
		check("side yards: 10+ stall blocks in the south yard (z 232.4..276.3) and 10+ in the north yard (z 33.3..71.1), x -471.4..-311.2", okS2 and okN2, dS2 .. " / " .. dN2)
		-- R5b guard rails (BP1 iso_northyard and iso_shedsA, BP2 iso_vendors_tricycles): the side booths are canopied counter stalls, the north yard has its low awning on the
		--   shed wall, vendors stand at counters, price boards stand at counters, goods lie on counters, the sample board carries fixed-size text.
		local function gapXZ(alo, ahi, blo, bhi)
			local dx = math.max(0, alo.X - bhi.X, blo.X - ahi.X)
			local dz = math.max(0, alo.Z - bhi.Z, blo.Z - ahi.Z)
			return math.sqrt(dx * dx + dz * dz)
		end
		local counterBoxes = {} -- Counter parts (side booths, wet markets) and the street stalls' counters (the yard names them Stall<i>Table)
		for _, p in ipairs(own) do
			if p.Name:match("^Counter%d*$") or p.Name:match("^Stall%d+Table$") then
				local clo, chi = wb(p)
				table.insert(counterBoxes, { clo, chi })
			end
		end
		local function nearCounter(lo, hi, d)
			for _, c in ipairs(counterBoxes) do if gapXZ(lo, hi, c[1], c[2]) <= d then return true end end
			return false
		end
		do
			local sideUnits, badSide = units("^SideStallN%d+$"), 0
			for _, u in ipairs(units("^SideStallS%d+$")) do table.insert(sideUnits, u) end
			for _, u in ipairs(sideUnits) do
				local ps = partsIn(u)
				local lo, hi = ub(u)
				local hasCanopy, hasCounter = false, false
				for _, p in ipairs(ps) do
					if p.Name:match("^SideCanopy%d*$") then hasCanopy = true end
					if p.Name:match("^Counter%d*$") then hasCounter = true end
				end
				if not (#ps >= 3 and hasCanopy and hasCounter and between(hi.Y, 7, 11) and lo.Y <= 0.6) then badSide += 1 end
			end
			check("side booths: 21 units (11 north, 10 south), each on the ground, 7..11 tall, 3+ parts with a Counter and a SideCanopy (BP1 pyramid-roof booths)",
				#sideUnits == 21 and badSide == 0, #sideUnits .. " units, " .. badSide .. " off")
		end
		do
			-- R5d (BP1 iso_northyard and iso_shedsA): the canopy is one pyramid, not stacked plates. Rays straight down onto each booth (Include filter on that booth only), any part class.
			--   Rise = hit height above the pole tops. Apex (one ray per quarter, 0.25 off the seams) 1.2+, eaves and corners (0.4 inside the edge) 0..0.6, diagonal mid-points 0.6..1.3.
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Include
			local HX, HZ = 4, 3.5 -- the 8 x 7 canopy base
			local booths, nBad, worst = units("^SideStallN%d+$"), 0, ""
			for _, u in ipairs(units("^SideStallS%d+$")) do table.insert(booths, u) end
			for _, u in ipairs(booths) do
				local poles, roofs, px, pz, top = 0, 0, 0, 0, 0
				for _, p in ipairs(partsIn(u)) do
					if p.Name:match("^SidePole%d+$") then
						local _, phi = wb(p)
						poles += 1
						px += p.Position.X
						pz += p.Position.Z
						top = math.max(top, phi.Y)
					elseif p.Name:match("^SideCanopy%d+$") then
						roofs += 1
					end
				end
				local why
				if poles ~= 4 or roofs < 4 then
					why = poles .. " poles, " .. roofs .. " SideCanopy parts (want 4 and 4+)"
				else
					local cx, cz = px / 4, pz / 4
					rp.FilterDescendantsInstances = { u }
					local function probe(label, dx, dz, lo, hi)
						if why then return end
						local hit = workspace:Raycast(Vector3.new(cx + dx, top + 30, cz + dz), Vector3.new(0, -60, 0), rp)
						local rise = hit and hit.Position.Y - top
						if not between(rise, lo, hi) then why = label .. " rise " .. (rise and sx(rise) or "no hit") .. " (want " .. lo .. ".." .. hi .. ")" end
					end
					for _, a in ipairs({ -1, 1 }) do
						for _, b in ipairs({ -1, 1 }) do
							probe("apex", a * 0.25, b * 0.25, 1.2, 4)
							probe("corner", a * (HX - 0.4), b * (HZ - 0.4), 0, 0.6)
							probe("diagonal", a * HX / 2, b * HZ / 2, 0.6, 1.3)
						end
						probe("x edge", a * (HX - 0.4), 0.25, 0, 0.6)
						probe("z edge", 0.25, a * (HZ - 0.4), 0, 0.6)
					end
				end
				if why then
					nBad += 1
					if worst == "" then worst = u.Name .. ": " .. why end
				end
			end
			check("side booths (BP1 iso_northyard, iso_shedsA): each of the 21 canopies is a pyramid - 4 SideCanopy parts, apex 1.2+ over the pole tops, eaves and corners within 0.6, diagonals 0.6..1.3 (rays down, any part class)",
				#booths == 21 and nBad == 0, #booths .. " booths, " .. nBad .. " off" .. (worst ~= "" and (", first " .. worst) or ""))
		end
		do
			local aw, slab, counters = named("^SideAwningN%d+$"), false, 0
			for _, p in ipairs(aw) do
				local lo, hi = wb(p)
				if hi.X - lo.X >= 100 and between(hi.Y, 7.2, 8.2) and lo.Z >= 62 and hi.Z <= 71.1 then slab = true end
			end
			for _, c in ipairs(counterBoxes) do
				local cx, cz = (c[1].X + c[2].X) / 2, (c[1].Z + c[2].Z) / 2
				if between(cx, -460, -310) and between(cz, 63, 71) then counters += 1 end
			end
			check("north yard awning (BP1 iso_northyard): a long low slab (100+ long, top y 7.2..8.2, z 62..71.1) on posts (7+ SideAwningN parts) over 11 counters",
				#aw >= 7 and slab and counters >= 11, #aw .. " parts, slab " .. tostring(slab) .. ", " .. counters .. " counters under it")
		end
		do
			local vf, nV, badV = site:FindFirstChild("VendorNPCs"), 0, {}
			for _, r in ipairs(vf and vf:GetChildren() or {}) do
				local h = r:FindFirstChild("HumanoidRootPart")
				if h then
					nV += 1
					local p = h.Position
					local pt = Vector3.new(p.X, 0, p.Z)
					local inBox = (between(p.X, -250, -229) and between(p.Z, 148, 172)) or (between(p.X, -250.4, -228) and between(p.Z, 154, 166)) or (between(p.X, -247, -235) and between(p.Z, 142, 154))
					local inside = #blockers(Vector3.new(p.X, 3, p.Z), Vector3.new(1.5, 4, 1.5)) > 0
					if not (between(p.Y, 2, 4.5) and nearCounter(pt, pt, 2.5) and not inBox and not inside) then table.insert(badV, r.Name) end
				end
			end
			check("vendors (6..9 rigs) stand on the ground within 2.5 studs of a counter, outside the Guide, aisle and InfoPanel boxes and not inside any part",
				nV >= 6 and nV <= 9 and #badV == 0, nV .. " rigs, off: " .. table.concat(badV, ", "))
		end
		do
			local bd, badB, badLab = named("^PriceBoard%d*$"), 0, 0
			for _, b in ipairs(bd) do
				local lo, hi = wb(b)
				if not nearCounter(lo, hi, 3) then badB += 1 end
				for _, l in ipairs(b:GetDescendants()) do if l:IsA("TextLabel") and l.TextScaled then badLab += 1 end end
			end
			check("price boards: 28+, each within 3 studs of a counter, every label a fixed TextSize (TextScaled off)", #bd >= 28 and badB == 0 and badLab == 0,
				#bd .. " boards, " .. badB .. " away from a counter, " .. badLab .. " scaled labels")
		end
		do
			local sb, lab = named("^SampleBoard$")[1], nil
			for _, l in ipairs(sb and sb:GetDescendants() or {}) do if l:IsA("TextLabel") then lab = l end end
			local ok = false
			if sb and lab then
				local lo, hi = wb(sb)
				local t = lab.Text:upper()
				ok = (not lab.TextScaled) and t:find("SAMPLE PRICES", 1, true) ~= nil and t:find("ILLUSTRATION", 1, true) ~= nil and hi.X <= -227.95
					and not (hi.X > -250 and lo.X < -229 and hi.Z > 148 and lo.Z < 172) -- clear of the wide Guide box
			end
			check("SampleBoard reads SAMPLE PRICES - FOR ILLUSTRATION in a fixed TextSize, inside the slot and clear of the Guide box", ok, sb and (lab and lab.Text or "no label") or "missing")
		end
		do
			local function goods(folderName, minParts, frac)
				local f, n, onC = site:FindFirstChild(folderName), 0, 0
				for _, d in ipairs(f and f:GetDescendants() or {}) do
					if d:IsA("BasePart") then
						n += 1
						local lo, hi = wb(d)
						if nearCounter(lo, hi, 4) then onC += 1 end
					end
				end
				return n >= minParts and onC >= frac * n, folderName .. " " .. n .. " parts, " .. onC .. " near a counter"
			end
			local okP, dP = goods("Produce", 40, 0.8)
			local okB, dB = goods("Baskets", 20, 0.8)
			local okM, dM = goods("MarketStalls", 15, 0)
			check("goods are visible and lie on counters: Produce 40+ parts and Baskets 20+ parts, 80 percent of them within 4 studs of a counter; MarketStalls 15+ parts", okP and okB and okM, dP .. " / " .. dB .. " / " .. dM)
		end
		-- R5c (BP1 iso_stairN and iso_northyard: jeepney and van sized vehicles beside both stair feet and in both side yards; BP2 bp2_iso_vendors_tricycles: a kerb row of boxy van forms).
		--   The 8 tricycles above stay (BP2 labels the queue); these are the jeepneys and vans. Human scale: a jeepney or van is 9..14 long, 5..7.5 wide, 5..8 tall.
		do
			local vs, badV, nStairN, nStairS, nYardN, nYardS, hit = units("^ParkedVehicle%d+$"), 0, 0, 0, 0, 0, {}
			local aisleBoxes = { { -250, -229, 148, 172 }, { -250.4, -228, 154, 166 }, { -247, -235, 142, 154 } }
			for i, u in ipairs(vs) do
				local lo, hi = ub(u)
				local c = (lo + hi) / 2
				local dx, dz, dy = hi.X - lo.X, hi.Z - lo.Z, hi.Y - lo.Y
				local long, wide = math.max(dx, dz), math.min(dx, dz)
				local kind = u:GetAttribute("Kind")
				local inBox = false
				for _, bx in ipairs(aisleBoxes) do if lo.X < bx[2] and hi.X > bx[1] and lo.Z < bx[4] and hi.Z > bx[3] then inBox = true end end
				if not ((kind == "Jeepney" or kind == "Van") and #partsIn(u) >= 4 and #partsIn(u) <= 10 and between(long, 9, 14) and between(wide, 5, 7.5) and between(dy, 5, 8) and lo.Y <= 0.6 and not inBox) then badV += 1 end
				if between(c.X, -240, -228) and between(c.Z, 60, 98) then nStairN += 1
				elseif between(c.X, -240, -228) and between(c.Z, 222, 258) then nStairS += 1
				elseif between(c.X, -470, -310) and between(c.Z, 33.3, 72) then nYardN += 1
				elseif between(c.X, -470, -310) and between(c.Z, 232, 277) then nYardS += 1 end
				for j = i + 1, #vs do
					local a, b = ub(vs[j])
					if lo.X < b.X - 0.2 and hi.X > a.X + 0.2 and lo.Z < b.Z - 0.2 and hi.Z > a.Z + 0.2 then table.insert(hit, u.Name .. "/" .. vs[j].Name) end
				end
				for _, p in ipairs(own) do -- nothing else stands where a vehicle stands (the apron slab and other thin ground parts are fine)
					if not p:IsDescendantOf(u) and not isKept(p) then
						local a, b = wb(p)
						if b.Y > 0.6 and lo.X < b.X - 0.1 and hi.X > a.X + 0.1 and lo.Y < b.Y - 0.1 and hi.Y > a.Y + 0.1 and lo.Z < b.Z - 0.1 and hi.Z > a.Z + 0.1 then table.insert(hit, u.Name .. "/" .. p.Name) end
					end
				end
			end
			check("parked jeepneys and vans: 11 ParkedVehicle Models (Kind Jeepney or Van, 4..10 parts, 9..14 long, 5..7.5 wide, 5..8 tall, on the ground, out of the Guide, aisle and InfoPanel boxes): 2+ at each stair foot, 4+ in the north yard, 2+ in the south yard",
				#vs == 11 and badV == 0 and nStairN >= 2 and nStairS >= 2 and nYardN >= 4 and nYardS >= 2,
				#vs .. " vehicles, " .. badV .. " off; stairs " .. nStairN .. "N/" .. nStairS .. "S, yards " .. nYardN .. "N/" .. nYardS .. "S")
			check("parked vehicles overlap no other vehicle and no other built part", #vs > 0 and #hit == 0, #hit .. ": " .. table.concat(hit, ", ", 1, math.min(#hit, 4)))
		end
		-- R5e (owner request 2026-10-30, a busier street): StreetTricycle, Motorbike and StreetJeepney Models. New names, so the R5c counts above (8 TricycleBody, 11 ParkedVehicle) stay exact.
		--   Tricycles and jeepneys follow BP2 bp2_iso_vendors_tricycles and BP1 iso_stairN; motorbikes are NOT drawn in either blueprint (a creative addition the owner asked for).
		--   Each stands on the apron (x -250.4..-229) or in a side yard, outside the apron band z 140..180 that holds the Guide, the aisle and the InfoPanel and keeps the walk to the Guide open.
		do
			local KINDS = {
				{ pat = "^StreetTricycle%d+$", kind = "Tricycle", n = 8, parts = 5, long = { 7.5, 9 }, wide = { 4.4, 5.8 }, tall = { 5.5, 7.2 } },
				{ pat = "^Motorbike%d+$", kind = "Motorbike", n = 24, parts = 4, long = { 4, 5.8 }, wide = { 0.5, 2.2 }, tall = { 2.5, 4 } },
				{ pat = "^StreetJeepney%d+$", kind = "Jeepney", n = 3, parts = 8, long = { 9, 14 }, wide = { 5, 7.5 }, tall = { 5, 8 } },
			}
			local rigParts = {}
			for _, d in ipairs(site:GetDescendants()) do
				if d:IsA("BasePart") and isRig(d) then table.insert(rigParts, d) end
			end
			local found, badShape, badClash, firstShape, firstClash, nApronMB, nYardMB = {}, 0, 0, "", "", 0, 0
			for _, K in ipairs(KINDS) do
				local list = units(K.pat)
				table.insert(found, #list .. " " .. K.kind)
				if #list ~= K.n then
					badShape += 1
					if firstShape == "" then firstShape = K.kind .. " count " .. #list .. " (want " .. K.n .. ")" end
				end
				for _, u in ipairs(list) do
					local lo, hi = ub(u)
					local dx, dz, dy = hi.X - lo.X, hi.Z - lo.Z, hi.Y - lo.Y
					local long, wide = math.max(dx, dz), math.min(dx, dz)
					local onApron = lo.X >= -250.6 and hi.X <= -228.8 and lo.Z >= 33.3 and hi.Z <= 277
					local inYard = lo.X >= -473 and hi.X <= -309 and ((lo.Z >= 32.3 and hi.Z <= 72.1) or (lo.Z >= 231.4 and hi.Z <= 277.3))
					local shape
					if u:GetAttribute("Kind") ~= K.kind then shape = "Kind attribute"
					elseif #partsIn(u) ~= K.parts then shape = #partsIn(u) .. " parts (want " .. K.parts .. ")"
					elseif not (between(long, K.long[1], K.long[2]) and between(wide, K.wide[1], K.wide[2]) and between(dy, K.tall[1], K.tall[2])) then shape = string.format("size %.1f x %.1f x %.1f", long, wide, dy)
					elseif lo.Y > 0.6 or lo.Y < -0.1 then shape = "not on the ground (y " .. sx(lo.Y) .. ")"
					elseif not (onApron or inYard) then shape = "outside the apron and the side yards"
					elseif onApron and lo.Z < 180 and hi.Z > 140 then shape = "in the Guide band z 140..180"
					end
					if shape then
						badShape += 1
						if firstShape == "" then firstShape = u.Name .. ": " .. shape end
					else
						if K.kind == "Motorbike" then
							if onApron then nApronMB += 1 elseif inYard then nYardMB += 1 end
						end
						local clash
						for _, p in ipairs(own) do -- nothing else stands where a vehicle stands (the apron slab and other thin ground parts are fine)
							if not p:IsDescendantOf(u) and not isKept(p) then
								local a, b = wb(p)
								if b.Y > 0.6 and lo.X < b.X - 0.1 and hi.X > a.X + 0.1 and lo.Y < b.Y - 0.1 and hi.Y > a.Y + 0.1 and lo.Z < b.Z - 0.1 and hi.Z > a.Z + 0.1 then clash = "overlaps " .. p:GetFullName():sub(#site:GetFullName() + 2) break end
							end
						end
						if not clash then
							for _, p in ipairs(rigParts) do -- a figure may not stand inside or touch a vehicle (0.5 clear)
								local a, b = wb(p)
								if lo.X < b.X + 0.5 and hi.X > a.X - 0.5 and lo.Z < b.Z + 0.5 and hi.Z > a.Z - 0.5 and lo.Y < b.Y and hi.Y > a.Y then clash = "touches a figure (" .. p.Name .. ")" break end
							end
						end
						if clash then
							badClash += 1
							if firstClash == "" then firstClash = u.Name .. " " .. clash end
						end
					end
				end
			end
			check("street traffic (R5e): exactly 8 StreetTricycle (5 parts), 24 Motorbike (4 parts) and 3 StreetJeepney (8 parts) Models with the right Kind, size, on the ground, on the apron or in a side yard, out of the Guide band z 140..180",
				badShape == 0, table.concat(found, ", ") .. "; " .. badShape .. " off" .. (firstShape ~= "" and (", first: " .. firstShape) or ""))
			check("street traffic overlaps no other vehicle, no other built part and no figure", #found == 3 and badShape == 0 and badClash == 0, badClash .. " clash" .. (firstClash ~= "" and (", first: " .. firstClash) or ""))
			check("street traffic fills the kerbs: 8+ motorbikes along the apron and 6+ in the side yards", nApronMB >= 8 and nYardMB >= 6, nApronMB .. " on the apron, " .. nYardMB .. " in the yards")
		end
	end)

	------------------------------------------------------------------ bands: R6a, band traffic in the north and south bands (spec: scratch/site02/r6a-positions.md)
	-- BandTraffic (Folder or Model, direct child of the site, no Humanoid) holds, per band (NORTH z -5..31 x -576..-228, SOUTH z 277..325 x -530..-228):
	--   6 BandJeepney (Kind Jeepney, 8 parts), 4 BandTricycle (Kind Tricycle, 5 parts), 6 BandMotorbike (Kind Motorbike, 4 parts): Models, direct children, numbered 1..12 / 1..8 / 1..12;
	--   6 UtilityPole parts (20..28 tall, on the ground) with one PoleArm and one PoleLamp each (within 6 studs of the pole), and 10 PoleWire parts (thin, above y 14, 40..60 long along x,
	--   ends on the axes of two different poles of the same band). 240 parts in all (184 vehicle + 36 pole + 20 wire), all anchored. The size ranges and the ground rule are the R5e ones.
	pcallGroup("bands", function()
		local bt = site:FindFirstChild("BandTraffic")
		local BANDS = {
			N = { label = "north", x0 = -576, x1 = -228, z0 = -5, z1 = 31 },
			S = { label = "south", x0 = -530, x1 = -228, z0 = 277, z1 = 325 }, -- x -530 keeps clear of the corner block (x <= -539); z 277 keeps clear of STri3 and SJ3 (end z 276.6)
		}
		local function bandOf(cz) return cz < 150 and "N" or "S" end
		local function inBT(inst) return bt ~= nil and inst:IsDescendantOf(bt) end
		local function btNamed(pat)
			local t = {}
			for _, p in ipairs(named(pat)) do if inBT(p) then table.insert(t, p) end end
			return t
		end
		local function btUnits(pat) -- Models that are DIRECT children of BandTraffic
			local t = {}
			for _, u in ipairs(units(pat)) do if bt ~= nil and u.Parent == bt then table.insert(t, u) end end
			return t
		end
		local function numbered(list, n) -- exactly n items, names end in 1..n, each number once
			local seen, ok = {}, #list == n
			for _, x in ipairs(list) do
				local k = tonumber(x.Name:match("%d+$"))
				if k == nil or k < 1 or k > n or seen[k] then ok = false else seen[k] = true end
			end
			return ok
		end
		local function onGround(lo) return lo.Y >= -0.1 and lo.Y <= 0.6 end -- the R5e rule
		local function poleFamily(p)
			return inBT(p) and (p.Name:match("^UtilityPole%d+$") or p.Name:match("^PoleArm%d+$") or p.Name:match("^PoleLamp%d+$") or p.Name:match("^PoleWire%d+$")) ~= nil
		end
		local function clashOf(inst, skip) -- first other built part that inst overlaps (the R5e test), or nil
			local lo, hi = ub(inst)
			for _, p in ipairs(own) do
				if p ~= inst and not p:IsDescendantOf(inst) and not isKept(p) and not (skip and skip(p)) then
					local a, b = wb(p)
					if b.Y > 0.6 and lo.X < b.X - 0.1 and hi.X > a.X + 0.1 and lo.Y < b.Y - 0.1 and hi.Y > a.Y + 0.1 and lo.Z < b.Z - 0.1 and hi.Z > a.Z + 0.1 then
						return p:GetFullName():sub(#site:GetFullName() + 2)
					end
				end
			end
			return nil
		end
		local KINDS = { -- the R5e size ranges
			{ pat = "^BandJeepney%d+$", kind = "Jeepney", n = 12, per = 6, parts = 8, long = { 9, 14 }, wide = { 5, 7.5 }, tall = { 5, 8 } },
			{ pat = "^BandTricycle%d+$", kind = "Tricycle", n = 8, per = 4, parts = 5, long = { 7.5, 9 }, wide = { 4.4, 5.8 }, tall = { 5.5, 7.2 } },
			{ pat = "^BandMotorbike%d+$", kind = "Motorbike", n = 12, per = 6, parts = 4, long = { 4, 5.8 }, wide = { 0.5, 2.2 }, tall = { 2.5, 4 } },
		}
		local function shapeOf(u, K) -- nil when the vehicle is right, else the first fault
			local lo, hi = ub(u)
			local dx, dz, dy = hi.X - lo.X, hi.Z - lo.Z, hi.Y - lo.Y
			local long, wide = math.max(dx, dz), math.min(dx, dz)
			if not u:IsA("Model") then return "not a Model" end
			if u:GetAttribute("Kind") ~= K.kind then return "Kind attribute" end
			if #partsIn(u) ~= K.parts then return #partsIn(u) .. " parts (want " .. K.parts .. ")" end
			if not (between(long, K.long[1], K.long[2]) and between(wide, K.wide[1], K.wide[2]) and between(dy, K.tall[1], K.tall[2])) then return string.format("size %.1f x %.1f x %.1f", long, wide, dy) end
			if not onGround(lo) then return "not on the ground (y " .. sx(lo.Y) .. ")" end
			return nil
		end
		local rigParts = {}
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("BasePart") and isRig(d) then table.insert(rigParts, d) end
		end

		-- a. the container
		check("bands: BandTraffic is a direct child of the site, a Folder or Model, and not a rig",
			bt ~= nil and bt.Parent == site and (bt:IsA("Folder") or bt:IsA("Model")) and not isRig(bt),
			bt == nil and "BandTraffic missing" or (bt.ClassName .. " in " .. (bt.Parent and bt.Parent.Name or "nil")))

		-- b. counts and shape per kind
		local allV = {}
		for _, K in ipairs(KINDS) do
			local list, bad, first = btUnits(K.pat), 0, ""
			for _, u in ipairs(list) do
				table.insert(allV, { u = u, K = K })
				local why = shapeOf(u, K)
				if why then
					bad += 1
					if first == "" then first = u.Name .. ": " .. why end
				end
			end
			check("bands: exactly " .. K.n .. " Band" .. K.kind .. " Models numbered 1.." .. K.n .. " (Kind " .. K.kind .. ", " .. K.parts .. " parts, long " .. K.long[1] .. ".." .. K.long[2] .. ", wide " .. K.wide[1] .. ".." .. K.wide[2] .. ", tall " .. K.tall[1] .. ".." .. K.tall[2] .. ", on the ground)",
				#list == K.n and numbered(list, K.n) and bad == 0, #list .. " found, " .. bad .. " off" .. (first ~= "" and (", first: " .. first) or ""))
		end

		-- c. per band: counts and bounds
		for _, key in ipairs({ "N", "S" }) do
			local B = BANDS[key]
			local cnt, outside, first = { Jeepney = 0, Tricycle = 0, Motorbike = 0 }, 0, ""
			for _, e in ipairs(allV) do
				local lo, hi = ub(e.u)
				if bandOf((lo.Z + hi.Z) / 2) == key then
					cnt[e.K.kind] += 1
					for _, p in ipairs(partsIn(e.u)) do
						local a, b = wb(p)
						if a.X < B.x0 - 0.05 or b.X > B.x1 + 0.05 or a.Z < B.z0 - 0.05 or b.Z > B.z1 + 0.05 then
							outside += 1
							if first == "" then first = e.u.Name .. "/" .. p.Name .. string.format(" x %s..%s z %s..%s", sx(a.X), sx(b.X), sx(a.Z), sx(b.Z)) end
						end
					end
				end
			end
			check("bands: " .. B.label .. " band holds 6 jeepneys, 4 tricycles and 6 motorbikes, every part inside x " .. B.x0 .. ".." .. B.x1 .. " and z " .. B.z0 .. ".." .. B.z1,
				cnt.Jeepney == 6 and cnt.Tricycle == 4 and cnt.Motorbike == 6 and outside == 0,
				cnt.Jeepney .. " jeepneys, " .. cnt.Tricycle .. " tricycles, " .. cnt.Motorbike .. " motorbikes, " .. outside .. " parts outside" .. (first ~= "" and (", first: " .. first) or ""))
		end

		-- d. clearance of the vehicles
		local nClash, firstClash = 0, ""
		for _, e in ipairs(allV) do
			local clash = clashOf(e.u)
			if not clash then
				local lo, hi = ub(e.u)
				for _, p in ipairs(rigParts) do -- a figure may not stand inside or touch a vehicle (0.5 clear)
					local a, b = wb(p)
					if lo.X < b.X + 0.5 and hi.X > a.X - 0.5 and lo.Z < b.Z + 0.5 and hi.Z > a.Z - 0.5 and lo.Y < b.Y and hi.Y > a.Y then clash = "touches a figure (" .. p.Name .. ")" break end
				end
			end
			if clash then
				nClash += 1
				if firstClash == "" then firstClash = e.u.Name .. " " .. (clash:find("^touches") and clash or ("overlaps " .. clash)) end
			end
		end
		check("bands: all 32 band vehicles overlap no other vehicle and no other built part, and no figure is within 0.5 of one", #allV == 32 and nClash == 0,
			#allV .. " vehicles, " .. nClash .. " clash" .. (firstClash ~= "" and (", first: " .. firstClash) or ""))

		-- e. utility poles
		local poles, arms, lamps, wires = btNamed("^UtilityPole%d+$"), btNamed("^PoleArm%d+$"), btNamed("^PoleLamp%d+$"), btNamed("^PoleWire%d+$")
		local perBand, badPole, firstPole = { N = 0, S = 0 }, 0, ""
		for _, p in ipairs(poles) do
			local lo, hi = wb(p)
			local why
			if not between(hi.Y - lo.Y, 20, 28) then why = string.format("height %.1f", hi.Y - lo.Y)
			elseif not onGround(lo) then why = "not on the ground (y " .. sx(lo.Y) .. ")" end
			for key, B in pairs(BANDS) do
				if between(p.Position.X, B.x0, B.x1) and between(p.Position.Z, B.z0, B.z1) then perBand[key] += 1 end
			end
			if why then
				badPole += 1
				if firstPole == "" then firstPole = p.Name .. ": " .. why end
			end
		end
		check("bands: exactly 12 UtilityPole parts numbered 1..12, each 20..28 tall and standing on the ground, 6 in the north band and 6 in the south band",
			#poles == 12 and numbered(poles, 12) and badPole == 0 and perBand.N == 6 and perBand.S == 6,
			#poles .. " poles, north " .. perBand.N .. ", south " .. perBand.S .. ", " .. badPole .. " off" .. (firstPole ~= "" and (", first: " .. firstPole) or ""))
		local function nearPoles(p)
			local c = 0
			for _, q in ipairs(poles) do
				if math.abs(p.Position.X - q.Position.X) <= 6 and math.abs(p.Position.Z - q.Position.Z) <= 6 then c += 1 end
			end
			return c
		end
		local strayArm, strayLamp, polesNoArm, polesNoLamp = 0, 0, 0, 0
		for _, a in ipairs(arms) do if nearPoles(a) < 1 then strayArm += 1 end end
		for _, l in ipairs(lamps) do if nearPoles(l) < 1 then strayLamp += 1 end end
		for _, q in ipairs(poles) do
			local na, nl = 0, 0
			for _, a in ipairs(arms) do if math.abs(a.Position.X - q.Position.X) <= 6 and math.abs(a.Position.Z - q.Position.Z) <= 6 then na += 1 end end
			for _, l in ipairs(lamps) do if math.abs(l.Position.X - q.Position.X) <= 6 and math.abs(l.Position.Z - q.Position.Z) <= 6 then nl += 1 end end
			if na ~= 1 then polesNoArm += 1 end
			if nl ~= 1 then polesNoLamp += 1 end
		end
		check("bands: exactly 12 PoleArm and 12 PoleLamp parts (numbered 1..12), each within 6 studs (x and z) of a pole, and every pole has exactly one arm and one lamp",
			#poles == 12 and #arms == 12 and #lamps == 12 and numbered(arms, 12) and numbered(lamps, 12) and strayArm == 0 and strayLamp == 0 and polesNoArm == 0 and polesNoLamp == 0,
			#arms .. " arms, " .. #lamps .. " lamps, stray " .. strayArm .. "/" .. strayLamp .. ", poles without exactly one arm/lamp " .. polesNoArm .. "/" .. polesNoLamp)
		local nPoleClash, firstPoleClash = 0, ""
		for _, list in ipairs({ poles, arms, lamps }) do
			for _, p in ipairs(list) do
				local clash = clashOf(p, poleFamily) -- the arm, lamp and wires of a pole meet it by design
				if clash then
					nPoleClash += 1
					if firstPoleClash == "" then firstPoleClash = p.Name .. " overlaps " .. clash end
				end
			end
		end
		check("bands: no pole, arm or lamp overlaps a band vehicle or any other built part", #poles == 12 and #arms == 12 and #lamps == 12 and nPoleClash == 0,
			(#poles + #arms + #lamps) .. " pole parts, " .. nPoleClash .. " clash" .. (firstPoleClash ~= "" and (", first: " .. firstPoleClash) or ""))

		-- f. wires
		local wireBand, badWire, firstWire, unlinked, firstUnlinked = { N = 0, S = 0 }, 0, "", 0, ""
		for _, w in ipairs(wires) do
			local lo, hi = wb(w)
			local dx, dy, dz = hi.X - lo.X, hi.Y - lo.Y, hi.Z - lo.Z
			local key = bandOf(w.Position.Z)
			wireBand[key] += 1
			local why
			if lo.Y <= 14 then why = "lowest point y " .. sx(lo.Y) .. " is not above 14"
			elseif not (dy <= 0.5 and dz <= 0.5) then why = string.format("not thin (%.2f x %.2f)", dy, dz)
			elseif not between(dx, 40, 60) then why = string.format("length along x %.1f", dx) end
			if why then
				badWire += 1
				if firstWire == "" then firstWire = w.Name .. ": " .. why end
			end
			local pa, pb -- the poles of the same band whose axes the two ends reach
			for _, q in ipairs(poles) do
				if bandOf(q.Position.Z) == key then
					if math.abs(q.Position.X - lo.X) <= 1 then pa = pa or q end
					if math.abs(q.Position.X - hi.X) <= 1 then pb = pb or q end
				end
			end
			if not (pa and pb and pa ~= pb) then
				unlinked += 1
				if firstUnlinked == "" then firstUnlinked = w.Name .. string.format(" x %s..%s", sx(lo.X), sx(hi.X)) end
			end
		end
		check("bands: exactly 20 PoleWire parts numbered 1..20, 10 in the north band and 10 in the south band", #wires == 20 and numbered(wires, 20) and wireBand.N == 10 and wireBand.S == 10,
			#wires .. " wires, north " .. wireBand.N .. ", south " .. wireBand.S)
		check("bands: every PoleWire is thin (both cross-sections at most 0.5), 40..60 long along x and has its lowest point above y 14", #wires == 20 and badWire == 0,
			#wires .. " wires, " .. badWire .. " off" .. (firstWire ~= "" and (", first: " .. firstWire) or ""))
		check("bands: each PoleWire reaches the axes (within 1 stud in x) of two different poles of the same band", #wires == 20 and #poles == 12 and unlinked == 0,
			#wires .. " wires, " .. unlinked .. " not linking two poles" .. (firstUnlinked ~= "" and (", first: " .. firstUnlinked) or ""))

		-- g. the container as a whole
		local all, unanch, badName = {}, 0, {}
		local NAMESPACES = { "TricycleBody", "TricycleWheel", "TricycleRoof", "ParkedVehicle", "LampPost", "LampHead", "StreetTricycle", "StreetJeepney", "SidePole", "StreetStall" }
		if bt then
			for _, d in ipairs(bt:GetDescendants()) do
				if d:IsA("BasePart") then
					table.insert(all, d)
					if not d.Anchored then unanch += 1 end
				end
				for _, pre in ipairs(NAMESPACES) do
					if d.Name:sub(1, #pre) == pre then table.insert(badName, d.Name) end
				end
			end
		end
		check("bands: BandTraffic holds exactly 240 BasePart descendants (184 vehicle + 36 pole + 20 wire)", #all == 240, tostring(#all))
		check("bands: every part in BandTraffic is anchored", #all > 0 and unanch == 0, #all .. " parts, " .. unanch .. " unanchored")
		check("bands: no name in BandTraffic starts with a namespace of another check (TricycleBody, TricycleWheel, TricycleRoof, ParkedVehicle, LampPost, LampHead, StreetTricycle, StreetJeepney, SidePole, StreetStall)",
			bt ~= nil and #badName == 0, #badName .. ": " .. table.concat(badName, ", ", 1, math.min(#badName, 4)))
	end)

	------------------------------------------------------------------ block: corner block (BP2) and service block (BP1 plan, BP2 plan)
	-- CornerBlock (Structure/CornerBlock): BP2's louvred 4-storey block with the white and blue-grey checkerboard hoarding, long face parallel to the hall front, hoarding facing
	--   east in the north half of that face (z 258..282). Parts: ONE CornerBlockBody; 12 Checker%d+ (3 wide x 4 high squares of 8 x 6) inside 4+ proud BlockFrame%d+; 10+ Louvre%d+
	--   (a big LouvreSlat%d+ screen on the south end); 3+ BlockBand%d+; 8+ BlockRib%d+; a low BlockHip%d+ roof with a BlockHipRidge%d*; 2+ BlockDoor%d+ (8..9.6 tall).
	--   Bounds x -574..-540, z 244..324 (BP2 draws it about 100 long; the slot allows 80 without touching the Bagsakan), top 29..32. No text, no decals.
	-- ServiceBlock (Structure/ServiceBlock): BP1 plan z 33..60 plus annex z 60..85 at the Bagsakan's north-west, flat roofs under 2+ ServiceCanopy%d+ overhanging slabs. Parts: ONE
	--   ServiceBlockBody, ONE ServiceAnnex, 4+ ServiceRoofEdge%d+, 2+ ServiceDoor%d+ (8..9.6 tall, README rule 7). BP1 reads the height at about 7; a door 8 tall needs a body of
	--   at least 9, so the top is 9..10.5.
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
		check("Structure/CornerBlock exists and holds 40..170 parts (BP2 louvred block with the checkerboard hoarding, hip roof, panel ribs, big louvre screen)", cbN >= 40 and cbN <= 170, cb and tostring(cbN) or "missing")
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
			check("checkerboard hoarding: exactly 12 Checker squares of 8 x 6 on the east face (x -541..-538), covering z 258..282 (+-2) and y 3..27 (+-1): BP2 sets it in the north half of the long face",
				#chk == 12 and badChk == 0 and near(klo.Z, 258, 2) and near(khi.Z, 282, 2) and near(klo.Y, 3, 1) and near(khi.Y, 27, 1),
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
			-- BP2 draws white and blue-grey squares, not black
			local lightN, darkN, badTone = 0, 0, 0
			for _, p in ipairs(chk) do
				local c = p.Color
				local b = c.R + c.G + c.B
				if b >= 2.4 then lightN += 1 elseif b >= 1.2 and b <= 1.7 and c.B > c.R + 0.05 then darkN += 1 else badTone += 1 end
			end
			check("checker colours (BP2 draws white and blue-grey, not black): 6 white squares (brightness R+G+B 2.4+) and 6 mid blue-grey squares (1.2..1.7, blue above red)",
				#chk == 12 and lightN == 6 and darkN == 6 and badTone == 0, lightN .. " white, " .. darkN .. " blue-grey, " .. badTone .. " other")
			-- the hoarding is a panel standing off the wall: its frame is proud of the squares and encloses them
			local fr = named("^BlockFrame%d+$")
			local frLo, frHi = union(fr)
			check("hoarding frame: 4+ BlockFrame parts standing at least 1.0 proud of the east wall (east face x -539.05 or more) and enclosing the squares by at least 0.2 on every side",
				#fr >= 4 and #chk == 12 and frHi.X >= -539.05 and frLo.Z <= klo.Z - 0.2 and frHi.Z >= khi.Z + 0.2 and frLo.Y <= klo.Y - 0.2 and frHi.Y >= khi.Y + 0.2,
				#fr .. " frame parts" .. (#fr > 0 and string.format(", east face x %s, z %s..%s y %s..%s", sx(frHi.X), sx(frLo.Z), sx(frHi.Z), sx(frLo.Y), sx(frHi.Y)) or ""))
			-- louvres on the north and south ends and beside the hoarding
			local lv = named("^Louvre%d+$")
			local lvN, lvS, lvE, southArea = 0, 0, 0, 0
			for _, p in ipairs(lv) do
				local lo, hi = wb(p)
				local c = (lo + hi) / 2
				if c.Z <= 247 then lvN += 1
				elseif c.Z >= 321 then lvS += 1; southArea += (hi.X - lo.X) * (hi.Y - lo.Y)
				elseif hi.X >= -541.5 and (hi.Z <= 257.5 or lo.Z >= 282.5) then lvE += 1 end
			end
			check("louvres: 10+ Louvre parts, 3+ on the north end (z <= 247), 3+ on the south end (z >= 321) and 3+ on the east face beside the hoarding (north of z 257.5 or south of z 282.5)",
				#lv >= 10 and lvN >= 3 and lvS >= 3 and lvE >= 3, #lv .. " louvres: " .. lvN .. " north, " .. lvS .. " south, " .. lvE .. " east")
			local southSlats = 0
			for _, p in ipairs(named("^LouvreSlat%d+$")) do if p.Position.Z >= 321 then southSlats += 1 end end
			check("south end screen (BP2 wraps one large dense louvre screen round the south end): the south-face Louvre panels cover at least 450 square studs and carry 20+ slat strips",
				southArea >= 450 and southSlats >= 20, string.format("%.0f square studs, %d slats", southArea, southSlats))
			-- low hip roof inside the parapet (BP2), and no plant boxes
			local hip = named("^BlockHip%d+$")
			local hpLo, hpHi = union(hip)
			check("low hip roof inside the parapet (BP2): 4+ BlockHip slopes and 1+ BlockHipRidge, inside x -573..-541 and z 245..323, top y 31.2..32.0, none below y 29.9",
				#hip >= 4 and #named("^BlockHipRidge%d*$") >= 1 and hpLo.X >= -573.05 and hpHi.X <= -540.95 and hpLo.Z >= 244.95 and hpHi.Z <= 323.05 and between(hpHi.Y, 31.2, 32.0) and hpLo.Y >= 29.9,
				#hip .. " slopes" .. (#hip > 0 and string.format(", x %s..%s z %s..%s y %s..%s", sx(hpLo.X), sx(hpHi.X), sx(hpLo.Z), sx(hpHi.Z), sx(hpLo.Y), sx(hpHi.Y)) or ""))
			check("no flat-roof plant boxes (BP2 draws a clean roof): no BlockRoofBox parts", #named("^BlockRoofBox%d+$") == 0, #named("^BlockRoofBox%d+$") .. " found")
			-- vertical panel ribs (BP2 divides the faces into a vertical panel grid)
			local ribs = named("^BlockRib%d+$")
			local ribE, badRib = 0, 0
			for _, p in ipairs(ribs) do
				local lo, hi = wb(p)
				if not (hi.X - lo.X <= 1.2 and hi.Z - lo.Z <= 1.2 and hi.Y - lo.Y >= 14) then badRib += 1
				elseif hi.X >= -540.1 and hi.X <= -538.5 and not (hi.Z > 257.4 and lo.Z < 282.6) then ribE += 1 end
			end
			check("panel ribs: 8+ BlockRib strips (thin, 14+ tall), 4+ of them on the east face (east face x -540.1..-538.5) and none across the hoarding (z 257.4..282.6)",
				#ribs >= 8 and badRib == 0 and ribE >= 4, #ribs .. " ribs, " .. badRib .. " not thin or too short, " .. ribE .. " on the east face")
			local bands = named("^BlockBand%d+$")
			local bLo, bHi = 1e9, -1e9
			for _, p in ipairs(bands) do bLo, bHi = math.min(bLo, p.Position.Y), math.max(bHi, p.Position.Y) end
			check("storey bands: 3+ BlockBand parts whose heights spread over at least 7 studs (four storeys read as four)", #bands >= 3 and bHi - bLo >= 7, #bands .. " bands, spread " .. (#bands > 0 and sx(bHi - bLo) or "n/a"))
			local bandBad = 0
			for _, p in ipairs(bands) do
				local lo, hi = wb(p)
				if lo.X >= -541 and hi.X >= -540.1 and hi.Z > 257.4 and lo.Z < 282.6 then bandBad += 1 end
			end
			check("the east-face storey bands are cut round the hoarding: none crosses z 257.4..282.6", bandBad == 0, bandBad .. " cross it")
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
			check("service block bounds: x -554.5..-495, z 31..84 (the canopy eaves overhang the block; nothing reaches the Bagsakan walls at z 84), nothing below y -0.5, top at most 10.5",
				slo.X >= -554.5 and shi.X <= -495 and slo.Z >= 31 and shi.Z <= 84 and slo.Y >= -0.5 and shi.Y <= 10.5,
				string.format("x %s..%s y %s..%s z %s..%s", sx(slo.X), sx(shi.X), sx(slo.Y), sx(shi.Y), sx(slo.Z), sx(shi.Z)))
			-- BP1 iso (iso_bags.png) draws the service block under an overhanging flat canopy roof
			local can = named("^ServiceCanopy%d+$")
			local cnLo, cnHi = union(can)
			local canThin = #can >= 2
			for _, p in ipairs(can) do
				local a, b = wb(p)
				if not (b.Y - a.Y <= 0.8 and between(b.Y, 9.4, 10.5) and a.Y >= 8) then canThin = false end
			end
			check("service canopy (BP1 draws an overhanging flat roof): 2+ ServiceCanopy slabs, each at most 0.8 thick, bottom y 8 or more, top y 9.4..10.5, overhanging the block by 1.4 or more on the north (z <= 31.6), east (x >= -495.6) and west (x <= -553.4)",
				canThin and cnLo.Z <= 31.6 and cnHi.X >= -495.6 and cnLo.X <= -553.4, #can .. " canopy parts" .. (#can > 0 and string.format(", x %s..%s z %s..%s", sx(cnLo.X), sx(cnHi.X), sx(cnLo.Z), sx(cnHi.Z)) or ""))
			check("service block carries no text, gui or decal", noText(sb) == 0, noText(sb) .. " found")
			local sHit = touching(sb, slo, shi)
			check("service block stands clear of everything else (Bagsakan, truck lane, north side yard): nothing within 1 stud of it", #sHit == 0, #sHit .. ": " .. table.concat(sHit, ", ", 1, math.min(#sHit, 4)))
		end
	end)

	------------------------------------------------------------------ crowd: 11 shoppers (R6b)
	-- R6b (owner-approved 2026-10-30): a crowd of 11 figures. REQUIRES: a Folder Crowd, direct child of Site02_Market, holding 11 R15 humanoid Models named
	--   Shopper1..Shopper11, each exactly 16 BaseParts (176 in all), no Accessory, no Animate, HumanoidRootPart anchored, Humanoid.DisplayDistanceType None,
	--   attribute SiteId 2. The site then holds 22 rigs (Guide, ShopperBayong1/2, Vendor1..8, Shopper1..11). Figures stand on the ground, keep clear of the
	--   Guide, InfoPanel, Road F mouth, band rows and pole axes, stay west of x -229 (the zebra crossings stay empty, an honest DIFF), clear of every built
	--   part, 2.5 studs apart, clustered at the stair feet and the side yards, with 4+ distinct torso colours. Every per-figure check also demands exactly 11
	--   figures, so nothing passes while Crowd is missing.
	pcallGroup("crowd", function()
		local crowd = site:FindFirstChild("Crowd")
		local figs = {}
		for _, c in ipairs(crowd and crowd:GetChildren() or {}) do
			if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") and c.Name:match("^Shopper%d+$") then table.insert(figs, c) end
		end
		table.sort(figs, function(a, b) return tonumber(a.Name:match("%d+$")) < tonumber(b.Name:match("%d+$")) end)
		local function numbered(list, n) -- exactly n items, names end in 1..n, each number once
			local seen, ok = {}, #list == n
			for _, x in ipairs(list) do
				local k = tonumber(x.Name:match("%d+$"))
				if k == nil or k < 1 or k > n or seen[k] then ok = false else seen[k] = true end
			end
			return ok
		end
		local have11 = #figs == 11 and numbered(figs, 11)
		local found = #figs .. " figures"
		local function partsOfFig(m)
			local t = {}
			for _, d in ipairs(m:GetDescendants()) do if d:IsA("BasePart") then table.insert(t, d) end end
			return t
		end
		local function hrpOf(m)
			local h = m:FindFirstChild("HumanoidRootPart")
			return (h ~= nil and h:IsA("BasePart")) and h or nil
		end
		local function figBox(m) -- world AABB from rig:GetBoundingBox() (CFrame + Size), over the 8 corners
			local cf, size = m:GetBoundingBox()
			local h = size / 2
			local lo, hi = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
			for _, a in ipairs({ -1, 1 }) do for _, b in ipairs({ -1, 1 }) do for _, c in ipairs({ -1, 1 }) do
				local w = cf * Vector3.new(a * h.X, b * h.Y, c * h.Z)
				lo = Vector3.new(math.min(lo.X, w.X), math.min(lo.Y, w.Y), math.min(lo.Z, w.Z))
				hi = Vector3.new(math.max(hi.X, w.X), math.max(hi.Y, w.Y), math.max(hi.Z, w.Z))
			end end end
			return lo, hi
		end
		local function scan(fn) -- fn(figure) -> nil when fine, else a reason; returns the bad count and a ", first: ..." detail
			local bad, first = 0, ""
			for _, m in ipairs(figs) do
				local why = fn(m)
				if why then
					bad += 1
					if first == "" then first = m.Name .. ": " .. why end
				end
			end
			return bad, (first ~= "" and (", first: " .. first) or "")
		end

		-- a. the container
		local childCount = crowd and #crowd:GetChildren() or 0
		check("crowd: Crowd is a Folder, a direct child of the site, holding exactly 11 Models with a Humanoid named Shopper1..Shopper11 (each number once, nothing else inside)",
			crowd ~= nil and crowd:IsA("Folder") and crowd.Parent == site and have11 and childCount == 11,
			crowd == nil and "Crowd missing" or (crowd.ClassName .. " in " .. (crowd.Parent and crowd.Parent.Name or "nil") .. ", " .. found .. ", " .. childCount .. " children"))

		-- b. what each figure is made of
		local bad, first = scan(function(m)
			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum.RigType ~= Enum.HumanoidRigType.R15 then return "RigType " .. tostring(hum.RigType) end
			local n = #partsOfFig(m)
			if n ~= 16 then return n .. " parts (want 16)" end
			return nil
		end)
		check("crowd: exactly 11 figures, each Humanoid.RigType R15 with exactly 16 BaseParts", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)
		local total = 0
		for _, m in ipairs(figs) do total += #partsOfFig(m) end
		check("crowd: exactly 11 figures holding 176 BaseParts in all", have11 and total == 176, found .. ", " .. total .. " parts")
		bad, first = scan(function(m)
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("Accessory") then return "Accessory " .. d.Name end
				if d.Name == "Animate" then return "descendant named Animate (" .. d.ClassName .. ")" end
			end
			return nil
		end)
		check("crowd: exactly 11 figures, none with an Accessory descendant or any descendant named Animate", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)
		bad, first = scan(function(m)
			local hrp, hum = hrpOf(m), m:FindFirstChildOfClass("Humanoid")
			if hrp == nil then return "no HumanoidRootPart" end
			if hrp.Anchored ~= true then return "HumanoidRootPart not anchored" end
			if hum.DisplayDistanceType ~= Enum.HumanoidDisplayDistanceType.None then return "DisplayDistanceType " .. tostring(hum.DisplayDistanceType) end
			return nil
		end)
		check("crowd: exactly 11 figures, each HumanoidRootPart anchored and Humanoid.DisplayDistanceType None", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)
		bad, first = scan(function(m)
			if m:GetAttribute("SiteId") ~= 2 then return "SiteId " .. tostring(m:GetAttribute("SiteId")) end
			return nil
		end)
		check("crowd: exactly 11 figures, each with attribute SiteId 2", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)

		-- c. grounded: a ray 10 studs straight down from each HumanoidRootPart lands 3.0 below it (+-0.2)
		local skip = {}
		for _, d in ipairs(workspace:GetDescendants()) do
			if d:IsA("Humanoid") and d.Parent ~= nil then table.insert(skip, d.Parent) end
		end
		local rayP = RaycastParams.new()
		rayP.FilterType = Enum.RaycastFilterType.Exclude
		rayP.FilterDescendantsInstances = skip
		bad, first = scan(function(m)
			local hrp = hrpOf(m)
			if hrp == nil then return "no HumanoidRootPart" end
			local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), rayP)
			if hit == nil then return "no ground within 10 studs below y " .. sx(hrp.Position.Y) end
			if math.abs((hrp.Position.Y - 3.0) - hit.Position.Y) > 0.2 then return "HRP y " .. sx(hrp.Position.Y) .. " over ground y " .. sx(hit.Position.Y) .. " (" .. hit.Instance.Name .. ")" end
			return nil
		end)
		check("crowd: exactly 11 figures, each standing on the ground (ray 10 studs down from the HumanoidRootPart hits, and HRP y - 3.0 is within 0.2 of the hit y)", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)

		-- d. keep-clear boxes (x0, x1, z0, z1), strict overlap in x,z only
		local KEEP = {
			{ name = "Guide", x0 = -246, x1 = -236, z0 = 155, z1 = 165 },
			{ name = "wide apron box", x0 = -250, x1 = -229, z0 = 148, z1 = 172 },
			{ name = "Guide band", x0 = -576, x1 = -228, z0 = 140, z1 = 180 },
			{ name = "InfoPanel", x0 = -247, x1 = -235, z0 = 142, z1 = 154 },
			{ name = "Road F mouth", x0 = -260, x1 = -228, z0 = 154, z1 = 166 },
			{ name = "north band rows", x0 = -576, x1 = -228, z0 = -4.5, z1 = 11.1 },
			{ name = "south band rows", x0 = -576, x1 = -228, z0 = 311.9, z1 = 324.5 },
			{ name = "north pole axis", x0 = -576, x1 = -228, z0 = 13, z1 = 16 },
			{ name = "south pole axis", x0 = -576, x1 = -228, z0 = 307, z1 = 310 },
		}
		bad, first = scan(function(m)
			local lo, hi = figBox(m)
			for _, k in ipairs(KEEP) do
				if lo.X < k.x1 and hi.X > k.x0 and lo.Z < k.z1 and hi.Z > k.z0 then
					return string.format("box x %s..%s z %s..%s overlaps %s", sx(lo.X), sx(hi.X), sx(lo.Z), sx(hi.Z), k.name)
				end
			end
			return nil
		end)
		check("crowd: exactly 11 figures, none whose bounding box overlaps (x,z, strict) the Guide, the wide apron box, the Guide band, the InfoPanel, the Road F mouth, the north or south band rows or either pole axis", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)

		-- e. nothing east of x -229 (the real-bounds rule caps x at -227.95; the zebra crossings stay empty)
		local maxX, maxName = -1e9, "none"
		for _, m in ipairs(figs) do
			for _, p in ipairs(partsOfFig(m)) do
				local _, hi = wb(p)
				if hi.X > maxX then maxX, maxName = hi.X, m.Name .. "/" .. p.Name end
			end
		end
		check("crowd: exactly 11 figures, no part of any figure east of x -229 (max X <= -229)", have11 and maxX <= -229 + 0.001, found .. ", max x " .. sx(maxX) .. " at " .. maxName)

		-- f. clear of every built part: the AABB grown by 0.5 on every side meets nothing that stands above y 0.6 (vehicles, stalls, counters, boards, steps, poles, InfoPanel)
		local ovP = OverlapParams.new()
		ovP.FilterType = Enum.RaycastFilterType.Include
		ovP.FilterDescendantsInstances = { site }
		bad, first = scan(function(m)
			local lo, hi = figBox(m)
			for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new((lo + hi) / 2), (hi - lo) + Vector3.new(1, 1, 1), ovP)) do
				if not isRig(p) and p.Position.Y + p.Size.Y / 2 > 0.6 then return "touches " .. p.Name end
			end
			return nil
		end)
		check("crowd: exactly 11 figures, each clear of every built part (box grown by 0.5 meets no non-rig part whose top is above y 0.6)", have11 and bad == 0, found .. ", " .. bad .. " off" .. first)

		-- g. spacing of every rig under the site
		local rigModels, rigRoots = {}, {}
		for _, d in ipairs(site:GetDescendants()) do
			if d:IsA("Model") and d:FindFirstChildOfClass("Humanoid") then
				table.insert(rigModels, d)
				local h = hrpOf(d)
				if h then table.insert(rigRoots, { n = d.Name, p = h.Position }) end
			end
		end
		local closest, closePair = 1e9, "none"
		for i = 1, #rigRoots do
			for j = i + 1, #rigRoots do
				local dx, dz = rigRoots[i].p.X - rigRoots[j].p.X, rigRoots[i].p.Z - rigRoots[j].p.Z
				local d = math.sqrt(dx * dx + dz * dz)
				if d < closest then closest, closePair = d, rigRoots[i].n .. " / " .. rigRoots[j].n end
			end
		end
		check("crowd: exactly 11 figures; the site holds exactly 22 rigs (Guide, 2 ShopperBayong, 8 Vendors, 11 Shoppers), each with a HumanoidRootPart, no two closer than 2.5 studs in the XZ plane",
			have11 and #rigModels == 22 and #rigRoots == 22 and closest >= 2.5,
			found .. ", " .. #rigModels .. " rigs, " .. #rigRoots .. " roots, closest " .. (closest < 1e9 and sx(closest) or "n/a") .. " (" .. closePair .. ")")

		-- h. clusters: the stair feet and the side yards (HumanoidRootPart position)
		local nearN, nearS, side = 0, 0, 0
		for _, m in ipairs(figs) do
			local h = hrpOf(m)
			if h then
				local p = h.Position
				if p.X <= -236 and math.abs(p.Z - 92) <= 14 then nearN += 1 end
				if p.X <= -236 and math.abs(p.Z - 228) <= 14 then nearS += 1 end
				if p.X <= -310 then side += 1 end
			end
		end
		check("crowd: exactly 11 figures, at least 3 with x <= -236 and |z - 92| <= 14 (north stair foot)", have11 and nearN >= 3, found .. ", " .. nearN .. " at the north stair foot")
		check("crowd: exactly 11 figures, at least 3 with x <= -236 and |z - 228| <= 14 (south stair foot)", have11 and nearS >= 3, found .. ", " .. nearS .. " at the south stair foot")
		check("crowd: exactly 11 figures, at least 4 with x <= -310 (the side yards)", have11 and side >= 4, found .. ", " .. side .. " in the side yards")

		-- i. variety
		local cols, ncol = {}, 0
		for _, m in ipairs(figs) do
			local ut = m:FindFirstChild("UpperTorso")
			if ut ~= nil and ut:IsA("BasePart") then
				local key = string.format("%d,%d,%d", math.floor(ut.Color.R * 255 + 0.5), math.floor(ut.Color.G * 255 + 0.5), math.floor(ut.Color.B * 255 + 0.5))
				if not cols[key] then cols[key] = true; ncol += 1 end
			end
		end
		check("crowd: exactly 11 figures with at least 4 distinct UpperTorso colours", have11 and ncol >= 4, found .. ", " .. ncol .. " distinct colours")

		-- j. shoppers belong to the Crowd, not to the vendors
		local vend, strays = site:FindFirstChild("VendorNPCs"), 0
		for _, d in ipairs(vend and vend:GetDescendants() or {}) do
			if d:IsA("Model") and d.Name:match("^Shopper%d+$") then strays += 1 end
		end
		check("crowd: exactly 11 figures in Crowd, and no Model named Shopper<number> sits under VendorNPCs", have11 and strays == 0, found .. ", " .. strays .. " Shoppers under VendorNPCs")
	end)

	------------------------------------------------------------------ general: whole-site rules
	pcallGroup("general", function()
		local pv = site:GetPivot()
		check("site pivot is at the SiteData pos (-402, 0, 160), facing E", (pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(1, 0, 0)) > 0.999,
			string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
		for _, n in ipairs({ "Guide", "InfoPanel", "Structure", "Crowd", "Yard", "MarketStalls", "Baskets", "Produce", "PriceSigns", "VendorNPCs", "LocalNPCs" }) do
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
		check("part count (rigs excluded) is between 950 and 2000 (the old model had 960; raised from 1500 for the corner block, service block, yard and vehicles, then from 1800 to 2000 for the street traffic, then 2000 to 2200 for the band traffic, owner-authorised 2026-10-30)", #own >= 950 and #own <= 2200, tostring(#own))
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
