function mobs.on_step(self,dtime)
	if self.type == "monster" and minetest.setting_getbool("only_peaceful_mobs") then
		self.object:remove()
		return
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
	
	self:do_avoidance()
	
	-- if they are attacking that should take priority over everything else so move it up here
	if self.state == "attack" and self.attack_type == "dogfight" then
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
					v.y = 7
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
						self.v_start = false
						self.set_velocity(self, 0)
						self.attack = {player=nil, dist=nil}
						self:set_animation("stand")
					end
				end
			end
		end
		return
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
		return
	end
	
	-- FIND SOMEONE TO ATTACK
	if ( self.type == "monster" or self.type == "barbarian" ) and minetest.setting_getbool("enable_damage") and self.state ~= "attack" then
		if mobs.api_throttling(self) then return end
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
		if mobs.api_throttling(self) then return end			
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
	
	
	if self.follow ~= nil and not self.following then
		if mobs.api_throttling(self) then return end
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
			if mobs.api_throttling(self) then return end
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
	end
end
