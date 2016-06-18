-- Minetest 0.4 mod: farming
-- See README.txt for licensing and other information.

farming = {}

farming.registered_plants = {}

-- Boilerplate to support localized strings if intllib mod is installed.
if (minetest.get_modpath("intllib")) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	farming.S = intllib.Getter(minetest.get_current_modname())
else
	farming.S = function ( s ) return s end
end

farming.seeds = {
	["farming_plus:pumpkin_seed"]=60,
	["farming_plus:strawberry_seed"]=30,
	["farming_plus:rhubarb_seed"]=30,
	["farming_plus:potatoe_seed"]=30,
	["farming_plus:tomato_seed"]=30,
	["farming_plus:orange_seed"]=30,
	["farming_plus:carrot_seed"]=30,
}

dofile(minetest.get_modpath("farming_plus").."/functions.lua")
--
-- Soil
--
dofile(minetest.get_modpath("farming_plus").."/soil.lua")

--
-- Hoes
--
dofile(minetest.get_modpath("farming_plus").."/tools.lua")

--
-- Override grass for drops
--
dofile(minetest.get_modpath("farming_plus").."/grass.lua")

-- ========= WHEAT =========
dofile(minetest.get_modpath("farming_plus").."/wheat.lua")

-- ========= COTTON =========
dofile(minetest.get_modpath("farming_plus").."/cotton.lua")

-- ========= STRAWBERRIES =========
dofile(minetest.get_modpath("farming_plus").."/strawberries.lua")

-- ========= RHUBARB =========
dofile(minetest.get_modpath("farming_plus").."/rhubarb.lua")

-- ========= POTATOES =========
dofile(minetest.get_modpath("farming_plus").."/potatoes.lua")

-- ========= TOMATOES =========
dofile(minetest.get_modpath("farming_plus").."/tomatoes.lua")

-- ========= ORANGES =========
dofile(minetest.get_modpath("farming_plus").."/oranges.lua")

-- ========= BANANAS =========
dofile(minetest.get_modpath("farming_plus").."/bananas.lua")

-- ========= CARROTS =========
dofile(minetest.get_modpath("farming_plus").."/carrots.lua")

-- ========= COCOA =========
dofile(minetest.get_modpath("farming_plus").."/cocoa.lua")

-- ========= PUMPKIN =========
dofile(minetest.get_modpath("farming_plus").."/pumpkin.lua")

-- ========= WEED =========
dofile(minetest.get_modpath("farming_plus").."/weed.lua")


dofile(minetest.get_modpath("farming_plus").."/aliases.lua")


