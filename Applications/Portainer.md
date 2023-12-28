# Portainer configurations

## Installing

Setup instructions: https://docs.portainer.io/start/install-ce/server/docker/linux


```bash
sudo docker volume create portainer_data && sudo docker network create sol && sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --network sol --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

```

Restore settings from backup

## Stacks

### wireguard-proxy

```yml
version: '3.8'
volumes:
  etc_wireguard:
  
services:
  wg-easy:
    environment:
      # ⚠️ Required:
      # Change this to your host's public address
      - WG_HOST=pernica.duckdns.org

      # Optional:
      - PASSWORD=ENTERPASS*
      # - WG_PORT=51820
      # - WG_INTERFACE=wg0
      # - WG_DEFAULT_ADDRESS=10.8.0.x
      # - WG_DEFAULT_DNS=1.1.1.1
      # - WG_MTU=1420
      # - WG_ALLOWED_IPS=192.168.15.0/24, 10.0.1.0/24
      # - WG_PERSISTENT_KEEPALIVE=25
      # - WG_PRE_UP=echo "Pre Up" > /etc/wireguard/pre-up.txt
      # - WG_POST_UP=echo "Post Up" > /etc/wireguard/post-up.txt
      # - WG_PRE_DOWN=echo "Pre Down" > /etc/wireguard/pre-down.txt
      # - WG_POST_DOWN=echo "Post Down" > /etc/wireguard/post-down.txt
      
    image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    volumes:
      - etc_wireguard:/etc/wireguard
    restart: unless-stopped
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    networks:
      - proxy
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
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
networks:
  proxy:
    name: proxy
    external: true

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