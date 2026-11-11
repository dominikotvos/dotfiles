--!nonstrict
-- Active Hyprland submap, shown like i3bar's binding-mode indicator.
--
-- Hyprland pushes changes from keys.lua (hl.on "keybinds.submap"):
--   noctalia msg plugin sleuth/submap:submap all set <name>
-- An empty name or "default" means no submap, and the widget hides.

local function show(name)
  if name == nil or name == "" or name == "default" then
    barWidget.setVisible(false)
    return
  end
  barWidget.setText(string.upper(name))
  barWidget.setColor("error")
  barWidget.setTooltip(`Hyprland submap: {name} - Esc/Return to leave`)
  barWidget.setVisible(true)
end

-- Start hidden, then ask Hyprland once so a noctalia restart mid-submap still
-- shows the right state. `hyprctl submap` prints "default" when none is active.
show("")
noctalia.runAsync({ "hyprctl", "submap" }, function(res)
  if res.exitCode == 0 then
    show((string.gsub(res.stdout or "", "%s+$", "")))
  end
end)

function onIpc(event, payload)
  if event == "set" then
    show(payload)
  end
end
