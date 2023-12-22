# Useful TrueNAS install configs on Proxmox

## Attach Hard disks

Find out the unique ID for hard disks

```bash
ls /dev/disk/by-id
```

Attach the disks

```bash
qm set 101 -scsi1 /dev/disk/by-id/ata-WDC_WD4000AAKS-00YGA0_WD-WCAS83621241
```