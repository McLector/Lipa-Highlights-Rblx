-- JeepneyClient: at any JeepStop (prompts with PromptKind == "Jeep") shows a destination menu and fires JeepRequest.
-- The server re-validates everything (JeepRules); this menu is only a convenience. Destinations are computed from
-- SiteData.hasJeepStop, never from Workspace, because of streaming.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("LipaShared")
local SiteData = require(Shared:WaitForChild("SiteData"))
local JeepRequest = Shared:WaitForChild("Remotes"):WaitForChild("JeepRequest")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "JeepMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 11
gui.Enabled = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Box"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromOffset(380, 420)
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
frame.BackgroundTransparency = 0.05
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local list = Instance.new("UIListLayout", frame)
list.Padding = UDim.new(0, 6)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", frame)
pad.PaddingTop, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12)

local header = Instance.new("TextLabel")
header.Name = "Header"
header.LayoutOrder = 0
header.Size = UDim2.new(1, 0, 0, 36)
header.BackgroundTransparency = 1
header.Text = "Where to?"
header.TextColor3 = Color3.fromRGB(255, 214, 102)
header.Font = Enum.Font.GothamBold
header.TextScaled = true
header.Parent = frame

local buttons = {}
for _, s in ipairs(SiteData.sites) do
	if SiteData.hasJeepStop(s.id) then
		local b = Instance.new("TextButton")
		b.Name = "Dest_" .. s.id
		b.LayoutOrder = s.id
		b.Size = UDim2.new(1, 0, 0, 44)
		b.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamMedium
		b.TextScaled = true
		b.Text = s.name
		b.Parent = frame
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.Activated:Connect(function()
			gui.Enabled = false
			JeepRequest:FireServer(s.id)
		end)
		buttons[s.id] = b
	end
end

local cancel = Instance.new("TextButton")
cancel.Name = "Cancel"
cancel.LayoutOrder = 99
cancel.Size = UDim2.new(1, 0, 0, 40)
cancel.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
cancel.TextColor3 = Color3.new(1, 1, 1)
cancel.Font = Enum.Font.GothamBold
cancel.TextScaled = true
cancel.Text = "Stay here"
cancel.Parent = frame
Instance.new("UICorner", cancel).CornerRadius = UDim.new(0, 8)
cancel.Activated:Connect(function()
	gui.Enabled = false
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
	if who ~= player or prompt:GetAttribute("PromptKind") ~= "Jeep" then
		return
	end
	local site = prompt:FindFirstAncestorOfClass("Model")
	local here = site and site:GetAttribute("SiteId")
	for id, b in pairs(buttons) do
		b.Visible = id ~= here -- never offer the stop you are standing at
	end
	gui.Enabled = true
end)
