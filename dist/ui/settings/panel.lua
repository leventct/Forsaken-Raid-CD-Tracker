-- RaidCooldownTracker — Settings: parent panel + global helpers
local mainPanel = CreateFrame("Frame", "RaidCD_MainPanel", UIParent)
mainPanel.name = "RaidCooldownTracker"
local mainTitle = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
mainTitle:SetPoint("TOPLEFT", mainPanel, "TOPLEFT", 16, -16)
mainTitle:SetText("RaidCooldownTracker " .. RaidCD.VERSION)
local mainSub = mainPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
mainSub:SetPoint("TOPLEFT", mainTitle, "BOTTOMLEFT", 0, -4)
mainSub:SetText("Track external raid cooldowns with live broadcast.")
InterfaceOptions_AddCategory(mainPanel)

function RaidCD_OnSettingChanged()
    if RaidCD.ui and RaidCD.ui.Refresh then
        RaidCD.ui:Refresh()
    end
end

function CreateScrollChild(parent, height)
    local scrollName = parent:GetName() .. "Scroll"
    local scroll = CreateFrame("ScrollFrame", scrollName, parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -36, 16)
    local childName = parent:GetName() .. "ScrollChild"
    local child = CreateFrame("Frame", childName, scroll)
    child:SetSize(550, height)
    scroll:SetScrollChild(child)
    return child
end
