--
-- Wheat
--
minetest.register_craftitem("farming_plus:seed_wheat", {
	description = "Wheat Seed",
	inventory_image = "farming_wheat_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		return farming:place_seed(itemstack, placer, pointed_thing, "farming_plus:wheat_1")
	end,
	ground = "farming_plus:flour",
})

minetest.register_craftitem("farming_plus:wheat", {
	description = "Wheat",
	inventory_image = "farming_wheat.png",
})

minetest.register_craftitem("farming_plus:flour", {
	description = "Flour",
	inventory_image = "farming_flour.png",
})

minetest.register_craftitem("farming_plus:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craft({
	type = "shapeless",
	output = "farming_plus:flour",
	recipe = {"farming_plus:wheat", "farming_plus:wheat", "farming_plus:wheat", "farming_plus:wheat"}
})

minetest.register_craft({
	type = "cooking",
	cooktime = 15,
	output = "farming_plus:bread",
	recipe = "farming_plus:flour"
})

local nodes = {}
for i=1,8 do
	local drop = {
		items = {
			{items = {'farming_plus:wheat'},rarity=9-i},
			{items = {'farming_plus:wheat'},rarity=18-i*2},
			{items = {'farming_plus:seed_wheat'},rarity=9-i},
			{items = {'farming_plus:seed_wheat'},rarity=18-i*2},
		}
	}
	minetest.register_node("farming_plus:wheat_"..i, {
		drawtype = "plantlike",
		tiles = {"farming_wheat_"..i..".png"},
		paramtype = "light",
		waving = 1,
		walkable = false,
		buildable_to = true,
		is_ground_content = true,
		drop = drop,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		groups = {snappy=3,flammable=2,plant=1,wheat=i,not_in_creative_inventory=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})
	table.insert(nodes,"farming_plus:wheat_"..i)
end

farming:add_plant("farming_plus:wheat_8",nodes,1600,1)