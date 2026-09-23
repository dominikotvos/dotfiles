--!nonstrict
-- Active fcitx5 input method, rendered as native bar text.
--
-- fcitx5-remote contract (see `fcitx5-remote -h`):
--   (no args)  -> "0" closed, "1" inactive, "2" active
--   -n         -> current input method id, e.g. "keyboard-us", "mozc"
--   -q         -> current input method GROUP name
--   -t         -> toggle active/inactive
--   -g <group> -> switch group
--
-- runAsync's callback result is { exitCode, stdout, stderr, timedOut, ... };
-- there is no .ok field, so exitCode is what we test.

-- Short, legible labels. Anything unmapped falls back to a derived code, so
-- adding a new input method still shows something sensible.
local LABELS = {
  ["keyboard-us"]          = "EN",
  ["keyboard-us-intl"]     = "EN",
  ["keyboard-jp"]          = "JP",
  ["keyboard-hu"]          = "HU",
  ["keyboard-kr"]          = "KR",
  ["mozc"]                 = "あ",
  ["anthy"]                = "あ",
  ["kkc"]                  = "あ",
  ["hangul"]               = "한",
  ["pinyin"]               = "拼",
  ["shuangpin"]            = "拼",
  ["rime"]                 = "中",
}

local method   = ""   -- last method we actually saw (survives focus gaps)
local state    = "1"
local group    = ""
local ready    = false
local hasFocus = true -- false when the focused window has no input context

local function label()
  if not ready then return "--" end
  local mapped = LABELS[method]
  if mapped then return mapped end
  -- "keyboard-us" -> "US"; otherwise first three chars
  local tail = string.match(method, "^keyboard%-(%a+)")
  if tail then return string.upper(tail) end
  if method ~= "" then return string.upper(string.sub(method, 1, 3)) end
  return "?"
end

local function render()
  barWidget.setText(label())
  if not ready then
    barWidget.setTooltip("fcitx5 not running")
  elseif not hasFocus then
    -- Games and some Wayland surfaces never create an input context, so
    -- fcitx5-remote -n comes back empty. Keep showing the last real method
    -- instead of blanking the widget.
    barWidget.setTooltip(`fcitx5: {method} - focused window has no input context (group {group})`)
  else
    local activity = if state == "2" then "active" else "inactive"
    barWidget.setTooltip(`fcitx5: {method} ({activity}) - group {group}`)
  end
end

local function trim(s)
  return (string.gsub(s or "", "%s+$", ""))
end

-- The switcher panel publishes here the instant `fcitx5-remote -s` returns, so
-- the label updates on click rather than on the next poll tick.
noctalia.state.watch("method", function(value)
  if value and value ~= "" then
    method = value
    hasFocus = true
    ready = true
    render()
  end
end)

local ticks = 0

local function poll()
  ticks += 1
  noctalia.runAsync({ "fcitx5-remote", "-n" }, function(res)
    if res.exitCode == 0 then
      ready = true
      local m = trim(res.stdout)
      -- Empty means "no input context on the focused window", NOT "no input
      -- method". Hold the previous value so the widget does not flicker to ?
      -- every time a game or surface without text entry takes focus.
      if m ~= "" then
        method = m
        hasFocus = true
      else
        hasFocus = false
      end
    else
      ready = false
    end
    render()
  end)

  -- Group is focus-independent, so it always answers and gives the tooltip
  -- something true to say even while method is stale. It changes rarely, so
  -- only refresh it every 10th tick rather than on every poll.
  if group == "" or ticks % 10 == 0 then
    noctalia.runAsync({ "fcitx5-remote", "-q" }, function(res)
      if res.exitCode == 0 then
        group = trim(res.stdout)
      end
    end)
  end

  noctalia.runAsync({ "fcitx5-remote" }, function(res)
    if res.exitCode == 0 then
      state = trim(res.stdout)
    end
    render()
  end)
end

function update()
  -- fcitx5 has no change signal we can reach without DBus, so poll. One cheap
  -- exec per second is well under the per-call budget.
  noctalia.setUpdateInterval(500)
  if not noctalia.commandExists("fcitx5-remote") then
    ready = false
    barWidget.setText("--")
    barWidget.setTooltip("fcitx5-remote not on PATH")
    return
  end
  poll()
end

-- Left click: open the picker panel so a method can be chosen directly.
function onClick()
  noctalia.runAsync({ "noctalia", "msg", "panel-toggle", "sleuth/fcitx5:switcher" })
end

-- Right click: quick activate/deactivate of the current method, no panel.
function onRightClick()
  noctalia.runAsync({ "fcitx5-remote", "-t" }, function()
    poll()
  end)
end

-- Shell-triggered refresh, e.g. after changing methods from a script:
--   noctalia msg plugin sleuth/fcitx5:fcitx5 focused refresh
function onIpc(event, _payload)
  if event == "refresh" then
    poll()
  end
end

-- Middle click: reload fcitx5 config, handy after editing profiles.
function onMiddleClick()
  noctalia.runAsync({ "fcitx5-remote", "-r" }, function()
    noctalia.notify("fcitx5", "config reloaded")
    poll()
  end)
end
