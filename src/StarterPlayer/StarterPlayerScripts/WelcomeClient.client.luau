-- WelcomeClient: a once-per-join welcome panel. ResetOnSpawn = false, so a respawn does not show it again.
-- The Start button closes it and starts the ambient loop (a button press is the user gesture audio wants).
-- The ScreenGui attribute WelcomeOpen exposes the state for playtests. All text is plain (no rich text).
-- Layout: a dim backdrop plus a panel that sizes itself to its text (fixed text sizes, wrapped), so it fits a phone in landscape
-- or portrait without the scaled-text shrinkage that made a wrapped line tiny.
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local talkHint = touchOnly and "tap the button that appears" or "press E"

local gui = Instance.new("ScreenGui")
gui.Name = "Welcome"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.Parent = playerGui
gui:SetAttribute("WelcomeOpen", true)

local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.Active = true
dim.Parent = gui

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.new(0.8, 0, 0, 0)
frame.AutomaticSize = Enum.AutomaticSize.Y
frame.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
frame.BackgroundTransparency = 0.04
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(540, 2000)
limit.Parent = frame
local pad = Instance.new("UIPadding", frame)
pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 18), UDim.new(0, 18), UDim.new(0, 14), UDim.new(0, 14)
local list = Instance.new("UIListLayout", frame)
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function text(name, order, size, str, font, color)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.LayoutOrder = order
	l.Size = UDim2.new(1, 0, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.TextSize = size
	l.Font = font
	l.TextColor3 = color
	l.Text = str
	l.Parent = frame
	return l
end

local GOLD, INK = Color3.fromRGB(255, 214, 102), Color3.fromRGB(232, 232, 238)
text("Title", 1, 28, "Lipa City: Eat, Pray, Love", Enum.Font.GothamBold, GOLD)
text("Subtitle", 2, 17, "Nine places that show modern Lipa, Batangas.", Enum.Font.Gotham, INK)
text("Step1", 3, 17, "1. Walk up to a guide and " .. talkHint .. " to talk. Each guide stamps your passport.", Enum.Font.Gotham, INK)
text("Step2", 4, 17, "2. Collect all 9 stamps. Your Passport is at the top left.", Enum.Font.Gotham, INK)
text("Step3", 5, 17, "3. For far places, ride the jeepney from any jeepney stop.", Enum.Font.Gotham, INK)
text("Step4", 6, 17, "4. Photo sources are on the credits board south of the spawn.", Enum.Font.Gotham, INK)

local start = Instance.new("TextButton")
start.Name = "Start"
start.LayoutOrder = 7
start.Size = UDim2.new(0.5, 0, 0, 48)
start.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
start.TextColor3 = Color3.new(1, 1, 1)
start.Font = Enum.Font.GothamBold
start.TextSize = 24
start.Text = "Start"
start.Parent = frame
Instance.new("UICorner", start).CornerRadius = UDim.new(0, 10)
local startLimit = Instance.new("UISizeConstraint")
startLimit.MinSize = Vector2.new(140, 48)
startLimit.Parent = start

start.Activated:Connect(function()
	local ambient = SoundService:FindFirstChild("AmbientTown")
	if ambient and ambient:IsA("Sound") and not ambient.IsPlaying then
		ambient:Play()
	end
	gui:SetAttribute("WelcomeOpen", false)
	gui:Destroy()
end)
