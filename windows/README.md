# Windows 10 port

This folder sets up the Linux setup on Windows 10:

| Linux | Windows |
|---|---|
| Hyprland | GlazeWM |
| noctalia | the Zebar bar in `zebar/gintama` |
| kitty and tmux | WezTerm |
| zsh | MSYS2 zsh |
| nvim | nvim, same config |
| omp | omp, same config |

`bootstrap.ps1` covers the scripted part. The steps below are the whole sequence, in order.

> **Security:** Windows 10 has been out of support since 2025-10-14, and paid home extended updates ended on 2026-10-13. Without business extended updates it gets no security patches.

## 0. Check what's already there

`check.ps1` is read-only and changes nothing. It marks each step below as `[ok]` (skip it) or `[todo]` (still needed), using the same step numbers as this README. Run it now, and again after each section.

Before the repo is cloned, download the script and run it on its own:
```powershell
iwr https://raw.githubusercontent.com/dominikotvos/dotfiles/noctalia-gintama/windows/check.ps1 -OutFile $env:TEMP\check.ps1
powershell -ExecutionPolicy Bypass -File $env:TEMP\check.ps1
```
Once the repo is cloned:
```powershell
powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\windows\check.ps1
```
Run it from an **admin** shell if you also want it to check the Defender exclusions.

## 1. Before bootstrap

1. **Developer Mode:** turn it on in Settings > Update & Security > For developers. Without it, the script can't create symlinks unless it runs as admin.
2. **Git:** run `winget install --id Git.Git -e`, then open a new terminal.
3. **SSH keys:** copy `~/.ssh/github` and `~/.ssh/gitlab` into `C:\Users\<you>\.ssh\`. Then, in an **admin** PowerShell:
   ```powershell
   Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
   ```
   Back in a normal shell:
   ```powershell
   ssh-add $HOME\.ssh\github; ssh-add $HOME\.ssh\gitlab
   ```
4. **Clone the dotfiles.** The Windows files only exist on this branch, not on `main`:
   ```powershell
   git -c core.sshCommand=C:/Windows/System32/OpenSSH/ssh.exe clone -b noctalia-gintama git@github.com:dominikotvos/dotfiles.git $HOME\dotfiles
   ```

## 2. Bootstrap

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
& $HOME\dotfiles\windows\bootstrap.ps1
```

The script does the following:
- Installs these apps with winget:
  - GlazeWM, Zebar, WezTerm, Flow Launcher
  - MSYS2, PowerShell 7, Neovim, rustup, PowerToys
  - omp, Epic Games Launcher
  - VS 2022 Build Tools
- Installs CLI tools with scoop: fzf, fd, ripgrep, zoxide, eza, bat, yazi, lazygit, gh, fastfetch and Hack Nerd Font.
- Links each config into place:
  - GlazeWM
  - WezTerm
  - nvim
  - `.zshrc`
  - the Zebar pack
  - omp's `config.yml` and `AGENTS.md`
- Writes Zebar's startup settings.
- Makes GlazeWM start at login.
- Points git at the Windows ssh.

## 3. After bootstrap

**Shell (MSYS2 zsh)**
1. Edit `C:\msys64\etc\nsswitch.conf` and set `db_home: windows`. This makes `~` the same folder as `C:\Users\<you>`, so zsh finds the linked `.zshrc`.
2. In the MSYS2 UCRT64 shell:
   ```sh
   pacman -S zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
   git clone https://github.com/Aloxaf/fzf-tab                      $ZSH_CUSTOM/plugins/fzf-tab
   git clone https://github.com/zsh-users/zsh-autosuggestions       $ZSH_CUSTOM/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting   $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
   git clone https://github.com/joshskidmore/zsh-fzf-history-search $ZSH_CUSTOM/plugins/zsh-fzf-history-search
   ```

**Unreal**
3. In the Epic Games Launcher, install **UE 5.8** to the default `C:\Program Files\Epic Games\UE_5.8`. That's the path `unreal-engine.lua` uses.
4. Check the UE 5.8 release notes for the MSVC toolset and Windows SDK versions it wants. Add those in the Visual Studio Installer under Modify > Individual components.
5. Clone the game project onto an NTFS drive. Don't put it in WSL.
6. Optional, for faster builds (Windows 10 has no Dev Drive). In an admin shell, add Defender exclusions for the project folder, the engine folder and `%LOCALAPPDATA%\UnrealEngine`, and for these processes: `cl.exe`, `link.exe`, `UnrealBuildTool.exe`, `ShaderCompileWorker.exe`, `UnrealEditor.exe`. Those folders and processes stop being scanned.

**Neovim**
7. Start `nvim` from WezTerm's **Developer PowerShell** profile (C-a w) the first time. The UNL cargo build and the tree-sitter parsers need MSVC on PATH. Run `:Lazy sync`. Then, inside the project, run `:UDEV` to generate the compile DB for clangd.

**omp**
8. Run `omp` and log in to openai-codex and anthropic. Logins are stored in `agent.db`, which isn't copied. If you want your learned memories, copy `~/.omp/agent/memories` over from Linux. Also check that omp on Windows actually reads `~\.omp\agent\config.yml`.

**Desktop**
9. Set up these Windows settings:
   - **Flow Launcher:** Settings > Hotkey > `Alt+D`.
   - **Input languages:** Settings > Time & Language > Language, add Japanese and Korean (replaces fcitx5 and mozc). Switch with Win+Space.
   - **Print Screen:** Settings > Ease of Access > Keyboard > "Use the Print Screen button to open screen snipping".
   - **Mouse:** Control Panel > Mouse > Pointer Options, untick "Enhance pointer precision" (flat accel).
   - **Animations off:** System > Advanced system settings > Performance > "Adjust for best performance", then tick "Smooth edges of screen fonts" again.
   - **Taskbar:** turn on auto-hide. Zebar replaces it.
10. Sign out and back in. GlazeWM starts at login and opens the bar.

## Known gaps

- No focus-border colors or square corners. They're Windows 11-only, so resize mode shows up in the bar instead.
- No scratchpad, no pseudo-tiling, and no Alt+mouse drag or resize.
- Lost Ark: on Linux keys.lua swapped Alt for Super automatically. Here, press `Alt+Shift+P` to pause GlazeWM's keybinds while playing.
- Bar widgets with no Windows equivalent were dropped (notifications, clipboard, bluetooth, brightness, control center, session). Use Win+A, Win+V and Win+X. 銀 is decoration only.
- `bootstrap.ps1` hasn't been run on Windows yet. If one of its winget IDs fails, find the right one with `winget search <name>`.
