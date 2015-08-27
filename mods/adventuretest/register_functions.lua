-- Only register one global step for this game and just call the respective globalstep functions
-- from within this function, preliminary testing shows that registering one globalstep and calling
-- all of your global step functions from there could slightly improve performance
-- having all dig node code in one function seemed to have the most improvement over calling several dignode
-- functions 

local function adventuretest_globalstep(dtime)
  default.player_globalstep(dtime)
  default.leaf_globalstep(dtime)
  energy_globalstep(dtime)
  hunger.global_step(dtime)
  itemdrop_globalstep(dtime)
  armor_globalstep(dtime)
  wieldview_globalstep(dtime)
  blacksmith_globalstep(dtime)
  throwing_globalstep(dtime)
  magic_globalstep(dtime)
  --ambience_globalstep(dtime)
end
minetest.register_globalstep(adventuretest_globalstep)

local function adventuretest_die_player(player)
	bones_on_dieplayer(player)
	skills_on_dieplayer(player)	
  	hunger.update_hunger(player, 20)
  	affects.player_died(player)
  	player:set_hp(20)
  	if sethome_respawnplayer(player) == false then  		
  		mg_villages.spawnplayer(player)
  	end
  	energy.respawnplayer(player)
  	stats.increment(player:get_player_name(),STAT_DIED,1)
  	return true
end

minetest.register_on_dieplayer(adventuretest_die_player)

local function adventuretest_dignode(pos, node, digger)
  --print("on_dignode")
  -- going to try to consolidate all on_dignode calls here so there is only one function call
  
  -- ON DIG NODE FOR MONEY MOD
  for k,v in pairs(money.convert_items) do
    if ( node.name == money.convert_items[k].dig_block ) then     
      money.stats[k].running_dug = money.stats[k].running_dug + 1 
    end
  end
  
  -- EXPERIENCE
  if minetest.registered_nodes[node.name] ~= nil then
    if minetest.registered_nodes[node.name]["skill"] ~= nil then
       default.drop_item(pos,"experience:1_exp")
    end
  end
  
  -- ENERGY
  if digger ~= nil and digger ~= "" then
    local name= digger:get_player_name()
    if player_energy[name] ~= nil then
      player_energy[name] = player_energy[name] - 0.05
    end
    
    stats.increment(name,STAT_DUG,1)
    local dug = stats.get(name,STAT_DUG)
	if dug % 100 == 0 then
		local ppos = digger:getpos()
		-- every 100 give them some experience
		local multiplier = dug / 100
		local exp = 5 * multiplier
		local e = experience.exp_to_items(exp)
		for _,item in pairs(e) do
			default.drop_item(ppos,item)
		end
	end
  end
  
  hunger.handle_node_actions(pos, node, digger)
end
minetest.register_on_dignode(adventuretest_dignode)

local function adventuretest_placenode(pos, node, placer)
  hunger.handle_node_actions(pos,node,placer)
  if placer:is_player() then
	  local name = placer:get_player_name()
	  stats.increment(name,STAT_PLACED,1)
	  
	  local placed = stats.get(name,STAT_PLACED)
	  if placed % 100 == 0 then
	  	local ppos = placer:getpos()
	  	-- every 100 give them some experience
	  	local multiplier = placed / 100
	  	local exp = 5 * multiplier
	  	local e = experience.exp_to_items(exp)
	  	for _,item in pairs(e) do
	  		default.drop_item(ppos,item)
	  	end
	  end
  end
end
minetest.register_on_placenode(adventuretest_placenode)


local function on_generated(minp,maxp,seed)
	quests.treasure.on_generated(minp,maxp)
end
minetest.register_on_generated(on_generated)

local function on_join(player)
	stats.load(player:get_player_name())
end
minetest.register_on_joinplayer(on_join)

local function on_leave(player)
	local name = player:get_player_name()
	stats.save(name)
	stats.unload(name)
end
minetest.register_on_leaveplayer(on_leave)

local function on_shutdown()
	stats.save_all()
end

minetest.register_on_shutdown(on_shutdown)
