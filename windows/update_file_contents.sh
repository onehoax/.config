#! /bin/bash

set -e

cp "$WHOME/.wslconfig" ~/.config/windows/.wslconfig

cp "$WHOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" \
  ~/.config/windows/terminal_settings.json

cp "$WHOME/AppData/Roaming/Code/User/settings.json" \
  ~/.config/windows/vscode/settings.json

cp "$WHOME/AppData/Roaming/Code/User/keybindings.json" \
  ~/.config/windows/vscode/keybindings.json
