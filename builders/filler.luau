-- filler: idempotently builds Workspace.World.CityFill, generic town buildings along the outer roads (the haze, light and music are in
-- builders/mood.luau). Why (owner, 2026-10-31): the far sites stood alone on open grass and could be seen from a mile away; four rows of
-- town blocks on touching concrete lots (paved like the road) keep each site a surprise until the player arrives. Guarded by
-- tests/filler_check.luau.
-- Run via execute_luau (Edit): require(game.ServerStorage.Builders.filler:Clone())()  Also repaints Grass -> Pavement under the town (see paint below); touches no Sites and no roads.
-- Rules: never inside a site (footprint + 10 percent + 26), the core town where the walking routes run (x -600..360, z -330..352), a road
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
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())

return function()
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
	local function block(pass, x0, x1, z0, z1, nx, nz, floors, ymin, ymax)
		count += 1
		local m = Instance.new("Model")
		m.Name = string.format("Bldg%03d", count)
		m:SetAttribute("Pass", pass)
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

	local T = workspace.Terrain
	for i, p in ipairs(paint) do
		local region = Region3.new(V(p[1], p[5], p[3]), V(p[2], p[6], p[4])):ExpandToGrid(4)
		T:ReplaceMaterial(region, 4, Enum.Material.Grass, Enum.Material.Pavement)
		if i % 40 == 0 then task.wait() end
	end

	return string.format("buildings %d parts %d painted %d | pass1 %d (%d parts) pass2 %d pass3 %d corner strips %d", count, parts, #paint,
		pass1Count, pass1Parts, pass2Count, pass3Count, corner)
end
