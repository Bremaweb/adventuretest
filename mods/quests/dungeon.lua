
minetest.register_craftitem("quests:dungeon_token",{
	description = "Dungeon Token",
	inventory_image = "quests_dungeon_token.png",
	stack_max = 999,
	on_use = function(itemstack, user, pointed_thing)
		local message = ""
		if pointed_thing.type == "node" then
			local n = minetest.get_node(pointed_thing.under)
			message = user:get_player_name() .. " taps their Dungeon Token loudly on a " .. minetest.registered_nodes[n.name]['description'] .. " to draw your attention to their many dungeon conquests!"
		end
		
		if pointed_thing.type == "object" then
			if pointed_thing.ref:is_player() then
				local n2 = pointed_thing.ref:get_player_name()
				message = user:get_player_name() .. " hits " .. n2 .. " with their Dungeon Token to draw your attention to their many dungeon conquests!"
			else
				message = user:get_player_name() .. " waves their Dungeon Token around in the air to draw your attention to their many dungeon conquests!"
			end
		end
		
		if pointed_thing.type == "nothing" then
			message = user:get_player_name() .. " waves their Dungeon Token around in the air to draw your attention to their many dungeon conquests!"
		end
		
		if message ~= "" then
			chat.local_chat(user:getpos(),message,25)
		end
	end,
})