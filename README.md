# Juneogo Setup Script (For Socotra Testnet) 
** This is not for Mainnet**

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

2. **Start and Stop the service:**
   ```bash
   #Reloading the systemctl file:
   sudo systemctl daemon-reload

   #Enabling a service:
   sudo systemctl enable juneogo.service

   #Starting a Service:
   sudo systemctl start juneogo.service

   #Note the above commands are already executed in the auto-installer, this is noted for future uses.

   #Restarting a Service:
   sudo systemctl restart juneogo.service

   #Stopping a service:
   sudo systemctl start juneogo.service

   #Disabling a service:
   sudo systemctl disable juneogo.service

3. **Check Status:**
   ```bash
   sudo systemctl status juneogo.service
   sudo journalctl -u juneogo.service

4. **Check Bootstrapping Status:**
   ```bash
   curl -X POST --data '{
    "jsonrpc":"2.0",
    "id"     :1,
    "method" :"info.isBootstrapped",
    "params": {
        "chain":"JUNE"
    }
   }' -H 'content-type:application/json;' 127.0.0.1:9650/ext/info

5 **When the output is like this**

   {
     "jsonrpc": "2.0",
     "result": {
       "isBootstrapped": true
     },
     "id": 1
   }

Follow the given steps on this document
Link - https://docs.juneo.com/intro/validate/add-a-validator
   


