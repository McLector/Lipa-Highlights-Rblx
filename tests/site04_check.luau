-- site04_check: the Slice 19 fidelity spec for Site 04 (Cafe de Lipa, Tibig/STAR branch), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site04_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site04_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site04.md "Revision 1 (Slice 19)": the one Tibig/STAR night photo is the only geometry source
-- (Commons has no Cafe de Lipa file, searched 2026-10-22). The builder works in the original Slice 08 coordinates (centre 160, -160);
-- Slice 14 moved the site to (272, -160), so every WORLD x below is the brief's x + 112. Frontage is west (-X).
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(272, 0, -160)

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site04_Cafe")
check("Site04_Cafe exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
-- A stray drag in Studio once moved a whole site; test the pivot first.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (272, 0, -160), facing W",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(-1, 0, 0)) > 0.999,
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
local function extent(d, axis)
	local cf, sz = d.CFrame, d.Size
	return (math.abs(cf.RightVector[axis]) * sz.X + math.abs(cf.UpVector[axis]) * sz.Y + math.abs(cf.LookVector[axis]) * sz.Z)
end
local function lo(d, axis) return d.Position[axis] - extent(d, axis) / 2 end
local function hi(d, axis) return d.Position[axis] + extent(d, axis) / 2 end
local function span(list, axis)
	local a, b = math.huge, -math.huge
	for _, d in ipairs(list) do a = math.min(a, lo(d, axis)); b = math.max(b, hi(d, axis)) end
	return a, b
end
local function fmt(v) return v and string.format("%.2f", v) or "nil" end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end

------------------------------------------------------------------ Kept objects and required props
local KEPT = { Guide = true, InfoPanel = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end
do
	for _, name in ipairs({ "Guide", "InfoPanel", "CoffeeBar", "BarakoBeans", "CoffeePacks", "BrewingSet", "Tables", "Pendants", "Staff" }) do
		check("present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	local staff = site:FindFirstChild("Staff")
	check("2 staff rigs", staff ~= nil and #staff:GetChildren() == 2)
	check("BarTop and RepresentativeSign anchors exist", anchor("BarTop") ~= nil and anchor("RepresentativeSign") ~= nil)

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { site }
	local function blockers(cf, size)
		local bad = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(cf, size, params)) do
			if not isKept(p) and not isRig(p) and p.Position.Y + p.Size.Y / 2 > 0.6 then table.insert(bad, p.Name) end
		end
		return bad
	end
	local g = blockers(CFrame.new(242, 7, -160), Vector3.new(24, 14, 24))
	check("Guide keep-clear box (x 230..254, z -172..-148) is free", #g == 0, #g .. ": " .. table.concat(g, ", ", 1, math.min(#g, 5)))
	local ip = blockers(CFrame.new(242, 6, -148), Vector3.new(12, 12, 12))
	check("InfoPanel front zone (x 236..248, z -154..-142) is free", #ip == 0, #ip .. ": " .. table.concat(ip, ", ", 1, math.min(#ip, 5)))
	local lp = OverlapParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { site }
	lp.RespectCanCollide = true
	local lane = {}
	for _, h in ipairs(workspace:GetPartBoundsInBox(CFrame.new(276.5, 5, -160), Vector3.new(41, 6, 4), lp)) do
		if not isRig(h) then table.insert(lane, h.Name) end
	end
	check("walking lane into the cafe is free", #lane == 0, #lane .. ": " .. table.concat(lane, ", ", 1, math.min(#lane, 5)))
end

------------------------------------------------------------------ 1: the sign, a legible bold 5 x 9 pixel lowercase "cafedelipa"
do
	local letters = allNamed("NeonLetter")
	check("sign has >= 60 neon blocks (a 5-column font; the 3-column one gave 47)", #letters >= 60, tostring(#letters))
	local z0, z1 = span(letters, "Z")
	check("sign is 38..48 studs wide", #letters > 0 and z1 - z0 >= 38 and z1 - z0 <= 48, fmt(z1 - z0))
	check("sign is centred on the band (centre z -158 +- 3)", #letters > 0 and math.abs((z0 + z1) / 2 + 158) <= 3, fmt((z0 + z1) / 2))
	local y0, y1 = span(letters, "Y")
	check("sign is 6..7.5 tall including the p descender", #letters > 0 and y1 - y0 >= 6 and y1 - y0 <= 7.5, fmt(y1 - y0))
	local _, xmax = span(letters, "X")
	check("letters stand in front of the band (x <= 256.1)", #letters > 0 and xmax <= 256.1, fmt(xmax))
	-- ten glyph windows of 6 pixels (5 wide + 1 gap); every window holds letter blocks and none straddles a gap column
	local pitch = 0.75
	local start = z0
	local empty, straddle = {}, {}
	for k = 0, 9 do
		local a, b = start + k * 6 * pitch, start + k * 6 * pitch + 5 * pitch
		local n = 0
		for _, p in ipairs(letters) do
			local pa, pb = lo(p, "Z"), hi(p, "Z")
			if pb > a + 0.01 and pa < b - 0.01 then n += 1 end
			if pa < b - 0.01 and pb > b + 0.01 and pa >= a - 0.01 then table.insert(straddle, tostring(k)) end
		end
		if n == 0 then table.insert(empty, tostring(k)) end
	end
	check("all 10 glyph windows hold letter blocks", #letters > 0 and #empty == 0, "empty windows: " .. table.concat(empty, ","))
	check("no block spills into the gap between letters", #letters > 0 and #straddle == 0, "straddling in window " .. table.concat(straddle, ",", 1, math.min(#straddle, 5)))
	local base, top = math.huge, -math.huge
	for _, p in ipairs(letters) do base = math.min(base, lo(p, "Y")); top = math.max(top, hi(p, "Y")) end
	local below = 0
	for _, p in ipairs(letters) do if hi(p, "Y") < y0 + 2.0 then below += 1 end end
	check("the p has a descender (blocks in the bottom 2 studs)", below >= 1, tostring(below))
end

------------------------------------------------------------------ 2: the sign band hides the roof edge (no white line under the dark fascia)
do
	local band = anchor("ArcadeSignBand")
	check("ArcadeSignBand exists", band ~= nil)
	if band then
		check("band reaches down to the roof slab (bottom y <= 13.05)", lo(band, "Y") <= 13.05, fmt(lo(band, "Y")))
		check("band is 8..10 tall", extent(band, "Y") >= 8 and extent(band, "Y") <= 10, fmt(extent(band, "Y")))
	end
end

------------------------------------------------------------------ 3: open arcade with three slim piers
do
	local cols = allNamed("ArcadeColumn")
	check("arcade has 3 columns", #cols == 3, tostring(#cols))
	local inLane = 0
	for _, c in ipairs(cols) do if hi(c, "Z") > -164 and lo(c, "Z") < -156 then inLane += 1 end end
	check("no column stands in the lane", inLane == 0, tostring(inLane))
end

------------------------------------------------------------------ 4: pale neighbour wall with two cool spotlights
do
	local bay = anchor("NeighbourBay")
	check("NeighbourBay exists", bay ~= nil)
	if bay then
		local r, g, b = rgb(bay)
		check("neighbour wall is pale blue-grey (r 185..215, b >= r)", r >= 185 and r <= 215 and b >= r, string.format("%.0f,%.0f,%.0f", r, g, b))
	end
	local spots = allNamed("NeighbourSpot")
	check("2 neon spotlights on the neighbour wall", #spots == 2, tostring(#spots))
	local neon = 0
	for _, s in ipairs(spots) do if s.Material == Enum.Material.Neon then neon += 1 end end
	check("the spotlights are neon", #spots > 0 and neon == #spots, neon .. "/" .. #spots)
end

------------------------------------------------------------------ 5: slat-back chairs
do
	local seats, slats, solid = #allNamed("ChairSeat"), #allNamed("ChairSlat"), #allNamed("ChairBack")
	check("every chair has 3 slats", seats > 0 and slats == seats * 3, seats .. " seats, " .. slats .. " slats")
	check("no solid chair backs remain", solid == 0, tostring(solid))
end

------------------------------------------------------------------ 6-7: floor grout and plank-front bar
do
	local grout = allNamed("TileGrout")
	check("terrace has >= 30 grout lines", #grout >= 30, tostring(#grout))
	local out = 0
	for _, p in ipairs(grout) do
		if lo(p, "X") < 255.9 or hi(p, "X") > 276.1 or lo(p, "Z") < -188.1 or hi(p, "Z") > -127.9 or hi(p, "Y") > 0.4 then out += 1 end
	end
	check("grout stays on the terrace slab (x 256..276, z -188..-128) and is thin", out == 0, tostring(out) .. " outside")
	local planks = allNamed("BarPlank")
	check("bar front has >= 10 plank strips", #planks >= 10, tostring(#planks))
end

------------------------------------------------------------------ 8: text legibility
do
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

------------------------------------------------------------------ Light-tier polish (scratch/light_tier_plan.md Part B): no z-fighting faces, staff on the floor
do
	-- C1: the charcoal band and the white roof shared the west face, the underside and both end faces (flicker on the band's edge).
	local band, roof = anchor("ArcadeSignBand"), anchor("ArcadeRoof")
	local proud = {}
	if band and roof then
		proud = {
			west = lo(roof, "X") - lo(band, "X"), under = lo(roof, "Y") - lo(band, "Y"),
			north = lo(roof, "Z") - lo(band, "Z"), south = hi(band, "Z") - hi(roof, "Z"),
		}
	end
	local flat = {}
	for k, v in pairs(proud) do
		if v < 0.02 or v > 0.2 then table.insert(flat, k .. " " .. fmt(v)) end
	end
	check("ArcadeSignBand stands 0.02..0.2 proud of ArcadeRoof's west face, underside and both ends (no shared face plane)",
		band ~= nil and roof ~= nil and #flat == 0, table.concat(flat, ", "))

	-- C2: the round table base discs sat at y 0..0.2, their tops coplanar with the floor top (0.2).
	local bases = allNamed("TableBase")
	local low = {}
	for _, b in ipairs(bases) do
		if hi(b, "Y") < 0.3 or hi(b, "Y") > 0.5 then table.insert(low, fmt(hi(b, "Y"))) end
	end
	check("4 TableBase discs, every top 0.1..0.3 above the floor top (y 0.3..0.5)", #bases == 4 and #low == 0,
		#bases .. " bases, bad tops: " .. table.concat(low, ", "))

	-- C3: the staff rigs were set on the terrain (y 0) + 3, so their feet sank about 0.4 into the 0.2 floor.
	local staff = site:FindFirstChild("Staff")
	local guide = site:FindFirstChild("Guide")
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = { staff, guide }
	local off = {}
	local rigs = staff and staff:GetChildren() or {}
	for _, rig in ipairs(rigs) do
		local hrp = rig:FindFirstChild("HumanoidRootPart")
		local m = math.huge
		for _, p in ipairs(rig:GetChildren()) do
			if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then m = math.min(m, lo(p, "Y")) end
		end
		local hit = hrp and workspace:Raycast(hrp.Position, Vector3.new(0, -20, 0), rp)
		if not hit or math.abs(m - hit.Position.Y) > 0.05 then
			table.insert(off, string.format("%s feet %s floor %s", rig.Name, fmt(m), hit and fmt(hit.Position.Y) or "nil"))
		end
	end
	check("each Staff rig's lowest body part is within 0.05 of the floor top under it", #rigs == 2 and #off == 0, table.concat(off, "; "))

	-- C5: the floor slab's (and the edge checker tiles') edge faces were coplanar with the outer faces of SideWallN, SideWallS
	-- and BackWall: a light strip flickering on the charcoal walls.
	local wn, ws, bw = anchor("SideWallN"), anchor("SideWallS"), anchor("BackWall")
	local flush = {}
	if wn and ws and bw then
		for _, name in ipairs({ "UnitFloor", "CheckerDark" }) do
			for _, f in ipairs(allNamed(name)) do
				if lo(f, "Z") < lo(wn, "Z") + 0.03 or hi(f, "Z") > hi(ws, "Z") - 0.03 or hi(f, "X") > hi(bw, "X") - 0.03 then
					table.insert(flush, name)
				end
			end
		end
	end
	check("UnitFloor and CheckerDark sit inside the side and back wall planes by >= 0.03", wn ~= nil and ws ~= nil and bw ~= nil
		and anchor("UnitFloor") ~= nil and #flush == 0, #flush .. " flush: " .. table.concat(flush, ", ", 1, math.min(#flush, 5)))
end

------------------------------------------------------------------ Thin ground parts stay inside the paved region (world x 224..324, z -200..-120)
do
	local out = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) and extent(d, "Y") <= 0.5 and lo(d, "Y") <= 0.35 and hi(d, "Y") <= 0.6 then
			if lo(d, "X") < 223.9 or hi(d, "X") > 324.1 or lo(d, "Z") < -200.1 or hi(d, "Z") > -119.9 then table.insert(out, d.Name) end
		end
	end
	check("thin ground parts are inside the paved region", #out == 0, #out .. ": " .. table.concat(out, ", ", 1, math.min(#out, 5)))
end

------------------------------------------------------------------ Part budget
do
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	check("non-rig, non-kept part count is 520..1300", n >= 520 and n <= 1300, tostring(n))
end

return HttpService:JSONEncode(results)
