function applyAffect(name,affectid)
	whoison.updateStats(name)
	local player = minetest.get_player_by_name(name)
	local oStage = affects._affectedPlayers[name][affectid].stage
	local stageChange = false
	minetest.log("action","Applying affect "..affectid.." stage " .. tostring(oStage) .. " on "..name)
	-- see if they need advanced into the next stage	
	if ( affects._affectedPlayers[name][affectid].nextStage < whoison.getTimeOnline(name) ) then
		local nextStageNum = affects._affectedPlayers[name][affectid].stage + 1
		affects._affectedPlayers[name][affectid].stage = nextStageNum
		affects._affectedPlayers[name][affectid].ran = false
		minetest.log("action","Advancing "..affectid.." to the next stage for "..name)
		if ( #affects._affects[affectid].stages < nextStageNum ) then
			minetest.log("action","Affect "..affectid.." has worn off of "..name)
			affects.removeAffect(name,affectid)
			return
		end		
		affects._affectedPlayers[name][affectid].nextStage = (whoison.getTimeOnline(name) + affects._affects[affectid].stages[nextStageNum].time)
		-- apply physics on stage changes
		stageChange = true
	end
	
	local iStage = affects._affectedPlayers[name][affectid].stage
	local stage = affects._affects[affectid].stages[iStage]
	local oPhysics = stage.physics

	if stageChange == true then
		if ( oPhysics ~= nil ) then		
			physics.adjust_physics(player,oPhysics)
		end
	end	
	
	if ( stage.damage ~= nil ) then
		if ( randomChance(stage.damage.chance) ) then			
			player:set_hp( player:get_hp() - stage.damage.amount )
		end
	end
	
	if ( stage.emote ~= nil ) then
		if ( randomChance(stage.emote.chance) ) then			
			minetest.chat_send_all(name.." "..stage.emote.action)
		end
	end
	
	if ( stage.place ~= nil ) then
		if ( randomChance(stage.place.chance) ) then
			minetest.place_node(player:getpos(),{name=stage.place.node, param1=0, param2=0})	
		end
	end
	
	if ( stage.custom ~= nil ) then
		if ( stage.custom.runonce == true and affects._affectedPlayers[name][affectid].ran == true ) then			
			return
		end
		if ( randomChance(stage.custom.chance) ) then
			affects._affectedPlayers[name][affectid].ran = true			
			stage.custom.func(name,player,affectid)
		end
	end	
end