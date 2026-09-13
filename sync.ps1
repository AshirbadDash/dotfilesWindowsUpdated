<#
.SYNOPSIS
    Syncs your current config files back into the dotfiles repo.
    Run this after making changes to your profile, theme, or WT settings.
#>

$repoDir = $PSScriptRoot

function Write-Step { param($msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-OK   { param($msg) Write-Host "    [OK] $msg" -ForegroundColor Green }

Write-Step "Syncing PowerShell profile"
Copy-Item $PROFILE "$repoDir\powershell\profile.ps1" -Force
Write-OK "profile.ps1 updated"

Write-Step "Syncing Oh My Posh themes"
Copy-Item "$env:USERPROFILE\.config\oh-my-posh\themes\*" "$repoDir\ohmyposh\themes\" -Force
Write-OK "themes updated"

Write-Step "Syncing Windows Terminal settings"
Copy-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" `
          "$repoDir\windowsterminal\settings.json" -Force
Write-OK "settings.json updated"

Write-Host ""
Write-Host "Sync complete! Review changes and commit:" -ForegroundColor Green
Write-Host "  git -C `"$repoDir`" diff"
Write-Host "  git -C `"$repoDir`" add -A"
Write-Host "  git -C `"$repoDir`" commit -m `"update dotfiles`""
Write-Host "  git -C `"$repoDir`" push"
Write-Host ""