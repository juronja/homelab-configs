#! /bin/bash

# Copyright (c) 2024-2024 juronja
# Author: juronja
# License: MIT

# Variables:
user="$(whoami)"
allowtcp="22,81"
allowudp="51820"

# Update and install upgrades
sudo apt update -y && sudo apt upgrade

# Create the Public Key Directory for SSH on your Linux Server. This is not needed in Ubuntu distro
#sudo mkdir ~/.ssh && chmod 700 ~/.ssh 

# Set local timezone
sudo timedatectl set-timezone Europe/Ljubljana

# Configure automatic updates
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time/Unattended-Upgrade::Automatic-Reboot-Time/' /etc/apt/apt.conf.d/50unattended-upgrades

# Configure firewall
#sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow $allowtcp/tcp && sudo ufw allow $allowudp/udp && sudo ufw enable

# Disable pings in firewall
#sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

# Install guest agent
sudo apt install qemu-guest-agent -y

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
sudo usermod -aG docker $user
# Verify
sudo docker run --name hello hello-world && sudo docker rm hello && sudo docker rmi hello-world

# Create custom app directory tree
mkdir appstorage
mkdir appstorage/{portainer,homepage}_data

echo "Script finished!"

# Reboot system
sudo reboot