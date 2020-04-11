medical = {}
medical.mod_storage = minetest.get_mod_storage()
medical.usedtools = {}
medical.attachedtools = {}
medical.data = medical.mod_storage:to_table() or {}
if not medical.data.vitals then medical.data.vitals = {} end
if not medical.data.injuries then medical.data.injuries = {} end

--mod_storage:from_table(medical)

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/vitals.lua")
dofile(modpath.."/hitloc.lua")
dofile(modpath.."/body.lua")