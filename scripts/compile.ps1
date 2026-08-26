# ------------------------------------------------------------------------------------
# Script:       compile.ps1
# Description:  Builds one tool in this terminal project by name (its folder must contain
#               a matching <tool>.pmake). Just forwards to pmake from inside that folder.
#               Windows port of compile.sh - see that file's own changelog for shared history.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Mon 2026-08-24 File created, ported from compile.sh.                       Version: 00.01
# ------------------------------------------------------------------------------------

param(
    [Parameter(Position = 0)]
    [string]$Tool,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$PmakeArgs
)

function Show-Help {
    @"
NAME
    compile.ps1 - build one tool in the terminal project

SYNOPSIS
    scripts\compile.ps1 <tool> [pmake args...]

DESCRIPTION
    Builds the <tool> folder using its <tool>.pmake file. Any extra arguments
    are forwarded straight through to pmake - see 'pmake -h' for what it
    accepts (-DDEBUG, --debug, --keywords). Run from anywhere inside the
    terminal project.

EXAMPLES
    scripts\compile.ps1 pmake
    scripts\compile.ps1 enigma -DDEBUG
    scripts\compile.ps1 enigma --debug:warn
"@
}

if (-not $Tool -or $Tool -eq '-h' -or $Tool -eq '-help' -or $Tool -eq '-?') {
    Show-Help
    exit 0
}

$ErrorActionPreference = 'Stop'

$TerminalRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ToolDir = Join-Path $TerminalRoot $Tool

if (-not (Test-Path $ToolDir -PathType Container)) {
    Write-Host "No such tool folder: $ToolDir"
    exit 1
}

Write-Host "Building $Tool..."
Push-Location $ToolDir
try {
    & pmake $Tool @PmakeArgs
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}

# pmake names its output "<tool>_<suffix>.exe" (version, and OS if is_os_gnostic=on).
# Collapse that down to a plain "<tool>.exe" binary.
$Built = Get-ChildItem -Path (Join-Path $TerminalRoot 'bin') -Filter "$Tool`_*.exe" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($Built) {
    Move-Item -Force $Built.FullName (Join-Path $TerminalRoot "bin\$Tool.exe")
}

Write-Host "Done. Type 'bin\$Tool.exe' (from $TerminalRoot) to run."
