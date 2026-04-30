comm = {}
comm.frame = nil
comm.Init = function()
    local existing = _G.RaidCD_CommFrame
    if existing ~= nil then
        existing:UnregisterAllEvents()
        existing:SetScript("OnEvent", nil)
    end
    comm.frame = CreateFrame("Frame", "RaidCD_CommFrame", UIParent)
    comm.frame:RegisterEvent("CHAT_MSG_ADDON")
    comm.frame:SetScript(
        "OnEvent",
        function(frame, event, ...)
            local args = {...}
            if event ~= "CHAT_MSG_ADDON" then
                return
            end
            local prefix, msg, dist, sender = unpack(args, 1, 4)
            if prefix ~= RaidCD.PREFIX then
                return
            end
            local requesterName = string.match(sender, "^([^%-]+)") or sender
            -- Try two-arg form: REQ "Spell" "Target"
            local spell1, target1 = string.match(msg, '^REQ%s+"([^"]+)"%s+"([^"]+)"')
            if spell1 then
                RaidCD.request:HandleRequest(requesterName, spell1, target1)
                return
            end
            -- Try one-arg form: REQ "Spell"
            local spell2 = string.match(msg, '^REQ%s+"([^"]+)"')
            if spell2 then
                RaidCD.request:HandleRequest(requesterName, spell2, nil)
                return
            end
            local parsed = RaidCD.state:HandleMessage(sender, msg)
            if parsed > 0 then
                RaidCD.ui:Refresh()
            end
        end
    )
end
RaidCD.comm = comm
