# Code server configurations

<https://coder.com/docs/code-server/install>

## mount SMB

1. Install cifs-utils
2. Make directory in /apps
3. Mount network drive with nas/share username and the right domain

```bash
apt update && apt install cifs-utils && mkdir /apps/code-server
mount -t cifs //nas.lan/personal/Development /apps/code-server -o username=NAS_USERNAME,password=NAS_PASSWORD,uid=LINUX_USERNAME,gid=LINUX_USERNAME
```

### Mount on system reboot with fstab (Recommended)

```shell
sudo sed -i '$a //nas.lan/personal/Development /home/juronja/apps/code-server cifs username=NAS_USERNAME,password=NAS_PASSWORD,uid=LINUX_USERNAME,gid=LINUX_USERNAME,_netdev 0 0' /etc/fstab
```

### Mount on system reboot with crontab

```bash
crontab -e

# Add this line:
@reboot mount -t cifs //nas.lan/personal/Development /apps/code-server -o username=NAS_USERNAME,password=NAS_PASSWORD,uid=LINUX_USERNAME,gid=LINUX_USERNAME
```