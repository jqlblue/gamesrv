--<<card 导表开始>>
local super = require "script.card.init"

ccard161007 = class("ccard161007",super,{
    sid = 161007,
    race = 6,
    name = "炎魔之王拉格纳罗斯",
    type = 201,
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
    max_amount = 1,
    composechip = 100,
    decomposechip = 10,
    atk = 8,
    maxhp = 8,
    crystalcost = 8,
    targettype = 0,
    halo = nil,
    desc = "无法攻击,在你的回合结束时,对一个随机敌人造成8点伤害。",
    effect = {
        onuse = nil,
        ondie = nil,
        onhurt = nil,
        onrecoverhp = nil,
        onbeginround = nil,
        onendround = {costhp=8},
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

function ccard161007:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard161007:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard161007:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard161007:onputinwar(pos,reason)
	self:set({cannotattack=true})
end

function ccard161007:onendhuodong()
	if self.inarea ~= "war" then
		return
	end
	local owner = self:getowner()
	local costhp = ccard161007.effect.onendhuodong.costhp
	local ids = deepcopy(owner.enemy.warcards)
	table.insert(ids,owner.enemy.id)
	local id = randlist(ids)
	local target = owner:gettarget(id)
	target:addhp(-costhp,self.id)

end

return ccard161007
