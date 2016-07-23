dofile(minetest.get_modpath("mobs").."/api.lua")
dofile(minetest.get_modpath("mobs").."/spawner.lua")
dofile(minetest.get_modpath("mobs").."/npcs/explorer.lua")
dofile(minetest.get_modpath("mobs").."/npcs/men.lua")
dofile(minetest.get_modpath("mobs").."/npcs/women.lua")
dofile(minetest.get_modpath("mobs").."/npcs/blacksmith.lua")
dofile(minetest.get_modpath("mobs").."/npcs/kids.lua")

dofile(minetest.get_modpath("mobs").."/monsters/barbarians.lua")
dofile(minetest.get_modpath("mobs").."/monsters/dirtmonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/dungeonmaster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/oerkki.lua")
dofile(minetest.get_modpath("mobs").."/monsters/sandmonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/spider.lua")
dofile(minetest.get_modpath("mobs").."/monsters/jungle_spider.lua")
dofile(minetest.get_modpath("mobs").."/monsters/stonemonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/treemonster.lua")
dofile(minetest.get_modpath("mobs").."/monsters/yeti.lua")
dofile(minetest.get_modpath("mobs").."/monsters/goblins.lua")

dofile(minetest.get_modpath("mobs").."/animals/rat.lua")
dofile(minetest.get_modpath("mobs").."/animals/sheep.lua")
dofile(minetest.get_modpath("mobs").."/animals/rabbits.lua")

dofile(minetest.get_modpath("mobs").."/icons.lua")

if minetest.setting_get("log_mods") then
	minetest.log("action", "mobs loaded")
end