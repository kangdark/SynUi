--[[
╔══════════════════════════════════════════════════════════════════╗
║                         SynUI.lua                               ║
║              A Modular Lua UI Component Library                  ║
║                                                                  ║
║  Features:                                                       ║
║  • Fully themeable (10 built-in cool themes)                    ║
║  • Modular component system                                      ║
║  • Responsive layout helpers                                     ║
║  • Accessible, keyboard-friendly widgets                         ║
║  • Inline documentation on every function                        ║
╚══════════════════════════════════════════════════════════════════╝

  USAGE:
    local SynUI = require("SynUI")
    SynUI.setTheme("neon_noir")
    local win = SynUI.Window.new({ title = "My App", w = 400, h = 300 })
    local btn = SynUI.Button.new({ label = "Click Me", x = 20, y = 20 })
    win:addChild(btn)
    SynUI.render()
]]

-- ═══════════════════════════════════════════════════════════════
-- MODULE ROOT
-- ═══════════════════════════════════════════════════════════════
local SynUI = {
  _VERSION     = "1.0.0",
  _DESCRIPTION = "SynUI — Modular Lua UI Component Library",
  _LICENSE     = "MIT",
}

-- ═══════════════════════════════════════════════════════════════
-- SECTION 1 — UTILITY HELPERS
-- ═══════════════════════════════════════════════════════════════
local Utils = {}

--- Shallow-merge src into dst (dst wins on conflicts if override=false).
--- @param dst    table  Destination table.
--- @param src    table  Source table whose keys are copied into dst.
--- @param override boolean  When true, src values overwrite dst values.
--- @return table  The mutated dst table.
function Utils.merge(dst, src, override)
  for k, v in pairs(src) do
    if override or dst[k] == nil then
      dst[k] = v
    end
  end
  return dst
end

--- Deep-copy a table (handles nested tables; does NOT copy metatables).
--- @param orig  table  Table to copy.
--- @return table  Independent copy of orig.
function Utils.deepcopy(orig)
  local copy
  if type(orig) == "table" then
    copy = {}
    for k, v in pairs(orig) do
      copy[Utils.deepcopy(k)] = Utils.deepcopy(v)
    end
  else
    copy = orig
  end
  return copy
end

--- Clamp a value between lo and hi.
--- @param val  number  Input value.
--- @param lo   number  Lower bound (inclusive).
--- @param hi   number  Upper bound (inclusive).
--- @return number  Clamped value.
function Utils.clamp(val, lo, hi)
  return math.max(lo, math.min(hi, val))
end

--- Return true if (px, py) is inside the axis-aligned rectangle
--- defined by (rx, ry, rw, rh).
--- @param px number  Point X.
--- @param py number  Point Y.
--- @param rx number  Rect origin X.
--- @param ry number  Rect origin Y.
--- @param rw number  Rect width.
--- @param rh number  Rect height.
--- @return boolean
function Utils.pointInRect(px, py, rx, ry, rw, rh)
  return px >= rx and px <= rx + rw
     and py >= ry and py <= ry + rh
end

--- Split a string by a delimiter.
--- @param str   string  Input string.
--- @param delim string  Single-character delimiter.
--- @return table  Ordered list of tokens.
function Utils.split(str, delim)
  local result = {}
  for part in (str .. delim):gmatch("(.-)" .. delim) do
    result[#result + 1] = part
  end
  return result
end

--- Pad a string to a minimum width with a fill character.
--- @param s     string  Input string.
--- @param width number  Minimum character width.
--- @param char  string  Fill character (default " ").
--- @param right boolean When true, right-align (pad left). Default: left-align.
--- @return string  Padded string.
function Utils.pad(s, width, char, right)
  char = char or " "
  s = tostring(s)
  local diff = width - #s
  if diff <= 0 then return s end
  local padding = string.rep(char, diff)
  return right and (padding .. s) or (s .. padding)
end

SynUI.Utils = Utils


-- ═══════════════════════════════════════════════════════════════
-- SECTION 2 — THEME SYSTEM
-- ═══════════════════════════════════════════════════════════════
--[[
  Each theme is a flat table of semantic color tokens plus typography
  and spacing tokens.  All component defaults reference these tokens,
  so swapping a theme changes the entire visual language at once.

  Color tokens (ANSI 256-color index for terminals, or hex for GUIs):
    bg         — primary background
    bg_alt     — secondary/surface background
    fg         — primary foreground / body text
    fg_muted   — secondary / placeholder text
    accent     — primary brand/action color
    accent_alt — secondary accent (hover, focus rings)
    border     — divider and border color
    success    — positive state
    warning    — cautionary state
    danger     — destructive / error state
    info       — informational state
    selection  — highlighted / selected background
]]

local Themes = {}

-- ── 1. NEON NOIR ─────────────────────────────────────────────
-- Deep midnight background with electric-cyan and hot-pink accents.
-- Inspired by rain-soaked city streets and CRT terminal glow.
Themes["neon_noir"] = {
  name        = "Neon Noir",
  bg          = "#0D0D1A",
  bg_alt      = "#141428",
  fg          = "#E0E0FF",
  fg_muted    = "#6060A0",
  accent      = "#00F5FF",   -- electric cyan
  accent_alt  = "#FF006E",   -- hot pink
  border      = "#2A2A4A",
  success     = "#39FF14",   -- neon green
  warning     = "#FFD600",
  danger      = "#FF1744",
  info        = "#00B0FF",
  selection   = "#1A1A3A",
  -- typography
  font_title  = "JetBrains Mono",
  font_body   = "Inter",
  font_mono   = "JetBrains Mono",
  -- spacing scale (px or terminal cols)
  space_xs    = 4,
  space_sm    = 8,
  space_md    = 16,
  space_lg    = 24,
  space_xl    = 40,
  -- border radius (px; 0 = sharp)
  radius      = 4,
}

-- ── 2. SYNTHWAVE SUNSET ──────────────────────────────────────
-- Purple-to-magenta sky, chrome chrome chrome. 80s VHS palette.
Themes["synthwave"] = {
  name        = "Synthwave Sunset",
  bg          = "#1A0533",
  bg_alt      = "#2D0B5B",
  fg          = "#F8C8FF",
  fg_muted    = "#9060B0",
  accent      = "#FF2D78",   -- neon rose
  accent_alt  = "#FFAA00",   -- chrome gold
  border      = "#4A1880",
  success     = "#00FF9F",
  warning     = "#FF9F00",
  danger      = "#FF2D00",
  info        = "#BD00FF",
  selection   = "#3D0A70",
  font_title  = "Orbitron",
  font_body   = "Rajdhani",
  font_mono   = "Fira Code",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 0,   -- sharp corners = retro grid aesthetic
}

-- ── 3. ARCTIC FROST ─────────────────────────────────────────
-- Icy blues and glacial whites. Clean, cold, surgical.
Themes["arctic_frost"] = {
  name        = "Arctic Frost",
  bg          = "#F0F7FF",
  bg_alt      = "#DEEEFF",
  fg          = "#0A1929",
  fg_muted    = "#546E8A",
  accent      = "#0288D1",   -- ice blue
  accent_alt  = "#00B8D4",   -- teal shimmer
  border      = "#B0CBE4",
  success     = "#00897B",
  warning     = "#F57C00",
  danger      = "#C62828",
  info        = "#1565C0",
  selection   = "#C5E1FF",
  font_title  = "Space Grotesk",
  font_body   = "Inter",
  font_mono   = "JetBrains Mono",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 8,
}

-- ── 4. FOREST TERMINAL ──────────────────────────────────────
-- Deep woodland green. Old-school hacker terminal. Phosphor CRT.
Themes["forest_terminal"] = {
  name        = "Forest Terminal",
  bg          = "#001A00",
  bg_alt      = "#002800",
  fg          = "#33FF33",   -- phosphor green
  fg_muted    = "#1A6600",
  accent      = "#00FF41",
  accent_alt  = "#AAFF00",
  border      = "#004400",
  success     = "#00FF41",
  warning     = "#FFFF00",
  danger      = "#FF3300",
  info        = "#00FFFF",
  selection   = "#003300",
  font_title  = "VT323",
  font_body   = "Courier New",
  font_mono   = "Courier New",
  space_xs=2, space_sm=4, space_md=8, space_lg=16, space_xl=32,
  radius      = 0,
}

-- ── 5. OBSIDIAN GOLD ─────────────────────────────────────────
-- Luxury dark. Matte black with 24-carat gold accents.
Themes["obsidian_gold"] = {
  name        = "Obsidian Gold",
  bg          = "#0A0A0A",
  bg_alt      = "#141414",
  fg          = "#F5F0E8",
  fg_muted    = "#5A5040",
  accent      = "#C9A84C",   -- antique gold
  accent_alt  = "#E8C97A",   -- pale gold
  border      = "#2A2010",
  success     = "#4CAF50",
  warning     = "#C9A84C",
  danger      = "#CF2020",
  info        = "#5090CF",
  selection   = "#201A08",
  font_title  = "Playfair Display",
  font_body   = "EB Garamond",
  font_mono   = "JetBrains Mono",
  space_xs=4, space_sm=8, space_md=20, space_lg=32, space_xl=56,
  radius      = 2,
}

-- ── 6. PASTEL DREAMSCAPE ────────────────────────────────────
-- Soft candy colors. Y2K vaporwave meets lo-fi study session.
Themes["pastel_dream"] = {
  name        = "Pastel Dreamscape",
  bg          = "#FFF0F8",
  bg_alt      = "#FFE0F5",
  fg          = "#4A1060",
  fg_muted    = "#9080A0",
  accent      = "#C084FC",   -- lilac
  accent_alt  = "#60D8D8",   -- mint
  border      = "#E8C0F0",
  success     = "#86EFAC",
  warning     = "#FCD34D",
  danger      = "#F87171",
  info        = "#7DD3FC",
  selection   = "#F3D0FF",
  font_title  = "Nunito",
  font_body   = "Nunito",
  font_mono   = "Fira Code",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 16,  -- very rounded = friendly/cute
}

-- ── 7. SOLARIZED DARK ───────────────────────────────────────
-- The classic Ethan Schoonover palette. Timeless and easy on eyes.
Themes["solarized_dark"] = {
  name        = "Solarized Dark",
  bg          = "#002B36",
  bg_alt      = "#073642",
  fg          = "#839496",
  fg_muted    = "#586E75",
  accent      = "#268BD2",   -- blue
  accent_alt  = "#2AA198",   -- cyan
  border      = "#073642",
  success     = "#859900",
  warning     = "#B58900",
  danger      = "#DC322F",
  info        = "#2AA198",
  selection   = "#073642",
  font_title  = "Source Sans Pro",
  font_body   = "Source Sans Pro",
  font_mono   = "Source Code Pro",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 4,
}

-- ── 8. BLOOD MOON ────────────────────────────────────────────
-- Deep crimson darkness. Gothic, dramatic, high-contrast.
Themes["blood_moon"] = {
  name        = "Blood Moon",
  bg          = "#100000",
  bg_alt      = "#1E0000",
  fg          = "#FFD0C0",
  fg_muted    = "#803030",
  accent      = "#FF2020",   -- blood red
  accent_alt  = "#FF6040",   -- ember orange
  border      = "#3A0000",
  success     = "#40C040",
  warning     = "#FF8800",
  danger      = "#FF0000",
  info        = "#4080FF",
  selection   = "#280000",
  font_title  = "Cinzel",
  font_body   = "Lora",
  font_mono   = "JetBrains Mono",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 2,
}

-- ── 9. DEEP OCEAN ─────────────────────────────────────────────
-- Submarine blues. Bio-luminescent accents. Calm and deep.
Themes["deep_ocean"] = {
  name        = "Deep Ocean",
  bg          = "#000D1A",
  bg_alt      = "#001428",
  fg          = "#A0D8EF",
  fg_muted    = "#305070",
  accent      = "#00C8FF",   -- bioluminescent blue
  accent_alt  = "#00FFCA",   -- sea-green glow
  border      = "#0A2840",
  success     = "#00E5B0",
  warning     = "#FFB800",
  danger      = "#FF4060",
  info        = "#40A0FF",
  selection   = "#001E3A",
  font_title  = "Exo 2",
  font_body   = "Exo 2",
  font_mono   = "Fira Code",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 6,
}

-- ── 10. STONE NEUTRAL ─────────────────────────────────────────
-- Warm grays. Corporate-safe. Zero distraction. Information first.
Themes["stone_neutral"] = {
  name        = "Stone Neutral",
  bg          = "#FAFAF9",
  bg_alt      = "#F1F0EE",
  fg          = "#1C1917",
  fg_muted    = "#78716C",
  accent      = "#0EA5E9",   -- sky blue — the one pop of color
  accent_alt  = "#38BDF8",
  border      = "#D6D3D1",
  success     = "#16A34A",
  warning     = "#D97706",
  danger      = "#DC2626",
  info        = "#0284C7",
  selection   = "#E7E5E4",
  font_title  = "DM Sans",
  font_body   = "DM Sans",
  font_mono   = "DM Mono",
  space_xs=4, space_sm=8, space_md=16, space_lg=24, space_xl=40,
  radius      = 6,
}

-- Active theme (default)
local _activeTheme = Utils.deepcopy(Themes["neon_noir"])

--- List all available built-in theme names.
--- @return table  Array of theme name strings.
function SynUI.listThemes()
  local names = {}
  for k in pairs(Themes) do names[#names+1] = k end
  table.sort(names)
  return names
end

--- Activate a theme by its key.
--- @param key string  One of the built-in theme keys, e.g. "synthwave".
--- @return boolean, string  true on success; false + error message on failure.
function SynUI.setTheme(key)
  if not Themes[key] then
    return false, ("SynUI: unknown theme '%s'"):format(key)
  end
  _activeTheme = Utils.deepcopy(Themes[key])
  return true
end

--- Return the currently active theme table (read-only copy).
--- @return table  Theme token table.
function SynUI.getTheme()
  return Utils.deepcopy(_activeTheme)
end

--- Register a custom theme.  Must contain at least: bg, fg, accent.
--- @param key    string  Unique identifier for the theme.
--- @param theme  table   Token table (see built-in examples for schema).
--- @return boolean, string
function SynUI.registerTheme(key, theme)
  assert(type(key)   == "string", "theme key must be a string")
  assert(type(theme) == "table",  "theme must be a table")
  assert(theme.bg and theme.fg and theme.accent,
    "theme must define at least bg, fg, accent")
  -- Fill any missing tokens from stone_neutral as a safe fallback
  local base = Utils.deepcopy(Themes["stone_neutral"])
  Themes[key] = Utils.merge(theme, base, false)
  return true
end

SynUI.Themes = Themes


-- ═══════════════════════════════════════════════════════════════
-- SECTION 3 — EVENT SYSTEM
-- ═══════════════════════════════════════════════════════════════
--[[
  Lightweight publish-subscribe event bus.
  Components emit events; handlers are registered with :on().
  No external dependencies.
]]

local EventEmitter = {}
EventEmitter.__index = EventEmitter

--- Create a new event emitter instance.
--- @return EventEmitter
function EventEmitter.new()
  return setmetatable({ _handlers = {} }, EventEmitter)
end

--- Register a callback for an event name.
--- @param event    string    Event name (e.g. "click", "change").
--- @param callback function  Function called with (sender, data) when fired.
--- @return EventEmitter  Self, for chaining.
function EventEmitter:on(event, callback)
  assert(type(callback) == "function", "callback must be a function")
  self._handlers[event] = self._handlers[event] or {}
  table.insert(self._handlers[event], callback)
  return self
end

--- Remove a specific callback from an event.
--- @param event    string    Event name.
--- @param callback function  Previously registered callback reference.
function EventEmitter:off(event, callback)
  local list = self._handlers[event]
  if not list then return end
  for i = #list, 1, -1 do
    if list[i] == callback then table.remove(list, i) end
  end
end

--- Fire an event, calling all registered handlers in registration order.
--- @param event  string  Event name.
--- @param data   any     Optional payload passed to each handler.
function EventEmitter:emit(event, data)
  local list = self._handlers[event]
  if not list then return end
  for _, cb in ipairs(list) do cb(self, data) end
end

--- Remove ALL handlers for a specific event (or all events if nil).
--- @param event  string|nil  Event name, or nil to clear everything.
function EventEmitter:clearListeners(event)
  if event then
    self._handlers[event] = nil
  else
    self._handlers = {}
  end
end

SynUI.EventEmitter = EventEmitter


-- ═══════════════════════════════════════════════════════════════
-- SECTION 4 — BASE WIDGET
-- ═══════════════════════════════════════════════════════════════
--[[
  All UI components inherit from Widget.
  Widget handles:
    • Geometry (x, y, w, h)
    • Visibility and enabled state
    • Parent/child hierarchy
    • Event delegation
    • Style overrides layered on top of the active theme
]]

local Widget = {}
Widget.__index = Widget

--- Create a new Widget (base constructor, usually called via super()).
--- @param opts table  {x, y, w, h, visible, enabled, id, style}
--- @return Widget
function Widget.new(opts)
  opts = opts or {}
  local t = _activeTheme
  local self = setmetatable({}, Widget)
  Utils.merge(self, EventEmitter.new())   -- mixin event emitter
  self._handlers = {}                     -- own handler table

  self.id       = opts.id or tostring(self):match("0x%x+") or "widget"
  self.x        = opts.x or 0
  self.y        = opts.y or 0
  self.w        = opts.w or 100
  self.h        = opts.h or 32
  self.visible  = (opts.visible ~= false)
  self.enabled  = (opts.enabled ~= false)
  self.tooltip  = opts.tooltip
  self.children = {}
  self.parent   = nil

  -- Per-widget style overrides (merged with theme at render time)
  self.style    = opts.style or {}

  return self
end

--- Resolve a style token: widget override → active theme → fallback.
--- @param token    string  Theme token key, e.g. "accent".
--- @param fallback any     Value returned when token is absent everywhere.
--- @return any  Resolved value.
function Widget:resolve(token, fallback)
  return self.style[token]
      or _activeTheme[token]
      or fallback
end

--- Add a child widget.  Sets child.parent = self.
--- @param child Widget  Widget to nest inside this one.
--- @return Widget  Self, for chaining.
function Widget:addChild(child)
  child.parent = self
  table.insert(self.children, child)
  return self
end

--- Remove a child widget by reference.
--- @param child Widget  Widget to detach.
function Widget:removeChild(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil
      return
    end
  end
end

--- Move widget to a new position.
--- @param x number  New X coordinate.
--- @param y number  New Y coordinate.
--- @return Widget  Self, for chaining.
function Widget:moveTo(x, y)
  self.x, self.y = x, y
  self:emit("move", { x = x, y = y })
  return self
end

--- Resize widget.
--- @param w number  New width.
--- @param h number  New height.
--- @return Widget  Self, for chaining.
function Widget:resize(w, h)
  self.w, self.h = w, h
  self:emit("resize", { w = w, h = h })
  return self
end

--- Show the widget (visible = true).
function Widget:show()
  self.visible = true
  self:emit("show")
end

--- Hide the widget (visible = false).
function Widget:hide()
  self.visible = false
  self:emit("hide")
end

--- Toggle visibility.
function Widget:toggle()
  if self.visible then self:hide() else self:show() end
end

--- Enable user interaction.
function Widget:enable()
  self.enabled = true
  self:emit("enable")
end

--- Disable user interaction (widget still renders, dimmed).
function Widget:disable()
  self.enabled = false
  self:emit("disable")
end

--- Abstract render method — override in subclasses.
--- @param ctx  table  Drawing context provided by the backend.
function Widget:render(ctx)
  -- Default: render self, then all visible children
  for _, child in ipairs(self.children) do
    if child.visible then child:render(ctx) end
  end
end

--- Hit-test: returns true if (px, py) is inside this widget's bounds.
--- @param px number
--- @param py number
--- @return boolean
function Widget:contains(px, py)
  return Utils.pointInRect(px, py, self.x, self.y, self.w, self.h)
end

--- Dispatch a synthetic mouse event to the deepest matching child.
--- @param event string  "mousedown" | "mouseup" | "mousemove"
--- @param px    number
--- @param py    number
--- @return boolean  true if any widget handled the event.
function Widget:dispatchMouse(event, px, py)
  if not self.visible or not self:contains(px, py) then return false end
  -- depth-first: children on top
  for i = #self.children, 1, -1 do
    if self.children[i]:dispatchMouse(event, px, py) then return true end
  end
  if self.enabled then
    self:emit(event, { x = px, y = py })
    return true
  end
  return false
end

SynUI.Widget = Widget


-- ═══════════════════════════════════════════════════════════════
-- SECTION 5 — LABEL
-- ═══════════════════════════════════════════════════════════════

local Label = setmetatable({}, { __index = Widget })
Label.__index = Label

--- Create a text label.
--- @param opts table  {text, x, y, w, h, align, wrap, style, …Widget opts}
---   align  "left"|"center"|"right" (default "left")
---   wrap   boolean  Wrap text at widget width (default false)
--- @return Label
function Label.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), Label)
  self.text  = opts.text  or ""
  self.align = opts.align or "left"
  self.wrap  = opts.wrap  or false
  return self
end

--- Change the displayed text.
--- @param text string  New label text.
function Label:setText(text)
  local old = self.text
  self.text = text
  if old ~= text then self:emit("change", { old = old, new = text }) end
end

--- Render the label. In a real backend this calls the draw API.
--- Here we emit a "draw" event with a descriptor for the backend.
function Label:render(ctx)
  if not self.visible then return end
  local desc = {
    type   = "label",
    x = self.x, y = self.y, w = self.w, h = self.h,
    text   = self.text,
    align  = self.align,
    wrap   = self.wrap,
    color  = self:resolve("fg", "#FFFFFF"),
    font   = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawLabel then ctx:drawLabel(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.Label = Label


-- ═══════════════════════════════════════════════════════════════
-- SECTION 6 — BUTTON
-- ═══════════════════════════════════════════════════════════════

local Button = setmetatable({}, { __index = Widget })
Button.__index = Button

--- Create a clickable button.
--- @param opts table
---   label    string   Button text.
---   icon     string   Optional icon glyph/emoji prefix.
---   variant  string   "primary"|"secondary"|"ghost"|"danger" (default "primary")
---   onClick  function Shorthand for :on("click", fn).
--- @return Button
function Button.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), Button)
  self.label   = opts.label   or "Button"
  self.icon    = opts.icon    or nil
  self.variant = opts.variant or "primary"
  self._hover  = false
  self._pressed = false

  if opts.onClick then self:on("click", opts.onClick) end

  -- Wire up press/release simulation via mousedown/mouseup
  self:on("mousedown", function(s) s._pressed = true end)
  self:on("mouseup",   function(s, d)
    s._pressed = false
    if s.enabled then s:emit("click", d) end
  end)
  self:on("mousemove", function(s) s._hover = true  end)
  self:on("mouseleave",function(s) s._hover = false; s._pressed = false end)

  return self
end

--- Compute the visual color set for the current state.
--- @return table  {bg, fg, border}
function Button:_colors()
  local t = _activeTheme
  local v = self.variant
  local base_bg, base_fg, base_border

  if v == "primary" then
    base_bg     = self:resolve("accent",  "#007BFF")
    base_fg     = "#FFFFFF"
    base_border = base_bg
  elseif v == "secondary" then
    base_bg     = self:resolve("bg_alt",  "#333333")
    base_fg     = self:resolve("fg",      "#EEEEEE")
    base_border = self:resolve("border",  "#555555")
  elseif v == "ghost" then
    base_bg     = "transparent"
    base_fg     = self:resolve("accent",  "#007BFF")
    base_border = self:resolve("accent",  "#007BFF")
  elseif v == "danger" then
    base_bg     = self:resolve("danger",  "#FF0000")
    base_fg     = "#FFFFFF"
    base_border = base_bg
  else
    base_bg     = self:resolve("accent", "#007BFF")
    base_fg     = "#FFFFFF"
    base_border = base_bg
  end

  if not self.enabled then
    return { bg = self:resolve("bg_alt","#333"), fg = self:resolve("fg_muted","#888"), border = self:resolve("border","#444") }
  end
  if self._pressed then
    -- darken accent_alt on press
    return { bg = self:resolve("accent_alt", base_bg), fg = base_fg, border = base_border }
  end
  if self._hover then
    return { bg = self:resolve("accent_alt", base_bg), fg = base_fg, border = base_border }
  end
  return { bg = base_bg, fg = base_fg, border = base_border }
end

function Button:render(ctx)
  if not self.visible then return end
  local colors = self:_colors()
  local text   = self.icon and (self.icon .. "  " .. self.label) or self.label
  local desc = {
    type    = "button",
    x = self.x, y = self.y, w = self.w, h = self.h,
    text    = text,
    bg      = colors.bg,
    fg      = colors.fg,
    border  = colors.border,
    radius  = self:resolve("radius", 4),
    variant = self.variant,
    enabled = self.enabled,
    hover   = self._hover,
    pressed = self._pressed,
    font    = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawButton then ctx:drawButton(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.Button = Button


-- ═══════════════════════════════════════════════════════════════
-- SECTION 7 — TEXT INPUT
-- ═══════════════════════════════════════════════════════════════

local TextInput = setmetatable({}, { __index = Widget })
TextInput.__index = TextInput

--- Create a single-line text input field.
--- @param opts table
---   value        string   Initial value (default "").
---   placeholder  string   Hint text shown when empty.
---   maxLength    number   Max character count (0 = unlimited).
---   password     boolean  Mask input with •.
---   onSubmit     function Called when user presses Enter/Return.
---   onChange     function Called on every keystroke with new value.
--- @return TextInput
function TextInput.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), TextInput)
  self.value       = opts.value       or ""
  self.placeholder = opts.placeholder or ""
  self.maxLength   = opts.maxLength   or 0
  self.password    = opts.password    or false
  self._focused    = false
  self._cursor     = #self.value      -- cursor position (char index)

  if opts.onSubmit then self:on("submit",  opts.onSubmit) end
  if opts.onChange then self:on("change",  opts.onChange) end

  self:on("mousedown", function(s) s._focused = true  end)
  self:on("focusout",  function(s) s._focused = false end)

  return self
end

--- Programmatically set the input value.
--- @param val string  New value string.
function TextInput:setValue(val)
  if self.maxLength > 0 then
    val = val:sub(1, self.maxLength)
  end
  local old = self.value
  self.value   = val
  self._cursor = #val
  if old ~= val then self:emit("change", { old = old, new = val }) end
end

--- Append a character at the cursor position (simulates typing).
--- @param char string  Single character.
function TextInput:typeChar(char)
  if self.maxLength > 0 and #self.value >= self.maxLength then return end
  local before = self.value:sub(1, self._cursor)
  local after  = self.value:sub(self._cursor + 1)
  local old = self.value
  self.value   = before .. char .. after
  self._cursor = self._cursor + 1
  self:emit("change", { old = old, new = self.value })
end

--- Delete the character before the cursor (Backspace).
function TextInput:backspace()
  if self._cursor == 0 then return end
  local old = self.value
  self.value   = self.value:sub(1, self._cursor - 1) .. self.value:sub(self._cursor + 1)
  self._cursor = self._cursor - 1
  self:emit("change", { old = old, new = self.value })
end

--- Simulate pressing Enter to submit.
function TextInput:submit()
  self:emit("submit", { value = self.value })
end

--- Return display string (masked if password=true).
--- @return string
function TextInput:displayValue()
  if self.password then
    return string.rep("•", #self.value)
  end
  return self.value
end

function TextInput:render(ctx)
  if not self.visible then return end
  local display = self:displayValue()
  if display == "" and not self._focused then display = nil end
  local desc = {
    type        = "textinput",
    x = self.x, y = self.y, w = self.w, h = self.h,
    value       = display,
    placeholder = self.placeholder,
    cursor      = self._cursor,
    focused     = self._focused,
    enabled     = self.enabled,
    bg          = self:resolve("bg_alt",  "#222"),
    fg          = self:resolve("fg",      "#EEE"),
    fg_placeholder = self:resolve("fg_muted", "#888"),
    border      = self._focused
                    and self:resolve("accent",  "#007BFF")
                    or  self:resolve("border",  "#555"),
    radius      = self:resolve("radius", 4),
    font        = self:resolve("font_mono", "monospace"),
  }
  if ctx and ctx.drawTextInput then ctx:drawTextInput(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.TextInput = TextInput


-- ═══════════════════════════════════════════════════════════════
-- SECTION 8 — CHECKBOX
-- ═══════════════════════════════════════════════════════════════

local Checkbox = setmetatable({}, { __index = Widget })
Checkbox.__index = Checkbox

--- Create a checkbox toggle.
--- @param opts table
---   checked   boolean   Initial state (default false).
---   label     string    Inline label text.
---   onChange  function  Called with (sender, {checked}) on toggle.
--- @return Checkbox
function Checkbox.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), Checkbox)
  self.checked  = opts.checked  or false
  self.label    = opts.label    or ""
  self.w        = opts.w or 20
  self.h        = opts.h or 20

  if opts.onChange then self:on("change", opts.onChange) end
  self:on("click", function(s)
    if s.enabled then s:toggle_check() end
  end)
  self:on("mouseup", function(s, d) s:emit("click", d) end)
  return self
end

--- Toggle the checked state.
function Checkbox:toggle_check()
  self.checked = not self.checked
  self:emit("change", { checked = self.checked })
end

--- Programmatically set the checked state.
--- @param state boolean
function Checkbox:setChecked(state)
  if self.checked ~= state then
    self.checked = state
    self:emit("change", { checked = state })
  end
end

function Checkbox:render(ctx)
  if not self.visible then return end
  local desc = {
    type    = "checkbox",
    x = self.x, y = self.y, w = self.w, h = self.h,
    checked = self.checked,
    label   = self.label,
    enabled = self.enabled,
    bg      = self.checked
                and self:resolve("accent",  "#007BFF")
                or  self:resolve("bg_alt",  "#222"),
    fg      = "#FFFFFF",
    border  = self.checked
                and self:resolve("accent",  "#007BFF")
                or  self:resolve("border",  "#555"),
    radius  = self:resolve("radius", 4),
    font    = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawCheckbox then ctx:drawCheckbox(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.Checkbox = Checkbox


-- ═══════════════════════════════════════════════════════════════
-- SECTION 9 — RADIO GROUP
-- ═══════════════════════════════════════════════════════════════

local RadioGroup = setmetatable({}, { __index = Widget })
RadioGroup.__index = RadioGroup

--- Create a group of mutually exclusive radio buttons.
--- @param opts table
---   options   table     Array of {value, label} pairs.
---   selected  string    Initially selected value.
---   direction string    "vertical"|"horizontal" (default "vertical").
---   spacing   number    Pixels between options (default theme space_sm).
---   onChange  function  Called with (sender, {value}) when selection changes.
--- @return RadioGroup
function RadioGroup.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), RadioGroup)
  self.options   = opts.options   or {}
  self.selected  = opts.selected  or (self.options[1] and self.options[1].value)
  self.direction = opts.direction or "vertical"
  self.spacing   = opts.spacing   or _activeTheme.space_sm or 8

  if opts.onChange then self:on("change", opts.onChange) end
  return self
end

--- Programmatically select an option by value.
--- @param value string  The value to select.
function RadioGroup:select(value)
  for _, opt in ipairs(self.options) do
    if opt.value == value then
      local old = self.selected
      self.selected = value
      if old ~= value then
        self:emit("change", { old = old, value = value })
      end
      return true
    end
  end
  return false
end

function RadioGroup:render(ctx)
  if not self.visible then return end
  local desc = {
    type      = "radiogroup",
    x = self.x, y = self.y, w = self.w, h = self.h,
    options   = self.options,
    selected  = self.selected,
    direction = self.direction,
    spacing   = self.spacing,
    enabled   = self.enabled,
    accent    = self:resolve("accent",  "#007BFF"),
    fg        = self:resolve("fg",      "#EEE"),
    bg        = self:resolve("bg_alt",  "#222"),
    border    = self:resolve("border",  "#555"),
    radius    = self:resolve("radius",  4),
    font      = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawRadioGroup then ctx:drawRadioGroup(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.RadioGroup = RadioGroup


-- ═══════════════════════════════════════════════════════════════
-- SECTION 10 — SLIDER
-- ═══════════════════════════════════════════════════════════════

local Slider = setmetatable({}, { __index = Widget })
Slider.__index = Slider

--- Create a range slider.
--- @param opts table
---   min      number   Minimum value (default 0).
---   max      number   Maximum value (default 100).
---   value    number   Initial value (default min).
---   step     number   Increment size (default 1).
---   showVal  boolean  Show current value label (default true).
---   onChange function Called with (sender, {value}) on change.
--- @return Slider
function Slider.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), Slider)
  self.min     = opts.min  or 0
  self.max     = opts.max  or 100
  self.value   = opts.value or self.min
  self.step    = opts.step or 1
  self.showVal = (opts.showVal ~= false)
  self.h       = opts.h or 24
  self._dragging = false

  if opts.onChange then self:on("change", opts.onChange) end
  return self
end

--- Set the slider value, clamped and snapped to step.
--- @param val number  Raw desired value.
function Slider:setValue(val)
  local snapped = math.floor((val - self.min) / self.step + 0.5) * self.step + self.min
  snapped = Utils.clamp(snapped, self.min, self.max)
  local old = self.value
  self.value = snapped
  if old ~= snapped then
    self:emit("change", { old = old, value = snapped })
  end
end

--- Compute the 0-1 normalized fill fraction.
--- @return number  Between 0.0 and 1.0.
function Slider:fraction()
  if self.max == self.min then return 0 end
  return (self.value - self.min) / (self.max - self.min)
end

function Slider:render(ctx)
  if not self.visible then return end
  local desc = {
    type     = "slider",
    x = self.x, y = self.y, w = self.w, h = self.h,
    min      = self.min,
    max      = self.max,
    value    = self.value,
    fraction = self:fraction(),
    showVal  = self.showVal,
    enabled  = self.enabled,
    track_bg = self:resolve("bg_alt",  "#333"),
    fill     = self:resolve("accent",  "#007BFF"),
    thumb    = self:resolve("accent_alt", "#FFFFFF"),
    fg       = self:resolve("fg",      "#EEE"),
    font     = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawSlider then ctx:drawSlider(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.Slider = Slider


-- ═══════════════════════════════════════════════════════════════
-- SECTION 11 — PROGRESS BAR
-- ═══════════════════════════════════════════════════════════════

local ProgressBar = setmetatable({}, { __index = Widget })
ProgressBar.__index = ProgressBar

--- Create a progress bar.
--- @param opts table
---   value      number   Current value (default 0).
---   max        number   Maximum value (default 100).
---   indeterminate boolean  Animated pulse mode (default false).
---   showPct    boolean  Show percentage label (default true).
---   color      string   Override fill color (default accent).
--- @return ProgressBar
function ProgressBar.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), ProgressBar)
  self.value         = opts.value or 0
  self.max           = opts.max   or 100
  self.indeterminate = opts.indeterminate or false
  self.showPct       = (opts.showPct ~= false)
  self.color         = opts.color
  self.h             = opts.h or 16

  return self
end

--- Update progress value.
--- @param val number  New value (clamped to 0..max).
function ProgressBar:setProgress(val)
  self.value = Utils.clamp(val, 0, self.max)
  self:emit("progress", { value = self.value, pct = self:pct() })
end

--- Return the percentage 0-100.
--- @return number
function ProgressBar:pct()
  if self.max == 0 then return 0 end
  return (self.value / self.max) * 100
end

function ProgressBar:render(ctx)
  if not self.visible then return end
  local desc = {
    type          = "progressbar",
    x = self.x, y = self.y, w = self.w, h = self.h,
    value         = self.value,
    max           = self.max,
    pct           = self:pct(),
    indeterminate = self.indeterminate,
    showPct       = self.showPct,
    track         = self:resolve("bg_alt", "#333"),
    fill          = self.color or self:resolve("accent", "#007BFF"),
    fg            = self:resolve("fg", "#EEE"),
    radius        = self:resolve("radius", 4),
    font          = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawProgressBar then ctx:drawProgressBar(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.ProgressBar = ProgressBar


-- ═══════════════════════════════════════════════════════════════
-- SECTION 12 — DROPDOWN / SELECT
-- ═══════════════════════════════════════════════════════════════

local Dropdown = setmetatable({}, { __index = Widget })
Dropdown.__index = Dropdown

--- Create a dropdown selector.
--- @param opts table
---   options   table     Array of {value, label} pairs.
---   selected  string    Initially selected value (default: first option).
---   placeholder string  Text shown when nothing is selected.
---   onChange  function  Called with (sender, {value, label}).
--- @return Dropdown
function Dropdown.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), Dropdown)
  self.options     = opts.options or {}
  self.selected    = opts.selected or (self.options[1] and self.options[1].value)
  self.placeholder = opts.placeholder or "Select…"
  self._open       = false
  self.h           = opts.h or 36

  if opts.onChange then self:on("change", opts.onChange) end
  self:on("click", function(s) s:toggleOpen() end)
  return self
end

--- Open or close the dropdown popover.
function Dropdown:toggleOpen()
  if not self.enabled then return end
  self._open = not self._open
  self:emit(self._open and "open" or "close")
end

--- Select an option by value.
--- @param value string
--- @return boolean  true if found and selected.
function Dropdown:selectOption(value)
  for _, opt in ipairs(self.options) do
    if opt.value == value then
      local old = self.selected
      self.selected = value
      self._open    = false
      if old ~= value then
        self:emit("change", { old = old, value = value, label = opt.label })
      end
      return true
    end
  end
  return false
end

--- Return the currently selected option table, or nil.
--- @return table|nil  {value, label}
function Dropdown:selectedOption()
  for _, opt in ipairs(self.options) do
    if opt.value == self.selected then return opt end
  end
  return nil
end

function Dropdown:render(ctx)
  if not self.visible then return end
  local sel = self:selectedOption()
  local desc = {
    type        = "dropdown",
    x = self.x, y = self.y, w = self.w, h = self.h,
    options     = self.options,
    selected    = self.selected,
    displayText = sel and sel.label or self.placeholder,
    open        = self._open,
    enabled     = self.enabled,
    bg          = self:resolve("bg_alt",  "#222"),
    fg          = self:resolve("fg",      "#EEE"),
    fg_placeholder = self:resolve("fg_muted", "#888"),
    border      = self._open
                    and self:resolve("accent", "#007BFF")
                    or  self:resolve("border", "#555"),
    radius      = self:resolve("radius", 4),
    accent      = self:resolve("accent", "#007BFF"),
    font        = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawDropdown then ctx:drawDropdown(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.Dropdown = Dropdown


-- ═══════════════════════════════════════════════════════════════
-- SECTION 13 — WINDOW / PANEL
-- ═══════════════════════════════════════════════════════════════

local Window = setmetatable({}, { __index = Widget })
Window.__index = Window

--- Create a floating window or panel container.
--- @param opts table
---   title       string   Title bar text.
---   resizable   boolean  Allow drag-resize (default true).
---   draggable   boolean  Allow drag-move (default true).
---   closable    boolean  Show close button (default true).
---   minimizable boolean  Show minimize button (default true).
---   onClose     function Called when the close button is clicked.
--- @return Window
function Window.new(opts)
  opts   = opts or {}
  opts.w = opts.w or 400
  opts.h = opts.h or 300
  local self = setmetatable(Widget.new(opts), Window)
  self.title       = opts.title       or "Window"
  self.resizable   = (opts.resizable   ~= false)
  self.draggable   = (opts.draggable   ~= false)
  self.closable    = (opts.closable    ~= false)
  self.minimizable = (opts.minimizable ~= false)
  self._minimized  = false
  self._titleH     = 32  -- height of title bar in pixels

  if opts.onClose then self:on("close", opts.onClose) end
  return self
end

--- Close (hide) the window and fire "close".
function Window:close()
  self:hide()
  self:emit("close")
end

--- Minimize / restore the window body (title bar stays visible).
function Window:minimize()
  self._minimized = not self._minimized
  self:emit(self._minimized and "minimize" or "restore")
end

function Window:render(ctx)
  if not self.visible then return end
  local desc = {
    type        = "window",
    x = self.x, y = self.y, w = self.w, h = self.h,
    title       = self.title,
    minimized   = self._minimized,
    titleH      = self._titleH,
    closable    = self.closable,
    minimizable = self.minimizable,
    bg          = self:resolve("bg",     "#1A1A2E"),
    bg_alt      = self:resolve("bg_alt", "#141428"),
    fg          = self:resolve("fg",     "#E0E0FF"),
    border      = self:resolve("border", "#2A2A4A"),
    accent      = self:resolve("accent", "#00F5FF"),
    radius      = self:resolve("radius", 4),
    font_title  = self:resolve("font_title", "sans-serif"),
    font_body   = self:resolve("font_body",  "sans-serif"),
  }
  if ctx and ctx.drawWindow then ctx:drawWindow(desc) end
  self:emit("draw", desc)
  if not self._minimized then
    Widget.render(self, ctx)  -- render children
  end
end

SynUI.Window = Window


-- ═══════════════════════════════════════════════════════════════
-- SECTION 14 — TAB BAR
-- ═══════════════════════════════════════════════════════════════

local TabBar = setmetatable({}, { __index = Widget })
TabBar.__index = TabBar

--- Create a horizontal tab bar.
--- @param opts table
---   tabs      table     Array of {id, label, icon?}.
---   activeTab string    ID of initially active tab.
---   onChange  function  Called with (sender, {id}).
--- @return TabBar
function TabBar.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), TabBar)
  self.tabs      = opts.tabs      or {}
  self.activeTab = opts.activeTab or (self.tabs[1] and self.tabs[1].id)
  self.h         = opts.h or 40

  if opts.onChange then self:on("change", opts.onChange) end
  return self
end

--- Switch to a tab by ID.
--- @param id string  Tab ID to activate.
function TabBar:setTab(id)
  for _, tab in ipairs(self.tabs) do
    if tab.id == id then
      local old = self.activeTab
      self.activeTab = id
      if old ~= id then self:emit("change", { old = old, id = id }) end
      return true
    end
  end
  return false
end

function TabBar:render(ctx)
  if not self.visible then return end
  local desc = {
    type      = "tabbar",
    x = self.x, y = self.y, w = self.w, h = self.h,
    tabs      = self.tabs,
    activeTab = self.activeTab,
    bg        = self:resolve("bg",      "#0D0D1A"),
    bg_tab    = self:resolve("bg_alt",  "#141428"),
    bg_active = self:resolve("bg",      "#0D0D1A"),
    fg        = self:resolve("fg_muted","#6060A0"),
    fg_active = self:resolve("accent",  "#00F5FF"),
    border    = self:resolve("border",  "#2A2A4A"),
    indicator = self:resolve("accent",  "#00F5FF"),
    font      = self:resolve("font_body","sans-serif"),
  }
  if ctx and ctx.drawTabBar then ctx:drawTabBar(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.TabBar = TabBar


-- ═══════════════════════════════════════════════════════════════
-- SECTION 15 — TOAST NOTIFICATION
-- ═══════════════════════════════════════════════════════════════

local Toast = setmetatable({}, { __index = Widget })
Toast.__index = Toast

--- Create a transient toast notification.
--- @param opts table
---   message   string   Notification text.
---   variant   string   "success"|"warning"|"danger"|"info" (default "info").
---   duration  number   Auto-dismiss milliseconds (0 = manual, default 3000).
---   position  string   "top"|"bottom"|"top-right"|"bottom-right" (default "bottom").
---   onDismiss function Called when dismissed.
--- @return Toast
function Toast.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), Toast)
  self.message   = opts.message  or ""
  self.variant   = opts.variant  or "info"
  self.duration  = opts.duration or 3000
  self.position  = opts.position or "bottom"
  self._born     = os.clock()
  self.w         = opts.w or 320
  self.h         = opts.h or 52

  if opts.onDismiss then self:on("dismiss", opts.onDismiss) end
  return self
end

--- Compute the semantic color for the current variant.
--- @return string  Hex color string.
function Toast:_variantColor()
  local map = {
    success = self:resolve("success", "#00FF41"),
    warning = self:resolve("warning", "#FFD600"),
    danger  = self:resolve("danger",  "#FF1744"),
    info    = self:resolve("info",    "#00B0FF"),
  }
  return map[self.variant] or map.info
end

--- Manually dismiss the toast.
function Toast:dismiss()
  self:hide()
  self:emit("dismiss")
end

--- Check if the auto-dismiss timer has elapsed.  Call from update loop.
function Toast:tick()
  if self.duration > 0 then
    local elapsed = (os.clock() - self._born) * 1000
    if elapsed >= self.duration then self:dismiss() end
  end
end

function Toast:render(ctx)
  if not self.visible then return end
  local desc = {
    type     = "toast",
    x = self.x, y = self.y, w = self.w, h = self.h,
    message  = self.message,
    variant  = self.variant,
    position = self.position,
    bg       = self:resolve("bg_alt", "#1A1A2E"),
    fg       = self:resolve("fg",     "#E0E0FF"),
    accent   = self:_variantColor(),
    border   = self:_variantColor(),
    radius   = self:resolve("radius", 6),
    font     = self:resolve("font_body","sans-serif"),
  }
  if ctx and ctx.drawToast then ctx:drawToast(desc) end
  self:emit("draw", desc)
end

SynUI.Toast = Toast


-- ═══════════════════════════════════════════════════════════════
-- SECTION 16 — MODAL / DIALOG
-- ═══════════════════════════════════════════════════════════════

local Modal = setmetatable({}, { __index = Widget })
Modal.__index = Modal

--- Create a blocking modal dialog.
--- @param opts table
---   title    string   Dialog title.
---   body     string   Body text or description.
---   buttons  table    Array of {label, variant, value} button specs.
---   onClose  function Called with (sender, {value}) when a button is clicked.
--- @return Modal
function Modal.new(opts)
  opts = opts or {}
  opts.w = opts.w or 480
  opts.h = opts.h or 200
  local self = setmetatable(Widget.new(opts), Modal)
  self.title   = opts.title   or "Dialog"
  self.body    = opts.body    or ""
  self.buttons = opts.buttons or {
    { label = "OK", variant = "primary", value = "ok" }
  }
  self._result = nil

  if opts.onClose then self:on("close", opts.onClose) end
  return self
end

--- Dismiss with a specific button value.
--- @param value any  The value field of the button that was clicked.
function Modal:resolve_dialog(value)
  self._result = value
  self:hide()
  self:emit("close", { value = value })
end

function Modal:render(ctx)
  if not self.visible then return end
  local desc = {
    type    = "modal",
    x = self.x, y = self.y, w = self.w, h = self.h,
    title   = self.title,
    body    = self.body,
    buttons = self.buttons,
    bg      = self:resolve("bg",      "#0D0D1A"),
    bg_overlay = "rgba(0,0,0,0.7)",
    fg      = self:resolve("fg",      "#E0E0FF"),
    border  = self:resolve("border",  "#2A2A4A"),
    accent  = self:resolve("accent",  "#00F5FF"),
    radius  = self:resolve("radius",  6),
    font_title = self:resolve("font_title","sans-serif"),
    font_body  = self:resolve("font_body", "sans-serif"),
  }
  if ctx and ctx.drawModal then ctx:drawModal(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.Modal = Modal


-- ═══════════════════════════════════════════════════════════════
-- SECTION 17 — LIST / TABLE
-- ═══════════════════════════════════════════════════════════════

local ListView = setmetatable({}, { __index = Widget })
ListView.__index = ListView

--- Create a scrollable list or data table.
--- @param opts table
---   columns     table    (Optional) Array of {key, label, width?} column defs.
---   rows        table    Array of row data tables.  Each row indexed by column key.
---   rowHeight   number   Height per row in pixels (default 36).
---   selectable  boolean  Allow row selection (default true).
---   multiSelect boolean  Allow multiple selections (default false).
---   onSelect    function Called with (sender, {indices, rows}) on selection change.
--- @return ListView
function ListView.new(opts)
  opts = opts or {}
  local self = setmetatable(Widget.new(opts), ListView)
  self.columns     = opts.columns    or {}
  self.rows        = opts.rows       or {}
  self.rowHeight   = opts.rowHeight  or 36
  self.selectable  = (opts.selectable  ~= false)
  self.multiSelect = opts.multiSelect or false
  self._selected   = {}   -- set of selected row indices (1-based)
  self._scrollTop  = 0

  if opts.onSelect then self:on("select", opts.onSelect) end
  return self
end

--- Select a row by index (1-based).
--- @param idx     number   Row index.
--- @param additive boolean When true, add to existing selection (multiSelect only).
function ListView:selectRow(idx, additive)
  if not self.selectable then return end
  if not self.multiSelect or not additive then
    self._selected = {}
  end
  if idx >= 1 and idx <= #self.rows then
    self._selected[idx] = true
  end
  self:emit("select", { indices = self:selectedIndices(), rows = self:selectedRows() })
end

--- Deselect all rows.
function ListView:clearSelection()
  self._selected = {}
  self:emit("select", { indices = {}, rows = {} })
end

--- Return sorted array of selected indices.
--- @return table
function ListView:selectedIndices()
  local indices = {}
  for k in pairs(self._selected) do indices[#indices+1] = k end
  table.sort(indices)
  return indices
end

--- Return selected row data tables.
--- @return table  Array of row tables.
function ListView:selectedRows()
  local result = {}
  for _, idx in ipairs(self:selectedIndices()) do
    result[#result+1] = self.rows[idx]
  end
  return result
end

--- Replace the entire dataset.
--- @param rows table  New rows array.
function ListView:setRows(rows)
  self.rows      = rows
  self._selected = {}
  self._scrollTop = 0
  self:emit("datachange", { count = #rows })
end

function ListView:render(ctx)
  if not self.visible then return end
  local desc = {
    type        = "listview",
    x = self.x, y = self.y, w = self.w, h = self.h,
    columns     = self.columns,
    rows        = self.rows,
    rowHeight   = self.rowHeight,
    selected    = self._selected,
    scrollTop   = self._scrollTop,
    bg          = self:resolve("bg",      "#0D0D1A"),
    bg_alt      = self:resolve("bg_alt",  "#141428"),
    bg_selected = self:resolve("selection","#1A1A3A"),
    fg          = self:resolve("fg",      "#E0E0FF"),
    fg_muted    = self:resolve("fg_muted","#6060A0"),
    border      = self:resolve("border",  "#2A2A4A"),
    accent      = self:resolve("accent",  "#00F5FF"),
    radius      = self:resolve("radius",  4),
    font        = self:resolve("font_body","sans-serif"),
    font_mono   = self:resolve("font_mono","monospace"),
  }
  if ctx and ctx.drawListView then ctx:drawListView(desc) end
  self:emit("draw", desc)
  Widget.render(self, ctx)
end

SynUI.ListView = ListView


-- ═══════════════════════════════════════════════════════════════
-- SECTION 18 — LAYOUT HELPERS
-- ═══════════════════════════════════════════════════════════════
--[[
  Layout helpers arrange widgets automatically, removing manual
  coordinate math for common patterns.
]]

local Layout = {}

--- Stack widgets vertically with even spacing.
--- @param widgets  table   Array of Widget instances.
--- @param opts     table   {x, y, spacing, w} — w overrides each widget width.
function Layout.vstack(widgets, opts)
  opts = opts or {}
  local x       = opts.x       or 0
  local y       = opts.y       or 0
  local spacing = opts.spacing or (_activeTheme.space_sm or 8)
  local w       = opts.w

  for _, widget in ipairs(widgets) do
    widget.x = x
    widget.y = y
    if w then widget.w = w end
    y = y + widget.h + spacing
  end
end

--- Stack widgets horizontally with even spacing.
--- @param widgets  table   Array of Widget instances.
--- @param opts     table   {x, y, spacing, h} — h overrides each widget height.
function Layout.hstack(widgets, opts)
  opts = opts or {}
  local x       = opts.x       or 0
  local y       = opts.y       or 0
  local spacing = opts.spacing or (_activeTheme.space_sm or 8)
  local h       = opts.h

  for _, widget in ipairs(widgets) do
    widget.x = x
    widget.y = y
    if h then widget.h = h end
    x = x + widget.w + spacing
  end
end

--- Place widgets in a grid.
--- @param widgets  table   Array of Widget instances (left-to-right, top-to-bottom).
--- @param opts     table   {x, y, cols, colW, rowH, gapX, gapY}
function Layout.grid(widgets, opts)
  opts = opts or {}
  local x0   = opts.x    or 0
  local y0   = opts.y    or 0
  local cols = opts.cols or 2
  local colW = opts.colW or 120
  local rowH = opts.rowH or 40
  local gapX = opts.gapX or (_activeTheme.space_sm or 8)
  local gapY = opts.gapY or (_activeTheme.space_sm or 8)

  for i, widget in ipairs(widgets) do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)
    widget.x = x0 + col * (colW + gapX)
    widget.y = y0 + row * (rowH + gapY)
    widget.w = colW
    widget.h = rowH
  end
end

--- Center a widget within a bounding rect.
--- @param widget   Widget  Widget to center.
--- @param bx number  Bounds X.
--- @param by number  Bounds Y.
--- @param bw number  Bounds width.
--- @param bh number  Bounds height.
function Layout.center(widget, bx, by, bw, bh)
  widget.x = bx + math.floor((bw - widget.w) / 2)
  widget.y = by + math.floor((bh - widget.h) / 2)
end

--- Dock a widget to an edge of a bounding rect.
--- @param widget  Widget  Widget to dock.
--- @param edge    string  "top"|"bottom"|"left"|"right"
--- @param bx number  Bounds X.
--- @param by number  Bounds Y.
--- @param bw number  Bounds width.
--- @param bh number  Bounds height.
--- @param padding number  Inset from the edge (default 0).
function Layout.dock(widget, edge, bx, by, bw, bh, padding)
  padding = padding or 0
  if edge == "top" then
    widget.x, widget.y, widget.w = bx + padding, by + padding, bw - padding * 2
  elseif edge == "bottom" then
    widget.x = bx + padding
    widget.y = by + bh - widget.h - padding
    widget.w = bw - padding * 2
  elseif edge == "left" then
    widget.x, widget.y, widget.h = bx + padding, by + padding, bh - padding * 2
  elseif edge == "right" then
    widget.x = bx + bw - widget.w - padding
    widget.y = by + padding
    widget.h = bh - padding * 2
  end
end

SynUI.Layout = Layout


-- ═══════════════════════════════════════════════════════════════
-- SECTION 19 — SETTINGS PANEL (BUILT-IN THEME SWITCHER)
-- ═══════════════════════════════════════════════════════════════
--[[
  A ready-made Settings window that lets users switch themes at runtime.
  Drop it into any application without extra wiring.
]]

local SettingsPanel = setmetatable({}, { __index = Window })
SettingsPanel.__index = SettingsPanel

--- Create the built-in Settings panel with theme switcher.
--- @param opts table  Passed through to Window.new (x, y, w, h, etc.)
--- @return SettingsPanel
function SettingsPanel.new(opts)
  opts         = opts or {}
  opts.title   = opts.title or "⚙  Settings"
  opts.w       = opts.w or 400
  opts.h       = opts.h or 460
  local self   = setmetatable(Window.new(opts), SettingsPanel)

  -- Build theme options for the radio group
  local themeOpts = {}
  local themeOrder = {
    "neon_noir", "synthwave", "arctic_frost", "forest_terminal",
    "obsidian_gold", "pastel_dream", "solarized_dark",
    "blood_moon", "deep_ocean", "stone_neutral",
  }
  for _, k in ipairs(themeOrder) do
    if Themes[k] then
      themeOpts[#themeOpts+1] = { value = k, label = Themes[k].name }
    end
  end

  -- Section label
  local lbl = Label.new({
    text  = "🎨  Choose Theme",
    x = 16, y = 12, w = 360, h = 24,
    style = { fg = _activeTheme.accent, font_body = _activeTheme.font_title },
  })

  -- Theme radio group
  local radio = RadioGroup.new({
    options   = themeOpts,
    selected  = "neon_noir",
    direction = "vertical",
    spacing   = 2,
    x = 16, y = 44, w = 360, h = 340,
    onChange  = function(sender, data)
      SynUI.setTheme(data.value)
      self:emit("themeChange", { theme = data.value, name = Themes[data.value].name })
    end,
  })
  self._radio = radio

  -- Close / Apply button
  local applyBtn = Button.new({
    label   = "Apply & Close",
    variant = "primary",
    x = 16, y = 400, w = 360, h = 36,
    onClick = function() self:close() end,
  })

  self:addChild(lbl)
  self:addChild(radio)
  self:addChild(applyBtn)

  return self
end

SynUI.SettingsPanel = SettingsPanel


-- ═══════════════════════════════════════════════════════════════
-- SECTION 20 — RENDER ROOT
-- ═══════════════════════════════════════════════════════════════
--[[
  The render root manages a flat list of top-level windows/widgets
  and provides the main render() + update() loop entry points.

  In a real integration, pass a backend ctx table with draw* methods
  that translate descriptor tables into actual draw calls for Love2D,
  Raylib, LÖVE, or whatever renderer you use.
]]

local _roots = {}   -- ordered list of top-level widgets
local _ctx   = nil  -- active drawing context

--- Set the drawing context (backend-specific draw function table).
--- @param ctx table  Must implement drawWindow, drawButton, etc.
function SynUI.setContext(ctx)
  _ctx = ctx
end

--- Add a top-level widget to the render tree.
--- @param widget Widget  Window or other top-level widget.
function SynUI.addRoot(widget)
  _roots[#_roots+1] = widget
end

--- Remove a top-level widget.
--- @param widget Widget
function SynUI.removeRoot(widget)
  for i, w in ipairs(_roots) do
    if w == widget then table.remove(_roots, i); return end
  end
end

--- Render all root widgets in order (back to front).
--- Call this every frame from your game/app loop.
function SynUI.render()
  for _, w in ipairs(_roots) do
    if w.visible then w:render(_ctx) end
  end
end

--- Update all root widgets (tick timers, etc.).
--- Call this every frame before render().
function SynUI.update()
  for _, w in ipairs(_roots) do
    if w.tick then w:tick() end
    -- recurse children that have tick()
    local function tickChildren(widget)
      for _, child in ipairs(widget.children or {}) do
        if child.tick then child:tick() end
        tickChildren(child)
      end
    end
    tickChildren(w)
  end
end

--- Dispatch a mouse event to the root stack (top-most root first).
--- @param event string  "mousedown"|"mouseup"|"mousemove"
--- @param x     number
--- @param y     number
function SynUI.mouse(event, x, y)
  for i = #_roots, 1, -1 do
    if _roots[i]:dispatchMouse(event, x, y) then return end
  end
end


-- ═══════════════════════════════════════════════════════════════
-- SECTION 21 — QUICK FACTORY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
--[[
  Convenience wrappers so common components can be created in one call
  without having to reference the class directly.
]]

--- Show a toast notification (auto-creates, adds to roots, auto-removes).
--- @param message  string
--- @param variant  string  "success"|"warning"|"danger"|"info"
--- @param duration number  Milliseconds (default 3000).
function SynUI.toast(message, variant, duration)
  local t = Toast.new({
    message  = message,
    variant  = variant or "info",
    duration = duration or 3000,
    x = 20, y = 20,
  })
  t:on("dismiss", function(s)
    SynUI.removeRoot(s)
  end)
  SynUI.addRoot(t)
  return t
end

--- Open a confirm dialog and call callback(value) when closed.
--- @param title    string
--- @param body     string
--- @param callback function  Receives the button value string.
function SynUI.confirm(title, body, callback)
  local m = Modal.new({
    title   = title,
    body    = body,
    buttons = {
      { label = "Cancel", variant = "ghost",   value = "cancel" },
      { label = "OK",     variant = "primary",  value = "ok"     },
    },
    x = 100, y = 100,
    onClose = function(_, data)
      SynUI.removeRoot(_)
      if callback then callback(data.value) end
    end,
  })
  SynUI.addRoot(m)
  return m
end

--- Open the built-in Settings panel.
--- @param opts table  Forwarded to SettingsPanel.new.
--- @return SettingsPanel
function SynUI.openSettings(opts)
  local s = SettingsPanel.new(opts or { x = 80, y = 60 })
  SynUI.addRoot(s)
  return s
end


-- ═══════════════════════════════════════════════════════════════
-- SECTION 22 — SELF-TEST  (run with: lua SynUI.lua)
-- ═══════════════════════════════════════════════════════════════

local function selfTest()
  print("╔══════════════════════════════════════════╗")
  print("║       SynUI Self-Test Suite              ║")
  print("╚══════════════════════════════════════════╝")
  local pass, fail = 0, 0
  local function assert_eq(a, b, name)
    if a == b then
      print(("  ✓  %s"):format(name)); pass = pass + 1
    else
      print(("  ✗  %s  [got: %s  expected: %s]"):format(name, tostring(a), tostring(b))); fail = fail + 1
    end
  end

  -- Utils
  assert_eq(Utils.clamp(150, 0, 100), 100,  "clamp upper")
  assert_eq(Utils.clamp(-5,  0, 100), 0,    "clamp lower")
  assert_eq(Utils.clamp(50,  0, 100), 50,   "clamp inside")
  assert_eq(Utils.pointInRect(5, 5, 0, 0, 10, 10), true,  "pointInRect inside")
  assert_eq(Utils.pointInRect(15,5, 0, 0, 10, 10), false, "pointInRect outside")
  assert_eq(Utils.pad("hi", 6), "hi    ", "pad left")
  assert_eq(Utils.pad("hi", 6, " ", true), "    hi", "pad right")

  -- Theme
  local ok, err = SynUI.setTheme("synthwave")
  assert_eq(ok, true, "setTheme valid")
  assert_eq(SynUI.getTheme().name, "Synthwave Sunset", "theme active name")
  local ok2, _ = SynUI.setTheme("__nonexistent__")
  assert_eq(ok2, false, "setTheme invalid returns false")
  SynUI.setTheme("neon_noir")   -- restore

  -- Widget
  local w = Widget.new({ x=10, y=20, w=100, h=50 })
  assert_eq(w.x, 10, "widget x")
  assert_eq(w.contains(w, 50, 40), true,  "widget contains inside")
  assert_eq(w.contains(w, 200, 40), false, "widget contains outside")

  -- Button
  local clicked = false
  local btn = Button.new({ label = "Test", onClick = function() clicked = true end })
  btn:emit("mousedown")
  btn:emit("mouseup")
  assert_eq(clicked, true, "button click fires")

  -- TextInput
  local inp = TextInput.new({ value = "hello" })
  inp:typeChar("!")
  assert_eq(inp.value, "hello!", "textinput typeChar")
  inp:backspace()
  assert_eq(inp.value, "hello", "textinput backspace")

  -- Checkbox
  local cb = Checkbox.new({ checked = false })
  local changed = false
  cb:on("change", function(_, d) changed = d.checked end)
  cb:toggle_check()
  assert_eq(cb.checked, true, "checkbox toggle")
  assert_eq(changed,    true, "checkbox change event")

  -- Slider
  local sl = Slider.new({ min = 0, max = 10, value = 5, step = 2 })
  sl:setValue(7)
  assert_eq(sl.value, 8, "slider step snap")  -- nearest even step

  -- ProgressBar
  local pb = ProgressBar.new({ value = 0, max = 200 })
  pb:setProgress(100)
  assert_eq(pb:pct(), 50, "progressbar pct")

  -- Dropdown
  local dd = Dropdown.new({
    options  = { {value="a", label="Alpha"}, {value="b", label="Beta"} },
    selected = "a",
  })
  dd:selectOption("b")
  assert_eq(dd.selected, "b", "dropdown select")

  -- ListView
  local lv = ListView.new({ rows = { {name="Alice"}, {name="Bob"} } })
  lv:selectRow(2)
  local sel = lv:selectedIndices()
  assert_eq(sel[1], 2, "listview selectRow")

  -- Layout vstack
  local b1 = Widget.new({ w=100, h=40 })
  local b2 = Widget.new({ w=100, h=40 })
  Layout.vstack({b1, b2}, { x=10, y=10, spacing=8 })
  assert_eq(b2.y, 58, "layout vstack y")

  -- EventEmitter
  local emitter = EventEmitter.new()
  local count = 0
  local cb2 = function() count = count + 1 end
  emitter:on("test", cb2)
  emitter:emit("test")
  emitter:emit("test")
  emitter:off("test", cb2)
  emitter:emit("test")
  assert_eq(count, 2, "emitter off")

  -- Theme registration
  SynUI.registerTheme("my_custom", {
    bg = "#111", fg = "#EEE", accent = "#F00",
  })
  SynUI.setTheme("my_custom")
  assert_eq(SynUI.getTheme().accent, "#F00", "custom theme accent")
  SynUI.setTheme("neon_noir")

  -- Summary
  print(("══ %d passed · %d failed ══"):format(pass, fail))
  return fail == 0
end

-- Run self-test when executed directly
if arg and arg[0] and arg[0]:find("SynUI") then
  local ok = selfTest()
  os.exit(ok and 0 or 1)
end


-- ═══════════════════════════════════════════════════════════════
-- PUBLIC API SUMMARY  (for IDE auto-complete / documentation)
-- ═══════════════════════════════════════════════════════════════
--[[
  SynUI.setTheme(key)          → bool, err
  SynUI.getTheme()             → theme table
  SynUI.listThemes()           → string[]
  SynUI.registerTheme(k, t)   → bool

  SynUI.Label.new(opts)
  SynUI.Button.new(opts)
  SynUI.TextInput.new(opts)
  SynUI.Checkbox.new(opts)
  SynUI.RadioGroup.new(opts)
  SynUI.Slider.new(opts)
  SynUI.ProgressBar.new(opts)
  SynUI.Dropdown.new(opts)
  SynUI.Window.new(opts)
  SynUI.TabBar.new(opts)
  SynUI.Toast.new(opts)
  SynUI.Modal.new(opts)
  SynUI.ListView.new(opts)
  SynUI.SettingsPanel.new(opts)

  SynUI.Layout.vstack(widgets, opts)
  SynUI.Layout.hstack(widgets, opts)
  SynUI.Layout.grid(widgets, opts)
  SynUI.Layout.center(widget, bx, by, bw, bh)
  SynUI.Layout.dock(widget, edge, bx, by, bw, bh, padding)

  SynUI.addRoot(widget)
  SynUI.removeRoot(widget)
  SynUI.setContext(ctx)
  SynUI.render()               -- call every frame
  SynUI.update()               -- call every frame (before render)
  SynUI.mouse(event, x, y)     -- forward mouse events

  SynUI.toast(msg, variant, duration)
  SynUI.confirm(title, body, callback)
  SynUI.openSettings(opts)

  SynUI.Utils   — utility helpers
  SynUI.Themes  — raw theme table (read-only intent)
  SynUI.EventEmitter — standalone pub/sub mixin
]]

return SynUI
