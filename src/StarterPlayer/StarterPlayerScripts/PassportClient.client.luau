-- PassportClient: HUD "Passport x/9" with a 3x3 stamp grid, driven by the StampList / StampCount player attributes
-- that PassportServer publishes. At 9/9 it shows a certificate (CertificateLogic) that can be reopened from the HUD.
-- A Mute button turns the ambient loop (SoundService.AmbientTown) down to 0 and back. Waypoints were cut (the jeepney menu
-- covers navigation). All text is plain (no rich text); every button is at least 44 px tall.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SiteData = require(ReplicatedStorage:WaitForChild("LipaShared"):WaitForChild("SiteData"))
local PassportLogic = require(ReplicatedStorage.LipaShared:WaitForChild("PassportLogic"))
local CertificateLogic = require(ReplicatedStorage.LipaShared:WaitForChild("CertificateLogic"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DARK = Color3.fromRGB(24, 26, 36)
local GOLD = Color3.fromRGB(255, 214, 102)
local GREEN = Color3.fromRGB(60, 160, 90)
local IDLE = Color3.fromRGB(50, 52, 66)

local gui = Instance.new("ScreenGui")
gui.Name = "PassportHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.Parent = playerGui

-- The HUD is a vertical stack: a button row that wraps onto a second line on narrow screens, then the stamp grid.
local hudRoot = Instance.new("Frame")
hudRoot.Name = "Root"
hudRoot.Position = UDim2.fromOffset(12, 12)
hudRoot.Size = UDim2.new(1, -24, 0, 0)
hudRoot.AutomaticSize = Enum.AutomaticSize.Y
hudRoot.BackgroundTransparency = 1
hudRoot.Parent = gui
local rootList = Instance.new("UIListLayout", hudRoot)
rootList.Padding = UDim.new(0, 8)
rootList.SortOrder = Enum.SortOrder.LayoutOrder

local hudRow = Instance.new("Frame")
hudRow.Name = "Row"
hudRow.LayoutOrder = 1
hudRow.Size = UDim2.new(1, 0, 0, 0)
hudRow.AutomaticSize = Enum.AutomaticSize.Y
hudRow.BackgroundTransparency = 1
hudRow.Parent = hudRoot
local rowList = Instance.new("UIListLayout", hudRow)
rowList.FillDirection = Enum.FillDirection.Horizontal
rowList.Wraps = true
rowList.Padding = UDim.new(0, 8)
rowList.SortOrder = Enum.SortOrder.LayoutOrder

local function hudButton(name, text, order, width)
	local b = Instance.new("TextButton")
	b.Name = name
	b.LayoutOrder = order
	b.Size = UDim2.fromOffset(width, 44)
	b.BackgroundColor3 = DARK
	b.BackgroundTransparency = 0.1
	b.TextColor3 = GOLD
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Text = text
	b.Parent = hudRow
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	return b
end

local toggle = hudButton("Counter", "Passport 0/9", 1, 170)
local muteButton = hudButton("MuteButton", "Sound: On", 2, 110)
local certButton = hudButton("CertificateButton", "Certificate", 3, 130)
certButton.Visible = false

local grid = Instance.new("Frame")
grid.Name = "Grid"
grid.LayoutOrder = 2
grid.Size = UDim2.fromOffset(330, 250)
grid.BackgroundColor3 = DARK
grid.BackgroundTransparency = 0.1
grid.Visible = false
grid.Parent = hudRoot
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
	slot.BackgroundColor3 = IDLE
	slot.TextColor3 = Color3.fromRGB(150, 150, 165)
	slot.Font = Enum.Font.Gotham
	slot.TextScaled = true
	slot.TextWrapped = true
	slot.Text = s.id .. ". " .. s.name
	slot.Parent = grid
	Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 8)
	slots[s.id] = slot
end

-- Certificate: a centred panel, built once and refilled when it opens. The places grid scales with the panel, so it fits a phone.
local certGui = Instance.new("ScreenGui")
certGui.Name = "Certificate"
certGui.ResetOnSpawn = false
certGui.IgnoreGuiInset = true
certGui.DisplayOrder = 15
certGui.Enabled = false
certGui.Parent = playerGui

local certDim = Instance.new("Frame")
certDim.Name = "Dim"
certDim.Size = UDim2.fromScale(1, 1)
certDim.BackgroundColor3 = Color3.new(0, 0, 0)
certDim.BackgroundTransparency = 0.45
certDim.BorderSizePixel = 0
certDim.Active = true
certDim.Parent = certGui

local certFrame = Instance.new("Frame")
certFrame.Name = "Panel"
certFrame.AnchorPoint = Vector2.new(0.5, 0.5)
certFrame.Position = UDim2.fromScale(0.5, 0.5)
certFrame.Size = UDim2.fromScale(0.86, 0.9)
certFrame.BackgroundColor3 = DARK
certFrame.BackgroundTransparency = 0.04
certFrame.Parent = certGui
Instance.new("UICorner", certFrame).CornerRadius = UDim.new(0, 14)
local certLimit = Instance.new("UISizeConstraint")
certLimit.MaxSize = Vector2.new(580, 500)
certLimit.Parent = certFrame
local certStroke = Instance.new("UIStroke")
certStroke.Color = GOLD
certStroke.Thickness = 2
certStroke.Parent = certFrame

local function certLabel(name, y, height, font, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Position = UDim2.new(0, 16, 0, y)
	l.Size = UDim2.new(1, -32, 0, height)
	l.BackgroundTransparency = 1
	l.TextScaled = true
	l.TextWrapped = true
	l.Font = font
	l.TextColor3 = color
	l.Text = ""
	l.Parent = certFrame
	return l
end
local certTitle = certLabel("Title", 10, 34, Enum.Font.GothamBold, GOLD)
local certPlayer = certLabel("Player", 48, 26, Enum.Font.GothamMedium, Color3.new(1, 1, 1))

local places = Instance.new("Frame")
places.Name = "Places"
places.Position = UDim2.new(0, 16, 0, 84)
places.Size = UDim2.new(1, -32, 1, -84 - 64)
places.BackgroundTransparency = 1
places.Parent = certFrame
local placesGrid = Instance.new("UIGridLayout", places)
placesGrid.CellSize = UDim2.new(1 / 3, -8, 1 / 3, -8)
placesGrid.CellPadding = UDim2.fromOffset(8, 8)
placesGrid.SortOrder = Enum.SortOrder.LayoutOrder
local placeLabels = {}
for i = 1, 9 do
	local l = Instance.new("TextLabel")
	l.Name = "Place" .. i
	l.LayoutOrder = i
	l.BackgroundColor3 = GREEN
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Font = Enum.Font.Gotham
	l.TextScaled = true
	l.TextWrapped = true
	l.Text = ""
	l.Parent = places
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
	local c = Instance.new("UITextSizeConstraint")
	c.MinTextSize = 10
	c.MaxTextSize = 20
	c.Parent = l
	placeLabels[i] = l
end

local certClose = Instance.new("TextButton")
certClose.Name = "Close"
certClose.AnchorPoint = Vector2.new(0.5, 1)
certClose.Position = UDim2.new(0.5, 0, 1, -12)
certClose.Size = UDim2.fromOffset(170, 44)
certClose.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
certClose.TextColor3 = Color3.new(1, 1, 1)
certClose.Font = Enum.Font.GothamBold
certClose.TextScaled = true
certClose.Text = "Close"
certClose.Parent = certFrame
Instance.new("UICorner", certClose).CornerRadius = UDim.new(0, 10)

local currentState = PassportLogic.new()

local function openCertificate()
	local cert = CertificateLogic.build(currentState, player.DisplayName, SiteData.sites)
	if not cert then
		return
	end
	certTitle.Text = cert.title
	certPlayer.Text = cert.player .. "  -  " .. os.date("%B %d, %Y") -- the player's local date
	for i, l in ipairs(placeLabels) do
		l.Text = cert.places[i] or ""
	end
	certGui.Enabled = true
	certGui:SetAttribute("CertificateOpen", true)
end

local function closeCertificate()
	certGui.Enabled = false
	certGui:SetAttribute("CertificateOpen", false)
end

certClose.Activated:Connect(closeCertificate)
certButton.Activated:Connect(openCertificate)
toggle.Activated:Connect(function()
	grid.Visible = not grid.Visible
end)

-- Mute: the ambient Sound lives in SoundService; WelcomeClient starts it. Volume is a client-side setting.
local ambient = SoundService:FindFirstChild("AmbientTown")
local baseVolume = ambient and ambient.Volume or 0
local muted = false
muteButton.Activated:Connect(function()
	muted = not muted
	if ambient then
		ambient.Volume = muted and 0 or baseVolume
	end
	muteButton.Text = muted and "Sound: Off" or "Sound: On"
	gui:SetAttribute("Muted", muted)
end)
gui:SetAttribute("Muted", false)

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
	currentState = state
	toggle.Text = string.format("Passport %d/9", PassportLogic.count(state))
	for id, slot in pairs(slots) do
		local stamped = PassportLogic.has(state, id)
		slot.BackgroundColor3 = stamped and GREEN or IDLE
		slot.TextColor3 = stamped and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 165)
	end
	local complete = PassportLogic.isComplete(state)
	certButton.Visible = complete
	if complete and lastCount < 9 then
		openCertificate()
	end
	lastCount = PassportLogic.count(state)
end

player:GetAttributeChangedSignal("StampList"):Connect(refresh)
refresh()
