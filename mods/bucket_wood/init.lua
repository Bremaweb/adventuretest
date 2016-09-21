-- Minetest 0.4 mod: bucket
-- See README.txt for licensing and other information.

local LIQUID_MAX = 8  --The number of water levels when liquid_finite is enabled

minetest.register_craft({
	output = 'bucket_wood:bucket_empty 1',
	recipe = {
		{'group:wood', '', 'group:wood'},
		{'', 'group:wood', ''},
	}
})

bucket_wood = {}
bucket_wood.liquids = {}
bucket_wood.swaps = {}

local function check_protection(pos, name, text)
	if minetest.is_protected(pos, name) then
		minetest.log("action", (name ~= "" and name or "A mod")
			.. " tried to " .. text
			.. " at protected position "
			.. minetest.pos_to_string(pos)
			.. " with a bucket")
		minetest.record_protection_violation(pos, name)
		return true
	end
	return false
end

-- Register a new liquid
--   source = name of the source node
--   flowing = name of the flowing node
--   itemname = name of the new bucket item (or nil if liquid is not takeable)
--   inventory_image = texture of the new bucket item (ignored if itemname == nil)
-- This function can be called from any mod (that depends on bucket).
function bucket_wood.register_liquid(source, flowing, itemname, inventory_image, name)
	bucket_wood.liquids[source] = {
		source = source,
		flowing = flowing,
		itemname = itemname,
	}
	bucket_wood.liquids[flowing] = bucket_wood.liquids[source]

	if itemname ~= nil then
		minetest.register_craftitem(itemname, {
			description = name,
			inventory_image = inventory_image,
			stack_max = 1,
			liquids_pointable = true,
			groups = {not_in_creative_inventory=1},
			on_place = function(itemstack, user, pointed_thing)
				-- Must be pointing to node
				if pointed_thing.type ~= "node" then
					return
				end
				
				local node = minetest.get_node_or_nil(pointed_thing.under)
				local ndef
				if node then
					ndef = minetest.registered_nodes[node.name]
				end
				-- Call on_rightclick if the pointed node defines it
				if ndef and ndef.on_rightclick and
				   user and not user:get_player_control().sneak then
					return ndef.on_rightclick(
						pointed_thing.under,
						node, user,
						itemstack) or itemstack
				end

				local place_liquid = function(pos, node, source, flowing, fullness)
					if bucket_wood.swaps[source] ~= nil then
						source = bucket_wood.swaps[source]
					end
					if bucket_wood.swaps[flowing] ~= nil then
						flowing = bucket_wood.swaps[flowing]
					end
					if check_protection(pos,
							user and user:get_player_name() or "",
							"place "..source) then
						return
					end
					if math.floor(fullness/128) == 1 or
						not minetest.setting_getbool("liquid_finite") then
						minetest.add_node(pos, {name=source,
								param2=fullness})
						return
					elseif node.name == flowing then
						fullness = fullness + node.param2
					elseif node.name == source then
						fullness = LIQUID_MAX
					end

					if fullness >= LIQUID_MAX then
						minetest.add_node(pos, {name=source,
								param2=LIQUID_MAX})
					else
						minetest.add_node(pos, {name=flowing,
								param2=fullness})
					end
				end

				-- Check if pointing to a buildable node
				local fullness = tonumber(itemstack:get_metadata())
				if not fullness then fullness = LIQUID_MAX end

				if ndef and ndef.buildable_to then
					-- buildable; replace the node
					place_liquid(pointed_thing.under, node,
							source, flowing, fullness)
				else
					-- not buildable to; place the liquid above
					-- check if the node above can be replaced
					local node = minetest.get_node_or_nil(pointed_thing.above)
					if node and minetest.registered_nodes[node.name].buildable_to then
						place_liquid(pointed_thing.above,
								node, source,
								flowing, fullness)
					else
						-- do not remove the bucket with the liquid
						return
					end
				end
				return {name="bucket_wood:bucket_empty"}
			end
		})
	end
end

function bucket_wood.register_swap(source, flowing, new_source, new_flowing)
	bucket_wood.swaps[source] = new_source
	bucket_wood.swaps[flowing] = new_flowing
end

minetest.register_craftitem("bucket_wood:bucket_empty", {
	description = "Empty Wooden Bucket",
	inventory_image = "bucket_wood.png",
	stack_max = 1,
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		-- Must be pointing to node
		if pointed_thing.type ~= "node" then
			return
		end
		-- Check if pointing to a liquid source
		local node = minetest.get_node(pointed_thing.under)
		local liquiddef = bucket_wood.liquids[node.name]
		if liquiddef ~= nil and liquiddef.itemname ~= nil and
			(node.name == liquiddef.source or
			(node.name == liquiddef.flowing and
				minetest.setting_getbool("liquid_finite"))) then
			if check_protection(pointed_thing.under,
					user:get_player_name(),
					"take ".. node.name) then
				return
			end

			minetest.add_node(pointed_thing.under, {name="air"})

			if node.name == liquiddef.source then
				node.param2 = LIQUID_MAX
			end
			return ItemStack({name = liquiddef.itemname,
					metadata = tostring(node.param2)})
		end
	end,
	groups = { guide = GUIDE_TOOLS },
})

bucket_wood.register_liquid(
	"default:water_source",
	"default:water_flowing",
	"bucket_wood:bucket_water",
	"bucket_wood_water.png",
	"Wooden Water Bucket"
)

bucket_wood.register_liquid(
	"default:mg_water_source",
	"default:mg_water_flowing",
	"bucket_wood:bucket_water",
	"bucket_wood_water.png",
	"Wooden Water Bucket"
)

bucket_wood.register_swap("default:mg_water_source","default:mg_water_flowing","default:water_source","default:water_flowing")
