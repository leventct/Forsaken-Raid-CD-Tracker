barManager = {}
barManager.bars = {}
barManager.independentManagers = {}

IsGroupIndependent = function(groupKey)
    return RaidCD.config.db.independentAnchors and RaidCD.config.db.independentAnchors[groupKey] ~= nil and RaidCD.config.db.independentAnchors[groupKey] ~= false
end

CreateIndependentManager = function(groupKey)
    if barManager.independentManagers[groupKey] then
        local existing = barManager.independentManagers[groupKey]
        if existing.anchor and existing.anchor.frame then
            if not RaidCD.config.db.serverMode then
                existing.anchor.frame:Show()
            else
                existing.anchor.frame:Hide()
            end
        end
        return existing
    end
    local anchorData = RaidCD.ui.CreateGroupAnchor(groupKey)
    local bars = {}
    local header = RaidCD.ui.CreateClassHeader(anchorData.frame, 0)
    table.insert(bars, header)
    for i = 1, 40 do
        local bar = RaidCD.ui.CreateCooldownBar(anchorData.frame, i)
        table.insert(bars, bar)
    end
    local manager = {
        anchor = anchorData,
        bars = bars,
        groupKey = groupKey,
        Refresh = function(self)
            if RaidCD.config.db.serverMode then
                for _, bar in ipairs(self.bars) do
                    bar.frame:Hide()
                end
                return
            end
            local now = GetTime()
            local me = UnitName("player") or ""
            local hideSelf = RaidCD.config.db.hideSelf
            local entries = {}
            for playerName in pairs(RaidCD.state.raidData) do
                if hideSelf and playerName == me then
                else
                    local spells = RaidCD.state.raidData[playerName]
                    for spellIdStr in pairs(spells) do
                        local spellId = tonumber(spellIdStr)
                        if spellId and (not RaidCD.config.db.spellActive or RaidCD.config.db.spellActive[spellId] ~= false) then
                            local data = spells[spellIdStr]
                            if data then
                                local spellGroup = GetSpellGroup(spellId)
                                if spellGroup == groupKey then
                                    table.insert(entries, {
                                        key = playerName .. "|" .. tostring(spellId),
                                        playerName = playerName,
                                        spellId = spellId,
                                        data = data,
                                        class = spellGroup
                                    })
                                end
                            end
                        end
                    end
                end
            end
            RaidCD.sorting:Sort(entries)
            if RaidCD.config.db.barDisplayMode == "collapsed" or RaidCD.config.db.barDisplayMode == "supercompact" then
                local aggregated = {}
                for ____, entry in ipairs(entries) do
                    local spellId = entry.spellId
                    if aggregated[spellId] == nil then
                        aggregated[spellId] = {
                            spellId = spellId,
                            class = entry.class,
                            readyCount = 0,
                            shortestRemaining = nil,
                            data = {ready = false, remaining = 0, duration = entry.data.duration or 30, lastUpdate = GetTime()}
                        }
                    end
                    local aggr = aggregated[spellId]
                    local timeSinceUpdate = now - (entry.data.lastUpdate or now)
                    local liveRemaining = math.max(0, (entry.data.remaining or 0) - timeSinceUpdate)
                    local isReady = entry.data.ready or liveRemaining <= 0.5
                    if isReady then
                        aggr.readyCount = aggr.readyCount + 1
                        aggr.data.ready = true
                    else
                        if aggr.shortestRemaining == nil or liveRemaining < aggr.shortestRemaining then
                            aggr.shortestRemaining = liveRemaining
                            aggr.data.remaining = liveRemaining
                        end
                    end
                end
                entries = {}
                for spellId, aggr in pairs(aggregated) do
                    local label
                    if aggr.readyCount > 0 then
                        label = tostring(aggr.readyCount)
                    else
                        label = tostring(math.ceil(aggr.shortestRemaining or 0)) .. "s"
                    end
                    local isSuperCompact = RaidCD.config.db.barDisplayMode == "supercompact"
                    table.insert(entries, {
                        key = tostring(spellId),
                        playerName = label,
                        spellId = spellId,
                        data = aggr.data,
                        class = aggr.class,
                        collapsed = true,
                        superCompact = isSuperCompact
                    })
                end
                RaidCD.sorting:Sort(entries)
            elseif RaidCD.config.db.barDisplayMode == "shotcalling" then
                for ____, entry in ipairs(entries) do
                    entry.shotcalling = true
                end
            end
            local step = RaidCD.config.db.barHeight + RaidCD.config.db.barSpacing
            local yOff = 0
            for idx, entry in ipairs(entries) do
                local showHeader = (idx == 1)
                if showHeader then
                    local label = WOTLK_CLASSES_SET[groupKey] or groupKey
                    header.headerLabel:SetText(label)
                    local classColor = CLASS_COLORS[groupKey] or {r=0.7,g=0.7,b=0.8}
                    header.headerLabel:SetTextColor(classColor.r, classColor.g, classColor.b, 1)
                    header.headerLabel:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", RaidCD.config.db.headerFontSize, "OUTLINE")
                    header.chipBg:SetColorTexture(classColor.r, classColor.g, classColor.b, 0.18)
                    header.accent:SetColorTexture(classColor.r, classColor.g, classColor.b, 0.8)
                    local textWidth = header.headerLabel:GetStringWidth()
                    header.chipBg:SetWidth(textWidth + 8)
                    header.frame:SetWidth(RaidCD.config.db.barWidth)
                    header.frame:ClearAllPoints()
                    header.frame:SetPoint("TOPLEFT", anchorData.frame, "BOTTOMLEFT", 0, -yOff)
                    header.frame:Show()
                    yOff = yOff + 14
                end
                local barIndex = idx + 1
                if barIndex <= #self.bars then
                    local bar = self.bars[barIndex]
                    RaidCD.ui.UpdateCooldownBar(bar, entry, now)
                    bar.frame:ClearAllPoints()
                    bar.frame:SetPoint("TOPLEFT", anchorData.frame, "BOTTOMLEFT", 0, -yOff)
                    yOff = yOff + step
                end
            end
            for i = 2, #self.bars do
                if i - 1 > #entries then
                    self.bars[i].frame:Hide()
                end
            end
            if #entries == 0 then
                header.frame:Hide()
            end
        end
    }
    barManager.independentManagers[groupKey] = manager
    if RaidCD.config.db.serverMode then
        anchorData.frame:Hide()
    end
    return manager
end

GetOrCreateIndependentManager = function(groupKey)
    if not IsGroupIndependent(groupKey) then return nil end
    return CreateIndependentManager(groupKey)
end

DestroyIndependentManager = function(groupKey)
    local mgr = barManager.independentManagers[groupKey]
    if mgr then
        for _, bar in ipairs(mgr.bars) do
            bar.frame:Hide()
        end
        mgr.anchor.frame:Hide()
        barManager.independentManagers[groupKey] = nil
    end
end

barManager.Init = function()
    do
        local i = 0
        while i < 20 do
            local header = RaidCD.ui.CreateClassHeader(RaidCD.ui.anchor, i)
            table.insert(barManager.bars, header)
            i = i + 1
        end
    end
    do
        local i = 0
        while i < 40 do
            local bar = RaidCD.ui.CreateCooldownBar(RaidCD.ui.anchor, i)
            table.insert(barManager.bars, bar)
            i = i + 1
        end
    end
end
GetSpellGroup = function(spellId)
    local customGroups = RaidCD.config.db.customGroups or ({})
    do
        local i = 0
        while i < #customGroups do
            local spells = RaidCD.config.db.trackedSpells[customGroups[i + 1]]
            if spells ~= nil then
                for ____, id in ipairs(spells) do
                    if id == spellId and (not RaidCD.config.db.spellActive or RaidCD.config.db.spellActive[spellId] ~= false) then
                        return customGroups[i + 1]
                    end
                end
            end
            i = i + 1
        end
    end
    for groupKey in pairs(RaidCD.config.db.trackedSpells) do
        local spells = RaidCD.config.db.trackedSpells[groupKey]
        if spells ~= nil then
            for ____, id in ipairs(spells) do
                if id == spellId and (not RaidCD.config.db.spellActive or RaidCD.config.db.spellActive[spellId] ~= false) then
                    return groupKey
                end
            end
        end
    end
    return ""
end
WOTLK_CLASSES_SET = {
    DEATHKNIGHT = "Death Knight",
    DRUID = "Druid",
    HUNTER = "Hunter",
    MAGE = "Mage",
    PALADIN = "Paladin",
    PRIEST = "Priest",
    ROGUE = "Rogue",
    SHAMAN = "Shaman",
    WARLOCK = "Warlock",
    WARRIOR = "Warrior"
}
barManager.Refresh = function()
    if not RaidCD.config.db.enabled or RaidCD.config.db.serverMode then
        for _, bar in ipairs(barManager.bars) do
            bar.frame:Hide()
        end
        for _, mgr in pairs(barManager.independentManagers) do
            for _, bar in ipairs(mgr.bars) do
                bar.frame:Hide()
            end
            if mgr.anchor and mgr.anchor.frame then
                mgr.anchor.frame:Hide()
            end
        end
        return
    end
    if not RaidCD.config.db.enabled or RaidCD.config.db.serverMode then
        return
    end
    local now = GetTime()
    local me = UnitName("player") or ""
    local hideSelf = RaidCD.config.db.hideSelf
    local mainEntries = {}
    local independentEntries = {}
    for playerName in pairs(RaidCD.state.raidData) do
        do
            local __continue24
            repeat
                if hideSelf and playerName == me then
                    __continue24 = true
                    break
                end
                local spells = RaidCD.state.raidData[playerName]
                for spellIdStr in pairs(spells) do
                    do
                        local __continue26
                        repeat
                            local spellId = tonumber(spellIdStr)
                            if spellId == nil then
                                __continue26 = true
                                break
                            end
                            if RaidCD.config.db.spellActive and RaidCD.config.db.spellActive[spellId] == false then
                                __continue26 = true
                                break
                            end
                            local data = spells[spellIdStr]
                            if data == nil then
                                __continue26 = true
                                break
                            end
                            local groupKey = GetSpellGroup(spellId)
                            local ____table_insert_2 = table.insert
                            local ____temp_1 = (playerName .. "|") .. tostring(spellId)
                            local ____temp_0
                            if groupKey ~= "" then
                                ____temp_0 = groupKey
                            else
                                ____temp_0 = RaidCD.roster:GetClass(playerName)
                            end
                            local entry = {
                                key = ____temp_1,
                                playerName = playerName,
                                spellId = spellId,
                                data = data,
                                class = ____temp_0
                            }
                            if IsGroupIndependent(____temp_0) then
                                if not independentEntries[____temp_0] then
                                    independentEntries[____temp_0] = {}
                                end
                                ____table_insert_2(independentEntries[____temp_0], entry)
                            else
                                ____table_insert_2(mainEntries, entry)
                            end
                            __continue26 = true
                        until true
                        if not __continue26 then
                            break
                        end
                    end
                end
                __continue24 = true
            until true
            if not __continue24 then
                break
            end
        end
    end
    for groupKey, entries in pairs(independentEntries) do
        local mgr = GetOrCreateIndependentManager(groupKey)
        if mgr then
            mgr:Refresh()
        end
    end
    RaidCD.sorting:Sort(mainEntries)
    if RaidCD.config.db.barDisplayMode == "shotcalling" then
        for ____, entry in ipairs(mainEntries) do
            entry.shotcalling = true
        end
    elseif RaidCD.config.db.barDisplayMode == "collapsed" or RaidCD.config.db.barDisplayMode == "supercompact" then
        local aggregated = {}
        for ____, entry in ipairs(mainEntries) do
            local spellId = entry.spellId
            if aggregated[spellId] == nil then
                aggregated[spellId] = {
                    spellId = spellId,
                    class = entry.class,
                    readyCount = 0,
                    shortestRemaining = nil,
                    data = {ready = false, remaining = 0, duration = entry.data.duration or 30, lastUpdate = GetTime()}
                }
            end
            local aggr = aggregated[spellId]
            local timeSinceUpdate = now - (entry.data.lastUpdate or now)
            local liveRemaining = math.max(0, (entry.data.remaining or 0) - timeSinceUpdate)
            local isReady = entry.data.ready or liveRemaining <= 0.5
            if isReady then
                aggr.readyCount = aggr.readyCount + 1
                aggr.data.ready = true
            else
                if aggr.shortestRemaining == nil or liveRemaining < aggr.shortestRemaining then
                    aggr.shortestRemaining = liveRemaining
                    aggr.data.remaining = liveRemaining
                end
            end
        end
        mainEntries = {}
        for spellId, aggr in pairs(aggregated) do
            local label
            if aggr.readyCount > 0 then
                label = tostring(aggr.readyCount)
            else
                label = tostring(math.ceil(aggr.shortestRemaining or 0)) .. "s"
            end
            local isSuperCompact = RaidCD.config.db.barDisplayMode == "supercompact"
            table.insert(mainEntries, {
                key = tostring(spellId),
                playerName = label,
                spellId = spellId,
                data = aggr.data,
                class = aggr.class,
                collapsed = true,
                superCompact = isSuperCompact
            })
        end
        RaidCD.sorting:Sort(mainEntries)
    end
    local step = RaidCD.config.db.barHeight + RaidCD.config.db.barSpacing
    local yOff = 0
    local lastClass = ""
    local headerCount = 0
    local barCount = 0
    for ____, entry in ipairs(mainEntries) do
        if entry.class ~= lastClass then
            if RaidCD.config.db.showClassHeaders and headerCount < 20 then
                if headerCount > 0 then
                    yOff = yOff + RaidCD.config.db.headerSpacing
                end
                local header = barManager.bars[headerCount + 1]
                local label = WOTLK_CLASSES_SET[entry.class] or entry.class
                header.headerLabel:SetText(label)
                RaidCD.ui.SetHeaderClass(header, entry.class)
                header.headerLabel:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", RaidCD.config.db.headerFontSize, "OUTLINE")
                header.frame:SetWidth(RaidCD.config.db.barWidth)
                header.frame:ClearAllPoints()
                header.frame:SetPoint(
                    "TOPLEFT",
                    RaidCD.ui.anchor,
                    "BOTTOMLEFT",
                    0,
                    -yOff
                )
                header.frame:Show()
                headerCount = headerCount + 1
                yOff = yOff + 14
                lastClass = entry.class
            end
        end
        local barIndex = 20 + barCount
        if barIndex < #barManager.bars then
            RaidCD.ui.UpdateCooldownBar(barManager.bars[barIndex + 1], entry, now)
            barManager.bars[barIndex + 1].frame:ClearAllPoints()
            barManager.bars[barIndex + 1].frame:SetPoint(
                "TOPLEFT",
                RaidCD.ui.anchor,
                "BOTTOMLEFT",
                0,
                -yOff
            )
            barCount = barCount + 1
            yOff = yOff + step
        end
    end
    for i = headerCount + 1, 20 do
        barManager.bars[i].frame:Hide()
    end
    for i = 20 + barCount + 1, #barManager.bars do
        barManager.bars[i].frame:Hide()
    end
end
RaidCD.ui = RaidCD.ui or ({})
RaidCD.ui.barManager = barManager
