#!/bin/bash

# Catch any errors that occur during uninstall
set -e
trap 'echo "Error: An error occurred during uninstall. Exiting."' ERR

# Stop and disable the service
sudo systemctl stop gitsync.service
sudo systemctl disable gitsync.service

# Remove the service file
sudo rm /etc/systemd/system/gitsync.service

# Remove man page for service
sudo rm /usr/share/man/man1/gitsync.1

# Reload systemd
sudo systemctl daemon-reload

echo "Service uninstalled."
