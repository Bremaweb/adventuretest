
function mobs.register_icon(name,texture)
	minetest.register_entity(name, {
		physical = false,
		visual = "sprite",
		visual_size = { x=0.4,y=0.4 },
		textures = {texture},
		timeout = 0,
		timer = 0,
		on_step = function (self, dtime)
			self.timer = self.timer + dtime
			if self.timeout ~= false and self.timer > self.timeout then
				-- remove the entity when it times out
				self.object:remove()
			end
		end,
	})
end

function mobs.put_icon(obj,icon,timeout)
	local pos = obj.object:getpos()
	local iobj = minetest.add_entity({x=pos.x,y=(pos.y+3),z=pos.z},icon)
	if iobj ~= nil then
		iobj = iobj:get_luaentity()
		iobj.timeout = timeout
		iobj.object:set_attach(obj.object,"",{x = 0, y = 10, z = 0}, {x = 0, y = 0, z = 0})
	end
end

mobs.register_icon("mobs:icon_notice","mobs_icon_notice.png")
mobs.register_icon("mobs:icon_quest","mobs_icon_quest.png")
mobs.register_icon("mobs:icon_sell","mobs_icon_sell.png")