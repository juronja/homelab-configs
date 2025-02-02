# Home assistant configurations

# Remote access

- Add the domain in Nginx Proxy Manager with Websocket support
- In `Settings > System > Network > Home Assistant URL > Internet` add the HA domain url.


## Configuration.yaml

```yml
# Jure - customization for specific entities
homeassistant:
  customize: !include customize.yaml

# Jure - Added trust for reverse proxy
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.84.0/24
  ip_ban_enabled: true # This will block an IP after x unsuccessful login attempts.
  login_attempts_threshold: 10

```
## Customize.yaml

```yml
sensor.toplotna_energy_total:
  state_class: total_increasing
  device_class: energy
  unit_of_measurement: kWh
```

