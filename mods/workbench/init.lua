-- Workbench mod by MirceaKitsune

-- Inventory crafting grid size. Use nil to leave the default formspec untouched, recommended if other mods change the inventory window.
local INVENTORY_CRAFT = 2

--
-- Internal workbench functions:
--

local function move_items(s_inv, s_listname, d_inv, d_listname,player)
	local list = s_inv:get_list(s_listname)
	for i in pairs(list) do
		local stack = s_inv:get_stack(s_listname,i)
		if stack:is_empty() ~= true then
			if d_inv:room_for_item(d_listname,stack) then
				d_inv:add_item(d_listname, stack)				
			else
				default.drop_item(player:getpos(),stack)
			end
			s_inv:set_stack(s_listname,i,nil)
		end
	end
end

local inventory_persistence = {}

local function inventory_set_size(player, size)
	size = math.min(6, math.max(1, size))
	local inv = player:get_inventory()	
	if inv:get_size("craft") ~= size*size then	
		inv:set_size("craft", size*size)
		inv:set_width("craft", size)
	end
end

local function inventory_set_formspec(player, size)
	size = math.min(6, math.max(1, size))
	local inv = player:get_inventory()
	local msize_x = math.min(inv:get_size("main"), 8)
	local msize_y = math.min(math.ceil(inv:get_size("main") / 8), 4)
	local fsize_x = math.max(msize_x, size + 2)
	local fsize_y = msize_y + size + 1.25

	local formspec = "size["..fsize_x..","..fsize_y.."]"
	..default.gui_bg
	..default.gui_bg_img
	..default.gui_slots
	.."list[current_player;main;"..(fsize_x-msize_x)..","..(fsize_y-msize_y)..";"..msize_x..",1;]"
	.."list[current_player;main;"..(fsize_x-msize_x)..","..(fsize_y-msize_y+1.25)..";"..msize_x..","..(msize_y - 1)..";"..msize_x.."]"
	.."list[current_player;craft;"..(fsize_x-size-2)..",0;"..size..","..size..";]"
	.."list[current_player;craftpreview;"..(fsize_x-1)..","..(size/2-0.5)..";1,1;]"
	.."listring[current_player;main]"
	.."listring[current_player;craft]"
	for i = 0, msize_x - 1, 1 do
		formspec = formspec.."image["..(fsize_x-msize_x + i)..","..(fsize_y-msize_y)..";1,1;gui_hb_bg.png]"
	end
	
	-- add the shortcut buttons
	if size ~= 3 then
		formspec = formspec .. "image_button[0.25,0.25;1,1;inventory_plus_zcg.png;zcg;]"
			.. "image_button[1.25,0.25;1,1;inventory_plus_skins.png;skins;]"
			.. "image_button[0.25,1.25;1,1;inventory_plus_armor.png;armor;]"
	end
	
	player:set_inventory_formspec(formspec)
end

local function inventory_set(player, size)
	local name = player:get_player_name()
	local inv = player:get_inventory()

	move_items(inv, "craft", inv, "main",player)
	-- When size is a number, we want to presist inventory settings and activate the workbench settings
	-- When size is nil, we want to re-activate the persisted inventory settings
	if not size then
		inv:set_size("craft", inventory_persistence[name].craft_size)
		inv:set_width("craft", inventory_persistence[name].craft_width)
		player:set_inventory_formspec(inventory_persistence[name].formspec)
		inventory_persistence[name] = nil
	else
		inventory_persistence[name] = {}
		inventory_persistence[name].craft_size = inv:get_size("craft")
		inventory_persistence[name].craft_width = inv:get_width("craft")
		inventory_persistence[name].formspec = player:get_inventory_formspec()

		inventory_set_size(player, size)
		inventory_set_formspec(player, size)
	end
end

local function on_craft(itemstack,player,old_craftgrid,craft_inv)
  if itemstack:get_definition().skill ~= nil then
  	local name = player:get_player_name()
    local probability = skills.get_probability(name,SKILL_CRAFTING,itemstack:get_definition().skill)
    local rangeLow = ( probability - 10 ) / 100
    probability = probability / 100
    local wear = math.floor(50000 - ( 50000 * math.random(rangeLow,probability) ))
    itemstack:add_wear(wear)
    local i = skills.add_skill_exp(name,SKILL_CRAFTING,1)
    local ii = skills.add_skill_exp(name,itemstack:get_definition().skill,1)
    if  i or ii  then
    	minetest.chat_send_player(name,"Your skills are increasing!")
    end
    return itemstack
  end
  return nil
end

minetest.register_on_craft(on_craft)

minetest.register_on_joinplayer(function(player)
	if minetest.setting_getbool("creative_mode") then
		inventory_set_size(player, 3)
	elseif INVENTORY_CRAFT then
		minetest.after(0, function()
			inventory_set_size(player, INVENTORY_CRAFT)
			inventory_set_formspec(player, INVENTORY_CRAFT)
		end)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "workbench:workbench" and fields.quit then
		inventory_set(player, _)
	end
end)

--
-- Item definitions:
--

minetest.register_node("workbench:3x3", {
	description = "WorkBench",
	tiles = {"workbench_3x3_top.png", "workbench_3x3_bottom.png", "workbench_3x3_side.png",
		"workbench_3x3_side.png", "workbench_3x3_side.png", "workbench_3x3_front.png"},
	paramtype2 = "facedir",
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Workbench")
	end,
	on_rightclick = function(pos, node, clicker)
		inventory_set(clicker, 3)
		minetest.show_formspec(clicker:get_player_name(), "workbench:workbench", clicker:get_inventory_formspec())
	end,
})

minetest.register_craft({
	output = 'workbench:3x3',
	recipe = {
		{'group:wood', 'group:wood', ''},
		{'group:wood', 'group:wood', ''},
		{'', '', ''},
	}
})
