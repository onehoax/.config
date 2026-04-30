dnf check-update
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y && sudo dnf clean all -y

fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update

gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
gsettings get org.gnome.desktop.input-sources xkb-options

rm ~/Pictures/Screenshots

########### snapshot+backup setup ###############

# Create DNF pre/post hook - only run for root config
sudo dnf install snapper btrbk libdnf5-plugin-actions

sudo bash -c "cat > /etc/dnf/libdnf5-plugins/actions.d/snapper.actions" <<'EOF'
# Get snapshot description
pre_transaction::::/usr/bin/sh -c echo\ "tmp.cmd=$(ps\ -o\ command\ --no-headers\ -p\ '${pid}')"

# Creates pre snapshot before the transaction and stores the snapshot number in the "tmp.snapper_pre_number"  variable.
pre_transaction::::/usr/bin/sh -c echo\ "tmp.snapper_pre_number=$(snapper\ create\ -t\ pre\ -c\ number\ -p\ -d\ '${tmp.cmd}')"

# If the variable "tmp.snapper_pre_number" exists, it creates post snapshot after the transaction and removes the variable "tmp.snapper_pre_number".
post_transaction::::/usr/bin/sh -c [\ -n\ "${tmp.snapper_pre_number}"\ ]\ &&\ snapper\ create\ -t\ post\ --pre-number\ "${tmp.snapper_pre_number}"\ -c\ number\ -d\ "${tmp.cmd}"\ ;\ echo\ tmp.snapper_pre_number\ ;\ echo\ tmp.cmd
EOF

sudo cat /etc/dnf/libdnf5-plugins/actions.d/snapper.actions

sudo snapper -c root create-config /
sudo snapper -c home create-config /home
sudo snapper list-configs
sudo ls -al /.snapshots
sudo ls -al /home/.snapshots/

# Restore the correct SELinux contexts for the .snapshots directories:
sudo restorecon -RFv /.snapshots
sudo restorecon -RFv /home/.snapshots
# Verify SELinux labels: they all should have `snapperd_data_t`
ls -1dZ /.snapshots /home/.snapshots

# Verify corresponding subvolumes: should see `path .snapshots` and `path home/.snapshots`
sudo btrfs subvolume list /

# Verify snapshots
sudo snapper -c root ls
sudo snapper -c home ls

# Enable time-based snap creation (optional)
sudo systemctl enable --now snapper-timeline.timer
sudo systemctl status snapper-timeline.timer

# Enable snap cleanup
sudo systemctl enable --now snapper-cleanup.timer
sudo systemctl status snapper-cleanup.timer

# Disable time-based snaps
sudo snapper -c root set-config TIMELINE_CREATE=no TIMELINE_CLEANUP=no
sudo snapper -c home set-config TIMELINE_CREATE=no TIMELINE_CLEANUP=no

# Modify retention policy
sudo snapper -c root set-config NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5
sudo snapper -c home set-config NUMBER_LIMIT=10 NUMBER_LIMIT_IMPORTANT=5

# Verify
sudo cat /etc/snapper/configs/root
sudo cat /etc/snapper/configs/home

# Verify pre/post flow
sudo dnf upgrade --refresh
sudo snapper -c root list
sudo snapper status 0..2
sudo ls -al /.snapshots

# DNF pre/post snaps do NOT include `/home` because there is a lot of constant noise in this subvolume; create on a per-need basis
sudo snapper -c home create -d "sample"
sudo ls -al /home/.snapshots
sudo snapper status 0..1
sudo snapper -c home remove 1
sudo snapper -c home ls
