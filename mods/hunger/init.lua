hunger = {}
hunger.food = {}

HUNGER_TICK = 60		-- time in seconds after that 1 hunger point is taken
HUNGER_HEALTH_TICK = 8		-- time in seconds after player gets healed/damaged
HUNGER_MOVE_TICK = 0.5		-- time in seconds after the movement is checked

HUNGER_EXHAUST_DIG = 3		-- exhaustion increased this value after digged node
HUNGER_EXHAUST_PLACE = 1	-- exhaustion increased this value after placed
HUNGER_EXHAUST_MOVE = 1.5	-- exhaustion increased this value if player movement detected
HUNGER_EXHAUST_LVL = 160	-- at what exhaustion player saturation gets lowered

HUNGER_HEAL = 1			-- number of HP player gets healed after HUNGER_HEALTH_TICK
HUNGER_HEAL_LVL = 15		-- lower level of saturation needed to get healed
HUNGER_STARVE = 2		-- number of HP player gets damaged by hunger after HUNGER_HEALTH_TICK
HUNGER_STARVE_LVL = 0.5		-- level of staturation that causes starving

HUNGER_MAX = 30			-- maximum level of saturation


local modpath = minetest.get_modpath("hunger")
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/food.lua")
dofile(modpath .. "/legacy.lua")


minetest.register_on_item_eat(hunger.eat)

