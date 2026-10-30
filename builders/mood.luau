-- mood: golden late-afternoon light, a light haze and a relaxing music loop. Guarded by tests/filler_check.luau.
-- Why (owner, 2026-10-31): "a nice mood of weather like sunny or sunset" and "a relaxing music"; the haze also fades the far sites.
-- Run via execute_luau (Edit): require(game.ServerStorage.Builders.mood:Clone())()  Idempotent. Touches only Lighting (ClockTime, the
-- Atmosphere, a MoodTint ColorCorrectionEffect) and SoundService.
-- Was: ClockTime 15.5 (set by builders/world.luau, never re-run), Atmosphere Density 0.30, Haze 0, Color (199,199,199), Decay (106,112,125).
-- Music: "Lofi Chill Blue Cat Study and Relaxing" by DistrokidOfficial (Creator Store, free), SoundService.MusicLoop, tagged Music=true so
-- WelcomeClient starts it with the ambient loop and the PassportClient Mute button silences it.
return function()
	local C3 = Color3.fromRGB
	local L = game.Lighting
	L.ClockTime = 17.5

	-- A warm golden tint over everything (the sky and the haze read blue-grey without it).
	local tint = L:FindFirstChild("MoodTint")
	if not tint then
		tint = Instance.new("ColorCorrectionEffect")
		tint.Name = "MoodTint"
		tint.Parent = L
	end
	tint.TintColor = C3(255, 232, 205)
	tint.Saturation = 0.12
	tint.Contrast = 0.05
	tint.Brightness = 0.02

	local atmo = L:FindFirstChildOfClass("Atmosphere")
	if not atmo then
		atmo = Instance.new("Atmosphere")
		atmo.Parent = L
	end
	atmo.Density = 0.42
	atmo.Haze = 1.6
	atmo.Color = C3(236, 206, 176)
	atmo.Decay = C3(186, 132, 104)

	local SoundService = game:GetService("SoundService")
	local music = SoundService:FindFirstChild("MusicLoop")
	if not music then
		music = Instance.new("Sound")
		music.Name = "MusicLoop"
		music.Parent = SoundService
	end
	music.SoundId = "rbxassetid://76934240287978"
	music.Looped = true
	music.Volume = 0.25
	music:SetAttribute("Music", true)

	return string.format("ClockTime %.1f, haze %.2f/%.1f, music %s", L.ClockTime, atmo.Density, atmo.Haze, music.SoundId)
end
