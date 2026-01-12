# First steps after installing Ubuntu Linux

OpenSSH can be installed when installing Linux, on Ubuntu it is preinstalled; so after installation you can ssh {{username}}@{{IP}} straight into your machine via the terminal (e.g. Windows PowerShell)

## SSH KEY PAIRS ON WINDOWS

### Create Public/Private keys on your computer/PC 

```bash
ssh-keygen -t ed25519 -C "nameofserver"

```

Rename the key eg. C:\Users\Jure/.ssh/id_nameofserver

### Setup SSH Managing config in Windows

To better manage multiple SSH keys, setup and edit the ssh config file like this.
In "C:\Users\Jure\.ssh\" make a new empty Text Document file named "config.txt". Save and remove the .txt extension.
Open the file with notepad and add this lines and edit what you need

```yaml
Host gateway
  Hostname 192.168.84.1
  User root
  IdentityFile ~/.ssh/id_gateway

Host ubuntu-homelab
  Hostname 192.168.84.25
  User juronja
  IdentityFile ~/.ssh/id_homelab

Host ubuntu-server2
  Hostname 192.168.84.24
  User juronja
#  IdentityFile ~/.ssh/id_ubuntu-server2
#  Port if a custom ssh port is set

```

### Upload your Public key to your Linux Server (Windows)

```bash
scp $env:USERPROFILE/.ssh/id_nameofserver.pub username@{IP}:~/.ssh/authorized_keys

```

### Disable password authentication

In Proxmox you can remove the sudo commands for this to work. Uncomment "PasswordAuthentication" and change to "no"

```bash
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo systemctl restart ssh

```

## Change static ip by editing the config file inside this folder 

```bash
cd /etc/netplan/

```

Example config:

```yml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    ens160:  # Your ethernet name.
     dhcp4: no
     addresses: [192.168.84.25/24]
     gateway4: 192.168.84.1
     nameservers:
       addresses: [1.1.1.2,8.8.8.8]

```

### Restart the netplan

```bash
sudo netplan try

```

## Environment Variables

In this document add export lines for persistent variables.

```bash
nano ~/.profile
export MONGO_ADMIN_USER=username
export MONGO_ADMIN_PASS=pass

```

Alternatively you can use `/etc/profile` for all users.

## USEFUL FOR OTHER DISTROS - Ubuntu has this by default

### Install automatic upgrades

```bash
sudo apt install unattended-upgrades && sudo dpkg-reconfigure --priority=low unattended-upgrades
```

### Add a user

adduser username

### Add user to sudo group

```bash
sudo usermod -aG sudo username
```

### Create the Public Key Directory for SSH on your Linux Server

```bash
sudo mkdir -m 700 ~/.ssh 
#Add user and group as owner and create authorized_keys file
sudo chown -R user:user ~/.ssh/
cd ~/.ssh && touch authorized_keys
```
