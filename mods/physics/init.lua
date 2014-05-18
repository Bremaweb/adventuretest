-- a Mod for keeping track of a player's current 
-- physics properties and allows building layers of
-- physics across multiple mods 
-- physics persist across sessions and server shutdowns

physics = {}
local physics_file = minetest.get_worldpath() .. "/physics"
physics.player_physics = default.deserialize_from_file(physics_file)
physics.player_frozen = {}
function physics.adjust_physics(player,_physics)
	local name = player:get_player_name()
	for p,v in pairs(_physics) do
		physics.player_physics[name][p] = physics.player_physics[name][p] + v 
	end
	physics.apply(player)
end

function physics.apply(player)
	local name = player:get_player_name()
	if physics.player_frozen[name] ~= true then
		player:set_physics_override(physics.player_physics[name])
	end
end

function physics.freeze_player(name)
	local player = minetest.get_player_by_name(name)
	physics.player_frozen[name] = true
	player:set_physics_override({speed=0,jump=0})
end

function physics.unfreeze_player(name)
	local player = minetest.get_player_by_name(name)
	physics.player_frozen[name] = false
	physics.apply(minetest.get_player_by_name(name))
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
	return physics.player_physics[name]
end

function physics.apply_item_physics(player,item)
	if minetest.registered_items[item] ~= nil then
		if minetest.registered_items[item].physics ~= nil then
			physics.adjust_physics(player,minetest.registered_items[item].physics)
		end
	end
end

function physics.init_player(player)
	-- reset physics to default when the player joins
	local name = player:get_player_name()
	if physics.player_physics[name] == nil then
		 physics.player_physics[name] = {speed = 1, jump = 1, gravity = 1}
	end
	minetest.after(10,physics.apply,player)
end

function physics.apply_all()
	-- reapply physics to everybody just in case we've missed it in a spot, or if it didn't take at the begining
	for _,p in pairs(minetest.get_connected_players()) do
		physics.apply(p)
	end
	default.serialize_to_file(physics_file,physics.player_physics)
	minetest.after(30,physics.apply_all)
end

minetest.register_on_joinplayer(physics.init_player)

minetest.register_on_shutdown(function ()
	default.serialize_to_file(physics_file,physics.player_physics)
end)

minetest.after(30,physics.apply_all)

