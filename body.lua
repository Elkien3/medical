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
		self.object:set_animation({x=162,y=167}, 1)
		self.object:set_armor_groups({immortal = 1})
		self.object:set_yaw(math.random(math.pi*-1, math.pi))
    end,
	--[[get_staticdata = function(self)
		--return minetest.serialize({owner = self.owner, sleeping = self.sleeping, expiretime = self.time, mesh = self.mesh, textures = self.textures, yaw = self.yaw, inv = serializeContents(self.inv)})
	end,--]]
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not puncher:is_player() then return end
		local wielditem = puncher:get_wielded_item()
		local wieldname = wielditem:get_name()
		local hitloc = medical.gethitloc(self, puncher, tool_capabilities, dir)
		if medical.attachedtools[wieldname] then
			medical.usedtools[wieldname](self, puncher, wielditem, hitloc)
		end
		-- attach things
    end,
    on_rightclick = function(self, clicker)
		if not clicker:is_player() then return end
		local wielditem = clicker:get_wielded_item()
		local wieldname = wielditem:get_name()
		local hitloc = medical.gethitloc(self, clicker, nil, nil)
		if medical.attachedtools[wieldname] then
			medical.usedtools[wieldname](self, clicker, wielditem, hitloc)
		end
		-- use things
    end
})

--open fracture test
minetest.register_entity("medical:fracturetest", {
    hp_max = 1,
    physical = true,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "mesh",
	mesh = "bone.b3d",
    visual_size = {x=1, y=1},--{x=.211, y=.211},
    textures = {"default_clay.png","default_clay.png","default_clay.png","default_clay.png","default_clay.png","default_clay.png"}, -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
	on_activate = function(self, staticdata, dtime_s)
		minetest.after(1, function()
			local all_objects = minetest.get_objects_inside_radius(self.object:get_pos(), 10)
			local _,obj
			for _,obj in ipairs(all_objects) do
				if obj:get_entity_name() == "medical:body" then
					minetest.chat_send_all(obj:get_entity_name())
					self.object:set_attach(obj, "Arm_Right", {x=0,y=4,z=0}, {x=1,y=0,z=math.random(-10, 10)})
					break
				end
			end
		end)
    end
})