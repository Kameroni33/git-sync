#!/bin/bash

# Copy the service file to systemd directory
sudo cp git_sync.service /etc/systemd/system/

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start git_sync.service

# Enable the service to start on boot
sudo systemctl enable git_sync.service

# Add custom commands to the service
sudo cp commands.sh /usr/local/bin/git_sync_commands.sh
sudo chmod +x /usr/local/bin/git_sync_commands.sh

# Create the git-sync man page
sudo cp man_entry.txt /usr/share/man/man1/git-sync.1

echo "Service installed and started."
