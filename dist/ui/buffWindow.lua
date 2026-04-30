-- RaidCooldownTracker — Buff Tracker: minimap button + main window
local buffWindow = {}

local PLAYER_COL_W = 140
local ICON_SIZE = 18
local ICON_SPACING = 2
local ROW_H = 25
local HEADER_H = 25
local TITLE_H = 28
local PADDING = 5

-- ── Minimap Button ─────────────────────────────────────────────

local MINIMAP_RADIUS = 78

local function PositionMinimapButton(button, angle)
    button:ClearAllPoints()
    local x = MINIMAP_RADIUS * math.cos(angle)
    local y = MINIMAP_RADIUS * math.sin(angle)
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function buffWindow.InitMinimapButton()
    local button = CreateFrame("Frame", "RaidCD_BuffMinimapButton", Minimap)
    button:SetWidth(31)
    button:SetHeight(31)
    button:SetFrameStrata("HIGH")
    button:EnableMouse(true)
    button:RegisterForDrag("LeftButton")

    local angle = RaidCD.config.db.minimapAngle or math.rad(135)
    PositionMinimapButton(button, angle)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\INV_Potion_93")
    icon:SetWidth(22)
    icon:SetHeight(22)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Icons\\INV_Potion_44")
    highlight:SetWidth(26)
    highlight:SetHeight(26)
    highlight:SetPoint("CENTER", button, "CENTER", 0, 0)

    button:SetScript("OnDragStart", function(self)
        self.isDragging = true
    end)
    button:SetScript("OnDragStop", function(self)
        self.isDragging = false
        RaidCD.config.db.minimapAngle = self.currentAngle
    end)
    button:SetScript("OnUpdate", function(self)
        if not self.isDragging then return end
        local mx, my = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        mx, my = mx / scale, my / scale
        local cx, cy = Minimap:GetCenter()
        self.currentAngle = math.atan2(my - cy, mx - cx)
        PositionMinimapButton(self, self.currentAngle)
    end)

    button:SetScript("OnMouseUp", function(self, btn)
        if self.isDragging then return end
        if btn == "LeftButton" then
            if buffWindow.mainFrame then
                local visible = buffWindow.mainFrame:IsVisible()
                if not visible then
                    buffWindow.Refresh()
                end
                buffWindow.mainFrame:SetShown(not visible)
            end
        elseif btn == "RightButton" then
            InterfaceOptionsFrame_OpenToCategory("RaidCooldownTracker")
            InterfaceOptionsFrame_OpenToCategory("RaidCooldownTracker")
        end
    end)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Click to view tracked buff list", 1, 1, 1)
        GameTooltip:AddLine("Right-click for settings", 0.6, 0.6, 0.6, 1)
        GameTooltip:AddLine("Drag to reposition", 0.6, 0.6, 0.6, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button.currentAngle = angle
    buffWindow.minimapButton = button
end

-- ── Roster ──────────────────────────────────────────────────────

local function GetRoster()
    local roster = {}
    local numRaid = GetNumRaidMembers()
    if numRaid > 0 then
        for i = 1, numRaid do
            local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i)
            if name and online then
                roster[#roster + 1] = { name = name, class = fileName, unit = "raid" .. i }
            end
        end
    else
        local numParty = GetNumPartyMembers()
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        roster[#roster + 1] = { name = playerName, class = playerClass, unit = "player" }
        for i = 1, numParty do
            local unit = "party" .. i
            if UnitExists(unit) then
                local name = UnitName(unit)
                local _, classFile = UnitClass(unit)
                roster[#roster + 1] = { name = name, class = classFile, unit = unit }
            end
        end
    end
    return roster
end

-- ── Buff Scanning ───────────────────────────────────────────────

local function ScanBuffs(unitToken)
    local buffs = {}
    local i = 1
    while true do
        local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, consolidate, spellId = UnitBuff(unitToken, i)
        if not name then break end
        if spellId then
            local remaining = 0
            if expirationTime and expirationTime > 0 then
                remaining = math.max(0, expirationTime - GetTime())
            end
            buffs[spellId] = { name = name, icon = icon, remaining = remaining, duration = duration or 0 }
        end
        i = i + 1
    end
    return buffs
end

-- ── Columns ─────────────────────────────────────────────────────

local function GetColumns()
    local cols = { { name = "Player", width = PLAYER_COL_W, ids = {} } }
    local trackedBuffs = RaidCD.config.db.trackedBuffs or {}
    local buffActive = RaidCD.config.db.buffActive or {}
    local groupOrder = RaidCD.config.db.buffGroupOrder or {}
    local orderedNames = {}
    local seen = {}
    if #groupOrder > 0 then
        for _, name in ipairs(groupOrder) do
            if trackedBuffs[name] ~= nil and not seen[name] then
                orderedNames[#orderedNames + 1] = name
                seen[name] = true
            end
        end
    end
    for name in pairs(trackedBuffs) do
        if not seen[name] then
            orderedNames[#orderedNames + 1] = name
            seen[name] = true
        end
    end
    for _, groupName in ipairs(orderedNames) do
        local ids = trackedBuffs[groupName]
        local activeIds = {}
        for _, id in ipairs(ids or {}) do
            if buffActive[id] ~= false then
                activeIds[#activeIds + 1] = id
            end
        end
        local numIds = #activeIds
        local textW = (#groupName * 7) + 16
        local w = math.max(numIds * (ICON_SIZE + ICON_SPACING) + ICON_SPACING, textW, 50)
        cols[#cols + 1] = { name = groupName, width = w, ids = activeIds }
    end
    return cols
end

-- ── Main Window ─────────────────────────────────────────────────

function buffWindow.CreateMainWindow()
    local window = CreateFrame("Frame", "RaidCD_BuffWindow", UIParent)
    window:SetWidth(420)
    window:SetHeight(400)
    window:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    window:SetFrameStrata("HIGH")
    window:SetClampedToScreen(true)
    window:EnableMouse(true)
    window:SetMovable(true)
    window:Hide()

    window:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12
    })
    window:SetBackdropColor(0.08, 0.08, 0.12, 0.98)
    window:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    local titleBar = CreateFrame("Frame", nil, window)
    titleBar:SetHeight(TITLE_H)
    titleBar:SetPoint("TOPLEFT", window, "TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", window, "TOPRIGHT", -32, -4)
    titleBar:EnableMouse(true)
    titleBar:SetMovable(true)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints(titleBar)
    titleBg:SetColorTexture(0.12, 0.12, 0.18, 1)

    local titleText = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText("Buff Tracker")
    titleText:SetTextColor(1, 0.82, 0, 1)

    titleBar:SetScript("OnMouseDown", function(self, btn)
        if btn == "LeftButton" then window:StartMoving() end
    end)
    titleBar:SetScript("OnMouseUp", function(self, btn)
        window:StopMovingOrSizing()
    end)

    local closeButton = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    closeButton:SetSize(28, 28)
    closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() window:Hide() end)

    local content = CreateFrame("Frame", nil, window)
    content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", PADDING, -PADDING)
    content:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -PADDING, PADDING)

    local header = CreateFrame("Frame", nil, content)
    header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
    header:SetHeight(HEADER_H)

    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints()
    headerBg:SetColorTexture(0.1, 0.1, 0.2, 0.9)

    buffWindow.mainFrame = window
    buffWindow.contentFrame = content
    buffWindow.headerRow = header
    buffWindow.rowFrames = {}
    buffWindow.headerElements = {}

    window:SetScript("OnShow", function()
        buffWindow.Refresh()
    end)
end

-- ── Refresh ─────────────────────────────────────────────────────

function buffWindow.Refresh()
    if not buffWindow.mainFrame then return end

    local cols = GetColumns()
    local roster = GetRoster()

    for _, row in ipairs(buffWindow.rowFrames) do
        row:Hide()
    end
    buffWindow.rowFrames = {}

    -- Clear old header elements
    for _, el in ipairs(buffWindow.headerElements or {}) do
        if el.Hide then el:Hide() end
        if el.SetText then el:SetText("") end
    end
    buffWindow.headerElements = {}

    -- Pre-scan all players for buff data
    local allPlayerBuffs = {}
    for _, player in ipairs(roster) do
        allPlayerBuffs[player.name] = ScanBuffs(player.unit)
    end

    -- Recalculate column widths based on actual active buff counts
    local showInactiveConfig = RaidCD.config.db.buffShowInactive or {}
    for _, col in ipairs(cols) do
        if col.ids and #col.ids > 0 then
            local showInactive = showInactiveConfig[col.name] and true or false
            local maxIcons
            if showInactive then
                maxIcons = #col.ids
            else
                maxIcons = 0
                for _, player in ipairs(roster) do
                    local pb = allPlayerBuffs[player.name]
                    local count = 0
                    for _, bid in ipairs(col.ids) do
                        if pb[bid] then count = count + 1 end
                    end
                    if count > maxIcons then maxIcons = count end
                end
            end
            local textW = (#col.name * 7) + 16
            col.width = math.max(maxIcons * (ICON_SIZE + ICON_SPACING) + ICON_SPACING, textW, 50)
        end
    end

    local totalW = 0
    for _, col in ipairs(cols) do
        totalW = totalW + col.width
    end
    totalW = totalW + PADDING * 2
    local totalH = TITLE_H + HEADER_H + (#roster * ROW_H) + PADDING * 3
    buffWindow.mainFrame:SetWidth(math.max(totalW, 300))
    buffWindow.mainFrame:SetHeight(math.max(totalH, 150))

    -- Compute missing players per group
    local missingPerGroup = {}
    for _, col in ipairs(cols) do
        if col.ids and #col.ids > 0 then
            local missing = {}
            local requireAll = showInactiveConfig[col.name] and true or false
            for _, player in ipairs(roster) do
                local pb = allPlayerBuffs[player.name]
                local isMissing
                if requireAll then
                    isMissing = false
                    for _, bid in ipairs(col.ids) do
                        if not pb[bid] then isMissing = true; break end
                    end
                else
                    local hasAny = false
                    for _, bid in ipairs(col.ids) do
                        if pb[bid] then hasAny = true; break end
                    end
                    isMissing = not hasAny
                end
                if isMissing then
                    missing[#missing + 1] = player.name
                end
            end
            missingPerGroup[col.name] = missing
        end
    end

    local xOffset = 0
    for _, col in ipairs(cols) do
        local label = buffWindow.headerRow:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        label:SetPoint("LEFT", buffWindow.headerRow, "LEFT", xOffset + 4, 0)
        label:SetWidth(col.width - 8)
        label:SetJustifyH("LEFT")
        label:SetText(col.name)
        label:SetTextColor(0.55, 0.55, 0.7, 1)
        buffWindow.headerElements[#buffWindow.headerElements + 1] = label

        local capturedMissing = missingPerGroup[col.name]
        if capturedMissing and #capturedMissing > 0 then
            local hitFrame = CreateFrame("Frame", nil, buffWindow.headerRow)
            hitFrame:SetPoint("LEFT", buffWindow.headerRow, "LEFT", xOffset, 0)
            hitFrame:SetWidth(col.width)
            hitFrame:SetHeight(HEADER_H)
            hitFrame:EnableMouse(true)
            local capturedName = col.name
            hitFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
                GameTooltip:SetText(capturedName .. " — Missing:", 1, 0.82, 0)
                for _, pName in ipairs(capturedMissing) do
                    GameTooltip:AddLine(pName, 1, 0.2, 0.2)
                end
                GameTooltip:Show()
            end)
            hitFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            hitFrame:SetScript("OnMouseDown", function()
                local channel = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or nil
                if not channel then return end
                SendChatMessage(capturedMissing[1] .. " is missing " .. capturedName, channel)
                for j = 2, #capturedMissing do
                    SendChatMessage(capturedMissing[j] .. " is missing " .. capturedName, channel)
                end
            end)
            buffWindow.headerElements[#buffWindow.headerElements + 1] = hitFrame
        end

        xOffset = xOffset + col.width
    end

    -- Player rows
    local prevRow = buffWindow.headerRow
    for i, player in ipairs(roster) do
        local row = CreateFrame("Frame", nil, buffWindow.contentFrame)
        row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, 0)
        row:SetPoint("TOPRIGHT", prevRow, "BOTTOMRIGHT", 0, 0)
        row:SetHeight(ROW_H)
        row:Show()
        prevRow = row

        local isEven = (i % 2) == 0
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if isEven then
            bg:SetColorTexture(0.08, 0.08, 0.14, 0.8)
        else
            bg:SetColorTexture(0.04, 0.04, 0.08, 0.6)
        end

        local playerBuffs = allPlayerBuffs[player.name]

        local xOffset = 0
        for colIndex, col in ipairs(cols) do
            if colIndex == 1 then
                local cell = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                cell:SetPoint("LEFT", row, "LEFT", xOffset + 5, 0)
                cell:SetWidth(col.width - 10)
                cell:SetJustifyH("LEFT")
                cell:SetText(player.name)
                cell:SetTextColor(0.9, 0.9, 0.95, 1)
            else
                -- Buff icons for this group
                local showInactive = RaidCD.config.db.buffShowInactive and RaidCD.config.db.buffShowInactive[col.name]
                local iconX = xOffset + ICON_SPACING
                for _, buffId in ipairs(col.ids) do
                    local buffInfo = playerBuffs[buffId]
                    local spellName, _, spellIcon = GetSpellInfo(buffId)
                    local hasBuff = buffInfo ~= nil

                    if hasBuff or showInactive then
                        local iconFrame = CreateFrame("Frame", nil, row)
                        iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
                        iconFrame:SetPoint("LEFT", row, "LEFT", iconX, 0)
                        iconFrame:SetPoint("TOP", row, "TOP", 0, -(ROW_H - ICON_SIZE) / 2)
                        iconFrame:EnableMouse(true)

                        local tex = iconFrame:CreateTexture(nil, "ARTWORK")
                        tex:SetAllPoints()
                        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        tex:SetTexture(spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark")

                        if hasBuff then
                            tex:SetVertexColor(1, 1, 1, 1)
                        else
                            tex:SetVertexColor(0.4, 0.4, 0.4, 0.7)
                        end

                        local capturedId = buffId
                        local capturedName = spellName or ("Spell #" .. buffId)
                        iconFrame:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                            GameTooltip:SetText(capturedName)
                            if hasBuff then
                                local rem = buffInfo.remaining
                                if rem > 0 then
                                    local mins = math.floor(rem / 60)
                                    local secs = math.floor(rem % 60)
                                    GameTooltip:AddDoubleLine("Remaining:", string.format("%dm %ds", mins, secs), 1, 1, 1, 0.2, 1, 0.2)
                                else
                                    GameTooltip:AddLine("Active", 0.2, 1, 0.2)
                                end
                            else
                                GameTooltip:AddLine("Missing", 1, 0.2, 0.2)
                            end
                            GameTooltip:Show()
                        end)
                        iconFrame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                        end)

                        iconX = iconX + ICON_SIZE + ICON_SPACING
                    end
                end
            end

            xOffset = xOffset + col.width
        end

        buffWindow.rowFrames[#buffWindow.rowFrames + 1] = row
    end
end

-- ── Init ────────────────────────────────────────────────────────

function buffWindow.Init()
    buffWindow.InitMinimapButton()
    buffWindow.CreateMainWindow()
end

RaidCD.ui = RaidCD.ui or {}
RaidCD.ui.buffWindow = buffWindow
