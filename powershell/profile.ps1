# PowerShell Profile

# Always start in home directory (overrides any inherited CWD from parent process)
Set-Location $HOME

# ============================================================
# Oh My Posh Prompt
# ============================================================
$env:POSH_THEMES_PATH = "$env:USERPROFILE\.config\oh-my-posh\themes"
oh-my-posh init pwsh --config "C:\Users\swade\.config\oh-my-posh\themes\powerlevel10k_lean.omp.json" | Invoke-Expression

# ============================================================
# Terminal Icons  (icons in ls / Get-ChildItem output)
# ============================================================
Import-Module -Name Terminal-Icons

# ============================================================
# ZLocation  (jump to frecent directories with: z <partial>)
# ============================================================
Import-Module ZLocation

# ============================================================
# posh-git  (git status info available to the prompt)
# ============================================================
Import-Module posh-git

# ============================================================
# Theme Switcher  -  usage: theme <name>
# ============================================================
function theme {
    param(
        [Parameter(Position = 0)]
        [string]$Name
    )

    $themesPath = "$env:USERPROFILE\.config\oh-my-posh\themes"

    # List available themes if no name given
    if (-not $Name) {
        Write-Host "Available themes:" -ForegroundColor Cyan
        Get-ChildItem $themesPath -Filter "*.omp.json" |
            ForEach-Object { Write-Host "  $($_.BaseName -replace '\.omp','')" }
        Write-Host "`nUsage: theme <name>   e.g. theme catppuccin" -ForegroundColor DarkGray
        return
    }

    $file = "$themesPath\$Name.omp.json"

    # Try with exact name, then with .omp suffix
    if (-not (Test-Path $file)) { $file = "$themesPath\$Name" }
    if (-not (Test-Path $file)) {
        Write-Host "Theme '$Name' not found. Run 'theme' to see available themes." -ForegroundColor Red
        return
    }

    # Apply theme for this session
    oh-my-posh init pwsh --config $file | Invoke-Expression

    # Persist to profile for next sessions
    $profile_content = Get-Content $PROFILE -Raw
    $updated = $profile_content -replace `
        '(oh-my-posh init pwsh --config "C:\Users\swade\.config\oh-my-posh\themes\powerlevel10k_lean.omp.json"]*(")', `
        "`${1}$file`${2}"
    [System.IO.File]::WriteAllText($PROFILE, $updated, [System.Text.UTF8Encoding]::new($false))

    Write-Host "Theme set to '$Name'" -ForegroundColor Green
    Write-Host "(Saved to profile — will persist on next open)" -ForegroundColor DarkGray
}

# ============================================================
# PSReadLine - Autocompletion & Syntax Colors
# Only runs in interactive console sessions
# ============================================================
if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine

    # --- Prediction (inline ghost text from history) ----------
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle InlineView
    } catch { <# silently ignore in non-VT terminals #> }

    # --- Key Bindings ----------------------------------------
    # Tab       -> open completion menu
    # Shift+Tab -> go backwards in completion menu
    # End       -> accept the inline ghost-text suggestion
    # Up/Down   -> search history by what you already typed
    # F7        -> show full history as a selectable popup list
    # Ctrl+R    -> fuzzy search history with fzf (fastest)
    # Ctrl+T    -> fuzzy search files in current directory
    # Ctrl+D    -> delete char or exit shell
    Set-PSReadLineKeyHandler -Key Tab         -Function MenuComplete
    Set-PSReadLineKeyHandler -Key "Shift+Tab" -Function TabCompletePrevious
    Set-PSReadLineKeyHandler -Key End         -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Key UpArrow     -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow   -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key "Ctrl+d"    -Function DeleteCharOrExit

    # --- PSFzf - Fuzzy history & file search -----------------
    # Ensure fzf binary is on PATH (winget installs it here)
    $fzfDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\junegunn.fzf_Microsoft.Winget.Source_8wekyb3d8bbwe"
    if ((Test-Path $fzfDir) -and ($env:PATH -notlike "*$fzfDir*")) {
        $env:PATH += ";$fzfDir"
    }
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' `
                    -PSReadlineChordSetLocation    'Ctrl+t'

    # --- Syntax Colors (Catppuccin Mocha palette) -------------
    Set-PSReadLineOption -Colors @{
        Command          = '#cba6f7'   # Mauve  - command names
        Parameter        = '#89b4fa'   # Blue   - -flags
        String           = '#a6e3a1'   # Green  - "strings"
        Number           = '#fab387'   # Peach  - numbers
        Variable         = '#89dceb'   # Sky    - $variables
        Operator         = '#89b4fa'   # Blue   - | > =
        Type             = '#f38ba8'   # Red    - [types]
        Comment          = '#585b70'   # Dim    - # comments
        Keyword          = '#cba6f7'   # Mauve  - if/foreach/etc
        Error            = '#f38ba8'   # Red    - errors
        InlinePrediction = '#585b70'   # Dim    - ghost text
        ListPrediction   = '#585b70'   # Dim    - list suggestion
        Selection        = '#313244'   # Dark   - selected text
    }
}