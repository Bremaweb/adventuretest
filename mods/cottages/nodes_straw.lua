---------------------------------------------------------------------------------------
-- straw - a very basic material
---------------------------------------------------------------------------------------
--  * straw mat - for animals and very poor NPC; also basis for other straw things
--  * straw bale - well, just a good source for building and decoration

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if intllib then
	S = intllib.Getter()
else
	S = function(s) return s end
end

-- an even simpler from of bed - usually for animals 
-- it is a nodebox and not wallmounted because that makes it easier to replace beds with straw mats
minetest.register_node("cottages:straw_mat", {
        description = S("layer of straw"),
        drawtype = 'nodebox',
        tiles = { 'cottages_darkage_straw.png' }, -- done by VanessaE
        wield_image = 'cottages_darkage_straw.png',
        inventory_image = 'cottages_darkage_straw.png',
        sunlight_propagates = true,
        paramtype = 'light',
        paramtype2 = "facedir",
        is_ground_content = true,
        walkable = false,
        groups = { snappy = 3 },
        sounds = default.node_sound_leaves_defaults(),
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
	}
})

-- straw bales are a must for farming environments; if you for some reason do not have the darkage mod installed, this here gets you a straw bale
minetest.register_node("cottages:straw_bale", {
	drawtype = "nodebox",
	description = S("straw bale"),
	tiles = {"cottages_darkage_straw_bale.png"},
	paramtype = "light",
	groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2,flammable=3},
	sounds = default.node_sound_wood_defaults(),
        -- the bale is slightly smaller than a full node
	node_box = {
		type = "fixed",
		fixed = {
					{-0.45, -0.5,-0.45,  0.45,  0.45, 0.45},
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.45, -0.5,-0.45,  0.45,  0.45, 0.45},
			}
	}
})

-- just straw
minetest.register_node("cottages:straw", {
	drawtype = "normal",
	description = S("straw"),
	tiles = {"cottages_darkage_straw.png"},
	groups = {snappy=3,choppy=3,oddly_breakable_by_hand=3,flammable=3},
	sounds = default.node_sound_wood_defaults(),
        -- the bale is slightly smaller than a full node
})


minetest.register_node("cottages:threshing_floor", {
	drawtype = "nodebox",
	description = S("threshing floor"),
-- TODO: stone also looks pretty well for this
	tiles = {"default_junglewood.png^farming_wheat.png","default_junglewood.png","default_junglewood.png^default_stick.png"},
	paramtype  = "light",
        paramtype2 = "facedir",
	groups = {cracky=2},
	node_box = {
		type = "fixed",
		fixed = {
					{-0.50, -0.5,-0.50, 0.50, -0.40, 0.50},

					{-0.50, -0.4,-0.50,-0.45, -0.20, 0.50},
					{ 0.45, -0.4,-0.50, 0.50, -0.20, 0.50},

					{-0.45, -0.4,-0.50, 0.45, -0.20,-0.45},
					{-0.45, -0.4, 0.45, 0.45, -0.20, 0.50},
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.50, -0.5,-0.50, 0.50, -0.20, 0.50},
			}
	},
	on_construct = function(pos)

               	local meta = minetest.env:get_meta(pos);
               	meta:set_string("infotext", S("Threshing floor"));
               	local inv = meta:get_inventory();
               	inv:set_size("harvest", 2);
               	inv:set_size("straw", 4);
               	inv:set_size("seeds", 4);
       	end,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos);
		meta:set_string("owner", placer:get_player_name() or "");
		meta:set_string("infotext", S("Threshing floor (owned by %s)"):format(meta:get_string("owner") or ""));
                meta:set_string("formspec",
                               "size[8,8]"..
				"image[1.5,0;1,1;default_stick.png]"..
				"image[0,1;1,1;farming_wheat.png]"..
                                "list[current_name;harvest;1,1;2,1;]"..
                                "list[current_name;straw;5,0;2,2;]"..
                                "list[current_name;seeds;5,2;2,2;]"..
					"label[1,0.5;"..S("Harvested wheat:").."]"..
					"label[4,0.0;"..S("Straw:").."]"..
					"label[4,2.0;"..S("Seeds:").."]"..
					"label[0,-0.5;"..S("Threshing floor").."]"..
					"label[2.5,-0.5;"..S("Owner: %s"):format(meta:get_string("owner") or "").."]"..
					"label[0,2.5;"..S("Punch threshing floor with a stick").."]"..
					"label[0,3.0;"..S("to get straw and seeds from wheat.").."]"..
                                "list[current_player;main;0,4;8,4;]");
        end,

        can_dig = function(pos,player)

                local meta  = minetest.get_meta(pos);
                local inv   = meta:get_inventory();
		local owner = meta:get_string('owner');

                if(  not( inv:is_empty("harvest"))
		  or not( inv:is_empty("straw"))
		  or not( inv:is_empty("seeds"))
		  or not( player )
		  or ( owner and owner ~= ''  and player:get_player_name() ~= owner )) then

		   return false;
		end
                return true;
        end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
                if( player and player:get_player_name() ~= meta:get_string('owner' )) then
                        return 0
		end
		return count;
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		-- only accept input the threshing floor can use/process
		if(    listname=='straw'
		    or listname=='seeds' 
		    or (listname=='harvest' and stack and stack:get_name() ~= 'farming:wheat' )) then
			return 0;
		end

                if( player and player:get_player_name() ~= meta:get_string('owner' )) then
                        return 0
		end
		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
                if( player and player:get_player_name() ~= meta:get_string('owner' )) then
                        return 0
		end
		return stack:get_count()
	end,


	on_punch = function(pos, node, puncher)
		if( not( pos ) or not( node ) or not( puncher )) then
			return;
		end
		-- only punching with a normal stick is supposed to work
		local wielded = puncher:get_wielded_item();
		if( not( wielded ) or not( wielded:get_name() ) or wielded:get_name() ~= 'default:stick') then
 			return;
		end
		local name = puncher:get_player_name();

               	local meta = minetest.env:get_meta(pos);
               	local inv = meta:get_inventory();

		local input = inv:get_list('harvest');
		-- we have two input slots
		local stack1 = inv:get_stack( 'harvest', 1);
		local stack2 = inv:get_stack( 'harvest', 2);

		if(       (      stack1:is_empty()  and stack2:is_empty())
			or( not( stack1:is_empty()) and stack1:get_name() ~= 'farming:wheat')
			or( not( stack2:is_empty()) and stack2:get_name() ~= 'farming:wheat')) then

--			minetest.chat_send_player( name, 'One of the input slots contains something else than wheat, or there is no wheat at all.');
			return;
		end

		-- on average, process 25 wheat at each punch (10..40 are possible)
		local anz_wheat = 10 + math.random( 0, 30 );
		-- we already made sure there is only wheat inside
		local found_wheat = stack1:get_count() + stack2:get_count();
		
		-- do not process more wheat than present in the input slots
		if( found_wheat < anz_wheat ) then
			anz_wheat = found_wheat;
		end

		-- this can be enlarged by a multiplicator if desired
		local anz_straw = anz_wheat;
		local anz_seeds = anz_wheat;

		if(    inv:room_for_item('straw','cottages:straw_mat '..tostring( anz_straw ))
		   and inv:room_for_item('seeds','farming:seed_wheat '..tostring( anz_seeds ))) then

			-- the player gets two kind of output
			inv:add_item("straw",'cottages:straw_mat '..tostring( anz_straw ));
			inv:add_item("seeds",'farming:seed_wheat '..tostring( anz_seeds ));
			-- consume the wheat
			inv:remove_item("harvest", 'farming:wheat '..tostring( anz_wheat ));

			local anz_left = found_wheat - anz_wheat;
			if( anz_left > 0 ) then
				minetest.chat_send_player( name, S('You have threshed %s wheat (%s are left).'):format(anz_wheat,anz_left));
			else
				minetest.chat_send_player( name, S('You have threshed the last %s wheat.'):format(anz_wheat));
			end
		end	
	end,
})



minetest.register_node("cottages:handmill", {
	drawtype = "nodebox",
	description = S("mill, powered by punching"),
	tiles = {"default_stone.png"},
	paramtype  = "light",
        paramtype2 = "facedir",
	groups = {cracky=2},
	node_box = {
		type = "fixed",
		fixed = {

				-- taken from 3dfornitures tree redefinition
				{-0.35,-0.50,-0.4,  0.35,-0.32,0.4},
				{-0.4, -0.50,-0.35, 0.4, -0.32,0.35},
				{-0.25,-0.50,-0.45, 0.25,-0.32,0.45},
				{-0.45,-0.50,-0.25, 0.45,-0.32,0.25},
				{-0.15,-0.50,-0.5,  0.15,-0.32,0.5},
				{-0.5, -0.50,-0.15, 0.5, -0.32,0.15},

				-- upper mill wheel
				{-0.35,-0.27,-0.4,  0.35,-0.05,0.4},
				{-0.4, -0.27,-0.35, 0.4, -0.05,0.35},
				{-0.25,-0.27,-0.45, 0.25,-0.05,0.45},
				{-0.45,-0.27,-0.25, 0.45,-0.05,0.25},
				{-0.15,-0.27,-0.5,  0.15,-0.05,0.5},
				{-0.5, -0.27,-0.15, 0.5, -0.05,0.15},

				-- middle axis
				{-0.05,-0.50,-0.05, 0.05, 0.15,0.05},
				-- handle
				{-0.35,-0.05,-0.35,-0.25, 0.25,-0.25},
			}
	},
	selection_box = {
		type = "fixed",
		fixed = {
					{-0.50, -0.5,-0.50, 0.50,  0.25, 0.50},
			}
	},
	on_construct = function(pos)

               	local meta = minetest.env:get_meta(pos);
               	meta:set_string("infotext", S("Mill, powered by punching"));
               	local inv = meta:get_inventory();
               	inv:set_size("seeds", 1);
               	inv:set_size("flour", 4);
       	end,

	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos);
		meta:set_string("owner", placer:get_player_name() or "");
		meta:set_string("infotext", S("Mill, powered by punching (owned by %s)"):format(meta:get_string("owner") or ""));
                meta:set_string("formspec",
                               "size[8,8]"..
				"image[0,1;1,1;farming_wheat_seed.png]"..
                                "list[current_name;seeds;1,1;1,1;]"..
                                "list[current_name;flour;5,1;2,2;]"..
					"label[0,0.5;"..S("Wheat seeds:").."]"..
					"label[4,0.5;"..S("Flour:").."]"..
					"label[0,-0.5;"..S("Mill").."]"..
					"label[2.5,-0.5;"..S("Owner: %s"):format(meta:get_string('owner') or "").."]"..
					"label[0,2.5;"..S("Punch this hand-driven mill").."]"..
					"label[0,3.0;"..S("to convert wheat seeds into flour.").."]"..
                                "list[current_player;main;0,4;8,4;]");
        end,

        can_dig = function(pos,player)

                local meta  = minetest.get_meta(pos);
                local inv   = meta:get_inventory();
		local owner = meta:get_string('owner');

                if(  not( inv:is_empty("flour"))
		  or not( inv:is_empty("seeds"))
		  or not( player )
		  or ( owner and owner ~= ''  and player:get_player_name() ~= owner )) then

		   return false;
		end
                return true;
        end,

	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local meta = minetest.get_meta(pos)
                if( player and player:get_player_name() ~= meta:get_string('owner' )) then
                        return 0
		end
		return count;
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		-- only accept input the threshing floor can use/process
		if(    listname=='flour'
		    or (listname=='seeds' and stack and stack:get_name() ~= 'farming:seed_wheat' )) then
			return 0;
		end

                if( player and player:get_player_name() ~= meta:get_string('owner' )) then
                        return 0
		end
		return stack:get_count()
	end,

	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
                if( player and player:get_player_name() ~= meta:get_string('owner' )) then
                        return 0
		end
		return stack:get_count()
	end,

        -- this code is very similar to the threshing floor; except that it has only one input- and output-slot
 	-- and does not require the usage of a stick
	on_punch = function(pos, node, puncher)
		if( not( pos ) or not( node ) or not( puncher )) then
			return;
		end
		local name = puncher:get_player_name();

               	local meta = minetest.env:get_meta(pos);
               	local inv = meta:get_inventory();

		local input = inv:get_list('seeds');
		local stack1 = inv:get_stack( 'seeds', 1);

		if(       (      stack1:is_empty())
			or( not( stack1:is_empty()) and stack1:get_name() ~= 'farming:seed_wheat')) then

			return;
		end

		-- turning the mill is a slow process; 1-21 flour are generated per turn
		local anz = 1 + math.random( 0, 20 );
		-- we already made sure there is only wheat inside
		local found = stack1:get_count();
		
		-- do not process more wheat than present in the input slots
		if( found < anz ) then
			anz = found;
		end


		if(    inv:room_for_item('flour','farming:flour '..tostring( anz ))) then

			inv:add_item("flour",'farming:flour '..tostring( anz ));
			inv:remove_item("seeds", 'farming:seed_wheat '..tostring( anz ));

			local anz_left = found - anz;
			if( anz_left > 0 ) then
				minetest.chat_send_player( name, S('You have grinded %s wheat seeds (%s are left).'):format(anz,anz_left));
			else
				minetest.chat_send_player( name, S('You have grinded the last %s wheat seeds.'):format(anz));
			end

			-- if the version of MT is recent enough, rotate the mill a bit
			if( minetest.swap_node ) then
				node.param2 = node.param2 + 1;
				if( node.param2 > 3 ) then
					node.param2 = 0;
				end
				minetest.swap_node( pos, node );
			end
		end	
	end,
})




---------------------------------------------------------------------------------------
-- crafting receipes
---------------------------------------------------------------------------------------
-- this returns corn as well
-- the replacements work only if the replaced slot gets empty...
minetest.register_craft({
	output = "cottages:straw_mat 6",
	recipe = {
                {'default:cobble','',''},
		{"farming:wheat_harvested", "farming:wheat_harvested", "farming:wheat_harvested", },
	},
        replacements = {{ 'default:cobble', "farming:seed_wheat 3" }},  
})

-- this is a better way to get straw mats
minetest.register_craft({
	output = "cottages:threshing_floor",
	recipe = {
		{"default:junglewood", "default:chest_locked", "default:junglewood", },
		{"default:junglewood", "default:stone",        "default:junglewood", },
	},
})

-- and a way to turn wheat seeds into flour
minetest.register_craft({
	output = "cottages:handmill",
	recipe = {
		{"default:stick",     "default:stone",    "", },
		{"",               "default:steel_ingot", "", },
		{"",                  "default:stone",    "", },
	},
})

minetest.register_craft({
	output = "cottages:straw_bale",
	recipe = {
		{"cottages:straw_mat"},
		{"cottages:straw_mat"},
		{"cottages:straw_mat"},
	},
})

minetest.register_craft({
	output = "cottages:straw",
	recipe = {
		{"cottages:straw_bale"},
	},
})

minetest.register_craft({
	output = "cottages:straw_bale",
	recipe = {
		{"cottages:straw"},
	},
})

minetest.register_craft({
	output = "cottages:straw_mat 3",
	recipe = {
		{"cottages:straw_bale"},
	},
})
