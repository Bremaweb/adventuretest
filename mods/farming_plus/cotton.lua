--
-- Cotton
--
minetest.register_craftitem("farming_plus:seed_cotton", {
	description = "Cotton Seed",
	inventory_image = "farming_cotton_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		return farming:place_seed(itemstack, placer, pointed_thing, "farming_plus:cotton_1")
	end,
})

minetest.register_craftitem("farming_plus:string", {
	description = "String",
	inventory_image = "farming_string.png",
})

minetest.register_craft({
	output = "wool:white",
	recipe = {
		{"farming_plus:string", "farming_plus:string"},
		{"farming_plus:string", "farming_plus:string"},
	}
})

local nodes = {}
for i=1,8 do
	local drop = {
		items = {
			{items = {'farming_plus:string'},rarity=9-i},
			{items = {'farming_plus:string'},rarity=18-i*2},
			{items = {'farming_plus:string'},rarity=27-i*3},
			{items = {'farming_plus:seed_cotton'},rarity=9-i},
			{items = {'farming_plus:seed_cotton'},rarity=18-i*2},
			{items = {'farming_plus:seed_cotton'},rarity=27-i*3},
		}
	}
	minetest.register_node("farming_plus:cotton_"..i, {
		drawtype = "plantlike",
		tiles = {"farming_cotton_"..i..".png"},
		paramtype = "light",
		waving = 1,
		walkable = false,
		buildable_to = true,
		floodable = true,
		is_ground_content = true,
		drop = drop,
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
		groups = {snappy=3,flammable=2,plant=1,cotton=i,not_in_creative_inventory=1,attached_node=1},
		sounds = default.node_sound_leaves_defaults(),
	})
	table.insert(nodes,"farming_plus:cotton_"..i)
end

farming:add_plant("farming_plus:cotton_8",nodes,1100,1)
