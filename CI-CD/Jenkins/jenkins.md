# Useful Jenkins repository configurations

## Plugins and Tools

Install default plugins. The logic is that you install the plugin first and **then set it up in the Tools section**.

### Docker specifics
Docker access is mounted already via container. But you have to give permissions to the "jenkins" user inside the container.

Login to the container and give read/write permissions to "Others". This will allow jenkins user to run docker commands.

```bash
sudo docker exec -ti -u root jenkins bash
chmod 666 /var/run/docker.sock
```

NOTE: Each reboot or restart of docker service this will reset back to defaults.