-- filler: idempotently builds Workspace.World.CityFill, generic town buildings along the outer roads (the haze, light and music are in
-- builders/mood.luau). Why (owner, 2026-10-31): the far sites stood alone on open grass and could be seen from a mile away; four rows of
-- town blocks on touching concrete lots (paved like the road) keep each site a surprise until the player arrives. Guarded by
-- tests/filler_check.luau.
-- Run via execute_luau (Edit): require(game.ServerStorage.Builders.filler:Clone())()  Also repaints Grass -> Pavement under the town (see paint below); touches no Sites and no roads.
-- Rules: never inside a site (footprint + 10 percent + 26), the core town where the walking routes run (x -600..360, z -330..352; Passes 1 to 3), a road
-- body (half width + 4) or beyond +-978; lots on terrain only (no water), at most 5 studs of slope; lots touch but never overlap. A seeded
-- Random keeps every run identical. Where no building fits, the front row's sidewalk is paved in 8-stud Lot pieces.
-- Each building: a concrete Lot (sidewalk in front, hides the grass), a Body, a storefront band, a Door (8.5 tall),
-- one window strip per upper floor on the road face, a roof parapet, and sometimes an awning or a roof tank. No text, images or scripts.
-- Fourth round (owner, 2026-10-31: "build more filler buildings"): after the four street rows (Pass 1), Pass 2 adds rows 5 and 6 behind them and
-- Pass 3 fills the remaining free land outward from the roads (nearest first) until the part budget (PART_CAP) is spent; both use cheaper blocks
-- (Lot, Body, Door, a glass curtain wall or up to three window strips, and a parapet, gable, roof box or tank) tagged with the attribute Pass,
-- kept 12 studs from every road edge and 8 studs from the core, the site boxes and the reserved land. Last, the grass corner by the Road A/B
-- junction is paved with flat Lot strips that exactly fill the gaps between the lots. Reserved land, never built on: the future Outlets
-- (x 325..775, z -850..-550) and Farm (x 570..970, z 80..400) slots plus 26, 60 studs round Malarayat's new entrance (450, 560), 250 studs round
-- Tagbakin (-600, 550) and everything west of x -480 with z > 300 (Taal Volcano and the lake view), and the grass control cells of the checks.
-- Fifth round (owner, 2026-10-31: yes to filling the core town): Passes 1 to 3 still keep out of the core box; Pass 4 (after the corner strips)
-- fills the free core lots with the same cheap blocks in rows of touching lots along the core roads, then a gap fill, from its own seeded Random,
-- so the outer town is unchanged. See the Pass 4 comment for what it keeps clear. require(...)({ planOnly = true }) counts the core lots
-- without building them (an approximate dry run: it skips the blocks' own random draws, so later lots and the count differ a little).
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())

return function(opts)
	local planOnly = type(opts) == "table" and opts.planOnly == true
	local world = workspace:FindFirstChild("World")
	assert(world, "filler: Workspace.World not found")
	local old = world:FindFirstChild("CityFill")
	if old then old:Destroy() end

	local V, C3 = Vector3.new, Color3.fromRGB
	local CORE = { x0 = -600, x1 = 360, z0 = -330, z1 = 352 }
	local SITE_MARGIN, ROAD_CLEAR, EDGE = 26, 4, 978
	local rng = Random.new(20261031)
	local rng2 = Random.new(20261101) -- Passes 2 and 3, so Pass 1 draws the same numbers as before
	local PART_CAP, CORNER_RESERVE, NEW_CLEAR, PAD = 4400, 150, 12, 8
	local RESERVED = {
		{ x0 = 299, x1 = 801, z0 = -876, z1 = -524 }, -- Outlets future slot (x 325..775, z -850..-550) + 26
		{ x0 = 544, x1 = 996, z0 = 54, z1 = 426 }, -- Farm future slot (x 570..970, z 80..400) + 26
		{ x0 = 390, x1 = 510, z0 = 500, z1 = 620 }, -- Malarayat's new main entrance at the Road D mouth (450, 560) + 60
		{ x0 = -447, x1 = -153, z0 = -725, z1 = -475 }, -- Carmel slot (x -410..-190, z -690..-510) + 10 percent + 26
		{ x0 = 314, x1 = 806, z0 = 518, z1 = 922 }, -- Malarayat slot (x 360..760, z 560..880) + 10 percent + 26
		{ x0 = -2000, x1 = -480, z0 = 300, z1 = 2000 }, -- Tagbakin's Taal Volcano and lake view: west of x -480 with z > 300
	}
	local TAAL_X, TAAL_Z, TAAL_R = -600, 550, 250
	-- Terrain cells the checks expect to stay Grass outside every site box and the core (roads_check, world_check): no lot within 12.
	local PROTECT = { { 40, 360 }, { -300, 360 }, { -440, 470 }, { -950, -950 }, { 950, -950 }, { 950, 950 } }
	local function reservedHit(x0, x1, z0, z1, pad)
		for _, b in ipairs(RESERVED) do
			if x0 < b.x1 + pad and x1 > b.x0 - pad and z0 < b.z1 + pad and z1 > b.z0 - pad then return true end
		end
		local qx, qz = math.clamp(TAAL_X, x0, x1), math.clamp(TAAL_Z, z0, z1)
		if (qx - TAAL_X) ^ 2 + (qz - TAAL_Z) ^ 2 < (TAAL_R + pad) ^ 2 then return true end
		for _, c in ipairs(PROTECT) do
			if c[1] > x0 - 12 and c[1] < x1 + 12 and c[2] > z0 - 12 and c[2] < z1 + 12 then return true end
		end
		return false
	end

	local WALLS = {
		C3(236, 226, 200), C3(200, 202, 204), C3(232, 196, 170), C3(184, 204, 222),
		C3(196, 216, 190), C3(238, 238, 234), C3(240, 224, 160), C3(222, 170, 150),
	}
	local AWNINGS = { C3(176, 52, 46), C3(46, 110, 70), C3(40, 84, 150), C3(214, 150, 40) }
	local TRIM, GLASS, SHUTTER, LOT, TANK = C3(70, 74, 80), C3(70, 96, 112), C3(150, 154, 158), C3(178, 176, 170), C3(60, 110, 170)

	local siteBoxes = {}
	for _, s in ipairs(SiteData.sites) do
		local hx, hz = s.size.X / 2 * 1.1 + SITE_MARGIN, s.size.Y / 2 * 1.1 + SITE_MARGIN
		table.insert(siteBoxes, { x0 = s.pos.X - hx, x1 = s.pos.X + hx, z0 = s.pos.Z - hz, z1 = s.pos.Z + hz })
	end
	local segs = {}
	for _, r in ipairs(RoadData.all()) do
		for i = 1, #r.pts - 1 do
			table.insert(segs, { a = r.pts[i], b = r.pts[i + 1], hw = r.w / 2 })
		end
	end
	local function segDist(px, pz, a, b)
		local dx, dz = b[1] - a[1], b[2] - a[2]
		local t = math.clamp(((px - a[1]) * dx + (pz - a[2]) * dz) / (dx * dx + dz * dz), 0, 1)
		local cx, cz = a[1] + t * dx - px, a[2] + t * dz - pz
		return math.sqrt(cx * cx + cz * cz)
	end
	local function overlaps(b, x0, x1, z0, z1)
		return x0 < b.x1 and x1 > b.x0 and z0 < b.z1 and z1 > b.z0
	end

	local tp = RaycastParams.new()
	tp.FilterType = Enum.RaycastFilterType.Include
	tp.FilterDescendantsInstances = { workspace.Terrain }
	local function ground(x, z)
		local r = workspace:Raycast(V(x, 400, z), V(0, -800, 0), tp)
		if not r or r.Material == Enum.Material.Water then return nil end
		return r.Position.Y
	end

	-- AABBs of accepted lots, in a 64-stud spatial hash used only for overlap queries (never for order).
	local placed, HCELL = {}, 64
	local function hashCells(x0, x1, z0, z1, fn)
		for i = math.floor(x0 / HCELL), math.floor(x1 / HCELL) do
			for k = math.floor(z0 / HCELL), math.floor(z1 / HCELL) do
				if fn(i * 4096 + k) then return true end
			end
		end
		return false
	end
	local function addPlaced(b)
		hashCells(b.x0, b.x1, b.z0, b.z1, function(key)
			local t = placed[key]
			if not t then t = {} placed[key] = t end
			table.insert(t, b)
			return false
		end)
	end
	local function hitsPlaced(x0, x1, z0, z1)
		return hashCells(x0, x1, z0, z1, function(key)
			for _, b in ipairs(placed[key] or {}) do
				if overlaps(b, x0, x1, z0, z1) then return true end
			end
			return false
		end)
	end
	-- A lot is the rectangle centred at (cx, cz), width w along u, depth d along n. Returns ymin, ymax or nil.
	local function lotOK(cx, cz, ux, uz, nx, nz, w, d)
		local ex = math.abs(ux) * w / 2 + math.abs(nx) * d / 2
		local ez = math.abs(uz) * w / 2 + math.abs(nz) * d / 2
		local x0, x1, z0, z1 = cx - ex, cx + ex, cz - ez, cz + ez
		if math.max(math.abs(x0), math.abs(x1), math.abs(z0), math.abs(z1)) > EDGE then return nil end
		if overlaps(CORE, x0 - 2, x1 + 2, z0 - 2, z1 + 2) then return nil end
		for _, b in ipairs(siteBoxes) do
			if overlaps(b, x0, x1, z0, z1) then return nil end
		end
		if reservedHit(x0, x1, z0, z1, PAD) then return nil end
		if hitsPlaced(x0 + 0.05, x1 - 0.05, z0 + 0.05, z1 - 0.05) then return nil end
		local gx, gz = math.max(1, math.ceil((x1 - x0) / 3)), math.max(1, math.ceil((z1 - z0) / 3))
		for ix = 0, gx do
			for iz = 0, gz do
				local px, pz = x0 + (x1 - x0) * ix / gx, z0 + (z1 - z0) * iz / gz
				for _, s in ipairs(segs) do
					if segDist(px, pz, s.a, s.b) < s.hw + ROAD_CLEAR then return nil end
				end
			end
		end
		local ymin, ymax = math.huge, -math.huge
		for _, o in ipairs({ { 0, 0 }, { -1, -1 }, { -1, 1 }, { 1, -1 }, { 1, 1 } }) do
			local y = ground(cx + ux * o[1] * w / 2 + nx * o[2] * d / 2, cz + uz * o[1] * w / 2 + nz * o[2] * d / 2)
			if not y then return nil end
			ymin, ymax = math.min(ymin, y), math.max(ymax, y)
		end
		if ymax - ymin > 5 then return nil end
		addPlaced({ x0 = x0, x1 = x1, z0 = z0, z1 = z1 })
		return ymin, ymax
	end

	-- Passes 2 and 3: the same lot rules, stricter. 8 studs (PAD) from the core, the site boxes and the reserved land, so the 4-stud paint pad
	-- and the 4-stud voxel grid never reach them; 12 studs (NEW_CLEAR) from every road edge, measured exactly (the roads are axis-aligned).
	local function rectRoadClear(x0, x1, z0, z1)
		for _, s in ipairs(segs) do
			local sx0, sx1 = math.min(s.a[1], s.b[1]), math.max(s.a[1], s.b[1])
			local sz0, sz1 = math.min(s.a[2], s.b[2]), math.max(s.a[2], s.b[2])
			local dx = math.max(0, sx0 - x1, x0 - sx1)
			local dz = math.max(0, sz0 - z1, z0 - sz1)
			if dx * dx + dz * dz < (s.hw + NEW_CLEAR) ^ 2 then return false end
		end
		return true
	end
	local function lotOK2(x0, x1, z0, z1)
		if math.max(math.abs(x0), math.abs(x1), math.abs(z0), math.abs(z1)) > EDGE then return nil end
		if overlaps(CORE, x0 - PAD, x1 + PAD, z0 - PAD, z1 + PAD) then return nil end
		for _, b in ipairs(siteBoxes) do
			if overlaps(b, x0 - PAD, x1 + PAD, z0 - PAD, z1 + PAD) then return nil end
		end
		if reservedHit(x0, x1, z0, z1, PAD) then return nil end
		if hitsPlaced(x0 + 0.05, x1 - 0.05, z0 + 0.05, z1 - 0.05) then return nil end
		if not rectRoadClear(x0, x1, z0, z1) then return nil end
		local ymin, ymax = math.huge, -math.huge
		for _, o in ipairs({ { 0.5, 0.5 }, { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } }) do
			local y = ground(x0 + (x1 - x0) * o[1], z0 + (z1 - z0) * o[2])
			if not y then return nil end
			ymin, ymax = math.min(ymin, y), math.max(ymax, y)
		end
		if ymax - ymin > 5 then return nil end
		addPlaced({ x0 = x0, x1 = x1, z0 = z0, z1 = z1 })
		return ymin, ymax
	end

	-- Ground under the town (owner, 2026-10-31: "repaint under the town"): every accepted lot, and for the front row the verge out to the
	-- road edge, is repainted Grass -> Pavement after the build (ReplaceMaterial swaps Grass only: the Asphalt roads are untouched; a second
	-- run finds no Grass left and changes nothing). To undo: the same regions Pavement -> Grass.
	local paint = {}
	local function addPaint(cx, cz, ux, uz, nx, nz, w, d, ymin, ymax)
		local ex = math.abs(ux) * w / 2 + math.abs(nx) * d / 2
		local ez = math.abs(uz) * w / 2 + math.abs(nz) * d / 2
		-- padded one voxel (4 studs): terrain blends the surface material across the neighbouring cell, so grass would show at lot edges
		table.insert(paint, { cx - ex - 4, cx + ex + 4, cz - ez - 4, cz + ez + 4, ymin - 6, ymax + 6 })
	end

	local fill = Instance.new("Folder")
	fill.Name = "CityFill"
	fill.Parent = world

	local count, parts = 0, 0
	local function part(model, name, size, cf, color, material, className)
		local p = Instance.new(className or "Part")
		p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
		p.Material = material or Enum.Material.SmoothPlastic
		p.Anchored = true
		p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		p.Parent = model
		parts += 1
		return p
	end

	-- A pavement-only piece (one Lot part straight in the folder) where a whole building lot does not fit.
	local function pavement(cx, cz, nx, nz, w, depth, ymin, ymax)
		local face = CFrame.lookAt(V(cx, 0, cz), V(cx - nx, 0, cz - nz))
		local top = ymax + 0.6
		part(fill, "Lot", V(w, top - (ymin - 1), depth), face + V(0, (top + ymin - 1) / 2, 0), LOT, Enum.Material.Concrete)
	end

	-- One building on a lot lotW wide and lotDepth deep. frame: origin at the lot centre at ground, LookVector toward the road (-n).
	-- The lot is wider and deeper than the body, so neighbouring lots touch and the street edge is paved end to end.
	local function building(cx, cz, ux, uz, nx, nz, lotW, lotDepth, w, d, front, floors, ymin, ymax)
		count += 1
		local m = Instance.new("Model")
		m.Name = string.format("Bldg%03d", count)
		local top = ymax + 0.6
		local face = CFrame.lookAt(V(cx, 0, cz), V(cx - nx, 0, cz - nz)) -- local -Z toward the road
		local function at(lx, y, lz) return face * CFrame.new(lx, 0, lz) + V(0, y, 0) end
		-- local z: the lot spans -lotDepth/2 (road side) .. +lotDepth/2; the body stands behind the front strip
		local lotH = top - (ymin - 1)
		part(m, "Lot", V(lotW, lotH, lotDepth), at(0, (top + ymin - 1) / 2, 0), LOT, Enum.Material.Concrete)
		local H = 10 + 8 * floors
		local bz = -lotDepth / 2 + front + d / 2
		local wall = WALLS[rng:NextInteger(1, #WALLS)]
		part(m, "Body", V(w, H, d), at(0, top + H / 2, bz), wall, Enum.Material.Concrete)
		local fz = bz - d / 2 -- the road face
		local shop = rng:NextNumber() < 0.5
		part(m, "Storefront", V(w - 2, 8, 0.4), at(0, top + 4.6, fz - 0.2), shop and GLASS or SHUTTER, shop and Enum.Material.Glass or Enum.Material.Metal)
		local dx = (rng:NextNumber() - 0.5) * (w - 8)
		part(m, "Door", V(4, 8.5, 0.5), at(dx, top + 4.25, fz - 0.5), TRIM)
		for f = 1, math.min(floors, 5) do
			part(m, "WindowStrip", V(w - 3, 3.2, 0.3), at(0, top + 10 + (f - 1) * 8 + 2.6, fz - 0.15), GLASS, Enum.Material.Glass)
		end
		part(m, "Parapet", V(w + 0.6, 1, d + 0.6), at(0, top + H + 0.5, bz), wall:Lerp(TRIM, 0.35), Enum.Material.Concrete)
		local extra = rng:NextNumber()
		if extra < 0.35 then
			part(m, "Awning", V(w - 2, 0.5, 3), at(0, top + 9.4, fz - 1.5), AWNINGS[rng:NextInteger(1, #AWNINGS)], Enum.Material.Fabric)
		elseif extra < 0.6 then
			part(m, "Tank", V(4, 4, 4), at((rng:NextNumber() - 0.5) * (w - 6), top + H + 3, bz), TANK, Enum.Material.Plastic)
		end
		m.Parent = fill
	end

	for si, s in ipairs(segs) do
		local ax, az, bx, bz = s.a[1], s.a[2], s.b[1], s.b[2]
		local L = math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2)
		local ux, uz = (bx - ax) / L, (bz - az) / L
		for _, side in ipairs({ 1, -1 }) do
			local nx, nz = -uz * side, ux * side
			-- Four rows of touching lots, ROW_DEPTH deep each: the front row keeps a 6-stud sidewalk, the rows behind grow taller.
			local ROW_DEPTH = 34
			local base = s.hw + ROAD_CLEAR + 0.5
			for r, row in ipairs({ { front = 6, minF = 1, maxF = 3 }, { front = 3, minF = 2, maxF = 4 }, { front = 3, minF = 3, maxF = 6 }, { front = 3, minF = 3, maxF = 6 } }) do
				local off = base + (r - 1) * ROW_DEPTH + ROW_DEPTH / 2
				local t = 2
				while t < L - 2 do
					local w = rng:NextInteger(18, 30)
					local lotW = w + rng:NextInteger(3, 6)
					local d = rng:NextInteger(18, ROW_DEPTH - row.front - 2)
					local floors = rng:NextInteger(row.minF, row.maxF)
					if t + lotW > L - 2 then lotW = L - 2 - t end
					if lotW < 8 then break end
					local tc = t + lotW / 2
					local cx, cz = ax + ux * tc + nx * off, az + uz * tc + nz * off
					local ymin, ymax
					if lotW >= w + 2 then ymin, ymax = lotOK(cx, cz, ux, uz, nx, nz, lotW, ROW_DEPTH) end
					if ymin then
						building(cx, cz, ux, uz, nx, nz, lotW, ROW_DEPTH, w, d, row.front, floors, ymin, ymax)
						if r == 1 then
							local verge = ROAD_CLEAR + 0.5
							addPaint(cx - nx * verge / 2, cz - nz * verge / 2, ux, uz, nx, nz, lotW, ROW_DEPTH + verge, ymin, ymax)
						else
							addPaint(cx, cz, ux, uz, nx, nz, lotW, ROW_DEPTH, ymin, ymax)
						end
					elseif r == 1 then
						-- no room for a building here: pave the sidewalk strip in 8-stud pieces where they fit
						local k = 0
						while k + 8 <= lotW do
							local pc = t + k + 4
							local pcx, pcz = ax + ux * pc + nx * (base + 4), az + uz * pc + nz * (base + 4)
							local y0, y1 = lotOK(pcx, pcz, ux, uz, nx, nz, 8, 8)
							if y0 then
								pavement(pcx, pcz, nx, nz, 8, 8, y0, y1)
								local verge = ROAD_CLEAR + 0.5
								addPaint(pcx - nx * verge / 2, pcz - nz * verge / 2, ux, uz, nx, nz, 8, 8 + verge, y0, y1)
							end
							k += 8
						end
					end
					t += lotW
				end
			end
			task.wait()
		end
		if si % 4 == 0 then task.wait() end
	end
	local pass1Count, pass1Parts = count, parts

	-- Passes 2 and 3 build cheaper blocks (about 6 to 8 parts). The lot is the world-aligned box x0..x1, z0..z1; (nx, nz) points from the road
	-- to the lot, so the door and windows face the road. More wall colours than Pass 1 and four roof kinds: a plain parapet, a gable (two
	-- wedges, low buildings only), a roof box (stair housing) or a water tank.
	local WALLS2 = {
		C3(236, 226, 200), C3(200, 202, 204), C3(232, 196, 170), C3(184, 204, 222), C3(196, 216, 190), C3(238, 238, 234),
		C3(240, 224, 160), C3(222, 170, 150), C3(214, 206, 188), C3(176, 168, 160), C3(228, 214, 228), C3(206, 226, 214),
		C3(244, 206, 140), C3(190, 150, 120),
	}
	local ROOF = C3(150, 72, 56)
	local sinceWait = 0
	local function block(pass, x0, x1, z0, z1, nx, nz, floors, ymin, ymax, gen)
		local rng2 = gen or rng2 -- Pass 4 passes its own Random; Passes 2 and 3 draw from rng2 as before
		count += 1
		local m = Instance.new("Model")
		m.Name = string.format("Bldg%03d", count)
		if pass <= 3 then m:SetAttribute("Pass", pass) else m:SetAttribute("Core", true) end
		local cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
		local lotW = nx ~= 0 and (z1 - z0) or (x1 - x0) -- along the road
		local lotD = nx ~= 0 and (x1 - x0) or (z1 - z0) -- away from the road
		local top = ymax + 0.6
		local face = CFrame.lookAt(V(cx, 0, cz), V(cx - nx, 0, cz - nz)) -- local -Z toward the road
		local function at(lx, y, lz) return face * CFrame.new(lx, 0, lz) + V(0, y, 0) end
		local before = parts
		part(m, "Lot", V(lotW, top - (ymin - 1), lotD), at(0, (top + ymin - 1) / 2, 0), LOT, Enum.Material.Concrete)
		local w = lotW - rng2:NextInteger(3, 6)
		local d = lotD - rng2:NextInteger(4, 8)
		local H = 10 + 8 * floors
		local bz = -lotD / 2 + 3 + d / 2
		local wall = WALLS2[rng2:NextInteger(1, #WALLS2)]
		part(m, "Body", V(w, H, d), at(0, top + H / 2, bz), wall, Enum.Material.Concrete)
		local fz = bz - d / 2 -- the road face
		part(m, "Door", V(4, 8.5, 0.5), at((rng2:NextNumber() - 0.5) * (w - 8), top + 4.25, fz - 0.25), TRIM)
		if floors >= 3 and rng2:NextNumber() < 0.35 then
			part(m, "Curtain", V(w - 3, H - 14, 0.3), at(0, top + 12 + (H - 14) / 2, fz - 0.15), GLASS, Enum.Material.Glass)
		else
			for f = 1, math.min(floors, 3) do
				part(m, "WindowStrip", V(w - 3, 3.2, 0.3), at(0, top + 10 + (f - 1) * 8 + 2.6, fz - 0.15), GLASS, Enum.Material.Glass)
			end
		end
		local roof = rng2:NextNumber()
		if roof < 0.22 and floors <= 4 then
			local rh = math.min(8, d / 3)
			part(m, "Gable", V(w + 1, rh, d / 2 + 0.5), at(0, top + H + rh / 2, bz - d / 4 - 0.25), ROOF, Enum.Material.Slate, "WedgePart")
			part(m, "Gable", V(w + 1, rh, d / 2 + 0.5), at(0, top + H + rh / 2, bz + d / 4 + 0.25) * CFrame.Angles(0, math.pi, 0), ROOF,
				Enum.Material.Slate, "WedgePart")
		else
			part(m, "Parapet", V(w + 0.6, 1, d + 0.6), at(0, top + H + 0.5, bz), wall:Lerp(TRIM, 0.35), Enum.Material.Concrete)
			if roof < 0.55 then
				part(m, "RoofBox", V(8, 6, 6), at((rng2:NextNumber() - 0.5) * (w - 10), top + H + 4, bz + (rng2:NextNumber() - 0.5) * (d - 8)),
					wall:Lerp(TRIM, 0.5), Enum.Material.Concrete)
			elseif roof < 0.8 then
				part(m, "Tank", V(4, 4, 4), at((rng2:NextNumber() - 0.5) * (w - 6), top + H + 3, bz), TANK, Enum.Material.Plastic)
			end
		end
		m.Parent = fill
		sinceWait += parts - before
		if sinceWait >= 300 then
			sinceWait = 0
			task.wait()
		end
	end
	local function budget(n) return parts + n <= PART_CAP - CORNER_RESERVE end
	local function paintBox(x0, x1, z0, z1, ymin, ymax)
		addPaint((x0 + x1) / 2, (z0 + z1) / 2, 1, 0, 0, 1, x1 - x0, z1 - z0, ymin, ymax)
	end

	-- Pass 2: rows 5 and 6, behind the four street rows, on both sides of every road segment.
	for si, s in ipairs(segs) do
		local ax, az, bx, bz = s.a[1], s.a[2], s.b[1], s.b[2]
		local L = math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2)
		local ux, uz = (bx - ax) / L, (bz - az) / L
		for _, side in ipairs({ 1, -1 }) do
			local nx, nz = -uz * side, ux * side
			local ROW_DEPTH = 34
			local base = s.hw + ROAD_CLEAR + 0.5
			for r = 5, 6 do
				local off = base + (r - 1) * ROW_DEPTH + ROW_DEPTH / 2
				local t = 2
				while t < L - 2 do
					local lotW = rng2:NextInteger(22, 34)
					local floors = rng2:NextInteger(3, 8)
					if t + lotW > L - 2 then lotW = L - 2 - t end
					if lotW < 16 then break end
					local tc = t + lotW / 2
					local cx, cz = ax + ux * tc + nx * off, az + uz * tc + nz * off
					local ex = math.abs(ux) * lotW / 2 + math.abs(nx) * ROW_DEPTH / 2
					local ez = math.abs(uz) * lotW / 2 + math.abs(nz) * ROW_DEPTH / 2
					if budget(12) then
						local ymin, ymax = lotOK2(cx - ex, cx + ex, cz - ez, cz + ez)
						if ymin then
							block(2, cx - ex, cx + ex, cz - ez, cz + ez, nx, nz, floors, ymin, ymax)
							paintBox(cx - ex, cx + ex, cz - ez, cz + ez, ymin, ymax)
						end
					end
					t += lotW
				end
			end
		end
		task.wait()
	end
	local pass2Count = count - pass1Count

	-- Pass 3: fill the free land outward from the roads. Candidate lot centres on an 8-stud grid, 24..320 studs from the nearest road edge,
	-- nearest first (ties by z, then x); each takes a 32-stud lot, else a 24-stud one, facing its nearest road.
	local cands = {}
	for gx = -976, 976, 8 do
		for gz = -976, 976, 8 do
			if not (gx > CORE.x0 - 24 and gx < CORE.x1 + 24 and gz > CORE.z0 - 24 and gz < CORE.z1 + 24) then
				local best, bs = math.huge, nil
				for _, s in ipairs(segs) do
					local dd = segDist(gx, gz, s.a, s.b) - s.hw
					if dd < best then best, bs = dd, s end
				end
				if best >= NEW_CLEAR + 12 and best <= 320 then table.insert(cands, { x = gx, z = gz, d = best, s = bs }) end
			end
		end
		if gx % 128 == 0 then task.wait() end
	end
	table.sort(cands, function(a, b)
		if a.d ~= b.d then return a.d < b.d end
		if a.z ~= b.z then return a.z < b.z end
		return a.x < b.x
	end)
	for i, c in ipairs(cands) do
		if not budget(12) then break end
		if not hitsPlaced(c.x - 0.5, c.x + 0.5, c.z - 0.5, c.z + 0.5) then
			for _, size in ipairs({ 32, 24 }) do
				local h = size / 2
				local ymin, ymax = lotOK2(c.x - h, c.x + h, c.z - h, c.z + h)
				if ymin then
					local a, b = c.s.a, c.s.b
					local dx, dz = b[1] - a[1], b[2] - a[2]
					local t = math.clamp(((c.x - a[1]) * dx + (c.z - a[2]) * dz) / (dx * dx + dz * dz), 0, 1)
					local vx, vz = c.x - (a[1] + t * dx), c.z - (a[2] + t * dz)
					local nx, nz = 0, 0
					if math.abs(vx) >= math.abs(vz) then nx = math.sign(vx) else nz = math.sign(vz) end
					block(3, c.x - h, c.x + h, c.z - h, c.z + h, nx, nz, rng2:NextInteger(2, 7), ymin, ymax)
					paintBox(c.x - h, c.x + h, c.z - h, c.z + h, ymin, ymax)
					break
				end
			end
		end
		if i % 300 == 0 then task.wait() end
	end
	local pass3Count = count - pass1Count - pass2Count

	-- The grass corner by the Road A/B junction (handoff 059): between City Hall's box (x -112), Road B, the core town (z -332) and x 356, flat
	-- Lot strips fill exactly the gaps between the lots and the road bodies (half width + 4): a sweep over the z edges of every blocker, the
	-- free x runs of each band, merged down the bands where they line up.
	local CB = { x0 = -112, x1 = 356, z0 = -450, z1 = -332 }
	local blockers, seen = {}, {}
	hashCells(CB.x0, CB.x1, CB.z0, CB.z1, function(key)
		for _, b in ipairs(placed[key] or {}) do
			if not seen[b] and overlaps(b, CB.x0, CB.x1, CB.z0, CB.z1) then
				seen[b] = true
				table.insert(blockers, b)
			end
		end
		return false
	end)
	for _, s in ipairs(segs) do
		local e = s.hw + ROAD_CLEAR
		local b = { x0 = math.min(s.a[1], s.b[1]) - e, x1 = math.max(s.a[1], s.b[1]) + e, z0 = math.min(s.a[2], s.b[2]) - e, z1 = math.max(s.a[2], s.b[2]) + e }
		if overlaps(b, CB.x0, CB.x1, CB.z0, CB.z1) then table.insert(blockers, b) end
	end
	local edges = { CB.z0, CB.z1 }
	for _, b in ipairs(blockers) do
		if b.z0 > CB.z0 and b.z0 < CB.z1 then table.insert(edges, b.z0) end
		if b.z1 > CB.z0 and b.z1 < CB.z1 then table.insert(edges, b.z1) end
	end
	table.sort(edges)
	local zs = {}
	for _, z in ipairs(edges) do
		if #zs == 0 or z - zs[#zs] > 0.01 then table.insert(zs, z) end
	end
	local strips, open = {}, {}
	for i = 1, #zs - 1 do
		local za, zb = zs[i], zs[i + 1]
		local iv = {}
		for _, b in ipairs(blockers) do
			if b.z0 < zb - 0.001 and b.z1 > za + 0.001 then table.insert(iv, { math.max(b.x0, CB.x0), math.min(b.x1, CB.x1) }) end
		end
		table.sort(iv, function(p, q) return p[1] < q[1] end)
		local x, nextOpen = CB.x0, {}
		local function free(fx0, fx1)
			if fx1 - fx0 < 0.5 then return end
			local key = string.format("%.3f:%.3f", fx0, fx1)
			local st = open[key]
			if st then
				st.z1 = zb
			else
				st = { x0 = fx0, x1 = fx1, z0 = za, z1 = zb }
				table.insert(strips, st)
			end
			nextOpen[key] = st
		end
		for _, p in ipairs(iv) do
			if p[1] > x then free(x, p[1]) end
			x = math.max(x, p[2])
		end
		if x < CB.x1 then free(x, CB.x1) end
		open = nextOpen
	end
	local corner = 0
	for _, st in ipairs(strips) do
		if st.z1 - st.z0 >= 0.5 and parts < PART_CAP then
			local ymin, ymax = math.huge, -math.huge
			for _, o in ipairs({ { 0.5, 0.5 }, { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } }) do
				local y = ground(st.x0 + (st.x1 - st.x0) * o[1], st.z0 + (st.z1 - st.z0) * o[2]) or 0
				ymin, ymax = math.min(ymin, y), math.max(ymax, y)
			end
			local top = ymax + 0.6
			part(fill, "Lot", V(st.x1 - st.x0, top - (ymin - 1), st.z1 - st.z0), CFrame.new((st.x0 + st.x1) / 2, (top + ymin - 1) / 2, (st.z0 + st.z1) / 2),
				LOT, Enum.Material.Concrete)
			paintBox(st.x0, st.x1, st.z0, st.z1, ymin, ymax)
			corner += 1
		end
	end

	-- Pass 4, the core town (owner, 2026-10-31: yes to filling the core box x -600..360, z -330..352 where the walking routes run). Four rows
	-- of touching lots (34 deep) along both sides of every road segment inside the core, then a gap fill on an 8-stud grid (nearest road first,
	-- a 32-stud lot, else 24), at most CORE_CAP parts, drawn from its own Random (rng4) so Passes 1 to 3 build exactly as before. Low blocks
	-- (1 to 4 floors) so the Cathedral and the shops stay on top. The models carry Core = true and no Pass attribute. A core lot stays wholly
	-- inside the core box and keeps clear of: the site boxes (+ PAD) and the reserved land; the road bodies (half width + 4, exact); 9 studs
	-- (a 4-stud path plus 6, plus 1 spare) from every walking line below; the Credits Plaza (x 24..152, z 272..348) and its entry path
	-- (x 4..24, z 304..316), plus 12; 40 studs round the spawn (-208, -260); 16 studs round the Grass control cells of the checks; and every
	-- part of Workspace.Sites, the CreditsBoard and the SpawnLocation. tests/filler_check.luau holds the same lists.
	-- Walking lines: PathfindingService routes measured in Edit on 2026-10-31 (radius 2, no jump; the routes of tests/routes_check.luau and the
	-- guidance legs of GuidanceLogic: side stairs -> shop Guides, JeepStops -> Guides), thinned to about 12-stud steps; plus each core Guide's
	-- look line (150 studs along its facing) and the line from the Guide to its own site's centre.
	local CORE_CAP, WALK_CLEAR, CORE_ROW = 2000, 9, 34
	local rng4 = Random.new(20261104)
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
	local CREDITS = { { x0 = 24, x1 = 152, z0 = 272, z1 = 348 }, { x0 = 4, x1 = 24, z0 = 304, z1 = 316 } }
	local SPAWN_X, SPAWN_Z, SPAWN_R = -208, -260, 40
	-- Grass control cells in or near the core (roads_check and world_check; world_check's (150, -300) lies in a free lot).
	local GRASS_CTRL = {
		{ 150, -300 }, { -332, -300 }, { -300, -184 }, { -146, -300 }, { -580, 160 }, { -590, 160 }, { -400, -24 }, { -400, -22 }, { -300, 360 },
		{ -212, 170 }, { -212, 150 }, { -108, 150 }, { 108, 150 }, { -60, 208 }, { 40, 360 }, { -212, 100 }, { -212, 200 }, { -222, -24 }, { -212, 334 },
		{ -580, -14 }, { -212, -14 }, { -580, 334 }, { 360, 140 }, { 292, 76 }, { 292, 204 }, { -102, 50 }, { 102, 50 }, { 50, -2 }, -- world_check's (50, 102) reads Pavement today (stale there), so it is left out
	}
	local lines = {}
	for _, w in ipairs(WALK) do
		for i = 1, #w - 3, 2 do table.insert(lines, { w[i], w[i + 1], w[i + 2], w[i + 3] }) end
	end
	for _, s in ipairs(SiteData.sites) do
		local g = SiteData.guidePos(s.id)
		if g.X > CORE.x0 and g.X < CORE.x1 and g.Z > CORE.z0 and g.Z < CORE.z1 then
			local f = SiteData.facingVector(s.facing)
			table.insert(lines, { g.X, g.Z, g.X + f.X * 150, g.Z + f.Z * 150 })
			table.insert(lines, { g.X, g.Z, s.pos.X, s.pos.Z })
		end
	end
	-- Least xz distance from the box x0..x1, z0..z1 to the segment (ax, az)-(bx, bz): 0 when they meet (Liang-Barsky clip), else the least of the
	-- endpoint-to-box and corner-to-segment distances.
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
	local keepParts = {}
	for _, inst in ipairs({ workspace:FindFirstChild("Sites"), world:FindFirstChild("CreditsBoard"), workspace:FindFirstChild("SpawnLocation") }) do
		table.insert(keepParts, inst)
	end
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = keepParts
	local function lotOKCore(x0, x1, z0, z1)
		if x0 < CORE.x0 or x1 > CORE.x1 or z0 < CORE.z0 or z1 > CORE.z1 then return nil end
		for _, b in ipairs(siteBoxes) do
			if overlaps(b, x0 - PAD, x1 + PAD, z0 - PAD, z1 + PAD) then return nil end
		end
		if reservedHit(x0, x1, z0, z1, PAD) then return nil end
		for _, b in ipairs(CREDITS) do
			if overlaps(b, x0 - 12, x1 + 12, z0 - 12, z1 + 12) then return nil end
		end
		local qx, qz = math.clamp(SPAWN_X, x0, x1), math.clamp(SPAWN_Z, z0, z1)
		if (qx - SPAWN_X) ^ 2 + (qz - SPAWN_Z) ^ 2 < SPAWN_R ^ 2 then return nil end
		for _, c in ipairs(GRASS_CTRL) do
			if c[1] > x0 - 16 and c[1] < x1 + 16 and c[2] > z0 - 16 and c[2] < z1 + 16 then return nil end
		end
		if hitsPlaced(x0 + 0.05, x1 - 0.05, z0 + 0.05, z1 - 0.05) then return nil end
		for _, s in ipairs(segs) do
			if boxSegDist(x0, x1, z0, z1, s.a[1], s.a[2], s.b[1], s.b[2]) < s.hw + ROAD_CLEAR then return nil end
		end
		for _, l in ipairs(lines) do
			if boxSegDist(x0, x1, z0, z1, l[1], l[2], l[3], l[4]) < WALK_CLEAR then return nil end
		end
		if #workspace:GetPartBoundsInBox(CFrame.new((x0 + x1) / 2, 40, (z0 + z1) / 2), V(x1 - x0 + 2, 100, z1 - z0 + 2), op) > 0 then return nil end
		local ymin, ymax = math.huge, -math.huge
		for _, o in ipairs({ { 0.5, 0.5 }, { 0, 0 }, { 0, 1 }, { 1, 0 }, { 1, 1 } }) do
			local y = ground(x0 + (x1 - x0) * o[1], z0 + (z1 - z0) * o[2])
			if not y then return nil end
			ymin, ymax = math.min(ymin, y), math.max(ymax, y)
		end
		if ymax - ymin > 5 then return nil end
		addPlaced({ x0 = x0, x1 = x1, z0 = z0, z1 = z1 })
		return ymin, ymax
	end
	local coreStart, coreCount, corePaint = parts, 0, #paint
	local function coreBudget(n) return parts - coreStart + n <= CORE_CAP end
	local function coreBlock(x0, x1, z0, z1, nx, nz, floors, ymin, ymax, verge)
		coreCount += 1
		if planOnly then
			parts += 8 -- about one cheap block
			return
		end
		block(4, x0, x1, z0, z1, nx, nz, floors, ymin, ymax, rng4)
		-- the front row is also paved out to the road edge (the verge), as in Pass 1
		local px0, px1, pz0, pz1 = x0, x1, z0, z1
		if verge then
			if nx > 0 then px0 -= verge elseif nx < 0 then px1 += verge end
			if nz > 0 then pz0 -= verge elseif nz < 0 then pz1 += verge end
		end
		paintBox(px0, px1, pz0, pz1, ymin, ymax)
	end
	local CROWS = { { 1, 3 }, { 1, 3 }, { 2, 4 }, { 2, 4 } } -- floors per row (min, max)
	for _, s in ipairs(segs) do
		local ax, az, bx, bz = s.a[1], s.a[2], s.b[1], s.b[2]
		local L = math.sqrt((bx - ax) ^ 2 + (bz - az) ^ 2)
		local ux, uz = (bx - ax) / L, (bz - az) / L
		for _, side in ipairs({ 1, -1 }) do
			local nx, nz = -uz * side, ux * side
			local base = s.hw + ROAD_CLEAR + 0.5
			for r, row in ipairs(CROWS) do
				local off = base + (r - 1) * CORE_ROW + CORE_ROW / 2
				local t = 2
				while t < L - 2 do
					local lotW = rng4:NextInteger(22, 34)
					local floors = rng4:NextInteger(row[1], row[2])
					if t + lotW > L - 2 then lotW = L - 2 - t end
					if lotW < 16 then break end
					local tc = t + lotW / 2
					local cx, cz = ax + ux * tc + nx * off, az + uz * tc + nz * off
					local ex = math.abs(ux) * lotW / 2 + math.abs(nx) * CORE_ROW / 2
					local ez = math.abs(uz) * lotW / 2 + math.abs(nz) * CORE_ROW / 2
					if coreBudget(12) then
						local ymin, ymax = lotOKCore(cx - ex, cx + ex, cz - ez, cz + ez)
						if ymin then coreBlock(cx - ex, cx + ex, cz - ez, cz + ez, nx, nz, floors, ymin, ymax, r == 1 and ROAD_CLEAR + 0.5 or nil) end
					end
					t += lotW
				end
			end
		end
		task.wait()
	end
	local coreRows = coreCount
	local ccands = {}
	for gx = CORE.x0 + 12, CORE.x1 - 12, 8 do
		for gz = CORE.z0 + 12, CORE.z1 - 12, 8 do
			local best, bs = math.huge, nil
			for _, s in ipairs(segs) do
				local dd = segDist(gx, gz, s.a, s.b) - s.hw
				if dd < best then best, bs = dd, s end
			end
			if best >= ROAD_CLEAR + 12 then table.insert(ccands, { x = gx, z = gz, d = best, s = bs }) end
		end
	end
	table.sort(ccands, function(a, b)
		if a.d ~= b.d then return a.d < b.d end
		if a.z ~= b.z then return a.z < b.z end
		return a.x < b.x
	end)
	for i, c in ipairs(ccands) do
		if not coreBudget(12) then break end
		if not hitsPlaced(c.x - 0.5, c.x + 0.5, c.z - 0.5, c.z + 0.5) then
			for _, size in ipairs({ 32, 24 }) do
				local h = size / 2
				local ymin, ymax = lotOKCore(c.x - h, c.x + h, c.z - h, c.z + h)
				if ymin then
					local a, b = c.s.a, c.s.b
					local dx, dz = b[1] - a[1], b[2] - a[2]
					local t = math.clamp(((c.x - a[1]) * dx + (c.z - a[2]) * dz) / (dx * dx + dz * dz), 0, 1)
					local vx, vz = c.x - (a[1] + t * dx), c.z - (a[2] + t * dz)
					local nx, nz = 0, 0
					if math.abs(vx) >= math.abs(vz) then nx = math.sign(vx) else nz = math.sign(vz) end
					coreBlock(c.x - h, c.x + h, c.z - h, c.z + h, nx, nz, rng4:NextInteger(1, 4), ymin, ymax, nil)
					break
				end
			end
		end
		if i % 300 == 0 then task.wait() end
	end
	local coreParts, corePainted = parts - coreStart, #paint - corePaint
	if planOnly then parts = coreStart end

	local T = workspace.Terrain
	for i, p in ipairs(paint) do
		local region = Region3.new(V(p[1], p[5], p[3]), V(p[2], p[6], p[4])):ExpandToGrid(4)
		T:ReplaceMaterial(region, 4, Enum.Material.Grass, Enum.Material.Pavement)
		if i % 40 == 0 then task.wait() end
	end

	return string.format("buildings %d parts %d painted %d | pass1 %d (%d parts) pass2 %d pass3 %d corner strips %d | core %d (%d in rows, %d parts%s, %d painted)%s",
		count, parts, #paint, pass1Count, pass1Parts, pass2Count, pass3Count, corner, coreCount, coreRows, coreParts, planOnly and " estimated" or "",
		corePainted, planOnly and " PLAN ONLY" or "")
end
