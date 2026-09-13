<#
.SYNOPSIS
    Windows dotfiles installer.
    Sets up PowerShell 7, Oh My Posh, fonts, modules, and all config files.

.USAGE
    # Run directly from GitHub (on a fresh machine):
    irm https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/install.ps1 | iex

    # Or clone and run locally:
    git clone https://github.com/YOUR_USERNAME/dotfiles
    cd dotfiles
    .\install.ps1
#>

# ── Self-elevate to Administrator if needed ──────────────────────────────────
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltinRole]::Administrator)) {

    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Helpers ──────────────────────────────────────────────────────────────────
function Write-Step  { param($msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-OK    { param($msg) Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Skip  { param($msg) Write-Host "    [--] $msg (already installed)" -ForegroundColor DarkGray }

# Determine where this script lives (works both from clone and from irm | iex)
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

# ── 1. Winget ────────────────────────────────────────────────────────────────
Write-Step "Checking winget"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "    winget not found. Please install App Installer from the Microsoft Store." -ForegroundColor Red
    exit 1
}
Write-OK "winget found"

# ── 2. PowerShell 7 ──────────────────────────────────────────────────────────
Write-Step "Installing PowerShell 7"
$installed = winget list --id Microsoft.PowerShell 2>$null | Select-String "Microsoft.PowerShell"
if ($installed) { Write-Skip "PowerShell 7" }
else {
    winget install --id Microsoft.PowerShell --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-OK "PowerShell 7 installed"
}

# ── 3. Oh My Posh ────────────────────────────────────────────────────────────
Write-Step "Installing Oh My Posh"
$installed = winget list --id JanDeDobbeleer.OhMyPosh 2>$null | Select-String "OhMyPosh"
if ($installed) { Write-Skip "Oh My Posh" }
else {
    winget install --id JanDeDobbeleer.OhMyPosh --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-OK "Oh My Posh installed"
}

# Refresh PATH so oh-my-posh is available
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

# ── 4. fzf ───────────────────────────────────────────────────────────────────
Write-Step "Installing fzf"
$installed = winget list --id junegunn.fzf 2>$null | Select-String "fzf"
if ($installed) { Write-Skip "fzf" }
else {
    winget install --id junegunn.fzf --source winget --accept-source-agreements --accept-package-agreements --silent
    Write-OK "fzf installed"
}

# ── 5. JetBrainsMono Nerd Font ───────────────────────────────────────────────
Write-Step "Installing JetBrainsMono Nerd Font"
$fontInstalled = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue).PSObject.Properties.Name |
                 Where-Object { $_ -like "*JetBrainsMono*" }
if ($fontInstalled) { Write-Skip "JetBrainsMono Nerd Font" }
else {
    oh-my-posh font install JetBrainsMono
    Write-OK "JetBrainsMono Nerd Font installed"
}

# ── 6. PowerShell Modules ────────────────────────────────────────────────────
Write-Step "Installing PowerShell modules"
$modules = @("Terminal-Icons", "PSReadLine", "PSFzf", "ZLocation")
foreach ($mod in $modules) {
    if (Get-Module -ListAvailable -Name $mod) {
        Write-Skip $mod
    } else {
        Install-Module $mod -Repository PSGallery -Force -Scope CurrentUser -AllowPrerelease
        Write-OK "$mod installed"
    }
}

# ── 7. Copy PowerShell Profile ───────────────────────────────────────────────
Write-Step "Copying PowerShell profile"
$profileDir = Split-Path $PROFILE -Parent
New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
Copy-Item "$scriptDir\powershell\profile.ps1" $PROFILE -Force
Write-OK "Profile copied to $PROFILE"

# ── 8. Copy Oh My Posh Theme ─────────────────────────────────────────────────
Write-Step "Copying Oh My Posh theme"
$themesDir = "$env:USERPROFILE\.config\oh-my-posh\themes"
New-Item -ItemType Directory -Path $themesDir -Force | Out-Null
Copy-Item "$scriptDir\ohmyposh\themes\*" $themesDir -Force
Write-OK "Theme(s) copied to $themesDir"

# ── 9. Copy Windows Terminal Settings ────────────────────────────────────────
Write-Step "Copying Windows Terminal settings"
$wtLocalState = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtLocalState) {
    Copy-Item "$scriptDir\windowsterminal\settings.json" "$wtLocalState\settings.json" -Force
    Write-OK "Windows Terminal settings applied"
} else {
    Write-Host "    [!!] Windows Terminal not found — skipping (install from Microsoft Store)" -ForegroundColor Yellow
}

# ── Done ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  All done! Restart Windows Terminal."       -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was set up:" -ForegroundColor White
Write-Host "  * PowerShell 7"
Write-Host "  * Oh My Posh (agnoster theme)"
Write-Host "  * JetBrainsMono Nerd Font"
Write-Host "  * Terminal-Icons, PSReadLine, PSFzf, ZLocation"
Write-Host "  * PowerShell profile -> $PROFILE"
Write-Host "  * Windows Terminal settings"
Write-Host ""