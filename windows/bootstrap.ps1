# Windows 10 bootstrap for the Hyprland/kitty/tmux/nvim/omp setup.
# Run from a normal (non-admin) PowerShell, with the dotfiles repo cloned to $HOME\dotfiles:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
#   & $HOME\dotfiles\windows\bootstrap.ps1
# Symlinks need Developer Mode (Settings > Update & Security > For developers) or an admin shell.

$ErrorActionPreference = 'Stop'
$dot = Join-Path $HOME 'dotfiles'

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
Link "$HOME\.glzr\zebar\gintama"                "$dot\windows\zebar\gintama"
Link "$HOME\.omp\agent\config.yml"               "$dot\windows\omp\config.yml"

# Zebar opens its startupConfigs when GlazeWM runs `shell-exec zebar`.
# Written, not linked: Zebar's settings UI rewrites this file.
$zebarSettings = "$HOME\.glzr\zebar\settings.json"
if (Test-Path $zebarSettings) { Copy-Item $zebarSettings "$zebarSettings.bak-$(Get-Date -Format yyyyMMddHHmmss)" }
@'
{
  "$schema": "https://github.com/glzr-io/zebar/raw/v3.0.0/resources/settings-schema.json",
  "startupConfigs": [{ "pack": "gintama", "widget": "bar", "preset": "default" }]
}
'@ | Set-Content -Encoding utf8 $zebarSettings
Link "$HOME\.omp\agent\AGENTS.md"                "$dot\windows\omp\AGENTS.md"

# --- Windows OpenSSH agent (replaces `eval $(ssh-agent)` in .zshrc) ---
# Needs admin; run these two lines in an elevated shell once:
#   Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
# then, as yourself: ssh-add $HOME\.ssh\github; ssh-add $HOME\.ssh\gitlab
git config --global core.sshCommand 'C:/Windows/System32/OpenSSH/ssh.exe'

Write-Host @'

Manual steps left:
 1. MSYS2: in C:\msys64\etc\nsswitch.conf set `db_home: windows` so ~ is C:\Users\<you>
    (same home as wezterm/omp/nvim). Then in the UCRT64 shell:
      pacman -S zsh git
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    and clone fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting, zsh-fzf-history-search
    into $ZSH_CUSTOM/plugins.
 2. Flow Launcher: Settings > Hotkey > Alt+D.
 3. Settings > Ease of Access > Keyboard: "Use the Print Screen button to open screen snipping".
 4. Mouse: Control Panel > Mouse > Pointer Options: untick "Enhance pointer precision" (= flat accel).
 5. System > About > Advanced system settings > Performance: "Adjust for best performance"
    (= animations off), then re-tick "Smooth edges of screen fonts".
 6. Taskbar: auto-hide (Zebar replaces it).
 7. omp: run `omp` once and log in again; auth lives in agent.db, which is not copied.
'@
