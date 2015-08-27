local MAGICMISSLE_ENTITY={
	physical = false,
	timer=0,
	visual = "sprite",
	visual_size = {x=0.5, y=0.5},
	textures = {"magic_magicmissle.png"},
	lastpos={},
	collisionbox = {0,0,0,0,0,0},
	player = nil,
	max_damage=25,
}

MAGICMISSLE_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)

	--if self.timer>0.2 then
		if self.player ~= nil then
			hitter = self.player
		else
			hitter = self.object
		end		
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 2)
		for k, obj in pairs(objs) do
			if obj:get_luaentity() ~= nil then
				if obj:get_luaentity().name ~= "magic:magicmissle" and obj:get_luaentity().name ~= "__builtin:item" then
					minetest.sound_play("magic_magicmissle_hit",{object=self.object})
					local skill = skills.get_skill(hitter:get_player_name(),SKILL_MAGIC)
					local damage = self.max_damage * ( (skill.level) / skills.get_def(SKILL_MAGIC)['max_level'] )
					obj:punch(hitter, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					hitparticles(pos)
					self.object:remove()
				end
			else
				if obj ~= hitter then
					minetest.sound_play("magic_magicmissle_hit",{object=self.object})
					local skill = skills.get_skill(hitter:get_player_name(),SKILL_MAGIC)
					local damage = self.max_damage * ( (skill.level) / skills.get_def(SKILL_MAGIC)['max_level'] )
					obj:punch(hitter, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
					hitparticles(pos)
					self.object:remove()
				end
			end
		end
	--end

	if self.lastpos.x~=nil then
		if ( minetest.registered_nodes[node.name].walkable == true or minetest.registered_nodes[node.name].walkable == nil ) and ( node.name ~= "air" and node.name ~= "default:water_source" and node.name ~= "default:water_flowing" ) then
			minetest.sound_play("magic_magicmissle_hit",{object=self.object})
			hitparticles(pos)
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z}
	
	-- drop particle
	--[[
	minetest.add_particle({
		pos = pos,
		velocity = {x=0,y=0,z=0},
		acceleration = { x=0,y=0,z=0 },
		expirationtime=2,
		size = 0.25,
		collisiondetection = false,
		vertical = true,
		texture = "magic_magicmissle.png",
	})
	]]
	local rnd = math.random(0,1)*-1
	local rnd2 = math.random(1,2)

	local ps_def = {
		pos = pos,
		velocity = {x=0.1*rnd, y=0, z=-0.1*rnd}, 
		acceleration = {x=0, y=-12, z=0},
		expirationtime = 4,
		size = 1.2,
		collisiondetection = true,
		texture = "magic_magicmissle_particle1.png",
	}
	minetest.add_particle(ps_def)
	
	if self.timer > 1.5 then
		minetest.sound_play("magic_magicmissle_hit",{object=self.object})
		hitparticles(pos)
		self.object:remove()
	end
end

function hitparticles(pos)
	local ps_def = {
		amount = 45,
		time = 0.75,
		minpos = {x=pos.x-0.3, y=pos.y+0.3, z=pos.z-0.3},
        maxpos = {x=pos.x+0.3, y=pos.y+0.5, z=pos.z+0.3},
        minvel = {x=0, y=-2, z=0},
        maxvel = {x=2, y=2, z=2},
        minacc = {x=-4,y=-4,z=-4},
        maxacc = {x=4,y=-4,z=4},
        minexptime = 0.1,
        maxexptime = 1,
        minsize = 1,
        maxsize = 3,
        collisiondetection = false,
        texture = "magic_magicmissle_particle1.png",
	}
	minetest.add_particlespawner(ps_def)
end

minetest.register_entity("magic:magicmissle", MAGICMISSLE_ENTITY)

local magicmissle_spell = {
	id="missle",
	desc = "Magic Missle",
	type = "wand",
	wand_texture = "magic_missle_wand.png",
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		
		local sk = skills.get_skill(name,SKILL_MAGIC)
		local skb = skills.get_def(SKILL_MAGIC)
		
		if sk.level >= 4 then		
			local mana = 10 - ( ( (sk.level - 2) / skb.max_level ) * 10 )
			if magic.player_magic[name] >= mana then
				magic.player_magic[name] = magic.player_magic[name] - mana
				minetest.sound_play("magic_magicmissle_cast",{object=user})
				local playerpos = user:getpos()
				local obj = minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, "magic:magicmissle")
				local dir = user:get_look_dir()
				obj:setvelocity({x=dir.x*19, y=dir.y*19, z=dir.z*19})
				obj:setacceleration({x=dir.x*-3, y=-1, z=dir.z*-3})
				obj:setyaw(user:get_look_yaw()+math.pi)
				obj:get_luaentity().player = user
				magic.update_magic(user,name)
			else
				minetest.chat_send_player(name,"You don't have enough magic")
			end
		else
			minetest.chat_send_player(name,"You are not high enough level to use Magic Missle")
		end
	end,
	max_mana = 10,
	level = 4,
}

magic.register_spell(magicmissle_spell)

