skills = { }
skill_file = minetest.get_worldpath().."/player_skills"
level_file = minetest.get_worldpath().."/player_levels"

skills.available_skills = {}
skills.player_skills = {}
skills.player_levels = {}

function skills.register_skill(skill_id,s_table)
	skills.available_skills[skill_id] = s_table
end

function skills.initialize()
	minetest.log("action","Loading player skills and levels")
	skills.player_skills = default.deserialize_from_file(skill_file)
	skills.player_levels = default.deserialize_from_file(level_file)
	dofile(minetest.get_modpath("skills").."/register_skills.lua")
	minetest.after(120,skills.save)
end

function skills.save()
	minetest.log("action","Saving levels and skills")
	default.serialize_to_file(skill_file,skills.player_skills)
	default.serialize_to_file(level_file,skills.player_levels)
	minetest.after(120,skills.save)
end

function skills.get_def(skill_id)
	return skills.available_skills[skill_id]
end

function skills.set_default_skills ( name )
	minetest.log("action","Setting default skills for "..name)
	if skills.player_skills[name] == nil then
		skills.player_skills[name] = { }
	end
	for k,v in pairs(skills.available_skills) do
		--print(name.." checking for skill "..v.desc)
		if skills.player_skills[name][k] == nil then
			--print(name.." adding skill "..tostring(k))
			skills.player_skills[name][k] = { level = 1, exp = 0 }
		end
	end
	default.serialize_to_file(skill_file,skills.player_skills)
end 

function skills.get_skill(name, skill_id)
	if skills.player_skills[name] ~= nil then
		--print(name.." in skill table")
		if skills.player_skills[name][skill_id] ~= nil then
			--print(name.." has "..tostring(skill_id).." in skill table")
			return skills.player_skills[name][skill_id]
		end
	end
	skills.set_default_skills(name)
	return skills.get_skill(name,skill_id)
end

function skills.get_player_level(name)
	if skills.player_levels[name] == nil then
		skills.player_levels[name] = {level=1,exp=0}
	end
	return skills.player_levels[name]
end

function skills.add_exp(name, exp)
	-- this adds experience to the user and increases their level when needed
	local l = skills.get_player_level(name)
	skills.player_levels[name].exp = l.exp + exp	
	local next_level = ((l.level^2) * 50)
	
	if skills.player_levels[name].exp >= next_level then
		skills.player_levels[name].level = skills.player_levels[name].level + 1
		skills.player_levels[name].exp = skills.player_levels[name].exp - next_level
		minetest.chat_send_player(name,"You have gained a level! You are now level "..tostring(skills.player_levels[name].level))
		minetest.sound_play("levelup", {
			to_player = name,
			gain = 10.0,
		})
	end	
end

function skills.get_probability(name, skill1, skill2)
	--print("get_probablilty("..name..","..tostring(skill1)..","..tostring(skill2)..")")
	if ( name == nil or name == "" ) then
		return 99
	end
	local s1 = skills.get_skill(name, skill1)
	local s2 = skills.get_skill(name, skill2)
	--print(tostring(s1['level']).."/"..tostring(skills.get_def(skill1)['max_level']))
	--print(tostring(s2['level']).."/"..tostring(skills.get_def(skill2)['max_level']))
	--print(tostring(( 99 * ( ( s1['level'] + s2['level'] ) / ( skills.get_def(skill1)['max_level'] + skills.get_def(skill2)['max_level'] ) ) )))
	return ( 99 * ( ( s1['level'] + s2['level'] ) / ( skills.get_def(skill1)['max_level'] + skills.get_def(skill2)['max_level'] ) ) )
end

function skills.get_skills_formspec(player)
	local name = player:get_player_name()
	local formspec = "size[12,10]"
		.."list[current_player;main;8,0.5;4,8;]"
	local i = 0
	for id,skill in pairs(skills.available_skills) do
		sk = skills.get_skill(name,id)	
		formspec = formspec.."label[1.5,"..tostring(i)..".2;"..skill.desc.."]"
		formspec = formspec.."label[3.5,"..tostring(i)..".2;"..sk.exp.." / "..tostring( (math.floor((sk.level^1.75)) * skill.level_exp) ).."]"
		formspec = formspec.."label[6,"..tostring(i)..".2;"..tostring(sk.level).." / "..tostring(skill.max_level).."]"
		formspec = formspec.."list[detached:"..name.."_skills;"..tostring(id)..";0.5,"..tostring(i)..";1,1;]"
		i = i + 1
	end
	return formspec
end

minetest.register_on_joinplayer(function (player)
	local name = player:get_player_name()
	local player_inv = player:get_inventory()
	local skill_inv = minetest.create_detached_inventory(name.."_skills",{
		on_put = function(inv, listname, index, stack, player)
			-- Calculate how much experience they have put in and increase their skill accordingly
			-- Remove the item from the inventory list
			if stack:get_definition().exp_value ~= nil then
				local name = player:get_player_name()
				local skill_id = tonumber(listname)
				local exp_dropped = stack:get_definition().exp_value * stack:get_count()
				
				local sk = skills.get_skill(name,skill_id)
				local skill = skills.available_skills[skill_id]
				local next_level = math.floor(((sk.level^1.75) * skill.level_exp))
				
				skills.player_skills[name][skill_id].exp = skills.player_skills[name][skill_id].exp + exp_dropped
				
				if skills.player_skills[name][skill_id].exp >= next_level then
					if skills.player_skills[name][skill_id].level ~= skill.max_level then
						skills.player_skills[name][skill_id].level = skills.player_skills[name][skill_id].level + 1
						skills.player_skills[name][skill_id].exp = skills.player_skills[name][skill_id].exp - next_level
					end
				end
				
				stack:clear()
				inv:set_stack(listname,index,stack)
				
				minetest.show_formspec(
					name,
					"skills_form",
					skills.get_skills_formspec(player)
				)
			end
		end,
	})
	for id,skill in pairs(skills.available_skills) do
		local list = tostring(id)
		player_inv:set_size(list, 1)
		skill_inv:set_size(list, 1)
		skill_inv:set_stack(list, 1, player_inv:get_stack(list, 1))
	end
	if skills.player_levels[name] == nil then
	 skills.player_levels[name] = {level=1,exp=1}
	end
end)

minetest.register_on_shutdown(function()
	default.serialize_to_file(skill_file,skills.player_skills)
	default.serialize_to_file(level_file,skills.player_levels)
end)

minetest.register_on_newplayer(function(player)
	skills.set_default_skills(player:get_player_name())
	skills.player_levels[player:get_player_name()] = {level=1,exp=1}
end)

minetest.register_on_leaveplayer(function(player)
	default.serialize_to_file(skill_file,skills.player_skills)
	default.serialize_to_file(level_file,skills.player_levels)
end)

minetest.register_chatcommand("skills", {
	params = "",
	description = "List player's level and skills",
	func = function(name, param)
		minetest.chat_send_player(name,"Level: "..tostring(skills.player_levels[name].level))
		for id,skill in pairs(skills.available_skills) do
			sk = skills.get_skill(name,id)
			minetest.chat_send_player(name,skill.desc.." "..tostring(sk.level))
		end
	end,
})

function skills_on_dieplayer (player)
    local name = player:get_player_name()
    local level  = skills.get_player_level(name)
    local decrease = level.exp * -0.1
    print(tostring(decrease))
    skills.add_exp(name,decrease)
end

skills.initialize()