# Juneogo Setup Script

- [Prerequisites](#prerequisites)
- [Installation Instructions](#installation-instructions)
- [Usage](#usage)
- [Update Node](#update-node)
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
   For Mainnet
   ```bash
   git clone https://github.com/SRV-YouSoRandom/Juneo-auto
   cd Juneo-auto
   chmod +x mainnet.sh
   sudo ./mainnet.sh
   ```
   For Testnet
   ```bash
   git clone https://github.com/SRV-YouSoRandom/Juneo-auto
   cd Juneo-auto
   chmod +x testnet.sh
   sudo ./testnet.sh
   ```

3. **Start and Stop the service:**
   
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

4. **Check Status:**
   
   ```bash
   sudo systemctl status juneogo.service
   sudo journalctl -fu juneogo.service
   ```

5. **Check Bootstrapping Status:**
   
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

6. **When the output is like this:**
   
   ```bash
   {
     "jsonrpc": "2.0",
     "result": {
       "isBootstrapped": true
     },
     "id": 1
   }
   ```

7. **Check if connected to mainnet:**
   
   ```bash
   curl -X POST --data '{
     "jsonrpc":"2.0",
     "id"     :1,
     "method" :"info.getNetworkName"
   }' -H 'content-type:application/json;' 127.0.0.1:9650/ext/info
   ```

8. **To login as new user (juneo):**
   
   ```bash
   su - juneo
   ```
   This logs you to the new user, and you can use your commands.

Follow the given steps in this document: [Juneo Documentation](https://docs.juneo.com/intro/validate/add-a-validator)

__________________________________________________________________________________

# Update Node

### If you have an older version of my repo just install the script

** Head to Juneo-auto dir **

```cd ~/Juneo-auto```

```bash
curl -L -o update.sh https://raw.githubusercontent.com/SRV-YouSoRandom/Juneo-auto/main/update.sh
```
Give permissions
```bash
chmod +x update.sh
```

Run the update file
```bash
./Juneo-auto/update.sh
```

Check Node Version
```bash
curl -X POST --data '{
    "jsonrpc":"2.0",
    "id"     :1,
    "method" :"info.getNodeVersion"
}' -H 'content-type:application/json;' 127.0.0.1:9650/ext/info
```

Output will look like this
```bash
{
  "jsonrpc": "2.0",
  "result": {
    "version": "juneogo/1.1.0",
    "databaseVersion": "v1.4.5",
    "rpcProtocolVersion": "35",
    "gitCommit": "",
    "vmVersions": {
      "jevm": "v1.1.0",
      "jvm": "v1.1.0",
      "platform": "v1.1.0",
      "srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e": "v0.6.4"
    }
  },
  "id": 1
}
```

__________________________________________________________________________________

# Backup Instructions

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
   eg:

https://github.com/user-attachments/assets/64443009-6bf8-40a4-bae4-bb0226ee98ba


   
   
5. Then follow this command:
   
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

__________________________________________________________________________________

# Snapshots

**Links to snapshots** 
- http://212.90.121.86:6969/juneogo_mdb_backup.zip
- https://sin1.contabostorage.com/9f27010c31e349bbb4465f8755b4ca60:zed/db-v.1.4.5-mainnet-juneo.tar.gz

- **Stop your Node**

- **Find the ```.juneogo``` dir (can be located in different locations based on the method used to run the node)**

- **Move the current DB to a temp dir**

```bash 
mv .juneogo/db .juneogo/db_old
```

Replace the **.juneogo** with the correct path of your .juneogo dir

- **Download the snapshot**

```bash 
wget http://212.90.121.86:6969/juneogo_mdb_backup.zip -P .juneogo
```

Replace the **.juneogo** with the correct path of your .juneogo dir

- **Unzip the Snapshot**

```bash 
unzip .juneogo/juneogo_mdb_backup.zip
```

```bash 
sudo systemctl daemon-reload
```

- **Restart the Node**

**juneogo_mdb_backup.zip is for mainnet**

__________________________________________________________________________________

## Contributing

If you would like to contribute to this project, please follow the standard [GitHub flow](https://guides.github.com/introduction/flow/). Fork the repository, create a feature branch, commit your changes, and open a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
