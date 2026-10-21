-- site05_check: the Slice 15 fidelity spec for Site 05 (Monastery of Our Lady of Mount Carmel), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site05_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site05_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site05.md "Revision 1 (Slice 15)": the 2018 frontal photo (outer facade 68 studs = 1130 px),
-- the OSM footprints and the elevated Velasquez photos, at massScale 2.5. The site pivot is yawed 180 degrees, but the builder
-- works in world-aligned local axes (origin = the pivot position), so every coordinate here is world position minus the site
-- position: local +Z = south = the facade side, +X = east. Heights are above the ground (y 0); the portico floor is B = 6.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(-300, 0, -600)
local B = 6 -- portico floor: 6 risers of 1 stud

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site05_Carmel")
check("Site05_Carmel exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
-- A stray drag in Studio once moved a whole site; it shows up as a dozen unrelated failures, so test the pivot first.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (-300, 0, -600), facing +Z (yawed 180)",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(0, 0, 1)) > 0.9999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
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
-- dark forest green roof (real roofs are (30,92,56)-ish; the Slice 04 teal (40,110,70) must fail)
local function forestGreen(p)
	local r, g, b = rgb(p)
	return r <= 50 and g >= 75 and g <= 105 and b <= 70
end
local function cream(p)
	local r, g, b = rgb(p)
	return r >= 225 and g >= 205 and b <= 215 and b >= 120
end
local function white(p)
	local r, g, b = rgb(p)
	return r >= 225 and g >= 220 and b >= 205
end

------------------------------------------------------------------ Facade: three-step silhouette (frontal photo)
do
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
	local stem = anchor("CrossStem")
	check("ringed cross: stem top at y 52 (+-2) and 8 CrossRing segments", stem ~= nil and near(topY(stem), B + 46, 2) and #allNamed("CrossRing") == 8,
		stem and fmt(topY(stem)) or "missing")
	local rose = anchor("Rose")
	check("rose window on the axis at y 31 (+-1.5), 7-9 studs across", rose ~= nil and math.abs(lp(rose).X) < 0.6 and near(rose.Position.Y, B + 25, 1.5) and rose.Size.Y >= 7 and rose.Size.Y <= 9,
		rose and string.format("x %s y %s d %s", fmt(lp(rose).X), fmt(rose.Position.Y), fmt(rose.Size.Y)) or "missing")
	local niche = anchor("NicheStatue")
	check("Marian niche statue on the axis between y 37 and 41", niche ~= nil and math.abs(lp(niche).X) < 0.6 and niche.Position.Y >= B + 31 and niche.Position.Y <= B + 35,
		niche and fmt(niche.Position.Y) or "missing")
	check("the old pyramid tiers and the 3-spoke rose are gone (Tier2, Tier3, Register2, RoseSpoke)",
		#allNamed("Tier2") == 0 and #allNamed("Tier3") == 0 and #allNamed("Register2") == 0 and #allNamed("RoseSpoke") == 0)
end

------------------------------------------------------------------ Portico, pillars, shoulder windows
do
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
	local low, midE = anchor("EntabLow"), anchor("EntabMid")
	check("stepped white entablature: EntabLow 44-50 wide at y 26, EntabMid 24-28 wide and higher",
		low ~= nil and midE ~= nil and low.Size.X >= 44 and low.Size.X <= 50 and midE.Size.X >= 24 and midE.Size.X <= 28 and midE.Position.Y > low.Position.Y + 1.5
			and near(low.Position.Y, B + 20, 1.2),
		low and midE and (fmt(low.Size.X) .. "/" .. fmt(midE.Size.X)) or "missing")
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
end

------------------------------------------------------------------ Steps and flank walls
do
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
	check("StairRiser: 6 risers of 1 stud, tops at y 1..6", okH and stepsOk, #risers .. " risers, tops " .. (function()
		local s = {}
		for _, t in ipairs(tops) do table.insert(s, fmt(t)) end
		return table.concat(s, ",")
	end)())
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

------------------------------------------------------------------ Nave, annex, roofs
do
	local nave = anchor("NaveBlock")
	check("NaveBlock: 44-48 wide, 54+ deep, 28 high", nave ~= nil and nave.Size.X >= 44 and nave.Size.X <= 48 and nave.Size.Z >= 54 and near(topY(nave), 28, 0.6),
		nave and string.format("%s x %s, top %s", fmt(nave.Size.X), fmt(nave.Size.Z), fmt(topY(nave))) or "missing")
	check("5+ tall arched windows on each nave side", #allNamed("NaveWinE_Pane") >= 5 and #allNamed("NaveWinW_Pane") >= 5,
		#allNamed("NaveWinE_Pane") .. "/" .. #allNamed("NaveWinW_Pane"))
	local annex = anchor("AnnexBlock")
	check("low east AnnexBlock between x 34 and 50", annex ~= nil and lp(annex).X - annex.Size.X / 2 >= 33.5 and lp(annex).X + annex.Size.X / 2 <= 50.5 and annex.Size.Y <= 14,
		annex and string.format("x %s..%s h %s", fmt(lp(annex).X - annex.Size.X / 2), fmt(lp(annex).X + annex.Size.X / 2), fmt(annex.Size.Y)) or "missing")
	local ad = anchor("AnnexDoor_Pane")
	check("annex door is 8+ studs high", ad ~= nil and ad.Size.Y + ad.Size.X / 2 >= 8.4, ad and fmt(ad.Size.Y + ad.Size.X / 2) or "missing")
	check("the old east wing is gone (EastWingBlock, EastWingRoof, WingBigWin)", #allNamed("EastWingBlock") == 0 and #allNamed("EastWingRoof") == 0 and #allPrefix("WingBigWin") == 0)
	for _, name in ipairs({ "NaveRoofL", "MonasteryRoofL", "AnnexRoof", "WalkwayRoof", "MonasteryReturnRoofL" }) do
		local p = anchor(name)
		check(name .. " is dark forest green (R <= 50, G 75..105, B <= 70), not teal", p ~= nil and forestGreen(p), p and tostring(p.Color) or "missing")
	end
	local nr = anchor("NaveRoofL")
	check("nave roof ridge stays below the facade apex (y 47)", nr ~= nil and topY(nr) < B + 41 - 2, nr and fmt(topY(nr)) or "missing")
end

------------------------------------------------------------------ Dome over the nave rear
do
	local dome = anchor("Dome")
	check("Dome: a cream ball 15-17 studs across over the nave rear (x within 1, z -53..-47)",
		dome ~= nil and cream(dome) and dome.Size.X >= 15 and dome.Size.X <= 17 and math.abs(lp(dome).X) < 1 and lp(dome).Z >= -53 and lp(dome).Z <= -47,
		dome and string.format("d %s at (%s, %s) %s", fmt(dome.Size.X), fmt(lp(dome).X), fmt(lp(dome).Z), tostring(dome.Color)) or "missing")
	check("Dome has 8 ribs of 6 segments (48+ Dome_Rib parts)", #allPrefix("Dome_Rib") >= 48, tostring(#allPrefix("Dome_Rib")))
	local drum = anchor("DomeDrum")
	check("DomeDrum is a round cylinder 16-19 across, taller than 8", drum ~= nil and drum.Shape == Enum.PartType.Cylinder and drum.Size.Y >= 16 and drum.Size.Y <= 19 and drum.Size.X >= 8,
		drum and string.format("d %s h %s", fmt(drum.Size.Y), fmt(drum.Size.X)) or "missing")
	check("4 arched DrumWin windows in the drum", #allNamed("DrumWin_Pane") == 4, tostring(#allNamed("DrumWin_Pane")))
	local cs = anchor("DomeCrossStem")
	check("dome cross tops out between y 56 and 62", cs ~= nil and topY(cs) >= 56 and topY(cs) <= 62, cs and fmt(topY(cs)) or "missing")
	check("the old square DrumBlock tower is gone", #allNamed("DrumBlock") == 0)
end

------------------------------------------------------------------ Monastery wing (west), walkway, court
do
	local mb = anchor("MonasteryBlock")
	check("MonasteryBlock: 60+ long, 24 high (two storeys of 12), x -102..-34, front face z -8",
		mb ~= nil and mb.Size.X >= 60 and near(topY(mb), 24, 0.6) and lp(mb).X - mb.Size.X / 2 <= -100 and lp(mb).X + mb.Size.X / 2 >= -36 and lp(mb).X + mb.Size.X / 2 <= -33
			and near(lp(mb).Z + mb.Size.Z / 2, -8, 0.6),
		mb and string.format("x %s..%s top %s front z %s", fmt(lp(mb).X - mb.Size.X / 2), fmt(lp(mb).X + mb.Size.X / 2), fmt(topY(mb)), fmt(lp(mb).Z + mb.Size.Z / 2)) or "missing")
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
	local lawn = anchor("CourtLawn")
	check("raised CourtLawn (0.3+ thick so the grass blades are hidden) in front of the wing, x -100..-52", lawn ~= nil and lawn.Size.Y >= 0.3 and lp(lawn).X - lawn.Size.X / 2 >= -101 and lp(lawn).X + lawn.Size.X / 2 <= -50,
		lawn and string.format("x %s..%s", fmt(lp(lawn).X - lawn.Size.X / 2), fmt(lp(lawn).X + lawn.Size.X / 2)) or "missing")
	check("8+ court Topiary cones", #allNamed("Topiary") >= 8, tostring(#allNamed("Topiary")))
	local cst = anchor("CourtStatue")
	check("white CourtStatue in the court (x -62..-46)", cst ~= nil and white(cst) and lp(cst).X >= -62 and lp(cst).X <= -46, cst and fmt(lp(cst).X) or "missing")
	check("the old veranda is gone (VerandaFloor, VerandaCanopy, VerandaPost)", #allNamed("VerandaFloor") == 0 and #allNamed("VerandaCanopy") == 0 and #allNamed("VerandaPost") == 0)
end

------------------------------------------------------------------ Grounds: Marian billboard, forecourt, shrine, props
do
	local base, panel = anchor("BillboardBase"), anchor("BillboardPanel_Pane")
	check("BillboardBase (dark lava stone) in the paved forecourt (x +-52, z 0..92)", base ~= nil and math.abs(lp(base).X) <= 50 and lp(base).Z >= 4 and lp(base).Z <= 90 and (function()
		local r, g, b = rgb(base)
		return r <= 110 and g <= 110 and b <= 110
	end)(), base and string.format("(%s, %s)", fmt(lp(base).X), fmt(lp(base).Z)) or "missing")
	check("BillboardPanel: thin arched pale-blue panel, 8+ high, standing on the base and facing +Z", panel ~= nil and base ~= nil and panel.Size.Z <= 1 and panel.Size.Y >= 8
		and select(3, rgb(panel)) >= 150 and panel.Position.Y - panel.Size.Y / 2 >= topY(base) - 1, panel and fmt(panel.Size.Y) or "missing")
	local gate = anchor("ShrineGate_Pane")
	check("the shrine gate is kept at (80, -51) and 8+ studs high", gate ~= nil and near(lp(gate).X, 80, 2) and near(lp(gate).Z, -51, 2) and gate.Size.Y >= 5, gate and fmt(lp(gate).X) or "missing")
	local tabletText = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text:find("THE TEN COMMANDMENTS", 1, true) then tabletText += 1 end
	end
	check("both shrine tablets read THE TEN COMMANDMENTS", tabletText == 2, tostring(tabletText))
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
	for _, name in ipairs({ "Guide", "InfoPanel", "JeepStop" }) do
		check("kept object " .. name .. " is present", site:FindFirstChild(name) ~= nil)
	end
end

------------------------------------------------------------------ Keep-clear zones and the terrain rule
do
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
