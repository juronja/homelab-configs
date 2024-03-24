# Useful Nexus repository configurations

Admin pass is at: `/var/lib/docker/volumes/nexus_nexus/_data`

## Setup a Docker private repo

1. Create repo Docker (hosted)
2. Check HTTP, add port 8082
3. Create `docker-admin` Nexus type role
4. Add `nx-repository-view-docker-REPONAME-*` Privileges
5. Create local user and add REPONAME to Granted list
6. Add `Docker Bearer Token Realm` to Active list (Needed to issue tokens)
7. Allow insecure (http) connections for Docker login command. Add "insecure-registries" line.

```json
{
"experimental": false,
"insecure-registries": [
    "64.64.64.64:8082"
  ]
}
```
7. Authenticate with Docker CLI (user Nexus local user credentials):

`docker login 64.64.64.64:8082`

