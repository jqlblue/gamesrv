--<<card 导表开始>>
local super = require "script.card.init"

ccard161006 = class("ccard161006",super,{
    sid = 161006,
    race = 6,
    name = "精英牛头人酋长",
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
    max_amount = 1,
    composechip = 100,
    decomposechip = 10,
    atk = 5,
    hp = 5,
    crystalcost = 5,
    targettype = 0,
    desc = "战吼：让两位玩家都具有摇滚的能力！（双方各获得一张强力和弦牌）",
})

function ccard161006:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard161006:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard161006:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard161006