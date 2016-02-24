--<<card 导表开始>>
local super = require "script.card.neutral.card162005"

ccard262005 = class("ccard262005",super,{
    sid = 262005,
    race = 6,
    name = "熔合巨人",
    type = 201,
    magic_immune = 0,
    assault = 0,
    sneer = 0,
    atkcnt = 1,
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
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 8,
    hp = 8,
    crystalcost = 20,
    targettype = 0,
    desc = "你的英雄每受到1点伤害,这张牌的法力值消耗便减少（1）点。",
})

function ccard262005:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard262005:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard262005:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard262005