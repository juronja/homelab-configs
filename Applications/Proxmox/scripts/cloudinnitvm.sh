#! /bin/bash

# Copyright (c) 2024-2024 juronja
# Author: juronja
# License: MIT

echo "Starting VM script .."
read -p "How many cores?: " cores
read -p "How much RAM? Write whole numbers (e.g. 1,4,8,..): " raminput

id=501
ram=$(($raminput * 1024))
disk="32G"
ubuntuRelease="jammy"


# Dowload the Ubuntu cloud innit image
wget -nc --directory-prefix=/var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/$ubuntuRelease/current/$ubuntuRelease-server-cloudimg-amd64.img

# Create a VM
qm create $id --cores $cores --cpu x86-64-v2-AES --memory $ram --balloon 1 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $id /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $id --scsi0 local-lvm:vm-$id-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk to 32 GB.
qm disk resize $id scsi0 $disk && qm set $id --boot order=scsi0