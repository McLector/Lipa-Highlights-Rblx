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

	local placed = {} -- AABBs of accepted lots
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
		for _, b in ipairs(placed) do
			if overlaps(b, x0 + 0.05, x1 - 0.05, z0 + 0.05, z1 - 0.05) then return nil end
		end
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
		table.insert(placed, { x0 = x0, x1 = x1, z0 = z0, z1 = z1 })
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
	local function part(model, name, size, cf, color, material)
		local p = Instance.new("Part")
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

	local T = workspace.Terrain
	for i, p in ipairs(paint) do
		local region = Region3.new(V(p[1], p[5], p[3]), V(p[2], p[6], p[4])):ExpandToGrid(4)
		T:ReplaceMaterial(region, 4, Enum.Material.Grass, Enum.Material.Pavement)
		if i % 40 == 0 then task.wait() end
	end

	return string.format("buildings %d parts %d painted %d", count, parts, #paint)
end
