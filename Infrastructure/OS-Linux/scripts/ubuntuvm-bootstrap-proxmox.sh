#!/bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

# Constant variables
rootUser="$(whoami)"
PortainerComposeUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Infrastructure/Portainer/Enterprise/compose.yaml"
JenkinsDockerfileUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/CI-CD/Jenkins/Dockerfile"
JenkinsComposeUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/CI-CD/Jenkins/compose.yaml"

# Functions
function exit_script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

echo "Starting script .."
whiptail --backtitle "Customize - Ubuntu VM" --title "NOTE" --msgbox "This will run a custom script to customize Ubuntu!" 10 58 || exit


#read -p "Do you want to add UFW TCP rules? (y/n) " tcpYesNo
#if [[ $tcpYesNo == "y" ]]; then
#  read -p "Write comma seperated ports to open on TCP: " tcpPorts
#fi

# WHIPTAIL INSTALL DOCKER & PORTAINER & JENKINS
if whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL DOCKER" --yesno --defaultno "Do you want to install Docker?" 10 62; then
  docker=1
  if insecReg=$(whiptail --backtitle "Customize - Ubuntu VM" --inputbox "\nWrite comma seperated IP:PORT list to allow in Docker:" 10 58 "IP:PORT" --title "ADD INSECURE REGISTRY RULES?" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    echo "Added insecure registry rules: $insecReg"
    registries=1
    else
    echo "Add registry rules skipped .."
  fi
  if whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL PORTAINER EE" --yesno "Do you want to install Portainer Enterprise?" 10 62; then
    portainer=1
    else
    echo "Portainer install skipped .."
  fi
  if whiptail --backtitle "Customize - Ubuntu VM" --title "INSTALL JENKINS" --yesno "Do you want to install Jenkins?" 10 62; then
    jenkins=1
    else
    echo "Jenkins install skipped .."
  fi
  else
  echo "Docker install skipped .."
fi

# WHIPTAIL PREP FOR KUBERNETES
if whiptail --backtitle "Customize - Ubuntu VM" --title "PREP VM FOR KUBERNETES" --yesno --defaultno "Will this VM be in a k8s cluster?" 10 62; then
  k8s=1
  if k8sInstallType=$(whiptail --backtitle "Customize - Ubuntu VM" --title "K8S TYPE" --radiolist "\nSelect the type of Kubernetes to install.\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "1" "Manual K8S 1.32" ON
    3>&1 1>&2 2>&3); then
      echo -e "Kubernetes install type: $k8sInstallType"
    else
      exit_script
  fi
  else
  echo "Kubernetes prep skipped .."
fi

whiptail --backtitle "Customize - Ubuntu VM" --title "REMINDER" --msgbox "Don't forget to setup a Firewall in Proxmox if needed." 10 58 || exit


# SCRIPT COMMANDS

# Update and install upgrades
sudo apt-get update -y && sudo apt-get upgrade -y

# Configure automatic updates
sudo sed -i 's|//Unattended-Upgrade::Automatic-Reboot-Time "02:00"|Unattended-Upgrade::Automatic-Reboot-Time "06:30"|' /etc/apt/apt.conf.d/50unattended-upgrades
echo "Automatic upgrades configured successfully!"

# Disable IPv6
sudo sed -i 's/IPV6=yes/IPV6=no/' /etc/default/ufw

# Create custom app folder for deployment
sudo mkdir -m 750 /home/$rootUser/apps && sudo chown -R $rootUser:$rootUser /home/$rootUser/apps

# Install guest agent
sudo apt-get install qemu-guest-agent -y

# Install Docker
if [[ $docker == 1 ]]; then

  # Remove legacy Docker
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

  # Add Docker's official GPG key:
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
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
  wget -nc --directory-prefix=/home/$rootUser/apps/portainer $PortainerComposeUrl
  # Run compose file
  cd /home/$rootUser/apps/portainer
  sudo docker compose up -d
fi

# Install Jenkins
if [[ $docker == 1 ]] && [[ $jenkins == 1 ]]; then
  # Pull the compose file
  wget -nc --directory-prefix=/home/$rootUser/apps/jenkins $JenkinsDockerfileUrl
  wget -nc --directory-prefix=/home/$rootUser/apps/jenkins $JenkinsComposeUrl
  # Run compose file
  cd /home/$rootUser/apps/jenkins
  sudo docker compose up -d
fi

# Prep server for kubernetes install
if [[ $k8s == 1 ]]; then
  # If K8S Master
  if [[ $k8sInstallType == 1 ]]; then
    # Install Master node
    sudo apt-get install containerd -y
    sudo mkdir /etc/containerd
    containerd config default | sudo tee /etc/containerd/config.toml
    sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
    sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
    sudo apt-get install -y apt-transport-https
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
  fi
fi

# # Add a maintenance user
# if [[ $user == 1 ]]; then

#   # Add user to sudo group
#   sudo usermod -aG sudo $newUser

#   # Create custom app folder for deployment
#   sudo mkdir -m 750 /home/$newUser/apps && sudo chown -R $newUser:$newUser /home/$newUser/apps

#   # Create the Public Key Directory for SSH on your Linux Server.
#   sudo mkdir -m 700 /home/$newUser/.ssh && sudo chown -R $newUser:$newUser /home/$newUser/.ssh && cd /home/$newUser/.ssh && nano authorized_keys
#   echo "Maintenance user added successfully!"
# fi

printf "\n## Script finished! Rebooting system .. ##\n"

# Reboot system
sudo reboot