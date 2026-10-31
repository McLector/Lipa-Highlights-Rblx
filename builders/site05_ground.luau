-- site05_ground: repaints terrain Grass under Site 05's ground-contact parts (2026-10-31, owner: "clean up the grass ... where it shouldnt be").
-- Studio copy: ServerStorage.Builders.site05_ground. Called at the end of builders/site05.luau; standalone:
--   return require(game.ServerStorage.Builders.site05_ground:Clone())()
-- Check: tests/site05_check.luau group "terrain".
-- Why: terrain Grass draws blades about 0.9 above its surface, so they poke through thin paving, floors, steps and up along wall and
--   building bases. Every part of Workspace.Sites.Site05_Carmel whose bottom is at or below y 0.9, that is 3+ studs wide, is not Grass
--   material (lawns, hedges, beds, shrubs keep their blades), not an NPC rig and not in Landscape (palms, trees, lamps), gets the Grass
--   voxels under its footprint padded 1 voxel (4 studs) replaced: Pavement under flat parts (top <= 1.2), Concrete under the rest.
-- Only Grass is replaced (ReplaceMaterial), occupancy is unchanged, so the ground shape, roads (Asphalt) and the forecourt Pavement stay.
-- Only cells whose centre lies inside the 220 x 180 slot are touched (edge cells overhang the slot by at most 2 studs: the 4-stud grid is
--   offset 2 from the slot edge). IDEMPOTENT: the second run repaints 0 voxels. Pure function of the parts (no randomness).
return function()
	local V = Vector3.new
	local ORIGIN = V(-300, 0, -600)
	local HALF_X, HALF_Z = 110, 90
	local PAD, RES = 4, 4
	local Y0, Y1 = -12, 8 -- voxel rows replaced: the surface layer and the layers just below it
	local GRASS = Enum.Material.Grass
	local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site05_Carmel")
	assert(site, "site05_ground: Workspace.Sites.Site05_Carmel not found")
	local terrain = workspace.Terrain
	local landscape = site:FindFirstChild("Landscape")

	local function isRig(inst)
		local p = inst
		while p and p ~= site do
			if p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
		end
		return false
	end

	-- cell key "i,k" (world grid index) -> material; flat parts are visited first so paving wins over footprints.
	local cells = {}
	local parts = { flat = {}, solid = {} }
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA("BasePart") and p.Material ~= GRASS and not isRig(p) and not (landscape and p:IsDescendantOf(landscape)) then
			local cf, h = p.CFrame, p.Size / 2
			local lo, hi = V(math.huge, math.huge, math.huge), V(-math.huge, -math.huge, -math.huge)
			for _, sx in ipairs({ -1, 1 }) do
				for _, sy in ipairs({ -1, 1 }) do
					for _, sz in ipairs({ -1, 1 }) do
						local w = cf:PointToWorldSpace(V(sx * h.X, sy * h.Y, sz * h.Z))
						lo, hi = lo:Min(w), hi:Max(w)
					end
				end
			end
			if lo.Y <= 0.9 and math.max(hi.X - lo.X, hi.Z - lo.Z) >= 3 then
				table.insert(hi.Y <= 1.2 and parts.flat or parts.solid, { p = p, lo = lo, hi = hi })
			end
		end
	end
	local nParts = #parts.flat + #parts.solid
	for _, kind in ipairs({ "flat", "solid" }) do
		local mat = kind == "flat" and Enum.Material.Pavement or Enum.Material.Concrete
		for _, e in ipairs(parts[kind]) do
			local p, h = e.p, e.p.Size / 2
			for i = math.floor((e.lo.X - PAD) / RES), math.floor((e.hi.X + PAD) / RES) do
				for k = math.floor((e.lo.Z - PAD) / RES), math.floor((e.hi.Z + PAD) / RES) do
					local cx, cz = i * RES + RES / 2, k * RES + RES / 2
					local l = V(cx, 0, cz) - ORIGIN
					if math.abs(l.X) <= HALF_X and math.abs(l.Z) <= HALF_Z then
						-- inside the part's own footprint padded by PAD (rotated parts: test in the part's frame at its centre height)
						local o = p.CFrame:PointToObjectSpace(V(cx, p.Position.Y, cz))
						if math.abs(o.X) <= h.X + PAD and math.abs(o.Y) <= h.Y + PAD and math.abs(o.Z) <= h.Z + PAD then
							local key = i .. "," .. k
							if not cells[key] then cells[key] = mat end
						end
					end
				end
			end
		end
	end

	-- Merge cells into runs along X per Z row and material, count Grass voxels, then replace.
	local rows = {}
	local nCells = 0
	for key, mat in pairs(cells) do
		local i, k = key:match("^(-?%d+),(-?%d+)$")
		i, k = tonumber(i), tonumber(k)
		rows[k] = rows[k] or {}
		rows[k][i] = mat
		nCells += 1
	end
	local ks = {}
	for k in pairs(rows) do table.insert(ks, k) end
	table.sort(ks)
	local repainted, regions, before = 0, 0, terrain:CountCells()
	for n, k in ipairs(ks) do
		local is = {}
		for i in pairs(rows[k]) do table.insert(is, i) end
		table.sort(is)
		local a = 1
		while a <= #is do
			local b = a
			while b < #is and is[b + 1] == is[b] + 1 and rows[k][is[b + 1]] == rows[k][is[a]] do b += 1 end
			local region = Region3.new(V(is[a] * RES, Y0, k * RES), V((is[b] + 1) * RES, Y1, (k + 1) * RES))
			local mats = terrain:ReadVoxels(region, RES)
			local grass = 0
			for x = 1, #mats do
				for y = 1, #mats[x] do
					for z = 1, #mats[x][y] do
						if mats[x][y][z] == GRASS then grass += 1 end
					end
				end
			end
			if grass > 0 then
				terrain:ReplaceMaterial(region, RES, GRASS, rows[k][is[a]])
				repainted += grass
			end
			regions += 1
			a = b + 1
		end
		if n % 20 == 0 then task.wait() end
	end
	task.wait()
	return { parts = nParts, cells = nCells, regions = regions, repaintedVoxels = repainted, countCellsBefore = before, countCellsAfter = terrain:CountCells() }
end
