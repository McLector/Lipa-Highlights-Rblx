-- site10_blocks: the 72 ElevatedBlock volumes of Site 10 (New Lipa City Hall), a 6 by 12 grid. Studio copy: ServerStorage.Builders.site10_blocks.
-- Owner container: Blocks. Checks group: shared.site10_only = "blocks". Brief section: The 72 blocks (briefs/site10.md).
-- Loaded by builders/site10.luau; see the MODULE CONTRACT header there for the env table (env.section, env.box, env.budget ...).
-- Coordinates are LOCAL to ORIGIN (y = height above ground). Per block (centres lx -50..0 pitch 10, lz -55..55 pitch 10):
--   ElevatedBlock  7 x 6 x 7, underside y 9, top y 15, Brick, colour (214, 206, 190).
--   BlockPilotis   4 per block, 0.8 square concrete columns from y 0 to y 9 at the corners (centres +-2.8 from the block centre),
--                  so the middle 4 x 4 under each block stays clear.
--   BlockCap       mortar band on the top, 0.5 tall, 7.4 x 7.4, colour (170, 150, 130), Concrete.
-- Parts planned: 72 + 288 + 72 = 432 of the 600 budget. Plain: no text, decals, textures or images. One env.section("Blocks") call.
return function(env)
	local BRICK = Color3.fromRGB(214, 206, 190)
	local PILOTI = Color3.fromRGB(190, 192, 190)
	local CAP = Color3.fromRGB(170, 150, 130)

	env.section("Blocks", function(ctx)
		for row = 0, 5 do
			local lx = -50 + row * 10 -- 6 rows along x: -50, -40, ..., 0
			for col = 0, 11 do
				local lz = -55 + col * 10 -- 12 columns along z: -55, -45, ..., 55
				env.box(ctx, "ElevatedBlock", lx - 3.5, lx + 3.5, 9, 15, lz - 3.5, lz + 3.5, BRICK, Enum.Material.Brick)
				env.box(ctx, "BlockCap", lx - 3.7, lx + 3.7, 15, 15.5, lz - 3.7, lz + 3.7, CAP, Enum.Material.Concrete)
				for _, sx in ipairs({ -1, 1 }) do
					for _, sz in ipairs({ -1, 1 }) do
						local px, pz = lx + sx * 2.8, lz + sz * 2.8
						env.box(ctx, "BlockPilotis", px - 0.4, px + 0.4, 0, 9, pz - 0.4, pz + 0.4, PILOTI, Enum.Material.Concrete)
					end
				end
			end
		end
	end)
end
