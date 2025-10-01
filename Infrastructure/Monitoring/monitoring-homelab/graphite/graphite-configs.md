# Graphite configurations

## Adjust metric retention

⚠️ This is now automated on deploy via volume mounts in `compose.yaml`.

### Manually

1. Edit the `storage-schemas.conf` default metrics retention to:

    ```shell
    [default_1min_for_1day]
    pattern = .*
    retentions = 10s:6h,1m:6d,10m:15d
    ```

    With sed

    ```shell
    sed -i 's|retentions = 10s:6h,1m:6d,10m:1800d|retentions = 10s:6h,1m:6d,10m:15d|g' /opt/graphite/conf/storage-schemas.conf
    ```

    Check if ok:

    ```shell
    cat /opt/graphite/conf/storage-schemas.conf
    ```

2. Restart container
