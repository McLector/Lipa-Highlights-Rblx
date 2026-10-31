-- site06_ground: repaint the terrain Grass under Site 06's hard surfaces (2026-10-31, owner: "clean up the grass ... especially on areas
-- there that the grass shouldnt be"). Studio copy: ServerStorage.Builders.site06_ground; run standalone with
--   return require(game.ServerStorage.Builders.site06_ground:Clone())()
-- or as the last step of builders/site06.luau. Check: tests/site06_check.luau group "ground".
-- WHY: terrain Grass draws decoration blades that poke through the 1.3 decks, so blades showed through the paving, roads, parking, the
--   artificial PitchTurf, the aprons, the building floors and the sign and monument bases.
-- WHAT: every ground-touching hard part of Workspace.Sites.Site06_Outlets (bottom at y 2 or lower, footprint 30+ sq studs, not a lawn,
--   bed or hedge, not Grass material, not the Jeepney, Guide or NPCs) marks the 4-stud voxel columns its footprint covers, padded 1 voxel
--   (4 studs). Those columns get Terrain:ReplaceMaterial Grass -> Concrete (under Concrete, Glass, Wood or Brick parts: buildings, the
--   stand, the aprons, the bases) or Grass -> Pavement (paving, roads, parking, turf). Only Grass changes; occupancy never changes.
-- SCOPE: only whole voxel columns inside the slot (x 328..772, z -848..-552, inside x 325..775, z -850..-550), y -8..4 (the surface
--   voxel and the one under it). Never touches roads or terrain outside the slot. Real lawns (exposed terrain and the lawn parts) keep Grass.
-- IDEMPOTENT: only columns that still hold Grass are written, so a second run repaints 0.
return function()
	local V = Vector3.new
	local T = workspace.Terrain
	local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site06_Outlets")
	assert(site, "site06_ground: Workspace.Sites.Site06_Outlets not found")
	local LAWN = { GardenLawn = true, OvalLawn = true, OvalLawnInner = true, MonumentBed = true, ParkingIsland = true, PerimeterHedge = true,
		PlazaBed = true, SpineBed = true }
	local SKIPTOP = { Jeepney = true, LocalNPCs = true, Guide = true }
	local HARD = { [Enum.Material.Concrete] = true, [Enum.Material.Glass] = true, [Enum.Material.Wood] = true, [Enum.Material.Brick] = true }
	local PAD, RES = 4, 4
	local X0, X1, Z0, Z1, Y0, Y1 = 328, 772, -848, -552, -8, 4

	local function isRig(inst)
		local p = inst
		while p and p ~= site do
			if p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
		end
		return false
	end
	local feet = {}
	for _, p in ipairs(site:GetDescendants()) do
		if p:IsA("BasePart") and not isRig(p) and not LAWN[p.Name] and p.Material ~= Enum.Material.Grass then
			local top = p
			while top.Parent ~= site do top = top.Parent end
			if not SKIPTOP[top.Name] then
				local cf, h = p.CFrame, p.Size / 2
				local ex = math.abs(cf.RightVector.X) * h.X + math.abs(cf.UpVector.X) * h.Y + math.abs(cf.LookVector.X) * h.Z
				local ey = math.abs(cf.RightVector.Y) * h.X + math.abs(cf.UpVector.Y) * h.Y + math.abs(cf.LookVector.Y) * h.Z
				local ez = math.abs(cf.RightVector.Z) * h.X + math.abs(cf.UpVector.Z) * h.Y + math.abs(cf.LookVector.Z) * h.Z
				if p.Position.Y - ey <= 2 and 4 * ex * ez >= 30 then
					table.insert(feet, { p = p, hard = HARD[p.Material] == true,
						x0 = p.Position.X - ex - PAD, x1 = p.Position.X + ex + PAD, z0 = p.Position.Z - ez - PAD, z1 = p.Position.Z + ez + PAD })
				end
			end
		end
	end
	-- the target material of a column: Concrete if any covering part is a building/base material, else Pavement, nil if uncovered
	local function target(x, z)
		local got = nil
		for _, f in ipairs(feet) do
			if x >= f.x0 and x <= f.x1 and z >= f.z0 and z <= f.z1 then
				local q = f.p.CFrame:PointToObjectSpace(V(x, f.p.Position.Y, z))
				local h = f.p.Size / 2
				if math.abs(q.X) <= h.X + PAD and math.abs(q.Y) <= h.Y + PAD and math.abs(q.Z) <= h.Z + PAD then
					if f.hard then return Enum.Material.Concrete end
					got = Enum.Material.Pavement
				end
			end
		end
		return got
	end

	local cellsBefore = T:CountCells()
	local mats, occ = T:ReadVoxels(Region3.new(V(X0, Y0, Z0), V(X1, Y1, Z1)), RES)
	local sz = mats.Size
	local function grassCol(i, k)
		for j = 1, sz.Y do
			if mats[i][j][k] == Enum.Material.Grass and occ[i][j][k] > 0 then return true end
		end
		return false
	end
	local covered, repainted, regions, toConcrete, toPavement = 0, 0, 0, 0, 0
	for k = 1, sz.Z do
		local z = Z0 + (k - 1) * RES
		-- merge runs of equal target along x, each run one ReplaceMaterial
		local runStart, runMat = nil, nil
		local function flush(iEnd)
			if runStart then
				T:ReplaceMaterial(Region3.new(V(X0 + (runStart - 1) * RES, Y0, z), V(X0 + iEnd * RES, Y1, z + RES)), RES, Enum.Material.Grass, runMat)
				regions += 1
			end
			runStart, runMat = nil, nil
		end
		for i = 1, sz.X do
			local x = X0 + (i - 0.5) * RES
			local m = target(x, z + RES / 2)
			if m then covered += 1 end
			if m and grassCol(i, k) then
				repainted += 1
				if m == Enum.Material.Concrete then toConcrete += 1 else toPavement += 1 end
				if runStart and runMat ~= m then flush(i - 1) end
				if not runStart then runStart, runMat = i, m end
			else
				flush(i - 1)
			end
		end
		flush(sz.X)
		if k % 10 == 0 then task.wait() end
	end
	task.wait()
	return {
		footprints = #feet,
		coveredColumns = covered,
		repaintedColumns = repainted,
		toConcrete = toConcrete,
		toPavement = toPavement,
		regions = regions,
		cellsBefore = cellsBefore,
		cellsAfter = T:CountCells(),
	}
end
