-- CertificateLogic: pure data for the 10/10 passport certificate (no Instances). The client draws it; the date is added there.
-- cleanName makes a Roblox display name safe to print; build returns nil unless the passport state is genuinely complete.
local PassportLogic = require(game:GetService("ReplicatedStorage"):WaitForChild("LipaShared"):WaitForChild("PassportLogic"))

local CertificateLogic = {}

local FALLBACK_NAME = "Traveler"
local MAX_NAME_CHARS = 40
local TITLE = "Lipa Passport Complete"
local TOTAL_SITES = 10 -- the nine town sites plus New Lipa City Hall; PassportLogic derives its ids from SiteData and must agree

-- Trimmed, control-free display name of at most 40 UTF-8 characters, cut on a character boundary.
function CertificateLogic.cleanName(raw)
	if type(raw) ~= "string" or not utf8.len(raw) then
		return FALLBACK_NAME
	end
	local s = string.gsub(raw, "[\0-\31\127]", "")
	s = string.match(s, "^%s*(.-)%s*$")
	if utf8.len(s) > MAX_NAME_CHARS then
		s = string.sub(s, 1, utf8.offset(s, MAX_NAME_CHARS + 1) - 1)
		s = string.match(s, "^%s*(.-)%s*$")
	end
	if s == "" then
		return FALLBACK_NAME
	end
	return s
end

-- layout(w, h): grid columns for the certificate. Portrait (taller than wide) gets 2 so long names stay readable;
-- landscape and square get 3. Anything that is not a positive finite pair of numbers gets the safe default (3).
local function positiveFinite(n)
	return type(n) == "number" and n == n and n > 0 and n < math.huge
end

function CertificateLogic.layout(w, h)
	if positiveFinite(w) and positiveFinite(h) and h > w then
		return { columns = 2 }
	end
	return { columns = 3 }
end

-- cellRects(w, h, count, columns, places): geometry for the certificate's places area (w x h pixels), pure and unit-tested.
-- The LAST place (count, the Welcome site: City Hall) is a full-width row on top; places 1..count-1 fill `columns` columns below it,
-- left to right, top to bottom. `columns` falls back to layout(w, h).columns when it is not an integer from 1 to 6. `places` is the
-- list of cell strings (cert.places); it sets the longest word and the wrapped line count the text size must survive. The size is
-- an ESTIMATE (CHAR_EM of the font size per character, LINE_EM per line, greedy word wrap): the largest whole size from MAX_TEXT down
-- to MIN_TEXT whose longest word fits one line of a cell and whose wrapped text fits the cell height. `fits` is false when even
-- MIN_TEXT does not. Returns nil for any bad size or count. count is at most MAX_COUNT.
CertificateLogic.CHAR_EM = 0.5 -- Gotham: width of a character in em for the one-line fit of the longest word, rounded up (Independencia measures 0.49)
CertificateLogic.WRAP_EM = 0.46 -- average character width in em for the wrapped-line estimate (whole labels measure 0.44)
CertificateLogic.LINE_EM = 1.2 -- line height in em
CertificateLogic.CELL_PAD = 6 -- total horizontal and vertical padding inside a cell
CertificateLogic.GAP = 6 -- gap between cells
CertificateLogic.MIN_TEXT = 10
CertificateLogic.MAX_TEXT = 20
CertificateLogic.MAX_COUNT = 100
local DEFAULT_LONGEST_LABEL = "1. Plaza Independencia & Metropolitan Cathedral"

local function wrappedLines(label, size, width)
	local lines, used = 1, 0
	local space = CertificateLogic.WRAP_EM * size
	for word in string.gmatch(label, "%S+") do
		local wpx = #word * CertificateLogic.WRAP_EM * size
		if used == 0 then
			used = wpx
		elseif used + space + wpx <= width then
			used += space + wpx
		else
			lines += 1
			used = wpx
		end
	end
	return lines
end

local function longestWordChars(label)
	local m = 0
	for word in string.gmatch(label, "%S+") do
		m = math.max(m, #word)
	end
	return m
end

function CertificateLogic.cellRects(w, h, count, columns, places)
	if not positiveFinite(w) or not positiveFinite(h) or type(count) ~= "number" or count ~= count or count < 1
		or count > CertificateLogic.MAX_COUNT or count ~= math.floor(count) then
		return nil
	end
	if type(columns) ~= "number" or columns ~= math.floor(columns) or columns < 1 or columns > 6 then
		columns = CertificateLogic.layout(w, h).columns
	end
	local labels = {}
	if type(places) == "table" then
		for i = 1, count do
			if type(places[i]) == "string" then
				labels[i] = places[i]
			end
		end
	end
	if next(labels) == nil then
		labels = { DEFAULT_LONGEST_LABEL } -- the default stands in for every cell
	end
	local gap, pad, em, lineEm = CertificateLogic.GAP, CertificateLogic.CELL_PAD, CertificateLogic.CHAR_EM, CertificateLogic.LINE_EM
	local grid = count - 1
	local rows = math.ceil(grid / columns)
	local cellW = (w - (columns - 1) * gap) / columns
	local gridLabels, welcomeLabel = {}, labels[count] or DEFAULT_LONGEST_LABEL
	for i = 1, grid do
		table.insert(gridLabels, labels[i] or DEFAULT_LONGEST_LABEL)
	end
	if #gridLabels == 0 then
		gridLabels = { DEFAULT_LONGEST_LABEL }
	end

	local textSize, fits, welcomeH = CertificateLogic.MIN_TEXT, false, nil
	for size = CertificateLogic.MAX_TEXT, CertificateLogic.MIN_TEXT, -1 do
		local ok = true
		local maxLines = 1
		for _, label in ipairs(gridLabels) do
			if longestWordChars(label) * em * size > cellW - pad then
				ok = false
			end
			maxLines = math.max(maxLines, wrappedLines(label, size, cellW - pad))
		end
		local wLines = wrappedLines(welcomeLabel, size, w - pad)
		if longestWordChars(welcomeLabel) * em * size > w - pad then
			ok = false
		end
		local wH = wLines * size * lineEm + pad
		local needGrid = rows > 0 and (rows * (maxLines * size * lineEm + pad) + (rows - 1) * gap) or 0
		local total = wH + (rows > 0 and (gap + needGrid) or 0)
		if ok and total <= h then
			textSize, fits, welcomeH = size, true, wH
			break
		end
		if size == CertificateLogic.MIN_TEXT then
			textSize = size
		end
	end

	local rects = {}
	if rows == 0 then
		welcomeH = h
	elseif not fits then
		welcomeH = h / (rows + 1) -- squeezed: share the height evenly so the rectangles stay valid
	end
	rects[count] = { x = 0, y = 0, w = w, h = welcomeH }
	if rows > 0 then
		local cellH = math.max((h - welcomeH - rows * gap) / rows, 1)
		for i = 1, grid do
			local col = (i - 1) % columns
			local row = math.floor((i - 1) / columns)
			rects[i] = { x = col * (cellW + gap), y = welcomeH + gap + row * (cellH + gap), w = cellW, h = cellH }
		end
	end
	return { columns = columns, rows = rows, textSize = textSize, fits = fits, welcomeIndex = count, rects = rects }
end

local function isRealPassport(state)
	if type(state) ~= "table" or type(state.valid) ~= "table" or type(state.stamped) ~= "table"
		or type(state.n) ~= "number" or type(state.total) ~= "number" then
		return false
	end
	if state.total ~= TOTAL_SITES or not PassportLogic.isComplete(state) then
		return false
	end
	for id = 1, TOTAL_SITES do
		if not PassportLogic.has(state, id) then
			return false
		end
	end
	return true
end

-- build(state, displayName, sites): { title, player, places, count } at 10/10, else nil. `sites` is SiteData.sites.
function CertificateLogic.build(state, displayName, sites)
	if not isRealPassport(state) or type(sites) ~= "table" or #sites ~= TOTAL_SITES then
		return nil
	end
	local ordered = {}
	for _, s in ipairs(sites) do
		if type(s) ~= "table" or type(s.name) ~= "string" or type(s.id) ~= "number" then
			return nil
		end
		table.insert(ordered, s)
	end
	table.sort(ordered, function(a, b) return a.id < b.id end)
	local places = {}
	for _, s in ipairs(ordered) do
		table.insert(places, s.id .. ". " .. s.name)
	end
	return {
		title = TITLE,
		player = "Awarded to " .. CertificateLogic.cleanName(displayName),
		places = places,
		count = #places,
	}
end

return CertificateLogic
