# Code server configurations

## mount SMB

1. Install cifs-utils
2. Make directory in /mnt
3. Mount network drive with nas/share username and the right IP

```bash
apt update && apt install cifs-utils && mkdir /mnt/Development
mount -t cifs //nas.lan/personal/Development /mnt/Development -o username=NAS_USERNAME,password=NAS_PASSWORD,uid=NAS_USERNAME,gid=NAS_USERNAME
```

### Mount on system reboot with crontab

```bash
crontab -e

# Add this line:
@reboot mount -t cifs //nas.lan/personal/Development /mnt/Development -o username=NAS_USERNAME,password=NAS_PASSWORD,uid=NAS_USERNAME,gid=NAS_USERNAME
```
