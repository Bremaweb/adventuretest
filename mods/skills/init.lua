skills = { }

skills.available_skills = {}

function skills.register_skill(skill_id,s_table)
	skills.available_skills[skill_id] = s_table
end

function skills.get_def(skill_id)
	return skills.available_skills[skill_id]
end

function skills.set_default_skills ( name )
	minetest.log("action","Setting default skills for "..name)
	local pskills = pd.get(name,"skills")
	if pskills == nil then pskills = {} end
	for k,v in pairs(skills.available_skills) do
		print(name.." checking for skill "..v.desc)
		if pskills[k] == nil then
			print("Doesn't have skill "..tostring(k))
			pskills[k] = { level = 1, exp = 0 }
		else
			print("Has skill "..tostring(k))
		end
	end
	print("Result!")
	default.tprint(pskills,4)
	pd.set(name,"skills",pskills)
end 

function skills.get_skill(name, skill_id)
	-- Existing skill
	
	local playerSkills = pd.get(name,"skills")
	local skill = playerSkills and playerSkills[skill_id]
	if skill ~= nil then
		return skill
	end

	-- Missing player or skill
	
	minetest.log("info", "Requesting skill (id="..tostring(skill_id)..") for player '"..name.."'. Player is new or missing the skill.")
	skills.set_default_skills(name)
	
	playerSkills = pd.get(name,"skills")
	skill = playerSkills and playerSkills[skill_id]

	if playerSkills == nil then
		minetest.log("error", "Failed to add default skills for player '"..name.."'.")
	elseif skill == nil then
		minetest.log("error", "Failed to add default skill (id="..tostring(skill_id)..") for player '"..name.."'.")
	end

	return skill
end

function skills.get_player_level(name)
	return pd.get(name,"level")
end

function skills.add_exp(name, exp)
	-- this adds experience to the user and increases their level when needed
	local l = pd.get(name,"level")
	l.exp = l.exp + exp	
	local next_level = ((l.level^2) * 50)
	
	if l.exp >= next_level then
		l.level = l.level + 1
		l.exp = l.exp - next_level
		minetest.chat_send_player(name,"You have gained a level! You are now level "..tostring(l.level))
		minetest.sound_play("levelup", {
			to_player = name,
			gain = 10.0,
		})
		pd.set(name,"level",l)
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
		local sk = skills.get_skill(name,id)	
		formspec = formspec.."label[1.5,"..tostring(i)..".2;"..skill.desc.."]"
		formspec = formspec.."label[3.5,"..tostring(i)..".2;"..math.floor(sk.exp).." / "..tostring( (math.floor((sk.level^1.75)) * skill.level_exp) ).."]"
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
				local pskills = pd.get(name,"skills")
				
				pskills[skill_id].exp = pskills[skill_id].exp + exp_dropped

				while pskills[skill_id].exp >= next_level and pskills[skill_id].level < skill.max_level do
						pskills[skill_id].level = pskills[skill_id].level + 1
						pskills[skill_id].exp = pskills[skill_id].exp - next_level
						next_level = math.floor(((pskills[skill_id].level^1.75) * skill.level_exp))
				end
				
				pd.set(name,"skills",pskills)
				
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

dofile(minetest.get_modpath("skills").."/register_skills.lua")
