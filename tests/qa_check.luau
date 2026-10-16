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
	-- the spawn is at (0,70) looking -Z at the Cathedral: keep a 16-stud-wide lane clear
	check("CreditsBoard does not block the spawn-to-Cathedral lane (|x| < 8, z 0..70)",
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
