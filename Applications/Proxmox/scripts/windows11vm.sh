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
      if whiptail --backtitle "Install - Windows VM" --defaultno --title "SSH DETECTED" --yesno "It's suggested to use the Proxmox shell instead of SSH, since SSH can create issues while gathering variables. Would you like to proceed with using SSH?" 10 62; then
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

while read -r LSOUTPUT; do
  ISOARRAY+=("$LSOUTPUT" "" "OFF")
done < <(ls /var/lib/vz/template/iso)


if WIN_ISO=$(whiptail --backtitle "Install - Windows 11 VM" --title "ISO FILE NAME" --radiolist "\nSelect the ISO FILE NAME to install. (Use Spacebar to select)\n" --cancel-button "Exit Script" 18 90 8 "${ISOARRAY[@]}" 3>&1 1>&2 2>&3 | tr -d '"'); then
    echo -e "Selected iso: $WIN_ISO"
else
    exit-script
fi

if CORE_COUNT=$(whiptail --backtitle "Install - Windows 11 VM" --title "CORE COUNT" --radiolist "\nAllocate number of CPU Cores. (Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 2 \
    "4" "cores" ON \
    "8" "cores" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated Cores: $CORE_COUNT"
else
    exit-script
fi

if RAM_COUNT=$(whiptail --backtitle "Install - Windows 11 VM" --title "RAM COUNT" --radiolist "\nAllocate number of RAM. (Use Spacebar to select)\n" --cancel-button "Exit Script" 12 58 3 \
    "4" "GB" OFF \
    "8" "GB" ON \
    "16" "GB" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated RAM: $RAM_COUNT GB"
else
    exit-script
fi

if DISK_SIZE=$(whiptail --backtitle "Install - Ubuntu VM" --inputbox "\nSet disk size in GB" 8 58 "64" --title "DISK SIZE" --cancel-button "Exit Script" 3>&1 1>&2 2>&3); then
    if [ -z $DISK_SIZE ]; then
        DISK_SIZE="128"
        echo -e "Disk size: $DISK_SIZE GB"
    else
        echo -e "Disk size: $DISK_SIZE GB"
    fi
else
    exit-script
fi

# Constant variables
NAME="windows11"
VMID=$NEXTID
RAM=$(($RAM_COUNT * 1024))
IMG_LOCATION="/var/lib/vz/template/iso/"

# Dowload the VirtIO drivers stable for Windows
wget -nc --directory-prefix=$IMG_LOCATION https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

# Create a VM
qm create $VMID --ostype win11 --cores $CORE_COUNT --cpu x86-64-v2-AES --memory $RAM --balloon 1 --name $NAME --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 --machine q35 --tpmstate0 local-lvm:1,version=v2.0 --scsihw virtio-scsi-single --scsi0 local-lvm:$DISK_SIZE,ssd=on,iothread=on --ide0 local:iso/$WIN_ISO,media=cdrom --ide1 local:iso/virtio-win.iso,media=cdrom --net0 virtio,bridge=vmbr0,firewall=1 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1 --boot order="ide0;scsi0"
#qm create 502 --ostype win11 --cores 4 --cpu x86-64-v2-AES --memory 8192 --balloon 1 --name windows11-template --bios ovmf --efidisk0 local-lvm:1,efitype=4m,pre-enrolled-keys=1 --machine q35 --tpmstate0 local-lvm:1,version=v2.0 --scsihw virtio-scsi-single --scsi0 local-lvm:64,ssd=on,iothread=on --ide0 local:iso/cyg-en-us_windows_11_business_editions_version_23h2_x64_dvd_a9092734.iso,media=cdrom --ide1 local:iso/virtio-win.iso,media=cdrom --net0 virtio,bridge=vmbr0,firewall=1 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1 --boot order="ide0;scsi0"

