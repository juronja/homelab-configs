# Nginx configurations

## Install

Official docs: https://nginxproxymanager.com/setup/

### Compose

```yml
version: '3.8'
services:
  app:
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

```

### Default Administrator User
U: `admin@example.com`
P: `changeme`


## Configs

Good guide: https://www.youtube.com/watch?v=qlcVx-k-02E

### SSL Certificates

Create a cert with DNS challenge.

Domain names: repina.eu *.repina.eu

Provider Clouflare

Create and use zone DNS token:
https://dash.cloudflare.com/profile/api-tokens

1. Token name: Give it a name
2. Permissions: Zone, DNS, Edit
3. Zone Resources: Include, All zones

Propagation Seconds
120

### Proxy Hosts Example

#### Details

Domain names: wg.repina.eu
Scheme: choose
IP: Server IP
FWD port: app port
- [x] block common exploits
- [x] Websockets # Home Assistant needs it

#### SSL
Choose the cert
- [x] Force SSL
- [x] HTTP/2 Support