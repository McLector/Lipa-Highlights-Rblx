-- music_check: the spec for one background music track for the whole game (professor's feedback), written BEFORE the change.
-- Studio copy: ServerStorage.Checks.music_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.music_check:Clone())      -- returns JSON {passed, failed, failures}
-- SoundService.BackgroundMusic (builders/music.luau) loops "Sunset Chill (Bed Version)" (APM Music, Creator Store, free) under
-- the town ambience, which drops to 0.12. The welcome Start button starts both (audio needs a user gesture) and the HUD
-- "Sound: On/Off" button mutes and restores both.
local HttpService = game:GetService("HttpService")

local MUSIC_ID = "rbxassetid://9046862941" -- Sunset Chill (Bed Version), APMOfficial
local AMBIENT_VOLUME = 0.12

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end
local function sourceOf(inst)
	local ok, src = pcall(function() return inst.Source end)
	return ok and src or ""
end

local SoundService = game:GetService("SoundService")
local music = SoundService:FindFirstChild("BackgroundMusic")
check("SoundService.BackgroundMusic is a Sound", music ~= nil and music:IsA("Sound"))
if music and music:IsA("Sound") then
	check("the music is Sunset Chill (Bed Version) from the Creator Store", music.SoundId == MUSIC_ID, music.SoundId)
	check("the music loops", music.Looped)
	check("the music volume is 0.2 to 0.5", music.Volume >= 0.2 and music.Volume <= 0.5, tostring(music.Volume))
	check("the music is tagged Music=true (and not Ambient)", music:GetAttribute("Music") == true and music:GetAttribute("Ambient") ~= true)
	check("the music does not autoplay (Start begins it after a click)", not music.Playing)
end
local ambient = SoundService:FindFirstChild("AmbientTown")
check("the town ambience is kept", ambient ~= nil and ambient:IsA("Sound"))
if ambient and music then
	check("the ambience sits under the music at 0.12", math.abs(ambient.Volume - AMBIENT_VOLUME) < 0.001 and ambient.Volume < music.Volume,
		tostring(ambient.Volume))
end
local count = 0
for _, s in ipairs(SoundService:GetDescendants()) do
	if s:IsA("Sound") and s:GetAttribute("Music") == true then count += 1 end
end
check("exactly one music track in the game", count == 1, tostring(count))

local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
local welcome = sps and sps:FindFirstChild("WelcomeClient")
local wsrc = welcome and sourceOf(welcome) or ""
check("WelcomeClient's Start button starts the music", string.find(wsrc, "BackgroundMusic", 1, true) ~= nil and string.find(wsrc, ":Play()", 1, true) ~= nil)
local passport = sps and sps:FindFirstChild("PassportClient")
local psrc = passport and sourceOf(passport) or ""
check("PassportClient's Sound button mutes the music too", string.find(psrc, "BackgroundMusic", 1, true) ~= nil and string.find(psrc, "AmbientTown", 1, true) ~= nil)

return HttpService:JSONEncode(results)
