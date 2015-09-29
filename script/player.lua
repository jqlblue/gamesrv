
require "script.card.init"
require "script.card.carddb"
require "script.card.cardtablelib"
require "script.friend.frienddb"
require "script.card.cardbaglib"
require "script.card.cardcontainer"

cplayer = class("cplayer",csaveobj,cdatabaseable)

function cplayer:init(pid)
	self.flag = "cplayer"
	csaveobj.init(self,{
		pid = pid,
		flag = self.flag,
	})
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	-- resume
	self.pid = pid
	self.name = nil
	self.account = nil
	self.lv = nil
	self.viplv = nil
	self.roletype = nil
	self.gold = nil
	self.chip = nil

	self.data = {}
	self.golden_carddb = ccarddb.new{pid = self.pid,flag = "golden",}
	self.wood_carddb = ccarddb.new{pid=self.pid,flag="wood",}
	self.water_carddb = ccarddb.new{pid=self.pid,flag="water",}
	self.fire_carddb = ccarddb.new{pid=self.pid,flag="fire",}
	self.soil_carddb = ccarddb.new{pid=self.pid,flag="soil",}
	self.neutral_carddb = ccarddb.new{pid=self.pid,flag="neutral",}
	self.carddb = ccardcontainer.new{
		golden = self.golden_carddb,
		wood = self.wood_carddb,
		water = self.water_carddb,
		fire = self.fire_carddb,
		soil = self.soil_carddb,
		neutral = self.neutral_carddb,
	}
	self.cardtablelib = ccardtablelib.new(self.pid)
	self.cardbaglib = ccardbaglib.new(self.pid)
	self.frienddb = cfrienddb.new(self.pid)
	self.today = ctoday.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thistemp = cthistemp.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thisweek = cthisweek.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thisweek2 = cthisweek2.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.timeattr = cattrcontainer.new{
		today = self.today,
		thistemp = self.thistemp,
		thisweek = self.thisweek,
		thisweek2 = self.thisweek2,
	}
	self.autosaveobj = {
		card = self.carddb,
		cardtablelib = self.cardtablelib, 
		cardbaglib = self.cardbaglib,
		friend = self.frienddb,
		time = self.timeattr,
	}

	self.loadstate = "unload"
	self:autosave()
end

function cplayer:save()
	local data = {}
	data.data = self.data
	data.resume = self:packresume()
	return data
end


function cplayer:load(data)
	if not data or not next(data) then
		logger.log("error","err",string.format("cplayer:load null,pid=%d",self.pid))
		return
	end
	self.data = data.data
	self:unpackresume(data.resume)
end

function cplayer:packresume()
	local resume = {
		gold = self.gold,
		chip = self.chip,
		viplv = self.viplv,
		account = self.account,
		name = self.name,
		lv = self.lv,
		viplv = self.viplv,
		roletype = self.roletype,
	}
	return resume
end

function cplayer:unpackresume(resume)
	self.gold = resume.gold
	self.chip = resume.chip
	self.account = resume.account
	self.name = resume.name
	self.lv = resume.lv
	self.viplv = resume.viplv
	self.roletype = resume.roletype
end

		
function cplayer:savetodatabase()
	assert(self.pid)
	if self.nosavetodatabase then
		return
	end

	local db = dbmgr.getdb(cserver.getsrvname(self.pid))
	if self.loadstate == "loaded" then
		local data = self:save()
		db:set(db:key("role",self.pid,"data"),data)
	end
	for k,v in pairs(self.autosaveobj) do
		if v.loadstate == "loaded" then
			db:set(db:key("role",self.pid,k),v:save())
		end
	end
	playermgr.unloadofflineplayer(self.pid)
end

function cplayer:loadfromdatabase(loadall)
	if loadall == nil then
		loadall = true
	end
	assert(self.pid)
	if self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb(cserver.getsrvname(self.pid))
		local data = db:get(db:key("role",self.pid,"data"))
		pprintf("role:data=>%s",data)
		-- 正常角色至少会有基本数据
		if not data or not next(data) then
			self.loadstate = "loadnull"
		else
			self:load(data)
			self.loadstate = "loaded"
		end
	end
	if loadall then
		for k,v in pairs(self.autosaveobj) do
			if v.loadstate == "unload" then
				v.loadstate = "loading"
				local db = dbmgr.getdb(cserver.getsrvname(self.pid))
				local data = db:get(db:key("role",self.pid,k))
				v:load(data)
				v.loadstate = "loaded"
			end
		end
	end
end

function cplayer:isloaded()
	if self.loadstate == "loaded" then
		for k,v in pairs(self.autosaveobj) do
			if v.loadstate ~= "loaded" then
				return false
			end
		end
		return true
	end
	return false
end

function cplayer:create(obj,conf)
	local name = assert(conf.name)
	local roletype =assert(conf.roletype)
	local account = assert(conf.account)
	logger.log("info","createrole",string.format("createrole,account=%s pid=%s name=%s roletype=%s ip=%s",account,self.pid,name,roletype,obj.__ip))

	self.loadstate = "loaded"
	self.account = account
	self.name = conf.name
	self.roletype = conf.roletype
	self.gold = 0
	self.lv = 25
	self.chip = 0
	self.viplv = 0
	self.createtime = getsecond()
	local db = dbmgr.getdb()
    db:hset(db:key("role","list"),self.pid,1)
    route.addroute(self.pid)
	self:oncreate()
end

function cplayer:entergame()
	self:onlogin()
	self:synctoac()
end


-- 正常退出游戏
function cplayer:exitgame()
	self:onlogoff()
	playermgr.delobject(self.pid,"exitgame")
end

-- 跨服前处理流程
function cplayer:ongosrv(srvname)
end

-- 回到原服前处理流程
function cplayer:ongohome()
end

-- 掉线处理(正常退出游戏也会走该接口)
function cplayer:disconnect(reason)
	self:savetodatabase()
	self:ondisconnect(reason)
	self:synctoac()
end

function cplayer:synctoac()
	local role = {
		roleid = self.pid,
		name = self.name,
		gold = self.gold,
		lv = self.lv,
		roletype = self.roletype,
	}
	role = cjson.encode(role)
	local url = string.format("/sync?gameflag=%s&srvname=%s&acct=%s&roleid=%s",cserver.gameflag,cserver.srvname,self.account,self.pid)
	httpc.get(cserver.accountcenter.host,url,nil,nil,role)
end


local function heartbeat(pid)
	local player = playermgr.getplayer(pid)
	if player then
		timer.timeout("player.heartbeat",120,functor(heartbeat,pid))
		sendpackage(pid,"player","heartbeat")
	end
end

function cplayer:oncreate()
	logger.log("info","register",string.format("register,account=%s pid=%d name=%s roletype=%d lv=%s gold=%d ip=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip()))

	self.frienddb:oncreate(self)
	resumemgr.oncreate(self)
end

function cplayer:onlogin()
	logger.log("info","login",string.format("login,account=%s pid=%s name=%s roletype=%s lv=%s gold=%s ip=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip()))
	local srvobj = globalmgr.getserver()
	heartbeat(self.pid)
	sendpackage(self.pid,"player","resource",{
		gold = self.gold,
	})
	sendpackage(self.pid,"player","switch",self:query("switch",{
		gm = self:authority() > 0,
		friend = srvobj:isopen("friend"),
	}))
	mailmgr.onlogin(self)
	if srvobj:isopen("friend")	then
		self.frienddb:onlogin(self)
	end
	resumemgr.onlogin(self)
	self:doing("login")
end

function cplayer:onlogoff()

	logger.log("info","login",string.format("logoff,account=%s pid=%s name=%s roletype=%s lv=%s gold=%s ip=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip()))
	mailmgr.onlogoff(self)
	local srvobj = globalmgr.getserver()
	if srvobj:isopen("friend")	then
		self.frienddb:onlogoff(self)
	end
	resumemgr.onlogoff(self)
	self:doing("logoff")
end

function cplayer:ondisconnect(reason)

	logger.log("info","login",string.format("disconnect,account=%s pid=%s name=%s roletype=%s lv=%s gold=%s ip=%s reason=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip(),reason))
	loginqueue.pop()
end

function cplayer:ondayupdate()
end

function cplayer:onweekupdate()
end

function cplayer:onweek2update()
end

function cplayer:validpay(typ,num,notify)
	local hasnum
	if typ == "gold" then
		hasnum = self.gold
	elseif typ == "chip" then
		hasnum = self.chip
	else
		error("invalid resource type:" .. tostring(typ))
	end
	if hasnum < num then
		if notify then
			local RESNAME = {
				gold = "金币",
				chip = "chip",
			}
			net.msg.notify(self.pid,string.format("%s不足%d",resname[typ],num))
		end
		return false
	end
	return true
end

function cplayer:addlv(val,reason)
	local oldval = self.lv
	local newval = oldval + val
	logger.log("info","lv",string.format("#%d addlv,%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.resume:set("lv",newval)
end

function cplayer:addgold(val,reason)
	val = math.floor(val)
	local oldval = self.gold
	local newval = oldval + val
	logger.log("info","resource/gold",string.format("#%d addgold,%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	assert(newval >= 0,string.format("not enough gold:%d+%d=%d",oldval,val,newval))
	self:set("gold",newval)
	return val
end

function cplayer:addchip(val,reason)
	val = math.floor(val)
	local oldval = self.chip
	local newval = oldval + val
	logger.log("info","resource/chip",string.format("#%d addchip,%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	assert(newval >= 0,string.format("not enough chip:%d+%d=%d",oldval,val,newval))
	self:set("chip",newval)
	return val
end

function cplayer:getcarddbbysid(sid)
	local cardcls = getclassbycardsid(sid)
	local racename = getracename(cardcls.race)
	local carddb = self.carddb:getcarddb_byname(racename)
	return assert(carddb,"Invalid card sid:" .. tostring(sid))
end

function cplayer:getcard(cardid)
	for name,_carddb in pairs(self.carddb.data) do
		local card = _carddb.getcard(cardid)
		if card then
			return card
		end
	end
end

function cplayer:addcard(sid,num,reason)
	local carddb = self:getcarddbbysid(sid)
	carddb:addcardbysid(sid,num,reason)
end

function cplayer:addcards(cards,reason)
	for i,v in ipairs(cards) do
		self:addcard(v.itemid,v.num,reason)
	end
end

function cplayer:addcardbag(id,num,reason)
	if not self.cardbaglib:isvalidid(id) then
		return 0
	end
	if num < 0 then
		local hasnum = self.cardbaglib:getcardbagnum(id)
		assert(hasnum + num >= 0,"[addcardbag] num not enough")
	end
	return self.cardbaglib:addcardbag(id,num,reason)
end

function cplayer:additem(itemid,num,reason)
	if itemid <= MAX_ITEMID then -- cardbag
		self:addcardbag(itemid,num,reason)
	else	-- card
		self:addcard(itemid,num,reason)

	end
end

function cplayer:additems(items,reason)
	for i,item in ipairs(items) do
		self:additem(item.itemid,item.num,reason)
	end
end

function cplayer:doing(what)
	local frdblk = self.frienddb:getfrdblk(self.pid)
	frdblk:set("doing",what)
end

function cplayer:pack_fight_profile()
	local cardtableid = assert(self:query("fight.cardtableid"))
	local cardtable = self.cardtablelib:getcardtable(cardtableid,0)
	
	return {
		pid = self.pid,
		lv = self.lv,
		name = self.name,
		wincnt = self:query("fight.wincnt",0),
		failcnt = self:query("fight.failcnt",0),
		consecutive_wincnt = self:query("fight.consecutive_wincnt",0),
		consecutive_failcnt = self:query("fight.consecutive_failcnt",0),
		show_achivelist = self:query("fight.show_achivelist",{}),
		race = cardtable.race,
		cardtable = cardtable,
	}
end

function cplayer:unpack_fight_profile(profile)
	local wincnt = assert(profile.wincnt)	
	local failcnt = assert(profile.failcnt)
	local consecutive_wincnt = assert(profile.consecutive_wincnt)
	local consecutive_failcnt = assert(profile.consecutive_failcnt)
	self:set("fight.wincnt",wincnt)
	self:set("fight.failcnt",failcnt)
	self:set("fight.consecutive_wincnt",consecutive_wincnt)
	self:set("fight.consecutive_failcnt",consecutive_failcnt)
	-- check task
	-- check achivement
end

-- getter
function cplayer:authority()
	if skynet.getenv("mode") == "debug" then
		return 100
	end
	return self:query("auth",0)
end

function cplayer:ip()
	return self.__ip
end

function cplayer:port()
	return self.__port
end

function cplayer:teamstate()
	if not teamid then
		return NO_TEAM
	end
	local team = teammgr.getteam(teamid)
	if not team then
		self.teamid = nil
		return NO_TEAM 
	end
	if team.captain == self.pid then
		return TEAM_CAPTAIN
	elseif team.follow[self.pid] then
		return TEAM_STATE_FOLLOW
	elseif team.leave[self.pid] then
		return TEAM_STATE_LEAVE
	end
	return NO_TEAM
end

function cplayer:getteamid()
	if self.teamid then
		local team = teammgr:getteam(self.teamid)
		if not team then
			sendpackage(self.pid,"team","delmember",{
				teamid = self.teamid,
				pid = self.pid,
			})
			self.teamid = nil
		end
	end
	return self.teamid
end

-- 组对成员
function cplayer:packmember()
	return {
		pid = self.pid,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		state = self:teamstate(),
	}
end

-- setter
function cplayer:setauthority(auth)
	self:set("auth",auth)
end


