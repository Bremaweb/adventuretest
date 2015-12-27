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
	output = 'glowcrystals:torch 4',
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


minetest.register_craftitem(":glowcrystals:torch", {
	description = "Glow Crystal Torch",
	inventory_image = "glowcrystals_glowtorch_on_floor.png",
	wield_image = "glowcrystals_glowtorch_on_floor.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
   	on_place = function(itemstack, placer, pointed_thing)
		local above = pointed_thing.above
		local under = pointed_thing.under
		local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})
		if wdir < 1 and not torches.enable_ceiling then
			return itemstack
		end
		local fakestack = itemstack
		local retval = false
		if wdir <= 1 then
			retval = fakestack:set_name("glowcrystals:floor")
		else
			retval = fakestack:set_name("glowcrystals:wall")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("glowcrystals:torch")

		return itemstack
	end
})

minetest.register_node("glowcrystals:floor", {
	description = "Glow Crystal Torch",
	inventory_image = "glowcrystals_glowtorch_on_floor.png",
	wield_image = "glowcrystals_glowtorch_on_floor.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	tiles = { "glowcrystals_glowtorch_on_floor.png"	},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 14,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "glowcrystals:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-1/16, -2/16, -1/16, 1/16, 0.5, 1/16},
		wall_bottom = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
})

minetest.register_node("glowcrystals:wall", {
	inventory_image = "glowcrystals_glowtorch_on_floor.png",
	wield_image = "glowcrystals_glowtorch_on_floor.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = { "glowcrystals_glowtorch_on_floor.png"	},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "glowcrystals:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
})

-- convert old torches and remove ceiling placed
minetest.register_abm({
	nodenames = {"glowcrystals:glowcrystal_torch"},
	interval = 1,
	chance = 1,
	action = function(pos)
		local n = minetest.get_node(pos)
		local def = minetest.registered_nodes[n.name]
		if n and def then
			local wdir = n.param2
			local node_name = "glowcrystals:wall"
			if wdir < 1 and not torches.enable_ceiling then
				minetest.remove_node(pos)
				return
			elseif wdir <= 1 then
				node_name = "glowcrystals:floor"
			end
			minetest.set_node(pos, {name = node_name, param2 = wdir})
		end
	end
})
