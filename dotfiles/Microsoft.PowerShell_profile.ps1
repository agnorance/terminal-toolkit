# PowerShell 7 profile: the Windows twin of .zshrc
# Installed by setup.ps1 to $PROFILE (Documents\PowerShell\Microsoft.PowerShell_profile.ps1)

$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND

# Interactive extras only; `ssh host <command>` runs with redirected input
$interactive = -not [Console]::IsInputRedirected

if ($interactive) {
    # Suggestions from history as you type (like zsh-autosuggestions); F2 toggles a list
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView -HistoryNoDuplicates
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Ctrl+T files, Ctrl+R history (like the fzf plugin)
    if (Get-Module -ListAvailable PSFzf) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# Built-in aliases win over functions, so drop them first
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
    function ls { eza --icons @args }
    function ll { eza -la --icons @args }
    function lt { eza --tree --icons @args }
}
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cat -Force -ErrorAction SilentlyContinue
    Set-Alias cat bat
}

function mkcd($path) { New-Item -ItemType Directory -Force $path | Out-Null; Set-Location $path }

if ($interactive -and (Get-Command starship -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&starship init powershell)
}

# After starship: zoxide hooks the prompt starship sets. --cmd cd makes cd smart (alias cd='z')
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}

# Pending reminders on interactive SSH logins, as in .zshrc
if ($interactive -and $env:SSH_CONNECTION -and -not $env:REMINDERS_SHOWN) {
    $reminders = Get-ChildItem "$HOME\.reminders\*.md" -ErrorAction SilentlyContinue
    if ($reminders) {
        Write-Host '── pending reminders (~/.reminders) ──' -ForegroundColor Yellow
        foreach ($f in $reminders) {
            Write-Host "• $($f.BaseName)" -ForegroundColor Cyan
            Get-Content $f -TotalCount 8 | ForEach-Object { "    $_" }
            Write-Host
        }
        Write-Host '──────────────────────────────────────' -ForegroundColor Yellow
    }
    $env:REMINDERS_SHOWN = 1
}
