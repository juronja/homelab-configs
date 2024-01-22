#! /bin/bash

# Copyright (c) 2024-2024 juronja
# Author: juronja
# License: MIT

id=501
cores=2
ram=4096
ubuntu_release="jammy"

wget -nc --directory-prefix=/var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/$ubuntu_release/current/$ubuntu_release-server-cloudimg-amd64.img
qm create $id --cores $cores --cpu x86-64-v2-AES --memory $ram --balloon 1 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1
qm disk import $id /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local-lvm --format qcow2
qm set $id --scsi0 local-lvm:vm-501-disk-0,discard=on,ssd=1 --ide2 local-lvm:cloudinit
qm disk resize $id scsi0 32G && qm set $id --boot order=scsi0