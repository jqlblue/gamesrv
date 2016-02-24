--<<card 导表开始>>
local super = require "script.card.init"

ccard163020 = class("ccard163020",super,{
    sid = 163020,
    race = 6,
    name = "负伤剑圣",
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
    atk = 4,
    hp = 7,
    crystalcost = 3,
    targettype = 0,
    desc = "战吼：对自身造成4点伤害。",
})

function ccard163020:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard163020:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard163020:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard163020