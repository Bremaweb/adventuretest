STAT_DUG = 1
STAT_PLACED = 2
STAT_DIED = 3
STAT_TRAVEL = 4
STAT_PK = 5
STAT_KILLS = 6

strStat = {"Nodes Dug","Nodes Placed","Died","Distance Traveled","Players Killed","Mobs Killed"}

minetest.register_chatcommand("stats",{
	params = "",
	description = "Shows players stats",
	func = function(name, param)
		for i,d in pairs(strStat) do
			minetest.chat_send_player(name, d..": "..tostring(pd.get(name,i)))
		end
	end,
})
