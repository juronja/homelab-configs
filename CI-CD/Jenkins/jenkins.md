# Useful Jenkins configurations

## Plugins and Tools

Install default plugins. The logic is that you install the plugin first and **then set it up in the Tools section**.

### Useful plugins

- NodeJS Plugin


```shell
# 1. Configure tool in Tools 
# 2. Add to the pipeline like this and use commands in any stage

pipeline {
    agent any
    tools {
        nodejs 'NodeJS_v20' // adds NPM commands
    }
}

# Example stage
stage('Build app with Vite') {
    steps {
        echo "Building App with Vite ..."
        sh "npm install"    
        sh "npm run build"
    }
}

```

- Multibranch Scan Webhook Trigger
- Version Number Plugin (useful in builds for versioning)

### Enable Docker
Docker access is mounted already via compose file. But you have to give permissions to the `jenkins` user inside the container to use docker commands by giving read/write permissions to `Others`.

```bash
sudo docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

⚠️ NOTE: Each reboot or restart of docker service this will reset back to defaults.

For Host reboot you can automate this with `crontab -e`. And then add this code at the end:
```bash
@reboot sudo docker exec -u root jenkins chmod 666 /var/run/docker.sock
```


## Migrate server configurations (untested)

1. Create a tar from docker volume:

```bash
sudo tar -czvf jdata.tar.gz /var/lib/docker/volumes/jenkins_data/_data/
```

2. Copy tar to other server:

```bash
scp -i ~/.ssh/id_rsa.pub jdata.tar.gz user@homelab:/home/user/apps
```

3. Unpack the tar

```bash
sudo tar -xzvf jdata.tar.gz -C /var/lib/docker/volumes/jenkins_data/_data/
```

