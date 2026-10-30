-- PassportClient: HUD "Passport x/N" (N = number of sites) with a gold Welcome row above a 3x3 Eat/Pray/Love stamp grid, driven by the
-- StampList / StampCount player attributes that PassportServer publishes. With every site stamped it shows a certificate
-- (CertificateLogic: Welcome row on top, then 2 or 3 columns by orientation, fixed text size) that can be reopened from the HUD.
-- A Mute button turns the ambient loop (SoundService.AmbientTown) down to 0 and back. All text is plain (no rich text); every button
-- is at least 44 px tall.
-- New-player guidance (2026-10-31): a "Next:" line under the buttons and a gold NEXT pin in the world, both from GuidanceLogic.hint
-- (positions from SiteData, so the pin works while far sites are streamed out), plus a "Stamp collected" message on each new stamp.
-- Polish (2026-10-31): the stamp cells use one fixed GRID_TEXT (fits the longest name, wrapped, in a 100 x 74 cell), and a new stamp
-- plays a quiet stamp sound (silent while muted) and pops the Passport counter.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local SiteData = require(ReplicatedStorage:WaitForChild("LipaShared"):WaitForChild("SiteData"))
local PassportLogic = require(ReplicatedStorage.LipaShared:WaitForChild("PassportLogic"))
local CertificateLogic = require(ReplicatedStorage.LipaShared:WaitForChild("CertificateLogic"))
local GuidanceLogic = require(ReplicatedStorage.LipaShared:WaitForChild("GuidanceLogic"))

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
-- Stamp cell text: one fixed size for every name (measured with TextService: the longest name wraps to 4 lines, 56 px, inside the
-- 92 x 66 padded cell, and its widest word "Independencia" is 91 px), so no name renders huge or tiny.
local GRID_TEXT = 14
local GRID_INSET = 4

-- HUD grid: the Welcome row (site 10, full width) above the 3x3 grid; the frame height is the sum of its parts.
local grid = Instance.new("Frame")
grid.Name = "Grid"
grid.LayoutOrder = 3
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

-- The next-stop line sits between the buttons and the grid; fixed text size, wraps on a phone, capped in width.
local HINT_TEXT = 16
local hint = Instance.new("TextLabel")
hint.Name = "NextHint"
hint.LayoutOrder = 2
hint.Size = UDim2.new(1, 0, 0, 0)
hint.AutomaticSize = Enum.AutomaticSize.Y
hint.BackgroundColor3 = DARK
hint.BackgroundTransparency = 0.1
hint.TextColor3 = Color3.new(1, 1, 1)
hint.Font = Enum.Font.GothamMedium
hint.TextSize = HINT_TEXT
hint.TextWrapped = true
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Text = ""
hint.Parent = hudRoot
Instance.new("UICorner", hint).CornerRadius = UDim.new(0, 10)
local hintLimit = Instance.new("UISizeConstraint")
hintLimit.MaxSize = Vector2.new(420, 400)
hintLimit.Parent = hint
local hintPad = Instance.new("UIPadding", hint)
hintPad.PaddingLeft, hintPad.PaddingRight, hintPad.PaddingTop, hintPad.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10), UDim.new(0, 8), UDim.new(0, 8)

-- The NEXT pin: a client-local invisible anchor part with a billboard that shows through walls at any distance.
local pin = Instance.new("Part")
pin.Name = "NextPin"
pin.Anchored = true
pin.CanCollide = false
pin.CanQuery = false
pin.CanTouch = false
pin.Transparency = 1
pin.Size = Vector3.new(1, 1, 1)
local pinGui = Instance.new("BillboardGui")
pinGui.Name = "NextPinGui"
pinGui.AlwaysOnTop = true
pinGui.LightInfluence = 0
pinGui.Size = UDim2.fromOffset(84, 56)
pinGui.StudsOffsetWorldSpace = Vector3.new(0, 14, 0)
pinGui.Enabled = false
pinGui.Parent = pin
local pinLabel = Instance.new("TextLabel")
pinLabel.Name = "Label"
pinLabel.Size = UDim2.new(1, 0, 0, 34)
pinLabel.BackgroundColor3 = GOLD
pinLabel.TextColor3 = DARK
pinLabel.Font = Enum.Font.GothamBold
pinLabel.TextSize = 22
pinLabel.Text = "NEXT"
pinLabel.Parent = pinGui
Instance.new("UICorner", pinLabel).CornerRadius = UDim.new(0, 8)
local pinArrow = Instance.new("TextLabel")
pinArrow.Name = "Arrow"
pinArrow.Position = UDim2.fromOffset(0, 32)
pinArrow.Size = UDim2.new(1, 0, 0, 24)
pinArrow.BackgroundTransparency = 1
pinArrow.TextColor3 = GOLD
pinArrow.TextStrokeTransparency = 0.4
pinArrow.Font = Enum.Font.GothamBold
pinArrow.TextSize = 24
pinArrow.Text = "V"
pinArrow.Parent = pinGui
pin.Parent = workspace

-- "Stamp collected" message, top centre, for 3 seconds.
local toast = Instance.new("TextLabel")
toast.Name = "StampToast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 70)
toast.Size = UDim2.fromOffset(0, 0)
toast.AutomaticSize = Enum.AutomaticSize.XY
toast.BackgroundColor3 = GREEN
toast.TextColor3 = Color3.new(1, 1, 1)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 20
toast.Visible = false
toast.Parent = gui
Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
local toastPad = Instance.new("UIPadding", toast)
toastPad.PaddingLeft, toastPad.PaddingRight, toastPad.PaddingTop, toastPad.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 8), UDim.new(0, 8)
local toastToken = 0
local function showToast(text)
	toastToken += 1
	local token = toastToken
	toast.Text = text
	toast.Visible = true
	task.delay(3, function()
		if token == toastToken then
			toast.Visible = false
		end
	end)
end

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
		slot.TextSize = GRID_TEXT
		local inset = Instance.new("UIPadding", slot)
		inset.PaddingLeft, inset.PaddingRight = UDim.new(0, GRID_INSET), UDim.new(0, GRID_INSET)
		inset.PaddingTop, inset.PaddingBottom = UDim.new(0, GRID_INSET), UDim.new(0, GRID_INSET)
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
-- The music loop (builders/mood.luau, tagged Music) mutes with the ambient loop.
local musicLoops = {}
for _, s in ipairs(SoundService:GetChildren()) do
	if s:IsA("Sound") and s:GetAttribute("Music") == true then
		table.insert(musicLoops, { sound = s, volume = s.Volume })
	end
end
local muted = false
muteButton.Activated:Connect(function()
	muted = not muted
	if ambient then
		ambient.Volume = muted and 0 or baseVolume
	end
	for _, m in ipairs(musicLoops) do
		m.sound.Volume = muted and 0 or m.volume
	end
	muteButton.Text = muted and "Sound: Off" or "Sound: On"
	gui:SetAttribute("Muted", muted)
end)
gui:SetAttribute("Muted", false)

-- New-stamp feedback: a short, quiet stamp sound made on this client (Creator Store, Pro Sound Effects, free; credited in CreditsData.audio)
-- and a quick pop of the Passport counter. The sound is skipped while muted.
local STAMP_ASSET = 9114026047 -- "Date Stamp Big Office Impact Good Squeak 2 (SFX)", 0.74 s
local STAMP_SOUND_ID = "rbxassetid://" .. STAMP_ASSET -- joined, so no slash-digit literal trips the old site-count pin
local STAMP_VOLUME = 0.35
local POP_SCALE = 1.15
local stampSound = Instance.new("Sound")
stampSound.Name = "StampSound"
stampSound.SoundId = STAMP_SOUND_ID
stampSound.Volume = STAMP_VOLUME
stampSound.Parent = SoundService
local counterScale = Instance.new("UIScale")
counterScale.Parent = toggle
local function popCounter()
	counterScale.Scale = POP_SCALE
	TweenService:Create(counterScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

local function stampIds()
	local ids = {}
	for token in string.gmatch(player:GetAttribute("StampList") or "", "%d+") do
		table.insert(ids, tonumber(token))
	end
	return ids
end

-- Re-aim the hint and the pin from the stamps and where the player stands now.
local function updateHint()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local h = GuidanceLogic.hint(stampIds(), hrp and hrp.Position or nil)
	hint.Text = h.text
	gui:SetAttribute("NextSiteId", h.siteId or 0)
	gui:SetAttribute("NextMode", h.mode)
	if h.point then
		pin.Position = h.point + Vector3.new(0, 1, 0)
		pinGui.Enabled = true
	else
		pinGui.Enabled = false
	end
end

local lastCount = 0
local lastSet = {}
local primed = false
local function refresh()
	local ids = stampIds()
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
	local gotNew = false
	for _, id in ipairs(PassportLogic.list(state)) do
		if primed and not lastSet[id] then -- not on the first refresh, so a late start never announces old stamps
			local site = SiteData.byId(id)
			showToast("Stamp collected: " .. GuidanceLogic.plain(site and site.name) .. " (" .. PassportLogic.count(state) .. "/" .. TOTAL .. ")")
			gotNew = true
		end
	end
	if gotNew then
		popCounter() -- once per refresh, however many stamps arrived
	end
	if gotNew and not muted then
		stampSound:Play()
	end
	lastSet = {}
	for _, id in ipairs(PassportLogic.list(state)) do
		lastSet[id] = true
	end
	lastCount = PassportLogic.count(state)
	primed = true
	updateHint()
end

player:GetAttributeChangedSignal("StampList"):Connect(refresh)
refresh()
task.spawn(function()
	while true do
		task.wait(1)
		updateHint()
	end
end)
