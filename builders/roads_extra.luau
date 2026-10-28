-- roads_extra.luau: paves the new roads (RoadData.NEW_ROADS: SPUR, WEST_BYPASS, EAST_BYPASS, WEST_LINK, EAST_LINK), repaints the ground under the
-- Cathedral and Credits plazas to Pavement, and repaints the ground under City Hall to Concrete (Slice 3b). Run in Edit via execute_luau:
--   return require(game.ServerStorage.Builders.roads_extra:Clone())()      -- returns { cellsBefore, cellsAfter, roads, regions, concreteRegions }
-- IDEMPOTENT: it only fills Asphalt, replaces Grass with Pavement (PAVED) and replaces Grass or Pavement with Concrete (CONCRETE), so a second run leaves every terrain voxel as it was.
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
	end
	task.wait()
	return { cellsBefore = before, cellsAfter = T:CountCells(), roads = #RoadData.NEW_ROADS, regions = #PAVED, concreteRegions = #CONCRETE }
end
