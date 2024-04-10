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

### Migrate server configurations

1. Create a tar from docker volume:

```bash
tar -czvf jdata.tar.gz /var/lib/docker/volumes/jenkins_data/_data/
```

2. Copy tar to other server:

scp jdata.tar.gz root@homelab:/root

3. Unpack the tar

tar -xzvf jdata.tar.gz -C /var/lib/docker/volumes/jenkins_data/_data/