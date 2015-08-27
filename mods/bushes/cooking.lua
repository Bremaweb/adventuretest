-- Basket
minetest.register_node("bushes:basket_empty", {
    description = "Basket",
    tiles = {
	"bushes_basket_empty_top.png",
	"bushes_basket_bottom.png",
	"bushes_basket_side.png"
    },
    groups = { dig_immediate = 3 },
})

minetest.register_craft({
    output = 'bushes:basket_empty',
    recipe = {
	{ 'default:stick', 'default:stick', 'default:stick' },
	{ '', 'default:stick', '' },
    },
})

-- Sugar
minetest.register_craftitem("bushes:sugar", {
    description = "Sugar",
    inventory_image = "bushes_sugar.png",
    on_use = minetest.item_eat(1),
})

minetest.register_craft({
    output = 'bushes:sugar 1',
    recipe = {
	{ 'default:papyrus', 'default:papyrus' },
    },
})

-- Raw pie
minetest.register_craftitem("bushes:berry_pie_raw", {
    description = "Raw berry pie",
    inventory_image = "bushes_berry_pie_raw.png",
    on_use = minetest.item_eat(3),
})

minetest.register_craft({
    output = 'bushes:berry_pie_raw 1',
    recipe = {
	{ 'bushes:sugar', 'default:junglegrass', 'bushes:sugar' },
	{ 'bushes:strawberry', 'bushes:strawberry', 'bushes:strawberry' },
    },
})

-- Cooked pie
minetest.register_craftitem("bushes:berry_pie_cooked", {
    description = "Cooked berry pie",
    inventory_image = "bushes_berry_pie_cooked.png",
    on_use = minetest.item_eat(4),
})

minetest.register_craft({
    type = 'cooking',
    output = 'bushes:berry_pie_cooked',
    recipe = 'bushes:berry_pie_raw',
    cooktime = 30,
})

-- Basket with pies
minetest.register_node("bushes:basket_pies", {
    description = "Basket with pies",
    tiles = {
	"bushes_basket_full_top.png",
	"bushes_basket_bottom.png",
	"bushes_basket_side.png"
    },
    on_use = minetest.item_eat(15),
    groups = { dig_immediate = 3 },
})

minetest.register_craft({
    output = 'bushes:basket_pies 1',
    recipe = {
	{ 'bushes:berry_pie_cooked', 'bushes:berry_pie_cooked', 'bushes:berry_pie_cooked' },
	{ '', 'bushes:basket_empty', '' },
    },
})
