-- PassportServer: per-player passport sessions. Validation lives in ServerStorage.LipaServer.StampRules.
-- State is published as player attributes StampList ("1,3,4") and StampCount; LastStampResult/StampSeq record the
-- outcome of the latest request for debugging and playtests. No DataStore (stamps reset each visit).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Remotes = ReplicatedStorage:WaitForChild("LipaShared"):WaitForChild("Remotes")
local StampRules = require(ServerStorage:WaitForChild("LipaServer"):WaitForChild("StampRules"))

local contexts = {}

local function publish(player, stamps)
	player:SetAttribute("StampList", table.concat(stamps, ","))
	player:SetAttribute("StampCount", #stamps)
end

local function register(player)
	contexts[player] = StampRules.newContext()
	publish(player, {})
end

local function findGuidePos(siteId)
	local sites = workspace:FindFirstChild("Sites")
	if not sites or type(siteId) ~= "number" then
		return nil
	end
	for _, m in ipairs(sites:GetChildren()) do
		if m:GetAttribute("SiteId") == siteId then
			local guide = m:FindFirstChild("Guide")
			local hrp = guide and guide:FindFirstChild("HumanoidRootPart")
			return hrp and hrp.Position or nil
		end
	end
	return nil
end

Remotes.StampRequest.OnServerInvoke = function(player, siteId)
	local ctx = contexts[player]
	if not ctx then
		return { ok = false, reason = "no_session", stamps = {} }
	end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local result = StampRules.check(ctx, siteId, hrp and hrp.Position or nil, findGuidePos(siteId), os.clock())
	player:SetAttribute("LastStampResult", result.ok and (result.new and "ok_new" or "ok_repeat") or result.reason)
	player:SetAttribute("StampSeq", (player:GetAttribute("StampSeq") or 0) + 1)
	if result.ok then
		publish(player, result.stamps)
	end
	return result
end

Players.PlayerAdded:Connect(register)
for _, p in ipairs(Players:GetPlayers()) do
	register(p)
end
Players.PlayerRemoving:Connect(function(player)
	contexts[player] = nil
end)
