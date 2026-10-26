-- credits: idempotently builds Workspace.World.CreditsBoard at the south edge of Plaza Independencia (Slice 13; six panels since Slice 3b).
-- Run via execute_luau (Edit). Destroys and rebuilds the board; touches nothing else (no terrain, no Sites).
-- Layout: six panels in a row, x -57..57 at z 94, facing north (-Z); the board stands in the Cathedral plaza (it did not move).
-- Seen from the front (looking south), the viewer's right is -X, so the panels run left to right as +X ... -X:
--   panels 1-3 = sites 1-3, 4-6, 7-9; panel 4 = site 10 (City Hall) + CreditsData.projectLines; panels 5-6 = "TOUR SOURCES",
--   the 25 CreditsData.tourSources as "[n] text (domain)" at 16 px. All 25 do not fit one panel (see the measurement in the report:
--   694 px of text for 484 px of canvas), and the full url on its own line needs three panels, so the url is cut to its domain
--   and the sources are packed greedily over panels 5 and 6, measured with TextService (a source is never split or truncated).
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

-- frame: a low plinth, one post between each pair of panels (and at both ends) and a cap beam
local NPANELS = 6
local SPACING = PANEL_W + 1
local BOARD_W = NPANELS * SPACING + 1 -- 115
part("Plinth", V(BOARD_W, 1, 2.4), CFrame.new(0, 0.5, Z), STONE, Enum.Material.Concrete)
for i = 0, NPANELS do
	local x = (NPANELS / 2 - i) * SPACING
	part("Post", V(0.8, 14, 0.8), CFrame.new(x, 8, Z - 0.1), STONE, Enum.Material.Concrete) -- spans y 1..15, flush with the cap top
end
part("Cap", V(BOARD_W, 0.8, 1.4), CFrame.new(0, PANEL_BOTTOM + PANEL_H + 0.4, Z - 0.1), STONE, Enum.Material.Concrete)

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

local TextService = game:GetService("TextService")
local function textHeight(text, size, font, width)
	local p = Instance.new("GetTextBoundsParams")
	p.Text, p.Font, p.Size, p.Width = text, Font.fromEnum(font), size, width
	return TextService:GetTextBoundsAsync(p).Y
end
local INNER_W, INNER_H = PANEL_W * PPS - 2 * PAD, PANEL_H * PPS - 2 * PAD -- 684 x 484
local SRC_SIZE = 16

-- the tour sources as '[n] text (domain)' lines, packed greedily into panels 5, 6, ... by measured height
local srcLines = {}
for _, s in ipairs(CreditsData.tourSources) do
	local domain = string.match(s.url, "^https?://([^/]+)") or s.url
	table.insert(srcLines, "[" .. s.ref .. "] " .. s.text .. " (" .. domain .. ")")
end
local headH = textHeight("TOUR SOURCES (1 of 2)", 32, Enum.Font.GothamBold, INNER_W) + GAP
local srcPanels, cur, curH = {}, {}, headH
for _, line in ipairs(srcLines) do
	local h = textHeight(line, SRC_SIZE, Enum.Font.Gotham, INNER_W) + GAP
	if curH + h > INNER_H - 2 and #cur > 0 then -- 2 px of slack
		table.insert(srcPanels, cur)
		cur, curH = {}, headH
	end
	table.insert(cur, line)
	curH += h
end
table.insert(srcPanels, cur)
assert(#srcPanels == NPANELS - 4, "credits: tour sources need " .. #srcPanels .. " panels, board has " .. (NPANELS - 4))
local sourceMeasure = {}

-- panel k content: a list of {text, size, font, color}
local groups = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 }, { 10 } }
local urlsById = {}
for _, entry in ipairs(CreditsData.sites) do urlsById[entry.id] = entry.urls end
local function contentFor(k)
	local items = {}
	local function add(text, size, font, color) table.insert(items, { text, size, font, color }) end
	if k <= 4 then
		if k == 1 then
			add("PHOTO AND SOURCE CREDITS", 32, Enum.Font.GothamBold, GOLD)
		elseif k == 4 then
			add("CITY HALL AND PROJECT NOTES", 32, Enum.Font.GothamBold, GOLD)
		end
		for _, id in ipairs(groups[k]) do
			add(id .. ". " .. SiteData.byId(id).name, 25, Enum.Font.GothamBold, GOLD)
			for _, url in ipairs(urlsById[id]) do
				add(url, 19, Enum.Font.Gotham, INK)
			end
		end
		if k == 4 then
			for _, line in ipairs(CreditsData.projectLines) do
				add(line, 19, Enum.Font.Gotham, INK)
			end
		end
		if k == 3 then
			add("Models are hand-built from photo references; no photo is used as a texture.", 19, Enum.Font.Gotham, INK)
			add(CreditsData.identityText(), 24, Enum.Font.GothamBold, GOLD)
		end
	else
		add(string.format("TOUR SOURCES (%d of %d)", k - 4, NPANELS - 4), 32, Enum.Font.GothamBold, GOLD)
		for _, line in ipairs(srcPanels[k - 4]) do
			add(line, SRC_SIZE, Enum.Font.Gotham, INK)
		end
	end
	return items
end

for k = 1, NPANELS do
	local x = ((NPANELS + 1) / 2 - k) * SPACING
	local panel = part("Panel" .. k, V(PANEL_W, PANEL_H, PANEL_T), CFrame.new(x, PANEL_BOTTOM + PANEL_H / 2, Z), SLATE, Enum.Material.SmoothPlastic)
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

	local total, n = 2 * PAD, 0
	for order, it in ipairs(contentFor(k)) do
		label(frame, it[1], order, it[2], it[3], it[4])
		total += textHeight(it[1], it[2], it[3], INNER_W)
		n += 1
	end
	total += (n - 1) * GAP
	table.insert(sourceMeasure, string.format("panel %d: %d px of %d", k, total, PANEL_H * PPS))
end

model.Parent = world
local count = 0
for _, d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then count += 1 end end
return string.format("CreditsBoard built: %d parts, %d panels; %s", count, NPANELS, table.concat(sourceMeasure, "; "))
