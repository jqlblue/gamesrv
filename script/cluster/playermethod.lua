


local function docmd(srvname,pid,methodname,...)
	local player = playermgr.getplayer(pid)	
	if not player then
		player = playermgr.loadofflineplayer(pid)
	end
	assert(player,"Not found pid:" .. tostring(pid))
	local modname,sep,funcname = string.match(methodname,"(.*)([.:].+)$")	
	if not (modname and sep and funcname) then
		error("[playermethod] Invalid methodname:" .. tostring(methodname))
	end
	local mod = player
	if modname ~= "" then
		local attrs = {}
		for attr in string.gmatch(modname,"([^.]+)") do
			mod = mod[attr]
		end
	end
	local func = assert(mod[funcname],"[playermethod] Unknow methodname:" .. tostring(methodname))
	if type(func) ~= "function" then
		assert(sep == ".")
		return func
	end
	if sep == "." then
		return func(...)
	elseif sep == ":" then
		return func(mod,...)
	else
		error("Invalid function seperator:" .. tostring(sep))
	end
end

netcluster_playermethod = netcluster_playermethod or {}

function netcluster_playermethod.dispatch(srvname,cmd,...)
	return docmd(srvname,cmd,...)
end

return netcluster_playermethod
