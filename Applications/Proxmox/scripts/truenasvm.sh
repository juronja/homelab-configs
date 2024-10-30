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
if SCALE_ISO_URL=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "RELEASE ISO URL" --inputbox "\nPaste the Release ISO URL from https://download.truenas.com/ to install.\n" --cancel-button "Exit Script" 12 58 3>&1 1>&2 2>&3); then
    echo -e "Release version: $SCALE_ISO_URL"
else
    exit-script
fi

if CORE_COUNT=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "CORE COUNT" --radiolist "\nAllocate amount of CORES. (Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "2" "cores" OFF \
    "4" "cores" ON \
    "8" "cores" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated CORES: $CORE_COUNT"
else
    exit-script
fi

if RAM_COUNT=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "RAM COUNT" --radiolist "\nAllocate amount of RAM. (Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "8" "GB" OFF \
    "16" "GB" ON \
    "32" "GB" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated RAM: $RAM_COUNT GB"
else
    exit-script
fi

# Execute following actions

# Constant variables for actions
NAME="truenas-scale"
CPU="x86-64-v3"
DISK_SIZE=32
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"
VMID=$NEXTID
SCALE_ISO=${SCALE_ISO_URL##*/}

# Download the image
wget -nc --directory-prefix=$IMG_LOCATION $SCALE_ISO_URL

# Create a VM
qm create $VMID --ostype l26 --cores $CORE_COUNT --cpu $CPU --memory $RAM --balloon 0 --name $NAME --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 --machine q35 --scsihw virtio-scsi-single --scsi0 local-lvm:$DISK_SIZE,ssd=on,iothread=on --cdrom local:iso/$SCALE_ISO --net0 virtio,bridge=vmbr0,firewall=1 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Importing disks specifics
whiptail --backtitle "Install - TrueNAS SCALE VM" --defaultno --title "IMPORT DISKS?" --yesno "Would you like to import onboard disks?" 10 58 || exit

DISKARRAY=()
SCSI_NR=0

while read -r LSOUTPUT; do
  DISKARRAY+=("$LSOUTPUT" "" "OFF")
done < <(ls /dev/disk/by-id | grep -E '^ata-|^nvme-' | grep -v 'part')

SELECTIONS=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "SELECT DISKS TO IMPORT" --checklist "\nSelect disk IDs to import. (Use Spacebar to select)\n" --cancel-button "Exit Script" 20 58 10 "${DISKARRAY[@]}" 3>&1 1>&2 2>&3 | tr -d '"') || exit

for SELECTION in $SELECTIONS; do
  ((SCSI_NR++))
  qm set $VMID --scsi$SCSI_NR /dev/disk/by-id/$SELECTION
done
