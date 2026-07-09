#!/bin/bash

# Make it available globaly through a soft link:
#   `ln -s ~/.config/zellij/scripts/work-tab.sh ~/.local/bin/zwt`

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $(basename "$0") <name> <path>"
    exit 1
fi

name="$1"
path="$2"

zellij -s work action new-tab -l work-general -n "$name" -c "$path"
