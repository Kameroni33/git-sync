#!/bin/bash

# Catch any errors that occur during installation
set -e
trap 'echo "Error: An error occurred during installation. Exiting."' ERR

# Variables
service_file="$(pwd)/gitsync.service"
user=$( pwd | awk -F '/' '{print $3}' )

# Create required config files
touch ../config/repos.txt

# Generate .service file from template
cp "$service_file.template" "$service_file"
sed -i "s|User=*|User=$user|" "$service_file"
sed -i "s|WorkingDirectory=*|WorkingDirectory=$(pwd)|" "$service_file"
sed -i "s|ExecStart=*|ExecStart=$(pwd)/gitsync.sh|" "$service_file"

# Make required files executable
sudo chmod +x gitsync.sh

# Copy the .service file to systemd directory
sudo cp gitsync.service /etc/systemd/system/

# Reload systemd and start the service
sudo systemctl daemon-reload
sudo systemctl start gitsync.service

# Enable the service to start on boot
sudo systemctl enable gitsync.service

# Create man page for service
sudo cp man_entry.txt /usr/share/man/man1/gitsync.1

echo "Service installed and started."
