--!nonstrict
-- Input-method picker for the bar widget.
--
-- Enumerates methods from ~/.config/fcitx5/profile ([Groups/N/Items/M] blocks),
-- because fcitx5-remote can report the CURRENT method but has no "list" verb.
-- Switching uses `fcitx5-remote -s <name>`.

local LABELS = {
  ["keyboard-us"]      = "English (US)",
  ["keyboard-us-intl"] = "English (Intl)",
  ["keyboard-hu"]      = "Hungarian",
  ["keyboard-jp"]      = "Japanese (kana)",
  ["mozc"]             = "Japanese (Mozc)",
  ["anthy"]            = "Japanese (Anthy)",
  ["kkc"]              = "Japanese (KKC)",
  ["skk"]              = "Japanese (SKK)",
  ["hangul"]           = "Korean",
  ["pinyin"]           = "Chinese (Pinyin)",
  ["rime"]             = "Chinese (Rime)",
}

local SHORT = {
  ["keyboard-us"] = "EN", ["keyboard-us-intl"] = "EN", ["keyboard-hu"] = "HU",
  ["keyboard-jp"] = "JP", ["mozc"] = "あ", ["anthy"] = "あ", ["kkc"] = "あ",
  ["skk"] = "あ", ["hangul"] = "한", ["pinyin"] = "拼", ["rime"] = "中",
}

local methods = {}
local current = ""
local status  = "Reading input methods..."

local function pretty(name)
  return LABELS[name] or name
end

local function short(name)
  return SHORT[name] or string.upper(string.sub(name, 1, 2))
end

local function render()
  local rows = {}

  if #methods == 0 then
    table.insert(rows, ui.label({
      text = status,
      color = "on_surface_variant",
    }))
  end

  for _, name in ipairs(methods) do
    local isCurrent = (name == current)
    table.insert(rows, ui.button({
      text = `{short(name)}   {pretty(name)}`,
      -- the active one reads as filled, the rest stay quiet
      variant = if isCurrent then "primary" else "ghost",
      onClick = function()
        noctalia.runAsync({ "fcitx5-remote", "-s", name }, function(res)
          if res.exitCode == 0 then
            current = name
            render()
            panel.close()
          else
            status = `Could not switch to {name}`
            render()
          end
        end)
      end,
    }))
  end

  panel.render(ui.column({ flexGrow = 1, gap = 12 }, {
    ui.row({ align = "center", justify = "space_between", gap = 8 }, {
      ui.label({ text = "Input method", fontSize = 15, fontWeight = "bold",
                 color = "on_surface", flexGrow = 1 }),
      ui.button({ glyph = "close", onClick = function() panel.close() end }),
    }),
    ui.scroll({ flexGrow = 1, gap = 6, align = "stretch" }, rows),
  }))
end

local function load()
  -- Current method first, so the right row can be highlighted.
  noctalia.runAsync({ "fcitx5-remote", "-n" }, function(res)
    if res.exitCode == 0 then
      current = (string.gsub(res.stdout or "", "%s+$", ""))
    end
    render()
  end)

  noctalia.runAsync({ "cat", noctalia.expandPath("~/.config/fcitx5/profile") }, function(res)
    methods = {}
    if res.exitCode == 0 then
      -- Only Name= lines inside an Items block are input methods; the group's
      -- own Name= must not be picked up, so track which block we are in.
      local inItem = false
      for line in string.gmatch(res.stdout or "", "[^\n]+") do
        if string.match(line, "^%[Groups/%d+/Items/%d+%]") then
          inItem = true
        elseif string.match(line, "^%[") then
          inItem = false
        elseif inItem then
          local name = string.match(line, "^Name=(.+)$")
          if name then
            table.insert(methods, name)
            inItem = false
          end
        end
      end
    end
    if #methods == 0 then
      status = "No input methods found in ~/.config/fcitx5/profile"
    end
    render()
  end)
end

-- Re-read on every open: the profile changes whenever an input method is added
-- or removed, and fcitx5 rewrites it on exit. Reading once at script load left
-- the list stale.
function onOpen(_context)
  load()
  render()
end

load()
render()
