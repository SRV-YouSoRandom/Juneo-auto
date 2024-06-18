# Juneogo Setup Script

This repository contains a script to set up Juneogo binaries and create a systemd service for it.

## Prerequisites

- Ubuntu or a similar Linux distribution
- `git` installed on your system

## Installation Instructions

1. **Run the script:**
   Open a terminal and run the following command to clone the repository:
   ```bash
   git clone https://github.com/Srv8/Juneo-auto
   cd Juneo-auto
   chmod +x setup.sh
   sudo ./setup.sh

2. **Start the service:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable juneogo.service
   sudo systemctl start juneogo.service

3. **Check Status:**
   ```bash
   sudo systemctl status juneogo.service
   sudo journalctl -u juneogo.service

   


