# Home assistant configurations

## Remote access

- Add the domain in Nginx Proxy Manager with Websocket support
- In `Settings > System > Network > Home Assistant URL > Internet` add the HA domain url.

## Configuration.yaml

```yml
# Jure - customization for specific entities
homeassistant:
  customize: !include customize.yaml
```

## Customize.yaml

```yml
sensor.toplotna_energy_total:
  state_class: total_increasing
  device_class: energy
  unit_of_measurement: kWh
```
