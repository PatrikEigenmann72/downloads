# ------------------------------------------------------------------------------------
# Script:       subrepo.ps1
# Description:  Pulls or pushes git-subrepo(s) under shared/. Give a name to target one
#               (e.g. "toolbox"), or omit it to act on every shared/*/.gitrepo found.
#               Windows port of subrepo.sh - see that file's own changelog for shared history.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Mon 2026-08-24 File created, ported from subrepo.sh.                       Version: 00.01
# ------------------------------------------------------------------------------------

param(
    [Parameter(Position = 0)]
    [string]$Action,

    [Parameter(Position = 1)]
    [string]$Name
)

function Show-Help {
    @"
NAME
    subrepo.ps1 - pull or push shared/ git-subrepos

SYNOPSIS
    scripts\subrepo.ps1 <pull|push> [name]

DESCRIPTION
    Runs "git subrepo <pull|push> shared/<name>". Without [name], runs it against
    every subdirectory of shared/ that has a .gitrepo file.

EXAMPLES
    scripts\subrepo.ps1 pull toolbox
    scripts\subrepo.ps1 push
"@
}

if (-not $Action -or $Action -eq '-h' -or $Action -eq '-help' -or $Action -eq '-?') {
    Show-Help
    exit 0
}

if ($Action -ne 'pull' -and $Action -ne 'push') {
    Write-Host "Unknown action: $Action (expected pull or push)"
    Show-Help
    exit 1
}

$ErrorActionPreference = 'Stop'

$TerminalRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $TerminalRoot

$Targets = @()
if ($Name) {
    $Targets = @("shared\$Name")
}
else {
    Get-ChildItem -Path 'shared' -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName '.gitrepo')) {
            $Targets += "shared\$($_.Name)"
        }
    }
}

if ($Targets.Count -eq 0) {
    Write-Host "No git-subrepos found under shared/."
    exit 1
}

foreach ($Target in $Targets) {
    if (-not (Test-Path (Join-Path $Target '.gitrepo'))) {
        Write-Host "Skipping $Target`: no .gitrepo file."
        continue
    }
    Write-Host "== $Action $Target =="
    & git subrepo $Action $Target
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
