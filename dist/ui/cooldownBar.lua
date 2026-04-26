CreateCooldownBar = function(parent, index)
    local width = RaidCD.config.db.barWidth
    local height = RaidCD.config.db.barHeight
    local frame = CreateFrame(
        "Frame",
        "RaidCD_Bar" .. tostring(index),
        parent
    )
    frame:SetSize(width, height)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0.1, 0.1, 0.1, RaidCD.config.db.barBgOpacity or 0.8)
    local statusBar = CreateFrame(
        "StatusBar",
        "RaidCD_BarSB" .. tostring(index),
        frame
    )
    statusBar:SetSize(width - 4, height - 4)
    statusBar:SetPoint(
        "CENTER",
        frame,
        "CENTER",
        0,
        0
    )
    statusBar:SetStatusBarTexture(RaidCD.config.db.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetStatusBarColor(0.9, 0.2, 0.2, 1)
    statusBar:EnableMouse(false)
    local icon = statusBar:CreateTexture(nil, "OVERLAY")
    icon:SetSize(height - 2, height - 2)
    icon:SetPoint(
        "LEFT",
        frame,
        "LEFT",
        1,
        0
    )
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local countdownText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    countdownText:SetPoint(
        "RIGHT",
        statusBar,
        "RIGHT",
        -4,
        0
    )
    countdownText:SetJustifyH("RIGHT")
    countdownText:SetWidth(40)
    local spellText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    spellText:SetJustifyH("LEFT")
    local playerText = statusBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    playerText:SetJustifyH("RIGHT")
    local clickOverlay = CreateFrame("Button", nil, frame)
    clickOverlay:SetAllPoints(frame)
    clickOverlay:SetFrameLevel(frame:GetFrameLevel() + 10)
    clickOverlay:RegisterForClicks("AnyUp")
    clickOverlay:SetScript(
        "OnClick",
        function(self, button)
            RaidCD:Log("Bar CLICK detected: button=" .. tostring(button))
            local parent = self:GetParent()
            local spellId = parent.currentSpellId
            if spellId == nil then
                RaidCD:Log("Bar CLICK: ABORT spellId=nil")
                return
            end
            local spellInfo = {GetSpellInfo(spellId)}
            local spellName = spellInfo and spellInfo[1] or nil
            if spellName == nil or spellName == "" then
                RaidCD:Log("Bar CLICK: ABORT spellName=nil for spellId=" .. tostring(spellId))
                return
            end
            local channel = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or nil
            if channel == nil then
                print(RaidCD.COLORS.ERROR .. "You must be in a raid or party to request cooldowns.")
                return
            end
            local scope = RaidCD.config.db.spellScopes and RaidCD.config.db.spellScopes[spellId]
            local msgToSend
            if scope == "personal" then
                local playerName = UnitName("player") or ""
                msgToSend = "REQ \"" .. spellName .. "\" \"" .. playerName .. "\""
            else
                msgToSend = "REQ \"" .. spellName .. "\""
            end
            SendAddonMessage(RaidCD.PREFIX, msgToSend, channel)
            RaidCD:Log("Bar CLICK: SENT request for " .. tostring(spellName))
            print(RaidCD.COLORS.INFO .. "Request sent: " .. spellName)
        end
    )
    frame:Hide()
    return {
        frame = frame,
        statusBar = statusBar,
        icon = icon,
        spellText = spellText,
        playerText = playerText,
        countdownText = countdownText,
        bg = bg
    }
end
UpdateCooldownBar = function(bar, entry, now)
    if entry == nil then
        bar.frame:Hide()
        bar.frame.currentSpellId = nil
        return
    end
    local data = entry.data
    local timeSinceUpdate = now - (data.lastUpdate or now)
    local liveRemaining = math.max(0, (data.remaining or 0) - timeSinceUpdate)
    local totalDuration = math.max(1, data.duration or 30)
    local isReady = data.ready or liveRemaining <= 0.5
    local fillValue = isReady and 1 or math.max(0, 1 - liveRemaining / totalDuration)
    local ____isReady_0
    if isReady then
        ____isReady_0 = RaidCD.COLORS.READY
    else
        ____isReady_0 = RaidCD.COLORS.ON_CD
    end
    local color = ____isReady_0
    local spellInfo = {GetSpellInfo(entry.spellId)}
    local ____temp_1
    if spellInfo ~= nil and spellInfo[1] ~= nil then
        ____temp_1 = spellInfo[1]
    else
        ____temp_1 = "Spell#" .. tostring(entry.spellId)
    end
    local spellName = ____temp_1
    local ____temp_2
    if spellInfo ~= nil and spellInfo[3] ~= nil then
        ____temp_2 = spellInfo[3]
    else
        ____temp_2 = nil
    end
    local spellIcon = ____temp_2
    bar.statusBar:SetValue(fillValue)
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    bar.spellText:SetText(spellName)
    bar.playerText:SetText(entry.playerName)
    bar.countdownText:SetText(isReady and "" or tostring(math.ceil(liveRemaining)) .. "s")
    if entry.collapsed then
        local aggrLabel
        if isReady then
            aggrLabel = entry.playerName
        else
            aggrLabel = tostring(math.ceil(liveRemaining)) .. "s"
        end
        bar.spellText:SetText(entry.superCompact and "" or spellName)
        bar.playerText:SetText(aggrLabel)
        bar.countdownText:SetText("")
    end
    local showIcon = RaidCD.config.db.showIcons and spellIcon ~= nil
    local iconSize = entry.superCompact and (RaidCD.config.db.barHeight - 4) or (RaidCD.config.db.barHeight - 2)
    local ____showIcon_3
    if showIcon and not entry.superCompact then
        ____showIcon_3 = iconSize + 4
    else
        ____showIcon_3 = 0
    end
    local iconPad = ____showIcon_3
    bar.spellText:ClearAllPoints()
    bar.playerText:ClearAllPoints()
    bar.icon:ClearAllPoints()
    bar.countdownText:ClearAllPoints()
    if entry.shotcalling then
        bar.icon:SetPoint("LEFT", bar.frame, "LEFT", 1, 0)
        bar.playerText:ClearAllPoints()
        bar.playerText:SetPoint("LEFT", bar.icon, "RIGHT", 4, 0)
        bar.playerText:SetJustifyH("LEFT")
        bar.countdownText:ClearAllPoints()
        bar.countdownText:SetPoint("LEFT", bar.playerText, "RIGHT", 4, 0)
        bar.countdownText:SetJustifyH("LEFT")
        bar.countdownText:SetText(isReady and "" or tostring(math.ceil(liveRemaining)) .. "s")
    else
        bar.countdownText:SetPoint(
            "RIGHT",
            bar.statusBar,
            "RIGHT",
            -4,
            0
        )
        bar.countdownText:SetJustifyH("RIGHT")
    end
    local barW = RaidCD.config.db.barWidth
    if not entry.shotcalling then
        if entry.collapsed then
            bar.icon:SetPoint("LEFT", bar.frame, "LEFT", 1, 0)
            bar.spellText:SetPoint("LEFT", bar.statusBar, "LEFT", iconPad > 0 and iconPad or 4, 0)
            bar.spellText:SetPoint("RIGHT", bar.statusBar, "RIGHT", -4, 0)
            if entry.superCompact then
                bar.playerText:ClearAllPoints()
                bar.playerText:SetPoint("LEFT", bar.icon, "RIGHT", 2, 0)
                bar.countdownText:ClearAllPoints()
                bar.countdownText:SetPoint("LEFT", bar.playerText, "RIGHT", 2, 0)
                bar.countdownText:SetJustifyH("LEFT")
            else
                bar.playerText:ClearAllPoints()
                bar.playerText:SetPoint("RIGHT", bar.statusBar, "RIGHT", -4, 0)
            end
        elseif isReady then
            bar.icon:SetPoint("LEFT", bar.frame, "LEFT", 1, 0)
            bar.spellText:SetPoint("LEFT", bar.statusBar, "LEFT", iconPad > 0 and iconPad or 4, 0)
            bar.spellText:SetPoint("RIGHT", bar.statusBar, "RIGHT", -4, 0)
            bar.playerText:ClearAllPoints()
            bar.playerText:SetPoint("RIGHT", bar.statusBar, "RIGHT", -4, 0)
        else
            bar.icon:SetPoint("LEFT", bar.frame, "LEFT", 1, 0)
            bar.countdownText:ClearAllPoints()
            bar.countdownText:SetPoint("RIGHT", bar.statusBar, "RIGHT", -4, 0)
            bar.spellText:ClearAllPoints()
            bar.spellText:SetPoint("LEFT", bar.statusBar, "LEFT", iconPad > 0 and iconPad or 4, 0)
            bar.spellText:SetPoint("RIGHT", bar.statusBar, "RIGHT", -4, 0)
            bar.playerText:ClearAllPoints()
            bar.playerText:SetPoint("RIGHT", bar.countdownText, "LEFT", -4, 0)
        end
    end
    if RaidCD.config.db.showIcons and spellIcon ~= nil then
        bar.icon:SetTexture(tostring(spellIcon))
        bar.icon:Show()
    else
        bar.icon:Hide()
    end
    local fontSize = RaidCD.config.db.fontSize
    local fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    bar.spellText:SetFont(fontPath, fontSize, "OUTLINE")
    bar.playerText:SetFont(fontPath, fontSize - 2, "OUTLINE")
    bar.countdownText:SetFont(fontPath, fontSize, "OUTLINE")
    if entry.superCompact then
        local scWidth = math.max(20, RaidCD.config.db.barHeight * 1.7)
        bar.frame:SetSize(scWidth, RaidCD.config.db.barHeight)
        bar.statusBar:SetSize(scWidth - 2, RaidCD.config.db.barHeight - 2)
        bar.icon:SetSize(RaidCD.config.db.barHeight - 4, RaidCD.config.db.barHeight - 4)
        bar.spellText:Hide()
        bar.playerText:SetFont(fontPath, RaidCD.config.db.fontSize - 2, "OUTLINE")
    elseif entry.shotcalling then
        bar.frame:SetSize(RaidCD.config.db.barWidth, RaidCD.config.db.barHeight)
        bar.statusBar:SetSize(RaidCD.config.db.barWidth - 4, RaidCD.config.db.barHeight - 4)
        bar.icon:SetSize(RaidCD.config.db.barHeight - 2, RaidCD.config.db.barHeight - 2)
        bar.spellText:Hide()
    else
        bar.frame:SetSize(RaidCD.config.db.barWidth, RaidCD.config.db.barHeight)
        bar.statusBar:SetSize(RaidCD.config.db.barWidth - 4, RaidCD.config.db.barHeight - 4)
        bar.icon:SetSize(RaidCD.config.db.barHeight - 2, RaidCD.config.db.barHeight - 2)
        bar.spellText:Show()
    end
    bar.frame.currentSpellId = entry.spellId
    bar.bg:SetColorTexture(0.1, 0.1, 0.1, RaidCD.config.db.barBgOpacity or 0.8)
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b, RaidCD.config.db.barBgOpacity or 0.8)
    bar.frame:Show()
end
CLASS_COLORS = {
    DEATHKNIGHT = {r = 0.77, g = 0.12, b = 0.23},
    DRUID = {r = 1, g = 0.49, b = 0.04},
    HUNTER = {r = 0.67, g = 0.83, b = 0.45},
    MAGE = {r = 0.41, g = 0.8, b = 0.94},
    PALADIN = {r = 0.96, g = 0.55, b = 0.73},
    PRIEST = {r = 1, g = 1, b = 1},
    ROGUE = {r = 1, g = 0.96, b = 0.41},
    SHAMAN = {r = 0, g = 0.44, b = 0.87},
    WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
    WARRIOR = {r = 0.78, g = 0.61, b = 0.43}
}
CreateClassHeader = function(parent, index)
    local frame = CreateFrame(
        "Frame",
        "RaidCD_ClassHeader" .. tostring(index),
        parent
    )
    frame:SetSize(RaidCD.config.db.barWidth, 14)
    local accent = frame:CreateTexture(nil, "ARTWORK")
    accent:SetSize(2, 10)
    accent:SetPoint(
        "LEFT",
        frame,
        "LEFT",
        2,
        0
    )
    accent:SetColorTexture(0.4, 0.4, 0.5, 0.8)
    local divider = frame:CreateTexture(nil, "BACKGROUND")
    divider:SetHeight(1)
    divider:SetPoint(
        "LEFT",
        frame,
        "LEFT",
        2,
        0
    )
    divider:SetPoint(
        "RIGHT",
        frame,
        "RIGHT",
        -2,
        0
    )
    divider:SetPoint(
        "BOTTOM",
        frame,
        "BOTTOM",
        0,
        2
    )
    divider:SetColorTexture(0.4, 0.4, 0.5, 0)
    local chipBg = frame:CreateTexture(nil, "ARTWORK")
    chipBg:SetHeight(12)
    chipBg:SetPoint(
        "LEFT",
        accent,
        "RIGHT",
        3,
        0
    )
    chipBg:SetColorTexture(0.5, 0.5, 0.5, 0.2)
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint(
        "LEFT",
        accent,
        "RIGHT",
        6,
        0
    )
    label:SetJustifyH("LEFT")
    label:SetWidth(RaidCD.config.db.barWidth - 20)
    label:SetTextColor(0.7, 0.7, 0.8, 0.9)
    label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", RaidCD.config.db.headerFontSize, "OUTLINE")
    frame:Hide()
    return {frame = frame, headerLabel = label, chipBg = chipBg, accent = accent}
end
SetHeaderClass = function(header, className)
    local c = CLASS_COLORS[className] or ({r = 0.7, g = 0.7, b = 0.8})
    header.headerLabel:SetTextColor(c.r, c.g, c.b, 1)
    header.chipBg:SetColorTexture(c.r, c.g, c.b, 0.18)
    header.accent:SetColorTexture(c.r, c.g, c.b, 0.8)
    local textWidth = header.headerLabel:GetStringWidth()
    header.chipBg:SetWidth(textWidth + 8)
end
RaidCD.ui = RaidCD.ui or ({})
RaidCD.ui.CreateCooldownBar = CreateCooldownBar
RaidCD.ui.UpdateCooldownBar = UpdateCooldownBar
RaidCD.ui.CreateClassHeader = CreateClassHeader
RaidCD.ui.SetHeaderClass = SetHeaderClass
