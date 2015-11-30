minetest.set_gen_notify("dungeon,temple")

dungeon_chest = {}
table.insert(dungeon_chest, { "default:gold_ingot", 60, 25 })
table.insert(dungeon_chest, { "default:steel_ingot", 68, 35 })
table.insert(dungeon_chest, { "default:mese_crystal", 40, 10})
table.insert(dungeon_chest, { "default:sword_steel", 80, 1 })
table.insert(dungeon_chest, { "default:sword_mese", 20, 1 })
table.insert(dungeon_chest, { "default:sword_diamond", 5, 1 })
table.insert(dungeon_chest, { "default:diamond", 10, 5 })
table.insert(dungeon_chest, { "default:torch", 95, 25 })
table.insert(dungeon_chest, { "default:mese", 15, 4 })
table.insert(dungeon_chest, { "default:diamondblock",10, 4 })
table.insert(dungeon_chest, { "potions:fly3", 50, 1})
table.insert(dungeon_chest, { "potions:bones", 70, 5})
table.insert(dungeon_chest, { "potions:magid_replenish3", 60, 10})
table.insert(dungeon_chest, { "potions:antidote", 80, 10})
table.insert(dungeon_chest, { "farming:bread", 80, 15})
table.insert(dungeon_chest, { "mobs:meat", 80, 5})
table.insert(dungeon_chest, { "bushes:berry_pie_cooked", 90, 5})
table.insert(dungeon_chest, { "3d_armor:helmet_bronze", 70, 1})
table.insert(dungeon_chest, { "3d_armor:helmet_diamond", 20, 1})
table.insert(dungeon_chest, { "3d_armor:chestplate_bronze", 60,1})
table.insert(dungeon_chest, { "3d_armor:leggings_bronze", 65, 1})
table.insert(dungeon_chest, { "3d_armor:boots_bronze", 70, 1})
table.insert(dungeon_chest, { "3d_armor:helmet_mithril", 12, 1})
table.insert(dungeon_chest, { "3d_armor:chestplate_mithril", 12,1})
table.insert(dungeon_chest, { "3d_armor:leggings_mithril", 12, 1})
table.insert(dungeon_chest, { "3d_armor:boots_mithril", 12, 1})
table.insert(dungeon_chest, { "magic:wand_missle",25,1})

d_air = minetest.get_content_id("air")
d_glowblock = minetest.get_content_id("glowcrystals:glowcrystal_ore")

minetest.register_on_generated( function (minp, maxp, blockseed)
	
	
	local notify = minetest.get_mapgen_object("gennotify")	
	if notify ~= nil then
		if notify.dungeon ~= nil then
			minetest.log("action","Dungeon generated")
			local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
			local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
			local data = vm:get_data()
			local spawn = {}
			local chests = {}
			local c = 0
			for k,v in ipairs(notify.dungeon) do
				--print(minetest.pos_to_string(v))
				-- find the size of this room
				--if v.y < 0 then
					local center = {x=v.x,y=v.y,z=v.z}
					
					local ycheck = {x=center.x,y=center.y,z=center.z}
					local i = area:indexp(ycheck)
					c = 0
					while data[i] == d_air and c < 25 do
						ycheck.y = ycheck.y + 1
						i = area:indexp(ycheck)
						c = c + 1
					end
					ycheck.y = ycheck.y - 1
					local height = ( ycheck.y - center.y )
					
					local xcheck = {x=center.x,y=center.y,z=center.z}
					local i = area:indexp(xcheck)
					c = 0
					while data[i] == d_air and c < 25 do
						xcheck.x = xcheck.x + 1
						i = area:indexp(xcheck)
						c = c + 1
					end
					xcheck.x = xcheck.x - 1
										
					local zcheck = {x=center.x,y=center.y,z=center.z}
					local i = area:indexp(zcheck)
					c = 0
					while data[i] == d_air and c < 25 do
						zcheck.z = zcheck.z + 1
						i = area:indexp(zcheck)
						c = c + 1
					end
					zcheck.z = zcheck.z - 1
										
					local xsize = ( xcheck.x - center.x )
					local zsize = ( zcheck.z - center.z )
					
					if randomChance(75) then
						local gp = {x=zcheck.x,y=(zcheck.y+1),z=(zcheck.z+1)}
						if gp.y < emax.y and gp.y > emin.y and gp.x < emax.x and gp.x > emin.x and gp.z < emax.z and gp.z > emin.z then
							i = area:indexp(gp)
							if data[i] ~= d_air then
								data[i] = d_glowblock
							end
						end
						local gp = {x=(xcheck.x+1),y=(xcheck.y+1),z=xcheck.z}
						if gp.y < emax.y and gp.y > emin.y and gp.x < emax.x and gp.x > emin.x and gp.z < emax.z and gp.z > emin.z then
							i = area:indexp(gp)
							if data[i] ~= d_air then
								data[i] = d_glowblock
							end
						end
						local gp = {x=(center.x - (xsize+1)),y=(center.y+1),z=zcheck.z}
						if gp.y < emax.y and gp.y > emin.y and gp.x < emax.x and gp.x > emin.x and gp.z < emax.z and gp.z > emin.z then
							i = area:indexp(gp)
							if data[i] ~= d_air then
								data[i] = d_glowblock
							end
						end
						local gp = {x=center.x,y=(center.y+1),z=(zcheck.z - (zsize+1))}
						if gp.y < emax.y and gp.y > emin.y and gp.x < emax.x and gp.x > emin.x and gp.z < emax.z and gp.z > emin.z then
							i = area:indexp(gp)
							if data[i] ~= d_air then
								data[i] = d_glowblock
							end
						end
					end
					
					local size = xsize * zsize
					
					math.randomseed(os.clock())
					local fillratio = ( math.random(8,14) / 100 )
					local numgoblins = 2 + ( ((xsize * 2) * (zsize * 2)) * fillratio )
					
					for e=1,numgoblins do
						local x1 = (center.x-(xsize-1))
						local x2 = (center.x+(xsize-1))
						if x1 > x2 then break end
						local rx = math.random(x1,x2)
						
						local z1 = (center.z-(zsize-1))
						local z2 = (center.z+(zsize-1))
						if z1 > z2 then break end
						local rz = math.random(z1,z2)
						
						local s = {mob="mobs:goblin",pos={x=rx,z=rz,y=(center.y+1)}}
						table.insert(spawn,s)
					end
					
					if numgoblins > 4 then
						local king = { mob = "mobs:goblin_king", pos={x=center.x,y=(center.y+1),z=center.z} }
						table.insert(spawn,king)
					end
					
					if ( (xsize*2) * (zsize*2) ) > 68 and height > 2 then
						-- larger rooms add a chest full of stuff and a DM
						local i = area:indexp(center)
						table.insert(chests,center)
						local d = { mob = "mobs:dungeon_master", pos={x=center.x,y=(center.y+1),z=center.z} }
						table.insert(spawn,d)
					end
				--end
			end
			
			vm:set_data(data)			
			vm:calc_lighting(emin,emax)
			vm:write_to_map(data)
			for _,v in ipairs(spawn) do
				mobs:spawn_mob(v.pos,v.mob)
			end
			
			for _,cpos in ipairs(chests) do
				minetest.place_node(cpos,{name="default:chest"})
				local meta = minetest.get_meta( cpos );
				local inv  = meta:get_inventory();
				inv:add_item("main","quests:dungeon_token")
				for _,item in ipairs(dungeon_chest) do
					if randomChance(item[2]) then
						local qty = math.random(1,item[3])
						inv:add_item("main", item[1].." "..tostring(qty))
					end
				end
			end
		end
		
		if notify.temple ~= nil then
			--print("Temple generated")
			--for k,v in ipairs(notify.temple) do
--				print(minetest.pos_to_string(v))
	--		end
		end		
	end
end)

