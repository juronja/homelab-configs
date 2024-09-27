# Useful Nexus repository configurations

Admin pass is at: `/nexus-data/admin.password`

## Setup a Docker hosted repo

1. Create repo Docker (hosted)
2. Check HTTP, add port 8082
3. Create nexus role with id `nx-docker`
4. Add `nx-repository-view-docker-*-*` Privileges
5. Create local user and add `nx-docker` role to Granted list
6. Add `Docker Bearer Token Realm` to Active list (Needed to issue tokens)
7. Allow insecure (http) connections for Docker login command. [See below](#allow-docker-login-to-insecure-http-repos)
8. Check in linux cli if port is open `netstat -lnpt`. If installed with Docker container you have add this port to the exposed list.

```yaml
    ports:
      - "8081:8081"
      - "8082:8082" # Extra port for Docker hosted repo

```

9. Authenticate with Docker CLI (user Nexus local user credentials):

```bash
docker login 64.64.64.64:8082
```

### Allow docker login to insecure (http) repos

Add "insecure-registries" line. In the app or on Linux in this file:
`/etc/docker/daemon.json`

```json
{
"insecure-registries": [
    "64.64.64.64:8082"
  ]
}
```
Restart docker service:
```bash
systemctl restart docker
```
