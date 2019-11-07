
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

local ChainHeal = PHD.Spell:NewWithId(1064)
function ChainHeal:Compute()
    local heal, count, effectReduction = string.match(self.description, "Heals the friendly target for (%d[%d.,]*), then jumps to heal the (%d+) most injured nearby allies. Healing is reduced by (%d+)%% with each jump")
    if heal == nil or count == nil or effectReduction == nil then
        return
    end

    heal = PHD:StrToNumber(heal)
    count = PHD:StrToNumber(count)
    effectReduction = PHD:StrToNumber(effectReduction)

    local aoe = heal
    local postJumpHeal = heal
    local effectPreservation = 1 - (effectReduction / 100)

    for jump = 1, count, 1 do
        postJumpHeal = postJumpHeal * effectPreservation
        aoe = aoe + postJumpHeal
    end

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(aoe),
        aoeHpm = self:GetValPerMana(aoe)
    }
end

local HealingWave = PHD.Spell:NewWithId(77472)
function HealingWave:Compute()
    local heal = string.match(self.description, "restores (%d[%d.,]*) of a friendly")
    if heal == nil then
        return
    end

    return { heal = PHD:StrToNumber(heal) }
end

local HealingRain = PHD.Spell:NewWithId(73920)
function HealingRain:Compute()
    local healOverTime, targets, durationSec = string.match(self.description, "restoring (%d[%d.,]*) health to up to (%d+) allies over (%d+) sec")
    if healOverTime == nil or targets == nil or durationSec == nil then
        return
    end

    local hot = PHD:StrToNumber(healOverTime)
    local durationMs = PHD:StrToNumber(durationSec) * 1000

    return {
        hot = hot,
        hps = self:GetValPerSecond(hot, durationMs),
        hpsc = PHD.IGNORE_STAT,
        aoeHps = self:GetValPerSecond(hot * PHD.AOE_AVERAGE_TARGETS, durationMs),
        aoeHpm = self:GetValPerMana(hot * PHD.AOE_AVERAGE_TARGETS)
    }
end

local HealingTideTotem = PHD.Spell:NewWithId(108280)
function HealingTideTotem:Compute()
    local durationSec, tickIntervalSec, range, healTick = string.match(self.description, "at your feet for (%d[%d.,]*) sec, which pulses every (%d[%d.,]*) sec, healing all party or raid members within (%d+) yards for (%d[%d.,]*)")
    if durationSec == nil or tickIntervalSec == nil or healTick == nil then
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
        hpsc = self:GetValPerSecondAccountForCooldown(heal, durationMs),
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS, durationMs),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS, durationMs),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end
