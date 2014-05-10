
vlog_queue = {}

function vendor_log_queue(name,line)
	if ( vlog_queue[name] == nil ) then
		vlog_queue[name] = {}
	end
	table.insert(vlog_queue[name],line)
end

function write_vendor_log(again)

minetest.log("action","Writing vendor log queue to file")
	for name,log_lines in pairs(vlog_queue) do
		local logfile = minetest.get_worldpath().."/vendor_logs/"..name..".csv"
		local f = io.open(logfile, "a+")
		for _,line in pairs(log_lines) do
			local csv_line = line.date..",\""..line.pos.."\","..line.action..","..line.from..","..line.qty..","..line.desc..","..line.amount.."\r\n"
			f:write(csv_line)
		end
		f:close()
	end
	vlog_queue = {}
	
	if ( again == true ) then
		minetest.after(60,write_vendor_log,true)
	end
end

minetest.register_on_shutdown(write_vendor_log)
minetest.after(60,write_vendor_log,true)