local thunder = {
	id = "thunder",
	type = "cast",
	desc = "Thunder Strike",
	level = 3,
	max_mana = 13,
	on_cast = function(spell, name, target)
		local p = minetest.get_player_by_name(name)
		local sk = skills.get_skill(name,SKILL_MAGIC)
		local skb = skills.get_def(SKILL_MAGIC)
		local rad = 15 * ( sk.level / 10 )
		local damage = ( 25 * ( sk.level / skb.max_level ) )
		local mana = spell.max_mana - ( ( (sk.level - 3) / skb.max_level ) * 10 )
		if magic.player_magic[name] >= mana then
			magic.player_magic[name] = magic.player_magic[name] - mana
			minetest.sound_play("spells_thunder",{object=p})
			for _,obj in ipairs(minetest.get_objects_inside_radius(p:getpos(), rad)) do
				if p ~= obj then
					obj:punch(p, 1.0, {
						full_punch_interval=1.0,
						damage_groups={fleshy=damage},
					}, nil)
				end
			end
		else
			minetest.chat_send_player(name,"You don't have enough magic to cast "..spell.desc)
		end
		magic.update_magic(p,name)
	end
}

magic.register_spell(thunder)