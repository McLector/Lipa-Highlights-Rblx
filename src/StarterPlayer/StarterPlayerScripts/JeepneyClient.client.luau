-- JeepneyClient: at any JeepStop (prompts with PromptKind == "Jeep") shows a destination menu and fires JeepRequest.
-- The server re-validates everything (JeepRules); this menu is only a convenience. Destinations are computed from
-- SiteData.hasJeepStop, never from Workspace, because of streaming.
-- Layout (Slice 13): the box is a share of the screen (capped), with a pinned header and Cancel and a two-column, scrollable
-- destination grid, so it fits a 338 px-tall phone. The old fixed 380x420 box ran off both edges there. Buttons are 48 px tall.
-- New-player guidance (2026-10-31): stamped places say " - done", the next stop (GuidanceLogic.jeepTarget) is gold, a footnote explains
-- the three walk-only shops, a refused ride says why, and after a ride the camera turns to that site's guide.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("LipaShared")
local SiteData = require(Shared:WaitForChild("SiteData"))
local GuidanceLogic = require(Shared:WaitForChild("GuidanceLogic"))
local JeepRequest = Shared:WaitForChild("Remotes"):WaitForChild("JeepRequest")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BUTTON_HEIGHT = 48
local HEADER_HEIGHT = 40
local GAP = 6
local FOOT_HEIGHT = 36
local BLUE = Color3.fromRGB(70, 120, 220)
local DONE = Color3.fromRGB(52, 66, 100)
local GOLD = Color3.fromRGB(255, 214, 102)
local DARK = Color3.fromRGB(24, 26, 36)

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
scroll.Size = UDim2.new(1, 0, 1, -(HEADER_HEIGHT + GAP + GAP + FOOT_HEIGHT + GAP + BUTTON_HEIGHT))
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
		b.BackgroundColor3 = BLUE
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

-- The Market, Lomi King and the Cafe have no stop; this line is the only place the menu can say how to reach them.
local foot = Instance.new("TextLabel")
foot.Name = "Footnote"
foot.AnchorPoint = Vector2.new(0, 1)
foot.Position = UDim2.new(0, 0, 1, -(BUTTON_HEIGHT + GAP))
foot.Size = UDim2.new(1, 0, 0, FOOT_HEIGHT)
foot.BackgroundTransparency = 1
foot.TextColor3 = Color3.fromRGB(220, 220, 230)
foot.Font = Enum.Font.Gotham
foot.TextSize = 14
foot.TextWrapped = true
foot.Text = "Market, Lomi King, Cafe de Lipa: ride to the Plaza, then walk."
foot.Parent = frame

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
	local stamped, ids = {}, {}
	for token in string.gmatch(player:GetAttribute("StampList") or "", "%d+") do
		stamped[tonumber(token)] = true
		table.insert(ids, tonumber(token))
	end
	local target = GuidanceLogic.jeepTarget(GuidanceLogic.nextSite(ids))
	for id, b in pairs(buttons) do
		b.Visible = id ~= here -- never offer the stop you are standing at
		local site = SiteData.byId(id)
		b.Text = site.name .. (stamped[id] and " - done" or "")
		b.BackgroundColor3 = id == target and GOLD or (stamped[id] and DONE or BLUE)
		b.TextColor3 = id == target and DARK or Color3.new(1, 1, 1)
	end
	gui.Enabled = true
end)

-- Jeep prompts say what they open (set on this client only; the prompts come from builders/placeholders.luau and stream in and out).
local function relabel(inst)
	if inst:IsA("ProximityPrompt") and inst:GetAttribute("PromptKind") == "Jeep" then
		inst.ActionText = "Choose a ride"
	end
end
for _, d in ipairs(workspace:GetDescendants()) do
	relabel(d)
end
workspace.DescendantAdded:Connect(relabel)

-- A short message at the top of the screen for a refused ride.
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "JeepToast"
toastGui.ResetOnSpawn = false
toastGui.DisplayOrder = 12
toastGui.Parent = playerGui
local toast = Instance.new("TextLabel")
toast.Name = "Message"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 70)
toast.Size = UDim2.fromOffset(0, 0)
toast.AutomaticSize = Enum.AutomaticSize.XY
toast.BackgroundColor3 = DARK
toast.BackgroundTransparency = 0.1
toast.TextColor3 = GOLD
toast.Font = Enum.Font.GothamBold
toast.TextSize = 18
toast.Visible = false
toast.Parent = toastGui
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

local REFUSALS = {
	cooldown = "Wait a moment for the next jeepney.",
	not_at_stop = "Stand on the yellow jeepney stop to ride.",
}

-- JeepSeq counts every request, so a second identical refusal still shows; LastJeepResult says what happened.
player:GetAttributeChangedSignal("JeepSeq"):Connect(function()
	local result = player:GetAttribute("LastJeepResult") or ""
	if REFUSALS[result] then
		showToast(REFUSALS[result])
		return
	end
	local id = tonumber(string.match(result, "^ok:(%d+)$"))
	local guidePos = id and SiteData.guidePos(id)
	if not guidePos then
		return
	end
	task.wait(0.3) -- let the server's move reach this client first
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not hrp or not camera then
		return
	end
	local look = Vector3.new(guidePos.X - hrp.Position.X, 0, guidePos.Z - hrp.Position.Z)
	if look.Magnitude < 1 then
		return
	end
	local eye = hrp.Position - look.Unit * 14 + Vector3.new(0, 6, 0)
	camera.CFrame = CFrame.lookAt(eye, Vector3.new(guidePos.X, hrp.Position.Y, guidePos.Z))
end)
