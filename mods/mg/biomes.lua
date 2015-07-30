minetest.clear_registered_biomes()

minetest.register_biome({
	name = "plains",	
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 15,
	node_dust = "air",
	node_underwater = "default:dirt",
	y_min = 2,
	y_max = 230,
	node_shore_filler = "default:sand",
	heat_point = 45,
	humidity_point = 45,
})

minetest.register_biome({
	name = "hot_plains",	
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 15,
	node_dust = "air",
	node_underwater = "default:dirt",
	y_min = 3,
	y_max = 230,
	node_shore_filler = "default:sand",
	heat_point = 70,
	humidity_point = 45,
})

minetest.register_biome({
	name = "beach",	
	node_top = "default:sand",
	depth_top = 1,
	node_filler = "default:sandstone",
	depth_filler = 5,
	node_dust = "air",
	node_underwater = "default:sand",
	y_min = -25,
	y_max = 3,
	node_shore_filler = "default:sand",
	heat_point = 70,
	humidity_point = 45,
})

minetest.register_biome({
	name = "gravelbar",	
	node_top = "default:river_gravel",
	depth_top = 1,
	node_filler = "default:gravel",
	depth_filler = 2,
	--node_dust = "air",
	node_underwater = "default:dirt",
	y_min = -25,
	y_max = 1,
	--node_shore_filler = "default:gravel",
	heat_point = 45,
	humidity_point = 45,
})


minetest.register_biome({
	name = "forest",	
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 15,
	node_dust = "air",
	node_underwater = "default:dirt",
	y_min = 2,
	y_max = 230,
	node_shore_filler = "default:sand",
	heat_point = 45,
	humidity_point = 65,
})

minetest.register_biome({
	name = "forest_gravelbar",	
	node_top = "default:river_gravel",
	depth_top = 1,
	node_filler = "default:gravel",
	depth_filler = 2,
	node_dust = "air",
	node_underwater = "default:dirt",
	y_min = -25,
	y_max = 1,
	node_shore_filler = "default:gravel",
	heat_point = 45,
	humidity_point = 65,
})

minetest.register_biome({
	name = "mtn_top",	
	node_top = "default:snowblock",
	depth_top = 1,
	node_filler = "default:snowblock",
	depth_filler = 5,
	node_dust = "default:snow",
	node_underwater = "default:dirt",
	y_min = 230,
	y_max = 32000,
	node_shore_filler = "default:snowblock",
	--heat_point = 45,
	--humidity_point = 45,
})

minetest.register_biome({
	name = "desert",
	--node_dust = "",
	node_top = "default:desert_sand",
	depth_top = 1,
	node_filler = "default:desert_sand",
	depth_filler = 1,
	node_stone = "default:desert_stone",
	--node_water_top = "",
	--depth_water_top = ,
	--node_water = "",
	y_min = 1,
	y_max = 230,
	heat_point = 95,
	humidity_point = 10,
})

minetest.register_biome({
	name = "savanna",
	--node_dust = "",
	node_top = "mg:dirt_with_dry_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 4,
	node_stone = "default:stone",
	--node_water_top = "",
	--depth_water_top = ,
	--node_water = "",
	y_min = 1,
	y_max = 230,
	heat_point = 95,
	humidity_point = 50,
})

minetest.register_biome({
	name = "snowy",
	node_dust = "default:snow",
	node_top = "default:snowblock",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 2,
	node_stone = "default:stone",
	node_water_top = "default:ice",
	depth_water_top = 2,
	--node_water = "",
	y_min = 1,
	y_max = 230,
	heat_point = 10,
	humidity_point = 70,
})

minetest.register_biome({
	name = "tundra",
	--node_dust = "",
	node_top = "default:dirt_with_snow",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 4,
	node_stone = "default:stone",
	node_water_top = "default:ice",
	depth_water_top = 2,
	--node_water = "",
	y_min = 1,
	y_max = 230,
	heat_point = 10,
	humidity_point = 40,
})

minetest.register_biome({
	name = "artic",
	--node_dust = "",
	node_top = "default:snowblock",
	depth_top = 5,
	node_filler = "default:dirt",
	depth_filler = 4,
	node_stone = "default:stone",
	node_water_top = "default:ice",
	depth_water_top = 10,
	--node_water = "",
	y_min = -15,
	y_max = 230,
	heat_point = -10,
	humidity_point = 20,
})

minetest.register_biome({
	name = "doom",
	--node_dust = "",
	node_top = "default:dirt",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 4,
	node_stone = "default:stone",
	node_water_top = "default:lavasource",
	depth_water_top = 2,
	node_water = "default:lavasource",
	y_min = -25,
	y_max = 31000,
	heat_point = 115,
	humidity_point = 100,
})


minetest.register_biome({
	name = "jungle",
	--node_dust = "",
	node_top = "default:dirt_with_grass",
	depth_top = 1,
	node_filler = "default:dirt",
	depth_filler = 6,
	node_stone = "default:stone",
	--node_water_top = "default:ice",
	--depth_water_top = 2,
	--node_water = "",
	y_min = 1,
	y_max = 230,
	heat_point = 90,
	humidity_point = 90,
})


