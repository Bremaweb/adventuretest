
-- Version: 2.2
-- Autor:   Sokomine
-- License: GPLv3
--
-- Modified:
-- 27.07.15 Moved into its own repository.
--          Made sure textures and craft receipe indigrents are available or can be replaced.
--          Took care of "unregistered globals" warnings.
-- 23.01.14 Added conversion receipes in case of installed castle-mod (has its own anvil)
-- 23.01.14 Added hammer and anvil as decoration and for repairing tools.
--          Added hatches (wood and steel).
--          Changed the texture of the fence/handrail.
-- 17.01.13 Added alternate receipe for fences in case of interference due to xfences
-- 14.01.13 Added alternate receipes for roof parts in case homedecor is not installed.
--          Added receipe for stove pipe, tub and barrel.
--          Added stairs/slabs for dirt road, loam and clay
--          Added fence_small, fence_corner and fence_end, which are useful as handrails and fences
--          If two or more window shutters are placed above each other, they will now all close/open simultaneously.
--          Added threshing floor.
--          Added hand-driven mill.

cottages = {}

-- Boilerplate to support localized strings if intllib mod is installed.
if minetest.get_modpath( "intllib" ) and intllib then
	cottages.S = intllib.Getter()
else
	cottages.S = function(s) return s end
end

--cottages.config_use_mesh_barrel   = false;
--cottages.config_use_mesh_handmill = true;

-- set alternate crafting materials and textures where needed
-- (i.e. in combination with realtest)
dofile(minetest.get_modpath("cottages").."/adaptions.lua");

-- add to this table what you want the handmill to convert;
-- add a stack size if you want a higher yield
cottages.handmill_product = {};
cottages.handmill_product[ cottages.craftitem_seed_wheat ] = 'farming:flour 1';
--[[ some examples:
cottages.handmill_product[ 'default:cobble' ] = 'default:gravel';
cottages.handmill_product[ 'default:gravel' ] = 'default:sand';
cottages.handmill_product[ 'default:sand'   ] = 'default:dirt 2';
cottages.handmill_product[ 'flowers:rose'   ] = 'dye:red 6';
cottages.handmill_product[ 'default:cactus' ] = 'dye:green 6';
cottages.handmill_product[ 'default:coal_lump'] = 'dye:black 6';
--]]
-- process that many inputs per turn
cottages.handmill_max_per_turn = 20;
cottages.handmill_min_per_turn = 0;


-- uncomment parts you do not want
dofile(minetest.get_modpath("cottages").."/nodes_furniture.lua");
dofile(minetest.get_modpath("cottages").."/nodes_historic.lua");
dofile(minetest.get_modpath("cottages").."/nodes_straw.lua");
dofile(minetest.get_modpath("cottages").."/nodes_anvil.lua");
dofile(minetest.get_modpath("cottages").."/nodes_doorlike.lua");
dofile(minetest.get_modpath("cottages").."/nodes_fences.lua");
dofile(minetest.get_modpath("cottages").."/nodes_roof.lua");
dofile(minetest.get_modpath("cottages").."/nodes_barrel.lua");
--dofile(minetest.get_modpath("cottages").."/nodes_chests.lua");

-- this is only required and useful if you run versions of the random_buildings mod where the nodes where defined inside that mod
dofile(minetest.get_modpath("cottages").."/alias.lua");

-- variable no longer needed
cottages.S = nil;
