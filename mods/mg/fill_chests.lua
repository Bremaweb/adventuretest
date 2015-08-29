ADD_RCC2 = function( data )
	if( data and #data>3 and ( minetest.registered_nodes[ data[1] ] or minetest.registered_items[ data[1] ]) ) then
		table.insert( mg_villages.random_chest_content, data );
	end
end

minetest.after(5,function()
	ADD_RCC2({"farming:bread",				85,  3, 2, chest_storage=1, church=1, library=1, chest_private=1, shelf=1, shed=1, lumberjack=1, hut=1})
	ADD_RCC2({"mobs:meat_raw",				70,  2, 2, chest_storage=1, church=1, library=1, chest_private=1, shelf=1, shed=1, lumberjack=1, hut=1})
	ADD_RCC2({"bushes:berry_pie_cooked",	80, 4, 3, chest_storage=1, church=1, library=1, chest_private=1, shelf=1, shed=1, lumberjack=1, hut=1})
	ADD_RCC2({"throwing:arrow",				30, 1, 3, chest_storage=1, church=1, library=1, chest_private=1, shelf=1, shed=1, lumberjack=1, hut=1})
	ADD_RCC2({"farming:pumpkin_bread",		60, 3, 2, chest_storage=1, church=1, library=1, chest_private=1, shelf=1, shed=1, lumberjack=1, hut=1})
	ADD_RCC2({"farming_plus:potato_item",	66, 2, 2, chest_storage=1, church=1, library=1, chest_private=1, shelf=1, shed=1, lumberjack=1, hut=1})
	
	ADD_RCC2({"experience:1_exp",			90, 6, 1, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"experience:3_exp",			85, 3, 1, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"experience:6_exp",			60, 2, 1, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"experience:9_exp",			40, 1, 1, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"experience:12_exp",			30, 1, 1, chest_storage=1, chest_private=1, shelf=1})
	
	ADD_RCC2({"default:axe_stone",			20, 1, 0, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"default:axe_steel",			5, 1, 0, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"default:pick_stone",			20, 1, 0, chest_storage=1, chest_private=1, shelf=1})
	ADD_RCC2({"default:pick_steel",			5, 1, 0, chest_storage=1, chest_private=1, shelf=1})
end)