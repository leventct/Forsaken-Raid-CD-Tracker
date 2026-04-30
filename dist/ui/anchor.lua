anchorFrame = CreateFrame("Frame", "RaidCD_Anchor", UIParent)
anchorFrame:SetSize(32, 32)
anchorFrame:SetFrameStrata("LOW")
anchorFrame:SetPoint(
    "CENTER",
    UIParent,
    "CENTER",
    0,
    0
)
anchorFrame:SetClampedToScreen(true)
anchorFrame:SetMovable(true)
anchorFrame:EnableMouse(true)
anchorFrame:RegisterForDrag("LeftButton")
anchorBorder = anchorFrame:CreateTexture(nil, "BACKGROUND")
anchorBorder:SetPoint(
    "TOPLEFT",
    anchorFrame,
    "TOPLEFT",
    -1,
    1
)
anchorBorder:SetPoint(
    "BOTTOMRIGHT",
    anchorFrame,
    "BOTTOMRIGHT",
    1,
    -1
)
anchorBorder:Hide()
anchorFill = anchorFrame:CreateTexture(nil, "ARTWORK")
anchorFill:SetAllPoints(anchorFrame)
anchorFill:SetColorTexture(0, 0, 0, 0)
anchorDot = anchorFrame:CreateTexture(nil, "OVERLAY")
anchorDot:SetSize(32, 32)
anchorDot:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
anchorDot:SetTexture("Interface\\ICONS\\ability_bossashvane_icon01")
anchorFrame:SetScript(
    "OnEnter",
    function()
        if not RaidCD.config.db.locked then
            GameTooltip_SetDefaultAnchor(GameTooltip, anchorFrame)
            GameTooltip:AddLine("Drag to move")
            GameTooltip:AddLine("|cFF888888Right-click for settings|r")
            GameTooltip:Show()
        end
    end
)
anchorFrame:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)
anchorFrame:SetScript(
    "OnDragStart",
    function(frame)
        if not RaidCD.config.db.locked then
            frame:StartMoving()
        end
    end
)
anchorFrame:SetScript(
    "OnDragStop",
    function(frame)
        frame:StopMovingOrSizing()
        local point = select(
            1,
            frame:GetPoint()
        ) or "CENTER"
        local x = select(
            4,
            frame:GetPoint()
        ) or 0
        local y = select(
            5,
            frame:GetPoint()
        ) or 0
        RaidCD.config.db.position = {point = point, x = x, y = y}
    end
)
anchorFrame:SetScript(
    "OnMouseUp",
    function(frame, button)
        if button == "RightButton" then
            InterfaceOptionsFrame_OpenToCategory("RaidCooldownTracker")
        end
    end
)
UpdateAnchorVisual = function()
    if RaidCD.config.db.serverMode == true then
        anchorBorder:Hide()
        anchorFill:Hide()
        anchorDot:Hide()
        anchorFrame:Hide()
        anchorFrame:EnableMouse(false)
        return
    end
    if RaidCD.config.db.locked then
        anchorBorder:Hide()
        anchorFill:Hide()
        anchorDot:Hide()
        anchorFrame:Show()
        anchorFrame:EnableMouse(false)
    else
        anchorBorder:Hide()
        anchorFill:Hide()
        anchorDot:Show()
        anchorFrame:Show()
        anchorFrame:EnableMouse(true)
    end
end
RestorePosition = function()
    local pos = RaidCD.config.db.position
    if pos ~= nil then
        anchorFrame:ClearAllPoints()
        anchorFrame:SetPoint(
            pos.point,
            UIParent,
            pos.point,
            pos.x,
            pos.y
        )
    end
end
RaidCD.ui = RaidCD.ui or ({})
RaidCD.ui.anchor = anchorFrame
RaidCD.ui.RestorePosition = RestorePosition
RaidCD.ui.UpdateAnchorVisual = UpdateAnchorVisual
RaidCD.ui.UpdateAllAnchors = function()
    UpdateAnchorVisual()
    if RaidCD.ui.notifManager and RaidCD.ui.notifManager.UpdateAnchorVisual then
        RaidCD.ui.notifManager.UpdateAnchorVisual()
    end
    for groupName, data in pairs(RaidCD.config.db.independentAnchors or {}) do
        local anchor = RaidCD.ui.independentAnchors and RaidCD.ui.independentAnchors[groupName]
        if anchor and anchor.UpdateVisual then
            anchor:UpdateVisual()
        end
    end
end

CreateGroupAnchor = function(groupName)
    local anchorName = "RaidCD_Anchor_" .. groupName
    local anchorFrame = CreateFrame("Frame", anchorName, UIParent)
    anchorFrame:SetSize(32, 32)
    anchorFrame:SetFrameStrata("LOW")
    anchorFrame:SetClampedToScreen(true)
    anchorFrame:SetMovable(true)
    anchorFrame:EnableMouse(true)
    anchorFrame:RegisterForDrag("LeftButton")

    local border = anchorFrame:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 1, -1)
    border:Hide()

    local fill = anchorFrame:CreateTexture(nil, "ARTWORK")
    fill:SetAllPoints(anchorFrame)
    fill:SetColorTexture(0, 0, 0, 0)

    local dot = anchorFrame:CreateTexture(nil, "OVERLAY")
    dot:SetSize(32, 32)
    dot:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
    dot:SetTexture("Interface\\ICONS\\ability_bossashvane_icon01")

    local label = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOM", anchorFrame, "TOP", 0, 2)
    label:SetText(groupName)
    label:SetTextColor(0.6, 0.6, 0.8, 0.9)
    label:Hide()

    anchorFrame:SetScript("OnEnter", function()
        if not RaidCD.config.db.locked then
            GameTooltip_SetDefaultAnchor(GameTooltip, anchorFrame)
            GameTooltip:AddLine("Drag to move " .. groupName)
            GameTooltip:AddLine("|cFF888888Right-click for settings|r")
            GameTooltip:Show()
        end
    end)
    anchorFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    anchorFrame:SetScript("OnDragStart", function(frame)
        if not RaidCD.config.db.locked then
            frame:StartMoving()
        end
    end)
    anchorFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        local point, _, relPoint, x, y = frame:GetPoint(1)
        RaidCD.config.db.independentAnchors[groupName] = {point = point, x = x, y = y}
    end)
    anchorFrame:SetScript("OnMouseUp", function(frame, button)
        if button == "RightButton" then
            InterfaceOptionsFrame_OpenToCategory("RaidCooldownTracker")
        end
    end)

    local function RestorePosition()
        local pos = RaidCD.config.db.independentAnchors and RaidCD.config.db.independentAnchors[groupName]
        if pos then
            anchorFrame:ClearAllPoints()
            anchorFrame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
        else
            anchorFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
    end

    local function UpdateVisual()
        if RaidCD.config.db.serverMode then
            border:Hide()
            fill:Hide()
            dot:Hide()
            label:Hide()
            anchorFrame:Hide()
            anchorFrame:EnableMouse(false)
            return
        end
        if RaidCD.config.db.locked then
            border:Hide()
            fill:Hide()
            dot:Hide()
            label:Hide()
            anchorFrame:Hide()
            anchorFrame:EnableMouse(false)
        else
            border:Hide()
            fill:Hide()
            dot:Show()
            label:Show()
            anchorFrame:Show()
            anchorFrame:EnableMouse(true)
        end
    end

    RestorePosition()
    UpdateVisual()

    local anchorObj = {
        frame = anchorFrame,
        border = border,
        fill = fill,
        dot = dot,
        label = label,
        RestorePosition = RestorePosition,
        UpdateVisual = UpdateVisual,
        groupName = groupName
    }
    RaidCD.ui.independentAnchors[groupName] = anchorObj
    return anchorObj
end
RaidCD.ui.CreateGroupAnchor = CreateGroupAnchor
RaidCD.ui.independentAnchors = RaidCD.ui.independentAnchors or {}
RaidCD.ui.Init = function()
    RestorePosition()
    UpdateAnchorVisual()
    if RaidCD.ui.barManager then
        RaidCD.ui.barManager:Init()
    end
    if RaidCD.ui.notifManager then
        RaidCD.ui.notifManager:Init()
    end
end
RaidCD.ui.Refresh = function()
    UpdateAnchorVisual()
    if RaidCD.ui.barManager then
        RaidCD.ui.barManager:Refresh()
    end
    if RaidCD.ui.notifManager then
        if RaidCD.ui.notifManager.UpdateAnchorVisual then
            RaidCD.ui.notifManager:UpdateAnchorVisual()
        end
        if RaidCD.ui.notifManager.UpdateLabelFont then
            RaidCD.ui.notifManager:UpdateLabelFont()
        end
    end
end
