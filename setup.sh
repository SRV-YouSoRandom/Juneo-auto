#!/bin/bash

# Define colors for styling
NC='\033[0m'      # No Color
RED='\033[0;31m'  # Red
GREEN='\033[0;32m' # Green
YELLOW='\033[0;33m' # Yellow
BLUE='\033[0;34m'  # Blue
MAGENTA='\033[0;35m' # Magenta
CYAN='\033[0;36m'  # Cyan

# Function to print messages with colors
print_msg() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${NC}"
}

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    print_msg "$RED" "This script must be run as root. Use sudo ./setup_juneogo.sh"
    exit 1
fi

# Prompt the user for a password or use the default password
print_msg "$CYAN" "Enter a password for the 'juneo' user (leave blank to use 'defaultpassword'): "
read -s juneo_password
if [ -z "$juneo_password" ]; then
    juneo_password="defaultpassword"
    print_msg "$YELLOW" "Using default password for 'juneo' user."
else
    print_msg "$YELLOW" "Using provided password for 'juneo' user."
fi

# Create a new user called juneo if it doesn't exist
if ! id -u juneo > /dev/null 2>&1; then
    print_msg "$BLUE" "Creating new user 'juneo'..."
    useradd -m -s /bin/bash juneo
    echo "juneo:$juneo_password" | chpasswd
else
    print_msg "$BLUE" "User 'juneo' already exists."
fi

# Ensure the home directory for 'juneo' user exists and has correct permissions
if [ ! -d "/home/juneo" ]; then
    print_msg "$BLUE" "Creating home directory for 'juneo' user..."
    mkdir -p /home/juneo
fi

# Correct ownership and permissions
print_msg "$BLUE" "Setting ownership and permissions for /home/juneo..."
chown -R juneo:juneo /home/juneo
chmod 755 /home/juneo

# Grant sudo privileges to the juneo user
if ! sudo grep -q "^juneo " /etc/sudoers; then
    print_msg "$BLUE" "Granting sudo privileges to 'juneo' user..."
    echo "juneo ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

# Switch to the new user and execute the rest of the script
sudo -u juneo -i <<'EOF'
# Define colors for styling inside the sudo block
NC='\033[0m'      # No Color
GREEN='\033[0;32m' # Green
CYAN='\033[0;36m'  # Cyan

# Function to print messages with colors
print_msg() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${NC}"
}

# Change to the user's home directory
print_msg "$GREEN" "Changing to the user's home directory..."
cd ~

# Clone the Juneogo binaries repository
print_msg "$GREEN" "Cloning the Juneogo binaries repository..."
git clone https://github.com/Juneo-io/juneogo-binaries

# Make the main binary and plugins executable
print_msg "$GREEN" "Setting executable permissions..."
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/jevm
chmod +x ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

# Move the main binary to the home directory
print_msg "$GREEN" "Moving the main binary to the home directory..."
mv ~/juneogo-binaries/juneogo ~

# Create the plugins directory and move plugins there
print_msg "$GREEN" "Creating plugins directory and moving plugins..."
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/jevm ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e ~/.juneogo/plugins

EOF

# Create the systemd service file
print_msg "$BLUE" "Creating the systemd service file..."
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
print_msg "$YELLOW" "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable the service to start on boot
print_msg "$YELLOW" "Enabling the Juneogo service to start on boot..."
sudo systemctl enable juneogo.service

# Start the service immediately
print_msg "$GREEN" "Starting the Juneogo service..."
sudo systemctl start juneogo.service

# Prompt the user to backup files
print_msg "$CYAN" "Would you like to backup the staking and signer files? (yes/no): "
read backup_choice
if [ "$backup_choice" == "yes" ]; then
    print_msg "$RED" "Stopping the Juneogo service..."
    sudo systemctl stop juneogo.service

    # Create the backup directory and backup the files
    backup_dir="/home/juneo/backup"
    print_msg "$BLUE" "Creating backup directory at $backup_dir..."
    mkdir -p $backup_dir

    print_msg "$BLUE" "Backing up staker.crt, staker.key, and signer.key..."
    cp /home/juneo/.juneogo/staking/staker.crt $backup_dir
    cp /home/juneo/.juneogo/staking/staker.key $backup_dir
    cp /home/juneo/.juneogo/staking/signer.key $backup_dir

    print_msg "$GREEN" "Starting the Juneogo service..."
    sudo systemctl start juneogo.service
fi

print_msg "$GREEN" "Juneogo setup complete and service started."
