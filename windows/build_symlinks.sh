#! /bin/bash

set -e

ln -sf "$WHOME/.wslconfig" ~/.config/windows/.wslconfig

ln -sf \
  "$WHOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" \
  ~/.config/windows/terminal_settings.json

ln -sf \
  "$WHOME/AppData/Roaming/Code/User/settings.json" \
  ~/.config/windows/vscode/settings.json

ln -sf \
  "$WHOME/AppData/Roaming/Code/User/keybindings.json" \
  ~/.config/windows/vscode/keybindings.json
