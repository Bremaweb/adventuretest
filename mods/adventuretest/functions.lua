abm_counter = 0
abm_timer = 0
abm_limit = 999
abm_time_limit = 1

function abm_limiter()
	if abm_counter > abm_limit then
		return true
	end
	abm_counter = abm_counter + 1
	return false
end

function abm_globalstep(dtime)
	abm_timer = abm_timer + dtime
	if abm_timer > abm_time_limit then
		abm_counter = 0
		abm_timer = 0
	end
end

adventuretest.pl_hooks = {}
function adventuretest.player_loop(dtime)
	local p = minetest.get_connected_players()
	local reset_hooks = {}
	for k,hook in pairs(adventuretest.pl_hooks) do
		adventuretest.pl_hooks[k].timer = adventuretest.pl_hooks[k].timer + dtime
		if adventuretest.pl_hooks[k].timer >= adventuretest.pl_hooks[k].timeout then
			for _, player in pairs(p) do
				local name = player:get_player_name()
				adventuretest.pl_hooks[k].timer = 0
				adventuretest.pl_hooks[k].func(player,name,dtime)
			end
		end 
	end
end

function adventuretest.register_pl_hook(f,t)
	table.insert(adventuretest.pl_hooks,{func=f,timeout=t,timer=0})
end

function adventuretest.teleport(player,pos)
	local name = player:get_player_name();
	pd.set(name,"lastpos",pos)
	player:moveto(pos)
end

function adventuretest.check_spawn(player)
	print("checking spawn")
	local count = 0
	local newpos = player:getpos()
	local badpos = false
	if adventuretest.obj_stuck(player) == true then
		print("moving player "..tostring(count))
		local pos = player:getpos()		
		--math.randomseed(os.time())
		newpos.x = pos.x + math.random(-50,50)
		newpos.z = pos.z + math.random(-50,50)
		
		local ab = adventuretest.above_ground(newpos)
		print("above ground: "..tostring(ab))
		if ab ~= false and ab > 4 then
			newpos.y = ( newpos.y - ( ab - 3 ) )
		else
			newpos.y = pos.y + math.random(0,10)
		end
		
		
		adventuretest.teleport(player,newpos)
		--count = count + 1
		--badpos = true
		minetest.after(3,adventuretest.check_spawn,player)
		return
	end
	if badpos == true then
		print("checking elevation")
		-- check the elevation so they don't fall to their death
		local ab = adventuretest.above_ground(newpos)
		print("above ground: "..tostring(ab))
		if ab ~= false and ab > 3 then
			newpos.y = ( newpos.y - ( ab - 3 ) )
			adventuretest.teleport(player,newpos)
		end
	end
	local n = player:get_player_name()
	pd.set(n,"homepos",newpos)
	player:hud_remove(pd.get(n,"spawning_hud"))
	pd.set(n,"spawning_hud",nil)
end

-- sees if a player  or entity is in a block
function adventuretest.obj_stuck(obj)
	local pos = obj:getpos()
	local pn = adventuretest.get_obj_nodes(obj)
	print("Feet walkable "..tostring(minetest.registered_nodes[pn.feet.name].walkable))
	print("Head walkable "..tostring(minetest.registered_nodes[pn.head.name].walkable))
	print("Feet node "..pn.feet.name)
	if minetest.registered_nodes[pn.feet.name].walkable == true or minetest.registered_nodes[pn.head.name].walkable == true or pn.feet.name == "ignore" or pn.head.name == "ignore" then
		return true
	end
	return false
end

-- mostly used for getting the nodes the player or entity is in
function adventuretest.get_obj_nodes(obj)
	local pos = obj:getpos()
	local retval = {}
	
	pos.y = pos.y
	retval.standing_on = minetest.get_node(pos)
	pos.y = pos.y + 1
	retval.feet = minetest.get_node(pos)
	pos.y = pos.y + 1
	retval.head = minetest.get_node(pos)
	
	return retval
end

function adventuretest.above_ground(pos)
	local step = 0
	local dest = 0
	if pos.y > 0 then
		step = -1
		dest = -35 
	else
		step = 1
		dest = 125
	end
	for y = pos.y,dest,step do
		local n = minetest.get_node({x=pos.x,y=y,z=pos.z})
		if minetest.registered_nodes[n.name].walkable == true then
			return math.abs(pos.y - y)
		end
	end 
	return false
end

function hunger_join_player(player)
	local name = player:get_player_name()		
	local lvl = pd.get_number(name,"hunger_lvl")
	if lvl > 20 then
		lvl = 20
	end
	minetest.after(0.8, function()
		hud.change_item(player, "hunger", {offset = "item", item_name = "hunger"})
		hud.change_item(player, "hunger", {number = lvl, max = 20})
	end)
end

function adventuretest.is_night()
	local t = minetest.get_timeofday()
	if t > 0.8 or t < 0.4 then
		return true
	else
		return false
	end
end