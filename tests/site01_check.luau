-- site01_check: the Slice 14 fidelity spec for Site 01 (Cathedral + Plaza Independencia), written BEFORE each rework pass.
-- Studio copy: ServerStorage.Checks.site01_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site01_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number below comes from briefs/site01.md "Slice 14 rework" (OSM footprints + the 2023-2025 photos), converted at
-- massScale 2.0 (2 studs per metre). Anchors are ONE uniquely named BasePart each, searched through the whole site.
-- Two levels (Dec 2025 drone photos): the church, its wing, the car-park forecourt and the hedged garden stand on a podium
-- RAISE studs above the ground; a retaining wall with two flights of steps and a central landing drops to the lower Plaza
-- Independencia at ground level (y 0), where the spawn, the pavilion, the vans and the CreditsBoard are.
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
local landing = anchor("StageLanding")
check("StageLanding is a wide stage (50+ studs, 10+ deep) on the wall axis at podium height", landing ~= nil and math.abs(landing.Position.X) < 2 and math.abs(topY(landing) - RAISE) < 0.06
	and landing.Size.X >= 50 and landing.Size.Z >= 10 and landing.Position.Z - landing.Size.Z / 2 >= WALL_Z - 0.6,
	landing and string.format("top %s w %s d %s", fmt(topY(landing)), fmt(landing.Size.X), fmt(landing.Size.Z)) or "missing")
-- The terraced seating beside the stage (P1 crop: long wooden tiers either side of the stage, reading as seats): 4 tiers each,
-- 3+ studs deep so a person can sit or stand on them, risers of exactly 1 stud. The east side is the longer one in the photo.
for _, spec in ipairs({ { "BleacherL", 40 }, { "BleacherR", 60 } }) do
	local steps = allNamed(spec[1])
	table.sort(steps, function(a, b) return a.Position.Z < b.Position.Z end)
	local okRisers, detail = #steps == 4, "tiers " .. #steps
	for i, s in ipairs(steps) do
		if math.abs(topY(s) - (RAISE - i)) > 0.06 or s.Size.X < spec[2] or s.Size.Z < 2.9 then
			okRisers = false
			detail = detail .. string.format(" [%d top %s w %s d %s]", i, fmt(topY(s)), fmt(s.Size.X), fmt(s.Size.Z))
		end
	end
	check(spec[1] .. ": 4 seating tiers, " .. spec[2] .. "+ studs long and 3+ deep, each riser exactly 1 stud (5 -> 4 -> 3 -> 2 -> 1 -> ground)", okRisers, detail)
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
local stage = site:FindFirstChild("EventStage")
check("EventStage is the landing gazebo: landing, 4 posts and a canopy above the podium", stage ~= nil and landing ~= nil and countNamed("StagePost") == 4
	and anchor("StageCanopy") ~= nil and anchor("StageCanopy").Position.Y > RAISE + 9)
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
	check("6+ vehicles on the upper forecourt and 4+ vans on the lower plaza", upper >= 6 and lower >= 4, upper .. " upper, " .. lower .. " lower")
end

------------------------------------------------------------------ Lower plaza (P1: paved plaza below the wall, the gabled pavilion, palms, fence)
local paving = anchor("ForecourtPaving")
check("lower plaza paving (ForecourtPaving) is at ground level and spans z 48..100", paving ~= nil and paving.Position.Y <= 0.6
	and math.abs(paving.Position.Z - paving.Size.Z / 2 - WALL_Z) < 1 and paving.Position.Z + paving.Size.Z / 2 >= 99,
	paving and string.format("y %s z %s..%s", fmt(paving.Position.Y), fmt(paving.Position.Z - paving.Size.Z / 2), fmt(paving.Position.Z + paving.Size.Z / 2)) or "missing")
local pavilion = anchor("CivicBuildingS")
check("gabled pavilion (CivicBuildingS) stands on the lower plaza: z >= 70, 36+ studs wide, ground level",
	pavilion ~= nil and pavilion.Position.Z >= 70 and pavilion.Size.X >= 36 and pavilion.Position.Y - pavilion.Size.Y / 2 < 0.6,
	pavilion and string.format("z %s w %s", fmt(pavilion.Position.Z), fmt(pavilion.Size.X)) or "missing")
check("long arcaded building on the lower plaza's west side (LongBuildingW)", anchor("LongBuildingW") ~= nil and anchor("LongBuildingW").Position.X < -80
	and anchor("LongBuildingW").Position.Z > WALL_Z)
check("12+ palm trunks", countNamed("PalmTrunk1") >= 12, tostring(countNamed("PalmTrunk1")))
check("3+ plaza tents on the lower plaza", countNamed("PlazaTent") >= 3, tostring(countNamed("PlazaTent")))
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

return HttpService:JSONEncode(results)
