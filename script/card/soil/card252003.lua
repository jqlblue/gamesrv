--<<card 导表开始>>
local super = require "script.card.soil.card152003"

ccard252003 = class("ccard252003",super,{
    sid = 252003,
    race = 5,
    name = "知识古树",
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
    recoverhp = 5,
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 5,
    hp = 5,
    crystalcost = 7,
    targettype = 0,
    desc = "抉择：抽2张牌；或恢复5点生命值。",
})

function ccard252003:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard252003:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard252003:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

return ccard252003