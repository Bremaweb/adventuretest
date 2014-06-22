
---------------------------------------------------------------------
-- a barrel and a tub - plus a function that makes 'round' objects
---------------------------------------------------------------------
-- IMPORTANT NOTE: The barrel requires a lot of nodeboxes. That may be
--                 too much for weak hardware!
---------------------------------------------------------------------
-- Functionality: right-click to open/close a barrel;
--                punch a barrel to change between vertical/horizontal
---------------------------------------------------------------------
-- Changelog:
-- 24.03.13 Can no longer be opended/closed on rightclick because that is now used for a formspec;
--          instead, it can be filled with liquids.
--          Filled barrels will always be closed, while empty barrels will always be open.

-- pipes: table with the following entries for each pipe-part:
--    f: radius factor; if 1, it will have a radius of half a nodebox and fill the entire nodebox
--    h1, h2: height at witch the nodebox shall start and end; usually -0.5 and 0.5 for a full nodebox
--    b: make a horizontal part/shelf
-- horizontal: if 1, then x and y coordinates will be swapped

-- TODO: option so that it works without nodeboxes

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if intllib then
  S = intllib.Getter()
else
  S = function(s) return s end
end

barrel = {};

barrel.make_pipe = function( pipes, horizontal )

   local result = {};
   for i, v in pairs( pipes ) do
 
      local f  = v.f;
      local h1 = v.h1;
      local h2 = v.h2;
      if( not( v.b ) or v.b == 0 ) then
 
         table.insert( result,   {-0.37*f,  h1,-0.37*f, -0.28*f, h2,-0.28*f});
         table.insert( result,   {-0.37*f,  h1, 0.28*f, -0.28*f, h2, 0.37*f});
         table.insert( result,   { 0.37*f,  h1,-0.28*f,  0.28*f, h2,-0.37*f});
         table.insert( result,   { 0.37*f,  h1, 0.37*f,  0.28*f, h2, 0.28*f});


         table.insert( result,   {-0.30*f,  h1,-0.42*f, -0.20*f, h2,-0.34*f});
         table.insert( result,   {-0.30*f,  h1, 0.34*f, -0.20*f, h2, 0.42*f});
         table.insert( result,   { 0.20*f,  h1,-0.42*f,  0.30*f, h2,-0.34*f});
         table.insert( result,   { 0.20*f,  h1, 0.34*f,  0.30*f, h2, 0.42*f});

         table.insert( result,   {-0.42*f,  h1,-0.30*f, -0.34*f, h2,-0.20*f});
         table.insert( result,   { 0.34*f,  h1,-0.30*f,  0.42*f, h2,-0.20*f});
         table.insert( result,   {-0.42*f,  h1, 0.20*f, -0.34*f, h2, 0.30*f});
         table.insert( result,   { 0.34*f,  h1, 0.20*f,  0.42*f, h2, 0.30*f});


         table.insert( result,   {-0.25*f,  h1,-0.45*f, -0.10*f, h2,-0.40*f});
         table.insert( result,   {-0.25*f,  h1, 0.40*f, -0.10*f, h2, 0.45*f});
         table.insert( result,   { 0.10*f,  h1,-0.45*f,  0.25*f, h2,-0.40*f});
         table.insert( result,   { 0.10*f,  h1, 0.40*f,  0.25*f, h2, 0.45*f});

         table.insert( result,   {-0.45*f,  h1,-0.25*f, -0.40*f, h2,-0.10*f});
         table.insert( result,   { 0.40*f,  h1,-0.25*f,  0.45*f, h2,-0.10*f});
         table.insert( result,   {-0.45*f,  h1, 0.10*f, -0.40*f, h2, 0.25*f});
         table.insert( result,   { 0.40*f,  h1, 0.10*f,  0.45*f, h2, 0.25*f});

         table.insert( result,   {-0.15*f,  h1,-0.50*f,  0.15*f, h2,-0.45*f});
         table.insert( result,   {-0.15*f,  h1, 0.45*f,  0.15*f, h2, 0.50*f});

         table.insert( result,   {-0.50*f,  h1,-0.15*f, -0.45*f, h2, 0.15*f});
         table.insert( result,   { 0.45*f,  h1,-0.15*f,  0.50*f, h2, 0.15*f});
 
      -- filled horizontal part
      else
         table.insert( result,   {-0.35*f,  h1,-0.40*f,  0.35*f, h2,0.40*f});
         table.insert( result,   {-0.40*f,  h1,-0.35*f,  0.40*f, h2,0.35*f});
         table.insert( result,   {-0.25*f,  h1,-0.45*f,  0.25*f, h2,0.45*f});
         table.insert( result,   {-0.45*f,  h1,-0.25*f,  0.45*f, h2,0.25*f});
         table.insert( result,   {-0.15*f,  h1,-0.50*f,  0.15*f, h2,0.50*f});
         table.insert( result,   {-0.50*f,  h1,-0.15*f,  0.50*f, h2,0.15*f});
      end
   end

   -- make the whole thing horizontal
   if( horizontal == 1 ) then
      for i,v in ipairs( result ) do
         result[ i ] = { v[2], v[1], v[3],   v[5], v[4], v[6] };
      end
   end

   return result;
end


-- prepare formspec
barrel.on_construct = function( pos )

   local meta = minetest.env:get_meta(pos);
   local percent = math.random( 1, 100 ); -- TODO: show real filling

   meta:set_string( 'formspec', 
                               "size[8,9]"..
                                "image[2.6,2;2,3;default_sandstone.png^[lowpart:"..
                                                (100-percent)..":default_desert_stone.png]".. -- TODO: better images
                                "label[2.2,0;"..S("Pour:").."]"..
                                "list[current_name;input;3,0.5;1,1;]"..
                                "label[5,3.3;"..S("Fill:").."]"..
                                "list[current_name;output;5,3.8;1,1;]"..
                                "list[current_player;main;0,5;8,4;]");


   meta:set_string( 'liquid_type', '' ); -- which liquid is in the barrel?
   meta:set_int(    'liquid_level', 0 ); -- how much of the liquid is in there?

   local inv = meta:get_inventory()
   inv:set_size("input",     1);  -- to fill in new liquid
   inv:set_size("output",    1);  -- to extract liquid 
end


-- can only be digged if there are no more vessels/buckets in any of the slots
-- TODO: allow digging of a filled barrel? this would disallow stacking of them
barrel.can_dig = function( pos, player )
   local  meta = minetest.env:get_meta(pos);
   local  inv = meta:get_inventory()

   return ( inv:is_empty('input')
        and inv:is_empty('output'));
end


-- the barrel received input; either a new liquid that is to be poured in or a vessel that is to be filled
barrel.on_metadata_inventory_put = function( pos, listname, index, stack, player )
end


-- right-click to open/close barrel; punch to switch between horizontal/vertical position
        minetest.register_node("cottages:barrel", {
                description = S("barrel (closed)"),
                paramtype = "light",
                tiles = {"cottages_minimal_wood.png","cottages_minimal_wood.png","cottages_barrel.png"}, -- "default_tree_top.png", "default_tree_top.png", "default_tree.png"},
                is_ground_content = true,
                drawtype = "nodebox",
                node_box = {
                        type = "fixed",
                        fixed = barrel.make_pipe( { {f=0.9,h1=-0.2,h2=0.2,b=0}, {f=0.75,h1=-0.50,h2=-0.35,b=0}, {f=0.75,h1=0.35,h2=0.5,b=0},
                                                                                          {f=0.82,h1=-0.35,h2=-0.2,b=0},  {f=0.82,h1=0.2, h2=0.35,b=0},
                                                                                          {f=0.75,h1= 0.37,h2= 0.42,b=1},   -- top closed
                                                                                          {f=0.75,h1=-0.42,h2=-0.37,b=1}}, 0 ), -- bottom closed
                },
                groups = { tree = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2
                },
		drop = "cottages:barrel",
--                on_rightclick = function(pos, node, puncher)
--                    minetest.env:add_node(pos, {name = "cottages:barrel_open", param2 = node.param2})
--                end,
-- TODO: on_rightclick is no longer available - maybe open if empty and closed if full?
                on_punch      = function(pos, node, puncher)
                    minetest.env:add_node(pos, {name = "cottages:barrel_lying", param2 = node.param2})
                end,

                on_construct = function( pos )
                   return barrel.on_construct( pos );
                end,
                can_dig = function(pos,player)
                   return barrel.can_dig( pos, player );
                end,
                on_metadata_inventory_put = function(pos, listname, index, stack, player)
                   return barrel.on_metadata_inventory_put( pos, listname, index, stack, player );
                end

        })

        -- this barrel is opened at the top
        minetest.register_node("cottages:barrel_open", {
                description = S("barrel (open)"),
                paramtype = "light",
                tiles = {"cottages_minimal_wood.png","cottages_minimal_wood.png","cottages_barrel.png"},--"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
                is_ground_content = true,
                drawtype = "nodebox",
                node_box = {
                        type = "fixed",
                        fixed = barrel.make_pipe( { {f=0.9,h1=-0.2,h2=0.2,b=0}, {f=0.75,h1=-0.50,h2=-0.35,b=0}, {f=0.75,h1=0.35,h2=0.5,b=0},
                                                                                          {f=0.82,h1=-0.35,h2=-0.2,b=0},  {f=0.82,h1=0.2, h2=0.35,b=0},
--                                                                                          {f=0.75,h1= 0.37,h2= 0.42,b=1},   -- top closed
                                                                                          {f=0.75,h1=-0.42,h2=-0.37,b=1}}, 0 ), -- bottom closed
                },
                groups = { tree = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2
                },
		drop = "cottages:barrel",
--                on_rightclick = function(pos, node, puncher)
--                    minetest.env:add_node(pos, {name = "cottages:barrel", param2 = node.param2})
--                end,
                on_punch      = function(pos, node, puncher)
                    minetest.env:add_node(pos, {name = "cottages:barrel_lying_open", param2 = node.param2})
                end,
        })

        -- horizontal barrel
        minetest.register_node("cottages:barrel_lying", {
                description = S("barrel (closed), lying somewhere"),
                paramtype = "light",
	        paramtype2 = "facedir",
                tiles = {"cottages_barrel_lying.png","cottages_barrel_lying.png","cottages_minimal_wood.png","cottages_minimal_wood.png","cottages_barrel_lying.png"},--"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
                is_ground_content = true,
                drawtype = "nodebox",
                node_box = {
                        type = "fixed",
                        fixed = barrel.make_pipe( { {f=0.9,h1=-0.2,h2=0.2,b=0}, {f=0.75,h1=-0.50,h2=-0.35,b=0}, {f=0.75,h1=0.35,h2=0.5,b=0},
                                                                                          {f=0.82,h1=-0.35,h2=-0.2,b=0},  {f=0.82,h1=0.2, h2=0.35,b=0},
                                                                                          {f=0.75,h1= 0.37,h2= 0.42,b=1},   -- top closed
                                                                                          {f=0.75,h1=-0.42,h2=-0.37,b=1}}, 1 ), -- bottom closed
                },
                groups = { tree = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2
                },
		drop = "cottages:barrel",
                on_rightclick = function(pos, node, puncher)
                    minetest.env:add_node(pos, {name = "cottages:barrel_lying_open", param2 = node.param2})
                end,
                on_punch      = function(pos, node, puncher)
                    if( node.param2 < 4 ) then
                       minetest.env:add_node(pos, {name = "cottages:barrel_lying", param2 = (node.param2+1)})
                    else
                       minetest.env:add_node(pos, {name = "cottages:barrel", param2 = 0})
                    end
                end,
        })

        -- horizontal barrel, open
        minetest.register_node("cottages:barrel_lying_open", {
                description = S("barrel (opened), lying somewhere"),
                paramtype = "light",
	        paramtype2 = "facedir",
                tiles = {"cottages_barrel_lying.png","cottages_barrel_lying.png","cottages_minimal_wood.png","cottages_minimal_wood.png","cottages_barrel_lying.png"},--"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
                is_ground_content = true,
                drawtype = "nodebox",
                node_box = {
                        type = "fixed",
                        fixed = barrel.make_pipe( { {f=0.9,h1=-0.2,h2=0.2,b=0}, {f=0.75,h1=-0.50,h2=-0.35,b=0}, {f=0.75,h1=0.35,h2=0.5,b=0},
                                                                                          {f=0.82,h1=-0.35,h2=-0.2,b=0},  {f=0.82,h1=0.2, h2=0.35,b=0},
--                                                                                          {f=0.75,h1= 0.37,h2= 0.42,b=1},   -- top closed
                                                                                          {f=0.75,h1=-0.42,h2=-0.37,b=1}}, 1 ), -- bottom closed
                },
                groups = { tree = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2
                },
		drop = "cottages:barrel",
                on_rightclick = function(pos, node, puncher)
                    minetest.env:add_node(pos, {name = "cottages:barrel_lying", param2 = node.param2})
                end,
                on_punch      = function(pos, node, puncher)
                    if( node.param2 < 4 ) then
                       minetest.env:add_node(pos, {name = "cottages:barrel_lying_open", param2 = (node.param2+1)})
                    else
                       minetest.env:add_node(pos, {name = "cottages:barrel_open", param2 = 0})
                    end
                end,

        })

        -- let's hope "tub" is the correct english word for "bottich"
        minetest.register_node("cottages:tub", {
                description = S("tub"),
                paramtype = "light",
                tiles = {"cottages_minimal_wood.png","cottages_minimal_wood.png","cottages_barrel.png"},--"default_tree_top.png", "default_tree_top.png", "default_tree.png"},
                is_ground_content = true,
                drawtype = "nodebox",
                node_box = {
                        type = "fixed",
                        fixed = barrel.make_pipe( { {f=1.0,h1=-0.5,h2=0.0,b=0}, {f=1.0,h1=-0.46,h2=-0.41,b=1}}, 0 ),
                },
                groups = { tree = 1, snappy = 1, choppy = 2, oddly_breakable_by_hand = 1, flammable = 2
                },
        })


minetest.register_craft({
	output = "cottages:barrel",
	recipe = {
		{"default:wood",        "",              "default:wood" },
		{"default:steel_ingot", "",              "default:steel_ingot"},
		{"default:wood",        "default:wood",  "default:wood" },
	},
})

minetest.register_craft({
	output = "cottages:tub 2",
	recipe = {
		{"cottages:barrel"},
	},
})

minetest.register_craft({
	output = "cottages:barrel",
	recipe = {
		{"cottages:tub"},
		{"cottages:tub"},
	},
})
