---
--vendor 1.01
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

vendor = {}
vendor.version = 1.1
vendor.tax = 0.01

dofile(minetest.get_modpath("vendor") .. "/vendor.lua")
--dofile(minetest.get_modpath("vendor") .. "/mese_vendor.lua")

-- comment out this line to disable logging
dofile(minetest.get_modpath("vendor").."/log.lua")

minetest.register_node("vendor:vendor", {
	description = "Vending Machine",
	tiles ={"vendor_side.png", "vendor_side.png", "vendor_side.png",
		"vendor_side.png", "vendor_side.png", "vendor_vendor_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},

	after_place_node = vendor.after_place_node,
	can_dig = vendor.can_dig,
	on_receive_fields = vendor.on_receive_fields,
	on_punch = vendor.on_punch,
})

minetest.register_node("vendor:depositor", {
	description = "Depositing Machine",
	tiles ={"vendor_side.png", "vendor_side.png", "vendor_side.png",
		"vendor_side.png", "vendor_side.png", "vendor_depositor_front.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},

	after_place_node = vendor.after_place_node,
	can_dig = vendor.can_dig,
	on_receive_fields = vendor.on_receive_fields,
	on_punch = vendor.on_punch,
})

minetest.register_craft({
	output = 'vendor:vendor',
	recipe = {
                {'default:wood', 'default:wood', 'default:wood'},
                {'default:wood', 'default:steel_ingot', 'default:wood'},
                {'default:wood', 'default:steel_ingot', 'default:wood'},
        }
})

minetest.register_craft({
	output = 'vendor:depositor',
	recipe = {
                {'default:wood', 'default:steel_ingot', 'default:wood'},
                {'default:wood', 'default:steel_ingot', 'default:wood'},
                {'default:wood', 'default:wood', 'default:wood'},
        }
})


