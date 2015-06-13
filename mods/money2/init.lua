---
--money 2.00
--Copyright (C) 2012 Bad_Command
--Copyright (C) 2012 kotolegokot
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

money = {}
money.version = 2.00

stat_file = minetest.get_worldpath() .. "/convert_stats"

dofile(minetest.get_modpath("money2") .. "/lockedsign.lua")

money.set = function(name, value)
	local output = io.open(minetest.get_worldpath() .. "/money_" .. name .. ".txt", "w")
	output:write(value)
	io.close(output)
end

money.get = function(name)
	local input = io.open(minetest.get_worldpath() .. "/money_" .. name .. ".txt", "r")
	if not input then 
		return nil
	end
	local credit = input:read("*n")
	io.close(input)
	return credit
end

money.has_credit = function(name)
	local privs = minetest.get_player_privs(name)
	if ( privs == nil or not privs["money"] ) then
		return false
	end
	return true
end

money.add = function(name, amount)
	if ( amount < 0 ) then
		return "must specify positive amount"
	end

	local credit = money.get(name)
	if ( credit == nil ) then
		return name .. " does not have a credit account."
	end

	money.set(name, credit + amount)
	return nil 
end

money.dec = function(name, amount) 
	if ( amount < 0 ) then
		return "must specify positive amount"
	end
	
	local credit = money.get(name)
	if ( credit == nil ) then
		return name .. " does not have a credit account."
	end
	if ( credit < amount ) then
		return name .. " does not have enough credit."
	end
	money.set(name, credit - amount)
	return nil
end

money.transfer = function(from, to, amount)
	if ( from == to ) then
		return
	end
	
	amount = math.ceil(amount)
	
	if ( not money.has_credit(from) ) then
		return from .. " does not have a credit account"
	end
	if ( not money.has_credit(to) ) then
		return to .. " does not have a credit account"
	end

	if ( amount < 0 ) then
		return "negative transfers not allowed"
	end
	local from_credit = money.get(from)
	if ( from_credit == nil or from_credit < amount ) then
		return "not enough credit"
	end
	local to_credit = money.get(to)
	if ( to_credit == nil ) then
		return to .. " does not have a credit account."
	end
	money.set(from, from_credit - amount)
	money.set(to, to_credit + amount)
	minetest.log('action',"Credit transfer of "..tostring(amount).." from "..from.." to "..to)
	return nil
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if not money.get(name) then
		money.set(name, tostring(money.initial_amount))
	end
end)

minetest.register_privilege("money", "Can use /money [pay <player> <amount>] command")
minetest.register_privilege("money_admin", {
	description = "Can use /money [<player> | pay/set/add/dec <player> <amount>] command",
	give_to_singleplayer = false,
})

minetest.register_chatcommand("money", {
	privs = {money=true},
	params = "[<player> | pay/set/add/dec <player> <amount>]",
	description = "Operations with credit",
	func = function(name,  param)
		if param == "" then
			minetest.chat_send_player(name, money.get(name) .. money.currency_name)
		else
			local param1, reciever, amount = string.match(param, "([^ ]+) ([^ ]+) (.+)")
			if not reciever and not amount then
				if minetest.get_player_privs(name)["money_admin"] then
					if not money.get(param) then
						minetest.chat_send_player(name, "money: Player named \"" .. param .. "\" does not exist or does not have an account.")
						return true
					end
					minetest.chat_send_player(name, money.get(param) .. money.currency_name)
					return true
				else
					minetest.chat_send_player(name, "money: You don't have permission to run this command (missing privileges: money_admin)")
				end
			end
			if (param1 ~= "pay") and (param1 ~= "set") and (param1 ~= "add") and (param1 ~= "dec") or not reciever or not amount then
				minetest.chat_send_player(name, "money: Invalid parameters (see /help money)")
				return true
			elseif not money.get(reciever) then
				minetest.chat_send_player(name, "money: Player named \"" .. reciever .. "\" does not exist or does not have account.")
				return true
			elseif not tonumber(amount) then
				minetest.chat_send_player(name, "money: amount .. " .. "is not a number.")
				return true
			elseif tonumber(amount) < 0 then
				minetest.chat_send_player(name, "money: The amount must be greater than 0.")
				return true
			end
			amount = tonumber(amount)
			if param1 == "pay" then
				local err = money.transfer(name ,reciever, amount)
				if ( err ~= nil ) then 
					minetest.chat_send_player(name, "money: Error: "..err..".")						
				else
					minetest.chat_send_player(name, "money: You paid " .. reciever .. " " .. amount .. money.currency_name)
					minetest.chat_send_player(reciever, "money: " .. name .. " paid you " .. amount .. money.currency_name)
				end
			elseif minetest.get_player_privs(name)["money_admin"] then
				if param1 == "add" then
					local err = money.add(reciever, amount)
					if ( err ~= nil ) then 
						minetest.chat_send_player(name, "money: Error"..err..".")		
					end
				elseif param1 == "dec" then
					local err = money.dec(reciever, amount)
					if ( err ~= nil ) then 
						minetest.chat_send_player(name, "money: Error"..err..".")
					end
				elseif param1 == "set" then
					local err = money.set(reciever, amount)
					if ( err ~= nil ) then 
						minetest.chat_send_player(name, "money: Error"..err..".")
					end					
				end
			else
				minetest.chat_send_player(name, "money: You don't have permission to run this command (missing privileges: money_admin)")
			end
		end
	end,
})


minetest.register_chatcommand("convertval",{
	privs = {money=true},
	params = "none",
	description = "Shows the current value of convertable items",
	func = function(name, param)
		for k,v in pairs(money.stats) do
			minetest.chat_send_player(name,money.convert_items[k].desc..": "..tostring(money.stats[k].running_value))
		end
	end
})

function money.calcConvertValues()
	for k,v in pairs(money.stats) do
		money.stats[k].running_time = money.stats[k].running_time + 1
		money.stats[k].running_value = math.floor(money.convert_items[k].amount + ( (money.stats[k].running_time / 960) + (money.stats[k].running_dug / 22) - ( money.stats[k].running_converted / 11 ) ))
		
		if ( money.stats[k].running_value < money.convert_items[k].minval ) then
			money.stats[k].running_val = money.convert_items[k].minval
		end
		
		minetest.log("action","Calculated "..money.convert_items[k].desc.." value at "..tostring(money.stats[k].running_value)) 
	end
	money.save_stats()
minetest.after(60,money.calcConvertValues)
end

function money.save_stats()
minetest.log("action","Saving convert stats")
	local f = io.open(stat_file, "w")
    	f:write(minetest.serialize(money.stats))
    	f:close()
end	

function money.load_stats()
minetest.log("action","Loading convert stats")
local f = io.open(stat_file, "r")
	if f==nil then 
		minetest.log("action","file not found")
		return false
	end
    	local t = f:read("*all")
    	f:close()
	if t=="" or t==nil then 
		minetest.log("action","File blank")
		return false
	end
	return minetest.deserialize(t)	
end

minetest.after(60, money.calcConvertValues)

dofile(minetest.get_modpath("money2") .. "/config.lua")

local convert_options = "<"
for k,v in pairs(money.convert_items) do
	convert_options = convert_options..k..","
end
convert_options = convert_options..">"

minetest.register_chatcommand("convert",{
	privs = {money=true},
	params = convert_options,
	description="Converts certain ores to credits",
	func = function(name, param)
		-- check the parameters
		if ( money.convert_items[param] ~= nil ) then			
			local item = money.convert_items[param].item
			local amount = money.stats[param].running_value
			local totalAmount = 0
			local totalItems = 0
			-- look through their inventory for the item they chose
			local player = minetest.get_player_by_name(name)
			local inventory = player:get_inventory()
						
			for i=1,inventory:get_size("main") do
				--player_inv:set_stack("main", i, nil)
				local inv_item = inventory:get_stack("main",i)				
				if ( inv_item:get_name() == item ) then
					local add_amount = inv_item:get_count() * amount
					money.add(name,add_amount)
					totalAmount = totalAmount + add_amount
					totalItems = totalItems + inv_item:get_count()
					inventory:set_stack("main",i,nil)
				end								
			end
			money.stats[param].running_converted = money.stats[param].running_converted + totalItems
			minetest.chat_send_player(name,"You converted "..tostring(totalItems).." "..param.." into "..tostring(totalAmount)..money.currency_name)
		end
	end
})
