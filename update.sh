#!/bin/bash

# update-juneo.sh

set -e

echo "🔄 Updating Juneogo node..."

# 1. Stop the systemd service
echo "⛔ Stopping juneogo systemd service..."
sudo systemctl stop juneogo.service

# 2. Backup current binary and plugins
BACKUP_DIR="$HOME/juneo-backup-$(date +%Y%m%d%H%M%S)"
echo "📦 Backing up current binaries to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
mv ~/juneogo "$BACKUP_DIR/" 2>/dev/null || echo "No juneogo binary found."
mv ~/.juneogo/plugins "$BACKUP_DIR/" 2>/dev/null || echo "No plugins directory found."

# 3. Get latest binaries
echo "⬇️ Cloning latest juneogo-binaries repo..."
git clone https://github.com/Juneo-io/juneogo-binaries ~/juneogo-binaries

# 4. Set permissions
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/*

# 5. Move binaries to proper locations
echo "🚚 Moving updated binaries..."
mv ~/juneogo-binaries/juneogo ~
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/* ~/.juneogo/plugins/

# 6. Cleanup
rm -rf ~/juneogo-binaries

# 7. Restart systemd service
echo "🚀 Restarting juneogo systemd service..."
sudo systemctl daemon-reload
sudo systemctl start juneogo.service

echo "✅ Juneogo node updated and restarted successfully."
