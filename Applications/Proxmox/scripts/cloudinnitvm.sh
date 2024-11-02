#! /bin/bash

# Copyright (c) 2024-present juronja
# Used code from https://github.com/tteck to some degree
# Author: juronja
# License: MIT

# Constant variables for dialogs
NEXTID=$(pvesh get /cluster/nextid)
NODE=$(hostname)
CLUSTER_FW_ENABLED=$(pvesh get /cluster/firewall/options --output-format json | sed -n 's/.*"enable": *\([0-9]*\).*/\1/p')


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
    "4" "GB" ON \
    "8" "GB" OFF \
    "16" "GB" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated RAM: $RAM_COUNT GB"
else
    exit-script
fi

if DISK_SIZE=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nSet disk size in GB" 8 58 "32" --title "DISK SIZE" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $DISK_SIZE ]; then
        DISK_SIZE="32"
        echo -e "Disk size: $DISK_SIZE GB"
    else
        echo -e "Disk size: $DISK_SIZE GB"
    fi
else
    exit-script
fi

# WHIPTAIL FIREWALL RULES
if whiptail --backtitle "Install - Ubuntu VM" --title "FIREWALL RULES" --yesno "Do you want to add FIREWALL rules?" 10 62; then
  fw=1
  echo "Enable value: $CLUSTER_FW_ENABLED"
  if tcpPorts=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nWrite comma seperated ports to open on TCP" 10 58 "7474,3131,..." --title "TCP PORTS" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    tcp=1
    echo "Opened TCP Ports: $tcpPorts"
    else
    echo "TCP ports skipped .."
  fi
  if udpPorts=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nWrite comma seperated ports to open on UDP" 10 58 "8082,..." --title "UDP PORTS" --cancel-button "Skip" 3>&1 1>&2 2>&3); then
    udp=1
    echo "Opened UDP Ports: $udpPorts"
    else
    echo "UDP ports skipped .."
  fi
  else
  echo "FIREWALL Rules skipped .."
fi


# Constant variables
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"
CPU="x86-64-v3"

# Download the Ubuntu cloud innit image
wget -nc --directory-prefix=$IMG_LOCATION https://cloud-images.ubuntu.com/$UBUNTU_RLS/current/$UBUNTU_RLS-server-cloudimg-amd64.img

# Create a VM
qm create $NEXTID --ostype l26 --cores $CORE_COUNT --cpu $CPU --memory $RAM --balloon 0 --name $VM_NAME --scsihw virtio-scsi-single --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $NEXTID $IMG_LOCATION$UBUNTU_RLS-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $NEXTID --scsi0 local-lvm:vm-$NEXTID-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk
qm disk resize $NEXTID scsi0 "${DISK_SIZE}G" && qm set $NEXTID --boot order=scsi0

# Configure default VM level Firewall rules
if [[ $fw == 1 ]]; then
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --source 192.168.84.0/24 --proto tcp  --enable 1 # Enable access on local network
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --source 192.168.84.0/24 --macro SSH --enable 1 # Enable SSH
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --source 192.168.84.0/24 --macro Ping --enable 1 # Enable Ping on local network
  pvesh set /nodes/$NODE/qemu/$NEXTID/firewall/options --enable 1
fi

if [[ $tcp == 1 ]]; then
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --proto tcp --dport $tcpPorts --enable 1
fi
if [[ $udp == 1 ]]; then
  pvesh create /nodes/$NODE/qemu/$NEXTID/firewall/rules --action ACCEPT --type in --iface net0 --proto udp --dport $udpPorts --enable 1
fi
