-- site07_check: the spec for Site 07 (The Farm at San Benito). Slice 20 fidelity spec, REWRITTEN for the BOARD rebuild
-- (Standard tier, 2026-10-31: "San_benito_blueprint.png", briefs/site07.md Revision 2). Written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site07_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site07_check:Clone())      -- returns JSON {passed, failed, failures}
-- Groups (set shared.site07_only = "general" | "entrance" | "south" | "centre" | "north" | "east" | "planting" | "ground" first to run one;
-- run_all leaves it nil and runs all; SET IT BACK TO nil after a filtered run).
-- Frame: WORLD coordinates (the builder is world-aligned; the site pivot (770, 0, 240) faces W). North = -Z, East = +X; the board's north
-- is world north. Slot x 570..970, z 80..400. Pins the board contradicts were REPLACED (never just deleted); each keeps its old text in a
-- "REPLACED (board)" comment and is listed in briefs/site07.md Revision 2.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(770, 0, 240)
local ONLY = shared.site07_only

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

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site07_Farm")
check("Site07_Farm exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end

local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true, LocalNPCs = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end
local function allNamed(name, root)
	local list = {}
	for _, d in ipairs((root or site):GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") and not isRig(d) then table.insert(list, d) end
	end
	return list
end
local function anchor(name) return allNamed(name)[1] end
local function find(path)
	local cur = site
	for seg in string.gmatch(path, "[^/]+") do
		cur = cur and cur:FindFirstChild(seg)
	end
	return cur
end
local function partsIn(inst)
	local list = {}
	if not inst then return list end
	for _, d in ipairs(inst:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then table.insert(list, d) end
	end
	return list
end
-- world-axis extent of a part (rotated corners included)
local function ext(p, axis)
	local lo, hi = math.huge, -math.huge
	local h = p.Size / 2
	for _, sx in ipairs({ -1, 1 }) do
		for _, sy in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local w = p.CFrame:PointToWorldSpace(Vector3.new(sx * h.X, sy * h.Y, sz * h.Z))
				lo, hi = math.min(lo, w[axis]), math.max(hi, w[axis])
			end
		end
	end
	return lo, hi
end
local function boundsOf(list)
	local b = { x0 = math.huge, x1 = -math.huge, y0 = math.huge, y1 = -math.huge, z0 = math.huge, z1 = -math.huge }
	for _, p in ipairs(list) do
		local a, c = ext(p, "X")
		b.x0, b.x1 = math.min(b.x0, a), math.max(b.x1, c)
		a, c = ext(p, "Y")
		b.y0, b.y1 = math.min(b.y0, a), math.max(b.y1, c)
		a, c = ext(p, "Z")
		b.z0, b.z1 = math.min(b.z0, a), math.max(b.z1, c)
	end
	return b
end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function bstr(b) return string.format("x %s..%s y %s..%s z %s..%s", fmt(b.x0), fmt(b.x1), fmt(b.y0), fmt(b.y1), fmt(b.z0), fmt(b.z1)) end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
local function brownRoof(p)
	local r, g, b = rgb(p)
	return r >= 100 and r <= 175 and g >= 55 and g <= 115 and b >= 30 and b <= 85 and r > g + 25 and g > b
end
local function waterBlue(p)
	local r, g, b = rgb(p)
	return b >= 140 and b > r + 60 and g >= 100
end
-- inside the land ellipse (the river's inner edge), with a margin
local function inLand(x, z, margin)
	local a, b = 182 - (margin or 0), 140 - (margin or 0)
	local dx, dz = (x - 770) / a, (z - 240) / b
	return dx * dx + dz * dz <= 1
end

------------------------------------------------------------------ general: pivot, slot, kept objects, required props, anchors, budget
if group("general") then
	local pv = site:GetPivot()
	-- REPLACED (board): "site pivot is at the SiteData pos (700, 0, 240), facing W" -> (770, 0, 240), the new 400 x 320 slot's centre.
	check("site pivot is at the SiteData pos (770, 0, 240), facing W",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(-1, 0, 0)) > 0.999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
	for name in pairs(KEPT) do check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil) end
	for _, name in ipairs({ "GardenPavilion", "LandscapedPath", "WellnessPanel" }) do
		local c = site:FindFirstChild(name)
		check("required prop present (a direct child holding parts): " .. name, c ~= nil and #partsIn(c) > 0)
	end
	check("Structure is a grouping Folder and no Block remains", site:FindFirstChild("Structure") ~= nil and site.Structure:IsA("Folder") and site:FindFirstChild("Block") == nil)
	for _, name in ipairs({ "VillaBody", "VillaRoof", "PoolWater", "PavilionDeck", "PathStart", "WellnessBoard" }) do
		check("anchor exists once: " .. name, #allNamed(name) == 1, tostring(#allNamed(name)))
	end
	-- every built part inside the slot x 570..970, z 80..400 (BuildCheck allows +10%; the board's oval is drawn inside the slot)
	local built, out, low = {}, {}, 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then
			table.insert(built, d)
			local x0, x1 = ext(d, "X")
			local z0, z1 = ext(d, "Z")
			if x0 < 570 - 0.01 or x1 > 970 + 0.01 or z0 < 80 - 0.01 or z1 > 400 + 0.01 then table.insert(out, d.Name) end
			local y0 = ext(d, "Y")
			if y0 < -1.01 then low += 1 end
		end
	end
	check("every built part lies inside the slot x 570..970, z 80..400", #out == 0, #out .. " out: " .. table.concat(out, ",", 1, math.min(#out, 4)))
	check("nothing reaches below y -1 (no terrain is cut; water parts are flush)", low == 0, tostring(low))
	-- REPLACED (board): "non-rig, non-kept part count is 600..1500" -> 1700..2400 (the plan's 2000..2300 for the board's zones; kept 67).
	check("non-rig, non-kept part count is 1700..2400", #built >= 1700 and #built <= 2400, tostring(#built))
	local total = 0
	for _, d in ipairs(site:GetDescendants()) do if d:IsA("BasePart") then total += 1 end end
	check("whole site (rigs and kept included) is at most 2500 parts (BuildCheck cap)", total <= 2500, tostring(total))
	-- every container (a Model or Folder whose own children are parts) holds at most 400 parts
	local big = {}
	for _, d in ipairs(site:GetDescendants()) do
		if (d:IsA("Model") or d:IsA("Folder")) and not isRig(d) and not isKept(d) then
			local n = 0
			for _, c in ipairs(d:GetChildren()) do if c:IsA("BasePart") then n += 1 end end
			if n > 400 then table.insert(big, d.Name .. "=" .. n) end
		end
	end
	check("no container holds more than 400 parts", #big == 0, table.concat(big, ","))
	-- text legibility (kept from Slice 20): every built label is fixed-size and fits its part
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
						table.insert(bad, string.format("%s: needs %.0fx%.0f px, has %.0fx%.0f", part.Name, textPx, lines * g.TextSize * 1.2, wPx, hPx))
					end
				end
			end
		end
	end
	check("every label is fixed-size and fits its part (no long TextScaled line)", #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	-- only the Wellness board carries text (no new on-screen text: no entrance lettering, no zone labels)
	local texts = {}
	for _, g in ipairs(site:GetDescendants()) do
		if g:IsA("TextLabel") and not isRig(g) and not isKept(g) then
			local gui = g:FindFirstAncestorOfClass("SurfaceGui")
			table.insert(texts, gui and gui.Parent and gui.Parent.Name or "?")
		end
	end
	check("the only built text is on the WellnessBoard", #texts == 1 and texts[1] == "WellnessBoard", table.concat(texts, ","))
end

------------------------------------------------------------------ entrance: river ring, bridge at the road mouth, gate, guard post
if group("entrance") then
	local water = allNamed("RiverWater")
	check("the river ring has at least 40 RiverWater parts", #water >= 40, tostring(#water))
	local quad, flush, inside, colour = { N = 0, S = 0, W = 0, E = 0 }, 0, 0, 0
	for _, w in ipairs(water) do
		local p = w.Position
		if p.Z < 115 then quad.N += 1 end
		if p.Z > 365 then quad.S += 1 end
		if p.X < 600 then quad.W += 1 end
		if p.X > 940 then quad.E += 1 end
		local y0, y1 = ext(w, "Y")
		if y1 >= 0.95 and y1 <= 1.4 and y0 >= -1 then flush += 1 end
		if inLand(p.X, p.Z, 2) then inside += 1 end
		if waterBlue(w) then colour += 1 end
	end
	check("the river runs round all four sides of the oval (North and South river edges, both tips)",
		quad.N >= 4 and quad.S >= 4 and quad.W >= 2 and quad.E >= 2, string.format("N %d S %d W %d E %d", quad.N, quad.S, quad.W, quad.E))
	-- REPLACED (owner's look, tidy 2026-10-31): "river water is flush with the ground (top y 0..0.3)" -> top 0.95..1.4: terrain Grass draws
	-- its blades up to about y 0.9 and poked through the flush parts.
	check("river water tops at y 0.95..1.4 (above the rendered grass)", #water > 0 and flush == #water, flush .. "/" .. #water)
	check("no river part lies inside the land ellipse", #water > 0 and inside == 0, tostring(inside))
	check("river water is blue", #water > 0 and colour == #water, colour .. "/" .. #water)
	-- tidy: one opaque deep blue-teal, SmoothPlastic (overlapping see-through Glass chords read as tiles with light seams)
	local same = #water > 0
	for _, w in ipairs(water) do
		if w.Transparency > 0.05 or w.Material ~= Enum.Material.SmoothPlastic or w.Color ~= water[1].Color then same = false end
	end
	local r0, g0, b0 = 0, 0, 0
	if #water > 0 then r0, g0, b0 = rgb(water[1]) end
	check("river water is one opaque deep blue-teal (transparency <= 0.05, SmoothPlastic, one colour, r <= 60, b <= 175)", same and r0 <= 60 and b0 <= 175,
		string.format("%.0f,%.0f,%.0f", r0, g0, b0))
	local banks = allNamed("RiverBank")
	check("the river has banks (>= 40 RiverBank strips)", #banks >= 40, tostring(#banks))

	local bridge = anchor("EntryBridge")
	if bridge then
		local x0, x1 = ext(bridge, "X")
		local z0, z1 = ext(bridge, "Z")
		local _, y1 = ext(bridge, "Y")
		check("EntryBridge crosses the river at the road mouth (x 572..592, covering z 234..246)",
			x0 <= 574 and x1 >= 590 and x0 >= 569.9 and z0 <= 234 and z1 >= 246, string.format("x %s..%s z %s..%s", fmt(x0), fmt(x1), fmt(z0), fmt(z1)))
		-- REPLACED (tidy): "bridge deck is low (top <= 1.2, walkable)" -> top 1.3..2.0, above the raised water, with ramps at both ends.
		check("bridge deck tops at 1.3..2.0 (above the water) with a ramp at each end", y1 >= 1.3 and y1 <= 2.0 and #allNamed("BridgeRamp") == 2, fmt(y1))
	else
		check("EntryBridge exists", false)
	end
	local rails = allNamed("BridgeRail")
	local railOk = #rails >= 2
	for _, r in ipairs(rails) do
		local y0, y1 = ext(r, "Y")
		local z0, z1 = ext(r, "Z")
		if y1 - math.max(y0, 0.5) < 2.8 or (z1 > 233 and z0 < 247) then railOk = false end
	end
	check("bridge railings 3 high on both edges, outside the drive (z 233..247)", railOk, tostring(#rails))

	local gate = find("Structure/Entrance")
	local piers = allNamed("GatePier", gate)
	local north, south, tall = 0, 0, 0
	for _, p in ipairs(piers) do
		local z0, z1 = ext(p, "Z")
		if z1 <= 232 then north += 1 end
		if z0 >= 248 then south += 1 end
		local _, y1 = ext(p, "Y")
		if y1 >= 10 then tall += 1 end
	end
	check("main entrance gate: piers either side of the drive, at least 10 high", #piers >= 2 and north >= 1 and south >= 1 and tall == #piers,
		string.format("%d piers, N %d S %d tall %d", #piers, north, south, tall))
	local beam = anchor("GateBeam")
	local by0 = beam and ext(beam, "Y")
	check("the gate beam spans the drive above head height (bottom >= 9)", beam ~= nil and by0 >= 9, fmt(by0))
	local gx = beam and beam.Position.X
	check("the gate stands just inside the bridge (x 600..640)", gx ~= nil and gx >= 600 and gx <= 640, fmt(gx))
	local booth = anchor("GuardPostBody")
	check("guard post booth beside the drive, past the gate (x 600..660, z < 232)", booth ~= nil and booth.Position.X >= 600 and booth.Position.X <= 660
		and select(2, ext(booth, "Z")) <= 232, booth and tostring(booth.Position) or "missing")
	local door = anchor("GuardPostDoor")
	local dh = door and (select(2, ext(door, "Y")) - select(1, ext(door, "Y")))
	check("guard post door is at least 8 tall (human scale)", dh ~= nil and dh >= 8, fmt(dh))
	local roofs = allNamed("GuardPostRoof")
	check("guard post has a brown hip roof", #roofs >= 1 and brownRoof(roofs[1]), tostring(#roofs))
end

------------------------------------------------------------------ south: Banaba hall over the old lagoon, parking, Acqua pools
if group("south") then
	local hall = anchor("BanabaHallBody")
	local hb = hall and boundsOf({ hall })
	check("Banaba function hall: a long block (>= 60 along x) south of the Guide (z > 300)", hb ~= nil and hb.x1 - hb.x0 >= 60 and hb.z0 > 300,
		hb and bstr(hb) or "missing")
	check("Banaba hall is two storeys (top >= 18)", hb ~= nil and hb.y1 >= 18, hb and fmt(hb.y1) or "missing")
	local hroofs = allNamed("BanabaRoof")
	local brown = 0
	for _, r in ipairs(hroofs) do if brownRoof(r) then brown += 1 end end
	check("Banaba hall has at least 3 brown hip roof sections", #hroofs >= 3 and brown == #hroofs, brown .. "/" .. #hroofs)
	local court = anchor("BanabaCourt")
	local cb = court and boundsOf({ court })
	check("BanabaCourt covers the old terrain lagoon (x 700..800, z 300..352) with a slab buried below the water (y0 <= -0.3)",
		cb ~= nil and cb.x0 <= 699 and cb.x1 >= 801 and cb.z0 <= 299 and cb.z1 >= 353 and cb.y0 <= -0.3, cb and bstr(cb) or "missing")
	local lot = anchor("ParkingLot")
	local lb = lot and boundsOf({ lot })
	check("ParkingLot lies west of the Banaba hall and south of the drive (board: parking beside the hall)",
		lb ~= nil and hb ~= nil and lb.x1 <= hb.x0 + 2 and lb.z0 >= 280, lb and bstr(lb) or "missing")
	check("parking has >= 10 bay lines and >= 4 cars", #allNamed("ParkingLine") >= 10 and #allNamed("CarBody") >= 4,
		#allNamed("ParkingLine") .. " lines, " .. #allNamed("CarBody") .. " cars")
	local pools = allNamed("AcquaPool")
	local west = 0
	for _, p in ipairs(pools) do if p.Position.X < 656 and p.Position.Z > 250 then west += 1 end end
	check("Acqua Hydrotherapy: at least 4 pools west of the plaza and south of the drive", #pools >= 4 and west == #pools, west .. "/" .. #pools)
	local pw = anchor("PoolWater")
	-- REPLACED (board): "pool water is dark teal (r <= 40, g <= 115, b <= 112)" (the villa photo) -> the board's bright pool blue.
	check("PoolWater (the main Acqua pool) is the board's pool blue", pw ~= nil and waterBlue(pw), pw and string.format("%.0f,%.0f,%.0f", rgb(pw)) or "missing")
	check("pool water stays see-through (transparency 0.05..0.3)", pw ~= nil and pw.Transparency >= 0.05 and pw.Transparency <= 0.3, pw and fmt(pw.Transparency) or "missing")
	-- REPLACED (board): "pool wall has >= 10 stone-block joints" (CopingJoint, the villa photo) -> every Acqua pool has a coping.
	check("Acqua pools sit in a stone deck with copings (>= 4 AcquaCoping)", #allNamed("AcquaCoping") >= 4, tostring(#allNamed("AcquaCoping")))
	check("Acqua has at least 2 hip-roof cabanas", #allNamed("CabanaRoof") >= 2, tostring(#allNamed("CabanaRoof")))
end

------------------------------------------------------------------ centre: the look-at group (round thatched pavilion beside the villa, path), amphitheater
if group("centre") then
	-- 3 (kept from Slice 20): smooth round thatched cone (12 tiers)
	local tiers = allNamed("PavilionThatch")
	table.sort(tiers, function(a, b) return a.Position.Y < b.Position.Y end)
	check("thatched cone has 12 tiers", #tiers == 12, tostring(#tiers))
	local mono, maxd, mind = true, 0, math.huge
	for i, t in ipairs(tiers) do
		local d = math.max(t.Size.Y, t.Size.Z)
		maxd, mind = math.max(maxd, d), math.min(mind, d)
		if i > 1 then
			local prev = math.max(tiers[i - 1].Size.Y, tiers[i - 1].Size.Z)
			if d > prev + 0.01 then mono = false end
		end
	end
	check("cone narrows from the eave (widest >= 17, narrowest <= 2.5)", #tiers > 0 and maxd >= 17 and mind <= 2.5, fmt(maxd) .. " / " .. fmt(mind))
	check("every tier is narrower than the one below", mono)
	local steps = 0
	for i = 2, #tiers do
		local d, prev = math.max(tiers[i].Size.Y, tiers[i].Size.Z), math.max(tiers[i - 1].Size.Y, tiers[i - 1].Size.Z)
		if prev - d > 2.2 then steps += 1 end
	end
	check("no step between tiers is wider than 2.2 studs (smooth profile)", #tiers > 0 and steps == 0, tostring(steps))
	check("a finial caps the cone", anchor("PavilionFinial") ~= nil)
	local gp = site:FindFirstChild("GardenPavilion")
	check("the thatch tiers and the deck are inside GardenPavilion", gp ~= nil and #allNamed("PavilionThatch", gp) == 12 and #allNamed("PavilionDeck", gp) == 1)
	local deck, body = anchor("PavilionDeck"), anchor("VillaBody")
	local glass = allNamed("VillaGlassPane")
	-- the look-at line "the round thatched pavilion beside the straight-edged villa": the deck centre is within 40 studs of the glass front
	local nearest = math.huge
	if deck then
		for _, g in ipairs(glass) do
			nearest = math.min(nearest, Vector3.new(g.Position.X - deck.Position.X, 0, g.Position.Z - deck.Position.Z).Magnitude)
		end
	end
	check("the round thatched pavilion stands beside the villa (deck within 40 studs of the glass front)", nearest <= 40, fmt(nearest))
	check("the pavilion stands north-west of the villa body and north of the amphitheater", deck ~= nil and body ~= nil and deck.Position.Z < body.Position.Z - 15
		and deck.Position.X < body.Position.X and anchor("AmphiStage") ~= nil and deck.Position.Z < anchor("AmphiStage").Position.Z - 20,
		deck and body and (tostring(deck.Position) .. " vs " .. tostring(body.Position)) or "missing")
	local deckTop = deck and select(2, ext(deck, "Y"))
	check("the pavilion floor is raised (top 0.8..1.2) so the yoga guest rests on it", deckTop ~= nil and deckTop >= 0.8 and deckTop <= 1.2, fmt(deckTop))
	-- the villa: straight-edged, glass on the west face, brown hip roof (board)
	check("villa has at least 6 glass panes on its west face", #glass >= 6, tostring(#glass))
	local roof = anchor("VillaRoof")
	-- REPLACED (board): "wings have 6 timber posts" and "posts stand ground to eave on the screen line" (WingPost, the villa photo's
	-- wings) -> the board's villas have brown hip roofs: VillaRoof is brown and its eave is at least 11 high.
	check("villa roof is the board's brown", roof ~= nil and brownRoof(roof), roof and string.format("%.0f,%.0f,%.0f", rgb(roof)) or "missing")
	check("villa roof eave is at least 11 high (doors and glass below)", roof ~= nil and ext(roof, "Y") >= 11, roof and fmt(ext(roof, "Y")) or "missing")
	-- the patterned path: white inlays on the dark pebble path, in view of the Guide
	local inlays = allNamed("PathInlay")
	local nearGuide = 0
	for _, p in ipairs(inlays) do
		if Vector3.new(p.Position.X - 670, 0, p.Position.Z - 240).Magnitude <= 100 then nearGuide += 1 end
	end
	check("the patterned path: >= 20 white PathInlay parts within 100 studs of the Guide", nearGuide >= 20, nearGuide .. "/" .. #inlays)
	-- amphitheater: octagonal seat tiers rising outward around a stage, low enough for the sight-lines (top <= 3.5)
	local amphi = find("Structure/Amphitheater")
	local amTiers = allNamed("AmphiTier", amphi)
	local ab = boundsOf(amTiers)
	check("amphitheater has >= 24 AmphiTier segments (3+ octagonal tiers)", #amTiers >= 24, tostring(#amTiers))
	check("amphitheater stands east of the Guide on the central plaza (x 715..775, z 220..280), top <= 3.5",
		#amTiers > 0 and ab.x0 >= 715 and ab.x1 <= 775 and ab.z0 >= 220 and ab.z1 <= 280 and ab.y1 <= 3.5, bstr(ab))
	local stage = anchor("AmphiStage")
	check("the stage is at the amphitheater's centre", stage ~= nil and #amTiers > 0 and math.abs(stage.Position.X - (ab.x0 + ab.x1) / 2) <= 3
		and math.abs(stage.Position.Z - (ab.z0 + ab.z1) / 2) <= 3, stage and tostring(stage.Position) or "missing")
end

------------------------------------------------------------------ north: Big Lagoon with its pavilion, Temple of Five Elements, labyrinth
if group("north") then
	local lw = allNamed("LagoonWater")
	local lb = boundsOf(lw)
	check("Big Lagoon: water north of the plaza (z < 200), x 710..810, at least 60 x 45", #lw >= 3 and lb.z1 <= 200 and lb.x0 >= 710 and lb.x1 <= 810
		and lb.x1 - lb.x0 >= 60 and lb.z1 - lb.z0 >= 45, bstr(lb))
	local fl = 0
	for _, w in ipairs(lw) do local y0, y1 = ext(w, "Y") if y1 >= 0.95 and y1 <= 1.4 and y0 >= -1 then fl += 1 end end
	-- REPLACED (tidy): "lagoon water is flush with the ground and blue" (top 0..0.3) -> top 0.95..1.4, above the rendered grass.
	check("lagoon water tops at y 0.95..1.4 and is blue", #lw > 0 and fl == #lw and waterBlue(lw[1]), fl .. "/" .. #lw)
	local lroof = allNamed("LagoonPavilionRoof")
	local lfloor = anchor("LagoonPavilionDeck")
	check("the lagoon pavilion (hip roof, board inset D) stands on a deck at the water's edge",
		#lroof >= 1 and brownRoof(lroof[1]) and lfloor ~= nil and #lw > 0 and lfloor.Position.X >= lb.x0 and lfloor.Position.X <= lb.x1
		and lfloor.Position.Z >= lb.z0 and lfloor.Position.Z <= lb.z1 + 6, lfloor and tostring(lfloor.Position) or "missing")
	local trail = allNamed("LagoonRail")
	check("the lagoon deck has railings 3 high", #trail >= 2 and (select(2, ext(trail[1], "Y")) - select(1, ext(trail[1], "Y"))) >= 2.9, tostring(#trail))
	local troof = allNamed("TempleRoof")
	local plinth = anchor("TemplePlinth")
	check("Temple of Five Elements: a hip-roofed pavilion on a plinth, west of the lagoon and north of the plaza",
		#troof >= 1 and brownRoof(troof[1]) and plinth ~= nil and #lw > 0 and plinth.Position.X < lb.x0 and plinth.Position.Z < 192,
		plinth and tostring(plinth.Position) or "missing")
	local rings = allNamed("LabyrinthRing")
	check("labyrinth garden: >= 5 concentric rings in front (south) of the temple", #rings >= 5 and plinth ~= nil
		and rings[1].Position.Z > plinth.Position.Z + 10, #rings .. " rings")
	local fountain = anchor("LabyrinthFountain")
	check("a fountain marks the labyrinth's centre", fountain ~= nil)
	-- tidy (owner's look): the board's many small brown hip-roof villas (Garden Glass, Acacia, Mahogany) along the north and west edges
	local sv = find("Structure/SmallVillas")
	local nN, nW, okV, all = 0, 0, true, 0
	for _, m in ipairs(sv and sv:GetChildren() or {}) do
		if m:IsA("Model") and m.Name:match("^SmallVilla%d+$") then
			all += 1
			local body, roof = m:FindFirstChild("SmallVillaBody"), m:FindFirstChild("SmallVillaRoof")
			if not (body and roof and brownRoof(roof)) or #partsIn(m) > 12 or not inLand(body.Position.X, body.Position.Z, 4) then okV = false
			else
				if body.Position.Z < 135 then nN += 1 end
				if body.Position.X < 650 then nW += 1 end
			end
		end
	end
	check("at least 8 small brown hip-roof villas: 3+ on the north edge (z < 135), 4+ on the west (x < 650), each <= 12 parts, inside the land",
		all >= 8 and okV and nN >= 3 and nW >= 4, string.format("%d villas, N %d W %d ok %s", all, nN, nW, tostring(okV)))
end

------------------------------------------------------------------ east: Narra pool villas, Front Office and lagoon, Holistic Medical Sanctuary
if group("east") then
	local villas = {}
	local root = find("Structure/NarraVillas")
	for _, m in ipairs(root and root:GetChildren() or {}) do
		if m:IsA("Model") and m.Name:match("^NarraVilla%d$") then table.insert(villas, m) end
	end
	check("a row of exactly 3 Narra pool villas", #villas == 3, tostring(#villas))
	local ok = #villas == 3
	local xs = {}
	for _, v in ipairs(villas) do
		local house, water = v:FindFirstChild("NarraVillaBody", true), v:FindFirstChild("NarraPoolWater", true)
		if not (house and water) then ok = false else
			table.insert(xs, house.Position.X)
			if not (house.Position.X > 800 and house.Position.Z < 175) then ok = false end
			if (house.Position - water.Position).Magnitude > 20 or not waterBlue(water) then ok = false end
			local r = v:FindFirstChild("NarraRoof", true)
			if not (r and brownRoof(r)) then ok = false end
		end
	end
	check("each Narra villa: body in the NE (x > 800, z < 175) along the North river, brown roof, private blue pool beside it", ok)
	table.sort(xs)
	check("the three villas stand in a row (spaced >= 20 along x)", #xs == 3 and xs[2] - xs[1] >= 20 and xs[3] - xs[2] >= 20, table.concat(xs, ","))
	local office = anchor("FrontOfficeBody")
	local fw = allNamed("FrontLagoonWater")
	local fb = boundsOf(fw)
	check("Front Office in the east (x > 840, z 220..280), its lagoon east of it", office ~= nil and office.Position.X > 840 and office.Position.Z > 220
		and office.Position.Z < 280 and #fw >= 1 and fb.x0 >= select(2, ext(office, "X")) - 2, office and tostring(office.Position) or "missing")
	check("Front Office has a brown hip roof", #allNamed("FrontOfficeRoof") >= 1 and brownRoof(allNamed("FrontOfficeRoof")[1]))
	local san = anchor("SanctuaryBody")
	local sb = san and boundsOf({ san })
	check("Holistic Medical Sanctuary: a long block (>= 60) in the SE (x > 820, z > 280), south of the Front Office",
		sb ~= nil and sb.x1 - sb.x0 >= 60 and sb.x0 > 820 and sb.z0 > 280 and office ~= nil and san.Position.Z > office.Position.Z + 20, sb and bstr(sb) or "missing")
	check("the Sanctuary is two storeys (top >= 18) under >= 2 brown roofs", sb ~= nil and sb.y1 >= 18 and #allNamed("SanctuaryRoof") >= 2
		and brownRoof(allNamed("SanctuaryRoof")[1]), sb and fmt(sb.y1) or "missing")
end

------------------------------------------------------------------ planting: dense palms (4, kept rules), trees, shrubs
if group("planting") then
	local trunks, fronds = allNamed("PalmTrunk"), allNamed("PalmFrond")
	local byPalm = {}
	for _, t in ipairs(trunks) do
		local key = string.format("%.0f,%.0f", t.Position.X, t.Position.Z)
		byPalm[key] = math.max(byPalm[key] or 0, select(2, ext(t, "Y")))
	end
	local palms, tall = 0, 0
	for _, h in pairs(byPalm) do palms += 1; if h >= 15.5 then tall += 1 end end
	-- REPLACED (board): "19 palms" -> at least 60 (the board's dense palms).
	check("dense palms: at least 60", palms >= 60, tostring(palms))
	check("every palm is at least 15.5 tall", palms > 0 and tall == palms, tall .. "/" .. palms)
	-- REPLACED (board): "8 fronds per palm (152)" -> 6 fronds per palm (the part budget of 60+ palms).
	check("6 fronds per palm", #fronds == 6 * palms, #fronds .. " for " .. palms)
	local long, collide = 0, 0
	for _, f in ipairs(fronds) do
		if math.max(f.Size.X, f.Size.Z) >= 8.5 then long += 1 end
		if f.CanCollide then collide += 1 end
	end
	check("fronds are at least 8.5 long", #fronds > 0 and long == #fronds, long .. "/" .. #fronds)
	check("fronds do not collide", collide == 0, tostring(collide))
	check("broadleaf trees too (>= 30 TreeCrown)", #allNamed("TreeCrown") >= 30, tostring(#allNamed("TreeCrown")))
	-- tidy (owner's look): the board is mostly green canopy. Seen from above, palm fronds and tree crowns are the first thing hit at >= 30%
	-- of a 6-stud grid over the land ellipse (it was 9.3% before the tidy pass).
	do
		local ex = {}
		for _, n in ipairs({ "Guide", "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney", "LocalNPCs" }) do
			local c = site:FindFirstChild(n)
			if c then table.insert(ex, c) end
		end
		local p = RaycastParams.new()
		p.FilterType = Enum.RaycastFilterType.Exclude
		p.FilterDescendantsInstances = ex
		local CAN = { PalmFrond = true, PalmHead = true, TreeCrown = true }
		local n, can = 0, 0
		for x = 590, 950, 6 do
			for z = 102, 378, 6 do
				if inLand(x, z, 2) then
					n += 1
					local h = workspace:Raycast(Vector3.new(x, 80, z), Vector3.new(0, -160, 0), p)
					if h and CAN[h.Instance.Name] and h.Instance:IsDescendantOf(site) then can += 1 end
				end
			end
		end
		check("dense canopy: fronds and crowns cover >= 30% of the land from above", n > 0 and can / n >= 0.30, string.format("%.1f%% of %d", 100 * can / math.max(n, 1), n))
	end
	-- forest beyond the river as on the board: some trees or palms outside the river's outer edge
	local outside = 0
	for _, list in ipairs({ trunks, allNamed("TreeTrunk") }) do
		for _, t in ipairs(list) do
			local dx, dz = (t.Position.X - 770) / 196, (t.Position.Z - 240) / 154
			if dx * dx + dz * dz > 1 then outside += 1 end
		end
	end
	check("forest beyond the river: >= 8 trunks outside the ring", outside >= 8, tostring(outside))
	-- no trunk stands in the river
	local wet = 0
	for _, list in ipairs({ trunks, allNamed("TreeTrunk") }) do
		for _, t in ipairs(list) do
			local dx, dz = (t.Position.X - 770) / 198, (t.Position.Z - 240) / 156
			local ix, iz = (t.Position.X - 770) / 180, (t.Position.Z - 240) / 138
			if dx * dx + dz * dz <= 1 and ix * ix + iz * iz >= 1 then wet += 1 end
		end
	end
	check("no trunk stands in the river band", wet == 0, tostring(wet))
end

------------------------------------------------------------------ ground: the old Pavement and Water terrain is covered by parts
if group("ground") then
	local exclude = {}
	for _, n in ipairs({ "Guide", "InfoPanel", "JeepStop", "JeepSignPole", "JeepSign", "Jeepney", "LocalNPCs" }) do
		local c = site:FindFirstChild(n)
		if c then table.insert(exclude, c) end
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = exclude
	-- the Pavement regions P1..P5 of the Slice 09 build and the terrain Water x 700..800, z 300..352; the kept-object holes are skipped
	local regions = { { 572, 652, 232, 248 }, { 652, 700, 192, 260 }, { 700, 796, 204, 276 }, { 692, 708, 260, 300 }, { 708, 752, 284, 300 }, { 700, 800, 300, 352 } }
	local holes = { { 662, 678, 195, 228 }, { 665, 675, 235, 245 }, { 673, 679, 243, 261 } }
	local bare, n = {}, 0
	for _, r in ipairs(regions) do
		for x = r[1] + 1, r[2] - 1, 4 do
			for z = r[3] + 1, r[4] - 1, 4 do
				local hole = false
				for _, h in ipairs(holes) do if x > h[1] and x < h[2] and z > h[3] and z < h[4] then hole = true end end
				if not hole then
					n += 1
					local hit = workspace:Raycast(Vector3.new(x, 60, z), Vector3.new(0, -120, 0), params)
					if not hit or not hit.Instance:IsDescendantOf(site) then table.insert(bare, x .. "," .. z) end
				end
			end
		end
	end
	check("every old Pavement / Water cell is covered by a site part (" .. n .. " samples)", #bare == 0, #bare .. " bare: " .. table.concat(bare, " ", 1, math.min(#bare, 6)))
	-- tidy (owner's look): no big grey courts. Ground-level stone, concrete and pebble (paths, plazas, decks, parking) is the first thing hit
	-- at <= 15% of a 6-stud grid over the land ellipse (it was 29.3%: the central plaza and the Banaba court).
	local PAVED = { [Enum.Material.Slate] = true, [Enum.Material.Concrete] = true, [Enum.Material.Pebble] = true }
	local m, paved = 0, 0
	for x = 590, 950, 6 do
		for z = 102, 378, 6 do
			if inLand(x, z, 2) then
				m += 1
				local h = workspace:Raycast(Vector3.new(x, 80, z), Vector3.new(0, -160, 0), params)
				local i = h and h.Instance
				if i and i:IsDescendantOf(site) and h.Position.Y < 1.6 and PAVED[i.Material] and not i.Name:find("Water") and not i.Name:find("Pool") then paved += 1 end
			end
		end
	end
	check("paved ground covers <= 15% of the land from above (paths and small terraces, not courts)", m > 0 and paved / m <= 0.15,
		string.format("%.1f%% of %d", 100 * paved / math.max(m, 1), m))
	-- every water part tops at >= 0.95, above the rendered grass blades (rivers, lagoons and pools)
	local low = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and (d.Name:find("Water") or d.Name == "AcquaPool") and not d.Name:find("Fountain") then
			local _, y1 = ext(d, "Y")
			if y1 < 0.95 then table.insert(low, d.Name) end
		end
	end
	check("every river, lagoon and pool water part tops at y >= 0.95", #low == 0, #low .. " low: " .. table.concat(low, ",", 1, math.min(#low, 4)))
	-- grass cleanup (owner, 2026-10-31): terrain Grass draws blades ~0.9 above its surface, through thin parts. builders/site07_ground.luau
	-- repaints the terrain under every ground-level water, path, deck, court and floor part (padded 1 voxel) to Mud / Ground / Pavement.
	-- Each named part is sampled at its centre and 4 points 1.5 studs inside its footprint: the top voxel there is not Grass.
	local T = workspace.Terrain
	local function topMat(x, z)
		local mats, occ = T:ReadVoxels(Region3.new(Vector3.new(x - 0.01, -8, z - 0.01), Vector3.new(x + 0.01, 4, z + 0.01)):ExpandToGrid(4), 4)
		for y = mats.Size.Y, 1, -1 do
			if occ[1][y][1] > 0 then return mats[1][y][1] end
		end
		return Enum.Material.Air
	end
	local function samplePoints(p)
		local cf, s = p.CFrame, p.Size
		local ax = { { cf.RightVector, s.X }, { cf.UpVector, s.Y }, { cf.LookVector, s.Z } }
		table.sort(ax, function(a, b) return math.abs(a[1].Y) > math.abs(b[1].Y) end)
		local c = Vector3.new(cf.X, 0, cf.Z)
		local u, v = Vector3.new(ax[2][1].X, 0, ax[2][1].Z).Unit, Vector3.new(ax[3][1].X, 0, ax[3][1].Z).Unit
		local hu, hv = math.max(ax[2][2] / 2 - 1.5, 0), math.max(ax[3][2] / 2 - 1.5, 0)
		if p:IsA("Part") and p.Shape == Enum.PartType.Cylinder then hu, hv = hu * 0.7, hv * 0.7 end
		return { c, c + u * hu + v * hv, c + u * hu - v * hv, c - u * hu + v * hv, c - u * hu - v * hv }
	end
	local NO_GRASS = { "RiverWater", "LagoonWater", "FrontLagoonWater", "PoolWater", "NarraPoolWater", "SmallPoolWater", "AcquaPool",
		"EntryPath", "PathSegment", "LabyrinthPath", "SouthWalk", "ParkingLot", "ParkingDrive", "AmphiTier", "LagoonPavilionDeck",
		"LagoonBoardwalk", "NarraDeck", "AcquaDeck", "SmallPoolDeck", "VillaBody", "NarraVillaBody", "SmallVillaBody", "FrontOfficePlinth",
		"SanctuaryPlinth", "TemplePlinth", "GuardPostBody", "BanabaHallBody", "EntryBridge" }
	local grassy, samples, missing = {}, 0, {}
	for _, name in ipairs(NO_GRASS) do
		local list = allNamed(name)
		if #list == 0 then table.insert(missing, name) end
		for _, p in ipairs(list) do
			for _, q in ipairs(samplePoints(p)) do
				samples += 1
				if topMat(q.X, q.Z) == Enum.Material.Grass then table.insert(grassy, name .. "@" .. math.floor(q.X) .. "," .. math.floor(q.Z)) end
			end
		end
	end
	check("every no-grass part name is present (" .. #NO_GRASS .. " names)", #missing == 0, table.concat(missing, ","))
	check("no terrain Grass under water, paths, decks, courts or floors (" .. samples .. " samples)", #grassy == 0,
		#grassy .. " grassy: " .. table.concat(grassy, " ", 1, math.min(#grassy, 6)))
	-- the lawns stay Grass: a lawn point clear of every ground part (only tree crowns above it)
	check("lawn control (840, 200) is still terrain Grass", topMat(840, 200) == Enum.Material.Grass, topMat(840, 200).Name)
end

return HttpService:JSONEncode(results)
