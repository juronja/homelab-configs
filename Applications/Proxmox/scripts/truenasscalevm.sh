#! /bin/bash

# Copyright (c) 2024-present juronja
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
if SCALE_RLS=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "SCALE RELEASE" --inputbox "\nType the RELEASE NAME to install\n(Case sensitive)\n" --cancel-button "Exit Script" 12 58 3>&1 1>&2 2>&3); then
    echo -e "Release version: $SCALE_RLS"
else
    exit-script
fi


if SCALE_VRS=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "SCALE VERSION" --inputbox "\nType the VERSION NUMBER to install\n" --cancel-button "Exit Script" 12 58 3>&1 1>&2 2>&3); then
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

# Execute following actions

# Constant variables for actions
CORE_COUNT=4
DISK_SIZE=32
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"
VMID=$NEXTID

# Download the image
wget -nc --directory-prefix=$IMG_LOCATION https://download.truenas.com/TrueNAS-SCALE-$SCALE_RLS/$SCALE_VRS/TrueNAS-SCALE-$SCALE_VRS.iso

# Create a VM
qm create $VMID --cores $CORE_COUNT --cpu x86-64-v2-AES --memory $RAM --balloon 0 --name truenas-scale --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import disk
qm disk import $VMID "${IMG_LOCATION}TrueNAS-SCALE-"$SCALE_VRS.iso local-lvm --format qcow2

# Map disk
qm set $VMID --scsi0 local-lvm:vm-$VMID-disk-0,ssd=1 --cdrom local:iso/TrueNAS-SCALE-$SCALE_VRS.iso

# Resize disk.
qm disk resize $VMID scsi0 "${DISK_SIZE}G" && qm set $VMID --boot order=scsi0



whiptail --backtitle "Install - TrueNAS SCALE VM" --defaultno --title "IMPORT DISKS?" --yesno "Would you like to import MB disks?" 10 58 || exit


# Importing disks

DISKARRAY=()
SCSI_NR=0

while read -r LSOUTPUT; do
  DISKARRAY+=("$LSOUTPUT" "" "OFF")
done < <(ls /dev/disk/by-id | grep -E '^ata-|^nvme-' | grep -v 'part')

SELECTIONS=$(whiptail --backtitle "Install - TrueNAS SCALE VM" --title "SELECT DISKS TO IMPORT" --checklist "\nSelect disk IDs to import\n(Use Spacebar to select)\n" --cancel-button "Exit Script" 20 58 10 "${DISKARRAY[@]}" 3>&1 1>&2 2>&3) || exit

for SELECTION in $SELECTIONS; do
  ((SCSI_NR++))
  echo "qm set 100 -scsi"$SCSI_NR" /dev/disk/by-id/"$SELECTION""
done

