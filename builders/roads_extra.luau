-- roads_extra.luau: paves the new roads (RoadData.NEW_ROADS: SPUR, WEST_BYPASS, EAST_BYPASS, WEST_LINK, EAST_LINK) and repaints the ground under
-- City Hall's forecourt (Slice 3b). Run in Edit via execute_luau:
--   return require(game.ServerStorage.Builders.roads_extra:Clone())()      -- returns { cellsBefore, cellsAfter, roads, regions }
-- IDEMPOTENT: it only fills Asphalt and replaces Grass with Pavement, so a second run leaves every terrain voxel as it was.
-- It never clears terrain (builders/world.luau does, and is never run). Same fill method as world.luau buildRoads: one Asphalt
-- FillBlock per segment, 4 studs thick, top at y -2 (surface 0), extended by w/2 at interior joints and at a start that joins another road.
local FLOOR_TOP = -2

-- City Hall forecourt and loop (local lx 25..120, lz -70..70 of the slot, pivot (-250,0,-260), facing E): world x -225..-130, z -330..-190.
-- Clipped to the slot (the slot's east edge is x -150) and widened to the 4-stud grid that ReplaceMaterial needs, so the paving
-- (ForecourtPaving x -225..-150, z -330..-190, 0.3 thick) has pavement under it and no grass blades show through. Keep in step with
-- builders/site10_forecourt.luau.
local PAVED = {
	{ x0 = -228, x1 = -148, z0 = -332, z1 = -188 },
	-- Slice 4 B3c-1: the stretched Cathedral plaza (ForecourtPaving x -100..100, z 112..195.4). The ground south of z 100 was grass; this repaints it Pavement.
	-- ReplaceMaterial leaves the old Road E asphalt strip (x -6..6) alone, so only Grass changes and no terrain is cleared.
	{ x0 = -100, x1 = 100, z0 = 100, z1 = 200 },
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
	task.wait()
	return { cellsBefore = before, cellsAfter = T:CountCells(), roads = #RoadData.NEW_ROADS, regions = #PAVED }
end
