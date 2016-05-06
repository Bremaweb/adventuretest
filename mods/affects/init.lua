affects = {}

affects.affectTime = 15	-- how often, in seconds, should runAffects be called

affectsPath = minetest.get_modpath("affects")
affectsFile = minetest.get_worldpath().."/affects.txt"

affects._affects = {}
affects._affectedPlayers = {}
affects._removeOnDieAffects = {}

dofile(affectsPath.."/functions.lua")
dofile(affectsPath.."/api.lua")
dofile(affectsPath.."/loops.lua")
dofile(affectsPath.."/chatcommands.lua")
dofile(affectsPath.."/persistance.lua")

affects.loadAffects()

minetest.register_privilege("affects", "Player can use the affects chat commands.")

minetest.register_on_shutdown(function()
	affects.saveAffects()
end
)

-- TODO on join player apply physics from affects they are affected by