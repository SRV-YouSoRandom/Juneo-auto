#!/bin/bash

# update.sh

set -e

# === CLEAN BEFORE ANYTHING ELSE ===
CLONE_DIR="$HOME/juneogo-binaries"

if [ -d "$CLONE_DIR" ]; then
    echo "🧹 Removing existing $CLONE_DIR directory..."
    rm -rf "$CLONE_DIR"
fi

echo "🔄 Updating Juneogo node..."

# Constants
BINARY_DIR="$HOME"
PLUGINS_DIR="$HOME/.juneogo/plugins"
BACKUP_DIR="$HOME/juneo-backup-$(date +%Y%m%d%H%M%S)"

# 1. Stop the systemd service
echo "⛔ Stopping juneogo systemd service..."
sudo systemctl stop juneogo.service

# 2. Backup current binary and plugins
echo "📦 Backing up current binaries to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
[ -f "$BINARY_DIR/juneogo" ] && mv "$BINARY_DIR/juneogo" "$BACKUP_DIR/" || echo "No juneogo binary found."
[ -d "$PLUGINS_DIR" ] && mv "$PLUGINS_DIR" "$BACKUP_DIR/" || echo "No plugins directory found."

# 3. Clone latest binaries
echo "⬇️ Cloning latest juneogo-binaries repo..."
git clone https://github.com/Juneo-io/juneogo-binaries "$CLONE_DIR"

# 4. Set executable permissions
echo "🔑 Setting executable permissions..."
chmod +x "$CLONE_DIR/juneogo"
chmod +x "$CLONE_DIR/plugins/"*

# 5. Move binaries and plugins into place
echo "🚚 Moving updated binaries..."
mv "$CLONE_DIR/juneogo" "$BINARY_DIR/"
mkdir -p "$PLUGINS_DIR"
mv "$CLONE_DIR/plugins/"* "$PLUGINS_DIR/"

# 6. Cleanup clone directory
rm -rf "$CLONE_DIR"

# 7. Restart the node
echo "🚀 Restarting juneogo systemd service..."
sudo systemctl daemon-reload
sudo systemctl start juneogo.service

echo "✅ Juneogo node updated and restarted successfully."
