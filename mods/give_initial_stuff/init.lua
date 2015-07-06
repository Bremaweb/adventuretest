minetest.register_on_newplayer(function(player)
	--print("on_newplayer")	
		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
		player:get_inventory():add_item('main', 'default:stick 6')
		player:get_inventory():add_item('main', 'default:torch 25')
		player:get_inventory():add_item('main', 'default:tree 3')
		player:get_inventory():add_item('main', 'default:axe_steel')
		if minetest.get_modpath("landrush") ~= nil then
		  player:get_inventory():add_item('main', 'landrush:landclaim 4')
		end
end)

