-- Minetest 0.4 mod: player
-- See README.txt for licensing and other information.

--[[

API
---

default.player_register_model(name, def)
^ Register a new model to be used by players.
^ <name> is the model filename such as "character.x", "foo.b3d", etc.
^ See Model Definition below for format of <def>.

default.registered_player_models[name]
^ See Model Definition below for format.

default.player_set_model(player, model_name)
^ <player> is a PlayerRef.
^ <model_name> is a model registered with player_register_model.

default.player_set_animation(player, anim_name [, speed])
^ <player> is a PlayerRef.
^ <anim_name> is the name of the animation.
^ <speed> is in frames per second. If nil, default from the model is used

default.player_set_textures(player, textures)
^ <player> is a PlayerRef.
^ <textures> is an array of textures
^ If <textures> is nil, the default textures from the model def are used

default.player_get_animation(player)
^ <player> is a PlayerRef.
^ Returns a table containing fields "model", "textures" and "animation".
^ Any of the fields of the returned table may be nil.

Model Definition
----------------

model_def = {
	animation_speed = 30, -- Default animation speed, in FPS.
	textures = {"character.png", }, -- Default array of textures.
	visual_size = {x=1, y=1,}, -- Used to scale the model.
	animations = {
		-- <anim_name> = { x=<start_frame>, y=<end_frame>, },
		foo = { x= 0, y=19, },
		bar = { x=20, y=39, },
		-- ...
	},
}

]]

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

default.registered_player_models = { }

-- Local for speed.
local models = default.registered_player_models

function default.player_register_model(name, def)
	models[name] = def
end

-- Default player appearance
default.player_register_model("character.x", {
	animation_speed = 30,
	textures = {"character.png", },
	animations = {
		-- Standard animations.
		stand     = { x=  0, y= 79, },
		lay       = { x=162, y=166, },
		walk      = { x=168, y=187, },
		mine      = { x=189, y=198, },
		walk_mine = { x=200, y=219, },
		-- Extra animations (not currently used by the game).
		sit       = { x= 81, y=160, },
	},
})

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}

function default.player_get_animation(player)
	local name = player:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

-- Called when a player's appearance needs to be updated
function default.player_set_model(player, model_name)
	local name = player:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		player:set_properties({
			mesh = model_name,
			textures = player_textures[name] or model.textures,
			visual = "mesh",
			visual_size = model.visual_size or {x=1, y=1},
		})
		default.player_set_animation(player, "stand")
	else
		player:set_properties({
			textures = { "player.png", "player_back.png", },
			visual = "upright_sprite",
		})
	end
	player_model[name] = model_name
end

function default.player_set_textures(player, textures)
	local name = player:get_player_name()
	player_textures[name] = textures
	player:set_properties({textures = textures,})
end

function default.player_set_animation(player, anim_name, speed)
	local name = player:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	player_anim[name] = anim_name
	player:set_animation(anim, speed or model.animation_speed, animation_blend)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	default.player_set_model(player, "character.x")
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
end)

-- Localize for better performance.
local player_set_animation = default.player_set_animation

-- Check each player and apply animations
function default.player_globalstep(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local model_name = player_model[name]
		local model = model_name and models[model_name]
		if model then
			local controls = player:get_player_control()
			local walking = false
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is walking
			if ( controls.up or controls.down or controls.left or controls.right ) and physics.player_frozen[name] ~= true then
				walking = true
			end

			-- Determine if the player is sneaking, and reduce animation speed if so
			if controls.sneak then
				animation_speed_mod = animation_speed_mod / 2
			end

			-- Apply animations based on what the player is doing
			if player:get_hp() == 0 then
				player_set_animation(player, "lay")
			elseif walking then
				if player_anim[name] == "lay" or player_anim[name] == "sit" then
					player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
					if player_sleephuds[name] ~= nil then
						player:hud_remove(player_sleephuds[name])
						player_sleephuds[name] = nil
					end
				end
				if player_sneak[name] ~= controls.sneak then
					player_anim[name] = nil
					player_sneak[name] = controls.sneak
				end
				if controls.LMB then
					player_set_animation(player, "walk_mine", animation_speed_mod)
				else
					player_set_animation(player, "walk", animation_speed_mod)
				end
			elseif controls.LMB then
				if player_anim[name] == "lay" or player_anim[name] == "sit" and physics.player_frozen[name] ~= true then
					player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
					if player_sleephuds[name] ~= nil then
						player:hud_remove(player_sleephuds[name])
						player_sleephuds[name] = nil
					end
				end
				player_set_animation(player, "mine")
			else
				if player_anim[name] ~= "lay" and player_anim[name] ~= "sit" then
					player_set_animation(player, "stand", animation_speed_mod)
				end
			end
		end
	end
end

if minetest.register_on_punchplayer ~= nil then
	minetest.register_on_punchplayer( function(player, hitter, time_from_last_punch, tool_capabilities, dir)
		process_weapon(player,time_from_last_punch,tool_capabilities)
		blood_particles(player:getpos(),0.5,27,"mobs_blood.png")
		if player_anim[name] == "lay" or player_anim[name] == "sit" then
			player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
			if player_sleephuds[name] ~= nil then
				player:hud_remove(player_sleephuds[name])
				player_sleephuds[name] = nil
			end
			physics.unfreeze_player(name)
		end
		if math.random(0,3) == 3 then
			local snum = math.random(1,4)
			minetest.sound_play("default_hurt"..tostring(snum),{object = player})
		end
	end)
end

