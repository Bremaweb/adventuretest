stats = {}
local player_stats = {}

dofile(minetest.get_modpath("player_stats").."/const.lua")

stats.load = function ( name )
	player_stats[name] = default.deserialize_from_file(minetest.get_worldpath() .. "/players/" .. name ..".stats")
end

stats.save = function (name)
	default.serialize_to_file(minetest.get_worldpath() .. "/players/" .. name .. ".stats",player_stats[name])
end

stats.save_all = function()
	for name,s in pairs(player_stats) do
		if s ~= nil then
			stats.save(name)
		end
	end
	minetest.after(600,stats.save_all)
end

stats.unload = function(name)
	player_stats[name] = nil
end

stats.set = function (name, stat, value)
	if player_stats[name] ~= nil then
		player_stats[name][stat] = value
	end
end

stats.get = function (name, stat)
	return player_stats[name][stat]
end

stats.increment = function (name, stat, amount)
	print("increment stat "..tostring(stat).." by "..tostring(amount))
	if player_stats[name] ~= nil then
		if tonumber(player_stats[name][stat]) ~= nil then
			player_stats[name][stat] = player_stats[name][stat] + amount
		else
			player_stats[name][stat] = amount	-- stat wasn't set or was invalid so reset it
		end
	end
end

minetest.after(600,stats.save_all)

minetest.register_chatcommand("stats",{
	params = "",
	description = "Shows players stats",
	func = function(name, param)
		for i,d in pairs(strStat) do
			minetest.chat_send_player(name, d..": "..tostring(player_stats[name][i]))
		end
	end,
})
