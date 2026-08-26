# ------------------------------------------------------------------------------------
# Script:       install.ps1
# Description:  Installs one tool's already-built binary (bin\<tool>.exe) into a user-local
#               bin directory, making it available to run by full path. Build it first with
#               scripts\compile.ps1 <tool>. Windows port of install.sh - see that file's
#               own changelog for shared history.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Mon 2026-08-24 File created, ported from install.sh.                       Version: 00.01
# ------------------------------------------------------------------------------------

param(
    [Parameter(Position = 0)]
    [string]$Tool
)

function Show-Help {
    @"
NAME
    install.ps1 - install one tool's binary into a user-local bin directory

SYNOPSIS
    scripts\install.ps1 <tool>

DESCRIPTION
    Copies bin\<tool>.exe to `$HOME\bin\<tool>.exe`. Run scripts\compile.ps1 <tool>
    first if bin\<tool>.exe doesn't exist yet. Add `$HOME\bin` to PATH yourself if
    you want <tool> runnable from anywhere - this script only copies the file.

EXAMPLES
    scripts\install.ps1 pmake
"@
}

if (-not $Tool -or $Tool -eq '-h' -or $Tool -eq '-help' -or $Tool -eq '-?') {
    Show-Help
    exit 0
}

$ErrorActionPreference = 'Stop'

$TerminalRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$BinPath = Join-Path $TerminalRoot "bin\$Tool.exe"

if (-not (Test-Path $BinPath -PathType Leaf)) {
    Write-Host "No such binary: $BinPath (build it first with scripts\compile.ps1 $Tool)"
    exit 1
}

$UserBin = Join-Path $HOME 'bin'
New-Item -ItemType Directory -Force -Path $UserBin | Out-Null
Copy-Item -Force $BinPath (Join-Path $UserBin "$Tool.exe")

Write-Host "Installed $Tool to $UserBin\$Tool.exe"
