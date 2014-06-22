-- Some variables you can change

-- How often (in seconds) player can teleport
-- Set it to 0 to disable
local cooldown = 300
-- Max distance player can teleport, otherwise he will see error messsage
-- Set it to 0 to disable
local max_distance = 5000
----------------------------------

local homes_file = minetest.get_worldpath()..'/homes'
--local homes_file = minetest.get_worldpath() .. "/homes"
local homepos = {}
local last_moved = {}

local function loadhomes()
    local input = io.open(homes_file, "r")
    if input then
        while true do
            local x = input:read("*n")
            if x == nil then
                break
            end
            local y = input:read("*n")
            local z = input:read("*n")
            local name = input:read("*l")
            homepos[name:sub(2)] = {x = x, y = y, z = z}
        end
        io.close(input)
    else
        homepos = {}
    end
end

loadhomes()

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
        if param ~= "" then
            if minetest.get_player_privs(name)["home_other"] then
                if not homepos[param] then
                    minetest.chat_send_player(name, "The player doesn't have a home now! Set it using /sethome <player>.")
                    return
                end
                player_name = param
            else
                minetest.chat_send_player(name, "You don't have permission to run this command (missing privileges: home_other)")
                return
            end
        end
        if player_name then pname = player_name else pname = name end
        local player = minetest.env:get_player_by_name(name)
        if player == nil then
            -- just a check to prevent server death
            return false
        end
        if homepos[pname] then
            local time = get_time()
            if cooldown ~= 0 and last_moved[name] ~= nil and time - last_moved[name] < cooldown then
                minetest.chat_send_player(name, "You can teleport only once in "..cooldown.." seconds. Wait another "..round(cooldown - (time - last_moved[name]), 3).." secs...")
                return true
            end
            local pos = player:getpos()
            local dst = distance(pos, homepos[pname])
            if max_distance ~= 0 and distance(pos, homepos[pname]) > max_distance then
                minetest.chat_send_player(name, "You are too far away from your home.")
                return true
            end
            last_moved[name] = time
            player:setpos(homepos[pname])
            minetest.chat_send_player(name, "Teleported to home!")
        else
            if param ~= "" then
                minetest.chat_send_player(name, "The player don't have a home now! Set it using /sethome <player>.")
            else
                minetest.chat_send_player(name, "You don't have a home now! Set it using /sethome.")
            end
        end
    end,
})

minetest.register_chatcommand("sethome", {
    description = "Set your home point",
    func = function(name, param)
        if param ~= "" then
            if minetest.get_player_privs(name)["sethome_other"] then
                player_name = param
            else
                minetest.chat_send_player(name, "You don't have permission to run this command (missing privileges: sethome_other)")
                return
            end
        end
        if player_name then pname = player_name else pname = name end
        local player = minetest.env:get_player_by_name(name)
        local pos = player:getpos()
        homepos[pname] = pos
        minetest.chat_send_player(name, "Home set!")
         local output = io.open(homes_file, "w")
        for i, v in pairs(homepos) do
            output:write(v.x.." "..v.y.." "..v.z.." "..i.."\n")
        end
        io.close(output)
    end,
})

minetest.register_on_respawnplayer( function (player)
	local name = player:get_player_name()
	if minetest.check_player_privs(name,{immortal = true}) then
		return true
	end
	if homepos[name] ~= nil then
		player:moveto(homepos[name])
		return true
	else
		return false
	end
end)


