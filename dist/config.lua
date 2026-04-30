-- Lua Library inline imports
local function __TS__StringTrim(self)
    local result = string.gsub(self, "^[%s ﻿]*(.-)[%s ﻿]*$", "%1")
    return result
end
-- End of Lua Library inline imports
MakeDefaults = function() return {
    enabled = true,
    trackedSpells = {
         MAGE = {
            {1145438, scope = "personal", active = false}
        },
        PALADIN = {
            {1514205},{1164205},
            {1106940, scope = "personal"},
            {1110278, scope = "personal", active = false},
            {1110310, scope = "personal"},
            {1131821},
            {1101038, scope = "personal"}
        },
        SHAMAN = {{1102825}, {1181421}, {1116190}, {1132182}},
        PRIEST = {{1180520}, 
        {1133206, scope = "personal"}, 
        {1110060, scope = "personal", active = false}, 
        {1106346, scope = "personal", active = false}, 
        {1180523}, {1164843}, {1164901, active = false}, {2304897, active = false}, {1110890, active = false}},
        DRUID = {{1129166, scope = "personal"}, {1120748, scope = "personal"},{1567851, scope = "personal"}},
        ROGUE = {{1157934, scope = "personal", active = false}},
        WARRIOR = {{1100469, active = false},{1125289, active = false},{1102565, scope = "personal", active = false}, {1100871, scope = "personal", active = false},{1186380, scope = "personal", active = false},{1112975, scope = "personal", active = false}},
    },
    hideSelf = false,
    reqFilter = "ready",
    notifDuration = 5,
    debug = false,
    locked = false,
    position = {point = "CENTER", x = 0, y = 0},
    notifPosition = {point = "TOP", x = 0, y = -200},
    barWidth = 230,
    barHeight = 17,
    barSpacing = 3,
    barTexture = "Interface\\TargetingFrame\\UI-StatusBar",
    showIcons = true,
    fontSize = 12,
    showClassHeaders = true,
    headerSpacing = 4,
    headerFontSize = 11,
    demoMode = false,
    notifWidth = 250,
    notifHeight = 22,
    notifSpacing = 1,
    notifIconSize = 20,
    notifFontSize = 12,
    notifLabelFontSize = 10,
    notifBgColorMode = "spell",
    notifBgOpacity = 0.2,
    barBgOpacity = 0.8,
    hideNotifTitle = false,
    customGroups = {},
    barDisplayMode = "collapsed",
    independentAnchors = {},
    spellScopes = {},
    spellActive = {},
    trackedBuffs = {
        Flask = {968451},
        Food = {22789},
        Potion = {},
        Scroll = {},
        ["Class Buffs"] = {1121564, 1127681, 1121850}
    },
    buffCustomGroups = {},
    buffScopes = {},
    buffActive = {},
    buffShowInactive = {},
    buffDeletedPresets = {},
    buffGroupOrder = {},
    minimapAngle = nil,
    serverMode = false
} end
defaults = MakeDefaults()
config = {
    db = {},
    defaults = defaults,
    Load = function()
        if type(_G.RaidCooldownTrackerDB) ~= "table" then
            _G.RaidCooldownTrackerDB = {}
        end
        local db = _G.RaidCooldownTrackerDB
        local fresh = MakeDefaults()
        for key in pairs(fresh) do
            if db[key] == nil then
                db[key] = fresh[key]
            end
        end
        if type(db.trackedSpells) ~= "table" then
            db.trackedSpells = {}
        end
        if type(db.trackedSpells[1]) == "number" then
            db.trackedSpells = {}
        end
        config.db = db
        if not db.spellScopes then db.spellScopes = {} end
        if not db.spellActive then db.spellActive = {} end
        if not db.trackedBuffs then db.trackedBuffs = fresh.trackedBuffs end
        if not db.buffCustomGroups then db.buffCustomGroups = {} end
        if not db.buffScopes then db.buffScopes = {} end
        if not db.buffActive then db.buffActive = {} end
        for className, spells in pairs(db.trackedSpells) do
            local normalized = {}
            for _, entry in ipairs(spells) do
                if type(entry) == "number" then
                    table.insert(normalized, entry)
                elseif type(entry) == "table" then
                    local spellId = entry[1]
                    table.insert(normalized, spellId)
                    if entry.scope then
                        db.spellScopes[spellId] = entry.scope
                    end
                    if entry.active ~= nil then
                        db.spellActive[spellId] = entry.active
                    end
                end
            end
            db.trackedSpells[className] = normalized
        end
        return config.db
    end,
    Save = function()
        _G.RaidCooldownTrackerDB = config.db
    end
}
RaidCD.config = config
config:Load()
SLASH_RCD1 = "/rcd"
SLASH_RCD2 = "/raidcd"
SLASH_REQUESTCD1 = "/requestcd"
SLASH_REQUESTCD2 = "/reqcd"

SlashCmdList.REQUESTCD = function(msg)
    local args = {}
    for quoted in string.gmatch(msg, '"([^"]*)"') do
        table.insert(args, quoted)
    end

    local spellName = args[1]
    local targetName = args[2]

    if not spellName then
        print(RaidCD.COLORS.ERROR .. "Usage: /requestcd \"Spell Name\" [\"Target\"]")
        return
    end

    local channel = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or nil
    if not channel then
        print(RaidCD.COLORS.ERROR .. "You must be in a raid or party to request cooldowns.")
        return
    end

    local msgToSend = "REQ \"" .. spellName .. "\""
    if targetName then
        msgToSend = msgToSend .. " \"" .. targetName .. "\""
    end

    SendAddonMessage(RaidCD.PREFIX, msgToSend, channel)
    print(RaidCD.COLORS.INFO .. "Request sent: " .. spellName .. (targetName and " for " .. targetName or ""))
end

SlashCmdList.RCD = function(msg)
    local raw = __TS__StringTrim(msg or "")
    local cmd = string.match(raw, "^%S+") or ""
    local rest = string.match(raw, "^%S%s+(.+)")
    local lcmd = string.lower(cmd)
    if lcmd == "" or lcmd == "config" or lcmd == "options" then
        InterfaceOptionsFrame_OpenToCategory("RaidCooldownTracker")
    elseif lcmd == "enable" then
        RaidCD.config.db.enabled = true
    elseif lcmd == "disable" then
        RaidCD.config.db.enabled = false
    elseif lcmd == "reset" then
        RaidCD.config.db.position = {point = "CENTER", x = 0, y = 0}
        if RaidCD.ui and RaidCD.ui.anchor then
            local anchor = RaidCD.ui.anchor
            anchor:ClearAllPoints()
            anchor:SetPoint(
                "CENTER",
                UIParent,
                "CENTER",
                0,
                0
            )
        end
    elseif lcmd == "unlock" then
        RaidCD.config.db.locked = false
        if RaidCD.ui and RaidCD.ui.UpdateAllAnchors then
            RaidCD.ui.UpdateAllAnchors()
        end
    elseif lcmd == "lock" then
        RaidCD.config.db.locked = true
        if RaidCD.ui and RaidCD.ui.UpdateAllAnchors then
            RaidCD.ui.UpdateAllAnchors()
        end
    elseif lcmd == "showpending" then
        if RaidCD.ui and RaidCD.ui.notifManager then
            local count = 0
            for t in pairs(RaidCD.ui.notifManager.pendingTargets) do
                print(RaidCD.COLORS.DEBUG .. "Pending target: " .. tostring(t))
                count = count + 1
            end
            if count == 0 then
                print(RaidCD.COLORS.DEBUG .. "No pending targets")
            end
        end
    elseif lcmd == "simresolve" then
        local target = string.match(rest or "", '"([^"]+)"')
        if not target then
            target = string.match(rest or "", "(%S+)")
        end
        if target then
            if RaidCD.ui and RaidCD.ui.notifManager then
                RaidCD.ui.notifManager:ResolveTarget(target, nil)
            end
        else
            print(RaidCD.COLORS.ERROR .. "Usage: /rcd simresolve \"TargetName\"")
        end
    else
        print(RaidCD.COLORS.DEBUG .. "Commands: /rcd [config|enable|disable|reset|unlock|lock|showpending|simresolve]")
    end
end
