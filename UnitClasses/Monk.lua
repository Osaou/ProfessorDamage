
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
