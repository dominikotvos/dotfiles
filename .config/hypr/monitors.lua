-- Monitor recovery workarounds. Required from hyprland.lua's MONITORS section so
-- that section stays declarative.

-- WORKAROUND: HDMI-A-1 does a real DRM connect -> disconnect -> reconnect during boot
-- ("Connector HDMI-A-1 disconnected" / "clearing stale crtc 428" in the log). ws3 is bound
-- to that output, so it migrates to DP-1 and back and returns with its visibility state
-- never re-set: windows report mapped/visible with correct geometry but never render.
-- Cycling the workspace away and back hits the activation path and fixes it for the session.
-- NOT a VRR issue -- vrr_capable flips across reads regardless of the monitor vrr setting.
local function unstick_ws3()
    local ok, m = pcall(hl.get_monitor, "HDMI-A-1")
    if not ok or not m then return end

    local ws = m.active_workspace
    if not ws or ws.id ~= 3 then return end -- user moved it elsewhere; leave it alone

    -- Restore focus afterwards so this is invisible apart from a brief flicker.
    local prev = "DP-1"
    for _, name in ipairs({ "DP-1", "HDMI-A-1" }) do
        local got, mon = pcall(hl.get_monitor, name)
        if got and mon and mon.focused then prev = name end
    end

    hl.dispatch(hl.dsp.focus({ monitor = "HDMI-A-1" }))
    hl.dispatch(hl.dsp.focus({ workspace = 5 }))
    hl.dispatch(hl.dsp.focus({ workspace = 3 }))
    hl.dispatch(hl.dsp.focus({ monitor = prev }))
end

-- Fires on the reconnect rather than guessing at boot timing. Delay lets the mode settle.
hl.on("monitor.added", function()
    hl.timer(unstick_ws3, { timeout = 1500, type = "oneshot" })
end)
