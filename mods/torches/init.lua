torches = {}
torches.enable_ceiling = minetest.setting_getbool("torches_enable_ceiling") or false
local style = minetest.setting_get("torches_style")

local modpath = minetest.get_modpath("torches")

-- load torch definition depending on stlye
if style == "minecraft" then
	dofile(modpath.."/mc_style.lua")
else
	dofile(modpath.."/mt_style.lua")
end
