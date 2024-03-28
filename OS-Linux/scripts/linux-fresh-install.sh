#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Constant variables
rootUser="$(whoami)"

# User input variables
printf "\n!! Please answer a few questions first: !!\n\n"

read -p "Do you run the installer on Proxmox (1) or Digital Ocean (2)? " installPlace

read -p "Do you want to add UFW TCP rules? (y/n) " tcpYesNo
if [[ $tcpYesNo == "y" ]]; then
  read -p "Write comma seperated ports to open on TCP: " tcpPorts
fi

read -p "Do you want to add UFW UTP rules? (y/n) " utpYesNo
if [[ $utpYesNo == "y" ]]; then
  read -p "Write comma seperated ports to open on UTP: " utpPorts
fi

if [[ $installPlace != 1 ]]; then
  read -p "Do you want to add a maintenance user? (y/n) " userYesNo # skip this for proxmox
  if [[ $userYesNo == "y" ]]; then
    read -p "Write the user name: " newUser
    adduser $newUser
  fi
fi
read -p "Do you want to install Docker? (y/n) " dockerYesNo


# sudo ufw allow from 176.57.95.182

# Update and install upgrades
sudo apt update -y && sudo apt upgrade -y

# Configure automatic updates
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time/Unattended-Upgrade::Automatic-Reboot-Time/' /etc/apt/apt.conf.d/50unattended-upgrades
echo "Automatic upgrades configured successfully!"

# Disable pings in firewall
sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules
echo "Disable pings in firewall configured successfully!"

# Configure firewall
sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow 22

if [[ $tcpYesNo == "y" ]]; then
  sudo ufw allow $tcpPorts/tcp
fi
if [[ $utpYesNo == "y" ]]; then
  sudo ufw allow $utpPorts/udp
fi
sudo ufw enable

# Remove legacy Docker
if [[ $dockerYesNo == "y" ]]; then

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key
sudo apt-get update && sudo apt-get install ca-certificates curl gnupg && sudo install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
# Append user to docker group
sudo usermod -aG docker $rootUser
# Verify - run hello image and delete
sudo docker run --rm hello-world && sudo docker rmi hello-world
# Create the daemon.json for insecure (http) logins configs if needed
cd /etc/docker/ && touch daemon.json
fi

# Add a maintenance user
if [[ $userYesNo == "y" ]]; then

  # Add user to sudo group
  sudo usermod -aG sudo $newUser

  # Create custom app folder for deployment
  sudo mkdir -m 750 /home/$newUser/apps && sudo chown -R $newUser:$newUser /home/$newUser/apps

  # Create the Public Key Directory for SSH on your Linux Server.
  sudo mkdir -m 700 /home/$newUser/.ssh && sudo chown -R $newUser:$newUser /home/$newUser/.ssh && cd /home/$newUser/.ssh && nano authorized_keys
  echo "Maintenance user added successfully!"
fi

# Proxmox install specifics
if [[ $installPlace == 1 ]]; then
  
  # Create custom app folder for deployment
  sudo mkdir -m 750 /home/$rootUser/apps && sudo chown -R $rootUser:$rootUser /home/$rootUser/apps

  #sudo mkdir apps/{portainer,homepage}_data # Create custom app directory tree

  # Set local timezone
  sudo timedatectl set-timezone Europe/Ljubljana
  echo "Local timezone set successfully!"

  # Install guest agent
  sudo apt install qemu-guest-agent -y
fi

printf "\n## Script finished! Rebooting system .. ##\n\n"

# Reboot system
sudo reboot