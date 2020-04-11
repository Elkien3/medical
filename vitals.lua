local timer = 0
local default_vitals = {}
default_vitals.temp = 98 --farhenhiet
default_vitals.oxygen = 94 --percent
default_vitals.respiratory = 12 --breaths per minute
default_vitals.pulse = 70 --beats per minute
default_vitals.volume = 5000 --milliliters
default_vitals.systolic = 110 --mmHg
default_vitals.diastolic = 70 --mmHg

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 5 then
		for _,player in ipairs(minetest.get_connected_players()) do
			--player:set_bone_position("Head", {x=0,y=10,z=0}, {x=0,y=180,z=0})
			--local bonepos = player:get_bone_position("Head")
			--[[local text = ""
			for id, data in pairs (bonepos) do
				text = text.." "..tostring(id)..":"..dump(data)
			end
			minetest.chat_send_all(text)--]]
			local name = player:get_player_name()
			if not medical.data.vitals[name] then medical.data.vitals[name] = default_vitals end
			
			if medical.data.injuries[name] then
				--handle loss of vital signs due to injuries
			end
			
			if hunger then
				--handle hunger things
			end
			
			if thirst then
				--handle thirst things
			end
			
			mv = medical.data.vitals[name]
			local perfusion = ((mv.oxygen-60)/34) * ((mv.pulse-30)/40) * ((mv.volume-2000)/3000) * ((mv.temp-70)/28)
			
			if perfusion < .9 then --compensate by raising pulse and respiratory rate
			
			elseif perfusion < .7 then --subject gets cold and dizzy
			
			elseif perfusion < .5 then --subject is confused
			
			elseif perfusion < .3 then --subject is unconscious
			
			elseif perfusion < .1 then --subject stops breathing and pumping blood
			
			else --subject is ded
			
			end
		end
		timer = 0
	end
end)