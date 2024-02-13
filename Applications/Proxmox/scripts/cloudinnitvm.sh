#! /bin/bash

# Copyright (c) 2024-2024 juronja
# Author: juronja
# License: MIT

id=501
cores=2
ram=4096
ubuntuRelease="jammy"

# Dowload the Ubuntu cloud innit image
wget -nc --directory-prefix=/var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/$ubuntuRelease/current/$ubuntuRelease-server-cloudimg-amd64.img

# Create a VM
qm create $id --cores $cores --cpu x86-64-v2-AES --memory $ram --balloon 1 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1

# Import cloud image disk
qm disk import $id /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local-lvm --format qcow2

# Map cloud image disk
qm set $id --scsi0 local-lvm:vm-501-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit

# Resize the disk to 32 GB.
qm disk resize $id scsi0 32G && qm set $id --boot order=scsi0