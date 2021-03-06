proto = proto or {}

function proto.kick(agent,fd)
	local connect = proto.connection[agent]
	if connect then
		local pid = assert(connect.pid,"invalid pid:" .. tostring(connect.pid))
		proto.connection[agent] = nil
		fd = fd or connect.fd
		skynet.send(agent,"lua","kick",fd)
	end
end

function proto.sendpackage(agent,protoname,cmd,request,onresponse)
	--local connect = assert(proto.connection[agent],"invalid agent:" .. tostring(agent))
	--
	local connect = proto.connection[agent]
	if not connect then
		return
	end
	connect.session = connect.session + 1
	logger.log("debug","netclient",format("[send] source=%s session=%d pid=%d protoname=%s cmd=%s request=%s onresponse=%s",agent,connect.session,connect.pid,protoname,cmd,request,onresponse))
	logger.pprintf("[send] REQUEST:%s\n",{
		pid = connect.pid,
		session = connect.session,
		agent = skynet.address(agent),
		protoname = protoname,
		cmd = cmd,
		request = request,
		onresponse = onresponse,
	})
	connect.sessions[connect.session] = {
		protoname = protoname,
		cmd = cmd,
		request = request,
		onresponse = onresponse,
	}
	skynet.send(agent,"lua","send_request",protoname .. "_" .. cmd,request,connect.session)
end

local function onrequest(agent,cmd,request)
	local connect = proto.connection[agent]
	if not connect then
		logger.log("warning","netclient",format("[NON EXIST AGENT] [onrequest] agent=%s cmd=%s request=%s",agent,cmd,request))
		return
	end
	local obj = playermgr.getobject(connect.pid)
	if not obj then
		logger.log("warning","netclient",format("[NON EXIST OBJECT] [onrequest] agent=%s cmd=%s request=%s",agent,cmd,request))
		return
	end
	local pid = obj.pid
	logger.pprintf("[recv] REQUEST:%s\n",{
		pid = pid,
		agent = skynet.address(agent),
		cmd = cmd,
		request = request,
	})
	local protoname,subprotoname = string.match(cmd,"([^_]-)%_(.+)") 
	if not obj.passlogin and protoname ~= "login" then
		logger.log("warning","netclient",format("[not passlogin] pid=%s cmd=%s request=%s",pid,cmd,request))
		return
	end
	if not net[protoname] then
		logger.log("warning","netclient",format("[unknow proto] pid=%s cmd=%s request=%s",pid,cmd,request))
		return
	end
	local REQUEST = net[protoname].REQUEST
    local func = REQUEST[subprotoname]
    if not func then
        logger.log("warning","netclient",format("[unknow cmd] pid=%s cmd=%s request=%s",pid,cmd,request))
        return
    end

	local r = func(obj,request)
	logger.pprintf("[send] RESPONSE:%s\n",{
		pid = obj.pid,
		cmd = cmd,
		response = r,
	})
	return r
end

-- 这里的session是sproto协议带的session，和skynet服务之间调用内部维护的session（proto.dispatch参数中的session)不一样!
local function onresponse(agent,session,response)
	local connect = proto.connection[agent]
	if not connect then
		logger.log("warning","netclient",format("[NON EXIST AGENT] [onresponse] agent=%s session=%s response=%s",agent,session,response))
		return
	end
	-- 替换下线时，旧对象已被删除，忽略其收到的回复
	local obj = playermgr.getobject(connect.pid)
	if not obj then
		return
	end
	logger.pprintf("[recv] RESPONSE:%s\n",{
		pid = obj.pid,
		agent = skynet.address(agent),
		session = session,
		response = response,
	})
	local ses = assert(connect.sessions[session],"error session id:" .. tostring(session))
	connect.sessions[session] = nil
	local callback = ses.onresponse
	if not callback then
		callback = net[ses.protoname].RESPONSE[ses.cmd]
	end
	if callback then
		callback(obj,ses.request,response)
	end
end

local function filter(agent,typ,...)
	return false
end

local CMD = {}
proto.CMD = CMD
function CMD.data(agent,typ,...)
	if filter(agent,typ,...) then
		return
	end
	if typ == "REQUEST" then
		local result = onrequest(agent,...)
		skynet.ret(skynet.pack(result))
	else
		assert(typ == "RESPONSE")
		onresponse(agent,...)
	end
end

function CMD.start(agent,fd,ip)
	local obj = cobject.new(agent,fd,ip)
	playermgr.addobject(obj)
	proto.connection[agent] = {
		pid = obj.pid,
		fd = fd,
		session = 0,
		sessions = {},
	}
end

function CMD.close(agent)
	local connect = proto.connection[agent]
	if not connect then
		return
	end
	local pid = assert(connect.pid,"invalid pid:" .. tostring(connect.pid))
	playermgr.delobject(pid,"disconnect")
	proto.connection[agent] = nil
end

function proto.dispatch(session,source,cmd,...)
	local pid = 0
	if proto.connection[source] then
		pid = proto.connection[source].pid
	end
	logger.log("debug","netclient",format("[recv] source=%s session=%d pid=%d cmd=%s package=%s",source,session,pid,cmd,{...}))
	local f = proto.CMD[cmd]
	return f(source,...)
end


function proto.init()
	proto.reloadproto()
	proto.connection = {}
end

function proto.reloadproto()
	local protodata = require "script.proto.proto"
	local sprotoparser = require "sprotoparser"
	local sprotoloader = require "sprotoloader"
	protodata.init()
	protodata.dump()
	local bin_c2s = sprotoparser.parse(protodata.c2s)
	local bin_s2c = sprotoparser.parse(protodata.s2c)
	sprotoloader.save(bin_c2s,1)
	sprotoloader.save(bin_s2c,2)
	if game.initall then
		for _,pid in ipairs(playermgr.allobject()) do
			local obj = playermgr.getobject(pid)
			if obj.__agent then
				skynet.send(obj.__agent,"lua","reloadproto")
			end
		end
	end
end


return proto
