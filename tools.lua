medical.hud = {}

medical.usedtools[""] = function(self, clicker, wielditem, hitloc, local_hitloc)
	local vitalpoints = {}
	local playerpos = self.object:get_pos()
	vitalpoints.cartoid =  {x=0,y=.1,z=-.425}
	vitalpoints.radialright = {x=.5,y=.1,z=-.05}
	vitalpoints.radialleft = {x=-.5,y=.1,z=-.05}
	vitalpoints.pedalright = {x=.20,y=.1,z=.7}
	vitalpoints.pedalleft = {x=-.20,y=.1,z=.7}
	local distance, hitpart = medical.getclosest(vitalpoints, local_hitloc)
	if distance > .15 then return false end
	local cname = clicker:get_player_name()
	local sname = self.owner
	if medical.hud[cname] then clicker:hud_remove(medical.hud[cname]) medical.hud[cname] = nil end
	medical.hud[cname] = clicker:hud_add({
		hud_elem_type = "image",
		position  = {x = 0.5, y = 0.55},
		offset    = {x = 0, y = 0},
		text      = "nopulse.png",
		scale     = { x = 10, y = 10},
		alignment = { x = 0, y = 0 },
	})
	clicker:hud_set_flags({wielditem=false})
	medical.start_timer(sname.."pulsecheck", 60/medical.data[sname].vitals.pulse, true, sname,
		function(arg)
			minetest.sound_play("human-heartbeat-daniel_simon", {
				pos = hitloc,
				to_player = arg,
			})
			local circle = clicker:hud_add({
				hud_elem_type = "image",
				position  = {x = 0.5, y = 0.55},
				offset    = {x = 0, y = 0},
				text      = "foundpulse.png",
				scale     = { x = 10, y = 10},
				alignment = { x = 0, y = 0 },
			})
			minetest.after(.15, function()
				local hitter = minetest.get_player_by_name(cname)
				if hitter then
					hitter:hud_remove(circle)
				end
			end)
		end,
		cname,
		function(stoparg)
			local player = minetest.get_player_by_name(stoparg)
			if medical.hud[stoparg] then
				player:hud_remove(medical.hud[stoparg])
				medical.hud[stoparg] = nil
				player:hud_set_flags({wielditem=true})
			end
		end, "RMB", cname
	)
	return true
end
medical.attachedtools[""] = function(self, clicker, wielditem, hitloc, local_hitloc)
	--local limb = medical.getlimb(self.object, clicker, nil, nil, hitloc)
	local all_objects = minetest.get_objects_inside_radius(hitloc, 10)
	local cname = clicker:get_player_name()
	for _,obj in ipairs(all_objects) do
		local pos = obj:get_pos()
		local marker = clicker:hud_add({
			hud_elem_type = "waypoint",
			name = obj:get_entity_name(),
			number = 0xFF0000,
			world_pos = obj:get_pos()
		})
			minetest.after(5, function()
				local hitter = minetest.get_player_by_name(cname)
				if hitter then
					hitter:hud_remove(marker)
				end
			end)
	end
end

minetest.register_tool("medical:bpcuff", {
    description = "Blood Pressure Cuff",
    inventory_image = "bpcuff.png",
})

minetest.register_tool("medical:bpbladder", {
    description = "Blood Pressure Cuff",
    inventory_image = "bpcuffbladder.png",
	on_use = function(itemstack, player, pointed_thing)
		--inflate bp cuff
	end
})

minetest.register_entity("medical:bpcuff", {
    hp_max = 1,
    physical = false,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "cube",
    visual_size = {x=.25, y=.25},--{x=.211, y=.211},
    textures = {"default_coal_block.png", "default_coal_block.png", "default_coal_block.png", "default_coal_block.png", "default_coal_block.png", "default_coal_block.png"}, -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() end
		self.owner = staticdata
	end
})

minetest.register_entity("medical:line", {
    hp_max = 1,
    physical = false,
    weight = 5,
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
    visual = "cube",
    visual_size = {x=.05, y=.1},
    textures = {"blackline.png", "blackline.png", "blackline.png", "blackline.png", "blackline.png", "blackline.png"}, -- number of required textures depends on visual
    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = false,
	on_step = function(self, dtime)
		if not self.target or not self.owner then self.object:remove() return end
		local player = minetest.get_player_by_name(self.owner)
		local op = player:get_pos()
		op.y = op.y + 1
		op = vector.add(op, vector.multiply(player:get_player_velocity(), .1))
		if self.lastpos and vector.equals(self.lastpos, op) then return end
		local tp = self.target
		
		if vector.distance(op, tp) > 1.5 then
			local inv = player:get_inventory()
			local list = "main"
			return
		end
		
		local delta = vector.subtract(op, tp)
		local yaw = math.atan2(delta.z, delta.x) - math.pi / 2
		local pitch = math.atan2(delta.y,  math.sqrt(delta.z*delta.z + delta.x*delta.x))
		pitch = pitch + math.pi/2
		
		self.object:move_to({x=(op.x+tp.x)/2, y=(op.y+tp.y)/2, z=(op.z+tp.z)/2, })
		self.object:set_rotation({x=pitch, y=yaw, z=0})
		self.object:set_properties({visual_size = {x=.05, y=vector.distance(tp, op)}})
		self.lastpos = op
	end,
	on_activate = function(self, staticdata, dtime_s)
		if not staticdata or staticdata == "" then self.object:remove() end
		self.owner = staticdata
		self.target = self.object:get_pos()
	end
})

medical.attachedtools["medical:bpcuff"] = function(self, clicker, wielditem, hitloc, local_hitloc)
	local limb = medical.getlimb(self.object, clicker, nil, nil, hitloc)
	local bone
	if limb == "rightarm" then bone = "Arm_Right" elseif limb == "leftarm" then bone = "Arm_Left" else return end
	local pos = self.object:get_pos()
	local obj = minetest.add_entity(pos, "medical:bpcuff", clicker:get_player_name())
	minetest.after(0, function()
		local marker = clicker:hud_add({
			hud_elem_type = "waypoint",
			name = "hit",
			number = 0xFF0000,
			world_pos = obj:get_pos()
		}) end)
	obj:set_attach(self.object, bone, {x=0,y=.5,z=0}, {x=0,y=0,z=0})
	--local obj = minetest.add_entity(hitloc, "medical:line", clicker:get_player_name())
	minetest.after(0, function() clicker:set_wielded_item({name = ""})end)
end