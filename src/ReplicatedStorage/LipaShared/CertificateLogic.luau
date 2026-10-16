-- CertificateLogic: pure data for the 9/9 passport certificate (no Instances). The client draws it; the date is added there.
-- cleanName makes a Roblox display name safe to print; build returns nil unless the passport state is genuinely complete.
local PassportLogic = require(game:GetService("ReplicatedStorage"):WaitForChild("LipaShared"):WaitForChild("PassportLogic"))

local CertificateLogic = {}

local FALLBACK_NAME = "Traveler"
local MAX_NAME_CHARS = 40
local TITLE = "Lipa Passport Complete"

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

local function isRealPassport(state)
	if type(state) ~= "table" or type(state.valid) ~= "table" or type(state.stamped) ~= "table"
		or type(state.n) ~= "number" or type(state.total) ~= "number" then
		return false
	end
	if state.total ~= 9 or not PassportLogic.isComplete(state) then
		return false
	end
	for id = 1, 9 do
		if not PassportLogic.has(state, id) then
			return false
		end
	end
	return true
end

-- build(state, displayName, sites): { title, player, places, count } at 9/9, else nil. `sites` is SiteData.sites.
function CertificateLogic.build(state, displayName, sites)
	if not isRealPassport(state) or type(sites) ~= "table" or #sites ~= 9 then
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
