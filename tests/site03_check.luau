-- site03_check: the fidelity spec for Site 03 (Lomi King), REBUILT from the Lomi King Architectural Blueprint Board and the Street View photo (Lomi King plan L1b).
-- Studio copy: ServerStorage.Checks.site03_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site03_check:Clone())      -- returns JSON {passed, failed, failures}
-- Groups (set shared.site03_only = "general" | "tower" | "front" | "dining" | "context" | "clear" first to run one; run_all leaves it nil and runs all).
-- Each group tests only its own parts. Design source: docs/handoff/053-handoff.md "Lomi King plan" (the numbers are a contract; a builder never loosens them).
-- World frame: the site pivot is (292, 0, 140) facing W (-X); world x east (+), z south (+), y up. Every number below is WORLD.
--
-- ===================================== NAMING CONTRACT (builders MUST follow it) =====================================
-- Anchors (ONE BasePart each in the whole site, no Model/Folder shares the name): LomiBody, AwningFascia, RoofCore, LogoDisk, LogoRing, LogoCore, LogoBowl,
--   SignMast, ParkingSign, RamenPoster, BambooCap, CounterTop, DrivewayAsphalt.
-- Name prefixes (matched against BASEPARTS unless marked [group]): Letter_ (8, north to south LOMIKING), BambooSlat, CurvedBay (Material Glass segments carry the glass),
--   BalconyGrille (grille floor), BalconyRing (ring discs, Shape Cylinder), GrilleBar (barred window: a [group] = a Model or Folder named GrilleBar* holding at least 3 parts),
--   Window / Shutter (neighbour windows), PoleWire, PendantGlobe, TableTop, ChairSeat, Door, RailPost, Pot, Topiary, SteelPost, SteelRail, BannerBlock, BannerDish.
-- [unit] = a Model or BasePart measured over all its parts: Context/NeighbourN, Context/NeighbourS, UtilityPole, Transformer, Car, Motorbike.
-- Names and thresholds fixed by the test (builders must follow):
--   ChairSeat: 8+ parts, every top >= 1.95.  CounterTop top y 3.5 (+-0.05), > 15 east of the awning.  Door* (if any) 8+ tall.  RailPost* (if any) 2.9..3.4 tall.
--   GrilleBar barred window = a Model or Folder named GrilleBar* with 3+ parts, centre y in 16..28 / 28..40 / 40..52 (2+ per floor); loose GrilleBar parts are dark.
--   Car* and Motorbike* are Models inside Context, in x 276..288, z 181..194, clear of DrivewayAsphalt.  Neighbour windows are parts named Window* or Shutter*,
--   per floor y 0..12 / 12..24 / 24..36.  SignMast: z within 3 of LogoDisk, bottom y <= 3.  ParkingSign label: TextScaled false, TextSize >= 20; the sign stands on the canopy's south return, 11+ wide along x, label facing +Z (Revision 3).
--   Letter_ x 276..284, bottom y >= 15.5.  BambooSlat z >= 158.  CurvedBay: z span 12 +-1, centre z 141 +-1.5, front x 280..281.5.  CornerPier z >= 160.
--   Wall colour about 238,150,125 (+-8).  The slab and eave limits below.
-- Storey slabs and bands (tower): any non-rig part at most 2.5 thick whose centre is inside the tower footprint (x >= 283, z 120..162), longest side at least 20,
--   with its bottom or top face at y 16, 28, 40, 52 (+-0.5); the name is free.
-- Hip eave (tower): any non-rig part with bottom >= 61.5, top <= 64.5 and longest horizontal side >= 34.
-- ======================================================================================================================
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(292, 0, 140)
local CAP = { part = 400, total = 2500 }
local ONLY = shared.site03_only

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

------------------------------------------------------------------ helpers
local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local KEPT = { Guide = true, InfoPanel = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end
local own = {} -- every non-rig BasePart of the site
for _, d in ipairs(site:GetDescendants()) do
	if d:IsA("BasePart") and not isRig(d) then table.insert(own, d) end
end
local function allNamed(name)
	local list = {}
	for _, d in ipairs(own) do if d.Name == name then table.insert(list, d) end end
	return list
end
local function withPrefix(prefix)
	local list = {}
	for _, d in ipairs(own) do if d.Name:sub(1, #prefix) == prefix then table.insert(list, d) end end
	return list
end
-- ONE BasePart with the name, and no Model/Folder shares it
local function single(name)
	local parts, clash = allNamed(name), 0
	for _, d in ipairs(site:GetDescendants()) do if d.Name == name and not d:IsA("BasePart") then clash += 1 end end
	return parts[1], #parts == 1 and clash == 0, #parts .. " parts, " .. clash .. " containers named " .. name
end
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
local function partsIn(inst)
	if inst:IsA("BasePart") then return { inst } end
	local t = {}
	for _, d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") and not isRig(d) then table.insert(t, d) end end
	return t
end
-- a [unit]'s box: returns lo, hi Vector3 over all its parts, or nil when it holds no part
local function box(inst)
	local list = partsIn(inst)
	if #list == 0 then return nil end
	local x0, x1 = span(list, "X")
	local y0, y1 = span(list, "Y")
	local z0, z1 = span(list, "Z")
	return Vector3.new(x0, y0, z0), Vector3.new(x1, y1, z1)
end
-- top-level Models / BaseParts whose name starts with the prefix (not nested in a match, holding at least one part)
local function units(prefix)
	local t = {}
	for _, d in ipairs(site:GetDescendants()) do
		if (d:IsA("BasePart") or d:IsA("Model") or d:IsA("Folder")) and d.Name:sub(1, #prefix) == prefix and not isRig(d) and not isKept(d) then
			local top, a = true, d.Parent
			while a and a ~= site do
				if a.Name:sub(1, #prefix) == prefix then top = false break end
				a = a.Parent
			end
			if top and #partsIn(d) > 0 then table.insert(t, d) end
		end
	end
	return t
end
local function between(v, a, b) return v ~= nil and v >= a and v <= b end
local function near(v, t, tol) return v ~= nil and math.abs(v - t) <= tol end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
local function darkCol(p) local r, g, b = rgb(p); return r <= 80 and g <= 80 and b <= 90 end
local function labelsOf(p) -- every TextLabel under the part's SurfaceGuis
	local t = {}
	for _, g in ipairs(p:GetChildren()) do
		if g:IsA("SurfaceGui") then
			for _, l in ipairs(g:GetDescendants()) do
				if l:IsA("TextLabel") then table.insert(t, l) end
			end
		end
	end
	return t
end
local function guiText(p)
	local t = {}
	for _, l in ipairs(labelsOf(p)) do table.insert(t, l.Text) end
	return table.concat(t, " ")
end
local function list(t, n) return #t .. ": " .. table.concat(t, ", ", 1, math.min(#t, n or 5)) end
local function group(name, fn)
	if ONLY ~= nil and ONLY ~= name then return end
	local ok, err = pcall(fn)
	if not ok then check("group " .. name .. " ran without a script error", false, tostring(err)) end
end
local params = OverlapParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = { site }
-- standing built parts in a world box (ground slabs, top within 0.6 of the ground, are fine); GetPartBoundsInBox skips CanQuery false parts
local function blockers(cf, size)
	local bad = {}
	for _, p in ipairs(workspace:GetPartBoundsInBox(cf, size, params)) do
		if not isKept(p) and not isRig(p) and p.Position.Y + p.Size.Y / 2 > 0.6 then table.insert(bad, p.Name) end
	end
	return bad
end

local body = single("LomiBody")
local fascia = single("AwningFascia")

------------------------------------------------------------------ general: pivot, kept objects, required props, rigs, budgets
group("general", function()
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (292, 0, 140), facing W",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(-1, 0, 0)) > 0.999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
	for name in pairs(KEPT) do
		check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "Counter", "Tables", "LomiBowls", "Menu", "Utensils" }) do
		local c = site:FindFirstChild(name)
		check("required prop is a direct child holding parts: " .. name, c ~= nil and #partsIn(c) > 0, c and (#partsIn(c) .. " parts") or "missing")
	end
	local diners = site:FindFirstChild("Diners")
	local rigs = 0
	if diners then for _, c in ipairs(diners:GetChildren()) do if c:FindFirstChildOfClass("Humanoid") then rigs += 1 end end end
	check("exactly 3 diner rigs in Diners", diners ~= nil and #diners:GetChildren() == 3 and rigs == 3, diners and (#diners:GetChildren() .. " children, " .. rigs .. " rigs") or "missing")

	local total = 0
	for _, d in ipairs(site:GetDescendants()) do if d:IsA("BasePart") then total += 1 end end
	check("site parts including rigs: at most " .. CAP.total, total <= CAP.total, tostring(total))
	local over = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("Model") or d:IsA("Folder") then
			local n = 0
			for _, x in ipairs(d:GetDescendants()) do if x:IsA("BasePart") then n += 1 end end
			if n > CAP.part then table.insert(over, d.Name .. "=" .. n) end
		end
	end
	check("every Model or Folder holds at most " .. CAP.part .. " parts in its subtree", #over == 0, list(over))
	local loose = {}
	for _, d in ipairs(own) do if not d.Anchored then table.insert(loose, d.Name) end end
	check("all non-rig parts are anchored", #loose == 0, list(loose))
	check("non-rig part count is 700..1500", #own >= 700 and #own <= 1500, tostring(#own))
	check("no LetterBoard slab behind the letters", #allNamed("LetterBoard") == 0, tostring(#allNamed("LetterBoard")))
	check("old small RoundBay cylinder is gone", #allNamed("RoundBay") == 0, tostring(#allNamed("RoundBay")))

	-- text legibility (a green check once passed a sign rendered at a tenth of its size)
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
end)

------------------------------------------------------------------ tower: four storeys, curved bays, barred windows, grille floor, hip eave, pavilion
group("tower", function()
	check("LomiBody is ONE unique part", body ~= nil)
	local tz0, tz1
	if body then tz0, tz1 = lo(body, "Z"), hi(body, "Z") end
	local fz0, fz1
	if fascia then fz0, fz1 = lo(fascia, "Z"), hi(fascia, "Z") end
	check("LomiBody is narrower in z than AwningFascia (fascia about 52, tower at most 36)",
		body ~= nil and fascia ~= nil and tz1 - tz0 <= 36 and (tz1 - tz0) < (fz1 - fz0), body and fascia and (fmt(tz1 - tz0) .. " vs " .. fmt(fz1 - fz0)) or "missing")
	check("RoofCore present", single("RoofCore") ~= nil)
	if body then
		local r, g, b = rgb(body)
		check("wall is salmon (about 238,150,125, each channel +-8)", math.abs(r - 238) <= 8 and math.abs(g - 150) <= 8 and math.abs(b - 125) <= 8, string.format("%.0f,%.0f,%.0f", r, g, b))
	end
	local bay = withPrefix("CurvedBay")
	local bz0, bz1 = span(bay, "Z")
	local bx0 = span(bay, "X")
	check("curved bay is 12 wide (z span 12 +-1)", #bay > 0 and near(bz1 - bz0, 12, 1), fmt(bz1 - bz0))
	check("curved bay is centred z 141 (+-1.5)", #bay > 0 and near((bz0 + bz1) / 2, 141, 1.5), fmt((bz0 + bz1) / 2))
	check("curved bay front face is x 280..281.5 (projects at most 3.5 from the tower front)", #bay > 0 and bx0 >= 279.9 and bx0 <= 281.6, fmt(bx0))

	-- storey slabs or bands, name-agnostic but real: thin, wide, inside the tower footprint
	for _, y in ipairs({ 16, 28, 40, 52 }) do
		local found
		for _, p in ipairs(own) do
			if extent(p, "Y") <= 2.5 and math.max(extent(p, "X"), extent(p, "Z")) >= 20 and p.Position.X >= 283 and between(p.Position.Z, 120, 162)
				and (near(lo(p, "Y"), y, 0.5) or near(hi(p, "Y"), y, 0.5)) then
				found = p
				break
			end
		end
		check("a storey slab or band at y " .. y .. " (+-0.5, thin, 20+ long, inside the tower)", found ~= nil)
	end

	-- grille floor y 52..62
	local grilles = {}
	for _, p in ipairs(withPrefix("BalconyGrille")) do
		if lo(p, "Y") >= 51.5 and hi(p, "Y") <= 62.5 then table.insert(grilles, p) end
	end
	check("grille floor y 52..62 has at least 10 BalconyGrille parts", #grilles >= 10, tostring(#grilles))
	local rings = 0
	for _, p in ipairs(withPrefix("BalconyRing")) do
		if p.Shape == Enum.PartType.Cylinder and lo(p, "Y") >= 51.5 and hi(p, "Y") <= 62.5 then rings += 1 end
	end
	check("grille floor has at least 4 ring discs (BalconyRing, Cylinder, y 52..62)", rings >= 4, tostring(rings))

	-- hip eave y 62..64
	local eave
	for _, p in ipairs(own) do
		if lo(p, "Y") >= 61.5 and hi(p, "Y") <= 64.5 and math.max(extent(p, "X"), extent(p, "Z")) >= 34 then eave = p break end
	end
	check("a hip eave at y 62..64 (bottom >= 61.5, top <= 64.5, 34+ long)", eave ~= nil)

	-- pavilion apex
	local apex = -math.huge
	for _, p in ipairs(own) do apex = math.max(apex, hi(p, "Y")) end
	check("pavilion apex (highest non-rig part top) is y 74..80", apex >= 74 and apex <= 80, fmt(apex))

	-- curved bay glass on floors 2, 3, 4
	local glass = {}
	for _, p in ipairs(withPrefix("CurvedBay")) do if p.Material == Enum.Material.Glass then table.insert(glass, p) end end
	for i, band in ipairs({ { 17, 27 }, { 29, 39 }, { 41, 51 } }) do
		local n = 0
		for _, p in ipairs(glass) do
			if lo(p, "Y") >= band[1] - 0.5 and hi(p, "Y") <= band[2] + 0.5 then n += 1 end
		end
		check("floor " .. (i + 1) .. " has CurvedBay glass segments (Material Glass, y " .. band[1] .. ".." .. band[2] .. ")", n >= 1, n .. " of " .. #glass .. " glass segments")
	end

	-- barred windows: GrilleBar groups, 2+ per floor on floors 2-4, 6+ in all
	local groups = {}
	for _, d in ipairs(site:GetDescendants()) do
		if (d:IsA("Model") or d:IsA("Folder")) and d.Name:sub(1, 9) == "GrilleBar" and not isRig(d) and #partsIn(d) >= 3 then table.insert(groups, d) end
	end
	check("at least 6 barred windows (GrilleBar groups of 3+ parts)", #groups >= 6, tostring(#groups))
	for i, band in ipairs({ { 16, 28 }, { 28, 40 }, { 40, 52 } }) do
		local n = 0
		for _, g in ipairs(groups) do
			local a, b = box(g)
			local cy = (a.Y + b.Y) / 2
			if cy >= band[1] and cy < band[2] then n += 1 end
		end
		check("floor " .. (i + 1) .. " has at least 2 barred windows (y " .. band[1] .. ".." .. band[2] .. ")", n >= 2, tostring(n))
	end
	local dk, bars = 0, withPrefix("GrilleBar")
	for _, p in ipairs(bars) do if darkCol(p) then dk += 1 end end
	check("grille bars are dark and present", #bars > 0 and dk == #bars, dk .. "/" .. #bars)
end)

------------------------------------------------------------------ front: canopy, letters, round sign, banner, steel frame, bamboo wall, parking sign, driveway
group("front", function()
	check("AwningFascia is ONE unique part", fascia ~= nil)
	check("AwningFascia carries no text (the words are the 3-D letters)", fascia ~= nil and guiText(fascia) == "", fascia and ("'" .. guiText(fascia) .. "'") or "missing")
	if fascia and body then
		check("awning is more than 10 west of LomiBody", body.Position.X - fascia.Position.X > 10, fmt(body.Position.X - fascia.Position.X))
	end
	local letters = withPrefix("Letter_")
	check("8 separate letter parts (LOMI KING)", #letters == 8, tostring(#letters))
	table.sort(letters, function(a, b) return a.Position.Z < b.Position.Z end)
	local word = {}
	for _, p in ipairs(letters) do table.insert(word, (guiText(p):gsub("%s", ""))) end
	check("letters read LOMIKING from north to south", table.concat(word) == "LOMIKING", table.concat(word, "|"))
	local lowY = span(letters, "Y")
	local loZ, hiZ = span(letters, "Z")
	local minX, maxX = span(letters, "X")
	check("letters stand on top of the awning (bottom y >= 15.5)", #letters > 0 and lowY >= 15.5, fmt(lowY))
	check("letters span the frontage (z width 28..40)", #letters > 0 and hiZ - loZ >= 28 and hiZ - loZ <= 40, fmt(hiZ - loZ))
	check("letters sit above the awning (x 276..284)", #letters > 0 and minX >= 276 and maxX <= 284, fmt(minX) .. ".." .. fmt(maxX))
	if fascia and #letters > 0 then
		check("letters stand on the fascia (bottom within 1 of its top)", math.abs(lowY - hi(fascia, "Y")) <= 1, fmt(lowY) .. " vs " .. fmt(hi(fascia, "Y")))
	end

	-- round sign north of the tower, on a mast
	local disk, ring, core, bowl, mast = single("LogoDisk"), single("LogoRing"), single("LogoCore"), single("LogoBowl"), single("SignMast")
	check("LogoDisk, LogoRing, LogoCore and LogoBowl all exist", disk ~= nil and ring ~= nil and core ~= nil and bowl ~= nil)
	check("LogoDisk is large (diameter >= 8)", disk ~= nil and math.max(disk.Size.Y, disk.Size.Z) >= 8, disk and fmt(math.max(disk.Size.Y, disk.Size.Z)) or "missing")
	check("round sign is north of the tower (LogoDisk max z < LomiBody min z)", disk ~= nil and body ~= nil and hi(disk, "Z") < lo(body, "Z"),
		disk and body and (fmt(hi(disk, "Z")) .. " vs " .. fmt(lo(body, "Z"))) or "missing")
	check("SignMast exists and stands at the sign (within 3 in z of LogoDisk, reaches the ground side: bottom <= 3)",
		mast ~= nil and disk ~= nil and math.abs(mast.Position.Z - disk.Position.Z) <= 3 and lo(mast, "Y") <= 3, mast and (fmt(mast.Position.Z) .. " y " .. fmt(lo(mast, "Y"))) or "missing")

	-- menu banner
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

	-- black steel frame around the opening
	local posts = withPrefix("SteelPost")
	check("steel posts at the opening (>= 3)", #posts >= 3, tostring(#posts))
	local tall, inLane, dkp = 0, {}, 0
	for _, p in ipairs(posts) do
		if extent(p, "Y") >= 11 then tall += 1 end
		if hi(p, "Z") > 138 and lo(p, "Z") < 142 then table.insert(inLane, p.Name) end
		if darkCol(p) then dkp += 1 end
	end
	check("every steel post is >= 11 tall", #posts > 0 and tall == #posts, tall .. "/" .. #posts)
	check("no steel post stands in the aisle (z 138..142)", #inLane == 0, #inLane .. " in the lane")
	check("steel posts are dark", #posts > 0 and dkp == #posts, dkp .. "/" .. #posts)
	local rails = withPrefix("SteelRail")
	check("a steel top rail across the opening", #rails >= 1 and extent(rails[1], "Z") >= 30, #rails >= 1 and fmt(extent(rails[1], "Z")) or "missing")

	-- south side: bamboo wall, ramen poster, parking sign, driveway
	local slats = withPrefix("BambooSlat")
	local south = 0
	for _, p in ipairs(slats) do if p.Position.Z >= 158 then south += 1 end end
	check("bamboo slats (>= 6 BambooSlat) stand on the south side (z >= 158, beyond the tower)", #slats >= 6 and south == #slats, #slats .. " slats, " .. south .. " south")
	check("bamboo screen has a cap", single("BambooCap") ~= nil)
	local sign = single("ParkingSign")
	check("ParkingSign exists", sign ~= nil)
	if sign then
		-- Revision 3 (owner, 2026-10-31): the board puts the sign on the canopy's south return, facing the driveway, so its width runs along x.
		local w, h = extent(sign, "X"), extent(sign, "Y")
		check("ParkingSign is large (>= 11 wide along x, >= 5.5 tall: it stands on the south return)", w >= 11 and h >= 5.5, fmt(w) .. " x " .. fmt(h))
		check("ParkingSign is low (bottom y <= 3.5, top y >= 8)", lo(sign, "Y") <= 3.5 and hi(sign, "Y") >= 8, fmt(lo(sign, "Y")) .. ".." .. fmt(hi(sign, "Y")))
		local labs = labelsOf(sign)
		local lab = labs[1]
		check("ParkingSign text is exactly PARKING FOR LOMI KING CUSTOMERS ONLY", #labs == 1 and lab.Text == "PARKING FOR LOMI KING CUSTOMERS ONLY", lab and lab.Text or "no label")
		check("ParkingSign text has a fixed TextSize (TextScaled false, TextSize >= 20)", lab ~= nil and lab.TextScaled == false and lab.TextSize >= 20, lab and ("size " .. lab.TextSize .. " scaled " .. tostring(lab.TextScaled)) or "no label")
		local gui = lab and lab:FindFirstAncestorOfClass("SurfaceGui")
		local normal = gui and sign.CFrame:VectorToWorldSpace(Vector3.FromNormalId(gui.Face))
		check("ParkingSign label faces south (world normal +Z, dot >= 0.99)", normal ~= nil and normal.Z >= 0.99, normal and string.format("normal %.2f, %.2f, %.2f", normal.X, normal.Y, normal.Z) or "no label")
		if body then
			check("ParkingSign is at least 10 south of LomiBody's centre z", sign.Position.Z >= body.Position.Z + 10, fmt(sign.Position.Z) .. " vs " .. fmt(body.Position.Z))
		end
	end
	local poster = single("RamenPoster")
	check("RamenPoster exists with RAMEN text", poster ~= nil and guiText(poster):find("RAMEN", 1, true) ~= nil, poster and guiText(poster) or "missing")
	local pier = single("CornerPier")
	check("CornerPier exists at the canopy's south corner (z >= 160)", pier ~= nil and pier.Position.Z >= 160, pier and fmt(pier.Position.Z) or "missing")
	if pier and body then
		check("CornerPier reaches the ground and the canopy top (bottom y <= 0.6, top y >= 16)", lo(pier, "Y") <= 0.6 and hi(pier, "Y") >= 16, fmt(lo(pier, "Y")) .. ".." .. fmt(hi(pier, "Y")))
		check("CornerPier is darker than the wall (R at least 8 below LomiBody)", pier.Color.R * 255 <= body.Color.R * 255 - 8, fmt(pier.Color.R * 255) .. " vs " .. fmt(body.Color.R * 255))
	elseif not pier then
		check("CornerPier reaches the ground and the canopy top and is darker than the wall", false, "missing")
	end
	local dw = single("DrivewayAsphalt")
	check("DrivewayAsphalt exists with z within 166..180", dw ~= nil and lo(dw, "Z") >= 165.9 and hi(dw, "Z") <= 180.1,
		dw and (fmt(lo(dw, "Z")) .. ".." .. fmt(hi(dw, "Z"))) or "missing")
end)

------------------------------------------------------------------ dining: human scale, counter, tables, pendants, pots, rigs
group("dining", function()
	-- human-scale rules (README rule 7): the old file had none of these as assertions, they are written here from the README numbers
	local seats, lowSeat = withPrefix("ChairSeat"), 0
	for _, p in ipairs(seats) do if hi(p, "Y") < 1.95 then lowSeat += 1 end end
	check("chairs are at least 2 high (every ChairSeat top >= 1.95, 8+ chairs)", #seats >= 8 and lowSeat == 0, #seats .. " seats, " .. lowSeat .. " low")
	local ct = single("CounterTop")
	check("CounterTop present, top y 3.5 (+-0.05)", ct ~= nil and near(hi(ct, "Y"), 3.5, 0.05), ct and fmt(hi(ct, "Y")) or "missing")
	if ct and fascia then
		check("CounterTop is more than 15 east of the awning", ct.Position.X - fascia.Position.X > 15, fmt(ct.Position.X - fascia.Position.X))
	end
	local doors, badDoor = withPrefix("Door"), 0
	for _, d in ipairs(doors) do if extent(d, "Y") < 8 then badDoor += 1 end end
	check("every Door part (if any) is 8+ tall", badDoor == 0, #doors .. " doors, " .. badDoor .. " short")
	local rp, badRp = withPrefix("RailPost"), 0
	for _, p in ipairs(rp) do if not between(extent(p, "Y"), 2.9, 3.4) then badRp += 1 end end
	check("every RailPost part (if any) is 3 tall (2.9..3.4)", badRp == 0, #rp .. " posts, " .. badRp .. " off")

	local tops = withPrefix("TableTop")
	check("at least 6 tables (TableTop)", #tops >= 6, tostring(#tops))
	local globes, lane = {}, 0
	for _, p in ipairs(withPrefix("PendantGlobe")) do
		if lo(p, "Y") >= 8.2 or not (p.Position.Z > 137 and p.Position.Z < 143) then table.insert(globes, p) else lane += 1 end
	end
	check("at least 4 PendantGlobe (none hanging into the aisle)", #globes >= 4 and lane == 0, #globes .. " globes, " .. lane .. " in the aisle")
	local diners = site:FindFirstChild("Diners")
	local rigs = 0
	if diners then for _, c in ipairs(diners:GetChildren()) do if c:FindFirstChildOfClass("Humanoid") then rigs += 1 end end end
	check("3 Diners rigs", diners ~= nil and rigs == 3, tostring(rigs))

	-- pots and shrubs flanking the dining front
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
		local a, b = span(part, "Z")
		local _, top = span(part, "Y")
		check(side[1] .. " shrub is tall (top y >= 8) and bushy (>= 4.5 wide)", #part > 0 and top >= 8 and b - a >= 4.5, fmt(top) .. " / " .. fmt(b - a))
	end
	local west = math.huge
	for _, p in ipairs(shrub) do west = math.min(west, lo(p, "X")) end
	for _, p in ipairs(pots) do west = math.min(west, lo(p, "X")) end
	check("shrubs and pots stay east of the Guide box (x >= 274)", #shrub > 0 and west >= 274, fmt(west))
end)

------------------------------------------------------------------ context: neighbours, utility poles, transformers, wires, car and motorbike
group("context", function()
	local ctx = site:FindFirstChild("Context")
	check("a Context folder exists", ctx ~= nil and ctx:IsA("Folder"), ctx and ctx.ClassName or "missing")
	if not ctx then return end
	local drive = single("DrivewayAsphalt")
	for _, spec in ipairs({ { "NeighbourN", 86, 112 }, { "NeighbourS", 181, 194 } }) do
		local n = ctx:FindFirstChild(spec[1])
		local a, b
		if n then a, b = box(n) end
		check(spec[1] .. " exists in Context and holds parts", a ~= nil)
		if a then
			check(spec[1] .. " stands in z " .. spec[2] .. ".." .. spec[3], a.Z >= spec[2] - 0.1 and b.Z <= spec[3] + 0.1, fmt(a.Z) .. ".." .. fmt(b.Z))
			check(spec[1] .. " front face at x >= 290", a.X >= 289.9, fmt(a.X))
			check(spec[1] .. " is 3 storeys, top y 34..38", between(b.Y, 34, 38), fmt(b.Y))
			for fl, band in ipairs({ { 0, 12 }, { 12, 24 }, { 24, 36 } }) do
				local cnt = 0
				for _, p in ipairs(partsIn(n)) do
					if (p.Name:sub(1, 6) == "Window" or p.Name:sub(1, 7) == "Shutter") and p.Position.Y >= band[1] and p.Position.Y < band[2] then cnt += 1 end
				end
				check(spec[1] .. " floor " .. fl .. " has at least 3 window or shutter parts", cnt >= 3, tostring(cnt))
			end
		end
	end
	local poles = units("UtilityPole")
	check("2 UtilityPole units", #poles == 2, tostring(#poles))
	for _, z in ipairs({ 98, 186 }) do
		local ok = false
		for _, u in ipairs(poles) do
			local a, b = box(u)
			if between((a.X + b.X) / 2, 266, 274) and near((a.Z + b.Z) / 2, z, 3) then ok = true end
		end
		check("a UtilityPole stands at x 266..274, z " .. z .. " (+-3)", ok)
	end
	check("at least 2 Transformer units", #units("Transformer") >= 2, tostring(#units("Transformer")))
	local wires, lowWire = withPrefix("PoleWire"), 0
	for _, p in ipairs(wires) do if lo(p, "Y") < 21.99 then lowWire += 1 end end
	check("at least 6 PoleWire parts, all with min y >= 22", #wires >= 6 and lowWire == 0, #wires .. " wires, " .. lowWire .. " low")
	for _, spec in ipairs({ { "Car", "car" }, { "Motorbike", "motorbike" } }) do
		local found
		for _, d in ipairs(ctx:GetDescendants()) do
			if d:IsA("Model") and d.Name:sub(1, #spec[1]) == spec[1] then found = d break end
		end
		local a, b
		if found then a, b = box(found) end
		check("a " .. spec[2] .. " Model (" .. spec[1] .. "*) stands in x 276..288, z 181..194",
			a ~= nil and a.X >= 275.9 and b.X <= 288.1 and a.Z >= 180.9 and b.Z <= 194.1, a and string.format("x %s..%s z %s..%s", fmt(a.X), fmt(b.X), fmt(a.Z), fmt(b.Z)) or "missing")
		check("the " .. spec[2] .. " is clear of DrivewayAsphalt", a ~= nil and drive ~= nil and (b.Z <= lo(drive, "Z") or a.Z >= hi(drive, "Z") or b.X <= lo(drive, "X") or a.X >= hi(drive, "X")),
			drive and "overlaps or missing" or "no DrivewayAsphalt")
	end
end)

------------------------------------------------------------------ clear: keep-clear zones, footprint, thin ground, depth
group("clear", function()
	for _, name in ipairs({ "Guide", "InfoPanel" }) do
		check("kept object present for the zone tests: " .. name, site:FindFirstChild(name) ~= nil)
	end
	local g = blockers(CFrame.new(262, 4, 140), Vector3.new(24, 8, 24))
	check("Guide keep-clear box (x 250..274, z 128..152, y 0..8) is free", #g == 0, list(g))
	local ip = blockers(CFrame.new(262, 4, 152), Vector3.new(12, 8, 12))
	check("InfoPanel front zone (x 256..268, z 146..158) is free", #ip == 0, list(ip))
	-- the aisle: z 138..142 from x 272 to 313, y 2..8, nothing colliding (rigs may stand in it)
	local lp = OverlapParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { site }
	lp.RespectCanCollide = true
	local lane = {}
	for _, h in ipairs(workspace:GetPartBoundsInBox(CFrame.new(292.5, 5, 140), Vector3.new(41, 6, 4), lp)) do
		if not isRig(h) then table.insert(lane, h.Name) end
	end
	check("aisle (x 272..313, z 138..142, y 2..8) is free", #lane == 0, list(lane))
	local rm = blockers(CFrame.new(236, 4, 140), Vector3.new(8, 8, 4))
	check("road mouth (x 232..240, z 138..142) is free", #rm == 0, list(rm))

	local out = {}
	for _, d in ipairs(own) do
		if lo(d, "X") < 236.9 or hi(d, "X") > 347.1 or lo(d, "Z") < 79.4 or hi(d, "Z") > 200.6 then table.insert(out, d.Name) end
	end
	check("every part is inside x 237..347, z 79.5..200.5", #out == 0, list(out))
	local thin = {}
	for _, d in ipairs(own) do
		if not isKept(d) and extent(d, "Y") <= 0.5 and lo(d, "Y") <= 0.35 and hi(d, "Y") <= 0.6 then
			if lo(d, "X") < 239.9 or hi(d, "X") > 344.1 or lo(d, "Z") < 83.9 or hi(d, "Z") > 196.1 then table.insert(thin, d.Name) end
		end
	end
	check("thin ground parts are inside x 240..344, z 84..196", #thin == 0, list(thin))
	local deep = {}
	for _, d in ipairs(own) do if lo(d, "Y") < -0.6 then table.insert(deep, d.Name) end end
	check("no part below y -0.6", #deep == 0, list(deep))
end)

return HttpService:JSONEncode(results)
