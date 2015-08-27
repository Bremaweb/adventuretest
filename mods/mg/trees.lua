local function add_leaves(data, vi, c_leaves, c_snow)
	if data[vi]==c_air or data[vi]==c_ignore or data[vi] == c_snow then
		data[vi] = c_leaves
	end
end

function add_tree(data, a, x, y, z, minp, maxp, pr)
	local th = pr:next(3, 4)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_tree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		add_leaves(data, a:index(xx, yy, zz), c_leaves)
	end
	end
	end
	for i=1,8 do
		local xi = pr:next(x-2, x+1)
		local yi = pr:next(maxy-1, maxy+1)
		local zi = pr:next(z-2, z+1)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for yy=math.max(minp.y, yi), math.min(maxp.y, yi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			add_leaves(data, a:index(xx, yy, zz), c_leaves)
		end
		end
		end
	end
end

function add_jungletree(data, a, x, y, z, minp, maxp, pr)
	local th = pr:next(7, 11)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_jungletree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		add_leaves(data, a:index(xx, yy, zz), c_jungleleaves)
	end
	end
	end
	for i=1,30 do
		local xi = pr:next(x-3, x+2)
		local yi = pr:next(maxy-2, maxy+1)
		local zi = pr:next(z-3, z+2)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for yy=math.max(minp.y, yi), math.min(maxp.y, yi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			add_leaves(data, a:index(xx, yy, zz), c_jungleleaves)
		end
		end
		end
	end
end

function add_savannatree(data, a, x, y, z, minp, maxp, pr)
	local th = pr:next(7, 11)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_savannatree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
	end
	end
	end
	for i=1,20 do
		local xi = pr:next(x-3, x+2)
		local yi = pr:next(maxy-2, maxy)
		local zi = pr:next(z-3, z+2)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for yy=math.max(minp.y, yi), math.min(maxp.y, yi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
		end
		end
		end
	end
	for i=1,15 do
		local xi = pr:next(x-3, x+2)
		local yy = pr:next(maxy-6, maxy-5)
		local zi = pr:next(z-3, z+2)
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			if minp.y<=yy and maxp.y>=yy then
				add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
			end
		end
		end
	end
end

function add_savannabush(data, a, x, y, z, minp, maxp, pr)
	local bh = pr:next(1, 2)
	local bw = pr:next(2, 4)

	for xx=math.max(minp.x, x-bw), math.min(maxp.x, x+bw) do
		for zz=math.max(minp.z, z-bw), math.min(maxp.z, z+bw) do
			for yy=math.max(minp.y, y-bh), math.min(maxp.y, y+bh) do
				if pr:next(1, 100) < 95 and math.abs(xx-x) < pr:next(bh, bh+2)-math.abs(y-yy) and math.abs(zz-z) < pr:next(bh, bh+2)-math.abs(y-yy) then
					add_leaves(data, a:index(xx, yy, zz), c_savannaleaves)
					for yyy=math.max(minp.y, yy-2), yy do
						add_leaves(data, a:index(xx, yyy, zz), c_savannaleaves)
					end
				end
			end
		end
	end

	if x<=maxp.x and x>=minp.x and y<=maxp.y and y>=minp.y and z<=maxp.z and z>=minp.z then
		local vi = a:index(x, y, z)
		data[vi] = c_savannatree
	end
end

function add_pinetree(data, a, x, y, z, minp, maxp, pr, snow)
	if snow == nil then snow = c_snow end
	local th = pr:next(9, 13)
	for yy=math.max(minp.y, y), math.min(maxp.y, y+th) do
		local vi = a:index(x, yy, z)
		data[vi] = c_pinetree
	end
	local maxy = y+th
	for xx=math.max(minp.x, x-3), math.min(maxp.x, x+3) do
	for yy=math.max(minp.y, maxy-1), math.min(maxp.y, maxy-1) do
	for zz=math.max(minp.z, z-3), math.min(maxp.z, z+3) do
		if pr:next(1, 100) < 80 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	for xx=math.max(minp.x, x-2), math.min(maxp.x, x+2) do
	for yy=math.max(minp.y, maxy), math.min(maxp.y, maxy) do
	for zz=math.max(minp.z, z-2), math.min(maxp.z, z+2) do
		if pr:next(1, 100) < 85 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, maxy+1), math.min(maxp.y, maxy+1) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		if pr:next(1, 100) < 90 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	if maxy+1<=maxp.y and maxy+1>=minp.y then
		add_leaves(data, a:index(x, maxy+1, z), c_pineleaves, snow)
		add_leaves(data, a:index(x, maxy+2, z), snow)
	end
	local my = 0
	for i=1,20 do
		local xi = pr:next(x-3, x+2)
		local yy = pr:next(maxy-6, maxy-5)
		local zi = pr:next(z-3, z+2)
		if yy > my then
			my = yy
		end
		for xx=math.max(minp.x, xi), math.min(maxp.x, xi+1) do
		for zz=math.max(minp.z, zi), math.min(maxp.z, zi+1) do
			if minp.y<=yy and maxp.y>=yy then
				add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
				add_leaves(data, a:index(xx, yy+1, zz), snow)
			end
		end
		end
	end
	for xx=math.max(minp.x, x-2), math.min(maxp.x, x+2) do
	for yy=math.max(minp.y, my+1), math.min(maxp.y, my+1) do
	for zz=math.max(minp.z, z-2), math.min(maxp.z, z+2) do
		if pr:next(1, 100) < 85 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
	for xx=math.max(minp.x, x-1), math.min(maxp.x, x+1) do
	for yy=math.max(minp.y, my+2), math.min(maxp.y, my+2) do
	for zz=math.max(minp.z, z-1), math.min(maxp.z, z+1) do
		if pr:next(1, 100) < 90 then
			add_leaves(data, a:index(xx, yy, zz), c_pineleaves, snow)
			add_leaves(data, a:index(xx, yy+1, zz), snow)
		end
	end
	end
	end
end