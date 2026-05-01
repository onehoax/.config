# DESCRIPTION

Fedora setup.

# NVIDIA

1. Enables NVIDIA kernel mode-setting (KMS)

   ```bash
   # edits all installed kernel boot entries
   sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"
   sudo systemctl reboot

   # verify
   cat /proc/cmdline | grep nvidia
   ```

# SUSPEND

There are usually problems with suspend when using NVIDIA and external monitor; there are the workarounds:

- Fix builtin screen black after suspend
  ```bash
  sudo systemctl restart display-manager
  ```
- Gnome settings
  ```bash
  # disable suspend
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
  ```
