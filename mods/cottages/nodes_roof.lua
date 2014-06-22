-- Boilerplate to support localized strings if intllib mod is installed.
local S
if intllib then
	S = intllib.Getter()
else
	S = function(s) return s end
end

---------------------------------------------------------------------------------------
-- roof parts
---------------------------------------------------------------------------------------
-- a better roof than the normal stairs; can be replaced by stairs:stair_wood


-- create the three basic roof parts plus receipes for them;
cottages.register_roof = function( name, tiles, basic_material, homedecor_alternative )

   minetest.register_node("cottages:roof_"..name, {
		description = S("Roof "..name),
		drawtype = "nodebox",
		--tiles = {"default_tree.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_tree.png"},
		tiles = tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
	})

   -- a better roof than the normal stairs; this one is for usage directly on top of walls (it has the form of a stair)
   minetest.register_node("cottages:roof_connector_"..name, {
		description = S("Roof connector "..name),
		drawtype = "nodebox",
                -- top, bottom, side1, side2, inner, outer
		--tiles = {"default_tree.png","default_wood.png","default_tree.png","default_tree.png","default_wood.png","default_tree.png"},
		--tiles = {"darkage_straw.png","default_wood.png","darkage_straw.png","darkage_straw.png","darkage_straw.png","darkage_straw.png"},
		tiles = tiles,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
	})

   -- this one is the slab version of the above roof
   minetest.register_node("cottages:roof_flat_"..name, {
		description = S("Roof (flat) "..name),
		drawtype = "nodebox",
                -- top, bottom, side1, side2, inner, outer
		--tiles = {"default_tree.png","default_wood.png","default_tree.png","default_tree.png","default_wood.png","default_tree.png"},
                -- this one is from all sides - except from the underside - of the given material
		tiles = { tiles[1], tiles[2], tiles[1], tiles[1], tiles[1], tiles[1] };
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
		node_box = {
			type = "fixed",
			fixed = {	
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			},
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
			},
		},
	})


   if( not( homedecor_alternative )
       or ( minetest.get_modpath("homedecor") ~= nil )) then

      minetest.register_craft({
	output = "cottages:roof_"..name.." 6",
	recipe = {
		{'', '', basic_material },
		{'', basic_material, '' },
		{basic_material, '', '' }
	}
      })
   end

   -- make those roof parts that use homedecor craftable without that mod
   if( homedecor_alternative ) then
      basic_material = 'cottages:roof_wood';

      minetest.register_craft({
	output = "cottages:roof_"..name.." 3",
	recipe = {
		{homedecor_alternative, '', basic_material },
		{'', basic_material, '' },
		{basic_material, '', '' }
	}
      })
   end


   minetest.register_craft({
	output = "cottages:roof_connector_"..name,
	recipe = {
		{'cottages:roof_'..name },
		{'default:wood' },
	}
   })

   minetest.register_craft({
	output = "cottages:roof_flat_"..name..' 2',
	recipe = {
		{'cottages:roof_'..name, 'cottages:roof_'..name },
	}
   })

   -- convert flat roofs back to normal roofs
   minetest.register_craft({
	output = "cottages:roof_"..name,
	recipe = {
	        {"cottages:roof_flat_"..name, "cottages:roof_flat_"..name }
	}
   })

end -- of cottages.register_roof( name, tiles, basic_material )




---------------------------------------------------------------------------------------
-- add the diffrent roof types
---------------------------------------------------------------------------------------
cottages.register_roof( 'straw',
		{"cottages_darkage_straw.png","cottages_darkage_straw.png","cottages_darkage_straw.png","cottages_darkage_straw.png","cottages_darkage_straw.png","cottages_darkage_straw.png"},
		'cottages:straw_mat', nil );
cottages.register_roof( 'reet',
		{"cottages_reet.png","cottages_reet.png","cottages_reet.png","cottages_reet.png","cottages_reet.png","cottages_reet.png"},
		'default:papyrus', nil );
cottages.register_roof( 'wood',
		{"default_tree.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_tree.png"},
		'default:wood', nil);
cottages.register_roof( 'black',
		{"cottages_homedecor_shingles_asphalt.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","cottages_homedecor_shingles_asphalt.png"},
		'homedecor:shingles_asphalt', 'default:coal_lump');
cottages.register_roof( 'red',
		{"cottages_homedecor_shingles_terracotta.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","cottages_homedecor_shingles_terracotta.png"},
		'homedecor:shingles_terracotta', 'default:clay_brick');
cottages.register_roof( 'brown',
		{"cottages_homedecor_shingles_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","cottages_homedecor_shingles_wood.png"},
		'homedecor:shingles_wood', 'default:dirt');
cottages.register_roof( 'slate',
		{"cottages_slate.png","default_wood.png","cottages_slate.png","cottages_slate.png","default_wood.png","cottages_slate.png"},
		'default:stone', nil);


---------------------------------------------------------------------------------------
-- slate roofs are sometimes on vertical fronts of houses
---------------------------------------------------------------------------------------
minetest.register_node("cottages:slate_vertical", {
        description = S("Vertical Slate"),
        tiles = {"cottages_slate.png","default_wood.png","cottages_slate.png","cottages_slate.png","default_wood.png","cottages_slate.png"},
        paramtype2 = "facedir",
        groups = {cracky=2, stone=1},
        sounds = default.node_sound_stone_defaults(),
})


minetest.register_craft({
	output  = "cottages:slate_vertical",
	recipe = { {'default:stone', 'default:wood',  '' }
	}
});

---------------------------------------------------------------------------------------
-- Reed might also be needed as a full block
---------------------------------------------------------------------------------------
minetest.register_node("cottages:reet", {
        description = S("Reet for thatching"),
        tiles = {"cottages_reet.png"},
	groups = {snappy=3,choppy=3,oddly_breakable_by_hand=3,flammable=3},
	sounds = default.node_sound_wood_defaults(),
})


minetest.register_craft({
	output  = "cottages:reet",
	recipe = { {'default:papyrus','default:papyrus'},
	           {'default:papyrus','default:papyrus'},
	},
})
