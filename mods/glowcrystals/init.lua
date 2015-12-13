--[[
Glowcrystals
A Minetest mod by SegFault22

Details: Adds several items for lighting, made out of glowing crystals - a better alternative to those ugly infini-torches.
--]]


--///////////////
-- Ores & Blocks
--///////////////

minetest.register_node( "glowcrystals:glowcrystal_ore", {
	description = "Glowing Crystal Ore",
	tiles = { "default_stone.png^glowcrystals_ore_glowcrystal.png" },
	is_ground_content = true,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 12,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	drop = 'craft "glowcrystals:glowcrystal" 1',
})

minetest.register_node( "glowcrystals:glowcrystal_block", {
	description = "Glowing Crystal Block",
	tiles = { "glowcrystals_block_glowcrystal.png" },
	is_ground_content = true,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 22,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("glowcrystals:glowcrystal_torch", {
	description = "Glowing Crystal Torch",
	drawtype = "torchlike",
	tiles = {"glowcrystals_glowtorch_on_floor.png", "glowcrystals_glowtorch_on_ceiling.png", "glowcrystals_glowtorch.png"},
	inventory_image = "glowcrystals_glowtorch_on_floor.png",
	wield_image = "glowcrystals_glowtorch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 14,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
})

--///////
-- Items
--///////

minetest.register_craftitem( "glowcrystals:glowcrystal", {
	description = "Glowing Crystal",
	inventory_image = "glowcrystals_item_glowcrystal.png",
	on_place_on_ground = minetest.craftitem_place_item,
})

--//////////
-- Crafting
--//////////

minetest.register_craft( {
	output = 'node "glowcrystals:glowcrystal_block" 1',
	recipe = {
		{ 'craft "glowcrystals:glowcrystal"', 'craft "glowcrystals:glowcrystal"', 'craft "glowcrystals:glowcrystal"' },
		{ 'craft "glowcrystals:glowcrystal"', 'craft "glowcrystals:glowcrystal"', 'craft "glowcrystals:glowcrystal"' },
		{ 'craft "glowcrystals:glowcrystal"', 'craft "glowcrystals:glowcrystal"', 'craft "glowcrystals:glowcrystal"' },
	}
})

minetest.register_craft({
	output = 'glowcrystals:glowcrystal 9',
	recipe = {
		{'glowcrystals:glowcrystal_block'},
	}
})

minetest.register_craft({
	output = 'glowcrystals:glowcrystal_torch 4',
	recipe = {
		{'glowcrystals:glowcrystal'},
		{'default:stick'},
	}
})

--/////////////////////////
--Ore Generation
--/////////////////////////

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "glowcrystals:glowcrystal_ore",
    wherein        = "default:stone",
    clust_scarcity = 9*9*9,
    clust_num_ores = 4,
    clust_size     = 3,
    y_min     = -20000,
    y_max     = -15,
})