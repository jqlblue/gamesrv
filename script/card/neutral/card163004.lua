--<<card 导表开始>>
local super = require "script.card.init"

ccard163004 = class("ccard163004",super,{
    sid = 163004,
    race = 6,
    name = "狂野炎术师",
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
    cure_to_hurt = 0,
    recoverhp_multi = 1,
    magic_hurt_multi = 1,
    max_amount = 2,
    composechip = 100,
    decomposechip = 10,
    atk = 3,
    maxhp = 2,
    crystalcost = 2,
    targettype = 0,
    halo = nil,
    desc = "每当你施放一个法术时,对所有随从造成1点伤害。",
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
        after_playcard = {costhp=1},
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

function ccard163004:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard163004:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard163004:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard163004:after_playcard(warcard,pos,targetid,choice)
	if self.inarea ~= "war" then
		return
	end
	if self.id ~= warcard.id then
		return
	end
	if not is_magiccard(warcard.type) then
		return
	end
	local owner = self:getowner()
	if owner:isenemy(warcard) then
		return
	end
	local costhp = ccard163004.effect.after_playcard.costhp
	local ids = deepcopy(owner.warcards)
	local ids2 = deepcopy(owner.enemy.warcards)
	for i,id in ipairs(ids) do
		local footman = owner:gettarget(id)
		footman:addhp(-costhp,self.id)
	end
	for i,id in ipairs(ids2) do
		local footman = owner:gettarget(id)
		footman:addhp(-costhp,self.id)
	end
end

return ccard163004
