function affects.saveAffects()
	minetest.log("action","Saving player affects")
	local f = io.open(affectsFile,"w")
	f:write(minetest.serialize(affects._affectedPlayers))
	f:close()	
end

function affects.loadAffects()
	minetest.log("action","Loading player affects")
	local f = io.open(affectsFile,"r")
	if ( f ~= nil ) then
		local af = f:read("*all")
		f:close()
		if ( af ~= nil and af ~= "" ) then
			affects._affectedPlayers = minetest.deserialize(af)
		end
	end
end
 
