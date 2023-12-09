# Home assistant configurations

## Configuartion.yaml

```yml
# Jure - customization for specific entities
homeassistant:
  customize: !include customize.yaml

# Jure - Added trust for reverse proxy
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 192.168.84.0/24

```
# Customize.yaml

```yml
sensor.toplotna_energy_total:
  state_class: total_increasing
  device_class: energy
  unit_of_measurement: kWh
```

