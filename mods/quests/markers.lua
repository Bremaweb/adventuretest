minetest.register_node( "quests:marker", {
	description = "Quest Marker",
	tiles = { "quests_marker.png" },
	is_ground_content = false,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 8,
	diggable=false,
	on_punch = function(pos, node, puncher, pointed_thing)
		local m = minetest.get_meta(pos)
		local message = m:get_string("message")
		local drop = m:get_string("drop")
		if message ~= nil then
			minetest.chat_send_player(puncher:get_player_name(),message)
		end
		if drop ~= nil then
			default.drop_item(puncher:getpos(),drop)
		end
		minetest.sound_play("quests_marker_punch",{pos=pos,gain=10,max_hear_distance=50})
	end,
})
