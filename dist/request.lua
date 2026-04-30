request = {}
request.HandleRequest = function(____, sender, spellName, target)
    local filter = RaidCD.config.db.reqFilter
    local allSpells = RaidCD.config.db.trackedSpells
    local foundId = 0
    local spellIcon = ""
    local anyOnCd = false
    local cdOwnedId = 0
    local readyOwnedId = 0
    for cls in pairs(allSpells) do
        local classSpells = allSpells[cls]
        for ____, trackedId in ipairs(classSpells) do
            local sName, ____, sIcon = GetSpellInfo(trackedId)
            if sName == spellName then
                if foundId == 0 then
                    foundId = trackedId
                    if sIcon ~= nil then
                        spellIcon = tostring(sIcon)
                    end
                end
                local s, d = GetSpellCooldown(trackedId)
                if s and s > 0 and d and d > 1.5 then
                    anyOnCd = true
                    cdOwnedId = trackedId
                elseif s == 0 and d == 0 and IsSpellKnown and IsSpellKnown(trackedId, false) then
                    readyOwnedId = trackedId
                end
            end
        end
    end
    local ownedId = 0
    if anyOnCd then
        ownedId = cdOwnedId
    else
        ownedId = readyOwnedId
    end
    if foundId == 0 then
        if filter ~= "all" then
            return
        end
        local sName, ____, sIcon = GetSpellInfo(spellName)
        if sName then
            RaidCD.ui.notifManager:ShowNotification(sender, 0, spellName, sIcon and tostring(sIcon) or "", target)
        end
        return
    end
    if filter == "all" then
        RaidCD.ui.notifManager:ShowNotification(sender, foundId, spellName, spellIcon, target)
    elseif filter == "have" then
        if ownedId > 0 then
            RaidCD.ui.notifManager:ShowNotification(sender, ownedId, spellName, spellIcon, target)
        end
    else
        if ownedId > 0 then
            local cd = RaidCD.cooldown:GetSpellCD(ownedId)
            if cd.ready then
                RaidCD.ui.notifManager:ShowNotification(sender, ownedId, spellName, spellIcon, target)
            end
        end
    end
end
RaidCD.request = request
