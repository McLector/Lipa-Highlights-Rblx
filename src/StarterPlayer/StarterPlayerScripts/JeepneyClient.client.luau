-- JeepneyClient: at any JeepStop (prompts with PromptKind == "Jeep") shows a destination menu and fires JeepRequest.
-- The server re-validates everything (JeepRules); this menu is only a convenience. Destinations are computed from
-- SiteData.hasJeepStop, never from Workspace, because of streaming.
-- Layout (Slice 13): the box is a share of the screen (capped), with a pinned header and Cancel and a two-column, scrollable
-- destination grid, so it fits a 338 px-tall phone. The old fixed 380x420 box ran off both edges there. Buttons are 48 px tall.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("LipaShared")
local SiteData = require(Shared:WaitForChild("SiteData"))
local JeepRequest = Shared:WaitForChild("Remotes"):WaitForChild("JeepRequest")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BUTTON_HEIGHT = 48
local HEADER_HEIGHT = 40
local GAP = 6

local gui = Instance.new("ScreenGui")
gui.Name = "JeepMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 11
gui.Enabled = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Box"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromScale(0.9, 0.86)
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
frame.BackgroundTransparency = 0.05
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(420, 480)
limit.Parent = frame
local pad = Instance.new("UIPadding", frame)
pad.PaddingTop, pad.PaddingBottom, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12)

local header = Instance.new("TextLabel")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
header.BackgroundTransparency = 1
header.Text = "Where to?"
header.TextColor3 = Color3.fromRGB(255, 214, 102)
header.Font = Enum.Font.GothamBold
header.TextSize = 26
header.Parent = frame

-- Destinations live in a scrolling grid between the header and the pinned Cancel button.
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Destinations"
scroll.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT + GAP)
scroll.Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + GAP + GAP + BUTTON_HEIGHT))
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new()
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Parent = frame
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.5, -(GAP / 2 + 3), 0, BUTTON_HEIGHT)
grid.CellPadding = UDim2.fromOffset(GAP, GAP)
grid.SortOrder = Enum.SortOrder.LayoutOrder

local buttons = {}
for _, s in ipairs(SiteData.sites) do
	if SiteData.hasJeepStop(s.id) then
		local b = Instance.new("TextButton")
		b.Name = "Dest_" .. s.id
		b.LayoutOrder = s.id
		b.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamMedium
		b.TextSize = 16
		b.TextWrapped = true
		b.Text = s.name
		b.Parent = scroll
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
cancel.AnchorPoint = Vector2.new(0, 1)
cancel.Position = UDim2.fromScale(0, 1)
cancel.Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT)
cancel.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
cancel.TextColor3 = Color3.new(1, 1, 1)
cancel.Font = Enum.Font.GothamBold
cancel.TextSize = 18
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
