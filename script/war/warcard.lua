
local BUFF_TYPE = 0
local HALO_TYPE = 1

cwarcard = class("cwarcard")

function cwarcard:init(conf)
	self.id = assert(conf.id)
	self.sid = assert(conf.sid)
	self.warid = assert(conf.warid)
	self.pid = assert(conf.pid)
	self.birthday = assert(conf.birthday)
	self.pos = nil
	self.inarea = "cardlib"
	self.halos = {}
	self.haloto = {} -- 光环收益对象:{[id]=true}
	self.buffs = {}
	self.state = {}
	self.atkcnt = 0
	self.leftatkcnt = 0
	self:initproperty()
end

function cwarcard:initproperty()
	local cardcls = getclassbycardsid(self.sid)
	self.type =  cardcls.type
	self.targettype = cardcls.targettype
	self.choice = cardcls.choice
	self.maxhp = cardcls.hp
	self.hp = self.maxhp
	self.atk = cardcls.atk
	self.magic_hurt = cardcls.magic_hurt
	self.recoverhp = cardcls.recoverhp
	self.crystalcost = cardcls.crystalcost
	self.magic_hurt_adden = cardcls.magic_hurt_adden
	self.atkcnt = cardcls.atkcnt
	self.hurt = 0
end


-- 取消抉择
function cwarcard:cancelchoice()
	self.cancelchoice = true
	warmgr.refreshwar(self.warid,self.pid,"cancelchoice",{id=self.id})
end

function cwarcard:setstate(type,newstate,nosync)	
	local oldstate = self.state[type]
	self.state[type] = newstate
	if oldstate ~= newstate  then
		logger.log("debug","war",string.format("[warid=%d] #%d setstate,cardid=%d type:%s,state:%s->%s",self.warid,self.pid,self.id,type,oldstate,newstate))
		if not nosync then
			warmgr.refreshwar(self.warid,self.pid,"setstate",{id=self.id,type=type,value=newstate})
		end
		if (not oldstate) and newstate then
			if type == "enrage" then
				self:onenrage()
			elseif type == "assault" then
				self:setleftatkcnt(self.atkcnt)
			end
		end
	end
end


function cwarcard:getstate(type)
	return self.state[type]
end

function cwarcard:delstate(type)
	local oldstate = self.state[type]
	if oldstate then
		logger.log("debug","war",string.format("#%d delstate,cardid=%d,type=%s",self.pid,self.id,type))
		self.state[type] = nil
		warmgr.refreshwar(self.warid,self.pid,"delstate",{id=self.id,state=type})
		if type == "enrage" then
			self:onunenrage()
		end
	end
	
end

function cwarcard:addleftatkcnt(value)
	local v = math.max(0,self.leftatkcnt + value)
	self:setleftatkcnt(v)
end

function cwarcard:setleftatkcnt(atkcnt,nosync)
	local oldleftatkcnt = self.leftatkcnt
	if oldleftatkcnt ~= atkcnt then
		self.leftatkcnt = atkcnt
		if not nosync then
			warmgr.refreshwar(self.warid,self.pid,"setleftatkcnt",{id=self.id,value=self.leftatkcnt,})
		end
	end
end

function cwarcard:setatkcnt(atkcnt,nosync)
	local oldatkcnt = self.atkcnt
	if oldatkcnt ~= atkcnt then
		self.atkcnt = atkcnt
		if not nosync then
			warmgr.refreshwar(self.warid,self.pid,"setatkcnt",{id=self.id,value=self.atkcnt,})
		end
		self:addleftatkcnt(atkcnt-oldatkcnt)
	end

end

local valid_lrhalo = {
	addatk = true,
	addmaxhp = true,
}

function cwarcard:setlrhalo(type,value)
	if not valid_lrhalo[type] then
		return
	end
	self.lrhalo[type] = value
	warmgr.refreshwar(self.warid,self.pid,"setlrhalo",{id=self.id,lrhalo=self.lrhalo})
end



function cwarcard:getmaxhp()
	local maxhp = self.maxhp
	if self.buff.setmaxhp then
		maxhp = self.buff.setmaxhp
	end

	local laddmaxhp,raddmaxhp = 0,0
	if self.inarea == "war" then
		local war = warmgr.getwar(self.warid)
		local warobj = war:getwarobj(self.pid)
		local warcard
		local id = warobj.warcards[self.pos-1]
		if id then
			warcard = warobj.id_card[id]
			laddmaxhp = warcard.lrhalo.addmaxhp
		end
		id = warobj.warcards[self.pos+1]
		if id then
			warcard = warobj.id_card[id]
			raddmaxhp = warcard.lrhalo.addmaxhp
		end
	end
	local lrhalo_addmaxhp = laddmaxhp + raddmaxhp
	return maxhp + self.buff.addmaxhp + self.halo.addmaxhp + lrhalo_addmaxhp
end

function cwarcard:setmaxhp(value)
	assert(value > 0)
	self.buff.setmaxhp = value
	self.buff.addmaxhp = 0
	local maxhp = self:getmaxhp()
	warmgr.refreshwar(self.warid,self.pid,"setmaxhp",{id=self.id,value=maxhp,})
	if self:gethp() > maxhp then
		self:sethp(maxhp)
	end
end

function cwarcard:addmaxhp(value,mode)
	if mode == BUFF_TYPE then
		self.buff.addmaxhp = self.buff.addmaxhp + value
		assert(self.buff.addmaxhp >= 0,string.format("buff.addmaxhp: %d < 0",self.buff.addmaxhp))
		self.buff.addhp = math.max(0,self.buff.addhp + value)
	else
		assert(mode == HALO_TYPE)
		self.halo.addmaxhp = self.halo.addmaxhp + value
		assert(self.halo.addmaxhp >= 0,string.format("halo.addmaxhp: %d < 0",self.halo.addmaxhp))
		self.halo.addhp = math.max(0,self.halo.addhp + value)
	end
	warmgr.refreshwar(self.warid,self.pid,"setmaxhp",{id=self.id,value=self:getmaxhp(),})
end

function cwarcard:gethp()
	return self.hp + self.buff.addhp + self.halo.addhp
end

function cwarcard:sethp(value,bsync)
	bsync = bsync or true
	self.buff.addhp = 0
	self.halo.addhp = 0
	self.hp = value
	local hp = self:gethp()
	if bsync then
		warmgr.refreshwar(self.warid,self.pid,"sethp",{id=self.id,value=hp,})
	end
	local ishurt = hp < self:getmaxhp()
	if ishurt then
		local state = ishurt and 1 or 0
		self:setstate("enrage",state)
	end
	if self.hp <= 0 then
		self:setdie()
	end
end

function cwarcard:addhp(value,srcid)
	local hp = self:gethp()
	logger.log("debug","war",string.format("[warid=%d] #%d warcard.addhp,id=%d hp=%d+%d srcid=%d",self.warid,self.pid,self.id,hp,value,srcid))
	if self:isdie() then
		return
	end
	local maxhp = self:getmaxhp()
	local oldhp = self:gethp()
	value = math.min(maxhp - hp,value)
	if value > 0 then
		if self:__onaddhp(value) then
			return
		end
		if self.hp < self.maxhp then
			local addval = self.maxhp - self.hp
			value = value - addval
			self.hp = self.hp + addval
		end
		if value > 0 then
			if self.halo.addhp < self.halo.addmaxhp then
				local addval = self.halo.addmaxhp - self.halo.addhp
				value = value - addval
				self.halo.addhp = self.halo.addhp + addval
			end
			if value > 0 then
				if self.buff.addhp < self.buff.addmaxhp then
					local addval = self.buff.addmaxhp - self.buff.addhp
					value = value - addval
					self.buff.addhp = self.buff.addhp + addval
				end
			end
		end
	elseif value < 0 then
		-- 免疫状态回合结束时结
		if self:getstate("immune") then
			return
		end
		if self:getstate("shield") then
			self:delstate("shield")
			return
		end
		value = -value
		if self:__onhurt(value,srcid) then
			return
		end
		if self.buff.addhp > 0 then
			local costhp = math.min(self.buff.addhp,value)
			value = value - costhp
			self.buff.addhp = self.buff.addhp - costhp
		end
		if value > 0 then
			if self.halo.addhp > 0 then
				local costhp = math.min(self.halo.addhp,value)
				value = value - costhp
				self.halo.addhp = self.halo.addhp - costhp
			end
			if value > 0 then
				assert(self.hp > 0)
				self.hp = self.hp - value
				self.hurt = self.hurt + value
			end
		end
	end
	local newhp = self:gethp()
	if oldhp ~= newhp then
		warmgr.refreshwar(self.warid,self.pid,"sethp",{id=self.id,value=newhp,})
	end
	if newhp == maxhp then
		self:delstate("enrage")
	else
		assert(newhp < maxhp,string.format("hp(%d) > maxhp(%d)",newhp,maxhp))
		self:setstate("enrage",1)
	end
	if self.hp <= 0 then
		self:setdie()
	end
end

function cwarcard:getowner(id)
	id = id or self.id
	local war = warmgr.getwar(self.id)
	return war:getowner(id)
end

function cwarcard:__get(buff_halo,attr)
	local lastval
	for i,v in ipairs(buff_halo) do
		if v[attr] then
			lastval = v[attr]
		end
	end
	return lastval
end

function cwarcard:getfromhalo(owner,attr,maxid)
	-- 光环(取最后进入战场卡牌光环效果)
	maxid = maxid or 0
	local val
	if owner.hero.weapon then
		local warcard = owner.hero.weapon
		if warcard.haloto[self.id] and warcard.id > maxid  then
			local tmp = self:__get(warcard.halos,attr)
			if tmp then
				maxid = warcard.id
				val = tmp
			end
		end
	end

	for i,id in ipairs(owner.secretcards) do
		local warcard = owner.id_card[id]
		if warcard.haloto[self.id] and warcard.id > maxid then
			local tmp = self:get(warcard.halos,attr)
			if tmp then
				maxid = warcard.id
				val = tmp
			end
		end
	end
	for i,id in ipairs(owner.warcards) do
		local warcard = owner.id_card[id]
		if warcard.haloto[self.id] and warcard.id > maxid then
			local tmp = self:get(warcard.halos,attr)
			if tmp then
				maxid = warcard.id
				val = tmp
			end
		end
	end
	return val,maxid
end

function cwarcard:__get2(buffs_or_halos,attr)
	local sum = 0
	for i,v in ipairs(buffs_or_halos) do
		if v[attr] then
			sum = sum + v[attr]
		end
	end
	return sum
end

function cwarcard:getfromhalo2(owner,attr)
	local sum = 0
	if owner.hero.weapon then
		local warcard = owner.hero.weapon
		if warcard.haloto[self.id] then
			local tmp = self:__get(warcard.halos,attr)
			if tmp then
				sum = sum + tmp
			end
		end
	end

	for i,id in ipairs(owner.secretcards) do
		local warcard = owner.id_card[id]
		if warcard.haloto[self.id] then
			local tmp = self:get(warcard.halos,attr)
			if tmp then
				sum = sum + tmp
			end
		end
	end
	for i,id in ipairs(owner.warcards) do
		local warcard = owner.id_card[id]
		if warcard.haloto[self.id] then
			local tmp = self:get(warcard.halos,attr)
			if tmp then
				sum = sum + tmp
			end
		end
	end
	return sum
end

function cwarcard:get(attr)
	-- 光环
	local owner = self:getowner()
	local val,maxid = self:getfromhalo(owner,attr,0)
	local enemy_val,enemy_maxid = self:getfromhalo(owner.enemy,"enemy_" .. attr,maxid)
	if maxid ~= enemy_maxid then
		val = assert(enemy_val)
	end
	if val then
		return val
	end
	-- BUFF
	val = self:__get(self.buffs,attr)
	if val then
		return val
	end
	return self[attr]
end


-- 得到增加（累积）的属性，如：addatk
function cwarcard:get2(attr)
	-- 光环
	local owner = self:getowner()
	local self_halo_add = self:getfromhalo2(owner,attr) or 0
	local enemy_halo_add = self:getfromhalo2(owner.enemy,"enemy_" .. attr) or 0
	-- BUFF
	local self_buff_add = self:__get2(self.buffs,attr) or 0
	return self_halo_add + enemy_halo_add + self_buff_add + (self[attr] or 0)
end

function cwarcard:has(attr)
	local val = self:get(attr)
	if type(val) ~= "boolean" then
		return val == YES
	else
		return val
	end
end



function cwarcard:getatk()
	-- 光耀之子：攻击力==生命值
	if self.sid == 134002 or self.sid == 234002 then
		if not self.silence then
			return self:gethp()
		end
	end
	local atk = self:get("atk")
	if atk then
		return atk
	end
	return self:get2("addatk") + self.atk
end

function cwarcard:getcrystalcost()
	local crystalcost = self:get("crystalcost")
	if crystalcost then
		return crystalcost
	end
	return self:get2("addcrystalcost")  + self.crystalcost
end

function cwarcard:gethurtvalue(magic_hurt)
	if is_footman(self.type) then
		return self:getatk()
	else
		if not magic_hurt then
			magic_hurt = self.magic_hurt
		end
		local war = warmgr.getwar(self.warid)
		local warobj = war:getwarobj(self.pid)
		local hurtvalue = (magic_hurt + warobj:get_magic_hurt_adden()) * warobj.magic_hurt_multiple
		if warobj.cure_to_hurt == 1 then
			hurtvalue = -hurtvalue
		end
		return hurtvalue
	end
end

function cwarcard:getrecoverhp(recoverhp)
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	recoverhp = recoverhp or self.recoverhp
	return warobj:getrecoverhp(recoverhp)
end

function cwarcard:set_magic_hurt_adden(value)
	assert(value >= 0)
	local oldvalue = self.magic_hurt_adden
	if oldvalue ~= value then
		self.magic_hurt_adden = value
		logger.log("debug","war",string.format("[warid=%d] #%d set_magic_hurt_adden,cardid=%d value:%d->%d",self.warid,self.pid,self.id,oldvalue,value))
		warmgr.refreshwar(self.warid,self.pid,"set_card_magic_hurt_adden",{id=self.id,value=value})
		local war = warmgr.getwar(self.warid)
		local warobj = war:getwarobj(self.pid)
		warobj:add_magic_hurt_adden(value-oldvalue)
	end
end

function cwarcard:issilence()
	return self.buffs.start
end

function cwarcard:silence()
	logger.log("debug","war",string.format("[warid=%d] #%d card.silence,cardid=%d",self.warid,self.pid,self.id))
	self:set_magic_hurt_adden(0)
	self:setatkcnt(1)
	self:clearlrhalo()
	self:clearstate()
	self:clearbuff()
	self:cleareffect()
	self:onremovefromwar()
	self:oncheckdie()
	self.buffs.start = #self.buffs
	local hp = self.maxhp - self.hurt
	self:sethp(hp,false)
	warmgr.refreshwar(self.warid,self.pid,"silence",{id=self.id,pos=self.buffs.start})
	warmgr.refreshwar(self.warid,self.pid,"synccard",{warcard=self:pack(),})
end

function cwarcard:clearbuff()
	self.buff = {}
	self.buff.addmaxhp = 0
	self.buff.addatk = 0
	self.buff.addcrystalcost = 0
	self.buff.addhp = 0
end

function cwarcard:clearhalo()
	self.halo = {}
	self.halo.addmaxhp = 0
	self.halo.addatk  = 0
	self.halo.addcrystalcost = 0
	self.halo.addhp = 0
end

function cwarcard:clearlrhalo()
	self.lrhalo = {
		addatk = 0,
		addmaxhp = 0,
	}
end

function cwarcard:clearstate()
	self.state = {}
end

function cwarcard:cleareffect()
	self.effect = {
		ondie = {},
		oncheckdie = {},
		onaddhp = {},
		onhurt = {},
		ondefense = {},
		onattack = {},
		onenrage = {},
		onunenrage = {},
		onendround = {},
		onbeginround = {},
	}
end

function cwarcard:pack()
	return {
		id = self.id,
		sid = self.sid,
		maxhp = self:getmaxhp(),
		atk = self:getatk(),
		hp = self:gethp(),
		state = self.state,
		atkcnt = self.atkcnt,
		leftatkcnt = self.leftatkcnt,
		pos = self.pos,
		magic_hurt_adden = self.magic_hurt_adden,
	}
end

function cwarcard:copyfrom(warcard)
	self.buffs = warcard.buffs
	self.buff = warcard.buff
	self.hp = warcard.hp
	self.atk = warcard.atk
	self.maxhp = warcard.maxhp
	self.crystalcost = warcard.crystalcost
	self.state = warcard.state
	self.atkcnt = warcard.atkcnt
	self.leftatkcnt = warcard.leftatkcnt
	self.effect = warcard.effect
end

function cwarcard:isdie()
	if self.__isdie then
		return true
	end
	-- after delcard
	if self.inarea == "graveyard" then
		return true
	end
	return false
end

function cwarcard:setdie()
	if not self.__isdie then
		logger.log("info","war",string.format("[warid=%d] #%d card.setdie,cardid=%d",self.warid,self.pid,self.id))
		self.__isdie = true
		local war = warmgr.getwar(self.warid)
		local warobj = war:getwarobj(self.pid)
		table.insert(warobj.diefootman,self)
		self:__ondie()
	end
end

function cwarcard:addeffect(type,effect)
	local effects = assert(self.effect[type],"Invalid effect type:" .. tostring(type))
	table.insert(effects,effect)
	warmgr.refreshwar(self.warid,self.pid,"addeffect",{id=self.id,type=type,effect=effect})
end

function cwarcard:deleffect(type,srcid)
	local effects = assert(self.effect[type],"Invalid effect type:" .. tostring(type))
	for i,effect in ipairs(effects) do
		if effect.id == srcid then
			table.remove(effects,i)
			warmgr.refreshwar(self.warid,self.pid,"deleffect",{id=self.id,type=type,srcid=srcid,})
			break
		end
	end
end


function cwarcard:__onenrage()
	-- 自身效果
	self:onenrage()
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onenrage) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onenrage(warcard,self)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	return ret
end

function cwarcard:__onenrage()
	-- 自身效果
	self:onunenrage()
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onunenrage) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onunenrage(warcard,self)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	return ret
end

function cwarcard:__onbeginround(roundcnt)
	-- 自身效果
	self:onbeginround(roundcnt)
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onbeginround) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onbeginround(warcard,self,roundcnt)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	return ret
end

function cwarcard:__onendround(roundcnt)
	-- 自身效果
	self:onendround(roundcnt)
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onendround) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onendround(warcard,self,roundcnt)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	return ret
end



function cwarcard:__onattack(target)
	-- 自身效果
	self:onattack(target)
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onattack) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onattack(warcard,self,target)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
		if self:isdie() then
			break
		end
	end
	if not self:isdie() then
		-- 光环效果
		if ignoreevent ~= IGNORE_ALL_LATER_EVENT then
			local categorys = warobj:getcategorys(self.type,self.sid,false)
			for _,category in ipairs(categorys) do
				for _,id in ipairs(category.onattack) do
					owner = war:getowner(id)
					warcard = owner.id_card[id]
					cardcls = getclassbycardsid(warcard.sid)
					eventresult = cardcls.__onattack(warcard,self,target)
					if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
						ret = true
					end
					ignoreevent = EVENTRESULT_FIELD2(eventresult)
					if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
						break
					end
					if self:isdie() then
						break
					end
				end
				if self:isdie() then
					break
				end
			end
		end
	end
	return ret
end

function cwarcard:__ondefense(attacker)
	-- 自身效果
	self:ondefense(attacker)
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.ondefense) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__ondefense(warcard,attacker,self)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
		if attacker:isdie() then
			break
		end
	end
	if not attacker:isdie() then
		-- 光环效果
		if ignoreevent ~= IGNORE_ALL_LATER_EVENT then
			local categorys = warobj:getcategorys(self.type,self.sid,false)
			for _,category in ipairs(categorys) do
				for _,id in ipairs(category.ondefense) do
					owner = war:getowner(id)
					warcard = owner.id_card[id]
					cardcls = getclassbycardsid(warcard.sid)
					eventresult = cardcls.__ondefense(warcard,attacker,self)
					if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
						ret = true
					end
					ignoreevent = EVENTRESULT_FIELD2(eventresult)
					if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
						break
					end
					if attacker:isdie() then
						break
					end
				end
				if attacker:isdie() then
					break
				end
			end
		end
	end
	return ret
end

function cwarcard:__onaddhp(recoverhp)
	-- 自身效果
	self:onaddhp(recoverhp)
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onaddhp) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onaddhp(warcard,self,recoverhp)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	-- 光环效果
	if ignoreevent ~= IGNORE_ALL_LATER_EVENT then
		local categorys = warobj:getcategorys(self.type,self.sid,false)
		for _,category in ipairs(categorys) do
			for _,id in ipairs(category.onaddhp) do
				owner = war:getowner(id)
				warcard = owner.id_card[id]
				cardcls = getclassbycardsid(warcard.sid)
				eventresult = cardcls.__onaddhp(warcard,recoverhp)
				if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
					ret = true
				end
				ignoreevent = EVENTRESULT_FIELD2(eventresult)
				if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
					break
				end
			end
		end
	end
	return ret
end


function cwarcard:__onhurt(hurtvalue,srcid)
	-- 自身效果
	self:onhurt(hurtvalue,srcid)
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.onhurt) do
		id = v.id
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__onhurt(warcard,self,hurtvalue,srcid)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	-- 光环效果
	if ignoreevent ~= IGNORE_ALL_LATER_EVENT then
		local categorys = warobj:getcategorys(self.type,self.sid,false)
		for _,category in ipairs(categorys) do
			for _,id in ipairs(category.onhurt) do
				owner = war:getowner(id)
				warcard = owner.id_card[id]
				cardcls = getclassbycardsid(warcard.sid)
				eventresult = cardcls.__onhurt(warcard,self,hurtvalue,srcid)
				if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
					ret = true
				end
				ignoreevent = EVENTRESULT_FIELD2(eventresult)
				if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
					break
				end
			end
		end
	end
	return ret
end



function cwarcard:__ondie()
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	-- 自身效果
	self:ondie()
	-- buff效果
	local ret = false
	local ignoreevent = IGNORE_NONE
	local eventresult
	local owner,warcard,cardcls
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	local id
	for _,v in ipairs(self.effect.ondie) do
		id = v.id
		assert(id ~= self.id)
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__ondie(warcard,self)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	-- 光环效果
	if ignoreevent ~= IGNORE_ALL_LATER_EVENT then
		local categorys = warobj:getcategorys(self.type,self.sid,false)
		for _,category in ipairs(categorys) do
			for _,id in ipairs(category.ondie) do
				owner = war:getowner(id)
				warcard = owner.id_card[id]
				cardcls = getclassbycardsid(warcard.sid)
				eventresult = cardcls.__ondie(warcard,self)
				if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
					ret = true
				end
				ignoreevent = EVENTRESULT_FIELD2(eventresult)
				if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
					break
				end
			end
		end
	end
	warobj:removefromwar(self)
	return ret
end

function cwarcard:__oncheckdie()
	local war = warmgr.getwar(self.warid)
	local warobj = war:getwarobj(self.pid)
	-- 自身效果
	self:oncheckdie()
	-- buff效果
	for _,v in ipairs(self.effect.oncheckdie) do
		id = v.id
		assert(id ~= self.id)
		owner = war:getowner(id)
		warcard = owner.id_card[id]
		cardcls = getclassbycardsid(warcard.sid)
		eventresult = cardcls.__oncheckdie(warcard,self)
		if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
			ret = true
		end
		ignoreevent = EVENTRESULT_FIELD2(eventresult)
		if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
			break
		end
	end
	-- 光环效果
	if ignoreevent ~= IGNORE_ALL_LATER_EVENT then
		local categorys = warobj:getcategorys(self.type,self.sid,false)
		for _,category in ipairs(categorys) do
			for _,id in ipairs(category.oncheckdie) do
				if id == self.id then
					warcard = self
				else
					owner = war:getowner(id)
					warcard = owner.id_card[id]
				end
				cardcls = getclassbycardsid(warcard.sid)
				eventresult = cardcls.__oncheckdie(warcard,self)
				if EVENTRESULT_FIELD1(eventresult) == IGNORE_ACTION then
					ret = true
				end
				ignoreevent = EVENTRESULT_FIELD2(eventresult)
				if ignoreevent == IGNORE_LATER_EVENT or ignoreevent == IGNORE_ALL_LATER_EVENT then
					break
				end
			end
		end
	end
	return ret
end

-- 随从牌(战吼)/法术牌(使用效果） 
function cwarcard:onuse(target)
	local cardcls = getclassbycardsid(self.sid)
	if cardcls.onuse then
		cardcls.onuse(self,target)
	end
end

function cwarcard:onputinwar()
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onputinwar then
			cardcls.onputinwar(self)
		end
	end
end

function cwarcard:onremovefromwar()
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onremovefromwar then
			cardcls.onremovefromwar(self)
		end
	end
end

function cwarcard:onputinhand()
	local cardcls = getclassbycardsid(self.sid)
	if cardcls.onputinhand then
		cardcls.onputinhand(self)
	end
end

function cwarcard:onremovefromhand()
	local cardcls = getclassbycardsid(self.sid)
	if cardcls.onremovefromhand then
		cardcls.onremovefromhand(self)
	end
end

function cwarcard:onequipweapon(hero)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onequipweapon then
			cardcls.onequipweapon(self,hero)
		end
	end
end

function cwarcard:ondelweapon(hero)
	local cardcls = getclassbycardsid(self.sid)
	if cardcls.ondelweapon then
		cardcls.ondelweapon(self,hero)
	end
end

function cwarcard:onbeginround(roundcnt)
	self:setleftatkcnt(self.atkcnt)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onbeginround then
			cardcls.onbeginround(self,roundcnt)
		end
	end
end

local lifecircle_states = {
	freeze = true,
	immune = true,
	assault = true
}

function cwarcard:checklifecircle()
	for state,_ in ipairs(lifecircle_states) do
		local lifecircle = self:getstate(state)
		if lifecircle then
			lifecircle = lifecircle - 1
			if lifecircle <= 0 then
				self:delstate(state)
			else
				self:setstate(state,lifecircle)
			end
		end
	end
	for i = #self.buffs,1,-1 do
		local buff = self.buffs[i]
		if buff.value.lifecircle then
			buff.value.lifecircle = buff.value.lifecircle - 1
			if buff.value.lifecircle <= 0 then
				self:delbuff(buff.srcid,i)
			end
		end
	end
	for i = #self.halos,1,-1 do
		local halo = self.halos[i]
		if halo.value.lifecircle then
			halo.value.lifecircle = halo.value.lifecircle - 1
			if halo.value.lifecircle <= 0 then
				self:delhalo(halo.srcid,i)
			end
		end
	end
end

function cwarcard:onendround(hero)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onendround then
			cardcls.onendround(self,roundcnt)
		end
	end
end

function cwarcard:onattack(target)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onattack then
			cardcls.onattack(self,target)
		end
	end
end

function cwarcard:ondefense(attacker)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.ondefense then
			cardcls.ondefense(self,attacker)
		end
	end
end

function cwarcard:onhurt(hurtvalue,srcid)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onhurt then
			cardcls.onhurt(self,hurtvalue,srcid)
		end
	end
end

function cwarcard:onaddhp(hurtvalue,srcid)
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onaddhp then
			cardcls.onaddhp(self,hurtvalue,srcid)
		end
	end
end

function cwarcard:ondie()
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.ondie then
			cardcls.ondie(self)
		end
	end
end

function cwarcard:oncheckdie()
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.oncheckdie then
			cardcls.oncheckdie(self)
		end
	end
end

function cwarcard:onenrage()
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onenrage then
			cardcls.onenrage(self)
		end
	end
end

function cwarcard:onunenrage()
	if not self:issilence() then
		local cardcls = getclassbycardsid(self.sid)
		if cardcls.onunenrage then
			cardcls.onunenrage(self)
		end
	end
end


function cwarcard:dump()
	local data = {}
	data.id = self.id
	data.sid = self.sid
	data.warid = self.warid
	data.pid = self.pid
	data.inarea = self.inarea
	data.pos = self.pos
	data.state = self.state
	data.halos = self.halos
	data.buffs = self.buffs
	data.buff = self.buff
	data.hp = self.hp
	data.maxhp = self.maxhp
	data.atk = self.atk
	data.magic_hurt = self.magic_hurt
	data.crystalcost = self.crystalcost
	data.hurt = self.hurt
	data.atkcnt = self.atkcnt
	data.leftatkcnt = self.atkcnt
	data.effect = self.effect
	return data
end

