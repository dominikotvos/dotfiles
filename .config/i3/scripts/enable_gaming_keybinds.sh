#!/bin/bash

# Re-enable keybindings for normal operation
i3-msg 'bindsym $mod+w layout tabbed'
i3-msg 'bindsym $mod+a focus parent'
i3-msg 'bindsym $mod+s layout stacking'
i3-msg 'bindsym $mod+d exec --no-startup-id /home/sleuth/.config/rofi/launchers/type-4/launcher.sh'
i3-msg 'bindsym $mod+space fullscreen toggle'
i3-msg 'bindsym $mod+Shift+space floating toggle'
i3-msg 'bindsym $mod+Shift+d exec --no-startup-id ~/dotfiles/.config/i3/scripts/toggle_layout.sh'
i3-msg 'bindsym $mod+Shift+q kill'
i3-msg 'bindsym $mod+f fullscreen toggle'
i3-msg 'bindsym $mod+Shift+c reload'
i3-msg 'bindsym $mod+Shift+r restart'
i3-msg 'bindsym $mod+r mode "resize"'
i3-msg 'bindsym $mod+Shift+e exec "i3-nagbar -t warning -m \'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.\' -b \'Yes, exit i3\' \'i3-msg exit\'"'
i3-msg 'bindsym $mod+e layout toggle split'

