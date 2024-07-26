#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo ./setup_juneogo.sh"
    exit 1
fi

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

echo "Juneogo setup complete and service started."
