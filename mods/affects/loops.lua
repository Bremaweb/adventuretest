local function runAffects(player,name,dtime)	
	if ( affects._affectedPlayers[name] ) ~= nil then	
		for affectid,a in pairs(affects._affectedPlayers[name]) do
			applyAffect(name,affectid)
		end
	end
end
adventuretest.register_pl_hook(runAffects,15)

local function doSave()
	affects.saveAffects()
	minetest.after(affects.affectTime, doSave)
end
minetest.after(affects.affectTime, doSave)
