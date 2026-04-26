-- Lua Library inline imports
local function __TS__ObjectKeys(obj)
    local result = {}
    local len = 0
    for key in pairs(obj) do
        len = len + 1
        result[len] = key
    end
    return result
end
-- End of Lua Library inline imports
roster = {}
roster.playerClass = {}
roster.demoActive = false
roster.Update = function()
    wipe(roster.playerClass)
    local function addUnit(unitId)
        local name = UnitName(unitId)
        if name == nil then
            return
        end
        local ____, className = UnitClass(unitId)
        if className ~= nil then
            roster.playerClass[name] = className
        end
    end
    addUnit("player")
    do
        local i = 1
        while i <= 4 do
            addUnit("party" .. tostring(i))
            i = i + 1
        end
    end
    do
        local i = 1
        while i <= 40 do
            addUnit("raid" .. tostring(i))
            i = i + 1
        end
    end
end
roster.GetClass = function(____, playerName)
    return roster.playerClass[playerName] or "zzz"
end
roster.InDemoMode = function()
    return roster.demoActive
end
RaidCD.roster = roster
