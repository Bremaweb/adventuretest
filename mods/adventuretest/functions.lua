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