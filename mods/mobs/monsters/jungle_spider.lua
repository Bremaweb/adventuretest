mobs:register_mob("mobs:jungle_spider",{
	type = "monster",
	hp_min = 15,
	hp_max = 40,
	exp_min = 3,
	exp_max = 20,
	collisionbox = {-0.5, 0, -0.5, 0.4, 0.4, 0.4},
	textures = {"mobs_jungle_spider.png"},
	visual_size = {x=3,y=3},
	visual = "mesh",
	mesh = "mobs_spider.x",
	makes_footstep_sound = false,
	view_range = 15,
	walk_velocity = 1.3,
	run_velocity = 4.2,
    armor = 200,
	damage = 1,
	drops = {
		{name = "farming:string",
		chance = 40,
		min = 3,
		max = 6,},
		
		{name = "mobs:jungle_spider_fang",
		chance = 70,
		min = 1,
		max = 2,
		},
	},
    light_resistant = false,
	drawtype = "front",
	water_damage = 5,
	lava_damage = 5,
	light_damage = 0,
	on_rightclick = nil,
	attack_type = "dogfight",
	animation = {
		speed_normal = 15,
		speed_run = 18,
		stand_start = 1,
		stand_end = 1,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
		punch_start = 50,
		punch_end = 90,
	},
	jump = true,
	sounds = {attack = "mobs_slash_attack",},
	step = 1,
	blood_amount = 14,
	blood_offset = 0.1,
	avoid_nodes = {"default:water_source","default:water_flowing","campfire:campfire_burning","fire:basic_flame","fire:permanent_flame"},
	avoid_range = 15,
	attack_function = function(self, target)
		self.attack.player:punch(self.object, 1.0,  {
			full_punch_interval=1.0,
			damage_groups = {fleshy=self.damage}
		})
		if randomChance(40) then
			-- poison the player
			affects.affectPlayer(target:get_player_name(),"spider_poison")
		end
	end
})

local spider_poison = {
	affectid = "spider_poison",
	name = "Jungle Spider Poison",
	stages = {
				{
					-- delay from being poisoned until it starts hurting
					time = 900,
				},
				{
					time = 120,
					--physics = { speed = -0.25 },
					custom = { chance=40, func = function(name, player, affectid)
						local y = player:get_look_yaw()
						local ny = y;
						if randomChance(50) then
							ny = ny * -0.15
						else
							ny = ny * 0.15
						end
						player:set_look_yaw(ny)
						minetest.chat_send_player(name,"You feel a little dizzy")
					end}
				},
				{
					time = 480,
					--physics = { speed = -0.5 },
					custom = { chance=85, func = function(name, player, affectid)
						local y = player:get_look_yaw()
						local ny = y;
						if randomChance(50) then
							ny = ny * -0.3
						else
							ny = ny * 0.3
						end
						player:set_look_yaw(ny)
						local h = pd.get_number(name,"hunger_lvl")
						h = h - 2
						hunger.update_hunger(player,h)
						pd.increment(name,"energy",-2)
						minetest.chat_send_player(name,"You feel a very dizzy")
					end
					},
				},
				{
					time = 720,
					custom = { chance=95, func = function(name, player, affectid)
						local y = player:get_look_yaw()
						local ny = y;
						if randomChance(50) then
							ny = ny * -0.5
						else
							ny = ny * 0.5
						end
						player:set_look_yaw(ny)
						local h = pd.get_number(name,"hunger_lvl")
						h = h - 4
						hunger.update_hunger(player,h)
						pd.increment(name,"energy",-4)
						player:set_breath(-2)
						if randomChance(40) then
							pass_out(name,player)
						end
						minetest.chat_send_player(name,"You can hardly stand...")
					end
					},
				},
			},
	onremove = function(name, player, affectid)
		--physics.adjust_physics(player,{speed=0.25})
		minetest.chat_send_player(name,"You are feeling much better",false)
	end,
	removeOnDeath = true,
}

affects.registerAffect(spider_poison)

function pass_out(name)
	physics.freeze_player(name)
	minetest.after(25,come_to,name)
end

function come_to(name)
	physics.unfreeze_player(name)
end

minetest.register_craftitem("mobs:jungle_spider_fang",{
	description = "Jungle Spider Fang",
	stack_max = 99,
	liquids_pointable = false,
	inventory_image = "mobs_jungle_spider_fang.png",
})


mobs:register_spawn("mobs:jungle_spider", {"default:jungleleaves", "default:junglegrass"}, 22, -1, 5000, 4, 31000)
mobs:register_spawn("mobs:jungle_spider", {"default:jungleleaves", "default:junglegrass"}, 10, -1, 2000, 6, 31000)