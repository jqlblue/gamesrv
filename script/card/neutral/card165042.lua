--<<card 导表开始>>
local super = require "script.card.init"

ccard165042 = class("ccard165042",super,{
    sid = 165042,
    race = 6,
    name = "蓝腮战士",
    type = 203,
    magic_immune = 0,
    assault = 1,
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
    atk = 2,
    hp = 1,
    crystalcost = 2,
    targettype = 0,
    desc = "冲锋",
})

function ccard165042:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard165042:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard165042:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard165042