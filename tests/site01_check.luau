-- site01_check: the Slice 14 fidelity spec for Site 01 (Cathedral + Plaza Independencia), written BEFORE each rework pass.
-- Studio copy: ServerStorage.Checks.site01_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site01_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number below comes from briefs/site01.md "Slice 14 rework" (OSM footprints + the 2023-2025 photos), converted at
-- massScale 2.0 (2 studs per metre). Anchors are ONE uniquely named BasePart each, searched through the whole site.
-- Two levels (Dec 2025 drone photos): the church, its wing, the car-park forecourt and the hedged garden stand on a podium
-- RAISE studs above the ground; a retaining wall with two flights of steps either side of a central fountain drops to the lower
-- Plaza Independencia at ground level (y 0), where the spawn, the covered court, the pergola garden and the CreditsBoard are.
-- Pass 4 (ground photo of the plaza): terracotta paving, fountain + statue on the axis with a kiosk each side at the top of the
-- steps, a round pergola garden, a vaulted covered court with a shade tree; no market tents and no vans on the lower plaza.
local HttpService = game:GetService("HttpService")
local RAISE = 5 -- podium top (upper level), studs above the ground; must equal builders/site01.luau RAISE
local WALL_Z = 48 -- the podium's south face, the retaining wall

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site01_Cathedral")
check("Site01_Cathedral exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
-- Every coordinate below is site-local = world, so the pivot must sit at the SiteData pos (0, 0, 0) facing +Z. A stray drag in
-- Studio once moved the whole site by (-57.5, 20.3) and showed up only as a dozen unrelated failures.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (0, 0, 0), facing +Z", pv.Position.Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(0, 0, 1)) > 0.9999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
end

local function anchor(name)
	-- the first BasePart with this exact name (a component Model of the same name, e.g. "Dome", must not shadow it)
	for _, d in ipairs(site:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") then return d end
	end
	return nil
end
local function allNamed(name)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") then table.insert(list, d) end
	end
	return list
end
local function countNamed(name, shape)
	local n = 0
	for _, d in ipairs(allNamed(name)) do
		if shape == nil or d.Shape == shape then n += 1 end
	end
	return n
end
local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function topY(p) return p.Position.Y + p.Size.Y / 2 end
-- Axis-aligned world bounds of a part (its 8 corners): the Revision 5 checks need world extents of the rotated west wings.
local function worldBox(p)
	local minX, maxX, minY, maxY, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge, math.huge, -math.huge
	local h = p.Size / 2
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local w = p.CFrame:PointToWorldSpace(Vector3.new(sx * h.X, sy * h.Y, sz * h.Z))
				minX, maxX = math.min(minX, w.X), math.max(maxX, w.X)
				minY, maxY = math.min(minY, w.Y), math.max(maxY, w.Y)
				minZ, maxZ = math.min(minZ, w.Z), math.max(maxZ, w.Z)
			end
		end
	end
	return { x0 = minX, x1 = maxX, y0 = minY, y1 = maxY, z0 = minZ, z1 = maxZ }
end

------------------------------------------------------------------ Proportions (OSM + P3)
local facade, tower = anchor("FacadeWall"), anchor("TowerBody")
check("FacadeWall width 38-46 studs (real ~20.5-22 m)", facade ~= nil and facade.Size.X >= 38 and facade.Size.X <= 46, fmt(facade and facade.Size.X))
check("TowerBody width 24-30 studs (about 38% of the frontage in P3)", tower ~= nil and tower.Size.X >= 24 and tower.Size.X <= 30, fmt(tower and tower.Size.X))
check("tower stands on the viewer's LEFT (-X) of the facade", facade ~= nil and tower ~= nil and tower.Position.X < facade.Position.X - 20,
	facade and tower and (fmt(tower.Position.X) .. " vs " .. fmt(facade.Position.X)) or "parts missing")
local transept = anchor("TranseptBlock")
check("TranseptBlock spans 76-100 studs (real ~48 m = 96, compressed)", transept ~= nil and transept.Size.X >= 76 and transept.Size.X <= 100, fmt(transept and transept.Size.X))
local apse = anchor("Apse")
check("Apse back reaches z <= -94 (the church uses the footprint depth)", apse ~= nil and apse.Position.Z - apse.Size.Z / 2 <= -94,
	apse and fmt(apse.Position.Z - apse.Size.Z / 2) or "missing")
local naveRoof = anchor("NaveRoof")
local towerCross, belfryCross = anchor("TowerCrossV"), anchor("BelfryCrossV")
if towerCross and belfryCross then
	local ratio = (topY(towerCross) - RAISE) / (topY(belfryCross) - RAISE)
	check("tower is 1.15-1.5x the facade apex (P3 photo ratio ~1.3-1.4)", ratio >= 1.15 and ratio <= 1.5, fmt(ratio))
else
	check("tower is 1.15-1.5x the facade apex (P3 photo ratio ~1.3-1.4)", false, "TowerCrossV / BelfryCrossV missing")
end
local tiers = 0
for _, d in ipairs(site:GetDescendants()) do
	if d:IsA("BasePart") and d.Name:match("^Tier%d+1$") then tiers += 1 end
end
check("tower has 7 octagonal tiers (Revision 5, blueprint: 7-tier octagonal bell tower)", tiers == 7, tostring(tiers))

------------------------------------------------------------------ Colours (P1 Dec 2025 domes, P3 walls)
local dome, cupola = anchor("Dome"), anchor("Cupola")
local function creamWhite(p)
	local c = p.Color
	return c.R * 255 >= 225 and c.G * 255 >= 220 and c.B * 255 >= 190 and c.B * 255 <= c.R * 255 + 4
end
check("main dome is cream-white (Dec 2025 repaint), not blue-grey", dome ~= nil and creamWhite(dome), dome and tostring(dome.Color) or "missing")
check("tower cupola is cream-white", cupola ~= nil and creamWhite(cupola), cupola and tostring(cupola.Color) or "missing")
check("main dome diameter 44-50 studs (Revision 5: larger dome on a 24-stud drum)", dome ~= nil and dome.Size.X >= 44 and dome.Size.X <= 50, fmt(dome and dome.Size.X))
if facade then
	local c = facade.Color
	check("walls are cream (Revision 5, blueprint; the 2024 photo is butter-yellow): G >= 210, B >= 165, 40 <= R-B <= 90", c.G * 255 >= 210 and c.B * 255 >= 165 and (c.R - c.B) * 255 >= 40 and (c.R - c.B) * 255 <= 90, tostring(c))
else
	check("walls are cream (Revision 5): FacadeWall missing", false, "FacadeWall missing")
end
if naveRoof then
	local c = naveRoof.Color
	check("nave roof is saturated red (R >= 150, G,B <= 70)", c.R * 255 >= 150 and c.G * 255 <= 70 and c.B * 255 <= 70, tostring(c))
else
	check("nave roof is saturated red (R >= 150, G,B <= 70)", false, "NaveRoof missing")
end

------------------------------------------------------------------ Tower LED screen (P3/P4/P1: front face, above the base cornice)
local screen = anchor("Screen")
check("LED Screen is on the left tower, 8+ studs wide, 20-32 studs above the podium (above the base cornice), facing +Z",
	screen ~= nil and tower ~= nil and math.abs(screen.Position.X - tower.Position.X) < 8 and screen.Size.X >= 8
		and screen.Position.Y - RAISE >= 20 and screen.Position.Y - RAISE <= 32 and screen.Position.Z > tower.Position.Z,
	screen and string.format("x %s y %s size %s", fmt(screen.Position.X), fmt(screen.Position.Y), fmt(screen.Size.X)) or "missing")

------------------------------------------------------------------ Facade detail (P3/P4)
check("8 round ColumnShaft cylinders (paired columns on two registers, not flat pilasters)", countNamed("ColumnShaft", Enum.PartType.Cylinder) == 8,
	tostring(countNamed("ColumnShaft", Enum.PartType.Cylinder)))
check("choir window has a scrolled hood", anchor("ChoirWindowHood") ~= nil)
check("belfry on the pediment apex", anchor("BelfryBlock") ~= nil)
check("steps to the door", anchor("StepHigh") ~= nil and anchor("StepLow") ~= nil)

------------------------------------------------------------------ Wing (P3/P4)
local wing = anchor("WingUpper")
local wb = wing and worldBox(wing)
check("2-storey SW wing on the G.A. Solis flank (Revision 5): WingUpper runs 40+ studs along z", wb ~= nil and wb.z1 - wb.z0 >= 40, wb and string.format("z %s..%s", fmt(wb.z0), fmt(wb.z1)) or "missing")
check("2-storey SW wing stands on the west flank (x1 <= -44, x0 >= -64)", wb ~= nil and wb.x1 <= -44 and wb.x0 >= -64, wb and string.format("x %s..%s", fmt(wb.x0), fmt(wb.x1)) or "missing")
check("no building on the east flank (blueprint: parking and garden there): WingUpper is west of x 0 and WingEndWall is gone", wing ~= nil and wing.Position.X < 0 and anchor("WingEndWall") == nil, wing and fmt(wing.Position.X) or "missing")
check("pavilion has scrolls, a balcony and a cross", countNamed("PavilionScroll") >= 4 and anchor("WingBalcony") ~= nil and anchor("PavilionCrossV") ~= nil,
	"scrolls " .. countNamed("PavilionScroll"))
check("wing entrance carries the CATEDRAL sign", (function()
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text:find("CATEDRAL DE SAN SEBASTIAN", 1, true) then return true end
	end
	return false
end)())

------------------------------------------------------------------ Two levels: podium, retaining wall, stairs, landing (P1 crop: wall with stairs down to the plaza)
local podium = anchor("Podium")
check("Podium top is RAISE studs above the ground", podium ~= nil and math.abs(topY(podium) - RAISE) < 0.06, podium and fmt(topY(podium)) or "missing")
check("Podium south face (the retaining wall) is at z 48", podium ~= nil and math.abs(podium.Position.Z + podium.Size.Z / 2 - WALL_Z) < 0.5,
	podium and fmt(podium.Position.Z + podium.Size.Z / 2) or "missing")
check("Podium carries the whole church: spans x +-120 and back to z <= -99", podium ~= nil and podium.Size.X >= 238 and podium.Position.Z - podium.Size.Z / 2 <= -99,
	podium and string.format("x %s back %s", fmt(podium.Size.X), fmt(podium.Position.Z - podium.Size.Z / 2)) or "missing")
local base = anchor("ColumnBase1")
check("the facade stands on the podium, not the ground", base ~= nil and base.Position.Y - base.Size.Y / 2 >= RAISE - 0.06, base and fmt(base.Position.Y - base.Size.Y / 2) or "missing")
local parapets = allNamed("Parapet")
check("2+ parapet runs cap the retaining wall, on the upper level", #parapets >= 2 and (function()
	for _, p in ipairs(parapets) do if p.Position.Y < RAISE then return false end end
	return true
end)(), tostring(#parapets))
-- The fountain and statue on the wall axis (ground photo: a stepped fountain with a statue at the centre of the stairs). The basins
-- are Roblox cylinders rolled upright (Size = height, diameter, diameter); the water is non-colliding so it never blocks a query.
local basin, statue = anchor("FountainBasin"), anchor("FountainStatue")
check("FountainBasin stands on the lower plaza on the wall axis (|x| < 2, z 48..64), at ground level, 12+ studs across",
	basin ~= nil and math.abs(basin.Position.X) < 2 and basin.Position.Z - basin.Size.Y / 2 >= WALL_Z - 0.6 and basin.Position.Z + basin.Size.Y / 2 <= 64
		and basin.Position.Y - basin.Size.X / 2 < 0.6 and basin.Size.Y >= 12,
	basin and string.format("x %s z %s d %s", fmt(basin.Position.X), fmt(basin.Position.Z), fmt(basin.Size.Y)) or "missing")
local waters, wetBad = allNamed("FountainWater"), 0
for _, w in ipairs(waters) do if w.CanCollide or w.CanQuery or w.Transparency < 0.1 or w.Transparency > 0.6 then wetBad += 1 end end
check("fountain has 2+ FountainWater surfaces, translucent and non-colliding", #waters >= 2 and wetBad == 0, #waters .. " parts, " .. wetBad .. " wrong")
check("FountainStatue is on the axis and tops out at y >= 12 (reads from the spawn)", statue ~= nil and math.abs(statue.Position.X) < 2 and topY(statue) >= 12,
	statue and string.format("x %s top %s", fmt(statue.Position.X), fmt(topY(statue))) or "missing")
-- Two flights of steps down to the plaza, either side of the fountain: 4 treads each with tops 4, 3, 2, 1 (then a 1-stud drop to the
-- ground), 2 studs deep, 12+ wide, so every riser is exactly 1 stud and a plain walk from the plaza reaches the Guide.
for _, spec in ipairs({ { "StairFlightL", -1 }, { "StairFlightR", 1 } }) do
	local steps = allNamed(spec[1])
	table.sort(steps, function(a, b) return a.Position.Z < b.Position.Z end)
	local okSteps, detail = #steps == 4, "treads " .. #steps
	for i, s in ipairs(steps) do
		if math.abs(topY(s) - (RAISE - i)) > 0.06 or s.Size.X < 12 or s.Size.Z < 1.9 or s.Position.X * spec[2] < 8 or s.Position.Z - s.Size.Z / 2 < WALL_Z - 0.6 then
			okSteps = false
			detail = detail .. string.format(" [%d top %s w %s d %s x %s]", i, fmt(topY(s)), fmt(s.Size.X), fmt(s.Size.Z), fmt(s.Position.X))
		end
	end
	check(spec[1] .. ": 4 treads, each riser exactly 1 stud, 12+ wide, 2+ deep, beside the fountain (5 -> 4 -> 3 -> 2 -> 1 -> ground)", okSteps, detail)
end
-- The terraced seating beside the stairs (P1 crop: long wooden tiers either side, reading as seats): 4 tiers each, 3+ studs deep so a
-- person can sit or stand on them, risers of exactly 1 stud. The east side is the longer one in the photo. Each ends at the flights.
for _, spec in ipairs({ { "BleacherL", 50, -1 }, { "BleacherR", 70, 1 } }) do
	local steps = allNamed(spec[1])
	table.sort(steps, function(a, b) return a.Position.Z < b.Position.Z end)
	local okRisers, detail = #steps == 4, "tiers " .. #steps
	for i, s in ipairs(steps) do
		local inner = spec[3] < 0 and (s.Position.X + s.Size.X / 2) or (s.Position.X - s.Size.X / 2) -- the edge toward the flight
		if math.abs(topY(s) - (RAISE - i)) > 0.06 or s.Size.X < spec[2] or s.Size.Z < 2.9 or inner * spec[3] < 21 or inner * spec[3] > 23 then
			okRisers = false
			detail = detail .. string.format(" [%d top %s w %s d %s inner %s]", i, fmt(topY(s)), fmt(s.Size.X), fmt(s.Size.Z), fmt(inner))
		end
	end
	check(spec[1] .. ": 4 seating tiers, " .. spec[2] .. "+ studs long and 3+ deep, each riser exactly 1 stud, inner edge at |x| 21..23 (the flight)", okRisers, detail)
end
-- Street-level access (review finding: Roads A and C end at the podium edge, so the forecourt needs side stairs, not only the front seating).
for _, name in ipairs({ "SideStairsW", "SideStairsE" }) do
	local steps = allNamed(name)
	table.sort(steps, function(a, b) return math.abs(a.Position.X) < math.abs(b.Position.X) end)
	local okSteps, detail = #steps == 4, "steps " .. #steps
	for i, s in ipairs(steps) do
		if math.abs(topY(s) - (RAISE - i)) > 0.06 or s.Size.Z < 10 then
			okSteps = false
			detail = detail .. string.format(" [%d top %s w %s]", i, fmt(topY(s)), fmt(s.Size.Z))
		end
	end
	check(name .. ": 4 steps, each riser exactly 1 stud, 10+ studs wide (street access to the forecourt)", okSteps, detail)
end
local fenceBlocks = {}
for _, p in ipairs(allNamed("FencePost")) do
	if p.Position.X > 98 and p.Position.Z > WALL_Z and p.Position.Z < 68 then table.insert(fenceBlocks, "post z" .. fmt(p.Position.Z)) end
end
for _, p in ipairs(allNamed("FenceRail")) do
	if p.Position.X > 98 and p.Position.Z - p.Size.Z / 2 < 68 and p.Position.Z + p.Size.Z / 2 > WALL_Z then table.insert(fenceBlocks, "rail z" .. fmt(p.Position.Z)) end
end
check("the east fence leaves the lower plaza open toward Road C (nothing at x 99 between z 48 and 68)", #fenceBlocks == 0, table.concat(fenceBlocks, ", "))
local stage = site:FindFirstChild("EventStage") -- the folder name is fixed by SiteData; it now holds the fountain, flights, seating and kiosks
check("EventStage folder holds the fountain, both flights and the seating (the old gazebo stage is gone)", stage ~= nil and basin ~= nil and basin:IsDescendantOf(stage)
	and anchor("StairFlightL"):IsDescendantOf(stage) and anchor("BleacherL"):IsDescendantOf(stage)
	and anchor("StageLanding") == nil and anchor("StageCanopy") == nil and anchor("StageFascia") == nil and countNamed("StagePost") == 0)
-- Two small kiosks with orange stepped roofs at the top of the steps, on the podium, clear of every kept prop and of each other.
local kiosks, kioskBad = allNamed("KioskBody"), {}
for _, k in ipairs(kiosks) do
	local r = k.Size.Y / 2 + 0.6 -- the body is a rolled cylinder; the roof overhangs by 0.6
	if k.Position.Y - k.Size.X / 2 < RAISE - 0.06 then table.insert(kioskBad, "below the podium top") end
	if math.abs(k.Position.X) < 25 or math.abs(k.Position.X) > 45 or k.Position.Z + r > WALL_Z - 0.4 or k.Position.Z < 36 then
		table.insert(kioskBad, string.format("misplaced (%s, %s)", fmt(k.Position.X), fmt(k.Position.Z)))
	end
	for _, name in ipairs({ "Guide", "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney" }) do
		local inst = site:FindFirstChild(name)
		if inst then
			local cf, size
			if inst:IsA("Model") then cf, size = inst:GetBoundingBox() else cf, size = inst.CFrame, inst.Size end
			local ext = math.max(size.X, size.Z) / 2 -- generous: the larger half-extent works for any yaw
			local dx, dz = math.max(0, math.abs(k.Position.X - cf.X) - ext), math.max(0, math.abs(k.Position.Z - cf.Z) - ext)
			if math.sqrt(dx * dx + dz * dz) < r + 1 then table.insert(kioskBad, "touches " .. name) end
		end
	end
end
local roofs, orange = allNamed("KioskRoof"), 0
for _, p in ipairs(roofs) do
	local c = p.Color
	if c.R * 255 >= 200 and c.G * 255 >= 90 and c.G * 255 <= 150 and c.B * 255 <= 80 then orange += 1 end
end
check("2 kiosks (KioskBody) stand on the podium either side of the steps (|x| 25..45, z 36..48), clear of the Guide, InfoPanel and Jeepney",
	#kiosks == 2 and #kioskBad == 0 and kiosks[1].Position.X * kiosks[2].Position.X < 0, #kiosks .. " kiosks; " .. table.concat(kioskBad, "; "))
check("kiosk roofs are orange and stepped (4+ orange KioskRoof discs per kiosk)", #roofs >= 8 and orange == #roofs, #roofs .. " roof parts, " .. orange .. " orange")
for _, name in ipairs({ "Guide", "InfoPanel", "JeepStop" }) do
	local inst = site:FindFirstChild(name)
	local y = inst and (inst:IsA("Model") and inst:GetPivot().Position.Y or inst.Position.Y)
	check(name .. " survived and stands on the upper level", inst ~= nil and y ~= nil and y >= RAISE, y and fmt(y) or "missing")
end

------------------------------------------------------------------ Welcome Arch (P6)
local arch = site:FindFirstChild("WelcomeArch")
check("WelcomeArch is a direct child model with 12+ parts", arch ~= nil and arch:IsA("Model") and #arch:GetDescendants() >= 12)
if arch then
	local top, l, r = -math.huge, math.huge, -math.huge
	for _, p in ipairs(arch:GetDescendants()) do
		if p:IsA("BasePart") then
			top = math.max(top, p.Position.Y + p.Size.Y / 2)
			l, r = math.min(l, p.Position.X - p.Size.X / 2), math.max(r, p.Position.X + p.Size.X / 2)
		end
	end
	check("arch is walk-through: top >= 14 studs, clear span >= 12 studs", top >= 14 and (r - l) >= 12, string.format("top %s span %s", fmt(top), fmt(r - l)))
	local sign
	for _, d in ipairs(arch:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text:find("SAN SEBASTIAN", 1, true) and d.Text:find("1910", 1, true) then sign = d end
	end
	check("arch sign reads CATEDRAL de SAN SEBASTIAN / 10 de ABRIL 1910", sign ~= nil)
	check("arch has two stone gateposts", anchor("GatepostL") ~= nil and anchor("GatepostR") ~= nil)
end

------------------------------------------------------------------ Upper level: the car-park forecourt, monument, garden
local apron = anchor("ApronPaving")
check("ApronPaving (the wide parking forecourt) lies on the podium, z 10..48", apron ~= nil and apron.Position.Y >= RAISE and apron.Size.Z >= 34
	and apron.Position.Z - apron.Size.Z / 2 <= 12 and apron.Position.Z + apron.Size.Z / 2 >= WALL_Z - 1,
	apron and string.format("y %s z %s..%s", fmt(apron.Position.Y), fmt(apron.Position.Z - apron.Size.Z / 2), fmt(apron.Position.Z + apron.Size.Z / 2)) or "missing")
check("St Sebastian Monument on a plinth, on the forecourt", anchor("MonumentPlinth") ~= nil and anchor("MonumentPlinth").Position.Y >= RAISE
	and anchor("MonumentPlinth").Position.Z < WALL_Z and site:FindFirstChild("Monument", true) ~= nil)
local bays, badBays = allNamed("ParkingBayLine"), 0
for _, b in ipairs(bays) do if b.Position.Y < RAISE or b.Position.Z >= WALL_Z then badBays += 1 end end
check("16+ yellow parking-bay lines, all on the forecourt", #bays >= 16 and badBays == 0, #bays .. " lines, " .. badBays .. " misplaced")
local hedges, goodHedges = 0, 0
for _, d in ipairs(allNamed("GardenHedge")) do
	hedges += 1
	if d.Position.X > 36 and d.Position.Y >= RAISE and d.Position.Z < WALL_Z then goodHedges += 1 end
end
check("hedged garden on the east of the forecourt (12+ GardenHedge parts, upper level, east of x 36)", hedges >= 12 and hedges == goodHedges, hedges .. " / " .. goodHedges)

------------------------------------------------------------------ Parked vehicles: cars on the forecourt, vans on the lower plaza
local vehicles = site:FindFirstChild("ParkedVehicles")
check("ParkedVehicles folder has 8+ vehicles", vehicles ~= nil and #vehicles:GetChildren() >= 8, vehicles and tostring(#vehicles:GetChildren()) or "missing")
if vehicles then
	local worst, upper, lower = math.huge, 0, 0
	for _, v in ipairs(vehicles:GetChildren()) do
		local body = v:FindFirstChild("VehicleBody", true)
		if not body then worst = 0 else
			worst = math.min(worst, math.max(body.Size.X, body.Size.Z))
			if body.Position.Y >= RAISE then upper += 1 else lower += 1 end
		end
	end
	check("every vehicle body is >= 8 studs long (human-scale parts are never shrunk)", worst >= 8, fmt(worst))
	check("8+ cars on the upper forecourt and NO vans on the lower plaza (the ground photo shows an open paved plaza)", upper >= 8 and lower == 0, upper .. " upper, " .. lower .. " lower")
end

------------------------------------------------------------------ Lower plaza (P1: paved plaza below the wall, the gabled pavilion, palms, fence)
local paving = anchor("ForecourtPaving")
check("lower plaza paving (ForecourtPaving) is at ground level and spans z 48..100", paving ~= nil and paving.Position.Y <= 0.6
	and math.abs(paving.Position.Z - paving.Size.Z / 2 - WALL_Z) < 1 and paving.Position.Z + paving.Size.Z / 2 >= 99,
	paving and string.format("y %s z %s..%s", fmt(paving.Position.Y), fmt(paving.Position.Z - paving.Size.Z / 2), fmt(paving.Position.Z + paving.Size.Z / 2)) or "missing")
local pr, prCol = paving, paving and paving.Color
check("lower paving is terracotta, as in the ground photo (R >= 180, R - B >= 60)", pr ~= nil and prCol.R * 255 >= 180 and (prCol.R - prCol.B) * 255 >= 60, prCol and tostring(prCol) or "missing")
-- The covered court is the open-air stage (Revision 5): a dark peaked roof on posts, NOT a gabled hall.
local court = anchor("CoveredCourt")
check("CoveredCourt stands on the lower plaza: z >= 70, 36+ studs wide, ground level, x >= 34 (east of the open centre)",
	court ~= nil and court.Position.Z >= 70 and court.Size.X >= 36 and court.Position.Y - court.Size.Y / 2 < 0.6 and court.Position.X - court.Size.X / 2 >= 34,
	court and string.format("x %s z %s w %s", fmt(court.Position.X), fmt(court.Position.Z), fmt(court.Size.X)) or "missing")
do
	local sroofs, dark, steep = allNamed("StageRoof"), true, true
	for _, p in ipairs(sroofs) do
		local c = p.Color
		if not (c.R * 255 <= 80 and c.G * 255 <= 80 and c.B * 255 <= 80) then dark = false end
		local rx = p.CFrame:ToEulerAnglesXYZ()
		if math.abs(rx) < 0.35 then steep = false end
	end
	check("open-air stage pavilion (Revision 5): 2 dark peaked roof planes (R, G, B <= 80), each tilted 20+ degrees", #sroofs == 2 and dark and steep, #sroofs .. " planes")
	local sridge = anchor("StageRidge")
	check("stage pavilion ridge is 15+ studs above the ground", sridge ~= nil and topY(sridge) >= 15, sridge and fmt(topY(sridge)) or "missing")
	check("the pale vault is gone (no VaultPanel)", countNamed("VaultPanel") == 0, tostring(countNamed("VaultPanel")))
end
check("no gabled CivicBuildingS / CivicRoof left (the gabled hall is replaced by the vault)", anchor("CivicBuildingS") == nil and anchor("CivicRoof") == nil)
local trunk = anchor("ShadeTreeTrunk")
check("ShadeTree: a trunk at x 31..60, z 60..70 (clear of the open centre and the court) with 4+ canopy balls whose bottoms are above y 11.5",
	trunk ~= nil and trunk.Position.X >= 31 and trunk.Position.X <= 60 and trunk.Position.Z >= 60 and trunk.Position.Z <= 70 and countNamed("ShadeTreeCanopy") >= 4 and (function()
		for _, c in ipairs(allNamed("ShadeTreeCanopy")) do if c.Position.Y - c.Size.Y / 2 < 11.5 then return false end end
		return true
	end)(), trunk and string.format("trunk (%s, %s), canopies %d", fmt(trunk.Position.X), fmt(trunk.Position.Z), countNamed("ShadeTreeCanopy")) or "missing")
-- The round raised pergola garden (ground photo: a pink-walled ring with shrubs and a half-ring of white pergola columns).
local ring = anchor("PergolaRing")
check("PergolaRing is a raised round bed at ground level, 18+ studs across, on the lower plaza west of the open centre",
	ring ~= nil and ring.Position.Y - ring.Size.X / 2 < 0.6 and ring.Size.Y >= 18 and ring.Position.X + ring.Size.Y / 2 <= -34 and ring.Position.Z - ring.Size.Y / 2 >= WALL_Z + 6,
	ring and string.format("x %s z %s d %s", fmt(ring.Position.X), fmt(ring.Position.Z), fmt(ring.Size.Y)) or "missing")
check("pergola: 6+ white PergolaColumn posts on the ring's south side (z > ring centre), 6+ PergolaBeam and 4+ shrubs", ring ~= nil and countNamed("PergolaColumn") >= 6
	and countNamed("PergolaBeam") >= 6 and countNamed("RingShrub") >= 4 and (function()
		for _, c in ipairs(allNamed("PergolaColumn")) do if c.Position.Z <= ring.Position.Z then return false end end
		return true
	end)(), tostring(countNamed("PergolaColumn")) .. " columns")
check("2+ PlanterWall runs along the south fence, none inside the CreditsBoard strip (|x| < 31)", countNamed("PlanterWall") >= 2 and (function()
	for _, p in ipairs(allNamed("PlanterWall")) do
		if p.Position.X - p.Size.X / 2 < 31 and p.Position.X + p.Size.X / 2 > -31 then return false end
	end
	return true
end)(), tostring(countNamed("PlanterWall")))
check("4+ flower beds on the lower plaza", countNamed("FlowerBed") >= 4, tostring(countNamed("FlowerBed")))
check("long arcaded building on the lower plaza's west side (LongBuildingW)", anchor("LongBuildingW") ~= nil and anchor("LongBuildingW").Position.X < -80
	and anchor("LongBuildingW").Position.Z > WALL_Z)
check("22+ palm trunks (Revision 5: palms along the plaza edges)", countNamed("PalmTrunk1") >= 22, tostring(countNamed("PalmTrunk1")))
check("no market tents or slab on the lower plaza (the ground photo shows an open paved plaza)", countNamed("PlazaTent") == 0 and countNamed("TentPost") == 0 and countNamed("PlazaSlab") == 0,
	countNamed("PlazaTent") .. " tents")
check("perimeter fence with 20+ posts", countNamed("FencePost") >= 20, tostring(countNamed("FencePost")))

------------------------------------------------------------------ Keep-clear zones and the terrain rule
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances = { site }
overlap.RespectCanCollide = true
local function blockers(cf, size)
	local names = {}
	for _, p in ipairs(workspace:GetPartBoundsInBox(cf, size, overlap)) do
		if not isRig(p) and p.Size.Y > 0.5 then table.insert(names, (p:GetFullName():gsub("^Workspace%.Sites%.Site01_Cathedral%.", ""))) end
	end
	return names
end
local spawnHits = blockers(CFrame.new(0, 5, 70), Vector3.new(8, 8, 8))
check("the spawn (0,70) has 8x8 studs of clear ground", #spawnHits == 0, table.concat(spawnHits, ", ", 1, math.min(#spawnHits, 4)))
local boardHits = blockers(CFrame.new(0, 8, 94.5), Vector3.new(60, 14, 8))
check("the CreditsBoard strip (x +-30, z 90..98) is clear of Site01 geometry", #boardHits == 0, table.concat(boardHits, ", ", 1, math.min(#boardHits, 4)))
local centreHits = blockers(CFrame.new(-2, 6, 76), Vector3.new(64, 10, 24))
check("the lower plaza has a wide open centre (x -34..30, z 64..88 clear of Site01 geometry)", #centreHits == 0, table.concat(centreHits, ", ", 1, math.min(#centreHits, 4)))
-- Upper-level keep-clear: nothing the builder made may stand where a visitor meets the Guide or reads the InfoPanel.
local keptNames = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
local function builtBlockers(cf, size)
	local names = {}
	for _, p in ipairs(workspace:GetPartBoundsInBox(cf, size, overlap)) do
		local top = p
		while top.Parent and top.Parent ~= site do top = top.Parent end
		if not keptNames[top.Name] and not isRig(p) and p.Size.Y > 0.5 then table.insert(names, (p:GetFullName():gsub("^Workspace%.Sites%.Site01_Cathedral%.", ""))) end
	end
	return names
end
-- (y starts 0.5 above the podium top so the podium itself is not a hit; the InfoPanel zone is not checked here because the
-- original lamp row at x 14 stands in front of it by design, and the kiosk clearance above already guards the new geometry.)
local guideHits = builtBlockers(CFrame.new(0, RAISE + 4.5, 30), Vector3.new(8, 7, 8))
check("the Guide's 8x8 stand zone on the forecourt (0, 30) is free of built geometry", #guideHits == 0, table.concat(guideHits, ", ", 1, math.min(#guideHits, 4)))
local lowerBenches = 0
for _, b in ipairs(allNamed("BenchSeat")) do if b.Position.Y < RAISE then lowerBenches += 1 end end
check("5+ benches at the foot of the seating tiers on the lower plaza", lowerBenches >= 5, tostring(lowerBenches))
local stray = {}
for _, p in ipairs(site:GetDescendants()) do
	if p:IsA("BasePart") and not isRig(p) and p.Size.Y <= 0.5 and p.Position.Y <= 0.6 and p.Parent.Name ~= "JeepStop" then
		local x0, x1 = p.Position.X - p.Size.X / 2, p.Position.X + p.Size.X / 2
		local z0, z1 = p.Position.Z - p.Size.Z / 2, p.Position.Z + p.Size.Z / 2
		if p.Size.X > 3 and p.Size.Z > 3 and (x0 < -100.7 or x1 > 100.7 or z0 < WALL_Z - 0.6 or z1 > 100.7) then
			table.insert(stray, string.format("%s x[%.0f,%.0f] z[%.0f,%.0f]", p.Name, x0, x1, z0, z1))
		end
	end
end
check("flat ground-level parts lie on the lower plaza only (x +-100, z 48..100: the repainted Pavement; the podium covers the rest)", #stray == 0,
	table.concat(stray, "; ", 1, math.min(#stray, 3)))

------------------------------------------------------------------ Revision 5 (Slice 4): blueprint pass
-- Source: 2nd Reference/cathedral/3d blueprints/Metropolitan Cathedral Blueprint Plaza Plan.png (massing, layout, proportion).
-- Each block is one diff item in briefs/site01.md "Revision 5 (Slice 4): blueprint pass". Wrapped in do ... end to keep the locals scoped.
do
	-- 1. Bell tower: seven octagonal tiers, narrowing as they rise, arched openings, a small domed cap.
	local towerBody = anchor("TowerBody")
	local radii = {}
	for i = 1, 7 do
		local p = anchor("Tier" .. i .. "1")
		if p ~= nil and towerBody ~= nil then
			radii[i] = math.sqrt((p.Position.X - towerBody.Position.X) ^ 2 + (p.Position.Z - towerBody.Position.Z) ^ 2)
		else
			radii[i] = 0
		end
	end
	local narrowing = radii[1] > 0
	for i = 2, 7 do
		if radii[i] <= 0 or radii[i] >= radii[i - 1] then narrowing = false end
	end
	check("tower tiers narrow as they rise: 7 tier radii, each smaller than the one below", narrowing, table.concat(radii, " "))
	local octagons = 0
	for i = 1, 7 do
		local n = 0
		for k = 1, 8 do
			if anchor("Tier" .. i .. k) ~= nil then n += 1 end
		end
		if n == 8 then octagons += 1 end
	end
	check("each of the 7 tiers is an octagon: 8 wall segments (Tier<i>1..8)", octagons == 7, tostring(octagons))
	local openings = countNamed("Tier1Win_Pane") == 3
	for i = 2, 7 do
		if countNamed("Tier" .. i .. "Win_Pane") ~= 4 then openings = false end
	end
	check("arched openings: tier 1 has 3 (its front is the LED screen), tiers 2-7 have 4 on the cardinal faces", openings,
		countNamed("Tier1Win_Pane") .. " on tier 1, " .. countNamed("Tier2Win_Pane") .. " on tier 2")
	local cupola2, cornice7 = anchor("Cupola"), anchor("Cornice71")
	check("tower cap is a small dome: Cupola 8-12 studs across, set on the 7th tier cornice",
		cupola2 ~= nil and cupola2.Size.X >= 8 and cupola2.Size.X <= 12 and cornice7 ~= nil and cupola2.Position.Y >= topY(cornice7) - 1.5,
		cupola2 and string.format("d %s y %s", fmt(cupola2.Size.X), fmt(cupola2.Position.Y)) or "missing")

	-- 2. Main dome: larger, warm cream, on a drum of apothem 24 with eight windows, a lantern and a cross.
	check("main dome is warm cream (R-B >= 40, G >= 215), not the grey of the earlier scheme", dome ~= nil and (dome.Color.R - dome.Color.B) * 255 >= 40 and dome.Color.G * 255 >= 215,
		dome and tostring(dome.Color) or "missing")
	check("main dome top reaches y 76 (Revision 5: larger dome on the 24-stud drum)", dome ~= nil and topY(dome) >= 76, dome and fmt(topY(dome)) or "missing")
	local lanternOk = anchor("LanternCap") ~= nil and anchor("DomeCrossV") ~= nil
	for k = 1, 8 do
		if anchor("Lantern" .. k) == nil then lanternOk = false end
	end
	check("lantern: 8 Lantern segments, a LanternCap and the DomeCrossV on top", lanternOk)
	local drum1 = anchor("Drum1")
	local drumOk = drum1 ~= nil and drum1.Size.X >= 19
	for k = 1, 8 do
		if anchor("DrumWin" .. k .. "_Pane") == nil then drumOk = false end
	end
	check("drum: 8 arched windows (DrumWin1..8) on an octagon of apothem 24 (Drum1 at least 19 studs)", drumOk, drum1 and fmt(drum1.Size.X) or "missing")

	-- 3. The 2-storey wing on the west flank (the G.A. Solis side): arcade bays 1, 2, 4, 5 with bay 3 as the entrance; red tile roof.
	local groundBays = 0
	for i = 1, 5 do
		if i ~= 3 and (anchor("WingBay" .. i) ~= nil or anchor("WingBay" .. i .. "_PierL") ~= nil) then groundBays += 1 end
	end
	check("2-storey wing storey 1: 4 arched arcade bays (bay 3 is the entrance)", groundBays == 4, tostring(groundBays))
	local upperWins = 0
	for i = 1, 5 do
		if i ~= 3 and countNamed("WingWin" .. i .. "_Pane") == 1 then upperWins += 1 end
	end
	check("2-storey wing storey 2: 4 arched windows (bays 1, 2, 4, 5)", upperWins == 4, tostring(upperWins))
	local ww1 = anchor("WingWin1_Pane")
	check("2-storey wing arcade faces west: its windows sit west of x -52", ww1 ~= nil and ww1.Position.X < -52, ww1 and fmt(ww1.Position.X) or "missing")
	check("no dark glass backing panel behind the wing arcade (WingBacking removed)", anchor("WingBacking") == nil)
	local wroof = anchor("WingRoofFront")
	check("2-storey wing roof is red tile (R >= 150, G and B <= 70)", wroof ~= nil and wroof.Color.R * 255 >= 150 and wroof.Color.G * 255 <= 70 and wroof.Color.B * 255 <= 70,
		wroof and tostring(wroof.Color) or "missing")

	-- 4. The 3-storey parish and archdiocese office wing at the back-left (the far end of the west flank): 3 storeys, red tile roof.
	local ob = anchor("OfficeBody")
	local obb = ob and worldBox(ob)
	check("3-storey office wing at the back-left: OfficeBody x1 <= -44 and reaches z -90 or beyond", obb ~= nil and obb.x1 <= -44 and obb.z0 <= -90,
		obb and string.format("x %s..%s z %s..%s", fmt(obb.x0), fmt(obb.x1), fmt(obb.z0), fmt(obb.z1)) or "missing")
	local storeys = { 0, 0, 0 }
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then
			local k = d.Name:match("^OfficeS(%d)Win%d+$")
			if k ~= nil and storeys[tonumber(k)] ~= nil then
				storeys[tonumber(k)] += 1
			end
		end
	end
	check("3-storey office wing: 4+ windows on each of storeys 1, 2 and 3 (OfficeS<k>Win<i>)", storeys[1] >= 4 and storeys[2] >= 4 and storeys[3] >= 4, table.concat(storeys, " / "))
	check("3-storey office wing: bands OfficeBand1..3 and no fourth storey", anchor("OfficeBand1") ~= nil and anchor("OfficeBand2") ~= nil and anchor("OfficeBand3") ~= nil and anchor("OfficeBand4") == nil)
	local s1w, s2w, s3w = anchor("OfficeS1Win1"), anchor("OfficeS2Win1"), anchor("OfficeS3Win1")
	check("3-storey office wing: storeys stack (storey 1 below storey 2 below storey 3)", s1w ~= nil and s2w ~= nil and s3w ~= nil and s1w.Position.Y < s2w.Position.Y and s2w.Position.Y < s3w.Position.Y, "")
	local od = anchor("OfficeDoor")
	check("office ground-floor door is 8+ studs tall (human scale)", od ~= nil and od.Size.Y >= 8, od and fmt(od.Size.Y) or "missing")
	local oroof = anchor("OfficeRoofFront")
	check("office wing roof is red tile (R >= 150, G and B <= 70)", oroof ~= nil and oroof.Color.R * 255 >= 150 and oroof.Color.G * 255 <= 70 and oroof.Color.B * 255 <= 70,
		oroof and tostring(oroof.Color) or "missing")

	-- 5. Walled parking forecourt: brick walls on the east and west edges with a 20-stud gateway (z 16..36) opposite the side stairs,
	--    brick retaining skins at the ends of the podium's south face, and dark iron railings on the lower plaza.
	local fwW, fwE = allNamed("ForecourtWallW"), allNamed("ForecourtWallE")
	local wallsOk = #fwW >= 2 and #fwE >= 2
	for _, p in ipairs(fwW) do
		local b = worldBox(p)
		if b.y0 < RAISE - 0.1 or b.y1 - b.y0 < 2.5 or b.z0 < 9.5 or b.z1 > 47 then wallsOk = false end
	end
	for _, p in ipairs(fwE) do
		local b = worldBox(p)
		if b.y0 < RAISE - 0.1 or b.y1 - b.y0 < 2.5 or b.z0 < 9.5 or b.z1 > 47 then wallsOk = false end
	end
	check("walled forecourt: ForecourtWallW and ForecourtWallE segments on the podium top, 2.5+ tall, z 10..46", wallsOk, #fwW .. " west, " .. #fwE .. " east")
	local gateOk = #fwW >= 2 and #fwE >= 2
	for _, name in ipairs({ "ForecourtWallW", "ForecourtWallE", "ForecourtPier" }) do
		for _, p in ipairs(allNamed(name)) do
			local b = worldBox(p)
			if math.abs((b.x0 + b.x1) / 2) > 98 and b.z1 > 16 and b.z0 < 36 then gateOk = false end
		end
	end
	check("gateway: no forecourt wall or pier between z 16 and 36 on either side (the side stairs at z 20..32 stay reachable)", gateOk)
	local function brick(p) return p ~= nil and p.Color.R * 255 >= 150 and p.Color.G * 255 <= 110 and p.Color.B * 255 <= 90 end
	check("forecourt walls and the retaining skins are brick red (R >= 150, G <= 110, B <= 90)", brick(fwW[1]) and brick(fwE[1]) and brick(anchor("RetainBrickW")) and brick(anchor("RetainBrickE")))
	local rbw = anchor("RetainBrickW")
	local rbb = rbw and worldBox(rbw)
	check("retaining wall: brick skin on the podium's south face (z 48.0..48.8) from the ground to the podium top",
		rbb ~= nil and rbb.z0 <= 48.1 and rbb.z1 >= 48.6 and rbb.y0 <= 0.1 and rbb.y1 >= RAISE - 0.1,
		rbb and string.format("z %s..%s y %s..%s", fmt(rbb.z0), fmt(rbb.z1), fmt(rbb.y0), fmt(rbb.y1)) or "missing")
	local rail = anchor("FenceRail")
	check("perimeter railing is dark iron, not white (average RGB below 0.4)", rail ~= nil and (rail.Color.R + rail.Color.G + rail.Color.B) / 3 < 0.4, rail and tostring(rail.Color) or "missing")
	check("railing posts are 3+ studs tall (human scale: railings 3)", anchor("FencePost") ~= nil and anchor("FencePost").Size.Y >= 3)

	-- 6. D-shaped monument mound (three stepped terraces, flat side to the retaining wall) with a looped ribbon sculpture on top.
	local mound = allNamed("MonumentPlinth")
	local tops, maxZ = {}, -math.huge
	for _, p in ipairs(mound) do
		tops[string.format("%.1f", topY(p))] = true
		maxZ = math.max(maxZ, p.Position.Z + p.Size.Z / 2)
	end
	local nTops = 0
	for _ in pairs(tops) do nTops += 1 end
	check("D-shaped monument mound: 3 stepped terraces (MonumentPlinth strips at 3 heights, 12+ strips)", #mound >= 12 and nTops == 3, #mound .. " strips at " .. nTops .. " heights")
	check("the D's flat side faces the retaining wall (strips reach z 44..47.5)", maxZ >= 44 and maxZ <= 47.5, fmt(maxZ))
	local ribbon, rTop = allNamed("MonumentRibbon"), -math.huge
	for _, p in ipairs(ribbon) do
		rTop = math.max(rTop, topY(p))
	end
	check("looped ribbon sculpture: 12 MonumentRibbon segments, top 7.5+ studs above the podium", #ribbon == 12 and rTop >= RAISE + 7.5, #ribbon .. " segments, top " .. fmt(rTop))
	check("the mound stays off the walkway (no MonumentPlinth within |x| 8)", (function()
		for _, p in ipairs(mound) do
			if math.abs(p.Position.X) < 8 then return false end
		end
		return true
	end)(), "")

	-- 7. Lipa Cultural Centre: a 2-storey cream block, arched windows on both storeys, an 8+ studs entrance, on the lower plaza's east side.
	local cc = anchor("CulturalCentreBody")
	local ccb = cc and worldBox(cc)
	check("Lipa Cultural Centre: 2-storey block (18+ tall, 15+ wide) on the lower plaza's east side (x 78..98, z 60..84), on the ground",
		ccb ~= nil and ccb.y1 - ccb.y0 >= 18 and ccb.x1 - ccb.x0 >= 15 and ccb.x0 >= 78 and ccb.x1 <= 98 and ccb.z0 >= 60 and ccb.z1 <= 84 and ccb.y0 < 0.6,
		ccb and string.format("x %s..%s z %s..%s y %s..%s", fmt(ccb.x0), fmt(ccb.x1), fmt(ccb.z0), fmt(ccb.z1), fmt(ccb.y0), fmt(ccb.y1)) or "missing")
	check("Cultural Centre south face at z 82.5 or less, clear of the palm fronds on the z 92 row", ccb ~= nil and ccb.z1 <= 82.5, ccb and fmt(ccb.z1) or "missing")
	local cs1, cs2 = 0, 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then
			if d.Name:match("^CulturalS1W%d+_Pane$") then cs1 += 1 end
			if d.Name:match("^CulturalS2W%d+_Pane$") then cs2 += 1 end
		end
	end
	check("Cultural Centre: 3+ arched windows on each storey (CulturalS1W<i>, CulturalS2W<i>)", cs1 >= 3 and cs2 >= 3, cs1 .. " / " .. cs2)
	local cdoor = anchor("CulturalDoor_Pane")
	check("Cultural Centre entrance is 8+ studs tall (human scale)", cdoor ~= nil and cdoor.Size.Y + 2 >= 8, cdoor and fmt(cdoor.Size.Y + 2) or "missing")

	-- 8. North-east garden (blueprint): 6 round-canopy trees (3 balls each) on the podium, east of x 50 and north of z -41.
	local gcanopies, gOk = allNamed("GardenTreeCanopy"), true
	for _, c in ipairs(gcanopies) do
		if c.Position.X < 50 or c.Position.Z > -41 or c.Position.Y < RAISE then gOk = false end
	end
	check("north-east garden: 6 round-canopy trees (18 GardenTreeCanopy balls) on the podium, east of x 50 and north of z -41", #gcanopies >= 18 and gOk, #gcanopies .. " canopies")

	-- 9. Budget and reach: at most 2183 parts (1683 + 500), and nothing beyond |x| 128 (the east bypass at x 165 needs 30 studs of clear ground).
	local nSite, maxAbsX = 0, 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then
			nSite += 1
			local b = worldBox(d)
			maxAbsX = math.max(maxAbsX, math.abs(b.x0), math.abs(b.x1))
		end
	end
	check("part budget: Site01 holds at most 2183 parts (1683 + 500)", nSite <= 2183, tostring(nSite))
	check("no part beyond |x| 128 world (the east bypass at x 165 needs 30 studs of clear ground)", maxAbsX <= 128.01, fmt(maxAbsX))

	-- 10. Human scale: the facade door stays 8+ studs tall.
	local fdoor = anchor("Door_Pane")
	check("facade door is 8+ studs tall (Door_Pane plus its round top)", fdoor ~= nil and fdoor.Size.Y + 4.6 >= 8, fdoor and fmt(fdoor.Size.Y + 4.6) or "missing")
end

return HttpService:JSONEncode(results)
