-- Tests for ServerStorage.LipaServer.JeepRules (plain Vector3 + injected clock, no Instances).
-- Contract: newContext() -> ctx; check(ctx, destId, playerPos, stops, now) -> { ok, reason, from, to }.
-- stops is a map id -> Vector3 of the JeepStop parts. Order: cooldown (3 s between accepted rides) ->
-- dest must be a whole number that is a key of stops -> player within 20 studs of some stop ->
-- dest ~= the stop the player is at. Reasons: "cooldown", "invalid_dest", "not_at_stop", "same_stop".
return function(t)
	local JeepRules = require(game.ServerStorage.LipaServer.JeepRules)
	local expect = t.expect

	local function stops()
		return {
			[1] = Vector3.new(0, 0, 0),
			[5] = Vector3.new(-300, 0, -600),
			[6] = Vector3.new(550, 0, -650),
			[7] = Vector3.new(700, 0, 240),
			[8] = Vector3.new(560, 20, 720),
			[9] = Vector3.new(-600, 0, 550),
			[10] = Vector3.new(-155, 0, -230),
		}
	end

	-- Positive control: standing at stop 1, riding to stop 5 is allowed and names both ends.
	t.test("rides from one stop to another", function()
		local r = JeepRules.check(JeepRules.newContext(), 5, Vector3.new(5, 0, 5), stops(), 100)
		expect.equal(r.ok, true)
		expect.equal(r.from, 1)
		expect.equal(r.to, 5)
	end)

	-- The 20-stud boundary: at the edge is fine, beyond it is not at a stop.
	t.test("must be within 20 studs of a stop", function()
		local ok = JeepRules.check(JeepRules.newContext(), 5, Vector3.new(20, 0, 0), stops(), 100)
		expect.equal(ok.ok, true)
		local far = JeepRules.check(JeepRules.newContext(), 5, Vector3.new(21, 0, 0), stops(), 100)
		expect.equal(far.ok, false)
		expect.equal(far.reason, "not_at_stop")
	end)

	-- An invalid destination is rejected even when the player is standing at a stop.
	t.test("rejects invalid destinations", function()
		local bad = { 42, 11, 0, 2, 3, 4, -1, 5.5, "5", {}, true }
		for _, id in ipairs(bad) do
			local r = JeepRules.check(JeepRules.newContext(), id, Vector3.new(0, 0, 0), stops(), 100)
			expect.equal(r.ok, false)
			expect.equal(r.reason, "invalid_dest")
		end
		local r = JeepRules.check(JeepRules.newContext(), nil, Vector3.new(0, 0, 0), stops(), 100)
		expect.equal(r.reason, "invalid_dest")
	end)

	-- Riding to the stop you are already at is rejected.
	t.test("rejects riding to the same stop", function()
		local r = JeepRules.check(JeepRules.newContext(), 1, Vector3.new(0, 0, 0), stops(), 100)
		expect.equal(r.ok, false)
		expect.equal(r.reason, "same_stop")
	end)

	-- A player in the middle of nowhere cannot summon a ride.
	t.test("rejects when not at any stop", function()
		local r = JeepRules.check(JeepRules.newContext(), 6, Vector3.new(100, 0, 100), stops(), 100)
		expect.equal(r.ok, false)
		expect.equal(r.reason, "not_at_stop")
	end)

	-- Cooldown: a second accepted ride within 3 s is refused, and allowed from 3 s on.
	t.test("3 second cooldown between rides", function()
		local ctx = JeepRules.newContext()
		expect.equal(JeepRules.check(ctx, 5, Vector3.new(0, 0, 0), stops(), 100).ok, true)
		local early = JeepRules.check(ctx, 1, Vector3.new(-300, 0, -600), stops(), 102.9)
		expect.equal(early.ok, false)
		expect.equal(early.reason, "cooldown")
		local later = JeepRules.check(ctx, 1, Vector3.new(-300, 0, -600), stops(), 103)
		expect.equal(later.ok, true)
		expect.equal(later.to, 1)
	end)

	-- A refused request does not restart the cooldown.
	t.test("rejected requests do not consume the cooldown", function()
		local ctx = JeepRules.newContext()
		JeepRules.check(ctx, 42, Vector3.new(0, 0, 0), stops(), 100) -- invalid, refused
		local r = JeepRules.check(ctx, 5, Vector3.new(0, 0, 0), stops(), 100.1)
		expect.equal(r.ok, true)
	end)

	-- City Hall (10) is a stop; 11 is not, even when standing at stop 10.
	t.test("accepts stop 10 and rejects 11", function()
		local s = stops()
		local ok = JeepRules.check(JeepRules.newContext(), 10, s[1], s, 100)
		expect.equal(ok.ok, true)
		expect.equal(ok.to, 10)
		local from10 = JeepRules.check(JeepRules.newContext(), 1, s[10], s, 100)
		expect.equal(from10.ok, true)
		expect.equal(from10.from, 10)
		local bad = JeepRules.check(JeepRules.newContext(), 11, s[10], s, 100)
		expect.equal(bad.ok, false)
		expect.equal(bad.reason, "invalid_dest")
		local same = JeepRules.check(JeepRules.newContext(), 10, s[10], s, 100)
		expect.equal(same.reason, "same_stop")
	end)

	-- Every outer stop can be reached from the hub, and the hub from every outer stop.
	t.test("hub to every outer stop and back", function()
		local s = stops()
		for _, id in ipairs({ 5, 6, 7, 8, 9, 10 }) do
			local there = JeepRules.check(JeepRules.newContext(), id, s[1], s, 100)
			expect.equal(there.ok, true)
			expect.equal(there.to, id)
			local back = JeepRules.check(JeepRules.newContext(), 1, s[id], s, 100)
			expect.equal(back.ok, true)
			expect.equal(back.from, id)
		end
	end)
end
