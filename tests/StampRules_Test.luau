-- Tests for ServerStorage.LipaServer.StampRules (plain Vector3 + injected clock, no Instances).
-- Contract: newContext() -> ctx; check(ctx, siteId, playerPos, guidePos, now) -> { ok, reason, new, stamps }.
-- Order: rate limit (>= 0.5 s between requests, applies to every request) -> id validity -> guide known ->
-- distance <= 25 studs -> stamp. ok=true even when the site was already stamped (new=false).
-- Reasons: "rate_limited", "invalid_id", "no_guide", "too_far".
return function(t)
	local StampRules = require(game.ServerStorage.LipaServer.StampRules)
	local expect = t.expect
	local ORIGIN = Vector3.new(0, 0, 0)

	-- Positive control: a valid request next to the guide stamps the site.
	t.test("stamps when near the guide", function()
		local ctx = StampRules.newContext()
		local r = StampRules.check(ctx, 3, Vector3.new(10, 0, 0), ORIGIN, 100)
		expect.equal(r.ok, true)
		expect.equal(r.new, true)
		expect.deepEqual(r.stamps, { 3 })
	end)

	-- Exactly 25 studs is allowed; just past it is not.
	t.test("distance boundary is 25 studs", function()
		local ok = StampRules.check(StampRules.newContext(), 1, Vector3.new(25, 0, 0), ORIGIN, 100)
		expect.equal(ok.ok, true)
		local far = StampRules.check(StampRules.newContext(), 1, Vector3.new(25.5, 0, 0), ORIGIN, 100)
		expect.equal(far.ok, false)
		expect.equal(far.reason, "too_far")
	end)

	-- A request from 200 studs away is rejected and nothing is stamped.
	t.test("rejects a stamp from 200 studs away", function()
		local ctx = StampRules.newContext()
		local r = StampRules.check(ctx, 2, Vector3.new(200, 0, 0), ORIGIN, 100)
		expect.equal(r.ok, false)
		expect.equal(r.reason, "too_far")
		expect.equal(#r.stamps, 0)
	end)

	-- Fake or malformed ids are rejected with invalid_id and change nothing.
	t.test("rejects fake ids", function()
		local bad = { 0, 10, -3, 2.5, "3", {}, true }
		local now = 100
		for _, id in ipairs(bad) do
			local ctx = StampRules.newContext()
			local r = StampRules.check(ctx, id, ORIGIN, ORIGIN, now)
			expect.equal(r.ok, false)
			expect.equal(r.reason, "invalid_id")
			expect.equal(#r.stamps, 0)
		end
		local r = StampRules.check(StampRules.newContext(), nil, ORIGIN, ORIGIN, now)
		expect.equal(r.reason, "invalid_id")
	end)

	-- A missing guide position (guide not found) is its own reason.
	t.test("rejects when the guide position is unknown", function()
		local r = StampRules.check(StampRules.newContext(), 4, ORIGIN, nil, 100)
		expect.equal(r.ok, false)
		expect.equal(r.reason, "no_guide")
	end)

	-- Twenty different valid sites at the same instant: only the first passes the limiter.
	t.test("rate limit lets exactly one of 20 same-instant requests through", function()
		local ctx = StampRules.newContext()
		local oks, limited = 0, 0
		for i = 1, 20 do
			local site = ((i - 1) % 9) + 1
			local r = StampRules.check(ctx, site, ORIGIN, ORIGIN, 100)
			if r.ok then oks += 1 end
			if r.reason == "rate_limited" then limited += 1 end
		end
		expect.equal(oks, 1)
		expect.equal(limited, 19)
		expect.equal(#StampRules.check(ctx, 1, ORIGIN, ORIGIN, 100).stamps, 1)
	end)

	-- The limiter also throttles invalid requests, so fake-id spam cannot flood the server.
	t.test("rate limit applies to invalid requests too", function()
		local ctx = StampRules.newContext()
		StampRules.check(ctx, 0, ORIGIN, ORIGIN, 100) -- first request passes the limiter
		local r = StampRules.check(ctx, 0, ORIGIN, ORIGIN, 100.1)
		expect.equal(r.reason, "rate_limited")
	end)

	-- Once 0.5 s has passed, the next request is allowed again.
	t.test("rate limit clears after 0.5 seconds", function()
		local ctx = StampRules.newContext()
		expect.equal(StampRules.check(ctx, 1, ORIGIN, ORIGIN, 100).ok, true)
		expect.equal(StampRules.check(ctx, 2, ORIGIN, ORIGIN, 100.49).reason, "rate_limited")
		expect.equal(StampRules.check(ctx, 2, ORIGIN, ORIGIN, 100.5).ok, true)
	end)

	-- Re-stamping a known site is ok but not new, and is still subject to the limiter.
	t.test("repeat stamp is ok but not new", function()
		local ctx = StampRules.newContext()
		StampRules.check(ctx, 5, ORIGIN, ORIGIN, 100)
		local again = StampRules.check(ctx, 5, ORIGIN, ORIGIN, 101)
		expect.equal(again.ok, true)
		expect.equal(again.new, false)
		local rapid = StampRules.check(ctx, 5, ORIGIN, ORIGIN, 101.1)
		expect.equal(rapid.reason, "rate_limited")
	end)

	-- Contexts are per player and do not leak into each other.
	t.test("contexts are independent", function()
		local a, b = StampRules.newContext(), StampRules.newContext()
		StampRules.check(a, 1, ORIGIN, ORIGIN, 100)
		local r = StampRules.check(b, 1, ORIGIN, ORIGIN, 100)
		expect.equal(r.ok, true)
		expect.equal(r.new, true)
	end)
end
