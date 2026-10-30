-- roads_extra.luau: paves the new roads (RoadData.NEW_ROADS), repaints the ground under the
-- Cathedral and Credits plazas to Pavement, and repaints the ground under City Hall and the whole Market slot to Concrete (Slice 3b, Slice 4).
-- It also paves the Market front street (STREET, Asphalt) and its two zebra crossings (ZEBRA, Concrete bars). Run in Edit via execute_luau:
--   return require(game.ServerStorage.Builders.roads_extra:Clone())()      -- returns { cellsBefore, cellsAfter, roads, regions, concreteRegions, streets, zebraBars }
-- IDEMPOTENT: it only fills Asphalt, replaces Grass with Pavement (PAVED) and replaces Grass or Pavement with Concrete (CONCRETE), so a second run leaves every terrain voxel as it was.
-- The street and the bars are fixed FillBlocks (Asphalt first, then the Concrete bars), so they give the same result on a second run.
-- It never clears terrain (builders/world.luau does, and is never run). Same fill method as world.luau buildRoads: one Asphalt
-- FillBlock per segment, 4 studs thick, top at y -2 (surface 0), extended by w/2 at interior joints and at a start that joins another road.
local FLOOR_TOP = -2

local PAVED = {
	-- Slice 4 B3c-1: the stretched Cathedral plaza (ForecourtPaving x -100..100, z 112..195.4). The ground south of z 100 was grass; this repaints it Pavement.
	-- ReplaceMaterial leaves the old Road E asphalt strip (x -6..6) alone, so only Grass changes and no terrain is cleared.
	{ x0 = -100, x1 = 100, z0 = 100, z1 = 200 },
	-- Slice 4 credits plaza: CreditsPaving (x 24..150, z 274..346) and EntryPath (x 6..24, z 306..314) stood on grass terrain, so blades showed through the floor and hid the path.
	-- Both regions are widened to the 4-stud grid. Road E's asphalt (x -6..6) is left alone: ReplaceMaterial only swaps Grass.
	{ x0 = 24, x1 = 152, z0 = 272, z1 = 348 },
	{ x0 = 4, x1 = 24, z0 = 304, z1 = 316 },
}

-- City Hall ground (owner decision 2026-10-29): grass blades (the swaying terrain Grass decoration) poked through the steps, plaza and terraces of City Hall.
-- Blades grow only on Grass terrain, so the ground under the whole site is repainted light Concrete (152,152,152), a neutral grey like the drawing's plaza.
-- The extents are the model's real bounds x -322..-150, z -446..-188 widened to the 4-stud grid that ReplaceMaterial needs. This region replaces the old
-- forecourt Pavement strip (x -228..-148, z -332..-188), so Pavement there becomes Concrete too. Asphalt and everything else is left alone.
local CONCRETE = {
	{ x0 = -324, x1 = -148, z0 = -448, z1 = -188 },
	-- Market ground (owner decision 2026-10-29, Slice 4 BP1 rebuild): the WHOLE Market slot x -576..-228, z -5..325 becomes Concrete (the old Pavement region x -376..-228,
	-- z 80..240 and the Grass around it). x is already on the 4-stud grid; z -5..325 is widened to -8..328 (the voxel [-8,-4) holds z -5, the voxel [324,328) holds z 325).
	-- Asphalt is never touched (Road F ends flush at x -228) and nothing east of x -228 changes. Four x-chunks of about 88 studs, a task.wait() after each, so Studio is not frozen.
	{ x0 = -576, x1 = -488, z0 = -8, z1 = 328 },
	{ x0 = -488, x1 = -400, z0 = -8, z1 = 328 },
	{ x0 = -400, x1 = -312, z0 = -8, z1 = 328 },
	{ x0 = -312, x1 = -228, z0 = -8, z1 = 328 },
}

-- Market front street (owner decision 2026-10-30, handoff 048): Asphalt, 12 wide (x -228..-216), against the paving edge with no grass verge, and the z span
-- equals the Market Concrete chunks (z -8..328, 4-stud grid). It is terrain only and NOT a RoadData.NEW_ROADS entry, because a road body there would break the
-- 7-roads, 12-wide and margin rules in roads_check / site02_check. site02_check forbids any non-rig part east of x -228, so there is no kerb, line or sign.
-- Road F (z 156..164) meets it as a T. Terrain voxels are 4 studs, so the zebra stripes below are 4 studs wide.
local STREET = {
	{ x0 = -228, x1 = -216, z0 = -8, z1 = 328 },
}

-- Two zebra crossings at the stair feet (z 88..96 and z 224..232): Concrete bars at x -228..-224 and x -220..-216 with Asphalt between. The west bar lies
-- beside the Market Concrete, so the two merge by colour (a known honest DIFF, owner approved the layout).
local ZEBRA = {
	{ x0 = -228, x1 = -224, z0 = 88, z1 = 96 },
	{ x0 = -220, x1 = -216, z0 = 88, z1 = 96 },
	{ x0 = -228, x1 = -224, z0 = 224, z1 = 232 },
	{ x0 = -220, x1 = -216, z0 = 224, z1 = 232 },
}

return function()
	local T = workspace.Terrain
	local RoadData = require(game.ReplicatedStorage.LipaShared.RoadData:Clone())
	local before = T:CountCells()

	for _, road in ipairs(RoadData.NEW_ROADS) do
		local w = road.w
		local n = #road.pts
		for i = 1, n - 1 do
			local x1, z1 = road.pts[i][1], road.pts[i][2]
			local x2, z2 = road.pts[i + 1][1], road.pts[i + 1][2]
			local capA = (i > 1 or road.joinStart) and w / 2 or 0
			local capB = (i < n - 1) and w / 2 or 0
			local cx, cz, sx, sz
			if x1 == x2 then
				local dir = z2 >= z1 and 1 or -1
				local a, b = z1 - dir * capA, z2 + dir * capB
				cx, cz = x1, (a + b) / 2
				sx, sz = w, math.abs(b - a)
			else
				local dir = x2 >= x1 and 1 or -1
				local a, b = x1 - dir * capA, x2 + dir * capB
				cx, cz = (a + b) / 2, z1
				sx, sz = math.abs(b - a), w
			end
			T:FillBlock(CFrame.new(cx, FLOOR_TOP - 2, cz), Vector3.new(sx, 4, sz), Enum.Material.Asphalt)
		end
		task.wait()
	end

	for _, r in ipairs(PAVED) do
		T:ReplaceMaterial(Region3.new(Vector3.new(r.x0, -4, r.z0), Vector3.new(r.x1, 4, r.z1)), 4, Enum.Material.Grass, Enum.Material.Pavement)
	end
	for _, r in ipairs(CONCRETE) do
		local region = Region3.new(Vector3.new(r.x0, -4, r.z0), Vector3.new(r.x1, 4, r.z1))
		T:ReplaceMaterial(region, 4, Enum.Material.Grass, Enum.Material.Concrete)
		T:ReplaceMaterial(region, 4, Enum.Material.Pavement, Enum.Material.Concrete)
		task.wait()
	end
	for _, r in ipairs(STREET) do
		T:FillBlock(CFrame.new((r.x0 + r.x1) / 2, FLOOR_TOP - 2, (r.z0 + r.z1) / 2), Vector3.new(r.x1 - r.x0, 4, r.z1 - r.z0), Enum.Material.Asphalt)
		task.wait()
	end
	for _, r in ipairs(ZEBRA) do
		T:FillBlock(CFrame.new((r.x0 + r.x1) / 2, FLOOR_TOP - 2, (r.z0 + r.z1) / 2), Vector3.new(r.x1 - r.x0, 4, r.z1 - r.z0), Enum.Material.Concrete)
	end
	task.wait()
	return { cellsBefore = before, cellsAfter = T:CountCells(), roads = #RoadData.NEW_ROADS, regions = #PAVED, concreteRegions = #CONCRETE, streets = #STREET, zebraBars = #ZEBRA }
end
