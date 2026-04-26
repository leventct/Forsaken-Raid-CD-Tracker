broadcast = {}
broadcast.FormatMessage = function()
    local me = UnitName("player") or "Unknown"
    local selfData = RaidCD.state.raidData[me]
    if selfData == nil then
        return ""
    end
    local parts = {}
    for spellId in pairs(selfData) do
        do
            local __continue4
            repeat
                local entry = selfData[spellId]
                if entry == nil then
                    __continue4 = true
                    break
                end
                table.insert(
                    parts,
                    string.format(
                        "%s|%.2f|%d|%.2f",
                        tostring(spellId),
                        entry.remaining,
                        entry.ready and 1 or 0,
                        entry.duration
                    )
                )
                __continue4 = true
            until true
            if not __continue4 then
                break
            end
        end
    end
    return table.concat(parts, ";")
end
broadcast.Send = function()
    local channel = nil
    if IsInRaid() then
        channel = "RAID"
    elseif IsInGroup() then
        channel = "PARTY"
    end
    if channel == nil then
        return
    end
    local msg = broadcast.FormatMessage()
    if msg == "" then
        return
    end
    SendAddonMessage(RaidCD.PREFIX, msg, channel)
end
RaidCD.broadcast = broadcast
