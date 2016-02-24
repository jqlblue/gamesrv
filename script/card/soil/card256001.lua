--<<card 导表开始>>
local super = require "script.card.soil.card156001"

ccard256001 = class("ccard256001",super,{
    sid = 256001,
    race = 5,
    name = "猎豹",
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
    max_amount = 0,
    composechip = 0,
    decomposechip = 0,
    atk = 3,
    hp = 2,
    crystalcost = 2,
    targettype = 0,
    desc = "None",
})

function ccard256001:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard256001:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard256001:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard256001