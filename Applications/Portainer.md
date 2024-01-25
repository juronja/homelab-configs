# Portainer configurations

## Installing

Setup instructions: https://docs.portainer.io/start/install-ce/server/docker/linux


```bash
sudo docker network create portainer && sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --network=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

```

Restore settings from backup