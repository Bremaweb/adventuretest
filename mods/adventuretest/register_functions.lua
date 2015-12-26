-- Only register one global step for this game and just call the respective globalstep functions
-- from within this function, preliminary testing shows that registering one globalstep and calling
-- all of your global step functions from there could slightly improve performance
-- having all dig node code in one function seemed to have the most improvement over calling several dignode
-- functions 



local function adventuretest_globalstep(dtime)
  adventuretest.player_loop(dtime)
  default.leaf_globalstep(dtime)
    
  if blacksmith_globalstep ~= nil then  
  	blacksmith_globalstep(dtime)
  end
  
  if mobs ~= nil then
  	mobs.global_step(dtime)
  end
  
  abm_globalstep(dtime)
  --ambience_globalstep(dtime)
end
minetest.register_globalstep(adventuretest_globalstep)

local function adventuretest_die_player(player)
	local name = player:get_player_name()
	if default.attached_to_player[name] ~= nil then
		local a = default.attached_to_player[name]
		a.object:set_detach()
		default.attached_to_player[name] = nil
		if a.name == "npc:kid_lost" then
			a.random_freq = 15
		end
	end
	bones_on_dieplayer(player)
	skills_on_dieplayer(player)	
  	hunger.update_hunger(player, 20)
  	affects.player_died(player)
  	player:set_hp(20)
  	if sethome_respawnplayer(player) == false then  		
  		mg_villages.spawnplayer(player)
  	end
  	energy.respawnplayer(player)
  	pd.increment(name,STAT_DIED,1)
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
    pd.increment(name,"energy",-0.05)
    
    pd.increment(name,STAT_DUG,1)
    local dug = pd.get(name,STAT_DUG)
	if dug % 100 == 0 then
		local ppos = digger:getpos()
		-- every 100 give them some experience
		local base = 1
		local bonus = dug / 1800
		local decelerator = 2500		
		local exp = base + bonus - math.floor(dug / decelerator) 
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
	  pd.increment(name,STAT_PLACED,1)
	  
	  local placed = pd.get(name,STAT_PLACED)
	  if placed % 100 == 0 then
	  	local ppos = placer:getpos()
	  	-- every 100 give them some experience
	  	local base = 1
		local bonus = placed / 1800
		local decelerator = 2500		
		local exp = base + bonus - math.floor(placed / decelerator) 
		local e = experience.exp_to_items(exp)
		for _,item in pairs(e) do
			default.drop_item(ppos,item)
		end
	  end
  end
end
minetest.register_on_placenode(adventuretest_placenode)


local function on_generated(minp,maxp,seed)
	mg_villages.on_generated(minp,maxp,seed)
	quests.treasure.on_generated(minp,maxp)
end
minetest.register_on_generated(on_generated)

local function on_join(player)	
	pd.load_player(player:get_player_name())
	if minetest.setting_getbool("enable_damage") then
		hunger_join_player(player)
	end
end
minetest.register_on_joinplayer(on_join)

local function on_leave(player)
	local name = player:get_player_name()
	pd.unload_player(name)
end
minetest.register_on_leaveplayer(on_leave)

local function on_new(player)
	local name = player:get_player_name()
	pd.load_player(name)
	-- set some defaults
	pd.set(name,"energy",20)
	pd.set(name,"stamina",0)
	pd.set(name,"mana",20)
	pd.set(name,"hunger_lvl",20)
	pd.set(name,"hunger_exhaus",0)
	pd.set(name,"speed",1)
	pd.set(name,"jump",1)
	pd.set(name,"gravity",1)
	pd.set(name,"level", {level=1,exp=0})
	skills.set_default_skills(name)
	pd.save_player(name)
	mg_villages.on_newplayer(player)
end
minetest.register_on_newplayer(on_new)


local function on_shutdown()
	pd.save_all()
end
minetest.register_on_shutdown(on_shutdown)
