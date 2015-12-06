mobs:register_mob("mobs:blacksmith",{
	type = "npc",
	hp_min = 30,
	hp_max = 75,
	exp_min = 0,
	exp_max = 0,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "3d_armor_character.x",
	textures = {"mobs_blacksmith.png",	
				"3d_armor_trans.png",
				minetest.registered_items["cottages:hammer"].inventory_image,
			},
	visual_size = {x=1, y=1},
	makes_footstep_sound = true,
	view_range = 12,
	walk_velocity = 1,
	run_velocity = 4.5,
	damage = 6,
	drops = { },
	armor = 150,
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = function (self, clicker)
		-- show formspec
		if self.state ~= "path" and self.state ~= "working" then
			blacksmith_formspec(self,clicker)
		else
			chat.local_chat(clicker:getpos(),"Blacksmith: Sorry, I'm busy. Come back later",3)
		end
	end,
	walk_chance = 1,
	stationary = true,
	attack_type = "dogfight",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 189,
		punch_end = 198,
	},
	jump = false,
	sounds = {
		war_cry = "mobs_die_yell",
		death = "default_death",
		attack = "default_punch2",
	},
	attacks_monsters=false,
	peaceful = true,
	group_attack = false,
	blood_amount = 35,
	blood_offset = 0.25,
	activity_level = 1,
	lifetimer = false,
	avoid_nodes = {"default:water_source","default:water_flowing","default:lava_source","default:lava_flowing"},
	avoid_range = 4,
})

-- list of active blacksmiths... I'm not sure how this is going to work when an entity is unloaded
local active_blacksmiths = {}

function blacksmith_formspec(self,player)
	local name = player:get_player_name()
	if active_blacksmiths[name] == nil then
		mobs:face_pos(self,player:getpos())
		chat.local_chat(player:getpos(),"Blacksmith: Give me your metal lumps and I will smelt them for you",3)
		active_blacksmiths[name] = {entity=self,inventory=nil,player=player,furnace=nil,active=false}
		local formspec = "size[8,6.25]"..
						"list[current_player;main;0,2.5;8,4;]"..
						"label[3,0.25;Lump]"..
						"list[detached:"..name.."_blacksmith;src;3,0.75;1,1;]"..
						"button_exit[5,0.25;2,1;smelt;Smelt]"..
						"button_exit[5,1;2,1;cancel;Cancel]"
		minetest.show_formspec(name,"blacksmith",formspec)
	else
		chat.local_chat(player:getpos(),"Blacksmith: Sorry, I'm not able to work for you at this time",3)
	end
end

function blacksmith_use_furnace(self,player)
	local name = player:get_player_name()
	local pos = active_blacksmiths[name].furnace
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_stack("src",1,active_blacksmiths[name].inventory)
	inv:set_stack("fuel",1,"default:coal_lump 99")
	self.state = "working"
	self.set_animation(self,"punch")
	active_blacksmiths[name].active = true
end

minetest.register_on_player_receive_fields(function(player,formname,fields)
	if formname == "blacksmith" then
		local name = player:get_player_name()
		local blacksmith = active_blacksmiths[name].entity
		if blacksmith == nil then
			minetest.chat_send_player(name,"An error occured... blacksmith lost")
			minetest.log("error","Blacksmith lost")
			return
		end
		if fields.smelt then
			-- find a furnace
			local inv = minetest.get_inventory({type="detached", name=name.."_blacksmith"})
			local stack = inv:get_stack("src",1)
			if stack:get_count() == 0 then
				chat.local_chat(player:getpos(),"Blacksmith: Please give me something to smelt",3)
				active_blacksmiths[name] = nil
				return
			else
				-- see if it's a smeltable item
			end
			local furnace = minetest.find_node_near(player:getpos(),55,{"default:furnace"})
			if furnace ~= nil then
				--furnace.y = furnace.y + 1
				local node = minetest.get_node(furnace)		-- On top of the furnace
				local fdir = minetest.facedir_to_dir(node.param2)
				local dest = {x=furnace.x,y=furnace.y,z=furnace.z}
					dest.x = dest.x + ( fdir.x * -1 )
					dest.y = dest.y + ( fdir.y * -1 )
					dest.z = dest.z + ( fdir.z * -1 )
				
				local start = blacksmith.object:getpos()
				start.y = start.y - 1
				-- find a path to the furnace
				local path = minetest.find_path(start,dest,5,2,3,"A*")
				if path ~= nil then	
					local crNeeded = (stack:get_count() * 2)
					if money.get(name) < crNeeded then
						chat.local_chat(player:getpos(),"Blacksmith: Sorry, you don't have enough money. I charge 2cr per lump.")
						active_blacksmiths[name] = nil
						return
					end
					money.dec(name,crNeeded)
					-- move the inventory from the detached inventory to the inventory variable
					active_blacksmiths[name].inventory = stack
					active_blacksmiths[name].furnace = furnace
					inv:remove_item("src",stack)
					blacksmith.path = path
					blacksmith.start_path(blacksmith, function (self) 
						blacksmith_use_furnace(self,player)
					end)
				else
					chat.local_chat(player:getpos(),"Blacksmith: Sorry, I can't get to the furance.",3)
					active_blacksmiths[name] = nil
					return
				end
			else
				chat.local_chat(player:getpos(),"Blacksmith: Sorry, I don't see a furance in this area.",3)
				active_blacksmiths[name] = nil
				-- TODO Get invnetory and throw item toward player
			end
		else
			active_blacksmiths[name] = nil
		end
	end
end)

-- create detached inventory for blacksmith
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local binv = minetest.create_detached_inventory(name.."_blacksmith",{})
	binv:set_size("src",1)
end)

local bs_timer = 5
function blacksmith_globalstep(dtime)
	bs_timer = bs_timer - dtime
	if bs_timer <= 0 then
		bs_timer = 3
		-- loop through the active blacksmiths and check their furnaces
		local addtl = 0
		for name,bs in pairs(active_blacksmiths) do
			if bs.active == true then
				addtl = addtl + 1
				bs.entity.set_animation(bs.entity,"punch")
				bs.entity.state = "working"
				mobs:face_pos(bs.entity,bs.furnace)	-- make sure he is facing the correct furnace
				local meta = minetest.get_meta(bs.furnace)
				local inv = meta:get_inventory()
				meta:set_int("in_use",1)
				if inv:is_empty("src") then
					-- empty the fuel
					inv:set_stack("fuel",1,nil)
					print("smelting done")
					-- they are done smelting
					local dlist = inv:get_list("dst")
					-- TODO return smelted items to the player
					
					-- blacksmith is done working
					bs.entity.state = "standing"
					bs.entity.set_animation(bs.entity,"stand")
					chat.local_chat(bs.entity.object:getpos(),"Blacksmith: "..name.." your ingots are ready!",25)
					active_blacksmiths[name] = nil		-- I think it's all byref so bs = nil should also work
					meta:set_int("in_use",0)
				end
			--print("processing done")
			end
		end
		-- when there are more blacksmiths active slow down this loop
		bs_timer = bs_timer + addtl
	end
end

