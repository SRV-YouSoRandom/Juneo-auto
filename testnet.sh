#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Install unzip tool if not already installed
echo "Installing unzip tool..."
apt-get update && apt-get install -y unzip

# Prompt for the password of the new user 'juneo'
echo -n "Please enter a password for the 'juneo' user: "
read -s juneo_password
echo
echo "Password entered."

# Check if the user 'juneo' already exists, and create if not
if id "juneo" &>/dev/null; then
    echo "User 'juneo' already exists."
else
    echo "Creating new user 'juneo'..."
    useradd -m -s /bin/bash juneo
    echo "juneo:$juneo_password" | chpasswd
    echo "User 'juneo' created successfully."
    
    # Add the juneo user to the sudo group
    echo "Adding 'juneo' user to the sudo group..."
    usermod -aG sudo juneo
    echo "'juneo' user added to the sudo group."
fi

# Change to the juneo user's home directory
cd /home/juneo

# Clone the Juneogo binaries repository
echo "Cloning the Juneogo binaries repository..."
sudo -u juneo git clone https://github.com/Juneo-io/juneogo-binaries /home/juneo/juneogo-binaries

# Make the main binary and plugins executable
echo "Setting executable permissions..."
chmod +x /home/juneo/juneogo-binaries/juneogo
chmod +x /home/juneo/juneogo-binaries/plugins/jevm
chmod +x /home/juneo/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

# Move the main binary to the juneo user's home directory
echo "Moving the main binary to the home directory..."
mv /home/juneo/juneogo-binaries/juneogo /home/juneo

# Create the plugins directory and move plugins there
echo "Creating plugins directory and moving plugins..."
mkdir -p /home/juneo/.juneogo/plugins
mv /home/juneo/juneogo-binaries/plugins/jevm /home/juneo/.juneogo/plugins
mv /home/juneo/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e /home/juneo/.juneogo/plugins

# Change ownership of all files to the juneo user
chown -R juneo:juneo /home/juneo

# Create the systemd service file
echo "Creating the systemd service file..."
cat <<EOF | sudo tee /etc/systemd/system/juneogo.service
[Unit]
Description=Juneogo Service
After=network.target

[Service]
Type=simple
ExecStart=/home/juneo/juneogo
WorkingDirectory=/home/juneo
Restart=on-failure
User=juneo

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling the Juneogo service to start on boot..."
sudo systemctl enable juneogo.service

# Start the service to generate the necessary directories
echo "Starting the Juneogo service..."
sudo systemctl start juneogo.service

# Wait for 30 seconds
sleep 30

# Stop the service to prepare for DB restoration
echo "Stopping the Juneogo service..."
sudo systemctl stop juneogo.service

# Rename the current database directory
echo "Renaming the current database directory..."
mv /home/juneo/.juneogo/db /home/juneo/.juneogo/db_old

# Download the snapshot DB zip file
echo "Downloading the snapshot DB file..."
wget /home/juneo/.juneogo http://212.90.121.86:6969/juneogo_db_backup.zip

# Unzip the snapshot into the .juneogo directory
echo "Unzipping the snapshot DB file..."
unzip /home/juneo/.juneogo/juneogo_db_backup.zip

sleep 10

# Verify if the DB replacement was successful
if [ -d "/home/juneo/.juneogo/db" ]; then
    echo "DB replacement successful."
else
    echo "DB replacement failed. Please check manually."
fi

# Restart the Juneogo service with the new DB
echo "Restarting the Juneogo service..."
sudo systemctl start juneogo.service

echo "Juneogo setup complete and service started as user 'juneo'."

# Prompt to backup NodeID and staking files
echo -n "Do you want to backup your NodeID and staking files? (yes/no): "
read backup_choice
echo "Backup choice received."

if [ "$backup_choice" == "yes" ]; then
    backup_dir="/root/juneogo_staking_backup"
    
    # Create backup directory in the root user's home directory
    mkdir -p $backup_dir
    
    # Copy the staking directory to the backup directory
    cp -r /home/juneo/.juneogo/staking/ $backup_dir/
    
    echo "Backup complete. The NodeID and staking files have been copied to: $backup_dir"
else
    echo "No backup was made. Exiting."
fi
