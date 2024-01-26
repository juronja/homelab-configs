# Homepage configurations

Official docs: https://github.com/gethomepage/homepage

## Install


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
      - /home/juronja/appstorage/homepage_data:/app/config # Make sure your local config directory exists
      - /var/run/docker.sock:/var/run/docker.sock:ro # optional, for docker integrations
    restart: unless-stopped

```