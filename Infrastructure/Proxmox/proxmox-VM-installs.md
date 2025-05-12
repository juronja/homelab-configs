# Virtual Machine install manual

How to setup various VMs in Proxmox.


## Ubuntu Cloud innit VM

Copy this line in the Proxmox Shell.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Infrastructure/Proxmox/scripts/cloudinnit-vm.sh)"
```

- POST INSTALL - Edit SSH KEY cloud-innit before starting
And you are done!


## TrueNAS VM

Copy this line in the Proxmox Shell.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Infrastructure/Proxmox/scripts/truenas-vm.sh)"
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
bash -c "$(curl -fsSL https://raw.githubusercontent.com/juronja/homelab-configs/refs/heads/main/Infrastructure/Proxmox/scripts/windows11-vm.sh)"
```

- STEP 1 - Choose Enterprise edition

- STEP 2 - Load Drivers
Load virtio **disk** (amd64>w11>virtio) and **network** drivers (NetKVM>w11>amd64) when installing!

- STEP 3 - Use local account
When asked to sign in use local domain (account) option.

- STEP 4 - Install guest-agent and other virtio drivers
Run the wizard in the iso drive (qemu-ga-x86_64 and virtio-win-gt-x64.msi).

### PCIe Passthrough a GPU (WIP)

1. Make sure IOMMU is enabled on the motherboard and CPU supports it
2. With recent kernels (6.8 or newer), IOMMU is enabled by default.
3. Add these modules: `printf "\nvfio\nvfio_iommu_type1\nvfio_pci" >> /etc/modules`
4. Find vendor & device ID with: `lspci -ns 01:00 -v`
5. Disable VGA: `echo "options vfio-pci ids=10de:1f02 disable_vga=1" > /etc/modprobe.d/vfio.conf`
6. Blacklist drivers so Proxmox does not load them `printf "blacklist nouveau\nblacklist nvidia\nblacklist nvidiafb" >> /etc/modprobe.d/blacklist.conf`
7. Update `update-initramfs -u -k all`

#### Optional lines

```bash
echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf
echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf

```