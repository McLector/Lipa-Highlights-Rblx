-- routes_check: walkability by PathfindingService. Studio copy: ServerStorage.Checks.routes_check. Run during Play, in the SERVER
-- datamodel (execute_luau, datamodel_type Server):
--   require(game.ServerStorage.Checks.routes_check:Clone())      -- returns JSON {passed, failed, failures}
-- Why: the Cathedral compound stands on a 5-stud podium, so Roads A and C end against its wall. A screenshot cannot prove that players
-- can get from the spawn or the roads to each Guide. The agent CANNOT jump (touch players must be able to walk every route), radius 2,
-- height 5. Length caps are measured from the waypoints; they were set from real runs (2026-10-17): Road C -> Guide is 156 studs with the
-- side stairs and 180 without them, Road A 383 / 407, spawn 77 either way, so the caps below fail if the side stairs disappear.
-- (Slice 3b: the spawn is now on the City Hall forecourt; the 77 studs figure belonged to the old plaza spawn.)
-- The negative control proves the check can fail.
local HttpService = game:GetService("HttpService")
local PathfindingService = game:GetService("PathfindingService")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local PARAMS = { AgentRadius = 2, AgentHeight = 5, AgentCanJump = false, AgentCanClimb = false }
-- Returns the walking length in studs, or nil when there is no path.
local function pathLength(from, to)
	local path = PathfindingService:CreatePath(PARAMS)
	local ok = pcall(function() path:ComputeAsync(from, to) end)
	if not ok or path.Status ~= Enum.PathStatus.Success then return nil, ok and tostring(path.Status) or "error" end
	local wps = path:GetWaypoints()
	local total, prev = 0, wps[1].Position
	for i = 2, #wps do
		total += (wps[i].Position - prev).Magnitude
		prev = wps[i].Position
	end
	return total
end
local function route(name, from, to, maxLen)
	local len, why = pathLength(from, to)
	check(name .. " is walkable without jumping" .. (maxLen and (" in at most " .. maxLen .. " studs") or ""), len ~= nil and (maxLen == nil or len <= maxLen),
		len and string.format("%.0f studs", len) or why)
end

local sites = workspace:FindFirstChild("Sites")
-- The spawn moved to the City Hall forecourt in Slice 3b (builders/spawn.luau): read the real SpawnLocation, stand 3 studs above its pad.
local spawnPart = workspace:FindFirstChild("SpawnLocation")
check("SpawnLocation exists", spawnPart ~= nil)
local spawnPos = spawnPart and (spawnPart.Position + Vector3.new(0, 3, 0)) or Vector3.new(0, 4, 70)
local cathedral = sites and sites:FindFirstChild("Site01_Cathedral")
local g1 = cathedral and cathedral:FindFirstChild("Guide") and cathedral.Guide:FindFirstChild("HumanoidRootPart")
check("Cathedral Guide exists", g1 ~= nil)
if g1 then
	local approach = g1.Position + Vector3.new(0, 0, 6) -- 6 studs in front (south) of the Guide, on the forecourt
	-- Slice 3b: from the City Hall pad the Cathedral Guide is 443 studs by PathfindingService (measured 2026-10-26), so the bound is
	-- that plus 15 percent = 510. Pathfinding also crosses open grass, so this proves the Cathedral can be reached from the new spawn
	-- (the route over the SPUR and Road A or a bypass is the shortest road link, proven by roads_check), not that it must use the roads.
	route("spawn -> Cathedral Guide", spawnPos, approach, 510)
	route("Road C start (126, 0) -> Cathedral Guide", Vector3.new(126, 3, 0), approach, 170)
	route("Road A start (0, -106) -> Cathedral Guide", Vector3.new(0, 3, -106), approach, 400)
	-- Cathedral south growth (Slice 4 B3b): Road E now starts at the compound's south edge (0, 225). Measured by PathfindingService
	-- 2026-10-27: 279 studs (the straight line is 189), so the cap was that plus 15 percent = 320. Slice 4 B3c-0b (owner markup): the plaza's south,
	-- east and west openings were closed with black fence, so every walk now goes round to a side stair (WEST_ENTRY / EAST_ENTRY): measured 378.7
	-- studs on 2026-10-27 (it was 203 through the old south gate), so the cap is that plus 15 percent = 435 (435.5, rounded down).
	route("Road E start (0, 225) -> Cathedral Guide", Vector3.new(0, 3, 225), approach, 435)
	local len = pathLength(spawnPos, Vector3.new(0, 2, -40)) -- inside the solid podium
	check("negative control: a point inside the podium is not reachable", len == nil, len and string.format("%.0f studs", len) or nil)
end

-- Slice 3b: Ate Joy stands 9 studs west of the pad, so the walk from the spawn to her (6 studs in front of her, along her facing) is short.
do
	local row = SiteData.byId(10)
	local m = sites and sites:FindFirstChild(string.format("Site%02d_%s", row.id, row.key))
	local hrp = m and m:FindFirstChild("Guide") and m.Guide:FindFirstChild("HumanoidRootPart")
	check("Ate Joy exists", hrp ~= nil)
	if hrp then route("spawn -> Ate Joy", spawnPos, hrp.Position + SiteData.facingVector(row.facing) * 6, 40) end
end

-- The core shops: every Guide must be reachable on foot from the spawn (6 studs in front of the Guide, along its facing).
for _, id in ipairs({ 2, 3, 4 }) do
	local row = SiteData.byId(id)
	local m = sites and sites:FindFirstChild(string.format("Site%02d_%s", row.id, row.key))
	local hrp = m and m:FindFirstChild("Guide") and m.Guide:FindFirstChild("HumanoidRootPart")
	check(row.key .. " Guide exists", hrp ~= nil)
	if hrp then
		route("spawn -> " .. row.key .. " Guide", spawnPos, hrp.Position + SiteData.facingVector(row.facing) * 6, 700)
	end
end

return HttpService:JSONEncode(results)
