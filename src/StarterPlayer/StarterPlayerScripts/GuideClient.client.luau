-- GuideClient: handles Guide prompts. Opens a typewriter dialogue (Next / Close; pressing the prompt key again also
-- advances) and asks the server to stamp the passport. Only prompts with PromptKind == "Guide" are handled.
-- ScreenGui attributes DialogueOpen / DialogueSiteId expose state for playtests.
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("LipaShared")
local SiteData = require(Shared:WaitForChild("SiteData"))
local DialogueLogic = require(Shared:WaitForChild("DialogueLogic"))
local StampRequest = Shared:WaitForChild("Remotes"):WaitForChild("StampRequest")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local TYPE_DELAY = 0.02

local gui = Instance.new("ScreenGui")
gui.Name = "GuideDialogue"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Enabled = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Box"
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.fromScale(0.5, 0.96)
frame.Size = UDim2.fromScale(0.62, 0.26)
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
frame.BackgroundTransparency = 0.08
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local pad = Instance.new("UIPadding", frame)
pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 16), UDim.new(0, 16), UDim.new(0, 10), UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0.2, 0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 214, 102)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Position = UDim2.fromScale(0, 0.23)
body.Size = UDim2.fromScale(1, 0.5)
body.BackgroundTransparency = 1
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextColor3 = Color3.new(1, 1, 1)
body.Font = Enum.Font.Gotham
body.TextWrapped = true
body.TextScaled = true
body.Parent = frame

local function button(name, text, x)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.AnchorPoint = Vector2.new(1, 1)
	b.Position = UDim2.fromScale(x, 1)
	b.Size = UDim2.fromScale(0.16, 0.22)
	b.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Parent = frame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end
local nextButton = button("Next", "Next", 1)
local closeButton = button("Close", "Close", 0.82)
closeButton.BackgroundColor3 = Color3.fromRGB(90, 90, 100)

local dialogue, current, typing, typeToken = nil, nil, false, 0

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
	dialogue, current = nil, nil
	gui.Enabled = false
	gui:SetAttribute("DialogueOpen", false)
end

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
