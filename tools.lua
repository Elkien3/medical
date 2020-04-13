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
	if distance > .15 then return end
	local cname = clicker:get_player_name()
	if medical.hud[cname] then clicker:hud_remove(medical.hud[cname]) medical.hud[cname] = nil end
	if not medical.lookingplayer[cname] then medical.lookingplayer[cname] = {dir = clicker:get_look_dir(), pos = clicker:get_pos()} end
	medical.hud[cname] = clicker:hud_add({
		hud_elem_type = "image",
		position  = {x = 0.5, y = 0.55},
		offset    = {x = 0, y = 0},
		text      = "nopulse.png",
		scale     = { x = 10, y = 10},
		alignment = { x = 0, y = 0 },
	})
	medical.start_timer(cname.."pulsecheck", 60/medical.data.vitals[cname].pulse, true, cname, --todo: change this to give the patient's pulse instead of yours
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
		end
	)
end

controls.register_on_release(function(player, key, time)
	local name = player:get_player_name()
	if key == "RMB" and medical.hud[name] then
		player:hud_remove(medical.hud[name]) medical.hud[name] = nil
		medical.lookingplayer[name] = nil
		medical.stop_timer(name.."pulsecheck", false)
	end
end)
medical.register_on_lookaway(function(player, name)
	if medical.hud[name] then
		player:hud_remove(medical.hud[name])
		medical.hud[name] = nil
		medical.lookingplayer[name] = nil
		medical.stop_timer(name.."pulsecheck", false)
	end
end)