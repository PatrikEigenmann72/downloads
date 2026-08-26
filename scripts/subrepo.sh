#!/bin/bash
# ------------------------------------------------------------------------------------
# Script:       subrepo.sh
# Description:  Pulls or pushes git-subrepo(s) under shared/. Give a name to target one
#               (e.g. "toolbox"), or omit it to act on every shared/*/.gitrepo found.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Sun 2026-08-23 File created.                                                Version: 00.01
# Mon 2026-08-24 Split the case block's catch-all in two: a genuinely unknown  Version: 00.02
#                action (e.g. a typo) now prints an error and exits 1, instead
#                of silently showing help and exiting 0 like a real -h/-help/-?
#                would - a typo looked identical to success. Also removed a
#                second "$1 = -h" check further down that could never run: the
#                case block above it already exits for every value except
#                literally "pull"/"push", so by the time execution reached that
#                check, $1 could never be -h/-help/-?/empty anymore.
# ------------------------------------------------------------------------------------

show_help() {
cat << EOF
NAME
    subrepo.sh - pull or push shared/ git-subrepos

SYNOPSIS
    scripts/subrepo.sh <pull|push> [name]

DESCRIPTION
    Runs "git subrepo <pull|push> shared/<name>". Without [name], runs it against
    every subdirectory of shared/ that has a .gitrepo file.

EXAMPLES
    scripts/subrepo.sh pull toolbox
    scripts/subrepo.sh push
EOF
}

case "$1" in
    -h|-help|-\?|"")
        show_help
        exit 0
        ;;
    pull|push)
        ;;
    *)
        echo "Unknown action: $1 (expected pull or push)"
        show_help
        exit 1
        ;;
esac

set -e

ACTION="$1"
NAME="$2"

TERMINAL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$TERMINAL_ROOT"

if [ -n "$NAME" ]; then
    TARGETS=("shared/$NAME")
else
    TARGETS=()
    for dir in shared/*/; do
        [ -f "${dir}.gitrepo" ] && TARGETS+=("${dir%/}")
    done
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo "No git-subrepos found under shared/."
    exit 1
fi

for target in "${TARGETS[@]}"; do
    if [ ! -f "$target/.gitrepo" ]; then
        echo "Skipping $target: no .gitrepo file."
        continue
    fi
    echo "== $ACTION $target =="
    git subrepo "$ACTION" "$target"
done
