local heal_spell = {
	id = "heal",
	desc = "Heal",
	type = "cast",
	level = 2,
	on_cast = function(spell,name,target)
		local t = nil
		local p = minetest.get_player_by_name(name)
		local sk = skills.get_skill(name,SKILL_MAGIC)
		local skb = skills.get_def(SKILL_MAGIC)
		local health = 5 + ( spell.max_health * ( sk.level / skb.max_level ) )
		local max_dist = 10 + (( sk.level / skb.max_level ) * 20 )
		if target ~= nil then
			t = minetest.get_player_by_name(target)
		else
			t = minetest.get_player_by_name(name)
		end
		if t ~= nil then 
		  if get_distance(t:getpos(),p:getpos()) < max_dist then
			 t:set_hp(t:get_hp() + health)
		  else
			 minetest.chat_send_player(name,tostring(target).." is too far away!")
		  end
		else
		  minetest.chat_send_player(name,tostring(target).." does not exist!")
		end
	end,
	max_mana = 15,
	max_health = 15,
}

magic.register_spell(heal_spell)