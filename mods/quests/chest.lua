quests.chest = {}

quests.chest.go = function(npc,player)
  local inv = player:get_inventory()
  local pos = npc.object:getpos()
  if inv:contains_item("main","farming:flour") and inv:contains_item("main","food:bowl") then
    inv:remove_item("main","farming:flour")
    inv:remove_item("main","food:bowl")
    chat.local_chat(pos,"'Thank you very much, take this as a token of my appreciation!'",6)
    local lp = player:getpos()
    local yaw = mobs:face_pos(npc,lp)
    local vec = {x=lp.x-pos.x, y=1, z=lp.z-pos.z}
    local x = math.sin(yaw) * -2
    local z = math.cos(yaw) * 2
    local acc = {x=x, y=-5, z=z}
    if inv:contains_item("main","default:chest_locked") == false then
      default.drop_item(pos,"default:chest_locked",vec,acc)
    end
    if npc.rewards ~= nil then
      --print("Get rewards")
      for _, r in pairs(npc.rewards) do
        --print(r.item)
        if math.random(0,100) < r.chance then
          default.drop_item(pos,r.item, vec, acc)
        end
      end
    end
  else
    chat.local_chat(pos,"'Can you help me?'",12)
    minetest.after(2,chat.local_chat,pos,"'I need to finish my baking but I have ran out of flour and lost my bowl!'",12)
    minetest.after(3,chat.local_chat,pos,"'Can you bring me some flour and a bowl?'",12)
  end
end