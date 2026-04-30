# Forsaken Raid CD Tracker

A World of Warcraft addon for tracking external raid cooldowns with live broadcast and request notifications. (Interface 30300, Lua 5.1)

## Features

### Cooldown Tracking

- Tracks cooldowns for all classes (Death Knight, Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman, Warlock, Warrior)
- Live broadcast to raid/party members via addon messages
- Automatic detection of spell casts through combat log events

### Display Modes

- **Collapsed** — Aggregates same-name spells, shows one bar per spell with player count
- **Super Compact** — Minimal single-line display
- **Shotcalling** — Raid-focused layout

Custom spell groups can have their own independent anchor, positioned separately from the main display.

### Request System

Players can request cooldowns from others:

- `/requestcd "Spell Name" ["Target"]` — send a request to raid/party
- Configurable filter modes: **Ready** (only available), **Have** (only if tracked), **All**
- Visual notifications with class-colored backgrounds, fading in/out
- Click-to-resolve target and spell notifications

### Buff Tracker

Separate system for tracking consumable and class buffs across the raid:

- Draggable minimap button (persists position across sessions)
- Left-click minimap button to toggle buff tracker window
- Right-click minimap button to open Buffs settings panel
- Table window with player rows and buff group columns
- Active buffs shown as full-color icons with remaining time tooltip
- Missing buffs hidden by default; per-group **Show Inactive** toggle shows them as desaturated icons
- Hover group headers to see which players are missing buffs (respects Show Inactive logic)
- Click group headers to announce missing players to raid/party chat

### Slash Commands

| Command                         | Description                          |
| ------------------------------- | ------------------------------------ |
| `/rcd` or `/raidcd`             | Open settings                        |
| `/rcd enable`                   | Enable addon                         |
| `/rcd disable`                  | Disable addon                        |
| `/rcd reset`                    | Reset anchor position                |
| `/rcd unlock`                   | Unlock anchor for dragging           |
| `/rcd lock`                     | Lock anchor                          |
| `/rcd showpending`              | Debug: show pending request targets  |
| `/rcd simresolve "Target"`      | Debug: resolve a target notification |
| `/requestcd "Spell" ["Target"]` | Request a cooldown from raid/party   |

### Settings Panels

Integrated into Interface Options (right-click anchor or minimap button):

- **General** — Enable/disable, hide self, lock, demo mode, server mode, display mode
- **Display Options** — Bar dimensions, font sizes, notification appearance, opacity
- **Tracked Spells** — Add/remove spells per class or custom group, scope toggle (personal/raid), active toggle, independent anchors
- **Tracked Buffs** — Add/remove buffs per preset/custom group, active toggle, per-group Show Inactive toggle
- **Requests** — Filter mode, notification duration

### Other

- **Server Mode** — Broadcast-only mode, hides all UI (for characters used as broadcast relays)
- Positions and settings saved via SavedVariables (`RaidCooldownTrackerDB`)

## Codebase Structure

```
RaidCooldownTracker/
├── RaidCooldownTracker.toc         # Addon manifest (interface 30300)
├── README.md
└── dist/
    ├── index.lua                   # Entry point, event loop, periodic refresh
    ├── core.lua                    # RaidCD namespace, colors, logging
    ├── config.lua                  # SavedVariables loading, defaults, slash commands
    ├── cooldown.lua                # Spell cooldown API wrappers
    ├── roster.lua                  # Raid/party roster tracking
    ├── state.lua                   # Cooldown state management & shared CD grouping
    ├── broadcast.lua               # Outbound addon message formatting & sending
    ├── comm.lua                    # Inbound addon message handling
    ├── events.lua                  # Combat log & cooldown event handlers
    ├── sorting.lua                 # Sort entries by class, spell, player
    ├── request.lua                 # Incoming cooldown request processing
    ├── ui/
    │   ├── anchor.lua              # Main anchor frame (draggable), independent anchors
    │   ├── cooldownBar.lua         # Individual cooldown bar rendering
    │   ├── barManager.lua          # Bar display manager (all display modes)
    │   ├── notification.lua        # Individual notification frame
    │   ├── notifManager.lua        # Notification lifecycle & fading
    │   ├── demo.lua                # Demo mode (simulated raid)
    │   ├── buffWindow.lua          # Minimap button + buff tracker window
    │   └── settings/
    │       ├── panel.lua           # Root settings panel & scroll helpers
    │       └── widgets/
    │           ├── general.lua     # General settings panel
    │           ├── display.lua     # Display options panel
    │           ├── spells.lua      # Tracked Spells panel
    │           ├── buffs.lua       # Tracked Buffs panel
    │           └── requests.lua    # Request settings panel
```

### Data Flow

1. **Init** (`index.lua`) — On `PLAYER_ENTERING_WORLD`, loads config, restores positions, updates roster, initializes UI and comms
2. **Broadcast** (`state.lua` → `broadcast.lua`) — Every tick, own cooldowns are computed with shared-CD grouping, then broadcast to group
3. **Receive** (`comm.lua` → `state.lua`) — Incoming addon messages update `state.raidData` for remote players
4. **Events** (`events.lua`) — `SPELL_UPDATE_COOLDOWN` and `CLEU` trigger cooldown recalculation and targeted broadcasts
5. **Display** (`barManager.lua`) — Reads `state.raidData`, sorts entries, renders bars anchored to the main anchor or independent anchors
6. **Requests** (`comm.lua` → `request.lua` → `notifManager.lua`) — `REQ` messages are filtered and displayed as clickable notifications
7. **Buffs** (`buffWindow.lua`) — Periodic `UnitBuff` scan on raid/party members, rendered as icon grid in tracker window. Missing player detection per group drives header tooltips and chat announcements

## Installation

Copy the entire folder to:

```
WoW/Interface/AddOns/RaidCooldownTracker/
```

Enable the addon in the WoW AddOns screen.
