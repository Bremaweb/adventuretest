---
--money 2.00
--Copyright (C) 2012 kotolegokot
--Copyright (C) 2012 Bad_Command
--
--This library is free software; you can redistribute it and/or
--modify it under the terms of the GNU Lesser General Public
--License as published by the Free Software Foundation; either
--version 2.1 of the License, or (at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public
--License along with this library; if not, write to the Free Software
--Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
---

minetest.register_on_punchnode(function(pos, node, puncher)
	bottom_pos = {x=pos.x, y=pos.y - 1, z=pos.z}
	bottom_node = minetest.env:get_node(bottom_pos)
	if (node.name == "locked_sign:sign_wall_locked") and (bottom_node.name == "default:chest_locked") and
		minetest.env:get_meta(pos):get_string("owner") == minetest.env:get_meta(bottom_pos):get_string("owner") then
		local sign_text = minetest.env:get_meta(pos):get_string("text")
		local shop_name, shop_type, nodename, amount, cost = string.match(sign_text, "([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+) ([^ ]+)")
		local owner_name = minetest.env:get_meta(pos):get_string("owner")
		local puncher_name = puncher:get_player_name()
		if (shop_type ~= "B") and (shop_type ~= "S") or (not minetest.registered_items[nodename]) or (not tonumber(amount)) or
		(not tonumber(cost)) then
			return true
		end
	
		if ( not money.has_credit(owner_name) ) then	
			minetest.chat_send_player(puncher_name, "Owner does not have a credit account.")
		end
		if ( not money.has_credit(puncher_name) ) then	
			minetest.chat_send_player(puncher_name, "You do not have a credit account.")
		end


		local chest_inv = minetest.env:get_meta({x=pos.x, y=pos.y - 1, z = pos.z}):get_inventory()
		local puncher_inv = puncher:get_inventory()
		--BUY
		if shop_type == "B" then
			if not chest_inv:contains_item("main", nodename .. " " .. amount) then
				minetest.chat_send_player(puncher_name, "In the chest is not enough goods.")
				return true
			elseif not puncher_inv:room_for_item("main", nodename .. " " .. amount) then
				minetest.chat_send_player(puncher_name, "In your inventory is not enough space.")
				return true
			elseif money.get(puncher_name) - cost < 0 then
				minetest.chat_send_player(puncher_name, "You do not have enough money.")
				return true
			end
			money.set(puncher_name, money.get(puncher_name) - cost)
			money.set(owner_name, money.get(owner_name) + cost)
			puncher_inv:add_item("main", nodename .. " " .. amount)
			chest_inv:remove_item("main", nodename .. " " .. amount)
			minetest.chat_send_player(puncher_name, "You bought " .. amount .. " " .. nodename .. " at a price of " .. cost .. money.currency_name .. ".")
		--SELL
		elseif shop_type == "S" then
			if not puncher_inv:contains_item("main", nodename .. " " .. amount) then
				minetest.chat_send_player(puncher_name, "You do not have enough product.")
				return true
			elseif not chest_inv:room_for_item("main", nodename .. " " .. amount) then
				minetest.chat_send_player(puncher_name, "In the chest is not enough space.")
				return true
			elseif money.get(owner_name) - cost < 0 then
				minetest.chat_send_player(puncher_name, "The buyer is not enough money.")
				return true
			end
			money.set(puncher:get_player_name(), money.get(puncher:get_player_name()) + cost)
			money.set(owner_name, money.get(owner_name) - cost)
			puncher_inv:remove_item("main", nodename .. " " .. amount)
			chest_inv:add_item("main", nodename .. " " .. amount)
			minetest.chat_send_player(puncher_name, "You sold " .. amount .. " " .. nodename .. " at a price of " .. cost .. money.currency_name .. ".")
		end
	end
end)
