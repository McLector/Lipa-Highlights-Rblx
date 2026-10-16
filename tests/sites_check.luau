-- sites_check: verifies Workspace.Sites against SiteData. Run in Edit via execute_luau; returns JSON {passed, failed, failures}.
-- Early skeleton of BuildCheck (full version in Slice 02).
local HttpService = game:GetService("HttpService")
local SiteData = require(game.ReplicatedStorage.LipaShared.SiteData:Clone())

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local terrainParams = RaycastParams.new()
terrainParams.FilterType = Enum.RaycastFilterType.Include
terrainParams.FilterDescendantsInstances = { workspace.Terrain }
local function ground(x, z)
	local r = workspace:Raycast(Vector3.new(x, 400, z), Vector3.new(0, -800, 0), terrainParams)
	if r then return r.Position.Y, r.Material end
	return nil, nil
end
local function xzDist(a, b)
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

-- Sites whose real builder has run (the rest are still placeholder Blocks).
local BUILT = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true }

local sites = workspace:FindFirstChild("Sites")
check("Workspace.Sites exists", sites ~= nil)
if sites then
	check("Sites holds exactly 9 children", #sites:GetChildren() == 9, tostring(#sites:GetChildren()))
	for _, s in ipairs(SiteData.sites) do
		local label = string.format("Site%02d_%s", s.id, s.key)
		local m = sites:FindFirstChild(label)
		check(label .. " exists", m ~= nil)
		if m then
			check(label .. " SiteId attribute", m:GetAttribute("SiteId") == s.id)
			local pivot = m:GetPivot()
			check(label .. " pivot within 1 stud of pos", (pivot.Position - s.pos).Magnitude <= 1, tostring(pivot.Position))
			check(label .. " facing dot > 0.99", pivot.LookVector:Dot(SiteData.facingVector(s.facing)) > 0.99, tostring(pivot.LookVector))
			if BUILT[s.id] then
				-- Built sites (1: Slice 02, 5: Slice 04, 6: Slice 05): the builder replaced the placeholder Block with Structure.
				check(label .. " Structure present and Block absent", m:FindFirstChild("Structure") ~= nil and m:FindFirstChild("Block") == nil)
				if s.id == 5 then
					-- Orientation guard (Slice 04): the pivot is yawed 180 degrees, so a build that used the pivot as its origin is
					-- mirrored yet still passes the symmetric bounds check. The facade must be south (+Z) of the nave, and the east
					-- wing must be east (+X) of it.
					local st = m:FindFirstChild("Structure")
					local podium = st and st:FindFirstChild("Podium", true)
					local nave = st and st:FindFirstChild("NaveBlock", true)
					local wing = st and st:FindFirstChild("EastWingBlock", true)
					check(label .. " facade is south of the nave", podium ~= nil and nave ~= nil and podium.Position.Z > nave.Position.Z + 20,
						podium and nave and (podium.Position.Z .. " vs " .. nave.Position.Z) or "parts missing")
					check(label .. " east wing is east of the nave", wing ~= nil and nave ~= nil and wing.Position.X > nave.Position.X + 15,
						wing and nave and (wing.Position.X .. " vs " .. nave.Position.X) or "parts missing")
				elseif s.id == 6 then
					-- Orientation guards (Slice 05): the site is diagonal (SW), so the symmetric bounds check cannot see a mirrored or
					-- rotated build. Each anchor is ONE uniquely named BasePart, searched through the whole site (the pitch lives
					-- outside Structure); a missing or non-part anchor fails cleanly instead of erroring the run.
					local function anchor(name)
						local p = m:FindFirstChild(name, true)
						return (p ~= nil and p:IsA("BasePart")) and p or nil
					end
					local body, walkway = anchor("ShopBody"), anchor("WalkwayRoof")
					local turf, tiers = anchor("PitchTurf"), anchor("StandTiers")
					local sw = SiteData.facingVector("SW")
					check(label .. " walkway is in front (SW) of the shop body", body ~= nil and walkway ~= nil
						and (walkway.Position - body.Position):Dot(sw) > 10,
						body and walkway and string.format("%.1f studs along SW", (walkway.Position - body.Position):Dot(sw)) or "parts missing")
					check(label .. " pitch is east of the shop body", body ~= nil and turf ~= nil and turf.Position.X > body.Position.X + 40,
						body and turf and (turf.Position.X .. " vs " .. body.Position.X) or "parts missing")
					check(label .. " stand is south of the pitch", turf ~= nil and tiers ~= nil and tiers.Position.Z > turf.Position.Z + 30,
						turf and tiers and (tiers.Position.Z .. " vs " .. turf.Position.Z) or "parts missing")
				elseif s.id == 2 then
					-- Orientation guards (Slice 06): the pivot is yawed to E, so a build that used the pivot as its origin is
					-- rotated yet still passes the symmetric bounds check. Anchors are ONE uniquely named BasePart each (no
					-- container may share these names). The name band is on the east frontage, the yard lies east of the hall,
					-- and the balcony deck is at the hall's north (-Z) end, which a mirrored build would put in the south.
					local function anchor(name)
						local p = m:FindFirstChild(name, true)
						return (p ~= nil and p:IsA("BasePart")) and p or nil
					end
					local hall, yard = anchor("HallBody"), anchor("YardSlab")
					local band, deck = anchor("NameBand"), anchor("BalconyDeck")
					check(label .. " yard is east of the hall", hall ~= nil and yard ~= nil and yard.Position.X > hall.Position.X + 30,
						hall and yard and (yard.Position.X .. " vs " .. hall.Position.X) or "parts missing")
					check(label .. " name band is on the east frontage", hall ~= nil and band ~= nil and band.Position.X > hall.Position.X + 10,
						hall and band and (band.Position.X .. " vs " .. hall.Position.X) or "parts missing")
					check(label .. " balcony is at the north end", hall ~= nil and deck ~= nil and deck.Position.Z < hall.Position.Z - 25,
						hall and deck and (deck.Position.Z .. " vs " .. hall.Position.Z) or "parts missing")
				elseif s.id == 3 then
					-- Orientation + walkability guards (Slice 07): the pivot is yawed to W, so a build that used it as its origin is
					-- rotated yet passes the symmetric bounds check. Anchors are ONE uniquely named BasePart each. The awning is on
					-- the west frontage, the counter is inside and behind it, and the parking sign is at the south (+Z) end.
					-- The interior is required, so the lane guard sweeps a person-sized box (4 wide, y 2..8) along the aisle
					-- (z 140) from the forecourt (x 160) through the open front to just short of the counter (x 201): any
					-- colliding non-rig part of the site in it fails. On the placeholder it is red because the Block fills it.
					local function anchor(name)
						local p = m:FindFirstChild(name, true)
						return (p ~= nil and p:IsA("BasePart")) and p or nil
					end
					local body, awning = anchor("LomiBody"), anchor("AwningFascia")
					local counter, sign = anchor("CounterTop"), anchor("ParkingSign")
					check(label .. " awning is on the west frontage", body ~= nil and awning ~= nil and awning.Position.X < body.Position.X - 10,
						body and awning and (awning.Position.X .. " vs " .. body.Position.X) or "parts missing")
					check(label .. " counter is inside, behind the awning", awning ~= nil and counter ~= nil and counter.Position.X > awning.Position.X + 15,
						awning and counter and (counter.Position.X .. " vs " .. awning.Position.X) or "parts missing")
					check(label .. " parking sign is at the south end", body ~= nil and sign ~= nil and sign.Position.Z > body.Position.Z + 10,
						body and sign and (sign.Position.Z .. " vs " .. body.Position.Z) or "parts missing")
					local lp = OverlapParams.new()
					lp.FilterType = Enum.RaycastFilterType.Include
					lp.FilterDescendantsInstances = { m }
					lp.RespectCanCollide = true
					local blockers = {}
					for _, h in ipairs(workspace:GetPartBoundsInBox(CFrame.new(180.5, 5, 140), Vector3.new(41, 6, 4), lp)) do
						local inRig, p = false, h.Parent
						while p and p ~= m do
							if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then inRig = true break end
							p = p.Parent
						end
						if not inRig then table.insert(blockers, h:GetFullName()) end
					end
					check(label .. " walking lane into the shop is free", #blockers == 0, #blockers .. " blocking: " .. table.concat(blockers, ", ", 1, math.min(#blockers, 4)))
				elseif s.id == 4 then
					-- Orientation + walkability guards (Slice 08): the pivot is yawed to W, so a build that used it as its origin is
					-- rotated yet passes the symmetric bounds check. Anchors are ONE uniquely named BasePart each. The sign fascia is
					-- on the west frontage, the coffee bar is inside and behind it, the arcade roof is in front (west) of the fascia,
					-- and the representative-interior sign is inside the unit (x 164..204, z -186..-134). The interior is required,
					-- so the lane guard sweeps a person-sized box (4 wide, y 2..8) along the lane (z -160) from the terrace (x 144)
					-- through the door to just short of the bar (x 185): any colliding non-rig part of the site in it fails. On the
					-- placeholder it is red because the Block fills it.
					local function anchor(name)
						local p = m:FindFirstChild(name, true)
						return (p ~= nil and p:IsA("BasePart")) and p or nil
					end
					local body, fascia = anchor("CafeBody"), anchor("SignFascia")
					local bar, roof, note = anchor("BarTop"), anchor("ArcadeRoof"), anchor("RepresentativeSign")
					check(label .. " sign fascia is on the west frontage", body ~= nil and fascia ~= nil and fascia.Position.X < body.Position.X - 10,
						body and fascia and (fascia.Position.X .. " vs " .. body.Position.X) or "parts missing")
					check(label .. " coffee bar is inside, behind the fascia", fascia ~= nil and bar ~= nil and bar.Position.X > fascia.Position.X + 15,
						fascia and bar and (bar.Position.X .. " vs " .. fascia.Position.X) or "parts missing")
					check(label .. " arcade roof is in front of the fascia", fascia ~= nil and roof ~= nil and roof.Position.X < fascia.Position.X - 5,
						fascia and roof and (roof.Position.X .. " vs " .. fascia.Position.X) or "parts missing")
					check(label .. " representative sign is inside the unit", note ~= nil and note.Position.X > 164 and note.Position.X < 204
						and note.Position.Z > -186 and note.Position.Z < -134,
						note and tostring(note.Position) or "part missing")
					local lp = OverlapParams.new()
					lp.FilterType = Enum.RaycastFilterType.Include
					lp.FilterDescendantsInstances = { m }
					lp.RespectCanCollide = true
					local blockers = {}
					for _, h in ipairs(workspace:GetPartBoundsInBox(CFrame.new(164.5, 5, -160), Vector3.new(41, 6, 4), lp)) do
						local inRig, p = false, h.Parent
						while p and p ~= m do
							if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then inRig = true break end
							p = p.Parent
						end
						if not inRig then table.insert(blockers, h:GetFullName()) end
					end
					check(label .. " walking lane into the cafe is free", #blockers == 0, #blockers .. " blocking: " .. table.concat(blockers, ", ", 1, math.min(#blockers, 4)))
					-- Sign legibility (added in review): the arcade roof once hid the fascia letters from the street. From an
					-- eye-level point on road H's walkway (124, 8, -160) a ray to each Neon letter's centre must reach that letter
					-- first (Guide and InfoPanel are ignored); at least 80% of the letters must pass.
					local vp = RaycastParams.new()
					vp.FilterType = Enum.RaycastFilterType.Include
					local incl = {}
					for _, c in ipairs(m:GetChildren()) do
						if c.Name ~= "Guide" and c.Name ~= "InfoPanel" then table.insert(incl, c) end
					end
					vp.FilterDescendantsInstances = incl
					local eye = Vector3.new(124, 8, -160)
					local letters, seen = 0, 0
					for _, d in ipairs(m:GetDescendants()) do
						if d.Name == "NeonLetter" and d:IsA("BasePart") then
							letters += 1
							local r = workspace:Raycast(eye, d.Position - eye, vp)
							if r and r.Instance == d then seen += 1 end
						end
					end
					check(label .. " sign letters are visible from the street", letters >= 20 and seen >= letters * 0.8,
						seen .. " of " .. letters .. " letters seen from the street")
				elseif s.id == 7 then
					-- Orientation, walkability, keep-clear and sight-line guards (Slice 09): the pivot is yawed to W, so a build that
					-- used it as its origin is rotated yet passes the symmetric bounds check. Anchors are ONE uniquely named BasePart
					-- each, searched through the whole site. The villa glass is on the west frontage (VillaBody is the back wall), the
					-- pool lies west of the villa, the pavilion deck is south (+Z) of the pool, the path starts west of the Guide and
					-- the wellness board stands east of it. The four lanes (entry path, plaza to pool, south to the lagoon, to the
					-- deck) are swept with person-sized boxes (4 wide, y 2..9); any colliding non-rig part of the site fails. The
					-- kept Guide / InfoPanel / JeepStop / jeepney are excluded from the keep-clear and sight-line queries.
					local function anchor(name)
						local p = m:FindFirstChild(name, true)
						return (p ~= nil and p:IsA("BasePart")) and p or nil
					end
					local function named(name)
						local list = {}
						for _, d in ipairs(m:GetDescendants()) do
							if d.Name == name and d:IsA("BasePart") then table.insert(list, d) end
						end
						return list
					end
					local body, roof, pool = anchor("VillaBody"), anchor("VillaRoof"), anchor("PoolWater")
					local deck, pstart, board = anchor("PavilionDeck"), anchor("PathStart"), anchor("WellnessBoard")
					local panes, thatch = named("VillaGlassPane"), named("PavilionThatch")
					local guideX = SiteData.guidePos(7).X
					local panesWest = body ~= nil and #panes >= 4
					for _, pn in ipairs(panes) do
						if body == nil or pn.Position.X >= body.Position.X - 15 then panesWest = false end
					end
					check(label .. " villa glass is on the west frontage", panesWest,
						body and (#panes .. " panes, body x " .. body.Position.X) or "parts missing")
					check(label .. " villa roof is above the glass", roof ~= nil and roof.Position.Y >= 13,
						roof and tostring(roof.Position) or "part missing")
					check(label .. " pool is west of the villa", body ~= nil and pool ~= nil and pool.Position.X < body.Position.X - 30,
						body and pool and (pool.Position.X .. " vs " .. body.Position.X) or "parts missing")
					check(label .. " pavilion deck is south of the pool", pool ~= nil and deck ~= nil and deck.Position.Z > pool.Position.Z + 30,
						pool and deck and (deck.Position.Z .. " vs " .. pool.Position.Z) or "parts missing")
					check(label .. " path starts west of the Guide", pstart ~= nil and pstart.Position.X < guideX - 60,
						pstart and tostring(pstart.Position) or "part missing")
					local boardGui = board and board:FindFirstChildOfClass("SurfaceGui")
					local boardText = boardGui and boardGui:FindFirstChildWhichIsA("TextLabel", true)
					check(label .. " wellness board is east of the Guide, with text", board ~= nil and board.Position.X > guideX + 20
						and boardText ~= nil and #boardText.Text > 0, board and tostring(board.Position) or "part missing")

					local function inRig(h)
						local p = h.Parent
						while p and p ~= m do
							if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
							p = p.Parent
						end
						return false
					end
					local lp = OverlapParams.new()
					lp.FilterType = Enum.RaycastFilterType.Include
					lp.FilterDescendantsInstances = { m }
					lp.RespectCanCollide = true
					for _, lane in ipairs({
						{ "entry path (a)", CFrame.new(615, 5.5, 240), Vector3.new(82, 7, 4) },
						{ "plaza to pool (b)", CFrame.new(698, 5.5, 240), Vector3.new(28, 7, 4) },
						{ "south to the lagoon (c)", CFrame.new(700, 5.5, 281), Vector3.new(4, 7, 38) },
						{ "to the deck (d)", CFrame.new(718, 5.5, 292), Vector3.new(20, 7, 4) },
					}) do
						local blockers = {}
						for _, h in ipairs(workspace:GetPartBoundsInBox(lane[2], lane[3], lp)) do
							if not inRig(h) then table.insert(blockers, h:GetFullName()) end
						end
						check(label .. " walking lane " .. lane[1] .. " is free", #blockers == 0,
							#blockers .. " blocking: " .. table.concat(blockers, ", ", 1, math.min(#blockers, 4)))
					end

					-- Everything built except the kept Guide / InfoPanel / JeepStop / jeepney.
					local kept = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
					local built = {}
					for _, c in ipairs(m:GetChildren()) do
						if not kept[c.Name] then table.insert(built, c) end
					end
					local kp = OverlapParams.new()
					kp.FilterType = Enum.RaycastFilterType.Include
					kp.FilterDescendantsInstances = built
					for _, zone in ipairs({
						{ "Guide box", CFrame.new(670, 7.5, 240), Vector3.new(24, 13, 24) },
						{ "InfoPanel front zone", CFrame.new(670, 5.5, 252), Vector3.new(12, 9, 12) },
						{ "JeepStop and landing box", CFrame.new(670, 7.5, 211), Vector3.new(24, 13, 42) },
					}) do
						local hits = {}
						for _, h in ipairs(workspace:GetPartBoundsInBox(zone[2], zone[3], kp)) do
							if not inRig(h) then table.insert(hits, h:GetFullName()) end
						end
						check(label .. " keep-clear " .. zone[1] .. " is free", #hits == 0,
							#hits .. " in the way: " .. table.concat(hits, ", ", 1, math.min(#hits, 4)))
					end

					-- Sight-lines: from eye-level points a ray to each target's centre must reach that part first.
					local vp = RaycastParams.new()
					vp.FilterType = Enum.RaycastFilterType.Include
					vp.FilterDescendantsInstances = built
					local function seenFrom(eye, targets)
						local seen = 0
						for _, t in ipairs(targets) do
							local r = workspace:Raycast(eye, t.Position - eye, vp)
							if r and r.Instance == t then seen += 1 end
						end
						return seen
					end
					local eyeGuide, eyeRoad = Vector3.new(664, 6, 234), Vector3.new(576, 6, 236)
					local sGuide, sRoad, sThatch = seenFrom(eyeGuide, panes), seenFrom(eyeRoad, panes), seenFrom(eyeGuide, thatch)
					check(label .. " villa glass is visible from the plaza", #panes >= 4 and sGuide >= #panes * 0.8,
						sGuide .. " of " .. #panes .. " panes seen from the plaza")
					check(label .. " villa glass is visible from the road mouth", #panes >= 4 and sRoad >= #panes * 0.8,
						sRoad .. " of " .. #panes .. " panes seen from the road mouth")
					check(label .. " pavilion thatch is visible from the plaza", #thatch >= 4 and sThatch >= #thatch * 0.8,
						sThatch .. " of " .. #thatch .. " thatch tiers seen from the plaza")
				elseif s.id == 8 then
					-- Orientation, walkability, keep-clear and sight-line guards (Slice 10): the pivot is yawed NW and the site sits on a slope, so a
					-- build that used the pivot as its origin is rotated yet passes the symmetric bounds check. Anchors are ONE uniquely named
					-- BasePart each, searched through the whole site. The porte-cochere and entry gable are NW (the frontage) of the main roof,
					-- the pool is SW of the clubhouse, the island flag is in the pond west of it, the mountain peak is east and high, the board
					-- stands near the Guide. The four lanes (drive, Guide to porte-cochere, forecourt to pool, plaza to the hole 1 tee) are swept
					-- with person-sized boxes (4 wide, in 16-stud segments, sloped lanes follow the terrain); any colliding non-rig part of the
					-- site fails. The kept Guide / InfoPanel / JeepStop / jeepney are excluded from the keep-clear and sight-line queries.
					local function anchor(name)
						local p = m:FindFirstChild(name, true)
						return (p ~= nil and p:IsA("BasePart")) and p or nil
					end
					local function named(name)
						local list = {}
						for _, d in ipairs(m:GetDescendants()) do
							if d.Name == name and d:IsA("BasePart") then table.insert(list, d) end
						end
						return list
					end
					local roof, gable, porte = anchor("ClubhouseRoofMain"), anchor("ClubhouseEntryGable"), anchor("PorteCochere")
					local pool, flag, peak, board = anchor("PoolWater"), anchor("IslandFlag"), anchor("BackdropPeak"), anchor("LeisureBoard")
					local windows, rails = named("ClubhouseWindow"), named("ClubhouseBalconyRail")
					local NW, SW = SiteData.facingVector("NW"), SiteData.facingVector("SW")
					local guidePos = SiteData.guidePos(8)
					local function off(a, b) return Vector3.new(a.X - b.X, 0, a.Z - b.Z) end
					check(label .. " porte-cochere is in front (NW) of the main roof", roof ~= nil and porte ~= nil and off(porte.Position, roof.Position):Dot(NW) >= 25,
						roof and porte and tostring(off(porte.Position, roof.Position):Dot(NW)) or "parts missing")
					check(label .. " entry gable is in front (NW) of the main roof", roof ~= nil and gable ~= nil and off(gable.Position, roof.Position):Dot(NW) >= 10,
						roof and gable and tostring(off(gable.Position, roof.Position):Dot(NW)) or "parts missing")
					check(label .. " main roof is high and over the clubhouse centre", roof ~= nil and roof.Position.Y >= 44 and off(roof.Position, Vector3.new(620, 0, 780)).Magnitude <= 15,
						roof and tostring(roof.Position) or "part missing")
					local winFront = #windows >= 10 and roof ~= nil
					if winFront then
						local sum = 0
						for _, w in ipairs(windows) do sum += off(w.Position, roof.Position):Dot(NW) end
						winFront = sum / #windows >= 10
					end
					check(label .. " the windows are on the NW face", winFront, #windows .. " windows")
					check(label .. " pool is SW of the clubhouse", roof ~= nil and pool ~= nil and off(pool.Position, roof.Position):Dot(SW) >= 60
						and math.abs(off(pool.Position, roof.Position):Dot(NW)) <= 35, roof and pool and tostring(pool.Position) or "parts missing")
					check(label .. " island flag stands in the pond", flag ~= nil and flag.Position.X > 440 and flag.Position.X < 500 and flag.Position.Z > 770
						and flag.Position.Z < 850 and flag.Position.Y >= 12, flag and tostring(flag.Position) or "part missing")
					check(label .. " mountain peak is east and high", peak ~= nil and peak.Position.X >= 690 and peak.Position.Y >= 60, peak and tostring(peak.Position) or "part missing")
					local boardGui = board and board:FindFirstChildOfClass("SurfaceGui")
					local boardText = boardGui and boardGui:FindFirstChildWhichIsA("TextLabel", true)
					check(label .. " leisure board is near the Guide, with text", board ~= nil and off(board.Position, guidePos).Magnitude <= 45
						and boardText ~= nil and #boardText.Text > 0, board and tostring(board.Position) or "part missing")

					local function inRig(h)
						local p = h.Parent
						while p and p ~= m do
							if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
							p = p.Parent
						end
						return false
					end
					local lp = OverlapParams.new()
					lp.FilterType = Enum.RaycastFilterType.Include
					lp.FilterDescendantsInstances = { m }
					lp.RespectCanCollide = true
					-- A lane is a polyline of (x, z) points swept in segments of at most 16 studs. fixedY = { y0, y1 } for the flat pad lanes;
					-- otherwise the box spans the highest terrain under the segment + 2 .. + 9 (steps and low kerbs of 2 or less do not block).
					local function laneBlockers(points, fixedY)
						local seen, blockers = {}, {}
						for i = 1, #points - 1 do
							local p1, p2 = Vector3.new(points[i][1], 0, points[i][2]), Vector3.new(points[i + 1][1], 0, points[i + 1][2])
							local dir = p2 - p1
							local n = math.max(1, math.ceil(dir.Magnitude / 16))
							for k = 0, n - 1 do
								local a, b = p1 + dir * (k / n), p1 + dir * ((k + 1) / n)
								local y0, y1
								if fixedY then
									y0, y1 = fixedY[1], fixedY[2]
								else
									local g = math.max(ground(a.X, a.Z) or 0, ground(b.X, b.Z) or 0)
									y0, y1 = g + 2, g + 9
								end
								local mid = (a + b) / 2
								local cy = (y0 + y1) / 2
								local cf = CFrame.lookAt(Vector3.new(mid.X, cy, mid.Z), Vector3.new(mid.X + dir.X, cy, mid.Z + dir.Z))
								for _, h in ipairs(workspace:GetPartBoundsInBox(cf, Vector3.new(4, y1 - y0, (b - a).Magnitude + 0.5), lp)) do
									if not inRig(h) and not seen[h] then
										seen[h] = true
										table.insert(blockers, h:GetFullName())
									end
								end
							end
						end
						return blockers
					end
					for _, lane in ipairs({
						{ "the drive (a)", { { 450, 552 }, { 450, 700 }, { 524, 700 } }, nil },
						{ "Guide to porte-cochere (b)", { { 548, 708 }, { 592, 752 } }, { 22, 29 } },
						{ "forecourt to pool (c)", { { 585, 753 }, { 537, 815 } }, { 22, 29 } },
						{ "plaza to the hole 1 tee (d)", { { 520, 722 }, { 436, 758 }, { 426, 788 } }, nil },
					}) do
						local blockers = laneBlockers(lane[2], lane[3])
						check(label .. " walking lane " .. lane[1] .. " is free", #blockers == 0,
							#blockers .. " blocking: " .. table.concat(blockers, ", ", 1, math.min(#blockers, 4)))
					end

					-- Everything built except the kept Guide / InfoPanel / JeepStop / jeepney.
					local kept = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
					local built = {}
					for _, c in ipairs(m:GetChildren()) do
						if not kept[c.Name] then table.insert(built, c) end
					end
					local kp = OverlapParams.new()
					kp.FilterType = Enum.RaycastFilterType.Include
					kp.FilterDescendantsInstances = built
					for _, zone in ipairs({
						{ "Guide box", CFrame.new(538.8, 27, 698.8), Vector3.new(24, 12, 24) },
						{ "InfoPanel front zone", CFrame.new(531, 26, 708), Vector3.new(16, 10, 16) },
						{ "JeepStop and landing box", CFrame.new(563, 27.5, 677), Vector3.new(34, 13, 30) },
					}) do
						local hits = {}
						for _, h in ipairs(workspace:GetPartBoundsInBox(zone[2], zone[3], kp)) do
							if not inRig(h) then table.insert(hits, h:GetFullName()) end
						end
						check(label .. " keep-clear " .. zone[1] .. " is free", #hits == 0,
							#hits .. " in the way: " .. table.concat(hits, ", ", 1, math.min(#hits, 4)))
					end

					-- Sight-lines: from eye-level points a ray to each target's centre must reach that part first.
					local vp = RaycastParams.new()
					vp.FilterType = Enum.RaycastFilterType.Include
					vp.FilterDescendantsInstances = built
					local function seenFrom(eye, targets)
						local seenCount = 0
						for _, t in ipairs(targets) do
							local r = workspace:Raycast(eye, t.Position - eye, vp)
							if r and r.Instance == t then seenCount += 1 end
						end
						return seenCount
					end
					local eyeGuide, eyeRoad = Vector3.new(534.6, 23.2, 694.6), Vector3.new(450, 14.5, 556)
					local sGuideW, sGuideR, sRoadW = seenFrom(eyeGuide, windows), seenFrom(eyeGuide, rails), seenFrom(eyeRoad, windows)
					check(label .. " clubhouse windows are visible from the Guide", #windows >= 10 and sGuideW >= #windows * 0.8,
						sGuideW .. " of " .. #windows .. " windows seen from the Guide")
					check(label .. " balcony rails are visible from the Guide", #rails >= 8 and sGuideR >= #rails * 0.8,
						sGuideR .. " of " .. #rails .. " rails seen from the Guide")
					check(label .. " clubhouse windows are visible from the road", #windows >= 10 and sRoadW >= #windows * 0.8,
						sRoadW .. " of " .. #windows .. " windows seen from the road")
				end
			else
				check(label .. " Block present", m:FindFirstChild("Block") ~= nil and m.Block:IsA("BasePart"))
			end

			-- Guide
			local guide = m:FindFirstChild("Guide")
			check(label .. " Guide present", guide ~= nil and guide:IsA("Model"))
			local gHrp
			if guide then
				gHrp = guide:FindFirstChild("HumanoidRootPart")
				check(label .. " Guide has Humanoid + HRP", guide:FindFirstChildOfClass("Humanoid") ~= nil and gHrp ~= nil)
				check(label .. " Guide Atomic streaming", guide.ModelStreamingMode == Enum.ModelStreamingMode.Atomic)
				local anchoredOthers = 0
				for _, d in ipairs(guide:GetDescendants()) do
					if d:IsA("BasePart") and d ~= gHrp and d.Anchored then anchoredOthers += 1 end
				end
				check(label .. " only the Guide HRP is anchored", gHrp ~= nil and gHrp.Anchored and anchoredOthers == 0, "others anchored: " .. anchoredOthers)
				if gHrp then
					local target = SiteData.guidePos(s.id)
					check(label .. " Guide XZ at guidePos", xzDist(gHrp.Position, target) <= 1, tostring(gHrp.Position))
					local gy = ground(gHrp.Position.X, gHrp.Position.Z)
					check(label .. " Guide stands on terrain", gy ~= nil and gHrp.Position.Y - gy >= 2 and gHrp.Position.Y - gy <= 5,
						"hrpY=" .. gHrp.Position.Y .. " groundY=" .. tostring(gy))
					local prompt = gHrp:FindFirstChild("GuidePrompt")
					check(label .. " GuidePrompt", prompt ~= nil and prompt:IsA("ProximityPrompt")
						and prompt.RequiresLineOfSight == false and prompt.HoldDuration == 0
						and prompt:GetAttribute("PromptKind") == "Guide")
				end
			end

			-- InfoPanel
			local panel = m:FindFirstChild("InfoPanel")
			local gui = panel and panel:FindFirstChildOfClass("SurfaceGui")
			local label1 = gui and gui:FindFirstChildWhichIsA("TextLabel", true)
			check(label .. " InfoPanel with SurfaceGui text", panel ~= nil and label1 ~= nil and #label1.Text > 0)

			-- JeepStop only where SiteData says so
			local stop = m:FindFirstChild("JeepStop")
			if SiteData.hasJeepStop(s.id) then
				check(label .. " JeepStop present", stop ~= nil and stop:IsA("BasePart"))
				check(label .. " Jeepney prop present", m:FindFirstChild("Jeepney") ~= nil)
				if stop then
					check(label .. " JeepStop XZ at jeepStopPos", xzDist(stop.Position, SiteData.jeepStopPos(s.id)) <= 1, tostring(stop.Position))
					local _, mat = ground(stop.Position.X, stop.Position.Z)
					check(label .. " JeepStop on dry land", mat ~= nil and mat ~= Enum.Material.Water, tostring(mat))
					if gHrp then
						local d = xzDist(stop.Position, gHrp.Position)
						check(label .. " JeepStop 15-25 studs from Guide", d >= 15 and d <= 25, tostring(d))
					end
					local jp = stop:FindFirstChild("JeepPrompt")
					check(label .. " JeepPrompt", jp ~= nil and jp:IsA("ProximityPrompt") and jp:GetAttribute("PromptKind") == "Jeep")
				end
			else
				check(label .. " has no JeepStop", stop == nil)
			end
			if gHrp then
				local _, mat = ground(gHrp.Position.X, gHrp.Position.Z)
				check(label .. " Guide on dry land", mat ~= nil and mat ~= Enum.Material.Water, tostring(mat))
			end

			-- Everything that is not part of a rig (any Model with a Humanoid: the Guide, plaza people) is anchored.
			local function insideRig(part)
				local p = part.Parent
				while p and p ~= m do
					if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return true end
					p = p.Parent
				end
				return false
			end
			local loose = 0
			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") and not insideRig(d) and not d.Anchored then loose += 1 end
			end
			check(label .. " all non-rig parts anchored", loose == 0, "unanchored: " .. loose)
		end
	end
end

return HttpService:JSONEncode(results)
