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
