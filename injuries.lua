medical.injuries = {}

function medical.injury_handle(owner, player, rightclick, tool, hitlimb, finish)
	local name = player:get_player_name()
	local injury = medical.data[owner].injuries[hitlimb]
	local injurydef = medical.injuries[injury.name]
	if not injury.step then injury.step = 1 end
	local stepdef = injurydef.steps[injury.step]
	if finish then
		injury.step = injury.step + 1
		if not injurydef.steps[injury.step] then
			if injury.ent then
				injury.ent:remove()
				medical.data[owner].injuries[hitlimb] = nil
			end
		return
	end
	if tool ~= stepdef.tool or rightclick ~= stepdef.rightclick then
		return end
	end
	local stopfunc
	local stoparg
	if stepdef.hud then
		medical.hud[name] = player:hud_add({
		hud_elem_type = "image",
		position  = {x = 0.5, y = 0.55},
		offset    = {x = 0, y = 0},
		text      = stepdef.hud,
		scale     = { x = 10, y = 10},
		alignment = { x = 0, y = 0 },
		})
		player:hud_set_flags({wielditem=false})
		stoparg = name
		stopfunc = function(stoparg)
			local player = minetest.get_player_by_name(stoparg)
			if medical.hud[stoparg] then
				player:hud_remove(medical.hud[stoparg])
				medical.hud[stoparg] = nil
				player:hud_set_flags({wielditem=true})
			end
		end
	end
	if stepdef.time then
		medical.start_timer(owner, stepdef.time, false, {owner, player, rightclick, tool, hitlimb, true}, medical.injury_handle, stoparg, stopfunc, "RMB", name)
	else
		medical.injury_handle(owner, player, rightclick, tool, hitlimb, true)
	end
end

minetest.register_entity("medical:cut", {
    hp_max = 1,
    physical = false,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "cube",
    visual_size = {x=.211, y=.211},
    textures = {"invis.png", "invis.png", "invis.png", "invis.png", "invis.png", "medical_cut.png"}, -- number of required textures depends on visual -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() return end
		local data = minetest.deserialize(staticdata)
		self.owner = data.owner
		self.bone = data.bone
	end
})

medical.injuries["cut"] = {
entity = "medical:cut",
steps = {{tool = "", rightclick = true, time = 5, hud = "applypressure.png"}},--steps = {"medical:dressing", "", "medical:dressing", "", "medical:tourniquet", ""},-- maybe make the optional steps removed if the initial severety of the wound is less severe. would need a way to make sure the player knows thta in real life tourniquets should only be applied in real situation only if neccisary and you know how, and should only be removed by professionals, lest bleeding start again.
--vitals = {depends on severity and current treatment},
healtime = nil,-- maybe make a severity value that starts at 1 or something, and goes down as you treat, or if the wound is less severe to start with.
medical_step = nil,
}


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
			self.object:remove()
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