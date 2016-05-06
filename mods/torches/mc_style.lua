-- Reduce particles send to client if on Server
local SERVER = minetest.is_singleplayer() or false
SERVER = not SERVER
local dur = 2
if SERVER then
	dur = 9 -- lowering sends more pakets to clients and let flames faster disappear (not recommended)
end

local VIEW_DISTANCE = 13 -- from what distance (in nodes) flames are send to player/client

-- constants
local rotat = {"I", "FX"}
local particle_def = {
    pos = {x = 0, y = 0, z = 0},
    velocity = { x= 0, y = 0, z = 0},
    acceleration = {x = 0, y = 0, z = 0},
    expirationtime = 1,
    size = 3.0,
    collisiondetection = true,
    vertical = false,
    texture = "torches_fire_1.png",
}

-- fire particles (flames)
local function add_fire(pos, duration, offset)
	if offset then
		pos.x = pos.x + offset.x
		pos.z = pos.z + offset.z
		pos.y = pos.y + offset.y
	end
	pos.y = pos.y + 0.19
	particle_def.pos = pos
	particle_def.expirationtime = duration
	particle_def.texture = "torches_fire"..tostring(math.random(1, 2)) ..".png^[transform"..rotat[math.random(1,2)]
	minetest.add_particle(particle_def)

	pos.y = pos.y + 0.01
	particle_def.pos = pos
	particle_def.texture = "torches_fire"..tostring(math.random(1, 2)) ..".png^[transform"..rotat[math.random(1,2)]
	minetest.add_particle(particle_def)
end

-- helper functions
local function player_near(pos)
	for  _,object in ipairs(minetest.get_objects_inside_radius(pos, VIEW_DISTANCE)) do
		if object:is_player() then
			return true
		end
	end

	return false
end

local function get_offset(wdir)
	local z = 0
	local x = 0
	if wdir == 4 then
		z = 0.25
	elseif wdir == 2 then
		x = 0.25
	elseif wdir == 5 then
		z = -0.25
	elseif wdir == 3 then
		x = -0.25
	end
	return {x = x, y = 0.08, z = z}
		
end

-- abms for flames
minetest.register_abm({
	nodenames = {"torches:wand"},
	interval = dur - 1,
	chance = 1,
	action = function(pos)
		if player_near(pos) then
			local n = minetest.get_node_or_nil(pos)
			local dir = {x = 0, y = 0, z = 0}
			if n and n.param2 then
				dir = get_offset(n.param2)
			end
			add_fire(pos, dur - .9, dir)
		end
	end
})

minetest.register_abm({
	nodenames = {"torches:floor"},
	interval = dur - 1,
	chance = 1,
	action = function(pos)
		if player_near(pos) then
			add_fire(pos, dur - .9)
		end
	end
})

-- convert old torches and remove ceiling placed
minetest.register_abm({
	nodenames = {"default:torch"},
	interval = 1,
	chance = 1,
	action = function(pos)
		local n = minetest.get_node(pos)
		local def = minetest.registered_nodes[n.name]
		if n and def then
			local wdir = n.param2
			if wdir == 0 then
				minetest.remove_node(pos)
			elseif wdir == 1 then
				minetest.set_node(pos, {name = "torches:floor", param2 = wdir})
			else
				minetest.set_node(pos, {name = "torches:wall", param2 = wdir})
			end
		end
	end
})

-- Item definitions
minetest.register_craftitem(":default:torch", {
	description = "Torch",
	inventory_image = "torches_torch.png",
	wield_image = "torches_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	liquids_pointable = false,
   	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local above = pointed_thing.above
		local under = pointed_thing.under
		local wdir = minetest.dir_to_wallmounted({x = under.x - above.x, y = under.y - above.y, z = under.z - above.z})

		local fakestack = itemstack
		local retval = false
		if wdir < 1 then
			return itemstack
		elseif wdir == 1 then
			retval = fakestack:set_name("torches:floor")
		else
			retval = fakestack:set_name("torches:wall")
		end
		if not retval then
			return itemstack
		end
		itemstack, retval = minetest.item_place(fakestack, placer, pointed_thing, wdir)
		itemstack:set_name("default:torch")

		-- add flame if placing was sucessfull
		if retval then
			-- expect node switch one sever step (default 0.1) delayed
			minetest.after(0.1, add_fire, above, dur, get_offset(wdir))
		end
		return itemstack
	end
})

minetest.register_node("torches:floor", {
	inventory_image = "default_torch.png",
	wield_image = "torches_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 2/16},
	drawtype = "mesh",
	mesh = "torch_floor.obj",
	tiles = {"torches_torch.png"},
	paramtype = "light",
	paramtype2 = "none",
	sunlight_propagates = true,
	drop = "default:torch",
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	legacy_wallmounted = true,
	selection_box = {
		type = "fixed",
		fixed = {-1/16, -0.5, -1/16, 1/16, 2/16, 1/16},
	},
})

minetest.register_node("torches:wall", {
	inventory_image = "default_torch.png",
	wield_image = "torches_torch.png",
	wield_scale = {x = 1, y = 1, z = 1 + 1/16},
	drawtype = "mesh",
	mesh = "torch_wall.obj",
	tiles = {"torches_torch.png"},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 13,
	groups = {choppy=2, dig_immediate=3, flammable=1, not_in_creative_inventory=1, attached_node=1, torch=1},
	drop = "default:torch",
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, -0.1, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, 0.1, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.2, 0.3, 0.1},
	},
})

minetest.register_alias("torches:wand", "torches:wall")
