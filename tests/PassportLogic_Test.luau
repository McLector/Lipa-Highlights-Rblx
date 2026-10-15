-- Tests for ReplicatedStorage.LipaShared.PassportLogic (pure, no Instances).
-- Contract: new(validIds?) -> state (default ids 1..9); stamp(state, id) -> true only when newly added;
-- has / count / list (sorted ascending) / isComplete (true only when every valid id is stamped);
-- sanitize(list, validIds?) -> sorted, de-duplicated list of valid integer ids only.
return function(t)
	local PassportLogic = require(game.ReplicatedStorage.LipaShared.PassportLogic)
	local expect = t.expect

	-- A fresh passport has no stamps and is not complete.
	t.test("new passport is empty", function()
		local p = PassportLogic.new()
		expect.equal(PassportLogic.count(p), 0)
		expect.falsy(PassportLogic.isComplete(p))
		expect.equal(#PassportLogic.list(p), 0)
	end)

	-- Stamping a valid id adds it and reports that it was new.
	t.test("stamp adds the site", function()
		local p = PassportLogic.new()
		expect.equal(PassportLogic.stamp(p, 3), true)
		expect.truthy(PassportLogic.has(p, 3))
		expect.equal(PassportLogic.count(p), 1)
	end)

	-- Stamping the same site again changes nothing and reports false.
	t.test("stamping twice is idempotent", function()
		local p = PassportLogic.new()
		PassportLogic.stamp(p, 4)
		expect.equal(PassportLogic.stamp(p, 4), false)
		expect.equal(PassportLogic.count(p), 1)
	end)

	-- Invalid ids are rejected and leave the state untouched.
	t.test("rejects nil, out-of-range, non-integer and wrong-type ids", function()
		local p = PassportLogic.new()
		local bad = { 0, 10, -1, 3.5, "3", {}, true, math.huge, 0 / 0 }
		for _, id in ipairs(bad) do
			expect.equal(PassportLogic.stamp(p, id), false)
		end
		expect.equal(PassportLogic.stamp(p, nil), false)
		expect.equal(PassportLogic.count(p), 0)
		expect.equal(#PassportLogic.list(p), 0)
	end)

	-- has() on junk is false rather than an error.
	t.test("has is false for junk", function()
		local p = PassportLogic.new()
		expect.equal(PassportLogic.has(p, nil), false)
		expect.equal(PassportLogic.has(p, "1"), false)
		expect.equal(PassportLogic.has(p, 99), false)
	end)

	-- Complete only when all nine are stamped; eight is not enough.
	t.test("complete only at nine", function()
		local p = PassportLogic.new()
		for id = 1, 8 do PassportLogic.stamp(p, id) end
		expect.equal(PassportLogic.count(p), 8)
		expect.falsy(PassportLogic.isComplete(p))
		PassportLogic.stamp(p, 9)
		expect.equal(PassportLogic.count(p), 9)
		expect.truthy(PassportLogic.isComplete(p))
	end)

	-- list() is sorted regardless of stamping order.
	t.test("list is sorted ascending", function()
		local p = PassportLogic.new()
		for _, id in ipairs({ 7, 2, 9, 1 }) do PassportLogic.stamp(p, id) end
		expect.deepEqual(PassportLogic.list(p), { 1, 2, 7, 9 })
	end)

	-- Two passports do not share state.
	t.test("passports are independent", function()
		local a, b = PassportLogic.new(), PassportLogic.new()
		PassportLogic.stamp(a, 1)
		expect.equal(PassportLogic.count(b), 0)
	end)

	-- A custom valid-id set is honoured.
	t.test("custom valid ids", function()
		local p = PassportLogic.new({ 1, 2 })
		expect.equal(PassportLogic.stamp(p, 3), false)
		PassportLogic.stamp(p, 1)
		PassportLogic.stamp(p, 2)
		expect.truthy(PassportLogic.isComplete(p))
	end)

	-- sanitize drops duplicates, foreign ids and non-numbers, and sorts.
	t.test("sanitize strips duplicates and foreign ids", function()
		local out = PassportLogic.sanitize({ 5, 5, 2, 0, 10, "3", 4.5, {}, 9, 2 })
		expect.deepEqual(out, { 2, 5, 9 })
	end)

	-- sanitize of junk input is an empty list, not an error.
	t.test("sanitize of non-table is empty", function()
		expect.deepEqual(PassportLogic.sanitize(nil), {})
		expect.deepEqual(PassportLogic.sanitize("abc"), {})
		expect.deepEqual(PassportLogic.sanitize({}), {})
	end)
end
