chat = {}

--[[
minetest.register_on_chat_message(function(name,msg)

end) 
]]

chat.local_chat = function(pos,text,radius)
	if radius == nil then
		radius = 25
	end
	if pos ~= nil then
		local oir = minetest.get_objects_inside_radius(pos, radius)
		for _,p in pairs(oir) do
			if p:is_player() then
				minetest.chat_send_player(p:get_player_name(),text)
			end
		end
	end
end