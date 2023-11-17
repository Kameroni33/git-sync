#!/bin/bash

# Stop and disable the service
sudo systemctl stop automated_script.service
sudo systemctl disable automated_script.service

# Remove the service file
sudo rm /etc/systemd/system/automated_script.service

# Remove the script_control.sh file
sudo rm /usr/local/bin/script_control.sh

# Remove the man page
sudo rm /usr/share/man/man1/git-sync.1.gz

echo "Service uninstalled."
