#!/bin/bash

# Make it available globaly through a soft link:
#   `ln -s ~/.config/scripts/fedora/update.sh ~/.local/bin/fedora-update`

sudo dnf upgrade --refresh -y
sudo dnf autoremove -y
sudo dnf clean all

flatpak update -y
flatpak uninstall --unused -y

fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update

rm ~/Pictures/Screenshots/*
