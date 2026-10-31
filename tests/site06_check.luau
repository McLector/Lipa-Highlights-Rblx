-- site06_check: the spec for Site 06 (The Outlets at LIMA Estate + Aboitiz Pitch). Rewritten BEFORE the board rebuild (Standard tier,
-- 2026-10-31: "The Outlets at Lima Estate Blueprint.png", briefs/site06.md Revision 2). Earlier: the Slice 16 fidelity spec (Revision 1).
-- Studio copy: ServerStorage.Checks.site06_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site06_check:Clone())      -- returns JSON {passed, failed, failures}
-- Groups (set shared.site06_only = "general" | "retail" | "promenade" | "parking" | "pitch" | "entrance" | "clear" | "props" first to run
-- one; run_all leaves it nil and runs all; SET IT BACK TO nil after a filtered run).
-- Frame: the site pivot is yawed SW, but the builder works in world-aligned local axes (origin = the pivot position (550, 0, -700)), so
-- lp(p) is the world position minus the site position (+X east, +Z south). The slot is x -225..225, z -150..150 (world x 325..775,
-- z -850..-550); the south edge z 150 is flush with Road B's end (430, -550). The estate is built at one uniform 1.05 studs per metre.
-- Kept objects (Guide, InfoPanel, JeepStop, JeepSign*, Jeepney, LocalNPCs) keep their WORLD positions: those pins are world literals.
-- Pins the board contradicts were REPLACED in place (each keeps its old text in a "REPLACED (board)" comment) and are listed in
-- briefs/site06.md Revision 2.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(550, 0, -700)
local R = math.sqrt(0.5)
local SW = Vector3.new(-R, 0, R)
local ONLY = shared.site06_only

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

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site06_Outlets")
check("Site06_Outlets exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end

local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
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
local function lp(p) return p.Position - SITE_POS end
local function topY(p) return p.Position.Y + p.Size.Y / 2 end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function near(a, b, tol) return a ~= nil and math.abs(a - b) <= tol end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
local function count(list, pred)
	local n = 0
	for _, p in ipairs(list) do if pred(p) then n += 1 end end
	return n
end
local function guiText(p)
	local t = {}
	for _, g in ipairs(p:GetChildren()) do
		if g:IsA("SurfaceGui") then
			for _, l in ipairs(g:GetDescendants()) do
				if l:IsA("TextLabel") then table.insert(t, l.Text) end
			end
		end
	end
	return table.concat(t, " ")
end
-- world-axis extent of a part in site-local coordinates (rotated corners included): min, max on axis "X" | "Y" | "Z"
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
local function partsIn(inst)
	local n = inst:IsA("BasePart") and 1 or 0
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("BasePart") then n += 1 end
	end
	return n
end
-- colour families (the board, by eye)
local function white(p) local r, g, b = rgb(p); return r >= 225 and g >= 220 and b >= 205 end
local function orange(p) local r, g, b = rgb(p); return r >= 180 and g >= 70 and g <= 130 and b <= 100 end
local function solarBlue(p) local r, g, b = rgb(p); return r <= 60 and b >= 70 and b > r + 30 end
local function brown(p) local r, g, b = rgb(p); return r >= 60 and r <= 130 and g >= 30 and g <= 80 and b <= 70 and r > b + 20 end
local function maroon(p) local r, g, b = rgb(p); return r >= 90 and r <= 140 and g >= 30 and g <= 70 and b >= 25 and b <= 60 end
local function darkGlass(p) local r, g, b = rgb(p); return r <= 90 and g <= 100 and b <= 110 and p.Material == Enum.Material.Glass end
local function greenish(p) local r, g, b = rgb(p); return g > r and g > b end
local function lightGrey(p) local r, g, b = rgb(p); return r >= 80 and r <= 225 and math.abs(r - b) <= 16 and math.abs(r - g) <= 12 end
-- Ground layers: the decks (world y 0..1.3; the rendered terrain hides any lower slab, briefs/site06.md Revision 2) and the thin inlays,
-- markings and lawns on them. They are walked on, so the clear-group boxes skip them by name.
local DECKS = { ClusterPaving = true, GardenLawn = true, ParkingNE = true, ParkingW = true, ParkingS = true, PitchTurf = true, PitchApronW = true,
	StandApron = true, SouthRoad = true, WestRoad = true, EastRoad = true, NorthRoad = true }
local GROUND_LAYER = { PromenadeSpine = true, PromenadeInlay = true, OvalPaving = true, OvalLawn = true, OvalRing = true, OvalLawnInner = true,
	OvalPath = true, EntryWalk = true, WalkwayPaving = true, PitchWalk = true, EntryRoad = true, ZebraBar = true, BayLine = true, ParkingIsland = true,
	TurfStripe = true, TouchLine = true, GoalLine = true, HalfwayLine = true, CentreCircle = true, CentreCircleFill = true, CentreSpot = true,
	PenaltyLine = true, PenaltySpot = true, GardenPath = true, GardenCircle = true, MonumentBed = true }
for n in pairs(DECKS) do GROUND_LAYER[n] = true end

local RETAIL = {}
for _, p in ipairs(allNamed("RetailBody")) do table.insert(RETAIL, p) end
local shopBody = anchor("ShopBody")
if shopBody then table.insert(RETAIL, shopBody) end

------------------------------------------------------------------ general: pivot, tree, budgets, slot
if group("general") then
	-- A stray drag in Studio once moved a whole site; it shows up as a dozen unrelated failures, so test the pivot first.
	-- REPLACED (slot move): "site pivot is at the SiteData pos (550, 0, -650), facing SW"
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (550, 0, -700), facing SW",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(SW) > 0.999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
	-- REPLACED (board): "part count is between 600 and 2500"
	local total = partsIn(site)
	check("site holds 1700..2500 parts (whole estate at 1.05 studs/m, BuildCheck cap 2500)", total >= 1700 and total <= 2500, tostring(total))
	local st = site:FindFirstChild("Structure")
	local need = { "RetailWest", "RetailCentre", "RetailEast", "Stand", "PitchHouse" }
	local missing = {}
	for _, n in ipairs(need) do
		if not (st and st:FindFirstChild(n)) then table.insert(missing, n) end
	end
	check("Structure is a grouping Folder holding RetailWest, RetailCentre, RetailEast, Stand, PitchHouse",
		st ~= nil and st:IsA("Folder") and #missing == 0, table.concat(missing, ","))
	local big = {}
	for _, c in ipairs(site:GetChildren()) do
		if not KEPT[c.Name] then
			if c:IsA("Folder") then
				for _, cc in ipairs(c:GetChildren()) do
					if partsIn(cc) > 400 then table.insert(big, c.Name .. "/" .. cc.Name .. "=" .. partsIn(cc)) end
				end
			elseif partsIn(c) > 400 then
				table.insert(big, c.Name .. "=" .. partsIn(c))
			end
		end
	end
	check("every container holds at most 400 parts", #big == 0, table.concat(big, ","))
	local missingProps = {}
	for _, n in ipairs({ "ShopStreet", "SportsField", "EstateModelPedestal", "LipaMalvarPanel" }) do
		local c = site:FindFirstChild(n)
		if not (c and partsIn(c) > 0) then table.insert(missingProps, n) end
	end
	check("the four required props are direct children with parts (ShopStreet, SportsField, EstateModelPedestal, LipaMalvarPanel)",
		#missingProps == 0, table.concat(missingProps, ","))
	local dup = {}
	for _, n in ipairs({ "ShopBody", "WalkwayRoof", "PitchTurf", "StandTiers" }) do
		local k = #allNamed(n)
		if k ~= 1 then table.insert(dup, n .. "=" .. k) end
	end
	check("the sites_check guard anchors are unique (ShopBody, WalkwayRoof, PitchTurf, StandTiers: one part each)", #dup == 0, table.concat(dup, ","))
	local unanchored, outside, low = {}, {}, {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then
			if not d.Anchored then table.insert(unanchored, d.Name) end
			if not isKept(d) then
				local x0, x1 = extent(d, "X")
				local z0, z1 = extent(d, "Z")
				local y0 = extent(d, "Y")
				if x0 < -225.05 or x1 > 225.05 or z0 < -150.05 or z1 > 150.05 then table.insert(outside, d.Name .. " " .. tostring(lp(d))) end
				if y0 < -0.6 then table.insert(low, d.Name) end
			end
		end
	end
	check("every non-rig part is anchored", #unanchored == 0, table.concat(unanchored, ", ", 1, math.min(#unanchored, 6)))
	-- REPLACED (slot move): "every non-rig part is inside the footprint +10% (|x| <= 165, |z| <= 110)"
	check("every built part is inside the slot itself (x -225..225, z -150..150; the south edge stays flush with Road B's end)", #outside == 0,
		#outside .. ": " .. table.concat(outside, "; ", 1, math.min(#outside, 4)))
	check("nothing built reaches below y -0.6", #low == 0, table.concat(low, ", ", 1, math.min(#low, 6)))
	-- the ground: the terrain renders up to about 0.9 (Grass) and 1.25 (the old Pavement patches) above its physical y 0, so the decks top out
	-- at 1.2..1.45, and the walks meeting the bare plaza stand at most 1.45 (every edge step stays walkable, <= 1.3 plus an inlay)
	local lowDeck, highLayer, nDeck = {}, {}, 0
	local EDGE_WALKS = { PromenadeSpine = true, PromenadeInlay = true, EntryWalk = true, WalkwayPaving = true, PitchWalk = true }
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and GROUND_LAYER[d.Name] and not isRig(d) then
			local top = select(2, extent(d, "Y"))
			if DECKS[d.Name] then
				nDeck += 1
				if top < 1.2 or top > 1.45 then table.insert(lowDeck, d.Name .. " " .. fmt(top)) end
			end
			if top > 1.45 and EDGE_WALKS[d.Name] then table.insert(highLayer, d.Name .. " " .. fmt(top)) end
		end
	end
	check("the decks (paving, garden, courts, turf, aprons, ring road) top out at 1.2..1.45 so the rendered terrain cannot hide them", nDeck >= 12 and #lowDeck == 0,
		nDeck .. " decks; off: " .. table.concat(lowDeck, ", ", 1, math.min(#lowDeck, 4)))
	check("the spine and the walks that meet the bare plaza stand at most 1.45 high (a walkable step)", #highLayer == 0, table.concat(highLayer, ", ", 1, math.min(#highLayer, 4)))
	local scaled, bracket = {}, {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("TextLabel") and not isKept(d) and not isRig(d) then
			if d.TextScaled then table.insert(scaled, d:GetFullName()) end
			if string.find(d.Text, "[", 1, true) then table.insert(bracket, d.Text) end
		end
	end
	check("every built label uses a fixed TextSize (no TextScaled)", #scaled == 0, #scaled .. ": " .. table.concat(scaled, ", ", 1, math.min(#scaled, 3)))
	check("no built label carries a draft bracket", #bracket == 0, table.concat(bracket, "; "))
end

------------------------------------------------------------------ retail: ~20 low-rise outlet blocks around the promenade
if group("retail") then
	-- REPLACED (board): the old ShopBlock / WhiteWing / SecondBlock / PitchBlock massing pins (SecondBody at shop-frame x 56..92, z 46..60;
	-- PitchBlock x 70..84; SecondFascia; SecondSolar; ShopSolar above y 34; WingFascia; 12 SolarPanel). The board has ~20 blocks instead.
	-- REPLACED (owner's tidy round, 2026-10-31): "18..24 retail block bodies" -> 24..32: more blocks, chained in bars and L shapes as on the board
	check("24..32 retail block bodies (RetailBody plus the one ShopBody)", #RETAIL >= 24 and #RETAIL <= 32, tostring(#RETAIL))
	check("every block body is white render and low-rise (12..22 tall)",
		#RETAIL > 0 and count(RETAIL, function(p) return white(p) and p.Size.Y >= 12 and p.Size.Y <= 22 end) == #RETAIL,
		count(RETAIL, function(p) return not (white(p) and p.Size.Y >= 12 and p.Size.Y <= 22) end) .. " off")
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	local onPitch = {}
	for _, p in ipairs(RETAIL) do
		local l = lp(p)
		minX, maxX, minZ, maxZ = math.min(minX, l.X), math.max(maxX, l.X), math.min(minZ, l.Z), math.max(maxZ, l.Z)
		local x0, x1 = extent(p, "X")
		if x1 > 45 then table.insert(onPitch, p.Name .. " " .. fmt(x1)) end
	end
	check("the retail cluster fills the west two thirds: block centres from x <= -140 to x >= 10, z <= -85 to z >= 110",
		minX <= -140 and maxX >= 10 and minZ <= -85 and maxZ >= 110,
		string.format("x %s..%s z %s..%s", fmt(minX), fmt(maxX), fmt(minZ), fmt(maxZ)))
	check("no block reaches the pitch side (every block body ends at x 45 or less)", #onPitch == 0, table.concat(onPitch, ", "))
	-- no two bodies intersect (GetPartsInPart is exact for blocks)
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = RETAIL
	local clash = {}
	for _, p in ipairs(RETAIL) do
		for _, q in ipairs(workspace:GetPartsInPart(p, op)) do
			if q ~= p then table.insert(clash, p.Name .. "@" .. fmt(lp(p).X) .. "," .. fmt(lp(p).Z)) end
		end
	end
	check("no two block bodies intersect", #clash == 0, table.concat(clash, " ", 1, math.min(#clash, 6)))
	-- tidy round: the cluster reads continuous (board: chained blocks), so most bodies stand within 4 studs (bounding-box gap) of another
	local function ext2(p)
		local x0, x1 = extent(p, "X")
		local z0, z1 = extent(p, "Z")
		return x0, x1, z0, z1
	end
	local chained = 0
	for i, a in ipairs(RETAIL) do
		local ax0, ax1, az0, az1 = ext2(a)
		local best = math.huge
		for j, b in ipairs(RETAIL) do
			if i ~= j then
				local bx0, bx1, bz0, bz1 = ext2(b)
				best = math.min(best, math.max(math.max(0, math.max(ax0, bx0) - math.min(ax1, bx1)), math.max(0, math.max(az0, bz0) - math.min(az1, bz1))))
			end
		end
		if best <= 4 then chained += 1 end
	end
	check("16+ block bodies stand within 4 studs of another body (chained clusters)", chained >= 16, tostring(chained))
	local rot = count(RETAIL, function(p) return math.abs(p.CFrame.LookVector.X) > 0.15 and math.abs(p.CFrame.LookVector.X) < 0.98 end)
	check("3+ blocks are turned off the grid (the board's blocks sit at angles round the courts)", rot >= 3, tostring(rot))

	local tv = allNamed("TimberVolume")
	check("orange timber volumes on 10+ blocks (orange, at least as tall as the body beside them: 12+)",
		#tv >= 10 and count(tv, function(p) return orange(p) and p.Size.Y >= 12 end) == #tv, #tv .. " volumes")
	local solar = allNamed("SolarStrip")
	check("solar roof panel strips: 70+ SolarStrip, dark blue, all on roofs (y 12+)",
		#solar >= 70 and count(solar, function(p) return solarBlue(p) and p.Position.Y >= 12 end) == #solar, tostring(#solar))
	local glass = allNamed("StoreGlass")
	check("dark glass storefronts: 18+ StoreGlass, Glass material, dark", #glass >= 18 and count(glass, darkGlass) == #glass, tostring(#glass))
	local doors = allNamed("StoreDoor")
	check("18+ StoreDoor, each 8.5+ high (human scale fixed)", #doors >= 18 and count(doors, function(p) return p.Size.Y >= 8.5 end) == #doors, tostring(#doors))
	local fas = allNamed("RoofFascia")
	check("18+ terracotta RoofFascia bands at the roof edges", #fas >= 18 and count(fas, function(p) return orange(p) or maroon(p) end) == #fas, tostring(#fas))

	-- The identified block (look-at line: "orange timber block against the white walls and dark glass").
	local legs, band, planks = allNamed("TimberLeg"), anchor("TimberBand"), allNamed("TimberPlank")
	check("ShopBlock: a white ShopBody with an orange timber frame (2 TimberLeg + TimberBand, 6+ TimberPlank)",
		shopBody ~= nil and white(shopBody) and #legs == 2 and band ~= nil and orange(band) and count(legs, orange) == 2 and #planks >= 6,
		#legs .. " legs, " .. #planks .. " planks")
	local sg = allNamed("ShopGlass")
	check("ShopBlock: 6+ ShopGlass dark glass panes and a brown ShopCanopy between the floors",
		#sg >= 6 and count(sg, darkGlass) == #sg and anchor("ShopCanopy") ~= nil and brown(anchor("ShopCanopy")), tostring(#sg))
	check("ShopBlock stands east of the arrival plaza (x 0..45, z 0..45)",
		shopBody ~= nil and lp(shopBody).X >= 0 and lp(shopBody).X <= 45 and lp(shopBody).Z >= 0 and lp(shopBody).Z <= 45,
		shopBody and tostring(lp(shopBody)) or "missing")
end

------------------------------------------------------------------ promenade: oval plaza, spine, covered walkways, planting
if group("promenade") then
	local street = site:FindFirstChild("ShopStreet")
	local oval = allNamed("OvalPaving")
	local ox0, ox1, oz0, oz1 = math.huge, -math.huge, math.huge, -math.huge
	for _, p in ipairs(oval) do
		local a, b = extent(p, "X")
		local c, d = extent(p, "Z")
		ox0, ox1, oz0, oz1 = math.min(ox0, a), math.max(ox1, b), math.min(oz0, c), math.max(oz1, d)
	end
	check("the oval plaza: OvalPaving 24..36 wide (x) and 40..58 long (z), centred near (-34, -40)",
		#oval >= 3 and ox1 - ox0 >= 24 and ox1 - ox0 <= 36 and oz1 - oz0 >= 40 and oz1 - oz0 <= 58
			and near((ox0 + ox1) / 2, -34, 6) and near((oz0 + oz1) / 2, -40, 6),
		string.format("x %s..%s z %s..%s", fmt(ox0), fmt(ox1), fmt(oz0), fmt(oz1)))
	check("the oval holds a lawn ring and a centre feature (OvalLawn 3+, OvalCentre)", #allNamed("OvalLawn") >= 3 and anchor("OvalCentre") ~= nil)
	local spine = anchor("PromenadeSpine")
	check("PromenadeSpine: a 0.4-thick paved spine from the oval (z <= -15) to the arrival plaza (z >= 28), x within -52..-16",
		spine ~= nil and spine.Size.Y >= 0.35 and select(1, extent(spine, "Z")) <= -15 and select(2, extent(spine, "Z")) >= 28
			and select(1, extent(spine, "X")) >= -52 and select(2, extent(spine, "X")) <= -16,
		spine and string.format("z %s..%s", fmt(select(1, extent(spine, "Z"))), fmt(select(2, extent(spine, "Z")))) or "missing")
	local wr = anchor("WalkwayRoof")
	local canopies = allNamed("WalkwayCanopy")
	check("covered walkways: WalkwayRoof plus 3+ WalkwayCanopy, brown, 10..14 high, 40+ studs of canopy beyond the WalkwayRoof",
		wr ~= nil and brown(wr) and #canopies >= 3 and count(canopies, brown) == #canopies
			and count(canopies, function(p) return topY(p) >= 10 and topY(p) <= 14 end) == #canopies,
		#canopies .. " canopies")
	local long = 0
	for _, p in ipairs(canopies) do long += math.max(p.Size.X, p.Size.Z) end
	check("the canopies run 100+ studs in all (a long covered walkway)", long >= 100, fmt(long))
	check("8+ WalkwayPost under the canopies", #allNamed("WalkwayPost") >= 8, tostring(#allNamed("WalkwayPost")))
	check("WalkwayRoof is in front (SW) of the ShopBody by 10+ (the sites_check guard)",
		wr ~= nil and shopBody ~= nil and (wr.Position - shopBody.Position):Dot(SW) > 10,
		wr and shopBody and fmt((wr.Position - shopBody.Position):Dot(SW)) or "missing")
	check("planting: 30+ TreeCrown and 12+ PalmTrunk in the site", #allNamed("TreeCrown") >= 30 and #allNamed("PalmTrunk") >= 12,
		#allNamed("TreeCrown") .. " crowns, " .. #allNamed("PalmTrunk") .. " palms")
	-- tidy round: a green landscaped spine, ring planting round the oval, planted beds on the arrival court, more trees and palms
	local beds = allNamed("SpineBed")
	local bedTrees = 0
	for _, t in ipairs(allNamed("TreeTrunk")) do
		for _, b in ipairs(beds) do
			local l = b.CFrame:PointToObjectSpace(t.Position)
			if math.abs(l.X) <= b.Size.X / 2 and math.abs(l.Z) <= b.Size.Z / 2 then bedTrees += 1 break end
		end
	end
	check("the spine is green: 2+ SpineBed lawn beds 30+ long within x -52..-16, 6+ trees growing in them",
		#beds >= 2 and count(beds, function(p) return greenish(p) and math.max(p.Size.X, p.Size.Z) >= 30 and lp(p).X >= -52 and lp(p).X <= -16 end) == #beds
			and bedTrees >= 6, #beds .. " beds, " .. bedTrees .. " trees")
	check("ring planting round the oval: 12+ OvalShrub", #allNamed("OvalShrub") >= 12, tostring(#allNamed("OvalShrub")))
	local pbeds = allNamed("PlazaBed")
	local pTrees = 0
	for _, t in ipairs(allNamed("TreeTrunk")) do
		for _, b in ipairs(pbeds) do
			local l = b.CFrame:PointToObjectSpace(t.Position)
			if math.abs(l.X) <= b.Size.X / 2 and math.abs(l.Z) <= b.Size.Z / 2 then pTrees += 1 break end
		end
	end
	check("the arrival court holds 2+ raised green PlazaBed beds (top 1.3+, above the rendered terrain) with 4+ trees",
		#pbeds >= 2 and count(pbeds, function(p) return greenish(p) and topY(p) >= 1.3 end) == #pbeds and pTrees >= 4, #pbeds .. " beds, " .. pTrees .. " trees")
	check("more planting: 220+ TreeCrown and 24+ PalmTrunk", #allNamed("TreeCrown") >= 220 and #allNamed("PalmTrunk") >= 24,
		#allNamed("TreeCrown") .. " crowns, " .. #allNamed("PalmTrunk") .. " palms")
	check("8+ StreetLampHead on StreetLampPole (LampGlow names)", #allNamed("StreetLampHead") >= 8 and #allNamed("StreetLampPole") >= 8,
		#allNamed("StreetLampHead") .. "/" .. #allNamed("StreetLampPole"))
	local seats = allNamed("BenchSeat")
	-- REPLACED (deck, after the first build): "seat top 1.8..2.4" measured from y 0; benches on a deck stand 1.3 higher, so the seat top is
	-- measured above the surface directly beneath it
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = seats
	local function seatHeight(p)
		local hit = workspace:Raycast(p.Position, Vector3.new(0, -10, 0), rp)
		return hit and (topY(p) - hit.Position.Y) or nil
	end
	check("6+ benches, seat top 1.8..2.4 above the surface beneath (human scale)", #seats >= 6
		and count(seats, function(p) local h = seatHeight(p); return h ~= nil and h >= 1.8 and h <= 2.4 end) == #seats, tostring(#seats))
	local lawn = allNamed("GardenLawn")
	check("landscaped garden in the north-west (GardenLawn within x -185..-60, z -120..-60, 4+ GardenPath)",
		#lawn >= 1 and count(lawn, function(p) return lp(p).X >= -185 and lp(p).X <= -60 and lp(p).Z >= -120 and lp(p).Z <= -60 end) == #lawn
			and #allNamed("GardenPath") >= 4, #lawn .. " lawns, " .. #allNamed("GardenPath") .. " paths")
	check("ShopStreet holds the spine, the oval and the walkways", street ~= nil and spine ~= nil and spine:IsDescendantOf(street)
		and #oval > 0 and oval[1]:IsDescendantOf(street))
end

------------------------------------------------------------------ parking: courts W and NE with islands and cars
if group("parking") then
	local ne, w = anchor("ParkingNE"), anchor("ParkingW")
	check("ParkingNE: a court slab north of the pitch (x 55..200, z -110..-10), 8000+ square studs",
		ne ~= nil and select(1, extent(ne, "X")) >= 55 and select(2, extent(ne, "X")) <= 200 and select(1, extent(ne, "Z")) >= -110
			and select(2, extent(ne, "Z")) <= -10 and ne.Size.X * ne.Size.Z >= 8000,
		ne and tostring(lp(ne)) .. " " .. tostring(ne.Size) or "missing")
	check("ParkingW: a court slab on the west edge (x -215..-165)", w ~= nil and select(1, extent(w, "X")) >= -215 and select(2, extent(w, "X")) <= -165,
		w and tostring(lp(w)) or "missing")
	local lines = allNamed("BayLine")
	check("60+ white BayLine marks", #lines >= 60 and count(lines, white) == #lines, tostring(#lines))
	local cars = allNamed("CarBody")
	local function onCourt(p)
		for _, c in ipairs({ ne, w, anchor("ParkingS") }) do
			if c then
				local l = c.CFrame:PointToObjectSpace(p.Position)
				if math.abs(l.X) <= c.Size.X / 2 and math.abs(l.Z) <= c.Size.Z / 2 then return true end
			end
		end
		return false
	end
	check("16+ cars, every CarBody on a parking court", #cars >= 16 and count(cars, onCourt) == #cars, #cars .. " cars, " .. count(cars, onCourt) .. " on a court")
	local isl = allNamed("ParkingIsland")
	check("3+ green ParkingIsland strips with trees", #isl >= 3 and count(isl, greenish) == #isl, tostring(#isl))
	local onIsl = 0
	for _, nm in ipairs({ "TreeTrunk", "PalmTrunk" }) do
		for _, t in ipairs(allNamed(nm)) do
			for _, i in ipairs(isl) do
				local l = i.CFrame:PointToObjectSpace(t.Position)
				if math.abs(l.X) <= i.Size.X / 2 and math.abs(l.Z) <= i.Size.Z / 2 then onIsl += 1 break end
			end
		end
	end
	check("tidy round: 22+ trees and palms grow on the parking islands", onIsl >= 22, tostring(onIsl))
	check("4+ CarParkLamp heads", #allNamed("CarParkLamp") >= 4, tostring(#allNamed("CarParkLamp")))
end

------------------------------------------------------------------ pitch: the Aboitiz Pitch and the curved grandstand
if group("pitch") then
	local turf = anchor("PitchTurf")
	-- REPLACED (board): "PitchTurf is bright green (G 140+) and still 62 x 96 at x 90..152"
	check("PitchTurf: bright green, 120..140 along x and 84..100 along z (long axis E-W), centre x 105..130, z 38..58",
		turf ~= nil and turf.Color.G * 255 >= 140 and turf.Size.X >= 120 and turf.Size.X <= 140 and turf.Size.Z >= 84 and turf.Size.Z <= 100
			and lp(turf).X >= 105 and lp(turf).X <= 130 and lp(turf).Z >= 38 and lp(turf).Z <= 58,
		turf and (tostring(turf.Size) .. " at " .. tostring(lp(turf))) or "missing")
	check("the pitch is east of the shops (turf x > ShopBody x + 40, the sites_check guard)",
		turf ~= nil and shopBody ~= nil and turf.Position.X > shopBody.Position.X + 40)
	local posts = allNamed("GoalPost")
	local ends = turf and count(posts, function(p) return math.abs(p.Position.X - turf.Position.X) >= 50 end) or 0
	check("two full goals at the E and W ends (4 GoalPost, each 50+ from the centre along x)", #posts == 4 and ends == 4, #posts .. " posts, " .. ends .. " at the ends")
	local lineNames = { "TouchLine", "GoalLine", "HalfwayLine", "CentreCircle", "PenaltyLine" }
	local miss = {}
	for _, n in ipairs(lineNames) do
		local l = allNamed(n)
		if #l == 0 or count(l, white) ~= #l then table.insert(miss, n) end
	end
	check("field markings in white: TouchLine, GoalLine, HalfwayLine, CentreCircle, PenaltyLine", #miss == 0, table.concat(miss, ","))
	check("2 touch lines 100+ long along x and 2 goal lines 60+ long along z",
		#allNamed("TouchLine") == 2 and count(allNamed("TouchLine"), function(p) return p.Size.X >= 100 end) == 2
			and #allNamed("GoalLine") == 2 and count(allNamed("GoalLine"), function(p) return p.Size.Z >= 60 end) == 2)
	local sign = anchor("PitchSign")
	check("PitchSign reads ABOITIZ PITCH (fixed text size)", sign ~= nil and guiText(sign):upper():find("ABOITIZ PITCH") ~= nil, sign and guiText(sign) or "missing")
	check("3+ PitchFence net panels and 4 FloodMast 24+ tall",
		#allNamed("PitchFence") >= 3 and #allNamed("FloodMast") == 4 and count(allNamed("FloodMast"), function(p) return math.max(p.Size.X, p.Size.Y) >= 24 end) == 4)

	local tiers = anchor("StandTiers")
	check("the stand is south of the pitch (StandTiers z > turf z + 30, the sites_check guard)",
		turf ~= nil and tiers ~= nil and tiers.Position.Z > turf.Position.Z + 30, tiers and tostring(lp(tiers)) or "missing")
	local tierParts = allNamed("StandTier")
	check("the grandstand has 24+ StandTier steps", #tierParts >= 24, tostring(#tierParts))
	-- curved: the front tier of the middle segment lies further south than the front tiers at the two ends
	local fronts = allNamed("StandFront")
	local midZ, endZ = nil, -math.huge
	if #fronts >= 5 and turf then
		table.sort(fronts, function(a, b) return a.Position.X < b.Position.X end)
		midZ = lp(fronts[math.ceil(#fronts / 2)]).Z
		endZ = math.max(lp(fronts[1]).Z, lp(fronts[#fronts]).Z)
	end
	check("the grandstand curves: 7+ StandFront segments, the middle one 5+ studs further south than the ends",
		#fronts >= 7 and midZ ~= nil and midZ >= endZ + 5, midZ and (fmt(midZ) .. " vs " .. fmt(endZ)) or tostring(#fronts))
	local roof, sol = allNamed("StandRoof"), allNamed("StandSolar")
	check("the stand roof carries solar panels (7+ StandRoof brown, 7+ StandSolar dark blue)",
		#roof >= 7 and count(roof, brown) == #roof and #sol >= 7 and count(sol, solarBlue) == #sol, #roof .. "/" .. #sol)
	local doors = allNamed("StandDoor")
	check("the support building under the stand has 3+ StandDoor 8.5+ high", #doors >= 3 and count(doors, function(p) return p.Size.Y >= 8.5 end) == #doors, tostring(#doors))
	local hb, hr = anchor("PitchHouseBody"), anchor("PitchHouseRoof")
	check("the brown-roofed support pavilion at the pitch's north-west corner (x 25..62, z -45..-5)",
		hb ~= nil and hr ~= nil and maroon(hr) and lp(hb).X >= 25 and lp(hb).X <= 62 and lp(hb).Z >= -45 and lp(hb).Z <= -5,
		hb and tostring(lp(hb)) or "missing")
end

------------------------------------------------------------------ entrance: roads, monument, perimeter
if group("entrance") then
	local stub = anchor("EntryRoad")
	check("EntryRoad meets Road B's end: x -126..-114 (12 wide), reaching z 150", stub ~= nil and near(lp(stub).X, -120, 1) and stub.Size.X >= 11.5
		and near(select(2, extent(stub, "Z")), 150, 0.3) and lightGrey(stub), stub and tostring(lp(stub)) or "missing")
	local missing = {}
	for _, n in ipairs({ "SouthRoad", "WestRoad", "EastRoad", "NorthRoad" }) do
		if not anchor(n) then table.insert(missing, n) end
	end
	check("the ring road: SouthRoad, WestRoad, EastRoad, NorthRoad", #missing == 0, table.concat(missing, ","))
	local slats = allNamed("MonumentSlat")
	check("the slatted monument: 10+ white MonumentSlat 9+ tall", #slats >= 10 and count(slats, function(p) return white(p) and p.Size.Y >= 9 end) == #slats, tostring(#slats))
	local panel = anchor("MonumentPanel")
	local txt = panel and (guiText(panel):gsub("<[^>]+>", "")) or "" -- RichText: the colour tags split OUTLETS, so match the plain words
	check("MonumentPanel reads % THE OUTLETS", panel ~= nil and txt:find("OUTLETS") ~= nil and txt:find("%%") ~= nil and txt:find("THE") ~= nil, txt)
	local face = panel and panel:FindFirstChildOfClass("SurfaceGui")
	local normal = face and panel.CFrame:VectorToWorldSpace(Vector3.FromNormalId(face.Face))
	check("the monument faces SW and stands within 45 studs of the road mouth (-120, 150)",
		normal ~= nil and normal:Dot(SW) > 0.9 and (Vector3.new(lp(panel).X, 0, lp(panel).Z) - Vector3.new(-120, 0, 150)).Magnitude <= 45,
		panel and (tostring(lp(panel)) .. " normal " .. tostring(normal)) or "missing")
	check("3+ PerimeterHedge strips", #allNamed("PerimeterHedge") >= 3)
	-- REPLACED (board): the Slice 16 junction pins (16-wide EntryPath, KerbBlack/KerbYellow, ZebraStripe at z 91, PaverStrip, IslandLawn,
	-- 24 Topiary, IslandRock, ChainBollard/ChainLink, WaterBarrier, BillboardPanel/BillboardPost, PylonBody/PylonSign/PylonChevron,
	-- OfficeBody/OfficeDoor/OfficeCanopy, CarParkSlab z 61+) are not on the board; those names stay unused.
	local gone = {}
	for _, n in ipairs({ "KerbBlack", "Topiary", "BillboardPanel", "PylonBody", "OfficeBody", "CarParkSlab", "PitchBlock", "SecondBody", "Hedge" }) do
		if #allNamed(n) > 0 then table.insert(gone, n) end
	end
	check("the retired Slice 16 junction and massing names are unused", #gone == 0, table.concat(gone, ","))
end

------------------------------------------------------------------ clear: kept objects untouched, landing, paths, NPC spots
if group("clear") then
	for name in pairs(KEPT) do
		check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	local pad, guide, info = site:FindFirstChild("JeepStop"), site:FindFirstChild("Guide"), site:FindFirstChild("InfoPanel")
	-- REPLACED (slot move): "JeepStop pad is at (-35.4, 7.1) of the site centre" and "Guide is at (-21.2, 21.2) of the site centre":
	-- the same WORLD points, now written as world literals.
	check("JeepStop pad is at world (514.6, -642.9)", pad ~= nil and (Vector3.new(pad.Position.X, 0, pad.Position.Z) - Vector3.new(514.645, 0, -642.929)).Magnitude < 1,
		pad and tostring(pad.Position) or "missing")
	local gpos = guide and guide:GetPivot().Position
	check("Guide is at world (528.8, -628.8)", gpos ~= nil and (Vector3.new(gpos.X, 0, gpos.Z) - Vector3.new(528.787, 0, -628.787)).Magnitude < 1, gpos and tostring(gpos) or "missing")
	check("InfoPanel is at world (541.5, -624.5)", info ~= nil and (Vector3.new(info.Position.X, 0, info.Position.Z) - Vector3.new(541.515, 0, -624.544)).Magnitude < 1,
		info and tostring(info.Position) or "missing")

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { site }
	local function blockers(centre, size, cf)
		local bad = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(cf or CFrame.new(centre), size, params)) do
			-- ground slabs (top within 0.6 of the ground) and the named ground layers (decks, inlays, markings) are fine, standing objects are not
			-- (REPLACED after the first build: the decks top out at 1.3, so they are skipped by name, not by height)
			if not isKept(p) and not isRig(p) and not GROUND_LAYER[p.Name] and p.Position.Y + p.Size.Y / 2 > 0.6 then table.insert(bad, p.Name) end
		end
		return bad
	end
	if pad then
		local bad = blockers(pad.Position + Vector3.new(0, 8, 0), Vector3.new(20, 16, 20))
		check("nothing stands within 10 studs of the JeepStop landing", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
		local under = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(pad.Position.X, 0.2, pad.Position.Z), Vector3.new(10, 0.4, 10), params)) do
			if not isKept(p) and not isRig(p) then table.insert(under, p.Name) end
		end
		check("no slab is stacked under the JeepStop pad (no z-fighting)", #under == 0, table.concat(under, ", ", 1, math.min(#under, 4)))
	end
	if pad and guide then
		local a, b = pad.Position, guide:GetPivot().Position
		local bad = {}
		for t = 0, 1, 0.05 do
			local c = a:Lerp(b, t)
			for _, n in ipairs(blockers(Vector3.new(c.X, 3.2, c.Z), Vector3.new(2, 5, 2))) do table.insert(bad, n) end
		end
		check("the straight path from the pad to the Guide stays open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
		local gb = blockers(b + Vector3.new(0, 3, 0), Vector3.new(8, 8, 8))
		check("nothing stands within the Guide's box", #gb == 0, table.concat(gb, ", ", 1, math.min(#gb, 6)))
	end
	if info then
		local front = info.Position - Vector3.new(0, info.Position.Y, 0) + SW * 7 + Vector3.new(0, 4, 0)
		local bad = blockers(front, Vector3.new(12, 8, 12))
		check("the InfoPanel's front zone (SW of it) is open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	end
	local jeep = site:FindFirstChild("Jeepney")
	if jeep then
		local cf, size = jeep:GetBoundingBox()
		local bad = blockers(nil, size + Vector3.new(4, 0, 4), cf)
		check("nothing built stands in the parked Jeepney's box (+2 each side)", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	end
	-- the NPC spots of builders/npcs.luau [6] stand in the open (a probe ray that starts inside a block would not see it)
	for _, spot in ipairs({ { "Shopper1", 575, -645 }, { "Shopper2", 566, -652 }, { "FootballPlayer", 650, -660 } }) do
		local bad = blockers(Vector3.new(spot[2], 5, spot[3]), Vector3.new(3, 8.6, 3))
		check("the " .. spot[1] .. " spot (" .. spot[2] .. ", " .. spot[3] .. ") is open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 4)))
	end
	local turf = anchor("PitchTurf")
	check("the FootballPlayer spot (650, -660) is on the turf", turf ~= nil and math.abs(650 - turf.Position.X) <= turf.Size.X / 2 - 4
		and math.abs(-660 - turf.Position.Z) <= turf.Size.Z / 2 - 4)
	-- the walk from Road B's mouth to the Guide: 4-wide person boxes, y 2..9, through the entrance walk and the plaza
	local lane = { { -108, 140 }, { -108, 104 }, { -62, 104 }, { -30, 78 } }
	local bad = {}
	for i = 1, #lane - 1 do
		local a = SITE_POS + Vector3.new(lane[i][1], 0, lane[i][2])
		local b = SITE_POS + Vector3.new(lane[i + 1][1], 0, lane[i + 1][2])
		local dir = b - a
		local n = math.max(1, math.ceil(dir.Magnitude / 12))
		for k = 0, n - 1 do
			local p, q = a + dir * (k / n), a + dir * ((k + 1) / n)
			local mid = (p + q) / 2
			local cf = CFrame.lookAt(Vector3.new(mid.X, 5.5, mid.Z), Vector3.new(mid.X + dir.X, 5.5, mid.Z + dir.Z))
			for _, nme in ipairs(blockers(nil, Vector3.new(4, 7, (q - p).Magnitude + 0.5), cf)) do table.insert(bad, nme) end
		end
	end
	check("the walk from Road B's mouth to the Guide is open (entry walk, then the plaza)", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	local mouth = blockers(nil, Vector3.new(12, 8, 30), CFrame.new(SITE_POS + Vector3.new(-120, 5, 135)))
	check("the road mouth lane (x -126..-114, z 120..150) is open", #mouth == 0, table.concat(mouth, ", ", 1, math.min(#mouth, 4)))
end

------------------------------------------------------------------ props: estate model pedestal and the Lipa/Malvar panel (texts kept)
if group("props") then
	local plinth = anchor("Plinth")
	check("EstateModelPedestal: Plinth labelled LIMA ESTATE MODEL, a ModelPitch and a glass ModelCase",
		plinth ~= nil and guiText(plinth):find("LIMA ESTATE MODEL") ~= nil and anchor("ModelPitch") ~= nil and anchor("ModelCase") ~= nil
			and plinth:IsDescendantOf(site:FindFirstChild("EstateModelPedestal") or site))
	local title, lipa, malvar = anchor("PanelTitle"), anchor("PanelLipa"), anchor("PanelMalvar")
	check("LipaMalvarPanel: LIMA ESTATE SPANS LIPA AND MALVAR / LIPA CITY / MALVAR",
		title ~= nil and lipa ~= nil and malvar ~= nil and guiText(title) == "LIMA ESTATE SPANS LIPA AND MALVAR"
			and guiText(lipa) == "LIPA CITY" and guiText(malvar) == "MALVAR")
	local guide = site:FindFirstChild("Guide")
	local g = guide and guide:GetPivot().Position
	check("both props stand on the arrival plaza within 45 studs of the Guide",
		g ~= nil and plinth ~= nil and title ~= nil
			and Vector3.new(plinth.Position.X - g.X, 0, plinth.Position.Z - g.Z).Magnitude <= 45
			and Vector3.new(title.Position.X - g.X, 0, title.Position.Z - g.Z).Magnitude <= 45)
end

return HttpService:JSONEncode(results)
