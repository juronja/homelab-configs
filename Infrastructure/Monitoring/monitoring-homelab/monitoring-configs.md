# Monitoring configurations

## Exporter setup

### Proxmox

Run this command on node:

```shell
pvesh create /cluster/metrics/server/graphite --type graphite --server homelab.lan --port 2003 --proto tcp --timeout 2
```

| Setting | Value |
| :--- | :--- |
| Name | graphite |
| Type | GRAPHITE |
| Server | homelab.lan |
| Port | 2003 |
| Protocol | TCP |
| TCP Timeout | 2 |

### TrueNAS

| Setting | Value |
| :--- | :--- |
| Name | truenas |
| Type | GRAPHITE |
| Server | homelab.lan |
| Port | 2003 |
| Namespace | truenas |
| Update Every | 10 |
| Buffer On Failures | 5 |
