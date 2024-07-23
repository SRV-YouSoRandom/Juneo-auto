#!/bin/bash

# Define colors for styling
NC='\033[0m'      # No Color
RED='\033[0;31m'  # Red
GREEN='\033[0;32m' # Green
YELLOW='\033[0;33m' # Yellow
BLUE='\033[0;34m'  # Blue
MAGENTA='\033[0;35m' # Magenta
CYAN='\033[0;36m'  # Cyan

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script must be run as root. Use sudo ./setup_juneogo.sh${NC}"
    exit 1
fi

# Prompt the user for a password or use the default root password
read -p "$(echo -e ${CYAN}Enter a password for the 'juneo' user (leave blank to use root password): ${NC})" juneo_password
if [ -z "$juneo_password" ]; then
    juneo_password=$(grep "^root:" /etc/shadow | cut -d: -f2)
    echo -e "${YELLOW}Using root password for 'juneo' user.${NC}"
else
    echo -e "${YELLOW}Using provided password for 'juneo' user.${NC}"
fi

# Create a new user called juneo if it doesn't exist
if ! id -u juneo > /dev/null 2>&1; then
    echo -e "${BLUE}Creating new user 'juneo'...${NC}"
    useradd -m -s /bin/bash juneo
    echo "juneo:$juneo_password" | chpasswd
else
    echo -e "${BLUE}User 'juneo' already exists.${NC}"
fi

# Switch to the new user and execute the rest of the script
sudo -u juneo -i <<'EOF'
# Change to the user's home directory
echo -e "${GREEN}Changing to the user's home directory...${NC}"
cd ~

# Clone the Juneogo binaries repository
echo -e "${GREEN}Cloning the Juneogo binaries repository...${NC}"
git clone https://github.com/Juneo-io/juneogo-binaries

# Make the main binary and plugins executable
echo -e "${GREEN}Setting executable permissions...${NC}"
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/jevm
chmod +x ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

# Move the main binary to the home directory
echo -e "${GREEN}Moving the main binary to the home directory...${NC}"
mv ~/juneogo-binaries/juneogo ~

# Create the plugins directory and move plugins there
echo -e "${GREEN}Creating plugins directory and moving plugins...${NC}"
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/jevm ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e ~/.juneogo/plugins

EOF

# Create the systemd service file
echo -e "${BLUE}Creating the systemd service file...${NC}"
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
echo -e "${YELLOW}Reloading systemd daemon...${NC}"
sudo systemctl daemon-reload

# Enable the service to start on boot
echo -e "${YELLOW}Enabling the Juneogo service to start on boot...${NC}"
sudo systemctl enable juneogo.service

# Start the service immediately
echo -e "${GREEN}Starting the Juneogo service...${NC}"
sudo systemctl start juneogo.service

# Prompt the user to backup files
read -p "$(echo -e ${CYAN}Would you like to backup the staking and signer files? (yes/no): ${NC})" backup_choice
if [ "$backup_choice" == "yes" ]; then
    echo -e "${RED}Stopping the Juneogo service...${NC}"
    sudo systemctl stop juneogo.service

    # Create the backup directory and backup the files
    backup_dir="/home/juneo/backup"
    echo -e "${BLUE}Creating backup directory at $backup_dir...${NC}"
    mkdir -p $backup_dir

    echo -e "${BLUE}Backing up staker.crt, staker.key, and signer.key...${NC}"
    cp /home/.juneogo/staking/staker.crt $backup_dir
    cp /home/.juneogo/staking/staker.key $backup_dir
    cp /home/.juneogo/staking/signer.key $backup_dir

    echo -e "${GREEN}Starting the Juneogo service...${NC}"
    sudo systemctl start juneogo.service
fi

echo -e "${GREEN}Juneogo setup complete and service started.${NC}"
