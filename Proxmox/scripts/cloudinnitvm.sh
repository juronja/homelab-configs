#! /bin/bash

# Copyright (c) 2024-2024 juronja
# Author: juronja
# License: MIT

wget -nc --directory-prefix=/var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
qm create 501 --cores 2 --cpu x86-64-v2-AES --memory 4096 --balloon 1 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1
qm disk import 501 /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local-lvm --format qcow2
qm set 501 --scsi0 local-lvm:vm-501-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit
qm disk resize 501 scsi0 32G && qm set 501 --boot order=scsi0