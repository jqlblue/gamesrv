--<<card 导表开始>>
local super = require "script.card.init"

ccard164024 = class("ccard164024",super,{
    sid = 164024,
    race = 6,
    name = "麻风侏儒",
    type = 205,
    magic_immune = 0,
    assault = 0,
    sneer = 0,
    atkcnt = 1,
    shield = 0,
    warcry = 0,
    dieeffect = 1,
    sneak = 0,
    magic_hurt_adden = 0,
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 2,
    maxhp = 1,
    crystalcost = 1,
    targettype = 0,
    halo = nil,
    desc = "亡语：对敌方英雄造成2点伤害。",
    effect = {
        onuse = nil,
        ondie = {costhp=2},
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

function ccard164024:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard164024:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard164024:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard164024:ondie()
	local owner = self:getowner()
	local costhp = ccard164024.effect.ondie.costhp
	owner.enemy.hero:addhp(-costhp,self.id)
end

return ccard164024
