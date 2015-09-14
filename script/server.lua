require "script.attrblock.saveobj"
require "script.logger"
require "script.db"
require "script.conf.srvlist"

cserver = class("cserver",cdatabaseable,csaveobj,{
	srvname = skynet.getenv("srvname"),
	serverid = skynet.getenv("serverid"),
	gameflag = skynet.getenv("gameflag"),
})

function cserver:init()
	self.flag = "cserver"
	cdatabaseable.init(self,{
		pid = 0,
		flag = self.flag,
	})
	csaveobj.init(self,{
		pid = 0,
		flag = self.flag,
	})
	self.loadstate = "unload"
	self.data = {}
	self.onlinelimit = 20000	
	self:autosave()
	logger.log("info","server","init")
end

function cserver:create()
	logger.log("info","server","create")
	self.data = {
		createday = getdayno(),
	}
end

function cserver:save()
	local data = {}
	data.data = self.data
	return data
end

function cserver:load(data)
	if not data or not next(data) then
		return
	end
	self.data = data.data
end

function cserver:savetodatabase()
	if self.loadstate ~= "loaded" then
		return
	end
	local data = self:save()
	local db = dbmgr.getdb()
	db:set(db:key("global","server"),data)
end

function cserver:loadfromdatabase()
	if self.loadstate ~= "unload" then
		return
	end
	self.loadstate = "loading"
	local db = dbmgr.getdb()
	local data = db:get(db:key("global","server"))
	if data == nil then
		self:create()
	else
		self:load(data)
	end
	self.loadstate = "loaded"
end



-- getter
function cserver:getopenday()
	return getdayno() - self:query("createday") + self:query("openday")
end

function cserver:addopenday(val,reason)
	logger.log("info","server",string.format("addopenday,val=%d reason=%s",val,reason))
	self:add("openday",val)
end


function cserver:isopen(typ)
	require "script.cluster.clustermgr"
	if typ == "friend" then
		if not cserver.isgamesrv() then
			return false
		end
		if not clustermgr.isconnect("frdsrv") then	
			return false
		end
		return true
	end
end

-- class method
function cserver.isfrdsrv(srvname)
	srvname = srvname or cserver.srvname
	return string.find(srvname,"frdsrv") ~= nil
end

function cserver.isresumesrv(srvname)
	srvname = srvname or cserver.srvname
	return string.find(srvname,"resume") ~= nil
end

function cserver.isgamesrv(srvname)
	srvname = srvname or cserver.srvname
	return string.find(srvname,"gamesrv") ~= nil
end

function cserver.iswarsrv(srvname)
	srvname = srvname or cserver.srvname
	if srvname == "warsrvmgr" then
		return false
	end
	return string.find(srvname,"warsrv") ~= nil
end

function cserver.iswarsrvmgr(srvname)
	srvname = srvname or cserver.srvname
	return string.find(srvname,"warsrvmgr") ~= nil
end

function cserver.getsrvname(pid)
	local srvname = route.getsrvname(pid)
	if not srvname then
	end
	return srvname
end

return cserver
