-- site03_check: the Slice 18 fidelity spec for Site 03 (Lomi King), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site03_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site03_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site03.md "Revision 1 (Slice 18)": the 2015 Primer front-oblique photo is the only reference
-- (Commons has no usable Lomi King photo, searched 2026-10-22).
-- Coordinates: the brief and the builder use the original Slice 07 centre (180, 140); Slice 14 moved the site to (292, 140), so every
-- WORLD x below is the brief's x + 112. Frontage is west (-X); the viewer facing the shop has south (+Z) on their right.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(292, 0, 140)
local DX = 112

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site03_Lomi")
check("Site03_Lomi exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
-- A stray drag in Studio once moved a whole site; it shows up as a dozen unrelated failures, so test the pivot first.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (292, 0, 140), facing W",
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
local function withPrefix(prefix)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and d.Name:sub(1, #prefix) == prefix then table.insert(list, d) end
	end
	return list
end
local function anchor(name) return allNamed(name)[1] end
-- the part's real extent along a world axis (rotated corners included), the way BuildCheck measures bounds
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
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
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
local function darkCol(p) local r, g, b = rgb(p); return r <= 80 and g <= 80 and b <= 90 end

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
	for name in pairs(KEPT) do
		check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "Counter", "Tables", "LomiBowls", "Menu", "Utensils", "Diners" }) do
		check("required prop present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	local diners = site:FindFirstChild("Diners")
	check("3 diner rigs", diners ~= nil and #diners:GetChildren() == 3, diners and tostring(#diners:GetChildren()) or "missing")

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { site }
	local function blockers(cf, size)
		local bad = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(cf, size, params)) do
			-- ground slabs (top within 0.6 of the ground) are fine, standing objects are not
			if not isKept(p) and not isRig(p) and p.Position.Y + p.Size.Y / 2 > 0.6 then table.insert(bad, p.Name) end
		end
		return bad
	end
	local g = blockers(CFrame.new(262, 7, 140), Vector3.new(24, 14, 24))
	check("Guide keep-clear box (x 250..274, z 128..152) is free", #g == 0, #g .. ": " .. table.concat(g, ", ", 1, math.min(#g, 5)))
	local ip = blockers(CFrame.new(262, 6, 152), Vector3.new(12, 12, 12))
	check("InfoPanel front zone (x 256..268, z 146..158) is free", #ip == 0, #ip .. ": " .. table.concat(ip, ", ", 1, math.min(#ip, 5)))

	-- the aisle: z 138..142 from x 272 to 313, y 2..8, nothing colliding (rigs may stand in it)
	local lp = OverlapParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { site }
	lp.RespectCanCollide = true
	local lane = {}
	for _, h in ipairs(workspace:GetPartBoundsInBox(CFrame.new(292.5, 5, 140), Vector3.new(41, 6, 4), lp)) do
		if not isRig(h) then table.insert(lane, h.Name) end
	end
	check("walking lane into the shop is free", #lane == 0, #lane .. ": " .. table.concat(lane, ", ", 1, math.min(#lane, 5)))
end

------------------------------------------------------------------ Colour (photo: saturated coral, darker side pier)
local body = anchor("LomiBody")
do
	check("LomiBody exists", body ~= nil)
	if body then
		local r, g, b = rgb(body)
		check("wall is saturated coral (about 240,128,108)", r >= 238 and r <= 246 and g >= 124 and g <= 134 and b >= 104 and b <= 112,
			string.format("%.0f,%.0f,%.0f", r, g, b))
	end
end

------------------------------------------------------------------ 1-2: awning fascia plain, 3-D letters on top, no backing board
do
	local fascia = anchor("AwningFascia")
	check("AwningFascia exists", fascia ~= nil)
	check("AwningFascia carries no text (the words are the 3-D letters)", fascia ~= nil and guiText(fascia) == "", fascia and ("'" .. guiText(fascia) .. "'") or "missing")
	check("no LetterBoard slab behind the letters", #allNamed("LetterBoard") == 0, tostring(#allNamed("LetterBoard")))
	local letters = withPrefix("Letter_")
	check("8 separate letter parts (LOMI KING)", #letters == 8, tostring(#letters))
	table.sort(letters, function(a, b) return a.Position.Z < b.Position.Z end)
	local word = {}
	for _, p in ipairs(letters) do table.insert(word, (guiText(p):gsub("%s", ""))) end
	check("letters read LOMIKING from north to south", table.concat(word) == "LOMIKING", table.concat(word, "|"))
	local lowY, hiZ, loZ, minX, maxX = math.huge, -math.huge, math.huge, math.huge, -math.huge
	for _, p in ipairs(letters) do
		lowY = math.min(lowY, lo(p, "Y")); loZ = math.min(loZ, lo(p, "Z")); hiZ = math.max(hiZ, hi(p, "Z"))
		minX = math.min(minX, lo(p, "X")); maxX = math.max(maxX, hi(p, "X"))
	end
	check("letters stand on top of the awning (bottom y >= 15.5)", #letters > 0 and lowY >= 15.5, fmt(lowY))
	check("letters span the frontage (z width 28..40)", #letters > 0 and hiZ - loZ >= 28 and hiZ - loZ <= 40, fmt(hiZ - loZ))
	check("letters sit above the awning (x 276..284)", #letters > 0 and minX >= 276 and maxX <= 284, fmt(minX) .. ".." .. fmt(maxX))
end

------------------------------------------------------------------ 3: tall full-width banner of six coloured blocks with dish squares
do
	local blocks = withPrefix("BannerBlock")
	check("menu banner is 6 coloured blocks", #blocks == 6, tostring(#blocks))
	local y0, y1 = span(blocks, "Y")
	local z0, z1 = span(blocks, "Z")
	check("banner is at least 3 studs tall", #blocks > 0 and y1 - y0 >= 3, fmt(y1 - y0))
	check("banner bottom stays at y >= 8.4 (above the lane)", #blocks > 0 and y0 >= 8.4, fmt(y0))
	check("banner spans the opening (z width >= 30)", #blocks > 0 and z1 - z0 >= 30, fmt(z1 - z0))
	local text = {}
	for _, p in ipairs(blocks) do table.insert(text, guiText(p)) end
	local all = table.concat(text, " ")
	for _, w in ipairs({ "SPECIALS", "LOMI", "PANCIT", "RICE MEALS", "SANDWICHES" }) do
		check("banner labels include " .. w, all:find(w, 1, true) ~= nil, all)
	end
	check("no KOPI VINZ or phone number on the banner", not all:find("KOPI", 1, true) and not all:find("(043)", 1, true), all)
	check("banner has dish squares (>= 8)", #withPrefix("BannerDish") >= 8, tostring(#withPrefix("BannerDish")))
end

------------------------------------------------------------------ 4: black steel frame around the opening
do
	local posts = allNamed("SteelPost")
	check("steel posts at the opening (>= 3, >= 11 tall)", #posts >= 3, tostring(#posts))
	local tall = 0
	local inLane = {}
	for _, p in ipairs(posts) do
		if extent(p, "Y") >= 11 then tall += 1 end
		if hi(p, "Z") > 138 and lo(p, "Z") < 142 then table.insert(inLane, p.Name) end
	end
	check("every steel post is >= 11 tall", #posts > 0 and tall == #posts, tall .. "/" .. #posts)
	check("no steel post stands in the aisle (z 138..142)", #inLane == 0, #inLane .. " in the lane")
	local dk = 0
	for _, p in ipairs(posts) do if darkCol(p) then dk += 1 end end
	check("steel posts are dark", #posts > 0 and dk == #posts, dk .. "/" .. #posts)
	local rails = allNamed("SteelRail")
	check("a steel top rail across the opening", #rails >= 1 and extent(rails[1], "Z") >= 30, #rails >= 1 and fmt(extent(rails[1], "Z")) or "missing")
end

------------------------------------------------------------------ 5: row of 7 globe pendants behind the banner
do
	local globes = {}
	for _, p in ipairs(allNamed("PendantGlobe")) do
		if p.Position.X >= 275 and p.Position.X <= 282 and p.Position.Y >= 9 and p.Position.Z >= 116 and p.Position.Z <= 150 then
			table.insert(globes, p)
		end
	end
	check("7 pendant globes in a row behind the banner (bulb y >= 9)", #globes >= 7, tostring(#globes))
	local lane = 0
	for _, p in ipairs(globes) do if p.Position.Y - p.Size.Y / 2 < 8.2 and p.Position.Z > 137 and p.Position.Z < 143 then lane += 1 end end
	check("no globe hangs into the aisle", lane == 0, tostring(lane))
end

------------------------------------------------------------------ 6: large curved bay on the second floor
do
	local bay = withPrefix("CurvedBay")
	check("curved bay is built from >= 5 segments", #bay >= 5, tostring(#bay))
	local z0, z1 = span(bay, "Z")
	local y0, y1 = span(bay, "Y")
	local x0 = span(bay, "X")
	check("curved bay is 14..26 wide", #bay > 0 and z1 - z0 >= 14 and z1 - z0 <= 26, fmt(z1 - z0))
	check("curved bay is on the second floor (y 18..28.5)", #bay > 0 and y0 >= 18 and y1 <= 28.5, fmt(y0) .. ".." .. fmt(y1))
	check("curved bay projects from the wall (front at x <= 280.5)", #bay > 0 and x0 <= 280.5, fmt(x0))
	check("curved bay is on the north half (centre z < 140)", #bay > 0 and (z0 + z1) / 2 < 140, fmt((z0 + z1) / 2))
	check("old small RoundBay cylinder is gone", #allNamed("RoundBay") == 0, tostring(#allNamed("RoundBay")))
end

------------------------------------------------------------------ 7: iron grille and the darker corner pier
do
	local bars = withPrefix("GrilleBar")
	check("window grille has >= 6 bars", #bars >= 6, tostring(#bars))
	local south, dk = 0, 0
	for _, p in ipairs(bars) do
		if p.Position.Z > 140 and lo(p, "Y") >= 28 then south += 1 end
		if darkCol(p) then dk += 1 end
	end
	check("grille is on the southern upper windows (z > 140, y >= 28)", #bars > 0 and south == #bars, south .. "/" .. #bars)
	check("grille bars are dark", #bars > 0 and dk == #bars, dk .. "/" .. #bars)
	local pier = anchor("CornerPier")
	check("CornerPier exists on the south edge", pier ~= nil and pier.Position.Z >= 163.5, pier and fmt(pier.Position.Z) or "missing")
	if pier and body then
		check("CornerPier reaches the ground and the top of the facade", lo(pier, "Y") <= 0.6 and hi(pier, "Y") >= 40, fmt(lo(pier, "Y")) .. ".." .. fmt(hi(pier, "Y")))
		check("CornerPier is darker than the wall", pier.Color.R * 255 <= body.Color.R * 255 - 8, fmt(pier.Color.R * 255))
	end
end

------------------------------------------------------------------ 8: round logo sign at the north corner on a steel bracket
do
	local disk, ring, bracket = anchor("LogoDisk"), anchor("LogoRing"), anchor("LogoBracket")
	check("LogoDisk exists and is at the north corner (z < 125)", disk ~= nil and disk.Position.Z < 125, disk and fmt(disk.Position.Z) or "missing")
	check("LogoDisk is large (diameter >= 8)", disk ~= nil and math.max(disk.Size.Y, disk.Size.Z) >= 8, disk and fmt(math.max(disk.Size.Y, disk.Size.Z)) or "missing")
	check("white LogoRing and a cream bowl (cup icon)", ring ~= nil and anchor("LogoBowl") ~= nil, ring and "bowl missing" or "ring missing")
	check("LogoBracket rises from the awning top (bottom y <= 17, top y >= 28)", bracket ~= nil and lo(bracket, "Y") <= 17 and hi(bracket, "Y") >= 28,
		bracket and (fmt(lo(bracket, "Y")) .. ".." .. fmt(hi(bracket, "Y"))) or "missing")
end

------------------------------------------------------------------ 9: big pots with tall bushy shrubs, clear of the Guide
do
	local pots = allNamed("Pot")
	check("2 big pots (>= 2.9 wide)", #pots == 2, tostring(#pots))
	local narrow = 0
	for _, p in ipairs(pots) do if extent(p, "Z") < 2.9 then narrow += 1 end end
	check("both pots are at least 2.9 wide", #pots > 0 and narrow == 0, narrow .. " narrow")
	local shrub = withPrefix("Topiary")
	check("shrubs are built from >= 6 stacked parts", #shrub >= 6, tostring(#shrub))
	for _, side in ipairs({ { "north", function(p) return p.Position.Z < 140 end }, { "south", function(p) return p.Position.Z >= 140 end } }) do
		local part = {}
		for _, p in ipairs(shrub) do if side[2](p) then table.insert(part, p) end end
		local z0, z1 = span(part, "Z")
		local _, top = span(part, "Y")
		check(side[1] .. " shrub is tall (top y >= 8) and bushy (>= 4.5 wide)", #part > 0 and top >= 8 and z1 - z0 >= 4.5, fmt(top) .. " / " .. fmt(z1 - z0))
	end
	local west = 1e9
	for _, p in ipairs(shrub) do west = math.min(west, lo(p, "X")) end
	for _, p in ipairs(pots) do west = math.min(west, lo(p, "X")) end
	check("shrubs and pots stay east of the Guide box (x >= 274)", #shrub > 0 and west >= 274, fmt(west))
end

------------------------------------------------------------------ 10: big parking board, ramen poster, bamboo screen with a cap
do
	local sign = anchor("ParkingSign")
	check("ParkingSign exists", sign ~= nil)
	if sign then
		local w, h = extent(sign, "Z"), extent(sign, "Y")
		check("ParkingSign is large (>= 11 x >= 5.5 studs)", w >= 11 and h >= 5.5, fmt(w) .. " x " .. fmt(h))
		check("ParkingSign is low on the bay (bottom y <= 3.5, top y >= 8)", lo(sign, "Y") <= 3.5 and hi(sign, "Y") >= 8, fmt(lo(sign, "Y")) .. ".." .. fmt(hi(sign, "Y")))
		check("ParkingSign text names the customers", guiText(sign):find("CUSTOMERS", 1, true) ~= nil, guiText(sign))
	end
	local poster = anchor("RamenPoster")
	check("RamenPoster exists with RAMEN text", poster ~= nil and guiText(poster):find("RAMEN", 1, true) ~= nil, poster and guiText(poster) or "missing")
	check("bamboo screen has a cap", anchor("BambooCap") ~= nil)
	check("bamboo slats (>= 6 BambooSlat)", #withPrefix("BambooSlat") >= 6, tostring(#withPrefix("BambooSlat")))
end

------------------------------------------------------------------ 12: text legibility (a green check once passed a sign rendered at a tenth of its size)
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

------------------------------------------------------------------ Thin ground parts stay inside the paved region (world x 240..340, z 100..180)
do
	local out = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) and extent(d, "Y") <= 0.5 and lo(d, "Y") <= 0.35 and hi(d, "Y") <= 0.6 then
			if lo(d, "X") < 239.9 or hi(d, "X") > 340.1 or lo(d, "Z") < 99.9 or hi(d, "Z") > 180.1 then table.insert(out, d.Name) end
		end
	end
	check("thin ground parts are inside the paved region", #out == 0, #out .. ": " .. table.concat(out, ", ", 1, math.min(#out, 5)))
end

------------------------------------------------------------------ Part budget (the facade got richer; the model stays far below 2500)
do
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	check("non-rig, non-kept part count is 300..900", n >= 300 and n <= 900, tostring(n))
end

return HttpService:JSONEncode(results)
