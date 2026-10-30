-- guidance_play_check: the new-player guidance in a real Play session (2026-10-31). Not in run_all and not in ServerStorage: the HUD
-- lives in the client's PlayerGui, so paste this file into execute_luau with datamodel_type Client during Play, before any stamp.
-- It walks the tour start the way a newcomer does (Ate Joy, the City Hall jeep stop, the Plaza) by moving the character and calling
-- the real remotes, and checks the Next line, the NEXT pin, the stamp and refusal messages, the prompt words, the jeep menu marks and
-- the camera after a ride. Returns JSON { passed, failed, failures }.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SiteData = require(ReplicatedStorage.LipaShared.SiteData)
local Remotes = ReplicatedStorage.LipaShared.Remotes

local player = Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("PassportHUD")
local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. tostring(detail)) or ""))
	end
end
local function waitFor(fn, timeout)
	local t0 = os.clock()
	while os.clock() - t0 < (timeout or 3) do
		if fn() then return true end
		task.wait(0.1)
	end
	return fn()
end
local function hrp()
	return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end
local function guideAt(id)
	local row = SiteData.byId(id)
	local m = workspace.Sites:FindFirstChild(string.format("Site%02d_%s", id, row.key))
	local g = m and m:FindFirstChild("Guide") and m.Guide:FindFirstChild("HumanoidRootPart")
	return g and g.Position or SiteData.guidePos(id) + Vector3.new(0, 3, 0)
end
local function flat(a, b)
	return (Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z)).Magnitude
end
local hint = gui.Root.NextHint
local pin = workspace:FindFirstChild("NextPin")

-- 1. At the spawn: the Next line names City Hall and the pin stands on Ate Joy.
check("Welcome Step1 names Ate Joy", player.PlayerGui:FindFirstChild("Welcome") == nil
	or string.find(player.PlayerGui.Welcome.Panel.Step1.Text, "Ate Joy", 1, true) ~= nil)
check("NextSiteId is 10 at the spawn", waitFor(function() return gui:GetAttribute("NextSiteId") == 10 end), gui:GetAttribute("NextSiteId"))
check("Next line names New Lipa City Hall", string.find(hint.Text, "New Lipa City Hall", 1, true) ~= nil, hint.Text)
check("NEXT pin exists, shows through walls and is on", pin ~= nil and pin.NextPinGui.AlwaysOnTop and pin.NextPinGui.Enabled)
check("NEXT pin stands on Ate Joy", pin ~= nil and flat(pin.Position, SiteData.guidePos(10)) < 1, pin and pin.Position)

-- 2. Prompt words (relabelled on the client).
local talk, ride = 0, 0
for _, d in ipairs(workspace:GetDescendants()) do
	if d:IsA("ProximityPrompt") then
		if d:GetAttribute("PromptKind") == "Guide" and d.ActionText == "Talk (get a stamp)" then talk += 1 end
		if d:GetAttribute("PromptKind") == "Jeep" and d.ActionText == "Choose a ride" then ride += 1 end
	end
end
check("streamed-in guide prompts say 'Talk (get a stamp)'", talk >= 1, talk)
check("streamed-in jeep prompts say 'Choose a ride'", ride >= 1, ride)

-- 3. Stamp at Ate Joy: the message, then the hint moves on to the jeepney.
player.Character:PivotTo(CFrame.new(guideAt(10) + Vector3.new(4, 1, 0)))
task.wait(0.3)
local r = Remotes.StampRequest:InvokeServer(10)
check("Ate Joy stamps", r and r.ok, r and r.reason)
local toast = gui:FindFirstChild("StampToast")
check("stamp message 'Stamp collected: New Lipa City Hall (1/10)'",
	waitFor(function() return toast and toast.Visible and toast.Text == "Stamp collected: New Lipa City Hall (1/10)" end, 2), toast and toast.Text)
check("next is the Plaza by jeepney", waitFor(function() return gui:GetAttribute("NextSiteId") == 1 and gui:GetAttribute("NextMode") == "jeep" end, 3),
	tostring(gui:GetAttribute("NextSiteId")) .. " " .. tostring(gui:GetAttribute("NextMode")))
check("NEXT pin moved to the City Hall jeep stop", pin and flat(pin.Position, SiteData.jeepStopPos(10)) < 1, pin and pin.Position)

-- 4. Jeep menu marks: open it through the City Hall stop's prompt.
player.Character:PivotTo(CFrame.new(SiteData.jeepStopPos(10) + Vector3.new(0, 4, 0)))
task.wait(0.5)
local menu = player.PlayerGui:WaitForChild("JeepMenu")
local jp = workspace.Sites.Site10_CityHall.JeepStop:FindFirstChild("JeepPrompt")
pcall(function() jp:InputHoldBegin() task.wait(0.05) jp:InputHoldEnd() end)
if waitFor(function() return menu.Enabled end, 2) then
	local dest1 = menu.Box.Destinations.Dest_1
	check("jeep menu: the Plaza (next) is gold", dest1.BackgroundColor3 == Color3.fromRGB(255, 214, 102))
	check("jeep menu: not-yet places keep plain names", not string.find(menu.Box.Destinations.Dest_5.Text, " - done", 1, true))
	check("jeep menu footnote explains the walk-only shops", menu.Box.Footnote.Text == "Market, Lomi King, Cafe de Lipa: ride to the Plaza, then walk.")
	menu.Enabled = false
else
	check("jeep menu opened from the prompt (InputHoldBegin)", false, "menu did not open; check the marks by hand")
end

-- 5. Ride to the Plaza: the camera turns to the Plaza Guide; a second ask at once is refused with a message.
local seq = player:GetAttribute("JeepSeq") or 0
Remotes.JeepRequest:FireServer(1)
check("ride to the Plaza", waitFor(function() return (player:GetAttribute("JeepSeq") or 0) > seq end, 3) and player:GetAttribute("LastJeepResult") == "ok:1",
	player:GetAttribute("LastJeepResult"))
task.wait(0.8)
local cam = workspace.CurrentCamera
local toGuide = Vector3.new(guideAt(1).X - cam.CFrame.Position.X, 0, guideAt(1).Z - cam.CFrame.Position.Z).Unit
local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit
check("after the ride the camera faces the Plaza Guide", look:Dot(toGuide) > 0.9, look:Dot(toGuide))
seq = player:GetAttribute("JeepSeq")
Remotes.JeepRequest:FireServer(5)
local jt = player.PlayerGui:WaitForChild("JeepToast").Message
check("a ride asked again at once says 'Wait a moment for the next jeepney.'",
	waitFor(function() return jt.Visible and jt.Text == "Wait a moment for the next jeepney." end, 2), jt.Text)

-- 6. At the Plaza: walk to its guide, stamp, then the hint sends you out by the west side stairs to the Market.
check("at the Plaza stop the hint walks to its guide", waitFor(function() return gui:GetAttribute("NextSiteId") == 1 and gui:GetAttribute("NextMode") == "walk" end, 2),
	gui:GetAttribute("NextMode"))
player.Character:PivotTo(CFrame.new(guideAt(1) + Vector3.new(0, 1, 5)))
task.wait(0.3)
r = Remotes.StampRequest:InvokeServer(1)
check("the Plaza Guide stamps", r and r.ok, r and r.reason)
check("next is the Market via the west side stairs", waitFor(function() return gui:GetAttribute("NextSiteId") == 2 and gui:GetAttribute("NextMode") == "stairs" end, 3),
	tostring(gui:GetAttribute("NextSiteId")) .. " " .. tostring(gui:GetAttribute("NextMode")))
check("NEXT pin is at the west side stairs", pin and pin.Position.X < -120, pin and pin.Position)
check("Next line says west side stairs", string.find(hint.Text, "west side stairs", 1, true) ~= nil, hint.Text)

-- 7. Off the stop, after the cooldown: the refusal says where to stand.
task.wait(3.2)
Remotes.JeepRequest:FireServer(5)
check("a ride asked off the stop says 'Stand on the yellow jeepney stop to ride.'",
	waitFor(function() return jt.Visible and jt.Text == "Stand on the yellow jeepney stop to ride." end, 2), jt.Text)

return HttpService:JSONEncode(results)
