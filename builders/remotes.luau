-- remotes: idempotently creates ReplicatedStorage.LipaShared.Remotes. Run once via execute_luau (Edit).
-- StampRequest (RemoteFunction): client -> server, siteId -> {ok, reason, new, stamps}.
-- JeepRequest  (RemoteEvent):    client -> server, destination siteId.
-- Passport state is published by the server as player attributes StampList ("1,3,4") and StampCount.
local RS = game:GetService("ReplicatedStorage")
local shared = RS:FindFirstChild("LipaShared") or Instance.new("Folder")
shared.Name = "LipaShared"
shared.Parent = RS

local remotes = shared:FindFirstChild("Remotes") or Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = shared

local function ensure(name, class)
	local r = remotes:FindFirstChild(name)
	if r and not r:IsA(class) then r:Destroy(); r = nil end
	if not r then
		r = Instance.new(class)
		r.Name = name
		r.Parent = remotes
	end
	return r
end
ensure("StampRequest", "RemoteFunction")
ensure("JeepRequest", "RemoteEvent")

local names = {}
for _, c in ipairs(remotes:GetChildren()) do table.insert(names, c.Name .. ":" .. c.ClassName) end
table.sort(names)
return table.concat(names, ",")
