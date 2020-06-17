medical = {}
medical.mod_storage = minetest.get_mod_storage()
medical.usedtools = {}
medical.attachedtools = {}
medical.data = minetest.deserialize(medical.mod_storage:get_string("data")) or {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/controls.lua")
dofile(modpath.."/timers.lua")
dofile(modpath.."/vitals.lua")
dofile(modpath.."/hitloc.lua")
dofile(modpath.."/body.lua")
dofile(modpath.."/tools.lua")
dofile(modpath.."/injuries.lua")

medical.data["Elkien"] = {}
medical.data["Elkien"].injuries = {Arm_Left = {name = "cut"}}