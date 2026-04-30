RaidCD = {
    VERSION = "1.0.0",
    PREFIX = "WA_RaidCD",
    TICKER_INTERVAL = 3,
    STALE_THRESHOLD = 20,
    BAR_POOL_SIZE = 60,
    NOTIF_POOL_SIZE = 10,
    COLORS = {
        READY = {r = 0.2, g = 0.9, b = 0.2, a = 1.0},
        ON_CD = {r = 0.9, g = 0.2, b = 0.2, a = 1.0},
        BACKGROUND = {r = 0.1, g = 0.1, b = 0.1, a = 0.8},
        TEXT = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},
        DEBUG = "|cFF00CCFF[RaidCD]|r ",
        ERROR = "|cFFFF3333[RaidCD]|r ",
        INFO = "|cFF33CCFF[RaidCD]|r "
    }
}
_G["RaidCD"] = RaidCD

function RaidCD:Log(msg)
    if self.config and self.config.db and self.config.db.debug then
        print(self.COLORS.DEBUG .. tostring(msg))
    end
end

function RaidCD:Error(msg)
    print(self.COLORS.DEBUG .. "[RCD ERROR] " .. msg)
end