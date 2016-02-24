--<<card 导表开始>>
local super = require "script.card.neutral.card164015"

ccard264015 = class("ccard264015",super,{
    sid = 264015,
    race = 6,
    name = "年迈的酒仙",
    type = 201,
    magic_immune = 0,
    assault = 0,
    sneer = 0,
    atkcnt = 1,
    shield = 0,
    warcry = 1,
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
    atk = 5,
    hp = 4,
    crystalcost = 4,
    targettype = 12,
    desc = "战吼：使一个友方随从从战场上移回你的手牌。",
})

function ccard264015:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard264015:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard264015:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard264015