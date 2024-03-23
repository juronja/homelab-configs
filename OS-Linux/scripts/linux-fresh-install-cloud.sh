#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Variables
# REFACTOR THIS SO THE SRIPT WILL ASK FOR INPUT
rootUser="$(WHOAMI)"
mainUser="juronja"
allowTcp="3000,8081,27017"
allowUdp="" # E.g. - "&& sudo ufw allow 51820/udp"


# sudo ufw allow from 203.0.113.4


# Update and install upgrades
sudo apt update -y && sudo apt upgrade -y

# Configure automatic updates
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time/Unattended-Upgrade::Automatic-Reboot-Time/' /etc/apt/apt.conf.d/50unattended-upgrades

# Configure firewall
sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow 22,$allowTcp/tcp $allowUdp && sudo ufw enable

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
adduser $mainUser

# Add user to sudo group
sudo usermod -aG sudo $mainUser

# Switch user
su $mainUser

# Create the Public Key Directory for SSH on your Linux Server. This is not needed in Official Ubuntu distro.
sudo mkdir -m 700 ~/.ssh && sudo chown -R $mainUser:$mainUser ~/.ssh/ && cd ~/.ssh && touch authorized_keys

# Create custom app folder for deployment
mkdir ~/app

echo "Script finished! Rebooting system .."

# Reboot system
#sudo reboot