dnf check-update
sudo dnf upgrade --refresh -y
sudo dnf autoremove -y && sudo dnf clean all -y

fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update

rm ~/Pictures/Screenshots
