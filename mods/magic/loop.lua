local magicTick = 4
local magicTickCount = 0

function magic_globalstep(dtime)
  magicTickCount = magicTickCount + dtime
  if ( magicTickCount > magicTick ) then
    for _,player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      magic.update_magic(player,name)
    end
    magicTickCount = 0
  end
end

