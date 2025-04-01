# Useful TrueNAS configurations

## S.M.A.R.T.
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


## Setup SMB Share Auxiliary Parameters (For TrueCharts)

With the release of Cobia the Auxiliary Parameters has been removed from the WebUI. The below will guide you through the use of API calls and the system shell to add the correct parameters.

Open System Shell

Enter the following command:
```bash
midclt call sharing.smb.query | jq
```

Take note of the id(s) you wish to setup.

Enter the following command, make sure to replace <id> with the id from above.

```bash
midclt call sharing.smb.update <id> '{"auxsmbconf": "force user = apps\nforce group = apps"}'
```


The output should include the following if it was done correctly:

```bash
"auxsmbconf": "force user = apps\nforce group = apps",
```

Repeat for any additional SMB Shares.