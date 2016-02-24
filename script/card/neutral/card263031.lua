--<<card 导表开始>>
local super = require "script.card.neutral.card163031"

ccard263031 = class("ccard263031",super,{
    sid = 263031,
    race = 6,
    name = "上古看守者",
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
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 4,
    hp = 5,
    crystalcost = 2,
    targettype = 0,
    desc = "无法攻击。",
})

function ccard263031:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard263031:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard263031:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard263031