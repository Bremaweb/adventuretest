magic = { }
local magicpath = minetest.get_modpath("magic")
hud.register("magic", {
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	offset = {x=-262,y=-113},
	size = HUD_SB_SIZE,
	text = "hud_magic_fg.png",
	number = 20,
	alignment = {x=-1,y=-1},
	background = "hud_magic_bg.png",
	autohide_bg = true,
	max = 20,
    })


dofile(magicpath.."/api.lua")

function magic.update_magic(player,name)
	if minetest.check_player_privs(name, {immortal=true}) then
		pd.set(name,"mana",20)
		hud.change_item(player,"magic", {number = 20})
		return
	end
	local s = skills.get_skill(name,SKILL_MAGIC)
	local baseAdj = 2
	local mana = pd.get_number(name,"mana")	
		if default.player_get_animation(player) == "lay" then
			baseAdj = baseAdj + 3
		end
		
		if default.player_get_animation(player) == "sit" then
			baseAdj = baseAdj + 1
		end
		
		local adj = baseAdj * ( s.level / 10 )
	
		mana = mana + adj
	
		if mana > 20 then
			mana = 20
		end
		if mana < 0 then
			mana = 0
		end	
	pd.set(name,"mana",mana)
	hud.change_item(player,"magic", {number = mana})
end

-- load magic spells
dofile(magicpath.."/thunder.lua")
dofile(magicpath.."/magicmissle.lua")
dofile(magicpath.."/heal.lua")

adventuretest.register_pl_hook(magic.update_magic,4)