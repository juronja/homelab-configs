# Useful TrueNAS configurations

## SMART

```bash
sudo smartctl --scan #check SMART for all devices
sudo smartctl --info --attributes --log=selftest /dev/sda #check SMART (info, attributes, selftest)
```

## ZFS

Sometimes you can get ZFS DEGRADED status if you move a data cable. Run the scrub, and if no errors you can clear the ZFS status.

```bash
sudo zpool status -v #check for errors in pools
sudo zpool clear media-pool 0aac1d05-e336-4dda-acb6-bd5fedfa477b #clears the pool errors for a specific device
```
