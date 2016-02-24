--<<card 导表开始>>
local super = require "script.card.init"

ccard125006 = class("ccard125006",super,{
    sid = 125006,
    race = 2,
    name = "真银之剑",
    type = 301,
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
    atk = 4,
    hp = 2,
    crystalcost = 4,
    targettype = 0,
    desc = "每当你的英雄进攻时,为其恢复2点生命值。",
})

function ccard125006:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard125006:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard125006:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard125006