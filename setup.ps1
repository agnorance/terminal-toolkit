<#
.SYNOPSIS
    Terminal Toolkit - Windows setup (the Windows twin of setup.sh)
.DESCRIPTION
    Installs PowerShell 7, the modern tools (eza, zoxide, fzf, ripgrep, fd, bat), Starship,
    the JetBrainsMono Nerd Font and PSFzf, then puts dotfiles/Microsoft.PowerShell_profile.ps1
    in place. Safe to run again: installed packages are skipped, a changed profile is backed up.
.PARAMETER SshShell
    Also make PowerShell 7 the default shell for SSH logins (needs an elevated shell).
.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -SshShell
#>
param([switch]$SshShell)

$ErrorActionPreference = 'Stop'
$dotfiles = Join-Path $PSScriptRoot 'dotfiles'

Write-Host '🔧 [WINDOWS] Starting Terminal Toolkit setup...'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw 'winget not found. Install "App Installer" from the Microsoft Store, then run again.'
}

$packages = @(
    'Microsoft.PowerShell',          # PowerShell 7 (pwsh)
    'eza-community.eza',
    'ajeetdsouza.zoxide',
    'junegunn.fzf',
    'BurntSushi.ripgrep.MSVC',
    'sharkdp.fd',
    'sharkdp.bat',
    'Starship.Starship',
    'DEVCOM.JetBrainsMonoNerdFont'
)

Write-Host '📦 Installing packages with winget...'
foreach ($id in $packages) {
    winget list --id $id --exact --accept-source-agreements *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ $id already installed"
        continue
    }
    winget install --id $id --exact --silent --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) { Write-Host "   ✓ $id installed" } else { Write-Host "   ✗ $id failed ($LASTEXITCODE)" }
}

# Pick up the new commands without opening a new shell
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

$pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
if (-not $pwsh) { $pwsh = Get-Item "$env:ProgramFiles\PowerShell\7\pwsh.exe" -ErrorAction SilentlyContinue }
if (-not $pwsh) { throw 'PowerShell 7 (pwsh) not found after install; open a new shell and run again.' }
$pwshPath = if ($pwsh.Source) { $pwsh.Source } else { $pwsh.FullName }

# Modules and $PROFILE belong to pwsh, which may not be the shell running this script
Write-Host '📦 Installing PSFzf for PowerShell 7...'
& $pwshPath -NoProfile -Command 'if (-not (Get-Module -ListAvailable PSFzf)) { Install-Module PSFzf -Scope CurrentUser -Force -AcceptLicense }'

Write-Host '📝 Installing the PowerShell profile...'
$profilePath = & $pwshPath -NoProfile -Command '$PROFILE'
$source = Join-Path $dotfiles 'Microsoft.PowerShell_profile.ps1'
New-Item -ItemType Directory -Force (Split-Path $profilePath) | Out-Null
if ((Test-Path $profilePath) -and (Get-FileHash $profilePath).Hash -ne (Get-FileHash $source).Hash) {
    $backup = "$profilePath.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
    Copy-Item $profilePath $backup
    Write-Host "   ↪ old profile backed up to $backup"
}
Copy-Item $source $profilePath -Force
Write-Host "   ✓ $profilePath"

# Same starship.toml as on Linux; an existing one is left alone
$starshipConfig = "$HOME\.config\starship.toml"
if (-not (Test-Path $starshipConfig)) {
    New-Item -ItemType Directory -Force (Split-Path $starshipConfig) | Out-Null
    Copy-Item (Join-Path $dotfiles 'starship.toml') $starshipConfig
    Write-Host "   ✓ $starshipConfig"
} else {
    Write-Host "   ✓ $starshipConfig exists, kept"
}

if ($SshShell) {
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($admin) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value $pwshPath -PropertyType String -Force | Out-Null
        Write-Host "   ✓ SSH default shell: $pwshPath"
    } else {
        Write-Host '   ✗ -SshShell needs an elevated shell (Run as administrator); skipped'
    }
}

Write-Host ''
Write-Host '✅ [WINDOWS] Done. Open a new PowerShell 7 window (pwsh) and set your terminal font to'
Write-Host '   "JetBrainsMono Nerd Font" so the icons show.'
