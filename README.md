Here's the revised README file with proper formatting and internal links:

```markdown
# Juneogo Setup Script
**This is for Mainnet, not for Testnet**

- [Prerequisites](#prerequisites)
- [Installation Instructions](#installation-instructions)
- [Usage](#usage)
- [Backup Instructions](#backup-instructions)
- [Contributing](#contributing)
- [License](#license)

This repository contains a script to set up Juneogo binaries and create a systemd service for it. Installation guide below.

## Prerequisites

- Ubuntu or a similar Linux distribution
- `git` installed on your system

```bash
sudo apt-get update
```

## Installation Instructions

1. **Run the script:**
   
   Open a terminal and run the following command to clone the repository:
   ```bash
   git clone https://github.com/Srv8/Juneo-auto
   cd Juneo-auto
   chmod +x setup.sh
   sudo ./setup.sh
   ```

2. **Start and Stop the service:**
   
   ```bash
   # Reloading the systemctl file:
   sudo systemctl daemon-reload

   # Enabling a service:
   sudo systemctl enable juneogo.service

   # Starting a Service:
   sudo systemctl start juneogo.service

   # Checking status:
   sudo systemctl status juneogo.service

   # Note: The above commands are already executed in the auto-installer, this is noted for future uses.

   # Restarting a Service:
   sudo systemctl restart juneogo.service

   # Stopping a service:
   sudo systemctl stop juneogo.service

   # Disabling a service:
   sudo systemctl disable juneogo.service
   ```

3. **Check Status:**
   
   ```bash
   sudo systemctl status juneogo.service
   sudo journalctl -u juneogo.service
   ```

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
   ```

5. **When the output is like this:**
   
   ```bash
   {
     "jsonrpc": "2.0",
     "result": {
       "isBootstrapped": true
     },
     "id": 1
   }
   ```

6. **Check if connected to mainnet:**
   
   ```bash
   curl -X POST --data '{
     "jsonrpc":"2.0",
     "id"     :1,
     "method" :"info.getNetworkName"
   }' -H 'content-type:application/json;' 127.0.0.1:9650/ext/info
   ```

7. **To login as new user (juneo):**
   
   ```bash
   su - juneo
   ```
   This logs you to the new user, and you can use your commands.

Follow the given steps in this document: [Juneo Documentation](https://docs.juneo.com/intro/validate/add-a-validator)

__________________________________________________________________________________

## Backup Instructions

### How to backup my files

1. Stop the node:
   
   ```bash
   sudo systemctl stop juneogo.service
   ```

2. Start the backup:

   *If you can't find the file use this command:*
   
   ```bash
   find ~/ -type f -name "staker.crt"
   ```
   This will output the path to the files.

3. **Backup on the same server:**
   
   ```bash
   mkdir ~/backup
   cp .juneogo/staking/staker.crt ~/backup/
   ```
   Repeat the same for the other 2 files:
   - staker.key
   - signer.key

### How to download the file to my local device

1. Create a folder called backup (or whatever you want) on your local device.
2. Go into that folder and open Command Prompt from that folder (To open Command Prompt from within File Manager, just type "cmd" in the address bar and it will open CMD from that folder).

Use these commands to get the files to your local device:
   
```bash
scp -r root@PublicIPofVPS:Path/To/The/File ./
```
   
1. The above command assumes that you are inside the folder you want to download the files to.
2. Update the Public IP Of VPS with the IP of your VPS.
3. You should have the path to the files using this:

   ```bash
   find ~/ -type f -name "staker.crt"
   ```

Repeat the same for the remaining 2 more files:
- staker.key
- signer.key

### How to Replace the new files

Depending on which method you used to save your original files:

#### A. Backup on the same server

1. Run the Find Command:
   
   ```bash
   find ~/ -type f -name "staker.crt"
   ```
2. Copy the path and save it.
3. `cd` into your backup folder and follow this command:
   
   ```bash
   cd ~/backup
   cp -f staker.crt Path/To/The/Dir/Where/The/New/Files/Are

   # Example:
   cd ~/backup
   cp -f staker.crt /root/juneogo-docker/juneogo/.juneogo/staking/
   ```

#### B. Backup on local device

1. Run the Find Command:
   
   ```bash
   find ~/ -type f -name "staker.crt"
   ```
2. Copy the path and save it.
3. Navigate to your local device folder where the backup files are and open Command Prompt from that folder.
4. Then follow this command:
   
   ```bash
   scp /staker.crt root@IPaddress:Path/to/the/dir

   # Example:
   scp /staker.crt root@84.2**.***.***:/root/.juneogo/staking
   ```

It will ask for permission to connect; type yes and hit enter. It will ask for the password (use the password you use to log in to the VPS).

Check if the directory has all three files.

**After backup, you can either delete the old files and use my auto installer script (Guide Below) to start a new node or continue with the setup you have and follow the official docs to update to the latest Binaries version.**

Once you are done with the update, you need to upload your files back to the required directory.

### I have uploaded my files to the correct directory. What next?

If you are using my auto installer, follow this:

```bash
sudo systemctl daemon-reload
sudo systemctl start juneogo.service
```

### Check Status

```bash
sudo systemctl status juneogo.service
```

## Check if the NodeID matches your original NodeID
   

## Contributing

If you would like to contribute to this project, please follow the standard [GitHub flow](https://guides.github.com/introduction/flow/). Fork the repository, create a feature branch, commit your changes, and open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

This README file now includes proper links and formatting for a more professional appearance.
