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

