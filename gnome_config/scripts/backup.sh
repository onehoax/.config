#!/bin/bash

mkdir -p ~/.config/gnome_config/settings

dconf dump /org/gnome/Ptyxis/ > ~/.config/gnome_config/settings/ptyxis.ini

dconf dump /org/gnome/desktop/calendar/ > ~/.config/gnome_config/settings/desktop_calendar.ini
dconf dump /org/gnome/desktop/datetime/ > ~/.config/gnome_config/settings/desktop_datetime.ini
dconf dump /org/gnome/desktop/input-sources/ > ~/.config/gnome_config/settings/desktop_input_sources.ini
dconf dump /org/gnome/desktop/interface/ > ~/.config/gnome_config/settings/desktop_interface.ini
dconf dump /org/gnome/desktop/peripherals/ > ~/.config/gnome_config/settings/desktop_peripherals.ini
dconf dump /org/gnome/desktop/privacy/ > ~/.config/gnome_config/settings/desktop_privacy.ini
dconf dump /org/gnome/desktop/wm/ > ~/.config/gnome_config/settings/desktop_wm.ini

dconf dump /org/gnome/mutter/ > ~/.config/gnome_config/settings/mutter.ini

dconf dump /org/gnome/nautilus/preferences/ > ~/.config/gnome_config/settings/nautilus_preferences.ini

dconf dump /org/gnome/settings-daemon/plugins/color/ > ~/.config/gnome_config/settings/settings_daemon_plugins_color.ini
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > ~/.config/gnome_config/settings/settings_daemon_plugins_media_keys.ini
dconf dump /org/gnome/settings-daemon/plugins/power/ > ~/.config/gnome_config/settings/settings_daemon_plugins_power.ini

dconf dump /org/gnome/shell/keybindings/ > ~/.config/gnome_config/settings/shell_keybindings.ini

dconf dump /org/gnome/system/location/ > ~/.config/gnome_config/settings/system_location.ini
