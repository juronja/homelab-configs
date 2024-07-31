# Useful TrueNAS install configs on Proxmox

## Install TrueNas Scale

Copy this line in the Proxmox Shell.

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/juronja/homelab-configs/main/Applications/Proxmox/scripts/truenasscalevm.sh)"
```

## Attach Hard disks

Find out the unique ID for hard disks. Filtering results having "ata-"" and "nvme-"" but excluding results containing "part".

```bash
ls /dev/disk/by-id | grep -E '^ata-|^nvme-' | grep -v 'part'
```

Attach the disks -scsi1, -scsi2, -scsi3, etc

```bash
qm set 101 -scsi1 /dev/disk/by-id/ata-Hitachi_HTS547564A9E384_J2180053HELJ4C

qm set 101 -scsi2 /dev/disk/by-id/ata-Hitachi_HTS727575A9E364_J3390084GMAGND

```