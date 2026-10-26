-- Tests for ServerStorage.LipaServer.QuizKey (server-only quiz answer key).
-- Contract: answers = { [siteId 1..10] = 1..3 }; isCorrect(siteId, choice) is true only when siteId is an integer 1..10 with a
-- stored answer, choice is an integer 1..3 and equals it. Everything else (nil, strings, 0, 4, 2.5, NaN, unknown id) is false
-- and never throws. The "stubbed" tests set answers themselves and restore them; the "real answers" test stays RED until
-- the key is filled in.
return function(t)
	local QuizKey = require(game.ServerStorage.LipaServer.QuizKey:Clone())
	local expect = t.expect

	-- Runs fn with QuizKey.answers replaced by a stub, then restores the real table (even if fn throws).
	local function withAnswers(stub, fn)
		local saved = QuizKey.answers
		QuizKey.answers = stub
		local ok, err = pcall(fn)
		QuizKey.answers = saved
		if not ok then error(err, 0) end
	end

	local NAN = 0 / 0
	local JUNK = { "1", "2", true, false, {}, NAN, math.huge, -math.huge, -1, 0, 4, 11, 2.5, 1.0000001 }

	t.test("stubbed: the stored choice is correct", function()
		withAnswers({ [1] = 2, [10] = 3 }, function()
			expect.equal(QuizKey.isCorrect(1, 2), true)
			expect.equal(QuizKey.isCorrect(10, 3), true)
		end)
	end)

	t.test("stubbed: a different valid choice is wrong", function()
		withAnswers({ [1] = 2 }, function()
			expect.equal(QuizKey.isCorrect(1, 1), false)
			expect.equal(QuizKey.isCorrect(1, 3), false)
		end)
	end)

	t.test("stubbed: an unknown or out-of-range site id is wrong", function()
		withAnswers({ [1] = 2 }, function()
			expect.equal(QuizKey.isCorrect(2, 2), false) -- valid id, no stored answer
			expect.equal(QuizKey.isCorrect(0, 2), false)
			expect.equal(QuizKey.isCorrect(11, 2), false)
			expect.equal(QuizKey.isCorrect(-1, 2), false)
		end)
	end)

	t.test("stubbed: ids outside 1..10 are rejected even if present in answers", function()
		withAnswers({ [0] = 1, [11] = 1, [1.5] = 1 }, function()
			expect.equal(QuizKey.isCorrect(0, 1), false)
			expect.equal(QuizKey.isCorrect(11, 1), false)
			expect.equal(QuizKey.isCorrect(1.5, 1), false)
		end)
	end)

	t.test("stubbed: a corrupt stored answer never matches", function()
		withAnswers({ [1] = 5, [2] = 0, [3] = 2.5, [4] = "2" }, function()
			expect.equal(QuizKey.isCorrect(1, 5), false)
			expect.equal(QuizKey.isCorrect(2, 0), false)
			expect.equal(QuizKey.isCorrect(3, 2.5), false)
			expect.equal(QuizKey.isCorrect(4, 2), false)
		end)
	end)

	t.test("stubbed: junk choices are false and do not throw", function()
		withAnswers({ [1] = 2, [2] = 1, [3] = 3 }, function()
			expect.equal(QuizKey.isCorrect(1, nil), false)
			for _, junk in ipairs(JUNK) do
				local ok, result = pcall(QuizKey.isCorrect, 1, junk)
				expect.truthy(ok)
				expect.equal(result, false)
			end
		end)
	end)

	t.test("stubbed: junk site ids are false and do not throw", function()
		withAnswers({ [1] = 2, [2] = 1, [3] = 3 }, function()
			expect.equal(QuizKey.isCorrect(nil, 2), false)
			expect.equal(QuizKey.isCorrect(nil, nil), false)
			for _, junk in ipairs(JUNK) do
				local ok, result = pcall(QuizKey.isCorrect, junk, 2)
				expect.truthy(ok)
				expect.equal(result, false)
			end
		end)
	end)

	t.test("stubbed: a string that looks like the right number is still wrong", function()
		withAnswers({ [1] = 2 }, function()
			expect.equal(QuizKey.isCorrect("1", 2), false)
			expect.equal(QuizKey.isCorrect(1, "2"), false)
		end)
	end)

	t.test("stubbed: an empty or non-table answers table is false and does not throw", function()
		withAnswers({}, function() expect.equal(QuizKey.isCorrect(1, 1), false) end)
		withAnswers("broken", function()
			local ok, result = pcall(QuizKey.isCorrect, 1, 1)
			expect.truthy(ok)
			expect.equal(result, false)
		end)
	end)

	t.test("withAnswers restores the real answers table", function()
		local before = QuizKey.answers
		withAnswers({ [1] = 1 }, function() end)
		expect.truthy(QuizKey.answers == before)
	end)

	t.test("real answers: exactly the keys 1..10, each an integer 1..3", function()
		local count = 0
		for key, value in pairs(QuizKey.answers) do
			count += 1
			expect.truthy(type(key) == "number" and key >= 1 and key <= 10 and key == math.floor(key))
			expect.truthy(type(value) == "number" and value >= 1 and value <= 3 and value == math.floor(value))
		end
		expect.equal(count, 10)
	end)
end
