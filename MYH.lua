

_addon.name = 'MYH'
_addon.author = 'Cliff'
_addon.version = '1.0'
_addon.date = '5.11.2024'
_addon.commands = {'myh'}

require('logger')
require('coroutine')

res = require('resources')

local show = false

local texts = require('texts')
local settings ={
	defaultOn = true,
	str = "[ - ]",
	text = {
		pos = {
			x = 555,
			y = 480
		},
		flags={draggable=true},
	},
}
function setup_text(text)
    text:bg_alpha(255)
    text:bg_visible(true)
    text:font('ＭＳ ゴシック')
    text:size(24)
    text:color(255,255,255,255)
    text:stroke_alpha(200)
    text:stroke_color(20,20,20)
    text:stroke_width(2)
	text:show()
end
text = texts.new("[ ${ws} ]", settings.text, settings)
setup_text(text)

trusts = S(res.spells:type('Trust'):map(string.gsub-{' ', ''} .. table.get-{'name'}))
--Check if the actor is actually an npc rather than a player
function isMob(id)
    if not trusts:contains(windower.ffxi.get_mob_by_id(id)['name']) then
        return windower.ffxi.get_mob_by_id(id)['is_npc']
    end
    return false
end

Dangers = {
    -- [392] = {name='test', back=true},
    [4096] = {name='痛覚同化', back=true},
    [4188] = {name='ダークソーン', back=false},
    [4192] = {name='フェイタルアリュア', back=false},
}

local function myhlog(str)
    windower.add_to_chat(258, str)
end

windower.register_event('action', function(act)
    local curact = T(act)
    local actor = T{}
    actor.id = curact.actor_id
    mob = windower.ffxi.get_mob_by_target()
    if mob and actor.id ~= mob.id then
        return
    end
    if windower.ffxi.get_mob_by_id(actor.id) then
        actor.name = windower.ffxi.get_mob_by_id(actor.id).name
    else
        return
    end
    local extparam = curact.param
    local targets = curact.targets
    local party = T(windower.ffxi.get_party())
    local typ = ''
    local danger = false
    local player = T(windower.ffxi.get_player())
    -- myhlog('a'..tostring(curact.category))
    
    if isMob(actor.id) then
        if curact.category == 8 then typ = 'spell'
        else typ = 'ws' end
        if S{7}:contains(curact.category) and extparam ~= 28787 then
            local inact = targets[1].actions[1]
            text.ws = res.monster_abilities[inact.param].name
            if show then
                myhlog(windower.to_shift_jis(actor.name.." 使用: "..res.monster_abilities[inact.param].name.." !!"))
            end
            if inact.message ~= 0  and Dangers[inact.param] then
                myhlog(actor.name..'>>'..typ..': '..res.monster_abilities[inact.param].english..'('..tostring(inact.param)..')')
                windower.ffxi.turn(mob.facing)
            end
        elseif S{11}:contains(curact.category) then
            text.ws = "-"
            if Dangers[curact.param] then
                myhlog(actor.name..'<<'..typ..': '..res.monster_abilities[curact.param].english..'('..tostring(curact.param)..')')
                if Dangers[curact.param] and Dangers[curact.param].back then
                    coroutine.sleep(1)
                    windower.ffxi.turn(mob.facing+3.6)
                end
            end
        end
    end
end)

windower.register_event('load', function()
end)

windower.register_event('addon command', function (command, ...)
	command = command and command:lower()
	local args = T{...}

	if command == 'show' then
        show = not show
        log("Show log: "..tostring(show))
    end
end)