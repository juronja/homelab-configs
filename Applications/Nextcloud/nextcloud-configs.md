# NextCloud configurations

Post install parameters:

```bash
occ config:system:set trusted_domains 0 --value=nextcloud.repina.eu
occ config:system:set trusted_domains 1 --value=192.168.84.11
occ config:system:set trusted_proxies 0 --value=192.168.84.24/24
occ config:system:set overwriteprotocol --value=https
occ config:system:set default_phone_region --value=SI
occ config:system:set maintenance_window_start --type=integer --value=1
occ db:add-missing-indices
```