-- TourContent: the written content of the Lipa Tour v2 (site blurbs, trivia, quizzes, NPC dialogue, glossary, wrap-up).
-- Data only: nothing reads it yet. The owner approves the wording (content/tour_content_changes.md) before any script uses it.
-- content/tour_content.md is the readable copy; tests/tour_content_crosscheck.ps1 keeps the two in step.
-- The quiz answer index is NEVER stored here; it lives in ServerStorage.LipaServer.QuizKey so clients cannot read it.
-- Shape of one site (ids 1..10; 10 is New Lipa City Hall):
--   { id, headline, blurb, trivia = { 3 strings }, quiz = { question, options = { 3 strings }, right, wrong, pdfRef },
--     npc = { name, role }, firstTalk = { 2..3 lines }, talkAgain = { >= 1 lines }, goodbye, lookAt, displayProps = { >= 1 strings } }
-- Format rule for the disk cross-check: one field per line, double-quoted strings, \" is the only escape.
local TourContent = {}

TourContent.sites = {
	{
		id = 1,
		headline = "Lipa's historic heart: the Cathedral and its plaza",
		blurb = "Plaza Independencia and the cathedral connect religious life, public gatherings and the city's historic center.",
		trivia = {
			"The parish was founded by the Augustinians in 1605.",
			"The town moved to its present site after the 1754 eruption of Taal Volcano.",
			"The church was heavily damaged in 1944 and rebuilt by 1957, and its octagonal bell tower went from five to seven floors.",
		},
		quiz = {
			question = "Which religious order founded the cathedral's parish in 1605?",
			options = {
				"The Franciscans",
				"The Augustinians",
				"The Dominicans",
			},
			right = "Yes! The Augustinians founded this parish in 1605.",
			wrong = "Not quite. Check the first Did you know fact about this stop.",
			pdfRef = 16,
		},
		npc = { name = "Lola Cora", role = "Parishioner" },
		firstTalk = {
			"Oh, hello, anak! That means child, said with affection.",
			"That's the Cathedral of San Sebastian, and I've been coming here since I was a little girl.",
			"The parish goes all the way back to 1605, older than all of us, haha.",
		},
		talkAgain = {
			"Down the steps from this forecourt is Plaza Independencia, where the city gathers for events.",
			"The cathedral is the seat of the Archdiocese of Lipa.",
			"It got badly damaged in the war in 1944, but they rebuilt it by 1957.",
		},
		goodbye = "Ingat ka, anak. Take care, ha?",
		lookAt = "Look at the octagonal bell tower and count its tiers as they narrow up to the cupola, a clear form. Then look across the open space of the plaza below the steps.",
		displayProps = {
			"plaza benches and trees",
			"cathedral facade with its dome",
			"octagonal bell tower",
			"people at public activities",
		},
	},
	{
		id = 2,
		headline = "The Palengke: where everyday Lipa shops, sells, and chats.",
		blurb = "The palengke shows everyday Lipa through food vendors, produce, coffee, local delicacies and small businesses.",
		trivia = {
			"In 1914, the government's public works bureau praised Lipa's market as possibly the most complete provincial market in the country.",
			"That market had three main buildings.",
			"That market cost 61,000 pesos to build.",
		},
		quiz = {
			question = "How much did Lipa's market cost to build?",
			options = {
				"61,000 pesos",
				"6,100 pesos",
				"610,000 pesos",
			},
			right = "Yes! The market cost 61,000 pesos to build, with three main buildings.",
			wrong = "Not quite. Think about the cost of three main buildings, then try again.",
			pdfRef = 15,
		},
		npc = { name = "Aling Nena", role = "Market vendor" },
		firstTalk = {
			"Halika, halika! That means come, come, so look around.",
			"This is the Lipa City Public Market, the palengke where Lipa shops for produce, food, and daily needs.",
			"'Suki' means regular customer. Buy from me twice and you're officially suki na.",
		},
		talkAgain = {
			"Fresh veggies, fish, coffee, sweets... if Lipa eats it, it's here.",
			"Don't be shy to haggle. Just say tawad po, which means can I get a discount?",
			"Our model follows a plan drawing and recent street photos, so some details may differ.",
		},
		goodbye = "Balik ka ha, come back, okay? I'll save you the good mangoes.",
		lookAt = "Look at the rounded arches repeating along the top floor in a steady rhythm. Count the arches, and notice how the two stairs climb toward the middle.",
		displayProps = {
			"market stalls",
			"baskets",
			"fresh produce",
			"price signs",
			"coffee and delicacies",
			"vendor figures",
		},
	},
	{
		id = 3,
		headline = "Lomi: Lipa's thick, hearty noodle soup.",
		blurb = "A visit to a lomihan introduces local cooking and the social side of sharing a meal.",
		trivia = {
			"Local historians credit Lipa lomi to To Kim Eng, a Chinese immigrant who opened Lipa Panciteria with his wife Natalia in 1968.",
			"The name probably comes from the Hokkien noodle dish 'lor mee'.",
			"Diners often add soy sauce, kalamansi, and chili.",
		},
		quiz = {
			question = "Which immigrant do local historians credit with Lipa lomi?",
			options = {
				"Natalia",
				"Lor Mee",
				"To Kim Eng",
			},
			right = "Yes! Local historians credit To Kim Eng, who opened Lipa Panciteria in 1968.",
			wrong = "Not quite. Think about the immigrant who opened the panciteria with his wife.",
			pdfRef = 7,
		},
		npc = { name = "Kuya Ben", role = "Lomi cook" },
		firstTalk = {
			"Uy, customer! Kain tayo, which means let's eat.",
			"This is Lomi King, one of Lipa's lomi houses.",
			"You have to try our lomi. Thick noodles, thick soup, and lots of toppings.",
		},
		talkAgain = {
			"Kikiam, liver, meatballs... it's basically a whole meal in one bowl.",
			"Historians credit To Kim Eng, but that is an attribution, not a fully documented fact.",
			"Our model follows a 2026 Street View image and a drawn board, so details may differ.",
		},
		goodbye = "Busog ka na, which means are you full already? Go get coffee next.",
		lookAt = "Look at the bold orange sign band above the entrance, where the color pulls your eye to the name. Then find the bamboo texture of the screen beside the closed bay.",
		displayProps = {
			"lomihan counter",
			"big wok",
			"steaming bowls of lomi",
			"condiment tray (toyo, kalamansi, sili)",
			"menu board",
			"long shared tables",
		},
	},
	{
		id = 4,
		headline = "Kapeng Barako: strong, bold coffee with a long history in Lipa.",
		blurb = "Coffee connects Lipa's agricultural heritage with its present cafe culture.",
		trivia = {
			"Coffee made Lipa one of the richest towns in the country.",
			"On October 21, 1887, Lipa was elevated to 'Villa de Lipa'.",
			"The boom ended in the 1890s when pests and a leaf blight (likely coffee rust) killed most plantations.",
		},
		quiz = {
			question = "When did Spanish friars introduce coffee in Lipa?",
			options = {
				"In the 1840s",
				"In the 1740s",
				"In the 1940s",
			},
			right = "Yes! Spanish friars introduced coffee in Lipa in the 1740s.",
			wrong = "Not quite. Think about how long before the coffee boom of the 1800s the friars arrived.",
			pdfRef = 12,
		},
		npc = { name = "Mika", role = "Barista" },
		firstTalk = {
			"Hey, welcome in! You look like you need coffee.",
			"This is Cafe de Lipa, linked to kapeng barako, a Liberica coffee known for its strong flavor.",
			"Coffee links Lipa's farming past with today's cafe culture.",
		},
		talkAgain = {
			"Ever tried kapeng barako? It's strong, like wake-you-up-for-two-days strong.",
			"Spanish friars introduced coffee in Lipa in the 1740s.",
			"This model shows the Tibig/STAR branch, and its interior is a representative display.",
		},
		goodbye = "Want it black? Brave choice.",
		lookAt = "Look at the dark fascia line above the glass storefront, where the warm light spills onto the outdoor seating. Then notice the slatted texture of the red chairs.",
		displayProps = {
			"coffee beans",
			"coffee sacks",
			"coffee packaging",
			"brewing equipment",
			"cafe counter",
			"coffee boom history wall",
		},
	},
	{
		id = 5,
		headline = "A place of prayer and pilgrimage since 1946.",
		blurb = "Founded on May 31, 1946, the Carmelite monastery became an important place of prayer in Lipa.",
		trivia = {
			"The monastery was founded by Bishop Alfredo Verzosa with seven sisters from Manila Carmel.",
			"Its patroness is Mary, Mediatrix of All Grace.",
			"The Vatican has not approved the 1948 apparitions that were reported here.",
		},
		quiz = {
			question = "In what year was the Carmelite monastery founded?",
			options = {
				"1948",
				"1951",
				"1946",
			},
			right = "Yes. The monastery was founded on May 31, 1946.",
			wrong = "Not quite. Think about the year just after World War II ended.",
			pdfRef = 23,
		},
		npc = { name = "Ate Liza", role = "Chapel volunteer" },
		firstTalk = {
			"Hi, I'm a volunteer guide and a pilgrim, not a nun. This is the Monastery of Our Lady of Mount Carmel in Lipa, a Carmelite community founded on May 31, 1946.",
			"In 1948, Teresita Castillo reported apparitions of Mary here, drawing pilgrims to Lipa.",
		},
		talkAgain = {
			"Did you know? The monastery was founded less than a year after World War II ended.",
			"The Church's 1951 ruling called the events not supernatural, and the Vatican reaffirmed that ruling in 2015.",
			"Many people here believe in these reported events, though the Vatican has not approved them.",
		},
		goodbye = "Thanks for dropping by. Ingat po, take care.",
		lookAt = "Look at the large center arch of the portico, which gives the front its emphasis, and then at the open space of the forecourt below the steps.",
		displayProps = {
			"monastery chapel replica",
			"prayer space",
			"devotional items",
			"historical pilgrimage panels",
		},
	},
	{
		id = 6,
		headline = "Shop, eat, and play at Batangas' outdoor lifestyle mall.",
		blurb = "Contemporary shopping, dining, recreation, and the city's link to a growing industrial economy.",
		trivia = {
			"The Outlets at LIMA Estate was formerly The Outlets at Lipa and was rebranded in March 2025.",
			"LIMA Estate covers about 1,000 hectares and hosts 186 companies with over 75,000 employees.",
			"Besides the Aboitiz Pitch, it has pickleball and basketball courts and hosts Car-Free Sundays.",
		},
		quiz = {
			question = "In what year was The Outlets at Lipa rebranded as The Outlets at LIMA Estate?",
			options = {
				"2025",
				"2019",
				"2021",
			},
			right = "Yes! The Outlets were rebranded in March 2025.",
			wrong = "Not quite. Think about the most recent year the name changed.",
			pdfRef = 18,
		},
		npc = { name = "Paolo", role = "Football player" },
		firstTalk = {
			"Yo! You here to shop or to play?",
			"This is The Outlets at LIMA Estate. It used to be called The Outlets at Lipa.",
			"That big field is the Aboitiz Pitch, and we play football there on weekends.",
		},
		talkAgain = {
			"It's an outdoor mall, so bring an umbrella or sunscreen, depending on the sky.",
			"LIMA Estate is huge, like around 1,000 hectares, and it spans Lipa and Malvar.",
			"Car-Free Sundays are the best. No cars, just bikes, runners, and a lot of dogs.",
		},
		goodbye = "Tara, one game? Okay, next time!",
		lookAt = "Look at the shape of the orange shop block against the white walls and dark glass. Then follow the canopy along the covered walkway to the slatted sign by the road.",
		displayProps = {
			"outdoor shopping street",
			"sports field",
			"small model of the estate",
		},
	},
	{
		id = 7,
		headline = "Slow down and recharge at one of Lipa's wellness retreats.",
		blurb = "This operating resort represents Lipa's contemporary wellness tourism, with gardens, accommodation, dining, and organized activities.",
		trivia = {
			"The property covers 52 hectares and has a 300-year-old mango tree.",
			"It has a labyrinth for walking meditation and gardens with resident peacocks.",
			"Visits involve bookings or paid services.",
		},
		quiz = {
			question = "How many hectares does The Farm at San Benito cover?",
			options = {
				"25 hectares",
				"520 hectares",
				"52 hectares",
			},
			right = "Yes! The property covers 52 hectares.",
			wrong = "Not quite. Think about the size of the property, measured in hectares.",
			pdfRef = 19,
		},
		npc = { name = "Ms. Grace", role = "Resort staff" },
		firstTalk = {
			"Welcome to The Farm. Breathe in and out, it feels better already, right?",
			"We have a mango tree here that's about 300 years old. Say hi, it's seen a lot.",
			"There's a labyrinth you can walk for meditation, and nobody's gotten lost yet.",
		},
		talkAgain = {
			"Watch out for the peacocks. They act like they own the place, and honestly, they kinda do.",
			"Take a slow walk through the gardens, and mind the peacocks.",
		},
		goodbye = "Take your time. Nobody rushes here.",
		lookAt = "Look at the round thatched pavilion beside the straight-edged villa, where its curve contrasts with the flat walls. Then follow the patterned path to see where it leads you.",
		displayProps = {
			"gardens",
			"labyrinth",
			"300-year-old mango tree",
			"resident peacocks",
		},
	},
	{
		id = 8,
		headline = "Golf with a mountain view at Mount Malarayat.",
		blurb = "A present-day recreation and hospitality destination tied to Lipa's mountain setting.",
		trivia = {
			"It is Lipa's first private golf course.",
			"It is a 27-hole course about 1,200 ft above sea level.",
			"'Dagatan' comes from 'Dagat-Dagatan,' a small basin that fills with water when it rains.",
		},
		quiz = {
			question = "How many holes does the Mount Malarayat course have?",
			options = {
				"18",
				"27",
				"36",
			},
			right = "Yes! The course has 27 holes.",
			wrong = "Not quite. Think about the number of holes on this club's course.",
			pdfRef = 22,
		},
		npc = { name = "Jun", role = "Caddie" },
		firstTalk = {
			"Hey there! Ready to swing?",
			"I'll carry the bag, you do the hard part.",
			"This is Mount Malarayat, the first private golf course in Lipa.",
		},
		talkAgain = {
			"There are 27 holes, and we're about 1,200 feet up. That's why the air's nice and cool.",
			"If you miss the shot, don't worry. I won't tell anyone.",
			"Access depends on the service or booking.",
		},
		goodbye = "Fore! Haha, kidding, enjoy the view.",
		lookAt = "Look at the big roof on the clubhouse, then find the smaller entry gable and the wing roof. Their red-brown color stands out against the green lawn.",
		displayProps = {
			"27-hole golf course",
			"clubhouse",
			"mountain view",
			"hotel and leisure facilities",
		},
	},
	{
		id = 9,
		headline = "Tagbakin: Lipa's lakeside spot, where the city first began.",
		blurb = "Tagbakin, in Barangay Halang, introduces Lipa's lakeside identity.",
		trivia = {
			"Tawilis is found only in Taal Lake.",
			"Tawilis has been listed as endangered by the IUCN since 2018.",
			"Fishing for tawilis is banned every March 1 to April 30, its peak spawning season.",
		},
		quiz = {
			question = "Since what year has the IUCN listed tawilis as endangered?",
			options = {
				"2018",
				"2010",
				"2023",
			},
			right = "Yes! The IUCN has listed tawilis as endangered since 2018.",
			wrong = "Not quite. Think about the year the tawilis listing began.",
			pdfRef = 25,
		},
		npc = { name = "Mang Tonyo", role = "Fisherman" },
		firstTalk = {
			"Ay, a visitor! Come, come.",
			"The lake's calm today.",
			"This is Tagbakin, in Barangay Halang, on Lipa's lakeside.",
		},
		talkAgain = {
			"We catch tawilis here. Small fish, big flavor.",
			"Oh, but we don't fish them in March and April. They're endangered, so we let them spawn.",
		},
		goodbye = "Watch your step, the rocks are slippery. Ingat!",
		lookAt = "Look along the dock and count the posts that repeat. Then find the volcano beyond the water and the windows on the lakeside building.",
		displayProps = {
			"lakeside scene",
			"fishing boats",
			"shoreline activities",
			"tawilis fish",
		},
	},
	{
		id = 10,
		headline = "Welcome to Lipa! This is the New Lipa City Hall.",
		blurb = "Lipa's new seat of local government, inaugurated April 8, 2026, sits inside Ayala Land's 92-hectare Areza estate, with open lobbies, gardens and shaded walkways.",
		trivia = {
			"The real building has 72 elevated blocks, one for each of Lipa's 72 barangays.",
			"Designed by architect Royal Pineda, whose stated goal was to bring back the land to the people.",
			"It was the first locator in Areza, built on a 5-hectare site.",
		},
		quiz = {
			question = "What do the 72 elevated blocks at the New Lipa City Hall stand for?",
			options = {
				"72 hectares of the Areza estate",
				"The 72 barangays of Lipa",
				"72 years of Lipa's history",
			},
			right = "Yes! The 72 elevated blocks stand for Lipa's 72 barangays, one for each.",
			wrong = "Not quite. Think about what Lipa has 72 of.",
			pdfRef = 2,
		},
		npc = { name = "Ate Joy", role = "City tourism guide" },
		firstTalk = {
			"Hiii, welcome to Lipa! I'm Joy, your tour guide for today.",
			"The real building has 72 elevated blocks, one for every barangay, which is like a neighborhood.",
			"Oh, fun fact: 'Lipa' is actually the name of a tree with stinging twigs. Don't touch it, okay?",
		},
		talkAgain = {
			"First time in Batangas? Ala eh, that's how we say oh wow here, and you'll hear it a lot.",
			"Hop on the jeepney outside! When you want to get off, just say 'para po,' which means stop, please.",
			"Where should you go first? Food, always food first, so let's get you some lomi.",
			"A barangay's like a neighborhood. So yeah, we've got a lot of neighbors.",
		},
		goodbye = "Balik ka ha! That means come back, okay?",
		lookAt = "Look at the shape of the huge faceted canopy on its tall round columns. Then follow the white brick boxes stepping along the wing in a steady rhythm.",
		displayProps = {
			"white brick boxes and atrium canopy",
			"pocket gardens",
			"open lobby",
			"front plaza with welcome billboard and tour map",
			"jeepney stop",
		},
	},
}
TourContent.cityHallFacts = {
	"Lipa became a chartered city on June 20, 1947, under Republic Act No 162, and was inaugurated as a city on August 31, 1947.",
	"Lipa has 72 barangays and a population of 387,392 in the 2024 census.",
	"The city is named after the lipa tree (Dendrocnide meyeniana), a native tree known for its stinging twigs.",
	"The city motto is Virtud y Trabajo, meaning Virtue and Work, and Jose Rizal dedicated his Himno al Trabajo to the people of Lipa in 1888.",
	"Lipa's city fiesta honors its patron, Saint Sebastian, every January 20.",
	"The New Lipa City Hall was inaugurated on April 8, 2026, inside Ayala Land's 92-hectare Areza estate.",
	"The City Hall has about 23,000 square meters of floor area and a 2,160 square meter plaza.",
	"It was the first locator in Areza, built on a 5-hectare site.",
}
TourContent.jeepLines = {
	"Sakay na! That means hop on, so come on in.",
	"Saan po tayo? That means where are we going?",
	"We're here! When you want to get off, say para po, which means stop, please.",
	"Hold on tight, the road has a few bumps! Enjoy the golden hour view from your seat.",
	"Ingat po! That means take care, so see you at the next stop.",
}
TourContent.glossary = {
	{ term = "Ala eh!", meaning = "Batangueno for Oh wow! or Exactly!" },
	{ term = "Kain tayo", meaning = "Let's eat" },
	{ term = "Tara", meaning = "Let's go" },
	{ term = "Para po", meaning = "Stop, please, said to the jeepney driver" },
	{ term = "Suki", meaning = "Regular customer" },
	{ term = "Tawad po?", meaning = "Can I get a discount?" },
	{ term = "Busog", meaning = "Full" },
	{ term = "Anak", meaning = "Child, said with affection" },
	{ term = "Ingat", meaning = "Take care" },
	{ term = "Balik ka ha!", meaning = "Come back, okay?" },
	{ term = "po", meaning = "Polite word" },
	{ term = "lomihan", meaning = "A lomi house, such as Lomi King" },
	{ term = "palengke", meaning = "Public market, where everyday Lipa shops, sells, and chats" },
	{ term = "barangay", meaning = "A neighborhood (Lipa has 72 barangays)" },
}
TourContent.wrapUp = {
	text = "So, full, caffeinated, and a little sun-kissed? Perfect, that's the full Lipa experience.",
	reflection = "Balik ka ha! Which of Eat, Pray or Love do you usually stop at, and which one will you try next time?",
}

local SITE_COUNT = 10
local CARMEL_ID = 5 -- Monastery of Our Lady of Mount Carmel, see SiteData
local MAX_BLURB_WORDS = 25
local MAX_PDF_REF = 25
local MAX_LINE_SENTENCES = 2
local ELEMENT_WORDS = { "line", "shape", "form", "color", "texture", "space", "rhythm", "emphasis" }
local FORBIDDEN_QUIZ_KEYS = { answer = true, correct = true, key = true, index = true }

local function add(errs, message)
	table.insert(errs, message)
end

local function countWords(s)
	local n = 0
	for _ in string.gmatch(s, "%S+") do n += 1 end
	return n
end

-- Counts . ! ? that end a sentence (followed by a space or the end of the text); a run like "?!" or "..." counts once.
local function countSentences(s)
	local n = 0
	for i = 1, #s do
		local ch = string.sub(s, i, i)
		if string.find(ch, "[%.!%?]") then
			local nextCh = string.sub(s, i + 1, i + 1)
			if nextCh == "" or string.find(nextCh, "%s") then n += 1 end
		end
	end
	return n
end

local function hasWord(lowerText, word)
	return string.find(lowerText, "%f[%a]" .. word .. "%f[%A]") ~= nil
end

-- True if "confirmed" appears without "not" or "never" earlier in the same text.
local function hasUnqualifiedConfirmed(text)
	local lower = string.lower(text)
	local from = 1
	while true do
		local s, e = string.find(lower, "%f[%a]confirmed%f[%A]", from)
		if not s then return false end
		local before = string.sub(lower, 1, s - 1)
		if not (hasWord(before, "not") or hasWord(before, "never")) then return true end
		from = e + 1
	end
end

-- Walks any value and reports empty strings and anything outside printable ASCII (bytes 32..126).
local function checkStrings(value, path, errs, depth)
	if type(value) == "string" then
		if value == "" then
			add(errs, path .. ": empty string")
		elseif string.find(value, "[^\32-\126]") then
			add(errs, path .. ": not printable ASCII")
		end
	elseif type(value) == "table" and depth < 6 then
		for k, v in pairs(value) do
			local label = type(k) == "number" and ("[" .. k .. "]") or ("." .. tostring(k))
			checkStrings(v, path .. label, errs, depth + 1)
		end
	end
end

local function collectStrings(value, out, depth)
	if type(value) == "string" then
		table.insert(out, value)
	elseif type(value) == "table" and depth < 6 then
		for _, v in pairs(value) do collectStrings(v, out, depth + 1) end
	end
end

local function needString(v, path, errs)
	if type(v) ~= "string" then add(errs, path .. ": missing or not a string") end
end

-- A list of strings with minN..maxN entries. Returns true when it is a usable list.
local function needList(v, path, minN, maxN, errs)
	if type(v) ~= "table" then
		add(errs, path .. ": missing or not a list")
		return false
	end
	if #v < minN or #v > maxN then
		local upper = maxN == math.huge and "any number of" or tostring(maxN) -- %d cannot format math.huge
		add(errs, string.format("%s: needs %s..%s entries, has %d", path, tostring(minN), upper, #v))
	end
	for i, entry in ipairs(v) do
		if type(entry) ~= "string" then add(errs, string.format("%s[%d]: not a string", path, i)) end
	end
	return true
end

local function checkDialogue(line, path, errs)
	if type(line) == "string" and countSentences(line) > MAX_LINE_SENTENCES then
		add(errs, string.format("%s: more than %d sentences", path, MAX_LINE_SENTENCES))
	end
end

local function checkQuiz(quiz, name, errs)
	if type(quiz) ~= "table" then
		add(errs, name .. ".quiz: missing or not a table")
		return
	end
	needString(quiz.question, name .. ".quiz.question", errs)
	needString(quiz.right, name .. ".quiz.right", errs)
	needString(quiz.wrong, name .. ".quiz.wrong", errs)
	if needList(quiz.options, name .. ".quiz.options", 3, 3, errs) then
		local seen = {}
		for _, option in ipairs(quiz.options) do
			if seen[option] then add(errs, name .. ".quiz.options: duplicate option") end
			seen[option] = true
		end
	end
	local ref = quiz.pdfRef
	if type(ref) ~= "number" or ref ~= math.floor(ref) or ref < 1 or ref > MAX_PDF_REF then
		add(errs, string.format("%s.quiz.pdfRef: needs an integer 1..%d, got %s", name, MAX_PDF_REF, tostring(ref)))
	end
	for k in pairs(quiz) do
		if type(k) == "string" and FORBIDDEN_QUIZ_KEYS[string.lower(k)] then
			add(errs, string.format("%s.quiz.%s: the answer must not be stored in TourContent (use QuizKey)", name, k))
		end
	end
end

local function checkCarmel(site, name, errs)
	local talk = {}
	collectStrings(site.firstTalk, talk, 0)
	collectStrings(site.talkAgain, talk, 0)
	if not hasWord(string.lower(table.concat(talk, " ")), "reported") then
		add(errs, name .. ": Carmel firstTalk or talkAgain must say \"reported\"")
	end
	local all = {}
	collectStrings(site, all, 0)
	for _, text in ipairs(all) do
		if hasUnqualifiedConfirmed(text) then
			add(errs, name .. ": Carmel text says \"confirmed\" without \"not\" or \"never\" before it")
			break
		end
	end
end

local function checkSite(site, i, errs)
	local name = "site " .. i
	if type(site) ~= "table" then
		add(errs, name .. ": missing or not a table")
		return
	end
	if site.id ~= i then add(errs, string.format("%s.id: expected %d, got %s", name, i, tostring(site.id))) end
	checkStrings(site, name, errs, 0)

	needString(site.headline, name .. ".headline", errs)
	if type(site.blurb) == "string" then
		if countWords(site.blurb) > MAX_BLURB_WORDS then
			add(errs, string.format("%s.blurb: more than %d words", name, MAX_BLURB_WORDS))
		end
	else
		add(errs, name .. ".blurb: missing or not a string")
	end

	if needList(site.trivia, name .. ".trivia", 3, 3, errs) then
		for n, fact in ipairs(site.trivia) do
			if type(fact) == "string" and countSentences(fact) ~= 1 then
				add(errs, string.format("%s.trivia[%d]: must be exactly one sentence", name, n))
			end
		end
	end

	checkQuiz(site.quiz, name, errs)

	if type(site.npc) == "table" then
		needString(site.npc.name, name .. ".npc.name", errs)
		needString(site.npc.role, name .. ".npc.role", errs)
	else
		add(errs, name .. ".npc: missing or not a table")
	end

	if needList(site.firstTalk, name .. ".firstTalk", 2, 3, errs) then
		for n, line in ipairs(site.firstTalk) do checkDialogue(line, string.format("%s.firstTalk[%d]", name, n), errs) end
	end
	if needList(site.talkAgain, name .. ".talkAgain", 1, math.huge, errs) then
		for n, line in ipairs(site.talkAgain) do checkDialogue(line, string.format("%s.talkAgain[%d]", name, n), errs) end
	end
	needString(site.goodbye, name .. ".goodbye", errs)
	checkDialogue(site.goodbye, name .. ".goodbye", errs)
	needString(site.lookAt, name .. ".lookAt", errs)
	checkDialogue(site.lookAt, name .. ".lookAt", errs)
	needList(site.displayProps, name .. ".displayProps", 1, math.huge, errs)

	if i == CARMEL_ID then checkCarmel(site, name, errs) end
end

local function checkLists(content, errs)
	if needList(content.cityHallFacts, "cityHallFacts", 5, math.huge, errs) then
		for n, line in ipairs(content.cityHallFacts) do checkDialogue(line, "cityHallFacts[" .. n .. "]", errs) end
	end
	if needList(content.jeepLines, "jeepLines", 3, math.huge, errs) then
		for n, line in ipairs(content.jeepLines) do checkDialogue(line, "jeepLines[" .. n .. "]", errs) end
	end
	checkStrings(content.cityHallFacts, "cityHallFacts", errs, 0)
	checkStrings(content.jeepLines, "jeepLines", errs, 0)

	if type(content.glossary) ~= "table" then
		add(errs, "glossary: missing or not a list")
	else
		if #content.glossary < 8 then add(errs, "glossary: needs at least 8 entries, has " .. #content.glossary) end
		for n, entry in ipairs(content.glossary) do
			local path = "glossary[" .. n .. "]"
			if type(entry) == "table" then
				needString(entry.term, path .. ".term", errs)
				needString(entry.meaning, path .. ".meaning", errs)
			else
				add(errs, path .. ": not a table")
			end
		end
		checkStrings(content.glossary, "glossary", errs, 0)
	end

	if type(content.wrapUp) == "table" then
		needString(content.wrapUp.text, "wrapUp.text", errs)
		needString(content.wrapUp.reflection, "wrapUp.reflection", errs)
		checkStrings(content.wrapUp, "wrapUp", errs, 0)
	else
		add(errs, "wrapUp: missing or not a table")
	end
end

local function checkContent(content, errs)
	if type(content) ~= "table" then
		add(errs, "content: not a table")
		return
	end
	if type(content.sites) ~= "table" then
		add(errs, "sites: missing or not a list")
	else
		for i = 1, SITE_COUNT do checkSite(content.sites[i], i, errs) end
		if #content.sites > SITE_COUNT then add(errs, "sites: more than " .. SITE_COUNT .. " entries") end

		-- The lookAt lines together must cover every element of art.
		local lookAll = {}
		for i = 1, SITE_COUNT do
			local site = content.sites[i]
			if type(site) == "table" and type(site.lookAt) == "string" then table.insert(lookAll, site.lookAt) end
		end
		local lookText = string.lower(table.concat(lookAll, " "))
		for _, word in ipairs(ELEMENT_WORDS) do
			if not hasWord(lookText, word) then add(errs, "lookAt: no line mentions the element \"" .. word .. "\"") end
		end
	end
	checkLists(content, errs)
end

-- Returns a list of error messages; an empty list means the content is valid. Never throws.
function TourContent.validate(content)
	local errs = {}
	local ok, err = pcall(checkContent, content, errs)
	if not ok then add(errs, "validate crashed on malformed content: " .. tostring(err)) end
	return errs
end

return TourContent
