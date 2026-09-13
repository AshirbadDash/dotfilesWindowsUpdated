# dotfiles

My Windows terminal setup — one command to restore everything on a fresh machine.

## What's included

| Tool | Purpose |
|------|---------|
| **PowerShell 7** | Modern shell |
| **Oh My Posh** | Prompt styling (agnoster theme) |
| **JetBrainsMono Nerd Font** | Font with icons |
| **Terminal-Icons** | File/folder icons in `ls` |
| **PSReadLine** | Syntax colors + ghost-text autocompletion |
| **PSFzf + fzf** | Fuzzy history search (`Ctrl+R`) |
| **ZLocation** | Jump to frecent directories (`z <name>`) |

## Quick Install (fresh machine)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/AshirbadDash/dotfilesWindowsUpdated/main/install.ps1 | iex
```

> Requires **winget** (comes pre-installed on Windows 11). If missing, install [App Installer](https://apps.microsoft.com/detail/9nblggh4nns1) from the Microsoft Store first.

## Manual Install (clone first)

```powershell
git clone https://github.com/AshirbadDash/dotfilesWindowsUpdated $HOME\dotfiles
cd $HOME\dotfiles
.\install.ps1
```

## After install

1. **Restart Windows Terminal**

## Updating dotfiles

After making changes to your profile, theme, or Windows Terminal settings, sync and push:

```powershell
cd C:\Users\swade\dotfiles
.\sync.ps1
git add -A
git commit -m "update"
git push
```

## Key bindings

| Key | Action |
|-----|--------|
| `Tab` | Open completion menu |
| `Shift+Tab` | Go back in completion menu |
| `→` / `End` | Accept ghost-text suggestion |
| `↑` / `↓` | Search history by prefix |
| `Ctrl+R` | Fuzzy search history (fzf) |
| `Ctrl+T` | Fuzzy search files |
| `Ctrl+D` | Exit shell |

## Repo structure

```
dotfiles/
├── install.ps1                 ← run this on a new machine
├── sync.ps1                    ← sync current config back into repo
├── README.md
├── powershell/
│   └── profile.ps1
├── ohmyposh/
│   └── themes/
│       └── agnoster.omp.json
└── windowsterminal/
    └── settings.json
```