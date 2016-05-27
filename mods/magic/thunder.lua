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
		minetest.sound_play("magic_thunder",{object=p})
		for _,obj in pairs(minetest.get_objects_inside_radius(p:getpos(), rad)) do
			if p ~= obj then
				obj:punch(p, 1.0, {
					full_punch_interval=1.0,
					damage_groups={fleshy=damage},
				}, nil)
			end
		end
	end,
}

magic.register_spell(thunder)