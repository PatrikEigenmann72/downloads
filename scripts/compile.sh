#!/bin/bash
# ------------------------------------------------------------------------------------
# Script:       compile.sh
# Description:  Builds one tool in this terminal project by name (its folder must contain
#               a matching <tool>.pmake). Just forwards to pmake from inside that folder.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Sun 2026-08-23 File created, ported from legacy's own copy - LEGACY_ROOT      Version: 00.01
#                renamed TERMINAL_ROOT, same as arcade's copy renames it
#                ARCADE_ROOT. Otherwise identical.
# Mon 2026-08-24 Removed -DDEBUG from the help text - pmake dropped that flag   Version: 00.02
#                entirely (see pmake's own changelog); any extra argument here
#                still forwards straight through to pmake, so its real flags
#                (-DDEBUG for the target project's own build, --debug/--keywords
#                for pmake's own diagnostics) work exactly as pmake documents
#                them, this script just never claimed the wrong one before.
# ------------------------------------------------------------------------------------

show_help() {
cat << EOF
NAME
    compile.sh - build one tool in the terminal project

SYNOPSIS
    scripts/compile.sh <tool> [pmake args...]

DESCRIPTION
    Builds the <tool> folder using its <tool>.pmake file. Any extra arguments
    are forwarded straight through to pmake - see 'pmake -h' for what it
    accepts (-DDEBUG, --debug, --keywords). Run from anywhere inside the
    terminal project.

EXAMPLES
    scripts/compile.sh pmake
    scripts/compile.sh enigma -DDEBUG
    scripts/compile.sh enigma --debug:warn
EOF
}

case "$1" in
    -h|-help|-\?|"")
        show_help
        exit 0
        ;;
esac

set -e

TOOL="$1"
shift

TERMINAL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL_DIR="$TERMINAL_ROOT/$TOOL"

if [ ! -d "$TOOL_DIR" ]; then
    echo "No such tool folder: $TOOL_DIR"
    exit 1
fi

echo "Building $TOOL..."
cd "$TOOL_DIR"
pmake "$TOOL" "$@"

# pmake names its output "<tool>_<suffix>" (version, and OS if is_os_gnostic=on). Collapse
# that down to a plain "<tool>" binary.
BUILT="$(ls -t "$TERMINAL_ROOT/bin/${TOOL}"_* 2>/dev/null | head -n1)"
if [ -n "$BUILT" ]; then
    mv "$BUILT" "$TERMINAL_ROOT/bin/$TOOL"
fi

echo "Done. Type 'bin/$TOOL' (from $TERMINAL_ROOT) to run."
