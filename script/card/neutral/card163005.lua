--<<card 导表开始>>
local super = require "script.card.init"

ccard163005 = class("ccard163005",super,{
    sid = 163005,
    race = 6,
    name = "紫罗兰教师",
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
    atk = 3,
    hp = 5,
    crystalcost = 4,
    targettype = 0,
    desc = "每当你施放一个法术时,召唤一个1/1的紫罗兰学徒。",
})

function ccard163005:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard163005:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard163005:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard163005