-- TODO: this function also occours in replacements.lua
handle_schematics.get_content_id_replaced = function( node_name, replacements )
	if( not( replacements ) or not(replacements.table )) then
		if not( node_name ) then
			return minetest.get_content_id( 'ignore' );
		else
			return minetest.get_content_id( node_name );
		end
	end
	if( replacements.table[ node_name ]) then
		return minetest.get_content_id( replacements.table[ node_name ] );
	else
		return minetest.get_content_id( node_name )
	end
end

-- either uses get_node_or_nil(..) or the data from voxelmanip
-- the function might as well be local (only used by *.mg_drop_moresnow)
handle_schematics.get_node_somehow = function( x, y, z, a, data, param2_data )
	if( a and data and param2_data ) then
		return { content = data[a:index(x, y, z)], param2 = param2_data[a:index(x, y, z)] };
	end
	-- no voxelmanip; get the node the normal way
	local node = minetest.get_node_or_nil( {x=x, y=y, z=z} );
	if( not( node ) ) then
		return { content = moresnow.c_ignore, param2 = 0 };
	end
	return { content = minetest.get_content_id( node.name ), param2 = node.param2, name = node.name };
end


-- "drop" moresnow snow on diffrent shapes; works for voxelmanip and node-based setting
handle_schematics.mg_drop_moresnow = function( x, z, y_top, y_bottom, a, data, param2_data)

	-- this only works if moresnow is installed
	if( not( handle_schematics.moresnow_installed )) then
		return;
	end

	local y = y_top;
	local node_above = handle_schematics.get_node_somehow( x, y+1, z, a, data, param2_data );	
	local node_below = nil;
	while( y >= y_bottom ) do

		node_below = handle_schematics.get_node_somehow( x, y, z, a, data, param2_data );
		if(     node_above.content == moresnow.c_air
		    and node_below.content
		    and node_below.content ~= moresnow.c_ignore
		    and node_below.content ~= moresnow.c_air ) then

			-- turn water into ice, but don't drop snow on it
			if( node_below.content == minetest.get_content_id("default:water_source")
			 or node_below.content == minetest.get_content_id("default:river_water_source")) then
				return { height = y, suggested = {new_id = minetest.get_content_id('default:ice'), param2 = 0 }};
			end

			-- if the node below drops snow when digged (i.e. is either snow or a moresnow node), we're finished
			local get_drop = minetest.get_name_from_content_id( node_below.content );
			if( get_drop ) then
				get_drop = minetest.registered_nodes[ get_drop ];
				if( get_drop and get_drop.drop and type( get_drop.drop )=='string' and get_drop.drop == 'default:snow') then
					return;
				end
			end
			if( not(node_below.content)
			    or  node_below.content == moresnow.c_snow ) then
				return;
			end

			local suggested = moresnow.suggest_snow_type( node_below.content, node_below.param2 );

			-- c_snow_top and c_snow_fence can only exist when the node 2 below is a solid one
			if(    suggested.new_id == moresnow.c_snow_top
			    or suggested.new_id == moresnow.c_snow_fence) then	
				local node_below2 = handle_schematics.get_node_somehow( x, y-1, z, a, data, param2_data);
				if(     node_below2.content ~= moresnow.c_ignore
				    and node_below2.content ~= moresnow.c_air ) then
					local suggested2 = moresnow.suggest_snow_type( node_below2.content, node_below2.param2 );

					if( suggested2.new_id == moresnow.c_snow ) then
						return { height = y+1, suggested = suggested };
					end
				end
			-- it is possible that this is not the right shape; if so, the snow will continue to fall down
			elseif( suggested.new_id ~= moresnow.c_ignore ) then
					
				return { height = y+1, suggested = suggested };
			end
			-- TODO return; -- abort; there is no fitting moresnow shape for the node below
		end
		y = y-1;
		node_above = node_below;
	end
end


-- helper function for generate_building
-- places a marker that allows players to buy plots with houses on them (in order to modify the buildings)
local function generate_building_plotmarker( pos, minp, maxp, data, param2_data, a, cid, building_nr_in_bpos, village_id, filename)
	-- position the plot marker so that players can later buy this plot + building in order to modify it
	-- pos.o contains the original orientation (determined by the road and the side the building is
	local p = {x=pos.x, y=pos.y+1, z=pos.z};
	if(     pos.o == 0 ) then
		p.x = p.x - 1;
		p.z = p.z + pos.bsizez - 1;
	elseif( pos.o == 2 ) then
		p.x = p.x + pos.bsizex;
	elseif( pos.o == 1 ) then
		p.z = p.z + pos.bsizez;
		p.x = p.x + pos.bsizex - 1;
	elseif( pos.o == 3 ) then
		p.z = p.z - 1;
	end
	-- actually position the marker
	if(   p.x >= minp.x and p.x <= maxp.x and p.z >= minp.z and p.z <= maxp.z and p.y >= minp.y and p.y <= maxp.y) then
		if( data[ a:index(p.x, p.y, p.z)] == cid.c_snow and p.y<maxp.y and moresnow and moresnow.c_snow_top and cid.c_snow_top ~= cid.c_ignore) then
			data[ a:index(p.x, p.y+1, p.z)] = moresnow.c_snow_top;
		end
		data[       a:index(p.x, p.y, p.z)] = cid.c_plotmarker;
		param2_data[a:index(p.x, p.y, p.z)] = pos.brotate;
		-- store the necessary information in the marker so that it knows for which building it is responsible
		local meta = minetest.get_meta( p );
		meta:set_string('village_id', village_id );
		meta:set_int(   'plot_nr',    building_nr_in_bpos );
		meta:set_string('infotext',   'Plot No. '..tostring( building_nr_in_bpos ).. ' with '..tostring( filename ));
	end
end



-- we do have a list of all nodenames the building contains (the .mts file provided it);
-- we can thus apply all replacements to these nodenames;
-- this also checks param2 and sets some other variables to indicate that it's i.e. a tree or a chest
-- (which both need special handling later on)
local function generate_building_translate_nodenames( nodenames, replacements, cid, binfo_scm, mirror_x, mirror_z )
	
	if( not( nodenames )) then
		return;
	end
	local i;
	local v;
	local new_nodes   = {};
	for i,node_name in ipairs( nodenames ) do

		new_nodes[ i ] = {}; -- array for collecting information about the new content id for nodes with number "i" in their .mts savefile

		-- some nodes may be called differently when mirrored; needed for doors
		local new_node_name = node_name;
		if( new_node_name and ( mirror_x or mirror_z ) and handle_schematics.mirrored_node[ new_node_name ] ) then
			new_node_name = handle_schematics.mirrored_node[ node_name ];
			new_nodes[ i ].is_mirrored = 1; -- currently unused
		end

		-- apply the replacements
		if( new_node_name and replacements.table[ new_node_name ] ) then
			new_node_name = replacements.table[ new_node_name ];
			new_nodes[ i ].is_replaced = 1; -- currently unused
		end

		-- those chests do not exist as regular nodes; they're just placeholders
		if(        node_name == 'cottages:chest_private'
		   or      node_name == 'cottages:chest_work'
		   or      node_name == 'cottages:chest_storage' ) then

			new_nodes[ i ].is_replaced   = 1; -- currently unused
			new_nodes[ i ].special_chest = node_name;
			-- TODO: perhaps use a locked chest owned by the mob living there?
			-- place a normal chest here
			new_nodes[ i ].new_content   = cid.c_chest;
			new_nodes[ i ].special_chest = node_name;
			new_node_name = 'default:chest';			

		elseif(new_node_name == 'cottages:chest_private'
		   or  new_node_name == 'cottages:chest_work'
		   or  new_node_name == 'cottages:chest_storage' ) then

			new_nodes[ i ].is_replaced   = 1; -- currently unused
			new_nodes[ i ].special_chest = new_node_name;
			-- TODO: perhaps use a locked chest owned by the mob living there?
			-- place a normal chest here
			new_nodes[ i ].new_content   = cid.c_chest;
		end

		-- only existing nodes can be placed
		if( new_node_name and minetest.registered_nodes[ new_node_name ]) then
							
			local regnode = minetest.registered_nodes[ new_node_name ];

			new_nodes[ i ].new_node_name = new_node_name;
			new_nodes[ i ].new_content   = minetest.get_content_id( new_node_name );
			if( regnode.on_construct ) then
				new_nodes[ i ].on_construct = 1;
			end

			local new_content = new_nodes[ i ].new_content;
			if( new_content == cid.c_dirt or new_content == cid.c_dirt_with_grass ) then
				new_nodes[ i ].is_grass     = 1;
		
			elseif( new_content == cid.c_sapling
			     or new_content == cid.c_jsapling
			     or new_content == cid.c_psapling
			     or new_content == cid.c_savannasapling
			     or new_content == cid.c_pinesapling ) then
				-- store that a tree is to be grown there
				new_nodes[ i ].is_tree      = 1;

			elseif( new_content == cid.c_chest
			   or   new_content == cid.c_chest_locked 
			   or   new_content == cid.c_chest_shelf
			   or   new_content == cid.c_chest_ash
			   or   new_content == cid.c_chest_aspen
			   or   new_content == cid.c_chest_birch
			   or   new_content == cid.c_chest_maple
			   or   new_content == cid.c_chest_chestnut
			   or   new_content == cid.c_chest_pine
			   or   new_content == cid.c_chest_spruce) then
				-- we're dealing with a chest that might need filling
				new_nodes[ i ].is_chestlike = 1;

			elseif( new_content == cid.c_sign ) then
				-- the sign may require some text to be written on it
				new_nodes[ i ].is_sign      = 1;
			end


			-- handle_schematics.get_param2_rotated( 'facedir', param2 ) needs to be called for nodes
			-- which use either facedir or wallmounted;
			-- realtest rotates some nodes diffrently and does not come with default:ladder
			if(    node_name == 'default:ladder' and not( minetest.registered_nodes[ node_name ])) then
				new_nodes[ i ].change_param2 = {}; --{ 2->1, 5->2, 3->3, 4->0 }	
				new_nodes[ i ].change_param2[2] = 1;
				new_nodes[ i ].change_param2[5] = 2;
				new_nodes[ i ].change_param2[3] = 3;
				new_nodes[ i ].change_param2[4] = 0;
				new_nodes[ i ].paramtype2 = 'facedir';
			-- ..except if they are stairs or ladders
			elseif( string.sub( node_name, 1, 7 ) == 'stairs:' or string.sub( node_name, 1, 6 ) == 'doors:') then
				new_nodes[ i ].paramtype2 = 'facedir';
			-- normal nodes
			elseif( regnode and regnode.paramtype2 and (regnode.paramtype2=='facedir' or regnode.paramtype2=='wallmounted')) then
				new_nodes[ i ].paramtype2 = regnode.paramtype2;
			end
		
		-- we tried our best, but the replacement node is not defined	
		elseif( new_node_name ~= 'mg:ignore' ) then
			local msg = 'ERROR: Did not find a suitable replacement for '..tostring( node_name )..' (suggested but inexistant: '..
					tostring( new_node_name )..'). Building: '..tostring( binfo_scm )..'.';
			if( mg_villages and mg_villages.print ) then
				mg_villages.print( mg_villages.DEBUG_LEVEL_WARNING, msg );
			else
				print( msg );
			end
			msg = nil;
			new_nodes[ i ].ignore = 1; -- keep the old content
		else -- handle mg:ignore
			new_nodes[ i ].ignore = 1;
		end

		
	end
	return new_nodes;
end


local function generate_building(pos, minp, maxp, data, param2_data, a, extranodes, replacements, cid, extra_calls, building_nr_in_bpos, village_id, binfo_extra, road_node, keep_ground)

	local binfo = binfo_extra;
	if( not( binfo ) and mg_villages) then
		binfo = mg_villages.BUILDINGS[pos.btype]
	end
	local scm

	-- the building got removed from mg_villages.BUILDINGS in the meantime
	if( not( binfo )) then
		return;
	end

	-- schematics of .mts type are not handled here; they need to be placed using place_schematics
	if( binfo.is_mts and binfo.is_mts == 1 ) then
		return;
	end


	-- roads are very simple structures that are not stored as schematics
	if( pos.btype == 'road' ) then
		handle_schematics.place_road( minp, maxp, data, param2_data, a, road_node, pos, cid.c_air );
		return;
	end


	if( not( pos.no_plotmarker )) then
		generate_building_plotmarker( pos, minp, maxp, data, param2_data, a, cid, building_nr_in_bpos, village_id, binfo.scm );
	end

	-- skip building if it is not located at least partly in the area that is currently beeing generated
	if(   pos.x > maxp.x or pos.x + pos.bsizex < minp.x
	   or pos.z > maxp.z or pos.z + pos.bsizez < minp.z ) then
		return;
	end


	if( pos.btype and
	  ((     binfo.sizex ~= pos.bsizex and binfo.sizex ~= pos.bsizez )
	    or ( binfo.sizez ~= pos.bsizex and binfo.sizez ~= pos.bsizez )
	    or not( binfo.scm_data_cache ))) then
		if( mg_villages and mg_villages.print ) then
			mg_villages.print( mg_villages.DEBUG_LEVEL_WARNING,
				'ERROR: This village was created using diffrent buildings than those known know. Cannot place unknown building.');
		else
			print( 'ERROR: Size information about this building differs. Cannot place building.');
		end
		return;
	end

	if( binfo.scm_data_cache )then
		scm = binfo.scm_data_cache;
	else
		scm = binfo.scm
	end

	-- the fruit is set per building, not per village as the other replacements
	if( binfo.farming_plus and binfo.farming_plus == 1 and pos.fruit and mg_villages) then
		mg_villages.get_fruit_replacements( replacements, pos.fruit);
	end

	local c_ignore = minetest.get_content_id("ignore")
	local c_air = minetest.get_content_id("air")
	local c_snow                 = minetest.get_content_id( "default:snow");
	local c_dirt                 = minetest.get_content_id( "default:dirt" );
	local c_dirt_with_grass      = minetest.get_content_id( "default:dirt_with_grass" );
	local c_dirt_with_snow       = minetest.get_content_id( "default:dirt_with_snow" );

	local scm_x = 0;
	local scm_z = 0;
	local step_x = 1;
	local step_z = 1;
	local scm_z_start = 0;

	if(     pos.brotate == 2 ) then
		scm_x  = pos.bsizex+1;
		step_x = -1;
	end
	if(     pos.brotate == 1 ) then
		scm_z  = pos.bsizez+1;
		step_z = -1;
		scm_z_start = scm_z;
	end
		
	local mirror_x = false;
	local mirror_z = false;
	if( pos.mirror ) then
		if( binfo.axis and binfo.axis == 1 ) then
			mirror_x = true;
			mirror_z = false;
		else
			mirror_x = false;
			mirror_z = true;
		end
	end

	-- translate all nodenames and apply the replacements
	local new_nodes = generate_building_translate_nodenames( binfo.nodenames, replacements, cid, binfo.scm, mirror_x, mirror_z );

	for x = 0, pos.bsizex-1 do
	scm_x = scm_x + step_x;
	scm_z = scm_z_start;
	for z = 0, pos.bsizez-1 do
		scm_z = scm_z + step_z;

		local xoff = scm_x;
		local zoff = scm_z;
		if(     pos.brotate == 2 ) then
			if( mirror_x ) then
				xoff = pos.bsizex - scm_x + 1;
			end
			if( mirror_z ) then
				zoff = scm_z;
			else
				zoff = pos.bsizez - scm_z + 1;
			end
		elseif( pos.brotate == 1 ) then
			if( mirror_x ) then
				xoff = pos.bsizez - scm_z + 1;
			else
				xoff = scm_z;
			end
			if( mirror_z ) then
				zoff = pos.bsizex - scm_x + 1;
			else
				zoff = scm_x;
			end
		elseif( pos.brotate == 3 ) then
			if( mirror_x ) then
				xoff = pos.bsizez - scm_z + 1;
			else
				xoff = scm_z;
			end
			if( mirror_z ) then
				zoff = scm_x;
			else
				zoff = pos.bsizex - scm_x + 1;
			end
		elseif( pos.brotate == 0 ) then
			if( mirror_x ) then
				xoff = pos.bsizex - scm_x + 1;
			end
			if( mirror_z ) then
				zoff = pos.bsizez - scm_z + 1;
			end
		end

		local has_snow    = false;
		local ground_type = c_dirt_with_grass; 
		for y = 0, binfo.ysize-1 do
			local ax = pos.x+x;
			local ay = pos.y+y+binfo.yoff;
			local az = pos.z+z;
			if (ax >= minp.x and ax <= maxp.x) and (ay >= minp.y and ay <= maxp.y) and (az >= minp.z and az <= maxp.z) then
	
				local new_content = c_air;
				local t = scm[y+1][xoff][zoff];

				local node_content = data[a:index(ax, ay, az)];
				if( binfo.yoff+y == 0 ) then
					-- no snow on the gravel roads
					if( node_content == c_dirt_with_snow or data[a:index(ax, ay+1, az)]==c_snow) then
						has_snow    = true;
					end

					ground_type = node_content;
				end

				if( not( t )) then
					if( node_content ~= cid.c_plotmarker and (not(moresnow) or node_content ~= moresnow.c_snow_top )) then
						data[ a:index(ax, ay, az)] = cid.c_air;
					end
				else
					local n = new_nodes[ t[1] ]; -- t[1]: id of the old node
					if( not( n.ignore )) then
						new_content = n.new_content;
					else
						new_content = node_content;
					end

					-- replace all dirt and dirt with grass at that x,z coordinate with the stored ground grass node;
					if( n.is_grass and keep_ground) then
						new_content = ground_type;
					end

					if( n.on_construct ) then
						if( not( extra_calls.on_constr[ new_content ] )) then
							extra_calls.on_constr[ new_content ] = { {x=ax, y=ay, z=az}};
						else
							table.insert( extra_calls.on_constr[ new_content ], {x=ax, y=ay, z=az});
						end
					end

					-- do not overwrite plotmarkers
					if( new_content ~= cid.c_air or node_content ~= cid.c_plotmarker ) then
						data[       a:index(ax, ay, az)] = new_content;
					end

					-- store that a tree is to be grown there
					if(     n.is_tree ) then
						table.insert( extra_calls.trees,  {x=ax, y=ay, z=az, typ=new_content, snow=has_snow});

					-- we're dealing with a chest that might need filling
					elseif( n.is_chestlike ) then
						table.insert( extra_calls.chests, {x=ax, y=ay, z=az, typ=new_content, bpos_i=building_nr_in_bpos, typ_name=n.special_chest});

					-- the sign may require some text to be written on it
					elseif( n.is_sign ) then
						table.insert( extra_calls.signs,  {x=ax, y=ay, z=az, typ=new_content, bpos_i=building_nr_in_bpos});
					end

					-- handle rotation
					if(     n.paramtype2 ) then
						local param2 = t[2];
						if( n.change_param2 and  n.change_param2[ t[2] ]) then
							param2 = n.change_param2[ param2 ];
						end
	
						local np2 = 0;
						if(     mirror_x ) then
							np2 = handle_schematics.rotation_table[ n.paramtype2 ][ param2+1 ][ pos.brotate+1 ][ 2 ];
						elseif( mirror_z ) then
							np2 = handle_schematics.rotation_table[ n.paramtype2 ][ param2+1 ][ pos.brotate+1 ][ 3 ];
						else
							np2 = handle_schematics.rotation_table[ n.paramtype2 ][ param2+1 ][ pos.brotate+1 ][ 1 ];
						end

--[[
						local param2list = handle_schematics.get_param2_rotated( n.paramtype2, param2);
						local np2 = param2list[ pos.brotate + 1];
						-- mirror
						if(     mirror_x ) then
							if(     #param2list==5) then
								np2 = handle_schematics.mirror_facedir[ ((pos.brotate+1)%2)+1 ][ np2+1 ];
							elseif( #param2list<5 
							       and  ((pos.brotate%2==1 and (np2==4 or np2==5)) 
						 	          or (pos.brotate%2==0 and (np2==2 or np2==3)))) then 
								np2 = param2list[ (pos.brotate + 2)%4 +1];
							end

						elseif( mirror_z ) then
							if(     #param2list==5) then
								np2 = handle_schematics.mirror_facedir[ (pos.brotate     %2)+1 ][ np2+1 ];
							elseif( #param2list<5 
							       and  ((pos.brotate%2==0 and (np2==4 or np2==5)) 
						 	          or (pos.brotate%2==1 and (np2==2 or np2==3)))) then 
								np2 = param2list[ (pos.brotate + 2)%4 +1];
							end
						end
--]]

						param2_data[a:index(ax, ay, az)] = np2;
					else
						param2_data[a:index(ax, ay, az)] = t[2];
					end
				end
			end
		end

		local ax = pos.x + x;
		local az = pos.z + z;
		local y_top    = pos.y+binfo.yoff+binfo.ysize;
		if( y_top+1 > maxp.y ) then
			y_top = maxp.y-1;
		end
		local y_bottom = pos.y+binfo.yoff;
		if( y_bottom < minp.y ) then
			y_bottom = minp.y;
		end
		if( has_snow and ax >= minp.x and ax <= maxp.x and az >= minp.z and az <= maxp.z ) then
			local res = handle_schematics.mg_drop_moresnow( ax, az, y_top, y_bottom-1, a, data, param2_data);
			if( res and (data[ a:index(ax, res.height, az)]==cid.c_air
			          or data[ a:index(ax, res.height, az)]==cid.c_water )) then
				data[       a:index(ax, res.height, az)] = res.suggested.new_id;
				param2_data[a:index(ax, res.height, az)] = res.suggested.param2;
				has_snow = false;
			end
		end
	end
	end
end



-- actually place the buildings (at least those which came as .we files; .mts files are handled later on)
-- this code was also responsible for tree placement;
-- place_buildings is used by mg_villages exclusively. It calls the local function generate_building and
-- therefore resides in this file.
handle_schematics.place_buildings = function(village, minp, maxp, data, param2_data, a, cid, village_id)
	-- this function is only relevant for mg_villages
	if( not( mg_villages )) then
		return;
	end
	local vx, vz, vs, vh = village.vx, village.vz, village.vs, village.vh
	local village_type = village.village_type;

	local bpos             = village.to_add_data.bpos;

	local replacements = mg_villages.get_replacement_table( village.village_type, nil, village.to_add_data.replacements );

	cid.c_chest            = handle_schematics.get_content_id_replaced( 'default:chest',          replacements );
	cid.c_chest_locked     = handle_schematics.get_content_id_replaced( 'default:chest_locked',   replacements );
	cid.c_chest_shelf      = handle_schematics.get_content_id_replaced( 'cottages:shelf',         replacements );
	cid.c_chest_ash        = handle_schematics.get_content_id_replaced( 'trees:chest_ash',        replacements );
	cid.c_chest_aspen      = handle_schematics.get_content_id_replaced( 'trees:chest_aspen',      replacements );
	cid.c_chest_birch      = handle_schematics.get_content_id_replaced( 'trees:chest_birch',      replacements );
	cid.c_chest_maple      = handle_schematics.get_content_id_replaced( 'trees:chest_maple',      replacements );
	cid.c_chest_chestnut   = handle_schematics.get_content_id_replaced( 'trees:chest_chestnut',   replacements );
	cid.c_chest_pine       = handle_schematics.get_content_id_replaced( 'trees:chest_pine',       replacements );
	cid.c_chest_spruce     = handle_schematics.get_content_id_replaced( 'trees:chest_spruce',     replacements );
	cid.c_sign             = handle_schematics.get_content_id_replaced( 'default:sign_wall',      replacements );
--print('REPLACEMENTS: '..minetest.serialize( replacements.table )..' CHEST: '..tostring( minetest.get_name_from_content_id( cid.c_chest ))); -- TODO
	--print("Chest CID" ..tostring(cid.c_chest))
	local extranodes = {}
	local extra_calls = { on_constr = {}, trees = {}, chests = {}, signs = {}, traders = {} };

	for i, pos in ipairs(bpos) do
		-- roads are only placed if there are at least mg_villages.MINIMAL_BUILDUNGS_FOR_ROAD_PLACEMENT buildings in the village
		if( not(pos.btype) or pos.btype ~= 'road' or village.anz_buildings > mg_villages.MINIMAL_BUILDUNGS_FOR_ROAD_PLACEMENT )then 
			-- replacements are in table format for mapgen-based building spawning
			local road_material = mg_villages.road_node;
			if( pos.road_material ) then
				road_material = pos.road_material;
			end
			generate_building(pos, minp, maxp, data, param2_data, a, extranodes, replacements, cid, extra_calls, i, village_id, nil, road_material, true )
		end
	end

	-- replacements are in list format for minetest.place_schematic(..) type spawning
	return { extranodes = extranodes, bpos = bpos, replacements = replacements.list, dirt_roads = village.to_add_data.dirt_roads,
			plantlist = village.to_add_data.plantlist, extra_calls = extra_calls };
end



-- place a schematic manually
--
-- pos needs to contain information about how to place the building:
-- 	pos.x, pos.y, pos.z	where the building is to be placed
-- 	pos.btype		determines which building will be placed; if not set, binfo_extra needs to be provided
-- 	pos.brotate		contains a value of 0-3, which determines the rotation of the building
--	pos.bsizex		size of the building in x direction
--	pos.bsizez		size of the building in z direction
--	pos.mirror		if set, the building will be mirrored
-- 	pos.no_plotmarker	optional; needs to be set in order to avoid the generation of a plotmarker
-- 	building_nr		optional; used for plotmarker
-- 	village_id		optional; used for plotmarker
-- 	pos.fruit		optional; determines the fruit a farm is going to grow (if binfo.farming_plus is set)

-- binfo contains general information about a building:
-- 	binfo.sizex		size of the building in x direction
-- 	binfo.sizez
-- 	binfo.ysize
-- 	binfo.yoff		how deep is the building burried?
-- 	binfo.nodenames		list of the node names beeing used by the building
-- 	binfo.scm		name of the file containing the schematic; only needed for an error message
-- 	binfo.scm_data_cache	contains actual information about the nodes beeing used (the data)
-- 	binfo.is_mts		optional; if set to 1, the function will abort
-- 	binfo.farming_plus	optional; if set, pos.fruit needs to be set as well
-- 	binfo.axis		optional; relevant for some mirroring operations
-- 
-- replacement_list		contains replacements in the same list format as place_schematic uses
--
handle_schematics.place_building_using_voxelmanip = function( pos, binfo, replacement_list)

	if( not( replacement_list ) or type( replacement_list ) ~= 'table' ) then
		return;
	end

	-- if not defined, the building needs to start at pos.x,pos.y,pos.z - without offset
	if( not( binfo.yoff )) then
		binfo.yoff = 0;
	end

-- TODO: calculate the end position from the given data
	-- get a suitable voxelmanip object
	-- (taken from minetest_game/mods/default/trees.lua)
	local vm = minetest.get_voxel_manip()
	local minp, maxp = vm:read_from_map(
		{x = pos.x, y = pos.y, z = pos.z},
		{x = pos.x+pos.bsizex, y = pos.y+binfo.ysize, z = pos.z+pos.bsizez} -- TODO
        )
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data        = vm:get_data()
	local param2_data = vm:get_param2_data();


	-- translate the replacement_list into replacements.ids and replacements.table format
	-- the first two parameters are nil because we do not want a new replacement list to be generated
	local replacements = handle_schematics.get_replacement_table( nil, nil, replacement_list );

	-- only very few nodes are actually used from the cid table (content ids)
	local cid = {};
	cid.c_air              = minetest.get_content_id( 'air' );
	cid.c_dirt             = handle_schematics.get_content_id_replaced( 'default:dirt',           replacements );
	cid.c_dirt_with_grass  = handle_schematics.get_content_id_replaced( 'default:dirt_with_grass',replacements );
	cid.c_sapling          = handle_schematics.get_content_id_replaced( 'default:sapling',        replacements );
	cid.c_jsapling         = handle_schematics.get_content_id_replaced( 'default:junglesapling',  replacements );
	cid.c_psapling         = handle_schematics.get_content_id_replaced( 'default:pine_sapling',   replacements );
	cid.c_savannasapling   = handle_schematics.get_content_id_replaced( 'mg:savannasapling',      replacements );
	cid.c_pinesapling      = handle_schematics.get_content_id_replaced( 'mg:pinesapling',         replacements );
	cid.c_plotmarker       = handle_schematics.get_content_id_replaced( 'mg_villages:plotmarker', replacements );

	cid.c_chest            = handle_schematics.get_content_id_replaced( 'default:chest',          replacements );
	cid.c_chest_locked     = handle_schematics.get_content_id_replaced( 'default:chest_locked',   replacements );
	cid.c_chest_shelf      = handle_schematics.get_content_id_replaced( 'cottages:shelf',         replacements );
	cid.c_chest_ash        = handle_schematics.get_content_id_replaced( 'trees:chest_ash',        replacements );
	cid.c_chest_aspen      = handle_schematics.get_content_id_replaced( 'trees:chest_aspen',      replacements );
	cid.c_chest_birch      = handle_schematics.get_content_id_replaced( 'trees:chest_birch',      replacements );
	cid.c_chest_maple      = handle_schematics.get_content_id_replaced( 'trees:chest_maple',      replacements );
	cid.c_chest_chestnut   = handle_schematics.get_content_id_replaced( 'trees:chest_chestnut',   replacements );
	cid.c_chest_pine       = handle_schematics.get_content_id_replaced( 'trees:chest_pine',       replacements );
	cid.c_chest_spruce     = handle_schematics.get_content_id_replaced( 'trees:chest_spruce',     replacements );
	cid.c_sign             = handle_schematics.get_content_id_replaced( 'default:sign_wall',      replacements );

	-- for roads
	cid.c_sign             = handle_schematics.get_content_id_replaced( 'default:gravel',         replacements );

	local extranodes = {}
	local extra_calls = { on_constr = {}, trees = {}, chests = {}, signs = {}, traders = {} };

	-- last parameter false -> place dirt nodes instead of trying to keep the ground nodes
	generate_building(pos, minp, maxp, data, param2_data, a, extranodes, replacements, cid, extra_calls, pos.building_nr, pos.village_id, binfo, cid.c_gravel, false);

	-- store the changed map data
	vm:set_data(data);
	vm:set_param2_data(param2_data);
	vm:write_to_map();
	vm:update_liquids();
	vm:update_map();

-- TODO: do the calls for the extranodes as well
	-- replacements are in list format for minetest.place_schematic(..) type spawning
	return { extranodes = extranodes, replacements = replacements.list, extra_calls = extra_calls };
end



-- places a building read from file "building_name" on the map between start_pos and end_pos using luavoxelmanip
-- returns error message on failure and nil on success
handle_schematics.place_building_from_file = function( start_pos, end_pos, building_name, replacement_list, rotate, axis, mirror, no_plotmarker )
	if( not( building_name )) then
		return "No file name given. Cannot find the schematic.";
	end

	local binfo = handle_schematics.analyze_file( building_name, nil, nil );
	if( not( binfo )) then
		return "Failed to import schematic. Only .mts and .we are supported!";
	end

	-- nodenames and scm_data_cache can be used directly;
	-- the size dimensions need to be renamed
	binfo.sizex = binfo.size.x;
	binfo.sizez = binfo.size.z;
	binfo.ysize = binfo.size.y;

	-- this value has already been taken care of when determining start_pos
	binfo.yoff  = 0;
	-- file name of the scm; only used for error messages
	binfo.scm   = building_name;
	-- this is relevant for mirroring operations
	binfo.axis  = axis;


	if( not( rotate ) or rotate=="0" ) then
		start_pos.brotate = 0;
	elseif( rotate=="90" ) then
		start_pos.brotate = 1;
	elseif( rotate=="180" ) then
		start_pos.brotate = 2;
	elseif( rotate=="270" ) then
		start_pos.brotate = 3;
	end

	if( start_pos.brotate > 3 ) then
		start_pos.brotate = start_pos.brotate % 4;
	end


	-- determine the size of the bulding from the place we assigned to it...
	start_pos.bsizex  = math.abs(end_pos.x - start_pos.x)+1;
	start_pos.bsizez  = math.abs(end_pos.z - start_pos.z)+1;

	-- otpional; if set, the building will be mirrored
	start_pos.mirror = mirror;
	-- do not generate a plot marker as this is not part of a village;
	-- otherwise, building_nr and village_id would have to be provided
	start_pos.no_plotmarker = no_plotmarker;

	-- all those calls to on_construct need to be done now
	local res = handle_schematics.place_building_using_voxelmanip( start_pos, binfo, replacement_list);
	if( not(res) or not( res.extra_calls )) then
		return;
	end

	-- call on_construct where needed;
	-- trees, chests and signs receive no special treatment here
	for k, v in pairs( res.extra_calls.on_constr ) do
		local node_name = minetest.get_name_from_content_id( k );
		if( minetest.registered_nodes[ node_name ].on_construct ) then
			for _, pos in ipairs(v) do
				minetest.registered_nodes[ node_name ].on_construct( pos );
			end
		end
	end

	if( binfo.metadata ) then
		-- if it is a .we/.wem file, metadata was included directly
		handle_schematics.restore_meta( nil, binfo.metadata, start_pos, end_pos, start_pos.brotate, mirror);
	else
		-- .mts files come with extra .meta file (if such a .meta file was created)
		-- TODO: restore metadata for .mts files
		--handle_schematics.restore_meta( filename, nil, binfo.metadata, start_pos, end_pos, start_pos.brotate, mirror);
	end
end



-- add the dirt roads
handle_schematics.place_dirt_roads = function(village, minp, maxp, data, param2_data, a, c_road_node)
	local c_air = minetest.get_content_id( 'air' );
	for _, pos in ipairs(village.to_add_data.dirt_roads) do
		handle_schematics.place_road( minp, maxp, data, param2_data, a, c_road_node, pos, c_air );
	end
end

handle_schematics.place_road = function(minp, maxp, data, param2_data, a, c_road_node, pos, c_air )
	local param2 = 0;
	if( pos.bsizex > 2 and pos.bsizex > pos.bsizez) then
		param2 = 1;
	end

--[[
	local is_main_road  = false;
	local c_road_node   = minetest.get_content_id('default:coalblock');
	local c_middle_wool = minetest.get_content_id('default:clay');
	local slab_stone    = minetest.get_content_id('stairs:slab_stone');
	if( pos.bsizex > 2 and pos.bsizez > 2 ) then
		is_main_road = true;
	end
--]]

	if( not(pos.y >= minp.y and pos.y <= maxp.y-2)) then
		return;
	end
	for x = math.max( pos.x, minp.x ), math.min( pos.x+pos.bsizex-1, maxp.x ) do
		for z = math.max( pos.z, minp.z ), math.min( pos.z+pos.bsizez-1, maxp.z ) do
			-- roads have a height of 1 block
			data[        a:index( x, pos.y, z)] = c_road_node;
			param2_data[ a:index( x, pos.y, z)] = param2;
			-- ...with air above
			data[ a:index( x, pos.y+1, z)] = c_air;
			data[ a:index( x, pos.y+2, z)] = c_air;

--[[
			if(    (param2==0 and (x==pos.x or x==pos.x+8) and is_main_road)
			    or (param2==1 and (z==pos.z or z==pos.z+8) and is_main_road)) then
				data[ a:index( x, pos.y+1, z )] = slab_stone; 
			elseif((param2==0 and (x==pos.x+4 ) and is_main_road)
			    or (param2==1 and (z==pos.z+4 ) and is_main_road)) then
				data[ a:index( x, pos.y,   z )] = c_middle_wool;
			end
--]]
		end
	end
end


if( minetest.get_modpath('moresnow' )) then
	handle_schematics.moresnow_installed = true;
end
