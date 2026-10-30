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
-- Credits job B (2026-10-27, owner: "another area for like displaying the credits board"): the board left the south end of the Cathedral plaza
-- (z 205, now outside the Cathedral's closed south fence) for the Credits Plaza (x 24..150, z 274..346, east of Road E) and grew from six panels
-- to the title, identity, project notes, notices and the 78 APA 7 references. Replaced assertions (old text -> why -> new text):
--   "CreditsBoard sits inside the paved plaza at its south end (x -100..100, z 195..215)" -> the plaza moved -> "sits inside the Credits Plaza box x 24..150, z 274..346"
--   "CreditsBoard keeps a walking aisle open (no part under 8 studs headroom inside |x| < 8)" -> the aisle at x 0 led to the old fence -> "keeps a reading aisle, at least 14 studs wide, free of parts under 8 studs headroom"
--   "CreditsBoard labels have RichText off" -> the references use <i> -> "only the Ref<i> labels have RichText on, equal to marked; every other label has it off"
--   "CreditsBoard has six panels (CreditsGui1..6)", "panel 4 names City Hall...", "panel 4 carries every projectLines line", "panel 5 has the Tour sources header",
--   "panels 5-6 carry every tourSources text (or url)", "panels 5-6 show each tour source's domain" -> the sources are now the 78 references, nothing is cut to a domain ->
--   "panel 1 carries the title, identityText, every projectLines and noticeLines line; panels 2..N carry the references in order, each exactly once (N >= 8)"
--   "tour-source panels use at least 16 px text" -> "reference labels are exactly 16 px"
--   "CreditsBoard text carries every credits url" keeps its text, now satisfied through the references.
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
	check("CreditsBoard stays under 100 parts (about 90 budgeted)", #parts <= 100, tostring(#parts))
	local unanchored = {}
	for _, p in ipairs(parts) do if not p.Anchored then table.insert(unanchored, p.Name) end end
	check("CreditsBoard parts are all anchored", #unanchored == 0, table.concat(unanchored, ","))

	-- axis-aligned extents of a (possibly rotated) part: x0, x1, y0, y1, z0, z1
	local function extents(p)
		local cf, sz = p.CFrame, p.Size
		local function half(axis)
			return (math.abs(cf.RightVector[axis]) * sz.X + math.abs(cf.UpVector[axis]) * sz.Y + math.abs(cf.LookVector[axis]) * sz.Z) / 2
		end
		local pos = p.Position
		return pos.X - half("X"), pos.X + half("X"), pos.Y - half("Y"), pos.Y + half("Y"), pos.Z - half("Z"), pos.Z + half("Z")
	end
	local function unmark(s)
		s = string.gsub(string.gsub(s, "<i>", ""), "</i>", "")
		return (string.gsub(string.gsub(string.gsub(s, "&lt;", "<"), "&gt;", ">"), "&amp;", "&"))
	end

	-- the Credits Plaza box: every part but the EntryPath ground strip (which reaches Road E's east edge) lies inside x 24..150, z 274..346
	local outside, paving = {}, nil
	for _, p in ipairs(parts) do
		if not string.match(p.Name, "^EntryPath") then
			local x0, x1, _, _, z0, z1 = extents(p)
			if x0 < 24 - 0.01 or x1 > 150 + 0.01 or z0 < 274 - 0.01 or z1 > 346 + 0.01 then
				table.insert(outside, string.format("%s x %.1f..%.1f z %.1f..%.1f", p.Name, x0, x1, z0, z1))
			end
			if p.Name == "CreditsPaving" then paving = p end
		end
	end
	check("CreditsBoard sits inside the Credits Plaza box (x 24..150, z 274..346): every part but the EntryPath strip", #outside == 0, table.concat(outside, "; ", 1, math.min(#outside, 3)))
	local pvOk = paving ~= nil and paving.Size.Y <= 0.25 and paving.Size.X >= 100 and paving.Size.Z >= 60 and select(4, extents(paving)) <= 0.3
	check("CreditsBoard has a CreditsPaving floor part (0.2 thick, top y <= 0.3, at least 100 x 60 studs) inside that box", pvOk, paving and tostring(paving.Size) or "missing")

	-- two facing rows of panels
	local panels, nPanels = {}, 0
	for _, p in ipairs(parts) do
		local k = tonumber(string.match(p.Name, "^Panel(%d+)$"))
		if k then panels[k] = p; nPanels += 1 end
	end
	local contiguous = nPanels >= 1
	for k = 1, nPanels do if not panels[k] then contiguous = false end end
	check("CreditsBoard has Panel1..PanelN, N >= 8", contiguous and nPanels >= 8, tostring(nPanels))
	local zs = {}
	for k = 1, nPanels do
		local z, found = panels[k] and panels[k].Position.Z or 0, false
		for _, v in ipairs(zs) do if math.abs(v - z) < 0.5 then found = true end end
		if not found then table.insert(zs, z) end
	end
	table.sort(zs)
	local zN, zS = zs[1] or 0, zs[2] or 0
	local aisleZ = (zN + zS) / 2
	local rowN, rowS = 0, 0
	for k = 1, nPanels do if panels[k].Position.Z < aisleZ then rowN += 1 else rowS += 1 end end
	check("panels stand in exactly two rows (two z lines), each holding half of them (ceil and floor of N / 2)", #zs == 2 and math.abs(rowN - rowS) <= 1 and rowN >= 4 and rowS >= 4, string.format("%d lines, %d + %d panels", #zs, rowN, rowS))
	local notFacing = {}
	for k = 1, nPanels do
		local p = panels[k]
		local look = p.CFrame.LookVector
		local g = p:FindFirstChild("CreditsGui" .. k)
		if not (math.abs(look.Z) > 0.99 and look.Z * (aisleZ - p.Position.Z) > 0 and g and g:IsA("SurfaceGui") and g.Face == Enum.NormalId.Front) then
			table.insert(notFacing, "Panel" .. k)
		end
	end
	check("every panel's Front face (its SurfaceGui) points across the aisle, so no text is on a panel back", #notFacing == 0, table.concat(notFacing, ","))

	-- the reading aisle: the strip between the rows (1.3 studs inside each panel line, so the plinth may protrude) is at least 14 studs wide, and no
	-- part with its bottom under 8 studs stands in it along the rows' x range (ground paving, top y <= 0.3, is not an obstacle)
	local sx0, sx1 = math.huge, -math.huge
	for k = 1, nPanels do
		local x0, x1 = extents(panels[k])
		sx0, sx1 = math.min(sx0, x0), math.max(sx1, x1)
	end
	local stripN, stripS = zN + 1.3, zS - 1.3
	local blockers = {}
	for _, p in ipairs(parts) do
		local x0, x1, y0, y1, z0, z1 = extents(p)
		if y0 < 8 and y1 > 0.3 and x0 < sx1 and x1 > sx0 and z0 < stripS and z1 > stripN then table.insert(blockers, p.Name) end
	end
	check("CreditsBoard keeps a reading aisle at least 14 studs wide between the rows", stripS - stripN >= 14, string.format("%.1f studs", stripS - stripN))
	check("CreditsBoard reading aisle has no part under 8 studs headroom inside it", #blockers == 0, #blockers .. " blocking: " .. table.concat(blockers, ","))

	-- the entry path: a ground strip from Road E's east edge (x 6) to the plaza (x 24), on the aisle line (z about 310)
	local pathX0, pathX1, pathOk, pathN = math.huge, -math.huge, true, 0
	for _, p in ipairs(parts) do
		if string.match(p.Name, "^EntryPath") then
			local x0, x1, _, y1, z0, z1 = extents(p)
			pathN += 1
			pathX0, pathX1 = math.min(pathX0, x0), math.max(pathX1, x1)
			if y1 > 0.3 or math.abs((z0 + z1) / 2 - aisleZ) > 1.5 or math.abs((z0 + z1) / 2 - 310) > 4 then pathOk = false end
		end
	end
	check("CreditsBoard has an EntryPath ground strip from Road E's east edge (x 6) to the plaza (x 24), top y <= 0.3, centred on the aisle (z about 310)",
		pathN >= 1 and pathOk and pathX0 <= 6.05 and pathX1 >= 23.95, string.format("%d parts, x %.1f..%.1f", pathN, pathX0, pathX1))

	-- the entrance sign (text only), 2 benches and 4 to 6 lamps
	local sign = board:FindFirstChild("EntrySign")
	local signGui = sign and sign:FindFirstChild("EntrySignGui")
	local signLabel = signGui and signGui:FindFirstChildWhichIsA("TextLabel", true)
	local signOk = sign ~= nil and signGui ~= nil and signLabel ~= nil and signLabel.Text == "CREDITS AND SOURCES" and signLabel.TextScaled == false and signLabel.TextSize >= 14
		and not string.find(signLabel.Text, "[\128-\255]") and select(3, extents(sign)) >= 8
		and sign.CFrame:VectorToWorldSpace(Vector3.FromNormalId(signGui.Face)).X < -0.99 and not string.match(signGui.Name, "^CreditsGui")
	check("entrance sign: text-only 'CREDITS AND SOURCES' (ASCII, fixed TextSize), bottom at 8+ studs, facing west toward Road E", signOk, signLabel and (signLabel.Text .. " " .. signLabel.TextSize) or "missing")
	local benchN, lampN = 0, 0
	for _, p in ipairs(parts) do
		if p.Name == "BenchSeat" then benchN += 1 end
		if p.Name == "LampGlobe" then lampN += 1 end
	end
	check("CreditsBoard has 2 benches and 4 to 6 lamps", benchN == 2 and lampN >= 4 and lampN <= 6, string.format("%d benches, %d lamps", benchN, lampN))

	-- text
	local texts, richBad = {}, {}
	for _, l in ipairs(labels) do table.insert(texts, l.Text) end
	local all = table.concat(texts, "\n")
	local refMarked = {}
	for i, ref in ipairs(CreditsData.references) do refMarked[i] = ref end
	for _, l in ipairs(labels) do
		local i = tonumber(string.match(l.Name, "^Ref(%d+)$"))
		if i then
			local ref = refMarked[i]
			if not (ref and l.RichText == true and l.Text == ref.marked and unmark(l.Text) == ref.text) then table.insert(richBad, l.Name) end
		elseif l.RichText then
			table.insert(richBad, l.Name)
		end
	end
	check("only the Ref<i> labels have RichText on (Text = references[i].marked, <i> and entities removed = text); every other label has it off", #richBad == 0, table.concat(richBad, ",", 1, math.min(#richBad, 5)))
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
	check("CreditsBoard has at least one SurfaceGui", #guis >= 1)

	-- panel contents: guis by k, labels by LayoutOrder (GetDescendants order is not guaranteed)
	local panelLabels, nGuis = {}, 0
	for _, g in ipairs(guis) do
		local k = tonumber(string.match(g.Name, "^CreditsGui(%d+)$"))
		if k then
			local ls = {}
			for _, l in ipairs(g:GetDescendants()) do
				if l:IsA("TextLabel") then table.insert(ls, l) end
			end
			table.sort(ls, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
			panelLabels[k] = ls
			nGuis += 1
		end
	end
	check("CreditsBoard has CreditsGui1..N, one per panel", nGuis == nPanels and nPanels >= 8 and panelLabels[nPanels] ~= nil, string.format("%d guis, %d panels", nGuis, nPanels))
	local pl1 = panelLabels[1] or {}
	check("panel 1 starts with the title CREDITS AND SOURCES (32 px) and the identity line (24 px)",
		pl1[1] ~= nil and pl1[1].Text == "CREDITS AND SOURCES" and pl1[1].TextSize == 32 and pl1[2] ~= nil and pl1[2].Text == CreditsData.identityText() and pl1[2].TextSize == 24,
		pl1[1] and (pl1[1].Text .. " " .. pl1[1].TextSize) or "no labels")
	local missingNotes = {}
	for _, list in ipairs({ CreditsData.projectLines, CreditsData.noticeLines }) do
		for _, line in ipairs(list) do
			local n = 0
			for _, l in ipairs(pl1) do if l.Text == line and l.TextSize == 19 then n += 1 end end
			if n ~= 1 then table.insert(missingNotes, string.sub(line, 1, 40)) end
		end
	end
	check("panel 1 carries every projectLines and every noticeLines line, once each, at 19 px", #missingNotes == 0 and #CreditsData.projectLines >= 2 and #CreditsData.noticeLines >= 4, table.concat(missingNotes, " ; "))
	local headersOk, headerBad = true, {}
	for k = 2, nPanels do
		local first = panelLabels[k] and panelLabels[k][1]
		if not (first and first.Text == string.format("REFERENCES (%d of %d)", k - 1, nPanels - 1) and first.TextSize == 32) then
			headersOk = false
			table.insert(headerBad, "panel " .. k)
		end
	end
	check("panels 2..N start with the header REFERENCES (k of N-1) at 32 px", headersOk and nPanels >= 8, table.concat(headerBad, ","))
	local seq, refOnP1 = {}, 0
	for k = 1, nPanels do
		for _, l in ipairs(panelLabels[k] or {}) do
			local i = tonumber(string.match(l.Name, "^Ref(%d+)$"))
			if i then
				table.insert(seq, i)
				if k == 1 then refOnP1 += 1 end
			end
		end
	end
	local orderOk = #seq == #CreditsData.references and #seq == 78 and refOnP1 == 0
	for j, i in ipairs(seq) do if i ~= j then orderOk = false end end
	check("labels Ref1..Ref78 appear once each, in order across panels 2..N (none on panel 1)", orderOk, #seq .. " Ref labels, first mismatch near " .. tostring(seq[1]))
	local refBad, refSizeBad = {}, {}
	for i, ref in ipairs(CreditsData.references) do
		local n = 0
		for _, l in ipairs(labels) do if l.Text == ref.marked then n += 1 end end
		if n ~= 1 then table.insert(refBad, "#" .. i) end
	end
	for _, l in ipairs(labels) do
		if string.match(l.Name, "^Ref%d+$") and l.TextSize ~= 16 then table.insert(refSizeBad, l.Name) end
	end
	check("every references[i].marked string appears in exactly one label", #refBad == 0, table.concat(refBad, ",", 1, math.min(#refBad, 5)))
	local scaled = {}
	for _, l in ipairs(labels) do if l.TextScaled then table.insert(scaled, l.Name) end end
	check("CreditsBoard labels never use TextScaled (fixed TextSize)", #scaled == 0, table.concat(scaled, ","))
	check("reference labels are exactly 16 px", #refSizeBad == 0 and #seq == 78, table.concat(refSizeBad, ",", 1, math.min(#refSizeBad, 5)))

	-- every panel's text must fit its canvas: measured with TextService (RichText measured as RichText when the property exists), so a long url cannot clip silently
	local TextService = game:GetService("TextService")
	local probe = Instance.new("GetTextBoundsParams")
	local hasRich = pcall(function() probe.RichText = true end)
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
					if l.RichText then
						if hasRich then p.RichText = true else p.Text = unmark(l.Text) end
					end
					total += TextService:GetTextBoundsAsync(p).Y + ((l.RichText and not hasRich) and 4 or 0)
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
	-- Slice 3b: ten places, and the credits board directions are true from the City Hall spawn. Credits job B (2026-10-27): the board moved from the
	-- south end of the Cathedral plaza to the Credits Plaza (x 24..150, z 274..346), so the old pin "credits board at the south end of the Cathedral plaza"
	-- (the board is no longer there) is replaced by the new Step4 line below, and the old string must be gone; "not south of the spawn" stays.
	check("WelcomeClient says 'Ten places'", string.find(src, "Ten places", 1, true) ~= nil)
	check("WelcomeClient no longer says 'Nine places'", string.find(src, "Nine places", 1, true) == nil)
	check("WelcomeClient says 'Collect all 10 stamps'", string.find(src, "Collect all 10 stamps", 1, true) ~= nil)
	check("WelcomeClient no longer says 'all 9 stamps'", string.find(src, "all 9 stamps", 1, true) == nil)
	check("WelcomeClient Step4 sends players to the credits board in the Credits Plaza, south of the Cathedral",
		string.find(src, "4. Photo sources are on the credits board in the Credits Plaza, south of the Cathedral. Take the jeepney, exit by a side gate, walk south.", 1, true) ~= nil)
	check("WelcomeClient no longer places the credits board at the south end of the Cathedral plaza", string.find(src, "south end of the Cathedral plaza", 1, true) == nil)
	check("WelcomeClient no longer places the credits board 'south of the spawn'", string.find(src, "south of the spawn", 1, true) == nil)
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
	-- Slice 3b: ten sites. No site-count literal may remain in the script; the counts come from the site list and the certificate
	-- uses the pure cellRects/layout functions with fixed text sizes.
	check("PassportClient has no '/9' count literal", string.find(src, "/9", 1, true) == nil)
	check("PassportClient has no ' 9)' count literal", string.find(src, " 9)", 1, true) == nil)
	check("PassportClient has no 'for i = 1, 9' loop", string.find(src, "for i = 1, 9", 1, true) == nil)
	check("PassportClient has no 'lastCount < 9' threshold", string.find(src, "lastCount < 9", 1, true) == nil)
	check("PassportClient counts from the site list (#SiteData.sites or TOTAL_SITES)",
		string.find(src, "#SiteData.sites", 1, true) ~= nil or string.find(src, "TOTAL_SITES", 1, true) ~= nil)
	check("PassportClient shows the 10-based counter ('Passport 0/' .. total and a '%d/' .. total format)",
		string.find(src, "\"Passport 0/\"", 1, true) ~= nil and string.find(src, "Passport %d/", 1, true) ~= nil)
	check("PassportClient certificate loops over every site (1..TOTAL)", string.find(src, "for i = 1, TOTAL", 1, true) ~= nil)
	check("PassportClient HUD has a gold Welcome row from SiteData.categoryColor('Welcome')",
		string.find(src, "categoryColor(\"Welcome\")", 1, true) ~= nil and string.find(src, "WelcomeRow", 1, true) ~= nil)
	check("PassportClient lays out the certificate with CertificateLogic.cellRects and layout",
		string.find(src, "CertificateLogic.cellRects(", 1, true) ~= nil and string.find(src, "CertificateLogic.layout(", 1, true) ~= nil)
	check("PassportClient certificate cells use a fixed TextSize, not the old scaled 3x3 grid",
		string.find(src, "TextSize = geo.textSize", 1, true) ~= nil and string.find(src, "UITextSizeConstraint", 1, true) == nil
		and string.find(src, "CellSize = UDim2.new(1 / 3", 1, true) == nil)
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
-- New-player guidance (owner-approved plan, 2026-10-31): the newcomer playtest found no "what next" after Ate Joy, no way to find the
-- three walk-only shops, a camera facing away from the guide after a ride, silent stamps and silent ride refusals. The logic is unit
-- tested in GuidanceLogic_Test; these pins keep the clients wired to it and the approved words in place.
if welcome then
	local src = sourceOf(welcome)
	check("WelcomeClient Step1 names Ate Joy as the first guide and keeps the touch hint",
		string.find(src, "1. Ate Joy, the guide in front of you, starts the tour. Walk up to a guide and \" .. talkHint .. \" to talk. Each guide stamps your passport.", 1, true) ~= nil)
end
if passport then
	local src = sourceOf(passport)
	check("PassportClient takes its next-stop hint from GuidanceLogic", string.find(src, "GuidanceLogic.hint(", 1, true) ~= nil)
	check("PassportClient shows the hint in a NextHint label with a fixed text size (HINT_TEXT >= 14)",
		string.find(src, "\"NextHint\"", 1, true) ~= nil and (tonumber(string.match(src, "HINT_TEXT%s*=%s*(%d+)")) or 0) >= 14)
	check("PassportClient publishes the next site as the NextSiteId attribute (for playtests)", string.find(src, "\"NextSiteId\"", 1, true) ~= nil)
	check("PassportClient draws a client-local NEXT pin that shows through walls (BillboardGui, AlwaysOnTop)",
		string.find(src, "\"NextPin\"", 1, true) ~= nil and string.find(src, "AlwaysOnTop = true", 1, true) ~= nil)
	check("PassportClient announces a new stamp ('Stamp collected: ')", string.find(src, "\"Stamp collected: \"", 1, true) ~= nil)
	check("PassportClient header no longer says the waypoints were cut", string.find(src, "Waypoints were cut", 1, true) == nil)
end
if guide then
	local src = sourceOf(guide)
	check("GuideClient relabels streamed-in guide prompts 'Talk (get a stamp)'",
		string.find(src, "\"Talk (get a stamp)\"", 1, true) ~= nil and string.find(src, "DescendantAdded", 1, true) ~= nil)
end
if jeep then
	local src = sourceOf(jeep)
	check("JeepneyClient relabels jeep prompts 'Choose a ride'", string.find(src, "\"Choose a ride\"", 1, true) ~= nil)
	check("JeepneyClient explains a cooldown refusal", string.find(src, "\"Wait a moment for the next jeepney.\"", 1, true) ~= nil)
	check("JeepneyClient explains a ride asked for off the stop", string.find(src, "\"Stand on the yellow jeepney stop to ride.\"", 1, true) ~= nil)
	check("JeepneyClient marks stamped places ' - done' and highlights GuidanceLogic.jeepTarget",
		string.find(src, "\" - done\"", 1, true) ~= nil and string.find(src, "GuidanceLogic.jeepTarget(", 1, true) ~= nil)
	check("JeepneyClient tells how to reach the walk-only shops",
		string.find(src, "\"Market, Lomi King, Cafe de Lipa: ride to the Plaza, then walk.\"", 1, true) ~= nil)
	check("JeepneyClient turns the camera to the guide after a ride",
		string.find(src, "LastJeepResult", 1, true) ~= nil and string.find(src, "SiteData.guidePos(", 1, true) ~= nil and string.find(src, "CurrentCamera", 1, true) ~= nil)
end
-- Polish pass (2026-10-31, owner: "small effort big returns"): a fade around the jeepney ride so the teleport does not read as a glitch,
-- a fixed grid text size, a quiet stamp sound with a counter pop (muted by the Sound button), and warm lamp lights at golden hour.
if jeep then
	local src = sourceOf(jeep)
	local fadeOut = tonumber(string.match(src, "FADE_OUT%s*=%s*([%d%.]+)")) or 0
	local fadeIn = tonumber(string.match(src, "FADE_IN%s*=%s*([%d%.]+)")) or 0
	check("JeepneyClient fades through black in its own full-screen JeepFade ScreenGui (TweenService, IgnoreGuiInset)",
		string.find(src, "\"JeepFade\"", 1, true) ~= nil and string.find(src, "fadeGui.IgnoreGuiInset = true", 1, true) ~= nil
		and string.find(src, "TweenService", 1, true) ~= nil)
	check("JeepneyClient fade is short: out 0.15..0.4 s, in 0.2..0.5 s", fadeOut >= 0.15 and fadeOut <= 0.4 and fadeIn >= 0.2 and fadeIn <= 0.5,
		string.format("out %s, in %s", tostring(fadeOut), tostring(fadeIn)))
	local waitAt = string.find(src, "Completed:Wait()", 1, true)
	local fireAt = string.find(src, "JeepRequest:FireServer(", 1, true)
	check("JeepneyClient asks for the ride only once the screen is black (Completed:Wait() before JeepRequest:FireServer)",
		waitAt ~= nil and fireAt ~= nil and waitAt < fireAt)
	local _, fadeIns = string.gsub(src, "fadeIn%(%)", "")
	check("JeepneyClient fades back in on a refusal, after the camera turn and on a timeout (FADE_TIMEOUT, fadeIn() called 3+ times)",
		string.find(src, "FADE_TIMEOUT", 1, true) ~= nil and fadeIns >= 3, tostring(fadeIns))
	check("JeepneyClient fade frame never eats clicks (Active = false)", string.find(src, "fade.Active = false", 1, true) ~= nil)
end
if passport then
	local src = sourceOf(passport)
	check("PassportClient stamp cells no longer use TextScaled", string.find(src, "slot.TextScaled = true", 1, true) == nil)
	local size = tonumber(string.match(src, "GRID_TEXT%s*=%s*(%d+)")) or 0
	local inset = tonumber(string.match(src, "GRID_INSET%s*=%s*(%d+)")) or -1
	local cw, ch = string.match(src, "WELCOME_H, CELL_W, CELL_H, GRID_GAP, GRID_PAD = %d+, (%d+), (%d+)")
	cw, ch = tonumber(cw) or 0, tonumber(ch) or 0
	check("PassportClient stamp cells use a fixed GRID_TEXT >= 12 with a GRID_INSET padding",
		size >= 12 and inset >= 0 and string.find(src, "slot.TextSize = GRID_TEXT", 1, true) ~= nil, size .. " / " .. inset)
	if size >= 12 and inset >= 0 and cw > 0 then
		local TextService = game:GetService("TextService")
		local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())
		local innerW, innerH = cw - 2 * inset, ch - 2 * inset
		local over = {}
		for _, s in ipairs(SiteData.sites) do
			if s.category ~= "Welcome" then
				local text = s.id .. ". " .. s.name
				local fit = TextService:GetTextSize(text, size, Enum.Font.Gotham, Vector2.new(innerW, 10000))
				if fit.Y > innerH then table.insert(over, string.format("%d tall %.0f > %d", s.id, fit.Y, innerH)) end
				for word in string.gmatch(text, "%S+") do
					local w = TextService:GetTextSize(word, size, Enum.Font.Gotham, Vector2.new(10000, 10000)).X
					if w > innerW then table.insert(over, string.format("%d word %s %.0f > %d", s.id, word, w, innerW)) end
				end
			end
		end
		check("every stamp cell name fits its cell at GRID_TEXT (wrapped height and every single word, measured with TextService)", #over == 0, table.concat(over, "; "))
	end
	local vol = tonumber(string.match(src, "STAMP_VOLUME%s*=%s*([%d%.]+)")) or 0
	check("PassportClient makes a quiet client-side StampSound (rbxassetid, STAMP_VOLUME 0 < v <= 0.4)",
		string.find(src, "\"StampSound\"", 1, true) ~= nil and string.find(src, "STAMP_SOUND_ID = \"rbxassetid://", 1, true) ~= nil and vol > 0 and vol <= 0.4, tostring(vol))
	check("PassportClient plays the stamp sound only when not muted", string.find(src, "if gotNew and not muted then", 1, true) ~= nil
		and string.find(src, "stampSound:Play()", 1, true) ~= nil)
	local pop = tonumber(string.match(src, "POP_SCALE%s*=%s*([%d%.]+)")) or 0
	check("PassportClient pops the counter on a new stamp (UIScale, POP_SCALE 1.05..1.3)",
		string.find(src, "UIScale", 1, true) ~= nil and pop >= 1.05 and pop <= 1.3, tostring(pop))
end
do
	local lamp = game:GetService("ServerScriptService"):FindFirstChild("LampGlow")
	check("ServerScriptService.LampGlow exists and is a Script", lamp ~= nil and lamp:IsA("Script") and not lamp:IsA("LocalScript"))
	if lamp then
		local src = sourceOf(lamp)
		local names = { "LampGlobe", "LampHead", "PoleLamp", "StreetLampHead", "CornerLampGlobe", "CarParkLamp", "LightHead" }
		local missing = {}
		for _, n in ipairs(names) do
			if string.find(src, "\"" .. n .. "\"", 1, true) == nil then table.insert(missing, n) end
		end
		check("LampGlow matches the seven lamp head names and not the architectural Lanterns", #missing == 0 and string.find(src, "Lantern", 1, true) == nil, table.concat(missing, ","))
		local br = tonumber(string.match(src, "BRIGHTNESS%s*=%s*([%d%.]+)")) or 99
		local range = tonumber(string.match(src, "RANGE%s*=%s*([%d%.]+)")) or 99
		local cap = tonumber(string.match(src, "MAX_LIGHTS%s*=%s*(%d+)")) or 9999
		check("LampGlow lights are soft PointLights without shadows (Brightness <= 1.5, Range <= 16, Shadows = false)",
			string.find(src, "\"PointLight\"", 1, true) ~= nil and br > 0 and br <= 1.5 and range > 0 and range <= 16 and string.find(src, "Shadows = false", 1, true) ~= nil,
			string.format("br %s range %s", tostring(br), tostring(range)))
		check("LampGlow caps its lights (MAX_LIGHTS <= 300), skips heads that already hold a Light and follows rebuilt sites (DescendantAdded)",
			cap <= 300 and string.find(src, "FindFirstChildWhichIsA(\"Light\")", 1, true) ~= nil and string.find(src, "DescendantAdded", 1, true) ~= nil, tostring(cap))
	end
end
local shared = game.ReplicatedStorage:FindFirstChild("LipaShared")
check("GuidanceLogic lives in LipaShared", shared ~= nil and shared:FindFirstChild("GuidanceLogic") ~= nil)
check("CertificateLogic and CreditsData live in LipaShared",
	shared ~= nil and shared:FindFirstChild("CertificateLogic") ~= nil and shared:FindFirstChild("CreditsData") ~= nil)

return HttpService:JSONEncode(results)
