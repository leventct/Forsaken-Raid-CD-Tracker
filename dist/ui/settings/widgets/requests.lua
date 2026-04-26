-- RaidCooldownTracker — UI Settings: Requests panel
local function SliderText(s) return _G[s:GetName() .. "Text"] end
local function SliderHigh(s) return _G[s:GetName() .. "High"] end
local function SliderLow(s) return _G[s:GetName() .. "Low"] end
local function SliderValue(s) return _G[s:GetName() .. "Value"] end

local frame = CreateFrame("Frame", "RaidCD_RequestsPanel", UIParent)
frame.name = "Requests"
frame.parent = "RaidCooldownTracker"

local scroll = CreateScrollChild(frame, 300)
local y = -10

local filterLabel = scroll:CreateFontString(nil, "ARTWORK", "GameFontNormal")
filterLabel:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
filterLabel:SetText("Show notifications for:")
y = y - 20

local filterDropdown = CreateFrame("Frame", "RaidCD_FilterDropdown", scroll, "UIDropDownMenuTemplate")
filterDropdown:SetPoint("TOPLEFT", filterLabel, "BOTTOMLEFT", -12, -4)
y = y - 44

local FILTER_LABELS = {"Ready Only", "Have Spell (Ready or Not)", "All Requests"}
local FILTER_VALUES = {"ready", "have", "all"}

local function UpdateFilterText()
    local idx = 1
    for i, v in ipairs(FILTER_VALUES) do
        if v == RaidCD.config.db.reqFilter then idx = i; break end
    end
    UIDropDownMenu_SetText(filterDropdown, FILTER_LABELS[idx])
end

filterDropdown.initialize = function()
    for i, label in ipairs(FILTER_LABELS) do
        UIDropDownMenu_AddButton({
            text = label,
            value = FILTER_VALUES[i],
            checked = RaidCD.config.db.reqFilter == FILTER_VALUES[i],
            func = function()
                RaidCD.config.db.reqFilter = FILTER_VALUES[i]
                UpdateFilterText()
            end
        })
    end
end
UpdateFilterText()

local durSlider = CreateFrame("Slider", "RaidCD_DurSlider", scroll, "OptionsSliderTemplate")
durSlider:SetSize(200, 16)
durSlider:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, y)
durSlider:SetMinMaxValues(1, 15)
durSlider:SetValueStep(1)
durSlider:SetValue(RaidCD.config.db.notifDuration or 5)
SliderText(durSlider):SetText("Notification Duration")
SliderHigh(durSlider):SetText("15s")
SliderLow(durSlider):SetText("1s")
durSlider:SetScript("OnValueChanged", function(s, v)
    RaidCD.config.db.notifDuration = math.floor(v)
    SliderValue(s):SetText(tostring(math.floor(v)) .. "s")
end)
SliderValue(durSlider):SetText(tostring(RaidCD.config.db.notifDuration or 5) .. "s")

y = y - 40

frame:SetScript("OnShow", function()
    UpdateFilterText()
end)

InterfaceOptions_AddCategory(frame)
