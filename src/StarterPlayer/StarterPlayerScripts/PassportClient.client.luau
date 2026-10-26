-- PassportClient: HUD "Passport x/N" (N = number of sites) with a gold Welcome row above a 3x3 Eat/Pray/Love stamp grid, driven by the
-- StampList / StampCount player attributes that PassportServer publishes. With every site stamped it shows a certificate
-- (CertificateLogic: Welcome row on top, then 2 or 3 columns by orientation, fixed text size) that can be reopened from the HUD.
-- A Mute button turns the ambient loop (SoundService.AmbientTown) down to 0 and back. Waypoints were cut (the jeepney menu
-- covers navigation). All text is plain (no rich text); every button is at least 44 px tall.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SiteData = require(ReplicatedStorage:WaitForChild("LipaShared"):WaitForChild("SiteData"))
local PassportLogic = require(ReplicatedStorage.LipaShared:WaitForChild("PassportLogic"))
local CertificateLogic = require(ReplicatedStorage.LipaShared:WaitForChild("CertificateLogic"))

local TOTAL = #SiteData.sites -- every count below comes from the site list

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

local toggle = hudButton("Counter", "Passport 0/" .. TOTAL, 1, 170)
local muteButton = hudButton("MuteButton", "Sound: On", 2, 110)
local certButton = hudButton("CertificateButton", "Certificate", 3, 130)
certButton.Visible = false

local WELCOME = SiteData.categoryColor("Welcome") or GOLD
local WELCOME_H, CELL_W, CELL_H, GRID_GAP, GRID_PAD = 40, 100, 74, 6, 8
local cellsW, cellsH = 3 * CELL_W + 2 * GRID_GAP, 3 * CELL_H + 2 * GRID_GAP

-- HUD grid: the Welcome row (site 10, full width) above the 3x3 grid; the frame height is the sum of its parts.
local grid = Instance.new("Frame")
grid.Name = "Grid"
grid.LayoutOrder = 2
grid.Size = UDim2.fromOffset(cellsW + 2 * GRID_PAD, 2 * GRID_PAD + WELCOME_H + GRID_GAP + cellsH)
grid.BackgroundColor3 = DARK
grid.BackgroundTransparency = 0.1
grid.Visible = false
grid.Parent = hudRoot
Instance.new("UICorner", grid).CornerRadius = UDim.new(0, 10)
local gpad = Instance.new("UIPadding", grid)
gpad.PaddingLeft, gpad.PaddingRight = UDim.new(0, GRID_PAD), UDim.new(0, GRID_PAD)
gpad.PaddingTop, gpad.PaddingBottom = UDim.new(0, GRID_PAD), UDim.new(0, GRID_PAD)
local gridList = Instance.new("UIListLayout", grid)
gridList.Padding = UDim.new(0, GRID_GAP)
gridList.SortOrder = Enum.SortOrder.LayoutOrder

local cells = Instance.new("Frame")
cells.Name = "Cells"
cells.LayoutOrder = 2
cells.Size = UDim2.fromOffset(cellsW, cellsH)
cells.BackgroundTransparency = 1
cells.Parent = grid
local layout = Instance.new("UIGridLayout", cells)
layout.CellSize = UDim2.fromOffset(CELL_W, CELL_H)
layout.CellPadding = UDim2.fromOffset(GRID_GAP, GRID_GAP)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local slots, slotStyle = {}, {}
for _, s in ipairs(SiteData.sites) do
	local slot = Instance.new("TextLabel")
	slot.LayoutOrder = s.id
	slot.BackgroundColor3 = IDLE
	slot.TextColor3 = Color3.fromRGB(150, 150, 165)
	slot.TextWrapped = true
	slot.Text = s.id .. ". " .. s.name
	if s.category == "Welcome" then
		slot.Name = "WelcomeRow"
		slot.LayoutOrder = 1
		slot.Size = UDim2.fromOffset(cellsW, WELCOME_H)
		slot.Font = Enum.Font.GothamBold
		slot.TextSize = 18 -- fixed, not scaled
		slot.TextColor3 = WELCOME
		slot.Parent = grid
		slotStyle[s.id] = { on = WELCOME, onText = DARK, off = IDLE, offText = WELCOME }
	else
		slot.Name = "Slot" .. s.id
		slot.Font = Enum.Font.Gotham
		slot.TextScaled = true
		slot.Parent = cells
		slotStyle[s.id] = { on = GREEN, onText = Color3.new(1, 1, 1), off = IDLE, offText = Color3.fromRGB(150, 150, 165) }
	end
	Instance.new("UICorner", slot).CornerRadius = UDim.new(0, 8)
	slots[s.id] = slot
end

-- Certificate: a centred panel, built once and refilled when it opens. Its cells are placed by CertificateLogic.cellRects from the viewport size, so they fit a phone.
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
local PLACES_TOP, PLACES_BOTTOM = 84, 64 -- room for the title and player lines above, the Close button below
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
places.Position = UDim2.new(0, 16, 0, PLACES_TOP)
places.Size = UDim2.new(1, -32, 1, -PLACES_TOP - PLACES_BOTTOM)
places.BackgroundTransparency = 1
places.Parent = certFrame
local placeLabels = {}
for i = 1, TOTAL do
	local l = Instance.new("TextLabel")
	l.Name = "Place" .. i
	l.LayoutOrder = i
	l.BackgroundColor3 = GREEN
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Font = Enum.Font.Gotham
	l.TextScaled = false -- a fixed size from CertificateLogic.cellRects, so long names never shrink or break mid-word
	l.TextSize = CertificateLogic.MIN_TEXT
	l.TextWrapped = true
	l.Text = ""
	l.Parent = places
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 8)
	local inset = CertificateLogic.CELL_PAD / 2
	local lp = Instance.new("UIPadding", l)
	lp.PaddingLeft, lp.PaddingRight, lp.PaddingTop, lp.PaddingBottom = UDim.new(0, inset), UDim.new(0, inset), UDim.new(0, inset), UDim.new(0, inset)
	placeLabels[i] = l
end
placeLabels[TOTAL].BackgroundColor3 = WELCOME -- the Welcome site's row is gold
placeLabels[TOTAL].TextColor3 = DARK
placeLabels[TOTAL].Font = Enum.Font.GothamBold

-- Place the cells for the current viewport. The panel is 86 percent by 90 percent of the screen, capped at 580 x 500 (certLimit).
local lastPlaces = nil
local function layoutPlaces()
	if not lastPlaces then
		return
	end
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
	local panelW = math.min(0.86 * vp.X, certLimit.MaxSize.X)
	local panelH = math.min(0.9 * vp.Y, certLimit.MaxSize.Y)
	local areaW, areaH = panelW - 32, panelH - PLACES_TOP - PLACES_BOTTOM
	local geo = CertificateLogic.cellRects(areaW, areaH, TOTAL, CertificateLogic.layout(vp.X, vp.Y).columns, lastPlaces)
	if not geo then
		return
	end
	for i, l in ipairs(placeLabels) do
		local r = geo.rects[i]
		if r then
			l.Position = UDim2.fromOffset(r.x, r.y)
			l.Size = UDim2.fromOffset(r.w, r.h)
			l.TextSize = geo.textSize
		end
	end
end
local camera = workspace.CurrentCamera
if camera then
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(layoutPlaces)
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
	lastPlaces = cert.places
	layoutPlaces()
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
	toggle.Text = string.format("Passport %d/%d", PassportLogic.count(state), TOTAL)
	for id, slot in pairs(slots) do
		local stamped = PassportLogic.has(state, id)
		local style = slotStyle[id]
		slot.BackgroundColor3 = stamped and style.on or style.off
		slot.TextColor3 = stamped and style.onText or style.offText
	end
	local complete = PassportLogic.isComplete(state)
	certButton.Visible = complete
	if complete and lastCount < TOTAL then
		openCertificate()
	end
	lastCount = PassportLogic.count(state)
end

player:GetAttributeChangedSignal("StampList"):Connect(refresh)
refresh()
