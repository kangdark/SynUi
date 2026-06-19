# SynUI — Modular Lua UI Component Library

> **Version:** 1.0.0 · **License:** MIT · **Lua:** 5.1 / 5.2 / 5.3 / 5.4 · **Dependencies:** none

```
╔══════════════════════════════════════════════════════════════════╗
║                         SynUI.lua                               ║
║              A Modular Lua UI Component Library                  ║
║                                                                  ║
║  • Fully themeable  (10 built-in cool themes)                   ║
║  • Modular component system                                      ║
║  • Responsive layout helpers                                     ║
║  • Pub/sub event system                                          ║
║  • Inline documentation on every function                        ║
╚══════════════════════════════════════════════════════════════════╝
```

SynUI is a **single-file, dependency-free** Lua UI component library.
It ships a complete widget toolkit — buttons, inputs, modals, sliders, lists, tabs, and more — wired to a backend-agnostic drawing layer so it works with **LÖVE2D, Raylib, terminal renderers, or any custom draw backend**.

---

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Architecture Overview](#architecture-overview)
4. [Theme System](#theme-system)
   - [Built-in Themes](#built-in-themes)
   - [Theme Token Reference](#theme-token-reference)
   - [Custom Themes](#custom-themes)
5. [API Reference](#api-reference)
   - [SynUI (root module)](#synui-root-module)
   - [EventEmitter](#eventemitter)
   - [Widget (base class)](#widget-base-class)
   - [Label](#label)
   - [Button](#button)
   - [TextInput](#textinput)
   - [Checkbox](#checkbox)
   - [RadioGroup](#radiogroup)
   - [Slider](#slider)
   - [ProgressBar](#progressbar)
   - [Dropdown](#dropdown)
   - [Window](#window)
   - [TabBar](#tabbar)
   - [Toast](#toast)
   - [Modal](#modal)
   - [ListView](#listview)
   - [SettingsPanel](#settingspanel)
   - [Layout Helpers](#layout-helpers)
   - [Utils](#utils)
6. [Backend Integration](#backend-integration)
7. [Event System Guide](#event-system-guide)
8. [Examples](#examples)
9. [Running the Self-Test](#running-the-self-test)
10. [Changelog](#changelog)

---

## Installation

Drop `SynUI.lua` anywhere on your Lua path, then require it:

```lua
local SynUI = require("SynUI")
```

No build step. No package manager. No other files needed.

---

## Quick Start

```lua
local SynUI = require("SynUI")

-- 1. Pick a theme
SynUI.setTheme("neon_noir")

-- 2. Create a window
local win = SynUI.Window.new({
  title = "Hello SynUI",
  x = 100, y = 80,
  w = 420, h = 280,
})

-- 3. Add widgets
local label = SynUI.Label.new({
  text = "Enter your name:",
  x = 16, y = 16, w = 380, h = 24,
})

local input = SynUI.TextInput.new({
  placeholder = "Your name…",
  x = 16, y = 48, w = 380, h = 36,
})

local btn = SynUI.Button.new({
  label = "Greet",
  variant = "primary",
  x = 16, y = 100, w = 120, h = 36,
  onClick = function()
    print("Hello, " .. input.value .. "!")
  end,
})

win:addChild(label)
win:addChild(input)
win:addChild(btn)

-- 4. Register in the render tree
SynUI.addRoot(win)

-- 5. In your game/app loop:
--    SynUI.update()   -- every frame, before render
--    SynUI.render()   -- every frame
--    SynUI.mouse("mousedown", x, y)  -- forward mouse events
```

---

## Architecture Overview

```
SynUI
├── Theme System      — token tables, setTheme, registerTheme
├── EventEmitter      — pub/sub mixin (on / off / emit)
├── Widget            — base class (geometry, hierarchy, hit-test)
│   ├── Label
│   ├── Button
│   ├── TextInput
│   ├── Checkbox
│   ├── RadioGroup
│   ├── Slider
│   ├── ProgressBar
│   ├── Dropdown
│   ├── TabBar
│   ├── Toast
│   ├── ListView
│   ├── Modal
│   └── Window
│       └── SettingsPanel
├── Layout            — vstack / hstack / grid / center / dock
├── Utils             — clamp, deepcopy, merge, pad, split, pointInRect
└── Render Root       — addRoot / removeRoot / render / update / mouse
```

**No coupling to any renderer.** Every widget's `render()` method emits
a plain descriptor table via its `"draw"` event AND calls an optional
`ctx.draw*()` method if a context is set. Plug in any draw backend by
implementing those methods (see [Backend Integration](#backend-integration)).

---

## Theme System

### Built-in Themes

| Key | Name | Character |
|---|---|---|
| `neon_noir` | **Neon Noir** | Electric cyan + hot-pink on midnight |
| `synthwave` | **Synthwave Sunset** | 80s VHS, neon rose, chrome gold |
| `arctic_frost` | **Arctic Frost** | Icy blues, glacial whites, surgical |
| `forest_terminal` | **Forest Terminal** | Phosphor-green CRT, zero-radius |
| `obsidian_gold` | **Obsidian Gold** | Matte black, 24k gold accents |
| `pastel_dream` | **Pastel Dreamscape** | Y2K candy, very rounded corners |
| `solarized_dark` | **Solarized Dark** | Classic Schoonover, eye-friendly |
| `blood_moon` | **Blood Moon** | Gothic crimson, high contrast |
| `deep_ocean` | **Deep Ocean** | Bioluminescent submarine blues |
| `stone_neutral` | **Stone Neutral** | Warm grays, information-first |

```lua
-- List all available theme keys
local keys = SynUI.listThemes()
-- → { "arctic_frost", "blood_moon", "deep_ocean", ... }

-- Activate a theme
SynUI.setTheme("synthwave")

-- Read the active theme
local t = SynUI.getTheme()
print(t.name)   -- "Synthwave Sunset"
print(t.accent) -- "#FF2D78"
```

### Theme Token Reference

Every theme exposes these semantic tokens:

| Token | Type | Description |
|---|---|---|
| `name` | string | Display name |
| `bg` | hex | Primary background |
| `bg_alt` | hex | Surface / secondary background |
| `fg` | hex | Primary foreground / body text |
| `fg_muted` | hex | Placeholder / secondary text |
| `accent` | hex | Primary action / brand color |
| `accent_alt` | hex | Hover, focus ring, pressed state |
| `border` | hex | Divider and border color |
| `success` | hex | Positive state |
| `warning` | hex | Cautionary state |
| `danger` | hex | Destructive / error state |
| `info` | hex | Informational state |
| `selection` | hex | Selected row / highlight background |
| `font_title` | string | Display / heading typeface name |
| `font_body` | string | Body copy typeface name |
| `font_mono` | string | Monospace typeface name |
| `space_xs` | number | Spacing unit XS (px / cols) |
| `space_sm` | number | Spacing unit SM |
| `space_md` | number | Spacing unit MD |
| `space_lg` | number | Spacing unit LG |
| `space_xl` | number | Spacing unit XL |
| `radius` | number | Default border-radius (px) |

### Custom Themes

Any subset of the tokens above is valid. Missing tokens fall back to `stone_neutral`.

```lua
SynUI.registerTheme("cyberpunk_red", {
  name       = "Cyberpunk Red",
  bg         = "#0A0000",
  bg_alt     = "#1A0000",
  fg         = "#FFE0D0",
  fg_muted   = "#804040",
  accent     = "#FF1A1A",
  accent_alt = "#FF6600",
  border     = "#3A0000",
  success    = "#00FF88",
  warning    = "#FFAA00",
  danger     = "#FF0000",
  info       = "#4488FF",
  selection  = "#280000",
  radius     = 0,
})

SynUI.setTheme("cyberpunk_red")
```

---

## API Reference

### SynUI (root module)

#### Theme

```lua
-- Activate a theme by key. Returns (true) or (false, errorMsg).
local ok, err = SynUI.setTheme(key: string) → boolean, string?

-- Return a deep-copy of the active theme table.
local theme = SynUI.getTheme() → table

-- Return a sorted array of all registered theme keys.
local keys = SynUI.listThemes() → string[]

-- Register a custom theme. Requires at least bg, fg, accent.
local ok = SynUI.registerTheme(key: string, theme: table) → boolean
```

#### Render Root

```lua
-- Add a top-level widget (Window, Modal, Toast, etc.) to the scene.
SynUI.addRoot(widget: Widget)

-- Remove a top-level widget.
SynUI.removeRoot(widget: Widget)

-- Set the backend drawing context (see Backend Integration).
SynUI.setContext(ctx: table)

-- Render all root widgets. Call every frame.
SynUI.render()

-- Tick timers (Toast auto-dismiss, etc.). Call every frame before render().
SynUI.update()

-- Forward a mouse event to the widget tree (top-most first).
-- event: "mousedown" | "mouseup" | "mousemove"
SynUI.mouse(event: string, x: number, y: number)
```

#### Quick Factories

```lua
-- Show a toast notification. Auto-creates, auto-removes when dismissed.
-- variant: "success" | "warning" | "danger" | "info"
local toast = SynUI.toast(message: string, variant: string?, duration_ms: number?)

-- Open a confirm dialog. Calls callback("ok") or callback("cancel").
local modal = SynUI.confirm(title: string, body: string, callback: function)

-- Open the built-in SettingsPanel (theme switcher).
local panel = SynUI.openSettings(opts: table?)
```

---

### EventEmitter

Standalone pub/sub mixin. All widgets inherit from it.

```lua
local emitter = SynUI.EventEmitter.new()

-- Register a handler. Returns self for chaining.
emitter:on(event: string, callback: function(sender, data)) → emitter

-- Remove a specific handler.
emitter:off(event: string, callback: function)

-- Fire an event. Calls all registered handlers in order.
emitter:emit(event: string, data: any?)

-- Remove all handlers for an event, or all events if nil.
emitter:clearListeners(event: string?)
```

---

### Widget (base class)

All components inherit Widget. You rarely instantiate it directly.

```lua
local w = SynUI.Widget.new({
  id      = "my_widget",   -- optional string identifier
  x       = 0,             -- position X  (default 0)
  y       = 0,             -- position Y  (default 0)
  w       = 100,           -- width        (default 100)
  h       = 32,            -- height       (default 32)
  visible = true,          -- initial visibility
  enabled = true,          -- initial enabled state
  tooltip = "Help text",   -- tooltip string (backend renders)
  style   = {},            -- per-widget theme token overrides
})
```

**Geometry**

```lua
widget:moveTo(x, y)          -- reposition; emits "move"
widget:resize(w, h)          -- resize;     emits "resize"
widget:contains(px, py)      -- → boolean hit-test
```

**Visibility & State**

```lua
widget:show()                -- visible = true;  emits "show"
widget:hide()                -- visible = false; emits "hide"
widget:toggle()              -- toggle visibility
widget:enable()              -- enabled = true;  emits "enable"
widget:disable()             -- enabled = false; emits "disable"
```

**Hierarchy**

```lua
widget:addChild(child)       -- nest a child widget; returns self
widget:removeChild(child)    -- detach a child
```

**Style Overrides**

Per-widget `style` table overrides any theme token for that widget only:

```lua
local btn = SynUI.Button.new({
  label = "Danger!",
  style = {
    accent    = "#FF0000",
    radius    = 0,
    font_body = "Impact",
  },
})
```

**Events emitted by Widget**

| Event | data | Fired when |
|---|---|---|
| `move` | `{x, y}` | `moveTo()` called |
| `resize` | `{w, h}` | `resize()` called |
| `show` | — | `show()` called |
| `hide` | — | `hide()` called |
| `enable` | — | `enable()` called |
| `disable` | — | `disable()` called |
| `draw` | descriptor table | `render()` called |
| `mousedown` | `{x, y}` | Mouse pressed inside bounds |
| `mouseup` | `{x, y}` | Mouse released inside bounds |
| `mousemove` | `{x, y}` | Mouse moved inside bounds |

---

### Label

Static text display.

```lua
local lbl = SynUI.Label.new({
  text  = "Hello World",    -- displayed string
  x=0, y=0, w=200, h=24,
  align = "left",           -- "left" | "center" | "right"
  wrap  = false,            -- word-wrap at widget width
  -- ...Widget opts
})
```

**Methods**

```lua
lbl:setText(text: string)   -- update text; emits "change" {old, new}
```

**Events**

| Event | data |
|---|---|
| `change` | `{old: string, new: string}` |

---

### Button

Clickable push button. Four visual variants.

```lua
local btn = SynUI.Button.new({
  label   = "Save",          -- button text
  icon    = "💾",            -- optional prefix glyph/emoji
  variant = "primary",       -- "primary"|"secondary"|"ghost"|"danger"
  x=0, y=0, w=120, h=36,
  onClick = function(sender, data)
    -- shorthand for :on("click", fn)
  end,
  -- ...Widget opts
})
```

**Variants**

| Variant | Style |
|---|---|
| `primary` | Filled accent color — main action |
| `secondary` | Subtle filled — secondary action |
| `ghost` | Transparent with accent border — tertiary |
| `danger` | Filled danger color — destructive action |

**Events**

| Event | data |
|---|---|
| `click` | `{x, y}` |
| `mousedown` | `{x, y}` |
| `mouseup` | `{x, y}` |

---

### TextInput

Single-line editable text field.

```lua
local inp = SynUI.TextInput.new({
  value       = "",           -- initial value
  placeholder = "Search…",   -- hint text when empty
  maxLength   = 0,            -- max chars; 0 = unlimited
  password    = false,        -- mask with •
  x=0, y=0, w=280, h=36,
  onSubmit = function(sender, data)
    print(data.value)         -- called on Enter
  end,
  onChange = function(sender, data)
    print(data.old, "→", data.new)
  end,
  -- ...Widget opts
})
```

**Methods**

```lua
inp:setValue(val: string)    -- set value programmatically
inp:typeChar(char: string)   -- insert char at cursor
inp:backspace()              -- delete char before cursor
inp:submit()                 -- fire "submit" event
inp:displayValue()           -- → string (masked if password=true)
```

**Events**

| Event | data |
|---|---|
| `change` | `{old: string, new: string}` |
| `submit` | `{value: string}` |

---

### Checkbox

Boolean toggle with inline label.

```lua
local cb = SynUI.Checkbox.new({
  checked  = false,
  label    = "Enable notifications",
  x=0, y=0, w=20, h=20,
  onChange = function(sender, data)
    print(data.checked)
  end,
  -- ...Widget opts
})
```

**Methods**

```lua
cb:toggle_check()            -- flip state; emits "change"
cb:setChecked(state: bool)   -- set state; emits "change" if different
```

**Events**

| Event | data |
|---|---|
| `change` | `{checked: boolean}` |

---

### RadioGroup

Mutually exclusive option set.

```lua
local radio = SynUI.RadioGroup.new({
  options = {
    { value = "sm",  label = "Small"  },
    { value = "md",  label = "Medium" },
    { value = "lg",  label = "Large"  },
  },
  selected  = "md",           -- initial selection
  direction = "vertical",     -- "vertical" | "horizontal"
  spacing   = 8,              -- px between options
  x=0, y=0, w=200, h=120,
  onChange = function(sender, data)
    print(data.value)         -- newly selected value
  end,
  -- ...Widget opts
})
```

**Methods**

```lua
-- Select by value. Returns true if found.
radio:select(value: string) → boolean
```

**Events**

| Event | data |
|---|---|
| `change` | `{old: string, value: string}` |

---

### Slider

Range input with step snapping.

```lua
local sl = SynUI.Slider.new({
  min     = 0,
  max     = 100,
  value   = 50,
  step    = 1,                -- snap increment
  showVal = true,             -- show current value label
  x=0, y=0, w=300, h=24,
  onChange = function(sender, data)
    print(data.value)
  end,
  -- ...Widget opts
})
```

**Methods**

```lua
sl:setValue(val: number)     -- clamp + snap + emits "change"
sl:fraction()                -- → number 0..1 fill ratio
```

**Events**

| Event | data |
|---|---|
| `change` | `{old: number, value: number}` |

---

### ProgressBar

Visual progress indicator.

```lua
local pb = SynUI.ProgressBar.new({
  value         = 0,
  max           = 100,
  indeterminate = false,      -- animated pulse when true
  showPct       = true,       -- show "47%" label
  color         = nil,        -- override fill color (nil = accent)
  x=0, y=0, w=300, h=16,
  -- ...Widget opts
})
```

**Methods**

```lua
pb:setProgress(val: number)  -- update value; emits "progress"
pb:pct()                     -- → number  percentage 0..100
```

**Events**

| Event | data |
|---|---|
| `progress` | `{value: number, pct: number}` |

---

### Dropdown

Single-select popover.

```lua
local dd = SynUI.Dropdown.new({
  options = {
    { value = "en", label = "English"  },
    { value = "id", label = "Bahasa Indonesia" },
    { value = "jp", label = "日本語"   },
  },
  selected    = "en",
  placeholder = "Choose language…",
  x=0, y=0, w=240, h=36,
  onChange = function(sender, data)
    print(data.value, data.label)
  end,
  -- ...Widget opts
})
```

**Methods**

```lua
dd:toggleOpen()                        -- open/close popover
dd:selectOption(value: string)         -- select by value → boolean
dd:selectedOption()                    -- → {value, label} or nil
```

**Events**

| Event | data |
|---|---|
| `open` | — |
| `close` | — |
| `change` | `{old, value, label}` |

---

### Window

Floating container with title bar.

```lua
local win = SynUI.Window.new({
  title       = "My Panel",
  x=100, y=60, w=400, h=300,
  resizable   = true,
  draggable   = true,
  closable    = true,
  minimizable = true,
  onClose     = function(sender)
    print("window closed")
  end,
  -- ...Widget opts
})

win:addChild(someWidget)
```

**Methods**

```lua
win:close()       -- hide + emits "close"
win:minimize()    -- toggle body collapse; emits "minimize" or "restore"
```

**Events**

| Event | data |
|---|---|
| `close` | — |
| `minimize` | — |
| `restore` | — |

---

### TabBar

Horizontal tab navigation.

```lua
local tabs = SynUI.TabBar.new({
  tabs = {
    { id = "general",  label = "General",  icon = "⚙" },
    { id = "network",  label = "Network",  icon = "🌐" },
    { id = "security", label = "Security", icon = "🔒" },
  },
  activeTab = "general",
  x=0, y=0, w=500, h=40,
  onChange = function(sender, data)
    print("switched to", data.id)
  end,
  -- ...Widget opts
})
```

**Methods**

```lua
tabs:setTab(id: string) → boolean   -- activate tab; emits "change"
```

**Events**

| Event | data |
|---|---|
| `change` | `{old: string, id: string}` |

---

### Toast

Auto-dismissing notification.

```lua
-- Quick factory (recommended):
SynUI.toast("File saved!", "success", 3000)

-- Full constructor:
local t = SynUI.Toast.new({
  message  = "Connection lost",
  variant  = "danger",          -- "success"|"warning"|"danger"|"info"
  duration = 5000,              -- ms; 0 = no auto-dismiss
  position = "bottom",          -- "top"|"bottom"|"top-right"|"bottom-right"
  x=20, y=20, w=320, h=52,
  onDismiss = function(sender)
    print("dismissed")
  end,
})
SynUI.addRoot(t)
```

**Methods**

```lua
t:dismiss()     -- hide + emits "dismiss"
t:tick()        -- call from update loop for auto-dismiss
```

**Events**

| Event | data |
|---|---|
| `dismiss` | — |

---

### Modal

Blocking dialog with configurable buttons.

```lua
-- Quick factory (recommended):
SynUI.confirm("Delete file?", "This cannot be undone.", function(value)
  if value == "ok" then
    -- do delete
  end
end)

-- Full constructor:
local m = SynUI.Modal.new({
  title   = "Unsaved Changes",
  body    = "Do you want to save before closing?",
  buttons = {
    { label = "Discard", variant = "ghost",   value = "discard" },
    { label = "Cancel",  variant = "secondary",value = "cancel"  },
    { label = "Save",    variant = "primary",  value = "save"    },
  },
  x=100, y=100, w=480, h=200,
  onClose = function(sender, data)
    print("result:", data.value)  -- "discard" | "cancel" | "save"
  end,
  -- ...Widget opts
})
SynUI.addRoot(m)
```

**Methods**

```lua
m:resolve_dialog(value: any)   -- dismiss with a specific value
```

**Events**

| Event | data |
|---|---|
| `close` | `{value: any}` |

---

### ListView

Scrollable data table with single or multi-row selection.

```lua
local list = SynUI.ListView.new({
  columns = {
    { key = "name",  label = "Name",   width = 180 },
    { key = "email", label = "Email",  width = 240 },
    { key = "role",  label = "Role",   width = 100 },
  },
  rows = {
    { name = "Alice", email = "alice@corp.io", role = "Admin" },
    { name = "Bob",   email = "bob@corp
