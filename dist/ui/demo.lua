-- Lua Library inline imports
local function __TS__ArrayFilter(self, callbackfn, thisArg)
    local result = {}
    local len = 0
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            len = len + 1
            result[len] = self[i]
        end
    end
    return result
end
-- End of Lua Library inline imports
MakeDemoTicker = function(interval, callback)
    local fn = _G.C_Timer.NewTicker
    return fn(interval, callback)
end
DEMO_SPELLS = {
    {id = 1514205, class = "PALADIN"},
    {id = 1106940, class = "PALADIN"},
    {id = 1110278, class = "PALADIN"},
    {id = 1110310, class = "PALADIN"},
    {id = 1131821, class = "PALADIN"},
    {id = 1101038, class = "PALADIN"},
    {id = 1102825, class = "SHAMAN"},
    {id = 1180520, class = "PRIEST"},
    {id = 1133206, class = "PRIEST"},
    {id = 1110060, class = "PRIEST"},
    {id = 1129166, class = "DRUID"},
    {id = 1120748, class = "DRUID"},
    {id = 1157934, class = "ROGUE"}
}
GetDemoSpellName = function(id)
    local info = {GetSpellInfo(id)}
    if info ~= nil and info[1] ~= nil and info[1] ~= "" then
        return info[1]
    end
    return "Spell #" .. tostring(id)
end
DEMO_PLAYERS = {
    {name = "Arthas", class = "DEATH_KNIGHT"},
    {name = "Mograine", class = "DEATH_KNIGHT"},
    {name = "Malfurion", class = "DRUID"},
    {name = "Cenarius", class = "DRUID"},
    {name = "Rexxar", class = "HUNTER"},
    {name = "Alleria", class = "HUNTER"},
    {name = "Jaina", class = "MAGE"},
    {name = "Kaelthas", class = "MAGE"},
    {name = "Uther", class = "PALADIN"},
    {name = "Tirion", class = "PALADIN"},
    {name = "Tyrande", class = "PRIEST"},
    {name = "Velen", class = "PRIEST"},
    {name = "Garona", class = "ROGUE"},
    {name = "Valeera", class = "ROGUE"},
    {name = "Thrall", class = "SHAMAN"},
    {name = "Nobundo", class = "SHAMAN"},
    {name = "Guldan", class = "WARLOCK"},
    {name = "Nerzul", class = "WARLOCK"},
    {name = "Garrosh", class = "WARRIOR"},
    {name = "Saurfang", class = "WARRIOR"}
}
demoTicker = nil
demoPhase = 0
savedRoster = nil
local TARGETS = {"Uther", nil, "Tirion", nil, nil, "Malfurion", nil, nil, "Tyrande", nil, nil, nil}
FireRandomNotif = function()
    local requester = DEMO_PLAYERS[math.random(1, #DEMO_PLAYERS)]
    local spell = DEMO_SPELLS[math.random(1, #DEMO_SPELLS)]
    local spellName = GetDemoSpellName(spell.id)
    local spellInfo = {GetSpellInfo(spell.id)}
    local ____temp_0
    if spellInfo ~= nil and spellInfo[3] ~= nil then
        ____temp_0 = tostring(spellInfo[3])
    else
        ____temp_0 = tostring(134400 + spell.id)
    end
    local iconId = ____temp_0
    local target = TARGETS[math.random(1, #TARGETS)]
    RaidCD.ui.notifManager:ShowNotification(requester.name, spell.id, spellName, iconId, target)
end
StartDemo = function()
    StopDemo()
    savedRoster = {}
    for k in pairs(RaidCD.roster.playerClass) do
        savedRoster[k] = RaidCD.roster.playerClass[k]
    end
    wipe(RaidCD.roster.playerClass)
    wipe(RaidCD.state.raidData)
    RaidCD.roster.demoActive = true
    for ____, p in ipairs(DEMO_PLAYERS) do
        RaidCD.roster.playerClass[p.name] = p.class
    end
    local now = GetTime()
    for ____, player in ipairs(DEMO_PLAYERS) do
        RaidCD.state.raidData[player.name] = {}
        local classSpells = __TS__ArrayFilter(
            DEMO_SPELLS,
            function(____, s) return s.class == player.class end
        )
        for ____, spell in ipairs(classSpells) do
            local ready = math.random(0, 1) == 1
            local duration = math.random(120, 600)
            local remaining = ready and 0 or math.random(5, duration)
            RaidCD.state.raidData[player.name][tostring(spell.id)] = {
                ready = ready,
                remaining = remaining,
                duration = duration,
                lastUpdate = now,
                isSelf = false
            }
        end
    end
    RaidCD.ui:Refresh()
    if RaidCD.config.db.debug then
        print(RaidCD.COLORS.DEBUG .. "Demo mode ON — simulated 10-man raid")
    end
    demoPhase = 0
    FireRandomNotif()
    demoTicker = MakeDemoTicker(
        2,
        function()
            local now2 = GetTime()
            for ____, player in ipairs(DEMO_PLAYERS) do
                do
                    local __continue17
                    repeat
                        local data = RaidCD.state.raidData[player.name]
                        if data == nil then
                            __continue17 = true
                            break
                        end
                        for spellIdStr in pairs(data) do
                            do
                                local __continue19
                                repeat
                                    local entry = data[spellIdStr]
                                    if entry == nil then
                                        __continue19 = true
                                        break
                                    end
                                    local elapsed = now2 - (entry.lastUpdate or now2)
                                    entry.remaining = math.max(0, (entry.remaining or 0) - elapsed)
                                    entry.lastUpdate = now2
                                    if math.random(1, 10) <= 2 then
                                        entry.ready = true
                                        entry.remaining = 0
                                    end
                                    __continue19 = true
                                until true
                                if not __continue19 then
                                    break
                                end
                            end
                        end
                        __continue17 = true
                    until true
                    if not __continue17 then
                        break
                    end
                end
            end
            RaidCD.ui:Refresh()
            demoPhase = demoPhase + 1
            if demoPhase % 2 == 1 then
                local count = math.random(2, 3)
                do
                    local n = 1
                    while n <= count do
                        FireRandomNotif()
                        n = n + 1
                    end
                end
            end
        end
    )
end
StopDemo = function()
    if demoTicker ~= nil then
        demoTicker:Cancel()
        demoTicker = nil
    end
    RaidCD.roster.demoActive = false
    if savedRoster ~= nil then
        wipe(RaidCD.roster.playerClass)
        for k in pairs(savedRoster) do
            RaidCD.roster.playerClass[k] = savedRoster[k]
        end
        savedRoster = nil
    end
    for ____, player in ipairs(DEMO_PLAYERS) do
        RaidCD.state.raidData[player.name] = {}
    end
    RaidCD.ui:Refresh()
    if RaidCD.config.db.debug then
        print(RaidCD.COLORS.DEBUG .. "Demo mode OFF")
    end
end
RaidCD.ui = RaidCD.ui or ({})
RaidCD.ui.DemoStart = StartDemo
RaidCD.ui.DemoStop = StopDemo
