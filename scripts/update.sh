#!/bin/bash

# enable debug mode to print commands
set -x

sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo apt autoclean
sudo snap refresh
# sudo flatpak update

# disable debug mode to print commands
set +x
