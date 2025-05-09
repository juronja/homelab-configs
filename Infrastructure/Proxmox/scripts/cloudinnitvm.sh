#!/usr/bin/env bash
# Copyright (c) 2024-present juronja
# Used parts from https://github.com/community-scripts to some extent
# Author: juronja
# License: MIT

# Constant variables for dialogs
NEXTID=$(pvesh get /cluster/nextid)
NODE=$(hostname)

# Functions
# Run as root only
root_check() {
  if [[ "$(id -u)" -ne 0 || $(ps -o comm= -p $PPID) == "sudo" ]]; then
    clear
    msg_error "Please run this script as root."
    echo -e "\nExiting..."
    sleep 2
    exit
  fi
}

# This function checks if the script is running through SSH and prompts the user to confirm if they want to proceed or exit.
ssh_check() {
  if [ -n "${SSH_CLIENT:+x}" ]; then
    if whiptail --backtitle "Proxmox VE Helper Scripts" --defaultno --title "SSH DETECTED" --yesno "It's advisable to utilize the Proxmox shell rather than SSH, as there may be potential complications with variable retrieval. Proceed using SSH?" 10 72; then
      whiptail --backtitle "Proxmox VE Helper Scripts" --msgbox --title "Proceed using SSH" "You've chosen to proceed using SSH. If any issues arise, please run the script in the Proxmox shell before creating a repository issue." 10 72
    else
      clear
      echo "Exiting due to SSH usage. Please consider using the Proxmox shell."
      exit
    fi
  fi
}

# This function is called when the user decides to exit the script. It clears the screen and displays an exit message.
function exit_script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

### MAIN SCRIPT ###
echo "Starting VM script .."

# WHIPTAIL VM INPUTS
if UBUNTU_RLS=$(whiptail --backtitle "Install - Ubuntu VM" --title "UBUNTU RELEASE" --radiolist "\nChoose the release to install\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
  "noble" "24.04 LTS" ON \
  "jammy" "22.04 LTS" OFF \
  3>&1 1>&2 2>&3); then
    echo -e "Release version: $UBUNTU_RLS"
else
  exit_script
fi

if CORE_COUNT=$(whiptail --backtitle "Install - Ubuntu VM" --title "CORE COUNT" --radiolist "\nAllocate number of CPU Cores\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 4 \
  "2" "cores" ON \
  "4" "cores" OFF \
  "6" "cores" OFF \
  "8" "cores" OFF \
  3>&1 1>&2 2>&3); then
    echo -e "Allocated Cores: $CORE_COUNT"
else
  exit_script
fi

if RAM_COUNT=$(whiptail --backtitle "Install - Ubuntu VM" --title "RAM COUNT" --radiolist "\nAllocate number of RAM\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 4 \
  "2" "GB" OFF \
  "4" "GB" ON \
  "8" "GB" OFF \
  "12" "GB" OFF \
  3>&1 1>&2 2>&3); then
    echo -e "Allocated RAM: $RAM_COUNT GB"
else
  exit_script
fi

if DISK_SIZE=$(whiptail --backtitle "Install - Ubuntu VM" --title "DISK SIZE" --radiolist "\nAllocate disk size\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
  "32" "GB" OFF \
  "48" "GB" ON \
  "64" "GB" OFF \
  3>&1 1>&2 2>&3); then
    echo -e "Allocated disk size: $DISK_SIZE GB"
else
  exit_script
fi

if VM_NAME=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nSet the name of the VM" 8 58 "homelab" --title "NAME" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
  if [ -z $VM_NAME ]; then
    VM_NAME="homelab"
    echo -e "Name: $VM_NAME"
  else
    echo -e "Name: $VM_NAME"
  fi
else
  exit_script
fi

while true; do
  if OS_USER=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nCloud-innit username" 8 58 --title "CLOUD-INIT USERNAME" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $OS_USER ]; then
      whiptail --backtitle "Install - Ubuntu VM" --msgbox "Username cannot be empty" 8 58
    else
      break # Username is not empty, break out of the loop
    fi
  else
    exit_script
  fi
done

while true; do
  if OS_PASS=$(whiptail --backtitle "Install - Ubuntu VM" --passwordbox "\nCloud-innit password" 8 58 --title "CLOUD-INIT PASSWORD" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $OS_PASS ]; then
      whiptail --backtitle "Install - Ubuntu VM" --msgbox "Password cannot be empty" 8 58
    elif [[ "$OS_PASS" == *" "* ]]; then
      whiptail --msgbox "Password cannot contain spaces. Please try again." 8 58
    elif [ ${#OS_PASS} -lt 8 ]; then
      whiptail --msgbox "Password must be at least 5 characters long. Please try again." 8 58
    else
      break # Password is valid, break out of the loop
    fi
  else
    exit_script
  fi
done

while true; do
  if OS_IPv4_CIDR=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nSet a Static IPv4 CIDR Address (/24)" 8 58 "dhcp" --title "CLOUD-INIT IPv4 CIDR" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $OS_IPv4_CIDR ]; then
      OS_IPv4_CIDR="dhcp"
      break
    elif [ "$OS_IPv4_CIDR" = "dhcp" ]; then
      break 
    elif [[ "$OS_IPv4_CIDR" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$ ]]; then
      echo -e "IPv4 Address: $OS_IPv4_CIDR"
      break
    else
      whiptail --backtitle "Install - Ubuntu VM" --msgbox "$OS_IPv4_CIDR is an invalid IPv4 CIDR address. Please enter a valid IPv4 CIDR address or 'dhcp'" 8 58
    fi
  else
    exit_script
  fi
done

if [[ $OS_IPv4_CIDR != "dhcp" ]]; then
  SUGGESTED_GW=$(echo "$OS_IPv4_CIDR" | sed 's/\.[0-9]\{1,3\}\/\([0-9]\+\)$/.1/')
  while true; do
    if OS_IPv4_GW=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nEnter gateway IP address" 8 58 "$SUGGESTED_GW" --title "CLOUD-INIT IPv4 GATEWAY" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
      if [ -z $OS_IPv4_GW ]; then
          whiptail --backtitle "Install - Ubuntu VM" --msgbox "Gateway IP address cannot be empty" 8 58
      elif [[ ! "$OS_IPv4_GW" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        whiptail --backtitle "Install - Ubuntu VM" --msgbox "Invalid IP address format" 8 58
      else
        OS_IPv4_GW_FULL=",gw=$OS_IPv4_GW"
        echo -e "Gateway IP Address: $OS_IPv4_GW"
        break # Exit the loop after a valid gateway IP is entered
      fi
    else
      exit_script
    fi
  done
fi

# WHIPTAIL FIREWALL RULES
if whiptail --backtitle "Install - Ubuntu VM" --title "PROXMOX FIREWALL" --yesno --defaultno "Do you want to enable Proxmox FIREWALL?" 10 62; then
  fw=1
  if tcpPorts=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nWrite comma seperated TCP ports to expose on WAN" 10 58 "7474,3131," --title "EXPOSE TCP PORTS" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    tcp=1
    echo "Will open TCP Ports: $tcpPorts"
    else
    echo "TCP ports skipped .."
  fi
  if udpPorts=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nWrite comma seperated UDP ports to expose on WAN" 10 58 "8082," --title "EXPOSE UDP PORTS" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    udp=1
    echo "Will open UDP Ports: $udpPorts"
    else
    echo "UDP ports skipped .."
  fi
else
  echo "FIREWALL setup skipped .."
fi

whiptail --backtitle "Install - Ubuntu VM" --title "SSH NOTE" --msgbox "Manually paste the public SSH key before starting the VM!" 10 58 || exit

# WHIPTAIL INSTALL DOCKER & PORTAINER & JENKINS

if whiptail --backtitle "Install - Ubuntu VM" --title "INSTALL DOCKER" --yesno --defaultno "Do you want to install Docker?" 10 62; then
  docker=1
  if insecReg=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nWrite comma seperated IP:PORT list to allow in Docker:" 10 58 "192.168.x.x:PORT" --title "ADD INSECURE REGISTRY RULES?" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    registries=1
    echo "Added insecure registry rules: $insecReg"
  else
    echo "Add registry rules skipped .."
  fi
  if installContainers=$(whiptail --backtitle "Install - Ubuntu VM" --title "INSTALL APPS" --checklist "Do you want to install these containers?" 10 40 3; \
    "portainer" "" OFF \
    "jenkins" "" OFF \
    3>&1 1>&2 2>&3); then
      echo -e "Install containers: $installContainers"
  else
    echo "Container install skipped .."
  fi
else
  echo "Docker install skipped .."
fi

# Constant variables
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"
CPU="x86-64-v3"
CLOUD_INNIT_ABSOLUTE="/var/lib/vz/snippets/ubuntu-homelab-cloud-init.yml"
CLOUD_INNIT_LOCAL="snippets/ubuntu-homelab-cloud-init.yml"
CLOUD_INNIT_GIT="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Infrastructure/Proxmox/ubuntu-homelab-cloud-init.yml"
PortainerComposeUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Applications/Portainer/compose.yaml"
JenkinsDockerfileUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/CI-CD/Jenkins/Dockerfile"
JenkinsComposeUrl="https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/CI-CD/Jenkins/compose.yaml"

# Proxmox variables
CLUSTER_FW_ENABLED=$(pvesh get /cluster/firewall/options --output-format json | sed -n 's/.*"enable": *\([0-9]*\).*/\1/p')
LOCAL_NETWORK=$(pve-firewall localnet | grep local_network | cut -d':' -f2 | sed 's/ //g')
ALIAS_HOME_NETWORK="home_network"
ALIAS_PROXY="proxy"
GROUP_LOCAL="local-ssh-ping"

# Download the Ubuntu cloud innit image
wget -nc --directory-prefix=$IMG_LOCATION https://cloud-images.ubuntu.com/$UBUNTU_RLS/current/$UBUNTU_RLS-server-cloudimg-amd64.img

# Create a VM
qm create $NEXTID --ostype l26 --cores $CORE_COUNT --cpu $CPU --numa 1 --memory $RAM --balloon 0 --name $VM_NAME --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=$OS_IPv4_CIDR$OS_IPv4_GW_FULL --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $NEXTID $IMG_LOCATION$UBUNTU_RLS-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $NEXTID --scsi0 local-lvm:vm-$NEXTID-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk
qm disk resize $NEXTID scsi0 "${DISK_SIZE}G" && qm set $NEXTID --boot order=scsi0

# Configure Cloudinit datails
qm set $NEXTID --ciuser $OS_USER --cipassword $OS_PASS
qm cloudinit dump $NEXTID user > $CLOUD_INNIT_ABSOLUTE
wget $CLOUD_INNIT_GIT -O temp_cloud_init.yml
cat temp_cloud_init.yml >> $CLOUD_INNIT_ABSOLUTE
# Create custom app folder for deployment
cat <<EOF >> $CLOUD_INNIT_ABSOLUTE
  # Create custom app folder for deployment
  - mkdir -m 750 /home/$OS_USER/apps && chown -R $OS_USER:$OS_USER /home/$OS_USER/apps
EOF
# Docker install
if [ "$docker" == "1" ]; then
  cat <<'EOF' >> $CLOUD_INNIT_ABSOLUTE
  # Add Docker's official GPG key
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && chmod a+r /etc/apt/keyrings/docker.asc
  # Add the repository to Apt sources
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  # Install Docker
  - apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
EOF
  cat <<EOF >> $CLOUD_INNIT_ABSOLUTE
  # Append user to docker group
  - usermod -aG docker $OS_USER
  # Create the daemon.json for insecure (http) logins configs if needed for Nexus
  - cd /etc/docker/ && touch daemon.json
EOF
fi
# Add insecure registries
if [[ $registries == 1 ]]; then
  cat <<EOF >> $CLOUD_INNIT_ABSOLUTE
  # Add insecure registries
  - 'printf "{\n    \"insecure-registries\" : [ \"$insecReg\" ]\n}" | tee /etc/docker/daemon.json > /dev/null'
EOF
fi
# Install Portainer
if [[ $docker == 1 ]] && [[ $installContainers == portainer ]]; then
  cat <<EOF >> $CLOUD_INNIT_ABSOLUTE
  # Install Portainer
  - wget -nc --directory-prefix=/home/$OS_USER/apps/portainer $PortainerComposeUrl
  - cd /home/$OS_USER/apps/portainer
  - docker compose up -d
EOF
fi
# Install Jenkins
if [[ $docker == 1 ]] && [[ $installContainers == jenkins ]]; then
  cat <<EOF >> $CLOUD_INNIT_ABSOLUTE
  # Install Jenkins
  - wget -nc --directory-prefix=/home/$OS_USER/apps/jenkins $JenkinsDockerfileUrl
  - wget -nc --directory-prefix=/home/$OS_USER/apps/jenkins $JenkinsComposeUrl
  - cd /home/$OS_USER/apps/jenkins
  - docker compose up -d
EOF
fi

qm set $NEXTID --cicustom "user=local:$CLOUD_INNIT_LOCAL"
rm temp_cloud_init.yml

# Configure Cluster level firewall rules if not enabled
if [[ $CLUSTER_FW_ENABLED != 1 ]]; then
  pvesh set /cluster/firewall/options --enable 1
  pvesh create /cluster/firewall/aliases --name $ALIAS_HOME_NETWORK --cidr $LOCAL_NETWORK
  pvesh create /cluster/firewall/aliases --name $ALIAS_PROXY --cidr 192.168.84.254
  pvesh create /cluster/firewall/groups --group $GROUP_LOCAL
  sleep 2
  pvesh create /cluster/firewall/rules --action ACCEPT --type in --iface vmbr0 --source $ALIAS_HOME_NETWORK --macro Ping --enable 1
  pvesh create /cluster/firewall/groups/$GROUP_LOCAL --action ACCEPT --type in --source $ALIAS_HOME_NETWORK --proto tcp --enable 1
  pvesh create /cluster/firewall/groups/$GROUP_LOCAL --action ACCEPT --type in --source $ALIAS_HOME_NETWORK --macro Ping --enable 1
  pvesh create /cluster/firewall/groups/$GROUP_LOCAL --action ACCEPT --type in --source $ALIAS_HOME_NETWORK --macro SSH --enable 1
  echo "Cluster Firewall configurations set successfully .."
  else
  echo "Cluster Firewall configurations already present .."
fi

# Configure optional VM level firewall rules
if [[ $fw == 1 ]]; then
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action $GROUP_LOCAL --type group --iface net0 --enable 1
  pvesh set /nodes/$NODE/qemu/$NEXTID/firewall/options --enable 1
  pvesh set /nodes/$NODE/qemu/$NEXTID/firewall/options --log_level_in warning
  echo "VM Firewall rules set successfully .."
fi

if [[ $tcp == 1 ]]; then
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --proto tcp --source $ALIAS_PROXY --dport $tcpPorts --enable 1
  echo "TCP ports exposed successfully .."
fi
if [[ $udp == 1 ]]; then
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --proto udp --source $ALIAS_PROXY --dport $udpPorts --enable 1
  echo "UDP ports exposed successfully .."
fi

printf "\n## Script finished! .. ##\n\n"
if [[ $installContainers == portainer ]]; then
  printf "Portainer is available at: https://$(echo "$OS_IPv4_CIDR" | awk -F'./' '{print $1}'):9443\n\n"
fi
if [[ $installContainers == jenkins ]]; then
  printf "Jenkins is available at: http://$(echo "$OS_IPv4_CIDR" | awk -F'./' '{print $1}'):8080\n\n"
fi