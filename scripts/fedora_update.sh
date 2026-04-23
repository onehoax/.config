dnf check-update
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y && sudo dnf clean all -y

fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update

gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
gsettings get org.gnome.desktop.input-sources xkb-options

rm ~/Pictures/Screenshots

