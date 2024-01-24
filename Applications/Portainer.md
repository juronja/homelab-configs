# Portainer configurations

## Installing

Setup instructions: https://docs.portainer.io/start/install-ce/server/docker/linux


```bash
sudo docker volume create portainer_data && sudo docker network create portainer && sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --network=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

```

Restore settings from backup

## Stacks

### Nginx proxy manager

```yml
version: '3.8'
services:
  proxy:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port
      # Add any other Stream port you want to expose
      # - '21:21' # FTP

    # Uncomment the next line if you uncomment anything in the section
    # environment:
      # Uncomment this if you want to change the location of
      # the SQLite DB file within the container
      # DB_SQLITE_FILE: "/data/database.sqlite"

      # Uncomment this if IPv6 is not enabled on your host
      # DISABLE_IPV6: 'true'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - proxy

```

### Services notes

#### Official notes

Nginx
instructions: https://nginxproxymanager.com/setup/#full-setup-instructions

Wireguard
https://github.com/wg-easy/wg-easy

#### Default logins

| Service | username | Password |
| --- | --- | --- |
| Nginx | admin@example.com | changeme |
| Wireguard | --- | setup in the stack |