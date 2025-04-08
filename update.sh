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
mv ~/juneogo "$BACKUP_DIR/" 2>/dev/null || echo "No juneogo binary found to back up."
mv ~/.juneogo/plugins "$BACKUP_DIR/" 2>/dev/null || echo "No plugins directory found to back up."

# 3. Remove previous clone if it exists
if [ -d "$HOME/juneogo-binaries" ]; then
    echo "🧹 Removing existing juneogo-binaries directory..."
    rm -rf "$HOME/juneogo-binaries"
fi

# 4. Clone latest binaries
echo "⬇️ Cloning latest juneogo-binaries repo..."
git clone https://github.com/Juneo-io/juneogo-binaries ~/juneogo-binaries

# 5. Set executable permissions
echo "🔑 Setting executable permissions..."
chmod +x ~/juneogo-binaries/juneogo
chmod +x ~/juneogo-binaries/plugins/*

# 6. Move binaries into place
echo "🚚 Moving updated binaries..."
mv ~/juneogo-binaries/juneogo ~
mkdir -p ~/.juneogo/plugins
mv ~/juneogo-binaries/plugins/* ~/.juneogo/plugins/

# 7. Cleanup
rm -rf ~/juneogo-binaries

# 8. Restart the node
echo "🚀 Restarting juneogo systemd service..."
sudo systemctl daemon-reload
sudo systemctl start juneogo.service

echo "✅ Juneogo node updated and restarted successfully."
