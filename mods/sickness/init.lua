local prev_physics = {}
local food_poisoning = {
	affectid = "food_poisoning",
	name = "Food Poisoning",
	stages = {
				{
					-- delay from eating the bad food until sickness starts
					time = 320,
				},
				{
					time = 120,
					physics = { speed = -0.5 },
					custom = { chance=100, func = function(name, player, affectid)
						minetest.chat_send_player(name,"You don't feel so good")
					end,runonce=true}
				},
				{
					time = 240,
					--physics = { speed = -0.5 },
					custom = { chance=70, func = function(name, player, affectid)
						minetest.log("action",name.." pukes")
						puke_physics(player)
						minetest.sound_play("sickness_puke",{object=player})
						if hud.hunger[name] ~= nil then
						  if hud.hunger[name] > 4 then
							  hud.hunger[name] = 4
							  hud.set_hunger(player)
						  end
						  if player_stamina[name] > 6 then
							  player_stamina[name] = 6
						  end
						  minetest.after(5,puke_reset,player)
						end
					end
					},
				},
				{
					time = 240,
					physics = { speed = 0.1 },
					custom = { chance=30, func = function(name, player, affectid)
						minetest.log("action",name.." pukes")
						puke_physics(player)
						minetest.sound_play("sickness_puke",{object=player})
						if hud.hunger[name] ~= nil then
						  if hud.hunger[name] > 4 then
							  hud.hunger[name] = 4
							  hud.set_hunger(player)
						  end
						  if player_stamina[name] > 10 then
							  player_stamina[name] = 10
						  end	
						  minetest.after(5,puke_reset,player)
						end
					end
					},
				},
				{
					time = 240,
					physics = { speed = 0.2 },
					custom = { chance=20, func = function(name, player, affectid)
						minetest.log("action",name.." pukes")
						puke_physics(player)
						minetest.sound_play("sickness_puke",{object=player})
						if hud.hunger[name] ~= nil then
						  if hud.hunger[name] > 4 then
							  hud.hunger[name] = 4
							  hud.set_hunger(player)
						  end
						  if player_stamina[name] > 16 then
							  player_stamina[name] = 16
						  end	
						  minetest.after(5,puke_reset,player)
						end
					end
					},
				}
			},
	onremove = function(name, player, affectid)
		physics.adjust_physics(player,{speed=0.2})
		minetest.chat_send_player(name,"You are feeling much better",false)
	end

}

function puke_physics(player)
	local name = player:get_player_name()
	prev_physics[name] = physics.get_player_physics(name)
	player:set_physics_override({speed=0.01, jump=0})
end

function puke_reset(player)
	local name = player:get_player_name()
	if prev_physics[name] ~= nil then
		player:set_physics_override(prev_physics[name])
		prev_physics[name] = nil
	end
end

affects.registerAffect(food_poisoning)