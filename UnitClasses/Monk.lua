
local SoothingMist = PHD.Spell:NewWithId(115175)
function SoothingMist:Compute()
    -- %d[%d.,]* is for handling , as the thousand separator
    local heal, channelTimeSec = string.match(self.description, "Heals the target for (%d[%d.,]*) over (%d[%d.,]*) sec")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)
    local channelTimeMs = PHD:StrToNumber(channelTimeSec) * 1000

    return {
        heal = heal,
        hps = self:GetValPerSecond(heal, channelTimeMs),
        hpsc = self:GetValPerSecondAccountForCooldown(heal, channelTimeMs),
        hpm = self:GetValPerMana(heal, channelTimeMs)
    }
end

local EnvelopingMist = PHD.Spell:NewWithId(124682)
function EnvelopingMist:Compute()
    local healOverTime, durationSec = string.match(self.description, "healing for (%d[%d.,]*) over (%d[%d.,]*) sec")
    if healOverTime == nil then
        return
    end

    local hot = PHD:StrToNumber(healOverTime)
    local durationMs = PHD:StrToNumber(durationSec) * 1000

    return {
        heal = hot,
        hot = hot,
        hps = self:GetValPerSecond(hot, durationMs),
        hpsc = PHD.IGNORE_STAT
    }
end

local RenewingMist = PHD.Spell:NewWithId(115151)
function RenewingMist:Compute()
    local healOverTime, durationSec = string.match(self.description, "restoring (%d[%d.,]*) health over (%d[%d.,]*) sec")
    if healOverTime == nil then
        return
    end

    local hot = PHD:StrToNumber(healOverTime)
    local durationMs = PHD:StrToNumber(durationSec) * 1000

    return {
        heal = hot,
        hot = hot,
        hps = self:GetValPerSecond(hot, durationMs),
        hpsc = PHD.IGNORE_STAT
    }
end

local LifeCocoon = PHD.Spell:NewWithId(116849)
function LifeCocoon:Compute()
    local absorb = string.match(self.description, "absorbing (%d[%d.,]*) damage")
    if absorb == nil then
        return
    end

    absorb = PHD:StrToNumber(absorb)

    return {
        absorb = absorb,
        hps = PHD.IGNORE_STAT, -- not affected by gcd
        hpsc = self:GetValPerSecondAccountForCooldown(absorb),
        hpm = self:GetValPerMana(absorb)
    }
end

local EssenceFont = PHD.Spell:NewWithId(191837)
function EssenceFont:Compute()
    local count, range, tickIntervalSec, channelTimeSec, tickHeal, tickHot = string.match(self.description, "healing bolts at up to (%d+) allies within (%d+) yds, every (%d[%d.,]*) sec for (%d[%d.,]*) sec. Each bolt heals a target for (%d[%d.,]*), plus an additional (%d[%d.,]*) over (%d[%d.,]*) sec")
    if tickIntervalSec == nil or channelTimeSec == nil or tickHeal == nil or tickHot == nil then
        return
    end

    local direct = PHD:StrToNumber(tickHeal)
    local hot = PHD:StrToNumber(tickHot)
    local tickIntervalMs = PHD:StrToNumber(tickIntervalSec) * 1000
    local channelTimeMs = PHD:StrToNumber(channelTimeSec) * 1000

    local tickCount = PHD:MathRound(channelTimeMs / tickIntervalMs)
    local heal = tickCount * direct + hot

    -- for now let's not care about that the hot will tick extra nor that there are many targets etc
    return {
        heal = heal,
        hps = self:GetValPerSecond(heal, channelTimeMs),
        hpsc = self:GetValPerSecondAccountForCooldown(heal, channelTimeMs),
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS, channelTimeMs),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS, channelTimeMs),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local ChiBurst = PHD.Spell:NewWithId(123986)
function ChiBurst:Compute()
    local dmg, heal = string.match(self.description, "dealing (%d[%d.,]*) Nature damage to all enemies, and (%d[%d.,]*) healing")
    if dmg == nil or heal == nil then
        return
    end

    dmg = PHD:StrToNumber(dmg)
    heal = PHD:StrToNumber(heal)

    return {
        dmg = dmg,
        aoeDps = self:GetValPerSecond(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpsc = self:GetValPerSecondAccountForCooldown(dmg * PHD.AOE_AVERAGE_TARGETS),
        aoeDpm = self:GetValPerMana(dmg * PHD.AOE_AVERAGE_TARGETS),
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local Revival = PHD.Spell:NewWithId(115310)
function Revival:Compute()
    local range, heal = string.match(self.description, "within (%d+) yards for (%d[%d.,]*)")
    if heal == nil then
        return
    end

    heal = PHD:StrToNumber(heal)

    return {
        heal = heal,
        aoeHps = self:GetValPerSecond(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpsc = self:GetValPerSecondAccountForCooldown(heal * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(heal * PHD.AOE_AVERAGE_TARGETS)
    }
end

local Vivify = PHD.Spell:NewWithId(116670)
function Vivify:Compute()
    local direct, mistAoe = string.match(self.description, "healing the target for (%d[%d.,]*) and all allies with your Renewing Mist active for (%d[%d.,]*)")
    if direct == nil or mistAoe == nil then
        return
    end

    direct = PHD:StrToNumber(direct)
    mistAoe = PHD:StrToNumber(mistAoe)

    return {
        heal = direct + mistAoe,
        aoeHps = self:GetValPerSecond(direct + mistAoe * PHD.AOE_AVERAGE_TARGETS),
        aoeHpm = self:GetValPerMana(direct + mistAoe * PHD.AOE_AVERAGE_TARGETS)
    }
end
