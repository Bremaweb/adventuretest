minetest.register_on_newplayer(function(player)
	--print("on_newplayer")	
		minetest.log("action", "Giving initial stuff to player "..player:get_player_name())
		player:get_inventory():add_item('main', 'default:stick 6')
		player:get_inventory():add_item('main', 'default:torch 25')
		player:get_inventory():add_item('main', 'default:tree 3')
end)

