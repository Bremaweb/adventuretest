arrows = {
	{"throwing:arrow", "throwing:arrow_entity"},
	{"throwing:arrow_fire", "throwing:arrow_fire_entity"},
	{"throwing:arrow_teleport", "throwing:arrow_teleport_entity"},
}

local shoot_timer = {}

local throwing_shoot_arrow = function(itemstack, player)
	if shoot_timer[player:get_player_name()] <= 0 or shoot_timer[player:get_player_name()] == nil then
		for _,arrow in pairs(arrows) do
			if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow[1] then
				if not minetest.setting_getbool("creative_mode") then
					player:get_inventory():remove_item("main", arrow[1])
				end
				local weapon = player:get_wielded_item()
				local weapon_def = weapon:get_definition() 
								
				local playerpos = player:getpos()
				local obj = minetest.env:add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2])
				local dir = player:get_look_dir()
				obj:setvelocity({x=dir.x*19, y=dir.y*19, z=dir.z*19})
				obj:setacceleration({x=dir.x*-3, y=weapon_def.drop_rate, z=dir.z*-3})
				obj:setyaw(player:get_look_yaw()+math.pi)
				obj:get_luaentity().player = player
				obj:get_luaentity().max_damage = obj:get_luaentity().max_damage + weapon_def.damage_modifier
				minetest.sound_play("throwing_sound", {object=player})
				obj:get_luaentity().node = player:get_inventory():get_stack("main", 1):get_name()
				if itemstack:get_definition().reload_time ~= nil then
					shoot_timer[player:get_player_name()] = itemstack:get_definition().reload_time 
				else
					shoot_timer[player:get_player_name()] = 2
				end
				return true
			end
		end
	end
	if itemstack:get_definition().reload_time ~= nil then
		shoot_timer[player:get_player_name()] = itemstack:get_definition().reload_time 
	else
		shoot_timer[player:get_player_name()] = 2
	end
	return false
end

minetest.register_tool("throwing:bow_wood", {
	description = "Wood Bow",
	inventory_image = "throwing_bow_wood.png",
    stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/50)
			end
		end
		return itemstack
	end,
	sounds = {[0]="throwing_arrow_hit1",[1]="throwing_arrow_hit2"},
	reload_time = 3,
	damage_modifier = 0,
	skill = SKILL_WOOD,
	drop_rate = -8,
})

minetest.register_craft({
	output = 'throwing:bow_wood',
	recipe = {
		{'farming:string', 'default:wood', ''},
		{'farming:string', '', 'default:wood'},
		{'farming:string', 'default:wood', ''},
	}
})

minetest.register_tool("throwing:bow_steel", {
	description = "Steel Bow",
	inventory_image = "throwing_bow_steel.png",
    stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/200)
			end
		end
		return itemstack
	end,
	sounds = {[0]="throwing_arrow_hit1",[1]="throwing_arrow_hit2"},
	reload_time = 2,
	damage_modifier = 5,
	-- skill = SKILL_STEEL,
	skill = SKILL_METAL,
	drop_rate = -4,
})

minetest.register_craft({
	output = 'throwing:bow_steel',
	recipe = {
		{'farming:string', 'default:steel_ingot', ''},
		{'farming:string', '', 'default:steel_ingot'},
		{'farming:string', 'default:steel_ingot', ''},
	}
})


local function do_shoot_timer(player,name,dtime)
	local name = player:get_player_name()
	if shoot_timer[name] ~= nil then
		shoot_timer[name] = shoot_timer[name] - dtime
	else
		shoot_timer[name] = 0
	end
end
adventuretest.register_pl_hook(do_shoot_timer,0)


dofile(minetest.get_modpath("throwing").."/arrow.lua")
dofile(minetest.get_modpath("throwing").."/fire_arrow.lua")
dofile(minetest.get_modpath("throwing").."/teleport_arrow.lua")

if minetest.setting_get("log_mods") then
	minetest.log("action", "throwing loaded")
end
