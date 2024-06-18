#!/bin/bash

# Change to home directory
cd ~

# Clone the repository
git clone https://github.com/Juneo-io/juneogo-binaries

# Make the main binary executable
chmod +x ~/juneogo-binaries/juneogo

# Make the plugin binaries executable
chmod +x ~/juneogo-binaries/plugins/jevm
chmod +x ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

# Move the main binary to the home directory
mv ~/juneogo-binaries/juneogo ~

# Create the plugins directory
mkdir -p ~/.juneogo/plugins

# Move the plugins to the plugins directory
mv ~/juneogo-binaries/plugins/jevm ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e ~/.juneogo/plugins

# Create the systemd service file
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
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable juneogo.service

# Start the service immediately
sudo systemctl start juneogo.service

echo "Juneogo setup complete and service started."
