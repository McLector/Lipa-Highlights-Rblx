-- StampRules: server-side validation for a stamp request. Pure (plain Vector3s, injected clock).
-- Order: rate limit -> id validity -> guide known -> distance -> stamp.
local PassportLogic = require(game:GetService("ReplicatedStorage").LipaShared.PassportLogic)

local StampRules = {}

StampRules.MIN_INTERVAL = 0.5
StampRules.MAX_DISTANCE = 25

function StampRules.newContext()
	return { passport = PassportLogic.new(), lastAt = nil }
end

local function result(ctx, ok, reason, isNew)
	return { ok = ok, reason = reason, new = isNew == true, stamps = PassportLogic.list(ctx.passport) }
end

function StampRules.check(ctx, siteId, playerPos, guidePos, now)
	if ctx.lastAt ~= nil and now - ctx.lastAt < StampRules.MIN_INTERVAL then
		return result(ctx, false, "rate_limited")
	end
	ctx.lastAt = now
	if not PassportLogic.isValid(ctx.passport, siteId) then
		return result(ctx, false, "invalid_id")
	end
	if guidePos == nil or playerPos == nil then
		return result(ctx, false, "no_guide")
	end
	if (playerPos - guidePos).Magnitude > StampRules.MAX_DISTANCE then
		return result(ctx, false, "too_far")
	end
	local isNew = PassportLogic.stamp(ctx.passport, siteId)
	return result(ctx, true, nil, isNew)
end

return StampRules
