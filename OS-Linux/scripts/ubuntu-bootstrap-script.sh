#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Constant variables
rootUser="$(whoami)"

# User input variables
whiptail --backtitle "CUSTOMIZE UBUNTU SCRIPT" --defaultno --title "PROCEED?" --yesno "This will run a custom script to customize Ubuntu!" 10 58 || exit

read -p "Did you install the VM on Proxmox (1) or Digital Ocean (2)? " installPlace

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

if [[ $dockerYesNo == "y" ]]; then
  read -p "Do you want to add insecure registry rules? (y/n) " insRegYesNo
  if [[ $insRegYesNo == "y" ]]; then
  read -p "Write comma seperated IP:PORT list to allow in Docker: " insecReg
  fi
  read -p "Do you want to install Portainer? (y/n) " portainerYesNo
fi

# sudo ufw allow from 176.57.95.182

# Update and install upgrades
sudo apt update -y && sudo apt upgrade -y

# Configure automatic updates
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time/Unattended-Upgrade::Automatic-Reboot-Time/' /etc/apt/apt.conf.d/50unattended-upgrades
echo "Automatic upgrades configured successfully!"

# Disable pings in firewall
#sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules
#echo "Disable pings in firewall configured successfully!"

# Configure firewall
sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow 22

if [[ $tcpYesNo == "y" ]]; then
  sudo ufw allow $tcpPorts/tcp
fi
if [[ $utpYesNo == "y" ]]; then
  sudo ufw allow $utpPorts/udp
fi
sudo ufw --force enable

# Proxmox install specifics
if [[ $installPlace == 1 ]]; then
  
  # Create custom app folder for deployment
  sudo mkdir -m 750 /home/$rootUser/apps && sudo chown -R $rootUser:$rootUser /home/$rootUser/apps

  # Set local timezone
  sudo timedatectl set-timezone Europe/Ljubljana
  echo "Local timezone set successfully!"

  # Install guest agent
  sudo apt install qemu-guest-agent -y
fi

# Install Docker
if [[ $dockerYesNo == "y" ]]; then

  # Remove legacy Docker
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update

  # Install Docker
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  # Append user to docker group
  sudo usermod -aG docker $rootUser
  # Verify - run hello image and delete
  sudo docker run --rm hello-world && sudo docker rmi hello-world
  # Create the daemon.json for insecure (http) logins configs if needed for Nexus
  cd /etc/docker/ && sudo touch daemon.json
  printf "{\n    \"insecure-registries\" : [ \"$insecReg\" ]\n}" | sudo tee /etc/docker/daemon.json > /dev/nullfi
fi

# Install Portainer
if [[ $dockerYesNo == "y" ]] && [[ $portainerYesNo == "y" ]]; then
  # Pull the compose file
  wget -nc --directory-prefix=/home/$rootUser/apps https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Applications/Portainer/compose.yaml
  # Run compose file
  cd /home/$rootUser/apps
  sudo docker compose up -d
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

printf "\n## Script finished! Rebooting system .. ##\n\n"

# Reboot system
sudo reboot