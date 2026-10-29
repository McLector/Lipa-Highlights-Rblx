-- site02_front: the front of Site 02 (Candido B. Lopez Memorial Public Market), rebuilt from PublicMarketBP1.jpg (Slice 4, job 4b).
-- Studio copy: ServerStorage.Builders.site02_front. Assembler: builders/site02.luau. Check: tests/site02_check.luau, group "hall".
-- Owns: the portico of the pavilion (inside Structure/Hall/Shell), the two stairs (Structure/Stairs) and the rooftop pipe scaffold over the
-- south wing (Structure/Scaffold). The portico is a low terrace on 4 slim posts, open above (BP1); the pavilion hip roof (site02_hall) stops at the body.
-- All numbers are WORLD (x east, z south, y up); env.wbox / env.wvcyl / env.W convert to the assembler's local frame (local = world - ORIGIN).
-- Pure function of env: nothing is read from the DataModel. Naming contract: briefs/site02.md.
return function(env)
	local V, CF, ANG, PI = env.V, env.CF, env.ANG, env.PI
	local W, wbox, wvcyl = env.W, env.wbox, env.wvcyl
	local C3 = Color3.fromRGB
	local MCON, MSMO, MCOR = Enum.Material.Concrete, Enum.Material.SmoothPlastic, Enum.Material.CorrodedMetal
	local WALL, RED, DRED, PAVE, STEP = C3(230, 226, 214), C3(176, 62, 50), C3(146, 46, 40), C3(150, 146, 138), C3(150, 146, 138)
	local RUST = C3(128, 98, 82)

	-- a thin beam between two WORLD points (length along the part's local Z)
	local function beam(ctx, name, a, b, t, color, material)
		local la, lb = W(a.X, a.Y, a.Z), W(b.X, b.Y, b.Z)
		return ctx:part(name, V(t, t, (lb - la).Magnitude), CFrame.lookAt((la + lb) / 2, lb), color, material)
	end

	------------------------------------------------------------------ portico (Structure/Hall/Shell)
	-- BP1: the pavilion's projection is a low terrace at floor-2 height (deck top y 9.5) on 4 slim round red posts, with a balustrade round the front
	-- and both sides, open above and with no roof over it (the pavilion hip roof stops at the body, x -262.6). The two stairs land on the deck at its
	-- north and south ends, so the side rails stop at x -256.5. A short flight of 4 ground steps stands at the terrace's south-front corner.
	-- Every Portico part stops at x -250.4: the aisle box (x -250.4..-228) and the Guide boxes stay free.
	env.section("Hall/Shell", function(ctx)
		local XC, XW0, XE0 = -251.8, -253.2, -250.4
		wbox(ctx, "PorticoBase1", -262.6, XE0, 0, 0.45, 145.6, 174.4, PAVE, MCON)
		for i, z in ipairs({ 148, 156, 164, 172 }) do
			wbox(ctx, "PorticoPlinth" .. i, XW0, XE0, 0, 0.9, z - 1.4, z + 1.4, WALL, MCON)
			wvcyl(ctx, "PorticoColumn" .. i, XC, z, 0, 9.3, 1.8, RED, MSMO) -- top 9.3 hides inside the deck slab (8.5..9.5)
		end
		wbox(ctx, "PorticoDeck", -262.6, XE0, 8.5, 9.5, 145.6, 174.4, WALL, MCON)
		wbox(ctx, "PorticoFascia1", -251.0, XE0, 7.9, 8.5, 145.6, 174.4, DRED, MSMO)
		-- balustrade: front rail along x -251.0, side rails from the landings' end (x -256.5) to the front; rail top 12.5, posts 3.0 tall
		wbox(ctx, "Balustrade2P1", -251.3, -250.7, 12.1, 12.5, 145.6, 174.4, WALL, MCON)
		wbox(ctx, "Balustrade2P2", -256.5, -250.7, 12.1, 12.5, 145.6, 146.2, WALL, MCON)
		wbox(ctx, "Balustrade2P3", -256.5, -250.7, 12.1, 12.5, 173.8, 174.4, WALL, MCON)
		local post = 100
		local function railPost(x, z)
			post += 1
			wbox(ctx, "RailPost" .. post, x - 0.25, x + 0.25, 9.5, 12.5, z - 0.25, z + 0.25, WALL, MCON)
		end
		for k = 0, 10 do railPost(-251.0, 146.0 + 28.0 * k / 10) end
		for _, x in ipairs({ -256.2, -254.2, -252.2 }) do
			railPost(x, 145.9)
			railPost(x, 174.1)
		end
		-- ground flight: step 4 touches the deck's south edge, step 1 is the lowest and farthest south; each rises 0.5, depth 1.5
		for i = 1, 4 do
			local z0 = 174.6 + (4 - i) * 1.5
			wbox(ctx, "PorchStep" .. i, -255.0, -250.6, 0, 0.5 * i, z0, z0 + 1.5, STEP, MCON)
		end
	end)

	------------------------------------------------------------------ stairs (Structure/Stairs)
	-- Two stairs, mirror-symmetric about z 160, climbing toward the pavilion alongside the facade. Each step is a solid block (width 6, height
	-- = tread above ground, rise 0.94), yawed to follow the line from the foot (x -254, z 94.6) to the top step (x -259.5, z 144.5).
	env.section("Stairs", function(ctx)
		local RISE, WIDTH, DEPTH = 0.94, 6.0, 5.6
		local P1, P10 = { -254.0, 94.6 }, { -259.5, 144.5 }
		local theta = math.atan2(P10[1] - P1[1], P10[2] - P1[2]) -- yaw of the run direction (local Z) for the north stair
		for _, st in ipairs({ { "N", 1, 0 }, { "S", -1, 320 } }) do
			local letter, flip, zoff = st[1], st[2], st[3]
			local yaw = theta * flip
			local function centre(i)
				local f = (i - 1) / 9
				local z = P1[2] + (P10[2] - P1[2]) * f
				return P1[1] + (P10[1] - P1[1]) * f, (flip == 1) and z or (zoff - z)
			end
			for i = 1, 10 do
				local cx, cz = centre(i)
				local h = RISE * i
				ctx:part("Step" .. letter .. i, V(WIDTH, h, DEPTH), CF(W(cx, h / 2, cz)) * ANG(0, yaw, 0), STEP, MCON)
			end
			-- landing in front of the pavilion, level with the floor-2 deck (top 9.5), flush with the deck end at z 145.6 / 174.4
			if letter == "N" then
				wbox(ctx, "StairLandingN", -262.6, -256.5, 0, 9.5, 145.6, 148.0, WALL, MCON)
			else
				wbox(ctx, "StairLandingS", -262.6, -256.5, 0, 9.5, 172.0, 174.4, WALL, MCON)
			end
			-- rails: 4 posts (steps 1, 4, 7, 10) on each side, 3 tall; a top rail and a mid rail per side
			local perp = { math.cos(yaw), -math.sin(yaw) } -- sideways unit vector in (x, z)
			local n = 0
			for _, side in ipairs({ 1, -1 }) do
				for _, k in ipairs({ 1, 4, 7, 10 }) do
					local cx, cz = centre(k)
					local h = RISE * k
					n += 1
					ctx:part("StairPost" .. letter .. n, V(0.4, 3.0, 0.4), CF(W(cx + perp[1] * side * 2.85, h + 1.5, cz + perp[2] * side * 2.85)) * ANG(0, yaw, 0), WALL, MCON)
				end
			end
			local r = 0
			for _, side in ipairs({ 1, -1 }) do
				for _, lift in ipairs({ 2.85, 1.5 }) do
					local ax, az = centre(1)
					local bx, bz = centre(10)
					local a = V(ax + perp[1] * side * 2.85, RISE * 1 + lift, az + perp[2] * side * 2.85)
					local b = V(bx + perp[1] * side * 2.85, RISE * 10 + lift, bz + perp[2] * side * 2.85)
					r += 1
					beam(ctx, "StairRail" .. letter .. r, a, b, 0.3, WALL, MCON)
				end
			end
		end
	end)

	------------------------------------------------------------------ scaffold (Structure/Scaffold)
	-- Rooftop steel-pipe lattice over the SOUTH wing only: two panels side by side (P1 z 205.3..231, P2 z 177.6..203.8), front plane x -264.5,
	-- rear legs x -272.5. Open lattice: posts, 4 rails, one diagonal per bay, 2 side trusses and 2 top ties per panel. No text, no gui, no decal.
	env.section("Scaffold", function(ctx)
		local XF, XR = -264.5, -272.5
		local YF, YR, YT = 30.6, 32.4, 50.6 -- front foot, rear foot (the wing roof rises toward its ridge), top
		local railY = { 35.0, 41.0, 47.0, 50.4 }
		local bandY = { 30.9, 35.0, 41.0, 47.0 }
		for pi, zr in ipairs({ { 205.3, 231.0 }, { 177.6, 203.8 } }) do
			local tag = "ScaffoldP" .. pi
			local z0, z1 = zr[1] + 0.25, zr[2] - 0.25
			local zs = {}
			for k = 1, 5 do zs[k] = z0 + (z1 - z0) * (k - 1) / 4 end
			for k = 1, 5 do
				wbox(ctx, tag .. "Post" .. k, XF - 0.25, XF + 0.25, YF, YT, zs[k] - 0.25, zs[k] + 0.25, RUST, MCOR)
			end
			wbox(ctx, tag .. "Post6", XR - 0.25, XR + 0.25, YR, YT, z0 - 0.25, z0 + 0.25, RUST, MCOR)
			wbox(ctx, tag .. "Post7", XR - 0.25, XR + 0.25, YR, YT, z1 - 0.25, z1 + 0.25, RUST, MCOR)
			for j, y in ipairs(railY) do
				wbox(ctx, tag .. "Rail" .. j, XF - 0.2, XF + 0.2, y - 0.2, y + 0.2, z0 - 0.25, z1 + 0.25, RUST, MCOR)
			end
			local b = 0
			for j = 1, 3 do
				for k = 1, 4 do
					local ya, yb = bandY[j], bandY[j + 1]
					local lowZ, highZ = zs[k], zs[k + 1]
					if (j + k) % 2 == 1 then lowZ, highZ = highZ, lowZ end
					b += 1
					beam(ctx, tag .. "Brace" .. b, V(XF, ya, lowZ), V(XF, yb, highZ), 0.35, RUST, MCOR)
				end
			end
			-- side trusses (diagonals front foot to rear top) and top ties at each end
			local t = 0
			for _, z in ipairs({ z0, z1 }) do
				t += 1
				beam(ctx, tag .. "Truss" .. t, V(XF, 31.4, z), V(XR, 49.8, z), 0.4, RUST, MCOR)
			end
			for _, z in ipairs({ z0, z1 }) do
				t += 1
				beam(ctx, tag .. "Truss" .. t, V(XF, 50.4, z), V(XR, 50.4, z), 0.4, RUST, MCOR)
			end
		end
	end)
end
