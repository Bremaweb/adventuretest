function affects.registerAffect( aDef )
	-- Here we validate some values and add it to the affects._affects table
	minetest.log("action","Registering affect: "..aDef.name)
	
	if ( aDef.affectid == nil ) then
		return false
	end

	if ( #aDef.stages < 1 ) then
		return false
	end
	
	if aDef.removeOnDeath ~= nil then
		table.insert(affects._removeOnDieAffects,aDef.affectid)
	end
	
	-- TODO add more checks here to ensure the affect definition won't crash the server	
	
	affects._affects[aDef.affectid] = aDef
	
end

function affects.removeAffect(name, affectid)
	if ( affects._affectedPlayers[name] ~= nil ) then
		if ( affectid == nil ) then
			return false
		else
		  if affects._affectedPlayers[name][affectid] ~= nil then
			   affects._affectedPlayers[name][affectid] = nil;
			   if ( affects._affects[affectid].onremove ~= nil ) then
				  local player = minetest.get_player_by_name(name)
				  --player:set_physics_override({ speed=1, jump=1,gravity=1,sneak=true })	-- reset their physics
				  affects._affects[affectid].onremove(name,player,affectid)
			   end
			end
			return true
		end
	end
	return false
end

function affects.affectPlayer(name, affectid)
	if ( affects._affectedPlayers[name] == nil ) then
		affects._affectedPlayers[name] = {}
	end
	
	if ( affects._affectedPlayers[name][affectid] == nil ) then
		if ( affects._affects[affectid] ~= nil ) then
			whoison.updateStats(name)
			local ns = ( whoison.getTimeOnline(name) + affects._affects[affectid].stages[1].time )
			affects._affectedPlayers[name][affectid] = { stage = 0, nextStage = 0, ran=false }
			applyAffect(name,affectid)
			return true
		else
			return false
		end
	end
end

function affects.default_on_use(itemstack,player,pointed_thing)
	local affectid = itemstack:get_definition().affectid
	local name = player:get_player_name()
	if pointed_thing.type == "object" then
		if pointed_thing.ref:is_player() then
			-- affect the player they are pointing at
			name = pointed_thing.ref:get_player_name()
		end
	end
	
	if ( affects.affectPlayer(name,affectid) ) then
		itemstack:take_item()
	end
	return itemstack
end

function affects.player_died(player)
	local name = player:get_player_name()
	for _,a in pairs(affects._removeOnDieAffects) do
		affects.removeAffect(name,a)
	end
end
 
