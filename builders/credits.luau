-- credits: idempotently builds Workspace.World.CreditsBoard as the Credits Plaza (Slice 13; six panels since Slice 3b; moved from z 94 to z 205 in
-- Slice 4 B3b2; since credits job B (2026-10-27) the board stands in its own plaza south of the Cathedral, east of Road E, because the old spot at
-- z 205 lies outside the Cathedral's closed south fence).
-- Run via execute_luau (Edit). Destroys and rebuilds the board; touches nothing else (no terrain, no Sites, no roads).
-- Site (verified empty, flat grass y 0.02): paved floor x 24..150, z 274..346 (a 0.2-thick part, like the Cathedral plaza), every part 4+ studs from every
-- road body (Road E x 0 edge 6; EAST_LINK z 260 edge 266; EAST_BYPASS x 165 edge 159) except EntryPath, the pale ground strip from Road E's east edge (x 6)
-- to the plaza (x 24) at z 310.
-- Layout: two facing rows of panels with a reading aisle between them, entrance on the west. Row 1 (north, z 299, turned 180 degrees so its front faces +Z,
-- south) holds panels 1..ceil(N/2) from the entrance eastward; row 2 (south, z 321, front faces -Z, north) holds the rest from the east end westward, so a
-- reader walks east along row 1, turns round and walks back west along row 2. The aisle is 19.6 studs clear between the plinths, free of parts under 8 studs.
-- Frame per row (the old board's recipe): a plinth, a post in every gap between panels and at both ends, one cap beam. Panel 18 x 13 x 0.6, bottom y 1.2,
-- SurfaceGui Front, PixelsPerStud 40 (720 x 520 px), UIPadding 18, UIListLayout gap 6, fixed TextSize (never TextScaled).
-- Panel 1 = title (32 px bold gold), identityText (24 px bold gold), every projectLines and noticeLines line (19 px). Panels 2..N = "REFERENCES (k of N-1)"
-- (32 px) then the 78 CreditsData.references marked strings in order at 16 px, packed greedily by measured height (TextService, RichText measured as
-- RichText), never splitting an entry. RichText is on ONLY for the labels named Ref<i>. At the entrance: a text-only sign, 2 benches, 6 lamps
-- (the Cathedral builders' bench and lamp recipes, builders/site01.luau).
local CreditsData = require(game.ReplicatedStorage.LipaShared.CreditsData:Clone())

local world = workspace:FindFirstChild("World")
assert(world, "credits: Workspace.World not found (run builders/world first)")
local old = world:FindFirstChild("CreditsBoard")
if old then old:Destroy() end

local V, CF, ANG = Vector3.new, CFrame.new, CFrame.Angles
local PLAZA = { x0 = 24, x1 = 150, z0 = 274, z1 = 346 }
local ZN, ZS, ZC = 299, 321, 310 -- the two panel rows and the aisle line
local X0 = 50 -- centre of the first panel of each row's west end (row 1)
local PANEL_W, PANEL_H, PANEL_T = 18, 13, 0.6
local PANEL_BOTTOM = 1.2
local SPACING = PANEL_W + 1
local PPS = 40 -- pixels per stud: each panel is 720 x 520 px
local PAD, GAP = 18, 6

local model = Instance.new("Model")
model.Name = "CreditsBoard"

local function part(name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame = name, size, cf
	p.Anchored = true
	p.Color, p.Material = color, material
	if shape then p.Shape = shape end
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = model
	return p
end

local STONE = Color3.fromRGB(120, 112, 100)
local PAVER = Color3.fromRGB(150, 152, 158)
local PATH = Color3.fromRGB(214, 204, 184)
local SLATE = Color3.fromRGB(24, 26, 36)
local GOLD = Color3.fromRGB(255, 214, 102)
local INK = Color3.fromRGB(232, 232, 238)
local TIMBER = Color3.fromRGB(150, 100, 60)
local LAMP_METAL = Color3.fromRGB(46, 50, 56)
local LAMP_GLOW = Color3.fromRGB(255, 232, 170)
local CONC, WOOD, METAL = Enum.Material.Concrete, Enum.Material.Wood, Enum.Material.Metal

-- ground: the paved floor and the entry path (both on the grass, y 0.02 .. 0.22)
part("CreditsPaving", V(PLAZA.x1 - PLAZA.x0, 0.2, PLAZA.z1 - PLAZA.z0), CF((PLAZA.x0 + PLAZA.x1) / 2, 0.12, (PLAZA.z0 + PLAZA.z1) / 2), PAVER, CONC)
part("EntryPath", V(PLAZA.x0 - 6, 0.2, 8), CF((6 + PLAZA.x0) / 2, 0.12, ZC), PATH, CONC) -- x 6..24: from Road E's east edge to the plaza

-- text measuring (the same method as tests/qa_check.luau: RichText measured as RichText)
local TextService = game:GetService("TextService")
local probe = Instance.new("GetTextBoundsParams")
local HAS_RICH = pcall(function() probe.RichText = true end)
local function unmark(s)
	s = string.gsub(string.gsub(s, "<i>", ""), "</i>", "")
	return (string.gsub(string.gsub(string.gsub(s, "&lt;", "<"), "&gt;", ">"), "&amp;", "&"))
end
local function textHeight(text, size, font, width, rich)
	local p = Instance.new("GetTextBoundsParams")
	p.Text, p.Font, p.Size, p.Width = text, Font.fromEnum(font), size, width
	if rich then
		if HAS_RICH then p.RichText = true else p.Text = unmark(text) end
	end
	return TextService:GetTextBoundsAsync(p).Y + ((rich and not HAS_RICH) and 4 or 0)
end
local INNER_W, INNER_H = PANEL_W * PPS - 2 * PAD, PANEL_H * PPS - 2 * PAD -- 684 x 484
local REF_SIZE = 16
local GB, G = Enum.Font.GothamBold, Enum.Font.Gotham

-- the references, packed greedily into panels 2, 3, ... by measured height (an entry is never split)
local headH = textHeight("REFERENCES (10 of 10)", 32, GB, INNER_W) + GAP
local refPanels, cur, curH = {}, {}, headH
for i, ref in ipairs(CreditsData.references) do
	local h = textHeight(ref.marked, REF_SIZE, G, INNER_W, true) + GAP
	if curH + h > INNER_H - 2 and #cur > 0 then -- 2 px of slack
		table.insert(refPanels, cur)
		cur, curH = {}, headH
	end
	table.insert(cur, i)
	curH += h
end
table.insert(refPanels, cur)
local NPANELS = 1 + #refPanels
assert(NPANELS >= 8, "credits: only " .. NPANELS .. " panels")

-- panel k content: a list of { text, size, font, color, name, rich }
local function contentFor(k)
	local items = {}
	local function add(text, size, font, color, name, rich) table.insert(items, { text, size, font, color, name, rich }) end
	if k == 1 then
		add("CREDITS AND SOURCES", 32, GB, GOLD)
		add(CreditsData.identityText(), 24, GB, GOLD)
		for _, line in ipairs(CreditsData.projectLines) do add(line, 19, G, INK) end
		for _, line in ipairs(CreditsData.noticeLines) do add(line, 19, G, INK) end
	else
		add(string.format("REFERENCES (%d of %d)", k - 1, NPANELS - 1), 32, GB, GOLD)
		for _, i in ipairs(refPanels[k - 1]) do add(CreditsData.references[i].marked, REF_SIZE, G, INK, "Ref" .. i, true) end
	end
	return items
end

-- the frame: two rows, ceil(N/2) panels in the north row from the entrance eastward, the rest in the south row from the east end westward
local NA = math.ceil(NPANELS / 2)
local NB = NPANELS - NA
local xEast = X0 + SPACING * (NA - 1) + PANEL_W / 2 -- the east edge of the last panel of both rows
assert(xEast + 6 <= PLAZA.x1 and X0 - PANEL_W / 2 - 10 >= PLAZA.x0, "credits: the rows do not fit x 24..150 (" .. xEast .. "); add a third row or ask")
local function frame(z, yaw, n, xWest)
	local width = SPACING * n + 1
	local front = (yaw == 0) and -1 or 1 -- the front face looks along the panel's LookVector (z)
	local xc = xWest + width / 2
	part("Plinth", V(width, 1, 2.4), CF(xc, 0.5, z), STONE, CONC)
	for j = 0, n do
		part("Post", V(0.8, 14, 0.8), CF(xWest + 0.5 + SPACING * j, 8, z + front * 0.1), STONE, CONC) -- spans y 1..15, flush with the cap top
	end
	part("Cap", V(width, 0.8, 1.4), CF(xc, PANEL_BOTTOM + PANEL_H + 0.4, z + front * 0.1), STONE, CONC)
end
frame(ZN, math.pi, NA, X0 - PANEL_W / 2 - 1)
frame(ZS, 0, NB, xEast + 1 - (SPACING * NB + 1))

local sourceMeasure = {}
for k = 1, NPANELS do
	local x, z, yaw
	if k <= NA then
		x, z, yaw = X0 + SPACING * (k - 1), ZN, math.pi
	else
		x, z, yaw = xEast - PANEL_W / 2 - SPACING * (k - NA - 1), ZS, 0
	end
	local panel = part("Panel" .. k, V(PANEL_W, PANEL_H, PANEL_T), CF(x, PANEL_BOTTOM + PANEL_H / 2, z) * ANG(0, yaw, 0), SLATE, Enum.Material.SmoothPlastic)
	local g = Instance.new("SurfaceGui")
	g.Name = "CreditsGui" .. k
	g.Face = Enum.NormalId.Front
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = PPS
	g.LightInfluence = 0
	g.Parent = panel

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundColor3 = SLATE
	content.BorderSizePixel = 0
	content.Parent = g
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, PAD), UDim.new(0, PAD), UDim.new(0, PAD), UDim.new(0, PAD)
	pad.Parent = content
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, GAP)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = content

	local total, n = 2 * PAD, 0
	for order, it in ipairs(contentFor(k)) do
		local l = Instance.new("TextLabel")
		l.Name = it[5] or ("Line" .. order)
		l.LayoutOrder = order
		l.Size = UDim2.new(1, 0, 0, 0)
		l.AutomaticSize = Enum.AutomaticSize.Y
		l.BackgroundTransparency = 1
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Top
		l.TextWrapped = true
		l.TextScaled = false
		l.RichText = it[6] == true
		l.TextSize = it[2]
		l.Font = it[3]
		l.TextColor3 = it[4]
		l.Text = it[1]
		l.Parent = content
		total += textHeight(it[1], it[2], it[3], INNER_W, it[6])
		n += 1
	end
	total += (n - 1) * GAP
	table.insert(sourceMeasure, string.format("panel %d: %d px of %d", k, total, PANEL_H * PPS))
end

-- the entrance: a text-only sign across the path (bottom y 9, on two posts in line with the rows), 2 benches, 6 lamps
do
	local sign = part("EntrySign", V(0.6, 4, ZS - ZN), CF(27, 11, ZC), SLATE, Enum.Material.SmoothPlastic)
	part("SignPost", V(0.8, 13, 0.8), CF(27, 6.5, ZN), STONE, CONC)
	part("SignPost", V(0.8, 13, 0.8), CF(27, 6.5, ZS), STONE, CONC)
	local g = Instance.new("SurfaceGui")
	g.Name = "EntrySignGui"
	g.Face = Enum.NormalId.Left -- the west face (-X), toward Road E
	g.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud = PPS
	g.LightInfluence = 0
	g.Parent = sign
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundColor3 = SLATE
	content.BorderSizePixel = 0
	content.Parent = g
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, PAD), UDim.new(0, PAD), UDim.new(0, PAD), UDim.new(0, PAD)
	pad.Parent = content
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, GAP)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Parent = content
	local l = Instance.new("TextLabel")
	l.Name = "SignText"
	l.Size = UDim2.new(1, 0, 0, 70)
	l.BackgroundTransparency = 1
	l.TextXAlignment = Enum.TextXAlignment.Center
	l.TextWrapped = true
	l.TextScaled = false
	l.RichText = false
	l.TextSize = 56
	l.Font = GB
	l.TextColor3 = GOLD
	l.Text = "CREDITS AND SOURCES"
	l.Parent = content
end

for _, x in ipairs({ 44, 52 }) do -- benches on the south row's line west of its first panel, facing north toward the aisle (the back is on the +Z side)
	local cf = CF(x, 0, ZS)
	part("BenchSeat", V(6, 0.5, 2), cf * CF(0, 1.75, 0), TIMBER, WOOD)
	part("BenchBack", V(6, 2, 0.4), cf * CF(0, 3, 0.9), TIMBER, WOOD)
	part("BenchLegL", V(0.5, 1.5, 1.8), cf * CF(-2.5, 0.75, 0), LAMP_METAL, METAL)
	part("BenchLegR", V(0.5, 1.5, 1.8), cf * CF(2.5, 0.75, 0), LAMP_METAL, METAL)
end

local function post(name, diameter, height, x, baseY, z) -- an upright cylinder, as the Cathedral builders' post()
	return part(name, V(height, diameter, diameter), CF(x, baseY + height / 2, z) * ANG(0, 0, math.pi / 2), LAMP_METAL, METAL, Enum.PartType.Cylinder)
end
for _, s in ipairs({ { 33, ZC - 7 }, { 33, ZC + 7 }, { xEast + 7, ZN + 2 }, { xEast + 7, ZS - 2 }, { 88, ZN - 8 }, { 88, ZS + 8 } }) do
	post("LampBase", 1.8, 1.2, s[1], 0, s[2])
	post("LampPole", 0.6, 10, s[1], 1.2, s[2])
	post("LampCollar", 1.6, 0.5, s[1], 11.2, s[2])
	part("LampGlobe", V(2.2, 2.2, 2.2), CF(s[1], 12.6, s[2]), LAMP_GLOW, Enum.Material.Neon, Enum.PartType.Ball)
end

model.Parent = world
local count = 0
for _, d in ipairs(model:GetDescendants()) do if d:IsA("BasePart") then count += 1 end end
return string.format("CreditsBoard built: %d parts, %d panels (%d + %d); %s", count, NPANELS, NA, NB, table.concat(sourceMeasure, "; "))
