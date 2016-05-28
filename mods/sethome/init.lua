-- Some variables you can change

-- How often (in seconds) player can teleport
-- Set it to 0 to disable
local cooldown = 300
-- Max distance player can teleport, otherwise he will see error messsage
-- Set it to 0 to disable
local max_distance = 5000
----------------------------------

local function get_time()
    return os.time()
end

local function distance(a, b)
    return math.sqrt(math.pow(a.x-b.x, 2) + math.pow(a.y-b.y, 2) + math.pow(a.z-b.z, 2))
end

local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

local changed = false

minetest.register_privilege("home_other", "Can use /home <player> command")
minetest.register_privilege("sethome_other", "Can use /sethome <player> command")

minetest.register_chatcommand("home", {
    description = "Teleport you to your home point",
    func = function(name, param)
    	local pname = nil    	 
        if param ~= "" then
            if minetest.get_player_privs(name)["home_other"] then
                if pd.get(param,"homepos") then
                    minetest.chat_send_player(name, "The player doesn't have a home now! Set it using /sethome <player>.")
                    return
                end
                pname = param
            else
                minetest.chat_send_player(name, "You don't have permission to run this command (missing privileges: home_other)")
                return
            end
        else
        	pname = name
        end
        local last_moved = pd.get_number(pname,"last_moved")
    	local homepos = pd.get(pname,"homepos")
        local player = minetest.env:get_player_by_name(name)
        if player == nil then
            -- just a check to prevent server death
            return false
        end
        if homepos then
            local time = get_time()
            if cooldown ~= 0 and time - last_moved < cooldown then
                minetest.chat_send_player(name, "You can teleport only once in "..cooldown.." seconds. Wait another "..round(cooldown - (time - last_moved), 3).." secs...")
                return true
            end
            local pos = player:getpos()
            local dst = distance(pos, homepos)
            if max_distance ~= 0 and dst > max_distance then
                minetest.chat_send_player(name, "You are too far away from your home.")
                return true
            end
            pd.set(pname,"last_moved",time)
            pd.set(pname,"lastpos",homepos)            
            player:setpos(homepos)
            minetest.chat_send_player(name, "Teleported to home!")
        else
            if param ~= "" then
                minetest.chat_send_player(name, "The player doesn't have a home now! Set it using /sethome <player>.")
            else
                minetest.chat_send_player(name, "You don't have a home now! Set it using /sethome.")
            end
        end
    end,
})

minetest.register_chatcommand("sethome", {
    description = "Set your home point",
    func = function(name, param)
    	local pname = nil
        if param ~= "" then
            if minetest.get_player_privs(name)["sethome_other"] then
                pname = param
            else
                minetest.chat_send_player(name, "You don't have permission to run this command (missing privileges: sethome_other)")
                return
            end
        else
        	pname = name
        end
        
        local player = minetest.env:get_player_by_name(name)
        local pos = player:getpos()
        pd.set(pname,"homepos",pos)        
        minetest.chat_send_player(name, "Home set!")
        pd.save_player(pname)
    end,
})

function sethome_respawnplayer (player)
	local name = player:get_player_name()
	if minetest.check_player_privs(name,{immortal = true}) then
		return true
	end
	local homepos = pd.get(name,"homepos")
	if homepos ~= nil then
		adventuretest.teleport(player,homepos)
		--player:moveto(homepos)
		return true
	else	
		return false
	end
end


