minetest.register_alias("farming:wheat","farming_plus:wheat")

minetest.register_alias("farming:string","farming_plus:string")
minetest.register_alias("farming:bread","farming_plus:bread")
minetest.register_alias("farming:flour","farming_plus:flour")
minetest.register_alias("farming:seed_wheat","farming_plus:seed_wheat")
minetest.register_alias("farming:seed_cotton","farming_plus:seed_cotton")

minetest.register_alias("farming:soil","farming_plus:soil")
minetest.register_alias("farming:soil_wet","farming_plus:soil_wet")

minetest.register_alias("farming:hoe_steel","farming_plus:hoe_steel")
minetest.register_alias("farming:hoe_stone","farming_plus:hoe_stone")
minetest.register_alias("farming:hoe_bronze","farming_plus:hoe_bronze")

for i=1,8 do
	minetest.register_alias("farming:wheat_"..i,"farming_plus:wheat_"..i)
	minetest.register_alias("farming:cotton_"..i,"farming_plus:cotton_"..i)
end