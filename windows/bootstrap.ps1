# Windows 10 bootstrap for the Hyprland/kitty/tmux/nvim/omp setup.
# Full ordered checklist (before and after this script): windows/README.md.
# Run from a normal (non-admin) PowerShell, with the dotfiles repo cloned to $HOME\dotfiles:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
#   & $HOME\dotfiles\windows\bootstrap.ps1

$ErrorActionPreference = 'Stop'
$dot = Join-Path $HOME 'dotfiles'

# Non-admin symlinks only work with Developer Mode on.
$devMode = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -ErrorAction SilentlyContinue
if ($devMode.AllowDevelopmentWithoutDevLicense -ne 1) {
  throw 'Enable Developer Mode first: Settings > Update & Security > For developers.'
}

# Reload PATH so tools installed earlier in this run are visible to later steps.
function Update-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
              [Environment]::GetEnvironmentVariable('Path', 'User')
}

# --- GUI apps + toolchains (winget) ---
$winget = @(
  'Git.Git'                      # also provides the bash that omp/Claude Code use
  'Microsoft.PowerShell'
  'wez.wezterm'                  # kitty + tmux replacement
  'glzr-io.glazewm'              # Hyprland replacement
  'glzr-io.zebar'                # noctalia bar replacement
  'Flow-Launcher.Flow-Launcher'  # launcher (set its hotkey to Alt+D)
  'MSYS2.MSYS2'                  # zsh + oh-my-zsh
  'Neovim.Neovim'
  'Rustlang.Rustup'              # UNL.nvim scanner: cargo build
  'Microsoft.PowerToys'          # Awake (caffeine), keyboard remaps
  'can1357.oh-my-pi'             # omp
  'EpicGames.EpicGamesLauncher'  # install UE 5.8 from here (nvim expects C:/Program Files/Epic Games/UE_5.8)
)
foreach ($id in $winget) {
  winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
}

# MSVC for UBT, clangd's compile DB, tree-sitter parsers and cargo.
# Check the UE 5.8 release notes for the exact MSVC toolset / Windows SDK it wants
# and add those components with the Visual Studio Installer afterwards.
winget install --id Microsoft.VisualStudio.2022.BuildTools --exact --silent --override `
  '--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'

# --- CLI tools from .zshrc / tmux workflow (scoop, user-level, on PATH) ---
Update-Path
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Invoke-RestMethod get.scoop.sh | Invoke-Expression
}
scoop bucket add extras
scoop bucket add nerd-fonts
scoop install fzf fd ripgrep zoxide eza bat yazi lazygit gh fastfetch Hack-NF

# --- config links ---
function Link($target, $source) {
  New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
  if (Test-Path $target) { Rename-Item $target "$target.bak-$(Get-Date -Format yyyyMMddHHmmss)" }
  New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
  Write-Host "linked $target -> $source"
}

Link "$HOME\.glzr\glazewm\config.yaml"          "$dot\windows\glazewm\config.yaml"
Link "$HOME\.config\wezterm\wezterm.lua"         "$dot\windows\wezterm\wezterm.lua"
Link "$env:LOCALAPPDATA\nvim"                    "$dot\.config\nvim"
Link "$HOME\.zshrc"                              "$dot\.zshrc"   # MSYS2 home = $HOME once db_home: windows is set
Link "$HOME\.glzr\zebar\gintama"                "$dot\windows\zebar\gintama"
Link "$HOME\.omp\agent\config.yml"               "$dot\windows\omp\config.yml"

# Zebar opens its startupConfigs when GlazeWM runs `shell-exec zebar`.
# Written, not linked: Zebar's settings UI rewrites this file.
$zebarSettings = "$HOME\.glzr\zebar\settings.json"
if (Test-Path $zebarSettings) { Copy-Item $zebarSettings "$zebarSettings.bak-$(Get-Date -Format yyyyMMddHHmmss)" }
$json = @'
{
  "$schema": "https://github.com/glzr-io/zebar/raw/v3.0.0/resources/settings-schema.json",
  "startupConfigs": [{ "pack": "gintama", "widget": "bar", "preset": "default" }]
}
'@
# No BOM: Windows PowerShell 5.1's `Set-Content -Encoding utf8` adds one, which JSON parsers reject.
[IO.File]::WriteAllText($zebarSettings, $json, (New-Object Text.UTF8Encoding $false))

# --- GlazeWM at login (it starts Zebar itself via startup_commands) ---
Update-Path
$glaze = (Get-Command glazewm -ErrorAction SilentlyContinue).Source
if (-not $glaze) { $glaze = "$env:ProgramFiles\glzr.io\GlazeWM\glazewm.exe" }
if (Test-Path $glaze) {
  $lnk = (New-Object -ComObject WScript.Shell).CreateShortcut(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\GlazeWM.lnk")
  $lnk.TargetPath = $glaze
  $lnk.Save()
  Write-Host "GlazeWM autostart -> $glaze"
} else {
  Write-Warning 'glazewm.exe not found; add it to shell:startup by hand.'
}
Link "$HOME\.omp\agent\AGENTS.md"                "$dot\windows\omp\AGENTS.md"

# --- Windows OpenSSH agent (replaces `eval $(ssh-agent)` in .zshrc) ---
# Needs admin; run these two lines in an elevated shell once:
#   Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
# then, as yourself: ssh-add $HOME\.ssh\github; ssh-add $HOME\.ssh\gitlab
git config --global core.sshCommand 'C:/Windows/System32/OpenSSH/ssh.exe'

Write-Host "`nDone. Continue with 'After bootstrap' in $dot\windows\README.md"
