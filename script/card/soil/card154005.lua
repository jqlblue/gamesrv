--<<card 导表开始>>
local super = require "script.card.init"

ccard154005 = class("ccard154005",super,{
    sid = 154005,
    race = 5,
    name = "愤怒",
    type = 101,
    magic_immune = 0,
    assault = 0,
    sneer = 0,
    atkcnt = 0,
    shield = 0,
    warcry = 0,
    dieeffect = 0,
    sneak = 0,
    magic_hurt_adden = 0,
    magic_hurt = 3,
    recoverhp = 0,
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 0,
    hp = 0,
    crystalcost = 2,
    targettype = 32,
    desc = "抉择：对一个随从造成3点伤害；或者造成1点伤害并抽一张牌。",
})

function ccard154005:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard154005:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard154005:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard154005