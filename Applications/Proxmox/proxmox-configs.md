# Useful Proxmox configurations

When installing I use `pve-new.lan` hostname.

## First time setup

Common steps when installing proxmox for the first time.

### Update repositories (no subscription, no enterprise)

Official docs: https://pve.proxmox.com/wiki/Package_Repositories

This is the recommended repository for testing and non-production use. Its packages are not as heavily tested and validated. You don’t need a subscription key to access the pve-no-subscription repository.

Configure this repository in /etc/apt/sources.list.
Add pve-no-subscription, disable pve-enterprise and update

Step 1
```bash
sed -i 's/-updates\ main\ contrib/-updates\ main\ contrib\n\n#\ pve-no-subscription-repository\ndeb\ http:\/\/download.proxmox.com\/debian\/pve\ bookworm\ pve-no-subscription/' /etc/apt/sources.list
sed -i 's/deb\ https:\/\/enterprise.proxmox.com\/debian\/pve\ bookworm\ pve-enterprise/#deb\ https:\/\/enterprise.proxmox.com\/debian\/pve\ bookworm\ pve-enterprise/' /etc/apt/sources.list.d/pve-enterprise.list
apt-get update

```
Step 2
```bash
apt-get dist-upgrade -y && reboot

```

## Clustering

Official docs: https://pve.proxmox.com/wiki/Cluster_Manager

### Kill a node and cluster

1. Identify the node ID to remove:

```bash
pvecm nodes
```
At this point, you must power off hp4 and ensure that it will not power on again (in the network) with its current configuration.

2. IMPORTANT: Set the quorum votes on the last node to 1!! 

```bash
pvecm expected 1
```


3. We can safely remove it from the cluster now. error = CS_ERR_NOT_EXIST can be ignored.

```bash
pvecm delnode pve-nodename
```

### Remove the cluster

Run on the machine where you want to remove the cluster settings

```bash
# First, stop the corosync and pve-cluster services on the node:
systemctl stop pve-cluster
systemctl stop corosync
# Start the cluster file system again in local mode:
pmxcfs -l
# Delete the corosync configuration files:
rm /etc/pve/corosync.conf
rm -r /etc/corosync/*
# You can now start the file system again as a normal service:
killall pmxcfs
systemctl start pve-cluster
```