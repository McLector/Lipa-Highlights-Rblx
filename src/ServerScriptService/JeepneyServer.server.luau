-- JeepneyServer: validates ride requests with ServerStorage.LipaServer.JeepRules, then moves the player to the
-- destination JeepStop. Outcome of the latest request is published as player attributes LastJeepResult
-- ("ok:5" or a refusal reason) and JeepSeq, for debugging and playtests.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Remotes = ReplicatedStorage:WaitForChild("LipaShared"):WaitForChild("Remotes")
local SiteData = require(ReplicatedStorage.LipaShared:WaitForChild("SiteData"))
local JeepRules = require(ServerStorage:WaitForChild("LipaServer"):WaitForChild("JeepRules"))

local contexts = {}

-- Map of site id -> JeepStop position, read from the live Sites folder.
local function collectStops()
	local stops = {}
	local sites = workspace:FindFirstChild("Sites")
	if sites then
		for _, m in ipairs(sites:GetChildren()) do
			local id = m:GetAttribute("SiteId")
			local stop = m:FindFirstChild("JeepStop")
			if id and stop then
				stops[id] = stop.Position
			end
		end
	end
	return stops
end

local function record(player, text)
	player:SetAttribute("LastJeepResult", text)
	player:SetAttribute("JeepSeq", (player:GetAttribute("JeepSeq") or 0) + 1)
end

Remotes.JeepRequest.OnServerEvent:Connect(function(player, destId)
	local ctx = contexts[player]
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not ctx or not hrp then
		record(player, "no_character")
		return
	end
	local stops = collectStops()
	local result = JeepRules.check(ctx, destId, hrp.Position, stops, os.clock())
	if not result.ok then
		record(player, result.reason)
		return
	end
	local site = SiteData.byId(result.to)
	local target = stops[result.to] + Vector3.new(0, 5, 0)
	-- Pre-stream the destination; failure (e.g. in Studio) must not block the ride.
	local okStream, err = pcall(function()
		player:RequestStreamAroundAsync(target)
	end)
	if not okStream then
		warn("[JeepneyServer] RequestStreamAroundAsync failed: " .. tostring(err))
	end
	char:PivotTo(CFrame.new(target) * CFrame.Angles(0, SiteData.facingToYaw(site.facing), 0))
	record(player, "ok:" .. result.to)
end)

Players.PlayerAdded:Connect(function(p)
	contexts[p] = JeepRules.newContext()
end)
for _, p in ipairs(Players:GetPlayers()) do
	contexts[p] = JeepRules.newContext()
end
Players.PlayerRemoving:Connect(function(p)
	contexts[p] = nil
end)
