-- Lua Library inline imports
local function __TS__StringIncludes(self, searchString, position)
    if not position then
        position = 1
    else
        position = position + 1
    end
    local index = string.find(self, searchString, position, true)
    return index ~= nil
end

local function __TS__New(target, ...)
    local instance = setmetatable({}, target.prototype)
    instance:____constructor(...)
    return instance
end

local function __TS__Class(self)
    local c = {prototype = {}}
    c.prototype.__index = c.prototype
    c.prototype.constructor = c
    return c
end

local function __TS__ClassExtends(target, base)
    target.____super = base
    local staticMetatable = setmetatable({__index = base}, base)
    setmetatable(target, staticMetatable)
    local baseMetatable = getmetatable(base)
    if baseMetatable then
        if type(baseMetatable.__index) == "function" then
            staticMetatable.__index = baseMetatable.__index
        end
        if type(baseMetatable.__newindex) == "function" then
            staticMetatable.__newindex = baseMetatable.__newindex
        end
    end
    setmetatable(target.prototype, base.prototype)
    if type(base.prototype.__index) == "function" then
        target.prototype.__index = base.prototype.__index
    end
    if type(base.prototype.__newindex) == "function" then
        target.prototype.__newindex = base.prototype.__newindex
    end
    if type(base.prototype.__tostring) == "function" then
        target.prototype.__tostring = base.prototype.__tostring
    end
end

local Error, RangeError, ReferenceError, SyntaxError, TypeError, URIError
do
    local function getErrorStack(self, constructor)
        if debug == nil then
            return nil
        end
        local level = 1
        while true do
            local info = debug.getinfo(level, "f")
            level = level + 1
            if not info then
                level = 1
                break
            elseif info.func == constructor then
                break
            end
        end
        if __TS__StringIncludes(_VERSION, "Lua 5.0") then
            return debug.traceback(("[Level " .. tostring(level)) .. "]")
        elseif _VERSION == "Lua 5.1" then
            return string.sub(
                debug.traceback("", level),
                2
            )
        else
            return debug.traceback(nil, level)
        end
    end
    local function wrapErrorToString(self, getDescription)
        return function(self)
            local description = getDescription(self)
            local caller = debug.getinfo(3, "f")
            local isClassicLua = __TS__StringIncludes(_VERSION, "Lua 5.0")
            if isClassicLua or caller and caller.func ~= error then
                return description
            else
                return (description .. "\n") .. tostring(self.stack)
            end
        end
    end
    local function initErrorClass(self, Type, name)
        Type.name = name
        return setmetatable(
            Type,
            {__call = function(____, _self, message) return __TS__New(Type, message) end}
        )
    end
    local ____initErrorClass_1 = initErrorClass
    local ____class_0 = __TS__Class()
    ____class_0.name = ""
    function ____class_0.prototype.____constructor(self, message)
        if message == nil then
            message = ""
        end
        self.message = message
        self.name = "Error"
        self.stack = getErrorStack(nil, __TS__New)
        local metatable = getmetatable(self)
        if metatable and not metatable.__errorToStringPatched then
            metatable.__errorToStringPatched = true
            metatable.__tostring = wrapErrorToString(nil, metatable.__tostring)
        end
    end
    function ____class_0.prototype.__tostring(self)
        return self.message ~= "" and (self.name .. ": ") .. self.message or self.name
    end
    Error = ____initErrorClass_1(nil, ____class_0, "Error")
    local function createErrorClass(self, name)
        local ____initErrorClass_3 = initErrorClass
        local ____class_2 = __TS__Class()
        ____class_2.name = ____class_2.name
        __TS__ClassExtends(____class_2, Error)
        function ____class_2.prototype.____constructor(self, ...)
            ____class_2.____super.prototype.____constructor(self, ...)
            self.name = name
        end
        return ____initErrorClass_3(nil, ____class_2, name)
    end
    RangeError = createErrorClass(nil, "RangeError")
    ReferenceError = createErrorClass(nil, "ReferenceError")
    SyntaxError = createErrorClass(nil, "SyntaxError")
    TypeError = createErrorClass(nil, "TypeError")
    URIError = createErrorClass(nil, "URIError")
end

local function __TS__ObjectGetOwnPropertyDescriptors(object)
    local metatable = getmetatable(object)
    if not metatable then
        return {}
    end
    return rawget(metatable, "_descriptors") or ({})
end

local function __TS__Delete(target, key)
    local descriptors = __TS__ObjectGetOwnPropertyDescriptors(target)
    local descriptor = descriptors[key]
    if descriptor then
        if not descriptor.configurable then
            error(
                __TS__New(
                    TypeError,
                    ((("Cannot delete property " .. tostring(key)) .. " of ") .. tostring(target)) .. "."
                ),
                0
            )
        end
        descriptors[key] = nil
        return true
    end
    target[key] = nil
    return true
end
-- End of Lua Library inline imports
(function()
    local state = {}
    RaidCD.state = state
    state.raidData = {}
    state.UpdateSelf = function()
        local me = UnitName("player") or "Unknown"
        if state.raidData[me] == nil then
            state.raidData[me] = {}
        end
        local trackedSpells = RaidCD.config.db.trackedSpells
        local knownSpells = {}
        for className in pairs(trackedSpells) do
            local classSpells = trackedSpells[className]
            for ____, spellId in ipairs(classSpells) do
                if RaidCD.cooldown:PlayerKnowsSpell(spellId) then
                    local cd = RaidCD.cooldown:GetSpellCD(spellId)
                    state.raidData[me][spellId] = {
                        ready = cd.ready,
                        remaining = cd.remaining,
                        duration = cd.duration,
                        lastUpdate = GetTime(),
                        isSelf = true
                    }
                    knownSpells[spellId] = true
                end
            end
        end
        for spellId in pairs(state.raidData[me]) do
            if not knownSpells[spellId] then
                state.raidData[me][spellId] = nil
            end
        end
    end
    state.Cleanup = function()
        local now = GetTime()
        local threshold = RaidCD.STALE_THRESHOLD
        for playerName in pairs(state.raidData) do
            local spells = state.raidData[playerName]
            local empty = true
            local toDelete = {}
            for spellId in pairs(spells) do
                local entry = spells[spellId]
                if now - (entry.lastUpdate or 0) > threshold then
                    toDelete[#toDelete + 1] = spellId
                else
                    empty = false
                end
            end
            for i = 1, #toDelete do
                __TS__Delete(spells, toDelete[i])
            end
            if empty then
                __TS__Delete(state.raidData, playerName)
            end
        end
    end
    state.HandleMessage = function(____, sender, message)
        if RaidCD.roster.demoActive then
            return 0
        end
        local playerName = string.match(sender, "^([^%-]+)") or sender
        if playerName == nil or playerName == "" then
            return 0
        end
        local me = UnitName("player") or ""
        if playerName == me then
            return 0
        end
        if state.raidData[playerName] == nil then
            state.raidData[playerName] = {}
        end
        local parsed = 0
        local trackedSet = {}
        local trackedSpells = RaidCD.config.db.trackedSpells
        for className in pairs(trackedSpells) do
            local classSpells = trackedSpells[className]
            for ____, id in ipairs(classSpells) do
                trackedSet[id] = true
            end
        end
        local iter = string.gmatch(message, "[^;]+")
        local entry = iter()
        while entry ~= nil do
            local idStr, remStr, rdyStr, durStr = string.match(entry, "^(%d+)|([%d%.]+)|([01])|([%d%.]+)$")
            if idStr ~= nil then
                local spellId = tonumber(idStr)
                if trackedSet[spellId] then
                    local remaining = tonumber(remStr) or 0
                    local ready = rdyStr == "1"
                    local duration = tonumber(durStr) or 0
                    state.raidData[playerName][spellId] = {
                        ready = ready,
                        remaining = remaining,
                        duration = duration,
                        lastUpdate = GetTime(),
                        isSelf = false
                    }
                    local spellName = GetSpellInfo(spellId)
                    parsed = parsed + 1
                end
            end
            entry = iter()
        end
        return parsed
    end
end)()
