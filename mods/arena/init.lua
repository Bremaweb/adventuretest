-- each user can create one arena at a time, arena setups are index by the person who started it's name
-- this allows multiple arenas to be going on at one time


-- commands
-- /arena create <pos> <fee> 	<pos> the position the participants should meet at, <fee> if there is an entrace fee, winner gets the majority of the fee
-- /arena cancel		cancels arena
-- /arena start			starts the arena match
-- /arena join <name>   where player name is the player that started the arena, a player can only join one arena at a time
-- /arena leave			leaves the arena before it has started, this is not an option after it has started
-- /arena bet <name> <participant> <amount>		places a bet on participant
-- /arena list 			shows a list of the active arenas

-- Maybe this should be done with a formspec? Then arena blocks could be placed near arenas and the blocks location could be used as the pos in create


arena = {}
events = {}	-- a list of the arena events

function arena.create(name,pos,fee,desc)
	if ( events[name] == nil ) then
		events[name] = {name=name,pos=pos,fee=fee,description=desc,participants={},fees_collected=0}
		minetest.chat_send_all(name.." has created an arena event at "..minetest.pos_to_string(pos)..". Entrance fee is "..fee)
	else
		minetest.chat_send_player(name,'It looks like you already have an arena event setup')
	end
end 

function arena.cancel(name)
	if ( events[name] ~= nil ) then
		events[name] = nil
		minetest.chat_send_all(name.." has canceled their arena event")
	else
		minetest.chat_send_player(name,"You have not created an arena event")
	end
end

function arena.list(name)
	minetest.chat_send_player(name,'Arena Events:')
	
	for k,event in pairs(events) do
		minetest.chat_send_player(name,event.name.." Arena Event at "..minetest.pos_to_string(event.pos)..". "..event.fee.." Entrance Fee")
	end
end

function arena.in_arena(name)	
	for _,event in pairs(events) do
		if ( event.participants[name] == true ) then
			return event
		end
	end	
	return false
end

function arena.die(player)
	local name = player:get_player_name();
	
	event = arena.in_arena(name)
		event.participants[name] = false
		minetest.chat_send_all(name.." died in the arena!")
		
		if ( arena.has_winner(event) ) then
			
		end
	
end

function arena.join(name,event)
	if ( events[event] ~= nil ) then
		if ( arena.in_arena(name) ) then
			minetest.chat_send_player(name,"You are already signed up for an arena")
		else
			if ( money.get(name) >= events[event].fee ) then
				-- pay the entrance fee
				money.dec(name,events[event].fee)
				events[event].fees_collected = events[event].fees_collected + events[event].fee
				 
				events[event].participants[name]=true			
				minetest.chat_send_all(name.." has joined "..event.." arena event!")
			end			
		end
	end
end

function arena.create_formspec(name)
	local player = minetest.get_player_by_name(name);
	local formspec = "size[6,8;]"
	formspec = formspec.."label[.25,.25;Create Arena Event]"
	formspec = formspec.."label[.25,1;Location]"
	formspec = formspec.."field[.25,2;2,1;arena_x;X;"..math.floor(player:getpos().x).."]"
	formspec = formspec.."field[2.25,2;2,1;arena_y;Y;"..math.ceil(player:getpos().y).."]"
	formspec = formspec.."field[4.25,2;2,1;arena_z;Z;"..math.floor(player:getpos().z).."]"
	formspec = formspec.."field[.25,3.5;3,1;arena_fee;Entrance Fee;0]"
	formspec = formspec.."field[.25,5.25;5,1;arena_desc;Description;]"
	formspec = formspec.."button_exit[.25,6.5;2,1;arena_save;Create]"
	formspec = formspec.."button_exit[2.5,6.5;2,1;arena_cancel;Cancel]"
	
	return formspec
end

function arena.process_forms(player,formname,fields)
	if ( formname == "arena_create" ) then
		if ( fields.arena_save ) then
			arena.create(player:get_player_name(),{x=fields.arena_x,y=fields.arena_y,z=fields.arena_z},fields.arena_fee,fields.arena_desc)
		end
	end
end

minetest.register_on_player_receive_fields(arena.process_forms)

minetest.register_chatcommand("arena",{
	params = "create | cancel | list | join <name>",
	description = "Create or Manage Arenas",
	func = function (name, param)		
		local psplit = param:split(" ")		
		if ( psplit[1] == "create" ) then
			minetest.show_formspec(name,"arena_create", arena.create_formspec(name))
		end
		if ( psplit[1] == "list" ) then
			arena.list(name)
		end
		
		if ( psplit[1] == "cancel" ) then
			arena.cancel(name)
		end
		
		if ( psplit[1] == "join" ) then
			if ( psplit[2] ~= nil ) then
				arena.join(name,psplit[2])
			else
				minetest.chat_send_player("name","Usage is /arena join <event name>")
			end
		end
		
		if ( psplit[1] == "leave" ) then
			if ( event == arena.in_arena(name) ) then
				event.participants[name] = false
				minetest.chat_send_all(name.." died in the arena!")
			end
		end
	end,
	
})

--minetest.register_on_dieplayer(function (player)
	--if ( #events > 0 ) then
--		arena.die(player)
	--end	
	--return true
--end)

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end