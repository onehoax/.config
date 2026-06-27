#!/bin/bash

# Configure individual settings: gsettings (gsettings set SCHEMA KEY VALUE)
# Backup/restore groups of settings: dconf dump and dconf load
# You can use dconf to set settings as well but gsettings is a better interface for setting

gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"

gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:swap_lalt_lctl', 'caps:escape']"

gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Super>h']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Super>l']"

gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>grave']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>grave']"
gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>m']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-left "['<Super><Shift>h']"
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-right "['<Super><Shift>l']"
