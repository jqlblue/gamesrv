--<<card 导表开始>>
local super = require "script.card.init"

ccard113002 = class("ccard113002",super,{
    sid = 113002,
    race = 1,
    name = "暴风雪",
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
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 0,
    maxhp = 0,
    crystalcost = 6,
    targettype = 0,
    halo = nil,
    desc = "对所有敌方随从造成2点伤害,并使其冻结",
    effect = {
        onuse = {magic_hurt=2,addbuff={freeze=1,lifecircle=2}},
        ondie = nil,
        onhurt = nil,
        onrecoverhp = nil,
        onbeginround = nil,
        onendround = nil,
        ondelsecret = nil,
        onputinwar = nil,
        onremovefromwar = nil,
        onaddweapon = nil,
        onputinhand = nil,
        before_die = nil,
        after_die = nil,
        before_hurt = nil,
        after_hurt = nil,
        before_recoverhp = nil,
        after_recoverhp = nil,
        before_beginround = nil,
        after_beginround = nil,
        before_endround = nil,
        after_endround = nil,
        before_attack = nil,
        after_attack = nil,
        before_playcard = nil,
        after_playcard = nil,
        before_putinwar = nil,
        after_putinwar = nil,
        before_removefromwar = nil,
        after_removefromwar = nil,
        before_addsecret = nil,
        after_addsecret = nil,
        before_delsecret = nil,
        after_delsecret = nil,
        before_addweapon = nil,
        after_addweapon = nil,
        before_delweapon = nil,
        after_delweapon = nil,
        before_putinhand = nil,
        after_putinhand = nil,
        before_removefromhand = nil,
        after_removefromhand = nil,
    },
})

function ccard113002:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard113002:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard113002:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard113002:onuse(pos,targetid,choice)
	local owner = self:getowner()
	local ids = deepcopy(owner.enemy.warcards)
	local magic_hurt = ccard113002.effect.onuse.magic_hurt
	magic_hurt = self:get_magic_hurt(magic_hurt)
	for i,id in ipairs(ids) do
		local footman = owner:gettarget(id)
		footman:addhp(-magic_hurt,self.id)
		local buff = self:newbuff(ccard113002.effect.onuse.addbuff)
		footman:addbuff(buff)
	end
end

return ccard113002
