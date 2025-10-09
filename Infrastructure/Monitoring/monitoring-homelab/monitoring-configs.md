# Monitoring configurations

## Proxmox

### Exporter

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

### Telegraf API Access

Required permissions for user and token: PVEAuditor role on /.

1. Create a `metrics` user.
2. Create API TOKEN for above user.
3. Add Permissions for user AND API Token on root / with PVEAuditor
