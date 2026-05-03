cooldown = {}
cooldown.GetSpellCD = function(____, spellId)
    local start, duration, enabled = GetSpellCooldown(spellId)
    if start == nil or start == 0 then
        return {ready = true, remaining = 0, duration = 0}
    end
    if duration ~= nil and duration <= 1.5 then
        return {ready = true, remaining = 0, duration = 0}
    end
    local now = GetTime()
    local remaining = 0
    if duration ~= nil and duration > 0 and start > 0 then
        remaining = math.max(0, start + duration - now)
    end
    return {ready = remaining <= 0, remaining = remaining, duration = duration or 0}
end
cooldown.PlayerKnowsSpell = function(____, spellId)
    if IsSpellKnown ~= nil then
        return IsSpellKnown(spellId, false)
    end
    return false
end
RaidCD.cooldown = cooldown
