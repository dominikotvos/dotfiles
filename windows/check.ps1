# Read-only audit: shows which README steps are already done on this machine.
# Changes nothing. Runs in the stock Windows PowerShell 5.1 (keep this file ASCII-only:
# 5.1 reads BOM-less UTF-8 as ANSI).
#
#   powershell -ExecutionPolicy Bypass -File .\check.ps1
#
# If the repo isn't cloned yet, download just this file from GitHub and run it the same way.
#
# [ok]   done, skip that step
# [todo] still needed
# [info] nothing to decide automatically; compare by hand
# [?]    could not check (usually needs admin)

$ErrorActionPreference = 'SilentlyContinue'
$dot = Join-Path $HOME 'dotfiles'
$script:todo = 0

function Ok($msg)    { Write-Host "  [ok]   $msg" -ForegroundColor Green }
function Todo($msg)  { Write-Host "  [todo] $msg" -ForegroundColor Yellow; $script:todo++ }
function Info($msg)  { Write-Host "  [info] $msg" -ForegroundColor Cyan }
function Unk($msg)   { Write-Host "  [?]    $msg" -ForegroundColor DarkGray }
function Section($t) { Write-Host "`n== $t" -ForegroundColor White }
function Check($cond, $okMsg, $todoMsg) { if ($cond) { Ok $okMsg } else { Todo $todoMsg } }
function Reg($path, $name) { (Get-ItemProperty -LiteralPath $path -Name $name).$name }
function Has($cmd) { [bool](Get-Command $cmd) }

# A config path is fine when it is a symlink into the dotfiles repo. Anything else
# there gets renamed to *.bak-<date> by bootstrap.ps1, so say so.
function CheckLink($target, $source) {
  $item = Get-Item -LiteralPath $target -Force
  if (-not $item) { Todo "$target missing (bootstrap links it)"; return }
  $dest = @($item.Target)[0]
  if ($item.LinkType -eq 'SymbolicLink' -and $dest -and ((Resolve-Path $dest).Path -eq (Resolve-Path $source).Path)) {
    Ok "$target -> dotfiles"
  } else {
    Todo "$target exists but is not the dotfiles link (bootstrap backs it up and replaces it)"
  }
}

$os = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
Write-Host "Windows: $($os.ProductName) $($os.DisplayVersion) build $($os.CurrentBuild).$($os.UBR)"

# ---------------------------------------------------------------------------
Section 'README 1. Before bootstrap'

Check ((Reg 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowDevelopmentWithoutDevLicense') -eq 1) `
  'Developer Mode on' '1.1 Developer Mode off'

Check (Has git) "git: $((git --version) -join '')" '1.2 git not installed'

foreach ($k in 'github', 'gitlab') {
  Check (Test-Path "$HOME\.ssh\$k") "~/.ssh/$k present" "1.3 ~/.ssh/$k missing"
}

$agent = Get-Service ssh-agent
if (-not $agent) {
  Todo '1.3 OpenSSH client / ssh-agent service not installed (Settings > Apps > Optional features > OpenSSH Client)'
} else {
  Check ($agent.StartType -eq 'Automatic' -and $agent.Status -eq 'Running') `
    'ssh-agent service automatic + running' "1.3 ssh-agent service is $($agent.StartType)/$($agent.Status)"
  if ($agent.Status -eq 'Running') {
    $keys = & "$env:SystemRoot\System32\OpenSSH\ssh-add.exe" -l 2>$null
    Check ($LASTEXITCODE -eq 0 -and $keys) "agent holds $(@($keys).Count) key(s)" '1.3 no keys in the agent (ssh-add)'
  }
}

if (Test-Path "$dot\.git") {
  $branch = git -C $dot rev-parse --abbrev-ref HEAD
  Check (Test-Path "$dot\windows\bootstrap.ps1") "dotfiles cloned (branch $branch)" `
    "1.4 dotfiles cloned but on '$branch' without windows/ (checkout noctalia-gintama)"
} else {
  Todo "1.4 dotfiles not cloned to $dot"
}

# ---------------------------------------------------------------------------
Section 'README 2. Bootstrap: packages'

$policy = Get-ExecutionPolicy -Scope CurrentUser
Check ($policy -in 'RemoteSigned', 'Unrestricted', 'Bypass') "execution policy (CurrentUser) $policy" `
  "2 execution policy (CurrentUser) is $policy; needs RemoteSigned"

if (-not (Has winget)) {
  Todo '2 winget missing (install "App Installer" from the Microsoft Store)'
} else {
  $ids = 'Git.Git', 'Microsoft.PowerShell', 'wez.wezterm', 'glzr-io.glazewm', 'glzr-io.zebar',
         'Flow-Launcher.Flow-Launcher', 'MSYS2.MSYS2', 'Neovim.Neovim', 'Rustlang.Rustup',
         'Microsoft.PowerToys', 'can1357.oh-my-pi', 'EpicGames.EpicGamesLauncher'
  foreach ($id in $ids) {
    winget list --id $id --exact --accept-source-agreements --disable-interactivity *> $null
    Check ($LASTEXITCODE -eq 0) "winget: $id" "2 winget: $id not installed"
  }
}

# Any Visual Studio 2022 edition with the C++ workload counts, not only Build Tools.
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = $null
if (Test-Path $vswhere) {
  $vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
}
Check $vs "MSVC (C++ tools) in $vs" '2 no Visual Studio / Build Tools with C++ tools'

Check (Has scoop) 'scoop' '2 scoop not installed'
foreach ($t in 'fzf', 'fd', 'rg', 'zoxide', 'eza', 'bat', 'yazi', 'lazygit', 'gh', 'fastfetch') {
  Check (Has $t) "cli: $t" "2 cli: $t not on PATH"
}

$fontDirs = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts", "$env:WINDIR\Fonts"
$hack = Get-ChildItem $fontDirs -Filter 'Hack*Nerd*' | Select-Object -First 1
Check $hack 'Hack Nerd Font' '2 Hack Nerd Font not installed'

# ---------------------------------------------------------------------------
Section 'README 2. Bootstrap: links and settings'

CheckLink "$HOME\.glzr\glazewm\config.yaml"   "$dot\windows\glazewm\config.yaml"
CheckLink "$HOME\.config\wezterm\wezterm.lua"  "$dot\windows\wezterm\wezterm.lua"
CheckLink "$env:LOCALAPPDATA\nvim"             "$dot\.config\nvim"
CheckLink "$HOME\.zshrc"                       "$dot\.zshrc"
CheckLink "$HOME\.glzr\zebar\gintama"          "$dot\windows\zebar\gintama"
CheckLink "$HOME\.omp\agent\config.yml"        "$dot\windows\omp\config.yml"
CheckLink "$HOME\.omp\agent\AGENTS.md"         "$dot\windows\omp\AGENTS.md"

$zs = Get-Content "$HOME\.glzr\zebar\settings.json" -Raw
Check ($zs -match '"gintama"') 'Zebar starts the gintama bar' '2 Zebar settings.json does not start the gintama bar'

Check (Test-Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\GlazeWM.lnk") `
  'GlazeWM starts at login' '2 GlazeWM not in the Startup folder'

$sshCmd = git config --global core.sshCommand
Check ($sshCmd -match 'System32/OpenSSH') 'git uses Windows OpenSSH' '2 git core.sshCommand not set to Windows OpenSSH'

# ---------------------------------------------------------------------------
Section 'README 3. After bootstrap: shell'

$msys = 'C:\msys64'
if (-not (Test-Path $msys)) {
  Todo '3.1 MSYS2 not at C:\msys64'
} else {
  Check ((Get-Content "$msys\etc\nsswitch.conf" -Raw) -match '(?m)^\s*db_home:\s*windows') `
    'MSYS2 db_home: windows' '3.1 nsswitch.conf db_home is not "windows"'
  Check (Test-Path "$msys\usr\bin\zsh.exe") 'zsh installed in MSYS2' '3.2 zsh not installed (pacman -S zsh)'
}
Check (Test-Path "$HOME\.oh-my-zsh") 'oh-my-zsh' '3.2 oh-my-zsh not installed'
foreach ($p in 'fzf-tab', 'zsh-autosuggestions', 'zsh-syntax-highlighting', 'zsh-fzf-history-search') {
  Check (Test-Path "$HOME\.oh-my-zsh\custom\plugins\$p") "omz plugin $p" "3.2 omz plugin $p missing"
}

# ---------------------------------------------------------------------------
Section 'README 3. After bootstrap: Unreal'

$ue = 'C:\Program Files\Epic Games\UE_5.8'
Check (Test-Path "$ue\Engine\Binaries\Win64\UnrealEditor.exe") "UE 5.8 at $ue" "3.3 UE 5.8 not at $ue (path used by unreal-engine.lua)"

if ($vs) {
  $msvc = (Get-ChildItem "$vs\VC\Tools\MSVC" -Directory | ForEach-Object Name) -join ', '
  Info "3.4 MSVC toolsets: $msvc  (compare with UE 5.8 release notes)"
}
$sdks = (Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\Include" -Directory | ForEach-Object Name) -join ', '
if ($sdks) { Info "3.4 Windows SDKs: $sdks" } else { Todo '3.4 no Windows 10/11 SDK installed' }

Info '3.5 game project clone: not checked (location unknown)'

$mp = Get-MpPreference
if ($null -eq $mp -or ($mp.ExclusionPath -and "$($mp.ExclusionPath)" -match 'Must be an administrator')) {
  Unk '3.6 Defender exclusions: rerun as admin to see them'
} else {
  $ex = @($mp.ExclusionPath) + @($mp.ExclusionProcess) | Where-Object { $_ }
  Check ($ex | Where-Object { $_ -match 'UnrealEngine|Epic Games|UnrealBuildTool|ShaderCompileWorker' }) `
    "Defender exclusions: $($ex -join '; ')" '3.6 (optional) no Unreal-related Defender exclusions'
}

# ---------------------------------------------------------------------------
Section 'README 3. After bootstrap: nvim / omp'

$lazy = "$env:LOCALAPPDATA\nvim-data\lazy"
Check (Test-Path "$lazy\lazy.nvim") 'nvim plugins installed' '3.7 nvim plugins not installed (:Lazy sync)'
Check (Get-ChildItem "$lazy\UNL.nvim\scanner\target\release" -Filter '*.exe') 'UNL scanner built' `
  '3.7 UNL scanner not built (run :Lazy build UNL.nvim from the Developer PowerShell)'

Check (Has omp) 'omp on PATH' '3.8 omp not installed'
Check (Test-Path "$HOME\.omp\agent\agent.db") 'omp has run before (login state may exist)' '3.8 omp never run / not logged in'
Check (Test-Path "$HOME\.omp\agent\memories") 'omp memories present' '3.8 (optional) omp memories not copied'

# ---------------------------------------------------------------------------
Section 'README 3. After bootstrap: desktop'

$flow = Get-Content "$env:APPDATA\FlowLauncher\Settings\Settings.json" -Raw
if ($flow) {
  Check ($flow -match '"Hotkey"\s*:\s*"Alt\s*\+\s*D"') 'Flow Launcher hotkey Alt+D' '3.9 Flow Launcher hotkey is not Alt+D'
} else {
  Unk '3.9 Flow Launcher settings not found (start it once)'
}

$langs = (Get-WinUserLanguageList).LanguageTag
foreach ($l in 'ja', 'ko') {
  Check ($langs | Where-Object { $_ -like "$l*" }) "input language $l" "3.9 input language $l not added"
}

Check ((Reg 'HKCU:\Control Panel\Keyboard' 'PrintScreenKeyForSnippingEnabled') -eq 1) `
  'Print Screen opens snipping' '3.9 Print Screen snipping off'

Check ((Reg 'HKCU:\Control Panel\Mouse' 'MouseSpeed') -eq '0') `
  'Enhance pointer precision off (flat accel)' '3.9 Enhance pointer precision still on'

$fx = Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting'
Check ($fx -eq 2 -or $fx -eq 3) "visual effects: $(if ($fx -eq 2) { 'best performance' } else { 'custom' })" `
  '3.9 visual effects not set to best performance'
Check ((Reg 'HKCU:\Control Panel\Desktop' 'FontSmoothing') -eq '2') 'font smoothing on' '3.9 font smoothing off (re-tick it)'

# StuckRects3 Settings byte 8: bit 0 set = taskbar auto-hide.
$stuck = Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3' 'Settings'
if ($stuck) {
  Check (($stuck[8] -band 1) -eq 1) 'taskbar auto-hide on' '3.9 taskbar auto-hide off'
} else {
  Unk '3.9 taskbar auto-hide: could not read'
}

# ---------------------------------------------------------------------------
Write-Host ''
if ($script:todo -eq 0) {
  Write-Host 'Everything checked is done.' -ForegroundColor Green
} else {
  Write-Host "$($script:todo) item(s) to do. Numbers match the steps in windows\README.md." -ForegroundColor Yellow
  Write-Host 'bootstrap.ps1 is safe to rerun: winget skips installed packages; existing configs get a .bak copy.'
}
