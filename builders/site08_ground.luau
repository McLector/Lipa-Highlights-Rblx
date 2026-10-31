-- site08_ground: repaint the terrain Grass under Site 08's water, bunkers, paving and floors (polish, 2026-10-31).
-- Studio copy: ServerStorage.Builders.site08_ground. Called at the end of builders/site08.luau, or standalone:
--   return require(game.ServerStorage.Builders.site08_ground:Clone())()
-- Why: terrain Grass draws decorative blades about 0.9 above its surface; they poke through the clear lagoon and pond water, the thin
-- bunker plates and the paving. Under each listed part, every 4 x 4 terrain column whose centre lies on the part's horizontal footprint
-- (padded 1 voxel) is sampled for its surface height (raycast) and the voxels from 8 below to 8 above that surface are repainted from
-- Grass to a blade-free material. Only Grass is replaced, only inside the slot (x 360..760, z 560..880); fairway and rough lawns stay Grass.
-- IDEMPOTENT: a second run finds no Grass left under the parts and repaints 0 voxels. Check: tests/site08_check.luau group "ground".
-- Session 062 (owner: blades still poked through the entrance lagoons): the lagoons' south edge lies 2 studs inside the slot, and the smooth
-- surface there blends with the Grass voxel row just outside it (z 556..560, the road verge), so blades rose through the water. For water parts
-- only, the columns may reach ONE voxel past the slot edge, and a column outside the slot is repainted Grass -> LeafyGrass (green, no blades),
-- not Mud; the footprint pad gets 0.05 of slack so a column exactly 1 voxel beyond the edge is not lost to rounding. The smooth surface also
-- reports (and draws) a Grass voxel's blades up to about 2 studs into the next column, so around water a second ring of columns (pad 8) goes
-- Grass -> LeafyGrass too: the water's edge never meets a Grass voxel and the lawn stays green. Still Grass-only; second run 0.
return function()
	local V = Vector3.new
	local T = workspace.Terrain
	local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site08_Malarayat")
	assert(site, "site08_ground: Workspace.Sites.Site08_Malarayat not found")
	local X0, X1, Z0, Z1 = 360, 760, 560, 880
	local PAD, RES = 4, 4
	local RING = 8 -- session 062: the LeafyGrass ring round water parts
	local GRASS = Enum.Material.Grass
	local WATER = { LagoonWater = true, PondWater = true, PoolWater = true, PoolWaterLobe = true, HotelPoolWater = true }
	local VERGE = Enum.Material.LeafyGrass
	local TARGET = {
		LagoonWater = Enum.Material.Mud, PondWater = Enum.Material.Mud, PoolWater = Enum.Material.Mud, PoolWaterLobe = Enum.Material.Mud,
		HotelPoolWater = Enum.Material.Mud,
		Bunker = Enum.Material.Sand,
		EntrancePaving = Enum.Material.Pavement, ForecourtKerb = Enum.Material.Pavement, ForecourtPlate = Enum.Material.Pavement,
		GatehousePlinth = Enum.Material.Pavement, Plinth = Enum.Material.Pavement, LoggiaFloor = Enum.Material.Pavement,
		EntryFloor = Enum.Material.Pavement,
		PoolDeck = Enum.Material.Concrete, HotelPoolDeck = Enum.Material.Concrete, HotelPodium = Enum.Material.Concrete,
		MonumentBase = Enum.Material.Ground, LagoonEdge = Enum.Material.Ground,
	}
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = { T }

	-- Horizontal footprint test: the part's most vertical axis is its normal; a Cylinder whose normal is its X axis is a disc.
	local function footprint(p, pad)
		local cf, sz = p.CFrame, p.Size
		local axes = { { cf.RightVector, sz.X }, { cf.UpVector, sz.Y }, { cf.LookVector, sz.Z } }
		local up = 1
		for i = 2, 3 do
			if math.abs(axes[i][1].Y) > math.abs(axes[up][1].Y) then up = i end
		end
		local inPlane = {}
		for i = 1, 3 do
			if i ~= up then
				local a = axes[i][1]
				local flat = V(a.X, 0, a.Z)
				table.insert(inPlane, { flat.Magnitude > 1e-3 and flat.Unit or V(1, 0, 0), axes[i][2] * flat.Magnitude })
			end
		end
		local disc = p:IsA("Part") and p.Shape == Enum.PartType.Cylinder and up == 1
		local c = p.Position
		local test = function(x, z)
			local d = V(x - c.X, 0, z - c.Z)
			if disc then return d.Magnitude <= math.max(inPlane[1][2], inPlane[2][2]) / 2 + pad end
			for _, a in ipairs(inPlane) do
				if math.abs(d:Dot(a[1])) > a[2] / 2 + pad then return false end
			end
			return true
		end
		local r = 0
		for _, a in ipairs(inPlane) do r += a[2] / 2 end
		return test, c, r + pad
	end

	local before = T:CountCells()
	local cols, voxels, parts, calls = {}, 0, 0, 0
	for _, d in ipairs(site:GetDescendants()) do
		local mat = d:IsA("BasePart") and TARGET[d.Name]
		if mat then
			parts += 1
			local water = WATER[d.Name] == true
			local ext = water and RES or 0
			local test, c, r = footprint(d, water and PAD + 0.05 or PAD)
			local ring = water and footprint(d, RING) or nil
			if water then r += RING - PAD end
			local gx0 = math.floor(math.max(X0 - ext, c.X - r) / RES) * RES
			local gz0 = math.floor(math.max(Z0 - ext, c.Z - r) / RES) * RES
			for gx = gx0, math.min(X1 - RES + ext, c.X + r), RES do
				for gz = gz0, math.min(Z1 - RES + ext, c.Z + r), RES do
					local key = gx .. "," .. gz
					local outside = gx < X0 or gx >= X1 or gz < Z0 or gz >= Z1
					local cx, cz = gx + RES / 2, gz + RES / 2
					if (not cols[key] or cols[key] == VERGE) and test(cx, cz) then
						cols[key] = outside and VERGE or mat
					elseif not cols[key] and ring and ring(cx, cz) then
						cols[key] = VERGE
					end
				end
			end
		end
	end
	local n = 0
	for key, mat in pairs(cols) do
		local gx, gz = key:match("^(-?%d+),(-?%d+)$")
		gx, gz = tonumber(gx), tonumber(gz)
		local hit = workspace:Raycast(V(gx + RES / 2, 300, gz + RES / 2), V(0, -600, 0), rp)
		if hit then
			local sy = math.floor(hit.Position.Y / RES) * RES
			local region = Region3.new(V(gx, sy - 8, gz), V(gx + RES, sy + 12, gz + RES)):ExpandToGrid(RES)
			local mats = T:ReadVoxels(region, RES)
			local grass = 0
			for i = 1, mats.Size.X do
				for j = 1, mats.Size.Y do
					for k = 1, mats.Size.Z do
						if mats[i][j][k] == GRASS then grass += 1 end
					end
				end
			end
			if grass > 0 then
				T:ReplaceMaterial(region, RES, GRASS, mat)
				voxels += grass
				calls += 1
			end
		end
		n += 1
		if n % 200 == 0 then task.wait() end
	end
	return { parts = parts, columns = n, repaintedColumns = calls, repaintedVoxels = voxels, cellsBefore = before, cellsAfter = T:CountCells() }
end
