mg_villages.new_village_spawned = function( village_id )
	-- determine whether it's a peaceful or barbarian village
	local vx = mg_villages.all_villages[ village_id ].vx
	local vz = mg_villages.all_villages[ village_id ].vz
	local seed = vx * vz
	local pr_vtype = PseudoRandom(seed)
	local rptype = pr_vtype:next(1,10)
	if mg_villages.anz_villages < 2 then
		mg_villages.all_villages[ village_id ].barbarians = false
	else
		if  rptype <= 3 then
			mg_villages.all_villages[ village_id ].barbarians = true
		else
			mg_villages.all_villages[ village_id ].barbarians = false
		end
	end
end

mg_villages.part_of_village_spawned = function( village, minp, maxp, data, param2_data, a, cid )
	--print("New building around "..minetest.pos_to_string(pos))
	for i,bpos in pairs(village.to_add_data.bpos) do
		-- get data about the building
		local building_data = mg_villages.BUILDINGS[ bpos.btype ];

		-- only handle buildings that are at least partly contained in that part of the
		-- village that got spawned in this mapchunk
		if not(  bpos.x > maxp.x or bpos.x + bpos.bsizex < minp.x or bpos.z > maxp.z or bpos.z + bpos.bsizez < minp.z ) then 
			 mobs.spawn_npc_and_spawner(bpos,village.barbarians)
		end
	end
end