-- site08_check: the Slice 21 fidelity spec for Site 08 (Mount Malarayat Golf & Country Club), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site08_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site08_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site08.md "Revision 1 (Slice 21)": Malarayat_Clubhouse_Aerial.jpg, the cart-side exterior photo and the
-- across-lake photo. The clubhouse is built in a local frame, so the checks use part names, counts, colours and sizes rather than coordinates.
-- Revision 2 (board rebuild, 2026-10-31): groups. Set shared.site08_only = "general" | "entrance" | "clubhouse" | "hotel" | "context" first
-- to run one; run_all leaves it nil and runs all. Photo pins the Mount Malarayat blueprint board contradicts were REPLACED, each logged
-- old -> new in briefs/site08.md Revision 2 (RoofTier, WindowTrim, StoneCourse, CartBody, the 16-pine count, the part range).
-- Revision 3 (owner look, 2026-10-31): groups "mountain" (a wedge ridge behind the clubhouse replaces the cylinder tiers), "course" (fairways,
-- greens with flags, bunkers, ponds lying on the slope), "planting" (dense woods and palms); the entrance group gains the flush-lagoon pins.
-- Polish (2026-10-31): group "ground" (no terrain Grass blades under water, bunkers, paving, floors; builders/site08_ground.luau).
-- Session 062 (owner): group "pines" (tapered conifers replace the stacked tiers), group "sign" (both lines of the rock sign seen from the
-- approach), and a dense no-Grass grid under the water in "ground". Pins replaced in place are logged in briefs/site08.md Revision 4.
local HttpService = game:GetService("HttpService")
local ONLY = shared.site08_only
local function run(group) return ONLY == nil or ONLY == group end
local SITE_POS = Vector3.new(560, 19.8, 720)

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site08_Malarayat")
check("Site08_Malarayat exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
do
	local pv = site:GetPivot()
	local s = math.sqrt(0.5)
	check("site pivot is at the SiteData pos (560, 19.8, 720), facing NW",
		(pv.Position - SITE_POS).Magnitude < 0.05 and pv.LookVector:Dot(Vector3.new(-s, 0, -s)) > 0.999,
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
local function extent(d, axis)
	local cf, sz = d.CFrame, d.Size
	return (math.abs(cf.RightVector[axis]) * sz.X + math.abs(cf.UpVector[axis]) * sz.Y + math.abs(cf.LookVector[axis]) * sz.Z)
end
local function fmt(v) return v and string.format("%.2f", v) or "nil" end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end

local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end

------------------------------------------------------------------ Kept objects and required props
if run("general") then
	for name in pairs(KEPT) do check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil) end
	for _, name in ipairs({ "Clubhouse", "MountainBackdrop", "LeisureSpacesPanel" }) do
		check("required prop present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "ClubhouseRoofMain", "ClubhouseEntryGable", "PorteCochere" }) do
		check("anchor exists: " .. name, #allNamed(name) == 1)
	end
end

------------------------------------------------------------------ Board rebuild helpers (Revision 2)
local S = math.sqrt(0.5)
local NW = Vector3.new(-S, 0, -S)
local function off(a, b) return Vector3.new(a.X - b.X, 0, a.Z - b.Z) end
local function within(root, name)
	local list = {}
	if not root then return list end
	for _, d in ipairs(root:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") then table.insert(list, d) end
	end
	return list
end
local function terracotta(p)
	local r, g, b = rgb(p)
	return r >= 190 and r <= 212 and g >= 76 and g <= 95 and b >= 44 and b <= 60
end
local function cream(p)
	local r, g, b = rgb(p)
	return r >= 220 and g >= 205 and b >= 165 and r - b <= 60
end
-- A hip roof is a Model named RoofHip holding 4 CornerWedgeParts (the hips) and tile parts, all terracotta.
local function hipRoofs(root)
	local list, bad = {}, 0
	if not root then return list, bad end
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("Model") and d.Name == "RoofHip" then
			local corners = 0
			for _, p in ipairs(d:GetDescendants()) do
				if p:IsA("CornerWedgePart") then corners += 1 end
				if p:IsA("BasePart") and p.Name == "RoofTile" and not terracotta(p) then bad += 1 end
			end
			if corners >= 4 then table.insert(list, d) end
		end
	end
	return list, bad
end
local function topY(p) return p.Position.Y + extent(p, "Y") / 2 end
local function gnd(x, z)
	local tp = RaycastParams.new()
	tp.FilterType = Enum.RaycastFilterType.Include
	tp.FilterDescendantsInstances = { workspace.Terrain }
	local r = workspace:Raycast(Vector3.new(x, 200, z), Vector3.new(0, -400, 0), tp)
	return r and r.Position.Y or 0
end
local function labelsOf(root)
	local t = {}
	for _, g in ipairs(root:GetDescendants()) do
		if g:IsA("TextLabel") then table.insert(t, g) end
	end
	return t
end
local function creamCount(list)
	local bad = 0
	for _, w in ipairs(list) do if not cream(w) then bad += 1 end end
	return bad
end

------------------------------------------------------------------ ENTRANCE (Revision 2): the board's main entrance at the road mouth
if run("entrance") then
	local ent = site:FindFirstChild("Entrance")
	check("entrance: Entrance container is a direct child", ent ~= nil and ent:IsA("Model"))
	-- Rock monument sign, east of the drive axis (board-left of the gate), lettering facing the road (south, -Z).
	local mon = ent and ent:FindFirstChild("RockMonument", true)
	local rocks = within(mon, "MonumentRock")
	check("entrance: rock monument of at least 12 rocks", mon ~= nil and #rocks >= 12, tostring(#rocks))
	local sign = within(mon, "MonumentSign")[1]
	local text, scaled = "", false
	if sign then
		for _, l in ipairs(labelsOf(sign)) do
			text ..= " " .. l.Text
			scaled = scaled or l.TextScaled
		end
	end
	local gui = sign and sign:FindFirstChildOfClass("SurfaceGui")
	local faceDir = gui and sign.CFrame:VectorToWorldSpace(Vector3.FromNormalId(gui.Face))
	check("entrance: sign reads MOUNT MALARAYAT / GOLF AND COUNTRY CLUB in fixed-size type",
		sign ~= nil and text:find("MOUNT MALARAYAT", 1, true) ~= nil and text:find("GOLF AND COUNTRY CLUB", 1, true) ~= nil and not scaled, text)
	check("entrance: lettering faces the road (south)", faceDir ~= nil and faceDir.Z < -0.7, tostring(faceDir))
	check("entrance: monument stands east of the drive near the road mouth (x 495..560, z 560..615)",
		sign ~= nil and sign.Position.X >= 495 and sign.Position.X <= 560 and sign.Position.Z >= 560 and sign.Position.Z <= 615,
		sign and tostring(sign.Position) or "missing")
	-- Lagoons on both sides of the drive: terraced level water parts, boulders.
	local water = within(ent, "LagoonWater")
	local east, westw, solid = 0, 0, 0
	for _, w in ipairs(water) do
		if w.Position.X > 456 then east += 1 elseif w.Position.X < 444 then westw += 1 end
		if w.CanCollide or w.Transparency < 0.1 then solid += 1 end
	end
	check("entrance: lagoon water on both sides of the drive (east and west)", east >= 1 and westw >= 1, east .. " east, " .. westw .. " west")
	check("entrance: lagoon water is non-colliding and translucent", #water > 0 and solid == 0, tostring(solid))
	check("entrance: at least 20 lagoon boulders", #within(ent, "LagoonBoulder") >= 20, tostring(#within(ent, "LagoonBoulder")))
	-- Gatehouse: cream walls, hip red-tile roofs, arched openings, gates and pillars, astride the drive.
	local gh = ent and ent:FindFirstChild("Gatehouse", true)
	local walls = within(gh, "GatehouseWall")
	check("entrance: gatehouse walls are cream (the board, not the photo's grey)", #walls >= 3 and creamCount(walls) == 0,
		#walls .. " walls, " .. creamCount(walls) .. " off colour")
	local ghRoofs, ghBad = hipRoofs(gh)
	check("entrance: gatehouse has at least 3 hip red-tile roofs (pavilion and two lane canopies)", #ghRoofs >= 3 and ghBad == 0,
		#ghRoofs .. " roofs, " .. ghBad .. " off colour")
	check("entrance: gatehouse has at least 3 arched openings", #within(gh, "GatehouseArch") >= 3, tostring(#within(gh, "GatehouseArch")))
	check("entrance: two gate leaves and at least 4 gate pillars", #within(ent, "GateLeaf") >= 2 and #within(ent, "GatePillar") >= 4,
		#within(ent, "GateLeaf") .. " leaves, " .. #within(ent, "GatePillar") .. " pillars")
	local ghc = gh and gh:GetBoundingBox()
	check("entrance: gatehouse straddles the drive at the road mouth (x 420..460, z 575..615)",
		ghc ~= nil and ghc.X >= 420 and ghc.X <= 460 and ghc.Z >= 575 and ghc.Z <= 615, ghc and tostring(ghc.Position) or "missing")
	local hi = -math.huge
	for _, p in ipairs(gh and gh:GetDescendants() or {}) do
		if p:IsA("BasePart") then hi = math.max(hi, topY(p)) end
	end
	check("entrance: gatehouse pavilion rises at least 16 above the drive", ghc ~= nil and hi - gnd(450, 600) >= 16, fmt(hi))
	-- Flag poles on a planter island in the forecourt, west of the drive axis (outside the road sight wedge).
	local poles = within(ent, "FlagPole")
	local badPole = 0
	for _, p in ipairs(poles) do
		if extent(p, "Y") < 14 or p.Position.X > 446 then badPole += 1 end
	end
	check("entrance: at least 4 flag poles, 14+ tall, west of the drive axis", #poles >= 4 and badPole == 0, #poles .. " poles, " .. badPole .. " bad")
	check("entrance: flag planter island and paved forecourt strips", #within(ent, "FlagPlanter") >= 1 and #within(ent, "EntrancePaving") >= 3,
		#within(ent, "FlagPlanter") .. " planter, " .. #within(ent, "EntrancePaving") .. " paving")
end

------------------------------------------------------------------ CLUBHOUSE (Revision 2): the board's elevation inset
if run("clubhouse") then
	local club = site:FindFirstChild("Clubhouse")
	local cap = allNamed("ClubhouseRoofMain")[1]
	local walls = within(club, "ClubWall")
	check("clubhouse: walls are cream (board), at least 4 wall parts", #walls >= 4 and creamCount(walls) == 0,
		#walls .. " walls, " .. creamCount(walls) .. " off colour")
	local roofs, bad = hipRoofs(club)
	check("clubhouse: at least 5 hip red-tile roofs (wings, main block, pavilion, porte-cochere)", #roofs >= 5 and bad == 0,
		#roofs .. " roofs, " .. bad .. " off colour")
	if cap then
		local r, g, b = rgb(cap)
		check("clubhouse: ridge cap is a darker terracotta (r 150..185)", r >= 150 and r <= 185 and g <= 75, string.format("%.0f,%.0f,%.0f", r, g, b))
	end
	local arches = within(club, "LoggiaArch")
	local front = 0
	for _, a in ipairs(arches) do
		if cap and off(a.Position, cap.Position):Dot(NW) >= 10 then front += 1 end
	end
	check("clubhouse: arched loggia of at least 5 arches on the front", #arches >= 5 and front >= 5, front .. " of " .. #arches .. " in front")
	local tallest = true
	if cap and club then
		for _, p in ipairs(club:GetDescendants()) do
			if p:IsA("BasePart") and p ~= cap and topY(p) > topY(cap) + 0.01 then tallest = false end
		end
	end
	check("clubhouse: the central pavilion is the highest roof", cap ~= nil and tallest and #within(club, "PavilionWall") >= 2, cap and fmt(topY(cap)) or "missing")
	local porte = allNamed("PorteCochere")[1]
	local porteRoof = false
	for _, rf in ipairs(roofs) do
		if porte and off(rf:GetBoundingBox().Position, porte.Position).Magnitude <= 12 then porteRoof = true end
	end
	check("clubhouse: the porte-cochere has its own hip roof", porteRoof)
	local planter = allNamed("RoundPlanter")[1]
	check("clubhouse: round planter on the forecourt in front of the porte-cochere", planter ~= nil and cap ~= nil and off(planter.Position, cap.Position):Dot(NW) >= 40,
		planter and tostring(planter.Position) or "missing")
end

------------------------------------------------------------------ HOTEL (Revision 2): Hotel & Suites wing, four storeys, red roofs
if run("hotel") then
	local hotel = site:FindFirstChild("Hotel")
	check("hotel: Hotel container is a direct child", hotel ~= nil and hotel:IsA("Model"))
	local wins = within(hotel, "HotelWindow")
	local levels, nLevels = {}, 0
	for _, w in ipairs(wins) do
		local k = math.floor(w.Position.Y / 4 + 0.5)
		if not levels[k] then
			levels[k] = true
			nLevels += 1
		end
	end
	check("hotel: at least 40 windows on at least 4 storeys", #wins >= 40 and nLevels >= 4, #wins .. " windows, " .. nLevels .. " levels")
	local walls = within(hotel, "HotelWall")
	check("hotel: walls are cream", #walls >= 2 and creamCount(walls) == 0, #walls .. " walls, " .. creamCount(walls) .. " off colour")
	local roofs, bad = hipRoofs(hotel)
	check("hotel: at least 2 hip red-tile roofs", #roofs >= 2 and bad == 0, #roofs .. " roofs, " .. bad .. " off colour")
	check("hotel: at least 8 balcony rail runs", #within(hotel, "HotelBalconyRail") >= 8, tostring(#within(hotel, "HotelBalconyRail")))
	local c = hotel and hotel:GetBoundingBox()
	local hi = -math.huge
	for _, p in ipairs(hotel and hotel:GetDescendants() or {}) do
		if p:IsA("BasePart") then hi = math.max(hi, topY(p)) end
	end
	check("hotel: stands right of and behind the clubhouse seen from the gate (x < 500, z > 820)", c ~= nil and c.X < 500 and c.Z > 820,
		c and tostring(c.Position) or "missing")
	check("hotel: roof top at least 40 above the ground (four storeys)", c ~= nil and hi - gnd(c.X, c.Z) >= 40, c and fmt(hi - gnd(c.X, c.Z)) or "missing")
end

------------------------------------------------------------------ CONTEXT: trees and backdrop (Revision 2 replaces the 16-pine count)
if run("context") then
	local trunks, tiers = allNamed("PineTrunk"), allNamed("PineTier")
	check("context: 6..16 Norfolk pines (the board's woods are broadleaf)", #trunks >= 6 and #trunks <= 16, tostring(#trunks))
	local short = 0
	for _, t in ipairs(trunks) do
		if extent(t, "Y") < 33 then short += 1 end
	end
	check("context: every pine trunk is at least 33 tall", #trunks > 0 and short == 0, short .. " short")
	-- Session 062 (owner: the stacked tiers look poor): the two tier pins are REPLACED in place (briefs/site08.md Revision 4).
	-- old: "context: each pine has 8 tiers" (#PineTier == #trunks * 8)
	local crowns = allNamed("PineCrown")
	check("context: each pine has a crown of 4 tiers (16 PineCrown corner wedges per trunk)", #trunks > 0 and #crowns == #trunks * 16,
		#crowns .. " crown wedges for " .. #trunks .. " trunks (" .. #tiers .. " old tiers)")
	-- old: "context: pine tiers are slender (widest <= 9.6)" (the tier cylinder's diameter); now the tier's width (2 x the wedge's half-width)
	local wide = 0
	for _, t in ipairs(crowns) do
		if 2 * math.max(t.Size.X, t.Size.Z) > 9.6 then wide += 1 end
	end
	check("context: pine crowns are slender (widest tier <= 9.6)", #crowns > 0 and wide == 0, tostring(wide))
	check("context: at least 30 broadleaf trees (the board's dense woods)", #allNamed("BroadleafTrunk") >= 30, tostring(#allNamed("BroadleafTrunk")))
	local mb = site:FindFirstChild("MountainBackdrop")
	local n = 0
	for _, d in ipairs(mb and mb:GetDescendants() or {}) do
		if d:IsA("BasePart") then n += 1 end
	end
	check("context: mountain backdrop of at least 20 parts", n >= 20, tostring(n))
end

------------------------------------------------------------------ 6: tall palms with long fronds (context group)
if run("context") then
	local fronds, trunks = allNamed("PalmFrond"), allNamed("PalmTrunk")
	local byPalm = {}
	for _, t in ipairs(trunks) do
		local key = string.format("%.0f,%.0f", t.Position.X, t.Position.Z)
		byPalm[key] = (byPalm[key] or 0) + extent(t, "Y")
	end
	local palms, short = 0, 0
	for _, h in pairs(byPalm) do palms += 1; if h < 17.5 then short += 1 end end
	check("palms are at least 17.5 tall", palms > 0 and short == 0, short .. " short of " .. palms)
	check("8 long fronds per palm", palms > 0 and #fronds == palms * 8, #fronds .. " fronds, " .. palms .. " palms")
	local small = 0
	for _, f in ipairs(fronds) do if math.max(f.Size.X, f.Size.Z) < 8.5 then small += 1 end end
	check("fronds are at least 8.5 long", #fronds > 0 and small == 0, tostring(small))
end

------------------------------------------------------------------ 7: text legibility
if run("general") then
	local bad = {}
	for _, g in ipairs(site:GetDescendants()) do
		if g:IsA("TextLabel") and not isRig(g) and not isKept(g) then
			local gui = g:FindFirstAncestorOfClass("SurfaceGui")
			local part = gui and gui.Parent
			if gui and part and part:IsA("BasePart") then
				local len = #g.Text
				if g.TextScaled and len > 14 then
					table.insert(bad, part.Name .. ": TextScaled on a " .. len .. "-char line")
				elseif not g.TextScaled and gui.SizingMode == Enum.SurfaceGuiSizingMode.PixelsPerStud then
					local face = gui.Face
					local wStuds, hStuds
					if face == Enum.NormalId.Back or face == Enum.NormalId.Front then wStuds, hStuds = part.Size.X, part.Size.Y
					elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then wStuds, hStuds = part.Size.Z, part.Size.Y
					else wStuds, hStuds = part.Size.X, part.Size.Z end
					local wPx, hPx = wStuds * gui.PixelsPerStud * g.Size.X.Scale, hStuds * gui.PixelsPerStud * g.Size.Y.Scale
					local textPx = len * g.TextSize * 0.6
					local lines = g.TextWrapped and math.ceil(textPx / math.max(wPx, 1)) or 1
					if (not g.TextWrapped and textPx > wPx) or lines * g.TextSize * 1.2 > hPx then
						table.insert(bad, string.format("%s: '%s' needs %.0fx%.0f px, has %.0fx%.0f", part.Name, g.Text, textPx, lines * g.TextSize * 1.2, wPx, hPx))
					end
				end
			end
		end
	end
	check("every label is fixed-size and fits its part (no long TextScaled line)", #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
end

------------------------------------------------------------------ Revision 3 helpers: plates lying on the slope
-- A plate is a thin Block (thin axis = its smallest size) or a Cylinder disc (thin axis = X). samplesOf returns its top-surface centre and four
-- points at 0.4 of its in-plane extent (inside a disc's radius); liftRange is min/max of (sample y - terrain y).
local function plateAxes(p)
	local cf, sz = p.CFrame, p.Size
	local axes = { { cf.RightVector, sz.X }, { cf.UpVector, sz.Y }, { cf.LookVector, sz.Z } }
	local thin = 1
	if not (p:IsA("Part") and p.Shape == Enum.PartType.Cylinder) then
		for i = 2, 3 do
			if axes[i][2] < axes[thin][2] then thin = i end
		end
	end
	local n = axes[thin][1]
	if n.Y < 0 then n = -n end
	local inPlane = {}
	for i = 1, 3 do
		if i ~= thin then table.insert(inPlane, axes[i]) end
	end
	return n, axes[thin][2], inPlane
end
local function samplesOf(p)
	local n, t, inPlane = plateAxes(p)
	local top = p.Position + n * (t / 2)
	local pts = { top }
	for _, a in ipairs(inPlane) do
		for _, s in ipairs({ -0.4, 0.4 }) do table.insert(pts, top + a[1] * (a[2] * s)) end
	end
	return pts
end
local function liftRange(p)
	local lo, hi = math.huge, -math.huge
	for _, q in ipairs(samplesOf(p)) do
		local h = q.Y - gnd(q.X, q.Z)
		lo, hi = math.min(lo, h), math.max(hi, h)
	end
	return lo, hi
end
local function flushBad(list, lo, hi)
	local bad = {}
	for _, p in ipairs(list) do
		local a, b = liftRange(p)
		if a < lo or b > hi then table.insert(bad, string.format("%s@(%.0f,%.0f) %.2f..%.2f", p.Name, p.Position.X, p.Position.Z, a, b)) end
	end
	return bad
end
-- Is the world point (x, z) on the plate's footprint? (Block: inside its in-plane rectangle; disc: inside its radius.)
local function onPlate(p, x, z)
	local _, _, inPlane = plateAxes(p)
	local d = Vector3.new(x - p.Position.X, 0, z - p.Position.Z)
	if p:IsA("Part") and p.Shape == Enum.PartType.Cylinder then
		return d.Magnitude <= inPlane[1][2] / 2
	end
	for _, a in ipairs(inPlane) do
		local flat = Vector3.new(a[1].X, 0, a[1].Z)
		if flat.Magnitude < 1e-3 then return false end
		if math.abs(d:Dot(flat.Unit)) > a[2] / 2 then return false end
	end
	return true
end
-- The corners of the solid: a box's 8; a WedgePart's 6 (its slope rises toward +Z, so the two top corners at -Z are empty box corners).
local function corners(p)
	local list, cf, h = {}, p.CFrame, p.Size / 2
	local wedge = p:IsA("WedgePart")
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				if not (wedge and sy == 1 and sz == -1) then
					table.insert(list, cf:PointToWorldSpace(Vector3.new(sx * h.X, sy * h.Y, sz * h.Z)))
				end
			end
		end
	end
	return list
end
local function partsOf(root)
	local list = {}
	for _, d in ipairs(root and root:GetDescendants() or {}) do
		if d:IsA("BasePart") then table.insert(list, d) end
	end
	return list
end
local function isBlue(p)
	local r, g, b = rgb(p)
	return b >= r + 60 and b >= g
end
-- The pinned walking lanes (sites_check site 8, briefs/site08.md): 4 wide.
local LANES = {
	{ { 450, 552 }, { 450, 700 }, { 524, 700 } },
	{ { 548, 708 }, { 592, 752 } },
	{ { 585, 753 }, { 537, 815 } },
	{ { 520, 722 }, { 436, 758 }, { 426, 788 } },
}
local function laneDist(x, z)
	local best = math.huge
	for _, lane in ipairs(LANES) do
		for i = 1, #lane - 1 do
			local ax, az, bx, bz = lane[i][1], lane[i][2], lane[i + 1][1], lane[i + 1][2]
			local dx, dz = bx - ax, bz - az
			local t = math.clamp(((x - ax) * dx + (z - az) * dz) / (dx * dx + dz * dz), 0, 1)
			best = math.min(best, math.sqrt((x - ax - t * dx) ^ 2 + (z - az - t * dz) ^ 2))
		end
	end
	return best
end
-- Minimum lane distance over a 5 x 5 grid on the plate's footprint (disc: the points inside it).
local function plateLaneDist(p)
	local n, t, inPlane = plateAxes(p)
	local top = p.Position + n * (t / 2)
	local disc = p:IsA("Part") and p.Shape == Enum.PartType.Cylinder
	local best = math.huge
	for i = -2, 2 do
		for j = -2, 2 do
			if not disc or (i * i + j * j) <= 4 then
				local q = top + inPlane[1][1] * (inPlane[1][2] * 0.25 * i) + inPlane[2][1] * (inPlane[2][2] * 0.25 * j)
				best = math.min(best, laneDist(q.X, q.Z))
			end
		end
	end
	return best
end

------------------------------------------------------------------ MOUNTAIN (Revision 3): the board's Mount Malarayat, a wedge ridge behind the clubhouse
if run("mountain") then
	local mb = site:FindFirstChild("MountainBackdrop")
	local parts = partsOf(mb)
	local round, wedges, solid = 0, 0, 0
	for _, p in ipairs(parts) do
		if p:IsA("Part") and p.Shape ~= Enum.PartType.Block then round += 1 end
		if p:IsA("WedgePart") or p:IsA("CornerWedgePart") then wedges += 1 end
		if p.CanCollide or p.CanQuery then solid += 1 end
	end
	check("mountain: no Cylinder or Ball parts (the stacked tank tiers are gone)", #parts > 0 and round == 0, round .. " round of " .. #parts)
	check("mountain: built from at least 100 wedges (a faceted ridge, Taal method)", wedges >= 100, tostring(wedges))
	check("mountain: every part is non-colliding and never blocks a query", #parts > 0 and solid == 0, tostring(solid))
	local top, topAt, out = -math.huge, nil, 0
	local uLo, uHi, aLo, aHi, front = math.huge, -math.huge, math.huge, -math.huge, 0
	local greenHit = false
	for _, p in ipairs(parts) do
		for _, c in ipairs(corners(p)) do
			if c.Y > top then top, topAt = c.Y, c end
			if c.X < 358 or c.X > 762 or c.Z < 558 or c.Z > 882 then out += 1 end
			if c.Y >= 70 then
				local u = (c.X - c.Z) * S
				uLo, uHi = math.min(uLo, u), math.max(uHi, u)
			end
			local a = math.deg(math.atan2(c.Z - 410, c.X - 360))
			aLo, aHi = math.min(aLo, a), math.max(aHi, a)
		end
		if p.Position.X + p.Position.Z < 1440 and p.Position.X < 730 and p.Position.Z < 864 then front += 1 end
		local lp = p.CFrame:PointToObjectSpace(Vector3.new(724, p.Position.Y, 620))
		if math.abs(lp.X) <= p.Size.X / 2 and math.abs(lp.Z) <= p.Size.Z / 2 and math.abs(lp.Y) <= p.Size.Y / 2 then greenHit = true end
	end
	check("mountain: the summit stands at least 115 high (about 80 above the plateau), east (x >= 690)", topAt ~= nil and top >= 115 and topAt.X >= 690,
		topAt and string.format("%.1f at (%.0f, %.0f)", top, topAt.X, topAt.Z) or "no parts")
	local peaks = within(mb, "BackdropPeak")
	check("mountain: exactly one BackdropPeak and it reaches the summit", #peaks == 1 and topY(peaks[1]) >= top - 1,
		#peaks .. " found" .. (peaks[1] and (", top " .. fmt(topY(peaks[1]))) or ""))
	check("mountain: a broad ridge, above y 70 over at least 120 studs along the ridge line", uHi - uLo >= 120, fmt(uHi - uLo))
	check("mountain: spans at least 40 degrees of the board-view camera (360, 410)", aHi - aLo >= 40, fmt(aHi - aLo))
	local bearing = function(x, z) return math.deg(math.atan2(z - 600, x - 450)) end
	check("mountain: the summit is behind the clubhouse seen from the gate (bearing within 15 degrees)",
		topAt ~= nil and math.abs(bearing(topAt.X, topAt.Z) - bearing(620, 780)) <= 15, topAt and fmt(bearing(topAt.X, topAt.Z) - bearing(620, 780)) or "none")
	check("mountain: nothing stands in front of the clubhouse rear (centres x + z >= 1440, or the east arm x >= 730, or the back strip z >= 864)",
		#parts > 0 and front == 0, tostring(front))
	check("mountain: every corner inside the slot (x 360..760, z 560..880, 2 studs slack)", #parts > 0 and out == 0, tostring(out))
	check("mountain: hole 2's green at (724, 620) is not buried", not greenHit)
end

------------------------------------------------------------------ COURSE (Revision 3): fairways, greens with flags, bunkers, ponds on the slope
if run("course") then
	local fair, greens, bunkers = allNamed("Fairway"), allNamed("PuttingGreen"), allNamed("Bunker")
	local fairBlocks, area, pale = 0, 0, 0
	for _, f in ipairs(fair) do
		local r, g, b = rgb(f)
		if g < 150 or g - r < 40 or g - b < 60 then pale += 1 end
		if not (f:IsA("Part") and f.Shape == Enum.PartType.Cylinder) then
			fairBlocks += 1
			local _, _, inPlane = plateAxes(f)
			area += inPlane[1][2] * inPlane[2][2]
		end
	end
	check("course: at least 5 fairways (Fairway blocks), lighter green than the grass", fairBlocks >= 5 and pale == 0, fairBlocks .. " fairways, " .. pale .. " off colour")
	check("course: fairway blocks cover at least 7000 square studs", area >= 7000, fmt(area))
	local bad = flushBad(fair, 0.6, 1.6)
	check("course: fairways lie on the slope (top 0.6..1.6 above the terrain)", #fair > 0 and #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	local flags = allNamed("GreenFlag")
	local noFlag = 0
	for _, g in ipairs(greens) do
		local ok = false
		for _, f in ipairs(flags) do
			if off(f.Position, g.Position).Magnitude <= 6 then ok = true end
		end
		if not ok then noFlag += 1 end
	end
	check("course: at least 5 putting greens, each with a GreenFlag on it", #greens >= 5 and noFlag == 0, #greens .. " greens, " .. noFlag .. " without a flag")
	bad = flushBad(greens, 0.6, 1.8)
	check("course: greens lie on the slope (top 0.6..1.8 above the terrain)", #greens > 0 and #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	local dull = 0
	for _, b in ipairs(bunkers) do
		local r, g, bl = rgb(b)
		if r < 200 or bl > 190 or r - bl < 30 then dull += 1 end
	end
	check("course: at least 10 sand bunkers, sand coloured", #bunkers >= 10 and dull == 0, #bunkers .. " bunkers, " .. dull .. " off colour")
	bad = flushBad(bunkers, 0.6, 1.8)
	check("course: bunkers lie on the slope (top 0.6..1.8 above the terrain)", #bunkers > 0 and #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	local ponds, okPonds, left, nearHotel = {}, 0, 0, 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("Model") and d.Name == "CoursePond" then table.insert(ponds, d) end
	end
	local hotel = site:FindFirstChild("Hotel")
	local hc = hotel and hotel:GetBoundingBox().Position
	local pondBad = {}
	for _, pd in ipairs(ponds) do
		local water, stones = within(pd, "PondWater"), within(pd, "PondStone")
		local good = #water >= 1 and #stones >= 4
		for _, w in ipairs(water) do
			if w.CanCollide or w.Transparency < 0.1 or w.Transparency > 0.6 or not isBlue(w) then good = false end
		end
		for _, b in ipairs(flushBad(water, 0.6, 1.8)) do table.insert(pondBad, b) end
		if good then okPonds += 1 end
		local c = pd:GetBoundingBox().Position
		if c.X > 480 then left += 1 end
		if hc and off(c, hc).Magnitude <= 80 then nearHotel += 1 end
	end
	check("course: at least 4 CoursePond models of blue translucent non-colliding PondWater with 4+ PondStone each", okPonds >= 4,
		okPonds .. " good of " .. #ponds)
	check("course: pond water lies flush on the slope (top 0.6..1.8 above the terrain)", #ponds > 0 and #pondBad == 0,
		#pondBad .. " bad: " .. table.concat(pondBad, "; ", 1, math.min(#pondBad, 4)))
	check("course: ponds on the board's left half (x > 480: 2+) and by the hotel (within 80: 1+)", left >= 2 and nearHotel >= 1,
		left .. " left, " .. nearHotel .. " by the hotel")
	local inLane = {}
	for _, list in ipairs({ fair, greens, bunkers }) do
		for _, p in ipairs(list) do
			if p.CanCollide and plateLaneDist(p) < 3 then table.insert(inLane, string.format("%s@(%.0f,%.0f)", p.Name, p.Position.X, p.Position.Z)) end
		end
	end
	check("course: no colliding course plate within 3 studs of a walking lane", #inLane == 0, table.concat(inLane, "; ", 1, math.min(#inLane, 4)))
end

------------------------------------------------------------------ PLANTING (Revision 3): the board's dense tropical planting
if run("planting") then
	local broad = allNamed("BroadleafTrunk")
	local pines = allNamed("PineTrunk")
	local palmAt = {}
	for _, t in ipairs(allNamed("PalmTrunk")) do
		palmAt[string.format("%.0f,%.0f", t.Position.X, t.Position.Z)] = t.Position
	end
	local palms = {}
	for _, p in pairs(palmAt) do table.insert(palms, p) end
	check("planting: at least 180 broadleaf trees", #broad >= 180, tostring(#broad))
	check("planting: at least 30 palms", #palms >= 30, tostring(#palms))
	local trunks = {}
	for _, t in ipairs(broad) do table.insert(trunks, t.Position) end
	for _, t in ipairs(pines) do table.insert(trunks, t.Position) end
	for _, p in ipairs(palms) do table.insert(trunks, p) end
	check("planting: at least 230 trees in all (broadleaf, palms, pines)", #trunks >= 230, tostring(#trunks))
	local drive = 0
	for _, p in ipairs(palms) do
		if math.abs(p.X - 450) <= 12 and p.Z >= 616 and p.Z <= 700 then drive += 1 end
	end
	check("planting: at least 10 palms line the drive (within 12 of x 450, z 616..700)", drive >= 10, tostring(drive))
	local rim = 0
	for _, p in ipairs(trunks) do
		if math.min(p.X - 360, 760 - p.X, p.Z - 560, 880 - p.Z) <= 24 then rim += 1 end
	end
	check("planting: a perimeter belt of at least 40 trees within 24 of the slot edge", rim >= 40, tostring(rim))
	local plates = {}
	for _, nm in ipairs({ "Fairway", "PuttingGreen", "Bunker", "PondWater" }) do
		for _, p in ipairs(allNamed(nm)) do table.insert(plates, p) end
	end
	local onCourse = {}
	for _, t in ipairs(trunks) do
		for _, p in ipairs(plates) do
			if onPlate(p, t.X, t.Z) then
				table.insert(onCourse, string.format("(%.0f,%.0f) on %s", t.X, t.Z, p.Name))
				break
			end
		end
	end
	check("planting: no tree stands on a fairway, green, bunker or pond", #plates > 0 and #onCourse == 0,
		#onCourse .. ": " .. table.concat(onCourse, "; ", 1, math.min(#onCourse, 4)))
end

------------------------------------------------------------------ ENTRANCE lagoons (Revision 3): water lying flush in a stone edge
if run("entrance") then
	local ent = site:FindFirstChild("Entrance")
	local water = within(ent, "LagoonWater")
	local bad = flushBad(water, 0.6, 1.6)
	check("entrance: lagoon water lies flush on the slope (top 0.6..1.6 above the terrain, not a raised slab)", #water > 0 and #bad == 0,
		#bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	local grey = 0
	for _, w in ipairs(water) do
		if not isBlue(w) then grey += 1 end
	end
	check("entrance: lagoon water is blue", #water > 0 and grey == 0, tostring(grey))
	local edges = within(ent, "LagoonEdge")
	local e, w = 0, 0
	for _, p in ipairs(edges) do
		if p.Position.X > 456 then e += 1 elseif p.Position.X < 444 then w += 1 end
	end
	check("entrance: each lagoon has a stone edge (8+ LagoonEdge parts east and west)", e >= 8 and w >= 8, e .. " east, " .. w .. " west")
end

------------------------------------------------------------------ GROUND (polish, 2026-10-31): no Grass blades through water, sand, paving or floors
-- Terrain Grass draws blades about 0.9 above its surface, so they poke through clear water and thin plates. builders/site08_ground.luau
-- repaints the terrain under these parts (1 voxel pad). Samples: the footprint centre and four points at 0.4 of its horizontal extent.
if run("ground") then
	local tp = RaycastParams.new()
	tp.FilterType = Enum.RaycastFilterType.Include
	tp.FilterDescendantsInstances = { workspace.Terrain }
	local function matAt(x, z)
		local r = workspace:Raycast(Vector3.new(x, 300, z), Vector3.new(0, -600, 0), tp)
		return r and r.Material or nil
	end
	local function footSamples(p)
		local cf, sz = p.CFrame, p.Size
		local axes = { { cf.RightVector, sz.X }, { cf.UpVector, sz.Y }, { cf.LookVector, sz.Z } }
		local up = 1
		for i = 2, 3 do
			if math.abs(axes[i][1].Y) > math.abs(axes[up][1].Y) then up = i end
		end
		local pts = { p.Position }
		for i = 1, 3 do
			if i ~= up then
				for _, s in ipairs({ -0.4, 0.4 }) do table.insert(pts, p.Position + axes[i][1] * (axes[i][2] * s)) end
			end
		end
		return pts
	end
	local function sampleBad(names, want)
		local n, bad, list = 0, 0, {}
		for _, nm in ipairs(names) do
			for _, p in ipairs(allNamed(nm)) do
				for _, q in ipairs(footSamples(p)) do
					-- Within 4 of the slot edge the surface blends with the voxel outside the slot (the road verge, not repainted): skipped.
					-- Logged in briefs/site08.md Revision 4: the verge is outside the plot; the water parts are pinned without this skip below.
					if math.min(q.X - 360, 760 - q.X, q.Z - 560, 880 - q.Z) < 4 then continue end
					n += 1
					local m = matAt(q.X, q.Z)
					local okM = m ~= nil and (want and m == want or (not want and m ~= Enum.Material.Grass))
					if not okM then
						bad += 1
						if #list < 4 then table.insert(list, string.format("%s@(%.0f,%.0f)=%s", nm, q.X, q.Z, m and m.Name or "nil")) end
					end
				end
			end
		end
		return n, bad, list
	end
	local n, bad, list = sampleBad({ "LagoonWater", "PondWater", "PoolWater", "PoolWaterLobe", "HotelPoolWater" })
	check("ground: no Grass under any water part (lagoons, ponds, pools; 20+ samples)", n >= 20 and bad == 0,
		bad .. " of " .. n .. ": " .. table.concat(list, "; "))
	n, bad, list = sampleBad({ "Bunker" }, Enum.Material.Sand)
	check("ground: Sand under every bunker (10+ bunkers, 50+ samples)", n >= 50 and bad == 0, bad .. " of " .. n .. ": " .. table.concat(list, "; "))
	n, bad, list = sampleBad({ "EntrancePaving", "ForecourtKerb", "ForecourtPlate", "GatehousePlinth", "PoolDeck", "HotelPoolDeck", "HotelPodium",
		"Plinth", "LoggiaFloor", "EntryFloor" })
	check("ground: no Grass under paving, decks, plinths and floors (40+ samples)", n >= 40 and bad == 0, bad .. " of " .. n .. ": " .. table.concat(list, "; "))
	n, bad, list = sampleBad({ "MonumentBase", "LagoonEdge" })
	check("ground: no Grass under the rock sign base and the lagoon stone edges", n >= 20 and bad == 0, bad .. " of " .. n .. ": " .. table.concat(list, "; "))
	local lawn = matAt(600, 600)
	check("ground: the open lawn at (600, 600) is still Grass (control)", lawn == Enum.Material.Grass, lawn and lawn.Name or "nil")
	-- Session 062: blades still showed through the lagoon water along the slot edge (the 0.4-extent samples above never reach a footprint's
	-- edge, and the edge skip hid the strip). Dense grid: every 1 stud over each water footprint padded 1 stud, no edge skip.
	local WATER = { LagoonWater = true, PondWater = true, PoolWater = true, PoolWaterLobe = true, HotelPoolWater = true }
	local wn, wbad, wlist = 0, 0, {}
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA("BasePart") and WATER[p.Name] and not isRig(p) then
			local cf, sz = p.CFrame, p.Size
			local axes = { { cf.RightVector, sz.X }, { cf.UpVector, sz.Y }, { cf.LookVector, sz.Z } }
			local up = 1
			for i = 2, 3 do
				if math.abs(axes[i][1].Y) > math.abs(axes[up][1].Y) then up = i end
			end
			local ip = {}
			for i = 1, 3 do
				if i ~= up then
					local f = Vector3.new(axes[i][1].X, 0, axes[i][1].Z)
					table.insert(ip, { f.Unit, axes[i][2] * f.Magnitude })
				end
			end
			local disc = p:IsA("Part") and p.Shape == Enum.PartType.Cylinder and up == 1
			local c = p.Position
			local R = disc and math.max(ip[1][2], ip[2][2]) / 2 + 1 or (ip[1][2] + ip[2][2]) / 2 + 1
			local b = 0
			for x = math.floor(c.X - R), math.ceil(c.X + R) do
				for z = math.floor(c.Z - R), math.ceil(c.Z + R) do
					local d = Vector3.new(x - c.X, 0, z - c.Z)
					local inside
					if disc then
						inside = d.Magnitude <= math.max(ip[1][2], ip[2][2]) / 2 + 1
					else
						inside = math.abs(d:Dot(ip[1][1])) <= ip[1][2] / 2 + 1 and math.abs(d:Dot(ip[2][1])) <= ip[2][2] / 2 + 1
					end
					if inside then
						wn += 1
						if matAt(x, z) == Enum.Material.Grass then b += 1 end
					end
				end
			end
			wbad += b
			if b > 0 and #wlist < 6 then table.insert(wlist, string.format("%s@(%.0f,%.0f) %d", p.Name, c.X, c.Z, b)) end
		end
	end
	check("ground: no Grass under or within 1 stud of any water part (1-stud grid, no edge skip; 3000+ samples)", wn >= 3000 and wbad == 0,
		wbad .. " of " .. wn .. ": " .. table.concat(wlist, "; "))
end

------------------------------------------------------------------ PINES (session 062): tapered conifers, not stacked discs
-- Each pine: a trunk and 4 crown tiers, each a square pyramid of 4 CornerWedgeParts (PineCrown), narrowing upward, overlapping into one cone.
if run("pines") then
	local trunks, crowns = allNamed("PineTrunk"), allNamed("PineCrown")
	local notWedge = 0
	for _, c in ipairs(crowns) do
		if not c:IsA("CornerWedgePart") then notWedge += 1 end
	end
	check("pines: no stacked cylinder tiers remain and every crown piece is a CornerWedgePart", #allNamed("PineTier") == 0 and #crowns > 0 and notWedge == 0,
		#allNamed("PineTier") .. " PineTier, " .. #crowns .. " PineCrown, " .. notWedge .. " not wedges")
	local per, orphan = {}, 0
	for _, t in ipairs(trunks) do per[t] = {} end
	for _, c in ipairs(crowns) do
		local best, bd = nil, 6
		for _, t in ipairs(trunks) do
			local d = off(c.Position, t.Position).Magnitude
			if d < bd then best, bd = t, d end
		end
		if best then table.insert(per[best], c) else orphan += 1 end
	end
	local badTaper, badCone, badShape, badCollide = {}, {}, {}, 0
	for t, list in pairs(per) do
		local tiers = {}
		for _, c in ipairs(list) do
			local base = c.Position.Y - c.Size.Y / 2
			local key = string.format("%.1f", base)
			tiers[key] = tiers[key] or { base = base, top = base + c.Size.Y, w = 2 * math.max(c.Size.X, c.Size.Z), n = 0 }
			tiers[key].n += 1
			if c.CanCollide then badCollide += 1 end
		end
		local arr = {}
		for _, v in pairs(tiers) do table.insert(arr, v) end
		table.sort(arr, function(a, b) return a.base < b.base end)
		local where = string.format("(%.0f,%.0f)", t.Position.X, t.Position.Z)
		local ok = #arr == 4
		for i, v in ipairs(arr) do
			if v.n ~= 4 then ok = false end
			if i > 1 and not (v.w < arr[i - 1].w - 0.5) then ok = false end
		end
		if not ok then table.insert(badTaper, where .. " " .. #arr .. " tiers") end
		local g = t.Position.Y - extent(t, "Y") / 2
		local tTop = t.Position.Y + extent(t, "Y") / 2
		if #arr >= 1 then
			local cone = arr[1].base - g >= 4 and arr[#arr].top >= tTop
			for i = 2, #arr do
				if arr[i].base >= arr[i - 1].top then cone = false end
			end
			if not cone then table.insert(badCone, where) end
			if arr[#arr].top - arr[1].base < 2.5 * arr[1].w then table.insert(badShape, where) end
		else
			table.insert(badCone, where .. " no crown")
			table.insert(badShape, where .. " no crown")
		end
		if not t.CanCollide then badCollide += 1 end
	end
	check("pines: every crown is 4 tiers of 4 wedges, each tier at least 0.5 narrower than the one below (tapered)", #trunks > 0 and #badTaper == 0 and orphan == 0,
		#badTaper .. " bad, " .. orphan .. " orphan wedges: " .. table.concat(badTaper, "; ", 1, math.min(#badTaper, 4)))
	check("pines: the tiers overlap into one cone, the crown starts 4+ above the ground and its tip covers the trunk top", #trunks > 0 and #badCone == 0,
		table.concat(badCone, "; "))
	check("pines: conifer silhouette (crown height at least 2.5 x the bottom tier width)", #trunks > 0 and #badShape == 0, table.concat(badShape, "; "))
	check("pines: foliage is non-colliding, trunks collide", #trunks > 0 and badCollide == 0, tostring(badCollide))
end

------------------------------------------------------------------ SIGN (session 062): both lines of the rock sign read from the approach
-- Targets: a grid on the glyph block of each TextLabel (TextService width, TextSize tall), on the sign face. Every ray from each approach eye
-- must reach MonumentSign first (nothing filtered: rocks, boulders, shrubs, water all count as blocking). Eyes: the pinned road eye at the
-- foot of the drive (sites_check), a standing eye south-west of the lagoon and one straight in front of the sign (outside the slot, the verge).
if run("sign") then
	local TS = game:GetService("TextService")
	local sign = site:FindFirstChild("MonumentSign", true)
	local gui = sign and sign:FindFirstChildOfClass("SurfaceGui")
	local lines = {}
	if gui and gui.Face == Enum.NormalId.Front then
		local ppsd = gui.PixelsPerStud
		local top = sign.Position.Y + sign.Size.Y / 2
		local face = sign.Position.Z - sign.Size.Z / 2
		for _, l in ipairs(gui:GetChildren()) do
			if l:IsA("TextLabel") then
				local px = TS:GetTextSize(l.Text, l.TextSize, l.Font, Vector2.new(1e4, 1e4))
				local cy = top - (l.Position.Y.Scale + l.Size.Y.Scale / 2) * sign.Size.Y
				local cx = sign.Position.X - sign.Size.X / 2 + (l.Position.X.Scale + l.Size.X.Scale / 2) * sign.Size.X
				local w, h = px.X / ppsd, l.TextSize / ppsd
				local pts = {}
				for i = 0, 6 do
					for _, fy in ipairs({ -0.3, 0, 0.3 }) do
						table.insert(pts, Vector3.new(cx - 0.45 * w + i * 0.15 * w, cy + fy * h, face + 0.05))
					end
				end
				table.insert(lines, { text = l.Text, pts = pts })
			end
		end
	end
	local EYES = { { "road eye", Vector3.new(450, 14.5, 556) }, { "south-west eye", Vector3.new(490, 18.3, 552) }, { "front eye", Vector3.new(532, 22.5, 552) } }
	for _, want in ipairs({ "MOUNT MALARAYAT", "GOLF AND COUNTRY CLUB" }) do
		local line
		for _, L in ipairs(lines) do
			if L.text == want then line = L end
		end
		local hits, total, blockers = 0, 0, {}
		for _, e in ipairs(EYES) do
			local eh = 0
			for _, q in ipairs(line and line.pts or {}) do
				total += 1
				local r = workspace:Raycast(e[2], (q - e[2]) * 1.02)
				if r and r.Instance == sign then
					hits += 1
					eh += 1
				elseif r then
					blockers[r.Instance.Name] = true
				end
			end
			if line then table.insert(blockers, e[1] .. " " .. eh .. "/" .. #line.pts) end
		end
		local names = {}
		for k, v in pairs(blockers) do table.insert(names, type(k) == "string" and k or v) end
		check("sign: every ray from 3 approach eyes reaches the sign on " .. want .. " (63 rays)", line ~= nil and total == 63 and hits == total,
			hits .. "/" .. total .. ": " .. table.concat(names, ", "))
	end
	local tall = {}
	for _, nm in ipairs({ "MonumentRock", "LagoonBoulder", "Shrub" }) do
		for _, p in ipairs(allNamed(nm)) do
			local top = p.Position.Y + extent(p, "Y") / 2
			if sign and p.Position.X > 518 and p.Position.X < 546 and p.Position.Z < sign.Position.Z - sign.Size.Z / 2 and p.Position.Z > 576
				and top > sign.Position.Y - sign.Size.Y / 2 then
				table.insert(tall, string.format("%s@(%.0f,%.0f) top %.1f", nm, p.Position.X, p.Position.Z, top))
			end
		end
	end
	check("sign: no rock, boulder or shrub in front of the lettering (x 518..546) rises above the sign's bottom edge", sign ~= nil and #tall == 0,
		#tall .. ": " .. table.concat(tall, "; ", 1, math.min(#tall, 4)))
end

------------------------------------------------------------------ Part budget
if run("general") then
	local all = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") then all += 1 end
	end
	-- Revision 3: the owner asked for about 1900..2300 parts (course, woods, mountain); BuildCheck's cap is 2500.
	check("whole site (kept included) is 1900..2500 parts", all >= 1900 and all <= 2500, tostring(all))
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	-- Revision 2: the board rebuild adds the entrance and the hotel; BuildCheck caps the whole site at 2500. The CSG arcades are one part per bay,
	-- so the floor written before the build (1400) was corrected to 900 after it (logged in briefs/site08.md Revision 2).
	check("non-rig, non-kept part count is 900..2450", n >= 900 and n <= 2450, tostring(n))
end

return HttpService:JSONEncode(results)
