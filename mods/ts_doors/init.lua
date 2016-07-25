ts_doors = {}

function ts_doors.register_door(recipe, description, texture)
	local node = minetest.registered_nodes[recipe]
	if node ~= nil then
		local groups = node.groups
		local door_groups = {}
		for k,v in pairs(groups) do
			if k ~= "wood" then
				door_groups[k] = v
			end
		end
		doors.register("ts_door_" .. recipe:gsub(":", "_"), {
			tiles = {{ name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR270^[colorize:#fff:30^ts_doors_base.png^[noalpha^[makealpha:0,255,0", backface_culling = true }},
			description = description .. " Door",
			inventory_image = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. "^[transformR270^[colorize:#fff:30^ts_doors_base_inv.png^[noalpha^[makealpha:0,255,0",
			groups = door_groups,
			recipe = {
				{recipe, recipe},
				{recipe, recipe},
				{recipe, recipe},
			}
		})
	
	
		door_groups.level = 2
	
		doors.register("ts_door_locked_" .. recipe:gsub(":", "_"), {
			tiles = {{ name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR270^[colorize:#fff:30^ts_doors_base_locked.png^[noalpha^[makealpha:0,255,0", backface_culling = true }},
			description = description .. " Locked Door",
			inventory_image = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. "^[transformR270^[colorize:#fff:30^ts_doors_base_locked_inv.png^[noalpha^[makealpha:0,255,0",
			protected = true,
			groups = door_groups,
			sound_open = "doors_steel_door_open",
			sound_close = "doors_steel_door_close",
			recipe = {
				{recipe, recipe},
				{recipe, "default:steel_ingot"},
				{recipe, recipe},
			}
		})
	end
end

ts_doors.register_door("mg:savannawood" , "Savanna"      , "mg_dry_wood.png" )
ts_doors.register_door("mg:pinewood"  , "Pine"       , "mg_pine_wood.png"  )
ts_doors.register_door("default:wood"       , "Wooden"     , "default_wood.png"       )
ts_doors.register_door("default:junglewood" , "Jungle Wood", "default_junglewood.png" )
ts_doors.register_door("default:tree" , "Unfinished Wood", "default_tree.png" )
ts_doors.register_door("default:jungletree" , "Unifished Jungle Wood", "default_jungletree.png" )
ts_doors.register_door("mg:savannatree" , "Unfinished Savanna"      , "mg_dry_tree.png" )
ts_doors.register_door("mg:pinetree" , "Unfinished Pine"      , "mg_pine_tree.png" )


if(minetest.get_modpath("moretrees")) then
	ts_furniture.register_furniture("moretrees:apple_tree_planks", "Apple Tree", "moretrees_apple_tree_wood.png")
	ts_furniture.register_furniture("moretrees:beech_planks", "Beech", "moretrees_beech_wood.png")
	ts_furniture.register_furniture("moretrees:birch_planks", "Birch", "moretrees_birch_wood.png")
	ts_furniture.register_furniture("moretrees:fir_planks", "Fir", "moretrees_fir_wood.png")
	ts_furniture.register_furniture("moretrees:oak_planks", "Oak", "moretrees_oak_wood.png")
	ts_furniture.register_furniture("moretrees:palm_planks", "Palm", "moretrees_palm_wood.png")
	ts_furniture.register_furniture("moretrees:rubber_tree_planks", "Rubber Tree", "moretrees_rubber_tree_wood.png")
	ts_furniture.register_furniture("moretrees:sequoia_planks", "Sequoia", "moretrees_sequoia_wood.png")
	ts_furniture.register_furniture("moretrees:spruce_planks", "Spruce", "moretrees_spruce_wood.png")
	ts_furniture.register_furniture("moretrees:willow_planks", "Willow", "moretrees_willow_wood.png")
end
