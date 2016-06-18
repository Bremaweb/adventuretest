-- main `S` code in init.lua
local S
S = farming.S

minetest.register_node(":farming_plus:weed", {
	description = S("Weed"),
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	floodable = true,
	drawtype = "plantlike",
	tiles = {"farming_weed.png"},
	inventory_image = "farming_weed.png",
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.5+4/16, 0.5}
		},
	},
	groups = {snappy=3, flammable=2,plant=1},
	sounds = default.node_sound_leaves_defaults()
})

minetest.register_abm({
	nodenames = {"farming_plus:soil_wet", "farming_plus:soil"},
	interval = 150,
	chance = 4,
	action = function(pos, node)
		if abm_limiter() then return end
		if minetest.find_node_near(pos, 4, {"farming_plus:scarecrow", "farming_plus:scarecrow_light"}) ~= nil then
			return
		end
		pos.y = pos.y+1
		if not minetest.get_node_light(pos,0.5) then
			return
		end
		if minetest.get_node_light(pos,0.5) < 8 then
			return
		end
		if minetest.get_node(pos).name == "air" then
			node.name = "farming_plus:weed"
			minetest.set_node(pos, node)
		end
	end
})

-- if something is overrun with weeds too long turn it back to regular dirt
minetest.register_abm({
	nodenames = {"farming_plus:weed"},
	interval = 700,
	chance = 3,
	action = function (pos, node)
		-- default:grass_#   # = 1-5
		math.randomseed(os.time())
		local grass = math.random(1,5)
		local node = "default:grass_" .. grass
		minetest.set_node(pos,{name=node})
		pos.y = pos.y - 1
		minetest.set_node(pos,{name="default:dirt_with_grass"})
	end
})

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming_plus:weed",
	burntime = 1
})
