-- qa_check: verifies the Slice 13 additions (CreditsBoard, ambient audio, welcome screen, certificate wiring).
-- Run in Edit via execute_luau; returns JSON {passed, failed, failures}. Same shape as sites_check.
-- Studio-side checks are structural: they do not pin the photo count or the student identity (both change before Ship).
local HttpService = game:GetService("HttpService")
local CreditsData = require(game.ReplicatedStorage.LipaShared.CreditsData:Clone())

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local function sourceOf(inst)
	local ok, src = pcall(function() return inst.Source end)
	return ok and src or ""
end

-- CreditsBoard ------------------------------------------------------------
local world = workspace:FindFirstChild("World")
local board = world and world:FindFirstChild("CreditsBoard")
check("Workspace.World.CreditsBoard exists", board ~= nil)
if board then
	local parts, guis, labels = {}, {}, {}
	for _, d in ipairs(board:GetDescendants()) do
		if d:IsA("BasePart") then table.insert(parts, d) end
		if d:IsA("SurfaceGui") then table.insert(guis, d) end
		if d:IsA("TextLabel") then table.insert(labels, d) end
	end
	check("CreditsBoard has parts", #parts >= 1, tostring(#parts))
	local unanchored = {}
	for _, p in ipairs(parts) do if not p.Anchored then table.insert(unanchored, p.Name) end end
	check("CreditsBoard parts are all anchored", #unanchored == 0, table.concat(unanchored, ","))

	-- bounding box of the whole board in world axes
	local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge
	for _, p in ipairs(parts) do
		local cf, sz = p.CFrame, p.Size
		for _, sx in ipairs({ -0.5, 0.5 }) do for _, sz2 in ipairs({ -0.5, 0.5 }) do
			local c = cf:PointToWorldSpace(Vector3.new(sx * sz.X, 0, sz2 * sz.Z))
			minX, maxX = math.min(minX, c.X), math.max(maxX, c.X)
			minZ, maxZ = math.min(minZ, c.Z), math.max(maxZ, c.Z)
		end end
	end
	check("CreditsBoard sits inside the paved plaza (x -100..100, z 0..100)",
		minX >= -100 and maxX <= 100 and minZ >= 0 and maxZ <= 100,
		string.format("x %.1f..%.1f z %.1f..%.1f", minX, maxX, minZ, maxZ))
	-- Slice 3b: the spawn moved to the City Hall forecourt, but the board still stands at z 94 (Step 3 of Slice 3b moves it). The lane it must
	-- keep clear is the plaza's approach to the Cathedral: the OLD spawn constants (x 0, z 70, looking -Z), kept here on purpose
	-- and no longer read from the SpawnLocation.
	check("CreditsBoard does not block the plaza lane to the Cathedral (|x| < 8, z 0..70, the old spawn lane)",
		maxX < -8 or minX > 8 or minZ > 70 or maxZ < 0,
		string.format("x %.1f..%.1f z %.1f..%.1f", minX, maxX, minZ, maxZ))

	check("CreditsBoard has at least one SurfaceGui", #guis >= 1)
	local texts, richText = {}, {}
	for _, l in ipairs(labels) do
		table.insert(texts, l.Text)
		if l.RichText then table.insert(richText, l.Name) end
	end
	local all = table.concat(texts, "\n")
	check("CreditsBoard labels have RichText off", #richText == 0, table.concat(richText, ","))
	local missing = {}
	for _, entry in ipairs(CreditsData.sites) do
		for _, url in ipairs(entry.urls) do
			if not string.find(all, url, 1, true) then table.insert(missing, url) end -- plain find: urls hold pattern characters
		end
	end
	check("CreditsBoard text carries every credits url", #missing == 0, #missing .. " missing: " .. table.concat(missing, " ; ", 1, math.min(#missing, 3)))
	check("CreditsBoard text carries the identity slot", string.find(all, CreditsData.identityText(), 1, true) ~= nil, CreditsData.identityText())
	local tooSmall = {}
	for _, l in ipairs(labels) do
		if l.TextScaled == false and l.TextSize < 14 then table.insert(tooSmall, l.Name) end
	end
	check("CreditsBoard labels are not set below 14 px", #tooSmall == 0, table.concat(tooSmall, ","))

	-- every panel's text must fit its canvas: measured with TextService, so a long url cannot clip silently
	local TextService = game:GetService("TextService")
	local overflow = {}
	for _, g in ipairs(guis) do
		local part = g.Adornee or g.Parent
		local sideways = g.Face == Enum.NormalId.Right or g.Face == Enum.NormalId.Left
		local canvasW = (sideways and part.Size.Z or part.Size.X) * g.PixelsPerStud
		local canvasH = part.Size.Y * g.PixelsPerStud
		local frame = g:FindFirstChildWhichIsA("Frame")
		local pad = frame and frame:FindFirstChildOfClass("UIPadding")
		local list = frame and frame:FindFirstChildOfClass("UIListLayout")
		if not (frame and pad and list) then
			table.insert(overflow, g.Name .. ": no Frame with UIPadding and UIListLayout")
		else
			local width = canvasW - pad.PaddingLeft.Offset - pad.PaddingRight.Offset
			local total, n = pad.PaddingTop.Offset + pad.PaddingBottom.Offset, 0
			for _, l in ipairs(frame:GetChildren()) do
				if l:IsA("TextLabel") then
					local p = Instance.new("GetTextBoundsParams")
					p.Text, p.Font, p.Size, p.Width = l.Text, l.FontFace, l.TextSize, width
					total += TextService:GetTextBoundsAsync(p).Y
					n += 1
				end
			end
			total += math.max(n - 1, 0) * list.Padding.Offset
			if total > canvasH then
				table.insert(overflow, string.format("%s needs %.0f px of %.0f", g.Name, total, canvasH))
			end
		end
	end
	check("CreditsBoard text fits every panel canvas", #overflow == 0, table.concat(overflow, "; "))
end

-- Spawn (Slice 3b): the pad is on the City Hall forecourt, facing the entrance, with Ate Joy 9 studs west of its edge ----------------
do
	local spawn = workspace:FindFirstChild("SpawnLocation")
	check("SpawnLocation exists", spawn ~= nil)
	local city = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site10_CityHall")
	if spawn and city then
		local p = spawn.Position
		check("spawn pad is at (-208, -260) +-0.5", math.abs(p.X + 208) <= 0.5 and math.abs(p.Z + 260) <= 0.5, tostring(p))
		check("spawn faces -X (the City Hall entrance)", spawn.CFrame.LookVector.X < -0.99, tostring(spawn.CFrame.LookVector))
		check("spawn pad is 12 x 1 x 12", math.abs(spawn.Size.X - 12) < 0.01 and math.abs(spawn.Size.Y - 1) < 0.01 and math.abs(spawn.Size.Z - 12) < 0.01, tostring(spawn.Size))
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Include
		rp.FilterDescendantsInstances = { workspace.Terrain, city.Forecourt }
		local hit = workspace:Raycast(Vector3.new(p.X, p.Y + 40, p.Z), Vector3.new(0, -100, 0), rp)
		local bottom = p.Y - spawn.Size.Y / 2
		check("paving or ground lies within 1.5 studs below the pad", hit ~= nil and hit.Position.Y <= bottom + 0.05 and bottom - hit.Position.Y <= 1.5,
			hit and string.format("ground %.2f, pad bottom %.2f", hit.Position.Y, bottom) or "no ground")
		-- nothing solid of City Hall inside the pad: the box starts 0.6 above y 0, over the flat paving and road layers (top y <= 0.5)
		local op = OverlapParams.new()
		op.FilterType = Enum.RaycastFilterType.Include
		op.FilterDescendantsInstances = { city }
		local box = CFrame.new(p.X, 2.3, p.Z) * spawn.CFrame.Rotation
		local hits = workspace:GetPartBoundsInBox(box, Vector3.new(spawn.Size.X - 0.2, 3.4, spawn.Size.Z - 0.2), op)
		local names = {}
		for _, h in ipairs(hits) do table.insert(names, h:GetFullName()) end
		check("spawn pad is not inside any City Hall part", #hits == 0, table.concat(names, ", ", 1, math.min(#names, 3)))
		local guide = city:FindFirstChild("Guide")
		if guide then
			local gx0, gx1, gz0, gz1 = math.huge, -math.huge, math.huge, -math.huge
			for _, d in ipairs(guide:GetDescendants()) do
				if d:IsA("BasePart") then
					gx0, gx1 = math.min(gx0, d.Position.X - d.Size.X / 2), math.max(gx1, d.Position.X + d.Size.X / 2)
					gz0, gz1 = math.min(gz0, d.Position.Z - d.Size.Z / 2), math.max(gz1, d.Position.Z + d.Size.Z / 2)
				end
			end
			local dx = math.max(gx0 - (p.X + 6), (p.X - 6) - gx1, 0)
			local dz = math.max(gz0 - (p.Z + 6), (p.Z - 6) - gz1, 0)
			check("pad is at least 6 studs from Ate Joy's footprint", math.sqrt(dx * dx + dz * dz) >= 6, string.format("%.2f", math.sqrt(dx * dx + dz * dz)))
		else
			check("Ate Joy's Guide exists for the spawn distance check", false)
		end
	end
end

-- Ambient audio -----------------------------------------------------------
do
	local found = {}
	for _, s in ipairs(game:GetService("SoundService"):GetDescendants()) do
		if s:IsA("Sound") then table.insert(found, s) end
	end
	check("SoundService holds at least one Sound", #found >= 1, tostring(#found))
	local ambient
	for _, s in ipairs(found) do
		if s:GetAttribute("Ambient") == true then ambient = s break end
	end
	check("an ambient Sound is tagged Ambient=true", ambient ~= nil)
	if ambient then
		check("ambient Sound has a SoundId", ambient.SoundId ~= "" and string.find(ambient.SoundId, "rbxassetid://", 1, true) == 1, ambient.SoundId)
		check("ambient Sound loops", ambient.Looped)
		check("ambient Sound volume is at most 0.5", ambient.Volume > 0 and ambient.Volume <= 0.5, tostring(ambient.Volume))
	end
end

-- Client scripts ------------------------------------------------------------
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
local welcome = sps and sps:FindFirstChild("WelcomeClient")
check("WelcomeClient exists in StarterPlayerScripts", welcome ~= nil)
if welcome then
	local src = sourceOf(welcome)
	check("WelcomeClient is a LocalScript", welcome:IsA("LocalScript"))
	check("WelcomeClient keeps ResetOnSpawn = false (once per join, not per respawn)", string.find(src, "ResetOnSpawn = false", 1, true) ~= nil)
	check("WelcomeClient draws above the HUD (DisplayOrder > 5)", (tonumber(string.match(src, "DisplayOrder%s*=%s*(%d+)")) or 0) > 5)
	check("WelcomeClient never turns RichText on", string.find(src, "RichText = true", 1, true) == nil)
	check("WelcomeClient has a Start button", string.find(src, "Start", 1, true) ~= nil)
	check("WelcomeClient switches its hint for touch devices", string.find(src, "TouchEnabled", 1, true) ~= nil)
end
local passport = sps and sps:FindFirstChild("PassportClient")
check("PassportClient exists", passport ~= nil)
if passport then
	local src = sourceOf(passport)
	check("PassportClient no longer defers the certificate to Slice 13", string.find(src, "Slice 13", 1, true) == nil)
	check("PassportClient builds the certificate from CertificateLogic", string.find(src, "CertificateLogic", 1, true) ~= nil)
	check("PassportClient never turns RichText on", string.find(src, "RichText = true", 1, true) == nil)
	check("PassportClient has a mute toggle for the ambient audio", string.find(src, "Mute", 1, true) ~= nil)
	-- Measured on a 401-wide portrait phone: the third HUD button (Certificate) ended at x 438, off screen. The row must wrap.
	check("PassportClient HUD button row wraps on narrow screens", string.find(src, "Wraps = true", 1, true) ~= nil)
	check("PassportClient HUD buttons are not placed at fixed x offsets", string.find(src, "b.Position = UDim2.new(0, x", 1, true) == nil)
end
local guide = sps and sps:FindFirstChild("GuideClient")
check("GuideClient exists", guide ~= nil)
if guide then
	local src = sourceOf(guide)
	-- Measured on a 705x338 phone before the fix: Next/Close were 65x12 px and the title text about 10 px (scaled box).
	check("GuideClient dialogue buttons are at least 44 px tall", (tonumber(string.match(src, "BUTTON_HEIGHT%s*=%s*(%d+)")) or 0) >= 44)
	check("GuideClient dialogue box no longer scales its buttons from the box", string.find(src, "fromScale(0.16, 0.22)", 1, true) == nil)
	check("GuideClient dialogue text is a fixed readable size (>= 16)", (tonumber(string.match(src, "BODY_TEXT%s*=%s*(%d+)")) or 0) >= 16)
	check("GuideClient never turns RichText on", string.find(src, "RichText = true", 1, true) == nil)
	-- Slice 23 playtest: after talking to a guide and riding the jeepney, the old dialogue (Next/Close) stayed on screen under the jeep menu.
	local leave = tonumber(string.match(src, "LEAVE_DISTANCE%s*=%s*(%d+)")) or 0
	check("GuideClient closes the dialogue once the player walks or rides away (LEAVE_DISTANCE 20..60 studs)", leave >= 20 and leave <= 60, tostring(leave))
	check("GuideClient measures that distance from where the dialogue opened", string.find(src, "openedAt", 1, true) ~= nil and string.find(src, "LEAVE_DISTANCE", 1, true) ~= nil and string.find(src, "Heartbeat", 1, true) ~= nil)
end
local jeep = sps and sps:FindFirstChild("JeepneyClient")
check("JeepneyClient exists", jeep ~= nil)
if jeep then
	local src = sourceOf(jeep)
	-- Measured on a 705x338 phone before the fix: the fixed 380x420 menu ran 70 px off the bottom and 12 px off the top.
	check("JeepneyClient menu is not a fixed 380x420 box", string.find(src, "fromOffset(380, 420)", 1, true) == nil)
	check("JeepneyClient menu scrolls (ScrollingFrame) so it fits short viewports", string.find(src, "ScrollingFrame", 1, true) ~= nil)
	check("JeepneyClient buttons are at least 44 px tall", (tonumber(string.match(src, "BUTTON_HEIGHT%s*=%s*(%d+)")) or 0) >= 44)
	check("JeepneyClient menu ignores the top-bar inset so it is centred on the real screen", string.find(src, "IgnoreGuiInset = true", 1, true) ~= nil)
	check("JeepneyClient never turns RichText on", string.find(src, "RichText = true", 1, true) == nil)
end
local shared = game.ReplicatedStorage:FindFirstChild("LipaShared")
check("CertificateLogic and CreditsData live in LipaShared",
	shared ~= nil and shared:FindFirstChild("CertificateLogic") ~= nil and shared:FindFirstChild("CreditsData") ~= nil)

return HttpService:JSONEncode(results)
