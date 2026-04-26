-- RaidCooldownTracker — UI Settings: Tracked Spells panel
local function StringTrim(s)
    return string.gsub(s, "^[%s]*(.-)[%s]*$", "%1")
end

local frame = CreateFrame("Frame", "RaidCD_SpellsPanel", UIParent)
frame.name = "Tracked Spells"
frame.parent = "RaidCooldownTracker"

-- Make the panel have a solid dark background
frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12
})
frame:SetBackdropColor(0.08, 0.08, 0.12, 0.98)
frame:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

local WOTLK_CLASSES = {
    "DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN",
    "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"
}
local CLASS_LABELS = {
    DEATHKNIGHT = "Death Knight", DRUID = "Druid", HUNTER = "Hunter",
    MAGE = "Mage", PALADIN = "Paladin", PRIEST = "Priest",
    ROGUE = "Rogue", SHAMAN = "Shaman", WARLOCK = "Warlock", WARRIOR = "Warrior"
}
local CLASS_COLORS = {
    DEATHKNIGHT = {r=0.77,g=0.12,b=0.23},
    DRUID = {r=1,g=0.49,b=0.04},
    HUNTER = {r=0.67,g=0.83,b=0.45},
    MAGE = {r=0.41,g=0.8,b=0.94},
    PALADIN = {r=0.96,g=0.55,b=0.73},
    PRIEST = {r=1,g=1,b=1},
    ROGUE = {r=1,g=0.96,b=0.41},
    SHAMAN = {r=0,g=0.44,b=0.87},
    WARLOCK = {r=0.58,g=0.51,b=0.79},
    WARRIOR = {r=0.78,g=0.61,b=0.43}
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

-- Vertical separator (thin 2px line, no border to avoid overlap)
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

-- Class buttons (below New Group, with extra spacing)
local classButtons = {}
for i, cls in ipairs(WOTLK_CLASSES) do
    local btn = CreateFrame("Button", "RaidCD_ClassBtn" .. i, leftPanel, "OptionsListButtonTemplate")
    btn:SetSize(leftW - 4, ROW_H)
    btn:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 2, -(20 + 30 + (i - 1) * ROW_H))
    btn:SetText(CLASS_LABELS[cls])
    classButtons[i] = btn
end

-- Custom group buttons (below classes, appended to classButtons table)
local customGroupButtons = {}
local customGroupItems = {}

-- Track how many total left-panel buttons exist for positioning reference
local totalLeftButtons = #WOTLK_CLASSES

-- Right panel: Add Spell section
local addLabel = rightPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
addLabel:SetPoint("TOPLEFT", rightPanel, "TOPLEFT", 0, 0)
addLabel:SetText("Add Spell by ID:")

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

-- Toggle: Global Anchor / Own Anchor
local anchorToggle = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
anchorToggle:SetSize(90, 22)
anchorToggle:SetPoint("LEFT", addBtn, "RIGHT", 8, 0)
anchorToggle:SetPoint("TOP", addBtn, "TOP", 0, 0)
anchorToggle:SetFrameStrata("HIGH")
anchorToggle:SetFrameLevel(frame:GetFrameLevel() + 10)

local function UpdateAnchorToggleText()
    if not frame.selectedGroup or frame.selectedGroup == "" then
        anchorToggle:SetText("Global Anchor")
        anchorToggle:SetNormalFontObject("GameFontNormalSmall")
        anchorToggle:SetHighlightFontObject("GameFontNormalSmall")
        return
    end
    local isIndependent = RaidCD.config.db.independentAnchors and RaidCD.config.db.independentAnchors[frame.selectedGroup] ~= nil and RaidCD.config.db.independentAnchors[frame.selectedGroup] ~= false
    if isIndependent then
        anchorToggle:SetText("Own Anchor")
        anchorToggle:SetNormalFontObject("GameFontHighlightSmall")
        anchorToggle:SetHighlightFontObject("GameFontHighlightSmall")
    else
        anchorToggle:SetText("Global Anchor")
        anchorToggle:SetNormalFontObject("GameFontNormalSmall")
        anchorToggle:SetHighlightFontObject("GameFontNormalSmall")
    end
end

anchorToggle:SetScript("OnClick", function()
    if not frame.selectedGroup or frame.selectedGroup == "" then
        return
    end
    if not RaidCD.config.db.independentAnchors then
        RaidCD.config.db.independentAnchors = {}
    end
    local current = RaidCD.config.db.independentAnchors[frame.selectedGroup]
    if current and current ~= false then
        RaidCD.config.db.independentAnchors[frame.selectedGroup] = nil
        if RaidCD.ui and RaidCD.ui.barManager then
            local mgr = RaidCD.ui.barManager
            if mgr.DestroyIndependentManager then
                mgr:DestroyIndependentManager(frame.selectedGroup)
            end
        end
    else
        RaidCD.config.db.independentAnchors[frame.selectedGroup] = {point = "CENTER", x = 0, y = 0}
    end
    UpdateAnchorToggleText()
    RaidCD_OnSettingChanged()
    if RaidCD.ui and RaidCD.ui.Refresh then
        RaidCD.ui.Refresh()
    end
end)

-- Spell list container
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
colName:SetText("Spell Name")
colName:SetTextColor(0.55, 0.55, 0.7, 1)

local colId = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colId:SetPoint("LEFT", colName, "RIGHT", 8, 0)
colId:SetText("ID")
colId:SetTextColor(0.55, 0.55, 0.7, 1)

local colScope = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colScope:SetPoint("RIGHT", header, "RIGHT", -136, 0)
colScope:SetText("Scope")
colScope:SetTextColor(0.55, 0.55, 0.7, 1)

local colActive = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colActive:SetPoint("RIGHT", header, "RIGHT", -76, 0)
colActive:SetText("Active")
colActive:SetTextColor(0.55, 0.55, 0.7, 1)

local colRemove = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
colRemove:SetPoint("RIGHT", header, "RIGHT", -4, 0)
colRemove:SetText("Action")
colRemove:SetTextColor(0.55, 0.55, 0.7, 1)

-- Spell rows container (grows downward)
local spellRowsParent = CreateFrame("Frame", nil, listFrame)
spellRowsParent:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
spellRowsParent:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -1)
spellRowsParent:SetHeight(LIST_H - headerH - 8)

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
frame.selectedGroup = WOTLK_CLASSES[1]
local spellRowItems = {}
local groupMgmtItems = {}

-- ── Functions ──────────────────────────────────────────────
local IsClassGroup, SelectGroup, RebuildSpellList, RebuildCustomGroups, DoAddSpell, DoAddGroup, RebuildGroupManagement, PositionCustomGroupControls

IsClassGroup = function(name)
    for _, v in ipairs(WOTLK_CLASSES) do
        if v == name then return true end
    end
    return false
end

SelectGroup = function(group)
    frame.selectedGroup = group
    for i, cls in ipairs(WOTLK_CLASSES) do
        if cls == group then
            classButtons[i]:LockHighlight()
        else
            classButtons[i]:UnlockHighlight()
        end
    end
    for i, btn in ipairs(customGroupButtons) do
        if customGroupButtons[i] and btn then
            local g = RaidCD.config.db.customGroups[i]
            if g == group then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
    end
    RebuildSpellList()
    RebuildGroupManagement()
    if anchorToggle then
        UpdateAnchorToggleText()
    end
end

for i, cls in ipairs(WOTLK_CLASSES) do
    classButtons[i]:SetScript("OnClick", function() SelectGroup(cls) end)
end

DoAddGroup = function()
    local name = StringTrim(addGroupInput:GetText() or "")
    if #name == 0 then return end
    local nameUpper = string.upper(name)
    for _, v in ipairs(WOTLK_CLASSES) do
        if v == nameUpper then return end
    end
    local customGroups = RaidCD.config.db.customGroups or {}
    for _, g in ipairs(customGroups) do
        if string.upper(g) == nameUpper then return end
    end
    table.insert(customGroups, name)
    RaidCD.config.db.customGroups = customGroups
    RaidCD.config.db.trackedSpells[name] = {}
    addGroupInput:SetText("")
    RebuildCustomGroups()
    SelectGroup(name)
    RaidCD_OnSettingChanged()
end

addGroupInput:SetScript("OnEnterPressed", function()
    DoAddGroup()
    addGroupInput:ClearFocus()
end)
addGroupBtn:SetScript("OnClick", DoAddGroup)

DoAddSpell = function()
    local text = addInput:GetText() or ""
    local spellId = tonumber(text)
    if spellId ~= nil and spellId > 0 then
        if RaidCD.config.db.trackedSpells[frame.selectedGroup] == nil then
            RaidCD.config.db.trackedSpells[frame.selectedGroup] = {}
        end
        local groupSpells = RaidCD.config.db.trackedSpells[frame.selectedGroup]
        local exists = false
        for _, id in ipairs(groupSpells) do
            if id == spellId then exists = true; break end
        end
        if not exists then
            table.insert(RaidCD.config.db.trackedSpells[frame.selectedGroup], spellId)
            RebuildSpellList()
            RaidCD_OnSettingChanged()
        end
    end
    addInput:SetText("")
end

addInput:SetScript("OnEnterPressed", function()
    DoAddSpell()
    addInput:ClearFocus()
end)
addBtn:SetScript("OnClick", DoAddSpell)

RebuildGroupManagement = function()
    for _, w in ipairs(groupMgmtItems) do
        w:Hide()
    end
    groupMgmtItems = {}
    renameInput:Hide()
    confirmBtn:Hide()

    if IsClassGroup(frame.selectedGroup) then
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
        for _, v in ipairs(WOTLK_CLASSES) do
            if v == nameUpper then return end
        end
        local customGroups = RaidCD.config.db.customGroups or {}
        for _, g in ipairs(customGroups) do
            if string.upper(g) == nameUpper then return end
        end
        for i, g in ipairs(customGroups) do
            if g == frame.selectedGroup then
                customGroups[i] = newName
                break
            end
        end
        local spells = RaidCD.config.db.trackedSpells[frame.selectedGroup]
        RaidCD.config.db.trackedSpells[frame.selectedGroup] = nil
        RaidCD.config.db.trackedSpells[newName] = spells
        frame.selectedGroup = newName
        renameInput:Hide()
        confirmBtn:Hide()
        RebuildCustomGroups()
        RebuildGroupManagement()
        RaidCD_OnSettingChanged()
    end

    renameInput:SetScript("OnEnterPressed", function()
        DoRename()
        renameInput:ClearFocus()
    end)
    confirmBtn:SetScript("OnClick", DoRename)

    deleteBtn:SetScript("OnClick", function()
        local customGroups = RaidCD.config.db.customGroups or {}
        for i, g in ipairs(customGroups) do
            if g == frame.selectedGroup then
                table.remove(customGroups, i)
                break
            end
        end
        RaidCD.config.db.trackedSpells[frame.selectedGroup] = nil
        RaidCD.config.db.customGroups = customGroups
        frame.selectedGroup = WOTLK_CLASSES[1]
        RebuildCustomGroups()
        SelectGroup(frame.selectedGroup)
        RaidCD_OnSettingChanged()
    end)
end

RebuildSpellList = function()
    for _, w in ipairs(spellRowItems) do
        w:Hide()
    end
    spellRowItems = {}

    local groupSpells = RaidCD.config.db.trackedSpells[frame.selectedGroup] or {}
    local spellCount = #groupSpells

    if spellCount == 0 then
        local empty = spellRowsParent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        empty:SetPoint("CENTER", spellRowsParent, "CENTER", 0, 0)
        empty:SetJustifyH("CENTER")
        empty:SetText("No spells tracked for this group.\nEnter a Spell ID above and click Add.")
        empty:SetTextColor(0.4, 0.4, 0.5, 1)
        spellRowItems[#spellRowItems + 1] = empty
        return
    end

    -- Grow the parent to fit all rows
    local contentH = spellCount * ROW_H
    spellRowsParent:SetHeight(math.max(contentH, LIST_H - headerH - 8))

    for idx, spellId in ipairs(groupSpells) do
        local y = -(idx - 1) * ROW_H
        local isEven = (idx % 2) == 0

        -- Row background
        local bg = spellRowsParent:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", spellRowsParent, "TOPLEFT", 0, y)
        bg:SetPoint("BOTTOMRIGHT", spellRowsParent, "TOPRIGHT", 0, y + ROW_H)
        if isEven then
            bg:SetColorTexture(0.08, 0.08, 0.14, 0.8)
        else
            bg:SetColorTexture(0.04, 0.04, 0.08, 0.6)
        end
        spellRowItems[#spellRowItems + 1] = bg

        -- Spell icon
        local sName, _, sIcon = GetSpellInfo(spellId)
        local spellName = sName or "Spell #" .. spellId
        local iconSz = 20

        local icon = spellRowsParent:CreateTexture(nil, "ARTWORK")
        icon:SetSize(iconSz, iconSz)
        icon:SetPoint("LEFT", spellRowsParent, "LEFT", 6, 0)
        icon:SetPoint("TOP", spellRowsParent, "TOP", 0, y - (ROW_H - iconSz) / 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon:SetTexture(sIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
        spellRowItems[#spellRowItems + 1] = icon

        -- Spell name
        local nameText = spellRowsParent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        nameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        nameText:SetPoint("RIGHT", spellRowsParent, "RIGHT", -208, 0)
        nameText:SetPoint("TOP", spellRowsParent, "TOP", 0, y - (ROW_H - 14) / 2 + 2)
        nameText:SetJustifyH("LEFT")
        nameText:SetText(spellName)
        spellRowItems[#spellRowItems + 1] = nameText

        -- Spell ID
        local idText = spellRowsParent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        idText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        idText:SetPoint("RIGHT", spellRowsParent, "RIGHT", -208, 0)
        idText:SetPoint("TOP", nameText, "BOTTOM", 0, -2)
        idText:SetJustifyH("LEFT")
        idText:SetTextColor(0.35, 0.35, 0.4, 1)
        idText:SetText(tostring(spellId))
        spellRowItems[#spellRowItems + 1] = idText

        -- Remove button
        local remBtn = CreateFrame("Button", nil, spellRowsParent, "UIPanelButtonTemplate")
        remBtn:SetSize(60, 18)
        remBtn:SetPoint("RIGHT", spellRowsParent, "RIGHT", -6, 0)
        remBtn:SetPoint("TOP", spellRowsParent, "TOP", 0, y - (ROW_H - 18) / 2)
        remBtn:SetText("Remove")
        remBtn:SetNormalFontObject("GameFontHighlightSmall")
        remBtn:SetHighlightFontObject("GameFontHighlightSmall")
        local capturedId = spellId
        remBtn:SetScript("OnClick", function()
            local spells = RaidCD.config.db.trackedSpells[frame.selectedGroup] or {}
            for j, id in ipairs(spells) do
                if id == capturedId then
                    table.remove(RaidCD.config.db.trackedSpells[frame.selectedGroup], j)
                    break
                end
            end
            if RaidCD.config.db.spellScopes then
                RaidCD.config.db.spellScopes[capturedId] = nil
            end
            if RaidCD.config.db.spellActive then
                RaidCD.config.db.spellActive[capturedId] = nil
            end
            RebuildSpellList()
            RaidCD_OnSettingChanged()
        end)
        spellRowItems[#spellRowItems + 1] = remBtn

        -- Active toggle button
        local activeBtn = CreateFrame("Button", nil, spellRowsParent, "UIPanelButtonTemplate")
        activeBtn:SetSize(56, 18)
        activeBtn:SetPoint("RIGHT", remBtn, "LEFT", -4, 0)
        activeBtn:SetPoint("TOP", spellRowsParent, "TOP", 0, y - (ROW_H - 18) / 2)
        activeBtn:SetNormalFontObject("GameFontHighlightSmall")
        activeBtn:SetHighlightFontObject("GameFontHighlightSmall")
        local capturedSpellId = spellId
        local function UpdateActiveBtnText()
            local active = RaidCD.config.db.spellActive and RaidCD.config.db.spellActive[capturedSpellId]
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
            if not RaidCD.config.db.spellActive then
                RaidCD.config.db.spellActive = {}
            end
            local current = RaidCD.config.db.spellActive[capturedSpellId]
            if current == false then
                RaidCD.config.db.spellActive[capturedSpellId] = true
            else
                RaidCD.config.db.spellActive[capturedSpellId] = false
            end
            UpdateActiveBtnText()
            RaidCD_OnSettingChanged()
        end)
        spellRowItems[#spellRowItems + 1] = activeBtn

        -- Scope toggle button
        local scopeBtn = CreateFrame("Button", nil, spellRowsParent, "UIPanelButtonTemplate")
        scopeBtn:SetSize(64, 18)
        scopeBtn:SetPoint("RIGHT", activeBtn, "LEFT", -4, 0)
        scopeBtn:SetPoint("TOP", spellRowsParent, "TOP", 0, y - (ROW_H - 18) / 2)
        scopeBtn:SetNormalFontObject("GameFontHighlightSmall")
        scopeBtn:SetHighlightFontObject("GameFontHighlightSmall")
        local capturedSpellId2 = spellId
        local function UpdateScopeBtnText()
            local scope = RaidCD.config.db.spellScopes and RaidCD.config.db.spellScopes[capturedSpellId2]
            if scope == "personal" then
                scopeBtn:SetText("Personal")
            else
                scopeBtn:SetText("Raid-wide")
            end
        end
        UpdateScopeBtnText()
        scopeBtn:SetScript("OnClick", function()
            if not RaidCD.config.db.spellScopes then
                RaidCD.config.db.spellScopes = {}
            end
            local current = RaidCD.config.db.spellScopes[capturedSpellId2]
            if current == "personal" then
                RaidCD.config.db.spellScopes[capturedSpellId2] = nil
            else
                RaidCD.config.db.spellScopes[capturedSpellId2] = "personal"
            end
            UpdateScopeBtnText()
            RaidCD_OnSettingChanged()
        end)
        spellRowItems[#spellRowItems + 1] = scopeBtn
    end
end

RebuildCustomGroups = function()
    for _, w in ipairs(customGroupItems) do
        w:Hide()
    end
    customGroupItems = {}
    customGroupButtons = {}
    local customGroups = RaidCD.config.db.customGroups or {}

    for i, group in ipairs(customGroups) do
        local btn = CreateFrame("Button", "RaidCD_CustomGrpBtn" .. i, leftPanel, "OptionsListButtonTemplate")
        btn:SetSize(leftW - 4, ROW_H)
        btn:SetPoint("TOPLEFT", leftPanel, "TOPLEFT", 2, -(20 + 30 + (#WOTLK_CLASSES + i - 1) * ROW_H))
        btn:SetText(group)
        btn:SetScript("OnClick", function() SelectGroup(group) end)
        customGroupItems[#customGroupItems + 1] = btn
        customGroupButtons[i] = btn
    end
end

PositionCustomGroupControls = function()
    -- Controls are now at top, nothing to reposition
end

RebuildCustomGroups()
InterfaceOptions_AddCategory(frame)
SelectGroup(frame.selectedGroup)
UpdateAnchorToggleText()

-- Restore Defaults button (bottom left)
local restoreBtn = CreateFrame("Button", "RaidCD_RestoreDefaultsBtn", frame, "UIPanelButtonTemplate")
restoreBtn:SetSize(90, 22)
restoreBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PADDING, PADDING)
restoreBtn:SetText("Restore Defaults")
restoreBtn:SetNormalFontObject("GameFontHighlightSmall")
restoreBtn:SetHighlightFontObject("GameFontHighlightSmall")
restoreBtn:SetScript("OnClick", function()
    local defaults = MakeDefaults()
    if not RaidCD.config.db.spellScopes then RaidCD.config.db.spellScopes = {} end
    if not RaidCD.config.db.spellActive then RaidCD.config.db.spellActive = {} end
    for groupKey, defaultSpells in pairs(defaults.trackedSpells) do
        if not RaidCD.config.db.trackedSpells[groupKey] then
            RaidCD.config.db.trackedSpells[groupKey] = {}
        end
        local existing = RaidCD.config.db.trackedSpells[groupKey]
        for _, entry in ipairs(defaultSpells) do
            local spellId, scope, active
            if type(entry) == "number" then
                spellId = entry
            else
                spellId = entry[1]
                scope = entry.scope
                active = entry.active
            end
            local found = false
            for _, existingId in ipairs(existing) do
                if existingId == spellId then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(existing, spellId)
            end
            if scope then
                RaidCD.config.db.spellScopes[spellId] = scope
            else
                RaidCD.config.db.spellScopes[spellId] = nil
            end
            if active ~= nil then
                RaidCD.config.db.spellActive[spellId] = active
            else
                RaidCD.config.db.spellActive[spellId] = nil
            end
        end
    end
    RebuildSpellList()
    RaidCD_OnSettingChanged()
end)

-- Restore custom group buttons after config loads (init runs before config is ready)
frame:SetScript("OnShow", function()
    RebuildCustomGroups()
    if not frame.selectedGroup or frame.selectedGroup == "" then
        frame.selectedGroup = WOTLK_CLASSES[1]
    end
    SelectGroup(frame.selectedGroup)
    UpdateAnchorToggleText()
end)
