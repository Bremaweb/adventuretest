-- Only register one global step for this game and just call the respective globalstep functions
-- from within this function, preliminary testing shows that registering one globalstep and calling
-- all of your global step functions from there could slightly improve performance

function adventuretest_globalstep(dtime)
  default.player_globalstep(dtime)
  default.leaf_globalstep(dtime)
  energy_globalstep(dtime)
  hunger.global_step(dtime)
  itemdrop_globalstep(dtime)
  armor_globalstep(dtime)
  wieldview_globalstep(dtime)
  blacksmith_globalstep(dtime)
  throwing_globalstep(dtime)
  magic_globalstep(dtime)
  ambience_globalstep(dtime)
end

minetest.register_globalstep(adventuretest_globalstep)