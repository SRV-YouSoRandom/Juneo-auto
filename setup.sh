#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo ./setup_juneogo.sh (juneo - new user will be created)"
    exit 1
fi

# Prompt the user for a password or use the default root password
read -p "Enter a password for the 'juneo' user (leave blank to use root password): " juneo_password
if [ -z "$juneo_password" ]; then
    juneo_password=$(grep "^root:" /etc/shadow | cut -d: -f2)
    echo "Using root password for 'juneo' user."
else
    echo "Using provided password for 'juneo' user."
fi

# Create a new user called juneo if it doesn't exist
if ! id -u juneo > /dev/null 2>&1; then
    echo "Creating new user 'juneo'..."
    useradd -m -s /bin/bash juneo
    echo "juneo:$juneo_password" | chpasswd
else
    echo "User 'juneo' already exists."
fi

# Switch to the new user and execute the rest of the script
sudo -u juneo -i <<'EOF'
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

EOF

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

# Start the service immediately
echo "Starting the Juneogo service..."
sudo systemctl start juneogo.service

# Prompt the user to backup files
read -p "Would you like to backup the staking and signer files? (yes/no): " backup_choice
if [ "$backup_choice" == "yes" ]; then
    echo "Stopping the Juneogo service..."
    sudo systemctl stop juneogo.service

    # Create the backup directory and backup the files
    backup_dir="/home/juneo/backup"
    echo "Creating backup directory at $backup_dir..."
    mkdir -p $backup_dir

    echo "Backing up staker.crt, staker.key, and signer.key..."
    cp /home/.juneogo/staking/staker.crt $backup_dir
    cp /home/.juneogo/staking/staker.key $backup_dir
    cp /home/.juneogo/staking/signer.key $backup_dir

    echo "Starting the Juneogo service..."
    sudo systemctl start juneogo.service
fi

echo "Juneogo setup complete and service started."
