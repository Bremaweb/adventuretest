function farming:place_seed(itemstack, placer, pointed_thing, plantname)

	-- Call on_rightclick if the pointed node defines it
	if pointed_thing.type == "node" and placer and
		not placer:get_player_control().sneak then
		local n = minetest.get_node(pointed_thing.under)
		local nn = n.name
		if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].on_rightclick then
			return minetest.registered_nodes[nn].on_rightclick(pointed_thing.under, n,
			placer, itemstack, pointed_thing) or itemstack, false
		end
	end

	local pt = pointed_thing
	-- check if pointing at a node
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end

	local under = minetest.get_node(pt.under)
	local above = minetest.get_node(pt.above)

	-- return if any of the nodes is not registered
	if not minetest.registered_nodes[under.name] then
		return
	end
	if not minetest.registered_nodes[above.name] then
		return
	end

	-- check if pointing at the top of the node
	if pt.above.y ~= pt.under.y+1 then
		return
	end

	-- check if you can replace the node above the pointed node
	if not minetest.registered_nodes[above.name].buildable_to then
		return
	end

	-- check if pointing at soil
	if minetest.get_item_group(under.name, "soil") <= 1 then
		return
	end

	-- add the node and remove 1 item from the itemstack
	minetest.add_node(pt.above, {name=plantname})
	if not minetest.setting_getbool("creative_mode") then
		itemstack:take_item()
	end
	return itemstack
end

function farming:add_plant(full_grown, names, interval, chance)
	minetest.register_abm({
		label = "growing "..full_grown,
		nodenames = names,
		neighbors = {"group:soil"},
		interval = interval,
		chance = chance,
		action = function(pos, node)
			if not minetest.get_node_light(pos,0.5) then
				return
			end
			if minetest.get_node_light(pos,0.5) < 8 then
				return
			end
			local step = nil
			for i,name in pairs(names) do
				if name == node.name then
					step = i
					break
				end
			end
			if step == nil then
				return
			end
			
			pos.y = pos.y-1
			local n = minetest.get_node(pos)
			if minetest.get_item_group(n.name, "soil") < 3 then
				if step > 1 and randomChance(30) then
					step = step - 2
				else
					return
				end
			end
			pos.y = pos.y + 1
			local new_node = {name=names[step+1]}
			if new_node.name == nil then
				new_node.name = full_grown
			end
			minetest.set_node(pos, new_node)
		end
	})

	table.insert(farming.registered_plants, {
		full_grown = full_grown,
		names = names,
		interval = interval,
		chance = chance,
	})
end

function farming:generate_tree(pos, trunk, leaves, underground, replacements)
	pos.y = pos.y-1
	local nodename = minetest.get_node(pos).name
	local ret = true
	for _,name in pairs(underground) do
		if nodename == name then
			ret = false
			break
		end
	end
	pos.y = pos.y+1
	if not minetest.get_node_light(pos,0.5) then
		return
	end
	if ret or minetest.get_node_light(pos,0.5) < 8 then
		return
	end
	
	node = {name = ""}
	for dy=1,4 do
		pos.y = pos.y+dy
		if minetest.get_node(pos).name ~= "air" then
			return
		end
		pos.y = pos.y-dy
	end
	node.name = trunk
	for dy=0,4 do
		pos.y = pos.y+dy
		minetest.set_node(pos, node)
		pos.y = pos.y-dy
	end
	
	if not replacements then
		replacements = {}
	end
	
	node.name = leaves
	pos.y = pos.y+3
	for dx=-2,2 do
		for dz=-2,2 do
			for dy=0,3 do
				pos.x = pos.x+dx
				pos.y = pos.y+dy
				pos.z = pos.z+dz
				
				if dx == 0 and dz == 0 and dy==3 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
							end
						end
					end
				elseif dx == 0 and dz == 0 and dy==4 then
					if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
						minetest.set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
							end
						end
					end
				elseif math.abs(dx) ~= 2 and math.abs(dz) ~= 2 then
					if minetest.get_node(pos).name == "air" then
						minetest.set_node(pos, node)
						for name,rarity in pairs(replacements) do
							if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
							end
						end
					end
				else
					if math.abs(dx) ~= 2 or math.abs(dz) ~= 2 then
						if minetest.get_node(pos).name == "air" and math.random(1, 5) <= 4 then
							minetest.set_node(pos, node)
							for name,rarity in pairs(replacements) do
								if math.random(1, rarity) == 1 then
								minetest.set_node(pos, {name=name})
								end
							end
						end
					end
				end
				
				pos.x = pos.x-dx
				pos.y = pos.y-dy
				pos.z = pos.z-dz
			end
		end
	end
end