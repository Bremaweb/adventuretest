---
--vendor
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
 
vendor.traversable_node_types = {
	"default:chest", 
	"default:chest_locked",
	"vendor:vendor", 
	"vendor:depositor",
	"technic:copper_chest",
	"technic:copper_locked_chest",
	"technic:gold_chest",
	"technic:gold_locked_chest",
	"technic:iron_chest",
	"technic:iron_locked_chest",
	"technic:mithril_chest",
	"technic:mithril_locked_chest",
	"technic:silver_chest",
	"technic:silver_locked_chest"
}

vendor.formspec = function(pos, player)
	local meta = minetest.env:get_meta(pos)
	local meta = minetest.env:get_meta(pos)
	local node = minetest.env:get_node(pos)	
	local description = minetest.registered_nodes[node.name].description;
	local buysell =  "sell"
	if ( node.name == "vendor:depositor" ) then	
		buysell = "buy"
	end

	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
	local limit = meta:get_int("limit")
	local shop = meta:get_string("shop") or "Shop Name"
	local formspec = "size[9,7;]"
		.."label[0,0;Configure " .. description .. "]"
		.."field[4,0;4,1;shop;;"..shop.."]"
		.."field[2,1.5;2,1;number;Count:;" .. number .. "]"
		.."label[4,1.25;How many to bundle together]"
		.."field[2,3.0;2,1;cost;Price:;" .. cost .. "]"
		.."label[4,2.75;Price of a bundle]"
		.."field[2,4.5;2,1;limit;Sale Limit:;" .. limit .. "]"
		.."label[4,4.15;Number of bundles to "..buysell.."]"
		.."label[4,4.45;   (0 for no limit)]"
		.."button[1.5,6;3,0.5;save;Save]"
		.."button_exit[4.5.5,6;3,0.5;close;Save & Close]"
	return formspec
end

vendor.after_place_node = function(pos, placer)
	local meta = minetest.env:get_meta(pos)
	meta:set_string("itemtype", "")
	meta:set_int("number", 0)
	meta:set_int("cost", 0)
	meta:set_int("limit", 0)
	meta:set_string("owner", placer:get_player_name() or "")
	meta:set_string("shop","")
	meta:set_string("formspec", vendor.formspec(pos, placer))
	local description = minetest.registered_nodes[minetest.env:get_node(pos).name].description;
	vendor.disable(pos, "New " .. description)
end

vendor.can_dig = function(pos,player)
	local meta = minetest.env:get_meta(pos);
	local owner = meta:get_string("owner")
	local name = player:get_player_name()
	if name == owner then
		return true
	end
	return minetest.get_player_privs(name)["server"]
end

vendor.on_receive_fields = function(pos, formname, fields, sender)

	if ( fields.quit == nil ) then
		return
	end

	local node = minetest.env:get_node(pos)
	local description = minetest.registered_nodes[node.name].description;
	local meta = minetest.env:get_meta(pos)
	local owner = meta:get_string("owner")
	if sender:get_player_name() ~= owner then
		minetest.chat_send_player(sender:get_player_name(), "vendor:  Cannot configure machine.  The " .. description .. " belongs to " .. owner ..".")
		return
	end

	local number = tonumber(fields.number)
	local cost = tonumber(fields.cost)
	local limit = tonumber(fields.limit)
	local shop = fields.shop
	
	if ( shop == "Shop Name" ) then
		shop = ""
	end
	
	if ( number == nil or number < 1 or number > 99) then
		minetest.chat_send_player(owner, "vendor: Invalid count.  You must enter a count between 1 and 99.")
		vendor.disable(pos, "Misconfigured")
		return
	end
	if ( cost == nil or cost < 0 ) then
		minetest.chat_send_player(owner, "vendor: Invalid price.  You must enter a positive number for the price.")
		vendor.disable(pos, "Misconfigured")
		return
	end
	if ( limit == nil or limit < 0 ) then
		minetest.chat_send_player(owner, "vendor: Invalid sales limit.  You must enter a positive number (or zero) for the limit.")
		vendor.disable(pos, "Misconfigured")
		return
	end

	local inv = vendor.find_connected_chest_inv(owner, pos, nil, nil, nil)

	if ( inv == nil ) then
		minetest.chat_send_player(owner, "vendor: Inventory is misconfigured.  It must be connected in a line to a locked chest that has items to sell")
		vendor.disable(pos, "No Inventory/Improper Attachments")
		return
	end

	local itemname = nil
	for i=1,32 do
		local stack = inv:get_stack("main", i)
		if stack ~= nil and not stack:is_empty() then
			itemname = stack:get_name()
			break
		end
	end

	meta:set_string("itemtype", itemname)
	meta:set_int("number", number)
	meta:set_int("cost", cost)
	meta:set_int("limit", limit)
	meta:set_int("enabled", 1)
	meta:set_string("shop",shop)
	meta:set_string("formspec", vendor.formspec(pos, sender))

	local buysell = "selling"
	if ( node.name == "vendor:depositor" ) then	
		buysell = "buying"
	end
	minetest.chat_send_player(owner, "vendor: " .. description .. " is now " .. buysell .. " " .. number .. " " .. vendor.get_item_desc(itemname) .. " for " .. cost .. money.currency_name)
	vendor.sound_activate(pos)
	vendor.refresh(pos)
end


vendor.disable = function(pos, desc) 
	vendor.sound_deactivate(pos)
	local meta = minetest.env:get_meta(pos)
	local owner = meta:get_string("owner")
	local description = minetest.registered_nodes[minetest.env:get_node(pos).name].description;
	if ( desc == nil ) then
		desc = "Disabled " .. description
	end
	meta:set_string("infotext", ""..desc..", Owned By: " .. owner .. "")
	meta:set_int("enabled", 0)
end

vendor.refresh = function(pos, err) 
	local meta = minetest.env:get_meta(pos)
	local node = minetest.env:get_node_or_nil(pos)
	if ( node == nil ) then
		return 
	end

	if ( meta:get_int("enabled") ~= 1 ) then
		return
	end

	local itemtype = meta:get_string("itemtype")
	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
	local owner = meta:get_string("owner")
	local limit = meta:get_int("limit")
	local infotext = nil
	local limit_text = ""

	if ( limit > 0 ) then
		limit_text = " (".. limit .. " left)"
	end

	if ( err == nil ) then
		err = ""
	else 
		err = err .. ": "
	end

	local per_text = ""
	if ( number > 1 ) then 
		local per = math.floor((cost * 100)/number + 0.5) / 100
		per_text = " ("..per..money.currency_name.." each)"
	end

	if ( node.name == "vendor:vendor" ) then	
		infotext = err .. owner .. " Sells " .. number .. " " .. vendor.get_item_desc(itemtype) .. " for " .. cost .. money.currency_name .. limit_text .. per_text
	else 
		infotext = err .. owner .. " Buys " .. number .. " " .. vendor.get_item_desc(itemtype) .. " for " .. cost .. money.currency_name .. limit_text .. per_text
	end

	if ( meta:get_string("infotext") ~= infotext ) then
		meta:set_string("infotext", infotext)
	end
	
	-- Update the formspec
	meta:set_string("formspec", vendor.formspec(pos, sender))
	
end

vendor.sound_activate = function(pos) 
	minetest.sound_play("vendor_activate", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

vendor.sound_deactivate = function(pos)
	minetest.sound_play("vendor_disable", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

vendor.sound_error = function (pos)
	minetest.sound_play("vendor_error", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

vendor.sound_deposit = function(pos)
	minetest.sound_play("vendor_deposit", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

vendor.sound_vend = function(pos) 
	minetest.sound_play("vendor_vend", {pos = pos, gain = 1.0, max_hear_distance = 10,})
end

vendor.on_punch = function(pos, node, player)
	local meta = minetest.env:get_meta(pos)
	local node = minetest.env:get_node_or_nil(pos)
	if ( node == nil ) then
		return 
	end

	local vending = false
	if ( node.name == "vendor:vendor" ) then	
		vending = true
	elseif ( node.name == "vendor:depositor" ) then
		vending = false
	else
		return
	end

	local player_name = player:get_player_name()

	local tax = 0
	local itemtype = meta:get_string("itemtype")
	local number = meta:get_int("number")
	local cost = meta:get_int("cost")
	local owner = meta:get_string("owner")
	local limit = meta:get_int("limit")
	local enabled = meta:get_int("enabled")
	local shop = meta:get_string("shop")

	if ( shop == "" ) then
		shop = minetest.pos_to_string(pos)
	end

	if minetest.get_modpath("landrush") then
		local land_owner = landrush.get_owner(pos)
		if ( land_owner ~= nil and land_owner ~= owner and owner ~= player_name and cost > 10 ) then
			tax = math.floor( cost * vendor.tax )
			if ( tax < 1 ) then
				tax = 1
			end
			cost = cost - tax
		end
	end
	if not money.has_credit(player_name) then
		minetest.chat_send_player(player_name, "vendor: You don't have credit ('money' privilege).")
		vendor.sound_error(pos)
		return 
	end 
	
	if not money.has_credit(owner) then
		vendor.refresh(pos, "Account Suspended")
		vendor.sound_error(pos)
		return 
	end 

	if ( enabled ~= 1 ) then
		vendor.sound_error(pos)
		return
	end

	local chest_inv = vendor.find_connected_chest_inv(owner, pos, itemtype, number, vending)
	if ( chest_inv == nil ) then
		if ( vending ) then
			vendor.refresh(pos, "Out of Inventory");
			if ( chatplus ) then					
				table.insert(chatplus.players[owner].messages,"mail from <Vendor>: Vending Machine at "..shop.." selling "..itemtype.." is out of stock!")					
			end
		else
			vendor.refresh(pos, "Storage is Full");
		end
		vendor.sound_error(pos)
		return
	end

	local to_inv = nil
	local from_inv = nil
	local to_account = nil
	local from_account = nil
	
	local player_inv = player:get_inventory()

	if ( vending ) then
		to_inv = player_inv
		from_inv = chest_inv
		to_account = owner
		from_account = player_name
	else
		to_inv = chest_inv
		from_inv = player_inv
		to_account = player_name
		from_account = owner
	end
	
	if not from_inv:contains_item("main", itemtype .. " " .. number ) then
		minetest.chat_send_player(player_name, "vendor: Not enough (or no) items found to sell")
		return
	end
	if not to_inv:room_for_item("main", itemtype .. " " .. number ) then
		minetest.chat_send_player(player_name, "vendor: Not enough room to purchase items")
		vendor.sound_error(pos)
		return 
	end
	local err = money.transfer(from_account, to_account, cost)
	if ( err ~= nil ) then
		minetest.chat_send_player(player_name, "vendor: Credit transfer failed: " .. err)
		if ( not vending ) then
			vendor.refresh(pos, "Out of Credit");
			vendor.sound_error(pos)
		end
		vendor.sound_error(pos)
		return
	end

	-- do the tax transfer
	if minetest.get_modpath("landrush") then
		if ( tax > 0 ) then
			vendor_log_queue(land_owner,{date=os.date("%m/%d/%Y %H:%M"),pos=shop,from=from_account,action="Tax",qty=tostring(number),desc="Tax on "..itemtype,amount=tax})
			money.transfer(from_account,land_owner,tax)
		end
	end
	from_inv:remove_item("main", itemtype .. " " .. number)
	to_inv:add_item("main", itemtype .. " " .. number)

	if ( vending ) then
		minetest.chat_send_player(player_name, "vendor: You bought " .. number .." " .. vendor.get_item_desc(itemtype) .. " from " .. owner .. " for " .. (cost+tax) .. money.currency_name)
		vendor.sound_vend(pos)
		vendor_log_queue(to_account,{date=os.date("%m/%d/%Y %H:%M"),pos=shop,from=from_account,action="Sale",qty=tostring(number),desc=itemtype,amount=cost})
	else
		minetest.chat_send_player(player_name, "vendor: You sold " .. number .. " " .. vendor.get_item_desc(itemtype) .. " to " .. owner .. " for " .. cost .. money.currency_name)
		vendor.sound_deposit(pos)
		vendor_log_queue(from_account,{date=os.date("%m/%d/%Y %H:%M"),pos=shop,from=to_account,action="Purch",qty=tostring(number),desc=itemtype,amount=(cost*-1)})
	end


	if ( limit > 0 ) then
		limit = limit - 1
		meta:set_int("limit", limit)
		if ( limit == 0 ) then
			vendor.disable(pos, "Sold Out")
		else
			vendor.refresh(pos)
		end
	end	
end


vendor.get_item_desc = function(nodetype) 
	local itemdef = minetest.registered_items[nodetype]
	if ( itemdef ~= nil ) then
		return itemdef["description"] or "Unknown"
	else
		return "Unknown"
	end
end


vendor.is_traversable = function(pos) 
	local node = minetest.env:get_node_or_nil(pos)
	if ( node == nil ) then
		return false
	end
	for i=1,#vendor.traversable_node_types do
		if node.name == vendor.traversable_node_types[i] then
			return true
		end
	end
	return false
end

vendor.neighboring_nodes = function(pos) 
	local check = {{x=pos.x+1, y=pos.y, z=pos.z},
		{x=pos.x-1, y=pos.y, z=pos.z},
		{x=pos.x, y=pos.y+1, z=pos.z},
		{x=pos.x, y=pos.y-1, z=pos.z},
		{x=pos.x, y=pos.y, z=pos.z+1},
		{x=pos.x, y=pos.y, z=pos.z-1}}
	local trav = {}
	for i=1,#check do
		if vendor.is_traversable(check[i]) then
			trav[#trav+1] = check[i]
		end
	end
	return trav		
end
vendor.find_connected_chest_inv = function(owner, pos, nodename, amount, removing) 
	local nodes = vendor.neighboring_nodes(pos)

	if ( #nodes < 1 or  #nodes > 2 ) then
		return nil
	end

	-- Find the stack direction
	local first = nil
	local second = nil
	for i=1,#nodes do
		if ( first == nil ) then
			first = nodes[i]
		else
			second = nodes[i]
		end
	end

	if ( first ~= nil and second ~= nil ) then
		local dx = (first.x - second.x)/2
		local dy = (first.y - second.y)/2
		local dz = (first.z - second.z)/2
		-- make sure they are in a column/row
		if ( (dx * dx + dy * dy + dz * dz) ~= 1 ) then
			return nil
		end
		local chest_pos = vendor.find_chest_inv(owner, pos, dx, dy, dz, nodename, amount, removing)
		if ( chest_pos == nil ) then
			chest_pos = vendor.find_chest_inv(owner, pos, -dx, -dy, -dz, nodename, amount, removing)
		end
		return chest_pos
	else 
		local dx = first.x - pos.x
		local dy = first.y - pos.y
		local dz = first.z - pos.z
		return vendor.find_chest_inv(owner, pos, dx, dy, dz, nodename, amount, removing)
	end
end

vendor.find_chest_inv = function(owner, pos, dx, dy, dz, nodename, amount, removing)
	pos = {x=pos.x + dx, y=pos.y + dy, z=pos.z + dz}

	local node = minetest.env:get_node_or_nil(pos)
	if ( node == nil ) then
		return nil
	end
	--node.name == "default:chest" or
	if ( node.name == "default:chest_locked" 
	  or node.name == "default:chest"
	  or node.name == "technic:copper_chest"
	  or node.name == "technic:copper_locked_chest"
	  or node.name == "technic:gold_chest"
	  or node.name == "technic:gold_locked_chest"
	  or node.name == "technic:iron_chest"
	  or node.name == "technic:iron_locked_chest"
	  or node.name == "technic:mithril_chest"
	  or node.name == "technic:mithril_locked_chest"
	  or node.name == "technic:silver_chest"
	  or node.name == "technic:silver_locked_chest"
	  ) then
		local meta = minetest.env:get_meta(pos)
		if ( string.find(node.name,"_locked") ~= nil and owner ~= meta:get_string("owner") ) then
			return nil
		end
		local inv = meta:get_inventory()
		if ( inv ~= nil ) then
			if ( nodename ~= nil and amount ~= nil and removing ~= nil) then
				if ( removing and inv:contains_item("main", nodename .. " " .. amount) ) then
					return inv
				elseif ( (not removing) and inv:room_for_item("main", nodename .. " " .. amount) ) then
					return inv
				end
			elseif ( not inv:is_empty("main") ) then
				return inv
			end
		end
	elseif ( node.name ~= "vendor:vendor" and node.name~="vendor:depositor") then
		return nil
	end

	return vendor.find_chest_inv(owner, pos, dx, dy, dz, nodename, amount, removing)
end
		

