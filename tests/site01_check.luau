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
local WALL_Z = 112 -- the podium's south face, the retaining wall (B3c-1: moved south from 48)
local PLAZA_S = 195.0 -- B3c-1: the lower plaza's south fence line (post centres; the brief said 198, moved to 195 for the Road E walk: the fence stays 4+ studs clear of the board's keep-out line z 199.8); the paving runs to PLAZA_S + 0.4, the south kerb to PLAZA_S + 1.1
local STAGE_Z = PLAZA_S - 11.5 -- B3c-1: the stage dais centre z

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
-- Every coordinate below is world (the builder works in world axes), and the pivot must sit at the SiteData pos facing +Z. A stray
-- drag in Studio once moved the whole site by (-57.5, 20.3) and showed up only as a dozen unrelated failures. Slice 4 B3b: the slot
-- grew south (centre z 57.5), so the pivot moved to (0, 0, 57.5) by a WorldPivot write; no part moved.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (0, 0, 57.5), facing +Z", (pv.Position - Vector3.new(0, 0, 57.5)).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(0, 0, 1)) > 0.9999,
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
-- B3c-0b: an assertion the owner's second markup contradicts is retired by renaming its call to retired(...), which does nothing. The old text stays in this file as the record; the reason and the replacement are logged in briefs/site01.md "B3c-0b".
local function retired() end

------------------------------------------------------------------ B3c-1: nothing is buried (the first real check)
-- Moving the retaining wall south from z 48 to z 112 puts every absolute z literal of the old lower plaza inside the podium. Every part (and every visitor rig's HumanoidRootPart)
-- whose centre is within |x| < 120 and z < WALL_Z must stand on or above the podium top (centre y >= RAISE). The only part allowed a lower centre is the Podium itself.
do
	local buried = {}
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA("BasePart") and p.Name ~= "Podium" and math.abs(p.Position.X) < 120 and p.Position.Z < WALL_Z and p.Position.Y < RAISE - 0.001 and (not isRig(p) or p.Name == "HumanoidRootPart") then
			table.insert(buried, string.format("%s (%.0f, %.1f, %.0f)", p.Name, p.Position.X, p.Position.Y, p.Position.Z))
		end
	end
	check("B3c-1 nothing is buried: no part (or visitor HumanoidRootPart) with its centre at |x| < 120, z < WALL_Z sits below the podium top (only the Podium itself)", #buried == 0,
		#buried .. " buried: " .. table.concat(buried, "; ", 1, math.min(#buried, 4)))
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
check("tower has 4 octagonal tiers", tiers == 4, tostring(tiers))

------------------------------------------------------------------ Colours (P1 Dec 2025 domes, P3 walls)
local dome, cupola = anchor("Dome"), anchor("Cupola")
local function creamWhite(p)
	local c = p.Color
	return c.R * 255 >= 225 and c.G * 255 >= 220 and c.B * 255 >= 190 and c.B * 255 <= c.R * 255 + 4
end
check("main dome is cream-white (Dec 2025 repaint), not blue-grey", dome ~= nil and creamWhite(dome), dome and tostring(dome.Color) or "missing")
check("tower cupola is cream-white", cupola ~= nil and creamWhite(cupola), cupola and tostring(cupola.Color) or "missing")
check("dome diameter 34-42 studs (about as wide as the nave)", dome ~= nil and dome.Size.X >= 34 and dome.Size.X <= 42, fmt(dome and dome.Size.X))
if facade then
	local c = facade.Color
	check("walls are butter-yellow (R-B >= 90, G >= 170)", (c.R - c.B) * 255 >= 90 and c.G * 255 >= 170, tostring(c))
else
	check("walls are butter-yellow (R-B >= 90, G >= 170)", false, "FacadeWall missing")
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
check("wing is 90+ studs long (real ~65 m, compressed to the footprint)", wing ~= nil and wing.Size.X >= 90, fmt(wing and wing.Size.X))
check("wing starts east of the facade", wing ~= nil and facade ~= nil and wing.Position.X - wing.Size.X / 2 >= facade.Position.X + facade.Size.X / 2 - 3,
	wing and facade and fmt(wing.Position.X - wing.Size.X / 2) or "missing")
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
check("Podium south face (the retaining wall) is at WALL_Z (z 112, B3c-1)", podium ~= nil and math.abs(podium.Position.Z + podium.Size.Z / 2 - WALL_Z) < 0.5,
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
-- Round 4 (replaces the 3 fountain assertions): the plaza drawing has no fountain; the wall axis is one wide flight of steps.
local basin = anchor("FountainBasin")
check("round 4: no fountain on the wall axis (no FountainBasin, FountainStatue, FountainColumn or FountainWater)", basin == nil and anchor("FountainStatue") == nil
	and countNamed("FountainColumn") == 0 and countNamed("FountainWater") == 0, countNamed("FountainWater") .. " water parts")
local stairC = allNamed("StairFlightC")
table.sort(stairC, function(a, b) return a.Position.Z < b.Position.Z end)
retired("round 4: StairFlightC fills the wall axis: 4 treads, tops 4, 3, 2, 1, 16 wide (x -8..8)", #stairC == 4 and (function()
	for i, s in ipairs(stairC) do
		if math.abs(topY(s) - (RAISE - i)) > 0.06 or s.Size.X < 15.9 or math.abs(s.Position.X) > 0.5 then return false end
	end
	return true
end)(), #stairC .. " treads")
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
	check(spec[1] .. ": 4 treads, each riser exactly 1 stud, 12+ wide, 2+ deep, down the wall (5 -> 4 -> 3 -> 2 -> 1 -> ground)", okSteps, detail)
end
-- The terraced seating beside the stairs (P1 crop: long wooden tiers either side, reading as seats): 4 tiers each, 3+ studs deep so a
-- person can sit or stand on them, risers of exactly 1 stud. The east side is the longer one in the photo. Each ends at the flights.
for _, spec in ipairs({ { "BleacherL", 50, -1 }, { "BleacherR", 70, 1 } }) do
	local steps = allNamed(spec[1])
	table.sort(steps, function(a, b) return a.Position.Z < b.Position.Z end)
	local okRisers, detail = #steps == 4, "tiers " .. #steps
	for i, s in ipairs(steps) do
		local inner = spec[3] < 0 and (s.Position.X + s.Size.X / 2) or (s.Position.X - s.Size.X / 2) -- the edge toward the flight
		if math.abs(topY(s) - (RAISE - i)) > 0.06 or s.Size.X < spec[2] or s.Size.Z < 2.9 or inner * spec[3] < 25 or inner * spec[3] > 27 then
			okRisers = false
			detail = detail .. string.format(" [%d top %s w %s d %s inner %s]", i, fmt(topY(s)), fmt(s.Size.X), fmt(s.Size.Z), fmt(inner))
		end
	end
	check(spec[1] .. ": 4 seating tiers, " .. spec[2] .. "+ studs long and 3+ deep, each riser exactly 1 stud, inner edge at |x| 25..27 (the flight, B3c-0b)", okRisers, detail)
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
retired("the east fence leaves the lower plaza open toward Road C (nothing at x 99 between z 48 and 68)", #fenceBlocks == 0, table.concat(fenceBlocks, ", "))
local stage = site:FindFirstChild("EventStage") -- the folder name is fixed by SiteData; it holds the wall steps, brick facing and side stairs
retired("round 4 (replaces 'EventStage folder holds the fountain, both flights and the seating'): EventStage holds the three flights and the seating, no gazebo stage",
	stage ~= nil and anchor("StairFlightL") ~= nil and anchor("StairFlightL"):IsDescendantOf(stage) and anchor("StairFlightC") ~= nil and anchor("StairFlightC"):IsDescendantOf(stage)
	and anchor("BleacherL") ~= nil and anchor("BleacherL"):IsDescendantOf(stage)
	and anchor("StageLanding") == nil and anchor("StageCanopy") == nil and anchor("StageFascia") == nil and countNamed("StagePost") == 0)
-- Round 4 (replaces the 2 kiosk assertions): the drawing has no kiosks at the top of the steps.
check("round 4: no kiosks (KioskBody, KioskRoof) at the top of the steps", countNamed("KioskBody") == 0 and countNamed("KioskRoof") == 0, countNamed("KioskBody") .. " kiosks")
for _, name in ipairs({ "Guide", "InfoPanel", "JeepStop" }) do
	local inst = site:FindFirstChild(name)
	local y = inst and (inst:IsA("Model") and inst:GetPivot().Position.Y or inst.Position.Y)
	check(name .. " survived and stands on the upper level", inst ~= nil and y ~= nil and y >= RAISE, y and fmt(y) or "missing")
end

------------------------------------------------------------------ Welcome Arch (P6)
local arch = site:FindFirstChild("WelcomeArch")
retired("WelcomeArch is a direct child model with 12+ parts", arch ~= nil and arch:IsA("Model") and #arch:GetDescendants() >= 12)
if arch and false then -- B3c-0b: the WelcomeArch is gone, its three nested checks are retired
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
check("lower plaza paving (ForecourtPaving) is at ground level and spans z WALL_Z..PLAZA_S+0.4 (112..198.4, B3c-1)", paving ~= nil and paving.Position.Y <= 0.6
	and math.abs(paving.Position.Z - paving.Size.Z / 2 - WALL_Z) < 1 and math.abs(paving.Position.Z + paving.Size.Z / 2 - (PLAZA_S + 0.4)) < 0.3,
	paving and string.format("y %s z %s..%s", fmt(paving.Position.Y), fmt(paving.Position.Z - paving.Size.Z / 2), fmt(paving.Position.Z + paving.Size.Z / 2)) or "missing")
local pr, prCol = paving, paving and paving.Color
-- Step B round 2 (replaces "lower paving is terracotta, as in the ground photo (R >= 180, R - B >= 60)"; the plaza drawing shows grey grid pavers)
check("lower paving is grey grid pavers (R, G, B within 24 of each other, 120..190), as in the plaza drawing", pr ~= nil and (function()
	local r, g, b = prCol.R * 255, prCol.G * 255, prCol.B * 255
	return math.max(r, g, b) - math.min(r, g, b) <= 24 and r >= 120 and r <= 190
end)(), prCol and tostring(prCol) or "missing")
-- Step B round 2 (replaces "CoveredCourt stands on the lower plaza: z >= 70, 36+ studs wide, ..." and "the court roof is a curved vault: 7+ VaultPanel ..."):
-- the drawing's plaza is an open grey-paver square with a shade tree, a lawn and palm strips, and no vaulted court.
check("the vaulted CoveredCourt is gone: no CoveredCourt, VaultPanel, CourtPost or VaultRidge on the paver square", anchor("CoveredCourt") == nil and countNamed("VaultPanel") == 0
	and countNamed("CourtPost") == 0 and anchor("VaultRidge") == nil, countNamed("VaultPanel") .. " vault panels")
check("no gabled CivicBuildingS / CivicRoof left (the gabled hall is replaced by the vault)", anchor("CivicBuildingS") == nil and anchor("CivicRoof") == nil)
local trunk = anchor("ShadeTreeTrunk")
check("ShadeTree: a trunk at x 31..60, z WALL_Z+20..PLAZA_S-30 (the middle band, B3c-1; clear of the open centre and the court) with 4+ canopy balls whose bottoms are above y 11.5",
	trunk ~= nil and trunk.Position.X >= 31 and trunk.Position.X <= 60 and trunk.Position.Z >= WALL_Z + 20 and trunk.Position.Z <= PLAZA_S - 30 and countNamed("ShadeTreeCanopy") >= 4 and (function()
		for _, c in ipairs(allNamed("ShadeTreeCanopy")) do if c.Position.Y - c.Size.Y / 2 < 11.5 then return false end end
		return true
	end)(), trunk and string.format("trunk (%s, %s), canopies %d", fmt(trunk.Position.X), fmt(trunk.Position.Z), countNamed("ShadeTreeCanopy")) or "missing")
-- Step B round 2 (replaces "PergolaRing is a raised round bed ..." and "pergola: 6+ white PergolaColumn posts ..."): the drawing has a lawn square, not a pergola ring.
check("the pergola ring is gone: no PergolaRing, PergolaColumn or PergolaBeam", anchor("PergolaRing") == nil and countNamed("PergolaColumn") == 0 and countNamed("PergolaBeam") == 0,
	countNamed("PergolaColumn") .. " columns")
check("2+ PlanterWall runs along the south fence, none inside the CreditsBoard strip (|x| < 31)", countNamed("PlanterWall") >= 2 and (function()
	for _, p in ipairs(allNamed("PlanterWall")) do
		if p.Position.X - p.Size.X / 2 < 31 and p.Position.X + p.Size.X / 2 > -31 then return false end
	end
	return true
end)(), tostring(countNamed("PlanterWall")))
check("4+ flower beds on the lower plaza", countNamed("FlowerBed") >= 4, tostring(countNamed("FlowerBed")))
-- B3c-0 (owner's colour markup 2026-10-27; replaces "long arcaded building on the lower plaza's west side (LongBuildingW)"): red = remove the long west building, black = remove the
-- west and north ranges (replaced by an iron fence), blue = remove the south cross range. Nothing of the parish wing is left, and no orphan from an old run either.
do
	local left = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		if d.Name == "LongBuildingW" or d.Name:match("^LongBuildingW") or d.Name:match("^ParishWing") or d.Name:match("^ParishCourt") or d.Name == "PlazaSquare"
			or d.Name == "LongRoof" or d.Name == "LongRidge" or d.Name == "LongPilaster" or d.Name == "ParishWin_Pane" or d.Name == "ParishDoor_Pane" then
			table.insert(left, d.Name)
		end
	end
	check("B3c-0 no LongBuildingW or ParishWing* parts remain (markup: red, black, blue), and no orphan PlazaSquare anywhere in the workspace", #left == 0 and site:FindFirstChild("ParishWing") == nil,
		#left .. " left: " .. table.concat(left, ", ", 1, math.min(#left, 4)))
end
check("12+ palm trunks", countNamed("PalmTrunk1") >= 12, tostring(countNamed("PalmTrunk1")))
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
-- B3c-0 (owner's colour markup; replaces the three old open-plaza boxes "the spawn (0,70) has 8x8 studs of clear ground", "the CreditsBoard strip (x +-30, z 90..98) is clear of
-- Site01 geometry" and "the lower plaza has a wide open centre (x -34..30, z 64..88 ...)"): the mound and the stage now stand on the centre line, so walking room is
-- measured round them instead. The real CreditsBoard keep-out (4+ studs round the board itself) is unchanged further down.
local moundN = blockers(CFrame.new(0, 5, WALL_Z + 14.2), Vector3.new(20, 8, 2.0))
local moundE = blockers(CFrame.new(14, 5, WALL_Z + 22), Vector3.new(4.4, 8, 16))
local moundW = blockers(CFrame.new(-14, 5, WALL_Z + 22), Vector3.new(4.4, 8, 16))
check("B3c-0 walking room round the mound: clear boxes in front of the statue (x -10..10, z WALL_Z+13.2..15.2; B3c-1) and on both sides (|x| 11.8..16.2, z WALL_Z+14..30)",
	#moundN + #moundE + #moundW == 0, table.concat(moundN, ", ", 1, math.min(#moundN, 2)) .. table.concat(moundE, ", ", 1, math.min(#moundE, 2)) .. table.concat(moundW, ", ", 1, math.min(#moundW, 2)))
local laneE = blockers(CFrame.new(19.5, 5, STAGE_Z + 2.5), Vector3.new(9, 8, 15.6))
local laneW = blockers(CFrame.new(-19.5, 5, STAGE_Z + 2.5), Vector3.new(9, 8, 15.6))
check("B3c-0 walkers pass round both sides of the stage: lanes x +-(15..24), z STAGE_Z-5.3..STAGE_Z+10.3 (B3c-1) are clear of Site01 geometry", #laneE + #laneW == 0,
	table.concat(laneE, ", ", 1, math.min(#laneE, 2)) .. " | " .. table.concat(laneW, ", ", 1, math.min(#laneW, 2)))
local corridor = blockers(CFrame.new(0, 5, STAGE_Z - 6.9), Vector3.new(30, 8, 1.4))
check("B3c-0 a corridor (x -15..15, z STAGE_Z-7.6..-6.2; B3c-1) separates the mound from the stage", #corridor == 0, table.concat(corridor, ", ", 1, math.min(#corridor, 3)))
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
		if p.Size.X > 3 and p.Size.Z > 3 and (x0 < -100.7 or x1 > 100.7 or z0 < WALL_Z - 0.6 or z1 > PLAZA_S + 1.1) then
			table.insert(stray, string.format("%s x[%.0f,%.0f] z[%.0f,%.0f]", p.Name, x0, x1, z0, z1))
		end
	end
end
check("flat ground-level parts lie on the lower plaza only (x +-100, z WALL_Z..PLAZA_S+1.1: the repainted Pavement, B3c-1; the podium covers the rest)", #stray == 0,
	table.concat(stray, "; ", 1, math.min(#stray, 3)))

------------------------------------------------------------------ Slice 4 step B: the plaza and its surroundings follow the plaza blueprint
-- (briefs/site01.md, "Slice 4 step B"). The church is pinned: the owner called it "spot on", so Structure must not change at all.
local function aabb(p)
	local r = p.CFrame
	local hx = (math.abs(r.RightVector.X) * p.Size.X + math.abs(r.UpVector.X) * p.Size.Y + math.abs(r.LookVector.X) * p.Size.Z) / 2
	local hy = (math.abs(r.RightVector.Y) * p.Size.X + math.abs(r.UpVector.Y) * p.Size.Y + math.abs(r.LookVector.Y) * p.Size.Z) / 2
	local hz = (math.abs(r.RightVector.Z) * p.Size.X + math.abs(r.UpVector.Z) * p.Size.Y + math.abs(r.LookVector.Z) * p.Size.Z) / 2
	return p.Position - Vector3.new(hx, hy, hz), p.Position + Vector3.new(hx, hy, hz)
end
do
	local structure = site:FindFirstChild("Structure")
	local nParts, lo, hi, list = 0, Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9), {}
	if structure then
		for _, d in ipairs(structure:GetDescendants()) do
			if d:IsA("BasePart") then
				nParts += 1
				table.insert(list, d)
				local a, b = aabb(d)
				lo = Vector3.new(math.min(lo.X, a.X), math.min(lo.Y, a.Y), math.min(lo.Z, a.Z))
				hi = Vector3.new(math.max(hi.X, b.X), math.max(hi.Y, b.Y), math.max(hi.Z, b.Z))
			end
		end
		table.sort(list, function(a, b) return a.Size.X * a.Size.Y * a.Size.Z > b.Size.X * b.Size.Y * b.Size.Z end)
	end
	-- Recorded before the plaza pass (2026-10-27): 5 children, 763 parts, box (-48.2, 5, -100.8) .. (121.2, 89.5, 9.8).
	check("church pin: Structure has exactly 5 direct children (Facade, Tower, Nave, Dome, Wing)", structure ~= nil and #structure:GetChildren() == 5,
		structure and tostring(#structure:GetChildren()) or "missing")
	check("church pin: Structure has exactly 763 parts", nParts == 763, tostring(nParts))
	check("church pin: Structure bounding box is (-48.2, 5, -100.8) .. (121.2, 89.5, 9.8) within 0.1",
		structure ~= nil and (lo - Vector3.new(-48.2, 5, -100.8)).Magnitude < 0.1 and (hi - Vector3.new(121.2, 89.5, 9.8)).Magnitude < 0.1,
		string.format("(%s, %s, %s) .. (%s, %s, %s)", fmt(lo.X), fmt(lo.Y), fmt(lo.Z), fmt(hi.X), fmt(hi.Y), fmt(hi.Z)))
	local want = { { "TranseptBlock", 232, 200, 120 }, { "Dome", 248, 241, 218 }, { "Apse", 232, 200, 120 }, { "TowerBody", 232, 200, 120 }, { "FacadeBase", 232, 200, 120 } }
	local okTop, detail = #list >= 5, ""
	for i, w in ipairs(want) do
		local p = list[i]
		if not p or p.Name ~= w[1] or math.abs(p.Color.R * 255 - w[2]) > 1 or math.abs(p.Color.G * 255 - w[3]) > 1 or math.abs(p.Color.B * 255 - w[4]) > 1 then
			okTop = false
			detail = detail .. string.format(" [%d %s]", i, p and p.Name or "nil")
		end
	end
	check("church pin: the five biggest parts and their colours (TranseptBlock, Dome, Apse, TowerBody, FacadeBase)", okTop, detail)
end
do
	local worst, who = 0, ""
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA("BasePart") then
			local a, b = aabb(p)
			local m = math.max(math.abs(a.X), math.abs(b.X))
			if m > worst then worst, who = m, (p:GetFullName():gsub("^Workspace%.Sites%.Site01_Cathedral%.", "")) end
		end
	end
	check("no part beyond |x| 128 (the road bypasses stand at x -170 and 165)", worst <= 128, string.format("%s at %s", who, fmt(worst)))
end
do
	-- The CreditsBoard (Workspace.World.CreditsBoard, x +-57.5, z 92.8..95.2) needs 4+ studs of clear space round it.
	local board = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CreditsBoard")
	local bad = {}
	if board then
		local bcf, bsz = board:GetBoundingBox()
		local x0, x1 = bcf.X - bsz.X / 2 - 4, bcf.X + bsz.X / 2 + 4
		local z0, z1 = bcf.Z - bsz.Z / 2 - 4, bcf.Z + bsz.Z / 2 + 4
		for _, p in ipairs(site:GetDescendants()) do
			if p:IsA("BasePart") and not isRig(p) and p.Size.Y > 0.5 and p.Parent.Name ~= "JeepStop" then
				local a, b = aabb(p)
				if b.X > x0 and a.X < x1 and b.Z > z0 and a.Z < z1 and a.Y < bcf.Y + bsz.Y / 2 then
					table.insert(bad, (p:GetFullName():gsub("^Workspace%.Sites%.Site01_Cathedral%.", "")))
				end
			end
		end
	end
	check("the CreditsBoard keeps 4+ studs clear on every side (nothing taller than 0.5 inside the board's bounds + 4: x -70..70, z 199.8..210.2 for the board at z 203.8..206.2)", board ~= nil and #bad == 0,
		board and table.concat(bad, ", ", 1, math.min(#bad, 4)) or "CreditsBoard missing")
end
-- Sign rule: a long label uses a fixed TextSize (never TextScaled) and the text must fill the face (a green check once passed a sign drawn at a
-- tenth of its size): it fits inside the canvas and fills 60%+ of the limiting dimension.
do
	local TextService = game:GetService("TextService")
	local seen, problems = 0, {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("TextLabel") and d.Text:find("CATEDRAL", 1, true) then
			seen += 1
			local gui, part = d.Parent, d.Parent and d.Parent.Parent
			if d.TextScaled then table.insert(problems, d.Parent.Parent.Name .. " is TextScaled") end
			if gui and part and gui:IsA("SurfaceGui") and part:IsA("BasePart") then
				local f, s = gui.Face, part.Size
				local w, h
				if f == Enum.NormalId.Front or f == Enum.NormalId.Back then w, h = s.X, s.Y
				elseif f == Enum.NormalId.Left or f == Enum.NormalId.Right then w, h = s.Z, s.Y
				else w, h = s.X, s.Z end
				local cw, ch = w * gui.PixelsPerStud, h * gui.PixelsPerStud
				local ok, tb = pcall(function() return TextService:GetTextSize(d.Text, d.TextSize, d.Font, Vector2.new(cw, 100000)) end)
				if not ok then
					table.insert(problems, part.Name .. " measure failed")
				else
					local fill = math.max(tb.X / cw, tb.Y / ch)
					if tb.X > cw + 1 or tb.Y > ch + 1 or fill < 0.6 then
						table.insert(problems, string.format("%s text %dx%d in %dx%d (fill %.2f)", part.Name, tb.X, tb.Y, cw, ch, fill))
					end
				end
			else
				table.insert(problems, "label is not on a SurfaceGui face")
			end
		end
	end
	check("B3c-0b CATEDRAL label (the wing entrance; the welcome arch is gone): 1 found, fixed TextSize, fit the face and fill 60%+ of it", seen == 1 and #problems == 0,
		seen .. " labels; " .. table.concat(problems, "; "))
end

-- Lipa Cultural Center: 2-storey cream flat-topped block with arched windows on the plaza's far (+X) edge, beside the road-side open gap.
local cc = anchor("CulturalCenterBody")
-- Step B round 2 (replaces "Lipa Cultural Center: a cream block 14+ studs wide and 20-30 tall at x 78..99, z 64..84, ..."): the old box was too small to read at blueprint-view scale.
-- Step B round 4 (replaces "a cream block 26+ wide, 14+ deep ... at x 68..99, z 64..84"): the drawing's Cultural Center is a long block down the EAST edge of the plaza.
check("round 4 Lipa Cultural Center: a cream block 18+ wide and 28+ long (N-S, along the east edge), 22-30 tall, x -99..-70 (B3c-0b: the west edge), z WALL_Z+16..PLAZA_S-3 (B3c-1), on the lower plaza, flat top",
	cc ~= nil and cc.Size.X >= 18 and cc.Size.Z >= 28 and cc.Size.Y >= 22 and cc.Size.Y <= 30 and cc.Position.X - cc.Size.X / 2 >= -99 and cc.Position.X + cc.Size.X / 2 <= -70
		and cc.Position.Z - cc.Size.Z / 2 >= WALL_Z + 16 and cc.Position.Z + cc.Size.Z / 2 <= PLAZA_S - 3 and cc.Position.Y - cc.Size.Y / 2 < 0.6
		and cc.Color.R * 255 >= 215 and cc.Color.B * 255 >= 130 and (cc.Color.R - cc.Color.B) * 255 <= 90,
	cc and string.format("x %s z %s w %s d %s h %s", fmt(cc.Position.X), fmt(cc.Position.Z), fmt(cc.Size.X), fmt(cc.Size.Z), fmt(cc.Size.Y)) or "missing")
check("Cultural Center has a flat parapet cap, a cornice and 10+ arched windows (CCWin_Pane)", anchor("CulturalCenterParapet") ~= nil and anchor("CulturalCenterCornice") ~= nil
	and countNamed("CCWin_Pane") >= 10, tostring(countNamed("CCWin_Pane")) .. " windows")
check("Cultural Center leaves the road gap open: nothing of it at z < WALL_Z+16 (B3c-1; Road C reaches the plaza between the seating and the building)",
	cc ~= nil and cc.Position.Z - cc.Size.Z / 2 >= WALL_Z + 16)

-- Open-air stage pavilion with a dark peaked roof, plaza south-east, apart from the vaulted CoveredCourt (which stays).
local roofL, roofR, dais = anchor("StageRoofL"), anchor("StageRoofR"), anchor("StageDais")
local function tilt(p) local rx = p.CFrame:ToEulerAnglesXYZ() return math.deg(rx) end
-- B3c-0 (owner's colour markup; replaces the round 4 clause "over a raised dais at the SOUTH-WEST (x -99..-72, z 80..96)", old text kept in briefs/site01.md): the dais centre is within
-- 4 studs of the plaza centre line (x 0) near the south edge (z 80..96), the open side faces NORTH (the white back wall is on the south long side), and the lane from the
-- dais's south edge to the south fence line (z 99.3) is 4.5+ studs, so a walker (agent radius 2) can slide round it. The roof, colour and dais-thickness clauses are unchanged.
check("B3c-0 StagePavilion: two dark roof slopes, tilted 15+ degrees in opposite senses, over a raised dais centred within 4 studs of the plaza centre line near the south edge (z PLAZA_S-18..PLAZA_S-2; B3c-1), open side facing NORTH (back wall on the south), 4.5+ studs to the south fence",
	roofL ~= nil and roofR ~= nil and dais ~= nil and tilt(roofL) * tilt(roofR) < 0 and math.abs(tilt(roofL)) >= 15 and math.abs(tilt(roofR)) >= 15
		and roofL.Color.R * 255 <= 90 and roofL.Color.G * 255 <= 90 and roofL.Color.B * 255 <= 90 and roofR.Color.R * 255 <= 90
		and math.abs(dais.Position.X) <= 4 and dais.Position.Z >= PLAZA_S - 18 and dais.Position.Z <= PLAZA_S - 2 and dais.Size.Y >= 1 and dais.Size.Y <= 2.5
		and roofL.Position.Y >= 12
		and anchor("StageBackWall") ~= nil and anchor("StageBackWall").Position.Z > dais.Position.Z + 4 and anchor("StageBackWall").Size.X >= 20
		and (PLAZA_S - 0.3) - (dais.Position.Z + dais.Size.Z / 2) >= 4.5,
	roofL and roofR and dais and string.format("tilt %s / %s, dais (%s, %s) south lane %s", fmt(tilt(roofL)), fmt(tilt(roofR)), fmt(dais.Position.X), fmt(dais.Position.Z), fmt((PLAZA_S - 0.3) - (dais.Position.Z + dais.Size.Z / 2))) or "missing")
check("StagePavilion has 4+ posts and a white back wall", countNamed("StagePavilionPost") >= 4 and anchor("StageBackWall") ~= nil, tostring(countNamed("StagePavilionPost")))

-- Red-brick retaining wall and brick steps along the forecourt's plaza side.
local brick = allNamed("RetainBrick")
local brickLen = 0
for _, b in ipairs(brick) do brickLen += b.Size.X end
check("red-brick retaining wall facing: 2+ RetainBrick runs, 40+ studs in all, brick red (R >= 140, R - G >= 50, R - B >= 60), below the podium top",
	#brick >= 2 and brickLen >= 40 and (function()
		for _, b in ipairs(brick) do
			local c = b.Color
			if c.R * 255 < 140 or (c.R - c.G) * 255 < 50 or (c.R - c.B) * 255 < 60 or topY(b) > RAISE + 0.1 then return false end
		end
		return true
	end)(), #brick .. " runs, " .. fmt(brickLen) .. " studs")
local bl = anchor("BleacherL")
check("the retaining-wall steps (BleacherL / BleacherR) are brick red, as in the blueprint", bl ~= nil and anchor("BleacherR") ~= nil and bl.Color.R * 255 >= 140
	and (bl.Color.R - bl.Color.G) * 255 >= 50, bl and tostring(bl.Color) or "missing")

-- Forecourt: many parked cars, a row of small statues down the middle.
local nUpper = 0
if vehicles then
	for _, v in ipairs(vehicles:GetChildren()) do
		local body = v:FindFirstChild("VehicleBody", true)
		if body and body.Position.Y >= RAISE then nUpper += 1 end
	end
end
check("forecourt holds 16+ parked cars (the blueprint shows it nearly full)", nUpper >= 16, tostring(nUpper))
local sp, spBad = allNamed("StatuePlinth"), 0
for _, p in ipairs(sp) do
	if p.Position.Y < RAISE or p.Position.Z < 10 or p.Position.Z > WALL_Z - 2 or math.abs(p.Position.X) > 12 then spBad += 1 end
end
check("a row of 6+ small statues (StatuePlinth) down the middle of the forecourt (|x| <= 12, z 10..46)", #sp >= 6 and spBad == 0 and countNamed("StatueFigure") >= 6, #sp .. " plinths, " .. spBad .. " misplaced")

-- Step B round 4 (replaces the 4 mound assertions: "far corner x 97..119", "footprint 22+ ... above the podium", "stays on the podium z <= 47.25 ... clears both gateway posts",
-- and "straight edge on the wall"): the drawing's D-shaped mound is on the LOWER plaza at the west-middle, its straight edge on the retaining wall.
do
	local tiersM, flats, ribbons = allNamed("MoundTier"), allNamed("MoundTierFlat"), allNamed("MoundRibbon")
	local mBad, widest, zlo, zhi, xlo, xhi = {}, 0, math.huge, -math.huge, math.huge, -math.huge
	local cxm, czm = 0, 0
	for _, t in ipairs(tiersM) do
		widest = math.max(widest, t.Size.Y)
		xlo, xhi, zhi = math.min(xlo, t.Position.X - t.Size.Y / 2), math.max(xhi, t.Position.X + t.Size.Y / 2), math.max(zhi, t.Position.Z + t.Size.Y / 2)
		zlo = math.min(zlo, t.Position.Z - t.Size.Y / 2)
		cxm, czm = t.Position.X, t.Position.Z
		if t.Position.Y >= RAISE then table.insert(mBad, "tier") end
	end
	local ribTop, ribMax = 0, 0
	for _, r in ipairs(ribbons) do
		ribTop, ribMax = math.max(ribTop, topY(r)), math.max(ribMax, math.max(r.Size.Y, r.Size.Z))
	end
	-- B3c-0 (owner's colour markup; replaces "round 4 mound: on the lower plaza at the west-middle (x -100..-76), straight edge on the wall (flat blocks from z 48..50), 22+ wide, 18+ deep,
	-- 3 tiers"; old text in briefs/site01.md): the mound is fully round and stands on the plaza centre line, south of the three stair flights. Tier and ribbon counts are unchanged.
	local nearest = math.huge
	for _, name in ipairs({ "StairFlightL", "StairFlightC", "StairFlightR" }) do
		for _, s in ipairs(allNamed(name)) do
			local dx = math.max(math.abs(cxm - s.Position.X) - s.Size.X / 2, 0)
			local dz = math.max(math.abs(czm - s.Position.Z) - s.Size.Z / 2, 0)
			nearest = math.min(nearest, math.sqrt(dx * dx + dz * dz))
		end
	end
	retired("B3c-0 round mound (3+ cylinder tiers, ribbon) centred within 4 studs of x 0 on the lower plaza, 22+ wide, no D-shaped flat blocks, south of the stair flights and not overlapping them (2+ studs of ground between the biggest tier and the nearest flight)",
		#tiersM >= 3 and #flats == 0 and #mBad == 0 and math.abs(cxm) <= 4 and zlo >= 56 and widest >= 22 and zhi - zlo >= 22 and countNamed("MoundTier", Enum.PartType.Cylinder) >= 3 and nearest - widest / 2 >= 2,
		string.format("centre (%s, %s) x %s..%s z %s..%s wide %s flats %d bad %d clear %s", fmt(cxm), fmt(czm), fmt(xlo), fmt(xhi), fmt(zlo), fmt(zhi), fmt(widest), #flats, #mBad, fmt(nearest - widest / 2)))
	check("round 4 mound: ribbon sculpture of 28+ bars rising 14+ studs above the ground with bars 0.8+ thick", #ribbons >= 28 and ribTop >= 14 and ribMax >= 0.8,
		string.format("ribbons %d top %s", #ribbons, fmt(ribTop)))
end

-- Walled garden at the far side: trees and an iron fence; a north gateway arch on the C.M. Recto side (x >= 100).
local trees, treeBad = allNamed("GardenTreeCanopy"), 0
for _, t in ipairs(trees) do if t.Position.X < 36 or t.Position.X > 100 or t.Position.Y < RAISE + 6 then treeBad += 1 end end
check("walled garden: 6+ trees (GardenTreeCanopy) and 10+ iron-fence posts (GardenFencePost)", #trees >= 6 and treeBad == 0 and countNamed("GardenFencePost") >= 10,
	#trees .. " canopies, " .. countNamed("GardenFencePost") .. " posts")
local gl, gr = anchor("GatewayPostL"), anchor("GatewayPostR")
check("gateway arch (x >= 100, walk-through, 8+ studs clear, 14+ tall) with 16+ iron bars", gl ~= nil and gr ~= nil and gl.Position.X >= 100 and gl.Position.Y >= RAISE
	and math.abs(gl.Position.Z - gr.Position.Z) - gl.Size.Z >= 8 and countNamed("GatewayIron") >= 16 and (function()
		local top = 0
		for _, p in ipairs(allNamed("GatewayIron")) do top = math.max(top, topY(p)) end
		return top - RAISE >= 14
	end)(), gl and gr and fmt(math.abs(gl.Position.Z - gr.Position.Z)) or "missing")

-- Paved square: palm-planted green strip(s) with lamp posts.
local strip = anchor("GreenStrip")
local stripPalms = 0
if strip then
	for _, t in ipairs(allNamed("PalmTrunk1")) do
		if math.abs(t.Position.X - strip.Position.X) <= strip.Size.X / 2 and math.abs(t.Position.Z - strip.Position.Z) <= strip.Size.Z / 2 then stripPalms += 1 end
	end
end
check("palm-planted green strip on the paved plaza: a GreenStrip lawn at ground level with 5+ palms standing on it", strip ~= nil and strip.Position.Y < 0.6 and stripPalms >= 5,
	strip and (stripPalms .. " palms") or "missing")

------------------------------------------------------------------ Step B round 2: lot, paver square, stage, Cultural Center, mound, strips (briefs/site01.md "round 2")
-- 1. The walled asphalt parking lot (drawing: grey asphalt, yellow bays in rows, 25+ muted cars, a row of small statues down the centre).
check("round 2 lot: ApronPaving is dark asphalt grey (every channel <= 90, Asphalt material), 150+ studs wide, 36+ deep, on the podium",
	apron ~= nil and apron.Size.X >= 150 and apron.Size.Z >= 36 and math.max(apron.Color.R, apron.Color.G, apron.Color.B) * 255 <= 90 and apron.Material == Enum.Material.Asphalt,
	apron and string.format("w %s d %s %s %s", fmt(apron.Size.X), fmt(apron.Size.Z), tostring(apron.Color), tostring(apron.Material)) or "missing")
check("round 2 lot: 40+ yellow bay lines in two rows (20+ per row)", (function()
	local north, south = 0, 0
	for _, b in ipairs(allNamed("ParkingBayLine")) do if b.Position.Z < 30 then north += 1 else south += 1 end end
	return north >= 20 and south >= 20
end)(), #allNamed("ParkingBayLine") .. " lines")
local carCount, carMaxParts, carMuted, carOverlap = 0, 0, 0, {}
if vehicles then
	local carParams = OverlapParams.new()
	carParams.FilterType = Enum.RaycastFilterType.Include
	carParams.FilterDescendantsInstances = { site }
	carParams.RespectCanCollide = false
	for _, v in ipairs(vehicles:GetChildren()) do
		local body = v:FindFirstChild("VehicleBody", true)
		if body and body.Position.Y >= RAISE then
			carCount += 1
			local n = 0
			for _, d in ipairs(v:GetDescendants()) do if d:IsA("BasePart") then n += 1 end end
			carMaxParts = math.max(carMaxParts, n)
			local c = body.Color
			if (math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)) * 255 <= 110 then carMuted += 1 end
			for _, hit in ipairs(workspace:GetPartBoundsInBox(body.CFrame, body.Size * 0.98, carParams)) do
				if not hit:IsDescendantOf(v) and not isRig(hit) and hit.Size.Y > 0.5 and hit.Position.Y > RAISE + 0.6 then
					table.insert(carOverlap, v.Name .. " hits " .. (hit:GetFullName():gsub("^Workspace%.Sites%.Site01_Cathedral%.", "")))
				end
			end
		end
	end
end
check("round 2 lot: 25+ parked cars on the forecourt, each at most 5 parts", carCount >= 25 and carMaxParts <= 5, carCount .. " cars, max " .. carMaxParts .. " parts")
check("round 2 lot: car colours are muted (every body colour has a max-min channel spread <= 110)", carCount > 0 and carMuted == carCount, carMuted .. " / " .. carCount)
check("round 2 lot: no parked car overlaps a lamp, statue, monument, the Guide, InfoPanel, JeepStop or Jeepney", #carOverlap == 0, table.concat(carOverlap, "; ", 1, math.min(#carOverlap, 3)))

-- 2. The grey grid-paver square (about the size of the lot, with a shade tree, lamps and a lawn square).
check("round 2 plaza: ForecourtPaving is 150+ wide and 45+ deep with 20+ PaverJoint grid lines on it", paving ~= nil and paving.Size.X >= 150 and paving.Size.Z >= 45 and countNamed("PaverJoint") >= 20,
	paving and string.format("w %s d %s, %d joints", fmt(paving.Size.X), fmt(paving.Size.Z), countNamed("PaverJoint")) or "missing")
local lawnSq = anchor("LawnSquare")
local lawnPalms = 0
if lawnSq then
	for _, t in ipairs(allNamed("PalmTrunk1")) do
		if math.abs(t.Position.X - lawnSq.Position.X) <= lawnSq.Size.X / 2 + 3 and math.abs(t.Position.Z - lawnSq.Position.Z) <= lawnSq.Size.Z / 2 + 3 then lawnPalms += 1 end
	end
end
check("round 2 plaza: a LawnSquare (20+ x 20+ studs, ground level, green) ringed by 6+ palms", lawnSq ~= nil and lawnSq.Size.X >= 20 and lawnSq.Size.Z >= 20 and lawnSq.Position.Y < 0.6
	and lawnSq.Color.G > lawnSq.Color.R and lawnPalms >= 6, lawnSq and (lawnPalms .. " palms, " .. fmt(lawnSq.Size.X) .. " x " .. fmt(lawnSq.Size.Z)) or "missing")
local stripE, stripEPalms = anchor("GreenStripE"), 0
if stripE then
	for _, t in ipairs(allNamed("PalmTrunk1")) do
		if math.abs(t.Position.X - stripE.Position.X) <= stripE.Size.X / 2 and math.abs(t.Position.Z - stripE.Position.Z) <= stripE.Size.Z / 2 then stripEPalms += 1 end
	end
end
check("round 2 plaza: a second palm-planted strip (GreenStripE, 20+ studs long, 4+ palms), apart from the first strip", stripE ~= nil and strip ~= nil and stripE.Size.Z >= 20 and stripEPalms >= 4
	and math.abs(stripE.Position.X - strip.Position.X) >= 60 and stripE.Position.Y < 0.6, stripE and (stripEPalms .. " palms") or "missing")
check("round 2 plaza: 6+ lamp posts stand on the paver square (LampPole at ground level)", (function()
	local n = 0
	for _, l in ipairs(allNamed("LampPole")) do if l.Position.Z > WALL_Z then n += 1 end end
	return n >= 6
end)(), "")
check("round 2 plaza: the shade tree has a planter and a canopy 16+ studs wide overall", anchor("ShadeTreePlanter") ~= nil and (function()
	local lo, hi = math.huge, -math.huge
	for _, c in ipairs(allNamed("ShadeTreeCanopy")) do lo = math.min(lo, c.Position.X - c.Size.X / 2) hi = math.max(hi, c.Position.X + c.Size.X / 2) end
	return hi - lo >= 16
end)(), "")

-- 3. The stage pavilion: dark peaked roof, big enough to read at blueprint scale.
check("round 2 stage: StageDais 24+ wide and 12+ deep, roof ridge (StageRidge) 24+ long and 16+ studs above the ground, 8+ posts",
	dais ~= nil and dais.Size.X >= 24 and dais.Size.Z >= 12 and anchor("StageRidge") ~= nil and anchor("StageRidge").Size.X >= 24 and topY(anchor("StageRidge")) >= 16
		and countNamed("StagePavilionPost") >= 8,
	dais and anchor("StageRidge") and string.format("dais %s x %s, ridge %s long top %s, %d posts", fmt(dais.Size.X), fmt(dais.Size.Z), fmt(anchor("StageRidge").Size.X), fmt(topY(anchor("StageRidge"))), countNamed("StagePavilionPost")) or "missing")

-- 4. The D-shaped mound and the gateway arch, readable at blueprint scale.
-- (round 4: the round 2 mound-size assertion moved into the round 4 mound checks above)
check("round 2 gateway: stone posts 3+ wide, clear span 10+, iron arch 16+ above the podium with bars 0.6+ thick", gl ~= nil and gr ~= nil and gl.Size.Z >= 3
	and math.abs(gl.Position.Z - gr.Position.Z) - gl.Size.Z >= 10 and (function()
		local top, thick = 0, 9
		for _, p in ipairs(allNamed("GatewayIron")) do top = math.max(top, topY(p) - RAISE); thick = math.min(thick, p.Size.X) end
		return top >= 16 and thick >= 0.6
	end)(), gl and gr and fmt(math.abs(gl.Position.Z - gr.Position.Z)) or "missing")
-- (round 4: the "mound stays on the podium" assertion was replaced by the round 4 mound checks above; the gateway keeps its own checks)
check("round 2 garden: the walled garden stays east of the lot (all GardenHedge and GardenTreeCanopy at x 64..94) and the FlagPole stands at x 70..74", (function()
	for _, h in ipairs(allNamed("GardenHedge")) do if h.Position.X < 64 or h.Position.X > 94 then return false end end
	for _, h in ipairs(allNamed("GardenTreeCanopy")) do if h.Position.X < 64 or h.Position.X > 94 then return false end end
	for _, fp in ipairs(allNamed("FlagPole")) do if fp.Position.X >= 70 and fp.Position.X <= 74 then return true end end
	return false
end)(), "")


------------------------------------------------------------------ Step B round 4 (briefs/site01.md "Slice 4 step B round 4"): the stacked layout against the rotated plaza drawing
do
	-- 1. B3c-0 (owner's colour markup 2026-10-27). The parish wing is gone (red, black, blue marks) and an iron fence runs its old edges. These round 4 checks are replaced (old text and
	-- reasons are logged in briefs/site01.md): "round 4 wing: ParishWingBody ranges on the west edge ...", "the side stairs stay open (no wing range between z 20 and 32)",
	-- "2+ cross ranges (ParishWingCrossBody ...)", "LongBuildingW is the 2-storey end of the wing ...", "red tile roofs (12+ roof slopes incl. LongRoof ...)", "60+ arched windows (ParishWin_Pane) and 2+ ... doors".
	local fencePosts, fenceRails = allNamed("IronFencePost"), allNamed("IronFenceRail")
	local function fenceRun(filter, axis, lo, hi)
		local vals = {}
		for _, p in ipairs(fencePosts) do
			if filter(p) then table.insert(vals, axis == "z" and p.Position.Z or p.Position.X) end
		end
		table.sort(vals)
		if #vals < 2 or vals[1] > lo + 1 or vals[#vals] < hi - 1 then return false, #vals .. " posts, " .. (vals[1] and (fmt(vals[1]) .. ".." .. fmt(vals[#vals])) or "none") end
		for i = 2, #vals do
			if vals[i] - vals[i - 1] > 6 then return false, "gap " .. fmt(vals[i - 1]) .. ".." .. fmt(vals[i]) end
		end
		return true, #vals .. " posts"
	end
	local okW1, dW1 = fenceRun(function(p) return math.abs(p.Position.X + 119.5) < 0.6 and p.Position.Y >= RAISE and p.Position.Z < 20.5 end, "z", -99, 19)
	local okW2, dW2 = fenceRun(function(p) return math.abs(p.Position.X + 119.5) < 0.6 and p.Position.Y >= RAISE and p.Position.Z > 32.5 end, "z", 33, WALL_Z - 1)
	local okN, dN = fenceRun(function(p) return math.abs(p.Position.Z + 99.5) < 0.6 and p.Position.Y >= RAISE and p.Position.X < -50 end, "x", -119.5, -52)
	local okK, dK = fenceRun(function(p) return math.abs(p.Position.X + 100.5) < 0.6 and p.Position.Y < RAISE end, "z", WALL_Z + 1.5, PLAZA_S)
	check("B3c-0 iron fence runs the west podium edge (x -119.5, z -99..19 and 33..WALL_Z-1), the north edge (z -99.5, x -119.5..-52) and the plaza west kerb (x -100.5, z WALL_Z+1.5..PLAZA_S; the gate gap is closed, B3c-0b; B3c-1), posts every 6 studs or less",
		okW1 and okW2 and okN and okK, "west " .. dW1 .. " / " .. dW2 .. "; north " .. dN .. "; kerb " .. dK)
	local fenceBad, gapHit = {}, {}
	for _, p in ipairs(fencePosts) do
		local base = p.Position.Y >= RAISE and RAISE or 0
		if math.abs(topY(p) - base - 3) > 0.15 then table.insert(fenceBad, "post top " .. fmt(topY(p) - base)) end
		if math.max(p.Color.R, p.Color.G, p.Color.B) * 255 > 70 then table.insert(fenceBad, "post colour") end
	end
	for _, r in ipairs(fenceRails) do
		local base = r.Position.Y >= RAISE and RAISE or 0
		if topY(r) - base > 3.1 or math.max(r.Color.R, r.Color.G, r.Color.B) * 255 > 70 then table.insert(fenceBad, "rail") end
	end
	for _, p in ipairs(fencePosts) do
		if p.Position.X < -118 and p.Position.Z > 19.5 and p.Position.Z < 32.5 then table.insert(gapHit, "post z" .. fmt(p.Position.Z)) end
	end
	for _, r in ipairs(fenceRails) do
		if r.Position.X < -118 and r.Position.Z + r.Size.Z / 2 > 20.2 and r.Position.Z - r.Size.Z / 2 < 31.8 then table.insert(gapHit, "rail z" .. fmt(r.Position.Z)) end
	end
	for _, p in ipairs(fencePosts) do
		if math.abs(p.Position.X + 100.5) < 0.6 and p.Position.Y < RAISE and p.Position.Z < WALL_Z + 1 then table.insert(gapHit, "gate post z" .. fmt(p.Position.Z)) end
	end
	for _, r in ipairs(fenceRails) do
		if math.abs(r.Position.X + 100.5) < 0.6 and r.Position.Y < RAISE and r.Position.Z - r.Size.Z / 2 < WALL_Z + 1 then table.insert(gapHit, "gate rail z" .. fmt(r.Position.Z)) end
	end
	check("B3c-0 iron fence is 3 studs tall and black like the garden fence, 40+ posts, and the stair gap (SideStairsW, z 20..32) stays open (the plaza gate gap is closed, B3c-0b)", #fenceBad == 0 and #gapHit == 0 and #fencePosts >= 40 and #fenceRails >= 6,
		#fencePosts .. " posts, " .. #fenceRails .. " rails; " .. table.concat(fenceBad, ", ", 1, math.min(#fenceBad, 3)) .. table.concat(gapHit, ", ", 1, math.min(#gapHit, 3)))
	-- 1b. B3c-0: the ChurchAnnex (magenta mark): one straight-edged 2-storey block on the green lawn between the east transept and the long east wing. Measured box (journal): x 45.4..94, z -99..-42.
	do
		local annex, abody = site:FindFirstChild("ChurchAnnex"), anchor("AnnexBody")
		local wBack, wEave, aEave = anchor("WingBackWall"), anchor("WingEave"), anchor("AnnexEave")
		local nA = 0
		local alo, ahi = Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
		if annex then
			for _, d in ipairs(annex:GetDescendants()) do
				if d:IsA("BasePart") then
					nA += 1
					local a, b = aabb(d)
					alo = Vector3.new(math.min(alo.X, a.X), math.min(alo.Y, a.Y), math.min(alo.Z, a.Z))
					ahi = Vector3.new(math.max(ahi.X, b.X), math.max(ahi.Y, b.Y), math.max(ahi.Z, b.Z))
				end
			end
		end
		check("B3c-0 ChurchAnnex is a Site child (not under Structure) of 100+ parts", annex ~= nil and annex:IsA("Model") and annex.Parent == site and nA >= 100, annex and tostring(nA) or "missing")
		local a0, a1 = Vector3.zero, Vector3.zero
		if abody then a0, a1 = aabb(abody) end
		check("B3c-0 ChurchAnnex measured box: AnnexBody x 45.4..94, z -99..-42 (within 0.3), 25+ tall (2 storeys); the whole annex inside x 44.5..95.5, z -100..-41",
			abody ~= nil and math.abs(a0.X - 45.4) < 0.3 and math.abs(a1.X - 94) < 0.3 and math.abs(a0.Z + 99) < 0.3 and math.abs(a1.Z + 42) < 0.3 and abody.Size.Y >= 25
				and alo.X >= 44.5 and ahi.X <= 95.5 and alo.Z >= -100 and ahi.Z <= -41,
			abody and string.format("body x %s..%s z %s..%s h %s; all x %s..%s z %s..%s", fmt(a0.X), fmt(a1.X), fmt(a0.Z), fmt(a1.Z), fmt(abody.Size.Y), fmt(alo.X), fmt(ahi.X), fmt(alo.Z), fmt(ahi.Z)) or "missing")
		check("B3c-0 ChurchAnnex touches the east wing's back wall (z -42, 40+ studs of shared run), its eave top is within 1 stud of the wing's eave, and it sits on the podium",
			abody ~= nil and wBack ~= nil and wEave ~= nil and aEave ~= nil and math.abs(a1.Z - (wBack.Position.Z - wBack.Size.Z / 2)) < 0.3
				and math.min(a1.X, wBack.Position.X + wBack.Size.X / 2) - math.max(a0.X, wBack.Position.X - wBack.Size.X / 2) >= 40
				and math.abs(topY(aEave) - topY(wEave)) <= 1 and math.abs(a0.Y - RAISE) < 0.1,
			abody and wEave and aEave and string.format("eave %s vs %s, south face %s", fmt(aEave and topY(aEave)), fmt(topY(wEave)), fmt(a1.Z)) or "missing")
		local rb, ribs, redBad = allNamed("AnnexRoof"), allNamed("AnnexRib"), 0
		for _, r in ipairs(rb) do
			if r.Color.R * 255 < 150 or r.Color.G * 255 > 70 or r.Color.B * 255 > 70 then redBad += 1 end
		end
		local wc = abody and abody.Color
		check("B3c-0 ChurchAnnex reads as one block with the church: butter-yellow walls (as WingUpper), 12+ arched windows (AnnexWin_Pane), a storey band, a red roof (2 slopes, R >= 150, G and B <= 70) with 20+ ribs",
			abody ~= nil and anchor("WingUpper") ~= nil and wc == anchor("WingUpper").Color and countNamed("AnnexWin_Pane") >= 12 and anchor("AnnexBand") ~= nil and #rb >= 2 and redBad == 0 and #ribs >= 20,
			countNamed("AnnexWin_Pane") .. " windows, " .. #rb .. " roof slopes, " .. redBad .. " not red, " .. #ribs .. " ribs")
		local palmIn = 0
		for _, t in ipairs(allNamed("PalmTrunk1")) do
			if t.Position.Y >= RAISE and t.Position.X > 44.5 and t.Position.X < 95.5 and t.Position.Z > -100 and t.Position.Z < -41 then palmIn += 1 end
		end
		check("B3c-0 no palm stands inside the annex (the palm at (60,-72) moved onto the lawn east of it)", palmIn == 0, palmIn .. " palms inside")
		local st = site:FindFirstChild("Structure")
		local nS, slo, shi = 0, Vector3.new(1e9, 1e9, 1e9), Vector3.new(-1e9, -1e9, -1e9)
		if st then
			for _, d in ipairs(st:GetDescendants()) do
				if d:IsA("BasePart") then
					nS += 1
					local a, b = aabb(d)
					slo = Vector3.new(math.min(slo.X, a.X), math.min(slo.Y, a.Y), math.min(slo.Z, a.Z))
					shi = Vector3.new(math.max(shi.X, b.X), math.max(shi.Y, b.Y), math.max(shi.Z, b.Z))
				end
			end
		end
		check("B3c-0 church Structure is untouched by the annex: still 763 parts, box (-48.2, 5, -100.8)..(121.2, 89.5, 9.8)",
			nS == 763 and (slo - Vector3.new(-48.2, 5, -100.8)).Magnitude < 0.1 and (shi - Vector3.new(121.2, 89.5, 9.8)).Magnitude < 0.1, nS .. " parts")
	end
	-- 2. The lot: full width between the wing and the garden wall, 36+ cars.
	local a0, a1 = Vector3.zero, Vector3.zero
	if apron then a0, a1 = aabb(apron) end
	-- B3c-0 (replaces "round 4 lot: the asphalt spans from the wing (x <= -103) to the garden wall (x >= 62)"): the wing is gone, so the asphalt runs on west to the new fence (x -119.5).
	check("B3c-0 lot: the asphalt spans from x -117.5 (two corner pieces take it on to the west fence at x -119.5, leaving the stair strip z 20..32 bare: B3c-0b) to the garden wall (x >= 62)", apron ~= nil and a0.X <= -117.4 and a1.X >= 62 and anchor("ApronPavingWestN") ~= nil and anchor("ApronPavingWestS") ~= nil, string.format("x %s..%s", fmt(a0.X), fmt(a1.X)))
	check("round 4 lot: 36+ parked cars, yellow bay lines still 40+", carCount >= 36 and #allNamed("ParkingBayLine") >= 40, carCount .. " cars, " .. #allNamed("ParkingBayLine") .. " lines")
	local nw = anchor("ApronPavingNW")
	-- B3c-0 (replaces "round 4 lot: the bare lawn and palms west of the tower are gone (no PodiumLawn or upper PalmTrunk1 at x < -48); asphalt (ApronPavingNW) takes their place"): the
	-- owner markup turns the old courtyard block (x -120..-52, z -99..-48) into lawn with two palms, like behind the church. Asphalt (ApronPavingNW) still covers z -46..10 up to the fence.
	local lawnW, palmW, palmBad = anchor("WestLawn"), 0, 0
	for _, t in ipairs(allNamed("PalmTrunk1")) do
		if t.Position.X < -48 and t.Position.Y >= RAISE and t.Position.Z < 10 then
			palmW += 1
			if t.Position.Z > -50 or lawnW == nil or math.abs(t.Position.X - lawnW.Position.X) > lawnW.Size.X / 2 then palmBad += 1 end
		end
	end
	check("B3c-0 lot: the old courtyard block is a lawn (WestLawn, x -119.5..-50, z -99..-46, on the podium) with exactly two palms standing on it; asphalt (ApronPavingNW) runs west to x <= -119 and takes the rest",
		lawnW ~= nil and lawnW.Position.Y >= RAISE and lawnW.Position.X - lawnW.Size.X / 2 <= -119 and lawnW.Position.X + lawnW.Size.X / 2 >= -52 and lawnW.Position.Z - lawnW.Size.Z / 2 <= -98.5
			and lawnW.Position.Z + lawnW.Size.Z / 2 >= -47 and lawnW.Color.G > lawnW.Color.R and palmW == 2 and palmBad == 0
			and nw ~= nil and nw.Position.X < -70 and nw.Position.X - nw.Size.X / 2 <= -119 and nw.Material == Enum.Material.Asphalt,
		(lawnW and "lawn ok" or "no WestLawn") .. ", " .. palmW .. " palms, " .. palmBad .. " off the lawn")
	-- 3. The plaza: Cultural Center E. B3c-0 (owner markup; replaces "round 4 plaza: the stage pavilion is on the west (dais x < -70) and the Cultural Center on the east"): the stage moved to the centre line, the Cultural Center stays east.
	check("B3c-0 plaza: the stage pavilion is on the centre line (dais |x| <= 4) and the Cultural Center on the west (centre x < -70, west face x <= -96; B3c-0b)",
		dais ~= nil and cc ~= nil and math.abs(dais.Position.X) <= 4 and cc.Position.X < -70 and cc.Position.X - cc.Size.X / 2 <= -96,
		dais and cc and string.format("dais %s, cc %s..%s", fmt(dais.Position.X), fmt(cc.Position.X - cc.Size.X / 2), fmt(cc.Position.X + cc.Size.X / 2)) or "missing")
end
------------------------------------------------------------------ B3c-0b (the owner's second colour markup, 2026-10-27; briefs/site01.md "B3c-0b")
do
	local function overlaps(p, x0, x1, z0, z1)
		local a, b = aabb(p)
		return b.X > x0 and a.X < x1 and b.Z > z0 and a.Z < z1
	end
	local function listed(t) return table.concat(t, ", ", 1, math.min(#t, 3)) end
	-- Magenta: the asphalt west of the tower holds two staggered rows of cars with bay lines and a drive aisle between them.
	local nBox, outBox, onLane, rowZ = 0, {}, {}, {}
	if vehicles then
		for _, v in ipairs(vehicles:GetChildren()) do
			local body = v:FindFirstChild("VehicleBody", true)
			if body and body.Position.Y >= RAISE then
				local a, b = aabb(body)
				if body.Position.Z < 10 then
					nBox += 1
					rowZ[math.floor(body.Position.Z + 0.5)] = true
					if a.X < -115 or b.X > -55 or a.Z < -42 or b.Z > 6 then table.insert(outBox, v.Name) end
				end
				if overlaps(body, -121, -98.5, 20, 32) or overlaps(body, 91, 121, 20, 32) then table.insert(onLane, v.Name) end
			end
		end
	end
	local nwBays, nRows = 0, 0
	for _, b in ipairs(allNamed("ParkingBayLine")) do
		if b.Position.Z < 10 and b.Position.X > -116 and b.Position.X < -54 then nwBays += 1 end
	end
	local zs = {}
	for z in pairs(rowZ) do table.insert(zs, z) nRows += 1 end
	table.sort(zs)
	check("B3c-0b magenta lot: 16+ cars stand inside x -115..-55, z -42..6 (none outside), in 2 rows with a drive aisle 12+ studs wide between them, and 16+ yellow bay lines there",
		nBox >= 16 and #outBox == 0 and nwBays >= 16 and nRows == 2 and (zs[2] - zs[1]) - 10 >= 12, nBox .. " cars, " .. #outBox .. " outside, " .. nwBays .. " bay lines, rows " .. table.concat(zs, "/"))
	check("B3c-0b no parked car stands on an entrance lane (x +-98.5..121, z 20..32)", #onLane == 0, listed(onLane))
	-- Orange: the gateway arch, the east stair and EAST_ENTRY (and the west stair and WEST_ENTRY) share z 26; a pale walkway runs from each stair top into the lot.
	local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())
	local roadZ = {}
	for _, road in ipairs(RoadData.NEW_ROADS) do
		if road.name == "WEST_ENTRY" or road.name == "EAST_ENTRY" then roadZ[road.name] = { road.pts[1][2], road.pts[#road.pts][2] } end
	end
	local stairZ = { SideStairsW = {}, SideStairsE = {} }
	for name, list in pairs(stairZ) do for _, s in ipairs(allNamed(name)) do table.insert(list, s.Position.Z) end end
	local gzMid = (gl and gr) and (gl.Position.Z + gr.Position.Z) / 2 or math.huge
	local function near26(t) if #t == 0 then return false end for _, z in ipairs(t) do if math.abs(z - 26) > 1 then return false end end return true end
	check("B3c-0b east entrance: the gateway arch (post midpoint z), SideStairsE and the EAST_ENTRY road all stand on z 26 (within 1 stud)",
		math.abs(gzMid - 26) <= 1 and near26(stairZ.SideStairsE) and roadZ.EAST_ENTRY ~= nil and near26(roadZ.EAST_ENTRY), "arch z " .. fmt(gzMid))
	check("B3c-0b west entrance: SideStairsW and the WEST_ENTRY road stand on z 26 (within 1 stud)", near26(stairZ.SideStairsW) and roadZ.WEST_ENTRY ~= nil and near26(roadZ.WEST_ENTRY), "")
	local function walk(side)
		local ivs, widthOk = {}, true
		for _, nm in ipairs({ "EntryWalkW", "EntryWalkE", "GatewayPath" }) do
			for _, p in ipairs(allNamed(nm)) do
				local c = p.Color
				if p.Position.X * side > 0 and math.abs(p.Position.Z - 26) <= 1 and math.abs(c.R * 255 - 214) < 2 and math.abs(c.G * 255 - 206) < 2 then
					table.insert(ivs, { p.Position.X - p.Size.X / 2, p.Position.X + p.Size.X / 2 })
					if p.Size.Z < 8 or p.Size.Z > 12.1 then widthOk = false end
				end
			end
		end
		table.sort(ivs, function(a, b) return a[1] < b[1] end)
		local lo, hi = math.huge, -math.huge
		for i, iv in ipairs(ivs) do
			if i > 1 and iv[1] > hi + 0.05 then return false, "gap" end
			lo, hi = math.min(lo, iv[1]), math.max(hi, iv[2])
		end
		if side < 0 then return widthOk and #ivs > 0 and lo <= -117.4 and hi >= -100.1, string.format("x %s..%s", fmt(lo), fmt(hi)) end
		return widthOk and #ivs > 0 and lo <= 100.1 and hi >= 117.9, string.format("x %s..%s", fmt(lo), fmt(hi))
	end
	local okWalkW, dWalkW = walk(-1)
	local okWalkE, dWalkE = walk(1)
	check("B3c-0b pale stone walkways (STONE_LIGHT, 8..12 wide, on z 26) run from the west stair top (x -120) to x -100 and from the east stair top (x 120) to x 100 without a gap", okWalkW and okWalkE, "west " .. dWalkW .. " / east " .. dWalkE)
	local walkHits = {}
	for _, nm in ipairs({ "EntryWalkW", "EntryWalkE" }) do
		for _, w in ipairs(allNamed(nm)) do
			local a, b = aabb(w)
			for _, other in ipairs({ "ParkingBayLine", "LampBase", "LampPole", "StatuePlinth", "ParkingAisleLine" }) do
				for _, o in ipairs(allNamed(other)) do
					if overlaps(o, a.X, b.X, a.Z, b.Z) then table.insert(walkHits, nm .. " x " .. other) end
				end
			end
		end
	end
	check("B3c-0b the entry walkways are clear of bay lines, lamps, statues and aisle lines", #allNamed("EntryWalkW") >= 1 and #allNamed("EntryWalkE") >= 1 and #walkHits == 0, listed(walkHits))
	local edgeHits = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then
			local a, b = aabb(d)
			if b.Y > RAISE + 0.05 and b.Z > 20 and a.Z < 32 and ((b.X > 118 and a.X < 120.2) or (a.X < -118 and b.X > -120.2)) and d.Parent.Name ~= "JeepStop" then table.insert(edgeHits, d.Name .. " top " .. fmt(b.Y - RAISE)) end
		end
	end
	check("B3c-0b nothing rises more than 0.05 above the podium on the stair edge strip (|x| 118..120.2, z 20..32): the last side step stays 1 stud (routes_check)", #edgeHits == 0, listed(edgeHits))
	local openHits = {}
	for _, p in ipairs(allNamed("GardenFencePost")) do
		if p.Position.X > 88 and p.Position.Z > 12.5 and p.Position.Z < 33.5 then table.insert(openHits, "post z" .. fmt(p.Position.Z)) end
	end
	check("B3c-0b the garden's east side stays open from z 12.5 to 33.5 (no GardenFencePost) in front of the moved gateway", #openHits == 0, listed(openHits))
	-- Green: the Cultural Center stands on the plaza's west side and faces east.
	local door, steps = anchor("CCDoor_Pane"), anchor("CulturalCenterSteps")
	local eastWins, beds, bedsEast = 0, 0, 0
	if cc then
		for _, w in ipairs(allNamed("CCWin_Pane")) do if w.Position.X >= cc.Position.X + cc.Size.X / 2 then eastWins += 1 end end
		for _, b in ipairs(allNamed("FlowerBed")) do
			if b.Position.X > cc.Position.X + cc.Size.X / 2 and b.Position.X < cc.Position.X + cc.Size.X / 2 + 6 then beds += 1 end
			if b.Position.X > 0 then bedsEast += 1 end
		end
	end
	check("B3c-0b Cultural Center: on the west (x < -70), door, steps and 3+ east-face CCWin_Pane windows all east of the body centre, 4+ flower beds just east of it, none left on the east side",
		cc ~= nil and cc.Position.X < -70 and door ~= nil and door.Position.X > cc.Position.X + cc.Size.X / 2 - 0.5 and steps ~= nil and steps.Position.X > cc.Position.X + cc.Size.X / 2
			and eastWins >= 3 and beds >= 4 and bedsEast == 0 and countNamed("CCDoor_Pane") == 1,
		cc and string.format("door %s steps %s eastWins %d beds %d/%d", fmt(door and door.Position.X), fmt(steps and steps.Position.X), eastWins, beds, bedsEast) or "missing")
	local stripHits = {}
	if cc then
		for _, nm in ipairs({ "GreenStrip", "StripHedge" }) do
			for _, s in ipairs(allNamed(nm)) do
				if s.Position.X < 0 then
					for _, other in ipairs({ "CulturalCenterBody", "CulturalCenterSteps", "FlowerBed", "CulturalCenterPlinth" }) do
						for _, o in ipairs(allNamed(other)) do
							local a, b = aabb(o)
							if overlaps(s, a.X, b.X, a.Z, b.Z) then table.insert(stripHits, nm .. " x " .. other) end
						end
					end
				end
			end
		end
		for _, t in ipairs(allNamed("PalmTrunk1")) do
			if t.Position.Y < 1 and t.Position.X < -66 and t.Position.X > -100 and t.Position.Z > WALL_Z + 8 then table.insert(stripHits, "palm " .. fmt(t.Position.X)) end
		end
	end
	check("B3c-0b the west palm strip, its hedges and the plaza palms leave the Cultural Center, its steps and beds alone", #stripHits == 0, listed(stripHits))
	-- Blue: every plaza fence is black (LAMP_METAL), none white.
	local fenceColor = {}
	for _, nm in ipairs({ "FencePost", "FenceRail" }) do
		for _, p in ipairs(allNamed(nm)) do
			local c = p.Color
			if math.max(c.R, c.G, c.B) * 255 > 70 then table.insert(fenceColor, nm .. " " .. tostring(c)) end
		end
	end
	check("B3c-0b FencePost / FenceRail are black (every channel <= 70), none white, 20+ posts kept", #fenceColor == 0 and countNamed("FencePost") >= 20 and countNamed("FenceRail") >= 4, #fenceColor .. " not black, " .. countNamed("FencePost") .. " posts")
	-- Red: the arch is gone and its gap, the west gate and the east side are closed with the same fence.
	local function lineGap(alongX, fixed, lo, hi)
		local ivs = {}
		for _, nm in ipairs({ "FenceRail", "IronFenceRail" }) do
			for _, r in ipairs(allNamed(nm)) do
				if math.abs((alongX and r.Position.Z or r.Position.X) - fixed) < 0.6 and r.Position.Y < RAISE then
					local a, b = aabb(r)
					table.insert(ivs, alongX and { a.X, b.X } or { a.Z, b.Z })
				end
			end
		end
		table.sort(ivs, function(a, b) return a[1] < b[1] end)
		local cur, worst = lo, 0
		for _, iv in ipairs(ivs) do
			if iv[1] > cur then worst = math.max(worst, iv[1] - cur) end
			cur = math.max(cur, iv[2])
		end
		return math.max(worst, hi - cur), #ivs
	end
	local gS, nS = lineGap(true, PLAZA_S, -96, 96)
	local gW, nWk = lineGap(false, -100.5, WALL_Z + 1.5, PLAZA_S)
	local gE, nE = lineGap(false, 99.4, WALL_Z + 1.5, PLAZA_S)
	check("B3c-0b the plaza has no gap on its south (x -96..96 at z PLAZA_S), west (z WALL_Z+1.5..PLAZA_S at x -100.5) or east (same at x 99.4) fence line: no open stretch longer than 1 stud (B3c-1: the lines moved with the stretch)",
		nS > 0 and nWk > 0 and nE > 0 and gS <= 1 and gW <= 1 and gE <= 1, string.format("gaps S %s W %s E %s", fmt(gS), fmt(gW), fmt(gE)))
	local archLeft = {}
	for _, d in ipairs(workspace:GetDescendants()) do
		local n = d.Name
		if n == "WelcomeArch" or n == "GatepostL" or n == "GatepostR" or n == "GatepostCap" or n == "GatepostPlinth" or n == "ArchIron" or n == "ArchSign" or n == "ArchCrossV" or n == "ArchCrossH" or n == "ArchYearL" or n == "ArchYearR"
			or (d:IsA("TextLabel") and d.Text:find("10 de ABRIL", 1, true)) then
			table.insert(archLeft, n)
		end
	end
	check("B3c-0b no WelcomeArch component or arch parts (gateposts, ArchIron, ArchSign, sign text) remain anywhere in the workspace", #archLeft == 0 and site:FindFirstChild("WelcomeArch") == nil, #archLeft .. " left: " .. listed(archLeft))
	-- Black: the statue stands in the middle of the stairs, D-shaped, flat back on the wall; the side flights moved out.
	do
		local tiersM, flats = allNamed("MoundTier"), allNamed("MoundTierFlat")
		local widest, cxm, flatBad, leak = 0, 0, 0, {}
		for _, t in ipairs(tiersM) do widest, cxm = math.max(widest, t.Size.Y), t.Position.X end
		for _, f in ipairs(flats) do
			if math.abs(f.Position.Z - f.Size.Z / 2 - WALL_Z) > 1.5 or math.abs(f.Position.X) > 1 then flatBad += 1 end
		end
		for _, nm in ipairs({ "MoundTier", "MoundTierFlat", "MoundBase", "MoundRibbon" }) do
			for _, m in ipairs(allNamed(nm)) do
				local a, b = aabb(m)
				if a.Z < WALL_Z - 0.5 and b.Y > RAISE + 0.1 then table.insert(leak, nm) end
			end
		end
		local clearL, clearR = math.huge, math.huge
		for _, s in ipairs(allNamed("StairFlightL")) do clearL = math.min(clearL, -(s.Position.X + s.Size.X / 2) - widest / 2) end
		for _, s in ipairs(allNamed("StairFlightR")) do clearR = math.min(clearR, (s.Position.X - s.Size.X / 2) - widest / 2) end
		check("B3c-0b statue (black mark): D-shaped (3+ round tiers and 3 MoundTierFlat blocks) centred on x 0 within 1 stud, 22+ wide, flat back within 1.5 studs of the wall (z 48), nothing above the podium top north of z WALL_Z-0.5, side flights 1+ stud clear of it, no StairFlightC",
			#tiersM >= 3 and #flats == 3 and flatBad == 0 and math.abs(cxm) <= 1 and widest >= 22 and #leak == 0 and clearL >= 0.99 and clearR >= 0.99 and #allNamed("StairFlightC") == 0,
			string.format("tiers %d flats %d (bad %d) centre x %s wide %s leaks %d clear %s/%s StairFlightC %d", #tiersM, #flats, flatBad, fmt(cxm), fmt(widest), #leak, fmt(clearL), fmt(clearR), #allNamed("StairFlightC")))
		check("B3c-0b the stage dais stays 6+ studs from the moved statue (dais north edge vs statue front)", dais ~= nil and tiersM[1] ~= nil and (dais.Position.Z - dais.Size.Z / 2) - (tiersM[1].Position.Z + widest / 2) >= 6,
			dais and tiersM[1] and fmt((dais.Position.Z - dais.Size.Z / 2) - (tiersM[1].Position.Z + widest / 2)) or "missing")
		check("B3c-0b EventStage holds StairFlightL, StairFlightR and the seating (no StairFlightC, no gazebo stage)", stage ~= nil and anchor("StairFlightL") ~= nil and anchor("StairFlightL"):IsDescendantOf(stage)
			and anchor("StairFlightR") ~= nil and anchor("StairFlightR"):IsDescendantOf(stage) and anchor("BleacherL") ~= nil and anchor("BleacherL"):IsDescendantOf(stage) and anchor("StairFlightC") == nil
			and anchor("StageLanding") == nil and anchor("StageCanopy") == nil and anchor("StageFascia") == nil and countNamed("StagePost") == 0, "")
	end
end
------------------------------------------------------------------ B3c-1: the compound is stretched onto the grown slot (the wall at z 112, the plaza to the fence at z 198)
do
	local function zr(p) if not p then return math.huge, -math.huge end local a, b = aabb(p) return a.Z, b.Z end
	-- the real south fence line, measured on the two long FenceRail runs (not read back from the constants)
	local fz, nSouth, fzMax, flatMax = nil, 0, -math.huge, -math.huge
	for _, nm in ipairs({ "FenceRail", "FencePost", "IronFenceRail", "IronFencePost" }) do
		for _, r in ipairs(allNamed(nm)) do
			if nm == "FenceRail" and r.Size.X > 100 then fz, nSouth = r.Position.Z, nSouth + 1 end
			fzMax = math.max(fzMax, select(2, zr(r)))
		end
	end
	for _, nm in ipairs({ "KerbSouthW", "KerbSouthE", "ForecourtPaving" }) do
		for _, p in ipairs(allNamed(nm)) do flatMax = math.max(flatMax, select(2, zr(p))) end
	end
	check("B3c-1 the south fence line is at PLAZA_S (195) within 0.5, measured on the real rails (two long rails on one line)", fz ~= nil and nSouth == 2 and math.abs(fz - PLAZA_S) <= 0.5, fz and fmt(fz) or "no long rail")
	local board = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CreditsBoard")
	local bcf, bsz
	if board then bcf, bsz = board:GetBoundingBox() end
	check("B3c-1 the plaza's south fence (posts and rails) stays 4+ studs clear of the CreditsBoard's keep-out line (board min z - 4): max z <= board min z - 8; the kerb and paving (0.3 thick) stay under the keep-out line (max z <= board min z - 4.4)",
		board ~= nil and fzMax > PLAZA_S - 1 and fzMax <= bcf.Z - bsz.Z / 2 - 8 + 0.001 and flatMax <= bcf.Z - bsz.Z / 2 - 4.4 + 0.001,
		board and string.format("fence max z %s, kerb/paving max z %s, board min z %s", fmt(fzMax), fmt(flatMax), fmt(bcf.Z - bsz.Z / 2)) or "CreditsBoard missing")
	-- the three bands: the church z -100..10 is unchanged; the lot runs on to the wall; the plaza runs from the wall to the fence
	local az0, az1 = zr(apron)
	local ea, wsA = anchor("ApronPavingEast"), anchor("ApronPavingWestS")
	local ez0, ez1 = zr(ea)
	local wz0, wz1 = zr(wsA)
	local gz0, gz1 = zr(anchor("GardenApron"))
	local eA, eB = Vector3.zero, Vector3.zero
	if ea then eA, eB = aabb(ea) end
	check("B3c-1 the lot is 90+ deep and runs on to the wall: ApronPaving z <= 12 .. WALL_Z; ApronPavingEast (x 64..119.5, z 48..WALL_Z, Asphalt) and ApronPavingWestS (z <= 32.1 .. WALL_Z) reach it too; GardenApron keeps its old stone extent (z <= 48.3)",
		apron ~= nil and az1 - az0 >= 90 and math.abs(az1 - WALL_Z) <= 0.3 and ea ~= nil and eA.X <= 64.1 and eB.X >= 119.4 and math.abs(ez0 - 48) <= 0.3 and math.abs(ez1 - WALL_Z) <= 0.3
			and ea.Material == Enum.Material.Asphalt and wsA ~= nil and wz0 <= 32.1 and math.abs(wz1 - WALL_Z) <= 0.3 and gz1 <= 48.3,
		string.format("apron z %s..%s east %s..%s westS %s..%s garden to %s", fmt(az0), fmt(az1), fmt(ez0), fmt(ez1), fmt(wz0), fmt(wz1), fmt(gz1)))
	local pz0, pz1 = zr(paving)
	check("B3c-1 the plaza is 80+ deep (ForecourtPaving z WALL_Z .. PLAZA_S+0.4, measured on the part) and the three bands are each about a third of the length (church 110, lot 90+, plaza 80+)",
		paving ~= nil and pz1 - pz0 >= 80 and math.abs(pz0 - WALL_Z) <= 0.3 and pz1 - pz0 <= 90, paving and string.format("z %s..%s", fmt(pz0), fmt(pz1)) or "missing")
	-- the layout on the new geometry
	local mid = (WALL_Z + (fz or PLAZA_S)) / 2
	local tiersM = allNamed("MoundTier")
	local ccz = cc and cc.Position.Z or 0
	local door = anchor("CCDoor_Pane")
	check("B3c-1 statue: first tier centre within 0.5 of (0, WALL_Z+2), on the middle of the stairs, its flat back on the wall",
		#tiersM >= 1 and math.abs(tiersM[1].Position.Z - (WALL_Z + 2)) <= 0.5 and math.abs(tiersM[1].Position.X) <= 1, tiersM[1] and fmt(tiersM[1].Position.Z) or "no tier")
	check("B3c-1 stage: dais centre within 4 studs of x 0 and within 15 of the measured south fence line, still open to the north", dais ~= nil and fz ~= nil and math.abs(dais.Position.X) <= 4 and math.abs(fz - dais.Position.Z) <= 15
		and anchor("StageBackWall") ~= nil and anchor("StageBackWall").Position.Z > dais.Position.Z + 4, dais and fz and string.format("dais z %s fence %s", fmt(dais.Position.Z), fmt(fz)) or "missing")
	check("B3c-1 Cultural Center: on the west, inside the plaza z range (z0 >= WALL_Z+8, z1 <= fence-4), centred within 8 studs of the plaza's middle, its door on its east face inside its z range",
		cc ~= nil and cc.Position.X < -70 and cc.Position.Z - cc.Size.Z / 2 >= WALL_Z + 8 and cc.Position.Z + cc.Size.Z / 2 <= (fz or PLAZA_S) - 4 and math.abs(ccz - mid) <= 8
			and door ~= nil and door.Position.X > cc.Position.X + cc.Size.X / 2 - 0.5 and math.abs(door.Position.Z - ccz) <= cc.Size.Z / 2,
		cc and string.format("cc z %s mid %s door z %s", fmt(ccz), fmt(mid), fmt(door and door.Position.Z)) or "missing")
	-- the middle band is filled, not just stretched
	local strip, stripE, lawnSq = anchor("GreenStrip"), anchor("GreenStripE"), anchor("LawnSquare")
	local trunkT = anchor("ShadeTreeTrunk")
	local midLamps = 0
	for _, l in ipairs(allNamed("LampPole")) do
		if l.Position.Z >= WALL_Z + 25 and l.Position.Z <= PLAZA_S - 25 then midLamps += 1 end
	end
	local benchOk = 0
	for _, b in ipairs(allNamed("BenchSeat")) do
		if b.Position.Y < RAISE and b.Position.Z >= WALL_Z + 10 and b.Position.Z <= WALL_Z + 18 then benchOk += 1 end
	end
	local plantersOk, nPl = true, 0
	for _, p in ipairs(allNamed("PlanterWall")) do
		nPl += 1
		if not fz or p.Position.Z < fz - 6 or p.Position.Z > fz - 1 then plantersOk = false end
	end
	check("B3c-1 the plaza middle band is spread over the depth: both palm strips 40+ long, the lawn square 30+ deep, 3+ lamps in the middle band (z WALL_Z+25..PLAZA_S-25), 5 benches in the row at the foot of the seating, the shade tree in the middle third, planter walls along the south fence",
		strip ~= nil and strip.Size.Z >= 40 and stripE ~= nil and stripE.Size.Z >= 40 and lawnSq ~= nil and lawnSq.Size.Z >= 30 and midLamps >= 3 and benchOk >= 5
			and trunkT ~= nil and math.abs(trunkT.Position.Z - mid) <= (PLAZA_S - WALL_Z) / 6 and nPl >= 2 and plantersOk,
		string.format("strip %s stripE %s lawn %s lamps %d benches %d tree z %s planters %d/%s", fmt(strip and strip.Size.Z), fmt(stripE and stripE.Size.Z), fmt(lawnSq and lawnSq.Size.Z), midLamps, benchOk, fmt(trunkT and trunkT.Position.Z), nPl, tostring(plantersOk)))
	-- visitors: two on the lot (on the podium), two on the plaza (on the ground, inside the fence)
	local onLot, onPlaza, badRig = 0, 0, {}
	local people = site:FindFirstChild("PlazaPeople")
	if people then
		for _, rig in ipairs(people:GetChildren()) do
			local hrp = rig:FindFirstChild("HumanoidRootPart")
			if hrp then
				if hrp.Position.Z < WALL_Z then
					onLot += 1
					if hrp.Position.Y < RAISE then table.insert(badRig, rig.Name .. " buried") end
				elseif hrp.Position.Z < (fz or PLAZA_S) - 2 then
					onPlaza += 1
					if hrp.Position.Y > 5 then table.insert(badRig, rig.Name .. " floats") end
				else
					table.insert(badRig, rig.Name .. " outside")
				end
			end
		end
	end
	check("B3c-1 visitors: 2 on the lot (above the podium top) and 2 on the plaza (on the ground, inside the fence)", onLot == 2 and onPlaza == 2 and #badRig == 0, string.format("%d lot, %d plaza, %s", onLot, onPlaza, table.concat(badRig, ", ")))
end
------------------------------------------------------------------ B3c-2: the south lot is filled (cars, bay lines, lamps) and the east garden strip is planted
-- B3c-1 left the lot bare south of z 48. Two more staggered rows of cars (rows z 65 and 87, bays 6 apart), their bay and aisle lines, six lamps down the Walkway and a hedged
-- tree-and-monument strip along the lot's east edge (x 70..110, z 52..104). The strip reuses the GardenTree / Monument recipes under NEW names (EastGarden*, EastMonument*) on purpose: the
-- old assertions pin GardenHedge / GardenTreeCanopy to x 36..100 and MonumentPlinth is an anchor, and they stay as they are.
do
	local function listed(t) return table.concat(t, ", ", 1, math.min(#t, 3)) end
	local function ov(p, x0, x1, z0, z1)
		local a, b = aabb(p)
		return b.X > x0 and a.X < x1 and b.Z > z0 and a.Z < z1
	end
	local ap0, ap1 = Vector3.zero, Vector3.zero
	if apron then ap0, ap1 = aabb(apron) end
	local south, bodies = {}, {}
	if vehicles then
		for _, v in ipairs(vehicles:GetChildren()) do
			local body = v:FindFirstChild("VehicleBody", true)
			if body and body.Position.Y >= RAISE then
				table.insert(bodies, body)
				if body.Position.Z > 55 and body.Position.Z < 105 then table.insert(south, body) end
			end
		end
	end
	-- 1. The cars: 70+ in all, 38+ in two rows in the south lot, every one on the asphalt, clear of the Walkway, the wall (4+ studs) and the entrance lanes, none overlapping another.
	local badCar, rowSet, zs = {}, {}, {}
	for _, b in ipairs(south) do
		local a, c = aabb(b)
		local zr = math.floor(b.Position.Z + 0.5)
		if not rowSet[zr] then rowSet[zr] = true table.insert(zs, zr) end
		if a.X < ap0.X or c.X > ap1.X + 0.05 or a.Z < 48 or c.Z > WALL_Z then table.insert(badCar, b.Parent.Name .. " off the asphalt") end
		if a.X < 8 and c.X > -8 then table.insert(badCar, b.Parent.Name .. " in the Walkway") end
		if c.Z > WALL_Z - 4 then table.insert(badCar, b.Parent.Name .. " within 4 of the wall") end
		if ov(b, -121, 121, 20, 32) then table.insert(badCar, b.Parent.Name .. " on a lane") end
	end
	table.sort(zs)
	local stacked = {}
	for i = 1, #bodies do
		local a1, b1 = aabb(bodies[i])
		for j = i + 1, #bodies do
			local a2, b2 = aabb(bodies[j])
			if b1.X > a2.X and a1.X < b2.X and b1.Z > a2.Z and a1.Z < b2.Z then table.insert(stacked, bodies[i].Parent.Name .. "/" .. bodies[j].Parent.Name) end
		end
	end
	check("B3c-2 cars: 70+ parked cars in all, 38+ of them in two staggered rows in the south lot (z 55..105, aisle 12+ studs between the rows), all on the asphalt, none in the Walkway (x -8..8), 4+ studs from the wall, on an entrance lane or on another car",
		#bodies >= 70 and #south >= 38 and #zs == 2 and (zs[2] - zs[1]) - 10 >= 12 and #badCar == 0 and #stacked == 0,
		string.format("%d cars, %d south, rows %s, %d bad %s, %d stacked %s", #bodies, #south, table.concat(zs, "/"), #badCar, listed(badCar), #stacked, listed(stacked)))
	-- 2. Bay lines: a yellow line on both sides of every south car (3 studs from its centre), and an aisle line either side of the drive aisle (z row1 + 5.2, row2 - 5.2).
	local bayAt, nBay, aisleZ = {}, 0, {}
	for _, l in ipairs(allNamed("ParkingBayLine")) do
		if l.Position.Z > 55 and l.Position.Z < 105 then
			nBay += 1
			bayAt[math.floor(l.Position.X + 0.5) .. ":" .. math.floor(l.Position.Z + 0.5)] = true
		end
	end
	for _, l in ipairs(allNamed("ParkingAisleLine")) do
		if l.Position.Z > 55 and l.Position.Z < 105 and l.Size.X > 30 then aisleZ[math.floor(l.Position.Z * 10 + 0.5)] = true end
	end
	local unlined = {}
	for _, b in ipairs(south) do
		local zk = math.floor(b.Position.Z + 0.5)
		if not (bayAt[math.floor(b.Position.X - 3 + 0.5) .. ":" .. zk] and bayAt[math.floor(b.Position.X + 3 + 0.5) .. ":" .. zk]) then table.insert(unlined, b.Parent.Name) end
	end
	check("B3c-2 bay lines: a ParkingBayLine each side of all south cars (40+ in z 55..105) and aisle lines (ParkingAisleLine) on both edges of the drive aisle (row z + 5.2 and next row z - 5.2)",
		#south >= 38 and nBay >= 40 and #unlined == 0 and #zs == 2 and aisleZ[math.floor((zs[1] + 5.2) * 10 + 0.5)] == true and aisleZ[math.floor((zs[2] - 5.2) * 10 + 0.5)] == true,
		string.format("%d lines, %d cars without both lines %s, aisle z %s", nBay, #unlined, listed(unlined), (function() local t = {} for k in pairs(aisleZ) do table.insert(t, k / 10) end table.sort(t) return table.concat(t, "/") end)()))
	-- 3. The east garden strip: a lawn slab over the asphalt, a long row of 6+ trees (trunk + 2 canopies), a monument.
	local lawnG, eastAsphalt = anchor("EastGardenLawn"), anchor("ApronPavingEast")
	local g0, g1 = Vector3.zero, Vector3.zero
	if lawnG then g0, g1 = aabb(lawnG) end
	local trunksG, canopiesG = allNamed("EastGardenTreeTrunk"), allNamed("EastGardenTreeCanopy")
	local treeBad, tzLo, tzHi = {}, math.huge, -math.huge
	for _, t in ipairs(trunksG) do
		tzLo, tzHi = math.min(tzLo, t.Position.Z), math.max(tzHi, t.Position.Z)
		if t.Position.X < g0.X or t.Position.X > g1.X or t.Position.Z < g0.Z or t.Position.Z > g1.Z or t.Position.Y < RAISE then table.insert(treeBad, "trunk " .. fmt(t.Position.X) .. "," .. fmt(t.Position.Z)) end
	end
	for _, c in ipairs(canopiesG) do
		if c.Position.X < g0.X or c.Position.X > g1.X or c.Position.Z < g0.Z or c.Position.Z > g1.Z or c.Position.Y - c.Size.Y / 2 < RAISE + 3 then table.insert(treeBad, "canopy " .. fmt(c.Position.X) .. "," .. fmt(c.Position.Z)) end
	end
	local monG = { anchor("EastMonumentPlinth"), anchor("EastMonument"), anchor("EastMonumentCap"), anchor("EastMonumentStatue"), anchor("EastMonumentHead") }
	local monOk = true
	for i = 1, 5 do
		local m = monG[i]
		if not m or m.Position.X < g0.X or m.Position.X > g1.X or m.Position.Z < g0.Z or m.Position.Z > g1.Z then monOk = false end
	end
	check("B3c-2 east garden strip: EastGardenLawn on the podium inside x 68..112, z 50..108 (36+ wide, 45+ deep, green, above the old asphalt), 6+ trees in a row (EastGardenTreeTrunk with 2 EastGardenTreeCanopy each, spanning 30+ studs of z), and a monument (EastMonumentPlinth, EastMonument, EastMonumentCap, EastMonumentStatue, EastMonumentHead) on the lawn",
		lawnG ~= nil and eastAsphalt ~= nil and lawnG.Position.Y >= RAISE and g0.X >= 68 and g1.X <= 112 and g0.Z >= 50 and g1.Z <= 108 and g1.X - g0.X >= 36 and g1.Z - g0.Z >= 45
			and lawnG.Color.G > lawnG.Color.R and topY(lawnG) > topY(eastAsphalt) and #trunksG >= 6 and #canopiesG == 2 * #trunksG and tzHi - tzLo >= 30 and #treeBad == 0 and monOk,
		string.format("lawn %s, %d trunks, %d canopies, span %s, bad %s, monument %s", lawnG and "ok" or "missing", #trunksG, #canopiesG, fmt(tzHi - tzLo), listed(treeBad), tostring(monOk)))
	-- 4. The hedge round the strip and its walk-in gap at the south end (a clear box 6 wide in the south hedge, a path through it); everything stays at |x| <= 128 and clear of the stair edge (x 118..120.2).
	local hedgesG, hN, hW, hE, hS = allNamed("EastGardenHedge"), 0, 0, 0, {}
	for _, h in ipairs(hedgesG) do
		local a, c = aabb(h)
		if h.Size.X >= 30 and math.abs(h.Position.Z - g0.Z) < 1.5 then hN += 1 end
		if h.Size.Z >= 45 and math.abs(h.Position.X - g0.X) < 1.5 then hW += 1 end
		if h.Size.Z >= 45 and math.abs(h.Position.X - g1.X) < 1.5 then hE += 1 end
		if h.Size.X < 30 and math.abs(h.Position.Z - g1.Z) < 1.5 and h.Size.Z <= 2.5 then table.insert(hS, { a.X, c.X }) end
	end
	table.sort(hS, function(p, q) return p[1] < q[1] end)
	local gapW = (#hS == 2) and (hS[2][1] - hS[1][2]) or 0
	local gapX = (#hS == 2) and (hS[1][2] + hS[2][1]) / 2 or 0
	local gapBlock = {}
	local pathG, farX = anchor("EastGardenPath"), 0
	local gz = 0
	for _, h in ipairs(hedgesG) do if h.Size.X < 30 and h.Size.Z <= 2.5 and math.abs(h.Position.Z - g1.Z) < 1.5 then gz = h.Position.Z end end
	if #hS == 2 then gapBlock = blockers(CFrame.new(gapX, RAISE + 1.4, gz), Vector3.new(6, 1.6, 3)) end
	local eg = site:FindFirstChild("EastGarden")
	if eg then
		for _, d in ipairs(eg:GetDescendants()) do
			if d:IsA("BasePart") then
				local a, c = aabb(d)
				farX = math.max(farX, math.abs(a.X), math.abs(c.X))
			end
		end
	end
	check("B3c-2 east garden hedge: EastGardenHedge runs along the north, west and east edges and the south edge in two pieces with a clear walk-in gap 6+ wide (nothing above 0.5 in the gap box) crossed by an EastGardenPath; every EastGarden part at |x| <= 112 (the stair edge strip is untouched)",
		lawnG ~= nil and hN >= 1 and hW >= 1 and hE >= 1 and #hS == 2 and gapW >= 6 and #gapBlock == 0 and pathG ~= nil and math.abs(pathG.Position.X - gapX) <= 3 and pathG.Position.Z + pathG.Size.Z / 2 >= gz
			and eg ~= nil and farX > 0 and farX <= 112,
		string.format("hedges N %d W %d E %d, south pieces %d, gap %s at x %s, blockers %s, path %s, max |x| %s", hN, hW, hE, #hS, fmt(gapW), fmt(gapX), listed(gapBlock), pathG and "ok" or "missing", fmt(farX)))
	-- 5. Lamps down the Walkway south of z 48 (the lot's lamp rows stop at z 44): 6+ LampPole at |x| 8..14, z 50..110, both sides.
	local lampW, lampE, lampBad = 0, 0, 0
	for _, l in ipairs(allNamed("LampPole")) do
		if l.Position.Z > 50 and l.Position.Z < WALL_Z - 2 then
			if math.abs(l.Position.X) >= 8 and math.abs(l.Position.X) <= 14 and l.Position.Y > RAISE then
				if l.Position.X < 0 then lampW += 1 else lampE += 1 end
			else
				lampBad += 1
			end
		end
	end
	check("B3c-2 lamps: 3+ LampPole each side of the Walkway south of z 48 (|x| 8..14, on the podium), none elsewhere in the south lot", lampW >= 3 and lampE >= 3 and lampBad == 0, string.format("%d west, %d east, %d elsewhere", lampW, lampE, lampBad))
	-- 6. The part budget: the exact count (2222 + 164 car parts + 52 lot markings + 36 garden + 24 lamps = 2498), the cap of 2500 and the batch ceiling of every new group.
	local totalParts, vehicleParts, lotParts, gardenParts = 0, 0, 0, 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then
			totalParts += 1
			if vehicles and d:IsDescendantOf(vehicles) then vehicleParts += 1 end
		end
	end
	for _, nm in ipairs({ "LotMarkings", "EastGarden" }) do
		local c = site:FindFirstChild(nm)
		local n = 0
		if c then for _, d in ipairs(c:GetDescendants()) do if d:IsA("BasePart") then n += 1 end end end
		if nm == "LotMarkings" then lotParts = n else gardenParts = n end
	end
	check("B3c-2 part budget: Site01 holds exactly 2498 parts (cap 2500), ParkedVehicles 388 (under the 400 batch ceiling), LotMarkings 52 and EastGarden 36 as their own components",
		totalParts == 2498 and totalParts <= 2500 and vehicleParts == 388 and lotParts == 52 and gardenParts == 36 and site:FindFirstChild("LotMarkings") ~= nil and site:FindFirstChild("EastGarden") ~= nil,
		string.format("total %d, vehicles %d, LotMarkings %d, EastGarden %d", totalParts, vehicleParts, lotParts, gardenParts))
end

-- Credits job B (2026-10-27): the CreditsBoard moved out of the Cathedral plaza to the Credits Plaza (x 24..150, z 274..346). The old keep-out assertions
-- (the board at z 203.8..206.2 needs 4+ studs round it) pass trivially now and are left as they are; this one states the new rule: no board part lies within
-- 4 studs of the Site01 model bounds (x -128..128, z -101..217).
do
	local board = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CreditsBoard")
	local near = {}
	if board then
		for _, d in ipairs(board:GetDescendants()) do
			if d:IsA("BasePart") then
				local x0, x1, z0, z1 = math.huge, -math.huge, math.huge, -math.huge
				for _, a in ipairs({ -0.5, 0.5 }) do
					for _, b in ipairs({ -0.5, 0.5 }) do
						local c = d.CFrame:PointToWorldSpace(Vector3.new(a * d.Size.X, 0, b * d.Size.Z))
						x0, x1, z0, z1 = math.min(x0, c.X), math.max(x1, c.X), math.min(z0, c.Z), math.max(z1, c.Z)
					end
				end
				if x0 < 128 + 4 and x1 > -128 - 4 and z0 < 217 + 4 and z1 > -101 - 4 then table.insert(near, string.format("%s z %.1f..%.1f", d.Name, z0, z1)) end
			end
		end
	end
	check("Credits Plaza: no CreditsBoard part lies within 4 studs of the Site01 bounds (x -128..128, z -101..217)", board ~= nil and #near == 0,
		board and table.concat(near, ", ", 1, math.min(#near, 4)) or "CreditsBoard missing")
end

return HttpService:JSONEncode(results)
