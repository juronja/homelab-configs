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

# WHIPTAIL INSTALL DOCKER & PORTAINER
whiptail --backtitle "Customize VM" --title "NOTE" --msgbox "This will run a custom script to customize this VM!" 10 58 || exit

if whiptail --backtitle "Customize VM" --title "INSTALL DOCKER" --yesno "Do you want to install Docker?" 10 62; then
  docker=1
  if insecReg=$(whiptail --backtitle "Customize VM" --inputbox "\nWrite comma seperated IP:PORT list to allow in Docker:" 10 58 "IP:PORT" --title "ADD INSECURE REGISTRY RULES?" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    echo "Added insecure registry rules: $insecReg"
    registries=1
    else
    echo "Add registry rules skipped .."
  fi
  else
  echo "Docker install skipped .."
fi

# SCRIPT COMMANDS

# Update and install upgrades
sudo dnf update
#sudo dnf upgrade --refresh

# Install Docker
if [[ $docker == 1 ]]; then

  # Install Docker
  sudo dnf install docker -y
  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $rootUser
  # Verify - run hello image and delete
  sudo docker run --rm hello-world && sudo docker rmi hello-world
  # Install docker compose
  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m) -o /usr/bin/docker-compose && sudo chmod 755 /usr/bin/docker-compose && docker-compose --version
  # Create the daemon.json for insecure (http) logins configs if needed for Nexus
  cd /etc/docker/ && sudo touch daemon.json
  if [[ $registries == 1 ]]; then
    printf "{\n    \"insecure-registries\" : [ \"$insecReg\" ]\n}" | sudo tee /etc/docker/daemon.json > /dev/null
    else
    echo "Add registry rules skipped .."
  fi
fi

printf "\n## Script finished! Rebooting system .. ##\n\n"

# Reboot system
sudo reboot