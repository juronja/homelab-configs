# Homepage configurations

## Install

Official docs: https://github.com/gethomepage/homepage

### Compose stack


### Portainer stack

Portainer creates a default app network, and prepends volume data.

Network: `homepage_default`

Volume: `homepage_` (With the example below the final volume name will be *homepage_*data)


```yml
version: "3.3"
services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    environment:
      PUID: 1000
      PGID: 1000
    ports:
      - 3000:3000
    volumes:
      - data:/app/config # Make sure your local config directory exists
      - /var/run/docker.sock:/var/run/docker.sock:ro # optional, for docker integrations
    restart: unless-stopped
volumes:
  data:
```