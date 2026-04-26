# RaidCooldownTracker — WoW WotLK 3.3.5 Addon

A standalone WoW addon tracking raid members' spell cooldowns with live broadcast sync. Target: WotLK 3.3.5 (Interface 30300, Lua 5.1).

## Features

### Cooldown Bars
- Progress bars tracking raid members' spell cooldowns (fill 0→1, green=ready, red=on CD)
- Click a bar to request that spell for the raid
- Shift+click a bar to request that spell for yourself (targeted request)
- Addon message broadcast for cross-player sync (every 5s + instant on cast/ready)
- CLEU SPELL_CAST_SUCCESS detection for instant bar update
- SPELL_UPDATE_COOLDOWN for instant ready detection
- Class headers with color coding
- Four bar display modes: Show All, Collapse Players, Super Compact, Shotcalling

### Bar Display Modes

- **Show All** — individual bars per player per spell
- **Collapse Players** — aggregates by spell, shows count (e.g., "3") or time (e.g., "35s")
- **Super Compact** — like Collapse Players but minimal square bars with icon + count, width scales with bar height
- **Shotcalling** — compact horizontal layout: `[icon] [player] [Xs]` when on CD, `[icon] [player]` when ready (no countdown)

All bar display modes apply to both the main anchor and independent group anchors.

### Request Notification System

Players can request cooldowns via slash commands or by clicking cooldown bars:

**Slash Commands:**
- `/requestcd "Spell Name"` — raid-wide request
- `/requestcd "Spell Name" "Target"` — targeted request for a specific player

**Notification formats:**
- Raid-wide: `Arthas requests Lay on Hands`
- Targeted: `Uther needs Lay on Hands`

**Merging behavior:**
- Raid-wide requests for the same spell merge together (e.g., "3 players request Lay on Hands")
- Targeted requests for the same spell AND same target merge together — each new request refreshes the notification duration instead of spawning duplicates
- Targeted requests for different targets remain separate

**Auto-dismiss:** Targeted notifications auto-dismiss when the spell is cast on the designated player (detected via CLEU combat log).

### Configuration
- Configurable notification duration (1–15 seconds)
- Debug logging toggle
- Position reset / unlock / lock for dragging anchors (including independent group anchors)
- Bar display mode dropdown (Show All / Collapse Players / Super Compact / Shotcalling)
- Bar BG opacity slider

## Slash Commands

| Command | Description |
|---------|-------------|
| `/rcd` or `/rcd config` | Open settings panel |
| `/rcd enable` | Enable addon |
| `/rcd disable` | Disable addon |
| `/rcd reset` | Reset bar anchor to center |
| `/rcd unlock` | Unlock anchors for dragging |
| `/rcd lock` | Lock anchors in place |
| `/rcd showpending` | List pending targeted notifications |
| `/rcd simresolve "Name"` | Simulate resolving a target notification |
| `/requestcd "Spell" ["Target"]` | Send a cooldown request |
| `/reqcd` | Alias for `/requestcd` |

## Architecture

### Project Structure

```
RaidCooldownTracker/
├── RaidCooldownTracker.toc
├── dist/                    # All Lua files (loaded directly, not compiled)
│   ├── core.lua            # Global addon table (RaidCD), shared constants, COLORS
│   ├── config.lua           # SavedVars loading, defaults, slash commands
│   ├── roster.lua           # Roster cache: name → class token, demo roster
│   ├── cooldown.lua         # GetSpellCD, PlayerKnowsSpell, UpdateSelf
│   ├── state.lua            # RaidData store, cleanup stale entries
│   ├── broadcast.lua        # Build/send addon messages
│   ├── comm.lua             # CHAT_MSG_ADDON listener, message parsing
│   ├── events.lua           # CLEU + SPELL_UPDATE_COOLDOWN handlers, ResolveTarget
│   ├── sorting.lua          # Sort entries by class/spell
│   ├── request.lua          # Request notification filter logic
│   └── ui/
│       ├── anchor.lua       # Main draggable anchor frame
│       ├── cooldownBar.lua   # Single bar: StatusBar + icon + texts + click handler
│       ├── barManager.lua    # Frame pool, create/update/hide bars, layout, aggregation
│       ├── notification.lua  # Single notification popup (icon + text)
│       ├── notifManager.lua  # Pool + stack of notification popups, pendingTargets
│       ├── demo.lua          # Demo mode for standalone testing
│       └── settings/
│           ├── panel.lua    # InterfaceOptionsFrame registration, RaidCD_OnSettingChanged
│           ├── general.lua  # Enable, HideSelf, Debug, Lock, Demo, BarDisplayMode dropdown
│           ├── spells.lua   # Tracked spells list (ScrollFrame + add/remove)
│           └── display.lua  # Bar appearance (width, height, spacing, font, opacity)
```

### Module Communication

- `RaidCD` global table created in `core.lua` (loaded first via TOC)
- All modules extend `RaidCD` with their functions

### TOC File Load Order

```
core.lua → config.lua → roster.lua → cooldown.lua → state.lua →
broadcast.lua → comm.lua → events.lua → sorting.lua → request.lua →
ui/anchor.lua → ui/cooldownBar.lua → ui/barManager.lua →
ui/notification.lua → ui/notifManager.lua → ui/demo.lua →
ui/settings/panel.lua → ui/settings/general.lua → ui/settings/spells.lua →
ui/settings/display.lua → index.lua
```


**Request Message Format** (addon communications):
- Raid-wide: `REQ "SpellName"`
- Targeted: `REQ "SpellName" "TargetName"`

### Demo Mode

Standalone demo mode simulates a 10-man raid with random cooldown states and notifications. Useful for testing UI without being in a group. Toggle via settings or `/rcd config`.

## Installation

Copy the entire folder to:
```
WoW/Interface/AddOns/RaidCooldownTracker/
```

Enable the addon in the WoW AddOns screen.

