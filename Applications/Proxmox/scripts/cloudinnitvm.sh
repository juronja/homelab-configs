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
      if whiptail --backtitle "Proxmox VE Helper Scripts" --defaultno --title "SSH DETECTED" --yesno "It's suggested to use the Proxmox shell instead of SSH, since SSH can create issues while gathering variables. Would you like to proceed with using SSH?" 10 62; then
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

if CORE_COUNT=$(whiptail --backtitle "Proxmox VM install Script" --title "CORE COUNT" --radiolist "Allocate number of CPU Cores\n(To make a selection, use the Spacebar.)\n" --cancel-button "Exit Script" 10 58 2 \
    "2" "cores" ON \
    "4" "cores" OFF \
    3>&1 1>&2 2>&3); then
        echo -e "Allocated Cores: $CORE_COUNT"
else
    exit-script
fi

read -p "How much RAM? Write whole numbers (e.g. 1,4,8,..): " raminput

# Constant variables
id=501
ram=$(($raminput * 1024))
disk="50G"
ubuntuRelease="jammy"


# Dowload the Ubuntu cloud innit image
wget -nc --directory-prefix=/var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/$ubuntuRelease/current/$ubuntuRelease-server-cloudimg-amd64.img

# Create a VM
qm create $id --cores $CORE_COUNT --cpu x86-64-v2-AES --memory $ram --balloon 1 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $id /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $id --scsi0 local-lvm:vm-$id-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk to 32 GB.
qm disk resize $id scsi0 $disk && qm set $id --boot order=scsi0