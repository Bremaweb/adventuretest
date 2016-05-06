function hunger.update_hunger(player, new_lvl)
	local name = player:get_player_name() or nil
	if not name then
		return false
	end
	if minetest.setting_getbool("enable_damage") == false then
		pd.set(name,"hunger_lvl",20)
		return
	end
	local lvl = pd.get(name,"hunger_lvl")
	if new_lvl then
		 lvl = new_lvl
	end
	if lvl > HUNGER_MAX then
		lvl = HUNGER_MAX
	end
	pd.set(name,"hunger_lvl",lvl)
	if lvl > 20 then
		lvl = 20
	end
	hud.change_item(player, "hunger", {number = lvl})
end
local update_hunger = hunger.update_hunger

-- player-action based hunger changes
function hunger.handle_node_actions(pos, oldnode, player, ext)
	if not player or not player:is_player() then
		return
	end
	local name = player:get_player_name()
	local exhaus = pd.get_number(name,"hunger_exhaus")
	local lvl = pd.get_number(name,"hunger_lvl")
	if not exhaus then		
		exhaus = 0
		--return
	end

	local new = HUNGER_EXHAUST_PLACE

	-- placenode event
	if not ext then
		new = HUNGER_EXHAUST_DIG
	end

	-- assume its send by action_timer(globalstep)
	if not pos and not oldnode then
		new = HUNGER_EXHAUST_MOVE
	end

	exhaus = exhaus + new

	if exhaus > HUNGER_EXHAUST_LVL then
		exhaus = 0
		local h = lvl
		if h > 0 then
			update_hunger(player, h - 1)
		end
	end

	pd.set(name,"hunger_exhaus",exhaus)
end


function hunger_move(player,name,dtime)
	local controls = player:get_player_control()
	-- Determine if the player is walking
	if controls.up or controls.down or controls.left or controls.right then
		hunger.handle_node_actions(nil, nil, player)
	end
end
adventuretest.register_pl_hook(hunger_move,HUNGER_MOVE_TICK)

function do_hunger_tick(player,name,dtime)
	local name = player:get_player_name()			
	if minetest.check_player_privs(name, {immortal=true}) then
		update_hunger(player,20)
		return
	end
	
	local hunger = pd.get_number(name,"hunger_lvl")
	if hunger > 0 then
		pd.increment(name,"hunger_lvl",-1)
		update_hunger(player, hunger - 1)
	end
end
adventuretest.register_pl_hook(do_hunger_tick,HUNGER_TICK)

function do_health_tick(player,name,dtime)
	local name = player:get_player_name()
	local lvl = pd.get_number(name,"hunger_lvl")
	
	local air = player:get_breath() or 0
	local hp = player:get_hp()

	-- heal player by 1 hp if not dead and saturation is > 15 (of 30)
	if lvl > HUNGER_HEAL_LVL and air > 0 then
		player:set_hp(hp + HUNGER_HEAL)
	end

	-- or damage player by 1 hp if saturation is < 2 (of 30)
	if lvl < HUNGER_STARVE_LVL then
		player:set_hp(hp - HUNGER_STARVE)
	end
end
adventuretest.register_pl_hook(do_health_tick,HUNGER_HEALTH_TICK)
	
-- food functions
local food = hunger.food

function hunger.register_food(name, hunger_change, replace_with_item, poisen, heal, sound)
	food[name] = {}
	food[name].saturation = hunger_change	-- hunger points added
	food[name].replace = replace_with_item	-- what item is given back after eating
	food[name].poisen = poisen		-- time its poisening
	food[name].healing = heal		-- amount of HP
	food[name].sound = sound		-- special sound that is played when eating
end

-- Poison player
local function poisenp(tick, time, time_left, player)
	time_left = time_left + tick
	if time_left < time then
		minetest.after(tick, poisenp, tick, time, time_left, player)
	else
		hud.change_item(player, "hunger", {text = "hud_hunger_fg.png"})
	end
	local hp = player:get_hp() -1 or 0
	if hp > 0 then
		player:set_hp(hp)
	end
end

function hunger.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)
	local item = itemstack:get_name()
	local def = food[item]
	if not def then
		def = {}
		def.saturation = hp_change * 1.3
		def.replace = replace_with_item
	end
	local func = hunger.item_eat(def.saturation, def.replace, def.poisen, def.healing, def.sound)
	return func(itemstack, user, pointed_thing)
end

function hunger.item_eat(hunger_change, replace_with_item, poisen, heal, sound)
    return function(itemstack, user, pointed_thing)
	if itemstack:take_item() ~= nil and user ~= nil then
		local name = user:get_player_name()
		local sat = pd.get_number(name,"hunger_lvl")
		local hp = user:get_hp()
		-- Saturation
		if sat < HUNGER_MAX and hunger_change then
			sat = sat + hunger_change
			hunger.update_hunger(user, sat)
			if sat >= HUNGER_MAX then
				minetest.chat_send_player(name, "You feel full.");
			end
		end
		-- Healing
		if hp < 20 and heal then
			hp = hp + heal
			if hp > 20 then
				hp = 20
			end
			user:set_hp(hp)
		end
		-- Poison
		if poisen then
			hud.change_item(user, "hunger", {text = "hunger_statbar_poisen.png"})
			poisenp(1.0, poisen, 0, user)
		end

		-- eating sound
		if not sound then
			sound = "hunger_eat"
		end
		minetest.sound_play(sound, {to_player = name, gain = 0.7})

		itemstack:add_item(replace_with_item)
	end

	return itemstack
    end
end
