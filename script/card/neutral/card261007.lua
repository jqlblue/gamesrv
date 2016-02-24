--<<card 导表开始>>
local super = require "script.card.neutral.card161007"

ccard261007 = class("ccard261007",super,{
    sid = 261007,
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
    magic_hurt = 0,
    recoverhp = 0,
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 1,
    composechip = 100,
    decomposechip = 10,
    atk = 8,
    hp = 8,
    crystalcost = 8,
    targettype = 0,
    desc = "无法攻击,在你的回合结束时,对一个随机敌人造成8点伤害。",
})

function ccard261007:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard261007:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard261007:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard261007