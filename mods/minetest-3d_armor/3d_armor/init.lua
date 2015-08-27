dofile(minetest.get_modpath(minetest.get_current_modname()).."/armor.lua")
local use_moreores = minetest.get_modpath("moreores")

-- Regisiter Head Armor

minetest.register_tool("3d_armor:helmet_wood", {
	description = "Wood Helmet",
	inventory_image = "3d_armor_inv_helmet_wood.png",
	groups = {armor_head=5, armor_heal=0, armor_use=2000 },
	wear = 0,
	skill=SKILL_WOOD,
})

minetest.register_tool("3d_armor:helmet_steel", {
	description = "Steel Helmet",
	inventory_image = "3d_armor_inv_helmet_steel.png",
	groups = {armor_head=10, armor_heal=0, armor_use=500 },
	wear = 0,
	skill=SKILL_METAL,
})

minetest.register_tool("3d_armor:helmet_bronze", {
	description = "Bronze Helmet",
	inventory_image = "3d_armor_inv_helmet_bronze.png",
	groups = {armor_head=10, armor_heal=6, armor_use=250},
	wear = 0,
	skill = SKILL_METAL,
})

minetest.register_tool("3d_armor:helmet_diamond", {
	description = "Diamond Helmet",
	inventory_image = "3d_armor_inv_helmet_diamond.png",
	groups = {armor_head=15, armor_heal=12, armor_use=100 },
	wear = 0,
	skill = SKILL_CRYSTAL,
})

minetest.register_tool("3d_armor:helmet_mithril", {
	description = "Mithril Helmet",
	inventory_image = "3d_armor_inv_helmet_mithril.png",
	groups = {armor_head=15, armor_heal=12, armor_use=50},
	wear = 0,
})


-- Regisiter Torso Armor

minetest.register_tool("3d_armor:chestplate_wood", {
	description = "Wood Chestplate",
	inventory_image = "3d_armor_inv_chestplate_wood.png",
	groups = {armor_torso=10, armor_heal=0, armor_use=2000 },
	wear = 0,
	physics = { speed = -0.06 },
	skill = SKILL_WOOD,
})

minetest.register_tool("3d_armor:chestplate_steel", {
	description = "Steel Chestplate",
	inventory_image = "3d_armor_inv_chestplate_steel.png",
	groups = {armor_torso=15, armor_heal=0, armor_use=500 },
	wear = 0,
	physics = { speed = -0.03 },
	skill = SKILL_METAL,
})

minetest.register_tool("3d_armor:chestplate_bronze", {
	description = "Bronze Chestplate",
	inventory_image = "3d_armor_inv_chestplate_bronze.png",
	groups = {armor_torso=15, armor_heal=6, armor_use=250 },
	wear = 0,
	physics = { speed = -0.03 },
	skill = SKILL_METAL,
})

minetest.register_tool("3d_armor:chestplate_diamond", {
	description = "Diamond Chestplate",
	inventory_image = "3d_armor_inv_chestplate_diamond.png",
	groups = {armor_torso=20, armor_heal=12, armor_use=100 },
	wear = 0,
	physics = { speed = -0.04 },
	skill = SKILL_CRYSTAL,
})

minetest.register_tool("3d_armor:chestplate_mithril", {
	description = "Mithril Chestplate",
	inventory_image = "3d_armor_inv_chestplate_mithril.png",
	groups = {armor_torso=25, armor_heal=12, armor_use=500},
	wear = 0,
	physics = { speed = 0.01 },
})



-- Regisiter Leg Armor

minetest.register_tool("3d_armor:leggings_wood", {
	description = "Wood Leggings",
	inventory_image = "3d_armor_inv_leggings_wood.png",
	groups = {armor_legs=5, armor_heal=0, armor_use=2000 },
	wear = 0,
	physics = { speed = -0.01 },
	skill = SKILL_WOOD,
})

minetest.register_tool("3d_armor:leggings_steel", {
	description = "Steel Leggings",
	inventory_image = "3d_armor_inv_leggings_steel.png",
	groups = {armor_legs=15, armor_heal=0, armor_use=500 },
	wear = 0,
	physics = { speed = -0.08 },
	skill = SKILL_METAL,
})

minetest.register_tool("3d_armor:leggings_bronze", {
	description = "Bronze Leggings",
	inventory_image = "3d_armor_inv_leggings_bronze.png",
	groups = {armor_legs=15, armor_heal=6, armor_use=250 },
	wear = 0,
	skill = SKILL_METAL,
})

minetest.register_tool("3d_armor:leggings_diamond", {
	description = "Diamond Leggings",
	inventory_image = "3d_armor_inv_leggings_diamond.png",
	groups = {armor_legs=20, armor_heal=12, armor_use=100 },
	wear = 0,
	physics = { speed = -0.09 },
	skill = SKILL_CRYSTAL,
})


minetest.register_tool("3d_armor:leggings_mithril", {
	description = "Mithril Leggings",
	inventory_image = "3d_armor_inv_leggings_mithril.png",
	groups = {armor_legs=25, armor_use=500},
	wear = 0,
	physics = { speed = 0.02 }
})


-- Regisiter Boots

minetest.register_tool("3d_armor:boots_wood", {
	description = "Wood Boots",
	inventory_image = "3d_armor_inv_boots_wood.png",
	groups = {armor_feet=5, armor_heal=0, armor_use=2000 },
	wear = 0,
	physics = { speed = -0.1 },
	skill = SKILL_WOOD,
})

minetest.register_tool("3d_armor:boots_steel", {
	description = "Steel Boots",
	inventory_image = "3d_armor_inv_boots_steel.png",
	groups = {armor_feet=10, armor_heal=0, armor_use=500 },
	wear = 0,
	physics = { speed = -0.07 },
	skill = SKILL_METAL,
})

minetest.register_tool("3d_armor:boots_bronze", {
	description = "Bronze Boots",
	inventory_image = "3d_armor_inv_boots_bronze.png",
	groups = {armor_feet=10, armor_heal=6, armor_use=250 },
	wear = 0,
	physics = { speed = -0.07 },
	skill = SKILL_METAL
})

minetest.register_tool("3d_armor:boots_diamond", {
	description = "Diamond Boots",
	inventory_image = "3d_armor_inv_boots_diamond.png",
	groups = {armor_feet=15, armor_heal=12, armor_use=100 },
	wear = 0,
	physics = { speed = -0.08 },
	skill = SKILL_CRYSTAL,
})

minetest.register_tool("3d_armor:boots_mithril", {
	description = "Mithril Boots",
	inventory_image = "3d_armor_inv_boots_mithril.png",
	groups = {armor_feet=15, armor_use=500},
	wear = 0,
	physics = { speed = 0.01 },
})


-- Register Craft Recipies

local craft_ingreds = {
	wood = "group:wood",
	steel = "default:steel_ingot",
	bronze = "default:bronze_ingot",
	diamond = "default:diamond",
}


-- Mithril armor is not craftable
-- craft_ingreds.mithril = "moreores:mithril_ingot"


for k, v in pairs(craft_ingreds) do
	minetest.register_craft({
		output = "3d_armor:helmet_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{"", "", ""},
		},
	})
	minetest.register_craft({
		output = "3d_armor:chestplate_"..k,
		recipe = {
			{v, "", v},
			{v, v, v},
			{v, v, v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:leggings_"..k,
		recipe = {
			{v, v, v},
			{v, "", v},
			{v, "", v},
		},
	})
	minetest.register_craft({
		output = "3d_armor:boots_"..k,
		recipe = {
			{v, "", v},
			{v, "", v},
		},
	})
end

