local energy_file = minetest.get_worldpath().."/energy"

player_energy = default.deserialize_from_file(energy_file)
player_lastpos = {}
player_sleephuds = {}

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
				local adj = 0.2 + ( 0.2 * ( skills.player_levels[name].level / 5 ) )
				if anim.animation == "lay" then
					adj = adj + 0.75
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
					adj = adj - ( vdiff * 0.15 )
				end
				
				local hdiff = math.sqrt(math.pow(pos.x-player_lastpos[name].x, 2) + math.pow(pos.z-player_lastpos[name].z, 2))
				adj = adj - ( hdiff * 0.05 )
				
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
				if player_energy[name] < 3 then
					affects.affectPlayer(name,"tired")
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
					time = 360,
					physics = { speed = -0.6 },
					custom = { chance=100, func = function(name, player, affectid)
						minetest.chat_send_player(name,"You are exhuasted")
					end,runonce=true},
				},
			},
	onremove = function(name, player, affectid)
		physics.adjust_physics(player,{speed=0.6})
		minetest.chat_send_player(name,"You don't feel as tired anymore",false)
	end,
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
	affects.removeAffect(name,"tired")
end

minetest.register_on_joinplayer(function (player)
	local name = player:get_player_name()
	if player_energy[name] == nil then
		player_energy[name] = 20
		player_lastpos[name] = player:getpos()
	end
end)

minetest.register_on_shutdown(function()
	default.serialize_to_file(energy_file,player_energy)
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
