-- site09_check: the Slice 22 fidelity spec for Site 09 (Tagbakin, Brgy. Halang), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site09_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site09_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site09.md "Revision 1 (Slice 22)": Tagbakin_Shoreline_Building_From_Lake.jpg (the generic lakeshore building;
-- never called glamping). The building is built in a local frame (the site is yawed NE), so the checks use part names, sizes, colours and materials.
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(-600, 0, 550)

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site09_Tagbakin")
check("Site09_Tagbakin exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
do
	local pv = site:GetPivot()
	local s = math.sqrt(0.5)
	check("site pivot is at the SiteData pos (-600, 0, 550), facing NE",
		(pv.Position - SITE_POS).Magnitude < 0.05 and pv.LookVector:Dot(Vector3.new(s, 0, -s)) > 0.999,
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
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end

local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end

------------------------------------------------------------------ Kept objects, required props, anchors
do
	for name in pairs(KEPT) do check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil) end
	for _, name in ipairs({ "LocationMapPanel", "FishingActivity", "Dock", "Bancas" }) do
		check("required prop present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	for _, name in ipairs({ "ShoreBody", "PavilionL", "PavilionR", "CentreDoor", "Terrace" }) do
		check("anchor exists: " .. name, #allNamed(name) == 1)
	end
end

------------------------------------------------------------------ 1: small windows (one ground, one upper per pavilion), like the photo
do
	local win = allNamed("ShoreWindow")
	check("8 lake-facade windows (4 on the pavilions, 4 on the centre bay)", #win == 8, tostring(#win))
	local big = 0
	for _, w in ipairs(win) do if w.Size.X >= 4.9 then big += 1 end end
	check("no window is the old 5-wide pane", big == 0, tostring(big))
end

------------------------------------------------------------------ 2: grey roofs, no metal sheen (it reflected the sky blue)
do
	local metal, offcolour = {}, {}
	for _, name in ipairs({ "ShoreRoofDeck", "PavilionTier1L", "PavilionTier2L", "PavilionRoofL", "PavilionTier1R", "PavilionTier2R", "PavilionRoofR", "EntryCanopy", "RearCanopy" }) do
		for _, p in ipairs(allNamed(name)) do
			if p.Material == Enum.Material.Metal then table.insert(metal, name) end
			local r, g, b = rgb(p)
			if not (math.abs(r - g) <= 8 and math.abs(g - b) <= 8 and r >= 110 and r <= 185) then table.insert(offcolour, name) end
		end
	end
	check("roofs and canopies are not Metal", #metal == 0, table.concat(metal, ","))
	check("roofs and canopies are neutral grey (r 110..185)", #offcolour == 0, table.concat(offcolour, ","))
end

------------------------------------------------------------------ 3: warm sandy yard
do
	local t = allNamed("Terrace")[1]
	if t then
		local r, g, b = rgb(t)
		check("yard is warm sand (r 205..222, g 180..196, b 138..156)", r >= 205 and r <= 222 and g >= 180 and g <= 196 and b >= 138 and b <= 156, string.format("%.0f,%.0f,%.0f", r, g, b))
	end
	local strips = allNamed("PromenadeStrip")
	local cold = 0
	for _, s in ipairs(strips) do local r, _, b = rgb(s); if b > r - 30 then cold += 1 end end
	check("promenade strips are warm too", #strips > 0 and cold == 0, cold .. " cold of " .. #strips)
end

------------------------------------------------------------------ 4: text legibility
do
	local bad = {}
	for _, g in ipairs(site:GetDescendants()) do
		-- Labels inside a Frame are scaled into a bounded box (the map board's layout), which is fine; a long label sitting directly
		-- on the SurfaceGui is the TextScaled bug of Slices 17 to 21.
		if g:IsA("TextLabel") and not isRig(g) and not isKept(g) and not g.Parent:IsA("Frame") then
			local gui = g:FindFirstAncestorOfClass("SurfaceGui")
			local part = gui and gui.Parent
			if gui and part and part:IsA("BasePart") then
				local len = #g.Text
				if g.TextScaled and len > 14 then
					table.insert(bad, part.Name .. ": TextScaled on a " .. len .. "-char line '" .. g.Text:sub(1, 20) .. "'")
				end
			end
		end
	end
	check("no long TextScaled line sits directly on a board", #bad == 0, #bad .. " bad: " .. table.concat(bad, "; ", 1, math.min(#bad, 4)))
	-- The map's 123-character description needs a wide column: at 34% of the board its type was tiny.
	local desc
	for _, g in ipairs(site:GetDescendants()) do
		if g:IsA("TextLabel") and g.Text:sub(1, 16) == "Tagbakin sits on" then desc = g end
	end
	check("map description column is at least 45% of the board wide", desc ~= nil and desc.Size.X.Scale >= 0.45, desc and tostring(desc.Size.X.Scale) or "label missing")
end

------------------------------------------------------------------ Part budget
do
	local n = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and not isKept(d) then n += 1 end
	end
	check("non-rig, non-kept part count is 250..900", n >= 250 and n <= 900, tostring(n))
end

------------------------------------------------------------------ Taal (Revision 2): the volcano island across the lake, in front of the lake facade
-- Reference: "2nd Reference/tagbakin_halang/taal volcano-in-front-of-tagbakin-halang-structure/caption.jpg" (from a boat): a low wide
-- green cone whose top is a crater with two peaks (the right one higher), a dip between them and a bare brown breach facing the viewer,
-- open water in front. Measured off the photo: summit 330 px over a ~1430 px waterline base, so H/W ~0.23 (the old 560-wide ball is
-- ~0.33). The island is World.Backdrops.Taal_Volcano (root BasePart) with every other part under it; it sits outside the site model
-- because BuildCheck's footprint+10% bounds forbid a backdrop in the site. All numbers below come from the parts' corners, not from
-- attributes the builder writes. View direction: the dock axis (local +Z = SW), from the dock-end eye and a promenade eye at y 6.2.
do
	local SWD = Vector3.new(-math.sqrt(0.5), 0, math.sqrt(0.5)) -- the dock axis, looking out over the lake
	local NWD = Vector3.new(-math.sqrt(0.5), 0, -math.sqrt(0.5)) -- the viewer's right when looking SW
	local EYE_DOCK, EYE_PROM = Vector3.new(-703.7, 6.2, 641.7), Vector3.new(-667.0, 6.2, 605.0)
	local DOCK_TIP = Vector3.new(-708.7, 0, 646.7)
	local GUIDE = Vector3.new(-578.8, 0, 528.8)
	local back = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Backdrops")
	local roots, ridges = {}, 0
	for _, c in ipairs(back and back:GetChildren() or {}) do
		if c.Name == "Taal_Volcano" then table.insert(roots, c) end
		if c.Name == "Taal_Ridge" then ridges += 1 end
	end
	local root = roots[1]
	check("Taal: exactly one Backdrops child Taal_Volcano, a BasePart (sites_check looks it up)", #roots == 1 and root:IsA("BasePart"), #roots .. " found")
	check("Taal: the old Taal_Ridge ball is gone (replaced by the island)", ridges == 0, ridges .. " left")
	local island = root and root:FindFirstChild("Island")
	local parts, all = {}, {}
	for _, d in ipairs(island and island:GetDescendants() or {}) do
		if d:IsA("BasePart") then table.insert(parts, d) end
	end
	for _, d in ipairs(root and root:GetDescendants() or {}) do
		if d:IsA("BasePart") then table.insert(all, d) end
	end
	check("Taal: the island is built from parts (50+ under Taal_Volcano.Island)", #parts >= 50, #parts .. " parts")
	check("Taal: within its part budget (<= 800 under Taal_Volcano)", #all <= 800, #all .. " parts")
	if #parts >= 50 then
		-- Corners of every island part.
		local maxY, summit = -math.huge, nil
		local minS, maxS, minN, maxN = math.huge, -math.huge, math.huge, -math.huge
		local corners = {}
		for _, p in ipairs(parts) do
			local h = p.Size / 2
			for _, sx in ipairs({ -1, 1 }) do
				for _, sy in ipairs({ -1, 1 }) do
					for _, sz in ipairs({ -1, 1 }) do
						local w = p.CFrame:PointToWorldSpace(Vector3.new(sx * h.X, sy * h.Y, sz * h.Z))
						table.insert(corners, w)
						if w.Y > maxY then maxY, summit = w.Y, w end
						local s, n = (w - DOCK_TIP):Dot(SWD), (w - DOCK_TIP):Dot(NWD)
						minS, maxS, minN, maxN = math.min(minS, s), math.max(maxS, s), math.min(minN, n), math.max(maxN, n)
					end
				end
			end
		end
		local W = maxN - minN
		local centre = DOCK_TIP + SWD * ((minS + maxS) / 2) + NWD * ((minN + maxN) / 2)
		local function bearing(eye, p)
			local d = Vector3.new(p.X - eye.X, 0, p.Z - eye.Z).Unit
			return math.deg(math.acos(math.clamp(d:Dot(SWD), -1, 1)))
		end
		check("Taal: island centre is in front of the dock end, on the dock axis (bearing <= 8 deg)", bearing(EYE_DOCK, centre) <= 8,
			string.format("%.1f deg, centre (%.0f, %.0f)", bearing(EYE_DOCK, centre), centre.X, centre.Z))
		check("Taal: island centre is in front of the lake facade too (promenade eye, bearing <= 8 deg)", bearing(EYE_PROM, centre) <= 8,
			string.format("%.1f deg", bearing(EYE_PROM, centre)))
		local body = allNamed("ShoreBody")[1]
		local beyond = body and (centre - body.Position):Dot(SWD) or 0
		check("Taal: island is beyond the building on the lake side (>= 400 studs SW of ShoreBody)", beyond >= 400, string.format("%.0f", beyond))
		check("Taal: open water before it (near shore 250+ studs out from the dock tip)", minS >= 250, string.format("near shore %.0f studs out", minS))
		-- Water all the way from the dock tip to the near shore (Water is the top occupied voxel in every 4-stud cell sampled).
		local dry = {}
		for d = 8, minS - 8, 16 do
			local p = DOCK_TIP + SWD * d
			local fx, fz = math.floor(p.X / 4) * 4, math.floor(p.Z / 4) * 4
			local mats, occ = workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, -8, fz), Vector3.new(fx + 4, 8, fz + 4)), 4)
			local top = nil
			for yi = #mats[1], 1, -1 do
				if occ[1][yi][1] > 0.01 and mats[1][yi][1] ~= Enum.Material.Air then top = mats[1][yi][1]; break end
			end
			if top ~= Enum.Material.Water then table.insert(dry, string.format("%d:%s", d, top and top.Name or "none")) end
		end
		check("Taal: across water (every cell from the dock tip to the near shore is Water)", minS >= 250 and #dry == 0,
			#dry .. " dry: " .. table.concat(dry, " ", 1, math.min(#dry, 4)))
		check("Taal: low wide island (summit / waterline width 0.18..0.28, photo ~0.23)", W > 0 and maxY / W >= 0.18 and maxY / W <= 0.28,
			string.format("H %.0f / W %.0f = %.3f", maxY, W, maxY / math.max(W, 1)))
		-- Apparent size from the dock-end eye: it must read (the photo's cone fills most of the frame) without towering.
		local elev = math.deg(math.atan2(maxY - EYE_DOCK.Y, Vector3.new(summit.X - EYE_DOCK.X, 0, summit.Z - EYE_DOCK.Z).Magnitude))
		local lo, hi = math.huge, -math.huge
		for _, w in ipairs(corners) do
			local d = Vector3.new(w.X - EYE_DOCK.X, 0, w.Z - EYE_DOCK.Z)
			local a = math.deg(math.atan2(d:Dot(NWD), d:Dot(SWD)))
			lo, hi = math.min(lo, a), math.max(hi, a)
		end
		check("Taal: summit elevation from the dock-end eye is 6..20 deg", elev >= 6 and elev <= 20, string.format("%.1f deg", elev))
		check("Taal: island spans 35..90 deg of the view from the dock end", hi - lo >= 35 and hi - lo <= 90, string.format("%.1f deg", hi - lo))
		-- The crater: two side peaks with a dip between them in the silhouette seen along the dock axis.
		local cN = (centre - DOCK_TIP):Dot(NWD)
		local hl, hm, hr = 0, 0, 0
		for _, w in ipairs(corners) do
			local x = ((w - DOCK_TIP):Dot(NWD) - cN) / W
			if x >= -0.22 and x <= -0.05 then hl = math.max(hl, w.Y) end
			if x >= -0.03 and x <= 0.03 then hm = math.max(hm, w.Y) end
			if x >= 0.05 and x <= 0.22 then hr = math.max(hr, w.Y) end
		end
		-- caption.jpg: the far rim dips ~6% of H below the left peak (~18% below the right one); 4% leaves margin under the photo.
		check("Taal: crater notch (silhouette middle at least 4% of H below both side peaks)", hm <= math.min(hl, hr) - 0.04 * maxY,
			string.format("left %.0f mid %.0f right %.0f", hl, hm, hr))
		local lake = island:FindFirstChild("TaalCraterLake", true)
		local lakeTop = lake and lake.Position.Y + lake.Size.Y / 2 or 0
		local lakeOff = lake and Vector3.new(lake.Position.X - centre.X, 0, lake.Position.Z - centre.Z).Magnitude or math.huge
		check("Taal: crater lake hint (TaalCraterLake well below the summit, near the centre)", lake ~= nil and lakeTop >= 20 and lakeTop <= maxY - 40 and lakeOff <= 0.25 * W,
			lake and string.format("top %.0f, %.0f off centre", lakeTop, lakeOff) or "missing")
		-- Nothing of the site blocks the summit from the lake-side eyes (site parts only; the kept Guide/InfoPanel/JeepStop ignored).
		local built = {}
		for _, c in ipairs(site:GetChildren()) do
			if not KEPT[c.Name] then table.insert(built, c) end
		end
		local vp = RaycastParams.new()
		vp.FilterType = Enum.RaycastFilterType.Include
		vp.FilterDescendantsInstances = built
		local blocked = {}
		for _, eye in ipairs({ EYE_DOCK, EYE_PROM }) do
			local r = workspace:Raycast(eye, summit - eye, vp)
			if r then table.insert(blocked, r.Instance:GetFullName()) end
		end
		check("Taal: the summit is in clear view from the dock end and the promenade", #blocked == 0, table.concat(blocked, ", "))
	end
	-- Backdrop behaviour: anchored, no collision, no queries (it must never block the site's own sight-line rays), no shadow on the site.
	local bad = {}
	for _, p in ipairs(all) do
		if not (p.Anchored and not p.CanCollide and not p.CanQuery and not p.CastShadow) then table.insert(bad, p.Name) end
	end
	if root then
		if not (root.Anchored and not root.CanCollide and not root.CanQuery) then table.insert(bad, root.Name) end
	end
	check("Taal: every part anchored, CanCollide/CanQuery/CastShadow false", #all > 0 and #bad == 0, #bad .. " bad: " .. table.concat(bad, ",", 1, math.min(#bad, 4)))
	-- Far from the Guide, InfoPanel and Jeep zones (they sit within 30 studs of the Guide).
	local nearest = math.huge
	for _, p in ipairs(all) do
		local h = p.Size / 2
		for _, sx in ipairs({ -1, 1 }) do
			for _, sz in ipairs({ -1, 1 }) do
				local w = p.CFrame:PointToWorldSpace(Vector3.new(sx * h.X, 0, sz * h.Z))
				nearest = math.min(nearest, Vector3.new(w.X - GUIDE.X, 0, w.Z - GUIDE.Z).Magnitude)
			end
		end
	end
	check("Taal: no part within 300 studs of the Guide (Guide, InfoPanel, Jeep zones untouched)", #all > 0 and nearest >= 300, string.format("%.0f", nearest))
end

------------------------------------------------------------------ Revision 3 (session 061): sandy shore patches (builders/site09_shore.luau)
-- Owner: "make the off shores like sand some parts". Six irregular Grass -> Sand patches along the waterline, three on the NW arm
-- (x -798..-726) and three on the SE arm (x -634..-590), none under the quay, dock or building. Cells are read like world_check:
-- the y -4..0 voxel of the 4-stud cell at floor(x/4)*4, floor(z/4)*4.
do
	local T = workspace.Terrain
	local M = Enum.Material
	local function cellMaterial(x, z)
		local fx, fz = math.floor(x / 4) * 4, math.floor(z / 4) * 4
		return T:ReadVoxels(Region3.new(Vector3.new(fx, -4, fz), Vector3.new(fx + 4, 0, fz + 4)), 4)[1][1][1]
	end
	local function expect(list, mat, label)
		local bad = {}
		for _, p in ipairs(list) do
			local m = cellMaterial(p[1], p[2])
			if m ~= mat then table.insert(bad, string.format("(%d,%d)=%s", p[1], p[2], m.Name)) end
		end
		check(label, #bad == 0, table.concat(bad, " "))
	end
	expect({ { -790, 546 }, { -762, 554 }, { -738, 566 }, { -622, 666 }, { -606, 694 }, { -598, 722 } }, M.Sand,
		"shore: the six patch centres on the waterline are Sand")
	expect({ { -774, 550 }, { -750, 558 }, { -614, 678 }, { -602, 710 } }, M.Grass,
		"shore: the gaps between the patches are still Grass (patches, not one stripe)")
	expect({ { -698, 594 }, { -662, 622 }, { -700, 500 }, { -560, 640 } }, M.Grass,
		"shore: control cells under the seawall and inland are still Grass")
	expect({ { -706, 610 }, { -716, 590 }, { -700, 640 }, { -800, 600 } }, M.Water, "shore: the lake cells are still Water")
	-- Every Sand cell at the surface layer in the box: near the site, on the waterline, and under no site part.
	local X0, X1, Z0, Z1 = -800, -560, 500, 760
	local mats = T:ReadVoxels(Region3.new(Vector3.new(X0, -4, Z0), Vector3.new(X1, 0, Z1)), 4)
	local nx, nz = mats.Size.X, mats.Size.Z
	local function at(i, k) if i < 1 or k < 1 or i > nx or k > nz then return nil end return mats[i][1][k] end
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { site }
	local sand, far, inland, covered = 0, {}, {}, {}
	for i = 1, nx do
		for k = 1, nz do
			if at(i, k) == M.Sand then
				sand += 1
				local cx, cz = X0 + (i - 0.5) * 4, Z0 + (k - 0.5) * 4
				if (Vector3.new(cx, 0, cz) - Vector3.new(-646, 0, 583)).Magnitude > 155 then table.insert(far, cx .. "," .. cz) end
				local wet = false
				for di = -4, 4 do
					for dk = -4, 4 do
						if at(i + di, k + dk) == M.Water then wet = true end
					end
				end
				if not wet then table.insert(inland, cx .. "," .. cz) end
				if #workspace:GetPartBoundsInBox(CFrame.new(cx, 10, cz), Vector3.new(3.9, 20, 3.9), op) > 0 then table.insert(covered, cx .. "," .. cz) end
			end
		end
	end
	check("shore: 30 to 400 Sand cells at the surface near Tagbakin", sand >= 30 and sand <= 400, tostring(sand))
	check("shore: every Sand cell is within 155 of the site centre (-646, 583) and 16 of the water, and under no site part",
		sand > 0 and #far == 0 and #inland == 0 and #covered == 0,
		string.format("far %d inland %d covered %d: %s", #far, #inland, #covered, table.concat(far, " ", 1, math.min(#far, 3)) .. " " .. table.concat(covered, " ", 1, math.min(#covered, 3))))
end

return HttpService:JSONEncode(results)
