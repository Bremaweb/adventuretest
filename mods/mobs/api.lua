mobs = {}
mobs.mob_list = { npc={}, barbarian={}, monster={}, animal={}}
function mobs:register_mob(name, def)
  table.insert(mobs.mob_list[def.type],name)
	minetest.register_entity(name, {
		name = name,
		hp_min = def.hp_min,
		hp_max = def.hp_max,
		physical = true,
		collisionbox = def.collisionbox,
		visual = def.visual,
		visual_size = def.visual_size,
		mesh = def.mesh,
		textures = def.textures,
		makes_footstep_sound = def.makes_footstep_sound,
		view_range = def.view_range,
		walk_velocity = def.walk_velocity or 0,
		run_velocity = def.run_velocity or 0,
		damage = def.damage,
		light_damage = def.light_damage,
		water_damage = def.water_damage or 1,
		lava_damage = def.lava_damage,
		disable_fall_damage = def.disable_fall_damage,
		drops = def.drops,
		armor = def.armor,
		drawtype = def.drawtype,
		on_rightclick = def.on_rightclick,
		type = def.type,
		attack_type = def.attack_type,
		attack_range = def.attack_range or 2,
		attack_function = def.attack_function or nil,
		arrow = def.arrow,
		arrow_offset = def.arrow_offset or 1,
		shoot_interval = def.shoot_interval,
		sounds = def.sounds,
		animation = def.animation,
		follow = def.follow,
		jump = def.jump,
		exp_min = def.exp_min or 0,
		exp_max = def.exp_max or 0,
		walk_chance = def.walk_chance or 50,
		attacks_monsters = def.attacks_monsters or false,
		group_attack = def.group_attack or false,
		step = def.step or 0,
		fov = def.fov or 165,
		passive = def.passive or false,
		recovery_time = def.recovery_time or 0.5,
		knock_back = def.knock_back or 3,
		blood_offset = def.blood_offset or 0,
		blood_amount = def.blood_amount or 15,
		blood_texture = def.blood_texture or "mobs_blood.png",
		rewards = def.rewards or nil,
		stationary = def.stationary or false,
		activity_level = def.activity_level or 10,
		
		stimer = 0,
		timer = 0,
		env_damage_timer = 0, -- only if state = "attack"
		attack = {player=nil, dist=nil},
		state = "stand",
		v_start = false,
		old_y = nil,
		lifetimer = 600,
		tamed = false,
		last_state = nil,
		pause_timer = 0,
		path = nil,
		path_pos = nil,
		last_dist = nil,
		leg_timer = nil,
		path_callback = nil,
		
		start_path = function(self,callback)
			-- start on the defined path
			self.physical = false	-- allow the mob to walk through other entities
			self.path_pos = 1
			self.state = "path"
			self.set_animation(self,"walk")
			mobs:face_pos(self,self.path[1])
			self.set_velocity(self,self.walk_velocity/2)
			self.last_dist = get_distance(self.object:getpos(),self.path[1])
			self.leg_timer = 0
			self.path_callback = callback
		end,
		
		check_path = function(self)
			local p = self.object:getpos()
			local pa = self.path[self.path_pos]
			local this_dist = get_distance(p,pa)
			if this_dist > self.last_dist or self.leg_timer > 1 then
				-- overshot the point so redirect the mob
				mobs:face_pos(self,self.path[self.path_pos])
				self.leg_timer = 0
			end
			self.last_dist = this_dist
			if math.abs(p.x - pa.x) < 1 and math.abs(p.z - pa.z) < 1 or ( self.path_pos == #self.path and this_dist < 1 ) then
				-- goto next position
				self.path_pos = self.path_pos + 1
				if self.path_pos <= #self.path then
					-- continue to next point
					mobs:face_pos(self,self.path[self.path_pos])
					self.set_velocity(self,self.walk_velocity)
					self.set_animation(self,"walk")
					self.leg_timer = 0
				else
					if self.path_callback ~= nil then
						-- do the arrival callback
						self.path_callback(self)
					end
					-- stop following path
					self.set_velocity(self,0)
					self.state = "stand"
					self.set_animation(self,"stand")
					self.path = nil
					self.path_pos = nil
					self.physical = true
					self.leg_timer = nil
				end
			end
		end,
		
		do_attack = function(self, player, dist)
			if self.state ~= "attack" then
				if self.sounds.war_cry then
					if math.random(0,100) < 90 then
						minetest.sound_play(self.sounds.war_cry,{ object = self.object })
					end
				end
				self.state = "attack"
				self.attack.player = player
				self.attack.dist = dist
			end
		end,
		
		set_velocity = function(self, v)
			local yaw = self.object:getyaw()
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			local x = math.sin(yaw) * -v
			local z = math.cos(yaw) * v
			self.object:setvelocity({x=x, y=self.object:getvelocity().y, z=z})
		end,
		
		get_velocity = function(self)
			local v = self.object:getvelocity()
			return (v.x^2 + v.z^2)^(0.5)
		end,
		
		in_fov = function(self,pos)
			-- checks if POS is in self's FOV
			return true
			--[[
			local yaw = (self.object:getyaw() * 180 / math.pi)
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			
			if yaw < 0 then
				yaw = 360 - yaw
			end
			
			if yaw > 360 then
				yaw = yaw - 360
			end
			
			print("Yaw: "..tostring(yaw))
			print("FOV: "..tostring(self.fov))
			local vx = math.sin(yaw)
			local vz = math.cos(yaw)
			local ds = math.sqrt(vx^2 + vz^2)
			local ps = math.sqrt(pos.x^2 + pos.z^2)
			local d = { x = vx / ds, z = vz / ds }
			local p = { x = pos.x / ps, z = pos.z / ps }
			
			print("DS "..tostring(ds))
			print("PS "..tostring(ps))
			print("D: x="..tostring(d.x)..", z="..tostring(d.z))
			print("P: x="..tostring(p.x)..", z="..tostring(p.z))
			
			local an = ( d.x * p.x ) + ( d.z * p.z )
			print("AN: "..tostring(an))
			local a = math.deg ( math.acos( an ) )
			print("A: "..tostring(a))
			if a > ( self.fov / 2 ) then
				return false
			else
				return true
			end
			]]
		end,
		
		set_animation = function(self, type)
			if not self.animation then
				return
			end
			if not self.animation.current then
				self.animation.current = ""
			end
			if type == "stand" and self.animation.current ~= "stand" then
				if
					self.animation.stand_start
					and self.animation.stand_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.stand_start,y=self.animation.stand_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "stand"
				end
			elseif type == "walk" and self.animation.current ~= "walk"  then
				if
					self.animation.walk_start
					and self.animation.walk_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.walk_start,y=self.animation.walk_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "walk"
				end
			elseif type == "run" and self.animation.current ~= "run"  then
				if
					self.animation.run_start
					and self.animation.run_end
					and self.animation.speed_run
				then
					self.object:set_animation(
						{x=self.animation.run_start,y=self.animation.run_end},
						self.animation.speed_run, 0
					)
					self.animation.current = "run"
				end
			elseif type == "punch" and self.animation.current ~= "punch"  then
				if
					self.animation.punch_start
					and self.animation.punch_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x=self.animation.punch_start,y=self.animation.punch_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "punch"
				end
			end
		end,
		
		on_step = function(self, dtime)
			
			if self.type == "monster" and minetest.setting_getbool("only_peaceful_mobs") then
				self.object:remove()
			end
			
			if self.lifetimer ~= false then
				self.lifetimer = self.lifetimer - dtime
				if self.lifetimer <= 0 and not self.tamed and self.type ~= "npc" then
					local player_count = 0
					for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:getpos(), 10)) do
						if obj:is_player() then
							player_count = player_count+1
						end
					end
					if player_count == 0 and self.state ~= "attack" then
						minetest.log("action","lifetimer expired, removed mob "..self.name)
						self.object:remove()
						return
					end
				end
			end
			if self.object:getvelocity().y > 0.1 then
				local yaw = self.object:getyaw()
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				local x = math.sin(yaw) * -2
				local z = math.cos(yaw) * 2
				self.object:setacceleration({x=x, y=-10, z=z})
			else
				self.object:setacceleration({x=0, y=-10, z=0})
			end
			
			if self.disable_fall_damage and self.object:getvelocity().y == 0 then
				if not self.old_y then
					self.old_y = self.object:getpos().y
				else
					local d = self.old_y - self.object:getpos().y
					if d > 5 then
						local damage = d-5
						self.object:set_hp(self.object:get_hp()-damage)
						if self.object:get_hp() == 0 then
							self.object:remove()
						end
					end
					self.old_y = self.object:getpos().y
				end
			end
			
			-- if pause state then this is where the loop ends
			-- pause is only set after a monster is hit
			if self.pause_timer > 0 then
				self.pause_timer = self.pause_timer - dtime
				if self.pause_timer <= 0 then
					self.pause_timer = 0
				end
				return
			end
			
			self.timer = self.timer+dtime
			if self.state ~= "attack" then
				if self.timer < 1 then
					return
				end
				self.timer = 0
			end
			
			if self.sounds and self.sounds.random and math.random(1, 100) <= 1 then
				minetest.sound_play(self.sounds.random, {object = self.object})
			end
			
			local do_env_damage = function(self)
				local pos = self.object:getpos()
				local n = minetest.get_node(pos)
				
				if self.light_damage and self.light_damage ~= 0
					and pos.y>0
					and minetest.get_node_light(pos)
					and minetest.get_node_light(pos) > 4
					and minetest.get_timeofday() > 0.2
					and minetest.get_timeofday() < 0.8
				then
					self.object:set_hp(self.object:get_hp()-self.light_damage)
					if self.object:get_hp() == 0 then
						self.object:remove()
					end
				end
				
				if self.water_damage and self.water_damage ~= 0 and
					minetest.get_item_group(n.name, "water") ~= 0
				then
					self.object:set_hp(self.object:get_hp()-self.water_damage)
					if self.object:get_hp() == 0 then
						self.object:remove()
					end
				end
				
				if self.lava_damage and self.lava_damage ~= 0 and
					minetest.get_item_group(n.name, "lava") ~= 0
				then
					self.object:set_hp(self.object:get_hp()-self.lava_damage)
					if self.object:get_hp() == 0 then
						self.object:remove()
					end
				end
			end
			
			self.env_damage_timer = self.env_damage_timer + dtime
			if self.state == "attack" and self.env_damage_timer > 1 then
				self.env_damage_timer = 0
				do_env_damage(self)
			elseif self.state ~= "attack" then
				do_env_damage(self)
			end
			
			-- FIND SOMEONE TO ATTACK
			if ( self.type == "monster" or self.type == "barbarian" ) and minetest.setting_getbool("enable_damage") and self.state ~= "attack" then
				local s = self.object:getpos()
				local inradius = minetest.get_objects_inside_radius(s,self.view_range)
				local player = nil
				local type = nil
				for _,oir in ipairs(inradius) do
					if oir:is_player() then
						player = oir
						type = "player"
					else
						local obj = oir:get_luaentity()
						if obj then
							player = obj.object
							type = obj.type
						end
					end
					
					if type == "player" or type == "npc" then
						local s = self.object:getpos()
						local p = player:getpos()
						local sp = s
						p.y = p.y + 1
						sp.y = sp.y + 1		-- aim higher to make looking up hills more realistic
						local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
						--print("Dist "..tostring(dist) .. " < " .. tostring(self.view_range) .. " in_fov " .. tostring(self.in_fov(self,p)))
						if dist < self.view_range and self.in_fov(self,p) then
							if minetest.line_of_sight(sp,p,2) == true then
								self.do_attack(self,player,dist)
								break
							else
								--print("no line of site")
							end
							
						end
					end
				end
			end
			
			-- NPC FIND A MONSTER TO ATTACK
			if self.type == "npc" and self.attacks_monsters and self.state ~= "attack" then
				local s = self.object:getpos()
				local inradius = minetest.get_objects_inside_radius(s,self.view_range)
				for _, oir in pairs(inradius) do
					local obj = oir:get_luaentity()
					if obj then
						if obj.type == "monster" or obj.type == "barbarian" then
							-- attack monster
							local p = obj.object:getpos()
							local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
							self.do_attack(self,obj.object,dist)
							break
						end
					end
				end
			end
			
			
			if self.follow ~= "" and not self.following then
				for _,player in pairs(minetest.get_connected_players()) do
					local s = self.object:getpos()
					local p = player:getpos()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if self.view_range and dist < self.view_range then
						self.following = player
						break
					end
				end
			end
			
			if self.following and self.following:is_player() then
				if self.following:get_wielded_item():get_name() ~= self.follow then
					self.following = nil
				else
					local s = self.object:getpos()
					local p = self.following:getpos()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if dist > self.view_range then
						self.following = nil
						self.v_start = false
					else
						local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
						local yaw = math.atan(vec.z/vec.x)+math.pi/2
						if self.drawtype == "side" then
							yaw = yaw+(math.pi/2)
						end
						if p.x > s.x then
							yaw = yaw+math.pi
						end
						self.object:setyaw(yaw)
						if dist > 2 then
							if not self.v_start then
								self.v_start = true
								self.set_velocity(self, self.walk_velocity)
							else
								if self.jump == true and self.get_velocity(self) <= 1.5 and self.object:getvelocity().y == 0 then
									local v = self.object:getvelocity()
									v.y = 6
									self.object:setvelocity(v)
								end
								self.set_velocity(self, self.walk_velocity)
							end
							self:set_animation("walk")
						else
							self.v_start = false
							self.set_velocity(self, 0)
							self:set_animation("stand")
						end
						return
					end
				end
			end
			
			if self.state == "stand" then
				-- randomly turn
				math.randomseed(os.clock())
				if math.random(1, 100) < self.activity_level then
					-- if there is a player nearby look at them
					local lp = nil
					local s = self.object:getpos()
					if self.type == "npc" then
						local o = minetest.get_objects_inside_radius(self.object:getpos(), 3)
						
						local yaw = 0
						for _,o in ipairs(o) do
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
				if math.random(1, 100) <= self.activity_level and self.stationary == false then
					self.set_velocity(self, self.walk_velocity)
					self.state = "walk"
					self.set_animation(self, "walk")
				end
			elseif self.state == "walk" or self.state == "path" then
				if ( math.random(1, 100) <= 30 or ( self.get_velocity(self) < self.walk_velocity ) ) and self.state ~= "path" then
					self.object:setyaw(self.object:getyaw()+((math.random(0,360)-270)/180*math.pi))
				end
				if self.jump == true and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
					local v = self.object:getvelocity()
					v.y = 5
					self.object:setvelocity(v)
				end
				self:set_animation("walk")
				self.set_velocity(self, self.walk_velocity)
				if math.random(1, 100) <= 30 and self.state ~= "path" then
					self.set_velocity(self, 0)
					self.state = "stand"
					self:set_animation("stand")
				end
				if self.state == "path" then
					self.leg_timer = self.leg_timer + dtime
					self.check_path(self)
				end
			elseif self.state == "attack" and self.attack_type == "dogfight" then
				if not self.attack.player or not self.attack.player:getpos() then
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					self.attack = {player=nil, dist=nil}
					self:set_animation("stand")
					return
				else
					self.attack.dist = dist
				end
				
				local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				if self.attack.dist > self.attack_range then
					if not self.v_start then
						self.v_start = true
						self.set_velocity(self, self.run_velocity)
					else
						if self.jump == true and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
							local v = self.object:getvelocity()
							v.y = 5
							self.object:setvelocity(v)
						end
						self.set_velocity(self, self.run_velocity)
					end
					self:set_animation("run")
				else
					self.set_velocity(self, 0)
					self:set_animation("punch")
					self.v_start = false
					if self.timer > 1 then
						self.timer = 0
						local p2 = p
						local s2 = s
						p2.y = p2.y + 1.5
						s2.y = s2.y + 1.5
						if minetest.line_of_sight(p2,s2) == true then
							if self.sounds and self.sounds.attack then
								minetest.sound_play(self.sounds.attack, {object = self.object})
							end
							if self.attack_function ~= nil then
								self.attack_function(self,self.attack.player)
							else 
								self.attack.player:punch(self.object, 1.0,  {
									full_punch_interval=1.0,
									damage_groups = {fleshy=self.damage}
								}, vec)
							end
							if self.attack.player:get_hp() <= 0 then
								self.state = "stand"
								self:set_animation("stand")
							end
						end
					end
				end
			elseif self.state == "attack" and self.attack_type == "shoot" then
				if not self.attack.player or not self.attack.player:is_player() then
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				p.y = p.y - .5
				s.y = s.y + .5
				local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					if self.type ~= "npc" then
						self.attack = {player=nil, dist=nil}
					end
					self:set_animation("stand")
					return
				else
					self.attack.dist = dist
				end
				
				local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				self.set_velocity(self, 0)
				
				if self.timer > self.shoot_interval and math.random(1, 100) <= 60 then
					self.timer = 0
					
					self:set_animation("punch")
					
					if self.sounds and self.sounds.attack then
						minetest.sound_play(self.sounds.attack, {object = self.object})
					end
					
					local p = self.object:getpos()
					p.y = p.y + self.arrow_offset
					local obj = minetest.add_entity(p, self.arrow)
					local amount = (vec.x^2+vec.y^2+vec.z^2)^0.5
					local v = obj:get_luaentity().velocity
					vec.y = vec.y
					vec.x = vec.x*v/amount
					vec.y = vec.y*v/amount
					vec.z = vec.z*v/amount
					obj:setvelocity(vec)
					if obj:get_luaentity().drop_rate ~= nil then
						obj:setacceleration({x=vec.x, y=obj:get_luaentity().drop_rate, z=vec.z})
					end
				end
			end
		end,
		
		on_activate = function(self, staticdata, dtime_s)
			-- reset HP
			local pos = self.object:getpos()
			local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / 20000 )	
			local newHP = self.hp_min + math.floor( self.hp_max * distance_rating )
			self.object:set_hp( newHP )

			self.object:set_armor_groups({fleshy=self.armor})
			self.object:setacceleration({x=0, y=-10, z=0})
			self.state = "stand"
			self.object:setvelocity({x=0, y=self.object:getvelocity().y, z=0})
			self.object:setyaw(((math.random(0,360)-270)/180*math.pi))
			if self.type == "monster" and minetest.setting_getbool("only_peaceful_mobs") then
				self.object:remove()
			end
			if self.type ~= "npc" then
				self.lifetimer = 600 - dtime_s
			end
			if staticdata then
				local tmp = minetest.deserialize(staticdata)
				if tmp and tmp.lifetimer then
					self.lifetimer = tmp.lifetimer - dtime_s
				end
				if tmp and tmp.tamed then
					self.tamed = tmp.tamed
				end
				--[[if tmp and tmp.textures then
					self.object:set_properties(tmp.textures)
				end]]
			end
			if self.lifetimer <= 0 and not self.tamed and self.type ~= "npc" then
				self.object:remove()
			end
		end,
		
		get_staticdata = function(self)
			local tmp = {
				lifetimer = self.lifetimer,
				tamed = self.tamed,
				textures = { textures = self.textures },
			}
			return minetest.serialize(tmp)
		end,
		
		on_punch = function(self, hitter, tflp, tool_capabilities, dir)
			if tflp == nil then
				tflp = 1
			end
			process_weapon(hitter,tflp,tool_capabilities)
			
			local pos = self.object:getpos()
			if self.object:get_hp() <= 0 then
				if hitter and hitter:is_player() and hitter:get_inventory() then
					for _,drop in ipairs(self.drops) do
						if math.random(1, 100) < drop.chance then
							local d = ItemStack(drop.name.." "..math.random(drop.min, drop.max))
							default.drop_item(pos,d)
						end
					end
					
					if self.sounds.death ~= nil then
						minetest.sound_play(self.sounds.death,{
							object = self.object,
						})
					end
					if minetest.get_modpath("skills") and minetest.get_modpath("experience") then
						-- DROP experience
						local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / ( skills.get_player_level(hitter:get_player_name()).level * 1000 ) )
						local emax = math.floor( self.exp_min + ( distance_rating * self.exp_max ) )
						local expGained = math.random(self.exp_min, emax)
						skills.add_exp(hitter:get_player_name(),expGained)
						local expStack = experience.exp_to_items(expGained)
						for _,stack in ipairs(expStack) do
							default.drop_item(pos,stack)
						end
					end
					
					-- see if there are any NPCs to shower you with rewards
					if self.type ~= "npc" and self.type ~= "animal" then
						local inradius = minetest.get_objects_inside_radius(hitter:getpos(),10)
						for _, oir in pairs(inradius) do
							local obj = oir:get_luaentity()
							if obj then	
								if obj.type == "npc" and obj.rewards ~= nil then
									local lp = hitter:getpos()
									local s = obj.object:getpos()
									local yaw = mobs:face_pos(self,lp)
									local vec = {x=lp.x-s.x, y=1, z=lp.z-s.z}
									local x = math.sin(yaw) * -2
									local z = math.cos(yaw) * 2
									acc = {x=x, y=-5, z=z}
									for _, r in pairs(obj.rewards) do
										if math.random(0,100) < r.chance then
											default.drop_item(obj.object:getpos(),r.item, vec, acc)
										end
									end
								end
							end
						end
					end
					
				end
			end
			
			
			blood_particles(pos,self.blood_offset,self.blood_amount,self.blood_texture)
			
			-- knock back effect, adapted from blockmen's pyramids mod
			-- https://github.com/BlockMen/pyramids
			local kb = self.knock_back
			local r = self.recovery_time
			
			if  tool_capabilities ~= nil then
			 if tflp < tool_capabilities.full_punch_interval then
				  kb = kb * ( tflp / tool_capabilities.full_punch_interval )
				  r = r * ( tflp / tool_capabilities.full_punch_interval )
			 end
			else
		    kb = kb * ( tflp / 1 )
        r = r * ( tflp / 1 )
			end
			
			local ykb=2
			local v = self.object:getvelocity()
			if v.y ~= 0 then
				ykb = 0
			end 
			
			self.object:setvelocity({x=dir.x*kb,y=ykb,z=dir.z*kb})
			self.pause_timer = r
			
			-- attack puncher and call other mobs for help
			if self.passive == false then
				if self.state ~= "attack" then
					self.do_attack(self,hitter,1)
				end
				-- alert other NPCs to the attack
				local inradius = minetest.get_objects_inside_radius(hitter:getpos(),10)
				for _, oir in pairs(inradius) do
					local obj = oir:get_luaentity()
					if obj then
						if obj.group_attack == true and obj.state ~= "attack" and self.type == obj.type then
							obj.do_attack(obj,hitter,1)
						end
					end
				end
			end
			
		end,
		
	})
end

mobs.spawning_mobs = {}
function mobs:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height, min_dist, max_dist, spawn_func)
	mobs.spawning_mobs[name] = true	
	minetest.register_abm({
		nodenames = nodes,
		--neighbors = {"air"},
		interval = 30,
		chance = chance,
		action = function(pos, node, _, active_object_count_wider)
			if active_object_count_wider > active_object_count then
				return
			end
			if not mobs.spawning_mobs[name] then
				return
			end
			
			--[[ don't spawn inside of blocks
			local p2 = pos
			p2.y = p2.y + 1
			local p3 = p2
			p3.y = p3.y + 1
			if minetest.registered_nodes[minetest.get_node(p2).name].walkable == false or minetest.registered_nodes[minetest.get_node(p3).name].walkable == false then
				return
			end]]
			
			pos.y = pos.y+1
			if not minetest.get_node_light(pos) then
				return
			end
			if minetest.get_node_light(pos) > max_light then
				return
			end
			if minetest.get_node_light(pos) < min_light then
				return
			end
			if pos.y > max_height then
				return
			end
			
			if min_dist == nil then
				min_dist = {x=-1,z=-1}
			end
			if max_dist == nil then
				max_dist = {x=33000,z=33000}
			end
			
			if math.abs(pos.x) < min_dist.x or math.abs(pos.z) < min_dist.z then
				return
			end
			
			if math.abs(pos.x) > max_dist.x or math.abs(pos.z) > max_dist.z then
				return
			end
						
			if spawn_func and not spawn_func(pos, node) then
				return
			end
			
			if minetest.setting_getbool("display_mob_spawn") then
				minetest.chat_send_all("[mobs] Add "..name.." at "..minetest.pos_to_string(pos))
			end
			mobs:spawn_mob(pos,name)
		end
	})
end

function mobs:spawn_mob(pos,name)  
	-- make sure the nodes above are walkable
	minetest.log("action","Attempting to spawn "..name)
	local nodename = minetest.get_node(pos).name
	if minetest.registered_nodes[nodename] ~= nil then
		if minetest.registered_nodes[nodename].walkable == true or minetest.registered_nodes[nodename].walkable == nil or nodename == "default:water_source" then
			return -1
		end  
		pos.y = pos.y + 1
		nodename = minetest.get_node(pos).name
		if minetest.registered_nodes[nodename].walkable == true or minetest.registered_nodes[nodename].walkable == nil or nodename == "default:water_source" then
			return -1
		end
		pos.y = pos.y - 1
	end

	local mob = minetest.add_entity(pos, name)
	-- setup the hp, armor, drops, etc... for this specific mob
	local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / 15000 )	
	if mob ~= nil then		
		mob = mob:get_luaentity()
		if mob ~= nil then
			minetest.log("action",name.." spawned at "..minetest.pos_to_string(pos))
			local newHP = mob.hp_min + math.floor( mob.hp_max * distance_rating )
			mob.object:set_hp( newHP )
			mob.state = "walk"	-- make them walk when they spawn so they walk away from their original spawn position
			-- vary the walk and run velocity when a mob is spawned so groups of mobs don't clump up so bad
			math.randomseed(os.clock())
			
			mob.walk_velocity = mob.walk_velocity - ( mob.walk_velocity * ( math.random(0,12) / 100 ) )
			if mob.walk_velocity < 0 then
				mob.walk_velocity = 0
			end
			
			mob.run_velocity = mob.run_velocity - ( mob.run_velocity * ( math.random(0,12) / 100 ) )
			if mob.run_velocity < 0 then
				mob.run_velocity = 0
			end
			return true
		end
	end
end

function mobs:get_random(type)
	if mobs.mob_list[type] ~= nil then
		local seed = os.clock() + os.time()
		math.randomseed(seed)
		local idx = math.random(1,#mobs.mob_list[type])
		if mobs.mob_list[type][idx] ~= nil then
			return mobs.mob_list[type][idx]
		end
		return false
	end
end

function mobs:register_arrow(name, def)
	minetest.register_entity(name, {
		physical = false,
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		velocity = def.velocity,
		hit_player = def.hit_player,
		hit_node = def.hit_node,
		timer = 0,
		
		on_step = function(self, dtime)
			self.timer=self.timer+dtime
			if self.timer > 0.2 then
				local pos = self.object:getpos()
				if minetest.get_node(self.object:getpos()).name ~= "air" and minetest.get_node(self.object:getpos()).name ~= "fire:basic_flame"then
					self.hit_node(self, pos, node)
					self.object:remove()
					return
				end
				--pos.y = pos.y-1
				local objs = minetest.get_objects_inside_radius(pos, 2)
				for _,player in pairs(objs) do
					if player:get_luaentity() ~= nil then
						local luae = player:get_luaentity()
						if luae.name ~= self.object:get_luaentity().name and luae.name ~= "__builtin:item" then
							self.hit_player(self, player)
							self.object:remove()
							return
						end
					else
						self.hit_player(self, player)
						self.object:remove()
						return
					end
				end
			end
		end
	})
end

function mobs:face_pos(self,pos)
	local s = self.object:getpos()
	local vec = {x=pos.x-s.x, y=pos.y-s.y, z=pos.z-s.z}
	local yaw = math.atan(vec.z/vec.x)+math.pi/2
	if self.drawtype == "side" then
		yaw = yaw+(math.pi/2)
	end
	if pos.x > s.x then
		yaw = yaw+math.pi
	end
	self.object:setyaw(yaw)
	--print("Yaw "..tostring(yaw))
	return yaw
end


function get_distance(pos1,pos2)
	if ( pos1 ~= nil and pos2 ~= nil ) then
		return math.abs(math.floor(math.sqrt( (pos1.x - pos2.x)^2 + (pos1.z - pos2.z)^2 )))
	else
		return 0
	end
end

blood_particles = function(pos,offset,amt,tex)
	if amt > 0 and pos ~= nil then
		local p = pos
		p.y = p.y + offset
		
		local ps_def = { 
			amount = amt,
			time = 0.25,
			minpos = {x=p.x-0.2, y=p.y-0.2, z=p.z-0.2},
			maxpos = {x=p.x+0.2, y=p.y+0.2, z=p.z+0.2},
			minvel = {x=0, y=-2, z=0},
			maxvel = {x=2, y=2, z=2},
			minacc = {x=-4,y=-4,z=-4},
			maxacc = {x=4,y=-4,z=4},
			minexptime = 0.1,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 1,
			collisiondetection = false,
			texture = tex
		}
		minetest.add_particlespawner(ps_def)
    end
end

function process_weapon(player, time_from_last_punch, tool_capabilities)
local weapon = player:get_wielded_item()
	if tool_capabilities ~= nil then
		local wear = ( tool_capabilities.full_punch_interval / 75 ) * 65535
		weapon:add_wear(wear)
		player:set_wielded_item(weapon)
	end
	
	if weapon:get_definition().sounds ~= nil then
		local s = math.random(0,#weapon:get_definition().sounds)
		minetest.sound_play(weapon:get_definition().sounds[s], {
			object=player,
		})
	else
		minetest.sound_play("default_sword_wood", {
			object = player,
		})
	end	
end

