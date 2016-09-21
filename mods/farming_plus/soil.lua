minetest.register_node("farming_plus:soil", {
	description = "Soil",
	tiles = {"farming_soil.png", "default_dirt.png"},
	drop = "default:dirt",
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative_inventory=1, soil=2},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("farming_plus:soil_wet", {
	description = "Wet Soil",
	tiles = {"farming_soil_wet.png", "farming_soil_wet_side.png"},
	drop = "default:dirt",
	is_ground_content = true,
	groups = {crumbly=3, not_in_creative_inventory=1, soil=3},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_abm({
	label = "wetting / drying soil",
	nodenames = {"farming_plus:soil", "farming_plus:soil_wet"},
	interval = 15,
	chance = 4,
	action = function(pos, node)
		--if abm_limiter() then return end
		pos.y = pos.y+1
		local nn = minetest.get_node(pos).name
		pos.y = pos.y-1
		
		-- check if there is water nearby
		if minetest.find_node_near(pos, 3, {"group:water"}) then
			-- if it is dry soil turn it into wet soil
			if node.name == "farming_plus:soil" then
				minetest.set_node(pos, {name="farming_plus:soil_wet"})
			end
		else
			-- turn it back into dirt if it is already dry
			if node.name == "farming_plus:soil" then
				-- only turn it back if there is no plant on top of it
				if minetest.get_item_group(nn, "plant") == 0 then
					minetest.set_node(pos, {name="default:dirt"})
				end
				
			-- if its wet turn it back into dry soil
			elseif node.name == "farming_plus:soil_wet" then
				minetest.set_node(pos, {name="farming_plus:soil"})
			end
		end
	end,
})
