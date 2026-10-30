-- site09_shore: sandy patches on the Tagbakin lakeshore (Revision 3, session 061; owner: "make the off shores like sand some parts").
-- Studio copy: ServerStorage.Builders.site09_shore; site09 calls it after the swap. Run alone with
--   require(game.ServerStorage.Builders.site09_shore:Clone())()      -- returns { columns = repainted 4-stud columns, cells = CountCells }
-- IDEMPOTENT and terrain-only: Terrain:ReplaceMaterial Grass -> Sand, one 4 x 16 x 4 column at a time, so only Grass changes
-- (Water, Pavement, Asphalt and every part are left alone; no cells are added). A second run finds no Grass left and repaints 0.
-- Six irregular patches along the waterline, three on the NW arm and three on the SE arm, none under the quay, dock or building:
-- a 4-stud column is repainted when its surface cell (y -4..0) is Grass, it lies within the patch's ragged radius
-- (r * 0.8..1.2, from math.noise), within 16 studs (4 cells) of a Water cell, and no Site09 part stands over it.
-- Spec: tests/site09_check.luau "shore:" checks; world_check's Tagbakin Grass controls are all 40+ studs away.
return function()
	local T = workspace.Terrain
	local M = Enum.Material
	local V = Vector3.new
	local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site09_Tagbakin")
	assert(site, "site09_shore: Workspace.Sites.Site09_Tagbakin not found")

	-- { centre x, centre z, radius }: centres are shore cells (4-stud cell centres) 78..147 studs from the site centre (-646, 583).
	local PATCHES = {
		{ -790, 546, 7 }, { -762, 554, 10 }, { -738, 566, 7 }, -- NW arm
		{ -622, 666, 7 }, { -606, 694, 9 }, { -598, 722, 7 }, -- SE arm
	}
	local X0, X1, Z0, Z1 = -800, -560, 500, 760 -- the surface layer read (4-stud grid)
	local mats = T:ReadVoxels(Region3.new(V(X0, -4, Z0), V(X1, 0, Z1)), 4)
	local nx, nz = mats.Size.X, mats.Size.Z
	local function at(i, k)
		if i < 1 or k < 1 or i > nx or k > nz then return nil end
		return mats[i][1][k]
	end
	local op = OverlapParams.new()
	op.FilterType = Enum.RaycastFilterType.Include
	op.FilterDescendantsInstances = { site }

	local columns = 0
	for i = 1, nx do
		for k = 1, nz do
			if at(i, k) == M.Grass then
				local cx, cz = X0 + (i - 0.5) * 4, Z0 + (k - 0.5) * 4
				local f = 0.8 + 0.4 * math.clamp(math.noise(cx / 9, cz / 9, 0.37) + 0.5, 0, 1)
				local inPatch = false
				for _, p in ipairs(PATCHES) do
					if (V(cx, 0, cz) - V(p[1], 0, p[2])).Magnitude <= p[3] * f then inPatch = true end
				end
				if inPatch then
					local wet = false
					for di = -4, 4 do
						for dk = -4, 4 do
							if at(i + di, k + dk) == M.Water then wet = true end
						end
					end
					if wet and #workspace:GetPartBoundsInBox(CFrame.new(cx, 10, cz), V(3.9, 20, 3.9), op) == 0 then
						T:ReplaceMaterial(Region3.new(V(cx - 2, -12, cz - 2), V(cx + 2, 4, cz + 2)), 4, M.Grass, M.Sand)
						columns += 1
					end
				end
			end
		end
	end
	return { columns = columns, cells = T:CountCells() }
end
