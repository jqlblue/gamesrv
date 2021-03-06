--<<card 导表开始>>
local super = require "script.card.init"

ccard163016 = class("ccard163016",super,{
    sid = 163016,
    race = 6,
    name = "法力怨魂",
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
    atk = 2,
    maxhp = 2,
    crystalcost = 2,
    targettype = 0,
    halo = {addcrystalcost=1},
    desc = "召唤所有随从的法力值消耗增加（1）点。",
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

function ccard163016:init(conf)
    super.init(self,conf)
--<<card 导表结束>>

end --导表生成

function ccard163016:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data)
    -- todo: load data
end

function ccard163016:save()
    local data = super.save(self)
    -- todo: save data
    return data
end

function ccard163016:onputinwar(pos,reason)
	local owner = self:getowner()
	for i,id in ipairs(owner.handcards) do
		local handcard = owner:gettarget(id)
		if is_footman(handcard.type) then
			self:addhaloto(handcard)
		end
	end
	for i,id in ipairs(owner.enemy.handcards) do
		local handcard = owner:gettarget(id)
		if is_footman(handcard.type) then
			self:addhaloto(handcard)
		end
	end
end

function ccard163016:after_putinhand(warcard)
	if self.inarea ~= "war" then
		return
	end
	if not is_footman(warcard.type) then
		return
	end
	self:addhaloto(warcard)
end

return ccard163016
