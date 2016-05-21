cmsg = {}
cmsg.hudids = {}
cmsg.messages = {}
cmsg.settings = {}
cmsg.next_msgids = {}

cmsg.settings.max_messages = 7
local setting = minetest.setting_get("central_message_max")
if type(tonumber(setting)) == "number" then
	cmsg.settings.max_messages = tonumber(setting)
elseif setting == "inf" then
	cmsg.settings.max_messages = nil
end

cmsg.settings.color = 0xFFFFFF
setting = minetest.setting_get("central_message_color")
if type(tonumber(setting)) == "number" then
	cmsg.settings.color = tonumber(setting)
end

local function update_display(player, pname)
	local messages = {}
	local start, stop
	stop = #cmsg.messages[pname]
	if cmsg.settings.max_messages ~= nil then
		local max = math.min(cmsg.settings.max_messages, #cmsg.messages[pname])
		if #cmsg.messages[pname] > cmsg.settings.max_messages then
			start = stop - max
		else
			start = 1
		end
	else
		start = 1
	end
	for i=start, stop do
		table.insert(messages, cmsg.messages[pname][i].text)
	end
	local concat = table.concat(messages, "\n")
	player:hud_change(cmsg.hudids[pname], "text", concat)
end

cmsg.push_message_player = function(player, text)
	local function push(tbl)
		-- Horrible Workaround code starts here
		if not (cmsg.last_push < cmsg.steps) then
			minetest.after(0, push, tbl)
			return
		end

		local player = tbl.player
		local text = tbl.text
		-- Horrible Workaround code ends here

		local pname = player:get_player_name()
		if cmsg.hudids[pname] == nil then
			cmsg.hudids[pname] = player:hud_add({
				hud_elem_type = "text",
				text = text,
				number = cmsg.settings.color,
				position = {x=0.5, y=0.5},
				offset = {x=-0,y=-256},
				direction = 3,
				alignment = {x=0,y=1},
				scale = {x=800,y=20*cmsg.settings.max_messages},
			})
			cmsg.messages[pname] = {}
			cmsg.next_msgids[pname] = 0
			table.insert(cmsg.messages[pname], {text=text, msgid=cmsg.next_msgids[pname]})
		else
			cmsg.next_msgids[pname] = cmsg.next_msgids[pname] + 1
			table.insert(cmsg.messages[pname], {text=text, msgid=cmsg.next_msgids[pname]})
			update_display(player, pname)
		end

		minetest.after(8, function(param)
			local pname = param.player:get_player_name()
			for i=1, #cmsg.messages[pname] do
				if param.msgid == cmsg.messages[pname][i].msgid then
					table.remove(cmsg.messages[pname], i)
					break
				end
			end
			update_display(player, pname)
		end, {player=player, msgid=cmsg.next_msgids[pname]})
	
		-- Update timer for Horrible Workaround
		cmsg.last_push = cmsg.steps
	end

	if cmsg.last_push < cmsg.steps then
		push({player=player, text=text})
	else
		minetest.after(0, push, {player=player, text=text})
	end
end

cmsg.push_message_all = function(text)
	local players = minetest.get_connected_players()
	for i=1,#players do
		cmsg.push_message_player(players[i], text)
	end
end

minetest.register_on_leaveplayer(function(player)
	cmsg.hudids[player:get_player_name()] = nil
end)

-- Horrible Workaround code starts here
cmsg.steps = 0
cmsg.last_push = -1
minetest.register_globalstep(function(dtime)
	cmsg.steps = cmsg.steps + 1
end)
-- Horrible Workaround code ends here
