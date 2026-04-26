NOTIF_CLASS_COLORS = {
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
notifManager = {}
notifManager.notifications = {}
notifManager.pendingTargets = {}
notifManager.pendingSpells = {}
notifManager.Init = function()
    local notifAnchor = _G.RaidCD_NotifAnchor
    local anchor
    if notifAnchor ~= nil then
        notifAnchor:UnregisterAllEvents()
        notifAnchor:SetScript("OnUpdate", nil)
        anchor = notifAnchor
    else
        anchor = CreateFrame("Frame", "RaidCD_NotifAnchor", UIParent)
    end
    anchor:SetSize(32, 32)
    anchor:SetFrameStrata("LOW")
    anchor:SetClampedToScreen(true)
    anchor:SetMovable(true)
    anchor:EnableMouse(true)
    anchor:RegisterForDrag("LeftButton")
    local pos = RaidCD.config.db.notifPosition
    anchor:SetPoint(
        pos.point,
        UIParent,
        pos.point,
        pos.x,
        pos.y
    )
    local editBorder = anchor:CreateTexture(nil, "BACKGROUND")
    editBorder:SetPoint(
        "TOPLEFT",
        anchor,
        "TOPLEFT",
        0,
        0
    )
    editBorder:SetPoint(
        "BOTTOMRIGHT",
        anchor,
        "BOTTOMRIGHT",
        0,
        0
    )
    editBorder:SetTexture("Interface\\ICONS\\ability_bossashvane_icon01")
    editFill = anchor:CreateTexture(nil, "ARTWORK")
    editFill:SetAllPoints(anchor)
    editFill:SetColorTexture(0, 0, 0, 0)
    local editLabel = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    editLabel:SetPoint(
        "BOTTOMLEFT",
        anchor,
        "BOTTOMLEFT",
        0,
        -3
    )
    editLabel:SetText("Notifications")
    editLabel:SetTextColor(1, 1, 1, 0.9)
    editLabel:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", RaidCD.config.db.notifLabelFontSize, "OUTLINE")
    editLabel:SetJustifyH("LEFT")
    local chipBg = anchor:CreateTexture(nil, "BACKGROUND")
    chipBg:SetHeight(16)
    chipBg:SetWidth(editLabel:GetStringWidth() + 12)
    chipBg:SetPoint(
        "CENTER",
        editLabel,
        "CENTER",
        0,
        0
    )
    chipBg:SetTexture("Interface\\COMMON\\Common-Input-Border-TL")
    chipBg:SetTexCoord(0, 1, 0, 1)
    chipBg:SetVertexColor(1, 1, 1, 0.18)
    local lockDot = anchor:CreateTexture(nil, "OVERLAY")
    lockDot:SetSize(32, 32)
    lockDot:SetPoint(
        "CENTER",
        anchor,
        "CENTER",
        0,
        0
    )
    lockDot:SetTexture("Interface\\ICONS\\ability_bossashvane_icon01")
    anchor:SetScript(
        "OnDragStart",
        function(frame)
            if not RaidCD.config.db.locked then
                frame:StartMoving()
            end
        end
    )
    anchor:SetScript(
        "OnDragStop",
        function(frame)
            frame:StopMovingOrSizing()
            local point = select(
                1,
                frame:GetPoint()
            ) or "TOP"
            local x = select(
                4,
                frame:GetPoint()
            ) or 0
            local y = select(
                5,
                frame:GetPoint()
            ) or 0
            RaidCD.config.db.notifPosition = {point = point, x = x, y = y}
        end
    )
    anchor:SetScript(
        "OnEnter",
        function()
            if not RaidCD.config.db.locked then
                GameTooltip_SetDefaultAnchor(GameTooltip, anchor)
                GameTooltip:AddLine("Notification Anchor")
                GameTooltip:AddLine("Drag to move")
                GameTooltip:Show()
            end
        end
    )
    anchor:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )
    anchor:SetScript(
        "OnMouseUp",
        function(frame, button)
            if button == "RightButton" then
                InterfaceOptionsFrame_OpenToCategory("RaidCooldownTracker")
            end
        end
    )
    local function UpdateNotifAnchorVisual()
        local sm = RaidCD.config.db.serverMode
        local hideTitle = RaidCD.config.db.hideNotifTitle
        if sm then
            editBorder:Hide()
            editFill:Hide()
            lockDot:Hide()
            editLabel:Hide()
            chipBg:Hide()
            anchor:Hide()
            anchor:EnableMouse(false)
        elseif RaidCD.config.db.locked then
            editBorder:Hide()
            editFill:Hide()
            lockDot:Hide()
            if hideTitle then
                editLabel:Hide()
                chipBg:Hide()
            else
                editLabel:Show()
                chipBg:Show()
            end
            anchor:Show()
            anchor:EnableMouse(false)
        else
            editBorder:Hide()
            editFill:Hide()
            lockDot:Show()
            if hideTitle then
                editLabel:Hide()
                chipBg:Hide()
            else
                editLabel:Show()
                chipBg:Show()
            end
            anchor:Show()
            anchor:EnableMouse(true)
        end
    end
    UpdateNotifAnchorVisual()
    notifManager.anchor = anchor
    notifManager.UpdateAnchorVisual = UpdateNotifAnchorVisual
    notifManager.UpdateLabelFont = function()
        editLabel:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", RaidCD.config.db.notifLabelFontSize, "OUTLINE")
    end
    do
        local i = 0
        while i < RaidCD.NOTIF_POOL_SIZE do
            local notif = RaidCD.ui.CreateNotification(anchor, i)
            table.insert(notifManager.notifications, notif)
            i = i + 1
        end
    end
    anchor:SetScript(
        "OnUpdate",
        function(frame)
            notifManager:Tick()
        end
    )
end
notifManager.ShowNotification = function(____, requester, spellId, spellName, spellIcon, target)
    if RaidCD.config.db.serverMode then
        return
    end
    local dur = RaidCD.config.db.notifDuration or 5
    for ____, notif in ipairs(notifManager.notifications) do
        local sameTarget = (target == nil and notif.target == nil) or (target ~= nil and notif.target ~= nil and target == notif.target)
        if notif.frame:IsShown() and notif.spellName == spellName and sameTarget then
            local alreadyListed = false
            for ____, name in ipairs(notif.requesters) do
                if name == requester then
                    alreadyListed = true
                    break
                end
            end
            if not alreadyListed then
                table.insert(notif.requesters, requester)
            end
            notif.expireTime = GetTime() + dur
            RaidCD.ui.UpdateNotificationText(notif)
            return
        end
    end
    for ____, notif in ipairs(notifManager.notifications) do
        if not notif.frame:IsShown() then
            notif.requesters = {requester}
            notif.spellName = spellName
            notif.target = target
            notif.requesterClass = RaidCD.roster:GetClass(requester)
            notif.spellClass = ""
            for cls in pairs(RaidCD.config.db.trackedSpells) do
                local list = RaidCD.config.db.trackedSpells[cls]
                for ____, id in ipairs(list) do
                    if id == spellId then
                        notif.spellClass = cls
                        break
                    end
                end
                if notif.spellClass ~= "" then
                    break
                end
            end
            notif.expireTime = GetTime() + dur
            if spellIcon ~= nil and spellIcon ~= "" then
                notif.icon:SetTexture(spellIcon)
            else
                notif.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            RaidCD.ui.UpdateNotificationText(notif)
            notif.fadeAlpha = 0
            notif.fadingIn = true
            notif.fadingOut = false
            notif.frame:SetAlpha(0)
            notif.frame:Show()
            if target then
                notifManager.pendingTargets[target] = notif
            else
                notifManager.pendingSpells[spellName] = notif
            end
            return
        end
    end
    local oldest = notifManager.notifications[1]
    for ____, notif in ipairs(notifManager.notifications) do
        if notif.expireTime < oldest.expireTime then
            oldest = notif
        end
    end
    for s, n in pairs(notifManager.pendingSpells) do
        if n == oldest then
            notifManager.pendingSpells[s] = nil
            break
        end
    end
    oldest.requesters = {requester}
    oldest.spellName = spellName
    oldest.target = target
    oldest.requesterClass = RaidCD.roster:GetClass(requester)
    oldest.spellClass = ""
    for cls in pairs(RaidCD.config.db.trackedSpells) do
        local list = RaidCD.config.db.trackedSpells[cls]
        for ____, id in ipairs(list) do
            if id == spellId then
                oldest.spellClass = cls
                break
            end
        end
        if oldest.spellClass ~= "" then
            break
        end
    end
    oldest.expireTime = GetTime() + dur
    local iconToUse = spellIcon
    if iconToUse == nil or iconToUse == "" then
        local info = {GetSpellInfo(spellId)}
        local ____temp_0
        if info ~= nil then
            ____temp_0 = info[3]
        else
            ____temp_0 = nil
        end
        iconToUse = ____temp_0
    end
    if iconToUse ~= nil and iconToUse ~= "" then
        oldest.icon:SetTexture(tostring(iconToUse))
    else
        oldest.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    RaidCD.ui.UpdateNotificationText(oldest)
    oldest.fadeAlpha = 0
    oldest.fadingIn = true
    oldest.fadingOut = false
    oldest.frame:SetAlpha(0)
    oldest.frame:Show()
    if target then
        notifManager.pendingTargets[target] = oldest
    else
        notifManager.pendingSpells[spellName] = oldest
    end
end
notifManager.Tick = function()
    if RaidCD.config.db.serverMode then
        for ____, notif in ipairs(notifManager.notifications) do
            if notif.frame:IsShown() then
                notif.frame:Hide()
            end
        end
        return
    end
    local now = GetTime()
    local step = RaidCD.config.db.notifHeight + RaidCD.config.db.notifSpacing
    local iconSize = RaidCD.config.db.notifIconSize
    local fontSize = RaidCD.config.db.notifFontSize
    local fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    local fadeSpeed = 0.02
    local bgMode = RaidCD.config.db.notifBgColorMode
    local bgOpacity = RaidCD.config.db.notifBgOpacity
    local visibleIndex = 0
    for ____, notif in ipairs(notifManager.notifications) do
        do
            local __continue49
            repeat
                if notif.frame:IsShown() then
                    if notif.fadingIn then
                        notif.fadeAlpha = math.min(1, notif.fadeAlpha + fadeSpeed)
                        if notif.fadeAlpha >= 1 then
                            notif.fadingIn = false
                        end
                    end
                    if now >= notif.expireTime and not notif.fadingOut then
                        notif.fadingOut = true
                    end
                    if notif.fadingOut then
                        local speed = notif.resolved and 0.15 or fadeSpeed
                        notif.fadeAlpha = math.max(0, notif.fadeAlpha - speed)
                        if notif.fadeAlpha <= 0 then
                            notif.frame:Hide()
                            notif.frame:SetAlpha(1)
                            notif.requesters = {}
                            notif.spellName = ""
                            notif.target = nil
                            notif.requesterClass = ""
                            notif.spellClass = ""
                            notif.fadingIn = false
                            notif.fadingOut = false
                            notif.fadeAlpha = 0
                            notif.resolved = nil
                            for t, n in pairs(notifManager.pendingTargets) do
                                if n == notif then
                                    notifManager.pendingTargets[t] = nil
                                    break
                                end
                            end
                            for s, n in pairs(notifManager.pendingSpells) do
                                if n == notif then
                                    notifManager.pendingSpells[s] = nil
                                    break
                                end
                            end
                            __continue49 = true
                            break
                        end
                    end
                    if bgMode == "none" then
                        notif.bg:SetColorTexture(0, 0, 0, 0)
                    else
                        local ____temp_1
                        if bgMode == "requester" then
                            ____temp_1 = notif.requesterClass
                        else
                            ____temp_1 = notif.spellClass
                        end
                        local cls = ____temp_1
                        local color = NOTIF_CLASS_COLORS[cls] or ({r = 0.15, g = 0.15, b = 0.2})
                        notif.bg:SetColorTexture(color.r, color.g, color.b, bgOpacity)
                    end
                    notif.frame:SetAlpha(notif.fadeAlpha)
                    if not InCombatLockdown() then
                        notif.frame:SetSize(RaidCD.config.db.notifWidth, RaidCD.config.db.notifHeight)
                        notif.icon:SetSize(iconSize, iconSize)
                        notif.text:SetFont(fontPath, fontSize, "OUTLINE")
                        notif.frame:ClearAllPoints()
                        notif.frame:SetPoint(
                            "TOPLEFT",
                            notif.frame:GetParent(),
                            "BOTTOMLEFT",
                            0,
                            -(visibleIndex * step + 10)
                        )
                    end
                    visibleIndex = visibleIndex + 1
                end
                __continue49 = true
            until true
            if not __continue49 then
                break
            end
        end
    end
end
notifManager.ResolveTarget = function(__, targetName, spellId)
    local notif = notifManager.pendingTargets[targetName]
    if notif == nil then
        return
    end
    local resolvedBySpell = false
    if spellId ~= nil then
        for cls in pairs(RaidCD.config.db.trackedSpells) do
            local list = RaidCD.config.db.trackedSpells[cls]
            for ____, id in ipairs(list) do
                if id == spellId and notif.spellName then
                    local info = {GetSpellInfo(id)}
                    if info and info[1] == notif.spellName then
                        resolvedBySpell = true
                        break
                    end
                end
            end
            if resolvedBySpell then
                break
            end
        end
    end
    notif.resolved = true
    notif.fadingOut = true
    notifManager.pendingTargets[targetName] = nil
end
notifManager.ResolveSpell = function(__, spellId)
    local spellInfo = {GetSpellInfo(spellId)}
    local spellName = spellInfo and spellInfo[1]
    if not spellName then return end
    local notif = notifManager.pendingSpells[spellName]
    if not notif then
        return
    end
    notif.resolved = true
    notif.fadingOut = true
    notifManager.pendingSpells[spellName] = nil
end
RaidCD.ui = RaidCD.ui or ({})
RaidCD.ui.notifManager = notifManager
