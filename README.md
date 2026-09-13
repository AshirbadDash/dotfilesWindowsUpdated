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
irm https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/install.ps1 | iex
```

> Requires **winget** (comes pre-installed on Windows 11). If missing, install [App Installer](https://apps.microsoft.com/detail/9nblggh4nns1) from the Microsoft Store first.

## Manual Install (clone first)

```powershell
git clone https://github.com/YOUR_USERNAME/dotfiles $HOME\dotfiles
cd $HOME\dotfiles
.\install.ps1
```

## After install

1. **Set terminal font** — Open Windows Terminal → Settings → Profiles → PowerShell → Appearance → Font: `JetBrainsMono Nerd Font Mono`
2. **Restart Windows Terminal**

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

## Updating dotfiles

After changing your profile or settings, sync them back:

```powershell
# From inside your dotfiles folder:
.\sync.ps1
```

## Repo structure

```
dotfiles/
├── install.ps1                 ← run this on a new machine
├── sync.ps1                    ← pull current config back into repo
├── README.md
├── powershell/
│   └── profile.ps1
├── ohmyposh/
│   └── themes/
│       └── agnoster.omp.json
└── windowsterminal/
    └── settings.json
```