-- VARIOUS MISC ADVENTURETEST RELATED STUFF
adventuretest = {}

game_origin = nil
if minetest.setting_get("game_origin") ~= nil then
	game_origin = minetest.string_to_pos(minetest.setting_get("game_origin"))
else
	game_origin = {x=0,y=3,z=0}
end

dofile(minetest.get_modpath("adventuretest").."/functions.lua");
dofile(minetest.get_modpath("adventuretest").."/register_functions.lua");
dofile(minetest.get_modpath("adventuretest").."/privs.lua")
