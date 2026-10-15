-- JeepRules: server-side validation for a jeepney ride request. Pure (plain Vector3s, injected clock).
-- `stops` maps site id -> Vector3 of that JeepStop. Order: cooldown -> destination -> at a stop -> not same stop.
local JeepRules = {}

JeepRules.COOLDOWN = 3
JeepRules.STOP_RADIUS = 20

function JeepRules.newContext()
	return { lastAt = nil }
end

local function refuse(reason)
	return { ok = false, reason = reason }
end

function JeepRules.check(ctx, destId, playerPos, stops, now)
	if ctx.lastAt ~= nil and now - ctx.lastAt < JeepRules.COOLDOWN then
		return refuse("cooldown")
	end
	if type(destId) ~= "number" or destId ~= destId or destId % 1 ~= 0 or stops[destId] == nil then
		return refuse("invalid_dest")
	end
	local from, best = nil, JeepRules.STOP_RADIUS
	for id, pos in pairs(stops) do
		local d = (playerPos - pos).Magnitude
		if d <= best then
			from, best = id, d
		end
	end
	if from == nil then
		return refuse("not_at_stop")
	end
	if from == destId then
		return refuse("same_stop")
	end
	ctx.lastAt = now
	return { ok = true, from = from, to = destId }
end

return JeepRules
