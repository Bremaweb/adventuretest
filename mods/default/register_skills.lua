-- REGISTER SKILLS


-- CONSTANT IDs
SKILL_WOOD    = 1
SKILL_STONE   = 2
SKILL_IRON    = 4
SKILL_STEEL   = 4
SKILL_COPPER  = 8
SKILL_DIAMOND = 16
SKILL_MESE    = 32
SKILL_GOLD    = 64

SKILL_SMELTING= 128
SKILL_CRAFTING= 256
SKILL_ARROW=512
SKILL_MAGIC=1024

-- REGISTER THE SKILLS
skills.register_skill(SKILL_WOOD, { desc = 'Wood', max_level = 10, level_exp = 15 })
skills.register_skill(SKILL_STONE, { desc = 'Stone', max_level = 10, level_exp = 15 })
skills.register_skill(SKILL_IRON, { desc = 'Iron/Steel', max_level = 25, level_exp = 20 })
skills.register_skill(SKILL_COPPER, { desc = 'Copper', max_level = 25, level_exp = 20 })
skills.register_skill(SKILL_DIAMOND, { desc = 'Diamond', max_level = 40, level_exp = 15 })
skills.register_skill(SKILL_MESE, { desc = 'Mese', max_level = 40, level_exp = 15 })
skills.register_skill(SKILL_GOLD, { desc = 'Gold', max_level = 15, level_exp = 20 })

skills.register_skill(SKILL_SMELTING, { desc = 'Smelting', max_level = 50, level_exp = 10 })
skills.register_skill(SKILL_CRAFTING, { desc = 'Crafting', max_level = 50, level_exp = 10 })

skills.register_skill(SKILL_ARROW, { desc = 'Bow and Arrow', max_level=10, level_exp = 25})
skills.register_skill(SKILL_MAGIC, { desc = 'Magic', max_level=15, level_exp = 25})
