 
local antig = {
				affectid="antig",
				name="Anti Gravity",
				stages={
							{
								time=60,
								physics = { gravity = .3 }
							},
							{	
								time=60,
								physics = { gravity = .5 }
							},
							{
								time=60,
								physics = { gravity = .9 }
							}
				},
				onremove = function(name, player, affectid)
					cmsg.push_message_player(player,"You no longer have anti gravity!")
				end
}

affects.registerAffect(antig)

local combust = {
				affectid="combust",
				name="Spontaneous Combustion",
				stages={
							{
								time=300,
								emote = { chance=40, action = "thinks it's getting hot in here" },
								place = { chance=70, node = "fire:basic_flame" }
							}
				}
}

affects.registerAffect(combust)

local fly = {
			affectid = "fly",
			name="Temporary Fly",
			stages = {
						{
							time=45,
							custom = { chance=100, func = function(name, player, affectid)
								local pPrivs = minetest.get_player_privs(name)									
								pPrivs["fly"] = true
								minetest.set_player_privs(name,pPrivs)
							end, runonce=true }
						}						
			},
			onremove = function(name, player, affectid)
				local pPrivs = minetest.get_player_privs(name)					
				pPrivs["fly"] = nil
				minetest.set_player_privs(name,pPrivs)
				cmsg.push_message_player(player,"You can no longer fly!")
			end
}

affects.registerAffect(fly)