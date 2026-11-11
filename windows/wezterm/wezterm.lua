-- WezTerm as kitty + tmux replacement on Windows (tmux has no native Windows build).
-- Lives at %USERPROFILE%\.config\wezterm\wezterm.lua (bootstrap.ps1 links it).
-- Leader = C-a like .tmux.conf; workspaces = tmux sessions; C-a f = tmux-sessionizer.

local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find('windows') ~= nil

-- Where tmux-sessionizer searched (~/projects, depth 3). Change if the Windows
-- checkout lives elsewhere, e.g. 'D:/projects'.
local PROJECTS = wezterm.home_dir .. '/projects'

---------------------------------------------------------------------------
-- Look: noctalia palette from kitty/themes/noctalia.conf, kitty font/opacity
---------------------------------------------------------------------------
local c = {
  bg = '#1a1e28', fg = '#dbdee6', primary = '#7b9ade', muted = '#989ca7',
  surface = '#323847', error = '#d15c74',
}

config.colors = {
  foreground = c.fg,
  background = c.bg,
  cursor_bg = c.primary,
  cursor_fg = c.bg,
  cursor_border = c.primary,
  selection_fg = c.bg,
  selection_bg = c.primary,
  split = c.primary,
  ansi = { '#181c24', '#d15c74', '#89c983', '#e0af68', '#7b9ade', '#9a84c6', '#66c4d8', '#989ca7' },
  brights = { '#434a62', '#e76b83', '#93cb77', '#ff9e64', '#7a9ee9', '#aa8fde', '#a3d8f7', '#dbdee6' },
  tab_bar = {
    background = c.bg,
    active_tab = { bg_color = c.primary, fg_color = c.bg },
    inactive_tab = { bg_color = c.surface, fg_color = c.muted },
    inactive_tab_hover = { bg_color = c.surface, fg_color = c.fg },
    new_tab = { bg_color = c.bg, fg_color = c.muted },
    new_tab_hover = { bg_color = c.surface, fg_color = c.fg },
  },
}

config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 13.0
config.window_background_opacity = 0.95
config.audible_bell = 'Disabled'
config.default_cursor_style = 'SteadyBlock'
config.use_ime = true
-- No title bar: GlazeWM tiles it, like kitty under Hyprland.
config.window_decorations = 'RESIZE'
config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }

-- Tab bar plays the role of the tmux status line.
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_and_split_indices_are_zero_based = false -- tmux base-index 1
config.hide_tab_bar_if_only_one_tab = false

---------------------------------------------------------------------------
-- Shell: MSYS2 zsh (oh-my-zsh works there), pwsh in the launcher menu
---------------------------------------------------------------------------
if is_windows then
  config.default_prog = {
    -- -use-full-path: inherit the Windows PATH (scoop shims, nvim, omp, git).
    -- MSYS2's default "minimal" PATH would hide all of them from zsh.
    'C:/msys64/msys2_shell.cmd', '-defterm', '-here', '-no-start', '-ucrt64', '-use-full-path', '-shell', 'zsh',
  }
  config.launch_menu = {
    { label = 'zsh (MSYS2)', args = config.default_prog },
    { label = 'PowerShell 7', args = { 'pwsh.exe', '-NoLogo' } },
    -- cl.exe/link.exe on PATH, for building tree-sitter parsers or native plugins.
    { label = 'Developer PowerShell (MSVC env)', args = {
      'pwsh.exe', '-NoExit', '-Command',
      '$vs = & "${env:ProgramFiles(x86)}/Microsoft Visual Studio/Installer/vswhere.exe" -latest -products * -property installationPath; '
        .. 'Import-Module "$vs/Common7/Tools/Microsoft.VisualStudio.DevShell.dll"; '
        .. 'Enter-VsDevShell -VsInstallPath $vs -SkipAutomaticLocation -DevCmdArguments "-arch=x64"',
    } },
  }
end

---------------------------------------------------------------------------
-- tmux-sessionizer: fuzzy-pick a dir under PROJECTS, switch/create workspace
---------------------------------------------------------------------------
-- basename with . -> _, same as `basename | tr . _`
local function workspace_name(dir)
  local trimmed = dir:gsub('[\\/]+$', '')
  local base = trimmed:match('([^\\/]+)$') or trimmed
  local name = base:gsub('%.', '_')
  return name
end

local function switch_to(window, pane, dir)
  window:perform_action(
    act.SwitchToWorkspace { name = workspace_name(dir), spawn = { cwd = dir } },
    pane
  )
end

-- Same as `find ~/projects -mindepth 1 -maxdepth 3 -type d`, via fd
-- (fd also skips .gitignored dirs, so UE Intermediate/Binaries stay out).
local function project_dirs()
  local ok, out = wezterm.run_child_process {
    'fd', '--type', 'd', '--max-depth', '3', '--absolute-path', '.', PROJECTS,
  }
  local dirs = {}
  if not ok then return dirs end
  for line in out:gmatch('[^\r\n]+') do
    local dir = line:gsub('[\\/]+$', '')
    table.insert(dirs, { id = dir, label = dir })
  end
  return dirs
end

local sessionizer = wezterm.action_callback(function(window, pane)
  window:perform_action(
    act.InputSelector {
      title = 'sessionizer',
      fuzzy = true,
      choices = project_dirs(),
      action = wezterm.action_callback(function(win, p, id)
        if id then switch_to(win, p, id) end
      end),
    },
    pane
  )
end)

-- Right status: workspace (= tmux session) name; red while the leader is held,
-- like the red border during a Hyprland submap.
wezterm.on('update-right-status', function(window)
  local color = window:leader_is_active() and c.error or c.primary
  window:set_right_status(wezterm.format {
    { Foreground = { Color = color } },
    { Text = ' ' .. window:active_workspace() .. ' ' },
  })
end)

---------------------------------------------------------------------------
-- Keys: .tmux.conf on C-a
---------------------------------------------------------------------------
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },
  { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },

  -- panes (tmux defaults + vim-like switching)
  { key = '%', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '"', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

  -- windows (= wezterm tabs)
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = '^', mods = 'LEADER|SHIFT', action = act.ActivateLastTab },

  -- copy mode is vi by default in wezterm; y copies to the clipboard
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

  -- sessions
  { key = 'f', mods = 'LEADER', action = sessionizer },
  { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|LAUNCH_MENU_ITEMS' } },

  -- C-a D: TODO.md in a new tab
  { key = 'D', mods = 'LEADER|SHIFT', action = act.SpawnCommandInNewTab {
    args = { 'nvim', 'TODO.md' },
  } },

  -- Pinned sessions like C-a P in .tmux.conf; add your Windows paths here.
  { key = 'P', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(w, p)
    switch_to(w, p, PROJECTS .. '/mmo-prologue')
  end) },
}

-- C-a 1..9 select window
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) })
end

return config
