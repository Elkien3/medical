local timer = 0
local default_vitals = {}
default_vitals.temp = 98 --farhenhiet
default_vitals.oxygen = 94 --percent
default_vitals.respiratory = 12 --breaths per minute
default_vitals.pulse = 70 --beats per minute
default_vitals.volume = 5000 --milliliters
default_vitals.systolic = 110 --mmHg
default_vitals.diastolic = 70 --mmHg

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	if not medical.data[name] then
		medical.data[name] = {}
	end
	if not medical.data[name].vitals then
		medical.data[name].vitals = default_vitals
	end
end)

minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 5 then
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			
			if medical.data[name].injuries then
				--handle loss of vital signs due to injuries
				for index, injury in pairs (medical.data[name].injuries) do
					local injurydef = medical.injuries[injury.name]
					if injurydef.medical_step then
						injurydef.medical_step()
					end
					if injury.vitals then
						for vital, amount in pairs (injury.vitals) do
							medical.data[name].vitals[vital] = medical.data[name].vitals[vital] - amount
						end
					end
					--handle loss of vital signs due to injuries
				end
			end
			
			if hunger then
				--handle hunger things
			end
			
			if thirst then
				--handle thirst things
			end
			
			local mv = medical.data[name].vitals
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