#!/bin/bash
# ------------------------------------------------------------------------------------
# Script:       pack.sh
# Description:  Zips up one tool for distribution, in one of two modes:
#                 -bin <tool>  Binary release: bin/<tool> + <tool>/<tool>.pdf (the manual,
#                              created by hand - this script only looks for it) +
#                              notes.pdf from the calling project's own root (whichever
#                              project pack.sh was run from - terminal/, legacy/,
#                              arcade/, ... - not hardcoded to one of them), named
#                              <tool>_<os>_v<major>.<minor>.zip.
#                 -src <tool>  Source release: this project's own .c/.h/.pmake, plus every
#                              shared/toolbox .c/.h/.pmake pulled in via <tool>.pmake's own
#                              libs= line (parsed directly, not a separate manifest - one
#                              source of truth instead of two that can drift apart), named
#                              <tool>_src_v<major>.<minor>.zip. Paths kept relative to
#                              TERMINAL_ROOT (<tool>/, shared/toolbox/...) so the archive
#                              unpacks into the same layout <tool>.pmake's libs= line
#                              expects, and rebuilds without further setup - the pmake
#                              build tool itself (from ~/bin/pmake) is bundled under
#                              bin/pmake (with a Notes.txt at the zip root warning that
#                              this prebuilt pmake will trigger the same Gatekeeper/
#                              SmartScreen prompt as the tool itself), and
#                              scripts/compile.sh + compile.ps1 (from the canonical
#                              ~/dev/scripts/ copy) under scripts/, so nothing has to be
#                              preinstalled to do it.
#               Both read the version from <tool>/main.c's own MAJOR/MINOR (same file
#               run() in pmake.c reads to name the build itself). Output lands in bin/,
#               then a copy is deployed to
#               ~/dev/downloads/<active>/<tool>/v<version>/, where <active> is the
#               name of the project folder pack.sh was called from (terminal, legacy,
#               ...), named <tool>_<os>_bin.zip or <tool>_<os>_src.zip (the <active>,
#               <tool> and v<version> folders are created there if they don't exist
#               yet). Three README.md tiers are dropped alongside it:
#               downloads/<active>/README.md (this project's own root README.md -
#               its personal "why this exists" blurb, copied as-is),
#               downloads/<active>/<tool>/README.md (a hand-authored
#               <tool>/README.md if present, else - for terminal projects only -
#               the tool's own manpage output, captured by running `<tool> -h`),
#               and .../v<version>/README.md (main.c's own abbreviated Change Log
#               block).
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Mon 2026-08-24 File created.                                                Version: 00.01
# Mon 2026-08-24 Added deploy step to ~/dev/downloads/<tool>/v<version>/.     Version: 00.02
# Mon 2026-08-24 Deploy name now includes os suffix (<tool>_<os>_bin/src).    Version: 00.03
# Mon 2026-08-24 -src output flattened one level (<tool>/, shared/ dropped).  Version: 00.04
# Mon 2026-08-24 Reverted flatten - source zip must keep <tool>/ and shared/  Version: 00.05
#                 as top-level folders so libs= relative paths still resolve
#                 when the extracted zip is rebuilt.
# Mon 2026-08-24 -src now also bundles each file's .pmake recipe and the      Version: 00.06
#                 pmake build tool itself (from ~/bin/pmake) under bin/pmake.
# Mon 2026-08-24 -src now also bundles scripts/compile.sh + compile.ps1       Version: 00.07
#                 (from ~/dev/scripts/) under scripts/.
# Mon 2026-08-24 -src now cross-checks every .c file's dependencies.txt (if    Version: 00.08
#                 present) after the libs= walk, resolving and bundling
#                 anything it names that libs= itself can't see (header-only
#                 files like version.h), and aborting if something's missing.
# Mon 2026-08-24 Deploy path now includes the calling project's own folder     Version: 00.09
#                 name (~/dev/downloads/<active>/<tool>/v<version>/) so
#                 terminal/, legacy/, etc. no longer share one flat <tool>/
#                 folder in downloads.
# Tue 2026-08-25 -bin now also bundles notes.pdf from the calling project's    Version: 00.10
#                 own root folder (case-insensitive, whichever project
#                 pack.sh was run from), not hardcoded to one project.
# Tue 2026-08-25 -src now also bundles Notes.txt (from the canonical           Version: 00.11
#                 ~/dev/scripts/notes_src.txt) at the zip root whenever
#                 bin/pmake gets bundled, warning that the prebuilt pmake
#                 will trigger the same Gatekeeper/SmartScreen prompt.
# Tue 2026-08-25 deploy_to_downloads now also drops two README.md files:        Version: 00.12
#                 a project-level one (hand-authored <tool>/README.md if
#                 present, else - terminal projects only - `<tool> -h`'s
#                 manpage output) and a version-level one (main.c's own
#                 abbreviated Change Log block).
# Tue 2026-08-25 Added a third, active-project-level README.md tier             Version: 00.13
#                (downloads/<active>/README.md), copied straight from
#                TERMINAL_ROOT's own root README.md.
# ------------------------------------------------------------------------------------

show_help() {
cat << EOF
NAME
    pack.sh - zip up a tool for distribution

SYNOPSIS
    scripts/pack.sh -bin <tool>
    scripts/pack.sh -src <tool>

DESCRIPTION
    -bin <tool>  Zips bin/<tool> together with <tool>/<tool>.pdf (if present) and
                 notes.pdf from the calling project's own root folder (case-
                 insensitive, if present) into bin/<tool>_<os>_v<major>.<minor>.zip.
                 Warns and skips whichever piece isn't found.

    -src <tool>  Zips into bin/<tool>_src_v<major>.<minor>.zip: this project's own
                 .c/.h/.pmake, plus every shared/toolbox .c/.h/.pmake referenced in
                 <tool>/<tool>.pmake's libs= line (compiler/linker flags like -lncurses
                 or -framework Foo are skipped). Paths kept relative to TERMINAL_ROOT
                 (<tool>/, shared/toolbox/...) so the archive rebuilds as-is. Also
                 bundles the pmake build tool itself (from ~/bin/pmake) under bin/pmake,
                 plus a Notes.txt at the zip root warning that this prebuilt pmake will
                 trigger the same Gatekeeper/SmartScreen prompt as the tool itself, and
                 scripts/compile.sh + compile.ps1 (from ~/dev/scripts/) under
                 scripts/ - warning and skipping whichever piece isn't found.

    Version comes from <tool>/main.c's own MAJOR/MINOR.

    Either mode also deploys a copy to
    ~/dev/downloads/<active>/<tool>/v<major>.<minor>/, where <active> is the name
    of the project folder pack.sh was called from (terminal, legacy, ...), named
    <tool>_<os>_bin.zip or <tool>_<os>_src.zip, creating the <active>, <tool> and
    v<version> folders there if they don't exist yet. Alongside it, three
    README.md tiers: downloads/<active>/README.md (this project's own root
    README.md, copied as-is), downloads/<active>/<tool>/README.md (a
    hand-authored <tool>/README.md if one exists, else - for terminal projects
    only - the tool's own manpage output from running `<tool> -h`), and
    .../v<version>/README.md (main.c's own abbreviated Change Log block).

EXAMPLES
    scripts/pack.sh -bin enigma
    scripts/pack.sh -src enigma
EOF
}

case "$1" in
    -h|-help|-\?|"")
        show_help
        exit 0
        ;;
    -bin|-src)
        ;;
    *)
        echo "Unknown mode: $1 (expected -bin or -src)"
        show_help
        exit 1
        ;;
esac

if [ -z "$2" ]; then
    echo "No tool given."
    show_help
    exit 1
fi

set -e

MODE="$1"
TOOL="$2"

TERMINAL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL_DIR="$TERMINAL_ROOT/$TOOL"
MAIN_C="$TOOL_DIR/main.c"

if [ ! -d "$TOOL_DIR" ]; then
    echo "No such tool folder: $TOOL_DIR"
    exit 1
fi

if [ ! -f "$MAIN_C" ]; then
    echo "No such file: $MAIN_C (pack.sh reads MAJOR/MINOR from here)"
    exit 1
fi

# --------------------------------------------------------------------------------
# get_version - Reads MAJOR/MINOR straight out of <tool>/main.c, same file run()
# (see pmake.c) reads to name the build itself - one canonical version, not a second
# copy that can drift out of sync.
# --------------------------------------------------------------------------------
get_version() {
    local major minor
    major="$(awk '/^#define[ \t]+MAJOR[ \t]/ {print $3; exit}' "$MAIN_C")"
    minor="$(awk '/^#define[ \t]+MINOR[ \t]/ {print $3; exit}' "$MAIN_C")"
    printf "%02d.%02d" "$major" "$minor"
}

# --------------------------------------------------------------------------------
# get_os_suffix - Mirrors pmake.c's own is_os_gnostic suffix (_mac/_win/_linux).
# --------------------------------------------------------------------------------
get_os_suffix() {
    case "$(uname -s)" in
        Darwin) echo "mac" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

VERSION="$(get_version)"

# --------------------------------------------------------------------------------
# find_header - looks for a dependency named $1, exactly as written in some
# dependencies.txt line. A bare filename (e.g. "debug.h") is looked up first in
# TOOL_DIR (this project's own headers), then recursively under shared/toolbox
# (the shared library tree). A name that spells out a path (e.g. "cipher/enigma.h",
# matching the #include itself) is resolved directly under shared/toolbox instead -
# needed when a shared header shares its bare name with the project's own header
# (enigma/enigma.h vs. shared/toolbox/cipher/enigma.h), which a basename-only search
# could never tell apart. Prints the absolute path if found, nothing if not. Used by
# resolve_deps below, not the libs= walk (which already knows its own paths).
# --------------------------------------------------------------------------------
find_header() {
    local name="$1" hit
    case "$name" in
        */*)
            hit="$TERMINAL_ROOT/shared/toolbox/$name"
            [ -f "$hit" ] || hit=""
            ;;
        *)
            hit="$(find "$TOOL_DIR" -maxdepth 1 -name "$name" -print -quit 2>/dev/null)"
            if [ -z "$hit" ]; then
                hit="$(find "$TERMINAL_ROOT/shared/toolbox" -name "$name" -print -quit 2>/dev/null)"
            fi
            ;;
    esac
    printf '%s' "$hit"
}

# --------------------------------------------------------------------------------
# has_file - true if $1 is already present in the (global) files[] array pack_src
# is building - avoids re-adding or re-walking the same dependency twice.
# --------------------------------------------------------------------------------
has_file() {
    local target="$1" existing
    for existing in "${files[@]}"; do
        [ "$existing" = "$target" ] && return 0
    done
    return 1
}

# --------------------------------------------------------------------------------
# resolve_deps - the "checksum verification" pass: reads <dir>/dependencies.txt
# (if any) for the line "<c_basename>:<dep1>,<dep2>,..." matching $1, and for each
# dependency, looks it up with find_header. A dependency with a matching .c file
# (same basename, same directory) is recursed into the same way, pulling in its
# .h/.pmake and walking its own dependencies.txt entry in turn - this is what
# catches header-only contracts like version.h (no .c implements it, so the libs=
# walk above can never see it, but main's own dependencies.txt entry names it
# directly). A dependency that can't be found anywhere is recorded in the (global)
# missing[] array instead of failing immediately, so pack_src can report every
# gap at once before deciding whether to zip.
#
# Deliberately additive, not a replacement for the libs= walk above: most tools in
# this repo don't have a dependencies.txt yet, and libs= alone still packs them
# exactly as before. Where a dependencies.txt does exist, this pass is what makes
# sure nothing quietly referenced-but-never-declared slips through.
# --------------------------------------------------------------------------------
resolve_deps() {
    local c_file="$1" dir base deps_file dep_line dep hit
    dir="$(dirname "$c_file")"
    base="$(basename "$c_file" .c)"
    deps_file="$dir/dependencies.txt"

    [ -f "$deps_file" ] || return 0
    dep_line="$(grep "^${base}:" "$deps_file" | head -1 | cut -d':' -f2-)"
    [ -z "$dep_line" ] && return 0

    local old_ifs="$IFS"
    IFS=','
    for dep in $dep_line; do
        IFS="$old_ifs"
        [ -z "$dep" ] && continue

        hit="$(find_header "$dep")"
        if [ -z "$hit" ]; then
            missing+=("$c_file needs $dep")
            IFS=','
            continue
        fi
        has_file "$hit" || files+=("$hit")

        local hdr_dir hdr_base sibling_c sibling_pmake
        hdr_dir="$(dirname "$hit")"
        hdr_base="$(basename "$hit" .h)"
        sibling_c="$hdr_dir/$hdr_base.c"
        if [ -f "$sibling_c" ]; then
            if ! has_file "$sibling_c"; then
                files+=("$sibling_c")
                resolve_deps "$sibling_c"
            fi
            sibling_pmake="$hdr_dir/$hdr_base.pmake"
            [ -f "$sibling_pmake" ] && ! has_file "$sibling_pmake" && files+=("$sibling_pmake")
        fi
        IFS=','
    done
    IFS="$old_ifs"
}

# --------------------------------------------------------------------------------
# run_with_timeout - runs "$@" in the background and waits up to $1 seconds for it
# to finish, killing it if it hasn't. macOS/BSD has no `timeout` builtin, so this
# is the portable stand-in - used below to run an unfamiliar project's own binary
# without risking a hang (a GUI/game binary sitting there waiting for input
# instead of just printing help and exiting). Prints the command's combined
# stdout+stderr on success; prints nothing and returns 1 if it had to be killed.
# --------------------------------------------------------------------------------
run_with_timeout() {
    local timeout_secs="$1"; shift
    local out_file
    out_file="$(mktemp)"

    "$@" > "$out_file" 2>&1 &
    local pid=$!
    local waited=0
    while kill -0 "$pid" 2>/dev/null && [ "$waited" -lt "$timeout_secs" ]; do
        sleep 1
        waited=$((waited + 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
        rm -f "$out_file"
        return 1
    fi

    wait "$pid"
    local status=$?
    cat "$out_file"
    rm -f "$out_file"
    return $status
}

# --------------------------------------------------------------------------------
# extract_changelog - pulls the abbreviated Change Log block straight out of
# <tool>/main.c (the condensed summary main.changelog.txt expands on in full) -
# from its first "<Weekday> <date> ... Version: XX.XX" entry (including the
# "Change Log:" label line right above it, if present) up to the next
# comment-block separator line (a run of "-" or "*"). Prints nothing and returns
# 1 if main.c has no such block.
# --------------------------------------------------------------------------------
extract_changelog() {
    local main_c="$1"
    [ -f "$main_c" ] || return 1

    local entry_re='^// [A-Za-z]{3} [0-9]{4}-[0-9]{2}-[0-9]{2}.*Version: [0-9]'
    local sep_re='^// -{5,}|^// \*{5,}'

    local start_line
    start_line="$(grep -nE "$entry_re" "$main_c" | head -1 | cut -d: -f1)"
    [ -z "$start_line" ] && return 1

    local total_lines
    total_lines="$(wc -l < "$main_c" | tr -d ' ')"

    local rel_end end_line
    rel_end="$(tail -n "+$((start_line + 1))" "$main_c" | grep -nE "$sep_re" | head -1 | cut -d: -f1)"
    if [ -n "$rel_end" ]; then
        end_line=$((start_line + rel_end))
    else
        end_line=$((total_lines + 1))
    fi

    local real_start="$start_line"
    if [ "$start_line" -gt 1 ]; then
        local prev_line
        prev_line="$(sed -n "$((start_line - 1))p" "$main_c")"
        echo "$prev_line" | grep -qE '^// *Change Log:?' && real_start=$((start_line - 1))
    fi

    sed -n "${real_start},$((end_line - 1))p" "$main_c" | sed -E 's#^// ?##'
}

# --------------------------------------------------------------------------------
# deploy_project_readme - drops a README.md at <project_dir> (downloads/<active>/
# <tool>/, not version-scoped). Prefers a hand-authored <tool>/README.md if one
# exists (copied verbatim - the escape hatch for non-CLI projects like an arcade
# game, where a manpage makes no sense); otherwise, only for tools built from the
# terminal project (CLI tools that all implement -h via manpage_display(), see
# shared/toolbox/help/manpage.c), runs "bin/<tool> -h" and wraps its output.
# Never auto-runs a binary from any other project - see run_with_timeout above.
# --------------------------------------------------------------------------------
deploy_project_readme() {
    local project_dir="$1"
    local dest="$project_dir/README.md"
    local hand_readme="$TOOL_DIR/README.md"

    mkdir -p "$project_dir"

    if [ -f "$hand_readme" ]; then
        cp "$hand_readme" "$dest"
        echo "Deployed $dest (from $hand_readme)"
        return
    fi

    if [ "$(basename "$TERMINAL_ROOT")" = "terminal" ]; then
        local bin_path="$TERMINAL_ROOT/bin/$TOOL"
        if [ -x "$bin_path" ]; then
            local manpage_output
            if manpage_output="$(run_with_timeout 5 "$bin_path" -h)"; then
                if [ -n "$manpage_output" ]; then
                    {
                        printf '# %s\n\n' "$TOOL"
                        printf '```text\n'
                        printf '%s\n' "$manpage_output"
                        printf '```\n'
                    } > "$dest"
                    echo "Deployed $dest (from '$TOOL -h')"
                    return
                fi
            else
                echo "Warning: '$TOOL -h' didn't return within 5s - skipping project-level README.md."
                return
            fi
        fi
    fi

    echo "Warning: no $hand_readme found - skipping project-level README.md."
}

# --------------------------------------------------------------------------------
# deploy_version_readme - drops a README.md at <version_dir> (downloads/<active>/
# <tool>/v<version>/) containing the abbreviated Change Log block already curated
# in main.c - not the full entry-by-entry history in main.changelog.txt.
# --------------------------------------------------------------------------------
deploy_version_readme() {
    local version_dir="$1"
    local dest="$version_dir/README.md"
    local changelog

    if changelog="$(extract_changelog "$MAIN_C")" && [ -n "$changelog" ]; then
        {
            printf '# %s v%s - Changelog\n\n' "$TOOL" "$VERSION"
            printf '```text\n'
            printf '%s\n' "$changelog"
            printf '```\n'
        } > "$dest"
        echo "Deployed $dest"
    else
        echo "Warning: no Change Log block found in $MAIN_C - skipping version-level README.md."
    fi
}

# --------------------------------------------------------------------------------
# deploy_active_readme - copies TERMINAL_ROOT's own root README.md (this project's
# personal "why does this exist" blurb, not a doc-standard About/Structure/Author
# writeup - those don't belong in a private repo's README, only in the public
# downloads/ one this gets copied into) into downloads/<active>/README.md - one
# level above every tool's own folder, so a visitor lands on some context before
# diving into individual tools.
# --------------------------------------------------------------------------------
deploy_active_readme() {
    local active_dir="$1"
    local dest="$active_dir/README.md"
    local root_readme="$TERMINAL_ROOT/README.md"

    mkdir -p "$active_dir"

    if [ -f "$root_readme" ]; then
        cp "$root_readme" "$dest"
        echo "Deployed $dest"
    else
        echo "Warning: no $root_readme found - skipping active-project-level README.md."
    fi
}

# --------------------------------------------------------------------------------
# deploy_to_downloads - copies the freshly packed bin/<zip_name> into
# ~/dev/downloads/<active>/<tool>/v<version>/<tool>_<os>_<kind>.zip (kind = bin or
# src), where <active> is the basename of TERMINAL_ROOT - the project folder
# pack.sh was actually called from (terminal, legacy, ...), so each project gets
# its own branch in downloads/ instead of every project's tools landing in one
# shared <tool>/ folder. Creates the <active>, <tool> and v<version> folders there
# if they don't exist yet. downloads/ is a sibling of TERMINAL_ROOT's own parent,
# not hardcoded to $HOME, so this still works if the repo is checked out somewhere
# other than ~/dev. Also drops three README.md tiers: an active-project one (this
# project's own root README.md), a per-tool one (manpage output, or a
# hand-authored one), and a per-version one (main.c's own Change Log block) - see
# deploy_active_readme/deploy_project_readme/deploy_version_readme above.
# --------------------------------------------------------------------------------
deploy_to_downloads() {
    local kind="$1" zip_name="$2"
    local downloads_root active_folder active_dir project_dir dest_dir dest_file

    downloads_root="$(dirname "$TERMINAL_ROOT")/downloads"
    active_folder="$(basename "$TERMINAL_ROOT")"
    active_dir="$downloads_root/$active_folder"
    project_dir="$active_dir/$TOOL"
    dest_dir="$project_dir/v$VERSION"
    dest_file="$dest_dir/${TOOL}_$(get_os_suffix)_${kind}.zip"

    mkdir -p "$dest_dir"
    cp "$TERMINAL_ROOT/bin/$zip_name" "$dest_file"

    echo "Deployed $dest_file"

    deploy_active_readme "$active_dir"

    deploy_project_readme "$project_dir"
    deploy_version_readme "$dest_dir"
}

# --------------------------------------------------------------------------------
# pack_bin - bin/<tool> + <tool>/<tool>.pdf (if present) + notes.pdf (if present,
# looked up case-insensitively in TERMINAL_ROOT - the calling project's own root,
# whichever project pack.sh was actually run from, not hardcoded to one of them)
# -> bin/<tool>_<os>_v<ver>.zip
# --------------------------------------------------------------------------------
pack_bin() {
    local os_suffix zip_name bin_path pdf_path notes_path
    os_suffix="$(get_os_suffix)"
    zip_name="${TOOL}_${os_suffix}_v${VERSION}.zip"
    bin_path="$TERMINAL_ROOT/bin/$TOOL"
    pdf_path="$TOOL_DIR/$TOOL.pdf"
    notes_path="$(find "$TERMINAL_ROOT" -maxdepth 1 -iname 'notes.pdf' -print -quit 2>/dev/null)"

    if [ ! -f "$bin_path" ]; then
        echo "No such binary: $bin_path (build it first with scripts/compile.sh $TOOL)"
        exit 1
    fi

    rm -f "$TERMINAL_ROOT/bin/$zip_name"

    local -a items=("bin/$TOOL")

    if [ -f "$pdf_path" ]; then
        items+=("$pdf_path")
    else
        echo "Warning: $pdf_path not found - packing without the tool manual."
    fi

    if [ -n "$notes_path" ]; then
        items+=("$notes_path")
    else
        echo "Warning: no notes.pdf found in $TERMINAL_ROOT - packing without release notes."
    fi

    (cd "$TERMINAL_ROOT" && zip -j "bin/$zip_name" "${items[@]}")

    echo "Packed bin/$zip_name"
    deploy_to_downloads "bin" "$zip_name"
}

# --------------------------------------------------------------------------------
# pack_src - this tool's own .c/.h, plus every .c/.h resolved from <tool>.pmake's
# libs= line, into bin/<tool>_src_v<ver>.zip, then verified against every reachable
# dependencies.txt (see resolve_deps above) before anything gets zipped. Paths kept
# relative to TERMINAL_ROOT so the zip unpacks into the same layout the sources
# actually live in.
# --------------------------------------------------------------------------------
pack_src() {
    local pmake_file="$TOOL_DIR/$TOOL.pmake"
    local zip_name="${TOOL}_src_v${VERSION}.zip"
    local -a files=()
    local -a missing=()

    if [ ! -f "$pmake_file" ]; then
        echo "No such file: $pmake_file"
        exit 1
    fi

    # This project's own sources, plus its own <tool>.pmake build recipe.
    local f
    for f in "$TOOL_DIR"/*.c "$TOOL_DIR"/*.h "$TOOL_DIR"/*.pmake; do
        [ -f "$f" ] && files+=("$f")
    done

    # Everything libs= pulls in from shared/toolbox - skip compiler/linker flags
    # (-lncurses, -framework Foo), resolve the rest (globs included) relative to
    # TOOL_DIR, same as pmake itself does when it builds this project. Each
    # shared/toolbox source also carries its own <name>.pmake build recipe
    # alongside its .c/.h - pull that in too when present.
    local libs_line token match hdr pmk
    libs_line="$(grep '^libs=' "$pmake_file" | head -1 | cut -d'=' -f2-)"

    for token in $libs_line; do
        case "$token" in
            -*) continue ;;
        esac
        for match in "$TOOL_DIR"/$token; do
            [ -f "$match" ] || continue
            # Resolve away any ".." (libs= paths like ../shared/toolbox/... are relative to
            # TOOL_DIR) - otherwise the zip ends up with entries like
            # "enigma/../shared/toolbox/cipher/enigma.c" instead of a clean
            # "shared/toolbox/cipher/enigma.c", and some unzip implementations refuse to
            # extract a ".." path entry at all (zip-slip protection).
            match="$(realpath "$match")"
            files+=("$match")
            case "$match" in
                *.c)
                    hdr="${match%.c}.h"
                    [ -f "$hdr" ] && files+=("$hdr")
                    pmk="${match%.c}.pmake"
                    [ -f "$pmk" ] && files+=("$pmk")
                    ;;
            esac
        done
    done

    # Checksum verification: walk every .c file found so far against its own
    # dependencies.txt entry (own sources and everything libs= just pulled in
    # alike) and make sure each declared dependency actually resolves - this is
    # what catches something like version.h, which no .c file implements and
    # libs= (a list of .c files) can therefore never express.
    local c_snapshot
    for c_snapshot in "${files[@]}"; do
        case "$c_snapshot" in
            *.c) resolve_deps "$c_snapshot" ;;
        esac
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Dependency check failed - missing:"
        local m
        for m in "${missing[@]}"; do
            echo "  $m"
        done
        exit 1
    fi

    if [ ${#files[@]} -eq 0 ]; then
        echo "No .c/.h files found to pack."
        exit 1
    fi

    rm -f "$TERMINAL_ROOT/bin/$zip_name"

    # Bundle the pmake build tool itself (from ~/bin/pmake, not this repo's own
    # bin/<tool> output) under bin/pmake, so the extracted source zip can be
    # rebuilt without pmake having to be installed separately first.
    local pmake_tool="$HOME/bin/pmake"
    local pmake_added=0
    if [ -f "$pmake_tool" ]; then
        local bin_stage_dir
        bin_stage_dir="$(mktemp -d)"
        mkdir -p "$bin_stage_dir/bin"
        cp "$pmake_tool" "$bin_stage_dir/bin/pmake"
        chmod +x "$bin_stage_dir/bin/pmake"
        (cd "$bin_stage_dir" && zip "$TERMINAL_ROOT/bin/$zip_name" bin/pmake)
        rm -rf "$bin_stage_dir"
        pmake_added=1
    else
        echo "Warning: $pmake_tool not found - packing sources without the pmake tool."
    fi

    # Bundle Notes.txt (from the canonical ~/dev/scripts/notes_src.txt copy) at the
    # zip root, warning the user that bin/pmake is a prebuilt binary and will
    # trigger the same Gatekeeper/SmartScreen warning as the tool itself - only
    # relevant if pmake actually got bundled above.
    local notes_src="$HOME/dev/scripts/notes_src.txt"
    local notes_added=0
    if [ "$pmake_added" -eq 1 ]; then
        if [ -f "$notes_src" ]; then
            local notes_stage_dir
            notes_stage_dir="$(mktemp -d)"
            cp "$notes_src" "$notes_stage_dir/Notes.txt"
            (cd "$notes_stage_dir" && zip "$TERMINAL_ROOT/bin/$zip_name" Notes.txt)
            rm -rf "$notes_stage_dir"
            notes_added=1
        else
            echo "Warning: $notes_src not found - packing bin/pmake without its Notes.txt."
        fi
    fi

    # Bundle scripts/compile.sh (and compile.ps1, if present) from the canonical
    # ~/dev/scripts/ copy, so the extracted source zip can be rebuilt the same way
    # this repo's own scripts/ folder works: scripts/compile.sh <tool>.
    local scripts_src="$HOME/dev/scripts"
    local scripts_stage_dir sf
    scripts_stage_dir="$(mktemp -d)"
    mkdir -p "$scripts_stage_dir/scripts"
    local -a scripts_added=()
    for sf in compile.sh compile.ps1; do
        if [ -f "$scripts_src/$sf" ]; then
            cp "$scripts_src/$sf" "$scripts_stage_dir/scripts/$sf"
            [ "$sf" = "compile.sh" ] && chmod +x "$scripts_stage_dir/scripts/$sf"
            scripts_added+=("scripts/$sf")
        else
            echo "Warning: $scripts_src/$sf not found - skipping it in the source zip."
        fi
    done
    if [ ${#scripts_added[@]} -gt 0 ]; then
        (cd "$scripts_stage_dir" && zip "$TERMINAL_ROOT/bin/$zip_name" "${scripts_added[@]}")
    fi
    rm -rf "$scripts_stage_dir"

    # Zip with paths relative to TERMINAL_ROOT, so the archive unpacks into the same
    # folder layout the sources live in (enigma/enigma.c, shared/toolbox/logging/debug.c, ...).
    local rel_files=()
    for f in "${files[@]}"; do
        rel_files+=("${f#"$TERMINAL_ROOT"/}")
    done

    (cd "$TERMINAL_ROOT" && zip "bin/$zip_name" "${rel_files[@]}")

    local -a extras=()
    [ "$pmake_added" -eq 1 ] && extras+=("bin/pmake")
    [ "$notes_added" -eq 1 ] && extras+=("Notes.txt")
    extras+=("${scripts_added[@]}")
    if [ ${#extras[@]} -gt 0 ]; then
        local extras_str
        extras_str="$(IFS=', '; echo "${extras[*]}")"
        echo "Packed bin/$zip_name (${#files[@]} files + $extras_str)"
    else
        echo "Packed bin/$zip_name (${#files[@]} files)"
    fi
    deploy_to_downloads "src" "$zip_name"
}

case "$MODE" in
    -bin) pack_bin ;;
    -src) pack_src ;;
esac
