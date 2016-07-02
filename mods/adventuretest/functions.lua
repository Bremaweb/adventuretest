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
	for _, player in pairs(p) do
		local name = player:get_player_name()
		for k,hook in pairs(adventuretest.pl_hooks) do
			adventuretest.pl_hooks[k].timer = adventuretest.pl_hooks[k].timer + dtime
			if adventuretest.pl_hooks[k].timer >= adventuretest.pl_hooks[k].timeout then
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
	local count = 0
	local newpos = player:getpos()
	local badpos = false
	while adventuretest.obj_stuck(player) == true and count < 5 do
		print("moving player")
		local pos = player:getpos()		
		newpos.x = pos.x + math.rand(-10,10)
		newpos.z = pos.z + math.rand(-10,10)
		adventuretest.teleport(player,newpos)
		count = count + 1
		badpos = true
	end
	if badpos == true then
		-- check the elevation so they don't fall to their death
		local ab = adventuretest.above_ground(newpos)
		if ab ~= false and ab > 3 then
			newpos.y = ( newpos.y - ( ab - 3 ) )
			adventuretest.teleport(player,newpos)
		end
	end
	local n = player:get_player_name()
	pd.set(n,"homepos",newpos)
end

-- sees if a player  or entity is in a block
function adventuretest.obj_stuck(obj)
	local pos = obj:getpos()
	local pn = adventuretest.get_obj_nodes(obj)
	if pn.feet.walkable == false or pn.head.walkable == false then
		return true
	end
	return false
end

-- mostly used for getting the nodes the player or entity is in
function adventuretest.get_obj_nodes(obj)
	local pos = obj:getpos()
	local retval = {}
	
	pos.y = pos.y - 1
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
		if n.walkable == false then
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
