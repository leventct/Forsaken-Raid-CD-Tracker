-- RaidCooldownTracker — UI Settings: Display Options widget builder
local function SliderText(s) return _G[s:GetName() .. "Text"] end
local function SliderHigh(s) return _G[s:GetName() .. "High"] end
local function SliderLow(s) return _G[s:GetName() .. "Low"] end
local function SliderValue(s) return _G[s:GetName() .. "Value"] end
local function GetCheckText(btn) return _G[btn:GetName() .. "Text"] end

local frame = CreateFrame("Frame", "RaidCD_DisplayOptionsPanel", UIParent)
frame.name = "Display Options"
frame.parent = "RaidCooldownTracker"

local scroll = CreateScrollChild(frame, 700)
local y = -10

local listbarHeader = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
listbarHeader:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 24
listbarHeader:SetText("|cFF69CCF0Cooldown List:|r")

-- Bar Width
local lbl1 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl1:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl1:SetText("Bar Width:")
local barWidthSlider = CreateFrame("Slider", "RaidCD_BarWidth", scroll, "OptionsSliderTemplate")
barWidthSlider:SetSize(200, 16)
barWidthSlider:SetPoint("TOPLEFT", lbl1, "BOTTOMLEFT", 0, -6)
barWidthSlider:SetMinMaxValues(100, 400)
barWidthSlider:SetValueStep(5)
barWidthSlider:SetValue(RaidCD.config.db.barWidth)
SliderText(barWidthSlider):SetText("")
SliderHigh(barWidthSlider):SetText("400")
SliderLow(barWidthSlider):SetText("100")
barWidthSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.barWidth = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.barWidth))
    RaidCD_OnSettingChanged()
end)
SliderValue(barWidthSlider):SetText(tostring(RaidCD.config.db.barWidth))
y = y - 46

-- Bar Height
local lbl2 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl2:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl2:SetText("Bar Height:")
local barHeightSlider = CreateFrame("Slider", "RaidCD_BarHeight", scroll, "OptionsSliderTemplate")
barHeightSlider:SetSize(200, 16)
barHeightSlider:SetPoint("TOPLEFT", lbl2, "BOTTOMLEFT", 0, -6)
barHeightSlider:SetMinMaxValues(10, 40)
barHeightSlider:SetValueStep(1)
barHeightSlider:SetValue(RaidCD.config.db.barHeight)
SliderText(barHeightSlider):SetText("")
SliderHigh(barHeightSlider):SetText("40")
SliderLow(barHeightSlider):SetText("10")
barHeightSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.barHeight = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.barHeight))
    RaidCD_OnSettingChanged()
end)
SliderValue(barHeightSlider):SetText(tostring(RaidCD.config.db.barHeight))
y = y - 46

-- Bar Spacing
local lbl3 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl3:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl3:SetText("Bar Spacing:")
local barSpacingSlider = CreateFrame("Slider", "RaidCD_BarSpacing", scroll, "OptionsSliderTemplate")
barSpacingSlider:SetSize(200, 16)
barSpacingSlider:SetPoint("TOPLEFT", lbl3, "BOTTOMLEFT", 0, -6)
barSpacingSlider:SetMinMaxValues(0, 10)
barSpacingSlider:SetValueStep(1)
barSpacingSlider:SetValue(RaidCD.config.db.barSpacing)
SliderText(barSpacingSlider):SetText("")
SliderHigh(barSpacingSlider):SetText("10")
SliderLow(barSpacingSlider):SetText("0")
barSpacingSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.barSpacing = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.barSpacing))
    RaidCD_OnSettingChanged()
end)
SliderValue(barSpacingSlider):SetText(tostring(RaidCD.config.db.barSpacing))
y = y - 46

-- Font Size
local lbl4 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl4:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl4:SetText("Font Size:")
local fontSizeSlider = CreateFrame("Slider", "RaidCD_FontSize", scroll, "OptionsSliderTemplate")
fontSizeSlider:SetSize(200, 16)
fontSizeSlider:SetPoint("TOPLEFT", lbl4, "BOTTOMLEFT", 0, -6)
fontSizeSlider:SetMinMaxValues(8, 20)
fontSizeSlider:SetValueStep(1)
fontSizeSlider:SetValue(RaidCD.config.db.fontSize)
SliderText(fontSizeSlider):SetText("")
SliderHigh(fontSizeSlider):SetText("20")
SliderLow(fontSizeSlider):SetText("8")
fontSizeSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.fontSize = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.fontSize))
    RaidCD_OnSettingChanged()
end)
SliderValue(fontSizeSlider):SetText(tostring(RaidCD.config.db.fontSize))
y = y - 46

-- Header Spacing
local lbl5 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl5:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl5:SetText("Class Header Spacing:")
local headerSpacingSlider = CreateFrame("Slider", "RaidCD_HeaderSpacing", scroll, "OptionsSliderTemplate")
headerSpacingSlider:SetSize(200, 16)
headerSpacingSlider:SetPoint("TOPLEFT", lbl5, "BOTTOMLEFT", 0, -6)
headerSpacingSlider:SetMinMaxValues(0, 20)
headerSpacingSlider:SetValueStep(1)
headerSpacingSlider:SetValue(RaidCD.config.db.headerSpacing)
SliderText(headerSpacingSlider):SetText("")
SliderHigh(headerSpacingSlider):SetText("20")
SliderLow(headerSpacingSlider):SetText("0")
headerSpacingSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.headerSpacing = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.headerSpacing))
    RaidCD_OnSettingChanged()
end)
SliderValue(headerSpacingSlider):SetText(tostring(RaidCD.config.db.headerSpacing))
y = y - 46

-- Show Class Headers
local headerCheck = CreateFrame("CheckButton", "RaidCD_ShowHeadersCheck", scroll, "UICheckButtonTemplate")
headerCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(headerCheck):SetText("Show Class Separators")
headerCheck:SetChecked(RaidCD.config.db.showClassHeaders)
headerCheck:SetScript("OnClick", function()
    RaidCD.config.db.showClassHeaders = headerCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

-- Class Header Font Size
local lblHeaderSize = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lblHeaderSize:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lblHeaderSize:SetText("Class Header Font Size:")
local headerFontSlider = CreateFrame("Slider", "RaidCD_HeaderFontSize", scroll, "OptionsSliderTemplate")
headerFontSlider:SetSize(200, 16)
headerFontSlider:SetPoint("TOPLEFT", lblHeaderSize, "BOTTOMLEFT", 0, -6)
headerFontSlider:SetMinMaxValues(8, 18)
headerFontSlider:SetValueStep(1)
headerFontSlider:SetValue(RaidCD.config.db.headerFontSize)
SliderText(headerFontSlider):SetText("")
SliderHigh(headerFontSlider):SetText("18")
SliderLow(headerFontSlider):SetText("8")
headerFontSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.headerFontSize = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.headerFontSize))
    RaidCD_OnSettingChanged()
end)
SliderValue(headerFontSlider):SetText(tostring(RaidCD.config.db.headerFontSize))
y = y - 46

-- Bar BG Opacity
local lblBarBg = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lblBarBg:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lblBarBg:SetText("Bar BG Opacity:")
local barBgOpacitySlider = CreateFrame("Slider", "RaidCD_BarBgOpacity", scroll, "OptionsSliderTemplate")
barBgOpacitySlider:SetSize(200, 16)
barBgOpacitySlider:SetPoint("TOPLEFT", lblBarBg, "BOTTOMLEFT", 0, -6)
barBgOpacitySlider:SetMinMaxValues(0, 100)
barBgOpacitySlider:SetValueStep(5)
barBgOpacitySlider:SetValue(math.floor((RaidCD.config.db.barBgOpacity or 0.8) * 100))
SliderText(barBgOpacitySlider):SetText("")
SliderHigh(barBgOpacitySlider):SetText("100")
SliderLow(barBgOpacitySlider):SetText("0")
barBgOpacitySlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.barBgOpacity = math.floor(v) / 100
    SliderValue(s):SetText(tostring(math.floor(v)))
    RaidCD_OnSettingChanged()
end)
SliderValue(barBgOpacitySlider):SetText(tostring(math.floor((RaidCD.config.db.barBgOpacity or 0.8) * 100)))
y = y - 46

-- Anchor Location
local anchorLocLabel = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
anchorLocLabel:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
anchorLocLabel:SetText("Anchor Location:")
local anchorLocDropdown = CreateFrame("Frame", "RaidCD_AnchorLocDropdown", scroll, "UIDropDownMenuTemplate")
anchorLocDropdown:SetPoint("TOPLEFT", anchorLocLabel, "BOTTOMLEFT", -12, -4)
y = y - 44

local ANCHOR_LOC_LABELS = {"Top Left", "Bottom Left", "Top Right", "Bottom Right"}
local ANCHOR_LOC_VALUES = {"TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "BOTTOMRIGHT"}

local function UpdateAnchorLocText()
    local idx = 1
    for i, v in ipairs(ANCHOR_LOC_VALUES) do
        if v == RaidCD.config.db.anchorLocation then idx = i; break end
    end
    UIDropDownMenu_SetText(anchorLocDropdown, ANCHOR_LOC_LABELS[idx])
end

anchorLocDropdown.initialize = function()
    for i, label in ipairs(ANCHOR_LOC_LABELS) do
        UIDropDownMenu_AddButton({
            text = label,
            value = ANCHOR_LOC_VALUES[i],
            checked = RaidCD.config.db.anchorLocation == ANCHOR_LOC_VALUES[i],
            func = function()
                RaidCD.config.db.anchorLocation = ANCHOR_LOC_VALUES[i]
                UpdateAnchorLocText()
                RaidCD_OnSettingChanged()
            end
        })
    end
end
UpdateAnchorLocText()

-- Notifications header
local notifHeader = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
notifHeader:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 24
notifHeader:SetText("|cFF69CCF0Notifications:|r")

-- Hide Notification Title
local hideNotifTitleCheck = CreateFrame("CheckButton", "RaidCD_HideNotifTitleCheck", scroll, "UICheckButtonTemplate")
hideNotifTitleCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(hideNotifTitleCheck):SetText("Hide Notification Title")
hideNotifTitleCheck:SetChecked(RaidCD.config.db.hideNotifTitle)
hideNotifTitleCheck:SetScript("OnClick", function()
    RaidCD.config.db.hideNotifTitle = hideNotifTitleCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

-- Notification Label Font Size
local lblNotifLabel = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lblNotifLabel:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lblNotifLabel:SetText("Notification Label Font Size:")
local notifLabelFontSlider = CreateFrame("Slider", "RaidCD_NotifLabelFontSize", scroll, "OptionsSliderTemplate")
notifLabelFontSlider:SetSize(200, 16)
notifLabelFontSlider:SetPoint("TOPLEFT", lblNotifLabel, "BOTTOMLEFT", 0, -6)
notifLabelFontSlider:SetMinMaxValues(8, 18)
notifLabelFontSlider:SetValueStep(1)
notifLabelFontSlider:SetValue(RaidCD.config.db.notifLabelFontSize)
SliderText(notifLabelFontSlider):SetText("")
SliderHigh(notifLabelFontSlider):SetText("18")
SliderLow(notifLabelFontSlider):SetText("8")
notifLabelFontSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifLabelFontSize = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.notifLabelFontSize))
    RaidCD_OnSettingChanged()
end)
SliderValue(notifLabelFontSlider):SetText(tostring(RaidCD.config.db.notifLabelFontSize))
y = y - 46

-- Notif Width
local lbl6 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl6:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl6:SetText("Notification Width:")
local notifWidthSlider = CreateFrame("Slider", "RaidCD_NotifWidth", scroll, "OptionsSliderTemplate")
notifWidthSlider:SetSize(200, 16)
notifWidthSlider:SetPoint("TOPLEFT", lbl6, "BOTTOMLEFT", 0, -6)
notifWidthSlider:SetMinMaxValues(150, 500)
notifWidthSlider:SetValueStep(10)
notifWidthSlider:SetValue(RaidCD.config.db.notifWidth)
SliderText(notifWidthSlider):SetText("")
SliderHigh(notifWidthSlider):SetText("500")
SliderLow(notifWidthSlider):SetText("150")
notifWidthSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifWidth = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.notifWidth))
end)
SliderValue(notifWidthSlider):SetText(tostring(RaidCD.config.db.notifWidth))
y = y - 46

-- Notif Height
local lbl7 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl7:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl7:SetText("Notification Row Height:")
local notifHeightSlider = CreateFrame("Slider", "RaidCD_NotifHeight", scroll, "OptionsSliderTemplate")
notifHeightSlider:SetSize(200, 16)
notifHeightSlider:SetPoint("TOPLEFT", lbl7, "BOTTOMLEFT", 0, -6)
notifHeightSlider:SetMinMaxValues(16, 50)
notifHeightSlider:SetValueStep(1)
notifHeightSlider:SetValue(RaidCD.config.db.notifHeight)
SliderText(notifHeightSlider):SetText("")
SliderHigh(notifHeightSlider):SetText("50")
SliderLow(notifHeightSlider):SetText("16")
notifHeightSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifHeight = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.notifHeight))
end)
SliderValue(notifHeightSlider):SetText(tostring(RaidCD.config.db.notifHeight))
y = y - 46

-- Notif Spacing
local lbl8 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl8:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl8:SetText("Notification Spacing:")
local notifSpacingSlider = CreateFrame("Slider", "RaidCD_NotifSpacing", scroll, "OptionsSliderTemplate")
notifSpacingSlider:SetSize(200, 16)
notifSpacingSlider:SetPoint("TOPLEFT", lbl8, "BOTTOMLEFT", 0, -6)
notifSpacingSlider:SetMinMaxValues(0, 20)
notifSpacingSlider:SetValueStep(1)
notifSpacingSlider:SetValue(RaidCD.config.db.notifSpacing)
SliderText(notifSpacingSlider):SetText("")
SliderHigh(notifSpacingSlider):SetText("20")
SliderLow(notifSpacingSlider):SetText("0")
notifSpacingSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifSpacing = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.notifSpacing))
end)
SliderValue(notifSpacingSlider):SetText(tostring(RaidCD.config.db.notifSpacing))
y = y - 46

-- Notif Icon Size
local lbl9 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl9:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl9:SetText("Notification Icon Size:")
local notifIconSizeSlider = CreateFrame("Slider", "RaidCD_NotifIconSize", scroll, "OptionsSliderTemplate")
notifIconSizeSlider:SetSize(200, 16)
notifIconSizeSlider:SetPoint("TOPLEFT", lbl9, "BOTTOMLEFT", 0, -6)
notifIconSizeSlider:SetMinMaxValues(12, 40)
notifIconSizeSlider:SetValueStep(1)
notifIconSizeSlider:SetValue(RaidCD.config.db.notifIconSize)
SliderText(notifIconSizeSlider):SetText("")
SliderHigh(notifIconSizeSlider):SetText("40")
SliderLow(notifIconSizeSlider):SetText("12")
notifIconSizeSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifIconSize = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.notifIconSize))
end)
SliderValue(notifIconSizeSlider):SetText(tostring(RaidCD.config.db.notifIconSize))
y = y - 46

-- Notif Font Size
local lbl10 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl10:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl10:SetText("Notification Font Size:")
local notifFontSizeSlider = CreateFrame("Slider", "RaidCD_NotifFontSize", scroll, "OptionsSliderTemplate")
notifFontSizeSlider:SetSize(200, 16)
notifFontSizeSlider:SetPoint("TOPLEFT", lbl10, "BOTTOMLEFT", 0, -6)
notifFontSizeSlider:SetMinMaxValues(8, 20)
notifFontSizeSlider:SetValueStep(1)
notifFontSizeSlider:SetValue(RaidCD.config.db.notifFontSize)
SliderText(notifFontSizeSlider):SetText("")
SliderHigh(notifFontSizeSlider):SetText("20")
SliderLow(notifFontSizeSlider):SetText("8")
notifFontSizeSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifFontSize = math.floor(v)
    SliderValue(s):SetText(tostring(RaidCD.config.db.notifFontSize))
end)
SliderValue(notifFontSizeSlider):SetText(tostring(RaidCD.config.db.notifFontSize))
y = y - 46

-- Notification BG Color Mode
local bgModeLabel = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
bgModeLabel:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
bgModeLabel:SetText("Notification Background Color:")
local bgModeDropdown = CreateFrame("Frame", "RaidCD_NotifBgMode", scroll, "UIDropDownMenuTemplate")
bgModeDropdown:SetPoint("TOPLEFT", bgModeLabel, "BOTTOMLEFT", -12, -4)
y = y - 44

local BG_MODE_LABELS = {"None", "Requester's Class", "Spell's Class"}
local BG_MODE_VALUES = {"none", "requester", "spell"}

local function UpdateBgModeText()
    local idx = 1
    for i, v in ipairs(BG_MODE_VALUES) do
        if v == RaidCD.config.db.notifBgColorMode then idx = i; break end
    end
    UIDropDownMenu_SetText(bgModeDropdown, BG_MODE_LABELS[idx])
end

bgModeDropdown.initialize = function()
    for i, label in ipairs(BG_MODE_LABELS) do
        UIDropDownMenu_AddButton({
            text = label,
            value = BG_MODE_VALUES[i],
            checked = RaidCD.config.db.notifBgColorMode == BG_MODE_VALUES[i],
            func = function()
                RaidCD.config.db.notifBgColorMode = BG_MODE_VALUES[i]
                UpdateBgModeText()
            end
        })
    end
end
UpdateBgModeText()

-- BG Opacity
local lbl11 = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
lbl11:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
lbl11:SetText("Notification BG Opacity:")
local bgOpacitySlider = CreateFrame("Slider", "RaidCD_NotifBgOpacity", scroll, "OptionsSliderTemplate")
bgOpacitySlider:SetSize(200, 16)
bgOpacitySlider:SetPoint("TOPLEFT", lbl11, "BOTTOMLEFT", 0, -6)
bgOpacitySlider:SetMinMaxValues(5, 100)
bgOpacitySlider:SetValueStep(5)
bgOpacitySlider:SetValue(math.floor(RaidCD.config.db.notifBgOpacity * 100))
SliderText(bgOpacitySlider):SetText("")
SliderHigh(bgOpacitySlider):SetText("100")
SliderLow(bgOpacitySlider):SetText("5")
bgOpacitySlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifBgOpacity = math.floor(v) / 100
    SliderValue(s):SetText(tostring(math.floor(v)))
end)
SliderValue(bgOpacitySlider):SetText(tostring(math.floor(RaidCD.config.db.notifBgOpacity * 100)))
y = y - 46

-- Show Icons
local iconCheck = CreateFrame("CheckButton", "RaidCD_ShowIconsCheck", scroll, "UICheckButtonTemplate")
iconCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(iconCheck):SetText("Show Spell Icons on Bars")
iconCheck:SetChecked(RaidCD.config.db.showIcons)
iconCheck:SetScript("OnClick", function()
    RaidCD.config.db.showIcons = iconCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

-- Reset Bar Position
local resetBtn = CreateFrame("Button", "RaidCD_ResetPosBtn", scroll, "UIPanelButtonTemplate")
resetBtn:SetSize(140, 24)
resetBtn:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 32
resetBtn:SetText("Reset Bar Position")
resetBtn:SetScript("OnClick", function()
    RaidCD.config.db.position = {point = "CENTER", x = 0, y = 0}
    if RaidCD.ui.anchor then
        RaidCD.ui.anchor:ClearAllPoints()
        RaidCD.ui.anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end)

-- Reset Notification Position
local resetNotifBtn = CreateFrame("Button", "RaidCD_ResetNotifBtn", scroll, "UIPanelButtonTemplate")
resetNotifBtn:SetSize(140, 24)
resetNotifBtn:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
resetNotifBtn:SetText("Reset Notif Pos")
resetNotifBtn:SetScript("OnClick", function()
    RaidCD.config.db.notifPosition = {point = "TOP", x = 0, y = -200}
    if RaidCD.ui.notifManager and RaidCD.ui.notifManager.anchor then
        RaidCD.ui.notifManager.anchor:ClearAllPoints()
        RaidCD.ui.notifManager.anchor:SetPoint("TOP", UIParent, "TOP", 0, -200)
    end
end)

-- Reset All to Defaults
local resetAllBtn = CreateFrame("Button", "RaidCD_ResetAllBtn", scroll, "UIPanelButtonTemplate")
resetAllBtn:SetSize(160, 24)
resetAllBtn:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 32
resetAllBtn:SetText("|cFFFF4444Reset All to Defaults|r")
resetAllBtn:SetScript("OnClick", function()
    RaidCD.config:Save()
    wipe(RaidCD.config.db)
    for k, v in pairs(RaidCD.config.defaults) do
        RaidCD.config.db[k] = v
    end
    RaidCD.config:Save()
    ReloadUI()
end)

InterfaceOptions_AddCategory(frame)
