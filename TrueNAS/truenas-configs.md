# Useful TrueNAS configurations

## S.M.A.R.T.
```bash
smartctl --scan #check SMART for all devices
smartctl -i -A --log=selftest /dev/sda #check SMART (info, attributes, selftest)
zpool status -v #check for errors in pools
zpool clear media-pool 0aac1d05-e336-4dda-acb6-bd5fedfa477b #clears the pool errors for a specific device
```