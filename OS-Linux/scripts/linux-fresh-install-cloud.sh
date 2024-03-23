#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Constant variables
rootUser="$(whoami)"

# User input variables
echo "Please answer a few questions next:"

read -p "Do you want to add UFW TCP rules? (y/n): " tcpYesNo
if [[ $tcpYesNo == "y" ]]; then
  read -p "Write comma seperated ports to open on TCP: " tcpPorts
fi

read -p "Do you want to add UFW UTP rules? (y/n): " utpYesNo
if [[ $utpYesNo == "y" ]]; then
  read -p "Write comma seperated ports to open on UTP: " utpPorts
fi

read -p "Do you want to add a maintenance user? (y/n): " userYesNo
if [[ $userYesNo == "y" ]]; then
  read -p "Write the user name: " newUser
  adduser $newUser
fi

# sudo ufw allow from 176.57.95.182

# Update and install upgrades
sudo apt update -y && sudo apt upgrade -y

# Configure automatic updates
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time/Unattended-Upgrade::Automatic-Reboot-Time/' /etc/apt/apt.conf.d/50unattended-upgrades

# Configure firewall
sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow 22

if [[ $tcpYesNo == "y" ]]; then
  sudo ufw allow $tcpPorts/tcp
fi
if [[ $utpYesNo == "y" ]]; then
  sudo ufw allow $utpPorts/udp
fi
sudo ufw enable

# Disable pings in firewall
sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

# Remove legacy Docker
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

# Add a maintenance user
if [[ $userYesNo == "y" ]]; then

  # Add user to sudo group
  sudo usermod -aG sudo $newUser

  # Create the Public Key Directory for SSH on your Linux Server.
  sudo mkdir -m 700 /home/$newUser/.ssh && sudo chown -R $newUser:$newUser /home/$newUser/.ssh/ && cd /home/$newUser/.ssh/ && touch authorized_keys
  
  # Create custom app folder for deployment
  mkdir /home/$newUser/app
fi

echo "Script finished! Rebooting system .."

# Reboot system
#sudo reboot