mobs = {}

dofile(minetest.get_modpath("mobs").."/step.lua")

mobs.mob_list = { npc={}, barbarian={}, monster={}, animal={}, npc_special={}}
mobs.api_throttle = 20	-- limits the amount of intense operations that can happen per second
mobs.api_icount = 0
mobs.api_timer = 0

mobs.spawn_counter = 0
mobs.spawn_limit = 25
mobs.spawn_timer = 0
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
		follow = def.follow or nil,
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
		avoid_nodes = def.avoid_nodes or nil,
		avoid_range = def.avoid_range or nil,
		random_freq = def.random_freq or 1,
		
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
		
		do_avoidance = function(self)
			
			if self.avoid_nodes ~= nil then
				local avoid_range = self.avoid_range
				local avoid_nodes = self.avoid_nodes
				
				local pos = self.object:getpos()
				
				local minx = pos.x - avoid_range
				local maxx = pos.x + avoid_range
				
				local minz = pos.z - avoid_range
				local maxz = pos.z + avoid_range

				local npos = minetest.find_nodes_in_area({x=minx,y=(pos.y-2),z=minz},{x=maxx,y=(pos.y+2),z=maxz}, avoid_nodes)
				
				if #npos > 0 then
					local fpos = { x=(npos[1].x * -1),y=npos[1].y,z=(npos[1].z*-1) } 
					mobs:face_pos(self,fpos)
					self.state="walk"
					self:set_animation("walk")
					self.set_velocity(self, self.walk_velocity)
					self.pause_timer = 3
				end
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
			
			--print("Yaw: "..tostring(yaw))
			--print("FOV: "..tostring(self.fov))
			local vx = math.sin(yaw)
			local vz = math.cos(yaw)
			local ds = math.sqrt(vx^2 + vz^2)
			local ps = math.sqrt(pos.x^2 + pos.z^2)
			local d = { x = vx / ds, z = vz / ds }
			local p = { x = pos.x / ps, z = pos.z / ps }
			
			--print("DS "..tostring(ds))
			--print("PS "..tostring(ps))
			--print("D: x="..tostring(d.x)..", z="..tostring(d.z))
			--print("P: x="..tostring(p.x)..", z="..tostring(p.z))
			
			local an = ( d.x * p.x ) + ( d.z * p.z )
			--print("AN: "..tostring(an))
			local a = math.deg ( math.acos( an ) )
			--print("A: "..tostring(a))
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
		
		on_step = def.on_step or mobs.on_step,
		
		on_activate = function(self, staticdata, dtime_s)
			-- reset HP
			local pos = self.object:getpos()
			local distance_rating = ( ( get_distance(game_origin,pos) ) / 20000 )	
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
		
		on_punch = def.on_punch or function(self, hitter, tflp, tool_capabilities, dir)
			if tflp == nil then
				tflp = 1
			end
			process_weapon(hitter,tflp,tool_capabilities)
			self.pause_timer = 0
			local hpos = hitter:getpos()
			local pos = self.object:getpos()
			if self.object:get_hp() <= 0 then
				if hitter and hitter:is_player() and hitter:get_inventory() then
					local name = hitter:get_player_name()
					pd.increment(name,STAT_KILLS,1)
					for _,drop in pairs(self.drops) do
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
						local distance_rating = ( ( get_distance(game_origin,pos) ) / ( skills.get_player_level(hitter:get_player_name()).level * 1000 ) )
						local emax = math.floor( self.exp_min + ( distance_rating * self.exp_max ) )
						local expGained = math.random(self.exp_min, emax)
						skills.add_exp(hitter:get_player_name(),expGained)
						local expStack = experience.exp_to_items(expGained)
						for _,stack in pairs(expStack) do
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
									local acc = {x=x, y=-5, z=z}
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
			
			if dir == nil then
				dir = {x=pos.x-hpos.x, y=pos.y-hpos.y, z=pos.z-hpos.z}
				if dir.x > 1 then dir.x = 1 end
				if dir.x < -1 then dir.x = -1 end
				if dir.z > 1 then dir.z = 1 end
				if dir.z < -1 then dir.z = -1 end
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
			if mobs.spawn_counter > mobs.spawn_limit then
				return
			end
			mobs.spawn_counter = mobs.spawn_counter + 1
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
			
			if pos.y > max_height then
				return
			end
			
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
		
	minetest.log("info","Attempting to spawn "..name)
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
	local distance_rating = ( ( get_distance(game_origin,pos) ) / 15000 )	
	if mob ~= nil then		
		mob = mob:get_luaentity()
		if mob ~= nil then
			minetest.log("info",name.." spawned at "..minetest.pos_to_string(pos))
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

function mobs.global_step(dtime)
	mobs.api_timer = mobs.api_timer + dtime
	mobs.spawn_timer = mobs.spawn_timer + dtime
	if mobs.api_timer >= 1 then
		mobs.api_icount = 0
		mobs.api_timer = 0
	end
	if mobs.spawn_timer >= 2 then
		mobs.spawn_timer = 0
		mobs.spawn_counter = 0
	end
end

function mobs.api_throttling(self)
	if mobs.api_icount > mobs.api_throttle then
		return true
	end
	mobs.api_icount = mobs.api_icount + 1
	self.timer = -2
	return false
end