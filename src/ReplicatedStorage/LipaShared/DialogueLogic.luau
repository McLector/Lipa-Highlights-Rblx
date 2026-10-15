-- DialogueLogic: pure paging state machine for a guide's lines (no Instances).
local DialogueLogic = {}

function DialogueLogic.new(lines)
	if type(lines) ~= "table" or #lines == 0 then
		error("DialogueLogic.new: lines must be a non-empty array", 2)
	end
	local copy = {}
	for i, line in ipairs(lines) do
		if type(line) ~= "string" or #line == 0 then
			error("DialogueLogic.new: line " .. i .. " must be a non-empty string", 2)
		end
		copy[i] = line
	end
	return { lines = copy, i = 1, open = true }
end

function DialogueLogic.isOpen(state)
	return state.open
end

function DialogueLogic.index(state)
	return state.i
end

-- The current line, or nil once the dialogue has closed.
function DialogueLogic.current(state)
	if not state.open then
		return nil
	end
	return state.lines[state.i]
end

-- Advances one line; past the last line the dialogue closes.
function DialogueLogic.next(state)
	if not state.open then
		return
	end
	if state.i >= #state.lines then
		state.open = false
	else
		state.i += 1
	end
end

function DialogueLogic.prev(state)
	if state.open and state.i > 1 then
		state.i -= 1
	end
end

function DialogueLogic.restart(state)
	state.i = 1
	state.open = true
end

return DialogueLogic
