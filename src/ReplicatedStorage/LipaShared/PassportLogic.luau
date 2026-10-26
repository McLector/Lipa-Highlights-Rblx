-- PassportLogic: pure passport state (no Instances). Ids are whole numbers from a fixed valid set (default: every SiteData id, 1..10).
local SiteData = require(game:GetService("ReplicatedStorage"):WaitForChild("LipaShared"):WaitForChild("SiteData"))

local PassportLogic = {}

local DEFAULT_IDS = {}
for _, s in ipairs(SiteData.sites) do
	table.insert(DEFAULT_IDS, s.id)
end

local function isWhole(id)
	return type(id) == "number" and id == id and id % 1 == 0
end

function PassportLogic.new(validIds)
	local valid, total = {}, 0
	for _, id in ipairs(validIds or DEFAULT_IDS) do
		if isWhole(id) and not valid[id] then
			valid[id] = true
			total += 1
		end
	end
	return { valid = valid, total = total, stamped = {}, n = 0 }
end

-- True when id is a whole number in this passport's valid set.
function PassportLogic.isValid(state, id)
	return isWhole(id) and state.valid[id] == true
end

-- Returns true only when the site was newly stamped.
function PassportLogic.stamp(state, id)
	if not PassportLogic.isValid(state, id) or state.stamped[id] then
		return false
	end
	state.stamped[id] = true
	state.n += 1
	return true
end

function PassportLogic.has(state, id)
	return PassportLogic.isValid(state, id) and state.stamped[id] == true
end

function PassportLogic.count(state)
	return state.n
end

function PassportLogic.list(state)
	local out = {}
	for id in pairs(state.stamped) do
		table.insert(out, id)
	end
	table.sort(out)
	return out
end

function PassportLogic.isComplete(state)
	return state.total > 0 and state.n == state.total
end

-- Sorted, de-duplicated list of the valid whole-number ids in `list`; anything else is dropped.
function PassportLogic.sanitize(list, validIds)
	if type(list) ~= "table" then
		return {}
	end
	local state = PassportLogic.new(validIds)
	for _, id in ipairs(list) do
		PassportLogic.stamp(state, id)
	end
	return PassportLogic.list(state)
end

return PassportLogic
