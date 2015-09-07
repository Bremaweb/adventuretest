-- a Mod for keeping track of a player's current 
-- physics properties and allows building layers of
-- physics across multiple mods 
-- physics persist across sessions and server shutdowns

physics = {}
function physics.adjust_physics(player,_physics)
	local name = player:get_player_name()
	for p,v in pairs(_physics) do
		pd.increment(name,p,v) 
	end
	physics.apply(player)
end

function physics.apply(player)
	if player ~= nil then
		local name = player:get_player_name()
		if pd.get(name,"frozen") ~= true then
			local o = physics.get_player_physics(name)
			player:set_physics_override(o)
		end
	end
end

function physics.freeze_player(name)
	local player = minetest.get_player_by_name(name)
	pd.set(name,"frozen",true)
	player:set_physics_override({speed=0,jump=0})
end

function physics.unfreeze_player(name)
	local player = minetest.get_player_by_name(name)
	pd.set(name,"frozen",false)
	physics.apply(player)
end

function physics.remove_item_physics(player,item)
	if minetest.registered_items[item] ~= nil then
		if minetest.registered_items[item].physics ~= nil then
			local physics_adj = {}
			for k,v in pairs(minetest.registered_items[item].physics) do
				physics_adj[k] = v * -1
			end
			physics.adjust_physics(player,physics_adj)
		end
	end
end

function physics.get_player_physics(name)
	local o = {}
	o["speed"] = pd.get_number(name,"speed")
	o["jump"] = pd.get_number(name,"jump")
	o["gravity"] = pd.get_number(name,"gravity")
	return o
end

function physics.apply_item_physics(player,item)
	if minetest.registered_items[item] ~= nil then
		if minetest.registered_items[item].physics ~= nil then
			physics.adjust_physics(player,minetest.registered_items[item].physics)
		end
	end
end

function physics.apply_all()
	-- reapply physics to everybody just in case we've missed it in a spot, or if it didn't take at the begining
	for _,p in pairs(minetest.get_connected_players()) do
		physics.apply(p)
	end
	minetest.after(30,physics.apply_all)
end
minetest.after(30,physics.apply_all)

