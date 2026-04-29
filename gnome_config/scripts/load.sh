#!/bin/bash

dconf load /org/gnome/Ptyxis/ < ~/.config/gnome_config_track/settings/ptyxis.ini

dconf load /org/gnome/desktop/calendar/ < ~/.config/gnome_config_track/settings/desktop_calendar.ini
dconf load /org/gnome/desktop/datetime/ < ~/.config/gnome_config_track/settings/desktop_datetime.ini
dconf load /org/gnome/desktop/input-sources/ < ~/.config/gnome_config_track/settings/desktop_input_sources.ini
dconf load /org/gnome/desktop/interface/ < ~/.config/gnome_config_track/settings/desktop_interface.ini
dconf load /org/gnome/desktop/peripherals/ < ~/.config/gnome_config_track/settings/desktop_peripherals.ini
dconf load /org/gnome/desktop/privacy/ < ~/.config/gnome_config_track/settings/desktop_privacy.ini
dconf load /org/gnome/desktop/wm/ < ~/.config/gnome_config_track/settings/desktop_wm.ini

dconf load /org/gnome/mutter/ < ~/.config/gnome_config_track/settings/mutter.ini

dconf load /org/gnome/nautilus/preferences/ < ~/.config/gnome_config_track/settings/nautilus_preferences.ini

dconf load /org/gnome/settings-daemon/plugins/color/ < ~/.config/gnome_config_track/settings/settings_daemon_plugins_color.ini
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/.config/gnome_config_track/settings/settings_daemon_plugins_media_keys.ini

dconf load /org/gnome/shell/keybindings/ < ~/.config/gnome_config_track/settings/shell_keybindings.ini

dconf load /org/gnome/system/location/ < ~/.config/gnome_config_track/settings/system_location.ini
