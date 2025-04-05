#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Install the unzip tool if not already installed
echo "Installing unzip tool..."
apt-get update && apt-get install -y unzip

# Change to the user's home directory
cd ~

# Clone the Juneogo binaries repository
echo "Cloning the Juneogo binaries repository..."
git clone https://github.com/Juneo-io/juneogo-binaries

# Make the main binary and plugins executable
echo "Setting executable permissions..."
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/jevm
chmod +x ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

# Move the main binary to the home directory
echo "Moving the main binary to the home directory..."
mv ~/juneogo-binaries/juneogo ~

# Create the plugins directory and move plugins there
echo "Creating plugins directory and moving plugins..."
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/jevm ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e ~/.juneogo/plugins

# Create the systemd service file
echo "Creating the systemd service file..."
cat <<EOF | sudo tee /etc/systemd/system/juneogo.service
[Unit]
Description=Juneogo Service
After=network.target

[Service]
Type=simple
ExecStart=/root/juneogo
WorkingDirectory=/root
Restart=on-failure
RestartSec=5s
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling the Juneogo service to start on boot..."
sudo systemctl enable juneogo.service

# Start the service immediately
echo "Starting the Juneogo service..."
sudo systemctl start juneogo.service

# Wait for 30 seconds
sleep 30

# Stop the service to prepare for DB restoration
echo "Stopping the Juneogo service..."
sudo systemctl stop juneogo.service

# Rename the current database directory
echo "Renaming the current database directory..."
mv .juneogo/db .juneogo/db_old

# Download the snapshot DB zip file
echo "Downloading the snapshot DB file..."
wget http://212.90.121.86:6969/juneogo_mdb_backup.zip -P .juneogo

# Unzip the snapshot into the .juneogo directory
echo "Unzipping the snapshot DB file..."
unzip .juneogo/juneogo_mdb_backup.zip

sleep 10

# Verify if the DB replacement was successful
if [ -d ".juneogo/db" ]; then
    echo "DB replacement successful."
else
    echo "DB replacement failed. Please check manually."
fi

# Restart the Juneogo service with the new DB

# Reload systemd to apply the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Restarting the Juneogo service..."
sudo systemctl start juneogo.service

echo "Juneogo setup complete and service started as user 'juneo'."

# Prompt to backup NodeID and staking files
echo -n "Do you want to backup your NodeID and staking files? (yes/no): "
read backup_choice
echo "Backup choice received."

if [ "$backup_choice" == "yes" ]; then
    backup_dir="juneogo_staking_backup"
    
    # Create a backup directory in the root user's home directory
    mkdir -p $backup_dir
    
    # Copy the staking directory to the backup directory
    cp -r .juneogo/staking/ $backup_dir/
    
    echo "Backup complete. The NodeID and staking files have been copied to: $backup_dir"
else
    echo "No backup was made. Exiting."
fi
