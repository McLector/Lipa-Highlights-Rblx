-- spawn.luau: puts Workspace.SpawnLocation on the City Hall forecourt (Slice 3b). Run in Edit via execute_luau:
--   return require(game.ServerStorage.Builders.spawn:Clone())()      -- returns { position, look, groundY }
-- IDEMPOTENT: it only sets Size and CFrame (every other property, the Decal and Neutral stay as they were).
-- Pad centre world (-208, groundY + 0.5, -260), 12 x 1 x 12: x -214..-202, z -266..-254 (local lx 36..48, lz -6..6 of the City Hall
-- slot, pivot (-250,0,-260)). It faces -X (toward the entrance, with Ate Joy at (-223,-260), 9 studs west of the pad edge).
-- groundY is found by a raycast onto the terrain and Site10_CityHall.Forecourt (the 0.3 thick paving), as placeholders.luau does.
-- world.luau placeSpawn holds the same constants for a full rebuild; keep them in step (world.luau is never run).
local X, Z = -208, -260
local SIZE = Vector3.new(12, 1, 12)
local LOOK_X = -300

return function()
	local spawn = workspace:FindFirstChild("SpawnLocation")
	assert(spawn and spawn:IsA("SpawnLocation"), "Workspace.SpawnLocation is missing")
	local city = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site10_CityHall")
	local include = { workspace.Terrain }
	if city and city:FindFirstChild("Forecourt") then table.insert(include, city.Forecourt) end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Include
	rp.FilterDescendantsInstances = include
	local hit = workspace:Raycast(Vector3.new(X, 80, Z), Vector3.new(0, -200, 0), rp)
	assert(hit, "no ground found under the spawn pad at (" .. X .. ", " .. Z .. ")")
	local groundY = hit.Position.Y
	local pos = Vector3.new(X, groundY + SIZE.Y / 2, Z)
	spawn.Size = SIZE
	spawn.CFrame = CFrame.lookAt(pos, Vector3.new(LOOK_X, pos.Y, Z))
	return { position = tostring(spawn.Position), look = tostring(spawn.CFrame.LookVector), groundY = groundY }
end
