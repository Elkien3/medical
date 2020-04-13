local limb_location = {}

--todo: make these change depending on what state the patient is in.
--[[ standing locations
limb_location.head = {x=0,y=1.6,z=0}
limb_location.torso = {x=0,y=1,z=0}
limb_location.rightarm = {x=.3,y=1,z=0}
limb_location.leftarm = {x=-.3,y=1,z=0}
limb_location.rightleg = {x=.1,y=.4,z=0}
limb_location.leftleg = {x=-.1,y=.4,z=0}
--]]
--[[ sitting locations
limb_location.head = {x=0,y=.9,z=0}
limb_location.torso = {x=0,y=.4,z=0}
limb_location.rightarm = {x=.3,y=.4,z=0}
limb_location.leftarm = {x=-.3,y=.4,z=0}
limb_location.rightleg = {x=.1,y=.1,z=.35}
limb_location.leftleg = {x=-.1,y=.1,z=.35}
--]]
-- laying locations
limb_location.head = {x=0,y=.1,z=-.65}
limb_location.torso = {x=0,y=.1,z=-.2}
limb_location.rightarm = {x=.4,y=.1,z=-.125}
limb_location.leftarm = {x=-.4,y=.1,z=-.125}
limb_location.rightleg = {x=.2,y=.1,z=.5}
limb_location.leftleg = {x=-.2,y=.1,z=.5}

local DEBUG_WAYPOINT = true
local DEBUG_CHAT = true

local function rotateVector(x, y, a)
  local c = math.cos(a)
  local s = math.sin(a)
  return c*x - s*y, s*x + c*y
end

function medical.gethitloc(player, hitter, tool_capabilities, dir)
	if not player or not hitter then return end
	local playerpos = player:get_pos()
	local hitpos
	local hitterpos = hitter:get_pos()
	local adj_hitterpos = hitterpos
	local isPlayer = hitter:is_player()
	if isPlayer then
		adj_hitterpos.y = adj_hitterpos.y + 1.45 -- eye offset
		local offset, _ = hitter:get_eye_offset()
		local hitteryaw = hitter:get_look_horizontal()
		local x, z = rotateVector(offset.x, offset.z, hitteryaw)
		offset = vector.multiply({x=x, y=offset.y, z=z}, .1)
		adj_hitterpos = vector.add(adj_hitterpos, offset)
	else
		local properties = hitter:get_properties()
		local offset = properties.eye_height or math.abs(properties.collisionbox[2] - properties.collisionbox[4])
		adj_hitterpos.y = adj_hitterpos.y + offset/2
	end
	if tool_capabilities and dir and tool_capabilities.groupcaps.medical_dir ~= nil then
		hitpos = vector.add(adj_hitterpos, vector.multiply(dir, vector.distance(playerpos, hitterpos)))
	else
		local pointdir = hitter:get_look_dir() or {}
		if not pointdir or pointdir == nil or not isPlayer then
			local yaw = hitter:getyaw()
			local pitch = 0
			pointdir.x = -1*math.cos(yaw)*math.cos(pitch)
			pointdir.z = -1*math.sin(yaw)*math.cos(pitch)
			pointdir.y = math.sin(pitch)
		end
		hitpos = vector.add(adj_hitterpos, vector.multiply(pointdir, vector.distance(playerpos, hitterpos)))
	end
	if minetest.raycast then
		local ray = minetest.raycast(adj_hitterpos, hitpos) -- it checks the players exact front before anything else because the default hit dir is weird, this may cause inaccuracies if a weapon with spread gives a look vector as a dir and the ray that goes stright ahead still hits the player
		local pointed = ray:next()
		if pointed and pointed.ref and pointed.ref == hitter then
			pointed = ray:next()
		end
		if pointed and pointed.ref == player then
			hitpos = pointed.intersection_point
		end
	end
	local playeryaw
	if player:is_player() then
		playeryaw = player:get_look_horizontal()
	else
		playeryaw = player:get_yaw()
	end
	local loc = vector.subtract(hitpos, playerpos)
	local x, z = rotateVector(loc.x, loc.z, -playeryaw)
	local local_hitpos = {x=x,y=loc.y,z=z}
	if DEBUG_WAYPOINT then
		local marker = hitter:hud_add({
			hud_elem_type = "waypoint",
			name = "hit",
			number = 0xFF0000,
			world_pos = hitpos
		})
		minetest.after(10, function() hitter:hud_remove(marker) end, hitter, marker)
	end
	return hitpos, local_hitpos
end

function medical.getclosest(table, local_hitpos)
	local distance
	local closest
	for name, loc in pairs (table) do
		if not distance then
			distance = vector.distance(loc, local_hitpos)
			closest = name
		else
			if vector.distance(loc, local_hitpos) < distance then
				distance = vector.distance(loc, local_hitpos)
				closest = name
			end
		end
	end
	return distance, closest
end

function medical.getlimb(player, hitter, tool_capabilities, dir, hitloc)
	local hitpos
	if hitloc then
		hitpos = hitloc
	else
		hitpos = medical.gethitloc(player, hitter, tool_capabilities, dir)
		if not hitpos then return end
	end
	local hitlimb
	local hitdistance
	local playeryaw
	local playerpos = player:get_pos()
	if player:is_player() then
		playeryaw = player:get_look_horizontal()
	else
		playeryaw = player:get_yaw()
	end
	for id, pos in pairs(limb_location) do
		local x, z = rotateVector(pos.x, pos.z, playeryaw)
		local rot_pos = {x=x,y=pos.y,z=z}
		local adj_pos = vector.add(playerpos, rot_pos)
		local dist = vector.distance(adj_pos, hitpos)
		if hitdistance == nil or dist < hitdistance then
			hitdistance = dist
			hitlimb = id
		end
		if DEBUG_WAYPOINT then 
			local mrker = hitter:hud_add({
				hud_elem_type = "waypoint",
				name = id,
				number = 0xFF0000,
				world_pos = adj_pos
			})
			minetest.after(5, function() hitter:hud_remove(mrker) end, hitter, mrker)
		end
	end
	if DEBUG_CHAT then
		minetest.chat_send_all(dump(hitlimb))
	end
	return hitlimb
end

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if reason.type then minetest.chat_send_all(reason.type) end
	return hp_change
end, true)
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	medical.getlimb(player, hitter, tool_capabilities, dir)
end)