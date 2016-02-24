--<<card 导表开始>>
local super = require "script.card.init"

ccard124006 = class("ccard124006",super,{
    sid = 124006,
    race = 2,
    name = "银色保卫者",
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
    atk = 2,
    hp = 2,
    crystalcost = 1,
    targettype = 12,
    desc = "战吼：使一个友方随从获得圣盾。",
})

function ccard124006:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard124006:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard124006:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard124006