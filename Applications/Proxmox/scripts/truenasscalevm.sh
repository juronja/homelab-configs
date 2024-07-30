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
      if whiptail --backtitle "Install - TrueNAS SCALE VM" --defaultno --title "SSH DETECTED" --yesno "It's suggested to use the Proxmox shell instead of SSH, since SSH can create issues while gathering variables. Would you like to proceed with using SSH?" 10 62; then
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

if SCALE_RLS=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "SCALE RELEASE" --radiolist "\nChoose the SCALE RELEASE to install\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
    "Dragonfish" "test" ON \
    3>&1 1>&2 2>&3); then
        echo -e "SCALE RELEASE: $SCALE_RLS"
else
    exit-script
fi

# Whiptail inputs
if SCALE_VRS=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "SCALE VERSION" --radiolist "\nChoose the SCALE VERSION to install\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
    "24.04.2" ON \
    3>&1 1>&2 2>&3); then
        echo -e "SCALE VERSION: $SCALE_VRS"
else
    exit-script
fi


if RAM_COUNT=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "RAM COUNT" --radiolist "\nAllocate number of RAM\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "8" "GB" OFF \
    "16" "GB" ON \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated RAM: $RAM_COUNT GB"
else
    exit-script
fi

# Constant variables
VMID=100
CORE_COUNT=4
DISK_SIZE=32
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"

# Dowload the Ubuntu cloud innit image
wget -nc --directory-prefix=$IMG_LOCATION https://download.truenas.com/TrueNAS-SCALE-$SCALE_RLS/$SCALE_VRS/TrueNAS-SCALE-$SCALE_VRS.iso

# Create a VM
qm create $VMID --cores $CORE_COUNT --cpu x86-64-v2-AES --memory $RAM --balloon 1 --name truenas-scale-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
#qm disk import $VMID $IMG_LOCATIONTrueNAS-SCALE-$SCALE_VRS.iso local-lvm --format qcow2

# Map cloud image disk
#qm set $VMID --scsi0 local-lvm:vm-$VMID-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk to 32 GB.
#qm disk resize $VMID scsi0 "${DISK_SIZE}G" && qm set $VMID --boot order=scsi0