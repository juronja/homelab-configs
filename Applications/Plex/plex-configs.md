# Plex configurations

## Plex behind Nginx Proxy Manager

### Nginx settings

Add proxy host with details:

- plex domain from cloudflare
- http + IP + Port: 32400
[x] cache assets
[x] block common exploits
[x] Websockets Support

SSL tab:

[x] Set the cert
[x] Force SSL
Do not set HTTP/2 Support

### Plex settings

- Remote Access - Disable
- Network - Custom server access URLs = https://<your-domain>:443,http://<your-domain>:80
- Network - Secure connections = Preferred.

Note you can force SSL by setting required and not adding the HTTP URL, however some players which do not support HTTPS (e.g: Roku, Playstations, some SmartTVs) will no longer function.


### Plex LXC - mount SMB

When instaling a LXC container in proxmox you can mount a network Samba share drive.

1. Install cifs-utils
2. Make a directory in /mnt
2. Mount network drive with nas/share username and the right IP

```bash
apt update && apt install cifs-utils
mkdir /mnt/media
mount -t -o username=NAS_USER cifs //192.x.x.x/media /mnt/media

```