--<<card 导表开始>>
local super = require "script.card.golden.card116001"

ccard216001 = class("ccard216001",super,{
    sid = 216001,
    race = 1,
    name = "镜像",
    type = 201,
    magic_immune = 0,
    assault = 0,
    sneer = 1,
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
    composechip = 0,
    decomposechip = 0,
    atk = 0,
    hp = 2,
    crystalcost = 0,
    targettype = 23,
    desc = "None",
})

function ccard216001:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard216001:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard216001:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard216001