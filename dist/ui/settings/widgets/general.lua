-- RaidCooldownTracker — UI Settings: General panel
local function GetCheckText(btn) return _G[btn:GetName() .. "Text"] end

local frame = CreateFrame("Frame", "RaidCD_GeneralPanel", UIParent)
frame.name = "General"
frame.parent = "RaidCooldownTracker"

local scroll = CreateScrollChild(frame, 400)
local y = -10

local enableCheck = CreateFrame("CheckButton", "RaidCD_EnableCheck", scroll, "UICheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(enableCheck):SetText("Enable Addon")
enableCheck:SetScript("OnClick", function()
    RaidCD.config.db.enabled = enableCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

local hideSelfCheck = CreateFrame("CheckButton", "RaidCD_HideSelfCheck", scroll, "UICheckButtonTemplate")
hideSelfCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(hideSelfCheck):SetText("Hide Own Cooldowns")
hideSelfCheck:SetScript("OnClick", function()
    RaidCD.config.db.hideSelf = hideSelfCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

local debugCheck = CreateFrame("CheckButton", "RaidCD_DebugCheck", scroll, "UICheckButtonTemplate")
debugCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(debugCheck):SetText("Debug Logging")
debugCheck:SetScript("OnClick", function()
    RaidCD.config.db.debug = debugCheck:GetChecked()
end)

local lockCheck = CreateFrame("CheckButton", "RaidCD_LockCheck", scroll, "UICheckButtonTemplate")
lockCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(lockCheck):SetText("Lock Positions")
lockCheck:SetScript("OnClick", function()
    RaidCD.config.db.locked = lockCheck:GetChecked()
    if RaidCD.ui.UpdateAllAnchors then
        RaidCD.ui:UpdateAllAnchors()
    end
end)

local demoCheck = CreateFrame("CheckButton", "RaidCD_DemoCheck", scroll, "UICheckButtonTemplate")
demoCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(demoCheck):SetText("Demo Mode (simulated 10-man raid)")
demoCheck:SetScript("OnClick", function()
    RaidCD.config.db.demoMode = demoCheck:GetChecked()
    if RaidCD.config.db.demoMode then
        RaidCD.ui:DemoStart()
    else
        RaidCD.ui:DemoStop()
    end
end)

local serverModeCheck = CreateFrame("CheckButton", "RaidCD_ServerModeCheck", scroll, "UICheckButtonTemplate")
serverModeCheck:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 28
GetCheckText(serverModeCheck):SetText("Server Mode (hide UI, broadcast only)")
serverModeCheck:SetScript("OnClick", function()
    RaidCD.config.db.serverMode = serverModeCheck:GetChecked()
    RaidCD_OnSettingChanged()
end)

local barDisplayLabel = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
barDisplayLabel:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
y = y - 20
barDisplayLabel:SetText("Bar Display Mode:")
local barDisplayDropdown = CreateFrame("Frame", "RaidCD_BarDisplayMode", scroll, "UIDropDownMenuTemplate")
barDisplayDropdown:SetPoint("TOPLEFT", barDisplayLabel, "BOTTOMLEFT", -12, -4)
y = y - 44

local BAR_DISPLAY_LABELS = {"Show All", "Collapse Players", "Super Compact", "Shotcalling"}
local BAR_DISPLAY_VALUES = {"all", "collapsed", "supercompact", "shotcalling"}

local function UpdateBarDisplayText()
    local idx = 1
    for i, v in ipairs(BAR_DISPLAY_VALUES) do
        if v == RaidCD.config.db.barDisplayMode then idx = i; break end
    end
    UIDropDownMenu_SetText(barDisplayDropdown, BAR_DISPLAY_LABELS[idx])
end

barDisplayDropdown.initialize = function()
    for i, label in ipairs(BAR_DISPLAY_LABELS) do
        UIDropDownMenu_AddButton({
            text = label,
            value = BAR_DISPLAY_VALUES[i],
            checked = RaidCD.config.db.barDisplayMode == BAR_DISPLAY_VALUES[i],
            func = function()
                RaidCD.config.db.barDisplayMode = BAR_DISPLAY_VALUES[i]
                UpdateBarDisplayText()
                RaidCD_OnSettingChanged()
            end
        })
    end
end
UpdateBarDisplayText()

local function SyncCheckboxes()
    enableCheck:SetChecked(RaidCD.config.db.enabled)
    hideSelfCheck:SetChecked(RaidCD.config.db.hideSelf)
    debugCheck:SetChecked(RaidCD.config.db.debug)
    lockCheck:SetChecked(RaidCD.config.db.locked)
    demoCheck:SetChecked(RaidCD.config.db.demoMode)
    serverModeCheck:SetChecked(RaidCD.config.db.serverMode)
    UpdateBarDisplayText()
end

frame:SetScript("OnShow", SyncCheckboxes)
SyncCheckboxes()

InterfaceOptions_AddCategory(frame)
