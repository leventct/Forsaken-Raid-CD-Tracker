-- RaidCooldownTracker — UI Settings: Buffs panel
local function StringTrim(s)
    return string.gsub(s, "^[%s]*(.-)[%s]*$", "%1")
end

local frame = CreateFrame("Frame", "RaidCD_BuffsPanel", UIParent)
frame.name = "Tracked Buffs"
frame.parent = "RaidCooldownTracker"

frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12
})
frame:SetBackdropColor(0.08, 0.08, 0.12, 0.98)
frame:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

local BUFF_GROUPS = {"Flask", "Food", "Potion", "Scroll", "Class Buffs"}
local GROUP_COLORS = {
    Flasks = {r=0.2,g=0.6,b=1.0},
    Scrolls = {r=0.9,g=0.8,b=0.4},
    Food = {r=0.9,g=0.5,b=0.2},
    Other = {r=0.6,g=0.6,b=0.6}
}
local ROW_H = 26
local PADDING = 16
local LIST_W = 400
local LIST_H = 280

-- Left panel
local leftW = 140
local leftPanel = CreateFrame("Frame", nil, frame)
leftPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", PADDING, -PADDING)
leftPanel:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PADDING, PADDING)
leftPanel:SetWidth(leftW)

-- Vertical separator
local sep = CreateFrame("Frame", nil, frame)
sep:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", 1, 0)
sep:SetPoint("BOTTOMLEFT", leftPanel, "BOTTOMRIGHT", 1, 0)
sep:SetWidth(2)
sep:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = nil,
    tile = false, tileSize = 0, edgeSize = 0
})
sep:SetBackdropColor(0.2, 0.2, 0.3, 0.8)

-- Right panel
local rightPanel = CreateFrame("Frame", nil, frame)
rightPanel:SetPoint("TOPLEFT", leftPanel, "TOPRIGHT", PADDING + 4, 0)
rightPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -PADDING, PADDING)

-- New Group section (TOP of left panel)
local addGroupLabel = leftPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
addGroupLabel:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 2, 0)
addGroupLabel:SetText("New Group:")

local addGroupInput = CreateFrame("EditBox", nil, frame)
addGroupInput:SetSize(80, 20)
addGroupInput:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 2, -20)
addGroupInput:SetAutoFocus(false)
addGroupInput:SetMaxLetters(20)
addGroupInput:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = nil,
    tile = false, tileSize = 0, edgeSize = 0
})
addGroupInput:SetBackdropColor(0.12, 0.12, 0.18, 1)
addGroupInput:SetBackdropBorderColor(0, 0, 0, 0)
addGroupInput:SetFont("Fonts\\FRIZQT__.TTF", 11)
addGroupInput:SetTextColor(1, 0.82, 0, 1)
addGroupInput:SetFrameStrata("HIGH")
addGroupInput:SetFrameLevel(frame:GetFrameLevel() + 10)

local addGroupBtn = CreateFrame("Button", nil, leftPanel, "UIPanelButtonTemplate")
addGroupBtn:SetSize(24, 20)
addGroupBtn:SetText("+")
addGroupBtn:SetPoint("LEFT", addGroupInput, "RIGHT", 2, 0)

-- All group buttons (built dynamically)
local allGroupButtons = {}
local allGroupItems = {}

-- Reorder buttons
local upBtn = CreateFrame("Button", nil, leftPanel, "UIPanelButtonTemplate")
upBtn:SetSize(24, 20)
upBtn:SetPoint("BOTTOMLEFT", leftPanel, "BOTTOMLEFT", 2, 0)
upBtn:SetText("▲")

local downBtn = CreateFrame("Button", nil, leftPanel, "UIPanelButtonTemplate")
downBtn:SetSize(24, 20)
downBtn:SetPoint("LEFT", upBtn, "RIGHT", 2, 0)
downBtn:SetText("▼")

local function GetEffectiveGroupOrder()
    local deletedPresets = RaidCD.config.db.buffDeletedPresets or {}
    local customGroups = RaidCD.config.db.buffCustomGroups or {}
    local validSet = {}
    for _, v in ipairs(BUFF_GROUPS) do
        if not deletedPresets[v] then validSet[v] = true end
    end
    for _, g in ipairs(customGroups) do validSet[g] = true end
    local savedOrder = RaidCD.config.db.buffGroupOrder
    if savedOrder and #savedOrder > 0 then
        local result = {}
        local seen = {}
        for _, name in ipairs(savedOrder) do
            if validSet[name] and not seen[name] then
                result[#result + 1] = name
                seen[name] = true
            end
        end
        for _, v in ipairs(BUFF_GROUPS) do
            if not deletedPresets[v] and not seen[v] then
                result[#result + 1] = v
                seen[v] = true
            end
        end
        for _, g in ipairs(customGroups) do
            if not seen[g] then
                result[#result + 1] = g
                seen[g] = true
            end
        end
        return result
    end
    local result = {}
    for _, v in ipairs(BUFF_GROUPS) do
        if not deletedPresets[v] then result[#result + 1] = v end
    end
    for _, g in ipairs(customGroups) do result[#result + 1] = g end
    return result
end

local SelectGroup, RebuildGroupButtons

local function MoveGroup(direction)
    if not frame.selectedGroup or frame.selectedGroup == "" then return end
    local order = GetEffectiveGroupOrder()
    local idx = nil
    for i, name in ipairs(order) do
        if name == frame.selectedGroup then idx = i; break end
    end
    if not idx then return end
    local targetIdx = idx + direction
    if targetIdx < 1 or targetIdx > #order then return end
    order[idx], order[targetIdx] = order[targetIdx], order[idx]
    RaidCD.config.db.buffGroupOrder = order
    RebuildGroupButtons()
    SelectGroup(frame.selectedGroup)
    RaidCD_OnSettingChanged()
end

upBtn:SetScript("OnClick", function() MoveGroup(-1) end)
downBtn:SetScript("OnClick", function() MoveGroup(1) end)

-- Right panel: Add Buff section
local addLabel = rightPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
addLabel:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 0, 0)
addLabel:SetText("Add Buff by Spell ID:")

local addInput = CreateFrame("EditBox", nil, frame)
addInput:SetSize(100, 20)
addInput:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 0, -20)
addInput:SetAutoFocus(false)
addInput:SetMaxLetters(7)
addInput:SetNumeric(true)
addInput:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = nil,
    tile = false, tileSize = 0, edgeSize = 0
})
addInput:SetBackdropColor(0.12, 0.12, 0.18, 1)
addInput:SetBackdropBorderColor(0, 0, 0, 0)
addInput:SetFont("Fonts\\FRIZQT__.TTF", 11)
addInput:SetTextColor(1, 0.82, 0, 1)
addInput:SetFrameStrata("HIGH")
addInput:SetFrameLevel(frame:GetFrameLevel() + 10)

local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetSize(60, 22)
addBtn:SetText("Add")
addBtn:SetPoint("LEFT", addInput, "RIGHT", 4, 0)
addBtn:SetPoint("TOP", addInput, "TOP", 0, 0)
addBtn:SetFrameStrata("HIGH")
addBtn:SetFrameLevel(frame:GetFrameLevel() + 10)

-- Buff list container
local listTopY = -70
local listFrame = CreateFrame("Frame", nil, rightPanel)
listFrame:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 0, listTopY)
listFrame:SetSize(LIST_W, LIST_H)

-- Table header
local headerH = 24
local header = CreateFrame("Frame", nil, listFrame)
header:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 4, -4)
header:SetPoint("TOPRIGHT", listFrame, "TOPRIGHT", -4, -4)
header:SetHeight(headerH)

local headerBg = header:CreateTexture(nil, "BACKGROUND")
headerBg:SetAllPoints()
headerBg:SetColorTexture(0.1, 0.1, 0.2, 0.9)

local colIcon = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colIcon:SetPoint("LEFT", header, "LEFT", 4, 0)
colIcon:SetText("Icon")
colIcon:SetTextColor(0.55, 0.55, 0.7, 1)

local colName = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colName:SetPoint("LEFT", colIcon, "RIGHT", 8, 0)
colName:SetText("Buff Name")
colName:SetTextColor(0.55, 0.55, 0.7, 1)

local colId = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colId:SetPoint("LEFT", colName, "RIGHT", 8, 0)
colId:SetText("ID")
colId:SetTextColor(0.55, 0.55, 0.7, 1)

local colActive = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colActive:SetPoint("RIGHT", header, "RIGHT", -76, 0)
colActive:SetText("Active")
colActive:SetTextColor(0.55, 0.55, 0.7, 1)

local colRemove = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colRemove:SetPoint("RIGHT", header, "RIGHT", -4, 0)
colRemove:SetText("Action")
colRemove:SetTextColor(0.55, 0.55, 0.7, 1)

-- Buff rows scrollable container
local buffScrollFrame = CreateFrame("ScrollFrame", "RaidCD_BuffScrollFrame", listFrame, "UIPanelScrollFrameTemplate")
buffScrollFrame:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
buffScrollFrame:SetPoint("BOTTOMRIGHT", listFrame, "BOTTOMRIGHT", 0, 4)

local buffRowsParent = CreateFrame("Frame", nil, buffScrollFrame)
buffScrollFrame:SetScrollChild(buffRowsParent)
buffRowsParent:SetWidth(LIST_W - 20)

-- Custom group management (below list)
local mgmtFrame = CreateFrame("Frame", nil, rightPanel)
mgmtFrame:SetPoint("TOPLEFT", listFrame, "BOTTOMLEFT", 0, -8)
mgmtFrame:SetPoint("TOPRIGHT", listFrame, "BOTTOMRIGHT", 0, -8)
mgmtFrame:SetHeight(30)

local renameInput = CreateFrame("EditBox", nil, frame)
renameInput:SetSize(120, 20)
renameInput:SetAutoFocus(false)
renameInput:SetMaxLetters(20)
renameInput:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = nil,
    tile = false, tileSize = 0, edgeSize = 0
})
renameInput:SetBackdropColor(0.12, 0.12, 0.18, 1)
renameInput:SetBackdropBorderColor(0, 0, 0, 0)
renameInput:SetFont("Fonts\\FRIZQT__.TTF", 11)
renameInput:SetTextColor(1, 0.82, 0, 1)
renameInput:SetFrameStrata("HIGH")
renameInput:SetFrameLevel(frame:GetFrameLevel() + 10)
renameInput:Hide()

local confirmBtn = CreateFrame("Button", nil, mgmtFrame, "UIPanelButtonTemplate")
confirmBtn:SetSize(40, 20)
confirmBtn:SetText("OK")
confirmBtn:Hide()

local deleteBtn = CreateFrame("Button", nil, mgmtFrame, "UIPanelButtonTemplate")
deleteBtn:SetSize(80, 20)
deleteBtn:SetText("Delete Group")
deleteBtn:SetPoint("LEFT", confirmBtn, "RIGHT", 4, 0)

-- State
frame.selectedGroup = BUFF_GROUPS[1]
local buffRowItems = {}
local groupMgmtItems = {}

-- Functions
local IsPresetGroup, RebuildBuffList, DoAddBuff, DoAddGroup, RebuildGroupManagement, UpdateShowInactiveCheck

IsPresetGroup = function(name)
    for _, v in ipairs(BUFF_GROUPS) do
        if v == name then return true end
    end
    return false
end

SelectGroup = function(group)
    frame.selectedGroup = group
    for _, entry in ipairs(allGroupButtons) do
        if entry.name == group then
            entry.button:LockHighlight()
        else
            entry.button:UnlockHighlight()
        end
    end
    RebuildBuffList()
    RebuildGroupManagement()
    UpdateShowInactiveCheck()
end

DoAddGroup = function()
    local name = StringTrim(addGroupInput:GetText() or "")
    if #name == 0 then return end
    local nameUpper = string.upper(name)
    local deletedPresets = RaidCD.config.db.buffDeletedPresets or {}
    for _, v in ipairs(BUFF_GROUPS) do
        if string.upper(v) == nameUpper and not deletedPresets[v] then return end
    end
    local customGroups = RaidCD.config.db.buffCustomGroups or {}
    for _, g in ipairs(customGroups) do
        if string.upper(g) == nameUpper then return end
    end
    local isDeletedPreset = false
    for _, v in ipairs(BUFF_GROUPS) do
        if string.upper(v) == nameUpper and deletedPresets[v] then
            isDeletedPreset = true
            deletedPresets[v] = nil
            name = v
            break
        end
    end
    if not isDeletedPreset then
        table.insert(customGroups, name)
        RaidCD.config.db.buffCustomGroups = customGroups
    end
    RaidCD.config.db.trackedBuffs[name] = {}
    RaidCD.config.db.buffDeletedPresets = deletedPresets
    addGroupInput:SetText("")
    RebuildGroupButtons()
    SelectGroup(name)
    RaidCD_OnSettingChanged()
end

addGroupInput:SetScript("OnEnterPressed", function()
    DoAddGroup()
    addGroupInput:ClearFocus()
end)
addGroupBtn:SetScript("OnClick", DoAddGroup)

DoAddBuff = function()
    local text = addInput:GetText() or ""
    local spellId = tonumber(text)
    if spellId ~= nil and spellId > 0 then
        if RaidCD.config.db.trackedBuffs[frame.selectedGroup] == nil then
            RaidCD.config.db.trackedBuffs[frame.selectedGroup] = {}
        end
        local groupBuffs = RaidCD.config.db.trackedBuffs[frame.selectedGroup]
        local exists = false
        for _, id in ipairs(groupBuffs) do
            if id == spellId then exists = true; break end
        end
        if not exists then
            table.insert(RaidCD.config.db.trackedBuffs[frame.selectedGroup], spellId)
            RebuildBuffList()
            RaidCD_OnSettingChanged()
        end
    end
    addInput:SetText("")
end

addInput:SetScript("OnEnterPressed", function()
    DoAddBuff()
    addInput:ClearFocus()
end)
addBtn:SetScript("OnClick", DoAddBuff)

-- Show Inactive checkbox
local showInactiveCheck = CreateFrame("CheckButton", nil, rightPanel, "UICheckButtonTemplate")
showInactiveCheck:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT", -10, -4)
showInactiveCheck:SetHitRectInsets(0, -80, 0, 0)
local showInactiveLabel = rightPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
showInactiveLabel:SetPoint("RIGHT", showInactiveCheck, "LEFT", -2, 1)
showInactiveLabel:SetText("Show Inactive")

UpdateShowInactiveCheck = function()
    if not RaidCD.config.db.buffShowInactive then RaidCD.config.db.buffShowInactive = {} end
    showInactiveCheck:SetChecked(RaidCD.config.db.buffShowInactive[frame.selectedGroup] and true or false)
end

showInactiveCheck:SetScript("OnClick", function()
    if not RaidCD.config.db.buffShowInactive then RaidCD.config.db.buffShowInactive = {} end
    RaidCD.config.db.buffShowInactive[frame.selectedGroup] = showInactiveCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

RebuildGroupManagement = function()
    for _, w in ipairs(groupMgmtItems) do
        w:Hide()
    end
    groupMgmtItems = {}
    renameInput:Hide()
    confirmBtn:Hide()

    if not frame.selectedGroup or frame.selectedGroup == "" then
        mgmtFrame:Hide()
        return
    end
    mgmtFrame:Show()

    local renameBtn = CreateFrame("Button", nil, mgmtFrame, "UIPanelButtonTemplate")
    renameBtn:SetSize(70, 22)
    renameBtn:SetPoint("LEFT", mgmtFrame, "LEFT", 0, 0)
    renameBtn:SetText("Rename")
    groupMgmtItems[#groupMgmtItems + 1] = renameBtn

    renameInput:SetSize(120, 20)
    renameInput:SetPoint("LEFT", renameBtn, "RIGHT", 4, 0)
    renameInput:SetText(frame.selectedGroup)
    renameInput:Show()
    groupMgmtItems[#groupMgmtItems + 1] = renameInput

    confirmBtn:SetPoint("LEFT", renameInput, "RIGHT", 4, 0)
    confirmBtn:Show()
    groupMgmtItems[#groupMgmtItems + 1] = confirmBtn

    deleteBtn:SetPoint("LEFT", confirmBtn, "RIGHT", 4, 0)
    deleteBtn:Show()
    groupMgmtItems[#groupMgmtItems + 1] = deleteBtn

    renameBtn:SetScript("OnClick", function()
        renameInput:Show()
        confirmBtn:Show()
        renameInput:SetFocus()
    end)

    local function DoRename()
        local newName = StringTrim(renameInput:GetText() or "")
        if #newName == 0 or newName == frame.selectedGroup then
            renameInput:Hide()
            confirmBtn:Hide()
            return
        end
        local nameUpper = string.upper(newName)
        local deletedPresets = RaidCD.config.db.buffDeletedPresets or {}
        for _, v in ipairs(BUFF_GROUPS) do
            if string.upper(v) == nameUpper and not deletedPresets[v] then return end
        end
        local customGroups = RaidCD.config.db.buffCustomGroups or {}
        for _, g in ipairs(customGroups) do
            if string.upper(g) == nameUpper then return end
        end
        if IsPresetGroup(frame.selectedGroup) then
            if not RaidCD.config.db.buffDeletedPresets then RaidCD.config.db.buffDeletedPresets = {} end
            RaidCD.config.db.buffDeletedPresets[frame.selectedGroup] = true
            table.insert(customGroups, newName)
            RaidCD.config.db.buffCustomGroups = customGroups
        else
            for i, g in ipairs(customGroups) do
                if g == frame.selectedGroup then
                    customGroups[i] = newName
                    break
                end
            end
        end
        local buffs = RaidCD.config.db.trackedBuffs[frame.selectedGroup]
        RaidCD.config.db.trackedBuffs[frame.selectedGroup] = nil
        RaidCD.config.db.trackedBuffs[newName] = buffs
        if RaidCD.config.db.buffGroupOrder then
            for i, name in ipairs(RaidCD.config.db.buffGroupOrder) do
                if name == frame.selectedGroup then
                    RaidCD.config.db.buffGroupOrder[i] = newName
                    break
                end
            end
        end
        frame.selectedGroup = newName
        renameInput:Hide()
        confirmBtn:Hide()
        RebuildGroupButtons()
        RebuildGroupManagement()
        RaidCD_OnSettingChanged()
    end

    renameInput:SetScript("OnEnterPressed", function()
        DoRename()
        renameInput:ClearFocus()
    end)
    confirmBtn:SetScript("OnClick", DoRename)

    deleteBtn:SetScript("OnClick", function()
        if IsPresetGroup(frame.selectedGroup) then
            if not RaidCD.config.db.buffDeletedPresets then RaidCD.config.db.buffDeletedPresets = {} end
            RaidCD.config.db.buffDeletedPresets[frame.selectedGroup] = true
        else
            local customGroups = RaidCD.config.db.buffCustomGroups or {}
            for i, g in ipairs(customGroups) do
                if g == frame.selectedGroup then
                    table.remove(customGroups, i)
                    break
                end
            end
            RaidCD.config.db.buffCustomGroups = customGroups
        end
        RaidCD.config.db.trackedBuffs[frame.selectedGroup] = nil
        local deletedPresets = RaidCD.config.db.buffDeletedPresets or {}
        frame.selectedGroup = nil
        for _, v in ipairs(BUFF_GROUPS) do
            if not deletedPresets[v] then frame.selectedGroup = v; break end
        end
        if not frame.selectedGroup then
            local customGroups = RaidCD.config.db.buffCustomGroups or {}
            if #customGroups > 0 then
                frame.selectedGroup = customGroups[1]
            else
                frame.selectedGroup = ""
            end
        end
        RebuildGroupButtons()
        if frame.selectedGroup ~= "" then
            SelectGroup(frame.selectedGroup)
        end
        RaidCD_OnSettingChanged()
    end)
end

RebuildBuffList = function()
    for _, w in ipairs(buffRowItems) do
        w:Hide()
    end
    buffRowItems = {}

    local groupBuffs = RaidCD.config.db.trackedBuffs[frame.selectedGroup] or {}
    local buffCount = #groupBuffs

    if buffCount == 0 then
        local empty = buffRowsParent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        empty:SetPoint("CENTER", buffRowsParent, "CENTER", 0, 0)
        empty:SetJustifyH("CENTER")
        empty:SetText("No buffs tracked for this group.\nEnter a Spell ID above and click Add.")
        empty:SetTextColor(0.4, 0.4, 0.5, 1)
        buffRowItems[#buffRowItems + 1] = empty
        return
    end

    local headerOffset = headerH + 1
    local contentH = buffCount * ROW_H
    buffRowsParent:SetHeight(math.max(headerOffset + contentH, LIST_H - 8))

    for idx, spellId in ipairs(groupBuffs) do
        local y = -(headerOffset + (idx - 1) * ROW_H)
        local isEven = (idx % 2) == 0

        local bg = buffRowsParent:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", buffRowsParent, "TOPLEFT", 0, y)
        bg:SetPoint("BOTTOMRIGHT", buffRowsParent, "TOPRIGHT", 0, y + ROW_H)
        if isEven then
            bg:SetColorTexture(0.08, 0.08, 0.14, 0.8)
        else
            bg:SetColorTexture(0.04, 0.04, 0.08, 0.6)
        end
        buffRowItems[#buffRowItems + 1] = bg

        local sName, _, sIcon = GetSpellInfo(spellId)
        local buffName = sName or "Spell #" .. spellId
        local iconSz = 20

        local icon = buffRowsParent:CreateTexture(nil, "ARTWORK")
        icon:SetSize(iconSz, iconSz)
        icon:SetPoint("LEFT", buffRowsParent, "LEFT", 6, 0)
        icon:SetPoint("TOP", buffRowsParent, "TOP", 0, y - (ROW_H - iconSz) / 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetTexture(sIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        buffRowItems[#buffRowItems + 1] = icon

        local nameText = buffRowsParent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        nameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        nameText:SetPoint("RIGHT", buffRowsParent, "RIGHT", -208, 0)
        nameText:SetPoint("TOP", buffRowsParent, "TOP", 0, y - (ROW_H - 14) / 2 + 2)
        nameText:SetJustifyH("LEFT")
        nameText:SetText(buffName)
        buffRowItems[#buffRowItems + 1] = nameText

        local idText = buffRowsParent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        idText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        idText:SetPoint("RIGHT", buffRowsParent, "RIGHT", -208, 0)
        idText:SetPoint("TOP", nameText, "BOTTOM", 0, -2)
        idText:SetJustifyH("LEFT")
        idText:SetTextColor(0.35, 0.35, 0.4, 1)
        idText:SetText(tostring(spellId))
        buffRowItems[#buffRowItems + 1] = idText

        -- Remove button
        local remBtn = CreateFrame("Button", nil, buffRowsParent, "UIPanelButtonTemplate")
        remBtn:SetSize(60, 18)
        remBtn:SetPoint("RIGHT", buffRowsParent, "RIGHT", -6, 0)
        remBtn:SetPoint("TOP", buffRowsParent, "TOP", 0, y - (ROW_H - 18) / 2)
        remBtn:SetText("Remove")
        remBtn:SetNormalFontObject("GameFontHighlightSmall")
        remBtn:SetHighlightFontObject("GameFontHighlightSmall")
        local capturedId = spellId
        remBtn:SetScript("OnClick", function()
            local buffs = RaidCD.config.db.trackedBuffs[frame.selectedGroup] or {}
            for j, id in ipairs(buffs) do
                if id == capturedId then
                    table.remove(RaidCD.config.db.trackedBuffs[frame.selectedGroup], j)
                    break
                end
            end
            if RaidCD.config.db.buffScopes then
                RaidCD.config.db.buffScopes[capturedId] = nil
            end
            if RaidCD.config.db.buffActive then
                RaidCD.config.db.buffActive[capturedId] = nil
            end
            RebuildBuffList()
            RaidCD_OnSettingChanged()
        end)
        buffRowItems[#buffRowItems + 1] = remBtn

        -- Active toggle button
        local activeBtn = CreateFrame("Button", nil, buffRowsParent, "UIPanelButtonTemplate")
        activeBtn:SetSize(56, 18)
        activeBtn:SetPoint("RIGHT", remBtn, "LEFT", -4, 0)
        activeBtn:SetPoint("TOP", buffRowsParent, "TOP", 0, y - (ROW_H - 18) / 2)
        activeBtn:SetNormalFontObject("GameFontHighlightSmall")
        activeBtn:SetHighlightFontObject("GameFontHighlightSmall")
        local capturedSpellId = spellId
        local function UpdateActiveBtnText()
            local active = RaidCD.config.db.buffActive and RaidCD.config.db.buffActive[capturedSpellId]
            if active == false then
                activeBtn:SetText("Inactive")
                activeBtn:SetNormalFontObject("GameFontDisableSmall")
                activeBtn:SetHighlightFontObject("GameFontDisableSmall")
            else
                activeBtn:SetText("Active")
                activeBtn:SetNormalFontObject("GameFontHighlightSmall")
                activeBtn:SetHighlightFontObject("GameFontHighlightSmall")
            end
        end
        UpdateActiveBtnText()
        activeBtn:SetScript("OnClick", function()
            if not RaidCD.config.db.buffActive then
                RaidCD.config.db.buffActive = {}
            end
            local current = RaidCD.config.db.buffActive[capturedSpellId]
            if current == false then
                RaidCD.config.db.buffActive[capturedSpellId] = true
            else
                RaidCD.config.db.buffActive[capturedSpellId] = false
            end
            UpdateActiveBtnText()
            RaidCD_OnSettingChanged()
        end)
        buffRowItems[#buffRowItems + 1] = activeBtn
    end
end

RebuildGroupButtons = function()
    for _, w in ipairs(allGroupItems) do
        w:Hide()
    end
    allGroupItems = {}
    allGroupButtons = {}
    local order = GetEffectiveGroupOrder()
    for idx, grp in ipairs(order) do
        local btn = CreateFrame("Button", "RaidCD_GrpBtn" .. idx, leftPanel, "OptionsListButtonTemplate")
        btn:SetSize(leftW - 4, ROW_H)
        btn:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 2, -(20 + 30 + (idx - 1) * ROW_H))
        btn:SetText(grp)
        btn:SetScript("OnClick", function() SelectGroup(grp) end)
        allGroupItems[#allGroupItems + 1] = btn
        allGroupButtons[#allGroupButtons + 1] = { name = grp, button = btn }
    end
end

RebuildGroupButtons()
InterfaceOptions_AddCategory(frame)
SelectGroup(frame.selectedGroup)

-- Restore group buttons after config loads
frame:SetScript("OnShow", function()
    RebuildGroupButtons()
    if not frame.selectedGroup or frame.selectedGroup == "" then
        local deletedPresets = RaidCD.config.db.buffDeletedPresets or {}
        for _, v in ipairs(BUFF_GROUPS) do
            if not deletedPresets[v] then frame.selectedGroup = v; break end
        end
    end
    SelectGroup(frame.selectedGroup)
end)
