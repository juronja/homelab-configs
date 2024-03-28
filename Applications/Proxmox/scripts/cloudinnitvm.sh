#! /bin/bash

# Copyright (c) 2024-present juronja
# Author: juronja
# License: MIT

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
      if whiptail --backtitle "Proxmox Ubuntu VM install Script" --defaultno --title "SSH DETECTED" --yesno "It's suggested to use the Proxmox shell instead of SSH, since SSH can create issues while gathering variables. Would you like to proceed with using SSH?" 10 62; then
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
if UBUNTU_RLS=$(whiptail --backtitle "Proxmox Ubuntu VM install Script" --title "UBUNTU RELEASE" --radiolist "\nChoose the Ubuntu release to install\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
    "jammy" "22.04 LTS" ON \
    3>&1 1>&2 2>&3); then
        echo -e "Ubuntu release version: $UBUNTU_RLS"
else
    exit-script
fi

if CORE_COUNT=$(whiptail --backtitle "Proxmox Ubuntu VM install Script" --title "CORE COUNT" --radiolist "\nAllocate number of CPU Cores\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
    "2" "cores" ON \
    "4" "cores" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated Cores: $CORE_COUNT"
else
    exit-script
fi

if RAM_COUNT=$(whiptail --backtitle "Proxmox Ubuntu VM install Script" --title "RAM COUNT" --radiolist "\nAllocate number of RAM\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "2" "GB" OFF \
    "4" "GB" ON \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated RAM: $RAM_COUNT GB"
else
    exit-script
fi

if DISK_SIZE=$(whiptail --backtitle "Proxmox Ubuntu VM install Script" --inputbox "\nSet disk size in GB" 8 58 "50" --title "DISK SIZE" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $DISK_SIZE ]; then
        DISK_SIZE="50"
        echo -e "Disk size: $DISK_SIZE GB"
    else
        echo -e "Disk size: $DISK_SIZE GB"
    fi
else
    exit-script
fi

# Constant variables
VMID=501
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"

# Dowload the Ubuntu cloud innit image
wget -nc --directory-prefix=$IMG_LOCATION https://cloud-images.ubuntu.com/$UBUNTU_RLS/current/$UBUNTU_RLS-server-cloudimg-amd64.img

# Create a VM
qm create $VMID --cores $CORE_COUNT --cpu x86-64-v2-AES --memory $RAM --balloon 1 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $VMID $IMG_LOCATION$UBUNTU_RLS-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $VMID --scsi0 local-lvm:vm-$VMID-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk to 32 GB.
qm disk resize $VMID scsi0 "${DISK_SIZE}G" && qm set $VMID --boot order=scsi0