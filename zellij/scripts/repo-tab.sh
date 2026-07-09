#!/bin/bash

# Make it available globaly through a soft link:
#   `ln -s ~/.config/zellij/scripts/repo-tab.sh ~/.local/bin/zrt`

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $(basename "$0") <session> <name> <path>"
    exit 1
fi

session="$1"
name="$2"
path="$3"

zellij -s "$session" action new-tab -l repo -n "$name" -c "$path"
