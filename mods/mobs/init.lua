dofile(minetest.get_modpath("mobs").."/api.lua")
dofile(minetest.get_modpath("mobs").."/spawner.lua")
dofile(minetest.get_modpath("mobs").."/npcs/explorer.lua")
dofile(minetest.get_modpath("mobs").."/npcs/men.lua")
dofile(minetest.get_modpath("mobs").."/npcs/women.lua")

dofile(minetest.get_modpath("mobs").."/monsters/barbarians.lua")
dofile(minetest.get_modpath("mobs").."/monsters/dirtmonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/dungeonmaster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/oerkki.lua")
dofile(minetest.get_modpath("mobs").."/monsters/sandmonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/spider.lua")
dofile(minetest.get_modpath("mobs").."/monsters/stonemonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/treemonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/yeti.lua")

dofile(minetest.get_modpath("mobs").."/animals/rat.lua")
dofile(minetest.get_modpath("mobs").."/animals/sheep.lua")
dofile(minetest.get_modpath("mobs").."/animals/rabbits.lua")


--[[NPCs and Barbarians to be randomly spawned in villages
mobs.npcs = { 

				[0] = "mobs:female1_npc", 
				[1] = "mobs:female2_npc", 
				[2] = "mobs:female3_npc", 
				[3] = "mobs:male1_npc", 
				[4] = "mobs:male2_npc",
				[5] = "mobs:male3_npc",
				[6] = "mobs:explorer"
			}


mobs.barbarians = {
				[0] = "mobs:barbarian1", 
				[1] = "mobs:barbarian2"
				}
]]
if minetest.setting_get("log_mods") then
	minetest.log("action", "mobs loaded")
end