-- init.lua
-- workbench minetest mod, by darkrose
-- Copyright (C) Lisa Milne 2012 <lisa@ltmnet.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 2.1 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>


-- uncomment the next 6 lines to restrict players to a 2x2 inventory craft grid

minetest.register_on_joinplayer(function(player)
	player:get_inventory():set_width("craft", 2)
	player:get_inventory():set_size("craft", 4)
	
	player:set_inventory_formspec("size[8,7.5]"..
		"list[current_player;main;0,3.5;8,4;]"..
		"list[current_player;craft;3,0.5;2,2;]"..
		"list[current_player;craftpreview;6,1;1,1;]")
end)

minetest.register_node("workbench:3x3", {
	description = "WorkBench",
	tile_images = {"workbench_3x3_top.png","workbench_3x3_bottom.png","workbench_3x3_side.png"},
	paramtype2 = "facedir",
	groups = {snappy=3,crumbly=3,oddly_breakable_by_hand=3},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec",
			"size[8,9]"..
			"list[current_name;table;1,1;3,3;]"..
			"list[current_name;dst;5,1;2,2;]"..
			"list[current_player;main;0,5;8,4;]"..
			"button[5,3;2,1;craft;Craft]")
		meta:set_string("infotext", "WorkBench")
		local inv = meta:get_inventory()
		inv:set_size("table", 9)
		inv:set_size("dst", 4)
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		local meta = minetest:get_meta(pos)
		meta:from_table(oldmetadata)
		local inv = meta:get_inventory()
		default.dump_inv(pos,"table",inv)
		default.dump_inv(pos,"dst",inv)
	end,
	on_receive_fields = function (pos, formname, fields, sender)
		if fields.craft then
			local meta = minetest.env:get_meta(pos)
			local inv = meta:get_inventory()
			local tablelist = inv:get_list("table")
			local crafted = nil
			local left_over = nil
			local dst = inv:get_list("dst")

			if tablelist then
				crafted, left_over = minetest.get_craft_result({method = "normal", width = 3, items = tablelist})
			end

			if crafted then
				if crafted.item:get_definition().skill ~= nil then
					
					-- adjust the quality of the craft item
					--if crafted.item:get_wear() > 0 then
					
						local probability = skills.get_probability(sender:get_player_name(),SKILL_CRAFTING,crafted.item:get_definition().skill)
						local rangeLow = ( probability - 10 ) / 100
						probability = probability / 100
						local wear = math.floor(50000 - ( 50000 * math.random(rangeLow,probability) ))
						crafted.item:add_wear(wear)
					--end
				end
				if inv:room_for_item("dst", crafted) then
					-- clear the crafting table first
					if left_over then
						inv:set_list("table", left_over.items)
						tablelist = left_over.items
					else
						--inv:set_list("table",nil)
					end	
					inv:add_item("dst",crafted.item)
				end
			end
		end
	end,
})


minetest.register_craft({
	output = "workbench:3x3",
	recipe = {{"group:wood","group:wood",""},{"group:wood","group:wood",""},{"","",""}},
})

