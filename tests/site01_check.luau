-- site01_check: the Slice 14 fidelity spec for Site 01 (Cathedral + Plaza Independencia), written BEFORE the rework.
-- Studio copy: ServerStorage.Checks.site01_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site01_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number below comes from briefs/site01.md "Slice 14 rework" (OSM footprints + the 2023-2025 photos), converted at
-- massScale 2.0 (2 studs per metre). Anchors are ONE uniquely named BasePart each, searched through the whole site.
local HttpService = game:GetService("HttpService")

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
local function countNamed(name, className)
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") and (className == nil or d.Shape == className) then n += 1 end
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
	local ratio = (towerCross.Position.Y + towerCross.Size.Y / 2) / (belfryCross.Position.Y + belfryCross.Size.Y / 2)
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
check("LED Screen is on the left tower, 8+ studs wide, centre y 20-32 (above the base cornice), facing +Z",
	screen ~= nil and tower ~= nil and math.abs(screen.Position.X - tower.Position.X) < 8 and screen.Size.X >= 8
		and screen.Position.Y >= 20 and screen.Position.Y <= 32 and screen.Position.Z > tower.Position.Z,
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

------------------------------------------------------------------ Welcome Arch (P6)
local arch = site:FindFirstChild("WelcomeArch")
check("WelcomeArch is a direct child model with 12+ parts", arch ~= nil and arch:IsA("Model") and #arch:GetDescendants() >= 12)
if arch then
	local top, span = -math.huge, 0
	local l, r = math.huge, -math.huge
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

------------------------------------------------------------------ Plaza (P1/P2)
check("ForecourtPaving exists", anchor("ForecourtPaving") ~= nil)
check("St Sebastian Monument on a plinth", anchor("MonumentPlinth") ~= nil and site:FindFirstChild("Monument", true) ~= nil)
check("16+ yellow parking-bay lines", countNamed("ParkingBayLine") >= 16, tostring(countNamed("ParkingBayLine")))
local vehicles = site:FindFirstChild("ParkedVehicles")
check("ParkedVehicles folder has 8+ vehicles", vehicles ~= nil and #vehicles:GetChildren() >= 8, vehicles and tostring(#vehicles:GetChildren()) or "missing")
if vehicles then
	local worst = math.huge
	for _, v in ipairs(vehicles:GetChildren()) do
		local body = v:FindFirstChild("VehicleBody", true)
		if not body then worst = 0 else worst = math.min(worst, math.max(body.Size.X, body.Size.Z)) end
	end
	check("every vehicle body is >= 8 studs long (human-scale parts are never shrunk)", worst >= 8, fmt(worst))
end
local stage = site:FindFirstChild("EventStage")
check("EventStage is the amphitheatre: dais + 6 steps each side", stage ~= nil and anchor("AmphiDais") ~= nil
	and countNamed("AmphiStepL") == 6 and countNamed("AmphiStepR") == 6, "L " .. countNamed("AmphiStepL") .. " R " .. countNamed("AmphiStepR"))
local hedges, eastHedges = 0, 0
for _, d in ipairs(site:GetDescendants()) do
	if d:IsA("BasePart") and d.Name == "GardenHedge" then
		hedges += 1
		if d.Position.X > 36 then eastHedges += 1 end
	end
end
check("hedged garden on the east flank (12+ GardenHedge parts, all east of x 36)", hedges >= 12 and hedges == eastHedges, hedges .. " / " .. eastHedges)
check("12+ palm trunks", countNamed("PalmTrunk1") >= 12, tostring(countNamed("PalmTrunk1")))
check("long arcaded building on the plaza's west side (LongBuildingW)", anchor("LongBuildingW") ~= nil and anchor("LongBuildingW").Position.X < -80)
check("gabled civic building at the south end (CivicBuildingS)", anchor("CivicBuildingS") ~= nil and anchor("CivicBuildingS").Position.Z > 85)
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
local stray = {}
for _, p in ipairs(site:GetDescendants()) do
	if p:IsA("BasePart") and not isRig(p) and p.Size.Y <= 0.5 and p.Position.Y <= 0.6 and p.Parent.Name ~= "JeepStop" then
		local x0, x1 = p.Position.X - p.Size.X / 2, p.Position.X + p.Size.X / 2
		local z0, z1 = p.Position.Z - p.Size.Z / 2, p.Position.Z + p.Size.Z / 2
		if p.Size.X > 3 and p.Size.Z > 3 and (x0 < -100.7 or x1 > 100.7 or z0 < -0.1 or z1 > 100.7) then
			table.insert(stray, string.format("%s x[%.0f,%.0f] z[%.0f,%.0f]", p.Name, x0, x1, z0, z1))
		end
	end
end
check("flat ground parts stay inside the repainted Pavement (x +-100, z 0..100)", #stray == 0, table.concat(stray, "; ", 1, math.min(#stray, 3)))
for _, name in ipairs({ "Guide", "InfoPanel", "JeepStop" }) do
	check(name .. " survived the rework", site:FindFirstChild(name) ~= nil)
end

return HttpService:JSONEncode(results)
