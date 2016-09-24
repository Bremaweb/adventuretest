---------------------------------------------------------------------------------------
-- furniture
---------------------------------------------------------------------------------------
-- contains:
--  * a bed seperated into foot and head reagion so that it can be placed manually; it has
--    no other functionality than decoration!
--  * a sleeping mat - mostly for NPC that cannot afford a bet yet
--  * bench - if you don't have 3dfurniture:chair, then this is the next best thing
--  * table - very simple one
--  * shelf - for storing things; this one is 3d
--  * stovepipe - so that the smoke from the furnace can get away
--  * washing place - put it over a water source and you can 'wash' yourself
---------------------------------------------------------------------------------------
-- TODO: change the textures of the bed (make the clothing white, foot path not entirely covered with cloth)

local S = cottages.S

-- a bed without functionality - just decoration
minetest.register_node("cottages:bed_foot", {
	description = S("Bed (foot region)"),
	drawtype = "nodebox",
	tiles = {"cottages_beds_bed_top_bottom.png", cottages.texture_furniture,  "cottages_beds_bed_side.png",  "cottages_beds_bed_side.png",  "cottages_beds_bed_side.png",  "cottages_beds_bed_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
					-- bed
					{-0.5, 0.0, -0.5, 0.5, 0.3, 0.5},
					
					-- stützen
					{-0.5, -0.5, -0.5, -0.4, 0.5, -0.4},
					{  0.4,-0.5, -0.5, 0.5,  0.5, -0.4},
                               
                                        -- Querstrebe
					{-0.4,  0.3, -0.5, 0.4, 0.5, -0.4}
				}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.3, 0.5},
				}
	},
	is_ground_content = false,
})

-- the bed is split up in two parts to avoid destruction of blocks on placement
minetest.register_node("cottages:bed_head", {
	description = S("Bed (head region)"),
	drawtype = "nodebox",
	tiles = {"cottages_beds_bed_top_top.png", cottages.texture_furniture,  "cottages_beds_bed_side_top_r.png",  "cottages_beds_bed_side_top_l.png",  cottages.texture_furniture,  "cottages_beds_bed_side.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
					-- bed
					{-0.5, 0.0, -0.5, 0.5, 0.3, 0.5},
					
					-- stützen
					{-0.5,-0.5, 0.4, -0.4, 0.5, 0.5},
					{ 0.4,-0.5, 0.4,  0.5, 0.5, 0.5},

                                        -- Querstrebe
					{-0.4,  0.3,  0.4, 0.4, 0.5,  0.5}
				}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.3, 0.5},
				}
	},
	is_ground_content = false,
})


-- the basic version of a bed - a sleeping mat
-- to facilitate upgrade path straw mat -> sleeping mat -> bed, this uses a nodebox
minetest.register_node("cottages:sleeping_mat", {
        description = S("sleeping mat"),
        drawtype = 'nodebox',
        tiles = { 'cottages_sleepingmat.png' }, -- done by VanessaE
        wield_image = 'cottages_sleepingmat.png',
        inventory_image = 'cottages_sleepingmat.png',
        sunlight_propagates = true,
        paramtype = 'light',
        paramtype2 = "facedir",
        walkable = false,
        groups = { snappy = 3 },
        sounds = default.node_sound_leaves_defaults(),
        selection_box = {
                        type = "wallmounted",
                        },
        node_box = {
                type = "fixed",
                fixed = {
                                        {-0.48, -0.5,-0.48,  0.48, -0.45, 0.48},
                        }
        },
        selection_box = {
                type = "fixed",
                fixed = {
                                        {-0.48, -0.5,-0.48,  0.48, -0.25, 0.48},
                        }
        },
	is_ground_content = false,
})



-- furniture; possible replacement: 3dforniture:chair
minetest.register_node("cottages:bench", {
	drawtype = "nodebox",
	description = S("simple wooden bench"),
	tiles = {"cottages_minimal_wood.png", "cottages_minimal_wood.png",  "cottages_minimal_wood.png",  "cottages_minimal_wood.png",  "cottages_minimal_wood.png",  "cottages_minimal_wood.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
					-- sitting area
					{-0.5, -0.15, 0.1,  0.5,  -0.05, 0.5},
					
					-- stützen
					{-0.4, -0.5,  0.2, -0.3, -0.15, 0.4},
					{ 0.3, -0.5,  0.2,  0.4, -0.15, 0.4},
				}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.5, -0.5, 0, 0.5, 0, 0.5},
				}
	},
	is_ground_content = false,
})


-- a simple table; possible replacement: 3dforniture:table
local cottages_table_def = {
		description = S("table"),
		drawtype = "nodebox",
                -- top, bottom, side1, side2, inner, outer
		tiles = {"cottages_minimal_wood.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.1, -0.5, -0.1,  0.1, 0.3,  0.1},
				{ -0.5,  0.3, -0.5,  0.5, 0.4,  0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5,  0.5, 0.4,  0.5},
			},
		},
		is_ground_content = false,
}


-- search for the workbench in AdventureTest
local workbench = minetest.registered_nodes[ "workbench:3x3"];
if( workbench ) then
	cottages_table_def.tiles        = {workbench.tiles[1], cottages_table_def.tiles[1]};
	cottages_table_def.on_rightclick = workbench.on_rightclick;
end
-- search for the workbench from RealTEst
workbench = minetest.registered_nodes[ "workbench:work_bench_birch"];
if( workbench ) then
	cottages_table_def.tiles	= {workbench.tiles[1], cottages_table_def.tiles[1]};
	cottages_table_def.on_construct = workbench.on_construct;
	cottages_table_def.can_dig      = workbench.can_dig;
	cottages_table_def.on_metadata_inventory_take = workbench.on_metadata_inventory_take;
	cottages_table_def.on_metadata_inventory_move = workbench.on_metadata_inventory_move;
	cottages_table_def.on_metadata_inventory_put  = workbench.on_metadata_inventory_put;
end

minetest.register_node("cottages:table", cottages_table_def );

local cottage_shelf_formspec =
		"size[8,8]"..
		"list[current_name;main;0,0;8,3;]"..
		"list[current_player;main;0,4;8,4;]"..
		"listring[]"

-- looks better than two slabs impersonating a shelf; also more 3d than a bookshelf 
-- the infotext shows if it's empty or not
minetest.register_node("cottages:shelf", {
		description = S("open storage shelf"),
		drawtype = "nodebox",
                -- top, bottom, side1, side2, inner, outer
		tiles = {"cottages_minimal_wood.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {

 				{ -0.5, -0.5, -0.3, -0.4,  0.5,  0.5},
 				{  0.4, -0.5, -0.3,  0.5,  0.5,  0.5},

				{ -0.5, -0.2, -0.3,  0.5, -0.1,  0.5},
				{ -0.5,  0.3, -0.3,  0.5,  0.4,  0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5,  0.5, 0.5,  0.5},
			},
		},

		on_construct = function(pos)

                	local meta = minetest.get_meta(pos);

	                meta:set_string("formspec", cottage_shelf_formspec)
                	meta:set_string("infotext", S("open storage shelf"))
                	local inv = meta:get_inventory();
                	inv:set_size("main", 24);
        	end,

	        can_dig = function( pos,player )
	                local  meta = minetest.get_meta( pos );
	                local  inv = meta:get_inventory();
	                return inv:is_empty("main");
	        end,

                on_metadata_inventory_put  = function(pos, listname, index, stack, player)
	                local  meta = minetest.get_meta( pos );
                        meta:set_string('infotext', S('open storage shelf (in use)'));
                end,
                on_metadata_inventory_take = function(pos, listname, index, stack, player)
	                local  meta = minetest.get_meta( pos );
	                local  inv = meta:get_inventory();
	                if( inv:is_empty("main")) then
                           meta:set_string('infotext', S('open storage shelf (empty)'));
                        end
                end,
		is_ground_content = false,


})

-- so that the smoke from a furnace can get out of a building
minetest.register_node("cottages:stovepipe", {
		description = S("stovepipe"),
		drawtype = "nodebox",
		tiles = {"cottages_steel_block.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {
				{  0.20, -0.5, 0.20,  0.45, 0.5,  0.45},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{  0.20, -0.5, 0.20,  0.45, 0.5,  0.45},
			},
		},
		is_ground_content = false,
})


-- this washing place can be put over a water source (it is open at the bottom)
minetest.register_node("cottages:washing", {
		description = S("washing place"),
		drawtype = "nodebox",
                -- top, bottom, side1, side2, inner, outer
		tiles = {"cottages_clay.png"},
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5,  0.5, -0.2, -0.2},

				{ -0.5, -0.5, -0.2, -0.4, 0.2,  0.5},
				{  0.4, -0.5, -0.2,  0.5, 0.2,  0.5},

				{ -0.4, -0.5,  0.4,  0.4, 0.2,  0.5},
				{ -0.4, -0.5, -0.2,  0.4, 0.2, -0.1},

			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{ -0.5, -0.5, -0.5,  0.5, 0.2,  0.5},
			},
		},
                on_rightclick = function(pos, node, player)
                   -- works only with water beneath
                   local node_under = minetest.get_node( {x=pos.x, y=(pos.y-1), z=pos.z} );
		   if( not( node_under ) or node_under.name == "ignore" or (node_under.name ~= 'default:water_source' and node_under.name ~= 'default:water_flowing')) then
                      minetest.chat_send_player( player:get_player_name(), S("Sorry. This washing place is out of water. Please place it above water!"));
		   else
                      minetest.chat_send_player( player:get_player_name(), S("You feel much cleaner after some washing."));
		   end
                end,
		is_ground_content = false,

})



---------------------------------------------------------------------------------------
-- crafting receipes
---------------------------------------------------------------------------------------
minetest.register_craft({
	output = "cottages:bed_foot",
	recipe = {
		{cottages.craftitem_wool,    "", "", },
		{cottages.craftitem_wood,  "", "", },
		{cottages.craftitem_stick, "", "", }
	}
})

minetest.register_craft({
	output = "cottages:bed_head",
	recipe = {
		{"", "",              cottages.craftitem_wool, },
		{"", cottages.craftitem_stick, cottages.craftitem_wood, },
		{"", "",              cottages.craftitem_stick, }
	}
})

minetest.register_craft({
	output = "cottages:sleeping_mat 3",
	recipe = {
		{"cottages:wool_tent", "cottages:straw_mat","cottages:straw_mat" }
	}
})


minetest.register_craft({
	output = "cottages:table",
	recipe = {
		{"", cottages.craftitem_slab_wood, "", },
		{"", cottages.craftitem_stick, "" }
	}
})

minetest.register_craft({
	output = "cottages:bench",
	recipe = {
		{"",              cottages.craftitem_wood, "", },
		{cottages.craftitem_stick, "",             cottages.craftitem_stick, }
	}
})


minetest.register_craft({
	output = "cottages:shelf",
	recipe = {
		{cottages.craftitem_stick,  cottages.craftitem_wood, cottages.craftitem_stick, },
		{cottages.craftitem_stick, cottages.craftitem_wood, cottages.craftitem_stick, },
		{cottages.craftitem_stick, "",             cottages.craftitem_stick}
	}
})

minetest.register_craft({
	output = "cottages:washing 2",
	recipe = {
		{cottages.craftitem_stick, },
		{cottages.craftitem_clay,  },
	}
})

minetest.register_craft({
	output = "cottages:stovepipe 2",
	recipe = {
		{cottages.craftitem_steel, '', cottages.craftitem_steel},
	}
})

--------------------------------------------------------------------------------
-- Update existing nodes to use SHIFT-CLICK
--------------------------------------------------------------------------------
minetest.register_lbm({
        name = "cottages:shelf_lbm",
        nodenames = {"cottages:shelf"},
        run_at_every_load = false,
        action = function(pos, node)
                local meta = minetest.get_meta(pos)
		meta:set_string("formspec", cottage_shelf_formspec)
        end,
})

