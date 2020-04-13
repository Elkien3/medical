medical.timers = {}

function medical.start_timer(name, length, loop, arg, func)
	local index
	if name then
		index = name
	else 
		local i = 0
		while true do
			if not medical.timers[i] then
				index = i
				break			
			end
			i = i + 1
		end
	end
	medical.timers[index] = {}
	medical.timers[index].length = length
	medical.timers[index].timeleft = length
	medical.timers[index].loop = loop
	medical.timers[index].arg = arg
	medical.timers[index].func = func
	return index
end

function medical.stop_timer(name, runonce)
	local timer = medical.timers[name]
	if runonce then
		timer.func(timer.arg)
	end
	medical.timers[name] = nil
end
	
minetest.register_globalstep(function(dtime)
	for index, timer in pairs (medical.timers) do
		timer.timeleft = timer.timeleft - dtime
		if timer.timeleft <= 0 then
			timer.func(timer.arg)
			if timer.loop then
				medical.start_timer(index, timer.length, timer.loop, timer.arg, timer.func)
			else
				medical.stoptimer(name)
			end
		end
	end
end)