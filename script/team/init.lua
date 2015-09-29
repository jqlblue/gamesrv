cteam = class("cteam")

function cteam:init(teamid,param)
	self.teamid = teamid
	self.follow = {}
	self.leave = {}
	self.captain = 0
	self.applyers = {}
	self.target = param.target or 0
	self.stage = param.stage or 0
	self.publish = false
end

function cteam:load(data)
	if not data or not next(data) then
		return
	end
	local tmp = {}
	for pid,v in pairs(data.follow) do
		pid = tonumber(pid)
		tmp[pid] = v
	end
	self.follow = tmp
	tmp = {}
	for pid,v in pairs(data.leave) do
		pid = tonumber(pid)
		tmp[pid] = v
	end
	self.leave = tmp
	self.captain = data.pid
	tmp = {}
	for pid,applyer in pairs(data.applyers) do
		pid = tonumber(pid)
		tmp[pid] = applyer
	end
	self.applyers = tmp
end

function cteam:save()
	local data = {}
	local tmp = {}
	for pid,v in pairs(self.follow) do
		tmp[tostring(pid)]=v
	end
	data.follow = tmp
	tmp = {}
	for pid,v in pairs(self.leave) do
		tmp[tostring(pid)]=v
	end
	data.leave = tmp
	data.captain = self.captain
	tmp = {}
	for pid,applyer in pairs(self.applyers) do
		tmp[tostring(pid)] = applyer
	end
	data.applyers = tmp
	return data
end

function cteam:onlogin(player)
	local pid = player.pid
	sendpackage(pid,"team","addapplyer",self.applyers)
end

function cteam:onlogoff(player)
end

function cteam:jointeam(player)
	local teamid = player.teamid
	assert(teamid==nil)
	local pid = player.pid
	logger.log("info","team",string.format("jointeam,pid=%d teamid=%d",pid,teamid))
	player.teamid = self.teamid
	self.leave[pid] = true
	local scene = scenemgr.getscene(player.sceneid)
	local state = player:teamstate()
	scene:sync(pid,{
		teamid = self.teamid,
		state = state,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","member",self:packmember(player))
	end)
	self:onjointeam(player)
end

function cteam:onjointeam(player)
	local pid = player.pid
	teammgr:unautomatch(pid,"jointeam")
end

function cteam:backteam(player)
	local pid = player.pid
	logger.log("info","team",string.format("backteam,pid=%d",player.pid))
	local captain = playermgr.getplayer(self.captain)
	local scene = scenemgr.getscene(captain.sceneid)
	if self.leave[pid] then
		self.leave[pid] = nil
	end
	self.follow[pid] = true
	local state = player:teamstate()
	scene:sync(pid,{
		sceneid = captain.sceneid,
		x = captian.x,
		y = captain.y,
		dir = captain.dir,
		teamid = self.teamid,
		state = state,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","member",self:packmember(player))
	end)
end

function cteam:leaveteam(player)
	local pid = player.pid
	assert(self.captain ~= pid)
	logger.log("info","team",string.format("leaveteam,pid=%d teamid=%d",pid,self.teamid))
	self.follow[pid] = nil
	self.leave[pid] = true
	local scene = scenemgr.getscene(player.sceneid)
	local state = player:teamstate()
	scene:sync(pid,{
		teamid = self.teamid,
		state = state,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","member",self:packmember(player))
	end)
	return true
end

function cteam:quitteam(player)
	local pid = player.pid
	logger.log("info","team",string.format("quitteam,pid=%d teamid=%d",pid,self.teamid))
	player.teamid = nil
	self.follow[pid] = nil
	self.leave[pid] = nil
	if self.captain == pid then
		if next(self.follow) then
			local newcaptain = randlist(keys(self.follow))
			self.follow[newcaptain] = nil
			self.captain = newcaptain
		elseif next(self.leave) then
			local newcaptain = randlist(keys(self.leave))
			self.leave[newcaptain] = nil
			self.captain = newcaptain
		end
	end
	local scene = scenemgr.getscene(player.sceneid)
	local state = player:teamstate()
	scene:sync(pid,{
		teamid = 0,
		state = state,
	})
	self:broadcast(function (uid)
		sendpackage(uid,"team","member",self:packmember(player))
	end)
end

function cteam:changecaptain(pid)
	assert(self.captain~=pid)
	assert(self.leave[pid]==nil)
	local oldcaptain_pid = self.captain
	local oldcaptain = playermgr.getplayer(oldcaptain_pid)
	assert(oldcaptain)
	local captain = playermgr.getplayer(pid)
	assert(captain)
	logger.log("info","team",string.format("changecaptain,teamid=%d captain=%d->%d",self.teamid,oldcaptain_pid,pid))
	self.captain = pid
	self.follow[oldcaptain_pid] = true
	self:broadcast(function (uid)
		sendpackage(uid,"team","member",self:packmember(oldcaptain))
		sendpackage(uid,"team","member",self:packmember(captain))
	end)
end

function cteam:addapplyer(player)
	local pid = player
	if self.applyers[pid] then
		return
	end
	logger.log("info","team",string.format("addapplyer,pid=%d teamid=%d",pid,self.teamid))
	local applyer = {
		pid = pid,
		name = player.name,
		lv = player.lv,
		roletype = player.roletype,
		time = os.time(),
	}
	self.applyers[pid] = applyer
	self:broadcast(function (uid)
		sendpackage(uid,"team","addapplyer",{applyer,})
	end)
end

function cteam:delapplyer(pid)
	local applyer = self.applyers[pid]
	if applyer then
		logger.log("info","team",string.format("delapplyer,pid=%d teamid=%d",pid,self.teamid))
		self:broadcast(function (uid)
			sendpackage(uid,"team","delapplyer",{applyer,})
		end)
	end
end

function cteam:packmember(player)
	return player:packmember()
end

function cteam:broadcast(func)
	func(self.captain)
	for pid,_ in pairs(self.follow) do
		func(pid)
	end
	for pid,_ in pairs(self.leave) do
		func(pid)
	end
end

function cteam:ismember(pid)
	if self.captain == pid then
		return true
	end
	if self.follow[pid] then
		return true
	end
	if self.leave[pid] then
		return true
	end
	return false
end

function cteam:len(state,include_captain)
	if state == TEAM_STATE_FOLLOW then
		return string.len(keys(self.follow)) + (include_captain and 1 or 0)
	elseif state == TEAM_STATE_LEAVE then
		return string.len(keys(self.leave))
	elseif state == TEAM_STATE_OFFLINE then
		local cnt = 0
		for pid,v in pairs(self.leave) do
			if not playermgr.getplayer(pid) then
				cnt = cnt + 1
			end
		end
		return cnt
	elseif state == TEAM_STATE_ALL then
		return 1 + string.len(keys(self.follow)) + string.len(keys(self.leave))
	else
		assert("invalid team state:" .. tostring(state))
	end
end
return cteam
