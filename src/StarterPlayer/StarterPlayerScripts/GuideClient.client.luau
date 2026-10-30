-- GuideClient: handles Guide prompts. Opens a typewriter dialogue (Next / Close; pressing the prompt key again also
-- advances) and asks the server to stamp the passport. Only prompts with PromptKind == "Guide" are handled.
-- ScreenGui attributes DialogueOpen / DialogueSiteId expose state for playtests.
-- Layout (Slice 13): the box sizes itself to its text and uses fixed text sizes and 48 px buttons, so it stays readable and
-- tappable on a phone. A transparent "ghost" label holds the whole line so the box does not change height while it types.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("LipaShared")
local SiteData = require(Shared:WaitForChild("SiteData"))
local DialogueLogic = require(Shared:WaitForChild("DialogueLogic"))
local StampRequest = Shared:WaitForChild("Remotes"):WaitForChild("StampRequest")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TYPE_DELAY = 0.02
local BUTTON_HEIGHT = 48
local BODY_TEXT = 18
local TITLE_TEXT = 16
local LEAVE_DISTANCE = 30 -- studs from where the dialogue opened; walking or riding farther closes it

local gui = Instance.new("ScreenGui")
gui.Name = "GuideDialogue"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Enabled = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Box"
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.new(0.5, 0, 1, -12)
frame.Size = UDim2.new(0.8, 0, 0, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
frame.BackgroundTransparency = 0.08
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(680, 2000)
limit.Parent = frame
local pad = Instance.new("UIPadding", frame)
pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 16), UDim.new(0, 16), UDim.new(0, 10), UDim.new(0, 10)
local list = Instance.new("UIListLayout", frame)
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder

local title = Instance.new("TextLabel")
title.Name = "Title"
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 0)
title.AutomaticSize = Enum.AutomaticSize.Y
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextWrapped = true
title.TextColor3 = Color3.fromRGB(255, 214, 102)
title.Font = Enum.Font.GothamBold
title.TextSize = TITLE_TEXT
title.Parent = frame

-- bodyHolder is as tall as the full line (the ghost); the visible body fills it and types over it.
local bodyHolder = Instance.new("Frame")
bodyHolder.Name = "BodyHolder"
bodyHolder.LayoutOrder = 2
bodyHolder.Size = UDim2.new(1, 0, 0, 0)
bodyHolder.AutomaticSize = Enum.AutomaticSize.Y
bodyHolder.BackgroundTransparency = 1
bodyHolder.Parent = frame

local ghost = Instance.new("TextLabel")
ghost.Name = "Ghost"
ghost.Size = UDim2.new(1, 0, 0, 0)
ghost.AutomaticSize = Enum.AutomaticSize.Y
ghost.BackgroundTransparency = 1
ghost.TextTransparency = 1
ghost.TextXAlignment = Enum.TextXAlignment.Left
ghost.TextYAlignment = Enum.TextYAlignment.Top
ghost.TextWrapped = true
ghost.Font = Enum.Font.Gotham
ghost.TextSize = BODY_TEXT
ghost.Parent = bodyHolder

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Size = UDim2.fromScale(1, 1)
body.BackgroundTransparency = 1
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextColor3 = Color3.new(1, 1, 1)
body.Font = Enum.Font.Gotham
body.TextWrapped = true
body.TextSize = BODY_TEXT
body.Parent = bodyHolder

local buttons = Instance.new("Frame")
buttons.Name = "Buttons"
buttons.LayoutOrder = 3
buttons.Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT)
buttons.BackgroundTransparency = 1
buttons.Parent = frame
local row = Instance.new("UIListLayout", buttons)
row.FillDirection = Enum.FillDirection.Horizontal
row.HorizontalAlignment = Enum.HorizontalAlignment.Right
row.VerticalAlignment = Enum.VerticalAlignment.Center
row.SortOrder = Enum.SortOrder.LayoutOrder
row.Padding = UDim.new(0, 8)

local function button(name, text, order)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.LayoutOrder = order
	b.Size = UDim2.new(0, 110, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.Parent = buttons
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end
local closeButton = button("Close", "Close", 1)
closeButton.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
local nextButton = button("Next", "Next", 2)

local dialogue, current, typing, typeToken = nil, nil, false, 0
local openedAt = nil -- player position when the dialogue opened

local function show()
	local line = dialogue and DialogueLogic.current(dialogue)
	if not line then
		-- Past the last line: fully reset so the next prompt press reopens the dialogue.
		dialogue, current = nil, nil
		gui.Enabled = false
		gui:SetAttribute("DialogueOpen", false)
		return
	end
	typeToken += 1
	local token = typeToken
	typing = true
	ghost.Text = line
	nextButton.Text = DialogueLogic.index(dialogue) == #dialogue.lines and "Done" or "Next"
	task.spawn(function()
		for i = 1, #line do
			if token ~= typeToken then return end
			body.Text = string.sub(line, 1, i)
			task.wait(TYPE_DELAY)
		end
		if token == typeToken then
			typing = false
		end
	end)
end

local function finishTyping()
	typeToken += 1
	typing = false
	body.Text = DialogueLogic.current(dialogue) or ""
end

local function advance()
	if not dialogue then return end
	if typing then
		finishTyping() -- first press completes the line, second press moves on
		return
	end
	DialogueLogic.next(dialogue)
	show()
end

local function close()
	typeToken += 1
	typing = false
	dialogue, current, openedAt = nil, nil, nil
	gui.Enabled = false
	gui:SetAttribute("DialogueOpen", false)
end

-- Playtest finding (Slice 23): a dialogue left open stayed on screen after walking away or riding the jeepney.
RunService.Heartbeat:Connect(function()
	if not gui.Enabled or not openedAt then return end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and (hrp.Position - openedAt).Magnitude > LEAVE_DISTANCE then
		close()
	end
end)

nextButton.Activated:Connect(advance)
closeButton.Activated:Connect(close)

local function open(siteId)
	local site = SiteData.byId(siteId)
	if not site then return end
	if dialogue and current == siteId then
		advance() -- pressing the prompt again advances
		return
	end
	current = siteId
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	openedAt = hrp and hrp.Position or nil
	dialogue = DialogueLogic.new(site.dialogue)
	title.Text = site.guideName .. " - " .. site.name
	gui.Enabled = true
	gui:SetAttribute("DialogueOpen", true)
	gui:SetAttribute("DialogueSiteId", siteId)
	show()
	task.spawn(function()
		local ok, result = pcall(function()
			return StampRequest:InvokeServer(siteId)
		end)
		if not ok then
			warn("[GuideClient] stamp request failed: " .. tostring(result))
		end
	end)
end

-- New-player guidance (2026-10-31): the prompt says what talking gives you. Set here, on this client only, because the prompts come from
-- builders/placeholders.luau (not re-run) and stream in and out, so every Guide prompt is relabelled as it arrives.
local function relabel(inst)
	if inst:IsA("ProximityPrompt") and inst:GetAttribute("PromptKind") == "Guide" then
		inst.ActionText = "Talk (get a stamp)"
	end
end
for _, d in ipairs(workspace:GetDescendants()) do
	relabel(d)
end
workspace.DescendantAdded:Connect(relabel)

ProximityPromptService.PromptTriggered:Connect(function(prompt, who)
	if who ~= player or prompt:GetAttribute("PromptKind") ~= "Guide" then
		return
	end
	local guide = prompt:FindFirstAncestorOfClass("Model")
	local siteId = guide and guide:GetAttribute("SiteId")
	if siteId then
		open(siteId)
	end
end)
