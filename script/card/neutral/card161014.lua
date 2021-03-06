--<<card 导表开始>>
local super = require "script.card.init"

ccard161014 = class("ccard161014",super,{
    sid = 161014,
    race = 6,
    name = "火车王里诺艾",
    type = 201,
    magic_immune = 0,
    assault = 1,
    sneer = 0,
    atkcnt = 1,
    shield = 0,
    warcry = 0,
    dieeffect = 0,
    sneak = 0,
    magic_hurt_adden = 0,
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 1,
    composechip = 100,
    decomposechip = 10,
    atk = 6,
    maxhp = 2,
    crystalcost = 5,
    targettype = 0,
    halo = nil,
    desc = "冲锋,战吼：为你的对手召唤2只1/1的雏龙。",
    effect = {
        onuse = {addfootman={sid=166019,num=2}},
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
        before_attack = nil,
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

function ccard161014:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard161014:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard161014:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard161014:onuse(pos,targetid,choice)
	local owner = self:getowner()
	local freespace = owner.enemy:getfreespace("warcard")
	local sid = ccard161014.effect.onuse.addfootman.sid
	local num = ccard161014.effect.onuse.addfootman.num
	sid = togoldsidif(sid,is_goldcard(self.sid))
	num = math.min(num,freespace)
	for i=1,num do
		local warcard = owner.enemy:newwarcard(sid)
		owner.enemy:putinwar(warcard)
	end
end

return ccard161014
