minetest.register_craftitem("potions:fly1",{
	description = "Level 1 Fly Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_fly1.png",
	affectid = "fly1",
	on_use = affects.default_on_use,
})

minetest.register_craftitem("potions:fly2",{
	description = "Level 2 Fly Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_fly2.png",
	affectid = "fly2",
	on_use = affects.default_on_use
})

minetest.register_craftitem("potions:fly3",{
	description = "Level 3 Fly Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_fly3.png",
	affectid="fly3",
	on_use = affects.default_on_use,	
})

minetest.register_craftitem("potions:gravity1",{
	description = "Level 1 Anti Gravity Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_gravity1.png",
	affectid="gravity1",
	on_use = affects.default_on_use,	
})


minetest.register_craftitem("potions:fly1_raw",{
	description = "Level 1 Raw Fly Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_fly1_raw.png"
})

minetest.register_craftitem("potions:fly2_raw",{
	description = "Level 2 Raw Fly Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_fly2_raw.png"
})

minetest.register_craftitem("potions:fly3_raw",{
	description = "Level 2 Raw Fly Potion",
	stack_max = 1,
	liquids_pointable = false
})

minetest.register_craftitem("potions:gravity1_raw", {
	description = "Level 1 Raw Anti Gravity Potion",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_gravity1_raw.png",
})

minetest.register_craftitem("potions:bones", {
	description = "Bones Finder Potion",
	stack_max=99,
	liquids_pointable = false,
	inventory_image = "potion_bones.png",
	on_use = function ( itemstack,player,pointed_thing )
		local name = player:get_player_name()
		if player_bones[name] ~= nil then
			local bpos = player_bones[name]
			bpos.y = bpos.y + 1
			adventuretest.teleport(player,bpos)
			--player:moveto(bpos)
		else
			minetest.chat_send_player(name,"Your bones were not found")
		end
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("potions:magic_replenish1", {
	description = "Level 1 Magic Replenisher",
	stack_max=99,
	liquids_pointable = false,
	inventory_image = "potions_magic.png",
	on_use = function ( itemstack,player,pointed_thing )
		local name = player:get_player_name()
		local m = pd.get_number(name,"mana")
		pd.increment(name,"mana",5)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("potions:magic_replenish2", {
	description = "Level 2 Magic Replenisher",
	stack_max=99,
	liquids_pointable = false,
	inventory_image = "potions_magic2.png",
	on_use = function ( itemstack,player,pointed_thing )
		local name = player:get_player_name()
		pd.increment(name,"mana",5)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("potions:magic_replenish3", {
	description = "Level 3 Magic Replenisher",
	stack_max=99,
	liquids_pointable = false,
	inventory_image = "potions_magic3.png",
	on_use = function ( itemstack,player,pointed_thing )
		local name = player:get_player_name()
		pd.set(name,"magic",20)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("potions:antidote",{
	description = "Jungle Spider Poison Antidote",
	stack_max = 1,
	liquids_pointable = false,
	inventory_image = "potions_antidote.png",	
	on_use = function ( itemstack, player, pointed_thing )
		local name = player:get_player_name()
		affects.removeAffect(name,"spider_poison")
		itemstack:take_item()
		return itemstack
	end,
})



local ground_items = {
	{ "flowers:dandelion_white", "ground_dandelion_white", "Ground White Dandelion" },
	{ "flowers:dandelion_yellow", "ground_dandelion_yellow", "Ground Yellow Dandelion" },
	{ "flowers:rose", "ground_rose", "Ground Rose" },
	{ "flowers:geranium", "ground_geranium", "Ground Geranium" },
	{ "flowers:tulip", "ground_tulip", "Ground Tulip" },
	{ "flowers:viola", "ground_viola", "Ground Viola" },
	{ "bones:bones","ground_bones","Ground Bones" },
	{ "flowers:magic", "ground_magic","Ground Magic Flower"}
}

for _, data in pairs(ground_items) do
	minetest.register_craftitem("potions:"..data[2],{
		description = data[3],
		stack_max = 99,
		liquids_pointable = false,
		inventory_image = "potions_"..data[2]..".png"
	})
	local gitem = "potions:"..data[2]
	minetest.register_craft({
		type="shapeless",
		output=gitem,
		recipe = {data[1]}
	})
	cottages.handmill_product[ data[1] ] = gitem .. ' 4';
end

minetest.register_craft({
	type = "shapeless",
	output = "potions:fly1_raw",
	recipe = {"bushes:sugar","potions:ground_rose","default:mese_crystal_fragment","vessels:glass_bottle","bucket:bucket_water","potions:ground_magic"},
	replacements = { { "bucket:bucket_water","bucket:bucket_empty" } }	
})

minetest.register_craft({
		type="cooking",
		recipe="potions:fly1_raw",
		output = "potions:fly1"
})

minetest.register_craft({
	type = "shapeless",
	output = "potions:fly2_raw",
	recipe = {"bushes:sugar","potions:ground_rose","default:mese_crystal","vessels:glass_bottle","bucket:bucket_water","potions:ground_magic"},
	replacements = { { "bucket:bucket_water","bucket:bucket_empty" } }	
})

minetest.register_craft({
		type="cooking",
		recipe="potions:fly2_raw",
		output = "potions:fly2"
})

minetest.register_craft({
	type="shapeless",
	output="potions:gravity1_raw",
	recipe = {"dye:green","farming_plus:wheat","potions:ground_bones","default:mese_crystal_fragment","vessels:glass_bottle","bucket:bucket_water","potions:ground_magic"},
	replacements = { { "bucket:bucket_water","bucket:bucket_empty" } }
})

minetest.register_craft({
		type="cooking",
		recipe="potions:gravity1_raw",
		output = "potions:gravity1"
})

minetest.register_craft({
	type="shapeless",
	output="potions:bones",
	recipe = {"potions:ground_bones","vessels:glass_bottle","bucket:bucket_water","potions:ground_magic"},
	replacements = { { "bucket:bucket_water","bucket:bucket_empty" } },
})

minetest.register_craft({
	type="shapeless",
	output="potions:antidote",
	recipe = {"mobs:jungle_spider_fang","vessels:glass_bottle","bucket:bucket_water","potions:ground_rose"},
	replacements = { { "bucket:bucket_water","bucket:bucket_empty" } },
})
