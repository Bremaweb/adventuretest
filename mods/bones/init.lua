-- Minetest 0.4 mod: bones
-- See README.txt for licensing and other information.
bone_file = minetest.get_worldpath().."/player_bones" 
player_bones = default.deserialize_from_file(bone_file)

local replaceable_node_types = {
	"default:lava_source", 
	"default:lava_flowing", 
	"default:water_source", 
	"default:water_flowing", 
	"air"
}


local function is_owner(pos, name)
	local owner = minetest.get_meta(pos):get_string("owner")
	if owner == "" or owner == name then
		return true
	end
	return false
end

local function not_pillaged(pos)
	local meta = minetest.get_meta(pos)
	if ( meta:get_string("pillaged") == "" ) then
		return true
	end
	return false
end

local function settle_bones(pos)
	local nextpos = pos; 
	local node

	-- find ground beneath player
	repeat
		pos = nextpos
		nextpos = {x=pos.x, y=pos.y-1, z=pos.z}
		node = minetest.get_node_or_nil(nextpos)
	until node == nil or not settle_type(node.name) 

	node = minetest.get_node_or_nil(pos)

	-- if the player is inside rock or something
	if node == nil or not settle_type(node.name) then
		-- find nearby empty node
		pos = minetest.find_node_near(pos, 3, replaceable_node_types)
	end

	-- if nothing nearby is empty
	if pos == nil then
		return nil
	end

	return pos;--{x=math.floor(pos.x*10)/10, y=math.floor(pos.y*10)/10, z=math.floor(pos.z*10)/10}
end

function settle_type (nodename) 
	for i=1,#replaceable_node_types do
		if nodename == replaceable_node_types[i] then
			return true
		end
	end
	return false
end

minetest.register_node("bones:bones", {
	description = "Bones",
	tiles = {
		"bones_top.png",
		"bones_bottom.png",
		"bones_side.png",
		"bones_side.png",
		"bones_rear.png",
		"bones_front.png"
	},
	paramtype2 = "facedir",
	groups = {dig_immediate=2},
	sounds = default.node_sound_dirt_defaults({
		footstep = {name="default_gravel_footstep", gain=0.5},
		dug = {name="default_gravel_footstep", gain=1.0},
	}),
	on_punch = function(pos, node, player)
		if node == nil or node.name ~= "bones:bones" then
			return
		end
		
		local meta = minetest.env:get_meta(pos)

		local name = player:get_player_name()
		if name ~= meta:get_string("owner") then
			return
		end
	
		local meta = minetest.env:get_meta(pos)
		local bones_inv = meta:get_inventory()
		if ( bones_inv == nil ) then
			return
		end
		
		local player_inv = player:get_inventory()
		if ( player_inv == nil ) then
			minetest.log("error", 'Bones:  Unable to get player '..name..' inventory')
			return
		end
	
		for i=1,32 do
			local stack = bones_inv:get_stack("main", i)
			if stack ~= nil and not stack:is_empty() then
				local leftover = player_inv:add_item("main", stack)
				bones_inv:set_stack("main", i, nil)
				if leftover ~= nil and not leftover:is_empty() then
					bones_inv:set_stack("main", i, leftover)
				else
					bones_inv:set_stack("main", i, nil)
				end
			end
		end
		minetest.log("action", name.." unloaded his fresh bones at "..minetest.pos_to_string(pos))
		
		-- destroy the bone node
		minetest.set_node(pos, {name="air", param1=0, param2=0})
		minetest.log("action","Destroying bones "..minetest.pos_to_string(pos))
	end,
	can_dig = function(pos, player)
		return is_owner(pos, player:get_player_name())
	end,	
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest:get_meta(pos)
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		default.dump_inv(pos,"main",inv)
		player_bones[meta:get_string("owner")] = nil
		default.serialize_to_file(bone_file,player_bones)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if is_owner(pos, player:get_player_name()) then
			return count
		end
		return 0
	end,
	
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return 0
	end,
	
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if is_owner(pos, player:get_player_name()) or not_pillaged(pos) then
			return stack:get_count()
		end
		return 0
	end,
	
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		meta:set_string("pillaged","1")
		if meta:get_string("owner") ~= "" and meta:get_inventory():is_empty("main") then
			meta:set_string("infotext", meta:get_string("owner").."'s old bones")
			meta:set_string("formspec", "")
			meta:set_string("owner", "")
		end
	end,
	
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local time = meta:get_int("time")+elapsed
		local publish = 1200
		local delete = 2400
		if tonumber(minetest.setting_get("share_bones_time")) then
			publish = tonumber(minetest.setting_get("share_bones_time"))
		end
		if publish == 0 then
			return
		end
		if time >= publish then
			meta:set_string("infotext", meta:get_string("owner").."'s old bones")
			meta:set_string("owner", "")
			return
		end
		
		if time >= delete then
			inv = meta:get_inventory()
			if inv:is_empty("main") == false then
				dump_bones(pos)
			end
			minetest.remove_node(pos)
			player_bones[meta:get_string("owner")] = nil
			default.serialize_to_file(bone_file,player_bones)
		end
		
		return true
	end,
})

function dump_bones(pos)
-- drop everything in the bones on the ground
	default.dump_inv(pos,"main")
end

minetest.register_on_dieplayer(function(player)
	if minetest.setting_getbool("creative_mode") or minetest.check_player_privs(player:get_player_name(),{immortal=true}) then
		player:set_hp(20)
		return
	end
	
	local pos = player:getpos()
	local name = player:get_player_name()
	
	pos = settle_bones(pos)
	if pos == nil then
		return
	end
	player_bones[name] = pos
	default.serialize_to_file(bone_file,player_bones)
	
	minetest.sound_play("default_death",{
		object = player,
	})
	
	minetest.chat_send_player(player:get_player_name(),"Your bones are at "..math.floor(pos.x + 0.5) .. "," .. math.floor(pos.y+0.5) .. "," .. math.floor(pos.z+0.5))
	
	pos.x = math.floor(pos.x+0.5)
	pos.y = math.floor(pos.y+0.5)
	pos.z = math.floor(pos.z+0.5)
	local param2 = minetest.dir_to_facedir(player:get_look_dir())
	
	local nn = minetest.get_node(pos).name
	if minetest.registered_nodes[nn].can_dig and
		not minetest.registered_nodes[nn].can_dig(pos, player) then
		local player_inv = player:get_inventory()

		for i=1,player_inv:get_size("main") do
			player_inv:set_stack("main", i, nil)
		end
		for i=1,player_inv:get_size("craft") do
			player_inv:set_stack("craft", i, nil)
		end
		return
	end
	
	--minetest.dig_node(pos)
	minetest.add_node(pos, {name="bones:bones", param2=param2})
	
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local player_inv = player:get_inventory()
	inv:set_size("main", 8*4)
	
	local empty_list = inv:get_list("main")
	inv:set_list("main", player_inv:get_list("main"))
	player_inv:set_list("main", empty_list)
	
	for i=1,player_inv:get_size("craft") do
		inv:add_item("main", player_inv:get_stack("craft", i))
		player_inv:set_stack("craft", i, nil)
	end
	
	meta:set_string("formspec", "size[8,9;]"..
			"list[current_name;main;0,0;8,4;]"..
			"list[current_player;main;0,5;8,4;]")
	meta:set_string("infotext", player:get_player_name().."'s fresh bones")
	meta:set_string("owner", player:get_player_name())
	meta:set_int("time", 0)
	
	local timer  = minetest.get_node_timer(pos)
	timer:start(10)
end)
