events = {}
events.frame = nil
events.Init = function()
    local existing = _G.RaidCD_EventsFrame
    if existing ~= nil then
        existing:UnregisterAllEvents()
        existing:SetScript("OnEvent", nil)
    end
    events.frame = CreateFrame("Frame", "RaidCD_EventsFrame", UIParent)
    events.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    events.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    events.frame:SetScript(
        "OnEvent",
        function(frame, event, ...)
            local args = {...}
            if not RaidCD.config.db.enabled then
                return
            end
            if RaidCD.roster.demoActive then
                return
            end
            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                events.HandleCLEU(nil, args)
            elseif event == "SPELL_UPDATE_COOLDOWN" then
                events.HandleCooldownUpdate()
            end
        end
    )
end
events.HandleCLEU = function(____, args)
    local subevent = args[2]
    local sourceName = args[4]
    local sourceFlags = args[5]
    local destName = args[7]
    local spellId = args[9]
    if subevent ~= "SPELL_CAST_SUCCESS" then
        return
    end
    if sourceFlags == nil then
        return
    end
    if _G["bit"].band(sourceFlags, 7) == 0 then
        return
    end
    local me = UnitName("player")
    if sourceName ~= me then
        if destName and RaidCD.ui and RaidCD.ui.notifManager then
            RaidCD.ui.notifManager:ResolveTarget(destName, spellId)
        end
        if RaidCD.ui and RaidCD.ui.notifManager then
            RaidCD.ui.notifManager:ResolveSpell(spellId)
        end
        return
    end
    local allSpells = RaidCD.config.db.trackedSpells
    for cls in pairs(allSpells) do
        local classSpells = allSpells[cls]
        for ____, tracked in ipairs(classSpells) do
            if tracked == spellId then
                RaidCD.state:UpdateSelf()
                RaidCD.broadcast:Send()
                RaidCD.ui:Refresh()
                if destName and RaidCD.ui and RaidCD.ui.notifManager then
                    RaidCD.ui.notifManager:ResolveTarget(destName, spellId)
                end
                if RaidCD.ui and RaidCD.ui.notifManager then
                    RaidCD.ui.notifManager:ResolveSpell(spellId)
                end
                return
            end
        end
    end
end
events.HandleCooldownUpdate = function()
    local me = UnitName("player") or "Unknown"
    local myData = RaidCD.state.raidData[me]
    if myData == nil then
        return
    end
    local now = GetTime()
    local allSpells = RaidCD.config.db.trackedSpells
    for cls in pairs(allSpells) do
        local classSpells = allSpells[cls]
        for ____, spellId in ipairs(classSpells) do
            if RaidCD.cooldown:PlayerKnowsSpell(spellId) then
                local cd = RaidCD.cooldown:GetSpellCD(spellId)
                local prev = myData[spellId]
                if prev ~= nil then
                    local prevRemaining = math.max(0, (prev.remaining or 0) - (now - (prev.lastUpdate or now)))
                    local diff = math.abs(cd.remaining - prevRemaining)
                    if diff > 1 or (not prev.ready and cd.ready) then
                        RaidCD.state:UpdateSelf()
                        RaidCD.broadcast:Send()
                        RaidCD.ui:Refresh()
                        return
                    end
                end
            end
        end
    end
end
RaidCD.events = events
