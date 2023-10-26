# Useful Proxmox configurations

## Proxmox Cloudinit VM
This setups a cloud VM with Cloudinit.

```bash
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
qm create 501 --cores 2 --cpu host --memory 4096 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1
qm disk import 501 jammy-server-cloudimg-amd64.img local --format qcow2
qm set 501 --scsi0 local:501/vm-501-disk-0.qcow2,discard=on,ssd=1 --ide2 local:cloudinit && qm disk resize 501 scsi0 32G
qm set 501 --boot order=scsi0

```