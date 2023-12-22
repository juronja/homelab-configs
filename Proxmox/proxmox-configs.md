# Useful Proxmox configurations

## First time setup

Common steps when installing proxmox for the first time.

### Update repositories (no subscription, no enterprise)

Official docs: https://pve.proxmox.com/wiki/Package_Repositories

This is the recommended repository for testing and non-production use. Its packages are not as heavily tested and validated. You don’t need a subscription key to access the pve-no-subscription repository.

Configure this repository in /etc/apt/sources.list.
Add pve-no-subscription, disable pve-enterprise and update

```bash
sed -i 's/-updates\ main\ contrib/-updates\ main\ contrib\n\n#\ pve-no-subscription-repository\ndeb\ http:\/\/download.proxmox.com\/debian\/pve\ bookworm\ pve-no-subscription/' /etc/apt/sources.list
sed -i 's/deb\ https:\/\/enterprise.proxmox.com\/debian\/pve\ bookworm\ pve-enterprise/#deb\ https:\/\/enterprise.proxmox.com\/debian\/pve\ bookworm\ pve-enterprise/' /etc/apt/sources.list.d/pve-enterprise.list
apt-get update && apt-get dist-upgrade
reboot

```

## Cloud innit VM setup
How to setup a cloud VM with Cloudinit.

### STEP 1 - Proxmox Cloudinit VM
Copy this line in the Proxmox CLI. Edit what is needed.

```bash
wget -nc --directory-prefix=/var/lib/vz/template/iso/ https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img && qm create 501 --cores 2 --cpu host --memory 4096 --balloon 0 --name ubuntu-cloud-template --scsihw virtio-scsi-pci --net0 virtio,bridge=vmbr0,firewall=1 --serial0 socket --vga serial0 --ipconfig0 ip=dhcp,ip6=dhcp --agent enabled=1 --onboot 1 && qm disk import 501 /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local --format qcow2 && qm set 501 --scsi0 local:501/vm-501-disk-0.qcow2,discard=on,ssd=1 --ide2 local:cloudinit && qm disk resize 501 scsi0 32G && qm set 501 --boot order=scsi0

```
### STEP 2 - Username and password
Set the username and password inside proxmox UI

### STEP 3 - Convert to template
Convert the created VM to template for future use.

### STEP 4 - Edit any cloud innit before starting
And you are done!