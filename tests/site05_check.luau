-- site05_check: the spec for Site 05 (Monastery of Our Lady of Mount Carmel). Slice 15 fidelity spec, extended for the BOARD rebuild
-- (Standard tier S1, 2026-10-31: "Mount Carmel Monastery Blueprint.png", briefs/site05.md Revision 2). Written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site05_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site05_check:Clone())      -- returns JSON {passed, failed, failures}
-- Groups (set shared.site05_only = "general" | "facade" | "chapel" | "monastery" | "rectory" | "grounds" | "clear" first to run one;
-- run_all leaves it nil and runs all; SET IT BACK TO nil after a filtered run).
-- Frame: the site pivot is yawed 180 degrees, but the builder works in world-aligned local axes (origin = the pivot position), so every
-- coordinate here is world position minus the site position: local +Z = south = the facade side, +X = east. Heights are above the
-- ground (y 0); the portico floor is B = 6. Pins the board contradicts were REPLACED (never just deleted); each keeps its old text in a
-- "REPLACED (board)" comment and is listed in briefs/site05.md Revision 2.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(-300, 0, -600)
local B = 6 -- portico floor: 6 risers of 1 stud
local ONLY = shared.site05_only

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end
local function group(name) return ONLY == nil or ONLY == name end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site05_Carmel")
check("Site05_Carmel exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end

local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local function allNamed(name)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") and not isRig(d) then table.insert(list, d) end
	end
	return list
end
local function anchor(name) return allNamed(name)[1] end
local function allPrefix(prefix)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and d.Name:sub(1, #prefix) == prefix then table.insert(list, d) end
	end
	return list
end
local function lp(p) return p.Position - SITE_POS end -- site-local position
local function topY(p) return p.Position.Y + p.Size.Y / 2 end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function near(a, b, tol) return a ~= nil and math.abs(a - b) <= tol end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
-- world-axis extent of a part (rotated corners included): returns min, max of the local coordinate on axis "X" | "Y" | "Z"
local function extent(p, axis)
	local lo, hi = math.huge, -math.huge
	local h = p.Size / 2
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local w = p.CFrame:PointToWorldSpace(Vector3.new(sx * h.X, sy * h.Y, sz * h.Z)) - SITE_POS
				lo, hi = math.min(lo, w[axis]), math.max(hi, w[axis])
			end
		end
	end
	return lo, hi
end
-- REPLACED (board): forestGreen = r <= 50 and g 75..105 and b <= 70 (the Slice 15 photo green (30,92,56)). The board's roofs sample at
-- (65..83, 104..125, 97..117): a muted teal-green. The Slice 04 teal (40,110,70) and the photo green both fail this rule.
local function boardGreen(p)
	local r, g, b = rgb(p)
	return r >= 55 and r <= 95 and g >= 100 and g <= 135 and b >= 90 and b <= 125 and g >= r + 25
end
local function cream(p)
	local r, g, b = rgb(p)
	return r >= 225 and g >= 205 and b <= 215 and b >= 120
end
local function white(p)
	local r, g, b = rgb(p)
	return r >= 225 and g >= 220 and b >= 205
end
local function maroonish(p)
	local r, g, b = rgb(p)
	return r >= 90 and r <= 165 and g <= 80 and b <= 70
end
local function partsIn(inst)
	local n = inst:IsA("BasePart") and 1 or 0
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("BasePart") then n += 1 end
	end
	return n
end

------------------------------------------------------------------ general: pivot, tree, budgets, slot
if group("general") then
	-- A stray drag in Studio once moved a whole site; it shows up as a dozen unrelated failures, so test the pivot first.
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (-300, 0, -600), facing +Z (yawed 180)",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(0, 0, 1)) > 0.9999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
	local total = partsIn(site)
	check("site holds 1000..2500 parts (board model, BuildCheck cap 2500)", total >= 1000 and total <= 2500, tostring(total))
	local st = site:FindFirstChild("Structure")
	local need = { "Facade", "Nave", "Dome", "Annex", "Monastery" }
	local missing = {}
	for _, n in ipairs(need) do
		if not (st and st:FindFirstChild(n)) then table.insert(missing, n) end
	end
	check("Structure is a grouping Folder holding Facade, Nave, Dome, Annex, Monastery", st ~= nil and st:IsA("Folder") and #missing == 0, table.concat(missing, ","))
	local big = {}
	local function cap(inst, label)
		local n = partsIn(inst)
		if n > 400 then table.insert(big, label .. "=" .. n) end
	end
	for _, c in ipairs(site:GetChildren()) do
		if c.Name == "Structure" then
			for _, s in ipairs(c:GetChildren()) do cap(s, "Structure." .. s.Name) end
			check("Structure holds no loose parts (a grouping node)", (function()
				for _, s in ipairs(c:GetChildren()) do if s:IsA("BasePart") then return false end end
				return true
			end)())
		else
			cap(c, c.Name)
		end
	end
	check("every container holds at most 400 parts", #big == 0, table.concat(big, ","))
	-- the sites_check orientation guard searches Structure recursively for these four; each must be unique there
	local dup = {}
	for _, n in ipairs({ "Podium", "NaveBlock", "AnnexBlock", "MonasteryBlock" }) do
		local k = 0
		if st then for _, d in ipairs(st:GetDescendants()) do if d.Name == n then k += 1 end end end
		if k ~= 1 then table.insert(dup, n .. "=" .. k) end
	end
	check("Podium, NaveBlock, AnnexBlock, MonasteryBlock each exist once under Structure", #dup == 0, table.concat(dup, ","))
	local out = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then
			local x0, x1 = extent(d, "X")
			local z0, z1 = extent(d, "Z")
			if x0 < -110.5 or x1 > 110.5 or z0 < -90.5 or z1 > 90.5 then table.insert(out, d.Name) end
		end
	end
	check("every built part lies inside the 220 x 180 slot (x +-110, z +-90)", #out == 0, #out .. ": " .. table.concat(out, ",", 1, math.min(#out, 4)))
	local low = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not (d:IsA("Part") and d.Shape == Enum.PartType.Ball) and select(1, extent(d, "Y")) < -0.6 then table.insert(low, d.Name) end
	end
	check("no box part reaches below y -0.6", #low == 0, table.concat(low, ",", 1, math.min(#low, 4)))
end

------------------------------------------------------------------ facade: three-step silhouette (frontal photo + front-elevation inset)
if group("facade") then
	local outer = allNamed("FacadeOuter")
	local minX, maxX, topsOk = math.huge, -math.huge, #outer == 2
	for _, p in ipairs(outer) do
		minX = math.min(minX, lp(p).X - p.Size.X / 2)
		maxX = math.max(maxX, lp(p).X + p.Size.X / 2)
		if not near(topY(p), B + 25, 0.7) then topsOk = false end
	end
	check("FacadeOuter: two shoulder blocks spanning x -34..34 (68 studs) with tops at y 31", #outer == 2 and minX <= -33.5 and maxX >= 33.5 and topsOk,
		string.format("%d parts, x %s..%s", #outer, fmt(minX), fmt(maxX)))
	local mid, centre = anchor("FacadeMid"), anchor("FacadeCentre")
	check("FacadeMid: 38-42 wide, top at y 39 (second step)", mid ~= nil and mid.Size.X >= 38 and mid.Size.X <= 42 and near(topY(mid), B + 33, 0.7),
		mid and (fmt(mid.Size.X) .. " top " .. fmt(topY(mid))) or "missing")
	check("FacadeCentre: 24-28 wide, top at y 42 (third step)", centre ~= nil and centre.Size.X >= 24 and centre.Size.X <= 28 and near(topY(centre), B + 36, 0.7),
		centre and (fmt(centre.Size.X) .. " top " .. fmt(topY(centre))) or "missing")
	local ped = allNamed("PedTrimL")
	check("pediment: a white triangle whose apex is at y 47", #ped == 1 and near(topY(ped[1]), B + 41, 0.9) and white(ped[1]),
		ped[1] and fmt(topY(ped[1])) or "missing")
	check("7+ PedScallop blocks along the pediment", #allNamed("PedScallop") >= 7, tostring(#allNamed("PedScallop")))
	check("12+ Crenel blocks on the shoulder bands (outer + mid)", #allNamed("Crenel") >= 20, tostring(#allNamed("Crenel")))
	-- REPLACED (board): "ringed cross: stem top at y 52 (+-2) and 8 CrossRing segments". The elevation inset draws the cross 9 studs tall,
	-- its top 58 above the ground (cross top 35 px, ground 745 px, 12.3 px per stud).
	local stem = anchor("CrossStem")
	check("ringed cross: stem top at y 56..59.5 (front elevation) and 8 CrossRing segments", stem ~= nil and topY(stem) >= 56 and topY(stem) <= 59.5 and #allNamed("CrossRing") == 8,
		stem and fmt(topY(stem)) or "missing")
	-- REPLACED (board): "rose window on the axis at y 31 (+-1.5), 7-9 studs across". The elevation's rose is 0.42 of the 26-stud centre block.
	local rose = anchor("Rose")
	check("rose window on the axis at y 31..34, 9.5-11.5 studs across (front elevation)", rose ~= nil and math.abs(lp(rose).X) < 0.6 and rose.Position.Y >= 31 and rose.Position.Y <= 34
		and rose.Size.Y >= 9.5 and rose.Size.Y <= 11.5,
		rose and string.format("x %s y %s d %s", fmt(lp(rose).X), fmt(rose.Position.Y), fmt(rose.Size.Y)) or "missing")
	local niche = anchor("NicheStatue")
	check("Marian niche statue on the axis between y 37 and 41", niche ~= nil and math.abs(lp(niche).X) < 0.6 and niche.Position.Y >= B + 31 and niche.Position.Y <= B + 35,
		niche and fmt(niche.Position.Y) or "missing")
	check("the old pyramid tiers and the 3-spoke rose are gone (Tier2, Tier3, Register2, RoseSpoke)",
		#allNamed("Tier2") == 0 and #allNamed("Tier3") == 0 and #allNamed("Register2") == 0 and #allNamed("RoseSpoke") == 0)
	-- NEW (board, front-elevation inset): low outer wings beyond the shoulders and square corner posts on the centre block.
	local low = allNamed("FacadeLow")
	check("FacadeLow: two low outer wings at |x| 36..49, tops 16..19 (elevation inset)", #low == 2 and (function()
		for _, p in ipairs(low) do
			local x0, x1 = extent(p, "X")
			local a, b = math.min(math.abs(x0), math.abs(x1)), math.max(math.abs(x0), math.abs(x1))
			if a < 35.5 or b > 49.5 or b < 46 or topY(p) < 16 or topY(p) > 19 then return false end
		end
		return true
	end)(), tostring(#low))
	local posts = allNamed("CentrePost")
	check("CentrePost: two corner posts of the centre block, tops 43..45.5, |x| 10..13.5", #posts == 2 and (function()
		for _, p in ipairs(posts) do
			if topY(p) < 43 or topY(p) > 45.5 or math.abs(lp(p).X) < 10 or math.abs(lp(p).X) > 13.5 then return false end
		end
		return true
	end)(), tostring(#posts))
	check("portico: one centre arch (ArchC) and two side arches (ArchS)", #allPrefix("ArchC") >= 1 and #allPrefix("ArchS") >= 2,
		#allPrefix("ArchC") .. "/" .. #allPrefix("ArchS"))
	local dc = anchor("DoorC_Pane")
	check("centre door is 11+ studs high (pane + half the width)", dc ~= nil and dc.Size.Y + dc.Size.X / 2 >= 10.5, dc and fmt(dc.Size.Y + dc.Size.X / 2) or "missing")
	local sides = allNamed("DoorS_Pane")
	check("two side doors, each 8+ studs high", #sides == 2 and sides[1].Size.Y + sides[1].Size.X / 2 >= 8.5 and sides[2].Size.Y + sides[2].Size.X / 2 >= 8.5, tostring(#sides))
	local pil = allNamed("Pilaster")
	local pilOk = #pil == 4
	local xs = {}
	for _, p in ipairs(pil) do
		table.insert(xs, math.floor(math.abs(lp(p).X) + 0.5))
		if not (white(p) and p.Size.Y >= 12 and p.Size.Y <= 14) then pilOk = false end
	end
	table.sort(xs)
	check("4 white pilasters, 12-14 high, at x +-10 and +-23", pilOk and xs[1] == 10 and xs[2] == 10 and xs[3] == 23 and xs[4] == 23, table.concat(xs, ","))
	local plinths = allNamed("PierPlinth")
	local maroon = #plinths == 4
	for _, p in ipairs(plinths) do
		local r, g, b = rgb(p)
		if not (r >= 90 and r <= 130 and g <= 60 and b <= 55) then maroon = false end
	end
	check("4 maroon PierPlinth bases", maroon, tostring(#plinths))
	local lowE, midE = anchor("EntabLow"), anchor("EntabMid")
	check("stepped white entablature: EntabLow 44-50 wide at y 26, EntabMid 24-28 wide and higher",
		lowE ~= nil and midE ~= nil and lowE.Size.X >= 44 and lowE.Size.X <= 50 and midE.Size.X >= 24 and midE.Size.X <= 28 and midE.Position.Y > lowE.Position.Y + 1.5
			and near(lowE.Position.Y, B + 20, 1.2),
		lowE and midE and (fmt(lowE.Size.X) .. "/" .. fmt(midE.Size.X)) or "missing")
	check("coat-of-arms Crest on the axis below the rose", (anchor("Crest") ~= nil) and math.abs(lp(anchor("Crest")).X) < 0.6 and anchor("Crest").Position.Y < (anchor("Rose") and anchor("Rose").Position.Y or 0),
		anchor("Crest") and fmt(anchor("Crest").Position.Y) or "missing")
	local sw = allNamed("ShoulderWin_Pane")
	check("2 ShoulderWin twin-arched windows at x +-27..30", #sw == 2 and math.abs(lp(sw[1]).X) >= 27 and math.abs(lp(sw[1]).X) <= 30 and math.abs(lp(sw[2]).X) >= 27 and math.abs(lp(sw[2]).X) <= 30,
		tostring(#sw))
	check("6 ShoulderSlit square slits (3 per shoulder) high on the shoulders", #allNamed("ShoulderSlit") == 6 and (function()
		for _, p in ipairs(allNamed("ShoulderSlit")) do if not near(p.Position.Y, B + 19.8, 2) then return false end end
		return true
	end)(), tostring(#allNamed("ShoulderSlit")))
	check("2 MidWin narrow arched windows on the second step", #allNamed("MidWin_Pane") == 2, tostring(#allNamed("MidWin_Pane")))
	-- steps and flank walls
	local risers = allNamed("StairRiser")
	local tops, widest, okH = {}, 0, #risers == 6
	for _, p in ipairs(risers) do
		table.insert(tops, topY(p))
		widest = math.max(widest, p.Size.X)
		if p.Size.Y < 0.9 or p.Size.Y > 1.05 then okH = false end
	end
	table.sort(tops)
	local stepsOk = #tops == 6
	for i = 1, #tops do if not near(tops[i], i, 0.1) then stepsOk = false end end
	check("StairRiser: 6 risers of 1 stud, tops at y 1..6", okH and stepsOk, #risers .. " risers")
	check("the stair is 52+ studs wide (the full portico) and terracotta", widest >= 52 and (function()
		for _, p in ipairs(risers) do
			local r, _, b = rgb(p)
			if not (r >= 170 and r - b >= 60) then return false end
		end
		return #risers > 0
	end)(), fmt(widest))
	local flank = allNamed("FlankWall")
	check("2 cream FlankWall runs beside the stair (|x| 28..52, 20+ long)", #flank == 2 and (function()
		for _, p in ipairs(flank) do
			if not (cream(p) and p.Size.X >= 20 and math.abs(lp(p).X) >= 36 and math.abs(lp(p).X) <= 44) then return false end
		end
		return true
	end)(), tostring(#flank))
	check("2 maroon FlankWallBase stripes", #allNamed("FlankWallBase") == 2)
	check("8+ StairTopiary cones on the flank walls", #allNamed("StairTopiary") >= 8, tostring(#allNamed("StairTopiary")))
	local pod = anchor("Podium")
	check("Podium top is the portico floor (y 6)", pod ~= nil and near(topY(pod), B, 0.06), pod and fmt(topY(pod)) or "missing")
end

------------------------------------------------------------------ chapel: nave, transept, side wing (annex), dome
if group("chapel") then
	local nave = anchor("NaveBlock")
	check("NaveBlock: 44-48 wide, 54+ deep, 28 high", nave ~= nil and nave.Size.X >= 44 and nave.Size.X <= 48 and nave.Size.Z >= 54 and near(topY(nave), 28, 0.6),
		nave and string.format("%s x %s, top %s", fmt(nave.Size.X), fmt(nave.Size.Z), fmt(topY(nave))) or "missing")
	check("5+ tall arched windows on each nave side", #allNamed("NaveWinE_Pane") >= 5 and #allNamed("NaveWinW_Pane") >= 5,
		#allNamed("NaveWinE_Pane") .. "/" .. #allNamed("NaveWinW_Pane"))
	-- REPLACED (board): "low east AnnexBlock between x 34 and 50" (height <= 14). The board's side wing (chapel extension and auxiliary
	-- rooms) is a long green-roofed block east of the chapel, behind the facade's low east wing.
	local annex = anchor("AnnexBlock")
	check("side wing: AnnexBlock east of the chapel, x 36..78, 14-20 high, 36+ deep", annex ~= nil and lp(annex).X - annex.Size.X / 2 >= 36 and lp(annex).X + annex.Size.X / 2 <= 78
		and annex.Size.Y >= 14 and annex.Size.Y <= 20 and annex.Size.Z >= 36,
		annex and string.format("x %s..%s h %s d %s", fmt(lp(annex).X - annex.Size.X / 2), fmt(lp(annex).X + annex.Size.X / 2), fmt(annex.Size.Y), fmt(annex.Size.Z)) or "missing")
	local ad = anchor("AnnexDoor_Pane")
	check("annex door is 8+ studs high", ad ~= nil and ad.Size.Y + ad.Size.X / 2 >= 8.4, ad and fmt(ad.Size.Y + ad.Size.X / 2) or "missing")
	check("the old east wing is gone (EastWingBlock, EastWingRoof, WingBigWin)", #allNamed("EastWingBlock") == 0 and #allNamed("EastWingRoof") == 0 and #allPrefix("WingBigWin") == 0)
	-- REPLACED (board): the five roofs were "dark forest green (R <= 50, G 75..105, B <= 70), not teal"; now the board's teal-green.
	for _, name in ipairs({ "NaveRoofL", "MonasteryRoofL", "AnnexRoof", "WalkwayRoof", "MonasteryReturnRoofL" }) do
		local p = anchor(name)
		check(name .. " is the board's green (R 55..95, G 100..135, B 90..125)", p ~= nil and boardGreen(p), p and tostring(p.Color) or "missing")
	end
	local nr = anchor("NaveRoofL")
	check("nave roof ridge stays below the facade apex (y 47)", nr ~= nil and topY(nr) < B + 41 - 2, nr and fmt(topY(nr)) or "missing")
	-- NEW (board): transept arms under the dome and the chapel's west side block (green hip roofs around the dome in the 3-D view).
	local tw, te = anchor("TranseptW"), anchor("TranseptE")
	check("TranseptW and TranseptE stick out past the nave walls (|x| 32+), around the dome's z", tw ~= nil and te ~= nil and select(1, extent(tw, "X")) <= -32 and select(2, extent(te, "X")) >= 32
		and math.abs(lp(tw).Z - lp(te).Z) < 1, tw and te and (fmt(lp(tw).Z) .. "/" .. fmt(lp(te).Z)) or "missing")
	local ww = anchor("ChapelWestWing")
	check("ChapelWestWing: a side block west of the nave, x -50..-22, 14-20 high", ww ~= nil and select(1, extent(ww, "X")) >= -50 and select(2, extent(ww, "X")) <= -22 and ww.Size.Y >= 14 and ww.Size.Y <= 20,
		ww and fmt(lp(ww).X) or "missing")
	-- REPLACED (board): "Dome: a cream ball 15-17 studs across over the nave rear (x within 1, z -53..-47)". The site-plan inset draws the
	-- dome circle about 20 studs across, 40 behind the facade (compressed 0.84 to fit the slot: z about -34..-42); the 3-D view makes it
	-- about as wide as the facade's centre block.
	local dome = anchor("Dome")
	check("Dome: a cream ball 21-24 studs across over the crossing (x within 1, z -45..-35)",
		dome ~= nil and cream(dome) and dome.Size.X >= 21 and dome.Size.X <= 24 and math.abs(lp(dome).X) < 1 and lp(dome).Z >= -45 and lp(dome).Z <= -35,
		dome and string.format("d %s at (%s, %s) %s", fmt(dome.Size.X), fmt(lp(dome).X), fmt(lp(dome).Z), tostring(dome.Color)) or "missing")
	check("Dome has 8 ribs of 6 segments (48+ Dome_Rib parts)", #allPrefix("Dome_Rib") >= 48, tostring(#allPrefix("Dome_Rib")))
	-- REPLACED (board): "DomeDrum is a round cylinder 16-19 across, taller than 8" -> 23-27 across (it carries the 21-24 dome).
	local drum = anchor("DomeDrum")
	check("DomeDrum is a round cylinder 23-27 across, taller than 8", drum ~= nil and drum.Shape == Enum.PartType.Cylinder and drum.Size.Y >= 23 and drum.Size.Y <= 27 and drum.Size.X >= 8,
		drum and string.format("d %s h %s", fmt(drum.Size.Y), fmt(drum.Size.X)) or "missing")
	-- REPLACED (board): "4 arched DrumWin windows in the drum" (exactly 4). The 3-D view shows a ring of small arched windows: 8.
	check("8 arched DrumWin windows in the drum", #allNamed("DrumWin_Pane") == 8, tostring(#allNamed("DrumWin_Pane")))
	-- REPLACED (board): "dome cross tops out between y 56 and 62" -> 64..71 (the bigger dome and lantern).
	local cs = anchor("DomeCrossStem")
	check("dome cross tops out between y 64 and 71", cs ~= nil and topY(cs) >= 64 and topY(cs) <= 71, cs and fmt(topY(cs)) or "missing")
	check("the old square DrumBlock tower is gone", #allNamed("DrumBlock") == 0)
end

------------------------------------------------------------------ monastery: the 2-storey L (N and W), walkway, veranda, courtyard
if group("monastery") then
	-- REPLACED (board): "MonasteryBlock: 60+ long, 24 high (two storeys of 12), x -102..-34, front face z -8". On the board the 2-storey
	-- wing runs along the NORTH of the courtyard, from the west edge to behind the chapel.
	local mb = anchor("MonasteryBlock")
	check("MonasteryBlock: the north leg, 70+ long, 24 high, x min <= -100, x max -34..-24, south face z -64 (+-1), back z <= -84",
		mb ~= nil and mb.Size.X >= 70 and near(topY(mb), 24, 0.6) and lp(mb).X - mb.Size.X / 2 <= -100 and lp(mb).X + mb.Size.X / 2 >= -34 and lp(mb).X + mb.Size.X / 2 <= -24
			and near(lp(mb).Z + mb.Size.Z / 2, -64, 1) and lp(mb).Z - mb.Size.Z / 2 <= -84,
		mb and string.format("x %s..%s top %s z %s..%s", fmt(lp(mb).X - mb.Size.X / 2), fmt(lp(mb).X + mb.Size.X / 2), fmt(topY(mb)), fmt(lp(mb).Z - mb.Size.Z / 2), fmt(lp(mb).Z + mb.Size.Z / 2)) or "missing")
	check("24+ MonasteryWin panes (paired louvred windows in two rows)", #allNamed("MonasteryWin") >= 24, tostring(#allNamed("MonasteryWin")))
	local roofs = allNamed("WalkwayRoof")
	check("covered Walkway along the wing: roof 12-13 up, 8+ posts", #roofs == 1 and roofs[1].Position.Y >= 12 and roofs[1].Position.Y <= 13 and #allNamed("WalkwayPost") >= 8,
		#roofs .. " roof, " .. #allNamed("WalkwayPost") .. " posts")
	local um, tealOk = allNamed("Umbrella"), true
	for _, p in ipairs(um) do
		local r, g, b = rgb(p)
		if not (r <= 50 and g >= 90 and b >= 80) then tealOk = false end
	end
	check("5 teal Umbrella canopies", #um == 5 and tealOk, tostring(#um))
	local ret = anchor("MonasteryReturn")
	check("MonasteryReturn: the L-shaped return wing, x -102..-80, reaching z <= -66",
		ret ~= nil and lp(ret).X - ret.Size.X / 2 <= -100 and lp(ret).X + ret.Size.X / 2 <= -78 and lp(ret).Z - ret.Size.Z / 2 <= -66,
		ret and string.format("x %s..%s zmin %s", fmt(lp(ret).X - ret.Size.X / 2), fmt(lp(ret).X + ret.Size.X / 2), fmt(lp(ret).Z - ret.Size.Z / 2)) or "missing")
	check("NEW (board): the return is the west leg of the L, running south to z -40 or further", ret ~= nil and lp(ret).Z + ret.Size.Z / 2 >= -40,
		ret and fmt(lp(ret).Z + ret.Size.Z / 2) or "missing")
	local lawn = anchor("CourtLawn")
	check("raised CourtLawn (0.3+ thick so the grass blades are hidden) in front of the wing, x -100..-52", lawn ~= nil and lawn.Size.Y >= 0.3 and lp(lawn).X - lawn.Size.X / 2 >= -101 and lp(lawn).X + lawn.Size.X / 2 <= -50,
		lawn and string.format("x %s..%s", fmt(lp(lawn).X - lawn.Size.X / 2), fmt(lp(lawn).X + lawn.Size.X / 2)) or "missing")
	check("8+ court Topiary cones", #allNamed("Topiary") >= 8, tostring(#allNamed("Topiary")))
	-- REPLACED (board): "white CourtStatue in the court (x -62..-46)". The board's statue stands in the north-west of the courtyard.
	local cst = anchor("CourtStatue")
	check("white CourtStatue inside the courtyard (x -92..-52, z -60..30)", cst ~= nil and white(cst) and lp(cst).X >= -92 and lp(cst).X <= -52 and lp(cst).Z >= -60 and lp(cst).Z <= 30,
		cst and (fmt(lp(cst).X) .. "," .. fmt(lp(cst).Z)) or "missing")
	-- REPLACED (board): "the old veranda is gone (VerandaFloor, VerandaCanopy, VerandaPost)". The board draws a covered veranda (walkway)
	-- along the WEST edge, so the pin now asserts the board's veranda instead (the Slice 04 part names stay unused).
	check("the Slice 04 veranda names stay unused (VerandaFloor, VerandaCanopy, VerandaPost)", #allNamed("VerandaFloor") == 0 and #allNamed("VerandaCanopy") == 0 and #allNamed("VerandaPost") == 0)
	local deck = anchor("VerandaDeck")
	check("covered veranda on the west edge: VerandaDeck x max <= -90, 60+ long in z", deck ~= nil and select(2, extent(deck, "X")) <= -90 and deck.Size.Z >= 60,
		deck and string.format("x max %s len %s", fmt(select(2, extent(deck, "X"))), fmt(deck.Size.Z)) or "missing")
	check("8+ VerandaColumn posts, each 8+ tall", #allNamed("VerandaColumn") >= 8 and (function()
		for _, p in ipairs(allNamed("VerandaColumn")) do if p.Size.Y < 8 then return false end end
		return true
	end)(), tostring(#allNamed("VerandaColumn")))
	local vr = anchor("VerandaRoofL")
	check("VerandaRoofL is the board's green", vr ~= nil and boardGreen(vr), vr and tostring(vr.Color) or "missing")
	local gz = anchor("GazeboRoof")
	check("a green Gazebo in the courtyard (GazeboRoof board green, 4 GazeboPost)", gz ~= nil and boardGreen(gz) and #allNamed("GazeboPost") == 4 and lp(gz).X >= -94 and lp(gz).X <= -50,
		gz and fmt(lp(gz).X) or "missing")
	local cw = anchor("CourtWall")
	check("cream CourtWall closes the courtyard on the south (z 28..40)", cw ~= nil and cream(cw) and lp(cw).Z >= 28 and lp(cw).Z <= 40 and cw.Size.X >= 30,
		cw and fmt(lp(cw).Z) or "missing")
end

------------------------------------------------------------------ rectory: the auxiliary building along the east edge
if group("rectory") then
	local rb = anchor("RectoryBlock")
	check("RectoryBlock: 2 storeys (top 20..25) along the east edge, x 80..108, 70+ long in z", rb ~= nil and select(1, extent(rb, "X")) >= 80 and select(2, extent(rb, "X")) <= 108
		and rb.Size.Z >= 70 and topY(rb) >= 20 and topY(rb) <= 25,
		rb and string.format("x %s..%s len %s top %s", fmt(select(1, extent(rb, "X"))), fmt(select(2, extent(rb, "X"))), fmt(rb.Size.Z), fmt(topY(rb))) or "missing")
	local rr = anchor("RectoryRoof")
	check("RectoryRoof is the board's green and sits on the block", rr ~= nil and rb ~= nil and boardGreen(rr) and rr.Position.Y > topY(rb) - 0.5, rr and tostring(rr.Color) or "missing")
	check("16+ RectoryWin panes", #allNamed("RectoryWin") >= 16, tostring(#allNamed("RectoryWin")))
	local can = anchor("RectoryCanopy")
	check("RectoryCanopy along the west face, 9..12 up", can ~= nil and rb ~= nil and lp(can).X < lp(rb).X and can.Position.Y >= 9 and can.Position.Y <= 12, can and fmt(can.Position.Y) or "missing")
	local rd = allNamed("RectoryDoor_Pane")
	check("2+ rectory doors, 8+ high", #rd >= 2 and rd[1].Size.Y + rd[1].Size.X / 2 >= 8.4, tostring(#rd))
	local rn = anchor("RectoryNorth")
	check("RectoryNorth: the north leg along the north edge (z <= -70), east of the nave (x min >= 26)", rn ~= nil and select(1, extent(rn, "Z")) <= -80 and select(1, extent(rn, "X")) >= 26,
		rn and fmt(lp(rn).Z) or "missing")
end

------------------------------------------------------------------ grounds: shrine, props, drive, island, perimeter wall, palms
if group("grounds") then
	-- Kept from Revision 1 (the plan does not retire it): the plain Marian billboard, moved off the board's palm island.
	local base, panel = anchor("BillboardBase"), anchor("BillboardPanel_Pane")
	check("BillboardBase (dark lava stone) in the paved forecourt (x +-52, z 0..92)", base ~= nil and math.abs(lp(base).X) <= 50 and lp(base).Z >= 4 and lp(base).Z <= 90 and (function()
		local r, g, b = rgb(base)
		return r <= 110 and g <= 110 and b <= 110
	end)(), base and string.format("(%s, %s)", fmt(lp(base).X), fmt(lp(base).Z)) or "missing")
	check("BillboardPanel: thin arched pale-blue panel, 8+ high, standing on the base and facing +Z", panel ~= nil and base ~= nil and panel.Size.Z <= 1 and panel.Size.Y >= 8
		and select(3, rgb(panel)) >= 150 and panel.Position.Y - panel.Size.Y / 2 >= topY(base) - 1, panel and fmt(panel.Size.Y) or "missing")
	-- REPLACED (board): "the shrine gate is kept at (80, -51) and 8+ studs high". The board puts the outdoor shrine at the SE corner.
	local gate = anchor("ShrineGate_Pane")
	check("the shrine gate stands in the SE corner (x 70..104, z 50..82), 8+ studs high", gate ~= nil and lp(gate).X >= 70 and lp(gate).X <= 104 and lp(gate).Z >= 50 and lp(gate).Z <= 82
		and gate.Size.Y + gate.Size.X / 2 >= 8, gate and (fmt(lp(gate).X) .. "," .. fmt(lp(gate).Z)) or "missing")
	local tabletText, scaled = 0, 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text:find("THE TEN COMMANDMENTS", 1, true) then
			tabletText += 1
			local g = d:FindFirstAncestorOfClass("SurfaceGui")
			local part = g and g.Parent
			if not (g and g.Face == Enum.NormalId.Back and part and part:IsA("BasePart") and part.CFrame.LookVector:Dot(Vector3.new(0, 0, -1)) > 0.99) then scaled += 100 end
		end
	end
	check("both shrine tablets read THE TEN COMMANDMENTS", tabletText == 2, tostring(tabletText))
	check("NEW (board): the tablets face south (+Z), as the shrine door does", tabletText == 2 and scaled == 0)
	local fixed = 0
	local labels = 0
	for _, d in ipairs(site:GetDescendants()) do
		local keptAncestor = false
		for _, k in ipairs({ "Guide", "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney", "LocalNPCs" }) do
			if d:FindFirstAncestor(k) then keptAncestor = true end
		end
		if d:IsA("TextLabel") and not isRig(d) and not keptAncestor then
			labels += 1
			if d.TextScaled == false and d.TextSize >= 12 then fixed += 1 end
		end
	end
	check("NEW (task rule): every built text label uses a fixed TextSize (12+), not TextScaled", labels >= 2 and fixed == labels, fixed .. " of " .. labels)
	local body = anchor("ShrineBody")
	check("NEW (board): brick-red ShrineBody with a green gable roof (ShrineRoofL)", body ~= nil and maroonish(body) and anchor("ShrineRoofL") ~= nil and boardGreen(anchor("ShrineRoofL")),
		body and tostring(body.Color) or "missing")
	for _, name in ipairs({ "Pews", "Kneeler", "Candles", "HistoryPanels" }) do
		local f = site:FindFirstChild(name)
		local n = 0
		if f then for _, d in ipairs(f:GetDescendants()) do if d:IsA("BasePart") then n += 1 end end end
		check("required prop folder " .. name .. " holds parts", f ~= nil and n > 0, tostring(n))
	end
	check("4 pews, 10 candle flames, 3 history panels in the east prayer garden (x 53..110)", #allNamed("PewSeat") == 4 and #allNamed("Flame") == 10 and #allPrefix("HistoryPanel") >= 3
		and (function()
			for _, p in ipairs(allNamed("PewSeat")) do if lp(p).X < 53 then return false end end
			return true
		end)(), #allNamed("PewSeat") .. " pews, " .. #allNamed("Flame") .. " flames")
	-- NEW: the two pilgrims (builders/npcs.luau, not rebuilt here) keep a place: a pew seat under the seated one (75, 32), and a
	-- devotional statue just north of the kneeling one (80, -43.5) with open sky above her.
	local seatOk = false
	for _, p in ipairs(allNamed("PewSeat")) do
		if math.abs(lp(p).Z - 32) < 1.2 and math.abs(lp(p).X - 75) < p.Size.X / 2 and near(topY(p), 2.2, 0.15) then seatOk = true end
	end
	check("a PewSeat (top y 2.2) is under the seated pilgrim's spot (75, 32)", seatOk)
	local gs = anchor("GrottoStatue")
	check("GrottoStatue 3..10 studs north of the kneeling pilgrim's spot (80, -43.5)", gs ~= nil and math.abs(lp(gs).X - 80) <= 3 and lp(gs).Z <= -46.5 and lp(gs).Z >= -53.5,
		gs and (fmt(lp(gs).X) .. "," .. fmt(lp(gs).Z)) or "missing")
	do
		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { site }
		local hits = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(SITE_POS + Vector3.new(80, 30, -43.5)), Vector3.new(3, 50, 3), op)) do
			if not isRig(p) then table.insert(hits, p.Name) end
		end
		check("nothing stands over the kneeling pilgrim (80, -43.5) between y 5 and 55", #hits == 0, table.concat(hits, ",", 1, math.min(#hits, 4)))
	end
	-- NEW (board): the curved arrival driveway with a palm island, the perimeter wall, the palms.
	local isl = anchor("IslandLawn")
	check("IslandLawn: the palm island east of the walking lane (x 8..60, z 48..88), raised 0.4+", isl ~= nil and select(1, extent(isl, "X")) >= 8 and select(2, extent(isl, "X")) <= 60
		and lp(isl).Z >= 48 and lp(isl).Z <= 88 and topY(isl) >= 0.4, isl and (fmt(lp(isl).X) .. "," .. fmt(lp(isl).Z)) or "missing")
	local palms = allNamed("PalmTrunk")
	local onIsland = 0
	for _, p in ipairs(palms) do
		local l = lp(p)
		if l.X >= 8 and l.X <= 60 and l.Z >= 48 and l.Z <= 88 then onIsland += 1 end
	end
	check("5+ palms on the island and 15+ palms in all", onIsland >= 5 and #palms >= 15, onIsland .. " / " .. #palms)
	local de = anchor("DriveEast")
	check("DriveEast: asphalt from the forecourt to the shrine, 0.3+ thick (outside the Pavement region)", de ~= nil and de.Size.Y >= 0.3 and lp(de).X > 52, de and fmt(lp(de).X) or "missing")
	local walls = allNamed("PerimeterWall")
	local n, e, w, s = false, false, false, false
	local creamOk = #walls >= 4
	for _, p in ipairs(walls) do
		local x0, x1 = extent(p, "X")
		local z0, z1 = extent(p, "Z")
		if z0 <= -86 and x1 - x0 > 60 then n = true end
		if x1 >= 106 and z1 - z0 > 60 then e = true end
		if x0 <= -106 and z1 - z0 > 60 then w = true end
		if z1 >= 76 and x1 - x0 > 30 then s = true end
		if not cream(p) or p.Size.Y < 5 then creamOk = false end
	end
	check("cream PerimeterWall (5+ high) on the north, east, west and south edges", n and e and w and s and creamOk, string.format("N %s E %s W %s S %s cream %s", tostring(n), tostring(e), tostring(w), tostring(s), tostring(creamOk)))
	check("maroon WallBase stripes under the perimeter wall (4+)", #allNamed("WallBase") >= 4 and maroonish(allNamed("WallBase")[1]), tostring(#allNamed("WallBase")))
	for _, name in ipairs({ "Guide", "InfoPanel", "JeepStop" }) do
		check("kept object " .. name .. " is present", site:FindFirstChild(name) ~= nil)
	end
end

------------------------------------------------------------------ clear: keep-clear zones and the terrain rule
if group("clear") then
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Include
	overlap.FilterDescendantsInstances = { site }
	overlap.RespectCanCollide = true
	local keptNames = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
	local function builtBlockers(localPos, size)
		local names = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(SITE_POS + localPos), size, overlap)) do
			local top = p
			while top.Parent and top.Parent ~= site do top = top.Parent end
			if not keptNames[top.Name] and not isRig(p) and p.Size.Y > 0.5 then
				table.insert(names, (p:GetFullName():gsub("^Workspace%.Sites%.Site05_Carmel%.", "")))
			end
		end
		return names
	end
	local g = builtBlockers(Vector3.new(0, 5, 30), Vector3.new(8, 7, 8))
	check("the Guide's 8x8 stand zone (0, 30) is free of built geometry", #g == 0, table.concat(g, ", ", 1, math.min(#g, 4)))
	local j = builtBlockers(Vector3.new(-20, 5, 30), Vector3.new(8, 7, 8))
	check("the JeepStop zone (-20, 30) is free of built geometry", #j == 0, table.concat(j, ", ", 1, math.min(#j, 4)))
	local ip = builtBlockers(Vector3.new(12, 5, 24), Vector3.new(8, 7, 6))
	check("the InfoPanel zone (12, 24) is free of built geometry", #ip == 0, table.concat(ip, ", ", 1, math.min(#ip, 4)))
	local lane = builtBlockers(Vector3.new(0, 5, 62), Vector3.new(8, 7, 56))
	check("the walking lane from the road mouth to the Guide (x +-4, z 34..90) is clear", #lane == 0, table.concat(lane, ", ", 1, math.min(#lane, 4)))
	local jeep = builtBlockers(Vector3.new(-34, 4, 30), Vector3.new(11, 6, 17))
	check("NEW: the parked Jeepney's box (-34, 30) is free of built geometry", #jeep == 0, table.concat(jeep, ", ", 1, math.min(#jeep, 4)))
	local stray = {}
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA("BasePart") and not isRig(p) and p.Size.Y <= 0.2 and p.Position.Y <= 0.6 and p.Parent.Name ~= "JeepStop" then
			local l = lp(p)
			if p.Size.X > 3 and p.Size.Z > 3 and (l.X - p.Size.X / 2 < -52.6 or l.X + p.Size.X / 2 > 52.6 or l.Z - p.Size.Z / 2 < -0.6 or l.Z + p.Size.Z / 2 > 92.6) then
				table.insert(stray, string.format("%s x[%.0f,%.0f] z[%.0f,%.0f]", p.Name, l.X - p.Size.X / 2, l.X + p.Size.X / 2, l.Z - p.Size.Z / 2, l.Z + p.Size.Z / 2))
			end
		end
	end
	check("thin ground-level paving lies inside the repainted Pavement region (x +-52, z 0..92)", #stray == 0, table.concat(stray, "; ", 1, math.min(#stray, 3)))
end

return HttpService:JSONEncode(results)
