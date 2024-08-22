#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo ./setup_juneogo.sh"
    exit 1
fi

# Prompt for the password of the new user 'juneo'
echo "Please enter a password for the 'juneo' user:"
read -s juneo_password

# Check if the user 'juneo' already exists, and create if not
if id "juneo" &>/dev/null; then
    echo "User 'juneo' already exists."
else
    echo "Creating new user 'juneo'..."
    useradd -m -s /bin/bash juneo
    echo "juneo:$juneo_password" | chpasswd
    echo "User 'juneo' created successfully."
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
ExecStart=/home/juneo/juneogo --network-id="socotra"
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

# Start the service immediately
echo "Starting the Juneogo service..."
sudo systemctl start juneogo.service

echo "Juneogo setup complete and service started as user 'juneo'."
