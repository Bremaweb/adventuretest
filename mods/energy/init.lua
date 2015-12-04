energy = {}

dofile(minetest.get_modpath("energy").."/energy.lua")

hud.register("energy", {
	hud_elem_type = "statbar",
	position = {x = 0.5, y = 1},
	offset = {x=15,y=-113},
	size = HUD_SB_SIZE,
	text = "hud_energy_fg.png",
	number = 20,
	alignment = {x=-1,y=-1},
	background = "hud_energy_bg.png",
	--autohide_bg = true,
	max = 20,
})

local energy_tick = 5
adventuretest.register_pl_hook(energy.update_energy,energy_tick)