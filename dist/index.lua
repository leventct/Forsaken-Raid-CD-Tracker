Init = function()
    RaidCD.config:Load()
    local restore = RaidCD.ui.RestorePosition
    if restore ~= nil then
        restore()
    end
    RaidCD.roster:Update()
    RaidCD.state:UpdateSelf()
    RaidCD.comm:Init()
    RaidCD.events:Init()
    RaidCD.ui.barManager:Init()
    RaidCD.ui.notifManager:Init()
    local spellCount = 0
    for cls in pairs(RaidCD.config.db.trackedSpells) do
        local classSpells = RaidCD.config.db.trackedSpells[cls]
        spellCount = spellCount + #classSpells
    end
end
mainFrame = _G.RaidCD_MainFrame
if mainFrame ~= nil then
    mainFrame:UnregisterAllEvents()
    mainFrame:SetScript("OnEvent", nil)
    mainFrame:SetScript("OnUpdate", nil)
    eventFrame = mainFrame
else
    eventFrame = CreateFrame("Frame", "RaidCD_MainFrame", UIParent)
end
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript(
    "OnEvent",
    function(frame, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            Init()
        elseif event == "GROUP_ROSTER_UPDATE" then
            if not RaidCD.roster.demoActive then
                RaidCD.roster:Update()
                RaidCD.state:UpdateSelf()
                RaidCD.ui:Refresh()
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
        end
    end
)
lastBroadcast = 0
lastRefresh = 0
eventFrame:SetScript(
    "OnUpdate",
    function(frame, elapsed)
        if not RaidCD.config.db.enabled then
            return
        end
        if RaidCD.roster.demoActive then
            return
        end
        local now = GetTime()
        if now - lastRefresh >= 1 then
            if RaidCD.ui and RaidCD.ui.Refresh then
                RaidCD.ui:Refresh()
            end
            lastRefresh = now
        end
        if now - lastBroadcast >= RaidCD.TICKER_INTERVAL then
            RaidCD.state:UpdateSelf()
            RaidCD.broadcast:Send()
            RaidCD.state:Cleanup()
            lastBroadcast = now
        end
    end
)
