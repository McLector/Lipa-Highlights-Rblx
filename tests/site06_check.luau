-- site06_check: the Slice 16 fidelity spec for Site 06 (The Outlets at LIMA Estate + Aboitiz Pitch), written BEFORE the rebuild.
-- Studio copy: ServerStorage.Checks.site06_check. Run in Edit via execute_luau:
--   require(game.ServerStorage.Checks.site06_check:Clone())      -- returns JSON {passed, failed, failures}
-- Every number comes from briefs/site06.md "Revision 1 (Slice 16)": the Commons junction photos (Judgefloro, CC0, 2019-09-23),
-- the LIMA Estate 2025 drone shot (CC BY-SA 4.0) and the architizer set the shop blocks were first built from.
-- Frames: the site pivot is yawed SW, but the builder works in world-aligned local axes (origin = the pivot position), so lp(p) is the
-- world position minus the site position (+X east, +Z south). SHc is the shop frame (local +Z = SW = the frontage, +X = SE).
local HttpService = game:GetService("HttpService")
local SITE_POS = Vector3.new(550, 0, -650)
local R = math.sqrt(0.5)
local SHc = CFrame.fromMatrix(SITE_POS + Vector3.new(-10, 0, -50), Vector3.new(R, 0, R), Vector3.new(0, 1, 0), Vector3.new(-R, 0, R))

local results = { passed = 0, failed = 0, failures = {} }
local function check(name, cond, detail)
	if cond then
		results.passed += 1
	else
		results.failed += 1
		table.insert(results.failures, name .. (detail and (" | " .. detail) or ""))
	end
end

local site = workspace:FindFirstChild("Sites") and workspace.Sites:FindFirstChild("Site06_Outlets")
check("Site06_Outlets exists", site ~= nil)
if not site then
	return HttpService:JSONEncode(results)
end
-- A stray drag in Studio once moved a whole site; it shows up as a dozen unrelated failures, so test the pivot first.
do
	local pv = site:GetPivot()
	check("site pivot is at the SiteData pos (550, 0, -650), facing SW",
		(pv.Position - SITE_POS).Magnitude < 0.01 and pv.LookVector:Dot(Vector3.new(-R, 0, R)) > 0.999,
		string.format("(%.2f, %.2f, %.2f) look %s", pv.X, pv.Y, pv.Z, tostring(pv.LookVector)))
end

local function isRig(inst)
	local p = inst
	while p and p ~= site do
		if p:FindFirstChildOfClass("Humanoid") then return true end
		p = p.Parent
	end
	return false
end
local function allNamed(name)
	local list = {}
	for _, d in ipairs(site:GetDescendants()) do
		if d.Name == name and d:IsA("BasePart") and not isRig(d) then table.insert(list, d) end
	end
	return list
end
local function anchor(name) return allNamed(name)[1] end
local function lp(p) return p.Position - SITE_POS end
local function sh(p) return SHc:PointToObjectSpace(p.Position) end
local function topY(p) return p.Position.Y + p.Size.Y / 2 end
local function fmt(v) return v and string.format("%.1f", v) or "nil" end
local function near(a, b, tol) return a ~= nil and math.abs(a - b) <= tol end
local function rgb(p) return p.Color.R * 255, p.Color.G * 255, p.Color.B * 255 end
local function guiText(p)
	local t = {}
	for _, g in ipairs(p:GetChildren()) do
		if g:IsA("SurfaceGui") then
			for _, l in ipairs(g:GetDescendants()) do
				if l:IsA("TextLabel") then table.insert(t, l.Text) end
			end
		end
	end
	return table.concat(t, " ")
end
local function count(list, pred)
	local n = 0
	for _, p in ipairs(list) do if pred(p) then n += 1 end end
	return n
end
-- colour families (the photos, by eye)
local function lightGrey(p) local r, g, b = rgb(p); return r >= 150 and r <= 225 and math.abs(r - b) <= 14 and math.abs(r - g) <= 10 end
local function maroon(p) local r, g, b = rgb(p); return r >= 90 and r <= 140 and g >= 30 and g <= 70 and b >= 25 and b <= 60 end
local function solarBlue(p) local r, g, b = rgb(p); return r <= 60 and b >= 70 and b > r + 30 end
local function white(p) local r, g, b = rgb(p); return r >= 225 and g >= 220 and b >= 205 end
local function red(p) local r, g, b = rgb(p); return r >= 180 and g <= 70 and b <= 70 end
local function yellow(p) local r, g, b = rgb(p); return r >= 220 and g >= 180 and b <= 90 end
local function orange(p) local r, g, b = rgb(p); return r >= 180 and g >= 70 and g <= 130 and b <= 100 end
local function purple(p) local r, g, b = rgb(p); return r >= 55 and r <= 110 and g <= 70 and b >= 90 end

------------------------------------------------------------------ Kept objects: untouched and clear
local KEPT = { Guide = true, InfoPanel = true, JeepStop = true, JeepSignPole = true, JeepSign = true, Jeepney = true }
local function isKept(inst)
	local p = inst
	while p and p ~= site do
		if KEPT[p.Name] and p.Parent == site then return true end
		p = p.Parent
	end
	return false
end
do
	for name in pairs(KEPT) do
		check("kept object still present: " .. name, site:FindFirstChild(name) ~= nil)
	end
	local pad, guide = site:FindFirstChild("JeepStop"), site:FindFirstChild("Guide")
	check("JeepStop pad is at (-35.4, 7.1) of the site centre", pad ~= nil and (lp(pad) - Vector3.new(-35.36, 0.2, 7.07)).Magnitude < 1, pad and tostring(lp(pad)) or "missing")
	local gpos = guide and guide:GetPivot().Position - SITE_POS
	check("Guide is at (-21.2, 21.2) of the site centre", gpos ~= nil and (Vector3.new(gpos.X, 0, gpos.Z) - Vector3.new(-21.2, 0, 21.2)).Magnitude < 1, gpos and tostring(gpos) or "missing")

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { site }
	local function blockers(centre, size)
		local bad = {}
		for _, p in ipairs(workspace:GetPartBoundsInBox(CFrame.new(centre), size, params)) do
			-- ground slabs (top within 0.6 of the ground) are fine, standing objects are not
			if not isKept(p) and not isRig(p) and p.Position.Y + p.Size.Y / 2 > 0.6 then table.insert(bad, p.Name) end
		end
		return bad
	end
	if pad then
		local bad = blockers(pad.Position + Vector3.new(0, 8, 0), Vector3.new(20, 16, 20))
		check("nothing stands within 10 studs of the JeepStop landing", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
	end
	if pad and guide then
		local a, b = pad.Position, guide:GetPivot().Position
		local bad = {}
		for t = 0, 1, 0.05 do
			local c = a:Lerp(b, t)
			for _, n in ipairs(blockers(Vector3.new(c.X, 3.2, c.Z), Vector3.new(2, 5, 2))) do table.insert(bad, n) end
		end
		check("the straight path from the pad to the Guide stays open", #bad == 0, table.concat(bad, ", ", 1, math.min(#bad, 6)))
		local gb = blockers(b + Vector3.new(0, 3, 0), Vector3.new(8, 8, 8))
		check("nothing stands within the Guide's box", #gb == 0, table.concat(gb, ", ", 1, math.min(#gb, 6)))
	end
end

------------------------------------------------------------------ A: approach road and junction
do
	local road = anchor("EntryPath")
	check("EntryPath is a 16-wide concrete road, light grey", road ~= nil and road.Size.X >= 15.5 and road.Size.Y >= 0.4 and lightGrey(road),
		road and (fmt(road.Size.X) .. " wide") or "missing")
	local kb, ky = allNamed("KerbBlack"), allNamed("KerbYellow")
	local onKerb = function(p) local d = math.abs(lp(p).X + 120); return d >= 7.5 and d <= 9 end
	check("black and yellow painted kerbs run along both sides of the road (14+ of each, 0.5+ high)",
		#kb >= 14 and #ky >= 14 and count(kb, onKerb) == #kb and count(ky, onKerb) == #ky and count(kb, function(p) return p.Size.Y >= 0.5 end) == #kb,
		#kb .. " black / " .. #ky .. " yellow")
	local zs = allNamed("ZebraStripe")
	check("zebra crossing: 6+ white stripes across the road near the mouth",
		#zs >= 6 and count(zs, function(p) return math.abs(lp(p).X + 120) < 8 and lp(p).Z >= 84 and lp(p).Z <= 98 and white(p) end) == #zs, tostring(#zs))
	local pv = allNamed("PaverStrip")
	local west, east = 0, 0
	for _, p in ipairs(pv) do
		if p.Size.Y >= 0.35 and p.Size.Z >= 60 and p.Size.X >= 4 then
			if lp(p).X < -125 then west += 1 elseif lp(p).X > -115 then east += 1 end
		end
	end
	check("paver sidewalks: one 5-wide, 60+ long strip on each side of the road, 0.4 thick", #pv == 2 and west == 1 and east == 1, #pv .. " strips, west " .. west .. " east " .. east)
	check("lamp poles with purple banners: 4+ StreetLampPole / StreetLampHead / LampBanner, poles 14+ tall",
		#allNamed("StreetLampPole") >= 4 and #allNamed("StreetLampHead") >= 4 and #allNamed("LampBanner") >= 4
			and count(allNamed("StreetLampPole"), function(p) return p.Size.X >= 14 or p.Size.Y >= 14 end) >= 4
			and count(allNamed("LampBanner"), purple) >= 4,
		#allNamed("StreetLampPole") .. "/" .. #allNamed("StreetLampHead") .. "/" .. #allNamed("LampBanner"))
	local palms = allNamed("PalmTrunk")
	local pw = count(palms, function(p) return lp(p).X >= -142 and lp(p).X <= -134 and lp(p).Z < 56 end)
	local pe = count(palms, function(p) return lp(p).X >= -112 and lp(p).X <= -95 end)
	check("palm avenue on both sides of the road (2+ west, 2+ east)", pw >= 2 and pe >= 2, "west " .. pw .. " east " .. pe)

	-- junction island: clipped round shrubs (topiary), foxtail palms, lava rock, on lawn
	local lawn = anchor("IslandLawn")
	check("IslandLawn: a 0.4-thick green lawn west of the road, x -150..-136", lawn ~= nil and lawn.Size.Y >= 0.4 and lp(lawn).X - lawn.Size.X / 2 >= -150.5 and lp(lawn).X + lawn.Size.X / 2 <= -135.5
		and lawn.Color.G > lawn.Color.R and lawn.Color.G > lawn.Color.B, lawn and tostring(lp(lawn)) or "missing")
	local top = allNamed("Topiary")
	local onIsland = function(p) return lp(p).X >= -150.5 and lp(p).X <= -135.5 and lp(p).Z >= 56 and lp(p).Z <= 102 end
	local colours, yg = {}, 0
	for _, p in ipairs(top) do
		colours[string.format("%d,%d,%d", rgb(p))] = true
		local r, g, b = rgb(p)
		if r >= 150 and g >= 180 and b < 100 then yg += 1 end
	end
	local nc = 0
	for _ in pairs(colours) do nc += 1 end
	check("24+ clipped round Topiary domes on the island, 3+ distinct greens, 2+ yellow-green",
		#top >= 24 and count(top, onIsland) == #top and nc >= 3 and yg >= 2, #top .. " domes, " .. nc .. " colours, " .. yg .. " yellow-green")
	check("2+ lava rocks (IslandRock) and 2+ palms on the island",
		#allNamed("IslandRock") >= 2 and count(palms, function(p) return lp(p).X >= -150 and lp(p).X <= -136 and lp(p).Z >= 56 end) >= 2,
		#allNamed("IslandRock") .. " rocks")
	check("the old flat Hedge boxes are gone", #allNamed("Hedge") == 0, tostring(#allNamed("Hedge")))
	local cb, cl, wb = allNamed("ChainBollard"), allNamed("ChainLink"), allNamed("WaterBarrier")
	check("yellow chain bollards along the island kerb (6+ ChainBollard, 5+ ChainLink) and 2+ orange WaterBarrier",
		#cb >= 6 and #cl >= 5 and count(cb, yellow) == #cb and #wb >= 2 and count(wb, orange) == #wb, #cb .. "/" .. #cl .. "/" .. #wb)

	-- billboard on a steel frame west of the road
	local bp = anchor("BillboardPanel")
	check("BillboardPanel: 20+ wide, 8+ tall, its bottom 12+ above the ground, reads OUTLETS",
		bp ~= nil and math.max(bp.Size.X, bp.Size.Z) >= 20 and bp.Size.Y >= 8 and bp.Position.Y - bp.Size.Y / 2 >= 12 and guiText(bp):upper():find("OUTLETS") ~= nil,
		bp and (fmt(bp.Size.Y) .. " tall, text '" .. guiText(bp) .. "'") or "missing")
	local posts = allNamed("BillboardPost")
	check("two BillboardPost steel posts, 14+ tall", #posts == 2 and posts[1].Size.X >= 14 and posts[2].Size.X >= 14, tostring(#posts))

	-- tenant pylon at the junction (the old 11-stud pylon beside the shops must be gone)
	local pb = anchor("PylonBody")
	check("PylonBody: 20+ tall, at the road mouth (not beside the shops)", pb ~= nil and pb.Size.Y >= 20 and lp(pb).Z >= 85 and lp(pb).X <= -85,
		pb and (fmt(pb.Size.Y) .. " tall at " .. tostring(lp(pb))) or "missing")
	local ps = allNamed("PylonSign")
	local hasPitch = false
	for _, p in ipairs(ps) do if guiText(p):upper():find("ABOITIZ PITCH") then hasPitch = true end end
	check("7 PylonSign tenant panels, one reading ABOITIZ PITCH", #ps == 7 and hasPitch, #ps .. " panels")
	local pc, pcd = anchor("PylonChevron"), anchor("PylonChevronDark")
	check("red chevron (PylonChevron) with a dark-grey backing (PylonChevronDark) beside the pylon",
		pc ~= nil and pcd ~= nil and red(pc) and pb ~= nil and (pc.Position - pb.Position).Magnitude <= 12 and pcd.Color.R * 255 <= 90,
		pc and "has chevron" or "missing")

	-- entrance office
	local ob, od, oc = anchor("OfficeBody"), anchor("OfficeDoor"), anchor("OfficeCanopy")
	check("OfficeBody: a small white block, 7-12 high, with a red door 8+ high and a canopy",
		ob ~= nil and od ~= nil and oc ~= nil and white(ob) and ob.Size.Y >= 7 and ob.Size.Y <= 12 and red(od) and od.Size.Y >= 8.5,
		ob and "body" or "missing")
	local cp = anchor("CarParkSlab")
	check("the car park slab is light concrete and starts at z 61+ (clear of the second block)", cp ~= nil and lightGrey(cp) and lp(cp).Z - cp.Size.Z / 2 >= 61,
		cp and (fmt(lp(cp).Z - cp.Size.Z / 2) .. " min z") or "missing")
end

------------------------------------------------------------------ B: shops, roofs, courtyard
do
	local solar = allNamed("SolarPanel")
	check("the white wing keeps its 12 solar panels", #solar >= 12, tostring(#solar))
	local ss = allNamed("ShopSolar")
	check("the corner shop block has a solar roof (6+ ShopSolar above y 34)", #ss >= 6 and count(ss, function(p) return solarBlue(p) and p.Position.Y >= 34 end) == #ss, tostring(#ss))
	local wf = anchor("WingFascia")
	check("WingFascia: a maroon strip along the white wing's frontage", wf ~= nil and maroon(wf) and wf.Size.X >= 38, wf and "found" or "missing")

	local sb = anchor("SecondBody")
	local s = sb and sh(sb)
	check("SecondBody: a white two-storey block across the courtyard (shop frame x 56..92, z 46..60, 20-24 high)",
		sb ~= nil and white(sb) and near(s.X - sb.Size.X / 2, 56, 1) and near(s.X + sb.Size.X / 2, 92, 1) and near(s.Z - sb.Size.Z / 2, 46, 1)
			and near(s.Z + sb.Size.Z / 2, 60, 1) and sb.Size.Y >= 20 and sb.Size.Y <= 24,
		sb and string.format("x %s..%s z %s..%s h %s", fmt(s.X - sb.Size.X / 2), fmt(s.X + sb.Size.X / 2), fmt(s.Z - sb.Size.Z / 2), fmt(s.Z + sb.Size.Z / 2), fmt(sb.Size.Y)) or "missing")
	check("SecondBody stays 10+ studs from the Guide (shop frame x of its west face >= 53)", sb ~= nil and s.X - sb.Size.X / 2 >= 53, sb and fmt(s.X - sb.Size.X / 2) or "missing")
	local sf = anchor("SecondFascia")
	check("SecondFascia: a maroon roof cap", sf ~= nil and maroon(sf) and sb ~= nil and sf.Size.X >= sb.Size.X, sf and "found" or "missing")
	check("second block glazing: 3+ SecondGlassGround, 3+ SecondGlassUpper, a SecondDoor 8.5+ high",
		#allNamed("SecondGlassGround") >= 3 and #allNamed("SecondGlassUpper") >= 3 and anchor("SecondDoor") ~= nil and anchor("SecondDoor").Size.Y >= 8.5,
		#allNamed("SecondGlassGround") .. "/" .. #allNamed("SecondGlassUpper"))
	local sol2 = allNamed("SecondSolar")
	check("second block solar roof: 8 SecondSolar above y 22", #sol2 >= 8 and count(sol2, function(p) return solarBlue(p) and p.Position.Y >= 22 end) == #sol2, tostring(#sol2))

	local link = anchor("CourtyardLink")
	check("CourtyardLink: a 0.4-thick slab joining the forecourt to the second block (shop frame x 54..94, z 42..46)",
		link ~= nil and link.Size.Y >= 0.4 and near(sh(link).Z, 44, 1.5) and sh(link).X - link.Size.X / 2 <= 55 and sh(link).X + link.Size.X / 2 >= 93,
		link and tostring(sh(link)) or "missing")
	check("courtyard planting: 2 CourtyardPlanter with 4 CourtyardShrub domes, trees kept (3+ TreeCrown)",
		#allNamed("CourtyardPlanter") == 2 and #allNamed("CourtyardShrub") == 4 and #allNamed("TreeCrown") >= 3,
		#allNamed("CourtyardPlanter") .. "/" .. #allNamed("CourtyardShrub") .. "/" .. #allNamed("TreeCrown"))
end

------------------------------------------------------------------ C: pitch and stand
do
	local turf = anchor("PitchTurf")
	check("PitchTurf is bright green (G 140+) and still 62 x 96 at x 90..152", turf ~= nil and turf.Color.G * 255 >= 140 and near(turf.Size.X, 62, 0.5) and near(turf.Size.Z, 96, 0.5)
		and near(lp(turf).X, 121, 1), turf and string.format("G %.0f", turf.Color.G * 255) or "missing")
	check("the stand is kept (StandTiers) with its stair", anchor("StandTiers") ~= nil and #allNamed("StandStair") >= 5)
	local pbk = anchor("PitchBlock")
	check("PitchBlock: a long low block west of the pitch (60+ long, 8-12 high, x 70..84)",
		pbk ~= nil and math.max(pbk.Size.X, pbk.Size.Z) >= 60 and pbk.Size.Y >= 8 and pbk.Size.Y <= 12 and lp(pbk).X >= 70 and lp(pbk).X <= 84,
		pbk and (fmt(math.max(pbk.Size.X, pbk.Size.Z)) .. " long at " .. tostring(lp(pbk))) or "missing")
	local pbs = allNamed("PitchBlockSolar")
	check("PitchBlock has a maroon fascia, 6+ solar panels and 3+ doors 8.5+ high",
		anchor("PitchBlockFascia") ~= nil and maroon(anchor("PitchBlockFascia")) and #pbs >= 6 and count(pbs, solarBlue) == #pbs
			and #allNamed("PitchBlockDoor") >= 3 and count(allNamed("PitchBlockDoor"), function(p) return p.Size.Y >= 8.5 end) >= 3,
		#pbs .. " solar, " .. #allNamed("PitchBlockDoor") .. " doors")
end

------------------------------------------------------------------ D: kept props and whole-site rules
do
	check("entrance sign, estate pedestal and Lipa/Malvar panel are kept",
		anchor("EntranceSign") ~= nil and anchor("Plinth") ~= nil and anchor("PanelTitle") ~= nil and anchor("ShopCanopy") ~= nil and anchor("WalkwayRoof") ~= nil)
	local total, unanchored, outside = 0, {}, {}
	for _, d in ipairs(site:GetDescendants()) do
		if d:IsA("BasePart") and not isRig(d) then
			total += 1
			if not d.Anchored then table.insert(unanchored, d.Name) end
			-- the part's real extent (rotated corners included), the way BuildCheck measures bounds
			local l, cf, sz = lp(d), d.CFrame, d.Size
			local ex = (math.abs(cf.RightVector.X) * sz.X + math.abs(cf.UpVector.X) * sz.Y + math.abs(cf.LookVector.X) * sz.Z) / 2
			local ez = (math.abs(cf.RightVector.Z) * sz.X + math.abs(cf.UpVector.Z) * sz.Y + math.abs(cf.LookVector.Z) * sz.Z) / 2
			if math.abs(l.X) + ex > 165 or math.abs(l.Z) + ez > 110 then table.insert(outside, d.Name .. " " .. tostring(l)) end
		end
	end
	check("every non-rig part is anchored", #unanchored == 0, table.concat(unanchored, ", ", 1, math.min(#unanchored, 6)))
	check("every non-rig part is inside the footprint +10% (|x| <= 165, |z| <= 110)", #outside == 0, table.concat(outside, "; ", 1, math.min(#outside, 4)))
	check("part count is between 600 and 2500", total >= 600 and total <= 2500, tostring(total))
end

return HttpService:JSONEncode(results)
