--<<card 导表开始>>
local super = require "script.card.init"

ccard142001 = class("ccard142001",super,{
    sid = 142001,
    race = 4,
    name = "毒蛇陷阱",
    type = 102,
    magic_immune = 0,
    assault = 0,
    sneer = 0,
    atkcnt = 0,
    shield = 0,
    warcry = 0,
    dieeffect = 0,
    sneak = 0,
    magic_hurt_adden = 0,
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 0,
    maxhp = 0,
    crystalcost = 2,
    targettype = 0,
    halo = nil,
    desc = "奥秘：当你的1个随从遭到攻击时,召唤3条1/1毒蛇。",
    effect = {
        onuse = nil,
        ondie = nil,
        onhurt = nil,
        onrecoverhp = nil,
        onbeginround = nil,
        onendround = nil,
        ondelsecret = nil,
        onputinwar = nil,
        onremovefromwar = nil,
        onaddweapon = nil,
        onputinhand = nil,
        before_die = nil,
        after_die = nil,
        before_hurt = nil,
        after_hurt = nil,
        before_recoverhp = nil,
        after_recoverhp = nil,
        before_beginround = nil,
        after_beginround = nil,
        before_endround = nil,
        after_endround = nil,
        before_attack = {addfootman={sid=146006,num=3}},
        after_attack = nil,
        before_playcard = nil,
        after_playcard = nil,
        before_putinwar = nil,
        after_putinwar = nil,
        before_removefromwar = nil,
        after_removefromwar = nil,
        before_addsecret = nil,
        after_addsecret = nil,
        before_delsecret = nil,
        after_delsecret = nil,
        before_addweapon = nil,
        after_addweapon = nil,
        before_delweapon = nil,
        after_delweapon = nil,
        before_putinhand = nil,
        after_putinhand = nil,
        before_removefromhand = nil,
        after_removefromhand = nil,
    },
})

function ccard142001:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard142001:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard142001:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard142001:before_attack(attacker,defenser)
	if self.inarea ~= "war" then
		return
	end
	local owner = self:getowner()
	if owner:isenemy(defenser) then
		return
	end
	if defenser.id == owner.hero.id then
		return
	end
	assert(defenser.inarea == "war")
	assert(is_footman(defenser.type))
	owner:delsecret(self.id,"trigger")
	local sid = is_goldcard(self.sid) and 24
	local num = ccard142001.effect.before_attack.addfootman.num
	num = math.min(num,owner:getfreespace("warcard"))
	local sid = ccard142001.effect.before_attack.addfootman.sid
	sid = togoldsidif(sid,is_goldcard(self.sid))
	for i=1,num do
		local warcard = owner:newwarcard(sid)
		owner:putinwar(warcard)
	end
	return
end

return ccard142001
