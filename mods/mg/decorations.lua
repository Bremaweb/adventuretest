

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:desert_sand"},
	sidelen = 80,
	noise_params = {
		offset = -0.0005,
		scale = 0.0015,
		spread = {x=200, y=200, z=200},
		seed = 230,
		octaves = 3,
		persist = 0.6
	},
	biomes = {"desert"},
	y_min = 2,
	y_max = 70,
	decoration = "default:cactus",
	height = 2,
	height_max = 4,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:sand","default:desert_sand","default:river_gravel"},
	spawn_by = "default:mg_water_source",
	num_spawn_by = 1,
	sidelen = 16,
	noise_params = {
		offset = -0.3,
		scale = 0.7,
		spread = {x=200, y=200, z=200},
		seed = 354,
		octaves = 3,
		persist = 0.7
	},
	y_min = -2,
	y_max = 70,
	decoration = "default:papyrus",
	height = 3,
	height_max = 5,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:desert_sand"},
	sidelen = 80,
	noise_params = {
		offset = -0.0005,
		scale = 0.0015,
		spread = {x=200, y=200, z=200},
		seed = 230,
		octaves = 3,
		persist = 0.6
	},
	biomes = {"desert"},
	y_min = 2,
	y_max = 155,
	decoration = "default:cactus",
	height = 2,
	height_max = 5,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"mg:dirt_with_dry_grass"},
	sidelen = 40,
	fill_ratio = 0.0008,
	biomes = {"savanna"},
	y_min = 2,
	y_max = 40,
	schematic = minetest.get_modpath("mg") .. "/schematics/acacia_tree.mts",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"mg:dirt_with_dry_grass","default:desert_sand"},
	sidelen = 40,
	fill_ratio = 0.05,
	biomes = {"savanna","desert"},
	y_min = 2,
	y_max = 40,
	decoration = "default:dry_shrub",
})


-- Apple tree

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	noise_params = {
		offset = 0.04,
		scale = 0.02,
		spread = {x=250, y=250, z=250},
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"forest"},
	y_min = 1,
	y_max = 155,
	schematic = minetest.get_modpath("mg").."/schematics/apple_tree.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	fill_ratio = 0.0005,
	biomes = {"plains","hot_plains"},
	y_min = 1,
	y_max = 155,
	schematic = minetest.get_modpath("mg").."/schematics/apple_tree.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_snow"},
	sidelen = 80,
	noise_params = {
		offset = -0.3,
		scale = 0.7,
		spread = {x=200, y=200, z=200},
		seed = 354,
		octaves = 3,
		persist = 0.7
	},
	y_min = -2,
	y_max = 70,
	schematic = minetest.get_modpath("mg").."/schematics/pine_tree.mts",
})

-- Jungle tree

minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	fill_ratio = 0.08,
	biomes = {"jungle"},
	y_min = -1,
	y_max = 155,
	schematic = minetest.get_modpath("mg").."/schematics/jungle_tree.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 80,
	fill_ratio = 0.9,
	biomes = {
		"jungle",
	},
	y_min = 0,
	y_max = 155,
	decoration = "default:junglegrass",
})



minetest.register_decoration({
	deco_type = "schematic",
	place_on = {"default:desert_sand"},
	sidelen = 80,
	noise_params = {
		offset = -0.0005,
		scale = 0.0015,
		spread = {x=200, y=200, z=200},
		seed = 230,
		octaves = 3,
		persist = 0.6
	},
	biomes = {"desert"},
	y_min = 2,
	y_max = 31000,
	schematic = minetest.get_modpath("mg").."/schematics/large_cactus.mts",
	flags = "place_center_x",
	rotation = "random",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.03,
		scale = 0.09,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {
		"plains","forest","hot_plains",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_5",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.02,
		scale = 0.09,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 4,
		persist = 0.8
	},
	biomes = {
		"forest",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_5",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.03,
		scale = 0.1,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 3,
		persist = 0.8
	},
	biomes = {
		"forest",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_5",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.03,
		scale = 0.1,
		spread = {x=200, y=200, z=200},
		seed = 322,
		octaves = 3,
		persist = 0.8
	},
	biomes = {
		"forest",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_5",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = -0.015,
		scale = 0.075,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {
		"plains","forest","hot_plains",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_4",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.06,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {
		"plains","forest","hot_plains",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_3",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0.015,
		scale = 0.045,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {
		"plains","forest","hot_plains",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_2",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	noise_params = {
		offset = 0.03,
		scale = 0.03,
		spread = {x=200, y=200, z=200},
		seed = 329,
		octaves = 3,
		persist = 0.6
	},
	biomes = {
		"plains","forest","hot_plains",
	},
	y_min = 3,
	y_max = 155,
	decoration = "default:grass_1",
})