local function get_campfire_active_formspec(pos, percent)
	local formspec =
		"size[8,9]"..
		"image[2,2;1,1;default_furnace_fire_bg.png^[lowpart:"..
		(100-percent)..":default_furnace_fire_fg.png]"..
		"list[current_name;fuel;2,3;1,1;]"..
		"list[current_name;src;2,1;1,1;]"..
		"list[current_name;dst;5,1;2,2;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end


local campfire_inactive_formspec =
	"size[8,9]"..
	"image[2,2;1,1;default_furnace_fire_bg.png]"..
	"list[current_name;fuel;2,3;1,1;]"..
	"list[current_name;src;2,1;1,1;]"..
	"list[current_name;dst;5,1;2,2;]"..
	"list[current_player;main;0,5;8,4;]"

minetest.register_node("campfire:campfire", {
	description = "Campfire",
	tiles = {"campfire_campfire.png"},
	use_texture_alpha=true,
	drawtype = "firelike",
	paramtype="light",
	paramtype2="facedir",
	sunlight_propagates = true,
	groups = {dig_immediate=2,flammable=1},
	is_ground_content = false,
	inventory_image = "campfire_campfire.png",
	drop = "",
	walkable=false,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.15, 0.5},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", campfire_inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
	end,	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest:get_meta(pos)
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		default.dump_inv(pos,"fuel",inv)
		default.dump_inv(pos,"dst",inv)
		default.dump_inv(pos,"src",inv)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then				
				return stack:get_count()
			else
				return 0
			end
		elseif listname == "src" then
			--print(player:get_player_name().." put item into campfire")
			meta:set_string("owner",player:get_player_name())
			return stack:get_count()
		elseif listname == "dst" then
			return 0
		end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local stack = inv:get_stack(from_list, from_index)
		if to_list == "fuel" then
			if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
				return count
			else
				return 0
			end
		elseif to_list == "src" then
			return count
		elseif to_list == "dst" then
			return 0
		end
	end,
})

minetest.register_node("campfire:campfire_burning", {
	description = "Campfire Burning",
	drawtype = "firelike",
	tiles = {{
		name="campfire_active.png",
		animation={type="vertical_frames", aspect_w=16, aspect_h=16, length=1},
	}},
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 16,
	drop = "",
	groups = {igniter=2,hot=3},
	is_ground_content = false,	
	damage_per_second = 2,
	walkable=false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", campfire_inactive_formspec)
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("dst", 4)
	end,
	can_dig = function(pos,player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty("fuel") then
				return false
			elseif not inv:is_empty("dst") then
				return false
			elseif not inv:is_empty("src") then
				return false
			end
			return true
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if listname == "fuel" then
				if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
					return stack:get_count()
				else
					return 0
				end
			elseif listname == "src" then
				--print(player:get_player_name().." put item into campfire")
				meta:set_string("owner",player:get_player_name())
				return stack:get_count()
			elseif listname == "dst" then
				return 0
			end
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)		
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local stack = inv:get_stack(from_list, from_index)
			if to_list == "fuel" then
				if minetest.get_craft_result({method="fuel",width=1,items={stack}}).time ~= 0 then
					return count
				else
					return 0
				end
			elseif to_list == "src" then
				return count
			elseif to_list == "dst" then
				return 0
			end
		
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		  return stack:get_count()
	end
})

local function swap_node(pos,name)
	local node = minetest.get_node(pos)
	if node.name == name then
		return
	end
	node.name = name
	minetest.swap_node(pos,node)
end

minetest.register_abm({
	nodenames = {"campfire:campfire","campfire:campfire_burning"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		for i, name in pairs({
				"fuel_totaltime",
				"fuel_time",
				"src_totaltime",
				"src_time"
		}) do
			if meta:get_string(name) == "" then
				meta:set_float(name, 0.0)
			end
		end

		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()

		local srclist = inv:get_list("src")
		local cooked = nil
		local aftercooked
		
		if srclist then
			cooked, aftercooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		end
		
		local was_active = false
		
		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
			was_active = true
			meta:set_float("fuel_time", meta:get_float("fuel_time") + 0.25)
			meta:set_float("src_time", meta:get_float("src_time") + 0.25)
			if cooked and cooked.item and meta:get_float("src_time") >= cooked.time then
				if inv:room_for_item("dst",cooked.item) then
					-- Put result in "dst" list
					inv:add_item("dst", cooked.item)
					-- take stuff from "src" list
					inv:set_stack("src", 1, aftercooked.items[1])
				end
				meta:set_string("src_time", 0)
			end
			if randomChance(25) then
				local ps_def = { 
					amount = 12,
					time = 0.25,
					minpos = {x=pos.x-0.2, y=pos.y-0.2, z=pos.z-0.2},
					maxpos = {x=pos.x+0.2, y=pos.y+0.2, z=pos.z+0.2},
					minvel = {x=0, y=1, z=0},
					maxvel = {x=1, y=2, z=1},
					minacc = {x=-0.5,y=-1,z=-0.5},
					maxacc = {x=0.5,y=1,z=0.5},
					minexptime = 0.1,
					maxexptime = 1,
					minsize = 0.25,
					maxsize = 0.5,
					collisiondetection = false,
					texture = "fire_basic_flame.png"
				}
				minetest.add_particlespawner(ps_def)			
			end
			
		end
		
		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
			local percent = math.floor(meta:get_float("fuel_time") /
					meta:get_float("fuel_totaltime") * 100)			
				swap_node(pos,"campfire:campfire_burning")
				meta:set_string("formspec",get_campfire_active_formspec(pos, percent))
			if meta:get_int("sound_played") == nil or ( os.time() - meta:get_int("sound_played") ) >= 4 then
				minetest.sound_play("default_furnace",{pos=pos})
				meta:set_string("sound_played",os.time())
			end
			return
		end

		local fuel = nil
		local afterfuel
		local cooked = nil
		local fuellist = inv:get_list("fuel")
		local srclist = inv:get_list("src")
		
		if srclist then
			cooked = minetest.get_craft_result({method = "cooking", width = 1, items = srclist})
		end
		if fuellist then
			fuel, afterfuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
		end

		if not fuel or fuel.time <= 0 then
			swap_node(pos,"campfire:campfire")
			meta:set_string("formspec", campfire_inactive_formspec)
			return
		end

		

		meta:set_string("fuel_totaltime", fuel.time)
		meta:set_string("fuel_time", 0)
		
		inv:set_stack("fuel", 1, afterfuel.items[1])
	end,
})

minetest.register_craft({
	type="shapeless",
	output = "campfire:campfire",
	recipe = {"group:stick","group:stick","group:stick","group:tree"}
})
