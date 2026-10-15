-- Tests for ReplicatedStorage.LipaShared.DialogueLogic (pure paging state machine).
-- Contract: new(lines) throws on nil / non-table / empty / non-string-or-empty lines; starts open at index 1;
-- current() is the line at index (nil once closed); next() advances and closes after the last line;
-- prev() never goes below 1; restart() reopens at index 1; isOpen(); index().
return function(t)
	local DialogueLogic = require(game.ReplicatedStorage.LipaShared.DialogueLogic)
	local expect = t.expect

	-- A new dialogue starts open on its first line.
	t.test("starts open at line 1", function()
		local d = DialogueLogic.new({ "a", "b", "c" })
		expect.truthy(DialogueLogic.isOpen(d))
		expect.equal(DialogueLogic.index(d), 1)
		expect.equal(DialogueLogic.current(d), "a")
	end)

	-- Next walks the lines in order.
	t.test("next advances through the lines", function()
		local d = DialogueLogic.new({ "a", "b", "c" })
		DialogueLogic.next(d)
		expect.equal(DialogueLogic.current(d), "b")
		DialogueLogic.next(d)
		expect.equal(DialogueLogic.current(d), "c")
		expect.truthy(DialogueLogic.isOpen(d))
	end)

	-- Next past the last line closes the dialogue.
	t.test("next past the end closes", function()
		local d = DialogueLogic.new({ "a", "b" })
		DialogueLogic.next(d)
		DialogueLogic.next(d)
		expect.falsy(DialogueLogic.isOpen(d))
		expect.equal(DialogueLogic.current(d), nil)
	end)

	-- Extra next calls on a closed dialogue are harmless.
	t.test("next on a closed dialogue stays closed", function()
		local d = DialogueLogic.new({ "a" })
		DialogueLogic.next(d)
		DialogueLogic.next(d)
		DialogueLogic.next(d)
		expect.falsy(DialogueLogic.isOpen(d))
	end)

	-- The index never drops below 1.
	t.test("prev never goes below 1", function()
		local d = DialogueLogic.new({ "a", "b" })
		DialogueLogic.prev(d)
		DialogueLogic.prev(d)
		expect.equal(DialogueLogic.index(d), 1)
		expect.equal(DialogueLogic.current(d), "a")
	end)

	-- Prev steps back one line.
	t.test("prev steps back", function()
		local d = DialogueLogic.new({ "a", "b", "c" })
		DialogueLogic.next(d)
		DialogueLogic.next(d)
		DialogueLogic.prev(d)
		expect.equal(DialogueLogic.current(d), "b")
	end)

	-- Restart reopens a closed dialogue at the first line.
	t.test("restart resets", function()
		local d = DialogueLogic.new({ "a", "b" })
		DialogueLogic.next(d)
		DialogueLogic.next(d)
		DialogueLogic.restart(d)
		expect.truthy(DialogueLogic.isOpen(d))
		expect.equal(DialogueLogic.index(d), 1)
		expect.equal(DialogueLogic.current(d), "a")
	end)

	-- A single-line dialogue closes after one next.
	t.test("single line dialogue", function()
		local d = DialogueLogic.new({ "only" })
		expect.equal(DialogueLogic.current(d), "only")
		DialogueLogic.next(d)
		expect.falsy(DialogueLogic.isOpen(d))
	end)

	-- Construction rejects unusable input.
	t.test("new throws on nil, empty or malformed lines", function()
		expect.throws(function() DialogueLogic.new(nil) end)
		expect.throws(function() DialogueLogic.new({}) end)
		expect.throws(function() DialogueLogic.new("text") end)
		expect.throws(function() DialogueLogic.new({ "ok", "" }) end)
		expect.throws(function() DialogueLogic.new({ "ok", 5 }) end)
	end)

	-- The state does not alias the caller's table.
	t.test("later edits to the source table do not change the dialogue", function()
		local src = { "a", "b" }
		local d = DialogueLogic.new(src)
		src[1] = "changed"
		expect.equal(DialogueLogic.current(d), "a")
	end)
end
