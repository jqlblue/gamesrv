--<<card 导表开始>>
local super = require "script.card.init"

ccard162009 = class("ccard162009",super,{
    sid = 162009,
    race = 6,
    name = "船长的鹦鹉",
    type = 202,
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
    atk = 1,
    maxhp = 2,
    crystalcost = 2,
    targettype = 0,
    halo = nil,
    desc = "战吼：随机从你的牌库中将一张海盗牌置入你的手牌。",
    effect = {
        onuse = nil,
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

function ccard162009:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard162009:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard162009:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard162009:onuse(pos,targetid,choice)
	local owner = self:getowner()
	local hitids = {}
	for i,id in ipairs(owner.leftcards) do
		local warcard = owner:gettarget(id)
		if is_footman(warcard.type) and warcard.type == FOOTMAN.HAIDAO then
			table.insert(hitids,id)
		end
	end
	if not next(hitids) then
		return
	end
	local id = randlist(hitids)
	owner:pickcard_and_putinhand(id)
end

return ccard162009
