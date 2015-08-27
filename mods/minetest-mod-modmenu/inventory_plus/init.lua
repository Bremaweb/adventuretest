--inventory_plus compatibility wrapper for use with modmenu

--This program is free software. It comes without any warranty, to
--the extent permitted by applicable law. You can redistribute it
--and/or modify it under the terms of the Do What The Fuck You Want
--To Public License, Version 2, as published by Sam Hocevar. See
--http://www.wtfpl.net/ for more details.

inventory_plus = {}

inventory_plus.set_inventory_formspec = function(player, formspec)
	minetest.show_formspec(player:get_player_name(), "custom", formspec)
end

inventory_plus.register_button = function(player, button_name, button_text)
	modmenu.add_button(player:get_player_name(), button_name, button_text)
end

--handle the "Back" button on inv. plus forms (such as skins/3d armor)
minetest.register_on_player_receive_fields(function(player,formname,fields)
	if fields.main then
		modmenu.show_menu(player:get_player_name())
	end
end)
