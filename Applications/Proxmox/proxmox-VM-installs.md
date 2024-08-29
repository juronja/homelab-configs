# Virtual Machine install manual

How to setup various VMs in Proxmox.


## Ubuntu Cloud innit VM

Copy this line in the Proxmox Shell.

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/juronja/homelab-configs/main/Applications/Proxmox/scripts/cloudinnitvm.sh)"

```

- STEP 1 - Username and password
Set the username and password inside proxmox UI

- STEP 2 - Convert to template
Convert the created VM to template for future use.

- STEP 3 - Edit any cloud innit before starting
And you are done!

## TrueNAS SCALE VM

Copy this line in the Proxmox Shell.

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/juronja/homelab-configs/main/Applications/Proxmox/scripts/truenasscalevm.sh)"
```

### Attach Motherboard Hard disks manually

Find out the unique ID for hard disks. Filtering results having "ata-"" and "nvme-"" but excluding results containing "part".

```bash
ls /dev/disk/by-id | grep -E '^ata-|^nvme-' | grep -v 'part'
```

Attach the disks -scsi1, -scsi2, -scsi3, etc

```bash
qm set 101 -scsi1 /dev/disk/by-id/ata-Hitachi_HTS547564A9E384_J2180053HELJ4C

qm set 101 -scsi2 /dev/disk/by-id/ata-Hitachi_HTS727575A9E364_J3390084GMAGND

```

## Windows 11 VM

Copy this line in the Proxmox Shell.

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/juronja/homelab-configs/main/Applications/Proxmox/scripts/windows11vm.sh)"

```

- STEP 1 - Choose Enterprise edition
Load virtio disk and network drivers when installing.

- STEP 2 - Load Drivers
Load virtio **disk** and **network** drivers when installing!

- STEP 2 - Use local account
When asked to sign in use local domain (account) option.


