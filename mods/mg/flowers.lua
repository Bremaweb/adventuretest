minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_snow","default:snowblock"},
	sidelen = 40,
	fill_ratio = 0.001,
	biomes = {"mtn_top"},
	y_min = 300,
	y_max = 32000,
	decoration = "flowers:magic",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 40,
	fill_ratio = 0.005,
	biomes = {
		"plains",
		"forest",
	},
	y_min = 0,
	y_max = 155,
	decoration = {"flowers:dandelion_white","flowers:dandelion_yellow"},
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 40,
	fill_radio = 0.003,
	biomes = {
		"plains",
		"forest",
		"hot_plains"
	},
	y_min = 0,
	y_max = 155,
	decoration = "flowers:geranium",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.006,
	biomes = {
		"plains"
	},
	y_min = 0,
	y_max = 155,
	decoration = "flowers:rose",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.004,
	biomes = {
		"plains",
		"hot_plains",
	},
	y_min = 0,
	y_max = 155,
	decoration = "flowers:tulip",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.003,
	biomes = {
		"plains",
	},
	y_min = 0,
	y_max = 155,
	decoration = "flowers:viola",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.0006,
	biomes = {
		"plains",
	},
	y_min = 0,
	y_max = 155,
	decoration = "bushes:strawberry_bush",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = {"default:dirt_with_grass"},
	sidelen = 16,
	fill_ratio = 0.003,
	biomes = {
		"forest",
	},
	y_min = 0,
	y_max = 155,
	decoration = "bushes:strawberry_bush",
})