#! /bin/bash

# Copyright (c) 2024-present juronja
# Used code from https://github.com/tteck to some degree
# Author: juronja
# License: MIT

# Constant variables for dialogs
NEXTID=$(pvesh get /cluster/nextid)
NODE=$(hostname)

# Functions
function check_root() {
  if [[ "$(id -u)" != 0 || $(ps -o comm= -p $PPID) == "sudo" ]]; then
    clear
    msg_error "Please run this script as root."
    echo -e "\nExiting..."
    sleep 2
    exit
  fi
}

function ssh_check() {
  if command -v pveversion >/dev/null 2>&1; then
    if [ -n "${SSH_CLIENT:+x}" ]; then
      if whiptail --backtitle "Install - Ubuntu VM" --defaultno --title "SSH DETECTED" --yesno "It's suggested to use the Proxmox shell instead of SSH, since SSH can create issues while gathering variables. Would you like to proceed with using SSH?" 10 62; then
        echo "you've been warned"
      else
        clear
        exit
      fi
    fi
  fi
}

function exit-script() {
  clear
  echo -e "⚠  User exited script \n"
  exit
}

echo "Starting VM script .."

# Whiptail inputs
if UBUNTU_RLS=$(whiptail --backtitle "Install - Ubuntu VM" --title "UBUNTU RELEASE" --radiolist "\nChoose the release to install\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
    "noble" "24.04 LTS" ON \
    "jammy" "22.04 LTS" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Release version: $UBUNTU_RLS"
else
    exit-script
fi

if VM_NAME=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nSet the name of the VM" 8 58 "homelab" --title "NAME" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $VM_NAME ]; then
        VM_NAME="homelab"
        echo -e "Name: $VM_NAME"
    else
        echo -e "Name: $VM_NAME"
    fi
else
    exit-script
fi


if CORE_COUNT=$(whiptail --backtitle "Install - Ubuntu VM" --title "CORE COUNT" --radiolist "\nAllocate number of CPU Cores\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "2" "cores" ON \
    "4" "cores" OFF \
    "8" "cores" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated Cores: $CORE_COUNT"
else
    exit-script
fi

if RAM_COUNT=$(whiptail --backtitle "Install - Ubuntu VM" --title "RAM COUNT" --radiolist "\nAllocate number of RAM\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "2" "GB" OFF \
    "4" "GB" ON \
    "8" "GB" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated RAM: $RAM_COUNT GB"
else
    exit-script
fi

if DISK_SIZE=$(whiptail --backtitle "Install - Ubuntu VM" --title "DISK SIZE" --radiolist "\nAllocate disk size\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "16" "GB" OFF \
    "32" "GB" ON \
    "64" "GB" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated disk size: $DISK_SIZE GB"
else
    exit-script
fi

# WHIPTAIL FIREWALL RULES
if whiptail --backtitle "Install - Ubuntu VM" --title "FIREWALL" --yesno --defaultno "Do you want to enable a FIREWALL?" 10 62; then
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


# Constant variables
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"
CPU="x86-64-v3"

# Proxmox variables
CLUSTER_FW_ENABLED=$(pvesh get /cluster/firewall/options --output-format json | sed -n 's/.*"enable": *\([0-9]*\).*/\1/p')
LOCAL_NETWORK=$(pve-firewall localnet | grep local_network | cut -d':' -f2 | sed 's/ //g')
ALIAS_HOME_NETWORK="home_network"
ALIAS_PROXY="npm"
GROUP_LOCAL="local-ssh-ping"
SOURCE_IPRANGE="192.168.84.1-192.168.84.49"

# Download the Ubuntu cloud innit image
wget -nc --directory-prefix=$IMG_LOCATION https://cloud-images.ubuntu.com/$UBUNTU_RLS/current/$UBUNTU_RLS-server-cloudimg-amd64.img

# Create a VM
qm create $NEXTID --ostype l26 --cores $CORE_COUNT --cpu $CPU --numa 1 --memory $RAM --balloon 0 --name $VM_NAME --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $NEXTID $IMG_LOCATION$UBUNTU_RLS-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $NEXTID --scsi0 local-lvm:vm-$NEXTID-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk
qm disk resize $NEXTID scsi0 "${DISK_SIZE}G" && qm set $NEXTID --boot order=scsi0

# Configure Cluster level firewall rules if not enabled
if [[ $CLUSTER_FW_ENABLED != 1 ]]; then
  pvesh set /cluster/firewall/options --enable 1
  pvesh create /cluster/firewall/aliases --name $ALIAS_HOME_NETWORK --cidr $LOCAL_NETWORK
  pvesh create /cluster/firewall/aliases --name $ALIAS_PROXY --cidr 192.168.84.254
  pvesh create /cluster/firewall/groups --group $GROUP_LOCAL
  sleep 2
  pvesh create /cluster/firewall/rules --action ACCEPT --type in --iface vmbr0 --source $ALIAS_HOME_NETWORK --macro Ping --enable 1
  pvesh create /cluster/firewall/groups/$GROUP_LOCAL --action ACCEPT --type in --source $SOURCE_IPRANGE --proto tcp --enable 1
  pvesh create /cluster/firewall/groups/$GROUP_LOCAL --action ACCEPT --type in --source $ALIAS_HOME_NETWORK --macro Ping --enable 1
  pvesh create /cluster/firewall/groups/$GROUP_LOCAL --action ACCEPT --type in --source $SOURCE_IPRANGE --macro SSH --enable 1
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
