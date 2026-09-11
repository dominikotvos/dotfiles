-- Hyprland Lua config (migrated from hyprland.conf, hyprlang deprecated since 0.55)
-- https://wiki.hypr.land/Configuring/Start/
--
-- This is the live config: `hyprctl systeminfo` reports `configProvider: lua`.
-- hyprland.conf / keys-alt.conf / keys-super.conf are kept only as historical
-- reference and are NOT read by the compositor or kept in sync.
--
-- Split across: programs.lua (shared program names), monitors.lua (monitor
-- workarounds), keys.lua (keybinds + ALT/SUPER switching).


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1, vrr = false })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "1920x0", scale = 1, vrr = false })

-- Boot-time ws3 render workaround for HDMI-A-1. See the file for the full writeup.
require("monitors")


---------------------
---- MY PROGRAMS ----
---------------------

-- Terminal / file manager / launcher live in programs.lua, shared with keys.lua
-- where the binds that use them are defined.


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("xrandr --output DP-1 --primary")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("noctalia --daemon")
    hl.exec_cmd("vesktop")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    -- Activate graphical-session.target on plain Hyprland so xdg-desktop-portal
    -- (Requisite=graphical-session.target) starts -> screenshare works
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("ssh-agent -D -a " .. (os.getenv("XDG_RUNTIME_DIR") or "") .. "/ssh-agent.socket")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("LIBVA_DRIVERS_PATH", "/usr/lib/dri")
hl.env("VDPAU_DRIVER", "radeonsi")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = 3,
        gaps_out         = 6,

        border_size      = 2,

        col              = {
            active_border   = "rgba(7aa2f7ff)",
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
        -- Required by the cs2-tearing window rule below.
        allow_tearing    = true,

        layout           = "dwindle",
    },

    -- Let fullscreen games bypass the compositor path when possible.
    render = {
        direct_scanout = 2,
    },

    cursor = {
        -- Keep hardware cursors on: a software cursor gets composited into every frame,
        -- which blocks the direct_scanout above (monitors report blocker "SW").
        no_hardware_cursors = false,
        no_break_fs_vrr     = true,
        min_refresh_rate    = 60,
    },

    -- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
    decoration = {
        rounding         = 6,
        rounding_power   = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow           = { enabled = false },

        -- Blur is the only per-frame-expensive effect enabled here. Every game
        -- opts back out via the perf window rules below, which also restore
        -- opaque so the direct_scanout path stays available.
        blur             = {
            enabled           = true,
            size              = 6,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            popups            = true,
            xray              = false,
        },
    },

    -- Off entirely, so the default curves/animation leaves are not defined.
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
    animations = {
        enabled = false,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})


--------------
---- MISC ----
--------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        -- 0, not 2: VRR made the panel track app fps instead of holding 144 in fullscreen.
        -- The HDMI EDID also reports vrr_capable inconsistently between reads.
        vrr                     = 0,
    },
})


---------------
---- INPUT ----
---------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout     = "us",
        kb_variant    = "",
        kb_model      = "",
        kb_options    = "",
        kb_rules      = "",

        follow_mouse  = 1,

        accel_profile = "flat",

        sensitivity   = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad      = {
            natural_scroll = true,
            scroll_factor  = 0.6,
        },
    },

    -- https://wiki.hypr.land/Configuring/Basics/Variables/#gestures
    gestures = {
        workspace_swipe_touch = true,
    },
})

-- Per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
--
-- DualSense touchpad: keep visible to libinput (so games receive click/swipe)
-- but don't drive desktop pointer.
hl.device({
    name    = "dualsense-wireless-controller-touchpad",
    enabled = false,
})


---------------------
---- KEYBINDINGS ----
---------------------

-- Binds plus native ALT/SUPER modifier switching.
require("keys")


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Workspaces are named in kanji so the noctalia bar can label them 一..十 via
-- label_source = "name". Monitor pinning is unchanged: 1, 2, 4 on DP-1 and 3 on
-- HDMI-A-1; 5-10 have no monitor rule and open wherever focus is.
local WS_KANJI   = { "一", "二", "三", "四", "五", "六", "七", "八", "九", "十" }
local WS_MONITOR = { [1] = "DP-1", [2] = "DP-1", [3] = "HDMI-A-1", [4] = "DP-1" }

for i = 1, 10 do
    hl.workspace_rule({
        workspace    = tostring(i),
        monitor      = WS_MONITOR[i],
        default_name = WS_KANJI[i],
    })
end

hl.window_rule({
    name      = "vesktop-ws",
    match     = { class = "^(vesktop)$" },
    workspace = "3 silent",
})

-- Games opt out of every desktop effect. Blur and animations are on globally for
-- the desktop; anything here gets them switched back off, stays opaque, and so
-- keeps the tearing / direct scanout path that general.allow_tearing enables.
for _, g in ipairs({
    { name = "sekiro-perf",     class = "^(sekiro\\.exe)$" },
    { name = "steam-app-perf",  class = "^(steam_app_\\d+)$" },
    { name = "lostark-perf",    class = "^(steam_app_1599340)$" },
}) do
    hl.window_rule({
        name      = g.name,
        match     = { class = g.class },
        no_blur   = true,
        no_shadow = true,
        no_anim   = true,
        opaque    = true,
    })
end

-- CS2: allow tearing for this window (general.allow_tearing above is the global gate).
hl.window_rule({
    name      = "cs2-tearing",
    match     = { title = "Counter-Strike 2" },
    immediate = true,
})

-- Unreal Editor: reduce compositor cost without changing pointer capture behavior.
hl.window_rule({
    name       = "unreal-performance",
    match      = {
        class = "^(UnrealEditor|UE4Editor|UE5Editor)$",
        title = "^.*Unreal Editor.*$",
    },
    no_blur    = true,
    no_shadow  = true,
    no_anim    = true,
    opaque     = true,
    force_rgbx = true,
})

-- Unreal standalone game windows launched from the editor.
-- Keep this separate from the editor rule because game content/immediate mode
-- can break editor viewport pointer capture.
hl.window_rule({
    name            = "unreal-standalone-performance",
    match           = {
        class = "^(UnrealEditor|UE4Editor|UE5Editor)$",
        title = "^.*\\(64-bit.*\\).*$",
    },
    content         = "game",
    no_blur         = true,
    no_shadow       = true,
    no_anim         = true,
    opaque          = true,
    force_rgbx      = true,
    sync_fullscreen = true,
    immediate       = true,
    idle_inhibit    = "fullscreen",
})

hl.window_rule({
    name = "mangayomi",
    match = {
        class = "[Mm]angayomi",
    },

    decorate = false,
    border_size = 0,
    no_shadow = true,
})

-- Godot editor dialogs: all float, centred, pinned to ws4. Only title and size differ.
local GODOT_EDITOR = "^(org\\.godotengine\\.Editor)$"

for _, d in ipairs({
    { name = "godot-project-settings", title = "^(Project Settings).*", size = "1280 720" },
    { name = "godot-editor-settings",  title = "^(Editor Settings).*",  size = "1280 720" },
    { name = "godot-create-node",      title = "^(Create New Node)$",   size = "1340 804" },
    -- Main editor window only (matches initial_title "Godot")
    { name = "godot-editor-main",      title = "^(Godot)$",             size = "1916 1052" },
}) do
    hl.window_rule({
        name = d.name,
        match = { initial_class = GODOT_EDITOR, initial_title = d.title },
        float = true,
        size = d.size,
        center = true,
        workspace = "4",
    })
end

-- Different class, and no initial_title to match on.
hl.window_rule({
    name = "godot-project-manager",
    match = { initial_class = "^(org\\.godotengine\\.ProjectManager)$" },
    float = true,
    size = "1916 1052",
    center = true,
    workspace = "4",
})

-- Godot debug/game window: matches the runtime class, and stays on the current workspace.
hl.window_rule({
    name = "godot-debug-window",
    match = { class = "^(Godot .*)$" },
    float = true,
    size = "1152 648",
    center = true,
})

-- For Noctalia Color templates
require("noctalia").apply_theme()

-- Noctalia's Hyprland template sets inactive_border = surface. At gaps_out = 0 the
-- border is the only seam between tiled windows, so surface-on-surface makes it
-- vanish. Pin it to the palette's outline tone instead. Must stay after the
-- require above, which is what sets the colors in the first place.
hl.config({
    general = {
        col = {
            inactive_border = "rgb(3c434d)",
        },
    },
})
