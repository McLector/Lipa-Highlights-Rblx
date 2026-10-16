-- credits: idempotently builds Workspace.World.CreditsBoard at the south edge of Plaza Independencia (Slice 13).
-- Run via execute_luau (Edit). Destroys and rebuilds the board; touches nothing else (no terrain, no Sites).
-- Layout: three panels in a row, x -28..28 at z 94, facing north (-Z) so a player who turns round from the spawn (0,70) reads them.
-- Seen from the front (looking south), the viewer's right is -X, so the panels run left to right as +X, 0, -X = sites 1-3, 4-6, 7-9.
-- A panel's front face is its Front (-Z) side. Text comes from CreditsData (urls) and SiteData (names); the identity slot is
-- CreditsData.identityText() (TO BE ADDED until the student fills it in). All labels have RichText off.
-- The plaza's south strip (z 90..98) is clear: lamps sit at z 80, benches at z 84..88, the kerb at z 100.
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
local CreditsData = require(game.ReplicatedStorage.LipaShared.CreditsData:Clone())

local world = workspace:FindFirstChild("World")
assert(world, "credits: Workspace.World not found (run builders/world first)")
local old = world:FindFirstChild("CreditsBoard")
if old then old:Destroy() end

local V = Vector3.new
local Z = 94
local PANEL_W, PANEL_H, PANEL_T = 18, 13, 0.6
local PANEL_BOTTOM = 1.2
local PPS = 40 -- pixels per stud: each panel is 720 x 520 px
local PAD, GAP = 18, 6

local model = Instance.new("Model")
model.Name = "CreditsBoard"

local function part(name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored = true
	p.Color, p.Material = color, material
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local STONE = Color3.fromRGB(120, 112, 100)
local SLATE = Color3.fromRGB(24, 26, 36)
local GOLD = Color3.fromRGB(255, 214, 102)
local INK = Color3.fromRGB(232, 232, 238)

-- frame: a low plinth, four posts and a cap beam
part("Plinth", V(58, 1, 2.4), CFrame.new(0, 0.5, Z), STONE, Enum.Material.Concrete)
for _, x in ipairs({ -28.5, -9.5, 9.5, 28.5 }) do
	part("Post", V(0.8, 14, 0.8), CFrame.new(x, 8, Z - 0.1), STONE, Enum.Material.Concrete) -- spans y 1..15, flush with the cap top
end
part("Cap", V(58, 0.8, 1.4), CFrame.new(0, PANEL_BOTTOM + PANEL_H + 0.4, Z - 0.1), STONE, Enum.Material.Concrete)

local function label(frame, text, order, size, font, color)
	local l = Instance.new("TextLabel")
	l.Name = "Line" .. order
	l.LayoutOrder = order
	l.Size = UDim2.new(1, 0, 0, 0)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.TextWrapped = true
	l.TextScaled = false
	l.RichText = false
	l.TextSize = size
	l.Font = font
	l.TextColor3 = color
	l.Text = text
	l.Parent = frame
	return l
end

-- panel k (1..3) shows sites 3k-2 .. 3k
local panelX = { 19, 0, -19 }
local groups = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } }
local urlsById = {}
for _, entry in ipairs(CreditsData.sites) do urlsById[entry.id] = entry.urls end

for k, ids in ipairs(groups) do
	local panel = part("Panel" .. k, V(PANEL_W, PANEL_H, PANEL_T), CFrame.new(panelX[k], PANEL_BOTTOM + PANEL_H / 2, Z), SLATE, Enum.Material.SmoothPlastic)
	local g = Instance.new("SurfaceGui")
	g.Name = "CreditsGui" .. k
	g.Face = Enum.NormalId.Front
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = PPS
	g.LightInfluence = 0
	g.Parent = panel

	local frame = Instance.new("Frame")
	frame.Name = "Content"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = SLATE
	frame.BorderSizePixel = 0
	frame.Parent = g
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, PAD), UDim.new(0, PAD), UDim.new(0, PAD), UDim.new(0, PAD)
	pad.Parent = frame
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, GAP)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = frame

	local order = 0
	local function add(text, size, font, color)
		order += 1
		return label(frame, text, order, size, font, color)
	end
	if k == 1 then
		add("PHOTO AND SOURCE CREDITS", 32, Enum.Font.GothamBold, GOLD)
	end
	for _, id in ipairs(ids) do
		add(id .. ". " .. SiteData.byId(id).name, 25, Enum.Font.GothamBold, GOLD)
		for _, url in ipairs(urlsById[id]) do
			add(url, 19, Enum.Font.Gotham, INK)
		end
	end
	if k == 3 then
		add("Models are hand-built from photo references; no photo is used as a texture.", 19, Enum.Font.Gotham, INK)
		add(CreditsData.identityText(), 24, Enum.Font.GothamBold, GOLD)
	end
end

model.Parent = world
local count = 0
for _, d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then count += 1 end end
return string.format("CreditsBoard built: %d parts, 3 panels", count)
