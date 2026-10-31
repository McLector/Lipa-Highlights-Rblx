-- filler_check: guards the city filler (builders/filler.luau, Workspace.World.CityFill), the haze, the golden-hour light and the music
-- (builders/mood.luau). Studio copy: ServerStorage.Checks.filler_check.
-- Run in Edit mode: require(game.ServerStorage.Checks.filler_check:Clone())  -- returns JSON {passed, failed, failures}
-- Why (owner, 2026-10-31): generic town buildings line the outer roads so the far sites stay hidden until a player arrives, and a light haze
-- fades what is still in view. The filler must never touch a site (footprint + 10 percent, the BuildCheck box, plus 24), a road body
-- (half width + 3), the core town where the walking routes run (x -600..360, z -330..352), or the world edge (+-980). Fourth round (more town):
-- nor the reserved land (future Outlets and Farm slots, Malarayat's new entrance), with 12 studs clear of the road edges for new buildings.
-- Fifth round (owner, 2026-10-31: yes to filling the core town). Pins REPLACED in place (old -> new):
--   "CityFill holds 1500..5000 parts" -> "CityFill holds 1500..6400 parts" (the core pass adds up to about 2000)
--   "no filler part in the core town box" -> the narrower core pins: no filler part within 8 studs of a walking route (a 4-stud path plus 6)
--     or of a core Guide's look line; the Credits Plaza and its entry path (+ 12) and the spawn (40 studs) clear; in the core, no part within a
--     road body (half width + 4, exact); no core part overlapping a part of Workspace.Sites, the CreditsBoard or the SpawnLocation; core Guide
--     rays clear of the filler; core lots on no Grass; the Grass control cells still Grass; core blocks low (Body 42 or less); at least 130 core
--     buildings, at most 2000 core parts. The site-box pin (+ 24) is unchanged and covers the core sites.
--   street-edge paving: points in the core were skipped -> they now join the no-Grass-under-the-Lot test (the 75 percent cover figure still
--     counts the points outside the core only, as before)
--   "CityFill holds 3600..4400 parts (was 2387; budget about 2000 new)" -> "the outer CityFill (no Core attribute) holds 3600..4400 parts"
local HttpService = game:GetService("HttpService")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())
local BuildCheck = require(game.ServerStorage.BuildCheck:Clone())

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local CORE = { x0 = -600, x1 = 360, z0 = -330, z1 = 352 }
local SITE_MARGIN, ROAD_CLEAR, EDGE = 24, 3, 980

local fill = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CityFill")
check("Workspace.World.CityFill exists", fill ~= nil)

local parts = {}
if fill then
	for _, d in ipairs(fill:GetDescendants()) do
		if d:IsA("BasePart") then table.insert(parts, d) end
	end
end
check("CityFill holds 1500..6400 parts", #parts >= 1500 and #parts <= 6400, #parts .. " parts")

local buildings = 0
if fill then
	for _, c in ipairs(fill:GetChildren()) do
		if c:IsA("Model") and c:FindFirstChild("Body") then buildings += 1 end
	end
end
-- Owner, 2026-10-31 (second round): more buildings, three rows deep.
check("CityFill has 220 or more buildings, each a Model with a Body", buildings >= 220, buildings .. " buildings")

-- Site boxes: the footprint + 10 percent (BuildCheck's rule) plus SITE_MARGIN.
local siteBoxes = {}
for _, s in ipairs(SiteData.sites) do
	local hx, hz = s.size.X / 2 * 1.1 + SITE_MARGIN, s.size.Y / 2 * 1.1 + SITE_MARGIN
	table.insert(siteBoxes, { key = s.key, x0 = s.pos.X - hx, x1 = s.pos.X + hx, z0 = s.pos.Z - hz, z1 = s.pos.Z + hz })
end
local segs = {}
for _, r in ipairs(RoadData.all()) do
	for i = 1, #r.pts - 1 do
		table.insert(segs, { name = r.name, a = r.pts[i], b = r.pts[i + 1], clear = r.w / 2 + ROAD_CLEAR })
	end
end
local function segDist(px, pz, a, b)
	local ax, az, bx, bz = a[1], a[2], b[1], b[2]
	local dx, dz = bx - ax, bz - az
	local t = ((px - ax) * dx + (pz - az) * dz) / (dx * dx + dz * dz)
	t = math.clamp(t, 0, 1)
	local cx, cz = ax + t * dx - px, az + t * dz - pz
	return math.sqrt(cx * cx + cz * cz)
end
local function overlaps(b, x0, x1, z0, z1)
	return x0 < b.x1 and x1 > b.x0 and z0 < b.z1 and z1 > b.z0
end

local inSite, onRoad, offEdge, loose, scripted = {}, {}, {}, {}, {}
local boxes = {} -- world xz box of each part, for the core pins
for i, p in ipairs(parts) do
	local half = p.Size / 2
	local cf = p.CFrame
	-- world xz extent of the rotated box
	local ex = math.abs(cf.RightVector.X) * half.X + math.abs(cf.UpVector.X) * half.Y + math.abs(cf.LookVector.X) * half.Z
	local ez = math.abs(cf.RightVector.Z) * half.X + math.abs(cf.UpVector.Z) * half.Y + math.abs(cf.LookVector.Z) * half.Z
	local x0, x1, z0, z1 = p.Position.X - ex, p.Position.X + ex, p.Position.Z - ez, p.Position.Z + ez
	for _, b in ipairs(siteBoxes) do
		if overlaps(b, x0, x1, z0, z1) then table.insert(inSite, p:GetFullName() .. " in " .. b.key) break end
	end
	boxes[i] = { x0, x1, z0, z1 }
	if math.max(math.abs(x0), math.abs(x1), math.abs(z0), math.abs(z1)) > EDGE then table.insert(offEdge, p:GetFullName()) end
	-- road bodies: sample the part's xz box every 3 studs
	local nx, nz = math.max(1, math.ceil((x1 - x0) / 3)), math.max(1, math.ceil((z1 - z0) / 3))
	local hit = nil
	for ix = 0, nx do
		for iz = 0, nz do
			local px, pz = x0 + (x1 - x0) * ix / nx, z0 + (z1 - z0) * iz / nz
			for _, s in ipairs(segs) do
				if segDist(px, pz, s.a, s.b) < s.clear then hit = s.name break end
			end
			if hit then break end
		end
		if hit then break end
	end
	if hit then table.insert(onRoad, p:GetFullName() .. " on " .. hit) end
	if not p.Anchored then table.insert(loose, p:GetFullName()) end
	if i % 200 == 0 then task.wait() end
end
local function list(t) return #t .. ": " .. table.concat(t, ", ", 1, math.min(#t, 4)) end
check("no filler part inside a site box (footprint + 10 percent + 24)", #inSite == 0, list(inSite))
-- REPLACED (owner, 2026-10-31, core-town filler): "no filler part in the core town box" -> the core pins below. builders/filler.luau (Pass 4)
-- holds the same lists. Walking routes: PathfindingService lines measured in Edit on 2026-10-31 (radius 2, no jump) for the routes of
-- tests/routes_check.luau and the guidance legs (side stairs -> shop Guides, JeepStops -> Guides), thinned to about 12-stud steps. Hard-coded on
-- purpose: a path computed after the build would bend round the filler, so the pin could never fail.
do
	local WALK = {
		{ -208, -260, -217, -260 }, -- spawn -> Ate Joy
		{ -208, -260, -204, -249, -198, -234, -193, -219, -188, -204, -182, -189, -177, -173, -171, -158, -172, -144, -167, -129, -163, -117, -160, -106,
			-156, -94, -152, -83, -149, -71, -145, -60, -140, -45, -136, -33, -131, -18, -126, -3, -126, 11, -118, 23, -107, 25, -91, 26, -75, 26, -59, 25,
			-47, 25, -31, 25, -16, 26, -4, 30, 0, 36 }, -- spawn -> Cathedral Guide
		{ 126, 0, 126, 16, 114, 24, 99, 28, 84, 27, 71, 27, 60, 34, 44, 34, 28, 35, 12, 36, 0, 36 }, -- Road C start -> Cathedral Guide
		{ 0, -106, 11, -102, 27, -102, 39, -102, 51, -102, 63, -102, 79, -102, 95, -102, 111, -102, 122, -94, 122, -78, 122, -62, 122, -46, 122, -30,
			122, -14, 125, 0, 127, 14, 118, 23, 103, 27, 88, 28, 71, 27 }, -- Road A start -> Cathedral Guide
		{ 0, 225, 5, 214, 11, 203, 25, 197, 37, 197, 49, 197, 61, 197, 76, 199, 88, 199, 101, 198, 102, 186, 101, 170, 101, 154, 101, 138, 110, 126,
			122, 115, 124, 102, 124, 86, 125, 70, 125, 58, 125, 46, 126, 30, 114, 30, 98, 29, 86, 28, 71, 27 }, -- Road E start -> Cathedral Guide
		{ 0, 225, 2, 241, 5, 257, 9, 271, 14, 282, 20, 292, 26, 303, 30, 310 }, -- Road E start -> Credits Plaza entrance
		{ -208, -260, -208, -248, -208, -236, -208, -224, -209, -209, -210, -197, -211, -185, -212, -173, -213, -161, -214, -149, -215, -137, -216, -125,
			-217, -109, -219, -93, -220, -77, -222, -61, -223, -50, -224, -38, -225, -26, -225, -11, -225, 5, -225, 17, -224, 29, -224, 41, -224, 53,
			-223, 69, -223, 81, -222, 93, -222, 105, -222, 117, -223, 132, -228, 143, -233, 154, -235, 160 }, -- spawn -> Market Guide
		{ -208, -260, -198, -253, -188, -240, -178, -227, -168, -215, -161, -205, -151, -192, -139, -185, -124, -179, -109, -172, -95, -166, -80, -159,
			-65, -153, -51, -146, -36, -140, -22, -133, -11, -128, 3, -124, 19, -121, 31, -119, 46, -116, 62, -113, 74, -111, 86, -109, 97, -107, 109, -104,
			121, -102, 127, -91, 134, -77, 140, -67, 146, -56, 153, -42, 160, -28, 168, -13, 179, -8, 191, -1, 207, 1, 223, 3, 228, 15, 229, 27, 231, 39,
			233, 51, 235, 63, 237, 74, 238, 86, 242, 99, 246, 110, 250, 122, 254, 133, 256, 140 }, -- spawn -> Lomi Guide
		{ -208, -260, -198, -253, -190, -243, -181, -230, -171, -218, -161, -205, -151, -192, -138, -187, -126, -184, -111, -180, -95, -176, -80, -172,
			-64, -168, -52, -165, -41, -162, -29, -159, -18, -156, -6, -153, 9, -151, 21, -154, 36, -157, 51, -159, 66, -159, 78, -159, 90, -159, 102, -159,
			114, -159, 128, -154, 139, -157, 154, -155, 168, -157, 181, -157, 196, -154, 208, -155, 221, -158, 236, -160 }, -- spawn -> Cafe Guide
		{ -128, 26, -135, 40, -145, 52, -156, 64, -166, 77, -176, 89, -186, 101, -194, 110, -202, 120, -209, 129, -219, 141, -230, 154, -235, 160 }, -- west stairs -> Market
		{ 128, 26, 138, 38, 149, 50, 157, 59, 165, 68, 175, 76, 184, 83, 194, 91, 203, 98, 212, 106, 222, 113, 231, 120, 244, 130, 256, 140 }, -- east stairs -> Lomi
		{ 128, 26, 129, 14, 126, 1, 128, -11, 134, -22, 140, -33, 145, -43, 151, -54, 156, -65, 162, -75, 167, -86, 173, -96, 180, -111, 188, -125,
			196, -135, 206, -142, 215, -149, 227, -158, 236, -160 }, -- east stairs -> Cafe
		{ -155, -230, -169, -238, -183, -246, -197, -254, -209, -258, -217, -260 }, -- City Hall JeepStop -> Ate Joy
		{ -20, 30, -5, 35, 0, 36 }, -- Plaza JeepStop -> Cathedral Guide
	}
	local CREDITS = { { key = "Credits Plaza", x0 = 24, x1 = 152, z0 = 272, z1 = 348 }, { key = "EntryPath", x0 = 4, x1 = 24, z0 = 304, z1 = 316 } }
	local SPAWN_X, SPAWN_Z, SPAWN_R = -208, -260, 40
	-- Grass control cells in or near the free core (roads_check and world_check, which is not in Studio: its (150, -300) lies in a free lot).
	local GRASS_CTRL = {
		{ 150, -300 }, { -332, -300 }, { -300, -184 }, { -146, -300 }, { -580, 160 }, { -590, 160 }, { -400, -24 }, { -400, -22 }, { -300, 360 },
		{ -212, 170 }, { -212, 150 }, { -108, 150 }, { 108, 150 }, { -60, 208 }, { 40, 360 }, { -212, 100 }, { -212, 200 }, { -222, -24 }, { -212, 334 },
		{ -580, -14 }, { -212, -14 }, { -580, 334 }, { 360, 140 }, { 292, 76 }, { 292, 204 }, { -102, 50 }, { 102, 50 }, { 50, -2 }, -- world_check's (50, 102) reads Pavement today (stale there), so it is left out
	}
	local function boxSegDist(x0, x1, z0, z1, ax, az, bx, bz)
		local function pb(px, pz)
			local cx, cz = math.max(x0 - px, 0, px - x1), math.max(z0 - pz, 0, pz - z1)
			return math.sqrt(cx * cx + cz * cz)
		end
		local dx, dz = bx - ax, bz - az
		if dx == 0 and dz == 0 then return pb(ax, az) end
		local t0, t1, inside = 0, 1, true
		for _, e in ipairs({ { -dx, ax - x0 }, { dx, x1 - ax }, { -dz, az - z0 }, { dz, z1 - az } }) do
			if e[1] == 0 then
				if e[2] < 0 then inside = false end
			elseif e[1] < 0 then
				t0 = math.max(t0, e[2] / e[1])
			else
				t1 = math.min(t1, e[2] / e[1])
			end
		end
		if inside and t0 <= t1 then return 0 end
		local d = math.min(pb(ax, az), pb(bx, bz))
		for _, c in ipairs({ { x0, z0 }, { x0, z1 }, { x1, z0 }, { x1, z1 } }) do d = math.min(d, segDist(c[1], c[2], { ax, az }, { bx, bz })) end
		return d
	end
	-- self-test of the distance (a check that cannot measure cannot fail): a box crossed by a line is at 0, a box 10 studs off is at 10
	check("core pins: the box-to-line distance measures (0 when crossed, 10 when 10 off)",
		boxSegDist(0, 4, 0, 4, -5, 2, 9, 2) == 0 and math.abs(boxSegDist(0, 4, 0, 4, 14, -5, 14, 9) - 10) < 1e-6)
	local walk, look = {}, {}
	for wi, w in ipairs(WALK) do
		for i = 1, #w - 3, 2 do table.insert(walk, { w[i], w[i + 1], w[i + 2], w[i + 3], wi }) end
	end
	local sitesF = workspace:FindFirstChild("Sites")
	local coreGuides = {}
	for _, s in ipairs(SiteData.sites) do
		local g = SiteData.guidePos(s.id)
		if g.X > CORE.x0 and g.X < CORE.x1 and g.Z > CORE.z0 and g.Z < CORE.z1 then
			local f = SiteData.facingVector(s.facing)
			table.insert(look, { g.X, g.Z, g.X + f.X * 150, g.Z + f.Z * 150, s.key })
			table.insert(look, { g.X, g.Z, s.pos.X, s.pos.Z, s.key })
			local m = sitesF and sitesF:FindFirstChild(string.format("Site%02d_%s", s.id, s.key))
			local head = m and m:FindFirstChild("Guide") and m.Guide:FindFirstChild("Head")
			table.insert(coreGuides, { s = s, head = head })
		end
	end
	local nearWalk, nearLook, inCredits, nearSpawn, coreRoad, coreParts = {}, {}, {}, {}, {}, {}
	local NEAR = { x0 = CORE.x0 - 20, x1 = CORE.x1 + 20, z0 = CORE.z0 - 20, z1 = CORE.z1 + 20 } -- every line lies inside the core box
	for i, p in ipairs(parts) do
		local b = boxes[i]
		if overlaps(NEAR, b[1], b[2], b[3], b[4]) then
			for _, l in ipairs(walk) do
				if boxSegDist(b[1], b[2], b[3], b[4], l[1], l[2], l[3], l[4]) < 8 then table.insert(nearWalk, p:GetFullName() .. " route " .. l[5]) break end
			end
			for _, l in ipairs(look) do
				if boxSegDist(b[1], b[2], b[3], b[4], l[1], l[2], l[3], l[4]) < 8 then table.insert(nearLook, p:GetFullName() .. " " .. l[5]) break end
			end
			for _, c in ipairs(CREDITS) do
				if overlaps(c, b[1] - 12, b[2] + 12, b[3] - 12, b[4] + 12) then table.insert(inCredits, p:GetFullName() .. " " .. c.key) break end
			end
			local qx, qz = math.clamp(SPAWN_X, b[1], b[2]), math.clamp(SPAWN_Z, b[3], b[4])
			if (qx - SPAWN_X) ^ 2 + (qz - SPAWN_Z) ^ 2 < SPAWN_R ^ 2 then table.insert(nearSpawn, p:GetFullName()) end
			if overlaps(CORE, b[1], b[2], b[3], b[4]) then
				table.insert(coreParts, p)
				for _, s in ipairs(segs) do
					if boxSegDist(b[1], b[2], b[3], b[4], s.a[1], s.a[2], s.b[1], s.b[2]) < s.clear + 1 then table.insert(coreRoad, p:GetFullName() .. " on " .. s.name) break end
				end
			end
		end
		if i % 300 == 0 then task.wait() end
	end
	check("no filler part within 8 studs of a walking route (the 4-stud path plus 6)", #nearWalk == 0, list(nearWalk))
	check("no filler part within 8 studs of a core Guide's look line (150 studs along its facing, and to its own site)", #nearLook == 0, list(nearLook))
	check("the Credits Plaza (x 24..152, z 272..348) and its entry path (x 4..24, z 304..316), plus 12, hold no filler", #inCredits == 0, list(inCredits))
	check("no filler part within 40 studs of the spawn (-208, -260)", #nearSpawn == 0, list(nearSpawn))
	check("in the core, no filler part within a road body (half width + 4, exact)", #coreRoad == 0, list(coreRoad))
	-- The Guides' own view: a ray from each core Guide's head along its facing (150 studs) and to its site's centre (20 up) meets no filler.
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { fill or Instance.new("Folder") }
	local blockedView, headless = {}, {}
	for _, g in ipairs(coreGuides) do
		if not g.head then
			table.insert(headless, g.s.key)
		else
			local eye = g.head.Position
			local f = SiteData.facingVector(g.s.facing)
			for _, aim in ipairs({ eye + Vector3.new(f.X, 0, f.Z).Unit * 150, Vector3.new(g.s.pos.X, g.s.pos.Y + 20, g.s.pos.Z) }) do
				local r = workspace:Raycast(eye, aim - eye, rp)
				if r then table.insert(blockedView, g.s.key .. " -> " .. r.Instance:GetFullName()) end
			end
		end
	end
	check("the core Guides (5) look out and back at their sites past no filler", #coreGuides == 5 and #headless == 0 and #blockedView == 0,
		#coreGuides .. " guides, no head: " .. table.concat(headless, ", ") .. "; " .. list(blockedView))
	-- No core filler part overlaps any part of the sites, the CreditsBoard or the spawn pad (NPCs, signs, lamps outside the site boxes too).
	local keep = {}
	for _, inst in ipairs({ sitesF, workspace:FindFirstChild("World") and workspace.World:FindFirstChild("CreditsBoard"), workspace:FindFirstChild("SpawnLocation") }) do
		table.insert(keep, inst)
	end
	local kp = OverlapParams.new()
	kp.FilterType = Enum.RaycastFilterType.Include
	kp.FilterDescendantsInstances = keep
	local clashes = {}
	for i, p in ipairs(coreParts) do
		local hits = workspace:GetPartBoundsInBox(p.CFrame, p.Size, kp)
		if #hits > 0 then table.insert(clashes, p:GetFullName() .. " x " .. hits[1]:GetFullName()) end
		if i % 300 == 0 then task.wait() end
	end
	check("no core filler part overlaps a part of Workspace.Sites, the CreditsBoard or the SpawnLocation", #clashes == 0, list(clashes))
	-- The core buildings: models with Core = true, wholly inside the core box, low (Body 42 or less: 4 floors), on lots repainted off Grass.
	local function cellMaterial(x, y, z)
		local fx, fy, fz = math.floor(x / 4) * 4, math.floor((y - 0.01) / 4) * 4, math.floor(z / 4) * 4
		return workspace.Terrain:ReadVoxels(Region3.new(Vector3.new(fx, fy, fz), Vector3.new(fx + 4, fy + 4, fz + 4)), 4)[1][1][1]
	end
	local coreB, coreBParts, outside, tall, grassy, lotPts = 0, 0, {}, {}, {}, 0
	if fill then
		for _, m in ipairs(fill:GetChildren()) do
			if m:IsA("Model") and m:GetAttribute("Core") == true then
				local body, lot = m:FindFirstChild("Body"), m:FindFirstChild("Lot")
				if body then coreB += 1 end
				for _, d in ipairs(m:GetDescendants()) do
					if d:IsA("BasePart") then coreBParts += 1 end
				end
				if body and body.Size.Y > 42 then table.insert(tall, m.Name .. string.format(" %.0f", body.Size.Y)) end
				if lot then
					-- the Lot is yawed to face its road: its world x extent is Size.X or Size.Z
					local half = (math.abs(lot.CFrame.RightVector.X) > 0.5) and Vector2.new(lot.Size.X, lot.Size.Z) / 2 or Vector2.new(lot.Size.Z, lot.Size.X) / 2
					local lx0, lx1 = lot.Position.X - half.X, lot.Position.X + half.X
					local lz0, lz1 = lot.Position.Z - half.Y, lot.Position.Z + half.Y
					if lx0 < CORE.x0 or lx1 > CORE.x1 or lz0 < CORE.z0 or lz1 > CORE.z1 then table.insert(outside, m.Name) end
					local gy = lot.Position.Y - lot.Size.Y / 2 + 1
					for _, q in ipairs({ { 0.5, 0.5 }, { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } }) do
						local qx = lx0 + 4 + (lx1 - lx0 - 8) * q[1]
						local qz = lz0 + 4 + (lz1 - lz0 - 8) * q[2]
						lotPts += 1
						if cellMaterial(qx, gy, qz) == Enum.Material.Grass then table.insert(grassy, string.format("%s(%.0f,%.0f)", m.Name, qx, qz)) end
					end
				end
			end
		end
	end
	check("the core town has 130 or more filler buildings (Core = true)", coreB >= 130, coreB .. " core buildings")
	check("the core filler holds at most 2000 parts", coreBParts <= 2000, coreBParts .. " core parts")
	check("every core Lot lies wholly inside the core box", #outside == 0, list(outside))
	check("core blocks stay low: every Body 42 studs or less (4 floors)", #tall == 0, list(tall))
	check("no Grass under the core Lots (centre and corners, 4 studs in)", coreB == 0 or (lotPts > 0 and #grassy == 0), lotPts .. " points, " .. list(grassy))
	local notGrass = {}
	for _, c in ipairs(GRASS_CTRL) do
		local m = cellMaterial(c[1], 0, c[2])
		if m ~= Enum.Material.Grass then table.insert(notGrass, string.format("(%d,%d)=%s", c[1], c[2], m.Name)) end
	end
	check("the Grass control cells in and near the core are still Grass", #notGrass == 0, list(notGrass))
end
check("no filler part on a road body (half width + 3)", #onRoad == 0, list(onRoad))
check("no filler part beyond +-980", #offEdge == 0, list(offEdge))
check("every filler part is anchored", #loose == 0, list(loose))

if fill then
	for _, d in ipairs(fill:GetDescendants()) do
		if d:IsA("LuaSourceContainer") or d:IsA("SurfaceGui") or d:IsA("Decal") or d:IsA("Texture") or d:IsA("BillboardGui") then
			table.insert(scripted, d:GetFullName())
		end
	end
end
check("no scripts, text or images in the filler", #scripted == 0, list(scripted))

-- Human scale: every door is at least 8 studs tall.
local shortDoors, doors = {}, 0
for _, p in ipairs(parts) do
	if p.Name == "Door" then
		doors += 1
		if p.Size.Y < 8 then table.insert(shortDoors, p:GetFullName()) end
	end
end
check("every building has a door 8 or more studs tall", doors >= buildings and #shortDoors == 0, doors .. " doors, short " .. list(shortDoors))

-- The building stands on its lot: the Body's bottom is within 0.05 of its Lot's top.
local floating = {}
if fill then
	for _, m in ipairs(fill:GetChildren()) do
		local body, lot = m:FindFirstChild("Body"), m:FindFirstChild("Lot")
		if body and lot then
			local gap = (body.Position.Y - body.Size.Y / 2) - (lot.Position.Y + lot.Size.Y / 2)
			if math.abs(gap) > 0.05 then table.insert(floating, m.Name .. string.format(" %.2f", gap)) end
		elseif m:IsA("Model") then
			table.insert(floating, m.Name .. " no Body/Lot")
		end
	end
end
check("every Body stands on its Lot", #floating == 0, list(floating))

-- The world budget (BuildCheck's cap, 25000 since 2026-10-31).
local w = BuildCheck.checkWorld()
check("world part budget holds with the filler", w.failed == 0, w.parts .. " parts")

-- Pavement (owner, second round: "concrete pavements like a road"): the lots tile the street edge with no grass gaps. Every 8 studs along
-- each side of every road, 7 studs out from the road edge, a point that lies outside the core, the site boxes and every road body must
-- have a concrete Lot under it; at least 75 percent of them (slopes over 5 studs and water stay bare).
if fill then
	local lp = RaycastParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { fill, workspace.Terrain }
	local eligible, covered = 0, 0
	-- Ground (owner, third round: "repaint under the town"): where a Lot stands at the street edge, the terrain under it and on the verge
	-- between the road body and the sidewalk (2 studs out from the road edge) is no longer Grass, so no grass blades show in the town.
	local tp = RaycastParams.new()
	tp.FilterType = Enum.RaycastFilterType.Include
	tp.FilterDescendantsInstances = { workspace.Terrain }
	local groundPts, grassPts = 0, {}
	local function terrainMat(px, pz)
		local r = workspace:Raycast(Vector3.new(px, 400, pz), Vector3.new(0, -800, 0), tp)
		return r and r.Material
	end
	-- REPLACED (core-town filler, 2026-10-31): points in the core box (+ 4) were skipped -> they join the no-Grass test below; the cover
	-- figure still counts the points outside the core only, as before.
	local function inCoreBox(px, pz)
		return px > CORE.x0 - 4 and px < CORE.x1 + 4 and pz > CORE.z0 - 4 and pz < CORE.z1 + 4
	end
	local function free(px, pz)
		if px < -EDGE or px > EDGE or pz < -EDGE or pz > EDGE then return false end
		for _, b in ipairs(siteBoxes) do
			if px > b.x0 - 4 and px < b.x1 + 4 and pz > b.z0 - 4 and pz < b.z1 + 4 then return false end
		end
		for _, s in ipairs(segs) do
			if segDist(px, pz, s.a, s.b) < s.clear + 2 then return false end
		end
		return true
	end
	for _, s in ipairs(segs) do
		local ax, az, bx, bz = s.a[1], s.a[2], s.b[1], s.b[2]
		local L = math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2)
		local ux, uz = (bx - ax) / L, (bz - az) / L
		for _, side in ipairs({ 1, -1 }) do
			local nx, nz = -uz * side, ux * side
			local off = s.clear - ROAD_CLEAR + 7
			for t = 16, L - 16, 8 do
				local px, pz = ax + ux * t + nx * off, az + uz * t + nz * off
				if free(px, pz) then
					local r = workspace:Raycast(Vector3.new(px, 400, pz), Vector3.new(0, -800, 0), lp)
					local core = inCoreBox(px, pz)
					if r and not (r.Instance == workspace.Terrain and r.Material == Enum.Material.Water) then
						if not core then eligible += 1 end
						if r.Instance.Name == "Lot" then
							if not core then covered += 1 end
							local vx, vz = ax + ux * t + nx * (off - 5), az + uz * t + nz * (off - 5)
							for _, q in ipairs({ { px, pz }, { vx, vz } }) do
								groundPts += 1
								if terrainMat(q[1], q[2]) == Enum.Material.Grass then
									table.insert(grassPts, string.format("(%.0f,%.0f)", q[1], q[2]))
								end
							end
						end
					end
				end
			end
		end
	end
	check("street edges are paved: 75 percent or more of the free road-edge points stand on a Lot", eligible > 0 and covered >= eligible * 0.75,
		covered .. " of " .. eligible)
	check("no Grass under the street-edge Lots or on the verge beside them", groundPts > 0 and #grassPts == 0,
		#grassPts .. " of " .. groundPts .. " grass: " .. table.concat(grassPts, " ", 1, math.min(#grassPts, 6)))
end

-- More town (owner, fourth round, 2026-10-31: "build more filler buildings"). The builder adds rows 5 and 6 behind the four street rows, then fills
-- the remaining gaps outward from the roads (Pass 2 and Pass 3 buildings carry the attribute Pass), and paves the grass corner by the Road A/B
-- junction. Budget: at most about 2000 new parts, so CityFill stays at or under 4400 parts.
do
	-- Reserved land, hard-coded so a SiteData edit cannot shrink it: the FUTURE slots of the Outlets (x 325..775, z -850..-550) and the Farm
	-- (x 570..970, z 80..400), each plus 26; 60 studs around Malarayat's new main entrance at the Road D mouth (450, 560); the current slots of
	-- Carmel (x -410..-190, z -690..-510) and Malarayat (x 360..760, z 560..880) with the site rule (footprint + 10 percent + 26).
	local RESERVED = {
		{ key = "Outlets future slot + 26", x0 = 299, x1 = 801, z0 = -876, z1 = -524 },
		{ key = "Farm future slot + 26", x0 = 544, x1 = 996, z0 = 54, z1 = 426 },
		{ key = "Malarayat entrance (450,560) + 60", x0 = 390, x1 = 510, z0 = 500, z1 = 620 },
		{ key = "Carmel slot + 10 percent + 26", x0 = -447, x1 = -153, z0 = -725, z1 = -475 },
		{ key = "Malarayat slot + 10 percent + 26", x0 = 314, x1 = 806, z0 = 518, z1 = 922 },
	}
	local function xzBox(p)
		local half, cf = p.Size / 2, p.CFrame
		local ex = math.abs(cf.RightVector.X) * half.X + math.abs(cf.UpVector.X) * half.Y + math.abs(cf.LookVector.X) * half.Z
		local ez = math.abs(cf.RightVector.Z) * half.X + math.abs(cf.UpVector.Z) * half.Y + math.abs(cf.LookVector.Z) * half.Z
		return p.Position.X - ex, p.Position.X + ex, p.Position.Z - ez, p.Position.Z + ez
	end
	local inReserved = {}
	for _, p in ipairs(parts) do
		local x0, x1, z0, z1 = xzBox(p)
		for _, b in ipairs(RESERVED) do
			if overlaps(b, x0, x1, z0, z1) then table.insert(inReserved, p:GetFullName() .. " in " .. b.key) break end
		end
	end
	check("no filler part inside the reserved land (future Outlets and Farm slots, Malarayat entrance, Carmel and Malarayat slots)", #inReserved == 0, list(inReserved))
	-- Tagbakin (site 09, slot x -720..-480, z 450..650) gets Taal Volcano and the lake view: nothing within 250 studs of (-600, 550), and nothing
	-- west of x -480 where z > 300 (coordinator, 2026-10-31).
	local nearTaal = {}
	for _, p in ipairs(parts) do
		local x0, x1, z0, z1 = xzBox(p)
		local qx, qz = math.clamp(-600, x0, x1), math.clamp(550, z0, z1)
		if (qx + 600) ^ 2 + (qz - 550) ^ 2 < 250 ^ 2 or (x0 < -480 and z1 > 300) then table.insert(nearTaal, p:GetFullName()) end
	end
	check("no filler part within 250 studs of Tagbakin (-600, 550) or west of x -480 with z > 300", #nearTaal == 0, list(nearTaal))

	check("CityFill holds 450 or more buildings (was 262)", buildings >= 450, buildings .. " buildings")
	-- REPLACED (core-town filler, 2026-10-31): "CityFill holds 3600..4400 parts" -> the same range for the outer town (no Core attribute);
	-- the core pass has its own cap (2000) above.
	local outerParts = 0
	for _, p in ipairs(parts) do
		local m = p:FindFirstAncestorOfClass("Model")
		if not (m and m:GetAttribute("Core") == true) then outerParts += 1 end
	end
	check("the outer CityFill (no Core attribute) holds 3600..4400 parts (was 2387; budget about 2000 new)", outerParts >= 3600 and outerParts <= 4400,
		outerParts .. " outer parts")

	-- New-pass buildings keep a 12-stud clear band from every road edge (the street rows already line the roads), and some stand deep.
	local newB, banded, deep = 0, {}, 0
	local function roadDist(px, pz)
		local best = math.huge
		for _, s in ipairs(segs) do best = math.min(best, segDist(px, pz, s.a, s.b) - (s.clear - ROAD_CLEAR)) end
		return best -- distance from the nearest road EDGE
	end
	if fill then
		for _, m in ipairs(fill:GetChildren()) do
			if m:IsA("Model") and (m:GetAttribute("Pass") or 1) >= 2 and m:FindFirstChild("Body") then
				newB += 1
				for _, p in ipairs(m:GetDescendants()) do
					if p:IsA("BasePart") then
						local x0, x1, z0, z1 = xzBox(p)
						local hit = false
						for ix = 0, 4 do
							for iz = 0, 4 do
								if roadDist(x0 + (x1 - x0) * ix / 4, z0 + (z1 - z0) * iz / 4) < 12 then hit = true end
							end
						end
						if hit then table.insert(banded, p:GetFullName()) break end
					end
				end
				local lot = m:FindFirstChild("Lot")
				if lot and roadDist(lot.Position.X, lot.Position.Z) > 144 then deep += 1 end
			end
		end
	end
	check("150 or more new-pass buildings (attribute Pass 2 or 3)", newB >= 150, newB .. " new")
	check("no new-pass building comes within 12 studs of a road edge", newB > 0 and #banded == 0, newB .. " new, " .. list(banded))
	check("rows deeper than the old four: 60 or more new buildings whose Lot centre is over 144 studs from every road edge", deep >= 60, deep .. " deep")

	-- The grass corner by the Road A/B junction (handoff 059, owed): x -104..352, z -448..-336 (between City Hall's box, Road A, Road B and the
	-- core town). Every 8 studs, off the road bodies (half width + 5), a downward ray must land on a CityFill part, not on terrain.
	local lp = RaycastParams.new()
	lp.FilterType = Enum.RaycastFilterType.Include
	lp.FilterDescendantsInstances = { fill or workspace.World, workspace.Terrain }
	local cornerN, bare = 0, {}
	for x = -104, 352, 8 do
		for z = -448, -336, 8 do
			local nearRoad = false
			for _, s in ipairs(segs) do
				if segDist(x, z, s.a, s.b) < s.clear - ROAD_CLEAR + 5 then nearRoad = true break end
			end
			if not nearRoad then
				cornerN += 1
				local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), lp)
				if not r or r.Instance == workspace.Terrain then table.insert(bare, string.format("(%d,%d)", x, z)) end
			end
		end
	end
	check("the Road A/B corner (x -104..352, z -448..-336) is filled: every sample lands on a CityFill part", cornerN > 0 and #bare == 0,
		#bare .. " of " .. cornerN .. " bare: " .. table.concat(bare, " ", 1, math.min(#bare, 8)))

	-- Lots touch but never overlap (more than 0.1 stud) one another.
	local lots = {}
	for _, p in ipairs(parts) do
		if p.Name == "Lot" then
			local x0, x1, z0, z1 = xzBox(p)
			table.insert(lots, { p = p, x0 = x0, x1 = x1, z0 = z0, z1 = z1 })
		end
	end
	local clash = {}
	for i = 1, #lots do
		local a = lots[i]
		for j = i + 1, #lots do
			local b = lots[j]
			if a.x0 < b.x1 - 0.1 and a.x1 > b.x0 + 0.1 and a.z0 < b.z1 - 0.1 and a.z1 > b.z0 + 0.1 then
				table.insert(clash, a.p.Parent.Name .. "/" .. b.p.Parent.Name)
			end
		end
		if i % 100 == 0 then task.wait() end
	end
	check("no two Lots overlap", #lots > 0 and #clash == 0, #lots .. " lots, " .. list(clash))

	-- Some variety: three kinds of roof detail among the new buildings.
	local kinds = {}
	if fill then
		for _, m in ipairs(fill:GetChildren()) do
			if m:IsA("Model") and (m:GetAttribute("Pass") or 1) >= 2 then
				for _, n in ipairs({ "Tank", "RoofBox", "Gable" }) do
					if m:FindFirstChild(n) then kinds[n] = true end
				end
			end
		end
	end
	local nk = 0
	for _ in pairs(kinds) do nk += 1 end
	check("new buildings show 3 kinds of roof detail (Tank, RoofBox, Gable)", nk == 3, nk .. " kinds")
end

-- Mood (owner, second round: "a nice mood of weather like sunny or sunset"): golden late afternoon.
check("golden hour: Lighting.ClockTime 16.6..17.9", game.Lighting.ClockTime >= 16.6 and game.Lighting.ClockTime <= 17.9, tostring(game.Lighting.ClockTime))

-- Music (owner, second round: "a relaxing music"): a looping track in SoundService tagged Music=true, started with the ambient loop by
-- WelcomeClient and silenced with it by the PassportClient Mute button. Track: "Lofi Chill Blue Cat Study and Relaxing" (DistrokidOfficial,
-- Creator Store, free).
local SoundService = game:GetService("SoundService")
local music
for _, s in ipairs(SoundService:GetChildren()) do
	if s:IsA("Sound") and s:GetAttribute("Music") == true then music = s break end
end
check("a Sound in SoundService is tagged Music=true", music ~= nil)
if music then
	check("music: the chosen track, looped, volume 0.1..0.4", music.SoundId == "rbxassetid://76934240287978" and music.Looped and music.Volume >= 0.1 and music.Volume <= 0.4,
		music.SoundId .. " looped " .. tostring(music.Looped) .. " vol " .. music.Volume)
end
local sps = game:GetService("StarterPlayer").StarterPlayerScripts
local welcome, passport = sps:FindFirstChild("WelcomeClient"), sps:FindFirstChild("PassportClient")
check("WelcomeClient starts the Music sounds", welcome ~= nil and string.find(welcome.Source, 'GetAttribute("Music")', 1, true) ~= nil)
check("PassportClient Mute also silences the Music sounds", passport ~= nil and string.find(passport.Source, 'GetAttribute("Music")', 1, true) ~= nil)

-- Haze: Lighting.Atmosphere thickened (was Density 0.30, Haze 0).
local atmo = game.Lighting:FindFirstChildOfClass("Atmosphere")
check("Lighting has one Atmosphere", atmo ~= nil)
if atmo then
	check("haze: Atmosphere Density 0.38..0.5 and Haze 1..2.5", atmo.Density >= 0.38 and atmo.Density <= 0.5 and atmo.Haze >= 1 and atmo.Haze <= 2.5,
		string.format("Density %.2f Haze %.2f", atmo.Density, atmo.Haze))
end

return HttpService:JSONEncode(results)
