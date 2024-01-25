# Useful TrueNAS install configs on Proxmox

## Attach Hard disks

Find out the unique ID for hard disks

```bash
ls /dev/disk/by-id
```

Attach the disks -scsi1, -scsi2, -scsi3, etc

```bash
qm set 101 -scsi1 /dev/disk/by-id/ata-Hitachi_HTS547564A9E384_J2180053HELJ4C

qm set 101 -scsi2 /dev/disk/by-id/ata-Hitachi_HTS727575A9E364_J3390084GMAGND

```