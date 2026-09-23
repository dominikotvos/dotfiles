-- Keybinds + native ALT/SUPER modifier switching.
-- Replaces keys-alt.conf / keys-super.conf / scripts/modifier_switch.sh
-- (no socat, no jq, no `hyprctl keyword unbind all` churn).

-- Shared with hyprland.lua so the two can never disagree.
local programs = require("programs")

local DIRS = { h = "left", l = "right", k = "up", j = "down" }

-- Builds the full bind set for a given main modifier.
-- Returns a list of bind handles so the set can be enabled/disabled wholesale.
local function build(mod)
    local binds = {}
    local function add(keys, dispatcher, opts)
        binds[#binds + 1] = hl.bind(keys, dispatcher, opts)
    end

    add(mod .. " + RETURN",  hl.dsp.exec_cmd(programs.terminal))
    add(mod .. " + SHIFT + Q", hl.dsp.window.close())
    add(mod .. " + M",       hl.dsp.exit())
    add(mod .. " + E",       hl.dsp.exec_cmd(programs.fileManager))
    add(mod .. " + V",       hl.dsp.window.float({ action = "toggle" }))
    add(mod .. " + D",       hl.dsp.exec_cmd(programs.menu))
    add(mod .. " + P",       hl.dsp.window.pseudo())
    add(mod .. " + F",       hl.dsp.window.fullscreen())
    add(mod .. " + T",       hl.dsp.layout("togglesplit")) -- dwindle only

    -- Noctalia shell. Panel ids are verified against `noctalia msg panel-open`.
    add(mod .. " + C",       hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"))
    add(mod .. " + N",       hl.dsp.exec_cmd("noctalia msg notification-dnd-toggle"))
    add(mod .. " + I",       hl.dsp.exec_cmd("noctalia msg caffeine-toggle"))
    add(mod .. " + W",       hl.dsp.exec_cmd("noctalia msg wallpaper-next"))
    add(mod .. " + Y",       hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
    add(mod .. " + X",       hl.dsp.exec_cmd("noctalia msg panel-toggle session"))

    -- Move focus / move window, vim keys
    for key, dir in pairs(DIRS) do
        add(mod .. " + " .. key,           hl.dsp.focus({ direction = dir }))
        add(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ direction = dir }))
    end

    -- Workspaces 1-10
    for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        add(mod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
        -- follow = false is the lua spelling of movetoworkspacesilent ("silent" is not a real key)
        add(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }))
    end

    add(mod .. " + TAB",       hl.dsp.focus({ workspace = "previous" }))

    -- Special workspace (scratchpad)
    add(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
    add(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Scroll through workspaces
    add(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    add(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    -- Move/resize with mod + LMB/RMB
    add(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    add(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    return binds
end

-- Binds that are identical in both modes: register once, never toggled.
-- Lock stays on SUPER so it survives the ALT/SUPER switch below.
hl.bind("SUPER + L",            hl.dsp.exec_cmd("noctalia msg session lock"))

hl.bind("Print",                hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind("SHIFT + Print",        hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("CTRL + SHIFT + Print", hl.dsp.exec_cmd("grimblast --notify copy area"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up 5"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("noctalia msg volume-mute"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("noctalia msg mic-mute"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl s 10%+"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl s 10%-"),                           { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-----------------------------------------------------------
---- MODIFIER SWITCHING (Lost Ark grabs ALT, so use SUPER)
-----------------------------------------------------------
local SWAP_TO_SUPER = "steam_app_1599340" -- Lost Ark

local sets = { ALT = build("ALT"), SUPER = build("SUPER") }

local function use(mod)
    for name, binds in pairs(sets) do
        local on = (name == mod)
        for _, b in ipairs(binds) do
            b:set_enabled(on)
        end
    end
end

local active = "ALT"
use(active)

hl.on("window.active", function(win)
    local want = "ALT"
    if win then
        -- Properties, not getters. Fallback to "" so a nil can never error:
        -- worst case we stay on ALT.
        local class = win.class or ""
        local title = win.title or ""
        if class:find(SWAP_TO_SUPER, 1, true) or title:find(SWAP_TO_SUPER, 1, true) then
            want = "SUPER"
        end
    end
    if want ~= active then
        active = want
        use(active)
    end
end)
