quests.treasure = {} 

local quest_file = minetest.get_worldpath().."/quests-treasure"

local ground_nodes = {"default:dirt",
		      "default:dirt_with_grass",
		      "default:sand",
		      "default:desert_sand",
		      "mg:dirt_with_dry_grass",
		      "default:dirt_with_snow",
		      "default:snow",
		      "default:gravel",
		      "deafult:river_gravel",
		      
}

local treasure_markers = { [0] = "default:stonebrick",	   
			   [1] = "default:cobble",
			   [2] = "default:bronzeblock",
			   [3] = "default:bookshelf",
			   [4] = "wool:yellow",
			   [5] = "wool:violet",
			   [6] = "moretrees:pine_planks",
}

local treasures = { 
					[1] = {
						{ item = "default:sword_steel", max=1, chance=90, },
						{ item = "3d_armor:helmet_steel", max=1, chance=80, },
						{ item = "3d_armor:chestplate_steel", max=1, chance=80, },
						{ item = "3d_armor:leggings_steel", max=1, chance=80, },
						{ item = "3d_armor:boots_steel", max=1, chance=80, },
						{ item = "default:gold_ingot",max=18, chance=89, },
						{ item = "potions:fly1",max=2, chance=70, },
						{ item = "default:pick_steel",max=1, chance=80, },
						{ item = "default:diamond",max=6, chance=60, },
						{ item = "potions:bones",max=2,chance=75, },
					},
					[2] = {
						{ item = "default:sword_mese", max=1, chance=80, },
						{ item = "3d_armor:helmet_steel", max=1, chance=90, },
						{ item = "3d_armor:chestplate_steel", max=1, chance=90, },
						{ item = "3d_armor:leggings_steel", max=1, chance=90, },
						{ item = "3d_armor:boots_steel", max=1, chance=90, },
						{ item = "default:gold_ingot",max=36, chance=89, },
						{ item = "potions:fly2",max=2, chance=75, },
						{ item = "default:pick_mese",max=1, chance=80, },
						{ item = "default:diamond",max=12, chance=65, },
						{ item = "potions:bones",max=4,chance=80, },
					},
					[3] = {
						{ item = "default:sword_mese", max=1, chance=80, },
						{ item = "3d_armor:helmet_steel", max=1, chance=90, },
						{ item = "3d_armor:chestplate_steel", max=1, chance=90, },
						{ item = "3d_armor:leggings_steel", max=1, chance=90, },
						{ item = "3d_armor:boots_steel", max=1, chance=90, },
						{ item = "default:gold_ingot",max=36, chance=89, },
						{ item = "potions:fly2",max=2, chance=75, },
						{ item = "default:pick_mese",max=1, chance=80, },
						{ item = "default:diamond",max=12, chance=65, },
						{ item = "potions:bones",max=4,chance=80, },
					},
					[4] = {
						{ item = "default:sword_mese", max=1, chance=80, },
						{ item = "3d_armor:helmet_steel", max=1, chance=90, },
						{ item = "3d_armor:chestplate_steel", max=1, chance=90, },
						{ item = "3d_armor:leggings_steel", max=1, chance=90, },
						{ item = "3d_armor:boots_steel", max=1, chance=90, },
						{ item = "default:gold_ingot",max=36, chance=89, },
						{ item = "potions:fly2",max=2, chance=75, },
						{ item = "default:pick_mese",max=1, chance=80, },
						{ item = "default:diamond",max=12, chance=65, },
						{ item = "potions:bones",max=4,chance=80, },
					},
				}

local max_exp = 1000

quests.treasure.generateQuest = function()
  quests.treasure.data.quest_start = os.time()
  quests.treasure.data.quest_end = nil
  quests.treasure.data.completed = false
  quests.treasure.data.completed_by = nil
  quests.treasure.data.pos = nil
  quests.treasure.data.do_on_generate = false
  
  -- find an area to place the treasure box
  local tx = math.random(-20000,20000)
  local tz = math.random(-20000,20000)  
  quests.treasure.data.marker = treasure_markers[math.random(0,(#treasure_markers-1))]
      
  local minp = {x= tx-32, y=-32, z=tz-32}
  local maxp = {x= tx+32, y=32, z=tz+32}
     
  local c_air = minetest.get_content_id("air")
  local c_ignore = minetest.get_content_id("ignore")
  local vm = VoxelManip()
  local e1, e2 = vm:read_from_map(minp, maxp)
  local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
  local data = vm:get_data()
  
  local allair = true
  for _,d in ipairs(data) do
    if d ~= c_air and d ~= c_ignore then
      allair = false
    end
  end
  
  quests.treasure.data.pos = {x=tx,y=0,z=tz}
  default.serialize_to_file(quest_file,quests.treasure.data)
  
  if allair == true then
    quests.treasure.data.do_on_generate = true
    default.serialize_to_file(quest_file,quests.treasure.data)
    return
  end
  quests.treasure.place_treasure({x=tx,y=0,z=tz},vm,e1,e2)  
end

quests.treasure.tell_story = function(pos)
	
	if quests.treasure.data.completed == false and quests.treasure.data.pos ~= nil then
	  local directions = "The old explorer says, 'If you search about "
	  local diff = math.floor(pos.x - quests.treasure.data.pos.x)
	  diff = diff - ( diff % 5 ) 
	  directions = directions .. tostring(math.abs(diff)) .. " meters "
	  if pos.x < quests.treasure.data.pos.x then
	    directions = directions .. "east"
	  else
	    directions = directions .. "west"
	  end
	  
	  diff = math.floor(pos.z - quests.treasure.data.pos.z)
	  diff = diff - ( diff % 5 )
	  directions = directions .. " and about " .. tostring(math.abs(diff)) .. " meters "
	  if pos.z > quests.treasure.data.pos.z then
	     directions = directions .. "south"
	  else
	     directions = directions .. "north"
	  end
	
	  directions = directions .. "'"
	  chat.local_chat(pos,"The old explorer says, 'I hear there are treasures buried in these lands...'",12)
	  minetest.after(4,chat.local_chat,pos,directions,12)
	  minetest.after(8,chat.local_chat,pos,"The old explorer says, 'You should find the treasure buried under a "..minetest.registered_nodes[quests.treasure.data.marker].description.."'",12)
	else
		chat.local_chat(pos,"The old explorer says, 'I hear "..tostring(quests.treasure.data.completed_by).." recently found some treasure'")
		minetest.after(4,chat.local_chat,pos,"The old explorer says, 'Come talk to me later and I will let you know if I hear of any more treasure'")
	end
end

-- LOAD DATA FROM PREVIOUS SESSION
quests.treasure.data = default.deserialize_from_file(quest_file)

-- If data is an emtpy table then generateQuest
if next(quests.treasure.data) == nil then
	minetest.after(1,quests.treasure.generateQuest)
else
	if quests.treasure.data.completed == true then
		minetest.after(60,quests.treasure.generateQuest)
	end
end

function is_ground_node(nodeid)
    for _,n in ipairs(ground_nodes) do
      if minetest.get_content_id(n) == nodeid then
	return true
      end
    end
    return false
end

quests.treasure.place_treasure = function (pos,minp,maxp)
  local c_air = minetest.get_content_id("air")
  local c_water = minetest.get_content_id("default:water_source")
  local prevnode = nil  
  
  local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    
  local e1, e2 = vm:read_from_map(minp, maxp)
  local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})
  local data = vm:get_data()
  
  -- find ground level
  for tz = minp.z, maxp.z,1 do
    for tx=minp.x, maxp.x,1 do
      for ty=32,-32,-1 do	
		if data[area:index(tx, ty, tz)] ~= c_air then
		    --if is_ground_node(data[area:index(tx, ty, tz)]) then
		      if prevnode == c_air or prevnode == c_water then
				quests.treasure.data.pos = {x=tx,y=ty-2,z=tz}
				quests.treasure.data.do_on_generate = false
				data[area:index(tx, ty+1, tz)] = minetest.get_content_id(quests.treasure.data.marker)
				local depth = math.random(2,6)
				data[area:index(tx,ty-depth,tz)] = minetest.get_content_id("quests:treasure_chest")
				vm:set_data(data)
				vm:write_to_map(data)
				vm:update_map()
				quests.treasure.set_inventory({x=tx,y=ty-depth,z=tz})
				default.serialize_to_file(quest_file,quests.treasure.data)
				return
		      end
		    --end
		end
		prevnode = data[area:index(tx, ty, tz)]
      end
      prevnode = nil
    end
  end
  -- placing treasure failed
  minetest.after(60,quests.treasure.generateQuest)
  --quests.treasure.data.do_on_generate = true
end

quests.treasure.set_inventory = function (pos)
	local distance = default.get_distance(game_origin,{x=pos.x,y=0,z=pos.z})
	local treasure_level = math.floor( distance / 5000 )
	if treasure_level == 0 then treasure_level = 1 end
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec",default.chest_formspec)
	meta:set_string("infotext", "Treasure Chest")
		
	local treasure_set = treasures[treasure_level]
	if treasure_set ~= nil then
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		for _,item in pairs(treasure_set) do
			if math.random(1,100) < item.chance then
				local qty = math.random(1,item.max)
				inv:add_item("main",item.item.." "..tostring(qty))
			end
		end
		
		-- add experience to the chest
		local exp = max_exp * ( distance / 30000 )
		local exp_items = experience.exp_to_items(exp)
		for _,e in pairs(exp_items) do
			inv:add_item("main",e)
		end
	end
end

quests.treasure.end_quest = function (player)
	local name = player:get_player_name()
	quests.treasure.data.quest_end = os.time()
	quests.treasure.data.completed = true
	quests.treasure.data.completed_by = name
	minetest.after(120,quests.treasure.generateQuest)
	default.serialize_to_file(quest_file,quests.treasure.data)
end

--[[minetest.register_on_generated(function(minp, maxp, seed)	
  
end)]]

-- called from mg mod
quests.treasure.on_generated = function (minp,maxp)
  if quests.treasure.data.do_on_generate == true then
    if quests.treasure.data.pos.x > minp.x and quests.treasure.data.pos.x < maxp.x and quests.treasure.data.pos.z > minp.z and quests.treasure.data.pos.z < maxp.z then
      --local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
      quests.treasure.place_treasure(quests.treasure.data.pos,minp,maxp)
    end
  end
end

minetest.register_node("quests:treasure_chest", {
	description = "Treasure Chest",
	tiles = {"default_chest_top.png", "default_chest_top.png", "default_chest_side.png",
		"default_chest_side.png", "default_chest_side.png", "default_chest_front.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",default.chest_formspec)
		meta:set_string("infotext", "Treasure Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		quests.treasure.end_quest(digger)
		local meta = minetest:get_meta(pos)
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		default.dump_inv(pos,"main",inv)
	end,	
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff in chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" moves stuff to chest at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		quests.treasure.end_quest(player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from chest at "..minetest.pos_to_string(pos))
	end,
})
