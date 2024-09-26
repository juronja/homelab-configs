#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Constant variables
rootUser="$(whoami)"

# Functions
function exit-script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

echo "Starting script .."

# Whiptail inputs
whiptail --backtitle "Customize - Ubuntu VM" --title "NOTE" --msgbox "This will run a custom script to customize Ubuntu!" 10 58 || exit

if installPlace=$(whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL PLACE" --radiolist "\nWhere did you install Ubuntu?\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
  "1" "Proxmox" ON \
  "2" "Digital Ocean" OFF \
  3>&1 1>&2 2>&3); then
    echo -e "Install place: $installPlace"
  else
    exit-script
fi

if whiptail --backtitle "Customize - Ubuntu VM" --title "UFW RULES" --yesno "Do you want to add UFW rules?" 10 62; then
  if tcpPorts=$(whiptail --backtitle "Customize - Ubuntu VM" --inputbox "\nWrite comma seperated ports to open on TCP" 10 58 "7474,8082,..." --title "TCP PORTS" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    tcp=1
    echo "Opened TCP Ports: $tcpPorts"
    else
    echo "TCP ports skipped .."
  fi
  if utpPorts=$(whiptail --backtitle "Customize - Ubuntu VM" --inputbox "\nWrite comma seperated ports to open on UTP" 10 58 "7474,8082,..." --title "UTP PORTS" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    utp=1
    echo "Opened TCP Ports: $utpPorts"
    else
    echo "UTP ports skipped .."
  fi
  else
  echo "UFW Rules skipped .."
fi

#read -p "Do you want to add UFW TCP rules? (y/n) " tcpYesNo
#if [[ $tcpYesNo == "y" ]]; then
#  read -p "Write comma seperated ports to open on TCP: " tcpPorts
#fi

#read -p "Do you want to add UFW UTP rules? (y/n) " utp
#if [[ $utp == "y" ]]; then
#  read -p "Write comma seperated ports to open on UTP: " utpPorts
#fi

if [[ $installPlace != 1 ]]; then # skips this for proxmox
  if whiptail --backtitle "Customize - Ubuntu VM" --title "MAINTENANCE USER" --yesno "Do you want to add a maintenance user?" 10 62; then
  if newUser=$(whiptail --backtitle "Customize - Ubuntu VM" --inputbox "\nWrite the user name:" 10 58 "" --title "ADD USER" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    user=1
    adduser $newUser
    echo "Added a new user: $newUser"
    else
    echo "Maintenance user skipped .."
  fi
  else
  echo "Maintenance user skipped .."
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
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00"/Unattended-Upgrade::Automatic-Reboot-Time "06:30"/' /etc/apt/apt.conf.d/50unattended-upgrades
echo "Automatic upgrades configured successfully!"

# Disable pings in firewall
#sudo sed -i 's/-A ufw-before-input -p icmp --icmp-type echo-request -j ACCEPT/-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules
#echo "Disable pings in firewall configured successfully!"

# Configure firewall
sudo sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw
sudo ufw default allow outgoing && sudo ufw default deny incoming && sudo ufw allow 22

if [[ $tcp == 1 ]]; then
  sudo ufw allow $tcpPorts/tcp
fi
if [[ $utp == 1 ]]; then
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
if [[ $user == 1 ]]; then

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