     --= Book (use to read or write to)

    minetest.register_craftitem("books_plus:booklocked", {
       description = "Locked Book",
       inventory_image = "booklocked.png",
       groups = {book=1,locked_book=1},
       stack_max = 1,
       on_use = function(itemstack, user, pointed_thing)
          local player_name = user:get_player_name()
          local data = minetest.deserialize(itemstack:get_metadata())
          local title, text, owner = "", "", player_name
          if data then
             title, text, owner = data.title, data.text, data.owner
			 
          end
          local formspec
          if owner == player_name or owner=="" then
             formspec = "size[8,8]"..default.gui_bg.. -- default.gui_bg_img..
                "field[0.5,1;7.5,0;title;Title:;"..
                   minetest.formspec_escape(title).."]"..
                "textarea[0.5,1.5;7.5,7;text;Contents:;"..
                   minetest.formspec_escape(text).."]"..
                "button_exit[2.5,7.5;3,1;save;Save]"
             minetest.show_formspec(user:get_player_name(), "default:book", formspec)
          else
             formspec = "size[8,8]"..default.gui_bg.. -- default.gui_bg_img..
                "button_exit[7,0.25;1,0.5;close;x]"..
                "label[0.5,0;"..minetest.formspec_escape(title).."]"..
                "label[0.5,0.5;by "..owner.."]"..
                "textarea[0.5,1.5;7.5,7;text;;"..
                   minetest.formspec_escape(text).."]"
             minetest.show_formspec(user:get_player_name(), "default:lockedbook", formspec)
          end
       end,
    })

    minetest.register_on_player_receive_fields(function(player, form_name, fields)
       if form_name ~= "default:book" or not fields.save then
          return
       end
	   
       local stack = player:get_wielded_item()
	   local empty_book=minetest.get_item_group(stack:get_name(), "empty_book") == 1
	   local book_written=minetest.get_item_group(stack:get_name(), "book") == 1
       if (not empty_book) and (not book_written) then
          return
       end
	    --print("fields1:"..dump(fields))
		--print("data1:"..dump(data))
       local data = minetest.deserialize(stack:get_metadata())
       if not data then data = {} end
       data.title, data.text, data.owner =
          fields.title, fields.text, player:get_player_name()
		if empty_book then
			if  (fields.title=="" and fields.text=="") then
				return
			end
			if stack:get_count()>1 then
				local stack2=ItemStack("books_plus:written_book")
				playerinv=player:get_inventory()
				if playerinv:room_for_item("main", stack2) then
					stack2:set_metadata(minetest.serialize(data))
					stack:take_item(1)
					playerinv:add_item("main", stack2)
					player:set_wielded_item(stack)
				end
			else
				local stack2=ItemStack("books_plus:written_book")
				stack2:set_metadata(minetest.serialize(data))
				player:set_wielded_item(stack2)
			end

		else
			--print("fields:"..dump(fields))
			--print("data:"..dump(data))
			
		if fields.title=="" and fields.text=="" then
			if minetest.get_item_group(stack:get_name(), "locked_book") == 1 then
				data.owner=""
			else
				stack:replace("default:book")
			end
		end
       stack:set_metadata(minetest.serialize(data))
       player:set_wielded_item(stack)
	   
	  end
    end)

minetest.register_craft({
	type = "shapeless",
	output = "default:book",
	recipe = {"books_plus:written_book", "dye:white"},
})
--[[
minetest.register_node("books_plus:writing_table", {
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.3125, -0.5, 0.5, 0.5, 0.5}, -- NodeBox9
			{0.375, -0.5, -0.5, 0.5, 0.3125, -0.375}, -- NodeBox11
			{0.375, -0.5, 0.375, 0.5, 0.3125, 0.5}, -- NodeBox12
			{-0.5, -0.5, 0.375, -0.375, 0.3125, 0.5}, -- NodeBox14
			{-0.5, -0.5, -0.5, -0.375, 0.375, -0.375}, -- NodeBox15
		}
	}
})
--]]
 minetest.register_craftitem(":default:book", {
       description = "Book",
       inventory_image = "default_book.png",
       groups = {empty_book=1},
       stack_max = 99,
       on_use = function(itemstack, user, pointed_thing)
          local title="" 
		  local text = ""
          local formspec

             formspec = "size[8,8]"..default.gui_bg.. -- default.gui_bg_img..
                "field[0.5,1;7.5,0;title;Title:;"..
                   minetest.formspec_escape(title).."]"..
                "textarea[0.5,1.5;7.5,7;text;Contents:;"..
                   minetest.formspec_escape(text).."]"..
                "button_exit[2.5,7.5;3,1;save;Save]"
             minetest.show_formspec(user:get_player_name(), "default:book", formspec) 
       end,
    })
	 minetest.register_craftitem("books_plus:written_book", {
       description = "Book written",
       inventory_image = "default_book.png",
       groups = {book=1},
       stack_max = 1,
       on_use = function(itemstack, user, pointed_thing)
          local player_name = user:get_player_name()
          local data = minetest.deserialize(itemstack:get_metadata())
          local title="" 
		  local text = ""
          if data then
             title, text = data.title, data.text
          end
          local formspec

             formspec = "size[8,8]"..default.gui_bg.. -- default.gui_bg_img..
                "field[0.5,1;7.5,0;title;Title:;"..
                   minetest.formspec_escape(title).."]"..
                "textarea[0.5,1.5;7.5,7;text;Contents:;"..
                   minetest.formspec_escape(text).."]"..
                "button_exit[2.5,7.5;3,1;save;Save]"
             minetest.show_formspec(user:get_player_name(), "default:book", formspec)
  
          
       end,
    })
	
	
minetest.register_craft({
   type ="shapeless",
   output = "books_plus:booklocked",
   recipe ={'default:book', "default:steel_ingot"},

})