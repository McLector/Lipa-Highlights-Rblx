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
-- Round 4 (replaces the 3 fountain assertions): the plaza drawing has no fountain; the wall axis is one wide flight of steps.
local basin = anchor("FountainBasin")
check("round 4: no fountain on the wall axis (no FountainBasin, FountainStatue, FountainColumn or FountainWater)", basin == nil and anchor("FountainStatue") == nil
	and countNamed("FountainColumn") == 0 and countNamed("FountainWater") == 0, countNamed("FountainWater") .. " water parts")
local stairC = allNamed("StairFlightC")
table.sort(stairC, function(a, b) return a.Position.Z < b.Position.Z end)
check("round 4: StairFlightC fills the wall axis: 4 treads, tops 4, 3, 2, 1, 16 wide (x -8..8)", #stairC == 4 and (function()
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
local stage = site:FindFirstChild("EventStage") -- the folder name is fixed by SiteData; it holds the wall steps, brick facing and side stairs
check("round 4 (replaces 'EventStage folder holds the fountain, both flights and the seating'): EventStage holds the three flights and the seating, no gazebo stage",
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
check("ShadeTree: a trunk at x 31..60, z 60..70 (clear of the open centre and the court) with 4+ canopy balls whose bottoms are above y 11.5",
	trunk ~= nil and trunk.Position.X >= 31 and trunk.Position.X <= 60 and trunk.Position.Z >= 60 and trunk.Position.Z <= 70 and countNamed("ShadeTreeCanopy") >= 4 and (function()
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
check("long arcaded building on the lower plaza's west side (LongBuildingW)", anchor("LongBuildingW") ~= nil and anchor("LongBuildingW").Position.X < -80
	and anchor("LongBuildingW").Position.Z > WALL_Z)
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
	check("the CreditsBoard keeps 4+ studs clear on every side (nothing taller than 0.5 inside x +-61.5, z 88.8..99.2)", board ~= nil and #bad == 0,
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
	check("CATEDRAL labels (wing entrance, welcome arch): 3+ found, fixed TextSize, fit the face and fill 60%+ of it", seen >= 3 and #problems == 0,
		seen .. " labels; " .. table.concat(problems, "; "))
end

-- Lipa Cultural Center: 2-storey cream flat-topped block with arched windows on the plaza's far (+X) edge, beside the road-side open gap.
local cc = anchor("CulturalCenterBody")
-- Step B round 2 (replaces "Lipa Cultural Center: a cream block 14+ studs wide and 20-30 tall at x 78..99, z 64..84, ..."): the old box was too small to read at blueprint-view scale.
-- Step B round 4 (replaces "a cream block 26+ wide, 14+ deep ... at x 68..99, z 64..84"): the drawing's Cultural Center is a long block down the EAST edge of the plaza.
check("round 4 Lipa Cultural Center: a cream block 18+ wide and 28+ long (N-S, along the east edge), 22-30 tall, x 70..99, z 64..95, on the lower plaza, flat top",
	cc ~= nil and cc.Size.X >= 18 and cc.Size.Z >= 28 and cc.Size.Y >= 22 and cc.Size.Y <= 30 and cc.Position.X - cc.Size.X / 2 >= 70 and cc.Position.X + cc.Size.X / 2 <= 99
		and cc.Position.Z - cc.Size.Z / 2 >= 64 and cc.Position.Z + cc.Size.Z / 2 <= 95 and cc.Position.Y - cc.Size.Y / 2 < 0.6
		and cc.Color.R * 255 >= 215 and cc.Color.B * 255 >= 130 and (cc.Color.R - cc.Color.B) * 255 <= 90,
	cc and string.format("x %s z %s w %s d %s h %s", fmt(cc.Position.X), fmt(cc.Position.Z), fmt(cc.Size.X), fmt(cc.Size.Z), fmt(cc.Size.Y)) or "missing")
check("Cultural Center has a flat parapet cap, a cornice and 10+ arched windows (CCWin_Pane)", anchor("CulturalCenterParapet") ~= nil and anchor("CulturalCenterCornice") ~= nil
	and countNamed("CCWin_Pane") >= 10, tostring(countNamed("CCWin_Pane")) .. " windows")
check("Cultural Center leaves the road gap open: nothing of it at z < 64 (Road C reaches the plaza between the seating and the building)",
	cc ~= nil and cc.Position.Z - cc.Size.Z / 2 >= 64)

-- Open-air stage pavilion with a dark peaked roof, plaza south-east, apart from the vaulted CoveredCourt (which stays).
local roofL, roofR, dais = anchor("StageRoofL"), anchor("StageRoofR"), anchor("StageDais")
local function tilt(p) local rx = p.CFrame:ToEulerAnglesXYZ() return math.deg(rx) end
check("round 4 StagePavilion (replaces 'at x 80..99, z 82..99'): two dark roof slopes, tilted 15+ degrees in opposite senses, over a raised dais at the SOUTH-WEST (x -99..-72, z 80..96)",
	roofL ~= nil and roofR ~= nil and dais ~= nil and tilt(roofL) * tilt(roofR) < 0 and math.abs(tilt(roofL)) >= 15 and math.abs(tilt(roofR)) >= 15
		and roofL.Color.R * 255 <= 90 and roofL.Color.G * 255 <= 90 and roofL.Color.B * 255 <= 90 and roofR.Color.R * 255 <= 90
		and dais.Position.X >= -99 and dais.Position.X <= -72 and dais.Position.Z >= 80 and dais.Position.Z <= 96 and dais.Size.Y >= 1 and dais.Size.Y <= 2.5
		and roofL.Position.Y >= 12,
	roofL and roofR and dais and string.format("tilt %s / %s, dais (%s, %s)", fmt(tilt(roofL)), fmt(tilt(roofR)), fmt(dais.Position.X), fmt(dais.Position.Z)) or "missing")
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
	for _, t in ipairs(tiersM) do
		widest = math.max(widest, t.Size.Y)
		xlo, xhi, zhi = math.min(xlo, t.Position.X - t.Size.Y / 2), math.max(xhi, t.Position.X + t.Size.Y / 2), math.max(zhi, t.Position.Z + t.Size.Z / 2)
		if t.Position.X >= 0 or t.Position.Y >= RAISE then table.insert(mBad, "tier") end
	end
	for _, f in ipairs(flats) do
		zlo = math.min(zlo, f.Position.Z - f.Size.Z / 2)
		if f.Position.X >= 0 or f.Position.Y >= RAISE then table.insert(mBad, "flat") end
	end
	local ribTop, ribMax = 0, 0
	for _, r in ipairs(ribbons) do
		ribTop, ribMax = math.max(ribTop, topY(r)), math.max(ribMax, math.max(r.Size.Y, r.Size.Z))
		if r.Position.X >= 0 or r.Position.Z > 75 then table.insert(mBad, "ribbon") end
	end
	check("round 4 mound: on the lower plaza at the west-middle (x -100..-76), straight edge on the wall (flat blocks from z 48..50), 22+ wide, 18+ deep, 3 tiers",
		#tiersM >= 3 and #flats >= 3 and #mBad == 0 and xlo >= -100.5 and xhi <= -76 and zlo >= 48 and zlo <= 50 and widest >= 22 and zhi - zlo >= 18 and countNamed("MoundTier", Enum.PartType.Cylinder) >= 3,
		string.format("x %s..%s z %s..%s wide %s bad %d", fmt(xlo), fmt(xhi), fmt(zlo), fmt(zhi), fmt(widest), #mBad))
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
	-- 1. The long parish and archdiocese wing down the WEST edge (3 storeys beside the church, 2 along the lot and the plaza).
	local bodies, crosses, lowerW = allNamed("ParishWingBody"), allNamed("ParishWingCrossBody"), anchor("LongBuildingW")
	local xlo, xhi, zlo, zhi, tall, two, gapHit = math.huge, -math.huge, math.huge, -math.huge, 0, 0, {}
	for _, b in ipairs(bodies) do
		local a, c = aabb(b)
		xlo, xhi, zlo, zhi = math.min(xlo, a.X), math.max(xhi, c.X), math.min(zlo, a.Z), math.max(zhi, c.Z)
		if b.Size.Y >= 32 and b.Position.Z < -10 then tall += 1 end
		if b.Size.Y >= 21 and b.Size.Y <= 24 then two += 1 end
		if a.Z < 32 and c.Z > 20 then table.insert(gapHit, "z " .. fmt(a.Z) .. ".." .. fmt(c.Z)) end
	end
	local lw0, lw1 = 0, 0
	if lowerW then
		local a, c = aabb(lowerW)
		zhi = math.max(zhi, c.Z)
		lw0, lw1 = a.X, c.X
	end
	check("round 4 wing: ParishWingBody ranges on the west edge (x -121..-103), 3 storeys (32+ tall) beside the church, 2 storeys (21..24) along the lot; with LongBuildingW the wing runs 150+ studs",
		#bodies >= 3 and xlo >= -121 and xhi <= -103 and tall >= 1 and two >= 2 and zhi - zlo >= 150,
		string.format("%d ranges x %s..%s z %s..%s tall %d two %d", #bodies, fmt(xlo), fmt(xhi), fmt(zlo), fmt(zhi), tall, two))
	check("round 4 wing: the side stairs stay open (no wing range between z 20 and 32)", #gapHit == 0, table.concat(gapHit, "; "))
	local cx0, cx1, cBad = math.huge, -math.huge, 0
	for _, b in ipairs(crosses) do
		local a, c = aabb(b)
		cx0, cx1 = math.min(cx0, a.X), math.max(cx1, c.X)
		if b.Size.Y < 32 then cBad += 1 end
	end
	check("round 4 wing: 2+ cross ranges (ParishWingCrossBody, 3 storeys) run from the west range to within 6 studs of the tower (x -121..-52)", #crosses >= 2 and cBad == 0 and cx0 >= -121 and cx1 >= -56 and cx1 <= -50,
		string.format("%d cross ranges x %s..%s, %d low", #crosses, fmt(cx0), fmt(cx1), cBad))
	check("round 4 wing: LongBuildingW is the 2-storey end of the wing on the lower plaza's west edge (x -121..-103, 22+ tall, 44+ long)", lowerW ~= nil and lowerW.Size.Y >= 22 and lowerW.Size.Z >= 44
		and lw0 >= -121 and lw1 <= -103, lowerW and string.format("x %s..%s h %s len %s", fmt(lw0), fmt(lw1), fmt(lowerW.Size.Y), fmt(lowerW.Size.Z)) or "missing")
	local roofsW, redBad = allNamed("ParishWingRoof"), 0
	for _, r in ipairs(allNamed("LongRoof")) do table.insert(roofsW, r) end
	for _, r in ipairs(roofsW) do
		if r.Color.R * 255 < 150 or r.Color.G * 255 > 70 or r.Color.B * 255 > 70 then redBad += 1 end
	end
	check("round 4 wing: red tile roofs (12+ roof slopes incl. LongRoof, every one R >= 150, G and B <= 70)", #roofsW >= 12 and redBad == 0, #roofsW .. " slopes, " .. redBad .. " not red")
	local doors, doorLow = allNamed("ParishDoor_Pane"), 0
	local doorTops = allNamed("ParishDoor_Top")
	for _, d in ipairs(doors) do -- the opening is the pane plus the half-round top above it (9.5 tall in the builder)
		local best = 0
		for _, t in ipairs(doorTops) do
			if (Vector2.new(t.Position.X, t.Position.Z) - Vector2.new(d.Position.X, d.Position.Z)).Magnitude < 0.6 then best = math.max(best, topY(t) - (d.Position.Y - d.Size.Y / 2)) end
		end
		if best < 8 then doorLow += 1 end
	end
	check("round 4 wing: 60+ arched windows (ParishWin_Pane) and 2+ human-scale arched doors (ParishDoor_Pane, 8+ tall)", countNamed("ParishWin_Pane") >= 60 and #doors >= 2 and doorLow == 0,
		countNamed("ParishWin_Pane") .. " windows, " .. #doors .. " doors, " .. doorLow .. " low")
	-- 2. The lot: full width between the wing and the garden wall, 36+ cars.
	local a0, a1 = Vector3.zero, Vector3.zero
	if apron then a0, a1 = aabb(apron) end
	check("round 4 lot: the asphalt spans from the wing (x <= -103) to the garden wall (x >= 62)", apron ~= nil and a0.X <= -103 and a1.X >= 62, string.format("x %s..%s", fmt(a0.X), fmt(a1.X)))
	check("round 4 lot: 36+ parked cars, yellow bay lines still 40+", carCount >= 36 and #allNamed("ParkingBayLine") >= 40, carCount .. " cars, " .. #allNamed("ParkingBayLine") .. " lines")
	local nw = anchor("ApronPavingNW")
	local lawnW = 0
	for _, l in ipairs(allNamed("PodiumLawn")) do if l.Position.X < -48 then lawnW += 1 end end
	local palmW = 0
	for _, t in ipairs(allNamed("PalmTrunk1")) do if t.Position.X < -48 and t.Position.Y >= RAISE and t.Position.Z < 10 then palmW += 1 end end
	check("round 4 lot: the bare lawn and palms west of the tower are gone (no PodiumLawn or upper PalmTrunk1 at x < -48); asphalt (ApronPavingNW) takes their place",
		lawnW == 0 and palmW == 0 and nw ~= nil and nw.Position.X < -70 and nw.Material == Enum.Material.Asphalt, lawnW .. " lawns, " .. palmW .. " palms")
	-- 3. The plaza: stage SW, Cultural Center E, so they stand on opposite sides.
	check("round 4 plaza: the stage pavilion is on the west (dais x < -70) and the Cultural Center on the east (centre x > 40, east face x >= 96)",
		dais ~= nil and cc ~= nil and dais.Position.X < -70 and cc.Position.X > 40 and cc.Position.X + cc.Size.X / 2 >= 96,
		dais and cc and string.format("dais %s, cc %s..%s", fmt(dais.Position.X), fmt(cc.Position.X - cc.Size.X / 2), fmt(cc.Position.X + cc.Size.X / 2)) or "missing")
end
return HttpService:JSONEncode(results)
