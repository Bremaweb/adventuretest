-- several experience blocks, registered as craft items
-- to craft smaller experience into larger experience orgs all experience will have to be divisible by 3... 1, 3, 6, 9
experience = { }
-- register experience items
local exp = 0
for e = 1, 13, 3 do
	if e > 1 then
		exp = e - 1
	else
		exp = e
	end
	minetest.register_craftitem("experience:"..tostring(exp).."_exp", {
		description = tostring(exp).." Experience",
		inventory_image = "experience_"..tostring(exp)..".png",
		exp_value=exp,
		stack_max = 999,
	})
	minetest.log("action","Generating "..tostring(exp).." Experience Orb")
end

function experience.exp_to_items(exp)
	-- this function takes the amount of experience, 
	-- and returns a table containing the number of items required to make that amount of expericne
	local exp_table = { }
	local remaining = exp
	for e = 12, 0, -3 do
		if  e == 0 then
			ee = 1
		else
			ee = e
		end
		ef = math.floor(remaining / ee)
		remaining = remaining % ee
		if ef > 0 then
			table.insert(exp_table, ItemStack("experience:"..tostring(ee).."_exp " .. tostring(ef)))
		end
	end
	return exp_table
end
