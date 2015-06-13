magic = { }

local magic_file = minetest.get_worldpath().."/magic"
local magicpath = minetest.get_modpath("magic")
magic.player_magic = default.deserialize_from_file(magic_file)

hud.register("magic", {
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	offset = {x=-262,y=-113},
	size = HUD_SB_SIZE,
	text = "hud_magic_fg.png",
	number = 20,
	alignment = {x=-1,y=-1},
	background = "hud_magic_bg.png",
	--autohide_bg = true,
	max = 20,
    })


dofile(magicpath.."/api.lua")

function magic.update_magic(player,name)
	if minetest.check_player_privs(name, {immortal=true}) then
		magic.player_magic[name] = 20
		return
	end
	local s = skills.get_skill(name,SKILL_MAGIC)
	local baseAdj = 2
	if magic.player_magic[name] ~= nil then
		if default.player_get_animation(player) == "lay" then
			baseAdj = baseAdj + 3
		end
		
		if default.player_get_animation(player) == "sit" then
			baseAdj = baseAdj + 1
		end
		
		local adj = baseAdj * ( s.level / 10 )
	
		magic.player_magic[name] = magic.player_magic[name] + adj
	
		if magic.player_magic[name] > 20 then
			magic.player_magic[name] = 20
		end
		if magic.player_magic[name] < 0 then
			magic.player_magic[name] = 0
		end
	else
		magic.player_magic[name] = 20
	end
end

minetest.register_on_shutdown(function()
	default.serialize_to_file(magic_file,magic.player_magic)
end)


-- load magic spells
dofile(magicpath.."/thunder.lua")
dofile(magicpath.."/magicmissle.lua")
dofile(magicpath.."/heal.lua")