#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Constant variables
rootUser="$(whoami)"
PortainerComposeUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Applications/Portainer/compose.yaml"

# Functions
function exit-script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

echo "Starting script .."

# WHIPTAIL INSTALL PLACE
whiptail --backtitle "Customize - Ubuntu VM" --title "NOTE" --msgbox "This will run a custom script to customize Ubuntu!" 10 58 || exit

if installPlace=$(whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL PLACE" --radiolist "\nWhere did you install Ubuntu?\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
  "1" "Proxmox" ON \
  "2" "Digital Ocean" OFF \
  3>&1 1>&2 2>&3); then
    echo -e "Install place: $installPlace"
  else
    exit-script
fi


#read -p "Do you want to add UFW TCP rules? (y/n) " tcpYesNo
#if [[ $tcpYesNo == "y" ]]; then
#  read -p "Write comma seperated ports to open on TCP: " tcpPorts
#fi

# WHIPTAIL MAINTENANCE USER
if [[ $installPlace != 1 ]]; then # skips this if installed on proxmox
  if whiptail --backtitle "Customize - Ubuntu VM" --title "MAINTENANCE USER" --yesno "Do you want to add a maintenance user?" 10 62; then
    if newUser=$(whiptail --backtitle "Customize - Ubuntu VM" --inputbox "\nWrite the user name:" 10 58 "" --title "ADD USER" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
      user=1
      sudo adduser $newUser
      else
      echo "Maintenance user skipped .."
    fi
    else
    echo "Maintenance user skipped .."
  fi
fi

# WHIPTAIL INSTALL DOCKER & PORTAINER
if whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL DOCKER" --yesno "Do you want to install Docker?" 10 62; then
  docker=1
  if insecReg=$(whiptail --backtitle "Customize - Ubuntu VM" --inputbox "\nWrite comma seperated IP:PORT list to allow in Docker:" 10 58 "IP:PORT" --title "ADD INSECURE REGISTRY RULES?" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    echo "Added insecure registry rules: $insecReg"
    registries=1
    else
    echo "Add registry rules skipped .."
  fi
  if whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL PORTAINER" --yesno "Do you want to install Portainer?" 10 62; then
    portainer=1
    else
    echo "Portainer install skipped .."
  fi
  else
  echo "Docker install skipped .."
fi

# WHIPTAIL PREP FOR KUBERNETES
if whiptail --backtitle "Customize - Ubuntu VM" --title "PREP VM FOR KUBERNETES" --yesno "Will this VM be in a k8s cluster?" 10 62; then
  k8s=1
  else
  echo "Kubernetes prep skipped .."
fi

whiptail --backtitle "Customize - Ubuntu VM" --title "REMINDER" --msgbox "Don't forget to setup a Firewall in Proxmox if needed." 10 58 || exit


# SCRIPT COMMANDS

# Update and install upgrades
sudo apt update -y && sudo apt upgrade -y

# Configure automatic updates
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00"/Unattended-Upgrade::Automatic-Reboot-Time "06:30"/' /etc/apt/apt.conf.d/50unattended-upgrades
echo "Automatic upgrades configured successfully!"

# Disable IPv6
sudo sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw

# Proxmox install specifics
if [[ $installPlace == 1 ]]; then
  
  # Create custom app folder for deployment
  sudo mkdir -m 750 /home/$rootUser/apps && sudo chown -R $rootUser:$rootUser /home/$rootUser/apps

  # Install guest agent
  sudo apt install qemu-guest-agent -y
fi

# Install Docker
if [[ $docker == 1 ]]; then

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
  if [[ $registries == 1 ]]; then
    printf "{\n    \"insecure-registries\" : [ \"$insecReg\" ]\n}" | sudo tee /etc/docker/daemon.json > /dev/null
    else
    echo "Add registry rules skipped .."
  fi
fi

# Install Portainer
if [[ $docker == 1 ]] && [[ $portainer == 1 ]]; then
  # Pull the compose file
  wget -nc --directory-prefix=/home/$rootUser/apps $PortainerComposeUrl
  # Run compose file
  cd /home/$rootUser/apps
  sudo docker compose up -d
fi

# Prep server for kubernetes install
if [[ $k8s == 1 ]]; then
  sudo apt install containerd -y
  sudo mkdir /etc/containerd
  containerd config default | sudo tee /etc/containerd/config.toml
  sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
  echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
  sudo apt-get install -y apt-transport-https
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