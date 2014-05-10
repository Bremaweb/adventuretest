---
--money 2.00
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

money.initial_amount = 2000
money.currency_name = "cr"


money.convert_items = {
						gold = { item = "default:gold_ingot", dig_block="default:stone_with_gold", desc='Gold', amount=75, minval=25 },
						silver = { item = "moreores:silver_ingot", dig_block="moreores:mineral_silver", desc='Silver', amount = 27, minval=7}
					}

money.stats = money.load_stats()
if ( money.stats == false ) then
	money.stats = { }

	for key,val in pairs(money.convert_items) do
		minetest.log("action","Initial Convert Stats Setup for "..money.convert_items[key].desc)
		money.stats[key] = { running_time = 0, running_dug = 0, running_converted = 0, running_value = money.convert_items[key].amount }
	end
end