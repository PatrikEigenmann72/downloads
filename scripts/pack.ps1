# ------------------------------------------------------------------------------------
# Script:       pack.ps1
# Description:  Zips up one tool for distribution, in one of two modes:
#                 -bin <tool>  Binary release: bin\<tool>.exe + <tool>\<tool>.pdf (the
#                              manual, created by hand - this script only looks for it) +
#                              notes.pdf from the calling project's own root (whichever
#                              project pack.ps1 was run from - terminal, legacy,
#                              arcade, ... - not hardcoded to one of them), named
#                              <tool>_win_v<major>.<minor>.zip.
#                 -src <tool>  Source release: this project's own .c/.h/.pmake, plus every
#                              shared/toolbox .c/.h/.pmake pulled in via <tool>.pmake's own
#                              libs= line, named <tool>_src_v<major>.<minor>.zip. Paths kept
#                              relative to TerminalRoot (<tool>\, shared\toolbox\...) so the
#                              archive unpacks into the same layout the sources actually live
#                              in. Cross-checked against each .c file's own dependencies.txt
#                              (if present) - a "checksum verification" pass that resolves
#                              and bundles anything a file names there that libs= itself
#                              can't see (header-only files like version.h - no .c
#                              implements them, so a list of .c files can never name them),
#                              and aborts if something's missing. Also bundles the pmake
#                              build tool itself (from %USERPROFILE%\bin\pmake.exe) under
#                              bin\pmake.exe (with a Notes.txt at the zip root warning
#                              that this prebuilt pmake will trigger the same Gatekeeper/
#                              SmartScreen prompt as the tool itself), and
#                              scripts\compile.sh + compile.ps1 (from
#                              %USERPROFILE%\dev\scripts\) under scripts\, so nothing has to
#                              be preinstalled to rebuild it.
#               Both read the version from <tool>\main.c's own MAJOR/MINOR. Output lands
#               in bin\, then a copy is deployed to
#               ~/dev/downloads/<active>/<tool>/v<version>/, where <active> is the name
#               of the project folder pack.ps1 was called from (terminal, legacy, ...),
#               named <tool>_win_bin.zip or <tool>_win_src.zip (the <active>, <tool> and
#               v<version> folders are created there if they don't exist yet). Three
#               README.md tiers are dropped alongside it: downloads\<active>\README.md
#               (this project's own root README.md - its personal "why this exists"
#               blurb, copied as-is), downloads\<active>\<tool>\README.md (a
#               hand-authored <tool>\README.md if present, else - for terminal
#               projects only - the tool's own manpage output, captured by running
#               `<tool>.exe -h`), and ...\v<version>\README.md (main.c's own
#               abbreviated Change Log block). Windows port of pack.sh - see that
#               file's own changelog for shared history.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Mon 2026-08-24 File created, ported from pack.sh.                          Version: 00.01
# Mon 2026-08-24 Added deploy step to ~/dev/downloads/<tool>/v<version>/.    Version: 00.02
# Mon 2026-08-24 -src output flattened one level (<tool>\, shared\ dropped). Version: 00.03
# Mon 2026-08-24 Reverted flatten - source zip must keep <tool>\ and shared\ Version: 00.04
#                 as top-level folders so libs= relative paths still resolve
#                 when the extracted zip is rebuilt.
# Mon 2026-08-24 -src now also bundles each file's .pmake recipe and the     Version: 00.05
#                 pmake build tool itself (from %USERPROFILE%\bin\pmake.exe)
#                 under bin\pmake.exe.
# Mon 2026-08-24 -src now also bundles scripts\compile.sh + compile.ps1      Version: 00.06
#                 (from %USERPROFILE%\dev\scripts\) under scripts\.
# Mon 2026-08-24 -src now cross-checks every .c file's dependencies.txt (if  Version: 00.07
#                 present) after the libs= walk, resolving and bundling
#                 anything it names that libs= itself can't see (header-only
#                 files like version.h), and aborting if something's missing.
# Mon 2026-08-24 Deploy path now includes the calling project's own folder   Version: 00.08
#                 name (~/dev/downloads/<active>/<tool>/v<version>/) so
#                 terminal, legacy, etc. no longer share one flat <tool>\
#                 folder in downloads.
# Tue 2026-08-25 -bin now also bundles notes.pdf from the calling project's  Version: 00.09
#                 own root folder (case-insensitive, whichever project
#                 pack.ps1 was run from), not hardcoded to one project.
# Tue 2026-08-25 -src now also bundles Notes.txt (from the canonical         Version: 00.10
#                 %USERPROFILE%\dev\scripts\notes_src.txt) at the zip root
#                 whenever bin\pmake.exe gets bundled, warning that the
#                 prebuilt pmake will trigger the same Gatekeeper/
#                 SmartScreen prompt.
# Tue 2026-08-25 Deploy-ToDownloads now also drops two README.md files:      Version: 00.11
#                 a project-level one (hand-authored <tool>\README.md if
#                 present, else - terminal projects only - `<tool>.exe -h`'s
#                 manpage output) and a version-level one (main.c's own
#                 abbreviated Change Log block).
# Tue 2026-08-25 Added a third, active-project-level README.md tier          Version: 00.12
#                (downloads\<active>\README.md), copied straight from
#                $TerminalRoot's own root README.md.
# ------------------------------------------------------------------------------------

param(
    [Parameter(Position = 0)]
    [string]$Mode,

    [Parameter(Position = 1)]
    [string]$Tool
)

function Show-Help {
    @"
NAME
    pack.ps1 - zip up a tool for distribution

SYNOPSIS
    scripts\pack.ps1 -bin <tool>
    scripts\pack.ps1 -src <tool>

DESCRIPTION
    -bin <tool>  Zips bin\<tool>.exe together with <tool>\<tool>.pdf (if present) and
                 notes.pdf from the calling project's own root folder (case-
                 insensitive, if present) into bin\<tool>_win_v<major>.<minor>.zip.
                 Warns and skips whichever piece isn't found.

    -src <tool>  Zips into bin\<tool>_src_v<major>.<minor>.zip: this project's own
                 .c/.h/.pmake, plus every shared/toolbox .c/.h/.pmake referenced in
                 <tool>\<tool>.pmake's libs= line (compiler/linker flags like -lncurses
                 or -framework Foo are skipped). Paths kept relative to TerminalRoot
                 (<tool>\, shared\toolbox\...) so the archive rebuilds as-is. Then
                 cross-checked against each .c file's own dependencies.txt (if
                 present): every dependency it names gets resolved and bundled too
                 (catching header-only files like version.h that libs= can't
                 express), and the whole pack aborts if anything's missing. Also
                 bundles the pmake build tool itself (from %USERPROFILE%\bin\pmake.exe)
                 under bin\pmake.exe, plus a Notes.txt at the zip root warning that
                 this prebuilt pmake will trigger the same Gatekeeper/SmartScreen
                 prompt as the tool itself, and scripts\compile.sh + compile.ps1 (from
                 %USERPROFILE%\dev\scripts\) under scripts\ - warning and skipping
                 whichever piece isn't found.

    Version comes from <tool>\main.c's own MAJOR/MINOR.

    Either mode also deploys a copy to
    ~/dev/downloads/<active>/<tool>/v<major>.<minor>/, where <active> is the name
    of the project folder pack.ps1 was called from (terminal, legacy, ...), named
    <tool>_win_bin.zip or <tool>_win_src.zip, creating the <active>, <tool> and
    v<version> folders there if they don't exist yet. Alongside it, three
    README.md tiers: downloads\<active>\README.md (this project's own root
    README.md, copied as-is), downloads\<active>\<tool>\README.md (a
    hand-authored <tool>\README.md if one exists, else - for terminal projects
    only - the tool's own manpage output from running `<tool>.exe -h`), and
    ...\v<version>\README.md (main.c's own abbreviated Change Log block).

EXAMPLES
    scripts\pack.ps1 -bin enigma
    scripts\pack.ps1 -src enigma
"@
}

if (-not $Mode -or $Mode -eq '-h' -or $Mode -eq '-help' -or $Mode -eq '-?') {
    Show-Help
    exit 0
}

if ($Mode -ne '-bin' -and $Mode -ne '-src') {
    Write-Host "Unknown mode: $Mode (expected -bin or -src)"
    Show-Help
    exit 1
}

if (-not $Tool) {
    Write-Host "No tool given."
    Show-Help
    exit 1
}

$ErrorActionPreference = 'Stop'

$TerminalRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ToolDir = Join-Path $TerminalRoot $Tool
$MainC = Join-Path $ToolDir 'main.c'

if (-not (Test-Path $ToolDir -PathType Container)) {
    Write-Host "No such tool folder: $ToolDir"
    exit 1
}

if (-not (Test-Path $MainC -PathType Leaf)) {
    Write-Host "No such file: $MainC (pack.ps1 reads MAJOR/MINOR from here)"
    exit 1
}

# --------------------------------------------------------------------------------
# Get-Version - Reads MAJOR/MINOR straight out of <tool>\main.c, same file run()
# (see pmake.c) reads to name the build itself - one canonical version, not a second
# copy that can drift out of sync.
# --------------------------------------------------------------------------------
function Get-Version {
    $content = Get-Content $MainC
    $major = ($content | Select-String -Pattern '^\s*#define\s+MAJOR\s+(\d+)' | Select-Object -First 1).Matches[0].Groups[1].Value
    $minor = ($content | Select-String -Pattern '^\s*#define\s+MINOR\s+(\d+)' | Select-Object -First 1).Matches[0].Groups[1].Value
    return ('{0:D2}.{1:D2}' -f [int]$major, [int]$minor)
}

$Version = Get-Version

# --------------------------------------------------------------------------------
# Find-Header - looks for a dependency named -Name, exactly as written in some
# dependencies.txt line. A bare filename (e.g. "debug.h") is looked up first in
# ToolDir (this project's own headers), then recursively under shared\toolbox (the
# shared library tree). A name that spells out a path (e.g. "cipher/enigma.h",
# matching the #include itself) is resolved directly under shared\toolbox instead -
# needed when a shared header shares its bare name with the project's own header
# (enigma\enigma.h vs. shared\toolbox\cipher\enigma.h), which a basename-only
# search could never tell apart. Returns the resolved full path, or $null. Used by
# Resolve-Deps below, not the libs= walk (which already knows its own paths).
# --------------------------------------------------------------------------------
function Find-Header {
    param([string]$Name)

    if ($Name -match '[\\/]') {
        $Candidate = Join-Path (Join-Path $TerminalRoot 'shared\toolbox') ($Name -replace '/', '\')
        if (Test-Path $Candidate -PathType Leaf) {
            return (Resolve-Path $Candidate).Path
        }
        return $null
    }

    $Hit = Get-ChildItem -Path $ToolDir -Filter $Name -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $Hit) {
        $Hit = Get-ChildItem -Path (Join-Path $TerminalRoot 'shared\toolbox') -Filter $Name -File -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    if ($Hit) {
        return $Hit.FullName
    }
    return $null
}

# --------------------------------------------------------------------------------
# Resolve-Deps - the "checksum verification" pass: reads <dir>\dependencies.txt
# (if any) for the line "<c_basename>:<dep1>,<dep2>,..." matching -CFile's own
# basename, and for each dependency, looks it up with Find-Header. A dependency
# with a matching .c file (same basename, same directory) is recursed into the
# same way, pulling in its .h/.pmake and walking its own dependencies.txt entry in
# turn - this is what catches header-only contracts like version.h (no .c
# implements it, so the libs= walk above can never see it, but main's own
# dependencies.txt entry names it directly). A dependency that can't be found
# anywhere is recorded in $script:Missing instead of failing immediately, so
# Pack-Src can report every gap at once before deciding whether to zip.
#
# Deliberately additive, not a replacement for the libs= walk above: most tools in
# this repo don't have a dependencies.txt yet, and libs= alone still packs them
# exactly as before. Where a dependencies.txt does exist, this pass is what makes
# sure nothing quietly referenced-but-never-declared slips through.
# --------------------------------------------------------------------------------
function Resolve-Deps {
    param([string]$CFile)

    $Dir = Split-Path $CFile -Parent
    $Base = [System.IO.Path]::GetFileNameWithoutExtension($CFile)
    $DepsFile = Join-Path $Dir 'dependencies.txt'

    if (-not (Test-Path $DepsFile -PathType Leaf)) { return }

    $DepLine = (Get-Content $DepsFile | Where-Object { $_ -match "^${Base}:" } | Select-Object -First 1) -replace "^${Base}:", ''
    if (-not $DepLine) { return }

    $Deps = $DepLine -split ',' | Where-Object { $_ -ne '' }
    foreach ($Dep in $Deps) {
        $Hit = Find-Header -Name $Dep
        if (-not $Hit) {
            $script:Missing += "$CFile needs $Dep"
            continue
        }
        if ($script:Files.FullName -notcontains $Hit) {
            $script:Files += Get-Item $Hit
        }

        $HdrDir = Split-Path $Hit -Parent
        $HdrBase = [System.IO.Path]::GetFileNameWithoutExtension($Hit)
        $SiblingC = Join-Path $HdrDir "$HdrBase.c"
        if (Test-Path $SiblingC -PathType Leaf) {
            if ($script:Files.FullName -notcontains $SiblingC) {
                $script:Files += Get-Item $SiblingC
                Resolve-Deps -CFile $SiblingC
            }
            $SiblingPmake = Join-Path $HdrDir "$HdrBase.pmake"
            if ((Test-Path $SiblingPmake -PathType Leaf) -and ($script:Files.FullName -notcontains $SiblingPmake)) {
                $script:Files += Get-Item $SiblingPmake
            }
        }
    }
}

# --------------------------------------------------------------------------------
# Invoke-WithTimeout - runs -FilePath/-ArgumentList in a background job and waits
# up to -TimeoutSeconds for it, killing the job if it hasn't finished - used below
# to run an unfamiliar project's own binary without risking a hang (a GUI/game
# binary sitting there waiting for input instead of just printing help and
# exiting). Returns the command's combined stdout+stderr as a single string on
# success, or $null if it had to be killed.
# --------------------------------------------------------------------------------
function Invoke-WithTimeout {
    param(
        [int]$TimeoutSeconds,
        [string]$FilePath,
        [string[]]$ArgumentList
    )

    $Job = Start-Job -ScriptBlock {
        param($Fp, $Al)
        & $Fp @Al 2>&1 | Out-String
    } -ArgumentList $FilePath, $ArgumentList

    $Completed = Wait-Job $Job -Timeout $TimeoutSeconds
    if (-not $Completed) {
        Stop-Job $Job | Out-Null
        Remove-Job $Job -Force | Out-Null
        return $null
    }

    $Output = Receive-Job $Job
    Remove-Job $Job -Force | Out-Null
    return $Output
}

# --------------------------------------------------------------------------------
# Get-ChangelogBlock - pulls the abbreviated Change Log block straight out of
# <tool>\main.c (the condensed summary main.changelog.txt expands on in full) -
# from its first "<Weekday> <date> ... Version: XX.XX" entry (including the
# "Change Log:" label line right above it, if present) up to the next
# comment-block separator line (a run of "-" or "*"). Returns $null if main.c has
# no such block.
# --------------------------------------------------------------------------------
function Get-ChangelogBlock {
    param([string]$MainCPath)

    if (-not (Test-Path $MainCPath -PathType Leaf)) { return $null }

    $Lines = Get-Content $MainCPath
    $EntryPattern = '^// [A-Za-z]{3} \d{4}-\d{2}-\d{2}.*Version: \d'
    $SepPattern = '^// -{5,}|^// \*{5,}'

    $StartIndex = -1
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match $EntryPattern) { $StartIndex = $i; break }
    }
    if ($StartIndex -eq -1) { return $null }

    $EndIndex = $Lines.Count
    for ($i = $StartIndex + 1; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match $SepPattern) { $EndIndex = $i; break }
    }

    $RealStart = $StartIndex
    if ($StartIndex -gt 0 -and $Lines[$StartIndex - 1] -match '^// *Change Log:?') {
        $RealStart = $StartIndex - 1
    }

    $Block = $Lines[$RealStart..($EndIndex - 1)] | ForEach-Object { $_ -replace '^// ?', '' }
    return ($Block -join "`n")
}

# --------------------------------------------------------------------------------
# Deploy-ProjectReadme - drops a README.md at -ProjectDir (downloads\<active>\
# <tool>\, not version-scoped). Prefers a hand-authored <tool>\README.md if one
# exists (copied verbatim - the escape hatch for non-CLI projects like an arcade
# game, where a manpage makes no sense); otherwise, only for tools built from the
# terminal project (CLI tools that all implement -h via manpage_display(), see
# shared/toolbox/help/manpage.c), runs "<tool>.exe -h" and wraps its output.
# Never auto-runs a binary from any other project - see Invoke-WithTimeout above.
# --------------------------------------------------------------------------------
function Deploy-ProjectReadme {
    param([string]$ProjectDir)

    $Dest = Join-Path $ProjectDir 'README.md'
    $HandReadme = Join-Path $ToolDir 'README.md'

    New-Item -ItemType Directory -Force -Path $ProjectDir | Out-Null

    if (Test-Path $HandReadme -PathType Leaf) {
        Copy-Item -Force $HandReadme $Dest
        Write-Host "Deployed $Dest (from $HandReadme)"
        return
    }

    if ((Split-Path $TerminalRoot -Leaf) -eq 'terminal') {
        $BinPath = Join-Path $TerminalRoot "bin\$Tool.exe"
        if (Test-Path $BinPath -PathType Leaf) {
            $ManpageOutput = Invoke-WithTimeout -TimeoutSeconds 5 -FilePath $BinPath -ArgumentList @('-h')
            if ($null -eq $ManpageOutput) {
                Write-Host "Warning: '$Tool -h' didn't return within 5s - skipping project-level README.md."
                return
            }
            if ($ManpageOutput.Trim().Length -gt 0) {
                $Fence = '```text'
                $FenceEnd = '```'
                $Content = "# $Tool`n`n$Fence`n$($ManpageOutput.TrimEnd())`n$FenceEnd`n"
                Set-Content -Path $Dest -Value $Content -NoNewline
                Write-Host "Deployed $Dest (from '$Tool -h')"
                return
            }
        }
    }

    Write-Host "Warning: no $HandReadme found - skipping project-level README.md."
}

# --------------------------------------------------------------------------------
# Deploy-VersionReadme - drops a README.md at -VersionDir (downloads\<active>\
# <tool>\v<version>\) containing the abbreviated Change Log block already curated
# in main.c - not the full entry-by-entry history in main.changelog.txt.
# --------------------------------------------------------------------------------
function Deploy-VersionReadme {
    param([string]$VersionDir)

    $Dest = Join-Path $VersionDir 'README.md'
    $Changelog = Get-ChangelogBlock -MainCPath $MainC

    if ($Changelog) {
        $Fence = '```text'
        $FenceEnd = '```'
        $Content = "# $Tool v$Version - Changelog`n`n$Fence`n$Changelog`n$FenceEnd`n"
        Set-Content -Path $Dest -Value $Content -NoNewline
        Write-Host "Deployed $Dest"
    }
    else {
        Write-Host "Warning: no Change Log block found in $MainC - skipping version-level README.md."
    }
}

# --------------------------------------------------------------------------------
# Deploy-ActiveReadme - copies $TerminalRoot's own root README.md (this project's
# personal "why does this exist" blurb, not a doc-standard About/Structure/Author
# writeup - those don't belong in a private repo's README, only in the public
# downloads one this gets copied into) into downloads\<active>\README.md - one
# level above every tool's own folder, so a visitor lands on some context before
# diving into individual tools.
# --------------------------------------------------------------------------------
function Deploy-ActiveReadme {
    param([string]$ActiveDir)

    $Dest = Join-Path $ActiveDir 'README.md'
    $RootReadme = Join-Path $TerminalRoot 'README.md'

    New-Item -ItemType Directory -Force -Path $ActiveDir | Out-Null

    if (Test-Path $RootReadme -PathType Leaf) {
        Copy-Item -Force $RootReadme $Dest
        Write-Host "Deployed $Dest"
    }
    else {
        Write-Host "Warning: no $RootReadme found - skipping active-project-level README.md."
    }
}

# --------------------------------------------------------------------------------
# Deploy-ToDownloads - copies the freshly packed bin\$ZipName into
# ~/dev/downloads/<active>/<tool>/v<version>/<tool>_win_<kind>.zip (kind = bin or
# src), where <active> is the leaf name of $TerminalRoot - the project folder
# pack.ps1 was actually called from (terminal, legacy, ...), so each project gets
# its own branch in downloads instead of every project's tools landing in one
# shared <tool>\ folder. Creates the <active>, <tool> and v<version> folders there
# if they don't exist yet. downloads is a sibling of $TerminalRoot's own parent,
# not hardcoded to $HOME, so this still works if the repo is checked out somewhere
# other than ~/dev. Windows port of pack.sh's own deploy_to_downloads. Also drops
# three README.md tiers: an active-project one (this project's own root
# README.md), a per-tool one (manpage output, or a hand-authored one), and a
# per-version one (main.c's own Change Log block) - see
# Deploy-ActiveReadme/Deploy-ProjectReadme/Deploy-VersionReadme above.
# --------------------------------------------------------------------------------
function Deploy-ToDownloads {
    param(
        [string]$Kind,
        [string]$ZipName
    )

    $DownloadsRoot = Join-Path (Split-Path $TerminalRoot -Parent) 'downloads'
    $ActiveFolder = Split-Path $TerminalRoot -Leaf
    $ActiveDir = Join-Path $DownloadsRoot $ActiveFolder
    $ProjectDir = Join-Path $ActiveDir $Tool
    $DestDir = Join-Path $ProjectDir "v$Version"
    $DestFile = Join-Path $DestDir "${Tool}_win_${Kind}.zip"

    New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    Copy-Item -Force (Join-Path $TerminalRoot "bin\$ZipName") $DestFile

    Write-Host "Deployed $DestFile"

    Deploy-ActiveReadme -ActiveDir $ActiveDir
    Deploy-ProjectReadme -ProjectDir $ProjectDir
    Deploy-VersionReadme -VersionDir $DestDir
}

function Pack-Bin {
    $ZipName = "${Tool}_win_v${Version}.zip"
    $BinPath = Join-Path $TerminalRoot "bin\$Tool.exe"
    $PdfPath = Join-Path $ToolDir "$Tool.pdf"
    $ZipPath = Join-Path $TerminalRoot "bin\$ZipName"

    if (-not (Test-Path $BinPath -PathType Leaf)) {
        Write-Host "No such binary: $BinPath (build it first with scripts\compile.ps1 $Tool)"
        exit 1
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    $ItemsToZip = @($BinPath)
    if (Test-Path $PdfPath -PathType Leaf) {
        $ItemsToZip += $PdfPath
    }
    else {
        Write-Host "Warning: $PdfPath not found - packing without the tool manual."
    }

    $NotesFile = Get-ChildItem -Path $TerminalRoot -Filter 'notes.pdf' -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($NotesFile) {
        $ItemsToZip += $NotesFile.FullName
    }
    else {
        Write-Host "Warning: no notes.pdf found in $TerminalRoot - packing without release notes."
    }

    Compress-Archive -Path $ItemsToZip -DestinationPath $ZipPath

    Write-Host "Packed bin\$ZipName"
    Deploy-ToDownloads -Kind 'bin' -ZipName $ZipName
}

function Pack-Src {
    $PmakeFile = Join-Path $ToolDir "$Tool.pmake"
    $ZipName = "${Tool}_src_v${Version}.zip"
    $ZipPath = Join-Path $TerminalRoot "bin\$ZipName"

    if (-not (Test-Path $PmakeFile -PathType Leaf)) {
        Write-Host "No such file: $PmakeFile"
        exit 1
    }

    $script:Files = @()
    $script:Missing = @()

    # This project's own sources, plus its own <tool>.pmake build recipe.
    $script:Files += Get-ChildItem -Path $ToolDir -Filter '*.c' -File -ErrorAction SilentlyContinue
    $script:Files += Get-ChildItem -Path $ToolDir -Filter '*.h' -File -ErrorAction SilentlyContinue
    $script:Files += Get-ChildItem -Path $ToolDir -Filter '*.pmake' -File -ErrorAction SilentlyContinue

    # Everything libs= pulls in from shared/toolbox - skip compiler/linker flags
    # (-lncurses, -framework Foo), resolve the rest (globs included) relative to
    # ToolDir, same as pmake itself does when it builds this project. Each
    # shared/toolbox source also carries its own <name>.pmake build recipe
    # alongside its .c/.h - pull that in too when present.
    $LibsLine = (Get-Content $PmakeFile | Where-Object { $_ -match '^libs=' } | Select-Object -First 1) -replace '^libs=', ''

    if ($LibsLine) {
        $Tokens = $LibsLine -split '\s+' | Where-Object { $_ -ne '' }
        foreach ($Token in $Tokens) {
            if ($Token.StartsWith('-')) { continue }
            $Pattern = Join-Path $ToolDir $Token
            $ParentDir = Split-Path $Pattern -Parent
            $Leaf = Split-Path $Pattern -Leaf
            if (-not (Test-Path $ParentDir -PathType Container)) { continue }
            $Found = Get-ChildItem -Path $ParentDir -Filter $Leaf -File -ErrorAction SilentlyContinue
            foreach ($Match in $Found) {
                # Resolve away any ".." (libs= paths like ..\shared\toolbox\... are relative
                # to ToolDir) - same reasoning as pack.sh's own realpath step: a clean
                # "shared\toolbox\..." path in the zip, not "enigma\..\shared\toolbox\...".
                $Resolved = (Resolve-Path $Match.FullName).Path
                $script:Files += Get-Item $Resolved
                if ($Resolved -like '*.c') {
                    $HdrPath = $Resolved -replace '\.c$', '.h'
                    if (Test-Path $HdrPath -PathType Leaf) {
                        $script:Files += Get-Item $HdrPath
                    }
                    $PmakePath = $Resolved -replace '\.c$', '.pmake'
                    if (Test-Path $PmakePath -PathType Leaf) {
                        $script:Files += Get-Item $PmakePath
                    }
                }
            }
        }
    }

    # Checksum verification: walk every .c file found so far against its own
    # dependencies.txt entry (own sources and everything libs= just pulled in
    # alike) and make sure each declared dependency actually resolves - this is
    # what catches something like version.h, which no .c file implements and
    # libs= (a list of .c files) can therefore never express.
    foreach ($CSnapshot in $script:Files) {
        if ($CSnapshot.Extension -eq '.c') {
            Resolve-Deps -CFile $CSnapshot.FullName
        }
    }

    if ($script:Missing.Count -gt 0) {
        Write-Host "Dependency check failed - missing:"
        foreach ($M in $script:Missing) {
            Write-Host "  $M"
        }
        exit 1
    }

    if ($script:Files.Count -eq 0) {
        Write-Host "No .c/.h files found to pack."
        exit 1
    }

    Remove-Item -Force -ErrorAction SilentlyContinue $ZipPath

    # Compress-Archive has no "zip with these relative paths" mode, so stage a temp
    # folder mirroring TerminalRoot's own layout and zip that - the archive then unpacks
    # into the same folder structure the sources actually live in (enigma\enigma.c,
    # shared\toolbox\logging\debug.c, ...), same as pack.sh's own output.
    $StageDir = Join-Path ([System.IO.Path]::GetTempPath()) "pack_${Tool}_$([guid]::NewGuid())"
    New-Item -ItemType Directory -Force -Path $StageDir | Out-Null

    try {
        foreach ($File in $script:Files) {
            $RelPath = $File.FullName.Substring($TerminalRoot.Length + 1)
            $DestPath = Join-Path $StageDir $RelPath
            New-Item -ItemType Directory -Force -Path (Split-Path $DestPath -Parent) | Out-Null
            Copy-Item -Force $File.FullName $DestPath
        }

        # Bundle the pmake build tool itself (from %USERPROFILE%\bin\pmake.exe, not
        # this repo's own bin\<tool>.exe output) under bin\pmake.exe, so the extracted
        # source zip can be rebuilt without pmake having to be installed separately first.
        $PmakeTool = Join-Path $env:USERPROFILE 'bin\pmake.exe'
        $PmakeAdded = $false
        if (Test-Path $PmakeTool -PathType Leaf) {
            $BinStageDir = Join-Path $StageDir 'bin'
            New-Item -ItemType Directory -Force -Path $BinStageDir | Out-Null
            Copy-Item -Force $PmakeTool (Join-Path $BinStageDir 'pmake.exe')
            $PmakeAdded = $true
        }
        else {
            Write-Host "Warning: $PmakeTool not found - packing sources without the pmake tool."
        }

        # Bundle Notes.txt (from the canonical %USERPROFILE%\dev\scripts\notes_src.txt
        # copy) at the zip root, warning the user that bin\pmake.exe is a prebuilt
        # binary and will trigger the same Gatekeeper/SmartScreen warning as the tool
        # itself - only relevant if pmake actually got bundled above.
        $NotesSrc = Join-Path $env:USERPROFILE 'dev\scripts\notes_src.txt'
        $NotesAdded = $false
        if ($PmakeAdded) {
            if (Test-Path $NotesSrc -PathType Leaf) {
                Copy-Item -Force $NotesSrc (Join-Path $StageDir 'Notes.txt')
                $NotesAdded = $true
            }
            else {
                Write-Host "Warning: $NotesSrc not found - packing bin\pmake.exe without its Notes.txt."
            }
        }

        # Bundle scripts\compile.sh + compile.ps1 (from the canonical
        # %USERPROFILE%\dev\scripts\ copy), so the extracted source zip can be
        # rebuilt the same way this repo's own scripts\ folder works:
        # scripts\compile.ps1 <tool>.
        $ScriptsSrc = Join-Path $env:USERPROFILE 'dev\scripts'
        $ScriptsAdded = @()
        foreach ($Sf in @('compile.sh', 'compile.ps1')) {
            $SrcFile = Join-Path $ScriptsSrc $Sf
            if (Test-Path $SrcFile -PathType Leaf) {
                $ScriptsStageDir = Join-Path $StageDir 'scripts'
                New-Item -ItemType Directory -Force -Path $ScriptsStageDir | Out-Null
                Copy-Item -Force $SrcFile (Join-Path $ScriptsStageDir $Sf)
                $ScriptsAdded += "scripts\$Sf"
            }
            else {
                Write-Host "Warning: $SrcFile not found - skipping it in the source zip."
            }
        }

        Compress-Archive -Path (Join-Path $StageDir '*') -DestinationPath $ZipPath

        $Extras = @()
        if ($PmakeAdded) { $Extras += 'bin\pmake.exe' }
        if ($NotesAdded) { $Extras += 'Notes.txt' }
        $Extras += $ScriptsAdded
        if ($Extras.Count -gt 0) {
            Write-Host "Packed bin\$ZipName ($($script:Files.Count) files + $($Extras -join ','))"
        }
        else {
            Write-Host "Packed bin\$ZipName ($($script:Files.Count) files)"
        }
        Deploy-ToDownloads -Kind 'src' -ZipName $ZipName
    }
    finally {
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $StageDir
    }
}

switch ($Mode) {
    '-bin' { Pack-Bin }
    '-src' { Pack-Src }
}
