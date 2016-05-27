local function get_kid(self,clicker)
		local name = clicker:get_player_name()
		self.object:set_attach(clicker,"",{x = 0, y = 5, z = -3}, {x = 0, y = 0, z = 0})
		self.random_freq = -1
		default.attached_to_player[name] = self
end

mobs:register_mob("mobs:kid_lost", {
	type = "npc_special",
	hp_min = 30,
	hp_max = 75,
	exp_min = 0,
	exp_max = 0,
	collisionbox = {-0.2,-0.70,-0.2, 0.2,0.6,0.2},
	visual = "mesh",
	mesh = "3d_armor_character.x",
	textures = {"mobs_kid_lost.png",	
				"3d_armor_trans.png",
				"3d_armor_trans.png",
			},
	visual_size = {x=0.70, y=0.70},
	makes_footstep_sound = true,
	view_range = 12,
	walk_velocity = 1.25,
	run_velocity = 3.75,
	damage = 0,
	drops = { },
	armor = 150,
	drawtype = "front",
	activity_level = 25,
	lava_damage = 5,
	light_damage = 0,
	walk_chance = -1,
	attack_type = "dogfight",
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219,
	},
	jump = false,
	sounds = {
		attack = "default_punch",
		random =  "mobs_lost_kid",
	},
	random_freq = 65,
	attacks_monsters=false,
	peaceful = true,
	step=4,
	blood_amount = 35,
	blood_offset = 0.25,
	rewards = {
		{chance=90, item="default:bread"},
		{chance=40, item="experience:6_exp"},
		{chance=60, item="potions:magic_replenish1"},
	},
	lifetimer = false,
	avoid_nodes = {"default:water_source","default:water_flowing","default:lava_source","default:lava_flowing"},
	avoid_range = 4,
	passive = false,
	stationary = true,
	on_rightclick = get_kid,
	on_punch = get_kid,
	on_step = function(self,dtime)
		self.timer = self.timer+dtime		
		if self.timer < self.step then
			return
		end
		self.timer = 0
		if self.sounds and self.sounds.random and self.state ~= "attack" then
			if randomChance(self.random_freq) then
				if ( self.type == "npc" and randomChance(65) ) or self.type ~= "npc" then
					local maxhear = 50
					local g = 1
					if self.type == "npc" then
						maxhear = 20
						g = 0.7
					end 			
					minetest.sound_play(self.sounds.random, {object = self.object, max_hear_distance=maxhear, gain=g})
				end
			end
		end
		
		math.randomseed(os.clock())
		if math.random(1, 100) < self.activity_level then
			if mobs.api_throttling(self) then return end
			-- if there is a player nearby look at them			
			local lp = nil
			local s = self.object:getpos()
			if self.type == "npc" then
				local o = minetest.get_objects_inside_radius(self.object:getpos(), 3)
				
				local yaw = 0
				for _,o in pairs(o) do
					if o:is_player() then
						lp = o:getpos()
						break
					end
				end
			end
			if lp ~= nil then
				mobs:face_pos(self,lp)
			else 
				local yaw = self.object:getyaw()+((math.random(0,360)-270)/180*math.pi)
				self.object:setyaw(yaw)
			end
		end
		self.set_velocity(self, 0)
		self.set_animation(self, "stand")		
	end,
})