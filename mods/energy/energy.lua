local energy_file = minetest.get_worldpath().."/energy"
local stamina_file = minetest.get_worldpath().."/stamina"

player_energy = default.deserialize_from_file(energy_file)
player_stamina = default.deserialize_from_file(stamina_file)
player_lastpos = {}
player_sleephuds = {}

player_can_boost_stamina = {}

function energy.update_energy(p,name)
	-- loop through all online players and check their movement and update their energy
		local pos = p:getpos()
		if player_lastpos[name] ~= nil and skills.player_levels[name] ~= nil then
			if player_energy[name] ~= nil then
				if minetest.check_player_privs(name, {immortal=true}) then
					player_energy[name] = 20
					return
				end
				
				local anim = default.player_get_animation(p)
				local adj = 0.2
				if anim.animation == "lay" then
					adj = adj + 1.15
					if math.random(0,4) == 1 then
						minetest.sound_play("default_snore",{object=p})
					end
					p:set_hp(p:get_hp()+2)
				end
				if anim.animation == "sit" then
					adj = adj + 0.5
					p:set_hp(p:get_hp()+1)
				end
				
				-- adjust their energy
				local vdiff = pos.y - player_lastpos[name].y
				if vdiff > 0 then
					adj = adj - ( vdiff * 0.2 )
				end
				
				local hdiff = math.sqrt(math.pow(pos.x-player_lastpos[name].x, 2) + math.pow(pos.z-player_lastpos[name].z, 2))
				
				stats.increment(name,STAT_TRAVEL,math.floor(hdiff))
				
				adj = adj - ( hdiff * 0.03 )
				--print("Energy Adjustments")
				--print(tostring(adj))
				--print("After stamina adjustment")
				adj = adj + player_stamina[name]
				--print(tostring(adj))
				
				player_energy[name] = player_energy[name] + adj
				if player_energy[name] < 0 then
					player_energy[name] = 0
					p:set_hp(p:get_hp()-1)
				end
				
				if player_energy[name] >= 20 then
					player_energy[name] = 20
					if anim.animation == "lay" then
						-- wake them up
						default.player_set_animation(p, "stand")
						p:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
						if player_sleephuds[name] ~= nil then
							p:hud_remove(player_sleephuds[name])
							player_sleephuds[name] = nil
						end
						minetest.chat_send_player(name,"You feel fully energized!")
						physics.unfreeze_player(name)
					end
				end
				if player_energy[name] < 8 and player_can_boost_stamina[name] == true then
				  player_can_boost_stamina[name] = false
				  if player_stamina[name] < 0.65 then
				    player_stamina[name] = player_stamina[name] + 0.003
				    --print("Boosted player stamina "..tostring(player_stamina[name]))
				    default.serialize_to_file(stamina_file,player_stamina)
				  end
				end
				if player_energy[name] < 2 then
					affects.affectPlayer(name,"tired")
				end
				if player_energy[name] > 8 then
				  player_can_boost_stamina[name] = true
				end
			else
				player_energy[name] = 20
			end
		end
		player_lastpos[name] = pos
		hud.change_item(p,"energy",{number = player_energy[name]})
end

local affect_tired = {
	affectid = "tired",
	name = "Exhaustion",
	stages = {
				{ 
					time = 120,
					physics = { speed = -0.2 },
					custom = { chance=100, func = function(name, player, affectid)
						minetest.chat_send_player(name,"You are exhausted")
					end,runonce=true},
				},
			},
	onremove = function(name, player, affectid)
		physics.adjust_physics(player,{speed=0.2})
		minetest.chat_send_player(name,"You don't feel as tired anymore",false)
	end,
	removeOnDeath = true,
}

affects.registerAffect(affect_tired)

minetest.register_chatcommand("sit",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "sit")
		player:set_eye_offset({x=0,y=-5,z=0},{x=0,y=0,z=0})
		if player_sleephuds[name] ~= nil then
			player:hud_remove(player_sleephuds[name])
			player_sleephuds[name] = nil
		end
		physics.freeze_player(name)
	end,
})

minetest.register_chatcommand("sleep",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "lay")
		player:set_eye_offset({x=0,y=-10,z=0},{x=0,y=0,z=0})
		player_sleephuds[name] = player:hud_add({
			hud_elem_type = "image",
			text = "energy_blackout.png",
			position = {x=1,y=1},		
			name="sleep",
			scale = {x=-100, y=-100},
			alignment = {x=-1,y=-1},
			offset = {x=0,y=0},
		})
		physics.freeze_player(name)
	end,
})

minetest.register_chatcommand("stand",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "stand")
		player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
		if player_sleephuds[name] ~= nil then
			player:hud_remove(player_sleephuds[name])
			player_sleephuds[name] = nil
			
		end
		physics.unfreeze_player(name)
	end,
})

function energy.respawnplayer(player)
	local name = player:get_player_name()
	player_energy[name] = 20
	player_lastpos[name] = player:getpos()
	energy.update_energy(player,name)
	--affects.removeAffect(name,"tired")
end

minetest.register_on_joinplayer(function (player)
	local name = player:get_player_name()
	if player_energy[name] == nil then
		player_energy[name] = 20
		player_lastpos[name] = player:getpos()
	end
	if player_stamina[name] == nil then
	 player_stamina[name] = 0
	end
	if player_energy[name] > 8 then
	 player_can_boost_stamina[name] = true
	else
	 player_can_boost_stamina[name] = false
	end
end)

minetest.register_on_shutdown(function()
	default.serialize_to_file(energy_file,player_energy)
	default.serialize_to_file(stamina_file,player_stamina)
end)

local energy_timer = 0
local energy_tick = 5

function energy_globalstep(dtime)
	energy_timer = energy_timer + dtime
	if energy_timer >= energy_tick then
		for _,player in ipairs(minetest.get_connected_players()) do
			energy.update_energy(player,player:get_player_name())
		end
		energy_timer = 0
	end
end
