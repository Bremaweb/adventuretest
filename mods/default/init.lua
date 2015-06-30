-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into doc/lua_api.txt

WATER_ALPHA = 160
WATER_VISC = 1
LAVA_VISC = 7
LIGHT_MAX = 14

intllib=minetest.get_modpath("intllib")

-- Definitions made by this mod that other mods can use too
default = {}

-- HAVE TO PUT SKILL IDS HERE BECAUSE THEY ARE USED IN nodes.lua and others
-- CONSTANT IDs
SKILL_WOOD    = 1
SKILL_STONE   = 2
SKILL_METAL   = 4
SKILL_CRYSTAL = 8

SKILL_SMELTING= 16
SKILL_CRAFTING= 32
SKILL_ARROW   = 64
SKILL_MAGIC   = 128

-- Load files
dofile(minetest.get_modpath("default").."/functions.lua")
dofile(minetest.get_modpath("default").."/nodes.lua")
dofile(minetest.get_modpath("default").."/tools.lua")
dofile(minetest.get_modpath("default").."/craftitems.lua")
dofile(minetest.get_modpath("default").."/crafting.lua")
dofile(minetest.get_modpath("default").."/mapgen.lua")
dofile(minetest.get_modpath("default").."/player.lua")
dofile(minetest.get_modpath("default").."/trees.lua")
