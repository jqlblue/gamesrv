--<<card 导表开始>>
local super = require "script.card.init"

ccard163006 = class("ccard163006",super,{
    sid = 163006,
    race = 6,
    name = "暮光幼龙",
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
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 4,
    maxhp = 1,
    crystalcost = 4,
    targettype = 0,
    halo = nil,
    desc = "战吼：你的每张手牌都会令暮光幼龙获得一次+1（生命值）效果",
    effect = {
        onuse = {addbuff={addmaxhp=1,addhp=1}},
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

function ccard163006:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard163006:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard163006:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard163006:onuse(pos,targetid,choice)
	local owner = self:getowner()
	local num = #owner.handcards
	if num == 0 then
		return
	end
	local buff = self:newbuff(ccard163006.effect.onuse.addbuff)
	for k,v in pairs(buff) do
		if k ~= "lifecircle" then
			buff[k] = v * num
		end
	end
	self:addbuff(buff)
end

return ccard163006
