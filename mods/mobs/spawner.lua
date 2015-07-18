-- mob spawner

minetest.register_node("mobs:spawner",{
  description = "Mob Spawner",
  groups = { oddly_breakable_by_hand=3 },
  tiles = { "mobs_spawner.png" },
  sunlight_propagates = true,
  drop = "default:dirt",
  on_receive_fields = function(pos, formname, fields, sender)    
    local name = sender:get_player_name()
    if minetest.check_player_privs(name,{ immortal=true }) then
      local meta = minetest.get_meta(pos)
      meta:set_string("entity",fields.entity)
      meta:set_string("infotext",fields.entity)
      if fields.active_objects ~= nil then
	meta:set_int("active_objects",fields.active_objects)
      end
      if fields.active_objects_wider ~= nil then
	meta:set_int("active_objects_wider",fields.active_objects_wider)
      end
      meta:set_string("formspec",getformspec(pos))
    else
      minetest.chat_send_player(name,"You do not have permission to change mob spawner settings")
    end
end,
  after_place_node = function(pos, placer, itemstack, pointed_thing)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec",getformspec(pos))    
end,  
  can_dig = function(pos,player)
    return minetest.check_player_privs(player:get_player_name(),{ immortal=true })
  end,
	on_punch = function (pos, node, puncher, pointed_thing)
		print("punched")
		if minetest.check_player_privs(puncher:get_player_name(),{ immortal=true }) then
			local meta = minetest.get_meta(pos)
			local entity = meta:get_string("entity")
			if entity ~= "" then	
				if minetest.registered_entities[entity] == nil then	  
					if mobs.mob_list[entity] ~= nil then
						entity = mobs:get_random(entity)
					else
						return
					end
				end
				local spawnpos = pos
				spawnpos.y = spawnpos.y + 4
				minetest.log("action","Spawn block spawning "..tostring(entity).." at "..minetest.pos_to_string(spawnpos))
				mobs:spawn_mob(spawnpos,entity)
			else
				minetest.log("action","No entity set in spawner block at "..minetest.pos_to_string(pos))
			end
		end
	end,
})

minetest.register_abm({
	nodenames = {"mobs:spawner"},
	interval = 60,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)	
	local meta = minetest.get_meta(pos)
	local entity = meta:get_string("entity")
	local active_objects = meta:get_int("active_objects")
	local active_objects_wider = meta:get_int("active_objects_wider")
	if entity ~= "" then	
		if minetest.registered_entities[entity] == nil then	  
		    if mobs.mob_list[entity] ~= nil then
		      entity = mobs:get_random(entity)
		    else
		      return
		    end
		end
		if active_objects_wider > 0 then
		  if active_object_count_wider > active_objects_wider then    
		    return
		  end
		end
		
		if active_objects > 0 then
		  if active_object_count > active_objects then    
		    return
		  end
		end
		
		local spawnpos = { x=pos.x, y=pos.y, z=pos.z }
		spawnpos.y = spawnpos.y + 6
		minetest.log("action","Spawn block spawning "..tostring(entity).." at "..minetest.pos_to_string(spawnpos))
		local r = mobs:spawn_mob(spawnpos,entity)
		if r == -1 then
			-- they are spawning in a block, remove this spawner
			local fails = meta:get_int("spawning_fails")
			fails = fails + 1
			meta:set_int("spawning_fails",fails)
			if fails > 5 then
				minetest.log("action","Too many spawning fails, removing spawning block at "..minetest.pos_to_string(pos))
				minetest.remove_node(pos)
			end
		end
	else
		minetest.log("action","No entity set in spawner block at "..minetest.pos_to_string(pos))
	end
end,
})

function getformspec(pos)
  local meta = minetest.get_meta(pos)
  
  local spawnerformspec =              "size[6,6,false]"
  spawnerformspec = spawnerformspec .. "field[.5,0.5;5,1;entity;Mob;"..meta:get_string("entity").."]"
  spawnerformspec = spawnerformspec .. "field[.5,2;3,1;active_objects;Active Objects;"..meta:get_string("active_objects").."]"
  spawnerformspec = spawnerformspec .. "field[.5,3.5;3,1;active_objects_wider;Active Objects Wider;"..meta:get_string("active_objects_wider").."]"
  spawnerformspec = spawnerformspec .. "button_exit[.5,5;3,1;send;Save]"
  return spawnerformspec
end

function mobs.spawn_npc_and_spawner(pos,barbarian_village)
local numNPCs = math.random(0,1)
		--print("Spawning "..tostring(numNPCs).." NPCs")
		if numNPCs > 0 then
			for i=0,numNPCs,1 do
				local npos = pos
				npos.x = npos.x + math.random(-8,8)
				npos.y = npos.y + 2
				npos.z = npos.z + math.random(-8,8)
				
				local spawnerpos = {x=npos.x, y=npos.y, z=npos.z}
				spawnerpos.y = spawnerpos.y - 5
				
				if barbarian_village == true then
					local barbarian = mobs:get_random('barbarian')
					minetest.log("action","Spawning "..barbarian.." at "..minetest.pos_to_string(npos))
					local mob = minetest.add_entity(pos, barbarian)
					if mob then
						local distance_rating = ( ( get_distance({x=0,y=0,z=0},npos) ) / 15000 )
						mob = mob:get_luaentity()
						local newHP = mob.hp_min + math.floor( mob.hp_max * distance_rating )
						mob.object:set_hp( newHP )
						local metatable = {  fields = { entity = barbarian, active_objects = 6 } }
						--table.insert(extranodes, {node={name="mobs:spawner",param1=0, param2=0}, pos=spawnerpos,mob="barbarian"})
					end
				else
					
					local npc = mobs:get_random('npc')
					minetest.log("action","Spawning "..npc.." at "..minetest.pos_to_string(npos))
					local mob = minetest.add_entity(pos, npc)
					if mob then
						mob = mob:get_luaentity()
						local p = mob.object:getpos()
						math.randomseed( ( p.x * p.y * p.z ) )
						local metatable = {  fields = { entity = npc, active_objects = 6 } }
						--table.insert(extranodes, {node={name="mobs:spawner",param1=0, param2=0}, pos=spawnerpos, mob="npc"})
					end
				end
			end
		end
end


