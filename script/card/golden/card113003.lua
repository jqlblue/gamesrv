--<<card 导表开始>>
local super = require "script.card.init"

ccard113003 = class("ccard113003",super,{
    sid = 113003,
    race = 1,
    name = "法术反制",
    type = 102,
    magic_immune = 0,
    assault = 0,
    sneer = 0,
    atkcnt = 0,
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
    atk = 0,
    hp = 0,
    crystalcost = 3,
    targettype = 0,
    halo = nil,
    desc = "奥秘：当你的对手施放法术时,反制该法术",
    effect = {
        onuse = nil,
        ondie = nil,
        onhurt = nil,
        onrecorverhp = nil,
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
        before_atttack = nil,
        after_attack = nil,
        before_playcard = nil,
        after_playcard = nil,
        before_putinwar = nil,
        after_putinwar = nil,
        before_removefromwar = nil,
        after_removefromwar = nil,
        before_addsecret = nil,
        after_addsecret = nil,
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

function ccard113003:init(pid)
    super.init(self,pid)
    self.data = {}
--<<card 导表结束>>

end --导表生成

function ccard113003:load(data)
    if not data or not next(data) then
        return
    end
    super.load(self,data.data)
    -- todo: load data
end

function ccard113003:save()
    local data = {}
    data.data = super.save(self)
    -- todo: save data
    return data
end

function ccard113003:before_playcard(warcard,pos,targetid,choice)
	if self.inarea ~= "war" then
		return
	end
	if not is_magiccard(warcard.type) then
		return
	end
	local owner = self:getowner()
	if not owner:isenemy(warcard.id) then
		return
	end
	return true,true
end

return ccard113003
