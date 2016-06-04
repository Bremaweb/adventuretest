function energy.update_energy(p,name,dtime)
	-- loop through all online players and check their movement and update their energy
		local pos = p:getpos()
		local lastpos = pd.get(name,"lastpos")
		local p_stamina = pd.get_number(name,"stamina")
		local sleep_hud = pd.get(name,"sleep_hud")
		if lastpos ~= nil then
				if minetest.check_player_privs(name, {immortal=true}) then
					pd.set(name,"energy",20)
					return
				end
				
				local anim = default.player_get_animation(p)
				local adj = 0.2
				if anim.animation == "lay" then
					adj = adj + 1.15
					if math.random(0,4) == 1 then
						minetest.sound_play("default_snore",{object=p})
					end
					if p:get_hp() < pd.get_number(name,"max_hp") then
						p:set_hp(p:get_hp()+2)
					end
				end
				if anim.animation == "sit" then
					adj = adj + 0.5
					if p:get_hp() < pd.get_number(name,"max_hp") then
						p:set_hp(p:get_hp()+1)
					end
				end
				
					-- adjust their energy
					local vdiff = pos.y - lastpos.y
					if vdiff > 0 then
						adj = adj - ( vdiff * 0.2 )
					end
					
					local hdiff = math.sqrt(math.pow(pos.x-lastpos.x, 2) + math.pow(pos.z-lastpos.z, 2))
					
					pd.increment(name,STAT_TRAVEL,math.floor(hdiff))
					
					adj = adj - ( hdiff * 0.03 )
					
				if default.player_attached_to[name] == "boats:boat" and adj < 0 then
					adj = adj * 0.75
				end
				--print("hdiff "..tostring(hdiff))
				--print("Energy Adjustments")
				--print(tostring(adj))
				--print("After stamina adjustment")
				adj = adj + p_stamina
				--print(tostring(adj))
				
				pd.increment(name,"energy",adj)
				local p_energy = pd.get_number(name,"energy")
				--print("Energy "..tostring(p_energy))
				if p_energy < 0 then
					p_energy = 0
					p:set_hp(p:get_hp()-1)
				end
				
				if p_energy >= 20 then
					p_energy = 20
					if anim.animation == "lay" then
						-- wake them up
						default.player_set_animation(p, "stand")
						p:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
						if sleep_hud ~= nil then
							p:hud_remove(sleep_hud)
							sleep_hud = nil
						end
						cmsg.push_message_player(p,"You feel fully energized!")
						physics.unfreeze_player(name)
					end
					pd.set(name,"energy",p_energy)
				end
				if p_energy < 8 and pd.get(name,"can_boost_stamina") == true then
				  pd.set(name,"can_boost_stamina",false)
				  if p_stamina < 0.65 then
				    p_stamina = p_stamina + 0.003
				  end
				end
				if p_energy < 2 then
					affects.affectPlayer(name,"tired")
				end
				if p_energy > 8 then
				  pd.set(name,"can_boost_stamina",true)
				end
			pd.set(name,"stamina",p_stamina)
		end
		pd.set(name,"lastpos",pos)
		hud.change_item(p,"energy",{number = pd.get(name,"energy")})
end

local affect_tired = {
	affectid = "tired",
	name = "Exhaustion",
	stages = {
				{ 
					time = 120,
					physics = { speed = -0.2 },
					custom = { chance=100, func = function(name, player, affectid)
						cmsg.push_message_player(player,"You are exhausted")
					end,runonce=true},
				},
			},
	onremove = function(name, player, affectid)
		physics.adjust_physics(player,{speed=0.2})
		cmsg.push_message_player(player,"You don't feel as tired anymore")
	end,
	removeOnDeath = true,
}

affects.registerAffect(affect_tired)

minetest.register_chatcommand("sit",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "sit")
		player:set_eye_offset({x=0,y=-5,z=0},{x=0,y=0,z=0})
		local sleep_hud = pd.get(name,"sleep_hud")
		if sleep_hud ~= nil then
			player:hud_remove(sleep_hud)
			pd.unset(name,"sleep_hud")
		end
		physics.freeze_player(name)
	end,
})

minetest.register_chatcommand("sleep",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "lay")
		player:set_eye_offset({x=0,y=-10,z=0},{x=0,y=0,z=0})
		local sleep_hud = player:hud_add({
			hud_elem_type = "image",
			text = "energy_blackout.png",
			position = {x=1,y=1},		
			name="sleep",
			scale = {x=-100, y=-100},
			alignment = {x=-1,y=-1},
			offset = {x=0,y=0},
		})
		physics.freeze_player(name)
		pd.set(name,"sleep_hud",sleep_hud)
	end,
})

minetest.register_chatcommand("stand",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "stand")
		player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
		local sleep_hud = pd.get(name,"sleep_hud")
		if sleep_hud ~= nil then
			player:hud_remove(sleep_hud)
			pd.unset(name,"sleep_hud")
		end
		physics.unfreeze_player(name)
	end,
})

function energy.respawnplayer(player)
	local name = player:get_player_name()
	pd.set(name,"energy",20)
	pd.set(name,"lastpos",player:getpos())	
	energy.update_energy(player,name)	
end
