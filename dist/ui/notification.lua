CreateNotification = function(parent, index)
    local iconSize = RaidCD.config.db.notifIconSize
    local h = RaidCD.config.db.notifHeight
    local w = RaidCD.config.db.notifWidth
    local frame = CreateFrame(
        "Frame",
        "RaidCD_Notif" .. tostring(index),
        parent
    )
    frame:SetSize(w, h)
    frame:EnableMouse(true)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(0, 0, 0, 0)
    local line = frame:CreateTexture(nil, "BORDER")
    line:SetHeight(1)
    line:SetPoint(
        "BOTTOMLEFT",
        frame,
        "BOTTOMLEFT",
        0,
        0
    )
    line:SetPoint(
        "BOTTOMRIGHT",
        frame,
        "BOTTOMRIGHT",
        0,
        0
    )
    line:SetColorTexture(0.3, 0.3, 0.3, 0.3)
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint(
        "LEFT",
        frame,
        "LEFT",
        2,
        0
    )
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(frame)
    highlight:SetColorTexture(1, 1, 1, 0.15)
    highlight:Hide()
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint(
        "LEFT",
        icon,
        "RIGHT",
        6,
        0
    )
    text:SetPoint(
        "RIGHT",
        frame,
        "RIGHT",
        -4,
        0
    )
    text:SetJustifyH("LEFT")
    text:SetTextColor(1, 1, 1, 0.95)
    local fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    text:SetFont(fontPath, RaidCD.config.db.notifFontSize, "OUTLINE")
    frame:Hide()
    return {
        frame = frame,
        icon = icon,
        text = text,
        bg = bg,
        highlight = highlight,
        requesterClass = "",
        spellClass = "",
        requesters = {},
        spellName = "",
        expireTime = 0,
        fadeAlpha = 0,
        fadingIn = false,
        fadingOut = false,
        resolved = false,
    }
end
UpdateNotificationText = function(notif)
    local count = #notif.requesters
    local baseText
    if notif.target then
        baseText = notif.target .. " needs " .. (notif.spellName or "?")
    elseif count <= 1 then
        baseText = ((notif.requesters[1] or "?") .. " requests ") .. (notif.spellName or "?")
    else
        baseText = (tostring(count) .. " players request ") .. (notif.spellName or "?")
    end
    notif.text:SetText(baseText)
end
RaidCD.ui = RaidCD.ui or ({})
RaidCD.ui.CreateNotification = CreateNotification
RaidCD.ui.UpdateNotificationText = UpdateNotificationText

