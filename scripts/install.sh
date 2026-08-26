#!/bin/bash
# ------------------------------------------------------------------------------------
# Script:       install.sh
# Description:  Installs one tool's already-built binary (bin/<tool>) into ~/bin, making
#               it globally runnable. Build it first with scripts/compile.sh <tool>.
# ------------------------------------------------------------------------------------
# Author:       Patrik Eigenmann
# eMail:        p.eigenmann@gmx.net
# ------------------------------------------------------------------------------------
# Change Log:
# Mon 2026-08-24 File created.                                                Version: 00.01
# ------------------------------------------------------------------------------------

show_help() {
cat << EOF
NAME
    install.sh - install one tool's binary into ~/bin

SYNOPSIS
    scripts/install.sh <tool>

DESCRIPTION
    Copies bin/<tool> to ~/bin/<tool>. Run scripts/compile.sh <tool> first if
    bin/<tool> doesn't exist yet.

EXAMPLES
    scripts/install.sh pmake
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

TERMINAL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN_PATH="$TERMINAL_ROOT/bin/$TOOL"

if [ ! -f "$BIN_PATH" ]; then
    echo "No such binary: $BIN_PATH (build it first with scripts/compile.sh $TOOL)"
    exit 1
fi

mkdir -p "$HOME/bin"
cp "$BIN_PATH" "$HOME/bin/$TOOL"
chmod +x "$HOME/bin/$TOOL"

echo "Installed $TOOL to $HOME/bin/$TOOL"
