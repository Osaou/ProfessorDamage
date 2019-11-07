
local HealingSurge = PHD.Spell:NewWithId(8004)
function HealingSurge:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal = string.match(self.description, "A quick surge of healing energy that restores (%d[%d.,]*)")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local Riptide = PHD.Spell:NewWithId(61295)
function Riptide:Compute()
    local initialHeal, healOverTime, duration = string.match(self.description, "Restorative waters wash over a friendly target, healing them for (%d[%d.,]*) and an additional (%d[%d.,]*) over (%d[%d.,]*) sec")
    if initialHeal == nil or healOverTime == nil then
        return
    end

    local direct = PHD:StrToNumber(initialHeal)
    local hot = PHD:StrToNumber(healOverTime)
    return {
        heal = direct + hot,
        hot = hot,
        hps = self:GetValPerSecond(direct),
        hpsc = self:GetValPerSecondAccountForCooldown(direct)
    }
end

local HealingStreamTotem = PHD.Spell:NewWithId(5394)
function HealingStreamTotem:Compute()
    local durationSec, range, healTick, tickIntervalSec = string.match(self.description, "at your feet for (%d[%d.,]*) sec that heals an injured party or raid member within (%d+) yards for (%d[%d.,]*) every (%d[%d.,]*) sec")
    if durationSec == nil or healTick == nil or tickIntervalSec == nil then
        return
    end

    healTick = PHD:StrToNumber(healTick)
    tickIntervalSec = PHD:StrToNumber(tickIntervalSec)
    durationSec = PHD:StrToNumber(durationSec)

    local heal = PHD:MathRound(durationSec / tickIntervalSec) * healTick
    local durationMs = durationSec * 1000

    return {
        heal = heal,
        hps = self:GetValPerSecond(heal, durationMs),
        hpsc = self:GetValPerSecondAccountForCooldown(heal, durationMs)
    }
end
