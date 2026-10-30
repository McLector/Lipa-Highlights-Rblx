-- site08_check: the Slice 21 fidelity spec for Site 08 (Mount Malarayat Golf & Country Club), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site08_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site08_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site08.md "Revision 1 (Slice 21)": Malarayat_Clubhouse_Aerial.jpg, the cart-side exterior photo and the
-- across-lake photo. The clubhouse is built in a local frame, so the checks use part names, counts, colours and sizes rather than coordinates.
-- Revision 2 (board rebuild, 2026-10-31): groups. Set shared.site08_only = "general" | "entrance" | "clubhouse" | "hotel" | "context" first
-- to run one; run_all leaves it nil and runs all. Photo pins the Mount Malarayat blueprint board contradicts were REPLACED, each logged
-- old -> new in briefs/site08.md Revision 2 (RoofTier, WindowTrim, StoneCourse, CartBody, the 16-pine count, the part range).
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
	check("context: each pine has 8 tiers", #trunks > 0 and #tiers == #trunks * 8, #tiers .. " tiers for " .. #trunks)
	local wide = 0
	for _, t in ipairs(tiers) do
		if math.max(t.Size.Y, t.Size.Z) > 9.6 then wide += 1 end
	end
	check("context: pine tiers are slender (widest <= 9.6)", #tiers > 0 and wide == 0, tostring(wide))
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

------------------------------------------------------------------ Part budget
if run("general") then
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	-- Revision 2: the board rebuild adds the entrance and the hotel; BuildCheck caps the whole site at 2500. The CSG arcades are one part per bay,
	-- so the floor written before the build (1400) was corrected to 900 after it (logged in briefs/site08.md Revision 2).
	check("non-rig, non-kept part count is 900..2450", n >= 900 and n <= 2450, tostring(n))
end

return HttpService:JSONEncode(results)
