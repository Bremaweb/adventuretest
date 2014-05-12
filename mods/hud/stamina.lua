local stamina_file = minetest.get_worldpath().."/stamina"

player_stamina = default.deserialize_from_file(stamina_file)
player_lastpos = {}
player_sleephuds = {}

function hud.update_stamina(p,name)
	-- loop through all online players and check their movement and update their stamina
		local pos = p:getpos()
		if player_lastpos[name] ~= nil then
			if player_stamina[name] ~= nil then
				local anim = default.player_get_animation(p)
				local adj = 0.25
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
				
				-- adjust their stamina
				local vdiff = pos.y - player_lastpos[name].y
				if vdiff > 0 then
					adj = adj - ( vdiff * 0.06 )
				end
				
				local hdiff = math.sqrt(math.pow(pos.x-player_lastpos[name].x, 2) + math.pow(pos.z-player_lastpos[name].z, 2))
				adj = adj - ( hdiff * 0.03 )
				
				player_stamina[name] = player_stamina[name] + adj
				
				if player_stamina[name] < 0 then
					player_stamina[name] = 0
					p:set_hp(p:get_hp()-1)
				end
				
				if player_stamina[name] > 20 then
					player_stamina[name] = 20
				end
				if player_stamina[name] < 3 then
					affects.affectPlayer(name,"tired")
				end
			else
				player_stamina[name] = 20
			end
		end
		player_lastpos[name] = pos 
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
	end,
})

minetest.register_chatcommand("sleep",{
	func = function( name, param )
		local player = minetest.get_player_by_name(name)
		default.player_set_animation(player, "lay")
		player:set_eye_offset({x=0,y=-10,z=0},{x=0,y=0,z=0})
		player_sleephuds[name] = player:hud_add({
			hud_elem_type = "image",
			text = "hud_blackout.png",
			position = {x=1,y=1},		
			name="sleep",
			scale = {x=-100, y=-100},
			alignment = {x=-1,y=-1},
			offset = {x=0,y=0},
		})
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
	end,
})

minetest.register_on_respawnplayer(function (player)
	local name = player:get_player_name()
	player_stamina[name] = 20
	player_lastpos[name] = player:getpos()
end)

minetest.register_on_joinplayer(function (player)
	local name = player:get_player_name()
	if player_stamina[name] == nil then
		player_stamina[name] = 20
		player_lastpos[name] = player:getpos()
	end
end)

minetest.register_on_shutdown(function()
	default.serialize_to_file(stamina_file,player_stamina)
end)
