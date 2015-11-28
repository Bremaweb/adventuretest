abm_counter = 0
abm_timer = 0
abm_limit = 5
abm_time_limit = 1

function abm_limiter()
	if abm_counter > abm_limit then
		return true
	end
	abm_counter = abm_counter + 1
	return false
end

function abm_globalstep(dtime)
	abm_timer = abm_timer + dtime
	if abm_timer > abm_time_limit then
		abm_counter = 0
		abm_timer = 0
	end
end