-- site07_ground: grass cleanup for Site 07 (The Farm at San Benito), owner's request 2026-10-31.
-- Studio copy: ServerStorage.Builders.site07_ground; run standalone with
--   return require(game.ServerStorage.Builders.site07_ground:Clone())()
-- or as the last step of builders/site07.luau. Check: tests/site07_check.luau group "ground" (no Grass under the named parts, lawn control).
-- WHY: terrain Grass draws decorative blades about 0.9 above its surface; they poke through the river ring, lagoons, pools, decks, the
-- bridge, paths, courts, parking, the amphitheater and the building floors. This step repaints the terrain under every ground-level part
-- of the site from Grass to a blade-free material. It ONLY calls Terrain:ReplaceMaterial(Grass -> X) on 4-stud column runs inside the
-- slot (columns fully within x 572..968, z 80..400), y -8..4. No cell is added or removed, no other site is touched.
-- Which parts: every BasePart of Site07_Farm (rigs skipped) whose world bottom is below y 1.5 and top above y -1, at least 2 studs wide
-- both ways, not Grass / LeafyGrass material (lawns, the river banks and planters stay Grass) and not a Ball (shrubs).
-- Target per 4-stud column (centre c, d = distance of c outside the part's horizontal footprint):
--   water part (name has Water or Pool, not Fountain): d <= 6 -> Mud
--   any other part: d <= 0 -> Pavement (under the part); 0 < d <= 6 -> Ground (overlapping columns plus a 1-voxel pad)
--   priority Mud > Pavement > Ground. Only columns whose top voxel is Grass are repainted, so a second run repaints 0.
-- IDEMPOTENT, deterministic. Returns { repainted, runs, cellsBefore, cellsAfter, byMaterial }.
return function()
	local V = Vector3.new
	local T = workspace.Terrain
	local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site07_Farm")
	assert(site, "site07_ground: Workspace.Sites.Site07_Farm not found")
	local X0, X1, Z0, Z1 = 572, 968, 80, 400 -- whole 4-stud columns inside the slot x 570..970, z 80..400
	local PAD = 6
	local RANK = { [Enum.Material.Mud] = 3, [Enum.Material.Pavement] = 2, [Enum.Material.Ground] = 1 }

	local function isRig(inst)
		local p = inst
		while p and p ~= site do
			if p:FindFirstChildOfClass("Humanoid") then return true end
			p = p.Parent
		end
		return false
	end
	local function yExt(p)
		local h = p.Size / 2
		local lo, hi = math.huge, -math.huge
		for _, sx in ipairs({ -1, 1 }) do
			for _, sy in ipairs({ -1, 1 }) do
				for _, sz in ipairs({ -1, 1 }) do
					local w = p.CFrame:PointToWorldSpace(V(sx * h.X, sy * h.Y, sz * h.Z))
					lo, hi = math.min(lo, w.Y), math.max(hi, w.Y)
				end
			end
		end
		return lo, hi
	end
	-- horizontal footprint: the local axis closest to vertical is dropped; the other two give a rectangle (or a disc for an upright cylinder)
	local function footprint(p)
		local cf, s = p.CFrame, p.Size
		local ax = { { cf.RightVector, s.X, "X" }, { cf.UpVector, s.Y, "Y" }, { cf.LookVector, s.Z, "Z" } }
		table.sort(ax, function(a, b) return math.abs(a[1].Y) > math.abs(b[1].Y) end)
		local u = V(ax[2][1].X, 0, ax[2][1].Z).Unit
		local v = V(ax[3][1].X, 0, ax[3][1].Z).Unit
		local f = { cx = cf.X, cz = cf.Z, u = u, v = v, hu = ax[2][2] / 2, hv = ax[3][2] / 2 }
		if p:IsA("Part") and p.Shape == Enum.PartType.Cylinder and ax[1][3] == "X" then
			f.r = math.min(s.Y, s.Z) / 2
		end
		local rx = math.abs(u.X) * f.hu + math.abs(v.X) * f.hv
		local rz = math.abs(u.Z) * f.hu + math.abs(v.Z) * f.hv
		f.x0, f.x1, f.z0, f.z1 = f.cx - rx, f.cx + rx, f.cz - rz, f.cz + rz
		f.w = 2 * math.min(rx, rz)
		return f
	end
	local function outside(f, x, z)
		local dx, dz = x - f.cx, z - f.cz
		if f.r then
			return math.max(0, math.sqrt(dx * dx + dz * dz) - f.r)
		end
		local a = math.abs(dx * f.u.X + dz * f.u.Z) - f.hu
		local b = math.abs(dx * f.v.X + dz * f.v.Z) - f.hv
		local ox, oz = math.max(a, 0), math.max(b, 0)
		return math.sqrt(ox * ox + oz * oz)
	end

	-- 1. plan: target material per column key "ix,iz" (column ix covers x 4ix..4ix+4)
	local target = {}
	local parts = 0
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) and d.Material ~= Enum.Material.Grass and d.Material ~= Enum.Material.LeafyGrass
			and not (d:IsA("Part") and d.Shape == Enum.PartType.Ball) then
			local y0, y1 = yExt(d)
			if y0 < 1.5 and y1 > -1 then
				local f = footprint(d)
				if f.w >= 2 then
					parts += 1
					local water = (d.Name:find("Water") or d.Name:find("Pool")) and not d.Name:find("Fountain")
					local ix0 = math.floor(math.max(f.x0 - PAD, X0) / 4)
					local ix1 = math.ceil(math.min(f.x1 + PAD, X1) / 4) - 1
					local iz0 = math.floor(math.max(f.z0 - PAD, Z0) / 4)
					local iz1 = math.ceil(math.min(f.z1 + PAD, Z1) / 4) - 1
					for ix = ix0, ix1 do
						for iz = iz0, iz1 do
							local dist = outside(f, ix * 4 + 2, iz * 4 + 2)
							local m = nil
							if dist <= PAD then
								if water then
									m = Enum.Material.Mud
								elseif dist <= 0 then
									m = Enum.Material.Pavement
								else
									m = Enum.Material.Ground
								end
							end
							if m then
								local k = ix .. "," .. iz
								local cur = target[k]
								if not cur or RANK[m] > RANK[cur] then target[k] = m end
							end
						end
					end
				end
			end
		end
	end

	-- 2. read the top voxels of the slot (y -4..0 is the ground layer; y -8..4 read to find the top occupied voxel)
	local cellsBefore = T:CountCells()
	local nx, nz = (X1 - X0) / 4, (Z1 - Z0) / 4
	local mats, occ = T:ReadVoxels(Region3.new(V(X0, -8, Z0), V(X1, 4, Z1)), 4)
	local function topIsGrass(i, k)
		for y = mats.Size.Y, 1, -1 do
			if occ[i][y][k] > 0 then return mats[i][y][k] == Enum.Material.Grass end
		end
		return false
	end

	-- 3. repaint Grass columns in runs along x (one ReplaceMaterial per run of equal target)
	local repainted, runs, byMat = 0, 0, {}
	for k = 1, nz do
		local iz = Z0 / 4 + k - 1
		local runStart, runMat = nil, nil
		local function flush(endIx)
			if runStart then
				T:ReplaceMaterial(Region3.new(V(runStart * 4, -8, iz * 4), V(endIx * 4, 4, iz * 4 + 4)), 4, Enum.Material.Grass, runMat)
				runs += 1
				runStart, runMat = nil, nil
			end
		end
		for i = 1, nx do
			local ix = X0 / 4 + i - 1
			local m = target[ix .. "," .. iz]
			if m and topIsGrass(i, k) then
				repainted += 1
				byMat[m.Name] = (byMat[m.Name] or 0) + 1
				if runMat ~= m then
					flush(ix)
					runStart, runMat = ix, m
				end
			else
				flush(ix)
			end
		end
		flush(X1 / 4)
		if k % 10 == 0 then task.wait() end
	end
	task.wait()
	local list = {}
	for n, c in pairs(byMat) do table.insert(list, n .. "=" .. c) end
	table.sort(list)
	return { repainted = repainted, runs = runs, parts = parts, cellsBefore = cellsBefore, cellsAfter = T:CountCells(), byMaterial = table.concat(list, ",") }
end
