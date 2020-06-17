
minetest.register_entity("medical:body", {
	hp_max = 1,
	physical = false,
	weight = 5,
	collisionbox = {-0.6, 0, -0.6, 0.6, .2, 0.6},
	visual = "mesh",
	mesh = "character.b3d",
	textures = {"character.png"},
	is_visible = true,
	makes_footstep_sound = false,
    automatic_rotate = false,
    on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then staticdata = "Elkien" end--return end
		--self.object:set_acceleration({x=0, y=-10, z=0})
		self.owner = staticdata
		self.object:set_animation({x=162,y=167}, 1)
		self.object:set_armor_groups({immortal = 1})
		self.object:set_yaw(math.random(-math.pi, math.pi)) --todo: have a set rotation value
		medical.init_injuries(self)
    end,
	--[[get_staticdata = function(self)
		--return
	end,--]]
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not puncher:is_player() then return end
		local name = puncher:get_player_name()
		local wielditem = puncher:get_wielded_item()
		local wieldname = wielditem:get_name()
		local hitloc, local_hitloc = medical.gethitloc(self.object, puncher, tool_capabilities, dir)
		local hitlimb = medical.getlimb(self.object, puncher, tool_capabilities, dir, hitloc)
		if not puncher:get_player_control(puncher).sneak and medical.attachedtools[wieldname] and medical.attachedtools[wieldname](self, puncher, wielditem, hitloc, local_hitloc) then
		
		elseif medical.data[name].injuries and medical.data[name].injuries[hitlimb] then
			medical.injury_handle(self.owner, puncher, false, wieldname, hitlimb)
		end
		-- attach things
    end,
    on_rightclick = function(self, clicker)
		if not clicker:is_player() then return end
		local name = clicker:get_player_name()
		local wielditem = clicker:get_wielded_item()
		local wieldname = wielditem:get_name()
		local hitloc, local_hitloc = medical.gethitloc(self.object, clicker, nil, nil)
		local hitlimb = medical.getlimb(self.object, clicker, tool_capabilities, dir, hitloc)
		if not clicker:get_player_control(clicker).sneak and medical.usedtools[wieldname] and medical.usedtools[wieldname](self, clicker, wielditem, hitloc, local_hitloc) then
		
		elseif medical.data[name].injuries and medical.data[name].injuries[hitlimb] then
			medical.injury_handle(self.owner, clicker, true, wieldname, hitlimb)
		end
		-- use things
    end
})

local injuryflip = {Arm_Right = 180, Arm_Left = 180, Leg_Right = 180, Leg_Left = 180}
local injurypos = {Head = -1.2}

function medical.init_injuries(self)
	local name = self.owner
	local player = minetest.get_player_by_name(name)
	local data = medical.data[name]
	local pos = self.object:get_pos()
	if medical.data[name].injuries then
		for bone, injury in pairs (medical.data[name].injuries) do
			local injurydef = medical.injuries[injury.name]
			local ent = minetest.add_entity(pos, injurydef.entity, minetest.serialize({owner = name, bone = bone}))
			local rot = injuryflip[bone] or 0
			local pos = injurypos[bone] or 0
			ent:set_attach(self.object, bone, {x=0, y=2, z=pos}, {x=rot,y=0,z=math.random(-10, 10)})
			medical.data[name].injuries[bone].ent = ent
		end
	end
end