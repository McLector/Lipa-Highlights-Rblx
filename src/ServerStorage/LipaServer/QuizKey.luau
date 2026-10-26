-- QuizKey: the server-only answer key for the tour quizzes. Never replicate this module to clients.
-- answers = { [siteId 1..10] = index of the right option, 1..3 }; filled in when the quiz content is written.
local QuizKey = {}

QuizKey.answers = { [1] = 2, [2] = 1, [3] = 3, [4] = 2, [5] = 3, [6] = 1, [7] = 3, [8] = 2, [9] = 1, [10] = 2 }

local function isIntInRange(n, lo, hi)
	return type(n) == "number" and n == math.floor(n) and n >= lo and n <= hi -- NaN fails n == floor(n)
end

-- True only for a known site and a valid choice that matches the stored answer; any other input is simply false.
function QuizKey.isCorrect(siteId, choice)
	if not isIntInRange(siteId, 1, 10) or not isIntInRange(choice, 1, 3) then return false end
	if type(QuizKey.answers) ~= "table" then return false end
	local stored = QuizKey.answers[siteId]
	return stored ~= nil and stored == choice
end

return QuizKey
