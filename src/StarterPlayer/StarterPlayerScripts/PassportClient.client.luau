-- PassportClient: HUD "Passport x/9" with a 3x3 stamp grid, driven by the StampList / StampCount player attributes
-- that PassportServer publishes. Shows a toast at 9/9 (the real certificate arrives in Slice 13).
-- Waypoints are deferred to Slice 13.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SiteData = require(ReplicatedStorage:WaitForChild("LipaShared"):WaitForChild("SiteData"))
local PassportLogic = require(ReplicatedStorage.LipaShared:WaitForChild("PassportLogic"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "PassportHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = playerGui

local toggle = Instance.new("TextButton")
toggle.Name = "Counter"
toggle.Position = UDim2.new(0, 12, 0, 12)
toggle.Size = UDim2.fromOffset(170, 40)
toggle.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
toggle.BackgroundTransparency = 0.1
toggle.TextColor3 = Color3.fromRGB(255, 214, 102)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
toggle.Text = "Passport 0/9"
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

local grid = Instance.new("Frame")
grid.Name = "Grid"
grid.Position = UDim2.new(0, 12, 0, 58)
grid.Size = UDim2.fromOffset(330, 250)
grid.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
grid.BackgroundTransparency = 0.1
grid.Visible = false
grid.Parent = gui
Instance.new("UICorner", grid).CornerRadius = UDim.new(0, 10)
local layout = Instance.new("UIGridLayout", grid)
layout.CellSize = UDim2.fromOffset(100, 74)
layout.CellPadding = UDim2.fromOffset(6, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
local gpad = Instance.new("UIPadding", grid)
gpad.PaddingLeft, gpad.PaddingTop = UDim.new(0, 8), UDim.new(0, 8)

local slots = {}
for _, s in ipairs(SiteData.sites) do
	local slot = Instance.new("TextLabel")
	slot.Name = "Slot" .. s.id
	slot.LayoutOrder = s.id
	slot.BackgroundColor3 = Color3.fromRGB(50, 52, 66)
	slot.TextColor3 = Color3.fromRGB(150, 150, 165)
	slot.Font = Enum.Font.Gotham
	slot.TextScaled = true
	slot.TextWrapped = true
	slot.Text = s.id .. ". " .. s.name
	slot.Parent = grid
	Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 8)
	slots[s.id] = slot
end

local toast = Instance.new("TextLabel")
toast.Name = "CompleteToast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 20)
toast.Size = UDim2.fromOffset(460, 56)
toast.BackgroundColor3 = Color3.fromRGB(60, 160, 90)
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Font = Enum.Font.GothamBold
toast.TextScaled = true
toast.Text = "Passport complete! You visited all 9 places."
toast.Visible = false
toast.Parent = gui
Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)

toggle.Activated:Connect(function()
	grid.Visible = not grid.Visible
end)

local lastCount = 0
local function refresh()
	local ids = {}
	for token in string.gmatch(player:GetAttribute("StampList") or "", "%d+") do
		table.insert(ids, tonumber(token))
	end
	local state = PassportLogic.new()
	for _, id in ipairs(PassportLogic.sanitize(ids)) do
		PassportLogic.stamp(state, id)
	end
	toggle.Text = string.format("Passport %d/9", PassportLogic.count(state))
	for id, slot in pairs(slots) do
		local stamped = PassportLogic.has(state, id)
		slot.BackgroundColor3 = stamped and Color3.fromRGB(60, 160, 90) or Color3.fromRGB(50, 52, 66)
		slot.TextColor3 = stamped and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 165)
	end
	if PassportLogic.isComplete(state) and lastCount < 9 then
		toast.Visible = true
		task.delay(6, function() toast.Visible = false end)
	end
	lastCount = PassportLogic.count(state)
end

player:GetAttributeChangedSignal("StampList"):Connect(refresh)
refresh()
