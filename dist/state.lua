(function()
    local state = {}
    RaidCD.state = state
    state.raidData = {}
    state.UpdateSelf = function()
        local me = UnitName("player") or "Unknown"
        if state.raidData[me] == nil then
            state.raidData[me] = {}
        end
        local trackedSpells = RaidCD.config.db.trackedSpells
        local knownSpells = {}
        local cdMap = {}
        for className in pairs(trackedSpells) do
            local classSpells = trackedSpells[className]
            for ____, spellId in ipairs(classSpells) do
                if RaidCD.cooldown:PlayerKnowsSpell(spellId) then
                    local cd = RaidCD.cooldown:GetSpellCD(spellId)
                    cdMap[spellId] = cd
                    knownSpells[spellId] = true
                end
            end
        end
        local nameGroups = {}
        for spellId in pairs(cdMap) do
            local name = GetSpellInfo(spellId)
            if name then
                nameGroups[name] = nameGroups[name] or {}
                nameGroups[name][#nameGroups[name] + 1] = spellId
            end
        end
        for name, ids in pairs(nameGroups) do
            if #ids > 1 then
                local maxRem = 0
                local maxDur = 0
                for _, id in ipairs(ids) do
                    if cdMap[id].remaining > maxRem then
                        maxRem = cdMap[id].remaining
                        maxDur = cdMap[id].duration
                    end
                end
                if maxRem > 0 then
                    for _, id in ipairs(ids) do
                        cdMap[id].remaining = maxRem
                        cdMap[id].duration = maxDur
                        cdMap[id].ready = false
                    end
                end
            end
        end
        for spellId, cd in pairs(cdMap) do
            state.raidData[me][spellId] = {
                ready = cd.ready,
                remaining = cd.remaining,
                duration = cd.duration,
                lastUpdate = GetTime(),
                isSelf = true
            }
        end
        for spellId in pairs(state.raidData[me]) do
            if not knownSpells[spellId] then
                state.raidData[me][spellId] = nil
            end
        end
    end
    state.Cleanup = function()
        local now = GetTime()
        local threshold = RaidCD.STALE_THRESHOLD
        for playerName in pairs(state.raidData) do
            local spells = state.raidData[playerName]
            local empty = true
            local toDelete = {}
            for spellId in pairs(spells) do
                local entry = spells[spellId]
                if now - (entry.lastUpdate or 0) > threshold then
                    toDelete[#toDelete + 1] = spellId
                else
                    empty = false
                end
            end
            for i = 1, #toDelete do
                spells[toDelete[i]] = nil
            end
            if empty then
                state.raidData[playerName] = nil
            end
        end
    end
    state.HandleMessage = function(____, sender, message)
        if RaidCD.roster.demoActive then
            return 0
        end
        local playerName = string.match(sender, "^([^%-]+)") or sender
        if playerName == nil or playerName == "" then
            return 0
        end
        local me = UnitName("player") or ""
        if playerName == me then
            return 0
        end
        if state.raidData[playerName] == nil then
            state.raidData[playerName] = {}
        end
        local parsed = 0
        local trackedSet = {}
        local trackedSpells = RaidCD.config.db.trackedSpells
        for className in pairs(trackedSpells) do
            local classSpells = trackedSpells[className]
            for ____, id in ipairs(classSpells) do
                trackedSet[id] = true
            end
        end
        local iter = string.gmatch(message, "[^;]+")
        local entry = iter()
        while entry ~= nil do
            local idStr, remStr, rdyStr, durStr = string.match(entry, "^(%d+)|([%d%.]+)|([01])|([%d%.]+)$")
            if idStr ~= nil then
                local spellId = tonumber(idStr)
                if trackedSet[spellId] then
                    local remaining = tonumber(remStr) or 0
                    local ready = rdyStr == "1"
                    local duration = tonumber(durStr) or 0
                    state.raidData[playerName][spellId] = {
                        ready = ready,
                        remaining = remaining,
                        duration = duration,
                        lastUpdate = GetTime(),
                        isSelf = false
                    }
                    local spellName = GetSpellInfo(spellId)
                    parsed = parsed + 1
                end
            end
            entry = iter()
        end
        return parsed
    end
end)()
