local function runAffects()	
	for _,player in ipairs( minetest.get_connected_players() ) do
		local name = player:get_player_name()
		if ( affects._affectedPlayers[name] ) ~= nil then	
			for affectid,a in pairs(affects._affectedPlayers[name]) do
				applyAffect(name,affectid)
			end
		end
	end
	affects.saveAffects()
	minetest.after(affects.affectTime, runAffects)
end

minetest.after(affects.affectTime, runAffects)
