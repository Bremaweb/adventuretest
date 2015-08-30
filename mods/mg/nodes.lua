minetest.register_alias("mapgen_stone", "default:stone")
minetest.register_alias("mapgen_dirt", "default:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "default:dirt_with_grass")
minetest.register_alias("mapgen_sand", "default:sand")
minetest.register_alias("mapgen_water_source", "default:water_source")
minetest.register_alias("mapgen_river_water_source", "default:water_source")
minetest.register_alias("mapgen_lava_source", "default:lava_source")
minetest.register_alias("mapgen_gravel", "default:gravel")
minetest.register_alias("mapgen_desert_stone", "default:desert_stone")
minetest.register_alias("mapgen_desert_sand", "default:desert_sand")
minetest.register_alias("mapgen_dirt_with_snow", "default:dirt_with_snow")
minetest.register_alias("mapgen_snowblock", "default:snowblock")
minetest.register_alias("mapgen_snow", "default:snow")
minetest.register_alias("mapgen_ice", "default:ice")
minetest.register_alias("mapgen_sandstone", "default:sandstone")
minetest.register_alias("mapgen_mossycobble", "default:mossycobble")
minetest.register_alias("mapgen_cobble","default:cobble")
minetest.register_alias("mapgen_stair_cobble","stairs:stair_cobble")

minetest.register_alias("default:acacia_tree", "mg:savannatree")
minetest.register_alias("default:acacia_leaves", "mg:savannaleaves")

minetest.register_alias("default:pine_needles", "mg:pineleaves")
minetest.register_alias("default:pinetree", "mg:pinetree")

minetest.register_node("mg:savannatree", {
	description = "Savannawood Tree",
	tiles = {"mg_dry_tree_top.png", "mg_dry_tree_top.png", "mg_dry_tree.png"},
	groups = {tree=1,choppy=2,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("mg:savannaleaves", {
	description = "Savannawood Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"mg_dry_leaves.png"},
	paramtype = "light",
	walkable=false,
	climbable=true,
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	waving = 1,
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mg:savannasapling'},
				rarity = 20,
			},
			{
				items = {'mg:savannaleaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("mg:savannawood", {
	description = "Savannawood Planks",
	tiles = {"mg_dry_wood.png"},
	groups = {choppy=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = 'mg:savannawood 4',
	recipe = {
		{'mg:savannatree'},
	}
})

minetest.register_node("mg:savannasapling", {
	description = "Savannawood Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"mg_dry_sapling.png"},
	inventory_image = "mg_dry_sapling.png",
	wield_image = "mg_dry_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("mg:savannasapling_ongen", {
	description = "Savannawood Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"mg_dry_sapling.png"},
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mg:savannasapling'},
				
			},
		}
	},
})


minetest.register_abm({
	nodenames = {"mg:savannasapling"},
	interval = 10,
	chance = 50,
	action = function(pos, node)
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map({x=pos.x-10, y=pos.y, z=pos.z-10}, {x=pos.x+10, y=pos.y+20, z=pos.z+10})
		local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
		local data = vm:get_data()
		add_savannatree(data, a, pos.x, pos.y, pos.z, minp, maxp, PseudoRandom(math.random(1,100000)))
		vm:set_data(data)
		vm:write_to_map(data)
		vm:update_map()
	end
})

minetest.register_node("mg:dirt_with_dry_grass", {
	description = "Dry Grass",
	tiles = {"mg_dry_grass.png", "default_dirt.png", "default_dirt.png^mg_dry_grass_side.png"},
	is_ground_content = true,
	groups = {crumbly=3,soil=1},
	drop = 'default:dirt',
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_grass_footstep", gain=0.25},
	}),
})

minetest.register_abm({
	nodenames = {"mg:dirt_with_dry_grass"},
	neighbors = {"default:water_source","default:water_flowing","default:dirt_with_snow","default:snow","default:snowblock"},
	interval = 2,
	chance = 200,
	action = function(pos, node)
		local above = {x=pos.x, y=pos.y+1, z=pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if nodedef and (nodedef.sunlight_propagates or nodedef.paramtype == "light")
				and nodedef.liquidtype == "none"
				and (minetest.get_node_light(above) or 0) >= 13 then
			if name == "default:snow" or name == "default:snowblock" then
				minetest.set_node(pos, {name = "default:dirt_with_snow"})
			else
				minetest.set_node(pos, {name = "default:dirt_with_grass"})
			end
		end
	end
})

minetest.register_abm({
	nodenames = {"mg:dirt_with_dry_grass"},
	interval = 2,
	chance = 20,
	action = function(pos, node)
		local above = {x=pos.x, y=pos.y+1, z=pos.z}
		local name = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[name]
		if name ~= "ignore" and nodedef
				and not ((nodedef.sunlight_propagates or nodedef.paramtype == "light")
				and nodedef.liquidtype == "none") then
			minetest.set_node(pos, {name = "default:dirt"})
		end
	end
})


minetest.register_node("mg:pinetree", {
	description = "Pine Tree",
	tiles = {"mg_pine_tree_top.png", "mg_pine_tree_top.png", "mg_pine_tree.png"},
	groups = {tree=1,choppy=2,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("mg:pineleaves", {
	description = "Pine Leaves",
	drawtype = "allfaces_optional",
	visual_scale = 1.3,
	tiles = {"mg_pine_leaves.png"},
	walkable=false,
	climbable=true,
	paramtype = "light",
	groups = {snappy=3, leafdecay=3, flammable=2, leaves=1},
	waving = 1,
	drop = {
		max_items = 1,
		items = {
			{
				items = {'mg:pinesapling'},
				rarity = 20,
			},
			{
				items = {'mg:pineleaves'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("mg:pinewood", {
	description = "Pine Planks",
	tiles = {"mg_pine_wood.png"},
	groups = {choppy=2,flammable=3,wood=1},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output = 'mg:pinewood 4',
	recipe = {
		{'mg:pinetree'},
	}
})

minetest.register_node("mg:pinesapling", {
	description = "Pine Sapling",
	drawtype = "plantlike",
	visual_scale = 1.0,
	tiles = {"mg_pine_sapling.png"},
	inventory_image = "mg_pine_sapling.png",
	wield_image = "mg_pine_sapling.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.35, 0.3}
	},
	groups = {snappy=2,dig_immediate=3,flammable=2,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_abm({
	nodenames = {"mg:pinesapling"},
	interval = 10,
	chance = 50,
	action = function(pos, node)
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map({x=pos.x-10, y=pos.y, z=pos.z-10}, {x=pos.x+10, y=pos.y+30, z=pos.z+10})
		local a = VoxelArea:new{MinEdge=minp, MaxEdge=maxp}
		local data = vm:get_data()
		add_pinetree(data, a, pos.x, pos.y, pos.z, minp, maxp, PseudoRandom(math.random(1,100000)), c_air)
		vm:set_data(data)
		vm:write_to_map(data)
		vm:update_map()
	end
})

minetest.register_node("mg:ignore", {
	description = "MG Ignore",
	drawtype = "airlike",
	sunlight_propagates = true,
	walkable=false,
	pointable=false,
	groups = {snappy=2,not_in_creative_inventory=1},
})
